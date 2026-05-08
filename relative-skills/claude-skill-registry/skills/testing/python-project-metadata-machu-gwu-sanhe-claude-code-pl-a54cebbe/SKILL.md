---
name: python-project-metadata
description: Use when exploring Python project structure, finding virtualenv paths (python/pip/pytest), or locating package metadata (name, version, pyproject.toml).
---

# python-project-metadata

Runs `uvx --from shai-py==0.1.1 shai-py project-info` to automatically detect and display Python project metadata:

- Package name and version from pyproject.toml
- Virtual environment paths (python, pip, pytest executables)
- Project directories (package root, tests, docs)
- Configuration files (Sphinx conf.py, mise.toml)
