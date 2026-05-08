---
name: external-docs
description: Verify external libraries, APIs, and frameworks against current documentation before writing code. Use when about to implement features using external dependencies, when writing import statements for third-party libraries, when unsure if a pattern or method is current, or when the user mentions grounding or verification.
---

# External Docs

Verify external dependencies against current documentation before implementation.

---

## When to Ground

| Signal | Action |
|--------|--------|
| About to write `import` for external lib | Ground first |
| Using API/SDK methods | Verify current syntax |
| Framework-specific patterns | Check version compatibility |
| Auth/security code | Always verify current best practices |
| User says "ground" or "verify" | Run full grounding check |

**Default: When uncertain, ground.**

---

## Decision Tree

```
Where does truth live?

CODEBASE ────► Warp-Grep
              "How does X work in our code?"

WEB ─────────► Exa
              "What's the current API for X?"

HISTORY ─────► cm context → cass search
              "How did we do this before?"

TASKS ───────► bv --robot-*
              "What should I work on?"
```

---

## Exa Query Patterns

**Template:**
```
{library} {feature} {version} 2024 2025
```

**Good queries:**
```
FastAPI Pydantic v2 model_validator 2024 2025
Next.js 14 app router server components
React useOptimistic hook 2024
```

**Tools:**
- `web_search_exa(query)` — Documentation search
- `get_code_context_exa(query)` — Code examples from GitHub
- `crawling(url)` — Specific doc page

---

## Verification

After grounding, check:

| Criterion | Pass If |
|-----------|---------|
| Source | Official docs or reputable repo |
| Freshness | Updated within 12 months |
| Version | Matches your dependency |
| Completeness | Full import + usage pattern |
| Status | Not deprecated |

---

## Record in Bead

Add grounding status table:

```markdown
## Grounding Status
| Pattern | Query | Source | Status |
|---------|-------|--------|--------|
| `@model_validator` | "Pydantic v2 2024" | docs.pydantic.dev | ✅ Verified |
| `useOptimistic` | "React 19 2024" | react.dev | ✅ Verified |
```

Status: ✅ Verified | ⚠️ Changed | ❌ Deprecated | ❓ Unverified

---

## Failure Handling

| Issue | Response |
|-------|----------|
| No results | Broaden query, try alternate terms |
| Conflicting info | Official docs > GitHub > tutorials |
| Only outdated info | Mark ❓, proceed with caution, add TODO |
| Can't verify | Flag for human review |

---

## See Also

- `queries.md` — Extended query examples
- `patterns.md` — Common grounding patterns by framework
