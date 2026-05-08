---
name: security-rbac-auth
description: Implement authentication, authorization, and security controls. Use for JWT handling, API key management, RBAC, OAuth integration, and security policies. Triggers on "authentication", "authorization", "JWT", "API key", "RBAC", "OAuth", "security", "permissions", or when implementing spec/006-security-governance.md.
---

# Security, RBAC, and Authentication

## Overview

Implement comprehensive security for AgentStack including authentication (JWT, API Keys, OAuth), authorization (RBAC), and security controls (encryption, audit logging, secret management).

## Security Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Security Stack                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    PERIMETER                              │  │
│  │  TLS 1.3 │ Rate Limiting │ CORS │ WAF                     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                 AUTHENTICATION                            │  │
│  │  JWT (RS256) │ API Keys │ OAuth 2.0 │ OIDC                │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                 AUTHORIZATION                             │  │
│  │  RBAC │ Project Scoping │ Resource Policies               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                           │                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                 DATA PROTECTION                           │  │
│  │  Encryption at Rest │ Secrets │ PII Masking               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## JWT Authentication

### JWT Structure

```go
// internal/auth/jwt/claims.go
package jwt

import (
    "time"
    
    "github.com/golang-jwt/jwt/v5"
)

type Claims struct {
    jwt.RegisteredClaims
    
    // User identity
    UserID string `json:"sub"`
    Email  string `json:"email"`
    
    // Organization context
    OrgID     string   `json:"org_id"`
    ProjectID string   `json:"project_id,omitempty"`
    TeamIDs   []string `json:"teams,omitempty"`
    
    // Permissions
    Permissions []string `json:"permissions"`
    Roles       []string `json:"roles"`
}

func NewClaims(user *User, org *Organization) *Claims {
    now := time.Now()
    return &Claims{
        RegisteredClaims: jwt.RegisteredClaims{
            Issuer:    "https://auth.agentstack.io",
            Audience:  jwt.ClaimStrings{"https://api.agentstack.io"},
            Subject:   user.ID,
            IssuedAt:  jwt.NewNumericDate(now),
            ExpiresAt: jwt.NewNumericDate(now.Add(1 * time.Hour)),
            NotBefore: jwt.NewNumericDate(now),
            ID:        uuid.NewString(),
        },
        UserID:      user.ID,
        Email:       user.Email,
        OrgID:       org.ID,
        TeamIDs:     user.TeamIDs,
        Permissions: user.GetPermissions(org),
        Roles:       user.GetRoles(org),
    }
}
```

### JWT Service

```go
// internal/auth/jwt/service.go
package jwt

import (
    "crypto/rsa"
    "fmt"
    "time"
    
    "github.com/golang-jwt/jwt/v5"
)

type Service struct {
    privateKey *rsa.PrivateKey
    publicKey  *rsa.PublicKey
    keyID      string
}

func NewService(privateKeyPEM, publicKeyPEM []byte, keyID string) (*Service, error) {
    privateKey, err := jwt.ParseRSAPrivateKeyFromPEM(privateKeyPEM)
    if err != nil {
        return nil, fmt.Errorf("parse private key: %w", err)
    }
    
    publicKey, err := jwt.ParseRSAPublicKeyFromPEM(publicKeyPEM)
    if err != nil {
        return nil, fmt.Errorf("parse public key: %w", err)
    }
    
    return &Service{
        privateKey: privateKey,
        publicKey:  publicKey,
        keyID:      keyID,
    }, nil
}

func (s *Service) GenerateToken(claims *Claims) (string, error) {
    token := jwt.NewWithClaims(jwt.SigningMethodRS256, claims)
    token.Header["kid"] = s.keyID
    
    return token.SignedString(s.privateKey)
}

func (s *Service) ValidateToken(tokenString string) (*Claims, error) {
    token, err := jwt.ParseWithClaims(tokenString, &Claims{}, func(token *jwt.Token) (interface{}, error) {
        if _, ok := token.Method.(*jwt.SigningMethodRSA); !ok {
            return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
        }
        return s.publicKey, nil
    })
    
    if err != nil {
        return nil, err
    }
    
    claims, ok := token.Claims.(*Claims)
    if !ok || !token.Valid {
        return nil, fmt.Errorf("invalid token")
    }
    
    return claims, nil
}

// GenerateRefreshToken creates a long-lived refresh token
func (s *Service) GenerateRefreshToken(userID string) (string, error) {
    claims := &jwt.RegisteredClaims{
        Subject:   userID,
        ExpiresAt: jwt.NewNumericDate(time.Now().Add(7 * 24 * time.Hour)),
        IssuedAt:  jwt.NewNumericDate(time.Now()),
        ID:        uuid.NewString(),
    }
    
    token := jwt.NewWithClaims(jwt.SigningMethodRS256, claims)
    return token.SignedString(s.privateKey)
}
```

### Auth Middleware

```go
// internal/api/middleware/auth.go
package middleware

import (
    "context"
    "strings"
    
    "github.com/gofiber/fiber/v2"
)

type contextKey string

const (
    UserContextKey   contextKey = "user"
    ClaimsContextKey contextKey = "claims"
)

func JWTAuth(jwtService *jwt.Service) fiber.Handler {
    return func(c *fiber.Ctx) error {
        authHeader := c.Get("Authorization")
        if authHeader == "" {
            return c.Status(401).JSON(fiber.Map{
                "error": "missing authorization header",
            })
        }
        
        parts := strings.SplitN(authHeader, " ", 2)
        if len(parts) != 2 || parts[0] != "Bearer" {
            return c.Status(401).JSON(fiber.Map{
                "error": "invalid authorization format",
            })
        }
        
        claims, err := jwtService.ValidateToken(parts[1])
        if err != nil {
            return c.Status(401).JSON(fiber.Map{
                "error": "invalid token",
            })
        }
        
        // Add claims to context
        c.Locals(string(ClaimsContextKey), claims)
        
        return c.Next()
    }
}

func ClaimsFromContext(c *fiber.Ctx) *jwt.Claims {
    claims, _ := c.Locals(string(ClaimsContextKey)).(*jwt.Claims)
    return claims
}
```

## API Key Authentication

### API Key Structure

```go
// internal/auth/apikey/key.go
package apikey

import (
    "crypto/rand"
    "crypto/sha256"
    "encoding/base64"
    "fmt"
    "strings"
)

const (
    Prefix    = "ask_"  // AgentStack Key
    KeyLength = 32      // bytes
)

type APIKey struct {
    ID           string
    Prefix       string    // "ask_"
    Hash         string    // SHA-256 hash of full key
    ProjectID    string
    OrgID        string
    Name         string
    Permissions  []string
    LastUsedAt   *time.Time
    ExpiresAt    *time.Time
    CreatedAt    time.Time
}

// Generate creates a new API key and returns the full key (shown once)
func Generate(projectID, orgID, name string, permissions []string) (*APIKey, string, error) {
    // Generate random bytes
    randomBytes := make([]byte, KeyLength)
    if _, err := rand.Read(randomBytes); err != nil {
        return nil, "", err
    }
    
    // Encode to base62-like string
    keyBody := base64.RawURLEncoding.EncodeToString(randomBytes)
    fullKey := Prefix + keyBody
    
    // Hash for storage (never store plaintext)
    hash := sha256.Sum256([]byte(fullKey))
    hashStr := fmt.Sprintf("%x", hash)
    
    key := &APIKey{
        ID:          uuid.NewString(),
        Prefix:      fullKey[:len(Prefix)+4], // Store prefix for identification
        Hash:        hashStr,
        ProjectID:   projectID,
        OrgID:       orgID,
        Name:        name,
        Permissions: permissions,
        CreatedAt:   time.Now(),
    }
    
    return key, fullKey, nil
}

// Verify checks if a provided key matches the stored hash
func (k *APIKey) Verify(providedKey string) bool {
    hash := sha256.Sum256([]byte(providedKey))
    return fmt.Sprintf("%x", hash) == k.Hash
}
```

### API Key Middleware

```go
// internal/api/middleware/apikey.go
package middleware

func APIKeyAuth(keyRepo apikey.Repository) fiber.Handler {
    return func(c *fiber.Ctx) error {
        // Check X-API-Key header
        apiKey := c.Get("X-API-Key")
        if apiKey == "" {
            // Also check Authorization header
            authHeader := c.Get("Authorization")
            if strings.HasPrefix(authHeader, "Bearer ask_") {
                apiKey = strings.TrimPrefix(authHeader, "Bearer ")
            }
        }
        
        if apiKey == "" {
            return c.Status(401).JSON(fiber.Map{
                "error": "missing API key",
            })
        }
        
        // Validate prefix
        if !strings.HasPrefix(apiKey, apikey.Prefix) {
            return c.Status(401).JSON(fiber.Map{
                "error": "invalid API key format",
            })
        }
        
        // Look up key by prefix (first 8 chars)
        prefix := apiKey[:len(apikey.Prefix)+4]
        key, err := keyRepo.FindByPrefix(c.Context(), prefix)
        if err != nil {
            return c.Status(401).JSON(fiber.Map{
                "error": "invalid API key",
            })
        }
        
        // Verify full key
        if !key.Verify(apiKey) {
            return c.Status(401).JSON(fiber.Map{
                "error": "invalid API key",
            })
        }
        
        // Check expiration
        if key.ExpiresAt != nil && key.ExpiresAt.Before(time.Now()) {
            return c.Status(401).JSON(fiber.Map{
                "error": "API key expired",
            })
        }
        
        // Update last used (async)
        go keyRepo.UpdateLastUsed(context.Background(), key.ID)
        
        // Set context
        c.Locals("api_key", key)
        c.Locals("org_id", key.OrgID)
        c.Locals("project_id", key.ProjectID)
        c.Locals("permissions", key.Permissions)
        
        return c.Next()
    }
}
```

## RBAC Authorization

### Role Definitions

```go
// internal/auth/rbac/roles.go
package rbac

type Role string

const (
    // Platform level
    RolePlatformAdmin Role = "platform:admin"
    
    // Organization level
    RoleOrgOwner  Role = "org:owner"
    RoleOrgAdmin  Role = "org:admin"
    RoleOrgMember Role = "org:member"
    
    // Project level
    RoleProjectAdmin     Role = "project:admin"
    RoleProjectDeveloper Role = "project:developer"
    RoleProjectViewer    Role = "project:viewer"
)

type Permission string

const (
    // Agent permissions
    PermAgentsRead   Permission = "agents:read"
    PermAgentsWrite  Permission = "agents:write"
    PermAgentsDelete Permission = "agents:delete"
    PermAgentsDeploy Permission = "agents:deploy"
    
    // Secret permissions
    PermSecretsRead  Permission = "secrets:read"
    PermSecretsWrite Permission = "secrets:write"
    
    // Project permissions
    PermProjectRead   Permission = "project:read"
    PermProjectWrite  Permission = "project:write"
    PermProjectDelete Permission = "project:delete"
    
    // Team permissions
    PermTeamManage Permission = "team:manage"
    
    // Billing
    PermBillingManage Permission = "billing:manage"
)

// RolePermissions maps roles to their permissions
var RolePermissions = map[Role][]Permission{
    RolePlatformAdmin: {
        PermAgentsRead, PermAgentsWrite, PermAgentsDelete, PermAgentsDeploy,
        PermSecretsRead, PermSecretsWrite,
        PermProjectRead, PermProjectWrite, PermProjectDelete,
        PermTeamManage, PermBillingManage,
    },
    RoleOrgOwner: {
        PermAgentsRead, PermAgentsWrite, PermAgentsDelete, PermAgentsDeploy,
        PermSecretsRead, PermSecretsWrite,
        PermProjectRead, PermProjectWrite, PermProjectDelete,
        PermTeamManage, PermBillingManage,
    },
    RoleOrgAdmin: {
        PermAgentsRead, PermAgentsWrite, PermAgentsDelete, PermAgentsDeploy,
        PermSecretsRead, PermSecretsWrite,
        PermProjectRead, PermProjectWrite,
        PermTeamManage,
    },
    RoleProjectDeveloper: {
        PermAgentsRead, PermAgentsWrite, PermAgentsDeploy,
        PermSecretsRead,
        PermProjectRead,
    },
    RoleProjectViewer: {
        PermAgentsRead,
        PermProjectRead,
    },
}
```

### Authorization Middleware

```go
// internal/api/middleware/authorize.go
package middleware

import (
    "github.com/gofiber/fiber/v2"
)

// RequirePermission checks if user has the required permission
func RequirePermission(permission rbac.Permission) fiber.Handler {
    return func(c *fiber.Ctx) error {
        claims := ClaimsFromContext(c)
        if claims == nil {
            // Check API key permissions
            perms, _ := c.Locals("permissions").([]string)
            if !hasPermission(perms, string(permission)) {
                return c.Status(403).JSON(fiber.Map{
                    "error":   "forbidden",
                    "message": "insufficient permissions",
                })
            }
            return c.Next()
        }
        
        // Check JWT permissions
        if !hasPermission(claims.Permissions, string(permission)) {
            return c.Status(403).JSON(fiber.Map{
                "error":   "forbidden",
                "message": "insufficient permissions",
            })
        }
        
        return c.Next()
    }
}

// RequireRole checks if user has one of the required roles
func RequireRole(roles ...rbac.Role) fiber.Handler {
    return func(c *fiber.Ctx) error {
        claims := ClaimsFromContext(c)
        if claims == nil {
            return c.Status(403).JSON(fiber.Map{
                "error": "forbidden",
            })
        }
        
        for _, required := range roles {
            for _, userRole := range claims.Roles {
                if userRole == string(required) {
                    return c.Next()
                }
            }
        }
        
        return c.Status(403).JSON(fiber.Map{
            "error":   "forbidden",
            "message": "insufficient role",
        })
    }
}

func hasPermission(perms []string, required string) bool {
    for _, p := range perms {
        if p == required || p == "*" {
            return true
        }
    }
    return false
}
```

### Resource-Level Authorization

```go
// internal/auth/rbac/policy.go
package rbac

import "context"

type Policy interface {
    CanAccess(ctx context.Context, subject Subject, resource Resource, action Action) (bool, error)
}

type Subject struct {
    UserID      string
    OrgID       string
    ProjectID   string
    Roles       []Role
    Permissions []Permission
}

type Resource struct {
    Type      string // "agent", "secret", "project"
    ID        string
    OwnerOrg  string
    OwnerProj string
}

type Action string

const (
    ActionRead   Action = "read"
    ActionWrite  Action = "write"
    ActionDelete Action = "delete"
    ActionDeploy Action = "deploy"
)

type DefaultPolicy struct {
    repo PolicyRepository
}

func (p *DefaultPolicy) CanAccess(ctx context.Context, subject Subject, resource Resource, action Action) (bool, error) {
    // Platform admin can do anything
    if hasRole(subject.Roles, RolePlatformAdmin) {
        return true, nil
    }
    
    // Must be in same org
    if subject.OrgID != resource.OwnerOrg {
        return false, nil
    }
    
    // Check project-level access
    if resource.OwnerProj != "" && subject.ProjectID != resource.OwnerProj {
        // Check if user has cross-project permissions
        if !hasRole(subject.Roles, RoleOrgAdmin, RoleOrgOwner) {
            return false, nil
        }
    }
    
    // Check action permission
    requiredPerm := resourceActionToPermission(resource.Type, action)
    return hasPermission(subject.Permissions, requiredPerm), nil
}
```

## OAuth 2.0 Integration

```go
// internal/auth/oauth/provider.go
package oauth

import (
    "context"
    
    "golang.org/x/oauth2"
    "golang.org/x/oauth2/google"
    "golang.org/x/oauth2/github"
)

type Provider interface {
    AuthURL(state string) string
    Exchange(ctx context.Context, code string) (*oauth2.Token, error)
    GetUserInfo(ctx context.Context, token *oauth2.Token) (*UserInfo, error)
}

type UserInfo struct {
    ID       string
    Email    string
    Name     string
    Avatar   string
    Provider string
}

type GoogleProvider struct {
    config *oauth2.Config
}

func NewGoogleProvider(clientID, clientSecret, redirectURL string) *GoogleProvider {
    return &GoogleProvider{
        config: &oauth2.Config{
            ClientID:     clientID,
            ClientSecret: clientSecret,
            RedirectURL:  redirectURL,
            Scopes:       []string{"openid", "email", "profile"},
            Endpoint:     google.Endpoint,
        },
    }
}

func (p *GoogleProvider) AuthURL(state string) string {
    return p.config.AuthCodeURL(state)
}

func (p *GoogleProvider) Exchange(ctx context.Context, code string) (*oauth2.Token, error) {
    return p.config.Exchange(ctx, code)
}

func (p *GoogleProvider) GetUserInfo(ctx context.Context, token *oauth2.Token) (*UserInfo, error) {
    client := p.config.Client(ctx, token)
    resp, err := client.Get("https://www.googleapis.com/oauth2/v2/userinfo")
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()
    
    var info struct {
        ID      string `json:"id"`
        Email   string `json:"email"`
        Name    string `json:"name"`
        Picture string `json:"picture"`
    }
    if err := json.NewDecoder(resp.Body).Decode(&info); err != nil {
        return nil, err
    }
    
    return &UserInfo{
        ID:       info.ID,
        Email:    info.Email,
        Name:     info.Name,
        Avatar:   info.Picture,
        Provider: "google",
    }, nil
}
```

## Secret Management

```go
// internal/secrets/service.go
package secrets

import (
    "context"
    "crypto/aes"
    "crypto/cipher"
    "crypto/rand"
    "encoding/base64"
)

type Service struct {
    key  []byte // 32 bytes for AES-256
    repo Repository
}

func NewService(encryptionKey string, repo Repository) *Service {
    return &Service{
        key:  []byte(encryptionKey),
        repo: repo,
    }
}

func (s *Service) Create(ctx context.Context, projectID, name, value string) (*Secret, error) {
    // Encrypt value
    encrypted, err := s.encrypt(value)
    if err != nil {
        return nil, err
    }
    
    secret := &Secret{
        ID:        uuid.NewString(),
        ProjectID: projectID,
        Name:      name,
        Value:     encrypted,
        CreatedAt: time.Now(),
    }
    
    return s.repo.Create(ctx, secret)
}

func (s *Service) Get(ctx context.Context, projectID, name string) (string, error) {
    secret, err := s.repo.FindByName(ctx, projectID, name)
    if err != nil {
        return "", err
    }
    
    return s.decrypt(secret.Value)
}

func (s *Service) encrypt(plaintext string) (string, error) {
    block, err := aes.NewCipher(s.key)
    if err != nil {
        return "", err
    }
    
    gcm, err := cipher.NewGCM(block)
    if err != nil {
        return "", err
    }
    
    nonce := make([]byte, gcm.NonceSize())
    if _, err := rand.Read(nonce); err != nil {
        return "", err
    }
    
    ciphertext := gcm.Seal(nonce, nonce, []byte(plaintext), nil)
    return base64.StdEncoding.EncodeToString(ciphertext), nil
}

func (s *Service) decrypt(ciphertext string) (string, error) {
    data, err := base64.StdEncoding.DecodeString(ciphertext)
    if err != nil {
        return "", err
    }
    
    block, err := aes.NewCipher(s.key)
    if err != nil {
        return "", err
    }
    
    gcm, err := cipher.NewGCM(block)
    if err != nil {
        return "", err
    }
    
    nonceSize := gcm.NonceSize()
    nonce, ciphertextBytes := data[:nonceSize], data[nonceSize:]
    
    plaintext, err := gcm.Open(nil, nonce, ciphertextBytes, nil)
    if err != nil {
        return "", err
    }
    
    return string(plaintext), nil
}
```

## Audit Logging

```go
// internal/audit/logger.go
package audit

import (
    "context"
    "encoding/json"
    "time"
)

type Event struct {
    ID          string                 `json:"id"`
    Timestamp   time.Time              `json:"timestamp"`
    Actor       Actor                  `json:"actor"`
    Action      string                 `json:"action"`
    Resource    Resource               `json:"resource"`
    Result      string                 `json:"result"` // success, failure
    IP          string                 `json:"ip"`
    UserAgent   string                 `json:"user_agent"`
    Details     map[string]interface{} `json:"details,omitempty"`
}

type Actor struct {
    Type   string `json:"type"` // user, api_key, service
    ID     string `json:"id"`
    Email  string `json:"email,omitempty"`
    OrgID  string `json:"org_id"`
}

type Resource struct {
    Type      string `json:"type"`
    ID        string `json:"id"`
    ProjectID string `json:"project_id,omitempty"`
}

type Logger struct {
    writer EventWriter
}

func (l *Logger) Log(ctx context.Context, event Event) error {
    event.ID = uuid.NewString()
    event.Timestamp = time.Now().UTC()
    
    return l.writer.Write(ctx, event)
}

// LogAction is a convenience method
func (l *Logger) LogAction(ctx context.Context, action string, resource Resource, result string) {
    actor := ActorFromContext(ctx)
    event := Event{
        Actor:    actor,
        Action:   action,
        Resource: resource,
        Result:   result,
        IP:       IPFromContext(ctx),
    }
    l.Log(ctx, event)
}
```

## Rate Limiting

```go
// internal/api/middleware/ratelimit.go
package middleware

import (
    "time"
    
    "github.com/gofiber/fiber/v2"
    "github.com/redis/go-redis/v9"
)

type RateLimiter struct {
    redis  *redis.Client
    limit  int
    window time.Duration
}

func NewRateLimiter(redis *redis.Client, limit int, window time.Duration) *RateLimiter {
    return &RateLimiter{
        redis:  redis,
        limit:  limit,
        window: window,
    }
}

func (rl *RateLimiter) Middleware() fiber.Handler {
    return func(c *fiber.Ctx) error {
        // Get identifier (API key or user ID)
        key := rl.getKey(c)
        
        // Increment counter
        count, err := rl.redis.Incr(c.Context(), key).Result()
        if err != nil {
            // Allow on Redis failure (fail open)
            return c.Next()
        }
        
        // Set expiry on first request
        if count == 1 {
            rl.redis.Expire(c.Context(), key, rl.window)
        }
        
        // Check limit
        if int(count) > rl.limit {
            ttl, _ := rl.redis.TTL(c.Context(), key).Result()
            
            c.Set("X-RateLimit-Limit", fmt.Sprintf("%d", rl.limit))
            c.Set("X-RateLimit-Remaining", "0")
            c.Set("X-RateLimit-Reset", fmt.Sprintf("%d", time.Now().Add(ttl).Unix()))
            c.Set("Retry-After", fmt.Sprintf("%d", int(ttl.Seconds())))
            
            return c.Status(429).JSON(fiber.Map{
                "error":   "rate_limit_exceeded",
                "message": "Too many requests",
            })
        }
        
        // Set headers
        c.Set("X-RateLimit-Limit", fmt.Sprintf("%d", rl.limit))
        c.Set("X-RateLimit-Remaining", fmt.Sprintf("%d", rl.limit-int(count)))
        
        return c.Next()
    }
}

func (rl *RateLimiter) getKey(c *fiber.Ctx) string {
    // Prefer API key, then user ID, then IP
    if key, ok := c.Locals("api_key").(*apikey.APIKey); ok {
        return fmt.Sprintf("ratelimit:%s", key.ID)
    }
    if claims := ClaimsFromContext(c); claims != nil {
        return fmt.Sprintf("ratelimit:user:%s", claims.UserID)
    }
    return fmt.Sprintf("ratelimit:ip:%s", c.IP())
}
```

## Resources

- `references/oauth-providers.md` - OAuth provider configurations
- `references/security-headers.md` - HTTP security headers
