---
name: integrations
description: External API integrations with OAuth2, async HTTP, and proper error handling
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: integrations
---

## What I do

- Create external API integration clients
- Implement OAuth2 authentication flows
- Build async HTTP clients with proper error handling
- Handle rate limiting, retries, and connection pooling

## When to use me

Use this when you need to:
- Add a new external API integration
- Implement OAuth2 authentication
- Create async HTTP clients
- Handle API errors gracefully

## MCP-First Workflow

Always use MCP servers in this order:

1. **codebase** - Search for integration patterns
   ```python
   search_codebase("OAuth2 async HTTP client REST API patterns", top_k=10)
   ```

2. **filesystem** - view_file existing clients
   ```python
   read_file("src/casare_rpa/infrastructure/clients/base.py")
   ```

3. **git** - Check similar integrations
   ```python
   git_log("--oneline", path="src/casare_rpa/infrastructure/clients/")
   ```

4. **exa** - API documentation research
   ```python
   web_search("OAuth2 best practices 2025", num_results=5)
   ```

5. **ref** - Official API docs
   ```python
   search_documentation("API", library="google-auth")
   ```

## Integration Pattern

```python
from casare_rpa.infrastructure.clients.base import BaseAsyncClient

class ServiceNameClient(BaseAsyncClient):
    """Client for Service API."""

    BASE_URL = "https://api.service.com/v1"

    async def authenticate(self) -> None:
        """Setup authentication."""
        pass

    async def make_request(self, method: str, endpoint: str, **kwargs) -> dict:
        """Make authenticated API request."""
        url = f"{self.BASE_URL}/{endpoint}"
        async with self.session.request(method, url, **kwargs) as resp:
            resp.raise_for_status()
            return await resp.json()
```

## Error Handling

```python
from casare_rpa.infrastructure.exceptions import RateLimitError, AuthenticationError

try:
    result = await client.call_api()
except RateLimitError:
    await asyncio.sleep(self.retry_delay)
    result = await client.call_api()
except AuthenticationError:
    await client.refresh_token()
    result = await client.call_api()
```

## OAuth2 Flow

```python
from google.oauth2.credentials import Credentials
from google.auth.transport.requests import Request

async def get_creds(token_data: dict) -> Credentials:
    creds = Credentials(**token_data)
    if creds.expired:
        await creds.refresh(Request())
    return creds
```

## Best Practices

1. Use async for all network operations
2. Implement retry with exponential backoff
3. Handle rate limits gracefully
4. Store credentials securely (env vars)
5. Log API calls for debugging
6. Use connection pooling
