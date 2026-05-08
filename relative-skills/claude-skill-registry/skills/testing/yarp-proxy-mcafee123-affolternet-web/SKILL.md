---
name: yarp-proxy
description: Configure YARP reverse proxy for affolterNET.Web.Bff. Use when setting up API proxying, route configuration, or backend service integration.
---

# YARP Reverse Proxy

Configure YARP to proxy requests to backend APIs.

For complete reference, see [Library Guide](../../LIBRARY_GUIDE.md).

## Quick Start

### appsettings.json

```json
{
  "affolterNET": {
    "ReverseProxy": {
      "Routes": {
        "api-route": {
          "ClusterId": "api-cluster",
          "Match": {
            "Path": "/api/{**catch-all}"
          }
        }
      },
      "Clusters": {
        "api-cluster": {
          "Destinations": {
            "api": {
              "Address": "https://api.example.com"
            }
          }
        }
      }
    }
  }
}
```

## How It Works

1. BFF receives request to `/api/...`
2. YARP matches the route pattern
3. `AuthTransform` adds bearer token from user session
4. Request is forwarded to backend API
5. Response is returned to client

## Configuration Options

### Routes

```json
{
  "Routes": {
    "route-name": {
      "ClusterId": "cluster-name",
      "Match": {
        "Path": "/api/{**catch-all}",
        "Methods": ["GET", "POST"]
      },
      "Transforms": []
    }
  }
}
```

### Clusters

```json
{
  "Clusters": {
    "cluster-name": {
      "Destinations": {
        "destination1": {
          "Address": "https://api1.example.com"
        },
        "destination2": {
          "Address": "https://api2.example.com"
        }
      },
      "LoadBalancingPolicy": "RoundRobin"
    }
  }
}
```

## Auth Transform

The BFF automatically adds bearer tokens to proxied requests:

```csharp
// Automatically extracts access token from user session
var token = await context.GetTokenAsync("access_token");
// Adds Authorization: Bearer {token} header
```

## Multiple Backend APIs

```json
{
  "affolterNET": {
    "ReverseProxy": {
      "Routes": {
        "users-api": {
          "ClusterId": "users",
          "Match": { "Path": "/api/users/{**catch-all}" }
        },
        "orders-api": {
          "ClusterId": "orders",
          "Match": { "Path": "/api/orders/{**catch-all}" }
        }
      },
      "Clusters": {
        "users": {
          "Destinations": {
            "default": { "Address": "https://users-api.example.com" }
          }
        },
        "orders": {
          "Destinations": {
            "default": { "Address": "https://orders-api.example.com" }
          }
        }
      }
    }
  }
}
```

## Path Rewriting

```json
{
  "Routes": {
    "api-route": {
      "ClusterId": "api",
      "Match": { "Path": "/bff/api/{**remainder}" },
      "Transforms": [
        { "PathRemovePrefix": "/bff" }
      ]
    }
  }
}
```

## Troubleshooting

### 502 Bad Gateway
- Verify backend API is running and accessible
- Check destination address is correct
- Review network connectivity between BFF and API

### Token not forwarded
- Ensure user is authenticated
- Verify access token is in session
- Check AuthTransform is registered

### Route not matched
- Verify path pattern matches incoming request
- Check route order (more specific routes first)
- Enable YARP logging for debugging
