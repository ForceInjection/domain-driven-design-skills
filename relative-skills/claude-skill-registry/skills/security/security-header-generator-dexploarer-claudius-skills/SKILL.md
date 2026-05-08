---
name: security-header-generator
description: Generates security HTTP headers (CSP, HSTS, CORS, etc.) for web applications to prevent common attacks. Use when user asks to "add security headers", "setup CSP", "configure CORS", "secure headers", or "HSTS setup".
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
---

# Security Header Generator

Generates security HTTP headers for web applications to prevent XSS, clickjacking, MITM attacks, and more.

## When to Use

- "Add security headers to my app"
- "Setup Content Security Policy"
- "Configure CORS headers"
- "Enable HSTS"
- "Secure my application headers"
- "Prevent clickjacking"
- "Setup security headers for Express/Next.js/nginx"

## Instructions

### 1. Detect Application Type

Scan the project to identify:

```bash
# Check for various frameworks/servers
[ -f "package.json" ] && echo "Node.js project"
[ -f "next.config.js" ] && echo "Next.js"
[ -f ".htaccess" ] && echo "Apache"
[ -f "nginx.conf" ] && echo "nginx"
[ -f "app.py" ] && echo "Python/Flask"
[ -f "Startup.cs" ] && echo ".NET"
```

Present findings:
- Project type detected
- Current security headers (if any)
- Recommended headers based on app type

### 2. Explain Security Headers

Brief overview of what will be added:

**Content Security Policy (CSP):**
- Prevents XSS attacks
- Controls resource loading sources
- Mitigates data injection attacks

**HTTP Strict Transport Security (HSTS):**
- Forces HTTPS connections
- Prevents protocol downgrade attacks
- Protects against MITM attacks

**X-Frame-Options:**
- Prevents clickjacking
- Controls iframe embedding
- Protects against UI redress attacks

**X-Content-Type-Options:**
- Prevents MIME-sniffing
- Blocks content-type confusion attacks

**Referrer-Policy:**
- Controls referrer information leakage
- Protects user privacy

**Permissions-Policy:**
- Controls browser features
- Limits API access (camera, microphone, etc.)

**CORS (Cross-Origin Resource Sharing):**
- Controls cross-origin requests
- Prevents unauthorized API access

### 3. Generate Headers Configuration

Based on detected framework, generate appropriate configuration:

## Framework-Specific Configurations

### Next.js

Create or update `next.config.js`:

```javascript
/** @type {import('next').NextConfig} */
const securityHeaders = [
  {
    key: 'Content-Security-Policy',
    value: ContentSecurityPolicy.replace(/\n/g, ''),
  },
  {
    key: 'X-DNS-Prefetch-Control',
    value: 'on',
  },
  {
    key: 'Strict-Transport-Security',
    value: 'max-age=63072000; includeSubDomains; preload',
  },
  {
    key: 'X-Frame-Options',
    value: 'SAMEORIGIN',
  },
  {
    key: 'X-Content-Type-Options',
    value: 'nosniff',
  },
  {
    key: 'X-XSS-Protection',
    value: '1; mode=block',
  },
  {
    key: 'Referrer-Policy',
    value: 'strict-origin-when-cross-origin',
  },
  {
    key: 'Permissions-Policy',
    value: 'camera=(), microphone=(), geolocation=()',
  },
]

// Content Security Policy
const ContentSecurityPolicy = `
  default-src 'self';
  script-src 'self' 'unsafe-eval' 'unsafe-inline';
  style-src 'self' 'unsafe-inline';
  img-src 'self' data: https:;
  font-src 'self' data:;
  object-src 'none';
  base-uri 'self';
  form-action 'self';
  frame-ancestors 'none';
  upgrade-insecure-requests;
`

const nextConfig = {
  async headers() {
    return [
      {
        source: '/:path*',
        headers: securityHeaders,
      },
    ]
  },
}

module.exports = nextConfig
```

### Express.js

Install helmet middleware:

```bash
npm install helmet
```

Configure in main app file:

```javascript
const express = require('express')
const helmet = require('helmet')

const app = express()

// Use Helmet middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
      fontSrc: ["'self'", "data:"],
      objectSrc: ["'none'"],
      baseUri: ["'self'"],
      formAction: ["'self'"],
      frameAncestors: ["'none'"],
      upgradeInsecureRequests: [],
    },
  },
  hsts: {
    maxAge: 63072000,
    includeSubDomains: true,
    preload: true,
  },
  frameguard: {
    action: 'sameorigin',
  },
  xssFilter: true,
  noSniff: true,
  referrerPolicy: {
    policy: 'strict-origin-when-cross-origin',
  },
  permissionsPolicy: {
    features: {
      camera: ["'none'"],
      microphone: ["'none'"],
      geolocation: ["'none'"],
    },
  },
}))

// CORS configuration (if needed)
const cors = require('cors')
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || 'http://localhost:3000',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}))

app.listen(3000)
```

### nginx

Create or update nginx configuration:

```nginx
# Security headers configuration
# Add this to your server block or http block

server {
    listen 443 ssl http2;
    server_name example.com;

    # SSL configuration
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;

    # Security Headers
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;

    # Content Security Policy
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; object-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'none'; upgrade-insecure-requests;" always;

    # CORS (if needed)
    add_header Access-Control-Allow-Origin "$http_origin" always;
    add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
    add_header Access-Control-Allow-Headers "Authorization, Content-Type" always;
    add_header Access-Control-Allow-Credentials "true" always;

    # Handle OPTIONS preflight
    if ($request_method = 'OPTIONS') {
        return 204;
    }

    location / {
        # Your app configuration
        proxy_pass http://localhost:3000;
    }
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name example.com;
    return 301 https://$server_name$request_uri;
}
```

### Apache (.htaccess)

Create or update `.htaccess`:

```apache
# Security Headers

# Force HTTPS
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
</IfModule>

# HTTP Strict Transport Security
<IfModule mod_headers.c>
    Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
</IfModule>

# X-Frame-Options
<IfModule mod_headers.c>
    Header always set X-Frame-Options "SAMEORIGIN"
</IfModule>

# X-Content-Type-Options
<IfModule mod_headers.c>
    Header always set X-Content-Type-Options "nosniff"
</IfModule>

# X-XSS-Protection
<IfModule mod_headers.c>
    Header always set X-XSS-Protection "1; mode=block"
</IfModule>

# Referrer Policy
<IfModule mod_headers.c>
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
</IfModule>

# Permissions Policy
<IfModule mod_headers.c>
    Header always set Permissions-Policy "camera=(), microphone=(), geolocation=()"
</IfModule>

# Content Security Policy
<IfModule mod_headers.c>
    Header always set Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; object-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'none'; upgrade-insecure-requests;"
</IfModule>

# CORS (if needed)
<IfModule mod_headers.c>
    Header always set Access-Control-Allow-Origin "*"
    Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    Header always set Access-Control-Allow-Headers "Authorization, Content-Type"
</IfModule>
```

### Flask/Python

```python
from flask import Flask
from flask_talisman import Talisman

app = Flask(__name__)

# Configure security headers with Talisman
csp = {
    'default-src': "'self'",
    'script-src': ["'self'", "'unsafe-inline'", "'unsafe-eval'"],
    'style-src': ["'self'", "'unsafe-inline'"],
    'img-src': ["'self'", "data:", "https:"],
    'font-src': ["'self'", "data:"],
    'object-src': "'none'",
    'base-uri': "'self'",
    'form-action': "'self'",
    'frame-ancestors': "'none'",
    'upgrade-insecure-requests': True,
}

Talisman(app,
    force_https=True,
    strict_transport_security=True,
    strict_transport_security_max_age=63072000,
    strict_transport_security_include_subdomains=True,
    content_security_policy=csp,
    content_security_policy_nonce_in=['script-src'],
    frame_options='SAMEORIGIN',
    frame_options_allow_from=None,
    referrer_policy='strict-origin-when-cross-origin',
    x_content_type_options=True,
    x_xss_protection=True,
)

# CORS configuration (if needed)
from flask_cors import CORS

CORS(app,
    origins=["http://localhost:3000"],
    methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["Content-Type", "Authorization"],
    supports_credentials=True,
)

@app.route('/')
def index():
    return 'Hello with secure headers!'

if __name__ == '__main__':
    app.run()
```

Install dependencies:
```bash
pip install flask-talisman flask-cors
```

### Django

```python
# settings.py

# Security Headers Middleware (built-in)
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    # ... other middleware
]

# Security Settings
SECURE_SSL_REDIRECT = True
SECURE_HSTS_SECONDS = 63072000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True

SECURE_CONTENT_TYPE_NOSNIFF = True
SECURE_BROWSER_XSS_FILTER = True

X_FRAME_OPTIONS = 'SAMEORIGIN'

SECURE_REFERRER_POLICY = 'strict-origin-when-cross-origin'

# Content Security Policy (use django-csp package)
# pip install django-csp
CSP_DEFAULT_SRC = ("'self'",)
CSP_SCRIPT_SRC = ("'self'", "'unsafe-inline'", "'unsafe-eval'")
CSP_STYLE_SRC = ("'self'", "'unsafe-inline'")
CSP_IMG_SRC = ("'self'", "data:", "https:")
CSP_FONT_SRC = ("'self'", "data:")
CSP_OBJECT_SRC = ("'none'",)
CSP_BASE_URI = ("'self'",)
CSP_FORM_ACTION = ("'self'",)
CSP_FRAME_ANCESTORS = ("'none'",)
CSP_UPGRADE_INSECURE_REQUESTS = True

# CORS (use django-cors-headers package)
# pip install django-cors-headers
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://localhost:8000",
]
CORS_ALLOW_CREDENTIALS = True
CORS_ALLOW_METHODS = [
    'DELETE',
    'GET',
    'OPTIONS',
    'PATCH',
    'POST',
    'PUT',
]
CORS_ALLOW_HEADERS = [
    'accept',
    'authorization',
    'content-type',
]
```

Add to MIDDLEWARE:
```python
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'csp.middleware.CSPMiddleware',
    'django.middleware.security.SecurityMiddleware',
    # ...
]
```

### 4. Customize for Project Needs

Ask user about specific requirements:

**CSP Customization:**
- External scripts needed? (Google Analytics, CDN scripts)
- Inline styles required? (styled-components, CSS-in-JS)
- Image CDNs or external sources?
- Font providers (Google Fonts)?
- API endpoints for fetch requests?

**CORS Customization:**
- Which origins should be allowed?
- Credentials needed? (cookies, authorization headers)
- Which HTTP methods?
- Custom headers required?

**Permissions Policy:**
- Camera access needed?
- Geolocation required?
- Microphone usage?
- Payment APIs?

### 5. Generate Test Suite

Create test file to verify headers:

```javascript
// test-security-headers.js
const https = require('https')

function testSecurityHeaders(url) {
  https.get(url, (res) => {
    console.log('Security Headers Test:\n')

    const requiredHeaders = {
      'strict-transport-security': 'HSTS',
      'x-frame-options': 'Clickjacking Protection',
      'x-content-type-options': 'MIME Sniffing Protection',
      'content-security-policy': 'CSP',
      'referrer-policy': 'Referrer Policy',
      'permissions-policy': 'Permissions Policy',
    }

    for (const [header, name] of Object.entries(requiredHeaders)) {
      const value = res.headers[header]
      if (value) {
        console.log(`✅ ${name}: ${value}`)
      } else {
        console.log(`❌ ${name}: MISSING`)
      }
    }
  })
}

testSecurityHeaders('https://your-domain.com')
```

### 6. Provide Testing Instructions

Show how to test headers:

**Using curl:**
```bash
# Test all headers
curl -I https://your-domain.com

# Test specific header
curl -I https://your-domain.com | grep -i strict-transport-security
```

**Using online tools:**
- Security Headers: https://securityheaders.com/
- Mozilla Observatory: https://observatory.mozilla.org/
- SSL Labs: https://www.ssllabs.com/ssltest/

**Using browser DevTools:**
1. Open DevTools (F12)
2. Go to Network tab
3. Reload page
4. Click on first request
5. Check "Response Headers" section

### 7. Document Warnings and Considerations

**CSP Warnings:**
- 'unsafe-inline' reduces security - remove if possible
- 'unsafe-eval' allows eval() - avoid if not needed
- Test thoroughly - CSP can break functionality
- Use CSP report-only mode first

**HSTS Considerations:**
- Can't easily undo once set
- Test on staging first
- Consider shorter max-age initially
- HSTS preload is permanent

**CORS Warnings:**
- Wildcard (*) allows all origins - use specific origins
- credentials + wildcard not allowed
- Preflight requests add latency

**General:**
- Headers may break third-party integrations
- Test all functionality after adding
- Monitor for CSP violations
- Update CSP as app evolves

### 8. Setup CSP Reporting

Offer to set up CSP violation reporting:

```javascript
// CSP with report URI
const ContentSecurityPolicy = `
  default-src 'self';
  script-src 'self' 'unsafe-inline';
  style-src 'self' 'unsafe-inline';
  img-src 'self' data: https:;
  font-src 'self' data:;
  object-src 'none';
  base-uri 'self';
  form-action 'self';
  frame-ancestors 'none';
  report-uri /csp-violation-report;
  report-to csp-endpoint;
`

// Express endpoint to receive reports
app.post('/csp-violation-report', express.json({ type: 'application/csp-report' }), (req, res) => {
  console.log('CSP Violation:', req.body)
  // Log to monitoring service
  res.status(204).end()
})
```

### 9. Create Environment-Specific Configs

Suggest different headers for dev vs production:

```javascript
// next.config.js
const isDev = process.env.NODE_ENV === 'development'

const ContentSecurityPolicy = isDev
  ? `
    default-src 'self' 'unsafe-eval' 'unsafe-inline';
    script-src 'self' 'unsafe-eval' 'unsafe-inline';
    style-src 'self' 'unsafe-inline';
  `
  : `
    default-src 'self';
    script-src 'self';
    style-src 'self';
    img-src 'self' data: https:;
  `
```

### 10. Provide Maintenance Guide

Document how to:
- Add new external sources to CSP
- Update CORS origins
- Adjust security levels
- Handle CSP violations
- Test changes safely

## Security Level Presets

Offer different security profiles:

### Strict (Recommended for Production)
```
CSP: No unsafe-inline, no unsafe-eval
HSTS: Long max-age with preload
CORS: Specific origins only
Permissions: All restricted
```

### Moderate (Balance Security/Functionality)
```
CSP: Limited unsafe-inline for styling
HSTS: Standard max-age
CORS: Controlled origins
Permissions: Essential features only
```

### Relaxed (Development)
```
CSP: Permissive for hot reload
HSTS: Disabled or short max-age
CORS: Localhost allowed
Permissions: Most allowed
```

## Common Patterns

### API Server Headers
```javascript
// API doesn't need all headers
app.use(helmet({
  contentSecurityPolicy: false, // No HTML content
  xssFilter: false, // No HTML rendering
  hsts: {
    maxAge: 63072000,
    includeSubDomains: true,
  },
}))

// Strict CORS for APIs
app.use(cors({
  origin: function(origin, callback) {
    const allowedOrigins = process.env.ALLOWED_ORIGINS.split(',')
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true)
    } else {
      callback(new Error('Not allowed by CORS'))
    }
  },
  credentials: true,
}))
```

### Static Site Headers
```nginx
# Static HTML/CSS/JS site
add_header Content-Security-Policy "default-src 'self'; img-src 'self' data: https:; font-src 'self' data:; style-src 'self' 'unsafe-inline';" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

### SPA with API Headers
```javascript
// Frontend SPA headers (Next.js)
const securityHeaders = [
  {
    key: 'Content-Security-Policy',
    value: "default-src 'self'; connect-src 'self' https://api.example.com; script-src 'self' 'unsafe-inline' 'unsafe-eval';",
  },
  // ... other headers
]

// Separate API server (Express)
app.use(cors({
  origin: ['https://app.example.com', 'https://www.example.com'],
  credentials: true,
}))
```

## Best Practices

1. ✅ Start with report-only CSP, then enforce
2. ✅ Test headers on staging before production
3. ✅ Use environment variables for origins
4. ✅ Monitor CSP violations in production
5. ✅ Regular security header audits
6. ✅ Keep HSTS max-age reasonable initially
7. ✅ Document all header decisions
8. ✅ Version control security configs
