---
name: testing-validation
description: Comprehensive testing and validation tools for Clerk authentication integrations. Includes E2E auth flow testing, security audits, configuration validation, unit testing patterns for sign-in/sign-up flows. Use when implementing Clerk tests, validating authentication setup, testing auth flows, running security audits, creating E2E tests for Clerk, or when user mentions Clerk testing, auth validation, E2E authentication tests, security audit, or test coverage.
allowed-tools: Read, Write, Bash, Grep, Glob
---

# Clerk Testing & Validation

Comprehensive testing and validation toolkit for Clerk authentication integrations. Provides test templates, validation scripts, security audit tools, and E2E testing patterns for sign-in, sign-up, session management, and multi-factor authentication flows.

## Instructions

### When Validating Clerk Setup

1. **Run Configuration Validation**
   - Execute `scripts/validate-setup.sh` to verify:
     - Environment variables (CLERK_PUBLISHABLE_KEY, CLERK_SECRET_KEY)
     - Middleware configuration
     - Protected routes setup
     - Provider configuration (Google, GitHub, etc.)
   - Check output for missing configurations or security warnings
   - Review generated validation report

2. **What Gets Validated**
   - Environment variable presence and format
   - API key validity (publishable vs secret key patterns)
   - ClerkProvider wrapper in app structure
   - Middleware configuration in middleware.ts/js
   - Protected route patterns in route configuration
   - CORS and domain settings for production

### When Testing Authentication Flows

1. **Run E2E Authentication Tests**
   - Execute `scripts/test-auth-flows.sh` to test:
     - Sign-up flow (email/password, OAuth providers)
     - Sign-in flow (all configured providers)
     - Session persistence across page reloads
     - Sign-out functionality
     - Protected route access control
   - Supports both Playwright and Cypress
   - Generates test coverage reports

2. **Authentication Flow Coverage**
   - Email/password registration and login
   - OAuth provider authentication (Google, GitHub, Microsoft)
   - Magic link authentication
   - Multi-factor authentication (2FA/MFA)
   - Session management and token refresh
   - User profile updates
   - Password reset flows

### When Running Security Audits

1. **Execute Security Checks**
   - Run `scripts/check-security.sh` to audit:
     - Environment variable exposure (no keys in client bundles)
     - Public vs secret key usage
     - Protected route coverage
     - Session security configuration
     - CSRF protection implementation
     - XSS prevention patterns
   - Review security findings report
   - Address high-priority vulnerabilities immediately

2. **Security Checklist Items**
   - No secret keys exposed to client
   - All admin routes properly protected
   - Session tokens stored securely (httpOnly cookies)
   - Rate limiting on auth endpoints
   - Input sanitization for user data
   - HTTPS enforcement in production
   - Proper CORS configuration

### When Creating Unit Tests

1. **Use Provided Test Templates**
   - For **React components**: `templates/test-suites/clerk-react.test.tsx`
   - For **Next.js pages**: `templates/test-suites/clerk-nextjs.test.tsx`
   - For **API routes**: `templates/test-suites/clerk-api.test.ts`
   - Templates include mocking patterns for Clerk hooks

2. **Unit Test Coverage**
   - Mock `useAuth()`, `useUser()`, `useSession()` hooks
   - Test component behavior for authenticated/unauthenticated states
   - Verify loading states during auth
   - Test error handling for auth failures
   - Validate conditional rendering based on auth status

### When Creating E2E Tests

1. **Use Playwright Templates**
   - Base template: `templates/e2e-tests/clerk-auth-flows.spec.ts`
   - OAuth template: `templates/e2e-tests/clerk-oauth.spec.ts`
   - Protected routes: `templates/e2e-tests/clerk-protected-routes.spec.ts`
   - Templates include Clerk test helpers and fixtures

2. **E2E Test Patterns**
   - Use Clerk test users (configured in .env.test)
   - Test complete user journeys (sign-up → profile → sign-out)
   - Verify redirect flows after authentication
   - Test session persistence across browser tabs
   - Validate error messages and UI feedback

## Templates

### Test Suite Templates

**React Component Tests:**
- `templates/test-suites/clerk-react.test.tsx` - Jest/Vitest tests with React Testing Library
- `templates/test-suites/clerk-hooks.test.ts` - Unit tests for Clerk hook integrations
- `templates/test-suites/clerk-components.test.tsx` - Tests for SignIn, SignUp, UserButton components

**Next.js Tests:**
- `templates/test-suites/clerk-nextjs.test.tsx` - App Router component tests
- `templates/test-suites/clerk-middleware.test.ts` - Middleware function tests
- `templates/test-suites/clerk-api.test.ts` - API route authentication tests

**Backend Tests:**
- `templates/test-suites/clerk-backend.test.ts` - Server-side auth validation
- `templates/test-suites/clerk-webhooks.test.ts` - Webhook handler tests

### E2E Test Templates

**Playwright Tests:**
- `templates/e2e-tests/clerk-auth-flows.spec.ts` - Complete auth flow testing
- `templates/e2e-tests/clerk-oauth.spec.ts` - OAuth provider testing
- `templates/e2e-tests/clerk-protected-routes.spec.ts` - Route protection tests
- `templates/e2e-tests/clerk-session.spec.ts` - Session management tests
- `templates/e2e-tests/clerk-mfa.spec.ts` - Multi-factor authentication tests

**Cypress Tests:**
- `templates/e2e-tests/cypress/clerk-signup.cy.ts` - Sign-up flow
- `templates/e2e-tests/cypress/clerk-signin.cy.ts` - Sign-in flow
- `templates/e2e-tests/cypress/clerk-profile.cy.ts` - User profile tests

### Validation Resources

- `templates/validation-checklist.md` - Comprehensive validation checklist
- `templates/security-audit-report.md` - Security audit report template
- `templates/test-coverage-report.md` - Test coverage analysis template

## Scripts

### Validation Scripts

**`scripts/validate-setup.sh`**
- Validates Clerk environment configuration
- Checks API key format and presence
- Verifies middleware and provider setup
- Outputs detailed validation report
- Exit code 0 for success, 1 for failures

**Usage:**
```bash
bash scripts/validate-setup.sh [--fix]
```

### Testing Scripts

**`scripts/test-auth-flows.sh`**
- Runs E2E authentication flow tests
- Supports Playwright and Cypress
- Generates coverage reports
- Can run in CI/CD environments

**Usage:**
```bash
bash scripts/test-auth-flows.sh [--playwright|--cypress] [--headed]
```

**`scripts/run-unit-tests.sh`**
- Executes Jest/Vitest unit tests
- Focuses on Clerk component and hook tests
- Generates coverage reports

**Usage:**
```bash
bash scripts/run-unit-tests.sh [--watch] [--coverage]
```

### Security Scripts

**`scripts/check-security.sh`**
- Performs security audit of Clerk integration
- Checks for exposed secrets
- Validates authentication patterns
- Outputs security findings report

**Usage:**
```bash
bash scripts/check-security.sh [--detailed]
```

## Examples

### Complete Test Examples

**`examples/auth-flow-tests.spec.ts`**
- Full Playwright test suite for authentication flows
- Tests sign-up, sign-in, sign-out
- Validates session persistence
- Tests OAuth providers
- Includes setup and teardown

**`examples/security-audit.ts`**
- Automated security audit script
- Scans codebase for security issues
- Checks environment variable usage
- Validates route protection patterns
- Generates detailed audit report

**`examples/clerk-unit-tests.test.tsx`**
- Comprehensive unit test examples
- React component testing with Clerk hooks
- Mocking patterns for useAuth, useUser
- Testing authenticated/unauthenticated states

**`examples/webhook-testing.test.ts`**
- Clerk webhook handler tests
- Validates signature verification
- Tests event processing
- Error handling patterns

## Security: API Key Handling

**CRITICAL:** This skill enforces security best practices:

- **Validation scripts** check for exposed API keys in client code
- **Security audit** scans for hardcoded credentials
- **Test templates** use environment variables only
- **Examples** demonstrate proper secret management

All generated tests use placeholders:
```typescript
// .env.test
CLERK_PUBLISHABLE_KEY=pk_test_your_key_here
CLERK_SECRET_KEY=sk_test_your_key_here
TEST_USER_EMAIL=test_user@example.com
TEST_USER_PASSWORD=test_password_here
```

Never commit real API keys or test credentials to version control.

## Requirements

**Testing Frameworks:**
- Jest 29.x or Vitest 1.x (for unit tests)
- Playwright 1.40+ or Cypress 13+ (for E2E tests)
- React Testing Library 14+ (for component tests)

**Clerk SDKs:**
- @clerk/nextjs 4.x or 5.x
- @clerk/clerk-react (for React apps)
- @clerk/clerk-js (for vanilla JS)

**Node.js:**
- Node.js 18+ (LTS recommended)
- npm 9+ or pnpm 8+

**Environment:**
- Test Clerk application (separate from production)
- Test user accounts configured
- .env.test file with test credentials

## Best Practices

1. **Separate Test Environments** - Use dedicated Clerk test application, never test against production
2. **Mock External Services** - Mock OAuth providers in unit tests, use real providers only in E2E
3. **Test User Isolation** - Create/delete test users for each test suite to avoid conflicts
4. **Security First** - Always run security audit before deployment
5. **Comprehensive Coverage** - Test both happy paths and error scenarios
6. **CI/CD Integration** - Run validation and tests in CI pipeline
7. **Regular Security Audits** - Schedule weekly security checks
8. **Keep Tests Updated** - Update tests when Clerk SDK versions change

## Validation Workflow

**Recommended Testing Pipeline:**

1. **Setup Validation** → Run `validate-setup.sh` to ensure proper configuration
2. **Unit Tests** → Run component and hook tests with coverage
3. **E2E Tests** → Execute authentication flow tests
4. **Security Audit** → Run security checks before deployment
5. **Review Reports** → Analyze coverage and security findings
6. **Fix Issues** → Address any failures or warnings
7. **Repeat** → Run full suite in CI/CD pipeline

---

**Purpose**: Standardize Clerk authentication testing and security validation
**Load when**: Testing Clerk integrations, validating auth setup, running security audits
**Security Level**: High - Enforces environment variable usage, scans for exposed secrets
