---
name: goth-fundamentals
description: This skill should be used when the user asks to "set up goth", "install goth", "oauth in go", "authentication in golang", "goth package", "goth basics", or mentions "github.com/markbates/goth". Provides foundational guidance for the Goth multi-provider authentication library.
---

# Goth Fundamentals

Expert guidance for github.com/markbates/goth - a Go library providing simple, clean, idiomatic multi-provider OAuth authentication.

## Installation

Install the package:

```bash
go get github.com/markbates/goth
```

Import in code:

```go
import (
    "github.com/markbates/goth"
    "github.com/markbates/goth/gothic"
    "github.com/markbates/goth/providers/google"
)
```

## Core Concepts

### Provider Interface

Every authentication provider implements the `goth.Provider` interface:

```go
type Provider interface {
    Name() string
    BeginAuth(state string) (Session, error)
    UnmarshalSession(string) (Session, error)
    FetchUser(Session) (User, error)
    Debug(bool)
    RefreshToken(refreshToken string) (*oauth2.Token, error)
    RefreshTokenAvailable() bool
}
```

Key methods:
- `Name()` - Returns provider identifier (e.g., "google", "microsoft")
- `BeginAuth()` - Initiates OAuth flow, returns session with auth URL
- `FetchUser()` - Retrieves user data after successful authentication
- `RefreshToken()` - Obtains new access token using refresh token

### Session Interface

Sessions manage OAuth state throughout the authentication flow:

```go
type Session interface {
    GetAuthURL() (string, error)
    Authorize(Provider, Params) (string, error)
    Marshal() string
}
```

### User Struct

Authenticated user data returned after successful OAuth:

```go
type User struct {
    RawData           map[string]interface{}
    Provider          string
    Email             string
    Name              string
    FirstName         string
    LastName          string
    NickName          string
    Description       string
    UserID            string
    AvatarURL         string
    Location          string
    AccessToken       string
    AccessTokenSecret string
    RefreshToken      string
    ExpiresAt         time.Time
    IDToken           string
}
```

## Gothic Helper Package

The `gothic` package provides convenience functions for common web frameworks:

### Key Functions

```go
// Begin authentication - redirects to provider
gothic.BeginAuthHandler(res http.ResponseWriter, req *http.Request)

// Complete authentication - handles callback
gothic.CompleteUserAuth(res http.ResponseWriter, req *http.Request) (goth.User, error)

// Get user from session (if already authenticated)
gothic.GetFromSession(providerName string, req *http.Request) (string, error)

// Logout user
gothic.Logout(res http.ResponseWriter, req *http.Request) error
```

### Provider Selection

Gothic uses the `provider` query parameter or URL path segment to identify which provider to use:

```go
// Query parameter: /auth?provider=google
// Path segment: /auth/google
```

Override the provider getter if needed:

```go
gothic.GetProviderName = func(req *http.Request) (string, error) {
    return mux.Vars(req)["provider"], nil
}
```

## Basic Authentication Flow

### Step 1: Register Providers

Initialize providers at application startup:

```go
func init() {
    goth.UseProviders(
        google.New(
            os.Getenv("GOOGLE_CLIENT_ID"),
            os.Getenv("GOOGLE_CLIENT_SECRET"),
            "http://localhost:3000/auth/google/callback",
            "email", "profile",
        ),
    )
}
```

### Step 2: Create Auth Routes

```go
func main() {
    http.HandleFunc("/auth/", handleAuth)
    http.HandleFunc("/auth/callback/", handleCallback)
    http.HandleFunc("/logout", handleLogout)
    http.ListenAndServe(":3000", nil)
}

func handleAuth(w http.ResponseWriter, r *http.Request) {
    gothic.BeginAuthHandler(w, r)
}

func handleCallback(w http.ResponseWriter, r *http.Request) {
    user, err := gothic.CompleteUserAuth(w, r)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    // User authenticated - store in session, redirect, etc.
    fmt.Fprintf(w, "Welcome %s!", user.Name)
}

func handleLogout(w http.ResponseWriter, r *http.Request) {
    gothic.Logout(w, r)
    http.Redirect(w, r, "/", http.StatusTemporaryRedirect)
}
```

### Step 3: Configure Session Store

Gothic uses gorilla/sessions by default:

```go
import "github.com/gorilla/sessions"

func init() {
    key := os.Getenv("SESSION_SECRET")
    maxAge := 86400 * 30 // 30 days
    isProd := os.Getenv("ENV") == "production"

    store := sessions.NewCookieStore([]byte(key))
    store.MaxAge(maxAge)
    store.Options.Path = "/"
    store.Options.HttpOnly = true
    store.Options.Secure = isProd

    gothic.Store = store
}
```

## Environment Variables Pattern

Store OAuth credentials securely using environment variables:

```bash
# .env (never commit this file)
GOOGLE_CLIENT_ID=your-client-id.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret
MICROSOFT_CLIENT_ID=your-azure-app-id
MICROSOFT_CLIENT_SECRET=your-azure-secret
SESSION_SECRET=your-32-byte-random-string
```

Load with godotenv or similar:

```go
import "github.com/joho/godotenv"

func init() {
    godotenv.Load()
}
```

## Supported Providers (70+)

Goth includes providers for major platforms:

| Category | Providers |
|----------|-----------|
| Cloud/Enterprise | Google, Microsoft (Azure AD), Apple, Amazon, Okta, Auth0 |
| Development | GitHub, GitLab, Bitbucket, Gitea |
| Social | Facebook, Twitter, Instagram, LinkedIn, Discord |
| Productivity | Slack, Salesforce, Shopify, Zoom |
| Other | Spotify, Twitch, PayPal, Stripe, Uber |

Import provider packages individually:

```go
import (
    "github.com/markbates/goth/providers/google"
    "github.com/markbates/goth/providers/azureadv2"
    "github.com/markbates/goth/providers/github"
)
```

## Error Handling

Handle common authentication errors:

```go
user, err := gothic.CompleteUserAuth(w, r)
if err != nil {
    switch {
    case strings.Contains(err.Error(), "access_denied"):
        // User denied access
        http.Redirect(w, r, "/login?error=denied", http.StatusTemporaryRedirect)
    case strings.Contains(err.Error(), "invalid_grant"):
        // Token expired or revoked
        http.Redirect(w, r, "/login?error=expired", http.StatusTemporaryRedirect)
    default:
        // Log and show generic error
        log.Printf("Auth error: %v", err)
        http.Error(w, "Authentication failed", http.StatusInternalServerError)
    }
    return
}
```

## Token Refresh

For long-lived sessions, refresh tokens before expiry:

```go
func refreshIfNeeded(provider goth.Provider, user *goth.User) error {
    if !provider.RefreshTokenAvailable() {
        return nil
    }

    if time.Until(user.ExpiresAt) > 5*time.Minute {
        return nil // Token still valid
    }

    token, err := provider.RefreshToken(user.RefreshToken)
    if err != nil {
        return err
    }

    user.AccessToken = token.AccessToken
    user.RefreshToken = token.RefreshToken
    user.ExpiresAt = token.Expiry
    return nil
}
```

## Quick Reference

| Task | Function/Pattern |
|------|-----------------|
| Register providers | `goth.UseProviders(provider1, provider2)` |
| Start auth flow | `gothic.BeginAuthHandler(w, r)` |
| Complete auth | `gothic.CompleteUserAuth(w, r)` |
| Logout | `gothic.Logout(w, r)` |
| Get current provider | `gothic.GetProviderName(r)` |
| Configure session store | `gothic.Store = yourStore` |
| Access user data | `user.Email`, `user.Name`, `user.AccessToken` |

## Related Skills

- **goth-providers** - Detailed provider configuration (Google, Microsoft)
- **goth-echo-security** - Echo framework integration and security patterns

## References

- [Goth GitHub Repository](https://github.com/markbates/goth)
- [Go Package Documentation](https://pkg.go.dev/github.com/markbates/goth)
