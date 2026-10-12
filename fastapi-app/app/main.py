from fastapi import FastAPI

from app.greeting import greet

app = FastAPI(title="fastapi-app")


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "UP"}


@app.get("/api/greeting")
def greeting(name: str | None = None) -> dict[str, str]:
    return {"message": greet(name)}
