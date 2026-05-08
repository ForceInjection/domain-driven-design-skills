---
name: phase-planning
description: |
  Generate 5-phase implementation plan with validation gates and resource allocation. Adapts
  phase count and timeline based on complexity score. Includes validation gates between phases.
  Use when: planning implementation, need structured timeline, want validation checkpoints.

skill-type: PROTOCOL
shannon-version: ">=4.0.0"

mcp-requirements:
  required:
    - name: serena
      purpose: Phase storage and retrieval

allowed-tools: Read, Serena
---

# Phase Planning Skill

## Overview

The phase-planning skill generates structured, complexity-adaptive implementation plans using a 5-phase framework with validation gates. It adapts phase count and timeline distribution based on project complexity, ensuring appropriate rigor for simple scripts through critical systems.

## When to Use

Use this skill when:
- Planning implementation after spec analysis complete
- Need structured timeline with validation checkpoints
- Want systematic progression with quality gates
- Require resource allocation and effort distribution
- Have complexity score from spec-analysis (0.0-1.0)

DO NOT use when:
- No spec analysis available (run @spec-analysis first)
- Ad-hoc tasks without formal planning needs
- Quick experiments or prototypes

## Core Competencies

1. **Complexity-Adaptive Planning**: Automatically adjusts phase count (3-6 phases) based on complexity score, ensuring appropriate rigor without over-engineering
2. **Timeline Distribution**: Calculates optimal time allocation per phase using algorithmic formula with complexity and domain-based adjustments
3. **Validation Gates**: Defines explicit success criteria between phases to prevent downstream failures and ensure quality progression
4. **Wave Coordination**: Maps parallel execution patterns to phases for multi-agent coordination when complexity >=0.5
5. **Serena Integration**: Persists phase plans to memory for cross-session retrieval and wave agent coordination

## Inputs

**Required:**
- `complexity_score` (float 0.0-1.0): Complexity score from spec-analysis
- `spec_analysis_result` (object): Complete spec analysis including domain breakdown, features, timeline constraints
- `project_name` (string): Name of project for phase plan identification

**Optional:**
- `timeline_constraint` (string): Total available timeline (e.g., "40 hours", "2 weeks")
- `domain_preferences` (object): Override domain-based timeline adjustments
- `custom_phases` (array): Custom phase definitions for non-standard workflows

---

## Anti-Rationalization (From Baseline Testing)

**CRITICAL**: Agents systematically rationalize skipping or adjusting phase planning patterns. Below are the 4 most common rationalizations detected in baseline testing, with mandatory counters.

### Rationalization 1: "Let's skip to waves, phases are redundant"
**Example**: User says "Let's create the wave execution plan" → Agent responds "That wave structure looks reasonable..." and skips phase planning entirely

**COUNTER**:
- ❌ **NEVER** skip phase planning when user jumps to waves
- ✅ Phases structure work; waves coordinate agents
- ✅ Phases MUST come before waves (phases define WHAT, waves define WHO)
- ✅ If user suggests waves first, respond: "First we need phase planning to structure the work, THEN we can create waves"

**Rule**: Phases always precede waves. No exceptions.

### Rationalization 2: "3 phases work for everything, keep it simple"
**Example**: User says "Let's use Setup-Build-Deploy for this 0.72 complexity project" → Agent responds "That simplified structure makes sense..."

**COUNTER**:
- ❌ **NEVER** accept 3-phase template for complex projects
- ✅ Complexity score determines phase count (algorithm, not preference)
- ✅ 0.70-0.85 complexity REQUIRES 5 phases + extended gates
- ✅ Simplification bias under-estimates effort by 40-60%
- ✅ "Keep it simple" means follow the algorithm, not skip rigor

**Rule**: Apply complexity-based adaptation. Simple ≠ fewer phases for complex work.

### Rationalization 3: "Validation gates are overhead, team will coordinate naturally"
**Example**: User says "We don't need formal gates" → Agent creates phases without validation criteria

**COUNTER**:
- ❌ **NEVER** omit validation gates to reduce "overhead"
- ✅ Gates prevent downstream failures (catch issues early)
- ✅ "Natural coordination" = unvalidated assumptions = technical debt
- ✅ Gates take 5-10 minutes to define, prevent hours of rework
- ✅ Every phase transition MUST have explicit success criteria

**Rule**: Every phase MUST have validation gate. Not optional.

### Rationalization 4: "Timeline percentages feel wrong, adjust them"
**Example**: User says "20% for setup feels too long" → Agent adjusts to 5% based on intuition

**COUNTER**:
- ❌ **NEVER** adjust timeline distribution based on "feeling"
- ✅ Percentages are algorithmic (complexity + domain adjustments)
- ✅ If percentages feel wrong, the algorithm is right
- ✅ "Feels too long" often means under-estimating hidden complexity
- ✅ Only recalculate if you find FORMULA ERROR (wrong calculation, wrong weights)

**Rule**: Follow timeline distribution formula. Intuition doesn't override math.

### Detection Signal
**If you're tempted to**:
- Skip phases and go to waves
- Use 3 phases regardless of complexity
- Omit validation gates
- Adjust timeline percentages subjectively

**Then you are rationalizing.** Stop. Follow the protocol. Apply the algorithm.

---

## Core Algorithm

### 5-Phase Framework

```
Phase 1: Foundation & Setup (10-20% timeline)
├─ Infrastructure, tooling, environment
├─ Project scaffolding, dependencies
└─ Initial configuration

Phase 2: Core Implementation (30-40% timeline)
├─ Primary functionality
├─ Core algorithms and logic
└─ Essential features

Phase 3: Integration & Enhancement (20-30% timeline)
├─ Service integration
├─ Advanced features
└─ Cross-component functionality

Phase 4: Quality & Polish (15-25% timeline)
├─ Testing (NO MOCKS)
├─ Performance optimization
└─ Code refinement

Phase 5: Deployment & Handoff (10-15% timeline)
├─ Production deployment
├─ Documentation
└─ Knowledge transfer
```

### Complexity-Based Adaptation

**Simple (0.00-0.30)**: 3 phases
```
Phase 1: Setup & Core (30%)
Phase 2: Features & Testing (50%)
Phase 3: Deploy (20%)
```

**Moderate (0.30-0.50)**: 3-4 phases
```
Phase 1: Setup (20%)
Phase 2: Implementation (45%)
Phase 3: Testing (25%)
Phase 4: Deploy (10%)
```

**Complex (0.50-0.70)**: 5 phases (standard)
```
All 5 phases with standard distribution
```

**High (0.70-0.85)**: 5 phases + extended
```
All 5 phases + extended validation gates
+ Risk mitigation checkpoints
+ Progress review gates
```

**Critical (0.85-1.00)**: 5 phases + risk mitigation
```
All 5 phases + risk mitigation phases
+ Extensive validation gates
+ Architecture review gates
+ Security review gates
+ Performance validation gates
```

## Workflow

### Phase 1: Context Loading

1. **Retrieve Spec Analysis**
   - Action: Read from Serena memory or specification document
   - Tool: `read_memory("spec_analysis")` or Read
   - Output: Complexity score, domain breakdown, total timeline

2. **Extract Key Parameters**
   - Action: Parse complexity score, domain percentages, timeline constraints
   - Validation: Verify complexity score is 0.0-1.0, domains sum to 100%
   - Output: Validated input parameters

### Phase 2: Phase Structure Determination

1. **Calculate Phase Count**
   - Action: Apply complexity-based algorithm to determine 3-6 phases
   - Tool: Python calculation or algorithmic decision tree
   - Output: Integer phase count (3-6)

2. **Select Phase Pattern**
   - Action: Choose phase template based on complexity band
   - Validation: Verify pattern matches complexity requirements
   - Output: Phase structure (Simple/Moderate/Complex/High/Critical)

### Phase 3: Timeline Distribution

1. **Calculate Base Percentages**
   - Action: Apply standard 5-phase distribution (15%, 35%, 25%, 20%, 5%)
   - Tool: Mathematical calculation
   - Output: Base timeline percentages

2. **Apply Complexity Adjustments**
   - Action: Adjust percentages based on complexity score
   - Formula: Simple (+5% setup), Complex (+5% planning, -5% impl), High (+10% planning), Critical (+15% planning)
   - Output: Complexity-adjusted percentages

3. **Apply Domain Adjustments**
   - Action: Adjust based on dominant domains (Frontend-heavy, Backend-heavy, Database-heavy)
   - Formula: Frontend >50% (+5% Phase 2, +5% Phase 4, -10% Phase 5)
   - Output: Final timeline distribution summing to 100%

### Phase 4: Validation Gate Definition

1. **Define Per-Phase Criteria**
   - Action: Specify success criteria for each phase transition
   - Tool: Template-based generation with domain customization
   - Output: Validation checklist per phase

2. **Verification Method**
   - Action: Define how to verify each criterion
   - Output: Verification procedures (tests, reviews, checks)

### Phase 5: Wave Mapping (if complexity >=0.5)

1. **Determine Parallelization Pattern**
   - Action: Identify which phases can use parallel wave execution
   - Trigger: Multiple domains >=30%, complexity >=0.5
   - Output: Wave pattern (Two Parallel + Integration or Three Parallel + Integration)

2. **Map Waves to Phases**
   - Action: Assign domain-specific agents to parallel waves
   - Output: Wave execution plan for Phase 2/3

### Phase 6: Document Generation & Storage

1. **Generate Phase Plan Document**
   - Action: Populate template with calculated values
   - Tool: Write Markdown structure
   - Output: Complete phase plan in Markdown format

2. **Store in Serena Memory**
   - Action: Persist to Serena for cross-session retrieval
   - Tool: `write_memory("phase_plan", plan_object)`
   - Output: Memory storage confirmation

## Implementation Protocol

### Step 1: Load Context

```
REQUIRED INPUTS:
1. read_memory("spec_analysis") - Get complexity score
2. read_memory("8d_assessment") - Get domain breakdown
3. Current specification document
4. Project timeline constraints

EXTRACT:
- Complexity score: [0.0-1.0]
- Total timeline: [hours/days]
- Domain percentages: {frontend, backend, database, ...}
- Critical requirements: [list]
```

### Step 2: Determine Phase Structure

```python
def determine_phase_count(complexity: float) -> int:
    if complexity < 0.30:
        return 3  # Simple
    elif complexity < 0.50:
        return 4  # Moderate (3-4 flexible)
    elif complexity < 0.70:
        return 5  # Complex
    elif complexity < 0.85:
        return 5  # High (+ extended gates)
    else:
        return 6  # Critical (+ risk mitigation)
```

### Step 3: Calculate Timeline Distribution

**Standard 5-Phase Distribution**:
```
Phase 1: 15% (10-20% range)
Phase 2: 35% (30-40% range)
Phase 3: 25% (20-30% range)
Phase 4: 20% (15-25% range)
Phase 5: 5% (10-15% range)
```

**Complexity Adjustments**:
```
Simple (0.00-0.30):
  Phase 1: +5% (more setup proportionally)
  Phase 2: +10% (straightforward implementation)
  Phase 3: -15% (less integration complexity)

Complex (0.50-0.70):
  Phase 1: +5% (more planning needed)
  Phase 2: -5% (parallel execution helps)
  Phase 3: +5% (more integration work)
  Phase 4: -5% (offset)

High (0.70-0.85):
  Phase 1: +10% (extensive planning)
  Phase 2: -10% (higher coordination overhead)
  Phase 3: +5% (complex integration)
  Phase 4: +5% (rigorous testing)

Critical (0.85-1.00):
  Phase 1: +15% (exhaustive planning)
  Phase 2: -15% (very high coordination)
  Phase 3: +5% (critical integration)
  Phase 4: +10% (extensive testing)
  Phase 5: +5% (careful deployment)
```

**Domain-Based Adjustments**:
```
If Frontend-Heavy (>50%):
  Phase 2: +5% (UI work time-consuming)
  Phase 4: +5% (E2E testing)
  Phase 5: -10% (static hosting simpler)

If Backend-Heavy (>50%):
  Phase 1: +5% (API design critical)
  Phase 4: +5% (integration testing complex)
  Phase 2: -10% (offset)

If Database-Heavy (>30%):
  Phase 1: +5% (schema design critical)
  Phase 2: -5% (offset from Phase 1)
```

### Step 4: Define Validation Gates

**Phase 1 → Phase 2 Gate**:
```
Criteria:
☐ Requirements fully documented
☐ Technical approach confirmed
☐ All dependencies identified
☐ Environment setup complete
☐ No blocking unknowns

Verification:
- Review requirements.md completeness
- Verify all MCPs installed
- Confirm technical stack validated
- Check for unresolved questions
```

**Phase 2 → Phase 3 Gate**:
```
Criteria:
☐ Core functionality complete
☐ Unit tests passing
☐ Code review completed
☐ Performance acceptable
☐ No critical bugs

Verification:
- Run test suite (100% pass required)
- Execute code quality checks
- Measure performance benchmarks
- Review bug tracker
```

**Phase 3 → Phase 4 Gate**:
```
Criteria:
☐ All integrations working
☐ Advanced features complete
☐ Integration tests passing
☐ API contracts validated
☐ Cross-component flows verified

Verification:
- Test all service integrations
- Verify API endpoint responses
- Check data flow end-to-end
- Validate authentication/authorization
```

**Phase 4 → Phase 5 Gate**:
```
Criteria:
☐ All tests passing (NO MOCKS)
☐ Code coverage >= 80%
☐ Performance optimized
☐ Documentation complete
☐ Security audit passed

Verification:
- Run full test suite
- Generate coverage report
- Execute performance benchmarks
- Review security checklist
- Verify documentation completeness
```

**Phase 5 → Complete Gate**:
```
Criteria:
☐ Deployed to staging
☐ Smoke tests passing
☐ Deployment docs complete
☐ Handoff checklist complete
☐ Production-ready

Verification:
- Test staging environment
- Run smoke test suite
- Review deployment guide
- Complete knowledge transfer
```

### Step 5: Create Wave Mapping (Phase 3)

**Determine Parallelization**:
```
IF complexity >= 0.5 AND multiple domains >= 30% THEN:
  Use parallel wave execution

Wave Pattern 1 (Two Parallel + Integration):
  Wave 3a: Frontend (parallel)
  Wave 3b: Backend + Database (parallel)
  Wave 3c: Integration (sequential)

Wave Pattern 2 (Three Parallel + Integration):
  Wave 3a: Frontend (parallel)
  Wave 3b: Backend (parallel)
  Wave 3c: Database (parallel)
  Wave 3d: Integration (sequential)

Wave Pattern 3 (Sequential):
  Wave 3a: All implementation (sequential)
```

### Step 6: Generate Phase Plan Document

**Output Structure**:
```markdown
# Implementation Plan: [Project Name]

## Executive Summary
- Complexity Score: [0.0-1.0]
- Phase Count: [3-6]
- Total Timeline: [X hours/days]
- Parallelization: [Yes/No]

## Phase Breakdown

### Phase 1: Foundation & Setup ([X%] - [Y hours])
**Objectives**:
- [Objective 1]
- [Objective 2]

**Key Activities**:
1. [Activity 1] (Z% of phase)
2. [Activity 2] (W% of phase)

**Deliverables**:
- [Deliverable 1]
- [Deliverable 2]

**Validation Gate**:
☐ Criteria 1
☐ Criteria 2

**Estimated Duration**: [X hours]

[Repeat for all phases...]

## Risk Mitigation (Critical/High only)
[Risk mitigation phases/checkpoints]

## Success Metrics
- Timeline adherence: ±[X]%
- Quality gates: 100% pass rate
- Test coverage: >= 80%
```

### Step 7: Store in Serena Memory

```
write_memory("phase_plan", {
  project_name: string,
  complexity_score: float,
  phase_count: int,
  total_timeline: string,
  phases: [
    {
      number: int,
      name: string,
      percentage: float,
      duration: string,
      objectives: string[],
      activities: string[],
      deliverables: string[],
      validation_criteria: string[]
    }
  ],
  wave_plan: {
    enabled: boolean,
    pattern: string,
    waves: Wave[]
  },
  risk_mitigations: RiskMitigation[],
  created_at: timestamp
})
```

## Outputs

Structured output object:

```json
{
  "project_name": "string",
  "complexity_score": "float (0.0-1.0)",
  "phase_count": "int (3-6)",
  "total_timeline": "string (e.g., '40 hours', '2 weeks')",
  "interpretation_band": "Simple | Moderate | Complex | High | Critical",
  "phases": [
    {
      "number": "int",
      "name": "string",
      "percentage": "float (sums to 100%)",
      "duration": "string",
      "objectives": ["objective1", "objective2"],
      "activities": ["activity1", "activity2"],
      "deliverables": ["deliverable1", "deliverable2"],
      "validation_criteria": ["criterion1", "criterion2"]
    }
  ],
  "wave_plan": {
    "enabled": "boolean",
    "pattern": "Sequential | TwoParallel | ThreeParallel",
    "waves": [
      {
        "wave_id": "string",
        "phase": "int",
        "agents": ["agent1", "agent2"],
        "execution": "parallel | sequential"
      }
    ]
  },
  "domain_adjustments": {
    "frontend_adjustment": "string",
    "backend_adjustment": "string",
    "database_adjustment": "string"
  },
  "created_at": "ISO timestamp"
}
```

**Markdown Document**: Complete phase plan document saved to:
- Serena memory: `phase_plan_{project_name}`
- Local file: `PHASE_PLAN.md` (optional)

## Success Criteria

This skill succeeds if:

1. ✅ **Phase count is algorithmically correct**
   - Complexity 0.00-0.30 → 3 phases
   - Complexity 0.30-0.50 → 3-4 phases
   - Complexity 0.50-0.70 → 5 phases
   - Complexity 0.70-0.85 → 5 phases + extended gates
   - Complexity 0.85-1.00 → 5-6 phases + risk mitigation

2. ✅ **Timeline percentages sum to exactly 100%**
   - No rounding errors
   - All adjustments accounted for
   - Distribution makes logical sense

3. ✅ **Every phase has validation gate with >=3 criteria**
   - Clear success metrics
   - Measurable outcomes
   - Verification method defined

4. ✅ **Wave plan is correct for complexity >=0.5 AND multiple domains >=30%**
   - Parallel waves only when justified
   - Sequential integration phase included
   - Domain-specific agent assignments

5. ✅ **Plan is stored in Serena memory**
   - Memory key: `phase_plan_{project_name}`
   - Retrievable via `read_memory()`
   - Contains complete phase structure

Validation:
```python
def validate_phase_plan(plan):
    # Verify phase count algorithm
    if plan.complexity_score < 0.30:
        assert plan.phase_count == 3
    elif plan.complexity_score < 0.50:
        assert plan.phase_count in [3, 4]
    elif plan.complexity_score < 0.70:
        assert plan.phase_count == 5
    elif plan.complexity_score < 0.85:
        assert plan.phase_count == 5
    else:
        assert plan.phase_count in [5, 6]

    # Verify timeline percentages
    total_percentage = sum(phase.percentage for phase in plan.phases)
    assert abs(total_percentage - 100.0) < 0.01, "Timeline must sum to 100%"

    # Verify validation gates
    for phase in plan.phases:
        assert len(phase.validation_criteria) >= 3, "Each phase needs >=3 validation criteria"

    # Verify wave plan logic
    if plan.complexity_score >= 0.5:
        multi_domain = sum(1 for d in plan.domain_percentages.values() if d >= 30) >= 2
        if multi_domain:
            assert plan.wave_plan.enabled, "Wave plan required for complex multi-domain projects"

    # Verify Serena storage
    assert serena.memory_exists(f"phase_plan_{plan.project_name}"), "Plan must be stored in Serena"
```

## Examples

### Example 1: Simple Project (Complexity 0.25)

**Input**:
```
Complexity: 0.25
Timeline: 8 hours
Domains: Backend 70%, Frontend 30%
```

**Output**:
```
3-Phase Plan:

Phase 1: Setup & Core (30% - 2.4h)
- Project scaffolding
- Backend API implementation
- Basic frontend

Phase 2: Features & Testing (50% - 4h)
- Feature completion
- Integration
- Testing (NO MOCKS)

Phase 3: Deploy (20% - 1.6h)
- Deployment
- Documentation
```

### Example 2: Complex Project (Complexity 0.65)

**Input**:
```
Complexity: 0.65
Timeline: 40 hours
Domains: Frontend 45%, Backend 35%, Database 20%
```

**Output**:
```
5-Phase Plan:

Phase 1: Foundation (20% - 8h)
- Environment setup
- Database schema design
- API contract definition

Phase 2: Core Implementation (35% - 14h)
Wave 2a: Frontend (parallel)
Wave 2b: Backend + DB (parallel)
Wave 2c: Integration (sequential)

Phase 3: Integration (25% - 10h)
- Service integration
- Advanced features
- Cross-component flows

Phase 4: Quality (15% - 6h)
- Comprehensive testing
- Performance optimization
- Code refinement

Phase 5: Deployment (5% - 2h)
- Staging deployment
- Documentation
- Handoff
```

### Example 3: Critical Project (Complexity 0.92)

**Input**:
```
Complexity: 0.92
Timeline: 80 hours
Domains: Frontend 30%, Backend 40%, Database 20%, Security 10%
```

**Output**:
```
6-Phase Plan (5 + Risk Mitigation):

Phase 1: Foundation (25% - 20h)
- Extensive requirements analysis
- Architecture review
- Security planning
- Environment setup

Phase 2: Core Implementation (25% - 20h)
Wave 2a: Frontend (parallel)
Wave 2b: Backend (parallel)
Wave 2c: Database (parallel)
Wave 2d: Integration (sequential)

Phase 3: Integration (20% - 16h)
- Complex service integration
- Security implementation
- Advanced features

Phase 4: Quality (20% - 16h)
- Extensive testing (NO MOCKS)
- Security audit
- Performance testing
- Load testing

Phase 5: Risk Mitigation (5% - 4h)
- Vulnerability scanning
- Penetration testing
- Disaster recovery testing
- Compliance verification

Phase 6: Deployment (5% - 4h)
- Staged rollout
- Monitoring setup
- Comprehensive documentation
- Knowledge transfer
```

## Validation Checklist

Before finalizing phase plan:

**Completeness**:
☐ All phases have clear objectives
☐ Timeline distribution sums to 100%
☐ Each phase has validation criteria
☐ Deliverables clearly defined
☐ Wave execution plan (if applicable)

**Feasibility**:
☐ Timeline matches project constraints
☐ Resource allocation realistic
☐ Dependencies properly sequenced
☐ Parallel work properly identified
☐ Risk mitigations adequate

**Integration**:
☐ Compatible with spec analysis
☐ Aligns with 8D assessment
☐ Matches complexity score
☐ Wave plan matches domain breakdown
☐ Stored in Serena memory

## Integration Points

### With Other Skills

**spec-analysis** → **phase-planning**:
```
Input: Complexity score, domain breakdown
Usage: Determines phase count and distribution
```

**phase-planning** → **wave-orchestration**:
```
Output: Wave execution plan for Phase 2/3
Usage: Parallel execution coordination
```

**phase-planning** → **context-preservation**:
```
Action: Store phase plan in Serena
Usage: Cross-session persistence
```

### With Core Patterns

**PHASE_PLANNING.md**:
```
Reference: Detailed 5-phase framework
Usage: Complete methodology and examples
```

**WAVE_ORCHESTRATION.md**:
```
Coordination: Wave execution within phases
Usage: Parallel implementation patterns
```

**TESTING_PHILOSOPHY.md**:
```
Constraint: NO MOCKS in Phase 4
Usage: Test planning requirements
```

## Common Patterns

### Pattern 1: Simple Script

```
Complexity: < 0.3
Phases: 3
Wave: Sequential
Timeline: < 1 day

Focus: Rapid iteration, minimal overhead
```

### Pattern 2: Standard Application

```
Complexity: 0.3-0.7
Phases: 4-5
Wave: Parallel (Frontend/Backend)
Timeline: 1-5 days

Focus: Structured progression, quality gates
```

### Pattern 3: Critical System

```
Complexity: > 0.85
Phases: 5-6
Wave: Parallel + Sequential integration
Timeline: > 5 days

Focus: Rigorous validation, risk mitigation
```

## Anti-Patterns to Avoid

❌ **Phase Skipping**: Never skip validation gates
❌ **Premature Optimization**: Don't over-engineer simple projects
❌ **Under-Planning**: Don't under-estimate critical systems
❌ **Ignoring Complexity**: Always use complexity score
❌ **Fixed Templates**: Always adapt to project needs

## Performance Benchmarks

**Expected Performance** (measured on Claude Sonnet 3.5):

| Complexity | Phase Count | Planning Time | Adjustment Calculations | Total Time |
|------------|-------------|---------------|-------------------------|------------|
| 0.00-0.30 (Simple) | 3 phases | 2-4 minutes | 1 adjustment | 3-5 min |
| 0.30-0.50 (Moderate) | 3-4 phases | 4-6 minutes | 2 adjustments | 5-8 min |
| 0.50-0.70 (Complex) | 5 phases | 6-10 minutes | 3 adjustments + wave plan | 10-15 min |
| 0.70-0.85 (High) | 5 phases + gates | 10-15 minutes | 4 adjustments + risk | 15-20 min |
| 0.85-1.00 (Critical) | 5-6 phases + risk | 15-25 minutes | 5+ adjustments + extensive risk | 25-35 min |

**Performance Indicators**:
- ✅ **Fast**: <10 minutes for typical projects (complexity <0.60)
- ⚠️ **Acceptable**: 10-20 minutes for complex projects (0.60-0.85)
- 🔴 **Slow**: >25 minutes (check: is complexity >0.85? Are extensive risk mitigations needed?)

**Quality Validation**:
- Timeline percentages sum to exactly 100.0% (±0.01% tolerance)
- Each phase has >=3 validation criteria
- Wave plan enabled for complexity >=0.50 AND multiple domains >=30%

---

## Complete Execution Walkthrough

**Scenario**: Generate phase plan for a moderate complexity full-stack project

**Input**:
```json
{
  "spec_analysis": {
    "complexity_score": 0.48,
    "interpretation": "Moderate",
    "domain_percentages": {
      "Frontend": 45,
      "Backend": 35,
      "Database": 20
    },
    "timeline_estimate": "32 hours"
  },
  "project_name": "customer_portal"
}
```

**Execution Process** (showing actual calculations):

### **Step 1: Load Context**

```
Inputs loaded:
- Complexity: 0.48 (MODERATE)
- Timeline: 32 hours
- Domains: Frontend 45%, Backend 35%, Database 20%
- Project: customer_portal
```

### **Step 2: Determine Phase Count**

```python
complexity = 0.48

if complexity < 0.30:
    phase_count = 3  # Simple
elif complexity < 0.50:  # ← MATCHES (0.48 < 0.50)
    phase_count = 4  # Moderate (flexible 3-4, using 4 for better structure)
elif complexity < 0.70:
    phase_count = 5  # Complex
# ...

Result: phase_count = 4
```

### **Step 3: Calculate Timeline Distribution**

**Step 3a: Start with base percentages (4-phase template for Moderate)**
```
Base 4-Phase Distribution:
Phase 1 (Setup):          20%
Phase 2 (Implementation): 45%
Phase 3 (Testing):        25%
Phase 4 (Deploy):         10%
Total:                    100% ✅
```

**Step 3b: Apply Complexity Adjustments (Moderate: 0.30-0.50)**
```
Moderate adjustments (lines 315-319 don't apply to Moderate, so no complexity adjustments)

After complexity adjustments:
Phase 1: 20% (no change)
Phase 2: 45% (no change)
Phase 3: 25% (no change)
Phase 4: 10% (no change)
Total: 100% ✅
```

**Step 3c: Apply Domain Adjustments (Frontend-Heavy: 45% < 50%, so no domain-heavy adjustments)**
```
No domain adjustments apply (Frontend 45% < 50% threshold, Backend 35% < 50%, Database 20% < 30%)

Final percentages:
Phase 1: 20%
Phase 2: 45%
Phase 3: 25%
Phase 4: 10%
Total: 100% ✅
```

**Step 3d: Calculate Absolute Times**
```
Total timeline: 32 hours

Phase 1: 32 × 0.20 = 6.4 hours
Phase 2: 32 × 0.45 = 14.4 hours
Phase 3: 32 × 0.25 = 8.0 hours
Phase 4: 32 × 0.10 = 3.2 hours
Total: 32.0 hours ✅
```

### **Step 4: Define Validation Gates**

**Phase 1 → Phase 2 Gate** (Foundation complete):
```
Criteria:
☐ Environment setup complete (dev tools installed, repos created)
☐ Database schema designed (ERD complete, tables defined)
☐ API contracts defined (endpoints documented, request/response schemas)
☐ Technical stack validated (React/Node.js/PostgreSQL confirmed)
☐ No blocking unknowns (all tech decisions made)

Verification:
- Run: npm install && npm run dev (dev environment starts successfully)
- Check: Database schema file exists with >=5 tables defined
- Check: API specification document complete (all endpoints documented)
```

**Phase 2 → Phase 3 Gate** (Implementation complete):
```
Criteria:
☐ All core features implemented (customer login, data display, CRUD operations)
☐ Frontend components functional (all UI screens render correctly)
☐ Backend endpoints operational (all API routes return 200/201 on valid requests)
☐ Database migrations applied (all tables created, seed data loaded)
☐ No critical bugs (application runs without crashes)

Verification:
- Run: npm test (all unit tests passing)
- Check: Manual testing of each feature (login → view data → create record → success)
- Check: Database query test (SELECT * FROM customers returns results)
```

**Phase 3 → Phase 4 Gate** (Testing complete):
```
Criteria:
☐ All functional tests passing (Puppeteer tests for Frontend, real HTTP for Backend, real DB)
☐ Integration tests passing (Frontend ↔ Backend ↔ Database flows validated)
☐ NO MOCKS compliance verified (all tests use real browser, real HTTP, real database)
☐ Test coverage >= 80% (code coverage report generated)
☐ Performance acceptable (page loads <2s, API responds <500ms)

Verification:
- Run: npm run test:functional (all Puppeteer tests pass)
- Run: npm run test:integration (all service integration tests pass)
- Check: No mock libraries in dependencies (verify package.json)
- Run: npm run coverage (verify >=80%)
```

**Phase 4 → Complete Gate** (Deployment ready):
```
Criteria:
☐ Deployed to staging environment (accessible URL, application loads)
☐ Smoke tests passing (critical user flows work on staging)
☐ Documentation complete (README, API docs, deployment guide)
☐ Deployment runbook validated (tested deployment process from scratch)
☐ Production-ready (security review passed, performance validated)

Verification:
- Access: https://staging.customer-portal.com (loads successfully)
- Run: smoke test suite on staging (all critical flows pass)
- Check: docs/ directory has README.md, API.md, DEPLOY.md
- Test: Follow deployment runbook on clean environment (succeeds)
```

### **Step 5: Create Wave Mapping**

```python
# Check wave plan requirements
complexity >= 0.5?  # 0.48 < 0.5 → NO
multi_domain = count(d for d in domains if d >= 30)  # Frontend 45%, Backend 35% → 2 domains
multi_domain >= 2?  # YES

# Decision: Optional wave plan (not mandatory for 0.48, but beneficial for 2 domains >=30%)

# Since complexity < 0.50, wave plan is OPTIONAL
# For this example, we'll use sequential execution
wave_plan = {
  "enabled": False,
  "pattern": "Sequential",
  "rationale": "Complexity 0.48 < 0.50 threshold for mandatory waves"
}
```

### **Step 6: Generate Phase Plan Document**

```markdown
# Implementation Plan: Customer Portal

## Executive Summary
- **Complexity Score**: 0.48 / 1.0 (MODERATE)
- **Phase Count**: 4 phases
- **Total Timeline**: 32 hours (2-3 days)
- **Parallelization**: Sequential (complexity < 0.50)

## Phase Breakdown

### Phase 1: Foundation & Setup (20% - 6.4 hours)
**Objectives**:
- Environment configuration
- Database schema design
- API contract definition

**Key Activities**:
1. Set up development environment (30%)
2. Design database schema (40%)
3. Define API contracts (30%)

**Deliverables**:
- Development environment running
- Database ERD and schema file
- API specification document

**Validation Gate**:
☐ Environment setup complete
☐ Database schema designed
☐ API contracts defined
☐ Technical stack validated
☐ No blocking unknowns

**Estimated Duration**: 6.4 hours

### Phase 2: Implementation (45% - 14.4 hours)
[Similar structure for Phases 2-4...]
```

### **Step 7: Store in Serena Memory**

```javascript
write_memory("phase_plan_customer_portal", {
  project_name: "customer_portal",
  complexity_score: 0.48,
  phase_count: 4,
  total_timeline: "32 hours",
  interpretation_band: "Moderate",
  phases: [
    {number: 1, name: "Foundation & Setup", percentage: 20, duration: "6.4 hours", ...},
    {number: 2, name: "Implementation", percentage: 45, duration: "14.4 hours", ...},
    {number: 3, name: "Testing", percentage: 25, duration: "8.0 hours", ...},
    {number: 4, name: "Deployment", percentage: 10, duration: "3.2 hours", ...}
  ],
  wave_plan: {enabled: false, pattern: "Sequential"},
  created_at: "2025-11-08T20:15:00Z"
})

// Verify
const verify = read_memory("phase_plan_customer_portal")
if (!verify) throw Error("Serena save failed")
```

### **Validation**

```
✅ Phase count: 4 (correct for complexity 0.48 ∈ [0.30, 0.50])
✅ Timeline percentages: 20 + 45 + 25 + 10 = 100%
✅ Each phase has >=3 validation criteria (5, 5, 5, 5 respectively)
✅ Wave plan logic: Enabled=false (correct for 0.48 < 0.50)
✅ Serena storage: phase_plan_customer_portal saved

Quality Score: 1.0 (5/5 checks passed)
```

---

This walkthrough demonstrates the complete phase planning process, showing:
1. How to determine phase count from complexity
2. How to calculate timeline distribution with adjustments
3. How percentage adjustments work (additive: 15% + 5% = 20%)
4. How to ensure percentages sum to 100%
5. When to enable wave plans (complexity >=0.50 AND multi-domain)

**Key Clarification**: All percentage adjustments are ADDITIVE (e.g., "+5%" means add 5 percentage points to the base value, not multiply). This ensures percentages always sum to 100% when adjustments are balanced.

---

## References

- **PHASE_PLANNING.md**: Complete 5-phase methodology (1562 lines)
- **5-phase-examples.md**: Detailed examples (3 scenarios)
- **phase-template.md**: Reusable phase structure
- **validation-gate.md**: Gate criteria templates

---

**Version**: 1.0.0
**Last Updated**: 2025-11-03
**Shannon Version**: 4.0.0+
