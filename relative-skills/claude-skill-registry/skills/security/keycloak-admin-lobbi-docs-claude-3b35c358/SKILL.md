---
name: keycloak-admin
description: Keycloak administration including realm management, client configuration, OAuth 2.0 setup, user management with custom attributes, role and group management, theme deployment, and token configuration. Activate for Keycloak Admin API operations, authentication setup, and identity provider configuration.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Task
  - WebFetch
  - WebSearch
dependencies:
  - authentication
triggers:
  - keycloak
  - realm
  - client
  - oauth
  - authentication
  - user management
  - identity provider
  - theme deployment
  - token configuration
---

# Keycloak Admin Skill

Comprehensive Keycloak administration for the keycloak-alpha multi-tenant MERN platform with OAuth 2.0 Authorization Code Flow.

## When to Use This Skill

Activate this skill when:
- Setting up Keycloak realms and clients
- Configuring OAuth 2.0 Authorization Code Flow
- Managing users with custom attributes (org_id)
- Deploying custom themes
- Troubleshooting authentication issues
- Configuring token lifetimes and session management

## Keycloak Admin REST API

### Authentication

Use the admin-cli client to obtain an access token:

```bash
# Get admin access token
TOKEN=$(curl -X POST "http://localhost:8080/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin" \
  -d "password=admin" \
  -d "grant_type=password" \
  -d "client_id=admin-cli" | jq -r '.access_token')

# Use token in subsequent requests
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8080/admin/realms/master"
```

### Key API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/admin/realms` | GET | List all realms |
| `/admin/realms/{realm}` | POST | Create realm |
| `/admin/realms/{realm}/clients` | GET/POST | Manage clients |
| `/admin/realms/{realm}/users` | GET/POST | Manage users |
| `/admin/realms/{realm}/roles` | GET/POST | Manage roles |
| `/admin/realms/{realm}/groups` | GET/POST | Manage groups |

## Realm Creation and Configuration

### Create a New Realm

```bash
# Create realm with basic configuration
curl -X POST "http://localhost:8080/admin/realms" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "realm": "lobbi",
    "enabled": true,
    "displayName": "Lobbi Platform",
    "sslRequired": "external",
    "registrationAllowed": false,
    "loginWithEmailAllowed": true,
    "duplicateEmailsAllowed": false,
    "resetPasswordAllowed": true,
    "editUsernameAllowed": false,
    "bruteForceProtected": true,
    "permanentLockout": false,
    "maxFailureWaitSeconds": 900,
    "minimumQuickLoginWaitSeconds": 60,
    "waitIncrementSeconds": 60,
    "quickLoginCheckMilliSeconds": 1000,
    "maxDeltaTimeSeconds": 43200,
    "failureFactor": 30,
    "defaultSignatureAlgorithm": "RS256",
    "revokeRefreshToken": false,
    "refreshTokenMaxReuse": 0,
    "accessTokenLifespan": 300,
    "accessTokenLifespanForImplicitFlow": 900,
    "ssoSessionIdleTimeout": 1800,
    "ssoSessionMaxLifespan": 36000,
    "offlineSessionIdleTimeout": 2592000,
    "accessCodeLifespan": 60,
    "accessCodeLifespanUserAction": 300,
    "accessCodeLifespanLogin": 1800
  }'
```

### Configure Realm Settings

```javascript
// In keycloak-alpha: services/keycloak-service/src/config/realm-config.js
export const realmDefaults = {
  realm: process.env.KEYCLOAK_REALM || 'lobbi',
  enabled: true,
  displayName: 'Lobbi Platform',

  // Security settings
  sslRequired: 'external',
  registrationAllowed: false,
  loginWithEmailAllowed: true,
  duplicateEmailsAllowed: false,

  // Token lifespans (seconds)
  accessTokenLifespan: 300,              // 5 minutes
  accessTokenLifespanForImplicitFlow: 900, // 15 minutes
  ssoSessionIdleTimeout: 1800,           // 30 minutes
  ssoSessionMaxLifespan: 36000,          // 10 hours
  offlineSessionIdleTimeout: 2592000,    // 30 days

  // Login settings
  resetPasswordAllowed: true,
  editUsernameAllowed: false,

  // Brute force protection
  bruteForceProtected: true,
  permanentLockout: false,
  maxFailureWaitSeconds: 900,
  minimumQuickLoginWaitSeconds: 60,
  failureFactor: 30
};
```

## Client Configuration for OAuth 2.0 Authorization Code Flow

### Create Client

```bash
# Create client for Authorization Code Flow
curl -X POST "http://localhost:8080/admin/realms/lobbi/clients" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "clientId": "lobbi-web-app",
    "name": "Lobbi Web Application",
    "enabled": true,
    "protocol": "openid-connect",
    "publicClient": false,
    "standardFlowEnabled": true,
    "implicitFlowEnabled": false,
    "directAccessGrantsEnabled": false,
    "serviceAccountsEnabled": false,
    "redirectUris": [
      "http://localhost:3000/auth/callback",
      "https://*.lobbi.com/auth/callback"
    ],
    "webOrigins": [
      "http://localhost:3000",
      "https://*.lobbi.com"
    ],
    "attributes": {
      "pkce.code.challenge.method": "S256"
    },
    "defaultClientScopes": [
      "email",
      "profile",
      "roles",
      "web-origins"
    ],
    "optionalClientScopes": [
      "address",
      "phone",
      "offline_access"
    ]
  }'
```

### Client Configuration in keycloak-alpha

```javascript
// In: apps/web-app/src/config/keycloak.config.js
export const keycloakConfig = {
  url: process.env.VITE_KEYCLOAK_URL || 'http://localhost:8080',
  realm: process.env.VITE_KEYCLOAK_REALM || 'lobbi',
  clientId: process.env.VITE_KEYCLOAK_CLIENT_ID || 'lobbi-web-app',
};

// OAuth 2.0 Authorization Code Flow with PKCE
export const authConfig = {
  flow: 'standard',
  pkceMethod: 'S256',
  responseType: 'code',
  scope: 'openid profile email roles',

  // Redirect URIs
  redirectUri: `${window.location.origin}/auth/callback`,
  postLogoutRedirectUri: `${window.location.origin}/`,

  // Token handling
  checkLoginIframe: true,
  checkLoginIframeInterval: 5,
  onLoad: 'check-sso',
  silentCheckSsoRedirectUri: `${window.location.origin}/silent-check-sso.html`
};
```

### Client Secret Management

```bash
# Get client secret
CLIENT_UUID=$(curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8080/admin/realms/lobbi/clients?clientId=lobbi-web-app" \
  | jq -r '.[0].id')

curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8080/admin/realms/lobbi/clients/$CLIENT_UUID/client-secret" \
  | jq -r '.value'

# Regenerate client secret
curl -X POST -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8080/admin/realms/lobbi/clients/$CLIENT_UUID/client-secret"
```

## User Management with Custom Attributes

### Create User with org_id

```bash
# Create user with custom org_id attribute
curl -X POST "http://localhost:8080/admin/realms/lobbi/users" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "john.doe@acme.com",
    "email": "john.doe@acme.com",
    "firstName": "John",
    "lastName": "Doe",
    "enabled": true,
    "emailVerified": true,
    "attributes": {
      "org_id": ["org_acme"],
      "tenant_name": ["ACME Corporation"]
    },
    "credentials": [{
      "type": "password",
      "value": "temp_password_123",
      "temporary": true
    }]
  }'
```

### User Service in keycloak-alpha

```javascript
// In: services/user-service/src/controllers/user.controller.js
import axios from 'axios';

export class UserController {

  async createUser(req, res) {
    const { email, firstName, lastName, orgId } = req.body;

    // Get admin token
    const adminToken = await this.getAdminToken();

    // Create user in Keycloak
    const userData = {
      username: email,
      email,
      firstName,
      lastName,
      enabled: true,
      emailVerified: false,
      attributes: {
        org_id: [orgId],
        created_by: [req.user.sub]
      },
      credentials: [{
        type: 'password',
        value: this.generateTemporaryPassword(),
        temporary: true
      }]
    };

    try {
      const response = await axios.post(
        `${process.env.KEYCLOAK_URL}/admin/realms/${process.env.KEYCLOAK_REALM}/users`,
        userData,
        { headers: { Authorization: `Bearer ${adminToken}` } }
      );

      // Extract user ID from Location header
      const userId = response.headers.location.split('/').pop();

      // Assign default roles
      await this.assignRoles(userId, ['user'], adminToken);

      // Send verification email
      await this.sendVerificationEmail(userId, adminToken);

      res.status(201).json({ userId, email });
    } catch (error) {
      console.error('User creation failed:', error.response?.data);
      res.status(500).json({ error: 'Failed to create user' });
    }
  }

  async getAdminToken() {
    const response = await axios.post(
      `${process.env.KEYCLOAK_URL}/realms/master/protocol/openid-connect/token`,
      new URLSearchParams({
        username: process.env.KEYCLOAK_ADMIN_USER,
        password: process.env.KEYCLOAK_ADMIN_PASSWORD,
        grant_type: 'password',
        client_id: 'admin-cli'
      }),
      { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } }
    );
    return response.data.access_token;
  }
}
```

### Query Users by org_id

```bash
# Search users by org_id attribute
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8080/admin/realms/lobbi/users?q=org_id:org_acme"

# Get user with attributes
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8080/admin/realms/lobbi/users/{user-id}"
```

## Role and Group Management

### Create Realm Roles

```bash
# Create organization-level roles
curl -X POST "http://localhost:8080/admin/realms/lobbi/roles" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "org_admin",
    "description": "Organization Administrator",
    "composite": false,
    "clientRole": false
  }'

curl -X POST "http://localhost:8080/admin/realms/lobbi/roles" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "org_user",
    "description": "Organization User",
    "composite": false,
    "clientRole": false
  }'
```

### Assign Roles to User

```javascript
// In: services/user-service/src/services/role.service.js
export class RoleService {

  async assignRolesToUser(userId, roleNames, adminToken) {
    // Get role definitions
    const roles = await Promise.all(
      roleNames.map(async (roleName) => {
        const response = await axios.get(
          `${process.env.KEYCLOAK_URL}/admin/realms/${process.env.KEYCLOAK_REALM}/roles/${roleName}`,
          { headers: { Authorization: `Bearer ${adminToken}` } }
        );
        return response.data;
      })
    );

    // Assign roles to user
    await axios.post(
      `${process.env.KEYCLOAK_URL}/admin/realms/${process.env.KEYCLOAK_REALM}/users/${userId}/role-mappings/realm`,
      roles,
      { headers: { Authorization: `Bearer ${adminToken}` } }
    );
  }

  async getUserRoles(userId, adminToken) {
    const response = await axios.get(
      `${process.env.KEYCLOAK_URL}/admin/realms/${process.env.KEYCLOAK_REALM}/users/${userId}/role-mappings`,
      { headers: { Authorization: `Bearer ${adminToken}` } }
    );
    return response.data;
  }
}
```

### Create Groups for Organizations

```bash
# Create group for organization
curl -X POST "http://localhost:8080/admin/realms/lobbi/groups" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "org_acme",
    "attributes": {
      "org_id": ["org_acme"],
      "org_name": ["ACME Corporation"]
    }
  }'

# Add user to group
GROUP_ID="..."
USER_ID="..."
curl -X PUT "http://localhost:8080/admin/realms/lobbi/users/$USER_ID/groups/$GROUP_ID" \
  -H "Authorization: Bearer $TOKEN"
```

## Theme Deployment

### Theme Structure

```
keycloak-alpha/
└── services/
    └── keycloak-service/
        └── themes/
            ├── lobbi-base/
            │   ├── login/
            │   │   ├── theme.properties
            │   │   ├── login.ftl
            │   │   ├── register.ftl
            │   │   └── resources/
            │   │       ├── css/
            │   │       │   └── login.css
            │   │       ├── img/
            │   │       │   └── logo.png
            │   │       └── js/
            │   │           └── login.js
            │   ├── account/
            │   └── email/
            └── org-acme/
                ├── login/
                │   ├── theme.properties (parent=lobbi-base)
                │   └── resources/
                │       ├── css/
                │       │   └── custom.css
                │       └── img/
                │           └── org-logo.png
```

### Theme Properties

```properties
# themes/lobbi-base/login/theme.properties
parent=keycloak
import=common/keycloak

styles=css/login.css

# Localization
locales=en,es,fr

# Custom properties
logo.url=/resources/img/logo.png
```

### Deploy Theme

```bash
# Copy theme to Keycloak
docker cp themes/lobbi-base keycloak:/opt/keycloak/themes/

# Restart Keycloak to pick up new theme
docker restart keycloak

# Set theme for realm
curl -X PUT "http://localhost:8080/admin/realms/lobbi" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "loginTheme": "lobbi-base",
    "accountTheme": "lobbi-base",
    "emailTheme": "lobbi-base"
  }'
```

### Theme Customization per Organization

```javascript
// In: services/keycloak-service/src/middleware/theme-mapper.js
export const themeMapper = {
  org_acme: 'org-acme',
  org_beta: 'org-beta',
  default: 'lobbi-base'
};

export function getThemeForOrg(orgId) {
  return themeMapper[orgId] || themeMapper.default;
}

// Apply theme dynamically via query parameter
// URL: http://localhost:8080/realms/lobbi/protocol/openid-connect/auth?kc_theme=org-acme
```

## Token Configuration and Session Management

### Token Lifetime Configuration

```bash
# Update token lifespans
curl -X PUT "http://localhost:8080/admin/realms/lobbi" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "accessTokenLifespan": 300,
    "accessTokenLifespanForImplicitFlow": 900,
    "ssoSessionIdleTimeout": 1800,
    "ssoSessionMaxLifespan": 36000,
    "offlineSessionIdleTimeout": 2592000,
    "accessCodeLifespan": 60,
    "accessCodeLifespanUserAction": 300
  }'
```

### Custom Token Mapper for org_id

```bash
# Create protocol mapper to include org_id in token
CLIENT_UUID="..."
curl -X POST "http://localhost:8080/admin/realms/lobbi/clients/$CLIENT_UUID/protocol-mappers/models" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "org_id",
    "protocol": "openid-connect",
    "protocolMapper": "oidc-usermodel-attribute-mapper",
    "config": {
      "user.attribute": "org_id",
      "claim.name": "org_id",
      "jsonType.label": "String",
      "id.token.claim": "true",
      "access.token.claim": "true",
      "userinfo.token.claim": "true"
    }
  }'
```

### Verify Token Claims

```javascript
// In: services/api-gateway/src/middleware/auth.middleware.js
import jwt from 'jsonwebtoken';
import jwksClient from 'jwks-rsa';

const client = jwksClient({
  jwksUri: `${process.env.KEYCLOAK_URL}/realms/${process.env.KEYCLOAK_REALM}/protocol/openid-connect/certs`
});

function getKey(header, callback) {
  client.getSigningKey(header.kid, (err, key) => {
    const signingKey = key.publicKey || key.rsaPublicKey;
    callback(null, signingKey);
  });
}

export async function verifyToken(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '');

  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }

  jwt.verify(token, getKey, {
    audience: 'account',
    issuer: `${process.env.KEYCLOAK_URL}/realms/${process.env.KEYCLOAK_REALM}`,
    algorithms: ['RS256']
  }, (err, decoded) => {
    if (err) {
      return res.status(401).json({ error: 'Invalid token' });
    }

    // Verify org_id claim exists
    if (!decoded.org_id) {
      return res.status(403).json({ error: 'Missing org_id claim' });
    }

    req.user = decoded;
    next();
  });
}
```

## Common Troubleshooting

### Issue: CORS Errors

**Solution:** Configure Web Origins in client settings

```bash
curl -X PUT "http://localhost:8080/admin/realms/lobbi/clients/$CLIENT_UUID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "webOrigins": ["+"]
  }'
```

### Issue: Invalid Redirect URI

**Solution:** Verify redirect URIs match exactly

```javascript
// Check configured URIs
const redirectUris = [
  'http://localhost:3000/auth/callback',
  'https://app.lobbi.com/auth/callback'
];

// Ensure callback URL matches
const callbackUrl = `${window.location.origin}/auth/callback`;
```

### Issue: Token Not Including Custom Claims

**Solution:** Verify protocol mapper is added to client scopes

```bash
# Check client scopes
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8080/admin/realms/lobbi/clients/$CLIENT_UUID/default-client-scopes"

# Add custom scope with org_id mapper
curl -X POST "http://localhost:8080/admin/realms/lobbi/client-scopes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "org-scope",
    "protocol": "openid-connect",
    "protocolMappers": [...]
  }'
```

### Issue: User Cannot Login

**Checklist:**
1. Verify user is enabled: `GET /admin/realms/lobbi/users/{id}`
2. Check email is verified (if required)
3. Verify password is not temporary
4. Check realm login settings allow email login
5. Review authentication flow configuration

### Issue: Theme Not Applied

**Solution:**
1. Verify theme is copied to Keycloak themes directory
2. Restart Keycloak container
3. Clear browser cache
4. Check theme name in realm settings matches theme directory name

## File Locations in keycloak-alpha

| Path | Purpose |
|------|---------|
| `services/keycloak-service/` | Keycloak configuration and themes |
| `services/user-service/` | User management API |
| `services/api-gateway/src/middleware/auth.middleware.js` | Token verification |
| `apps/web-app/src/config/keycloak.config.js` | Frontend Keycloak config |
| `apps/web-app/src/hooks/useAuth.js` | Authentication hooks |

## Best Practices

1. **Always use PKCE** for Authorization Code Flow in SPAs
2. **Never expose client secrets** in frontend code
3. **Validate org_id claim** in every backend request
4. **Use short access token lifespans** (5-15 minutes)
5. **Implement refresh token rotation** for enhanced security
6. **Enable brute force protection** in realm settings
7. **Use groups** for organization-level permissions
8. **Version control themes** in the repository
9. **Test theme changes** in development realm first
10. **Monitor token usage** and session metrics
