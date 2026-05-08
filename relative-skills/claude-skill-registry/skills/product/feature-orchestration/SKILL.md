---
name: feature-orchestration
description: Story orchestration with progress tracking, standardized directory structure, and validation
version: 1.1.0
type: skill
---

# Feature Orchestration

Coordinate multi-story features with consistent directory structure, progress tracking, and validation.

## What This Skill Provides

- **Story initialization**: Auto-create standardized directory structure
- **Story tracker template**: Track acceptance criteria, tasks, and progress
- **Validation**: Verify story tracker completeness before implementation
- **AI-guided workflow**: Fill story tracker with acceptance criteria and task breakdown

## When to Use

- Starting a new user story within a feature
- Tracking story progress and status
- Coordinating multi-story features
- Validating story readiness before implementation

## Quick Start

### 1. Initialize Story

```bash
# From project root
./scripts/init-story.sh us-001
```

Creates:
```
specs/{feature}/stories/us-001/
├── story-tracker.md          ← Track progress
├── delegation/               ← Delegation briefs
├── checklists/               ← Quality gates
└── retro/                    ← Post-merge retro
```

### 2. Fill Story Tracker

Use AI-guided prompt:
```
/fill-story-tracker
```

Guides you through:
- Story overview
- Acceptance criteria (specific, testable)
- Task breakdown (1-4 hour tasks)
- Dependencies
- Implementation status

### 3. Validate Completeness

```bash
./scripts/validate-story-tracker.sh us-001
```

Checks:
- [ ] All required sections present
- [ ] No [Fill] placeholders remaining
- [ ] Tasks defined with checkboxes
- [ ] Status fields initialized

Exit code 0 = passed, 1 = failed (for automated gates).

## Directory Structure Convention

All process artifacts live in:
```
specs/{feature}/stories/{story-id}/
├── delegation/                    # Delegation briefs
│   ├── {agent-name}.delegation.md
│   └── completion-reports/
│       └── {agent-name}.report.md
├── checklists/                    # Quality gate checklists
│   ├── tdd-compliance.md
│   ├── claude-audit.md
│   └── e2e-test-plan.md
└── retro/                         # Post-merge retrospective
    ├── retro.md
    └── handoff.yml
```

## Integration with Other Skills

- **Spec-driven-development**: Story tracker references spec.md, plan.md, tasks.md
- **Task-delegation**: Delegation briefs stored in delegation/
- **TDD-workflow**: TDD compliance checklist in checklists/
- **Retrospective-workflow**: Post-merge retro in retro/

## Configuration

Requires `.apm-workflow.yml` in project root:
```yaml
current_feature: feature-id
```

Scripts auto-load this configuration to determine directory paths.

## Validation Criteria

Story tracker must have:
- Story Overview (user value, context)
- Acceptance Criteria (specific, testable, no vague statements)
- Tasks (atomic, 1-4 hours each, with checkboxes)
- Dependencies (upstream/downstream stories)
- Implementation Status (status, assigned to, dates)

## Scripts

- `init-story.sh <story-id>` - Initialize story directory structure
- `validate-story-tracker.sh <story-id>` - Verify completeness (exit 0/1)

## Prompts

- `fill-story-tracker` - AI-guided story tracker completion

## Templates

- `story-tracker.template.md` - Progress tracking template

---

## Legacy Core Responsibilities (Reference)

### 1. Feature Context Management

**Maintain the big picture across all user stories**

**Validation Checklist**:
```markdown
## Cross-Story Consistency Check

### Constitution Alignment
- [ ] All stories follow [Constitution Principle I]
- [ ] Test coverage meets constitution standards (e.g., 80%+)
- [ ] Security requirements applied across all stories

### Specification Consistency
- [ ] API contracts match across stories (no breaking changes)
- [ ] Data models consistent (no schema conflicts)
- [ ] User flows connect properly (Story A output → Story B input)
- [ ] Performance targets met across all stories

### Technical Debt
- [ ] No duplicate code across story branches
- [ ] Shared utilities extracted (not copied)
- [ ] Consistent error handling patterns
```

**Commands**:
- `/feature.validate.consistency`: Check for cross-story conflicts
- `/feature.validate.spec`: Verify feature completeness against spec
- `/feature.validate.constitution`: Audit constitution compliance

**Anti-Patterns to Detect**:
- ❌ **API Drift**: Story A defines `/api/birds`, Story B expects `/api/v1/birds`
- ❌ **Data Model Conflicts**: Story A uses `userId`, Story B uses `user_id`
- ❌ **Duplicate Code**: Same utility function in 3 different branches
- ❌ **Test Gaps**: Story A has 90% coverage, Story B has 20%

---

### 3. Progress Tracking

**Monitor WIP limits and story completion**

**Progress Dashboard**:
```markdown
## Feature Progress

**WIP Limit**: 3 stories (ENFORCED)
**Completed**: 5/12 stories
**In Progress**: 3 stories (AT LIMIT)
**Blocked**: 1 story (waiting on Story 3)

| Story | Status | Branch | Assignee | Blockers | ETA |
|-------|--------|--------|----------|----------|-----|
| US1   | ✅ Done | merged | - | - | - |
| US2   | ✅ Done | merged | - | - | - |
| US3   | 🔄 WIP | feat/us3 | Agent-A | None | Today |
| US4   | 🔄 WIP | feat/us4 | Agent-B | None | Tomorrow |
| US5   | 🔄 WIP | feat/us5 | Agent-C | None | Tomorrow |
| US6   | ⏸️ Blocked | - | - | Needs US3 API | TBD |
| US7   | 📋 Ready | - | - | None | - |
```

**Commands**:
- `/feature.progress.status`: Show current progress dashboard
- `/feature.progress.next`: Determine next story to start (respecting WIP limit)
- `/feature.progress.blockers`: Identify and resolve blockers

**WIP Limit Enforcement**:
```markdown
## WIP Limit Protocol

1. **Before starting new story**:
   - Check: `current_wip < wip_limit` (default: 3)
   - If at limit: STOP. Wait for story completion.
   - If under limit: Proceed with task delegation

2. **When story completes**:
   - Update progress tracker
   - Merge story branch
   - Check for unblocked stories
   - Start next story if under WIP limit

3. **If story is blocked**:
   - Mark as blocked with reason
   - Does NOT count against WIP limit
   - Re-evaluate after each story completion
```

---

## Integration with Spec-Driven Development

**Feature orchestration operates at the feature level, above individual stories**:

```
Constitution (spec-kit)
    ↓
Feature Spec (spec-kit: /speckit.specify)
    ↓
Feature Plan (spec-kit: /speckit.plan)
    ↓
📍 FEATURE ORCHESTRATION STARTS HERE
    ↓
Story Breakdown (spec-kit: /speckit.tasks → user stories)
    ↓
Story 1 Branch ← Fullstack Engineer (TDD, claude-framework)
Story 2 Branch ← Fullstack Engineer (TDD, claude-framework)
Story 3 Branch ← Fullstack Engineer (TDD, claude-framework)
    ↓
📍 FEATURE ORCHESTRATION: Merge & Validate
    ↓
Feature Complete (spec-kit: /speckit.analyze)
```

**Handoff Points**:
1. **From Spec-Kit to Feature Orchestration**: Tasks broken down into parallelizable user stories
2. **From Feature Orchestration to Engineers**: Story context + branch + acceptance criteria
3. **From Engineers to Feature Orchestration**: Completed story + tests + merge request
4. **From Feature Orchestration to Spec-Kit**: Feature completion validation

---

## Commands Reference

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/feature.init` | Initialize feature orchestration | At feature kickoff |
| `/feature.context.update` | Update feature context | After story completion |
| `/feature.context.review` | Review feature state | Before starting new story |
| `/feature.validate.consistency` | Check cross-story conflicts | Before merging stories |
| `/feature.validate.spec` | Verify spec completeness | At feature completion |
| `/feature.validate.constitution` | Audit constitution compliance | Continuous |
| `/feature.progress.status` | Show progress dashboard | Daily standup |
| `/feature.progress.next` | Determine next story | When under WIP limit |
| `/feature.progress.blockers` | Identify blockers | When stories stall |

---

## Best Practices

### ✅ Do This

- **Maintain living context**: Update after every story completion
- **Enforce WIP limits strictly**: No exceptions to 3-story limit
- **Validate early and often**: Run consistency checks before merging
- **Document handoffs explicitly**: Make dependencies crystal clear
- **Use git worktree**: Keep story branches isolated

### ❌ Don't Do This

- **Skip context updates**: Leads to merge conflicts and confusion
- **Exceed WIP limits**: Reduces throughput and increases context switching
- **Validate only at end**: Catch conflicts early, not at merge time
- **Assume implicit dependencies**: Document everything
- **Mix stories in one branch**: Keep stories isolated for parallel work

---

## Success Metrics

- ✅ **WIP limit respected**: Never exceed 3 concurrent stories
- ✅ **No merge conflicts**: Cross-story consistency maintained
- ✅ **Constitution compliance**: All stories pass validation
- ✅ **Spec completeness**: All requirements implemented
- ✅ **Handoffs smooth**: Dependencies clearly documented and met
