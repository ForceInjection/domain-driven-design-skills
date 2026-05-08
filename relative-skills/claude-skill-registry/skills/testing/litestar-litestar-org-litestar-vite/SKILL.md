---
name: litestar
description: Expert knowledge for Litestar Python web framework. Use when working with Litestar routes, plugins, middleware, dependency injection, or configuration.
---

# Litestar Framework Skill

## Quick Reference

### Plugin Development

```python
from litestar.plugins import InitPluginProtocol
from litestar import Litestar

class MyPlugin(InitPluginProtocol):
    def __init__(self, config: MyConfig) -> None:
        self.config = config

    def on_app_init(self, app_config: AppConfig) -> AppConfig:
        """Modify app config during initialization."""
        app_config.state["my_plugin"] = self
        return app_config
```

### Route Handlers

```python
from litestar import get, post, Controller
from litestar.di import Provide

@get("/items/{item_id:int}")
async def get_item(item_id: int) -> Item:
    return await fetch_item(item_id)

class ItemController(Controller):
    path = "/items"
    dependencies = {"service": Provide(get_service)}

    @get("/")
    async def list_items(self, service: ItemService) -> list[Item]:
        return await service.list_all()
```

### Dependency Injection

```python
from litestar.di import Provide

def get_db_session(state: State) -> AsyncSession:
    return state.db_session

@get("/", dependencies={"session": Provide(get_db_session)})
async def handler(session: AsyncSession) -> Response:
    ...
```

### Middleware

```python
from litestar.middleware import AbstractMiddleware
from litestar.types import ASGIApp, Receive, Scope, Send

class MyMiddleware(AbstractMiddleware):
    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        # Pre-processing
        await self.app(scope, receive, send)
        # Post-processing
```

## Project-Specific Patterns

This project uses:
- **Type hints**: PEP 604 (`T | None`)
- **Async/await**: For all I/O operations
- **Google-style docstrings**: For all public APIs
- **No `from __future__ import annotations`**

## Context7 Lookup

```python
mcp__context7__get-library-docs(
    context7CompatibleLibraryID="/litestar-org/litestar",
    topic="plugins middleware dependency-injection",
    mode="code"
)
```

## Related Files

- `src/py/litestar_vite/plugin.py` - VitePlugin implementation
- `src/py/litestar_vite/config.py` - ViteConfig
- `src/py/litestar_vite/inertia/plugin.py` - InertiaPlugin
