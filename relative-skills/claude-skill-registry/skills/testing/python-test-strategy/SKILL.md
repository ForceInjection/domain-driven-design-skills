---
name: python-test-strategy
description: Python unit testing patterns for pytest, including test file structure, fixtures, mocks, and coverage strategy. Use when asked to write tests (unit/integration) for any Python module, function, class, or method.
---

# python-test-strategy

Organized testing strategy for Python projects: test file naming, coverage goals (95%+), and public API testing.

## Quick Start

**Find test location for any source file:**

When being asked to write tests for a specific source file, use the following command to determine the correct test file path based on established naming conventions:

```bash
uvx --from shai-py==0.1.1 shai-py test-path /path/to/my_package/subpackage/module.py
```

**Run tests:**
- Individual file: `.venv/bin/python tests/subpackage/test_*.py`
- Package: `.venv/bin/python tests/subpackage/all.py`
- All: `.venv/bin/python tests/all.py`

## Key Patterns

- **Test files mirror source**: `source/<pkg>/<module>.py` → `tests/<pkg>/test_<pkg>_<module>.py`
- **Coverage goal**: 95%+ for all implementation files
- **Public API**: Export all public interfaces in `api.py`, test in `tests/test_api.py`

## References

- 🎯 [Naming & File Location](./reference/naming.md)
- 📊 [Coverage Setup](./reference/coverage.md)
- 🔌 [Public API Testing](./reference/public-api.md)
