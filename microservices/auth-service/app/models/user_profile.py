# kubeship/microservices/auth-service/app/models/user_profile.py

from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.sql import func
from app.db import Base

class UserProfile(Base):
    __tablename__ = "users_profile"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    avatar_url = Column(String, nullable=True)
    bio = Column(String, nullable=True)
    location = Column(String, nullable=True)
    website = Column(String, nullable=True)
    interests = Column(String, nullable=True)  # Stored as CSV or JSON
    joined_date = Column(DateTime(timezone=True), server_default=func.now())
