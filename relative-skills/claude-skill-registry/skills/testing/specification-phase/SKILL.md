---
name: specification-phase
description: "Standard Operating Procedure for /specify phase. Covers classification, research depth, clarification strategy, and roadmap integration."
allowed-tools: Read, Write, Edit, Grep, Bash
---

# Specification Phase: Standard Operating Procedure

> **Training Guide**: Step-by-step procedures for executing the `/specify` command following workflow best practices.

**Supporting references**:
- [reference.md](reference.md) - Classification decision tree, informed guess heuristics, defaults
- [examples.md](examples.md) - Good specs (0-2 clarifications) vs bad specs (>5 clarifications)
- [templates/informed-guess-template.md](templates/informed-guess-template.md) - Template for making reasonable assumptions

---

## Phase Overview

**Purpose**: Transform natural language feature requests into structured specifications that enable planning and implementation.

**Inputs**:
- User's feature description (natural language)
- Existing roadmap entries (if applicable)
- Codebase context

**Outputs**:
- `specs/NNN-slug/spec.md` - Structured feature specification
- `specs/NNN-slug/NOTES.md` - Implementation notes and decisions
- `specs/NNN-slug/visuals/README.md` - Visual artifacts directory (if HAS_UI=true)
- `specs/NNN-slug/workflow-state.yaml` - Phase state tracking
- Updated roadmap (if feature from roadmap)

**Expected duration**: 10-15 minutes

---

## Prerequisites

**Environment checks**:
- [ ] Git working tree clean
- [ ] Not on main branch (create feature branch: `feature/NNN-slug`)
- [ ] Required templates exist in `.spec-flow/templates/`

**Knowledge requirements**:
- Understanding of classification flags (HAS_UI, IS_IMPROVEMENT, HAS_METRICS, HAS_DEPLOYMENT_IMPACT)
- Informed guess heuristics for common technical decisions
- Clarification prioritization matrix (scope > security > UX > technical)

---

## Execution Steps

### Step 1: Parse and Normalize Input

**Actions**:
1. Extract feature description from user arguments
2. Generate slug using normalization rules (see [reference.md](reference.md#slug-generation-rules))
   - Remove filler words: "add", "create", "we want to", "get our"
   - Normalize to lowercase kebab-case
   - Limit to 50 characters
3. Assign next available feature number (NNN)

**Example**:
```bash
Input: "We want to add student progress dashboard"
Slug: "student-progress-dashboard"
Number: 042
Directory: specs/042-student-progress-dashboard/
```

**Quality check**: Does slug clearly describe the feature without filler words?

---

### Step 2: Check Roadmap Integration

**Actions**:
1. Search `.spec-flow/memory/roadmap.md` for exact slug match
2. If not found, search for fuzzy matches (similar terms)
3. If match found:
   - Set `FROM_ROADMAP=true`
   - Extract existing requirements, area, role, impact/effort scores
   - Move roadmap entry from "Backlog"/"Next" to "In Progress"
   - Add branch and spec links to roadmap entry

**Example**:
```bash
# Exact match
if grep -qi "^### ${SLUG}" .spec-flow/memory/roadmap.md; then
  FROM_ROADMAP=true
  # Reuse context saves ~10 minutes
fi
```

**Quality check**: If feature was pre-planned in roadmap, did we reuse that context?

---

### Step 2.5: Load Project Documentation Context (NEW)

**Purpose**: Load architecture constraints from `docs/project/` before generating spec to prevent hallucination.

**Actions**:
1. Check if project docs exist:
   ```bash
   if [ -d "docs/project" ]; then
     HAS_PROJECT_DOCS=true
     echo "✅ Project documentation found - loading architecture context"
   else
     echo "ℹ️  No project documentation (run /init-project recommended)"
     HAS_PROJECT_DOCS=false
   fi
   ```

2. If docs exist, read relevant files for spec phase:
   - **tech-stack.md** → Avoid suggesting wrong technologies
   - **api-strategy.md** → Follow established REST/GraphQL patterns
   - **data-architecture.md** → Reuse existing entities, avoid duplication
   - **system-architecture.md** → Identify integration points

3. Extract key constraints:
   ```bash
   # Extract tech stack
   FRONTEND=$(grep -A 1 "| Frontend" docs/project/tech-stack.md | tail -1 | awk '{print $3}')
   BACKEND=$(grep -A 1 "| Backend" docs/project/tech-stack.md | tail -1 | awk '{print $3}')
   DATABASE=$(grep -A 1 "| Database" docs/project/tech-stack.md | tail -1 | awk '{print $3}')

   # Extract API patterns
   API_STYLE=$(grep -A 1 "## API Style" docs/project/api-strategy.md | tail -1)
   AUTH_PROVIDER=$(grep -A 1 "## Authentication" docs/project/api-strategy.md | tail -1)

   # Extract existing entities from ERD
   ENTITIES=$(grep -oP '[A-Z_]+(?= \{)' docs/project/data-architecture.md)
   ```

4. Document context in NOTES.md:
   ```bash
   cat >> $NOTES_FILE <<EOF

## Project Documentation Context

**Source**: \`docs/project/\` (loaded during spec phase)

### Tech Stack Constraints (from tech-stack.md)
- **Frontend**: $FRONTEND
- **Backend**: $BACKEND
- **Database**: $DATABASE

### API Patterns (from api-strategy.md)
- **API Style**: $API_STYLE
- **Auth**: $AUTH_PROVIDER

### Existing Entities (from data-architecture.md)
- $ENTITIES

**Spec Requirements**:
- ✅ MUST use documented tech stack (no hallucinating MongoDB if PostgreSQL is documented)
- ✅ MUST follow API patterns (REST vs GraphQL per api-strategy.md)
- ✅ MUST check for duplicate entities before proposing new ones
- ❌ MUST NOT suggest different tech stack without justification

EOF
   ```

**Quality check**:
- Project docs loaded? ✅
- Constraints extracted and documented? ✅
- NOTES.md includes project context section? ✅

**Skip if**: No project docs exist (warn user but don't block)

**References**: See `.claude/skills/project-docs-integration.md` for detailed extraction logic

---

### Step 3: Classify Feature

**Actions**:
1. Apply classification decision tree (see [reference.md](reference.md#classification-decision-tree))
2. Set classification flags:
   - **HAS_UI**: Does it include user-facing screens/components?
   - **IS_IMPROVEMENT**: Does it optimize existing functionality with measurable baseline?
   - **HAS_METRICS**: Does it track user behavior (HEART metrics)?
   - **HAS_DEPLOYMENT_IMPACT**: Does it require env vars, migrations, breaking changes?

**Decision tree quick reference**:
```
UI keywords (screen, page, dashboard, form, modal, component, frontend, interface)
  → BUT NOT backend-only (API, endpoint, worker, cron, job, migration, health check)
  → HAS_UI = true

Improvement keywords (improve, optimize, enhance, speed up, reduce time)
  → AND mentions baseline (existing, current, slow, faster, better)
  → IS_IMPROVEMENT = true

Metrics keywords (track user, measure user, engagement, retention, conversion, analytics)
  → HAS_METRICS = true

Deployment keywords (migration, env variable, breaking change, docker, schema change)
  → HAS_DEPLOYMENT_IMPACT = true
```

**Quality check**: Does classification match feature intent? (No UI for backend workers, no improvement flag without baseline)

---

### Step 4: Determine Research Depth

**Actions**:
1. Count classification flags (`FLAG_COUNT = number of true flags`)
2. Select research depth based on complexity:
   - `FLAG_COUNT = 0`: **Minimal** (1-2 tools: constitution check, pattern search)
   - `FLAG_COUNT = 1`: **Standard** (3-5 tools: + UI scan, performance budgets, similar specs)
   - `FLAG_COUNT ≥ 2`: **Full** (5-8 tools: + design inspirations, web search, integration analysis)

**Research tools by depth**:

| Depth | Tools | Use Cases |
|-------|-------|-----------|
| Minimal | Constitution, Grep similar patterns | Simple backend endpoint, config change |
| Standard | + UI inventory, Performance budgets, Similar specs | Single-aspect feature (UI-only or backend-only) |
| Full | + Design inspirations, Web search, Integration points | Complex multi-aspect feature |

**Quality check**: Research depth matches complexity. Don't over-research simple features.

---

### Step 5: Apply Informed Guess Strategy

**Actions**:
1. Identify technical decisions needed
2. For each decision, check if it has a reasonable default (see [reference.md](reference.md#informed-guess-heuristics))
3. **Use defaults for** (do NOT clarify):
   - Performance targets (API <500ms, Frontend FCP <1.5s)
   - Data retention (Logs 90 days, Analytics 365 days)
   - Error handling (User-friendly messages + error IDs)
   - Rate limiting (100 req/min per user)
   - Authentication (OAuth2 for users, JWT for APIs)
4. **Document assumptions** in spec.md "Assumptions" section

**Example - Performance targets**:
```markdown
## Performance Targets (Assumed)
- API endpoints: <500ms (95th percentile)
- Frontend FCP: <1.5s, TTI: <3.0s
- Lighthouse: Performance ≥85, Accessibility ≥95

_Assumption: Standard web application performance expectations applied._
```

**Quality check**: No clarifications for decisions with industry-standard defaults.

---

### Step 6: Generate Clarifications (Max 3)

**Actions**:
1. Identify ambiguities that **cannot** be reasonably assumed
2. Prioritize by impact using matrix (see [reference.md](reference.md#clarification-prioritization-matrix)):
   - **Critical** (always ask): Scope boundary, Security/Privacy, Breaking changes
   - **High** (ask if ambiguous): User experience decisions
   - **Medium** (use defaults): Performance SLAs, Technical stack choices
   - **Low** (use defaults): Error messages, Rate limits
3. Keep only top 3 most critical clarifications
4. Format as: `[NEEDS CLARIFICATION: Specific question?]`

**Example - Good clarifications**:
```markdown
[NEEDS CLARIFICATION: Should dashboard show all students or only assigned classes?]
[NEEDS CLARIFICATION: Should parents have access to this dashboard?]
```

**Example - Bad clarifications** (have defaults):
```markdown
❌ [NEEDS CLARIFICATION: What's the target response time?] → Use 500ms default
❌ [NEEDS CLARIFICATION: Which database to use?] → Planning-phase decision
❌ [NEEDS CLARIFICATION: What error message format?] → Use standard pattern
```

**Quality check**: ≤3 clarifications total, all are scope/security/UX critical.

---

### Step 7: Write Success Criteria

**Actions**:
1. For each requirement, define measurable success criteria
2. Use **quantifiable metrics**, not subjective statements
3. Include **measurement method** where applicable
4. Avoid technology-specific criteria (focus on outcomes)

**Good criteria format**:
```markdown
## Success Criteria
- User can complete registration in <3 minutes (measured via PostHog funnel)
- API response time <500ms for 95th percentile (measured via Datadog APM)
- Lighthouse accessibility score ≥95 (measured via CI Lighthouse check)
- 95% of user searches return results in <1 second
```

**Bad criteria to avoid**:
```markdown
❌ System works correctly (not measurable)
❌ API is fast (not quantifiable)
❌ UI looks good (subjective)
❌ React components render efficiently (technology-specific, not outcome-focused)
```

**Quality check**: Every criterion is measurable, quantifiable, and outcome-focused.

---

### Step 8: Generate Artifacts

**Actions**:
1. Create `specs/NNN-slug/` directory
2. Render `spec.md` from template with:
   - Classification flags
   - Requirements (from roadmap or user input)
   - Assumptions (documented informed guesses)
   - Clarifications (≤3)
   - Success criteria (measurable)
   - Deployment considerations (if HAS_DEPLOYMENT_IMPACT=true)
   - HEART metrics (if HAS_METRICS=true)
   - Hypothesis (if IS_IMPROVEMENT=true)
3. Create `NOTES.md` for implementation decisions
4. Create `visuals/README.md` (if HAS_UI=true)
5. Initialize `workflow-state.yaml`

**Quality check**: All required artifacts created, template variables filled correctly.

---

### Step 9: Validate and Commit

**Actions**:
1. Run validation checks:
   - [ ] Requirements checklist complete (if exists)
   - [ ] Clarifications ≤3
   - [ ] Classification flags match feature description
   - [ ] Success criteria are measurable
   - [ ] Roadmap updated (if FROM_ROADMAP=true)
2. Commit spec with proper message:
   ```bash
   git add specs/NNN-slug/
   git commit -m "feat: add spec for <feature-name>

   Generated specification with classification:
   - HAS_UI: <true/false>
   - IS_IMPROVEMENT: <true/false>
   - HAS_METRICS: <true/false>
   - HAS_DEPLOYMENT_IMPACT: <true/false>

   Clarifications: N
   Research depth: <minimal/standard/full>
   ```

**Quality check**: Spec committed, roadmap updated, workflow-state.yaml initialized.

---

## Common Mistakes to Avoid

### 🚫 Over-Clarification (Too Many [NEEDS CLARIFICATION] Markers)

**Impact**: Delays planning phase, frustrates users

**Scenario**:
```
Spec with 7 clarifications (limit: 3):
- [NEEDS CLARIFICATION: What format? CSV or JSON?] → Use JSON default
- [NEEDS CLARIFICATION: Rate limiting strategy?] → Use 100/min default
- [NEEDS CLARIFICATION: Maximum file size?] → Use 50MB default
```

**Prevention**:
- Use industry-standard defaults (see [reference.md](reference.md#informed-guess-heuristics))
- Only mark critical scope/security decisions as NEEDS CLARIFICATION
- Document assumptions in spec.md "Assumptions" section
- Prioritize by impact: scope > security > UX > technical

**If encountered**: Reduce to 3 most critical, convert others to documented assumptions.

---

### 🚫 Wrong Classification (HAS_UI=true for backend-only)

**Impact**: Creates unnecessary UI artifacts, wastes time

**Scenario**:
```
Feature: "Add background worker to process uploads"
Classified: HAS_UI=true (WRONG - no user-facing UI)
Result: Generated screens.yaml for backend-only feature
```

**Root cause**: Keyword "process" triggered false positive without checking for backend-only keywords

**Prevention**:
1. Check for backend-only keywords: worker, cron, job, migration, health check, API, endpoint, service
2. Require BOTH UI keyword AND absence of backend-only keywords
3. Use classification decision tree (see [reference.md](reference.md#classification-decision-tree))

---

### 🚫 Roadmap Slug Mismatch

**Impact**: Misses context reuse opportunity, duplicates planning work

**Scenario**:
```
User input: "We want to add Student Progress Dashboard"
Generated slug: "add-student-progress-dashboard" (BAD - includes "add")
Roadmap entry: "### student-progress-dashboard" (slug without "add")
Result: No match found, created fresh spec instead of reusing roadmap context
```

**Prevention**:
1. Remove filler words during slug generation: "add", "create", "we want to"
2. Normalize to lowercase kebab-case consistently
3. Offer fuzzy matches if exact match not found

---

### 🚫 Too Many Research Tools

**Impact**: Wastes time, exceeds token budget

**Scenario**:
```bash
# 15 research tools for simple backend endpoint (WRONG)
Glob *.py
Glob *.ts
Glob *.tsx
Grep "database"
Grep "model"
Grep "endpoint"
...10 more tools
```

**Prevention**:
- Use research depth guidelines: FLAG_COUNT = 0 → 1-2 tools only
- For simple features: Constitution check + pattern search is sufficient
- Reserve full research (5-8 tools) for complex multi-aspect features

**Correct approach**:
```bash
# 2 research tools for simple backend endpoint (CORRECT)
grep "similar endpoint" specs/*/spec.md
grep "BaseModel" api/app/models/*.py
```

---

### 🚫 Vague Success Criteria

**Impact**: Cannot validate implementation, leads to scope creep

**Bad examples**:
```markdown
❌ System works correctly (not measurable)
❌ API is fast (not quantifiable)
❌ UI looks good (subjective)
```

**Good examples**:
```markdown
✅ User can complete registration in <3 minutes (measured via PostHog funnel)
✅ API response time <500ms for 95th percentile (measured via Datadog APM)
✅ Lighthouse accessibility score ≥95 (measured via CI Lighthouse check)
```

**Prevention**: Every criterion must answer: "How do we measure this objectively?"

---

### 🚫 Technology-Specific Success Criteria

**Impact**: Couples spec to implementation details, reduces flexibility

**Bad examples**:
```markdown
❌ React components render efficiently
❌ Redis cache hit rate >80%
❌ PostgreSQL queries use proper indexes
```

**Good examples** (outcome-focused):
```markdown
✅ Page load time <1.5s (First Contentful Paint)
✅ 95% of user searches return results in <1 second
✅ Database queries complete in <100ms average
```

**Prevention**: Focus on user-facing outcomes, not implementation mechanisms.

---

## Best Practices

### ✅ Informed Guess Strategy

**When to use**:
- Non-critical technical decisions
- Industry standards exist
- Default won't impact scope or security

**When NOT to use**:
- Scope-defining decisions
- Security/privacy critical choices
- No reasonable default exists

**Approach**:
1. Check if decision has reasonable default (see [reference.md](reference.md#informed-guess-heuristics))
2. Document assumption clearly in spec
3. Note that user can override if needed

**Example**:
```markdown
## Performance Targets (Assumed)
- API response time: <500ms (95th percentile)
- Frontend FCP: <1.5s
- Database queries: <100ms

**Assumptions**:
- Standard web app performance expectations applied
- If requirements differ, specify in "Performance Requirements" section
```

**Result**: Reduces clarifications from 5-7 to 0-2, saves ~10 minutes

---

### ✅ Roadmap Integration

**When to use**:
- Feature name matches roadmap entry
- Roadmap uses consistent slug format

**Approach**:
1. Normalize user input to slug format
2. Search roadmap for exact match
3. If found: Extract requirements, area, role, impact/effort
4. Move to "In Progress" section automatically
5. Add branch and spec links

**Result**: Saves ~10 minutes, requirements already vetted, automatic status tracking

---

### ✅ Classification Decision Tree

**Best practice**: Follow decision tree systematically (see [reference.md](reference.md#classification-decision-tree))

**Process**:
1. Check UI keywords → Set HAS_UI (but verify no backend-only exclusions)
2. Check improvement keywords + baseline → Set IS_IMPROVEMENT
3. Check metrics keywords → Set HAS_METRICS
4. Check deployment keywords → Set HAS_DEPLOYMENT_IMPACT

**Result**: 90%+ classification accuracy, correct artifacts generated

---

## Phase Checklist

**Pre-phase checks**:
- [ ] Git working tree clean
- [ ] Not on main branch
- [ ] Required templates exist (`.spec-flow/templates/`)

**During phase**:
- [ ] Slug normalized (no filler words, lowercase kebab-case)
- [ ] Roadmap checked for existing entry
- [ ] Classification flags validated (no conflicting keywords)
- [ ] Research depth appropriate for complexity (FLAG_COUNT-based)
- [ ] Clarifications ≤3 (use informed guesses for rest)
- [ ] Success criteria measurable and quantifiable
- [ ] Assumptions documented clearly

**Post-phase validation**:
- [ ] Requirements checklist complete (if exists)
- [ ] spec.md committed with proper message
- [ ] NOTES.md initialized
- [ ] Roadmap updated (if FROM_ROADMAP=true)
- [ ] visuals/ created (if HAS_UI=true)
- [ ] workflow-state.yaml initialized

---

## Quality Standards

**Specification quality targets**:
- Clarifications: ≤3 per spec
- Classification accuracy: ≥90%
- Success criteria: 100% measurable
- Time to spec: ≤15 minutes
- Rework rate: <5%

**What makes a good spec**:
- Clear scope boundaries (what's in, what's out)
- Measurable success criteria (with measurement methods)
- Reasonable assumptions documented
- Minimal clarifications (only critical scope/security)
- Correct classification (matches feature intent)
- Context reuse (from roadmap when available)

**What makes a bad spec**:
- >5 clarifications (over-clarifying technical defaults)
- Vague success criteria ("works correctly", "is fast")
- Technology-specific criteria (couples to implementation)
- Wrong classification (UI flag for backend-only)
- Missing roadmap integration (duplicates planning work)

---

## Completion Criteria

**Phase is complete when**:
- [ ] All pre-phase checks passed
- [ ] All execution steps completed
- [ ] All post-phase validations passed
- [ ] Spec committed to git
- [ ] workflow-state.yaml shows `currentPhase: specification` and `status: completed`

**Ready to proceed to next phase** (`/clarify` or `/plan`):
- [ ] If clarifications >0 → Run `/clarify`
- [ ] If clarifications = 0 → Run `/plan`

---

## Troubleshooting

**Issue**: Too many clarifications (>3)
**Solution**: Review [reference.md](reference.md#informed-guess-heuristics) for defaults, convert non-critical questions to assumptions

**Issue**: Classification seems wrong
**Solution**: Re-check decision tree, verify no backend-only keywords for HAS_UI=true

**Issue**: Roadmap entry exists but wasn't matched
**Solution**: Check slug normalization, offer fuzzy matches, update roadmap slug format

**Issue**: Success criteria are vague
**Solution**: Add quantifiable metrics and measurement methods (see examples above)

---

_This SOP guides the specification phase. Refer to reference.md for technical details and examples.md for real-world patterns._
