---
name: security-prompts-engineering
description: Comprehensive security prompt templates for implementing secure features with multiple security layers. Use for complex implementations like forms, authenticated endpoints, public APIs, admin features, file uploads, middleware composition, and security testing. Triggers include "secure form", "authenticated endpoint", "public endpoint", "admin action", "file upload", "composable middleware", "security testing", "new security control".
---

# Prompt Engineering Security Templates

## Purpose

This skill provides comprehensive security prompt templates for implementing features that require multiple security layers and sophisticated controls. These templates go beyond simple utility usage and guide complete secure feature implementation.

## Available Templates

### 01: Comprehensive Secure Form
**File**: `01_secure_form.md`
**When to use**: Full security stack for public forms
**Time**: 30 minutes

**Security Controls**:
- CSRF protection
- Rate limiting
- Input validation
- XSS sanitization
- Security headers
- Secure error handling

**Trigger keywords**: "secure form", "contact form", "public form with security", "comprehensive form security"

**Use case**: Any public-facing form that accepts user input (contact, feedback, newsletter signup)

---

### 02: Authenticated Endpoint
**File**: `02_authenticated_endpoint.md`
**When to use**: Authenticated data modification with authorization
**Time**: 45 minutes

**Security Controls**:
- Clerk authentication
- Authorization checks
- Ownership verification
- Input validation
- Rate limiting
- Audit logging

**Trigger keywords**: "authenticated endpoint", "user update", "protected route", "user data modification", "authenticated mutation"

**Use case**: Profile updates, user settings, any authenticated data changes

---

### 03: Public Endpoint
**File**: `03_public_endpoint.md`
**When to use**: Public APIs with pagination and validation
**Time**: 30 minutes

**Security Controls**:
- Rate limiting
- Input validation
- Pagination
- Error handling
- Query sanitization

**Trigger keywords**: "public API", "public endpoint", "GET endpoint", "read-only API", "public data access"

**Use case**: Public data endpoints, blog posts, product catalogs

---

### 04: Admin Action
**File**: `04_admin_action.md`
**When to use**: Admin-only endpoints with audit logging
**Time**: 60 minutes

**Security Controls**:
- RBAC verification
- Admin-only access
- Audit logging
- Input validation
- Rate limiting
- Sensitive operation protection

**Trigger keywords**: "admin endpoint", "admin feature", "admin action", "admin-only", "privileged operation"

**Use case**: User management, system configuration, content moderation

---

### 05: File Upload
**File**: `05_file_upload.md`
**When to use**: Secure file handling with external service
**Time**: 90 minutes

**Security Controls**:
- File type validation
- File size limits
- Malware scanning
- Authenticated upload
- Storage security
- Rate limiting

**Trigger keywords**: "file upload", "image upload", "file handling", "secure upload", "document upload"

**Use case**: Profile pictures, document uploads, media attachments

---

### 06: Composable Middleware
**File**: `06_composable_middleware.md`
**When to use**: Multiple security layers with correct ordering
**Time**: 45 minutes

**Security Controls**:
- Middleware composition
- Correct execution order
- Layer compatibility
- Type safety
- Error propagation

**Trigger keywords**: "composable middleware", "middleware composition", "security layers", "multiple middleware", "middleware ordering"

**Use case**: Complex endpoints needing authentication + CSRF + rate limiting + custom logic

---

### 07: New Security Control
**File**: `07_new_control.md`
**When to use**: Extending security architecture with new utilities
**Time**: 90 minutes

**Security Controls**:
- Reusable utility creation
- Architecture integration
- Type safety
- Testing strategy
- Documentation

**Trigger keywords**: "new security control", "custom middleware", "security utility", "extend security", "new security layer"

**Use case**: Custom security requirements not covered by existing utilities

---

### 08: Security Testing
**File**: `08_security_testing.md`
**When to use**: Comprehensive security test generation
**Time**: 60 minutes

**Testing Coverage**:
- CSRF tests
- Rate limiting tests
- Authentication tests
- Authorization tests
- Input validation tests
- XSS prevention tests

**Trigger keywords**: "security testing", "security tests", "test security controls", "generate security tests", "comprehensive security testing"

**Use case**: Before deployment, after features, continuous security validation

---

## Usage Pattern

### 1. Identify Your Need

Match your feature to a template:
- **Form submission** → 01_secure_form.md
- **User data edit** → 02_authenticated_endpoint.md
- **Public data** → 03_public_endpoint.md
- **Admin panel** → 04_admin_action.md
- **File handling** → 05_file_upload.md
- **Complex security** → 06_composable_middleware.md
- **New pattern** → 07_new_control.md
- **Verification** → 08_security_testing.md

### 2. Load Template

```markdown
Read: .claude/skills/security/security-prompts/prompt-engineering/[number]_[name].md
```

### 3. Customize for User

Extract from template:
- Security controls list
- The prompt (customize placeholders)
- Testing checklist
- Time estimate

### 4. Present to User

```markdown
I'll implement this using the [TEMPLATE_NAME] security pattern.

**Security controls**:
- [List from template]

**Implementation approach**:
[Summarize from template]

**Estimated time**: [From template]

Here's the customized security prompt for your needs:

[Insert customized prompt]
```

### 5. After Implementation

Provide testing checklist from template.

## Combining Templates

### Example: Admin Dashboard

```markdown
Step 1: Setup RBAC (if not exists)
→ Use: .claude/skills/security/security-prompts/auth-authorization/01_rbac_implementation.md

Step 2: Implement each admin feature
→ Use: 04_admin_action.md (this category)

Step 3: Test implementation
→ Use: 08_security_testing.md (this category)

Step 4: Code review
→ Use: .claude/skills/security/security-prompts/threat-modeling/04_code_review.md

Step 5: Update threat model
→ Use: .claude/skills/security/security-prompts/threat-modeling/08_update_model.md
```

### Example: User Profile Editor

```markdown
Step 1: Implement authenticated endpoint
→ Use: 02_authenticated_endpoint.md (this category)

Step 2: Add ownership checks
→ Use: .claude/skills/security/security-prompts/auth-authorization/03_ownership.md

Step 3: Test authorization
→ Use: .claude/skills/security/security-prompts/auth-authorization/04_auth_testing.md

Step 4: Comprehensive security tests
→ Use: 08_security_testing.md (this category)
```

## Integration with Secure Vibe Coding OS

All templates reference:
- **Architecture**: `@docs/security/SECURITY_ARCHITECTURE.md`
- **Utilities**: `/lib` (withCsrf, withRateLimit, validateRequest, handleApiError)
- **Stack**: Next.js 14, Clerk, Convex, Stripe

Templates assume baseline security controls are available.

## Agent Usage

When agents need to implement secure features:

```typescript
// Load appropriate template
"Use the authenticated endpoint security template to implement profile editing"

// Chain multiple templates
"First apply RBAC template, then admin action template for each feature"

// Reference for patterns
"Follow the composable middleware template for correct security layer ordering"
```

## Customization Required

**Every template requires customization:**
- Replace `[PROJECT_NAME]` with actual app name
- Replace `[FEATURE_NAME]` with specific feature
- Adjust rate limits for use case
- Modify validation rules for data model
- Update field names and schemas
- Customize error messages

**Never use templates verbatim** - always customize for the specific implementation.

## Testing is Mandatory

After using any template:
1. **Follow testing checklist** in template
2. **Run security tests** using 08_security_testing.md
3. **Verify all controls** work as expected
4. **Update threat model** using threat-modeling/08_update_model.md

## Template Maintenance

When updating templates:
1. Update the .md file in this directory
2. Update version history in template
3. Update this SKILL.md if triggers or usage changes
4. Test with real implementation

## Related Skills

**Parent Skill**:
- **security-prompts** - Main directory with all template categories (auth, threat-modeling, controls, engineering)

**Implementation Skills** (referenced by templates):
- **security-testing** - Testing implementation skills
- **csrf-protection** - CSRF implementation details
- **rate-limiting** - Rate limiting patterns

**Note**: For other template categories (authentication, threat modeling, simple controls), see the parent `security-prompts` skill

## Version History

**v1.0** (2025-10-23): Initial skill creation
- Converted 8 prompt engineering templates
- Added trigger keywords
- Integrated with skill system

---

**Note**: These are comprehensive templates for complex features. For simpler implementations using existing utilities, see the parent `security-prompts` skill directory.
