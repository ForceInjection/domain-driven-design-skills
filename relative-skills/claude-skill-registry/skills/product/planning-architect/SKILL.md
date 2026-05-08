---
name: planning-architect
description: Expert in creating comprehensive task files, planning docs, PRDs, tech specs, and implementation roadmaps with proper sequencing, testing strategy, and production checklists. Use when planning features, creating project docs, or structuring development workflows.
---

# Planning Architect - Task & Documentation Master

## Purpose

Create production-ready planning documents with proper task sequencing, testing strategy, and continuous validation using MCP tools (Playwright, Chrome DevTools).

---

## Document Types (10 Core)

### 1. Product Requirements Document (PRD)
**File**: `{feature-name}-prd.md`
**Purpose**: Defines WHAT and WHY

```markdown
# {Feature Name} - PRD

## Overview
[1-2 sentence summary]

## Goals
- Business goal 1
- Technical goal 2

## Use Cases
- User persona 1: [action] → [outcome]
- User persona 2: [action] → [outcome]

## Scope
**In Scope**: Feature A, B, C
**Out of Scope**: Feature X, Y, Z

## Success Criteria
- Metric 1: [target value]
- Metric 2: [target value]

## KPIs
- DAU growth: +X%
- Conversion: +Y%
```

---

### 2. Technical Specification
**File**: `{feature-name}-tech-spec.md`
**Purpose**: Explains HOW

```markdown
# {Feature Name} - Technical Specification

## Architecture Overview
[Link to diagram: `diagrams/{feature}-architecture.mmd`]

## Components
- **Frontend**: React component paths
- **Backend**: Edge Functions
- **Database**: New tables/columns

## APIs & Endpoints
| Endpoint | Method | Purpose | Auth |
|----------|--------|---------|------|
| `/api/...` | POST | ... | JWT |

## Data Models
```typescript
interface FeatureData {
  id: string;
  // ...
}
```

## Dependencies
- External: OpenAI API, Stripe
- Internal: Existing tables

## Security Considerations
- RLS policies
- Input validation
- Rate limiting
```

---

### 3. Implementation Roadmap
**File**: `{feature-name}-roadmap.md`
**Purpose**: Aligns priorities, timelines

```markdown
# {Feature Name} - Implementation Roadmap

## Milestones

### Phase 1: Foundation (Week 1)
- [ ] Database schema
- [ ] RLS policies
- [ ] Migration scripts

### Phase 2: Backend (Week 2)
- [ ] Edge Functions
- [ ] API validation
- [ ] Unit tests

### Phase 3: Frontend (Week 3)
- [ ] UI components
- [ ] State management
- [ ] E2E tests

### Phase 4: Polish (Week 4)
- [ ] Performance optimization
- [ ] Security audit
- [ ] Production deploy

## Dependencies
- Milestone 1 → Milestone 2
- External: API key approval
```

---

### 4. Task Breakdown File
**File**: `{feature-name}-tasks.md`
**Purpose**: Granular implementation steps

```markdown
# {Feature Name} - Task Breakdown

## Task Sequencing (Logical Order)

### Layer 1: Database (Do First)
**Task 1.1**: Create database schema
- File: `supabase/migrations/{timestamp}_{feature}.sql`
- Tables: [list]
- Columns: [list]
- Success: `pnpm db:push` succeeds

**Task 1.2**: Add RLS policies
- Policy: [name]
- Rule: [condition]
- Success: Query returns correct rows

**Task 1.3**: Create migration rollback
- File: `{timestamp}_{feature}_rollback.sql`
- Success: Rollback restores previous state

### Layer 2: Backend (After Database)
**Task 2.1**: Create Edge Function
- File: `supabase/functions/{name}/index.ts`
- Inputs: [list]
- Outputs: [list]
- Success: `supabase functions deploy {name}` succeeds

**Task 2.2**: Add validation middleware
- Zod schema: [link]
- Success: Invalid input returns 400

**Task 2.3**: Write backend tests
- Test file: `{name}.test.ts`
- Coverage: >80%
- Success: All tests pass

### Layer 3: Frontend (After Backend)
**Task 3.1**: Create UI components
- Components: [list]
- File: `src/components/{Name}.tsx`
- Success: Component renders in Storybook

**Task 3.2**: Add state management
- Hook: `use{Feature}`
- Success: State updates correctly

**Task 3.3**: Write E2E tests
- Test: `e2e/{feature}.spec.ts`
- User journey: [steps]
- Success: Playwright test passes

### Layer 4: Testing & Validation (Continuous)
**Task 4.1**: Browser testing (Playwright)
- Navigate to feature page
- Interact with UI
- Verify expected behavior
- Success: All assertions pass

**Task 4.2**: Network monitoring (Chrome DevTools)
- Check API calls
- Verify response times <200ms
- Check console for errors
- Success: No errors, fast responses

**Task 4.3**: Visual regression
- Take screenshots
- Compare to baseline
- Success: No unexpected UI changes

### Layer 5: Production Readiness (Final)
**Task 5.1**: Performance audit
- Bundle size check
- Lighthouse score >90
- Success: Meets targets

**Task 5.2**: Security audit
- RLS validation
- Input sanitization
- Success: No vulnerabilities

**Task 5.3**: Deploy to production
- Environment: production
- Rollback plan: [link]
- Success: Feature live, no errors

## Testing Strategy (Continuous)

**After Each Layer**:
1. Run TypeScript check: `pnpm tsc`
2. Run tests: `pnpm test`
3. Manual validation: Browser test

**Before Next Layer**:
- All tests passing
- No console errors
- Code reviewed
```

---

### 5. Testing & Quality Plan
**File**: `{feature-name}-testing.md`

```markdown
# {Feature Name} - Testing Plan

## Test Coverage

### Unit Tests (Jest/Vitest)
- Component tests: >80%
- Util function tests: 100%
- Tool: Vitest

### Integration Tests
- API endpoint tests
- Database query tests
- Tool: Supertest

### E2E Tests (Playwright)
```typescript
test('user can {action}', async ({ page }) => {
  await page.goto('http://localhost:8080/{path}');
  await page.click('[data-testid="button"]');
  await expect(page.locator('h1')).toContainText('Success');
});
```

### Visual Regression
- Screenshot comparison
- Tool: Playwright screenshots

## Acceptance Criteria
- [ ] All unit tests pass
- [ ] All E2E tests pass
- [ ] No console errors
- [ ] Performance targets met

## MCP Testing Tools

### Playwright MCP
```
1. Navigate: mcp__playwright__browser_navigate
2. Snapshot: mcp__playwright__browser_snapshot
3. Click: mcp__playwright__browser_click
4. Assert: mcp__playwright__browser_wait_for
```

### Chrome DevTools MCP
```
1. Navigate: mcp__chrome-devtools__navigate_page
2. Network: mcp__chrome-devtools__list_network_requests
3. Console: mcp__chrome-devtools__list_console_messages
4. Screenshot: mcp__chrome-devtools__take_screenshot
```
```

---

### 6. Production Readiness Checklist
**File**: `{feature-name}-production-checklist.md`

```markdown
# {Feature Name} - Production Checklist

## Pre-Deploy Validation

### Code Quality
- [ ] TypeScript: 0 errors (`pnpm tsc`)
- [ ] Linter: 0 warnings (`pnpm lint`)
- [ ] Tests: 100% passing (`pnpm test`)
- [ ] Coverage: >80%

### Security
- [ ] RLS policies enabled
- [ ] Input validation added
- [ ] API keys server-side only
- [ ] No secrets in code/logs

### Performance
- [ ] Bundle size <500KB
- [ ] Lighthouse score >90
- [ ] API response <200ms
- [ ] No N+1 queries

### Testing
- [ ] E2E tests pass (Playwright)
- [ ] Browser testing complete (Chrome DevTools)
- [ ] Visual regression checked
- [ ] Manual QA complete

### Documentation
- [ ] README updated
- [ ] API docs complete
- [ ] Migration docs added
- [ ] Rollback plan documented

## Deployment Steps
1. [ ] Merge to main branch
2. [ ] Run migrations: `supabase db push`
3. [ ] Deploy Edge Functions: `supabase functions deploy`
4. [ ] Deploy frontend: `pnpm build && deploy`
5. [ ] Monitor logs: Check for errors
6. [ ] Verify feature: Manual test in production

## Rollback Plan
- Database: Run `{feature}_rollback.sql`
- Code: Revert commit `{hash}`
- Time estimate: <5 minutes

## Post-Deploy Monitoring
- [ ] Check error rates (first hour)
- [ ] Monitor performance metrics
- [ ] Verify user flows working
- [ ] Check analytics for adoption
```

---

### 7. Progress Tracker
**File**: `{feature-name}-progress.md`

```markdown
# {Feature Name} - Progress Tracker

**Status**: 🟡 In Progress
**Completion**: 45%
**ETA**: 2 weeks

## Progress by Phase

### Phase 1: Database ✅ Complete (100%)
- [x] Task 1.1: Schema created
- [x] Task 1.2: RLS policies added
- [x] Task 1.3: Migration tested

### Phase 2: Backend 🟡 In Progress (60%)
- [x] Task 2.1: Edge Function created
- [x] Task 2.2: Validation added
- [ ] Task 2.3: Tests (in progress)

### Phase 3: Frontend 🔴 Not Started (0%)
- [ ] Task 3.1: Components
- [ ] Task 3.2: State management
- [ ] Task 3.3: E2E tests

### Phase 4: Production ⏸️ Pending (0%)
- [ ] Task 4.1: Performance audit
- [ ] Task 4.2: Security audit
- [ ] Task 4.3: Deploy

## Blockers
- None currently

## Next Steps
1. Complete backend tests (Task 2.3)
2. Begin frontend components (Task 3.1)
3. Set up E2E test framework

## Last Updated
October 22, 2025
```

---

## Implementation Workflow

### Step 1: Create PRD
```bash
# Define requirements
cat > {feature}-prd.md << 'EOF'
[Use PRD template above]
EOF
```

### Step 2: Write Tech Spec
```bash
# Define architecture
cat > {feature}-tech-spec.md << 'EOF'
[Use Tech Spec template above]
EOF

# Create architecture diagram
cat > diagrams/{feature}-architecture.mmd << 'EOF'
graph TB
  [Mermaid diagram code]
EOF
```

### Step 3: Create Task Breakdown
```bash
# Break into granular tasks
cat > {feature}-tasks.md << 'EOF'
[Use Task template with proper sequencing]
EOF
```

### Step 4: Set Up Testing Plan
```bash
# Define test strategy
cat > {feature}-testing.md << 'EOF'
[Use Testing template with MCP tools]
EOF
```

### Step 5: Create Checklists
```bash
# Production readiness
cat > {feature}-production-checklist.md << 'EOF'
[Use Production Checklist template]
EOF

# Progress tracking
cat > {feature}-progress.md << 'EOF'
[Use Progress Tracker template]
EOF
```

---

## Prompt Templates for Claude

### Template: Database Layer
```
Task: Implement database schema for {feature}

Context:
- Tables: {list}
- RLS policies: {requirements}
- Migration file: supabase/migrations/{timestamp}_{feature}.sql

Instructions:
1. Create migration file with idempotent SQL
2. Add RLS policies for each table
3. Create rollback script
4. Test migration locally: `pnpm db:push`

Success Criteria:
- Migration runs without errors
- RLS policies enforce correct access
- Rollback script tested

Output:
- Migration file path
- RLS policy summary
- Test results
```

### Template: Edge Function
```
Task: Create Edge Function for {feature}

Context:
- Purpose: {description}
- Inputs: {request body schema}
- Outputs: {response schema}
- File: supabase/functions/{name}/index.ts

Instructions:
1. Create Edge Function with JWT validation
2. Add Zod schema for input validation
3. Implement business logic
4. Add error handling
5. Write unit tests
6. Deploy: `supabase functions deploy {name}`

Success Criteria:
- Function deploys successfully
- Returns expected output for valid input
- Returns 400 for invalid input
- Tests pass

Output:
- Function code
- Test results
- Deployment confirmation
```

### Template: Frontend Component
```
Task: Create React component for {feature}

Context:
- Component: {name}
- Props: {interface}
- File: src/components/{Name}.tsx
- Uses: shadcn/ui + Tailwind CSS

Instructions:
1. Create TypeScript component
2. Add proper types for props
3. Implement UI using shadcn/ui components
4. Add responsive styles (Tailwind)
5. Handle loading/error states
6. Write component tests

Success Criteria:
- Component renders correctly
- TypeScript: 0 errors
- Responsive design works
- Tests pass

Output:
- Component code
- Test file
- Usage example
```

### Template: E2E Test
```
Task: Write E2E test for {feature}

Context:
- User journey: {steps}
- Test file: e2e/{feature}.spec.ts
- Tool: Playwright

Instructions:
1. Create Playwright test file
2. Implement user journey steps:
   - Navigate to page
   - Interact with UI elements
   - Verify expected outcomes
3. Add assertions for all success criteria
4. Run test: `pnpm test:e2e`

Success Criteria:
- Test passes locally
- Covers all user journey steps
- Assertions validate expected behavior

Output:
- Test file code
- Test results (pass/fail)
- Screenshot on failure
```

---

## Best Practices

### Task Sequencing
1. **Database First**: Schema → RLS → Migration
2. **Backend Second**: Edge Functions → Validation → Tests
3. **Frontend Third**: Components → State → E2E Tests
4. **Validation Continuous**: Test after each layer
5. **Production Last**: Audit → Deploy → Monitor

### Testing Strategy
- **After each task**: Run relevant tests
- **After each layer**: Full layer validation
- **Before production**: Complete checklist
- **Use MCP tools**: Playwright + Chrome DevTools

### Documentation
- **Keep updated**: Progress tracker after each task
- **Link diagrams**: Use Mermaid for architecture
- **Version control**: All docs in git
- **Single source**: No duplication across docs

---

## Common Patterns

### New Feature Workflow
1. Create PRD (requirements)
2. Write Tech Spec (architecture)
3. Create Task Breakdown (implementation steps)
4. Set up Testing Plan (validation strategy)
5. Create Production Checklist (deploy criteria)
6. Initialize Progress Tracker (monitor status)

### Database Change Workflow
1. Design schema (ERD diagram)
2. Write migration (idempotent SQL)
3. Add RLS policies (security)
4. Create rollback (safety)
5. Test locally (validation)
6. Document in Tech Spec

### Testing Workflow
1. Unit tests (after each function)
2. Integration tests (after API complete)
3. E2E tests (after UI complete)
4. Browser tests (Playwright MCP)
5. Network tests (Chrome DevTools MCP)
6. Visual regression (screenshots)

---

*Use this skill to create comprehensive, production-ready planning documents with proper task sequencing and continuous testing validation.*
