# kubeship/microservices/auth-service/app/dependencies.py

import os
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from jose import JWTError, jwt
from app.db import SessionLocal
from app.models.user import User
from app.utils.redis_client import redis_client


# === Environment ===
JWT_SECRET_KEY = os.environ.get("JWT_SECRET_KEY")
JWT_ALGORITHM = os.environ.get("JWT_ALGORITHM", "HS256")
REDIS_URL = os.environ.get("REDIS_URL")

if not JWT_SECRET_KEY or not REDIS_URL:
    raise ValueError("JWT_SECRET_KEY or REDIS_URL is missing in environment variables.")

# === Security ===
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
) -> User:
    try:
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[JWT_ALGORITHM])
        jti = payload.get("jti")
        if jti:
            if redis_client.get(f"blacklist:{jti}"):
                raise HTTPException(status_code=401, detail="Token has been revoked")

        username = payload.get("sub")
        if not username:
            raise HTTPException(status_code=401, detail="Invalid token payload")
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")

    user = db.query(User).filter(User.email == username).first()
    if user is None:
        raise HTTPException(status_code=401, detail="User not found")

    return user
