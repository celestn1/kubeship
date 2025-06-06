# kubeship/microservices/auth-service/app/routers/auth.py

from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, EmailStr
from sqlalchemy.orm import Session
from sqlalchemy import or_
from passlib.context import CryptContext
from datetime import datetime, timedelta
from typing import Optional
import jwt

from app.db import SessionLocal
from app.models.user import User as UserModel

router = APIRouter()

SECRET_KEY = "kubeship_secret"
ALGORITHM = "HS256"
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class LoginRequest(BaseModel):
    username: str
    password: str

class UserRegister(BaseModel):
    firstname: str
    lastname: str
    email: EmailStr
    username: str
    password: str


class Token(BaseModel):
    access_token: str
    token_type: str


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=15))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/check")
def check_availability(email: str = None, username: str = None, db: Session = Depends(get_db)):
    if email:
        exists = db.query(UserModel).filter(UserModel.email == email).first()
        if exists:
            return {"available": False, "field": "email"}

    if username:
        exists = db.query(UserModel).filter(UserModel.username == username).first()
        if exists:
            return {"available": False, "field": "username"}

    return {"available": True}


@router.post("/register")
def register(user: UserRegister, db: Session = Depends(get_db)):
    # Check for existing email or username
    existing = db.query(UserModel).filter(
        (UserModel.email == user.email) | (UserModel.username == user.username)
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email or username already exists")

    hashed_pw = pwd_context.hash(user.password)

    db_user = UserModel(
        email=user.email,
        username=user.username,
        hashed_password=hashed_pw,
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
        or_(
            UserModel.email == user.username,
            UserModel.username == user.username
        )
    ).first()

    if not db_user:
        raise HTTPException(status_code=401, detail="Email or username not found")

    if not pwd_context.verify(user.password, db_user.hashed_password):
        raise HTTPException(status_code=401, detail="Incorrect password")

    token = create_access_token({
        "sub": db_user.email,
        "firstname": db_user.firstname
    }, expires_delta=timedelta(hours=1))

    return {"access_token": token, "token_type": "bearer"}

@router.get("/verify")
def verify_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return {
            "valid": True,
            "email": payload.get("sub"),
            "firstname": payload.get("firstname")
        }
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")
