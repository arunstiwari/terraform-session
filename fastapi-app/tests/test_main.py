from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "UP"}


def test_returns_greeting_for_name():
    response = client.get("/api/greeting", params={"name": "Arun"})
    assert response.status_code == 200
    assert response.json() == {"message": "Hello, Arun!"}


def test_returns_default_greeting():
    response = client.get("/api/greeting")
    assert response.status_code == 200
    assert response.json() == {"message": "Hello, World!"}
