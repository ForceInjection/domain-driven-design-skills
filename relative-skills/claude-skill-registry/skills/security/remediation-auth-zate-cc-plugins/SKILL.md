---
name: remediation-auth
description: Security fix patterns for authentication and authorization vulnerabilities (credentials, JWT, deserialization, access control). Provides language-specific secure implementations.
---

# Remediation: Authentication & Authorization Vulnerabilities

Actionable fix patterns for auth-related security vulnerabilities.

## When to Use This Skill

- **Fixing hardcoded credentials** - After finding secrets in code
- **Fixing JWT issues** - After finding weak JWT configuration
- **Fixing deserialization** - After finding unsafe deserialization
- **Fixing access control** - After finding missing authorization checks

## When NOT to Use This Skill

- **Detecting vulnerabilities** - Use vulnerability-patterns skill
- **Fixing injection issues** - Use remediation-injection skill
- **Fixing crypto issues** - Use remediation-crypto skill
- **Fixing config issues** - Use remediation-config skill

---

## Hardcoded Credentials (CWE-798)

### Problem
Credentials in source code are exposed in version control and can be extracted from compiled code.

### All Languages

**Don't**:
```python
# VULNERABLE: Hardcoded credentials
API_KEY = "sk-1234567890abcdef"
DB_PASSWORD = "admin123"
JWT_SECRET = "mysupersecretkey"
```

**Do**:
```python
# SECURE: Environment variables
import os
API_KEY = os.environ.get('API_KEY')
DB_PASSWORD = os.environ.get('DB_PASSWORD')

# SECURE: Configuration file (not in git)
import configparser
config = configparser.ConfigParser()
config.read('/etc/myapp/secrets.ini')
api_key = config['api']['key']

# SECURE: Secret manager (AWS Secrets Manager)
import boto3
client = boto3.client('secretsmanager')
response = client.get_secret_value(SecretId='myapp/api-key')
api_key = response['SecretString']

# SECURE: Vault
import hvac
client = hvac.Client(url='https://vault.example.com')
secret = client.secrets.kv.read_secret_version(path='myapp/api-key')
api_key = secret['data']['data']['value']
```

### Configuration Files

**Don't**:
```yaml
# VULNERABLE: .env committed to git
DATABASE_URL=postgres://admin:password123@localhost/db
API_SECRET=sk-live-abcdef123456

# VULNERABLE: docker-compose.yml with secrets
environment:
  - DB_PASSWORD=admin123
```

**Do**:
```yaml
# SECURE: .env.example (template, no real values)
DATABASE_URL=postgres://user:password@host/database
API_SECRET=your-api-secret-here

# SECURE: docker-compose with external secrets
environment:
  - DB_PASSWORD_FILE=/run/secrets/db_password
secrets:
  db_password:
    external: true

# SECURE: Use secret references
environment:
  - DB_PASSWORD=${DB_PASSWORD}  # Set at runtime
```

**ASVS**: V13.3.1, V13.3.2
**References**: [OWASP Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)

---

## Insecure Deserialization (CWE-502)

### Problem
Deserializing untrusted data can lead to remote code execution.

### Python

**Don't**:
```python
# VULNERABLE: pickle with untrusted data
import pickle
data = pickle.loads(user_input)

# VULNERABLE: yaml.load without SafeLoader
import yaml
data = yaml.load(user_input, Loader=yaml.Loader)
```

**Do**:
```python
# SECURE: JSON for untrusted data
import json
data = json.loads(user_input)

# SECURE: yaml.safe_load
import yaml
data = yaml.safe_load(user_input)

# SECURE: If pickle is required, use hmac signing
import pickle
import hmac
import hashlib

def secure_loads(data, key):
    signature, payload = data[:64], data[64:]
    expected = hmac.new(key, payload, hashlib.sha256).hexdigest()
    if not hmac.compare_digest(signature, expected):
        raise ValueError("Invalid signature")
    return pickle.loads(payload)
```

### Java

**Don't**:
```java
// VULNERABLE: ObjectInputStream with untrusted data
ObjectInputStream ois = new ObjectInputStream(inputStream);
Object obj = ois.readObject();
```

**Do**:
```java
// SECURE: Use JSON instead
ObjectMapper mapper = new ObjectMapper();
MyClass obj = mapper.readValue(jsonString, MyClass.class);

// SECURE: If Java serialization required, use allowlist
ObjectInputFilter filter = ObjectInputFilter.Config.createFilter(
    "com.myapp.*;java.util.*;!*"
);
ObjectInputStream ois = new ObjectInputStream(inputStream);
ois.setObjectInputFilter(filter);
```

### PHP

**Don't**:
```php
// VULNERABLE: unserialize with user input
$data = unserialize($_POST['data']);
```

**Do**:
```php
// SECURE: JSON instead
$data = json_decode($_POST['data'], true);

// SECURE: If unserialize required, use allowed_classes
$data = unserialize($input, ['allowed_classes' => ['AllowedClass']]);
```

**ASVS**: V1.5.1, V1.5.2
**References**: [OWASP Deserialization](https://cheatsheetseries.owasp.org/cheatsheets/Deserialization_Cheat_Sheet.html)

---

## JWT Security (CWE-347)

### Problem
Weak JWT configuration allows token forgery or manipulation.

### JavaScript (Node.js)

**Don't**:
```javascript
// VULNERABLE: "none" algorithm accepted
const decoded = jwt.verify(token, secret);  // May accept alg: "none"

// VULNERABLE: Weak secret
const token = jwt.sign(payload, 'secret');

// VULNERABLE: HS256 with RSA public key
const decoded = jwt.verify(token, publicKey);  // Algorithm confusion
```

**Do**:
```javascript
// SECURE: Explicit algorithm specification
const jwt = require('jsonwebtoken');

// Signing
const token = jwt.sign(payload, privateKey, {
  algorithm: 'RS256',
  expiresIn: '1h',
  issuer: 'myapp',
  audience: 'myapp-users'
});

// Verification with explicit options
const decoded = jwt.verify(token, publicKey, {
  algorithms: ['RS256'],  // Explicitly allow only RS256
  issuer: 'myapp',
  audience: 'myapp-users'
});

// SECURE: Strong symmetric key (if using HS256)
const crypto = require('crypto');
const secret = crypto.randomBytes(64).toString('hex');  // 512 bits
```

### Python (PyJWT)

**Do**:
```python
import jwt

# Signing
token = jwt.encode(
    payload,
    private_key,
    algorithm='RS256',
    headers={'kid': key_id}
)

# Verification
decoded = jwt.decode(
    token,
    public_key,
    algorithms=['RS256'],  # Explicit allowlist
    audience='myapp-users',
    issuer='myapp'
)
```

**ASVS**: V9.2.1, V9.2.2, V9.3.1
**References**: [OWASP JWT Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html)

---

## Missing Access Control (CWE-862)

### Problem
Endpoints accessible without proper authorization checks allow unauthorized access.

### Python (Flask)

**Don't**:
```python
# VULNERABLE: No authorization check
@app.route('/api/users/<int:user_id>')
def get_user(user_id):
    return User.query.get_or_404(user_id)

# VULNERABLE: Client-side only check
@app.route('/admin/dashboard')
def admin_dashboard():
    # Relies on frontend to hide link
    return render_template('admin.html')
```

**Do**:
```python
# SECURE: Authorization decorator
from functools import wraps
from flask import g, abort

def require_permission(permission):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if not g.user.has_permission(permission):
                abort(403)
            return f(*args, **kwargs)
        return decorated_function
    return decorator

@app.route('/api/users/<int:user_id>')
@require_permission('users:read')
def get_user(user_id):
    # Also check ownership for user's own data
    if g.user.id != user_id and not g.user.is_admin:
        abort(403)
    return User.query.get_or_404(user_id)
```

### JavaScript (Express)

**Do**:
```javascript
// SECURE: Middleware for authorization
const authorize = (requiredRole) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    if (!req.user.roles.includes(requiredRole)) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    next();
  };
};

// SECURE: Resource ownership check
app.get('/api/users/:id', authorize('user'), (req, res) => {
  if (req.params.id !== req.user.id && !req.user.roles.includes('admin')) {
    return res.status(403).json({ error: 'Forbidden' });
  }
  // Return user data
});
```

### Java (Spring)

**Do**:
```java
// SECURE: Method-level security
@PreAuthorize("hasRole('ADMIN') or #userId == authentication.principal.id")
@GetMapping("/users/{userId}")
public User getUser(@PathVariable Long userId) {
    return userService.findById(userId);
}

// SECURE: Custom authorization
@GetMapping("/resources/{id}")
public Resource getResource(@PathVariable Long id, Authentication auth) {
    Resource resource = resourceService.findById(id);
    if (!resource.getOwnerId().equals(auth.getName()) &&
        !auth.getAuthorities().contains(new SimpleGrantedAuthority("ROLE_ADMIN"))) {
        throw new AccessDeniedException("Not authorized");
    }
    return resource;
}
```

**ASVS**: V8.2.1, V8.2.2, V8.2.3
**References**: [OWASP Access Control](https://cheatsheetseries.owasp.org/cheatsheets/Access_Control_Cheat_Sheet.html)

---

## Quick Reference

| Vulnerability | Fix Pattern | Key Libraries |
|---------------|-------------|---------------|
| Hardcoded secrets | Environment variables, secret managers | dotenv, boto3, hvac |
| Unsafe deserialization | JSON, safe loaders | json, yaml.safe_load |
| Weak JWT | Explicit algorithms, strong keys | jsonwebtoken, PyJWT |
| Missing authz | Middleware, decorators | Flask-Login, Passport.js |

## See Also

- `remediation-injection` - Injection fixes
- `remediation-crypto` - Cryptography fixes
- `remediation-config` - Configuration fixes
- `vulnerability-patterns` - Detection patterns
