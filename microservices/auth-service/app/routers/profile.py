# kubeship/microservices/auth-service/app/routers/profile.py

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.dependencies import get_current_user, get_db
from app.models.user import User, UserProfile

router = APIRouter()

class UpdateProfileRequest(BaseModel):
    avatar_url: str | None = None
    bio: str | None = None
    location: str | None = None
    website: str | None = None
    skills: str | None = None

@router.get("/profile")
def get_profile(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    return current_user.profile

@router.put("/profile")
def update_profile(payload: UpdateProfileRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    profile = current_user.profile
    for field, value in payload.dict(exclude_unset=True).items():
        setattr(profile, field, value)
    db.commit()
    db.refresh(profile)
    return {"message": "Profile updated successfully ✅"}
