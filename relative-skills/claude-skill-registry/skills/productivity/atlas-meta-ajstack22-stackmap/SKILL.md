---
name: atlas-meta
description: Orchestrates Atlas workflow tier selection for software development tasks
---

# Atlas Workflow Orchestrator

## Your Role

You are the Atlas orchestrator. When a user describes a development task, you:

1. **Analyze** the task complexity, scope, and risk
2. **Select** the appropriate workflow tier (Quick/Iterative/Standard/Full)
3. **Invoke** the corresponding Atlas skill
4. **Execute** the workflow phases

## Quick Decision Tree

```
Is it 1 file, trivial, zero risk, no validation needed?
├─ YES → Load atlas-quick skill
└─ NO → Continue...

Does it need validation but not research/planning?
├─ YES → Load atlas-iterative skill
└─ NO → Continue...

Is it 2-5 files with clear requirements?
├─ YES → Load atlas-standard skill ⭐ DEFAULT
└─ NO → Continue...

Is it 6+ files, security-critical, or needs formal requirements?
├─ YES → Load atlas-full skill
└─ NOT SURE → Load atlas-standard skill
```

## Workflow Tiers

| If task is... | Load skill | Time | Example |
|--------------|------------|------|---------|
| **Typo, color, 1 file** | `atlas-quick` | 5-15 min | "Fix typo in welcome text" |
| **Style tweak, simple UI** | `atlas-iterative` | 15-30 min | "Improve button spacing" |
| **Bug fix, small feature** | `atlas-standard` | 30-60 min | "Fix sync race condition" |
| **New module, epic** | `atlas-full` | 2-4 hours | "Implement photo attachments" |

**Default**: When in doubt, use `atlas-standard` - it's right for 80% of tasks.

## Invocation Patterns

### Automatic Routing
```
User: "Fix the bug where sync fails with empty activity list"
→ You analyze: 2-5 files, needs research, bug fix
→ You invoke: atlas-standard skill
→ You execute: 5-phase Standard workflow
```

### Explicit Routing
```
User: "Fix typo in login button. Use Atlas Quick workflow."
→ You invoke: atlas-quick skill
→ You execute: 2-phase Quick workflow
```

## StackMap-Specific Rules

Before ANY deployment, verify:

### 1. Field Naming Standards ✅
- Activities use `text` and `icon` (NOT name/title/emoji)
- Users use `icon` and `name` (NOT emoji)
- Always include fallbacks: `activity.text || activity.name || activity.title`
- See `/src/utils/dataNormalizer.js` for field normalization

### 2. Store Updates ✅
- NEVER use `useAppStore.setState()` directly
- User updates: `useUserStore.getState().setUsers()`
- Settings: `useSettingsStore.getState().updateSettings()`
- Library: `useLibraryStore.getState().setLibrary()`

### 3. Platform Testing ✅
- Shared code changes → Test iOS, Android, Web
- Check platform-specific gotchas in CLAUDE.md:
  - **Android**: FlexWrap cards use 48% widths, font variants not fontWeight
  - **iOS**: AsyncStorage debounced, NetInfo disabled
  - **Web**: 3-column layout uses percentage widths, no Alert.alert

### 4. Deployment Process ✅
- ALWAYS update `PENDING_CHANGES.md` first
- Use `./scripts/deploy.sh [qual|stage|beta|prod]`
- NEVER skip tests without explicit approval
- Run `npm run typecheck` before committing

### 5. Design Rules ✅
- NO GRAY TEXT - all text must be #000 (black)
- High contrast required for accessibility
- Use Typography component (handles font variants automatically)

## Escalation Rules

### Escalate to Higher Tier If:
- **Quick → Iterative**: Simple change but want validation
- **Quick/Iterative → Standard**: Multiple files affected, tests fail, edge cases emerge
- **Standard → Full**: 6+ files, security concerns, formal requirements needed

### How to Escalate:
```
"Escalating to [TIER] workflow. [REASON: scope expanded, security implications, etc.]"
```
Then restart from Phase 1 of new tier.

## Anti-Patterns (Never Do This)

❌ Use Quick workflow for new authentication system (use Full)
❌ Use Full workflow for fixing a typo (use Quick)
❌ Skip deployment phase to save time (tests are mandatory)
❌ Use `useAppStore.setState()` directly (use store-specific methods)
❌ Use `activity.name` or `activity.emoji` (use `text` and `icon`)
❌ Gray text colors (use #000 only)
❌ Manual git commits (use deployment scripts)

## Success Indicators by Tier

### Quick Success:
- ✅ Change deployed in < 15 minutes
- ✅ Tests pass
- ✅ No rollbacks

### Iterative Success:
- ✅ Change validated in < 30 minutes
- ✅ Peer review approved
- ✅ Tests pass

### Standard Success:
- ✅ Feature complete in < 2 hours
- ✅ All edge cases covered
- ✅ Tests pass
- ✅ Peer review approved

### Full Success:
- ✅ Epic complete with full documentation
- ✅ 100% acceptance criteria met
- ✅ Zero defects in production
- ✅ Full evidence trail

## Resources

- **Full decision matrix**: See `resources/tier-selector.md`
- **StackMap conventions**: See project's `CLAUDE.md`
- **Platform gotchas**: See `docs/` directory

## Example Orchestration

### Example 1: Automatic Routing
```
User: "The sync system loses activity icons during conflict resolution"

Your analysis:
- Scope: Affects syncService.js, maybe conflict resolution logic (2-5 files)
- Complexity: Needs research to understand conflict handling
- Risk: Medium (data integrity issue)
- Validation: Needs peer review
→ Decision: atlas-standard

Your response:
"I'll use the Atlas Standard workflow for this bug fix."
[Invoke atlas-standard skill]
[Execute 5-phase workflow]
```

### Example 2: Explicit Routing
```
User: "Change primary button color to #007AFF. Use Atlas Quick."

Your analysis:
- Explicit tier specified: Quick
- Verification: 1 file, trivial, zero risk ✅
→ Decision: atlas-quick

Your response:
"Using Atlas Quick workflow for this trivial change."
[Invoke atlas-quick skill]
[Execute 2-phase workflow]
```

### Example 3: Escalation
```
User: "Fix the modal padding issue"

Your initial analysis:
- Expected: 1 file, simple CSS change
→ Initial decision: atlas-quick

During implementation:
- Found: Affects 4 modal components + platform-specific styles
- Complexity: Android uses different flex rules than iOS/Web
- Risk: Could break modal layouts across platforms
→ Escalation: atlas-standard

Your response:
"Escalating to Standard workflow. Found 4 files affected with platform-specific considerations."
[Invoke atlas-standard skill]
[Restart from Phase 1: Research]
```

## Integration with Agent Skills

Atlas includes specialized agent skills for specific phases:

- **atlas-agent-developer**: Implementation and planning (Sonnet)
- **atlas-agent-peer-reviewer**: Deep reviews, edge cases (Opus)
- **atlas-agent-product-manager**: Story creation, validation (Sonnet)
- **atlas-agent-devops**: Deployment, infrastructure (Sonnet)
- **atlas-agent-security**: Security audits (Sonnet)

These agents are invoked automatically during appropriate workflow phases.

## Quick Start

### As a User:
```
"[Describe your task]"
→ Orchestrator selects tier and executes workflow

OR

"[Task description]. Use Atlas [Quick|Iterative|Standard|Full] workflow."
→ Orchestrator uses specified tier
```

### As the Orchestrator:
1. Read task description
2. Apply decision tree
3. Invoke appropriate skill
4. Execute workflow phases
5. Apply StackMap-specific rules throughout
6. Ensure quality gates pass before deployment

---

**Remember**: When in doubt, choose `atlas-standard`. It provides the right balance of rigor and speed for most development tasks.
