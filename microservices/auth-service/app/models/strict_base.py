# kubeship/microservices/auth-service/app/models/strict_base.py
# project-wide protection for all Pydantic request models by using a custom base class.

from pydantic import BaseModel

class StrictModel(BaseModel):
    class Config:
        extra = "forbid"
