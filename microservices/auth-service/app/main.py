# kubeship/microservices/auth-service/app/main.py

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError

from app.db import database, engine, Base
from app.routers import auth, profile
from app.utils import error_handler

app = FastAPI(title="KubeShip Auth Service with PostgreSQL")

# CORS – Replace * with specific origin in production
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Error handlers
app.add_exception_handler(HTTPException, error_handler.http_exception_handler)
app.add_exception_handler(RequestValidationError, error_handler.validation_exception_handler)

# Database startup/shutdown
@app.on_event("startup")
async def startup():
    Base.metadata.create_all(bind=engine)
    await database.connect()

@app.on_event("shutdown")
async def shutdown():
    await database.disconnect()

# Versioned routes under /v1/auth/
auth_router = FastAPI()
auth_router.include_router(auth.router, prefix="/auth")
auth_router.include_router(profile.router, prefix="/profile")
app.mount("/v1", auth_router)

# Health/root check
@app.get("/")
def root():
    return {"message": "Auth service with PostgreSQL is running"}
