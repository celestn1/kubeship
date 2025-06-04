# kubeship/microservices/auth-service/app/main.py

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.db import database, engine, Base
from app.models.user import User
from app.routers import auth

app = FastAPI(title="KubeShip Auth Service with PostgreSQL")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def startup():
    # Create tables if they don't exist
    Base.metadata.create_all(bind=engine)
    await database.connect()

@app.on_event("shutdown")
async def shutdown():
    await database.disconnect()

app.include_router(auth.router, prefix="/auth")

@app.get("/")
def root():
    return {"message": "Auth service with PostgreSQL is running"}
