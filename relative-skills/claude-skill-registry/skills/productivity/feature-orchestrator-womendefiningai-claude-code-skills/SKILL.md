---
name: feature-orchestrator
description: Research-backed feature implementation workflow enforcing gap analysis, incremental planning, agent coordination, and continuous integration best practices. Auto-invoked for ALL feature implementation requests to prevent code duplication and ensure CLAUDE.md compliance.
---

<!--
Created by: Madina Gbotoe (https://madinagbotoe.com/)
Portfolio Project: AI-Enhanced Professional Portfolio
Version: 2.0 - Research-Backed Edition
Created: October 28, 2025
Last Updated: November 3, 2025
License: Creative Commons Attribution 4.0 International (CC BY 4.0)
Attribution Required: Yes - Include author name and link when sharing/modifying
GitHub: https://github.com/mgbotoe/claude-code-share/tree/main/claude-code-skills/feature-orchestrator

Purpose: Feature Orchestrator skill - Enforces CI/CD best practices, prevents redundancy, ensures incremental delivery based on Google, Microsoft, and industry research
-->

# Feature Orchestrator Skill

## 🚨 CRITICAL: This Skill Runs BEFORE Feature Implementation

**Purpose:** Enforce research-backed CI/CD workflow, prevent code duplication, ensure incremental delivery

**When to invoke:** Automatically when user requests implementing ANY new feature, component, or functionality

**Auto-invoke triggers:**
- "implement X feature"
- "add Y functionality"
- "build Z component"
- "create new X"
- "develop X feature"

**What this skill does NOT apply to:**
- Bug fixes (< 10 lines changed)
- Simple content/text updates
- Documentation-only changes
- Configuration tweaks

---

## 📚 Research Foundation

This workflow is backed by industry research from Google, Microsoft, IEEE, and leading software engineering organizations:

**Incremental Development (Scrum.org, 2024):**
> "Incremental delivery enables organizations to have greater visibility, decreases risks faster, delivers value sooner."

**Continuous Integration (Harness.io, 2024):**
> "Small problems are easier to fix than big problems, and frequent commits make bugs easier to identify."

**Code Review (Microsoft Research):**
> "Reviewing 200–400 lines of code at a time detects up to 90% of defects."

**DRY Principle (MetriDev, 2024):**
> "Abstraction and modularity prevent code duplication through identifying common patterns for reuse."

**For complete research citations and detailed procedures:** See `REFERENCE.md`

---

## 🎯 Four-Phase Workflow

### Overview

| Phase | Purpose | Time | Output |
|-------|---------|------|--------|
| **1. Gap Analysis** | Search for existing code | 2-3 min | Reuse opportunities identified |
| **2. Planning** | Break into increments | 3-5 min | Implementation plan with todos |
| **3. Review Gate** | Agent quality review | 1-2 min | Feedback incorporated |
| **4. Execution** | Build incrementally | Varies | Feature complete, tests passing |

---

### Phase 1: Gap Analysis (MANDATORY)

**Purpose:** Search for existing implementations BEFORE writing any code

**Research:** DRY principle - < 5% duplication target (SonarQube standard)

**Quick Procedure:**
```bash
# Search existing code
glob "**/*[keyword]*.tsx"
grep "[keyword]" --output_mode files_with_matches

# If found: Reuse or extend
# If not found: Create new with plan
```

**Template:** Use `resources/gap-analysis-template.md`

**Detailed procedures:** See `REFERENCE.md` → Phase 1

**Verification:**
- [ ] Searched for existing implementations?
- [ ] Identified reuse opportunities?
- [ ] Reported findings to user?

**If similar code exists:** Plan to extend/reuse → NO duplication

---

### Phase 2: Implementation Planning (MANDATORY per CLAUDE.md)

**Purpose:** Break feature into incremental, testable steps

**Research:** Agile INVEST criteria - Independent, Negotiable, Valuable, Estimable, Small, Testable

**Required Elements:**
1. **Objective** - What & Why & Success criteria
2. **Technical Approach** - Components, data flow, architecture
3. **Incremental Steps** - 30-60 min each, < 100 LOC each
4. **Testing Strategy** - Unit, integration, E2E, accessibility
5. **Performance** - React.memo(), useMemo(), code splitting
6. **Rollback Plan** - Feature flags, gradual rollout

**Template:** Use `resources/implementation-plan-template.md`

**Detailed procedures:** See `REFERENCE.md` → Phase 2

**Create TodoWrite Tracking:**
```typescript
TodoWrite({
  todos: [
    {
      content: "Step 1: Description",
      activeForm: "Step 1: Active form",
      status: "pending"
    },
    // ... all steps
  ]
})
```

**Present plan to user → Get approval before proceeding**

---

### Phase 3: Review Gate (CONDITIONAL)

**Purpose:** Invoke specialized agents for code/design review

**Research:** Google code reviews < 4 hour median latency for fast feedback

**Decision Matrix:**

| Criteria | Threshold | Action |
|----------|-----------|--------|
| Lines of code | > 100 | Invoke critic-agent |
| Security critical | Auth, payments | Always review |
| User-facing UI | Any | Invoke ui-ux-designer |
| Simple addition | < 50 lines | Skip review |

**Invoke Agents in Parallel:**
```markdown
Use Task tool with multiple calls in ONE message:
1. Task(subagent_type="critic-agent") → Code quality
2. Task(subagent_type="ui-ux-designer") → UX/accessibility
```

**After review:** Incorporate feedback → Update plan → Update todos

**Detailed procedures:** See `REFERENCE.md` → Phase 3

---

### Phase 4: Incremental Execution (MANDATORY)

**Purpose:** Implement feature in small, testable increments

**Research:** CI with frequent commits reduces integration issues (ResearchGate, 2024)

**The Golden Rule: NEVER Break the Build**

**For EACH increment:**

```markdown
1. Mark todo as "in_progress"

2. Implement (keep changes < 100 lines)

3. Test (MANDATORY - all must pass):
   npm run lint        # Must pass
   npm run type-check  # Must pass
   npm run test        # Must pass

   # Or use automation:
   ./scripts/validate-increment.sh  # Linux/Mac
   ./scripts/validate-increment.bat # Windows

4. Mark todo as "completed" (immediately!)

5. Commit (if appropriate)

6. ONLY proceed if ALL tests pass
```

**Template:** Use `resources/increment-checklist-template.md`

**Code Quality Rules:**
- **Component size:** < 200 lines (React), < 250 lines (services)
- **Data separation:** Arrays >20 lines → data files
- **Performance:** React.memo() for animations, expensive components
- **Imports:** No file extensions, use path aliases (@/...)
- **Accessibility:** WCAG 2.1 AA compliance

**File Size Monitoring:**
```bash
# Check before editing
./scripts/check-file-size.sh [file-path]

# Thresholds:
# 150-200 lines → ⚠️  Plan extraction
# 200-300 lines → 🚨 Extract before adding
# 300+ lines    → 🛑 MUST refactor first
```

**Detailed procedures:** See `REFERENCE.md` → Phase 4

**Verification (per increment):**
- [ ] Implemented ONLY this increment's scope?
- [ ] All tests passing?
- [ ] Todo marked completed?

---

## 🔄 Complete Workflow Example

**See `EXAMPLES.md` for:**
- Complete auth system implementation (2.5 hours)
- Simple feature addition (5 minutes)
- Gap analysis preventing duplication
- Review gate catching security issues

---

## 🎯 Integration with CLAUDE.md Rules

This skill enforces ALL mandatory CLAUDE.md rules:

1. ✅ **Search for existing code FIRST** (Phase 1: Gap Analysis)
2. ✅ **Plan before implementing** (Phase 2: Implementation Planning)
3. ✅ **Incremental implementation** (Phase 4: Never break the build)
4. ✅ **Test between increments** (Phase 4: lint + type-check + test)
5. ✅ **React.memo() for performance** (Phase 4: Code quality rules)
6. ✅ **Coordinate agents** (Phase 3: Review gate)
7. ✅ **TodoWrite tracking** (Phase 2 + Phase 4)
8. ✅ **Component size limits** (Phase 4: File size monitoring)

---

## 🚨 Anti-Patterns This Skill Prevents

### ❌ What NOT to Do:

1. **Starting without gap analysis** → Skill forces search first
2. **No implementation plan** → Skill requires incremental plan
3. **Large commits** → Skill enforces small increments
4. **Breaking the build** → Skill tests after each increment
5. **Skipping code review** → Skill invokes agents automatically
6. **Giant components (>300 lines)** → Skill monitors file size
7. **Missing optimization** → Skill checks React.memo(), etc.

---

## 📋 Verification Checklist (Before Completing)

**Before marking feature complete, verify:**

- [ ] Phase 1: Gap analysis completed?
- [ ] Phase 1: Existing code reused where possible?
- [ ] Phase 2: Implementation plan created?
- [ ] Phase 2: TodoWrite tracking set up?
- [ ] Phase 3: Agent review completed (if needed)?
- [ ] Phase 4: All increments implemented?
- [ ] Phase 4: All todos marked complete?
- [ ] Phase 4: All tests passing?
- [ ] Phase 4: No breaking changes introduced?
- [ ] Phase 4: Performance optimized?
- [ ] Phase 4: Accessibility verified (WCAG 2.1 AA)?
- [ ] Phase 4: Component sizes within limits?

**If any answer is NO, STOP and complete that phase.**

---

## 🚀 Expected Outcomes

**When this skill runs successfully:**

1. ✅ **No duplicate code** - Gap analysis finds existing implementations
2. ✅ **No redundancy** - Reuses existing components/services
3. ✅ **Well-planned** - Clear roadmap with time estimates
4. ✅ **Incrementally built** - Small, testable steps
5. ✅ **High quality** - Agent reviews catch issues early
6. ✅ **Well-tested** - Tests run after each increment
7. ✅ **Performant** - Optimization applied automatically
8. ✅ **Accessible** - WCAG compliance checked
9. ✅ **Maintainable** - Component sizes controlled
10. ✅ **Tracked** - TodoWrite shows clear progress

---

## 📊 Success Metrics

**Measure skill effectiveness:**
- ✅ Zero duplicate implementations in last 10 features
- ✅ All features have implementation plans
- ✅ No surprise breaking changes in commits
- ✅ Test pass rate > 95% on first try
- ✅ Code review feedback declining over time
- ✅ Component sizes staying within limits
- ✅ Feature delivery time predictable (within 20% of estimate)

**For detailed metrics and KPIs:** See `REFERENCE.md` → Success Metrics

---

## 🔧 Automation Scripts

**Validate increments:**
```bash
# Linux/Mac
./scripts/validate-increment.sh

# Windows
./scripts/validate-increment.bat
```

**Check file sizes:**
```bash
./scripts/check-file-size.sh [file-path]
```

**All scripts include:**
- Research citations
- Clear pass/fail status
- Actionable recommendations
- Exit codes for CI/CD integration

---

## 📚 Supporting Documentation

### For AI Assistants:

- **`REFERENCE.md`** - Complete research citations, detailed procedures, troubleshooting
- **`EXAMPLES.md`** - Real-world workflow examples, before/after scenarios
- **`resources/gap-analysis-template.md`** - Gap analysis structure
- **`resources/implementation-plan-template.md`** - Complete planning template
- **`resources/increment-checklist-template.md`** - Per-increment verification

### Research Sources:

**Academic:**
- Google Research: "Modern Code Review" (9M reviews analyzed)
- Microsoft Research: "Expectations of Modern Code Review" (900+ devs surveyed)
- IEEE: "Continuous Integration Research" (meta-analysis)
- Scrum.org: "Incremental Delivery Research" (2024)

**Industry:**
- SonarQube: Code quality standards
- Atlassian: Trunk-based development
- Harness.io: CI/CD best practices
- MetriDev: Code duplication research

**Books:**
- "The DevOps Handbook" (Gene Kim)
- "Accelerate" (Nicole Forsgren)
- "Building Maintainable Software" (O'Reilly)

---

## 💡 Tips for Maximum Effectiveness

1. **Trust the process** - Let all 4 phases run
2. **Don't skip gap analysis** - Even if you "know" nothing exists
3. **Break steps small** - 30-45 min increments ideal
4. **Test frequently** - After EVERY increment
5. **Use agent reviews** - They catch issues you miss
6. **Keep todos updated** - Reflects real progress
7. **Use automation** - Scripts save time and reduce errors

---

## 🔄 Integration with Other Skills

**Works with:**
- **code-refactoring** - Triggered when files exceed size limits
- **ui-ux-audit** - Invoked during Phase 3 for UI features
- **devops-deployment** - After Phase 4 for production deployment
- **qa-testing** - Referenced in Phase 2 for test strategy

---

## Final Note

**This skill is not optional.** When user requests implementing any feature, this skill MUST run to enforce research-backed CI/CD workflow rules.

**The goal:** Ship high-quality features faster by preventing common mistakes through automation.

**Research-backed. Industry-proven. Battle-tested.**

---

## Version History

- **v1.0** (Oct 2025): Initial version based on CLAUDE.md
- **v2.0** (Nov 2025): Added research citations, progressive disclosure, automation scripts, templates

**For complete version history and detailed research:** See `REFERENCE.md`
