---
name: version
description: Search and fetch the latest version of a Go or Python package.
license: Complete terms in LICENSE.txt
---

# Version Fetcher Skill

Fetch latest package versions for Go and Python packages.

## Tools

### get_go_version
Fetch the latest version of a Go package/module.

**Example:** `get_go_version github.com/gin-gonic/gin`

```bash
bash scripts/go-version.sh "$PACKAGE"
```

**Parameters:**
- `PACKAGE` (required): Go module path (e.g., github.com/gin-gonic/gin)

#### Alternative

Get the latest version of all the go mod files using `go list -m -u all`

---

### get_python_version
Fetch the latest version of a Python package from PyPI.

**Example:** `get_python_version requests`

```bash
bash scripts/python-version.sh "$PACKAGE"
```

**Parameters:**
- `PACKAGE` (required): Python package name (e.g., requests, numpy)

