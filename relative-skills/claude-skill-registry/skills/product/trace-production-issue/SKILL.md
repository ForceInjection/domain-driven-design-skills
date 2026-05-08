---
name: trace-production-issue
description: Trace production alerts and issues back through REQ-* to original intent, creating new intent for remediation. Closes feedback loop from Runtime → Intent. Use when production alerts fire or issues discovered.
allowed-tools: [Read, Grep, Glob, Bash]
---

# trace-production-issue

**Skill Type**: Actuator (Feedback Loop)
**Purpose**: Trace production issues back to requirements and create remediation intent
**Prerequisites**: Production alert or issue identified

---

## Agent Instructions

You are **closing the feedback loop** from production to intent.

**Workflow**: Alert → REQ-* → Original Intent → New Remediation Intent

**Your goal**: Trace issue back and create actionable remediation intent.

---

## Workflow

### Step 1: Parse Production Alert

**Extract REQ-* from alert**:

```json
{
  "alert_id": "alert_12345",
  "timestamp": "2025-11-20T15:30:00Z",
  "title": "Login latency exceeded",
  "description": "p95 latency is 750ms (threshold: 500ms)",
  "tags": {
    "req": "<REQ-ID>",  // ← Extract this
    "severity": "critical",
    "sla": "performance"
  },
  "metric": "auth.login.duration",
  "value": 750,
  "threshold": 500
}
```

**Extracted**: `<REQ-ID>`

---

### Step 2: Trace to Requirement

**Find requirement definition**:

```bash
# Search for requirement
grep -rn "^## <REQ-ID>" docs/requirements/

# Output:
# docs/requirements/authentication.md:15:## <REQ-ID>: User Login
```

**Load requirement**:

```markdown
## <REQ-ID>: User Login with Email and Password

**Type**: Functional Requirement
**Priority**: P0
**Intent**: INT-100

**Acceptance Criteria**:
...

**Related Requirements**:
- REQ-NFR-PERF-001: Login response < 500ms  ← SLA being violated!
```

---

### Step 3: Trace to Original Intent

**Find original intent**:

```bash
# From requirement, find intent
grep "Intent: INT-100" docs/requirements/authentication.md

# Load intent
cat intent.md | grep -A 20 "## INT-100"
```

**Intent context**:

```markdown
## INT-100: User Authentication System

**Requestor**: Product Team
**Priority**: P0

**Description**:
Secure user authentication for personalization and data protection.
```

---

### Step 4: Trace to Implementing Code

**Find code implementing requirement**:

```bash
# Find files implementing <REQ-ID>
grep -rn "# Implements: <REQ-ID>" src/

# Output:
# src/auth/login.py:23:# Implements: <REQ-ID>
```

**Analyze code**:
- What could cause 750ms latency?
- Database query slow?
- bcrypt cost too high?
- No caching?

---

### Step 5: Find Related Commits

**Git history for requirement**:

```bash
git log --all --grep="<REQ-ID>" --oneline

# Output:
# abc123 feat: Add user login (<REQ-ID>)
# def456 perf: Add caching to login (<REQ-ID>)
# ghi789 fix: Optimize db query (<REQ-ID>)
```

**Recent changes**: Did recent commit introduce regression?

---

### Step 6: Create Remediation Intent

**Generate new intent from alert**:

```markdown
# docs/intents/remediation.md

## INT-150: Fix Login Performance Degradation

**Type**: Remediation (URGENT)
**Created**: 2025-11-20
**Priority**: P0 (Critical - SLA violation)
**Source**: Production Alert (alert_12345)

**Related To**:
- **Original Intent**: INT-100 (User Authentication System)
- **Requirement**: <REQ-ID> (User login)
- **SLA Violated**: REQ-NFR-PERF-001 (Login response < 500ms)

**Problem**:
Login p95 latency increased to 750ms (threshold: 500ms).
SLA violation detected in production.

**Alert Details**:
- Alert: "Login latency exceeded"
- Metric: auth.login.duration{req:<REQ-ID>}
- Current: 750ms
- Threshold: 500ms
- Violation: +250ms (+50% over limit)

**Root Cause Analysis Needed**:
1. Database query performance (C-003: should be < 100ms)
2. bcrypt cost factor (C-001: cost 12, ~200ms expected)
3. Caching effectiveness (if implemented)
4. External service calls (if any)

**Proposed Investigation**:
1. Check database query times (should be < 100ms)
2. Profile bcrypt hashing time (should be ~200ms)
3. Check for N+1 queries
4. Review recent code changes (commits for <REQ-ID>)

**Success Criteria**:
- p95 latency < 500ms (back within SLA)
- p50 latency < 200ms (stretch goal)
- Root cause identified and fixed
- No regression in other requirements

**Impact**:
- Affected Users: 5% of login attempts (p95)
- Business Impact: Poor user experience, potential churn
- SLA Status: VIOLATED (critical)
```

---

### Step 7: Link to Traceability

**Create feedback loop entry**:

```yaml
# docs/traceability/feedback-loops.yml

alerts:
  - alert_id: "alert_12345"
    timestamp: "2025-11-20T15:30:00Z"
    title: "Login latency exceeded"
    requirement: "<REQ-ID>"
    original_intent: "INT-100"
    remediation_intent: "INT-150"  # ← New intent created
    status: "OPEN"
    assigned_to: "Backend Team"
```

---

### Step 8: Commit Remediation Intent

```bash
git add docs/intents/remediation.md docs/traceability/feedback-loops.yml
git commit -m "FEEDBACK: Create INT-150 from production alert (<REQ-ID>)

Create remediation intent from SLA violation alert.

Alert:
- ID: alert_12345
- Title: Login latency exceeded
- Metric: auth.login.duration (750ms, threshold 500ms)
- Requirement: <REQ-ID>

Traceability:
  Alert → req:<REQ-ID> → REQ-NFR-PERF-001 → INT-100 → INT-150 (new)

Remediation Intent Created:
- INT-150: Fix login performance degradation
- Priority: P0 (SLA violation)
- Related: <REQ-ID>, REQ-NFR-PERF-001

Feedback Loop:
  Production Issue → New Intent → SDLC Cycle Begins Again ♻️

Next: Investigate root cause, implement fix using TDD workflow
"
```

---

## Output Format

```
[TRACE PRODUCTION ISSUE - alert_12345]

Alert Details:
  ID: alert_12345
  Title: "Login latency exceeded"
  Timestamp: 2025-11-20T15:30:00Z
  Severity: CRITICAL

Requirement Trace:
  Alert Tag: req:<REQ-ID>
    ↓
  Requirement: <REQ-ID> (User Login)
  Location: docs/requirements/authentication.md:15
    ↓
  Related SLA: REQ-NFR-PERF-001 (Login < 500ms)
    ↓
  Original Intent: INT-100 (User Authentication System)
  Location: intent.md:5

Code Trace:
  Implementation: src/auth/login.py:23
  Recent Commits: 3 commits in last 7 days
    - abc123: perf: Add caching (3 days ago)
    - def456: refactor: Simplify login (5 days ago)
    - ghi789: fix: Handle edge case (7 days ago)

Root Cause Hypothesis:
  1. Database query slow (check C-003: should be < 100ms)
  2. bcrypt too slow (check C-001: cost 12 → ~200ms)
  3. Recent caching change (commit abc123)
  4. Increased traffic/load

Remediation Intent Created:
  ✓ INT-150: Fix login performance degradation
    - Type: Remediation (URGENT)
    - Priority: P0
    - Related: <REQ-ID>, REQ-NFR-PERF-001
    - Source: Production alert_12345

Feedback Loop:
  ✓ Alert → Requirement traced
  ✓ Original intent identified
  ✓ Remediation intent created
  ✓ Traceability logged

Next Steps:
  1. Assign INT-150 to backend team
  2. Investigate root cause (profile, DB queries)
  3. Implement fix using TDD workflow
  4. Deploy fix and verify SLA restored

✅ Production Issue Traced!
   Feedback loop closed
   Remediation intent ready for SDLC
```

---

## Notes

**Why trace production issues?**
- **Close feedback loop**: Production → Intent → SDLC
- **Root cause**: Understand what requirement is problematic
- **Living system**: Requirements evolve based on production reality
- **Homeostasis**: Production deviations generate corrective intents

**Feedback loop**:
```
Intent (INT-100)
  → Requirements (<REQ-ID>)
  → Design → Code → Deploy
  → Production (running)
  → Alert (SLA violation)
  → Trace back to <REQ-ID>
  → Create new Intent (INT-150: Fix performance)
  → SDLC cycle begins again ♻️
```

**Homeostasis Goal**:
```yaml
desired_state:
  all_alerts_traceable_to_req: true
  all_violations_create_intent: true
  feedback_loop: closed
```

**"Excellence or nothing"** 🔥
