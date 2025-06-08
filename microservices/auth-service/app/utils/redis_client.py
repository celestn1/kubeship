# kubeship/microservices/auth-service/app/utils/redis_client.py

import os
import redis

REDIS_URL = os.environ.get("REDIS_URL")

if not REDIS_URL:
    raise ValueError("REDIS_URL is not defined in environment variables.")

try:
    redis_client = redis.Redis.from_url(REDIS_URL, decode_responses=True)
    # Optional connection test
    redis_client.ping()
    print("[INFO] Connected to Redis from redis_client.py")
except redis.RedisError as e:
    raise ConnectionError(f"[ERROR] Could not connect to Redis: {e}")
