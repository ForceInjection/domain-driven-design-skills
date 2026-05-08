---
name: jwt-auth
description: Configure JWT Bearer authentication with Keycloak for affolterNET.Web.Api. Use when setting up token validation, Keycloak integration, or API authentication.
---

# JWT Bearer Authentication

Configure JWT Bearer authentication with Keycloak integration.

For complete reference, see [Library Guide](../../LIBRARY_GUIDE.md).

## Quick Start

### appsettings.json

```json
{
  "affolterNET": {
    "Web": {
      "Auth": {
        "Provider": {
          "Authority": "https://keycloak.example.com/realms/myrealm",
          "ClientId": "my-api-client",
          "ClientSecret": "your-client-secret"
        }
      }
    }
  }
}
```

### Program.cs

```csharp
var options = builder.Services.AddApiServices(isDev, builder.Configuration, opts => {
    opts.ConfigureApi = api => {
        api.AuthMode = AuthenticationMode.Authenticate;
    };
});
```

## Authentication Modes

| Mode | Description |
|------|-------------|
| `None` | No authentication required |
| `Authenticate` | Valid JWT required, no permission checks |
| `Authorize` | Valid JWT + Keycloak RPT permissions required |

## Configuration Options

### AuthProviderOptions

| Property | Description |
|----------|-------------|
| `Authority` | Keycloak realm URL |
| `ClientId` | OIDC client identifier |
| `ClientSecret` | OIDC client secret |
| `Audience` | Expected JWT audience (optional) |

## Permission-Based Authorization

When using `AuthenticationMode.Authorize`:

```csharp
[Authorize(Policy = "admin-resource")]
[HttpGet("admin")]
public IActionResult AdminOnly() { ... }

// Multiple permissions (comma-separated, any match)
[Authorize(Policy = "resource1,resource2")]
[HttpGet("multi")]
public IActionResult MultiPermission() { ... }
```

## Claims Enrichment

The API automatically enriches claims with:
- Standard JWT claims
- Aggregated roles from `ClaimTypes.Role` and `"roles"` claims
- Permissions from RPT tokens (when AuthMode is Authorize)

## Troubleshooting

### Token validation fails
- Verify `Authority` URL is correct and accessible
- Check that `ClientId` matches the Keycloak client
- Ensure the JWT audience matches if configured

### Permissions not recognized
- Confirm `AuthMode` is set to `Authorize`
- Verify Keycloak client has authorization services enabled
- Check that resources and policies are configured in Keycloak
