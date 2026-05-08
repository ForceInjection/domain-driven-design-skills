---
name: security-express
description: Express.js security audit patterns. Load when reviewing Express apps. Covers Helmet.js, CORS, body-parser limits, auth middleware, and common Express security mistakes.
---

<overview>

Security audit patterns for Express.js applications covering essential security middleware, CORS configuration, auth patterns, and common vulnerabilities.

</overview>

<rules>

## Essential Security Middleware

### Helmet.js (Security Headers)
```javascript
// ❌ Missing security headers
const app = express();

// ✓ Use Helmet
const helmet = require('helmet');
app.use(helmet());
```

**Check if Helmet is installed and used.** It sets:
- Content-Security-Policy
- X-Content-Type-Options: nosniff
- X-Frame-Options: DENY
- Strict-Transport-Security
- And more...

### Disable X-Powered-By
```javascript
// ❌ Default (header reveals framework)
const app = express();

// ✓ Disable fingerprinting
app.disable('x-powered-by');
// or: app.set('x-powered-by', false);
```

### CORS Configuration
```javascript
// ❌ CRITICAL: Allow all origins
app.use(cors());
app.use(cors({ origin: '*' }));

// ❌ HIGH: Reflect origin with credentials
app.use(cors({ 
  origin: true,  // Reflects any origin!
  credentials: true 
}));

// ✓ Explicit allowlist
app.use(cors({
  origin: ['https://app.example.com', 'https://admin.example.com'],
  credentials: true,
}));

// ✓ Function for dynamic validation
app.use(cors({
  origin: (origin, callback) => {
    const allowed = ['https://app.example.com'];
    if (!origin || allowed.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
}));
```

## Body Parser Limits

```javascript
// ❌ No limit (DoS risk)
app.use(express.json());

// ✓ Set reasonable limits
app.use(express.json({ limit: '100kb' }));
app.use(express.urlencoded({ extended: true, limit: '100kb' }));
```

</rules>

<vulnerabilities>

## Auth Middleware Patterns

### Missing Auth on Routes
```javascript
// ❌ No auth on admin routes
app.get('/api/admin/users', async (req, res) => {
  res.json(await User.find());
});

// ✓ Auth middleware applied
app.get('/api/admin/users', requireAuth, requireAdmin, async (req, res) => {
  res.json(await User.find());
});
```

### Middleware Order Matters
```javascript
// ❌ Wrong order - static files before auth
app.use(express.static('uploads')); // Exposed!
app.use(requireAuth);

// ✓ Auth before protected static files
app.use('/public', express.static('public')); // Intentionally public
app.use(requireAuth);
app.use('/uploads', express.static('uploads')); // Now protected
```

### Router-Level Auth Gaps
```javascript
// Check: Is auth applied to all routes in admin router?
const adminRouter = express.Router();
adminRouter.use(requireAuth); // Applied to all routes below
adminRouter.get('/users', getUsers);
adminRouter.delete('/users/:id', deleteUser);

// ❌ Watch for routes defined BEFORE the middleware
const apiRouter = express.Router();
apiRouter.get('/health', getHealth); // No auth (intentional?)
apiRouter.use(requireAuth);
apiRouter.get('/users', getUsers); // Has auth
```

## Common Vulnerabilities

### SQL/NoSQL Injection
```javascript
// ❌ String interpolation
const user = await db.query(`SELECT * FROM users WHERE id = ${req.params.id}`);

// ✓ Parameterized query
const user = await db.query('SELECT * FROM users WHERE id = $1', [req.params.id]);

// ❌ MongoDB injection
const user = await User.findOne({ email: req.body.email }); // If email is { $gt: "" }

// ✓ Validate input type
if (typeof req.body.email !== 'string') return res.status(400).json({ error: 'Invalid email' });
```

### Path Traversal
```javascript
// ❌ User-controlled path
app.get('/files/:filename', (req, res) => {
  res.sendFile(`./uploads/${req.params.filename}`); // ../../etc/passwd
});

// ✓ Validate and normalize
const path = require('path');
app.get('/files/:filename', (req, res) => {
  const filename = path.basename(req.params.filename);
  const filepath = path.join(__dirname, 'uploads', filename);
  if (!filepath.startsWith(path.join(__dirname, 'uploads'))) {
    return res.status(400).json({ error: 'Invalid path' });
  }
  res.sendFile(filepath);
});
```

### Error Handling
```javascript
// ❌ Stack traces in production
app.use((err, req, res, next) => {
  res.status(500).json({ error: err.stack }); // Leaks internals
});

// ✓ Safe error handler
app.use((err, req, res, next) => {
  console.error(err); // Log for debugging
  res.status(500).json({ error: 'Internal server error' });
});
```

### Session Security
```javascript
// ❌ Insecure session config
app.use(session({
  secret: 'keyboard cat', // Hardcoded!
  cookie: { secure: false }, // No HTTPS requirement
}));

// ✓ Secure config
app.use(session({
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: true, // HTTPS only
    httpOnly: true, // No JS access
    sameSite: 'strict', // CSRF protection
    maxAge: 1000 * 60 * 60 * 24, // 24 hours
  },
}));
```

## Rate Limiting

```javascript
// Check for rate limiting on auth routes
const rateLimit = require('express-rate-limit');

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts
  message: 'Too many login attempts',
});

app.post('/api/login', authLimiter, loginHandler);
app.post('/api/register', authLimiter, registerHandler);
app.post('/api/forgot-password', authLimiter, forgotPasswordHandler);
```

</vulnerabilities>

<commands>

## Quick Audit Commands

```bash
# Check if Helmet is used
rg -n 'helmet\\(' . -g "*.js" -g "*.ts"

# Check if x-powered-by is disabled
rg -n "x-powered-by" . -g "*.js" -g "*.ts"
```

```bash
# Check for helmet
rg "helmet" package.json
rg "require\\(['\"]helmet" .
rg "from ['\"]helmet" .

# Find CORS config
rg "cors\\(" . -g "*.js" -g "*.ts" -A 5

# Find routes without auth middleware
rg "app\\.(get|post|put|delete|patch)\\(" . -A 1 | grep -v "require.*[Aa]uth"

# Find string interpolation in queries
rg "(query|find|findOne|exec).*\\`" . -g "*.js" -g "*.ts"

# Check session config
rg "session\\(" . -A 10
```

</commands>

<checklist>

## Hardening Checklist

- [ ] Helmet.js installed and used
- [ ] CORS restricted to specific origins
- [ ] Body parser has size limits
- [ ] Auth middleware on all protected routes
- [ ] Rate limiting on auth endpoints
- [ ] Session cookies: secure, httpOnly, sameSite
- [ ] No hardcoded secrets
- [ ] Error handler doesn't leak stack traces
- [ ] Input validation on all user input
- [ ] Parameterized queries (no string concat)

</checklist>
