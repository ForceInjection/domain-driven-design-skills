---
name: Python
description: Python coding standards, best practices, type hints, and testing patterns. Use when writing or reviewing Python code, implementing tests, or discussing Python language features.
---
# Python

- Use the latest Python language features appropriate for the project's minimum supported version.

## Package Management

- Use `uv` for dependency management and package execution instead of virtual environments.
- Run scripts with `uv run <script>`.
- Add dependencies with `uv add <package>`.

## Documentation

When users ask about Python standard library modules, use `WebFetch` to get the latest official documentation from `docs.python.org`.

Example:
- For `asyncio`: `https://docs.python.org/3/library/asyncio.html`
- For `typing`: `https://docs.python.org/3/library/typing.html`
- For `pathlib`: `https://docs.python.org/3/library/pathlib.html`

Pattern: `https://docs.python.org/3/library/<module>.html`

## Type Hints

- **Always** use type hints for function signatures, class attributes, and variables where the type is not immediately obvious.
- **Avoid** using `Any` type. Use specific types, `TypeVar`, or protocols instead.
- **Avoid** using `# type: ignore` comments except in rare cases, mainly in test code.
- Use `from __future__ import annotations` for forward references and cleaner type hints.
- Prefer `list[T]`, `dict[K, V]`, `set[T]`, `tuple[T, ...]` over `typing.List`, `typing.Dict`, etc. (Python 3.9+).

Example:
```python
from __future__ import annotations

def process_items(items: list[str], max_count: int | None = None) -> dict[str, int]:
    """Process items and return a count dictionary."""
    result: dict[str, int] = {}
    for item in items[:max_count]:
        result[item] = result.get(item, 0) + 1
    return result
```

## Tests

Write parametrized tests using `pytest`:

```python
import pytest

@pytest.mark.parametrize(
    ("input_value", "expected"),
    [
        ("hello", "HELLO"),
        ("world", "WORLD"),
        ("", ""),
    ],
)
def test_uppercase(input_value: str, expected: str) -> None:
    assert my_function(input_value) == expected
```

- Use descriptive parameter names in test cases.
- Type hint test functions with `-> None`.
- Group related tests in classes when appropriate.
- Use fixtures for shared setup and teardown.

## Code Style

- Follow PEP 8 conventions.
- Use f-strings for string formatting.
