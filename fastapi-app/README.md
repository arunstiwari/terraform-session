# fastapi-app

A minimal FastAPI app used to demo the `python-action-setup` composite action.

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements-dev.txt

uvicorn app.main:app --reload          # http://localhost:8000/api/greeting?name=Arun
pytest --cov                            # unit tests + coverage
```
