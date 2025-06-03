from fastapi import FastAPI
app = FastAPI()
@app.get("/auth")
def auth():
    return {"auth": "OK"}