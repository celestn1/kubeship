# kubeship/microservices/auth-service/app/main.py

import os
import redis
import logging # For debugging purposes
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from app.utils.redis_client import redis_client
from app.db import database, engine, Base
from app.routers import auth, profile
from app.utils import error_handler

app = FastAPI(title="KubeShip Auth Service with PostgreSQL")
REDIS_URL = os.environ.get("REDIS_URL")

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

# === Startup ===
@app.on_event("startup")
async def startup():
    global redis_client
    Base.metadata.create_all(bind=engine)
    await database.connect()

    if REDIS_URL:
        redis_client = redis.Redis.from_url(REDIS_URL, decode_responses=True)
        # Optionally test connection
        try:
            redis_client.ping()
            print("[INFO] Connected to Redis")
        except redis.RedisError as e:
            print("[ERROR] Redis connection failed:", e)
    else:
        print("[WARN] REDIS_URL is not set")

# === Shutdown ===
@app.on_event("shutdown")
async def shutdown():
    await database.disconnect()
    if redis_client:
        try:
            redis_client.close()
            print("[INFO] Redis connection closed")
        except Exception as e:
            print("[WARN] Failed to close Redis connection:", e)

# Versioned routes under /v1/auth/
auth_router = FastAPI()
auth_router.include_router(auth.router, prefix="/auth")
auth_router.include_router(profile.router, prefix="/profile")
app.mount("/v1", auth_router)

# Health check
@app.get("/")
def root():
    return {"message": "Auth service with PostgreSQL is running"}
