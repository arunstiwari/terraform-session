import pytest

from app.greeting import greet


def test_greets_by_name():
    assert greet("Arun") == "Hello, Arun!"


def test_trims_whitespace():
    assert greet("  Arun  ") == "Hello, Arun!"


@pytest.mark.parametrize("name", [None, "", "   "])
def test_falls_back_to_world_when_name_missing(name):
    assert greet(name) == "Hello, World!"
