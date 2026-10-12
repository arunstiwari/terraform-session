def greet(name: str | None = None) -> str:
    if name is None or not name.strip():
        return "Hello, World!"
    return f"Hello, {name.strip()}!"
