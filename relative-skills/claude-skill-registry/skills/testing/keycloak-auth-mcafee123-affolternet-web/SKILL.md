---
name: keycloak-auth
description: Configure cookie-based OIDC authentication with Keycloak for affolterNET.Web.Bff. Use when setting up login/logout, token refresh, or Keycloak integration.
---

# Keycloak Authentication

Configure cookie-based OIDC authentication with Keycloak.

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
          "ClientId": "my-bff-client",
          "ClientSecret": "your-client-secret"
        },
        "CookieAuth": {
          "CookieName": ".MyApp.Auth",
          "ExpireTimeSpan": "01:00:00"
        }
      },
      "BffOptions": {
        "AuthMode": "Authenticate"
      }
    }
  }
}
```

## Authentication Modes

| Mode | Description |
|------|-------------|
| `None` | No authentication required |
| `Authenticate` | Valid session required, no permission checks |
| `Authorize` | Valid session + Keycloak RPT permissions required |

## Login/Logout Endpoints

The BFF provides these authentication endpoints:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/bff/account/login` | GET | Initiates OIDC login flow |
| `/bff/account/logout` | GET/POST | Logs out user |
| `/bff/account/user` | GET | Returns current user info |

### Login with Return URL

```
/bff/account/login?returnUrl=/dashboard
```

## Configuration Options

### AuthProviderOptions

| Property | Description |
|----------|-------------|
| `Authority` | Keycloak realm URL |
| `ClientId` | OIDC client identifier |
| `ClientSecret` | OIDC client secret |

### CookieAuthOptions

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `CookieName` | string | `.AspNetCore.Auth` | Authentication cookie name |
| `ExpireTimeSpan` | TimeSpan | `01:00:00` | Cookie expiration |
| `SlidingExpiration` | bool | `true` | Extend cookie on activity |

## Token Refresh

The `RefreshTokenMiddleware` automatically refreshes tokens:
- Checks token expiration before each request
- Refreshes when < 10 seconds until expiration
- Uses semaphore lock to prevent concurrent refreshes
- Signs out user on refresh failure

## SPA Integration

The BFF returns 401 instead of redirecting to Keycloak:

```typescript
// Handle 401 in your SPA
if (response.status === 401) {
    window.location.href = '/bff/account/login?returnUrl=' +
        encodeURIComponent(window.location.pathname);
}
```

## Troubleshooting

### Login redirects to wrong URL
- Verify `Authority` URL is correct
- Check Keycloak client redirect URIs include your app
- Ensure cookies are being set (check SameSite settings)

### Token refresh fails
- Check refresh token hasn't expired
- Verify Keycloak client has offline_access scope
- Review Keycloak session timeout settings

### Logout doesn't work
- Ensure Keycloak client has logout redirect URI configured
- Check if front-channel logout is enabled
