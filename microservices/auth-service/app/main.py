# kubeship/microservices/auth-service/app/main.py

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from app.db import database, engine, Base
from app.routers import auth
from app.routers import profile
from app.utils import error_handler

app = FastAPI(title="KubeShip Auth Service with PostgreSQL")

app.include_router(profile.router, prefix="/auth")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_exception_handler(HTTPException, error_handler.http_exception_handler)
app.add_exception_handler(RequestValidationError, error_handler.validation_exception_handler)

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
