# kubeship/microservices/auth-service/app/routers/auth.py

import os
import jwt
import uuid
from datetime import datetime, timedelta
from fastapi import APIRouter, HTTPException, Depends, Request
from pydantic import BaseModel, EmailStr
from sqlalchemy.orm import Session
from sqlalchemy import or_
from passlib.context import CryptContext
from app.utils.redis_client import redis_client
from app.db import SessionLocal
from app.models.user import User as UserModel
from typing import Optional
from app.utils.logger import logger # Importing logger for debugging
from app.models.strict_base import StrictModel # Custom base model for strict validation

# === Load Environment ===
JWT_SECRET_KEY = os.environ.get("JWT_SECRET_KEY")
JWT_ALGORITHM = os.environ.get("JWT_ALGORITHM", "HS256")
REDIS_URL = os.environ.get("REDIS_URL")

if not JWT_SECRET_KEY or not REDIS_URL:
    raise ValueError("Missing JWT_SECRET_KEY or REDIS_URL in environment variables.")

# === Security ===
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

router = APIRouter()

# === Models ===
class EmailRequest(StrictModel):
    email: EmailStr

class ResetPasswordRequest(StrictModel):
    token: str
    password: str

class LoginRequest(StrictModel):
    username: str
    password: str

class UserRegister(StrictModel):
    firstname: str
    lastname: str
    email: EmailStr
    username: str
    password: str 

class Token(StrictModel):
    access_token: str
    token_type: str

# === Helpers ===
def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    jti = str(uuid.uuid4())
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=15))
    to_encode.update({"exp": expire, "jti": jti})
    return jwt.encode(to_encode, JWT_SECRET_KEY, algorithm=JWT_ALGORITHM)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# === Endpoints ===

@router.get("/check")
def check_availability(email: str = None, username: str = None, db: Session = Depends(get_db)):
    if email:
        if db.query(UserModel).filter(UserModel.email == email).first():
            return {"available": False, "field": "email"}
    if username:
        if db.query(UserModel).filter(UserModel.username == username).first():
            return {"available": False, "field": "username"}
    return {"available": True}

@router.post("/register")
def register(user: UserRegister, db: Session = Depends(get_db)):
    if db.query(UserModel).filter((UserModel.email == user.email) | (UserModel.username == user.username)).first():
        raise HTTPException(status_code=400, detail="Email or username already exists")

    db_user = UserModel(
        email=user.email,
        username=user.username,
        hashed_password=pwd_context.hash(user.password),
        firstname=user.firstname,
        lastname=user.lastname,
    )

    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    return {"message": "User registered successfully"}

@router.post("/login", response_model=Token)
def login(user: LoginRequest, db: Session = Depends(get_db)):
    db_user = db.query(UserModel).filter(
        or_(UserModel.email == user.username, UserModel.username == user.username)
    ).first()

    if not db_user or not pwd_context.verify(user.password, db_user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    token = create_access_token({
        "sub": db_user.email,
        "firstname": db_user.firstname
    }, expires_delta=timedelta(hours=1))

    return {"access_token": token, "token_type": "bearer"}

@router.get("/verify-token")
def verify_token_bearer(request: Request):
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or invalid authorization header")

    token = auth_header.split(" ")[1]
    try:
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[JWT_ALGORITHM])
        return {
            "valid": True,
            "email": payload.get("sub"),
            "firstname": payload.get("firstname")
        }
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")

# === Request Password Reset ===
@router.post("/request-password-reset")
def request_password_reset(req: EmailRequest, db: Session = Depends(get_db)):
    user = db.query(UserModel).filter(UserModel.email == req.email).first()
    if not user:
        return {"message": "If that email exists, a reset link has been sent."}

    # Create token
    token_data = {
        "sub": user.email,
        "purpose": "password_reset"
    }
    token = jwt.encode(
        {**token_data, "exp": datetime.utcnow() + timedelta(minutes=60)},
        JWT_SECRET_KEY,
        algorithm=JWT_ALGORITHM
    )

    # Save to Redis with 1 hour TTL
    redis_client.setex(f"reset:{token}", 3600, user.email)

    # Simulate email
    reset_link = f"http://localhost:3001/reset-password/{token}"
    logger.info(f"[DEBUG-Logger] Password reset link for {user.email}: {reset_link}")
    # print(f"[DEBUG-Print] Reset link for {user.email}: {reset_link}")

    return {"message": "If that email exists, a reset link has been sent."}

# === Reset Password ===
@router.post("/reset-password")
def reset_password(req: ResetPasswordRequest, db: Session = Depends(get_db)):
    try:
        payload = jwt.decode(req.token, JWT_SECRET_KEY, algorithms=[JWT_ALGORITHM])
        token_email = payload.get("sub")
        redis_key = f"reset:{req.token}"
        redis_email = redis_client.get(redis_key)

        if not redis_email or token_email != redis_email or payload.get("purpose") != "password_reset":
            raise HTTPException(status_code=400, detail="Invalid or expired reset token")
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=400, detail="Reset token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=400, detail="Invalid reset token")

    user = db.query(UserModel).filter(UserModel.email == token_email).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.hashed_password = pwd_context.hash(req.password)
    db.commit()

    redis_client.delete(redis_key)
    return {"message": "Password updated successfully"}