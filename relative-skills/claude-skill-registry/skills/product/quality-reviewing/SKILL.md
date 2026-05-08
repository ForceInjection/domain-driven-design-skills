---
name: quality-reviewing
description: Deep code review with web research. USE WHEN user says 'double check against latest', 'verify versions', 'check security'. Complements automatic quality hook with ecosystem verification.
allowed-tools: '*'
---

# Quality Reviewing

Deep review with web research to verify against current ecosystem. Complements automatic hook.

**When to use this skill (not automatic hook):**

- **Explicit web research**: "double check against latest docs", "verify versions", "check security"
- **Deep dive needed**: Performance, architecture, trade-offs beyond automatic hook
- **Pre-change review**: Review before making changes (hook only triggers after)

**Relationship:** Automatic hook does fast check with existing knowledge. This skill does deep dive with web research (2-3 min).

## 1. Detect Phase

If in BDD workflow, read current ticket from `.safeword-project/tickets/` and apply phase-appropriate research:

| Phase           | Research Focus                                  |
| --------------- | ----------------------------------------------- |
| intake          | Similar features in ecosystem, scope patterns   |
| define-behavior | Testing patterns, BDD best practices            |
| decomposition   | Architecture patterns, test layer strategy      |
| implement       | **Library versions, deprecated APIs, security** |
| done            | CI/CD patterns, release checklists              |

## 2. Verify Versions (Primary Value)

**CRITICAL**: This is your main differentiator from automatic hook.

Search for: "[library name] latest stable version 2025"
Search for: "[library name] security vulnerabilities"

**Flag if outdated:**

- Major versions behind -> WARN (e.g., React 17 when 19 is stable)
- Minor versions behind -> NOTE
- Security vulnerabilities -> CRITICAL (must upgrade)
- Using latest -> Confirm

## 3. Verify Documentation (Primary Value)

Fetch official documentation for libraries in use.

**Look for:**

- Deprecated APIs being used?
- Newer, better patterns available?
- Recent recommendation changes?

## Output Format

```markdown
## Quality Review

**Versions:** [✓/⚠️/❌] [Latest version check]
**Documentation:** [✓/⚠️/❌] [Current docs check]
**Security:** [✓/⚠️/❌] [Vulnerability check]

**Verdict:** [APPROVE / REQUEST CHANGES / NEEDS DISCUSSION]

**Critical issues:** [List or "None"]
**Suggested improvements:** [List or "None"]
```

## Reminders

1. **Primary value: Web research** - Verify versions, docs, security
2. **Complement automatic hook** - Hook checks correctness/elegance/bloat, you verify ecosystem
3. **Phase matters** - Adapt research focus to current BDD phase
4. **Be concise** - Hook already prompts for general quality, focus on what it can't do
