---
name: intelligent-router
description: Analyzes user questions and automatically dispatches optimal agents/skills/plugins
triggers: []
version: 1.0.0
agents: []
activation: smart-auto-detect
context_levels:
  minimal: Router logic and decision framework
  detailed: Complete routing matrix and examples
  full: Scripts and testing tools
---

# 🎯 Intelligent Router - Smart Agent/Skill/Plugin Dispatch

## Overview

The Intelligent Router is an **automatic orchestration system** that analyzes user questions and intelligently selects the optimal combination of:
- 🤖 **Agents** (specialized subagents)
- 🎯 **Skills** (knowledge bundles)
- 🔌 **Plugins** (global tools)
- 📚 **Docs** (project documentation)
- 🛠️ **Tools** (native Claude tools)

**Design Philosophy: B - Medium Router**
- ✅ Auto-loads relevant skills
- ✅ Auto-dispatches primary agent
- 💡 Suggests optional agents (you choose)
- 📊 Transparent reporting (you see everything)

## When This Skill Activates

**Smart Auto-Detect** triggers on:
- ✅ Questions with 5+ words
- ✅ Action verbs: "maak", "bouw", "fix", "deploy", "test", etc.
- ✅ Complex requests (multiple domains)

**Skips on:**
- ❌ Simple questions: "Wat is X?", "Hoe werkt Y?"
- ❌ Short queries (< 5 words)
- ❌ Informational requests

## How It Works

### Phase 1: Analysis
```
User Question
    ↓
Intent Detection (analyze-intent.js)
    ↓
Match Against Routing Matrix
    ↓
Calculate Match Scores
    ↓
Identify Domains & Complexity
```

### Phase 2: Resource Collection
```
Collect ALL Matched Routes
    ↓
Primary Route = Highest Score
    ↓
Gather:
  - Skills from all matches
  - Plugins from all matches
  - Docs from all matches
  - Tools from primary route
  - Optional agents from secondary matches
```

### Phase 3: Dispatch
```
Auto-Load:
  ✅ Skills (via skill-loader.js)
  ✅ Docs (loaded into context)
  ✅ Plugins (activated)

Auto-Dispatch:
  ✅ Primary Agent (Task tool)

Suggest:
  💡 Optional Agents (you choose to dispatch)
  💡 Additional tools
  💡 Memory check (episodic-memory)
```

### Phase 4: Transparent Reporting
```
Display Formatted Analysis:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 INTELLIGENT ROUTER ANALYSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Detected Intent: [...]
📁 Complexity: [SIMPLE|MEDIUM|HIGH|COMPLEX]
🎯 Domains: [...]

✅ AUTO-LOADED SKILLS: [...]
✅ AUTO-DISPATCHED: [agent] → [reason]
💡 OPTIONAL DISPATCH: [suggestions]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Routing Matrix

The router uses `routing-matrix.json` with 20+ predefined routes:

### Critical Routes (Always Priority)
- **memory_recall** - Episodic memory search
- **security_review** - OWASP compliance, vulnerability scanning
- **authentication** - User auth, login systems
- **complex_feature** - Multi-domain features → master-orchestrator

### High Priority Routes
- **backend_api** - REST/GraphQL API development
- **backend_database** - SQL, schema design, queries
- **frontend_ui** - React/Vue components, UI work
- **testing_unit** - TDD, unit/integration tests
- **architecture** - System design, tech stack decisions
- **debugging** - Bug fixes, error resolution

### Medium Priority Routes
- **ux_design** - UI/UX, dashboards, premium interfaces
- **testing_e2e** - Playwright, browser automation
- **data_engineering** - ETL pipelines, data warehouses
- **deployment** - CI/CD, production deploys
- **ai_ml_integration** - LLM, RAG, vector databases
- **accessibility** - WCAG compliance, inclusive design

### Specialized Routes
- **code_search** - Finding code, codebase analysis
- **browser_automation** - Web scraping, UI testing
- **git_operations** - Worktrees, branching
- **documentation** - Writing docs, README files

## Complexity Assessment

Router automatically determines complexity:

### Simple (1 domain, < 10 words)
- Single file edit
- Small bug fix
- Quick query
→ **Auto-dispatch:** Direct to specialist agent

### Medium (2 domains, 10-30 words)
- New feature in one area
- Moderate refactoring
- Standard API endpoint
→ **Auto-dispatch:** Primary agent + suggest related agents

### High (3 domains, 30-50 words)
- Cross-cutting feature
- Security + functionality
- Multiple file changes
→ **Auto-dispatch:** Primary agent + optional specialists

### Complex (3+ domains, complex requirements)
- Complete new module
- System redesign
- Multi-domain integration
→ **Requires:** master-orchestrator with sub-agents

## Progressive Context Loading

Router uses 3 levels for skills:

### Level 1: Always Load
- Core principles (2-5KB)
- Quick reference
- Essential patterns

### Level 2: Load on Request
- Detailed patterns (10-15KB)
- Complete examples
- Architecture guidance

### Level 3: Full Context
- All scripts
- Templates
- Automation tools

**Default:** Router loads Level 1 for all matched skills
**Escalation:** Request Level 2/3 if needed

## Example Routing Scenarios

### Example 1: Simple Bug Fix
```
User: "Fix deze error in login.ts"

Router Analysis:
  Intent: Bug fixing
  Complexity: SIMPLE
  Domains: debugging, backend

Auto-Loaded:
  - systematic-debugging skill
  - testing-fundamentals skill

Auto-Dispatched:
  - senior-fullstack-developer

Optional:
  - qa-testing-engineer (regression tests)
```

### Example 2: Authentication System
```
User: "Maak een login systeem met registratie"

Router Analysis:
  Intent: User authentication
  Complexity: HIGH
  Domains: security, backend, frontend

Auto-Loaded:
  - security-essentials skill
  - backend-development-patterns skill
  - testing-fundamentals skill

Auto-Dispatched:
  - backend-specialist (primary)

Optional:
  - security-specialist (OWASP review)
  - frontend-specialist (login UI)
  - qa-testing-engineer (security tests)

Docs Loaded:
  - docs/security.md
  - docs/backend.md
```

### Example 3: Complete Feature
```
User: "Bouw een dashboard met gebruikers, data visualisatie en export"

Router Analysis:
  Intent: Multi-domain feature
  Complexity: COMPLEX
  Domains: frontend, backend, data, ux

Auto-Loaded:
  - backend-development-patterns skill
  - testing-fundamentals skill
  - brainstorming skill

Auto-Dispatched:
  - master-orchestrator
    Sub-agents (parallel):
      - backend-specialist (API)
      - frontend-specialist (Dashboard UI)
      - data-engineer (Data pipeline)
      - ux-design-expert (Charts/UX)
      - qa-testing-engineer (Test strategy)
```

### Example 4: Database Query
```
User: "Optimaliseer deze SQL query die te langzaam is"

Router Analysis:
  Intent: Database optimization
  Complexity: MEDIUM
  Domains: data-engineering, backend

Auto-Loaded:
  - backend-development-patterns skill

Auto-Dispatched:
  - data-engineer

Tools Activated:
  - sql-universal-expert

Optional:
  - senior-fullstack-developer (code refactor)

Docs Loaded:
  - docs/backend.md
```

## Usage

### Automatic (Recommended)
Router activates automatically when:
1. User asks question with 5+ words
2. Question contains action verbs
3. Question seems like a task (not just info)

No manual activation needed!

### Manual Testing
Test router analysis before dispatching:

```bash
# Analyze a question
node .claude/skills/intelligent-router/scripts/analyze-intent.js analyze "Maak een API"

# Get JSON output
node .claude/skills/intelligent-router/scripts/analyze-intent.js analyze "Fix bug" --json
```

### Integration with Hooks
Router integrates via `.claude/hooks/pre-prompt.sh` (optional):
```bash
#!/bin/bash
# Activate intelligent-router for every question
# Router internally checks if it should activate
```

## Configuration

### Customize Routing Matrix
Edit `routing-matrix.json` to:
- Add new routes
- Modify trigger keywords
- Adjust priorities
- Add custom agents/skills

### Customize Auto-Detect
Edit `auto_detect_config` in routing-matrix.json:
```json
{
  "min_word_count": 5,
  "action_verbs": ["maak", "bouw", "fix", ...],
  "skip_keywords": ["wat is", "hoe werkt", ...],
  "always_check_memory": true
}
```

### Complexity Thresholds
Adjust in `complexity_thresholds`:
```json
{
  "simple": {
    "max_words": 10,
    "max_domains": 1,
    "auto_dispatch": true
  },
  ...
}
```

## Router Decision Tree

```
User Question
    ↓
[Should Activate?]
    ├─ No → Normal response (skip router)
    └─ Yes → Continue
         ↓
    [Find Matches]
         ↓
    [No Matches?]
         ├─ Yes → Normal response
         └─ No → Continue
              ↓
         [Analyze Complexity]
              ↓
         [Simple/Medium/High] → Auto-dispatch primary agent
         [Complex] → Dispatch master-orchestrator
              ↓
         [Display Analysis]
              ↓
         [Execute Dispatch]
```

## Best Practices

### For Users
- ✅ Be specific in your questions (better matching)
- ✅ Use action verbs when you want work done
- ✅ Trust the router's suggestions
- ✅ Dispatch optional agents if they make sense

### For Developers
- ✅ Keep routing-matrix.json updated
- ✅ Add new routes for new capabilities
- ✅ Test routes with analyze-intent.js
- ✅ Monitor which routes get triggered most
- ✅ Refine trigger keywords based on usage

## Troubleshooting

### Router Not Activating
```bash
# Check question meets criteria
node scripts/analyze-intent.js analyze "your question"

# If "activate: false", question too simple
# Solution: Add more context or action verbs
```

### Wrong Agent Dispatched
```bash
# Check routing matrix matches
cat routing-matrix.json | grep -A 5 "your_keyword"

# Update triggers if needed
```

### Skills Not Loading
```bash
# Verify skills exist
node ../skill-loader.js list

# Check skill names in routing-matrix.json match
```

## Metrics & Improvement

Track router effectiveness:
- **Activation rate** - How often it activates vs skips
- **Accuracy** - Did it pick right agent/skills?
- **User satisfaction** - Did suggestions help?
- **Iteration count** - How many back-and-forth needed?

Store in: `.claude-memory/router-metrics.md`

## Version History

### v1.0.0 (Initial Release)
- Smart auto-detect activation
- 20+ predefined routes
- Complexity assessment
- Multi-level skill loading
- Transparent reporting
- Optional agent suggestions

## Future Enhancements

Planned features:
- [ ] Learning from past routing decisions
- [ ] User preference tracking
- [ ] Route effectiveness scoring
- [ ] Dynamic route creation
- [ ] Integration with episodic-memory for pattern learning
- [ ] Web UI for route visualization

## Resources

- **Routing Matrix:** `routing-matrix.json`
- **Intent Analyzer:** `scripts/analyze-intent.js`
- **Examples:** `examples/routing-scenarios.md`
- **Tests:** `examples/test-cases.md`

---

**Version:** 1.0.0
**Author:** CLAUDE Framework Team
**License:** MIT
**Compatibility:** Claude Code 1.0+, Claude 3.5 Sonnet+
