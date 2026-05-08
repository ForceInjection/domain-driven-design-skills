---
name: security-prompts-controls
description: Simple security prompt templates for quick implementations using existing Secure Vibe Coding OS utilities. Use for straightforward features like contact forms, authenticated updates, and public APIs. Triggers include "contact form", "simple form", "authenticated update", "user update", "public API", "read-only API", "quick secure implementation".
---

# Built-In Controls Security Templates

## Purpose

This skill provides simple, fast security prompt templates for common features that leverage existing Secure Vibe Coding OS utilities. These are streamlined templates for straightforward implementations that don't require extensive customization.

**When to use these templates**:
- Simple, common features
- Quick implementations (15-30 minutes)
- Leveraging existing security utilities
- Standard patterns without complex requirements

**When to use prompt-engineering instead**:
- Complex features requiring multiple security layers
- Custom security requirements
- Features needing extensive customization
- New patterns not covered by utilities

## Available Templates

### 01: Contact Form
**File**: `01_contact_form.md`
**When to use**: Public form with full security stack
**Time**: 15-30 minutes

**Security Controls** (Pre-configured):
- CSRF protection (withCsrf)
- Rate limiting (withRateLimit - 5 per 15 min)
- Input validation (Zod schemas)
- XSS sanitization (safeTextSchema)
- Secure error handling (handleApiError)

**Implementation**:
- Single API route
- Existing middleware composition
- Standard validation schemas
- Minimal customization needed

**Trigger keywords**: "contact form", "simple form", "feedback form", "quick form", "form with security"

**Use case**: Contact forms, feedback forms, newsletter signups, support requests

**Difference from prompt-engineering/01_secure_form.md**:
- Simpler template
- Less customization guidance
- Faster implementation
- Assumes standard use case

---

### 02: Authenticated Update
**File**: `02_authenticated_update.md`
**When to use**: User data modification with auth
**Time**: 30 minutes

**Security Controls** (Pre-configured):
- Clerk authentication (auth())
- Rate limiting (withRateLimit)
- Input validation (Zod schemas)
- XSS sanitization (safeTextSchema)
- Secure error handling (handleApiError)

**Implementation**:
- Single authenticated API route
- Standard data update pattern
- Existing utilities
- Basic ownership check

**Trigger keywords**: "authenticated update", "update profile", "user update", "edit profile", "user data modification"

**Use case**: Profile updates, user settings, preference changes

**Important**: For resources requiring strict ownership verification, follow up with:
→ `.claude/skills/security/security-prompts/auth-authorization/03_ownership.md`

**Difference from prompt-engineering/02_authenticated_endpoint.md**:
- Simpler ownership check
- Less comprehensive authorization
- Faster for basic updates
- Standard user → own data pattern

---

### 03: Public API
**File**: `03_public_api.md`
**When to use**: Public GET endpoints with validation
**Time**: 20 minutes

**Security Controls** (Pre-configured):
- Rate limiting (withRateLimit)
- Input validation (Zod query schemas)
- Error handling (handleApiError)
- Pagination (standard pattern)

**Implementation**:
- Read-only endpoints
- Query parameter validation
- Standard pagination
- No authentication required

**Trigger keywords**: "public API", "public endpoint", "GET endpoint", "read-only API", "public data"

**Use case**: Blog posts, product catalogs, public listings, documentation

**Difference from prompt-engineering/03_public_endpoint.md**:
- Simpler pagination
- Standard patterns only
- Less customization
- Faster for typical GET endpoints

---

## Usage Pattern

### 1. Identify Template Match

**Simple contact form**:
→ 01_contact_form.md ✅

**Profile editing**:
→ 02_authenticated_update.md ✅

**Public data listing**:
→ 03_public_api.md ✅

**Admin features**:
→ Use prompt-engineering/04_admin_action.md ❌ (not here)

**File uploads**:
→ Use prompt-engineering/05_file_upload.md ❌ (not here)

### 2. Quick Implementation

```markdown
For: [Simple feature name]

Template: built-in-controls/[template].md

Estimated time: [15-30 minutes]

This uses existing Secure Vibe Coding OS utilities:
- [List utilities from template]

Let me implement this quickly...
```

### 3. When to Upgrade

**Start with built-in-controls, upgrade if needed**:

```markdown
Started with: built-in-controls/02_authenticated_update.md
Need to add: Ownership verification for team resources
Upgrade to: auth-authorization/03_ownership.md
```

```markdown
Started with: built-in-controls/01_contact_form.md
Need to add: File attachment support
Upgrade to: prompt-engineering/05_file_upload.md
```

## Template Comparison

### Contact Form Templates

**built-in-controls/01_contact_form.md**:
- ✅ 15-30 minutes
- ✅ Standard fields (name, email, message)
- ✅ Pre-configured controls
- ❌ Limited customization guidance

**prompt-engineering/01_secure_form.md**:
- ⏱️ 30 minutes
- ✅ Any form fields
- ✅ Comprehensive security guidance
- ✅ Extensive customization tips
- ✅ More testing guidance

**Choose built-in-controls when**: Standard contact form, quick implementation
**Choose prompt-engineering when**: Custom fields, complex validation, learning security patterns

### Authenticated Update Templates

**built-in-controls/02_authenticated_update.md**:
- ✅ 30 minutes
- ✅ User → own data
- ✅ Basic ownership check
- ❌ Simple scenarios only

**prompt-engineering/02_authenticated_endpoint.md**:
- ⏱️ 45 minutes
- ✅ Any authenticated operation
- ✅ Complex authorization
- ✅ Team/organization resources
- ✅ Comprehensive audit logging

**Choose built-in-controls when**: User editing their own profile/settings
**Choose prompt-engineering when**: Team resources, complex permissions, admin features

### Public API Templates

**built-in-controls/03_public_api.md**:
- ✅ 20 minutes
- ✅ Simple GET endpoints
- ✅ Standard pagination
- ❌ Basic use cases only

**prompt-engineering/03_public_endpoint.md**:
- ⏱️ 30 minutes
- ✅ Complex queries
- ✅ Advanced pagination
- ✅ Search/filtering
- ✅ Performance optimization

**Choose built-in-controls when**: Simple data listing
**Choose prompt-engineering when**: Search, complex filtering, advanced pagination

## Workflow Integration

### Quick Feature Flow

```markdown
1. Quick Implementation
   → built-in-controls/[template].md

2. Test
   → Follow template testing checklist

3. Deploy
   → Update threat model (threat-modeling/08_update_model.md)
```

### Feature Growth Flow

```markdown
1. Start Simple
   → built-in-controls/[template].md

2. Add Complexity (if needed)
   → Upgrade to prompt-engineering/[template].md
   → Or add auth-authorization/[template].md

3. Test Thoroughly
   → prompt-engineering/08_security_testing.md

4. Review
   → threat-modeling/04_code_review.md
```

## Utilities Reference

All templates use these Secure Vibe Coding OS utilities:

### Middleware

**withCsrf()**:
```typescript
import { withCsrf } from "@/lib/security/csrf";
export const POST = withCsrf(handler);
```

**withRateLimit()**:
```typescript
import { withRateLimit } from "@/lib/security/rate-limit";
export const POST = withRateLimit(withCsrf(handler), {
  requests: 5,
  window: 15 * 60 // 15 minutes
});
```

### Validation

**safeTextSchema**:
```typescript
import { safeTextSchema } from "@/lib/validation";
const schema = z.object({
  message: safeTextSchema.max(1000)
});
```

**emailSchema**:
```typescript
import { emailSchema } from "@/lib/validation";
const schema = z.object({
  email: emailSchema
});
```

**validateRequest()**:
```typescript
import { validateRequest } from "@/lib/validation";
const data = await validateRequest(req, schema);
```

### Error Handling

**handleApiError()**:
```typescript
import { handleApiError } from "@/lib/errors";
try {
  // Logic
} catch (error) {
  return handleApiError(error);
}
```

### Authentication

**auth()**:
```typescript
import { auth } from "@clerk/nextjs/server";
const { userId } = auth();
if (!userId) return Response.json({error: "Unauthorized"}, {status: 401});
```

## Testing Checklists

### Contact Form Testing

```markdown
- [ ] Form requires CSRF token
- [ ] Rate limiting blocks 6th submission
- [ ] XSS in message field is sanitized
- [ ] Invalid email rejected
- [ ] Empty fields rejected
- [ ] Form submission succeeds with valid data
```

### Authenticated Update Testing

```markdown
- [ ] Unauthenticated request rejected (401)
- [ ] User can update own data
- [ ] User cannot update other user's data (403)
- [ ] Invalid data rejected
- [ ] Rate limiting works
- [ ] Success response correct
```

### Public API Testing

```markdown
- [ ] Endpoint returns data without auth
- [ ] Pagination works correctly
- [ ] Invalid query params rejected
- [ ] Rate limiting enforces limits
- [ ] Error responses secure
- [ ] Performance acceptable
```

## When NOT to Use Built-In Controls

❌ **Admin features**
→ Use: prompt-engineering/04_admin_action.md

❌ **File uploads**
→ Use: prompt-engineering/05_file_upload.md

❌ **Complex authorization**
→ Use: auth-authorization/[appropriate_template].md

❌ **Multiple middleware layers**
→ Use: prompt-engineering/06_composable_middleware.md

❌ **Custom security patterns**
→ Use: prompt-engineering/07_new_control.md

❌ **Team/organization resources**
→ Use: prompt-engineering/02_authenticated_endpoint.md + auth-authorization/03_ownership.md

## Agent Usage

### Quick Feature Request

```markdown
User: "Add a contact form"

Agent Response:
"I'll use the quick contact form template from built-in-controls.
This leverages existing security utilities for a 15-30 minute implementation.

Loading: .claude/skills/security/security-prompts/built-in-controls/01_contact_form.md"
```

### Upgrade Scenario

```markdown
User: "The contact form needs file attachment support"

Agent Response:
"File uploads require additional security controls beyond the simple template.
I'll upgrade to the comprehensive file upload template.

Switching to: .claude/skills/security/security-prompts/prompt-engineering/05_file_upload.md"
```

## Best Practices

### Start Simple

**Begin with built-in-controls**:
- Faster implementation
- Less complexity
- Standard patterns
- Easy to understand

**Upgrade when needed**:
- Requirements grow
- Need custom patterns
- Complex authorization
- Multiple security layers

### Always Test

Even simple templates need testing:
1. **Follow testing checklist** in template
2. **Verify all controls** work
3. **Test negative cases** (rejections)
4. **Update threat model** after deployment

### Document Deviations

If customizing beyond template:
```markdown
// Custom rate limit for this endpoint
// Deviation from template: Increased to 10 requests per 15 min
// Reason: Users frequently update bio
withRateLimit(handler, { requests: 10, window: 15 * 60 })
```

## Integration with Other Skills

### Feature Implementation

```markdown
1. Quick Implementation
   → security-prompts-controls (this skill)

2. Security Testing
   → prompt-engineering/08_security_testing.md

3. Update Threat Model
   → threat-modeling/08_update_model.md
```

### Growing Complexity

```markdown
1. Start Simple
   → security-prompts-controls (this skill)

2. Add Authorization
   → security-prompts-auth

3. Add Advanced Features
   → security-prompts-engineering

4. Review Security
   → security-prompts-threat-modeling
```

## Related Skills

**Parent Skill**:
- **security-prompts** - Main directory with all template categories (engineering, auth, threat-modeling, controls)

**Implementation Skills** (referenced by templates):
- **csrf-protection** - CSRF implementation details
- **rate-limiting** - Rate limiting patterns
- **input-validation** - Validation strategies

**Note**: For other template categories (comprehensive implementation, authentication, threat modeling), see the parent `security-prompts` skill

## Version History

**v1.0** (2025-10-23): Initial skill creation
- Converted 3 built-in-controls templates
- Added comparison with prompt-engineering templates
- Added upgrade paths
- Integration with utility reference

---

**Note**: These templates are optimized for speed and simplicity. For comprehensive security guidance and complex features, see the parent `security-prompts` skill directory.
