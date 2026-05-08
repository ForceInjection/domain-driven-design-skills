---
name: goth-echo-security
description: This skill should be used when the user asks to "integrate goth with echo", "oauth echo framework", "echo authentication", "goth session management", "oauth security", "secure oauth", "gorilla sessions", or needs help with session storage, security patterns, or Echo framework integration for Goth.
---

# Goth Echo Integration & Security

Expert guidance for integrating github.com/markbates/goth with the Echo web framework and implementing secure session management.

## Echo Framework Integration

### Basic Route Setup

```go
import (
    "github.com/labstack/echo/v4"
    "github.com/markbates/goth"
    "github.com/markbates/goth/gothic"
    "github.com/markbates/goth/providers/google"
)

func main() {
    e := echo.New()

    // Auth routes
    e.GET("/auth/:provider", handleAuth)
    e.GET("/auth/:provider/callback", handleCallback)
    e.GET("/logout", handleLogout)

    e.Start(":3000")
}
```

### Provider Name from Echo Context

Override Gothic's provider getter to use Echo's path parameters:

```go
func init() {
    gothic.GetProviderName = func(r *http.Request) (string, error) {
        // Extract from Echo's :provider path param
        // The request context contains Echo's params
        provider := r.URL.Query().Get(":provider")
        if provider == "" {
            // Fallback: parse from path
            parts := strings.Split(r.URL.Path, "/")
            for i, p := range parts {
                if p == "auth" && i+1 < len(parts) {
                    return parts[i+1], nil
                }
            }
        }
        if provider == "" {
            return "", errors.New("no provider specified")
        }
        return provider, nil
    }
}
```

### Echo Handler Wrappers

Wrap Gothic handlers for Echo compatibility:

```go
func handleAuth(c echo.Context) error {
    // Set provider in query for Gothic
    q := c.Request().URL.Query()
    q.Set(":provider", c.Param("provider"))
    c.Request().URL.RawQuery = q.Encode()

    gothic.BeginAuthHandler(c.Response(), c.Request())
    return nil
}

func handleCallback(c echo.Context) error {
    q := c.Request().URL.Query()
    q.Set(":provider", c.Param("provider"))
    c.Request().URL.RawQuery = q.Encode()

    user, err := gothic.CompleteUserAuth(c.Response(), c.Request())
    if err != nil {
        return c.String(http.StatusInternalServerError, err.Error())
    }

    // Store user in session, redirect to dashboard
    return c.JSON(http.StatusOK, map[string]interface{}{
        "name":  user.Name,
        "email": user.Email,
    })
}

func handleLogout(c echo.Context) error {
    gothic.Logout(c.Response(), c.Request())
    return c.Redirect(http.StatusTemporaryRedirect, "/")
}
```

### Echo Middleware for Auth

Create middleware to protect routes:

```go
func RequireAuth(next echo.HandlerFunc) echo.HandlerFunc {
    return func(c echo.Context) error {
        session, err := gothic.Store.Get(c.Request(), gothic.SessionName)
        if err != nil || session.Values["user_id"] == nil {
            return c.Redirect(http.StatusTemporaryRedirect, "/login")
        }
        return next(c)
    }
}

// Usage
e.GET("/dashboard", handleDashboard, RequireAuth)
```

## Session Management

### Default Cookie Store

Gothic uses gorilla/sessions CookieStore by default:

```go
import "github.com/gorilla/sessions"

func initSessionStore() {
    key := []byte(os.Getenv("SESSION_SECRET"))
    if len(key) < 32 {
        log.Fatal("SESSION_SECRET must be at least 32 bytes")
    }

    store := sessions.NewCookieStore(key)
    store.MaxAge(86400 * 30)  // 30 days
    store.Options.Path = "/"
    store.Options.HttpOnly = true
    store.Options.Secure = os.Getenv("ENV") == "production"
    store.Options.SameSite = http.SameSiteLaxMode

    gothic.Store = store
}
```

### Session Secret Generation

Generate a secure session secret:

```bash
# Generate 32-byte random secret
openssl rand -base64 32
```

### Storing User Data in Session

After successful authentication:

```go
func handleCallback(c echo.Context) error {
    user, err := gothic.CompleteUserAuth(c.Response(), c.Request())
    if err != nil {
        return err
    }

    // Get or create session
    session, _ := gothic.Store.Get(c.Request(), "user-session")

    // Store user data
    session.Values["user_id"] = user.UserID
    session.Values["email"] = user.Email
    session.Values["name"] = user.Name
    session.Values["access_token"] = user.AccessToken
    session.Values["provider"] = user.Provider

    // Save session
    if err := session.Save(c.Request(), c.Response()); err != nil {
        return err
    }

    return c.Redirect(http.StatusTemporaryRedirect, "/dashboard")
}
```

### Retrieving User from Session

```go
func getCurrentUser(c echo.Context) (*UserInfo, error) {
    session, err := gothic.Store.Get(c.Request(), "user-session")
    if err != nil {
        return nil, err
    }

    userID, ok := session.Values["user_id"].(string)
    if !ok || userID == "" {
        return nil, errors.New("not authenticated")
    }

    return &UserInfo{
        UserID:   userID,
        Email:    session.Values["email"].(string),
        Name:     session.Values["name"].(string),
        Provider: session.Values["provider"].(string),
    }, nil
}
```

## Alternative Session Stores

### Redis Session Store

For distributed deployments:

```go
import "github.com/rbcervilla/redisstore/v9"

func initRedisStore() {
    client := redis.NewClient(&redis.Options{
        Addr: os.Getenv("REDIS_URL"),
    })

    store, err := redisstore.NewRedisStore(context.Background(), client)
    if err != nil {
        log.Fatal(err)
    }

    store.KeyPrefix("session_")
    store.Options(sessions.Options{
        Path:     "/",
        MaxAge:   86400 * 30,
        HttpOnly: true,
        Secure:   true,
        SameSite: http.SameSiteLaxMode,
    })

    gothic.Store = store
}
```

### Database Session Store

For PostgreSQL with pgx:

```go
import "github.com/antonlindstrom/pgstore"

func initPgStore() {
    store, err := pgstore.NewPGStoreFromPool(
        dbPool,
        []byte(os.Getenv("SESSION_SECRET")),
    )
    if err != nil {
        log.Fatal(err)
    }

    store.Options = &sessions.Options{
        Path:     "/",
        MaxAge:   86400 * 30,
        HttpOnly: true,
        Secure:   true,
    }

    gothic.Store = store
}
```

See `references/session-storage-options.md` for detailed comparison.

## Security Best Practices

### CSRF Protection with State Parameter

Goth automatically handles the OAuth state parameter for CSRF protection. Verify it's working:

```go
// Gothic handles state internally, but verify in callback
func handleCallback(c echo.Context) error {
    // State is validated by gothic.CompleteUserAuth
    user, err := gothic.CompleteUserAuth(c.Response(), c.Request())
    if err != nil {
        // State mismatch will cause error here
        log.Printf("Auth failed (possible CSRF): %v", err)
        return c.Redirect(http.StatusTemporaryRedirect, "/login?error=invalid_state")
    }
    // ...
}
```

### Secure Cookie Configuration

```go
store.Options = &sessions.Options{
    Path:     "/",
    Domain:   "",                       // Current domain only
    MaxAge:   86400 * 7,               // 7 days
    Secure:   true,                    // HTTPS only
    HttpOnly: true,                    // No JavaScript access
    SameSite: http.SameSiteLaxMode,    // CSRF protection
}
```

### HTTPS Requirements

In production, always use HTTPS:
- Set `Secure: true` on cookies
- Use HTTPS callback URLs in provider configuration
- Redirect HTTP to HTTPS

```go
// Echo HTTPS redirect middleware
e.Pre(middleware.HTTPSRedirect())
```

### Token Storage Security

Never expose access tokens to the client:

```go
// DON'T: Send token to frontend
return c.JSON(200, map[string]string{
    "access_token": user.AccessToken,  // Dangerous!
})

// DO: Store token server-side only
session.Values["access_token"] = user.AccessToken
```

### Session Hijacking Prevention

Regenerate session ID after authentication:

```go
func handleCallback(c echo.Context) error {
    user, err := gothic.CompleteUserAuth(c.Response(), c.Request())
    if err != nil {
        return err
    }

    // Get existing session
    oldSession, _ := gothic.Store.Get(c.Request(), "user-session")

    // Copy values to new session (forces new ID)
    oldSession.Options.MaxAge = -1  // Delete old session
    oldSession.Save(c.Request(), c.Response())

    newSession, _ := gothic.Store.New(c.Request(), "user-session")
    newSession.Values["user_id"] = user.UserID
    newSession.Values["email"] = user.Email
    newSession.Save(c.Request(), c.Response())

    return c.Redirect(http.StatusTemporaryRedirect, "/dashboard")
}
```

### Rate Limiting Auth Endpoints

Protect against brute force:

```go
import "github.com/labstack/echo/v4/middleware"

// Limit auth endpoints
authGroup := e.Group("/auth")
authGroup.Use(middleware.RateLimiter(middleware.NewRateLimiterMemoryStore(
    rate.Limit(10),  // 10 requests per second
)))
```

## Token Refresh Pattern

Keep access tokens fresh:

```go
func refreshTokenIfNeeded(c echo.Context) error {
    session, _ := gothic.Store.Get(c.Request(), "user-session")

    expiresAt, ok := session.Values["expires_at"].(time.Time)
    if !ok || time.Until(expiresAt) > 5*time.Minute {
        return nil  // Token still valid
    }

    providerName := session.Values["provider"].(string)
    provider, _ := goth.GetProvider(providerName)

    if !provider.RefreshTokenAvailable() {
        return nil
    }

    refreshToken := session.Values["refresh_token"].(string)
    token, err := provider.RefreshToken(refreshToken)
    if err != nil {
        // Refresh failed - force re-login
        return c.Redirect(http.StatusTemporaryRedirect, "/logout")
    }

    session.Values["access_token"] = token.AccessToken
    session.Values["expires_at"] = token.Expiry
    if token.RefreshToken != "" {
        session.Values["refresh_token"] = token.RefreshToken
    }
    session.Save(c.Request(), c.Response())

    return nil
}
```

## Security Checklist

Before deploying:

- [ ] SESSION_SECRET is at least 32 random bytes
- [ ] Cookies use `Secure: true` in production
- [ ] Cookies use `HttpOnly: true`
- [ ] Cookies use `SameSite: Lax` or `Strict`
- [ ] HTTPS is enforced in production
- [ ] Callback URLs use HTTPS
- [ ] Access tokens stored server-side only
- [ ] Rate limiting on auth endpoints
- [ ] Session regeneration after login
- [ ] Error messages don't leak sensitive info

See `references/security-checklist.md` for complete checklist.

## Quick Reference

| Task | Code |
|------|------|
| Set session store | `gothic.Store = store` |
| Get session | `gothic.Store.Get(r, "name")` |
| Save session | `session.Save(r, w)` |
| Delete session | `session.Options.MaxAge = -1` |
| Secure cookie | `Secure: true, HttpOnly: true` |

## Related Skills

- **goth-fundamentals** - Core Goth concepts
- **goth-providers** - Provider configuration

## Reference Documentation

- `references/session-storage-options.md` - Storage comparison
- `references/security-checklist.md` - Security verification
