---
name: security-testing-verification
description: Test security features and verify implementation before deployment. Use this skill when you need to test CSRF protection, rate limiting, input validation, verify security headers, run security audits, or check the pre-deployment security checklist. Triggers include "test security", "security testing", "verify security", "security checklist", "pre-deployment", "test CSRF", "test rate limit", "security verification".
---

# Security Testing & Verification

## Built-In Security Tests

This project includes automated tests and verification scripts for all security features.

## Testing Rate Limiting

### Automated Test Script

```bash
# Run the provided test script
node scripts/test-rate-limit.js
```

**What it tests:**
- Makes 10 consecutive requests to rate-limited endpoint
- Verifies first 5 succeed (HTTP 200)
- Verifies requests 6-10 are blocked (HTTP 429)
- Tests rate limit reset after 60 seconds

**Expected output:**
```
Testing Rate Limiting (5 requests/minute per IP)
Request  1: ✓ 200 - Success
Request  2: ✓ 200 - Success
Request  3: ✓ 200 - Success
Request  4: ✓ 200 - Success
Request  5: ✓ 200 - Success
Request  6: ✗ 429 - Too many requests
Request  7: ✗ 429 - Too many requests
Request  8: ✗ 429 - Too many requests
Request  9: ✗ 429 - Too many requests
Request 10: ✗ 429 - Too many requests

✓ Rate limiting is working correctly!
```

### Manual Testing

```bash
# Test rate limiting manually
for i in {1..10}; do
  echo "Request $i:"
  curl -s -o /dev/null -w "%{http_code}\n" \
    http://localhost:3000/api/test-rate-limit
  sleep 0.1
done

# Expected:
# Requests 1-5: 200
# Requests 6-10: 429
```

### Test Reset After Window

```bash
# Make 5 requests
for i in {1..5}; do
  curl http://localhost:3000/api/test-rate-limit
done

# Wait 61 seconds (rate limit window = 60 seconds)
sleep 61

# Try again - should succeed
curl http://localhost:3000/api/test-rate-limit

# Expected: 200 OK (limit reset)
```

## Testing CSRF Protection

### Test 1: Request Without Token (Should Fail)

```bash
curl -X POST http://localhost:3000/api/example-protected \
  -H "Content-Type: application/json" \
  -d '{"title": "test"}'

# Expected: 403 Forbidden
# {
#   "error": "CSRF token missing"
# }
```

### Test 2: Request With Valid Token (Should Succeed)

```bash
# Step 1: Get CSRF token
TOKEN=$(curl -s http://localhost:3000/api/csrf \
  -c cookies.txt | jq -r '.csrfToken')

# Step 2: Use token in request
curl -X POST http://localhost:3000/api/example-protected \
  -b cookies.txt \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: $TOKEN" \
  -d '{"title": "test"}'

# Expected: 200 OK
```

### Test 3: Token Reuse (Should Fail)

```bash
# Get token
TOKEN=$(curl -s http://localhost:3000/api/csrf \
  -c cookies.txt | jq -r '.csrfToken')

# Use once (succeeds)
curl -X POST http://localhost:3000/api/example-protected \
  -b cookies.txt \
  -H "X-CSRF-Token: $TOKEN" \
  -d '{"title": "test"}'

# Try to reuse same token (should fail)
curl -X POST http://localhost:3000/api/example-protected \
  -b cookies.txt \
  -H "X-CSRF-Token: $TOKEN" \
  -d '{"title": "test2"}'

# Expected: 403 Forbidden - Token already used
```

### Test 4: Invalid Token (Should Fail)

```bash
curl -X POST http://localhost:3000/api/example-protected \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: fake-token-12345" \
  -d '{"title": "test"}'

# Expected: 403 Forbidden
# {
#   "error": "CSRF token invalid"
# }
```

## Testing Input Validation

### Test XSS Sanitization

```bash
# Test script tags removal
curl -X POST http://localhost:3000/api/example-protected \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: <get-token-first>" \
  -d '{"title": "<script>alert(1)</script>"}'

# Expected: 200 OK
# Title sanitized to: "alert(1)"
# < and > removed
```

### Test Length Validation

```bash
# Test too-long input
curl -X POST http://localhost:3000/api/example-protected \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: <token>" \
  -d "{\"title\": \"$(printf 'A%.0s' {1..200})\"}"

# Expected: 400 Bad Request
# {
#   "error": "Validation failed",
#   "details": {
#     "title": "String must contain at most 100 character(s)"
#   }
# }
```

### Test Email Validation

```bash
curl -X POST http://localhost:3000/api/contact \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "not-an-email",
    "subject": "Test",
    "message": "Test message"
  }'

# Expected: 400 Bad Request
# {
#   "error": "Validation failed",
#   "details": {
#     "email": "Invalid email"
#   }
# }
```

### Test Required Fields

```bash
curl -X POST http://localhost:3000/api/contact \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User"
  }'

# Expected: 400 Bad Request with missing field errors
```

## Testing Security Headers

### Test All Headers

```bash
curl -I http://localhost:3000

# Expected headers:
# Content-Security-Policy: default-src 'self'; ...
# X-Frame-Options: DENY
# X-Content-Type-Options: nosniff
# (HSTS only in production)
```

### Test CSP

```bash
# Check CSP includes required domains
curl -I http://localhost:3000 | grep "Content-Security-Policy"

# Should include:
# - script-src with Clerk domain
# - connect-src with Convex domain
# - frame-src with Stripe domain
```

### Test HSTS (Production Only)

```bash
# In production environment
curl -I https://yourapp.com | grep "Strict-Transport-Security"

# Should return:
# Strict-Transport-Security: max-age=31536000; includeSubDomains
```

### Test Protected Route Headers

```bash
curl -I http://localhost:3000/dashboard

# Should include:
# X-Robots-Tag: noindex, nofollow
```

## Testing Authentication

### Test Unauthenticated Access

```bash
# Try to access protected API without auth
curl http://localhost:3000/api/protected-endpoint

# Expected: 401 Unauthorized
# {
#   "error": "Unauthorized",
#   "message": "Authentication required"
# }
```

### Test Authenticated Access

```bash
# With valid Clerk session cookie
curl http://localhost:3000/api/protected-endpoint \
  -H "Cookie: __session=<clerk-session-token>"

# Expected: 200 OK (with authorized response)
```

### Test Authorization (Resource Ownership)

```bash
# Try to access another user's resource
curl http://localhost:3000/api/posts/user-abc-post-123 \
  -H "Cookie: __session=<different-user-token>"

# Expected: 403 Forbidden
# {
#   "error": "Forbidden",
#   "message": "You do not have access to this resource"
# }
```

### Test Subscription Gating

```bash
# Try premium feature with free account
curl http://localhost:3000/api/premium/generate \
  -H "Cookie: __session=<free-user-token>"

# Expected: 403 Forbidden
# {
#   "error": "Forbidden",
#   "message": "Premium subscription required"
# }
```

## Testing Error Handling

### Test Production Error Messages

```bash
# Set NODE_ENV=production temporarily
export NODE_ENV=production

# Trigger error in API
curl http://localhost:3000/api/error-test

# Expected: Generic message (no stack trace)
# {
#   "error": "Internal server error",
#   "message": "An unexpected error occurred"
# }
```

### Test Development Error Messages

```bash
# In development (NODE_ENV=development)
curl http://localhost:3000/api/error-test

# Expected: Detailed error with stack trace
# {
#   "error": "Internal server error",
#   "message": "Specific error message",
#   "stack": "Error: ...\n    at ...",
#   "context": "error-test"
# }
```

## Testing Dependency Security

### Run npm Audit

```bash
# Check for vulnerabilities
npm audit

# Expected: 0 vulnerabilities
# found 0 vulnerabilities
```

### Run Production Audit

```bash
# Only check production dependencies
npm audit --production

# Expected: 0 vulnerabilities
```

### Check Outdated Packages

```bash
npm outdated

# Expected: All packages up-to-date
# (or list of safe minor/patch updates available)
```

### Run Security Check Script

```bash
bash scripts/security-check.sh

# Expected:
# - 0 vulnerabilities
# - Minimal outdated packages
# - Fix commands if needed
```

## Online Security Testing Tools

### Security Headers Scanner

**Tool:** https://securityheaders.com/

**How to use:**
1. Deploy your app
2. Enter URL in Security Headers scanner
3. Check for A+ rating

**What it checks:**
- Content-Security-Policy
- X-Frame-Options
- X-Content-Type-Options
- Strict-Transport-Security
- Referrer-Policy
- Permissions-Policy

### Mozilla Observatory

**Tool:** https://observatory.mozilla.org/

**How to use:**
1. Enter your deployed URL
2. Run scan
3. Check score (aim for A+)

**What it checks:**
- Security headers
- Cookie security
- HTTPS configuration
- Subresource integrity
- Content Security Policy

### SSL Labs

**Tool:** https://www.ssllabs.com/ssltest/

**How to use:**
1. Enter your domain
2. Wait for scan (takes ~2 minutes)
3. Check for A+ rating

**What it checks:**
- SSL/TLS configuration
- Certificate validity
- Protocol support
- Cipher suite strength
- HSTS configuration

## Pre-Deployment Security Checklist

Run through this checklist before every production deployment:

### Environment & Configuration

- [ ] All environment variables set in production
- [ ] `CSRF_SECRET` generated and configured (32+ bytes)
- [ ] `SESSION_SECRET` generated and configured (32+ bytes)
- [ ] Clerk production keys configured
- [ ] Stripe live mode keys configured (if using payments)
- [ ] `.env.local` NOT committed to git

### Dependencies

- [ ] Run `npm audit --production` - **0 vulnerabilities**
- [ ] Run `npm outdated` - Check for critical updates
- [ ] `package-lock.json` committed
- [ ] Next.js on latest stable version

### Security Features

- [ ] CSRF protection tested (see tests above)
- [ ] Rate limiting tested (see tests above)
- [ ] Input validation tested (see tests above)
- [ ] Security headers verified (securityheaders.com)
- [ ] HSTS enabled in production
- [ ] Error messages are generic in production

### Authentication & Authorization

- [ ] Protected routes require authentication
- [ ] Resource ownership checked before access
- [ ] Subscription status verified for premium features
- [ ] Webhook signatures verified (Clerk, Stripe)
- [ ] Session expiration handled gracefully

### API Security

- [ ] All POST/PUT/DELETE routes have CSRF protection
- [ ] All public endpoints have rate limiting
- [ ] All user input validated with Zod
- [ ] All errors handled with error handler utilities
- [ ] No sensitive data in logs
- [ ] No hardcoded secrets in code

### Payment Security (if applicable)

- [ ] Using Clerk Billing + Stripe (not handling cards directly)
- [ ] Webhooks verified (Svix signatures)
- [ ] Subscription status checked on server
- [ ] Test mode disabled in production

### Testing

- [ ] Run rate limit test: `node scripts/test-rate-limit.js`
- [ ] Test CSRF protection manually
- [ ] Test input validation with malicious input
- [ ] Check security headers: `curl -I https://yourapp.com`
- [ ] Test authentication flows
- [ ] Test error handling in production mode

### Monitoring

- [ ] Error logging configured (Vercel logs)
- [ ] Failed auth attempts tracked (Clerk dashboard)
- [ ] GitHub Dependabot alerts enabled
- [ ] Security headers monitored (automated checks)

## Automated Testing Script

### security-test.sh

Create a comprehensive test script:

```bash
#!/bin/bash

echo "================================="
echo "Security Testing Suite"
echo "================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
PASSED=0
FAILED=0

# Function to run test
run_test() {
    local test_name=$1
    local command=$2
    local expected=$3

    echo -n "Testing $test_name... "

    result=$(eval $command 2>&1)

    if echo "$result" | grep -q "$expected"; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC}"
        echo "  Expected: $expected"
        echo "  Got: $result"
        ((FAILED++))
    fi
}

echo "=== Dependency Security ==="
run_test "npm audit" "npm audit --production" "found 0 vulnerabilities"

echo ""
echo "=== Rate Limiting ==="
echo "Running rate limit test script..."
node scripts/test-rate-limit.js

echo ""
echo "=== Security Headers ==="
run_test "X-Frame-Options" "curl -I http://localhost:3000" "X-Frame-Options: DENY"
run_test "X-Content-Type-Options" "curl -I http://localhost:3000" "X-Content-Type-Options: nosniff"
run_test "Content-Security-Policy" "curl -I http://localhost:3000" "Content-Security-Policy"

echo ""
echo "================================="
echo "Tests Passed: $PASSED"
echo "Tests Failed: $FAILED"
echo "================================="

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi
```

**Run it:**
```bash
bash scripts/security-test.sh
```

## Continuous Security Testing

### Add to CI/CD Pipeline

```yaml
# .github/workflows/security.yml
name: Security Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  security:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm ci

      - name: Run npm audit
        run: npm audit --production

      - name: Check for outdated packages
        run: npm outdated || true

      - name: Build application
        run: npm run build

      - name: Start server (background)
        run: npm run dev &
        env:
          NODE_ENV: test

      - name: Wait for server
        run: npx wait-on http://localhost:3000

      - name: Run security tests
        run: bash scripts/security-test.sh

      - name: Stop server
        run: pkill -f "npm run dev"
```

## Manual Penetration Testing

### Test XSS in All Input Fields

1. Try these payloads in every input:
   ```
   <script>alert('XSS')</script>
   <img src=x onerror=alert('XSS')>
   <svg onload=alert('XSS')>
   javascript:alert('XSS')
   "><script>alert('XSS')</script>
   ```

2. Verify all are sanitized

### Test SQL Injection

1. Try these in search/query fields:
   ```
   ' OR '1'='1
   '; DROP TABLE users; --
   ' UNION SELECT * FROM users --
   ```

2. Verify input validation blocks or sanitizes

### Test CSRF

1. Create malicious HTML file:
   ```html
   <form action="http://localhost:3000/api/delete-account" method="POST">
     <input type="hidden" name="confirm" value="yes" />
   </form>
   <script>document.forms[0].submit();</script>
   ```

2. Open while logged in
3. Verify request blocked (403 Forbidden)

### Test Authorization

1. Create resource as User A
2. Try to access/modify as User B
3. Verify 403 Forbidden

## What To Monitor Post-Deployment

### Daily

- Error rates (Vercel dashboard)
- Failed authentication attempts (Clerk dashboard)
- Rate limit violations (check logs for 429 responses)

### Weekly

- Run `npm audit --production`
- Check GitHub Dependabot alerts
- Review error logs for patterns

### Monthly

- Full security audit
- Update dependencies
- Re-run security testing suite
- Check security headers (securityheaders.com)

## References

- OWASP Testing Guide: https://owasp.org/www-project-web-security-testing-guide/
- Security Headers Scanner: https://securityheaders.com/
- Mozilla Observatory: https://observatory.mozilla.org/
- SSL Labs: https://www.ssllabs.com/ssltest/
- npm Audit: https://docs.npmjs.com/cli/v8/commands/npm-audit

## Next Steps

- For fixing issues: Use appropriate security skill (csrf-protection, rate-limiting, etc.)
- For deployment: Complete pre-deployment checklist above
- For monitoring: Set up automated security scans in CI/CD
- For ongoing maintenance: Run monthly security audit
