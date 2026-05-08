---
name: elevate-code
description: Elevate projects to production quality using proven patterns. Use when starting a project, reviewing architecture, auditing code, or when user mentions "elevate-code", "production ready", "patterns", "make it production grade".
---

# Elevate Code

*Transform any project into production-quality software using proven patterns.*

**The Problem**: Most projects fail in predictable ways—users can't set them up, accidents cause data loss, crashes waste hours of progress, code becomes unmaintainable, errors are cryptic. These aren't bugs; they're missing patterns.

**The Solution**: Elevate systematically applies 12 battle-tested patterns that distinguish amateur code from production software.

---

## Quick Start

| Mode | When to Use | What Happens |
|------|-------------|--------------|
| **New Project** | Starting from scratch | Detect type → Generate scaffold with all patterns |
| **Audit** | Reviewing existing code | Detect type → Scan → Gap report |
| **Transform** | Elevating existing project | Audit + Propose + Generate missing pieces |

---

## The 12 Patterns

### The Foundation: The Triad (Patterns 1-3)

Three non-negotiable properties. If your project lacks any of these, fix them first.

*Setup should verify. Mistakes should undo. Crashes should resume.*

| # | Pattern | Litmus Test |
|---|---------|-------------|
| 1 | [**Health (Doctor)**](patterns/01-health-doctor.md) | Can a new user run `tool doctor` and know what's missing? |
| 2 | [**Safety (Safety Net)**](patterns/02-safety-net.md) | Can a mistake be undone in under 60 seconds? |
| 3 | [**Resilience (Statekeeper)**](patterns/03-resilience-statekeeper.md) | Can interrupted work resume without losing progress? |

### The Complete Set (Patterns 4-12)

| # | Pattern | Problem It Solves |
|---|---------|-------------------|
| 4 | [**Architecture**](patterns/04-architecture.md) | "The code is a tangled mess" |
| 5 | [**Data Models**](patterns/05-data-models.md) | "What shape is this data?" |
| 6 | [**Code Organization**](patterns/06-code-organization.md) | "Where does this code go?" |
| 7 | [**Error Handling**](patterns/07-error-handling.md) | "It failed but I don't know why" |
| 8 | [**Testing**](patterns/08-testing.md) | "I'm afraid to change anything" |
| 9 | [**Build & Deploy**](patterns/09-build-deploy.md) | "How do I ship this?" |
| 10 | [**CLI UX**](patterns/10-cli-ux.md) | "This tool is confusing" |
| 11 | [**Documentation**](patterns/11-documentation.md) | "How does this work?" |
| 12 | [**State Persistence**](patterns/12-state-persistence.md) | "Where did my data go?" |

---

## Elevation Workflow

### Step 1: Detect Project Type

Scan for file markers to identify project type and load the appropriate checklist:

| File Markers | Project Type | Checklist |
|--------------|--------------|-----------|
| `pyproject.toml` + `[project.scripts]` | Python CLI | [python-cli.md](checklists/python-cli.md) |
| `package.json` + `"bin"` field | Node.js CLI | [node-cli.md](checklists/node-cli.md) |
| `manifest.json` + `"background"` | Browser Extension | [browser-extension.md](checklists/browser-extension.md) |
| `pyproject.toml` + `fastapi` in deps | REST API (Python) | [rest-api.md](checklists/rest-api.md) |
| `package.json` + `express`/`hono`/`fastify` | REST API (Node) | [rest-api.md](checklists/rest-api.md) |
| `mcp.json` OR `@modelcontextprotocol` imports | MCP Server | [mcp-server.md](checklists/mcp-server.md) |
| `action.yml` or `action.yaml` | GitHub Action | [github-action.md](checklists/github-action.md) |

### Step 2: Scan for Existing Patterns

For each of the 12 patterns, grep for indicators and score as **Present**, **Partial**, or **Missing**:

```bash
# Triad
grep -rE "(doctor|check|verify|preflight)" .         # Health
grep -rE "(undo|restore|trash|dry-run)" .            # Safety
grep -rE "(checkpoint|resume|state\.json)" .         # Resilience

# Structure
grep -rE "(@dataclass|interface |TypedDict)" .       # Data Models
grep -rE "(pytest|vitest|conftest|\.test\.)" .       # Testing

# Quality
grep -rE "(retry|backoff|graceful)" .                # Error Handling
```

### Step 3: Generate Gap Report

```markdown
## Gap Analysis: <project-name>

**Project Type**: <detected-type>
**Patterns Detected**: X/12

### Present
- [x] Pattern Name - evidence found

### Partial
- [~] Pattern Name - what exists, what's missing

### Missing
- [ ] Pattern Name - why it matters
```

### Step 4: Propose Transformations

For each gap, propose specific changes. Prioritize by impact:

1. **Triad first** (Doctor, Safety, Statekeeper)
2. **Data Models** (foundation for everything else)
3. **Error Handling** (user experience)
4. **Testing** (confidence to change)
5. **Everything else**

### Step 5: Generate Scaffold

For missing patterns, generate files from `templates/<project-type>/`:
- Customize with project name
- Show diff preview before writing

---

## Success Criteria

A fully elevated project passes:

- [ ] **Triad**: doctor ✓, undo ✓, resume ✓
- [ ] **Type Safety**: All data structures typed (dataclass/interface)
- [ ] **Module Separation**: One module = one responsibility
- [ ] **Error Messages**: Include what + why + fix
- [ ] **Tests**: Mocked external deps, >80% coverage on core
- [ ] **Build Config**: Standard tooling (pyproject.toml / package.json)
- [ ] **AI Collaboration**: CLAUDE.md with architecture
- [ ] **Output Modes**: Human + `--json` + `--quiet`

---

*Elevate: Because production-quality isn't about perfection—it's about patterns.*
