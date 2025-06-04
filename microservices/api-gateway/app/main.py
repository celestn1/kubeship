# kubeship/microservices/api-gateway/app/main.py

import os
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from app.routers import health
import httpx
from dotenv import load_dotenv
from fastapi.responses import JSONResponse

# Load environment variables from .env
load_dotenv()

app = FastAPI(title="KubeShip API Gateway")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health.router)

# Load AUTH_SERVICE_URL from .env
AUTH_SERVICE_URL = os.getenv("AUTH_SERVICE_URL", "http://localhost:8001")

@app.get("/")
def root():
    return {"message": "KubeShip API Gateway is up!"}

@app.post("/auth/register")
async def proxy_register(request: Request):
    data = await request.json()
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(f"{AUTH_SERVICE_URL}/auth/register", json=data)
            return JSONResponse(status_code=response.status_code, content=response.json())
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})

@app.post("/auth/login")
async def proxy_login(request: Request):
    data = await request.json()
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(f"{AUTH_SERVICE_URL}/auth/login", json=data)
            return JSONResponse(status_code=response.status_code, content=response.json())
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})
    
@app.get("/auth/verify")
async def proxy_verify(token: str):
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{AUTH_SERVICE_URL}/auth/verify", params={"token": token})
    return response.json()
