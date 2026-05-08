---
name: ffp-code-review
description: Review code changes for FFP project standards including multi-tenant security, British English, architecture patterns, and SOLID principles. Use when reviewing PRs, checking branch changes, or auditing code quality.
allowed-tools: Read, Grep, Glob, Bash(git diff:*), Bash(git log:*), Bash(git branch:*)
---

# FFP Code Review Skill

## Capabilities

Senior-level code review specialising in:

- **Multi-tenant security**: RLS enforcement, tenant isolation, JWT validation
- **Healthcare data compliance**: OWASP Top 10, sensitive data protection
- **FFP architecture patterns**: Domain-organised structure, Handler → Service → Repository flow
- **British English enforcement**: Spelling, grammar, naming conventions
- **TypeScript best practices**: Strict mode, type safety, explicit signatures

## Review Process

### 1. Gather Context

**Check for review context (ALWAYS DO THIS FIRST):**

- Try to read `.claude/review-context.md` using Read tool
- If exists: Extract goals, requirements, changes made, focus areas, known limitations
- If missing: Note "No review context provided" and proceed with general review

**Get git changes:**

```bash
git diff main...HEAD              # All changes on current branch
git log main..HEAD --oneline      # Recent commits
git branch --show-current         # Current branch name
```

**Load project documentation:**

- `CLAUDE.md` - Team-wide project standards
- `CLAUDE.local.md` - Personal preferences and FFP-specific gotchas
- `project-documentation/project-state.md` - Current sprint and task context
- `project-documentation/architecture.md` - Architecture patterns and decisions
- `project-documentation/security.md` - Security requirements and RLS patterns

### 2. Analyse Changes

**Search for critical patterns using Grep:**

- SQL queries: `query|execute|transaction`
- Tenant checks: `tenant_id|tenantId`
- Auth claims: `claims\[|custom:`
- Error handling: `throw|catch|Error`
- Database access: `db\.|repository|Repository`
- Raw HTML elements: `<h[1-5]|<p>|<p |<span>|<span |<button>|<button `
- Hard-coded colours: `text-(gray|red|blue|green|yellow|purple|pink|indigo)-(100|200|300|400|500|600|700|800|900)|bg-(gray|red|blue|green|yellow|purple|pink|indigo)-(100|200|300|400|500|600|700|800|900)`

**Read modified files using Read tool:**

- Focus on changed lines from git diff
- Check surrounding context for proper patterns
- Verify imports and dependencies

**Find related files using Glob:**

- Test files: `**/*.test.ts`, `**/*.spec.ts`
- Type definitions: `**/*.d.ts`, `**/types/*.ts`
- Related domain files: `packages/core/{domain}/**/*.ts`

### 3. Prioritise Feedback

**[CRITICAL] Security & Data Safety**

- Missing RLS context in database transactions
- Unvalidated `tenant_id` in queries
- SQL injection vulnerabilities (string concatenation)
- Exposed secrets or credentials
- Missing input validation
- Error messages leaking sensitive data
- Improper Cognito claim access (missing `custom:` prefix)

**[HIGH] Architecture & Type Safety**

- Business logic in handlers
- Direct data access in services (should use repositories)
- Missing error handling
- `any` types or missing type annotations
- Incorrect domain organisation
- Missing or improper entity usage

**[MEDIUM] Code Quality**

- American spelling in FFP-specific code (optimize, color, behavior)
  - Exception: Framework/package integrations (TailwindCSS classes, library APIs)
- Emojis in code, comments, or user-facing strings
- Raw HTML elements instead of components (h1-h5, p, span, button)
- Hard-coded colours instead of theme variables
- Poor naming conventions
- Missing comments for complex logic
- Inconsistent formatting (not 2-space indentation)

**[LOW] Style Preferences**

- Minor code organisation improvements
- Variable naming suggestions
- Performance micro-optimisations

### 4. Format Output

Provide structured feedback:

```markdown
# Code Review Summary

**Branch**: [branch-name]
**Files Changed**: X files, +Y/-Z lines
**Review Context**: [Yes/No] - [If yes, summarise key goals and focus areas]
**Review Focus**: [Security | Architecture | Quality]

## [CRITICAL] Issues (Must Fix Before Merge)

[Specific file:line references with remediation examples]

## [HIGH] Priority (Should Fix)

[Architecture violations, type safety issues]

## [MEDIUM] Suggestions (Consider)

[Code quality improvements with trade-offs]

## Positive Observations

[What was done well - reinforce good practices]
```

## FFP-Specific Security Patterns

### Correct RLS Pattern

```typescript
// Set RLS context in transaction
await db.transaction(async (tx) => {
  await setRLSContext(tx, context.tenantId);
  return await tx.query.users.findMany();
});
```

### Wrong RLS Pattern

```typescript
// WRONG: Direct query without RLS context - LEAKS DATA!
await db.query.users.findMany();
```

### Correct Cognito Claims

```typescript
// Use custom: prefix
const tenantId = claims['custom:tenantId'];
const role = claims['custom:role'];
```

### Wrong Cognito Claims

```typescript
// WRONG: Missing custom: prefix - won't work!
const tenantId = claims.tenantId; // undefined
```

### Correct Tenant Validation

```typescript
// Always validate tenant_id in queries
const user = await tx.query.users.findFirst({
  where: and(
    eq(users.id, userId),
    eq(users.tenant_id, tenantId) // CRITICAL
  ),
});
```

### Wrong Tenant Validation

```typescript
// WRONG: Missing tenant check - DATA LEAK!
const user = await tx.query.users.findFirst({
  where: eq(users.id, userId),
});
```

## Architecture Flow Validation

### Correct Handler Pattern

```typescript
// Handler = HTTP interface only, NO business logic
export const handler = async (event: APIGatewayProxyEvent) => {
  const context = extractUserContext(event);
  const input = parseInput(event.body);

  const result = await userService.createUser(context, input);

  return { statusCode: 201, body: JSON.stringify(result) };
};
```

### Wrong Handler Pattern

```typescript
// WRONG: Handler with business logic
export const handler = async (event: APIGatewayProxyEvent) => {
  const data = JSON.parse(event.body);

  // WRONG: Business logic in handler
  if (data.age < 18) {
    throw new Error('Must be 18+');
  }

  // WRONG: Direct data access in handler
  const user = await db.query.users.create({ ... });

  return { statusCode: 201, body: JSON.stringify(user) };
};
```

## Component Usage Enforcement

**Use themed components instead of raw HTML elements:**

### Text Elements

```typescript
// WRONG: Raw HTML elements
<h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
<h2 className="text-xl text-gray-600">Welcome</h2>
<p className="text-sm text-gray-500">Description text</p>
<span className="text-red-600">Error message</span>

// CORRECT: Use Title and Text components
<Title as="h1" colour="foreground">Dashboard</Title>
<Title as="h2" colour="muted-foreground">Welcome</Title>
<Text as="p" styleProps={{ size: 'sm', colour: 'muted-foreground' }}>Description text</Text>
<Text styleProps={{ colour: 'destructive' }}>Error message</Text>
```

### Buttons

```typescript
// WRONG: Raw button element
<button className="bg-blue-600 text-white px-4 py-2 rounded-md">
  Click me
</button>

// CORRECT: Use Button component
<Button variant="primary">Click me</Button>
```

**When raw HTML is acceptable:**

- Form inputs (input, textarea, select) - use FormTextInput instead
- Structural elements (div, section, nav, header, footer)
- Semantic elements (ul, ol, li, table, tr, td)
- Special cases where component doesn't exist (rare)

## Colour Theme Enforcement

**Use theme colours instead of hard-coded values:**

### Hard-coded Colours to Avoid

```typescript
// WRONG: Hard-coded colour classes
className="text-gray-900"
className="text-gray-600"
className="text-red-600"
className="bg-blue-50"
className="border-green-200"

// CORRECT: Use theme colours via components
<Text styleProps={{ colour: 'foreground' }} />
<Text styleProps={{ colour: 'muted-foreground' }} />
<Text styleProps={{ colour: 'destructive' }} />
className="bg-info/10"
className="border-success/20"
```

### Available Theme Colours

**Text colours** (use via `Text` or `Title` components):

- `foreground` - Primary text (dark)
- `muted-foreground` - Secondary text (medium gray)
- `primary` - FFP primary blue
- `secondary` - FFP light purple
- `success` - Green
- `destructive` - Red (errors)
- `warning` - Yellow/amber
- `info` - Blue (informational)

**Background/border colours** (use via Tailwind classes):

- `bg-background`, `bg-foreground`
- `bg-primary`, `bg-secondary`, `bg-success`, `bg-destructive`, `bg-warning`, `bg-info`
- `bg-muted`, `bg-accent`, `bg-card`
- Use opacity for lighter shades: `bg-primary/10`, `border-destructive/20`

### When Hard-coded Colours Are Acceptable

- Gradients or complex visual effects (e.g., `bg-gradient-to-r from-success to-info`)
- Temporary dev-only components
- Very specific brand colours not in theme (must be rare)

**Check files in scope:**

- All `.tsx` files in `packages/web/src/pages/`
- All `.tsx` files in `packages/web/src/components/`
- Focus on production components (not dev pages)

## British English Enforcement

**Important**: British English applies to FFP-specific code only. Framework/package integrations (e.g., TailwindCSS classes, library APIs) should use the framework's expected spelling.

**Common mistakes to catch in FFP code:**

| American (Wrong)         | British (Correct) |
| ------------------------ | ----------------- |
| optimize (in FFP code)   | optimise          |
| organize (in FFP code)   | organise          |
| customize (in FFP code)  | customise         |
| color (in FFP code)      | colour            |
| behavior (in FFP code)   | behaviour         |
| center (in FFP code)     | centre            |
| license (noun, FFP code) | licence (noun)    |

**Check in:**

- FFP variable/function names: `optimizeWorkout` → `optimiseWorkout`
- FFP comments: "// Optimize the query" → "// Optimise the query"
- FFP string literals: "Customization" → "Customisation"
- User-facing messages: "Authorization failed" → "Authorisation failed"

**DO NOT flag as errors:**

- TailwindCSS classes: `text-center`, `bg-color-blue-500` (framework convention)
- Library APIs: `color`, `initialize`, `center` (when part of framework interface)
- Package configuration: `color`, `behavior` (when required by package)

## Review Philosophy

1. **Security first**: Healthcare data = zero tolerance for vulnerabilities
2. **Constructive feedback**: Explain why, show how to fix
3. **Specific examples**: Provide remediation code, not just descriptions
4. **Positive reinforcement**: Acknowledge good practices
5. **Phase 1 context**: Don't over-engineer; ship fast, iterate on feedback
6. **Senior perspective**: Mentor, don't just criticise

## Usage Examples

**Invoke directly:**

```
Use the ffp-code-review skill to review my changes
```

**Focus on specific area:**

```
Use ffp-code-review to check security in my authentication code
```

**After making changes:**

```
Review my latest commit with ffp-code-review before I push
```
