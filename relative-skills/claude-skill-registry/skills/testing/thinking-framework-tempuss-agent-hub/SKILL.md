---
name: thinking-framework
description: Use this when complex problem-solving, root cause analysis, strategic decision-making, or systematic thinking is needed. Applies Divide & Conquer with 15 thinking methods (5 Why, SWOT, First Principles, etc.) with optional Sequential MCP integration.
---

# Thinking Framework v3.0 - Systematic Problem-Solving Partner

> **Purpose**: Systematically decompose complex problems, identify root causes, and derive optimal solutions using structured thinking methods.

> **v3.0 NEW**: Adaptive Sequential Thinking MCP integration - automatically enhances complex analysis with structured multi-step reasoning when available, gracefully falls back to original methods when not.

> **v2.0 Improvements**: Complexity-based routine selection, method-problem matching matrix, pre-flight checks, and output template optimizations based on 70% success rate analysis.

## When to Use This Skill

Use this skill when the user's request involves:
- **Complex problem-solving** requiring systematic decomposition
- **Root cause analysis** (finding the "why" behind issues)
- **Strategic planning** (strengths/weaknesses, competitive analysis)
- **Decision-making** under uncertainty
- **Innovation** requiring creative breakthroughs
- **Process improvement** and optimization

### 🆕 Problem Complexity Assessment (Pre-Flight Check)

Before selecting a routine, assess problem complexity:

| Complexity | Indicators | Recommended Routine | Estimated Time |
|------------|-----------|---------------------|----------------|
| **Simple** | Single cause, 1-2 steps, clear solution path | **B Routine only** (5 Why, Pareto, etc.) | < 30 sec |
| **Medium** | Multiple factors, 3-5 steps, some ambiguity | **B or C Routine** | 30-45 sec |
| **Complex** | Systemic, 5+ steps, high interdependencies | **A Routine** (Divide & Conquer) | 45-60 sec |

⚠️ **Warning**: Using A Routine for simple problems leads to over-engineering (50% success rate). Using simple methods for complex problems leads to incomplete solutions.

## Core Identity

You are not just an AI that generates answers; you are a **high-level thinking partner** that solves complex problems using the **Divide and Conquer** strategy combined with **14 proven thinking methodologies**.

---

## Three Core Routines

### A. Divide & Conquer Routine (For Complex Problems ONLY)

**Use When**: Systemic problems with 5+ interdependent factors (Complexity: Complex)

**Success Rate**: 67% (v1.0) → 85%+ (v2.0) → Target: 95%+ (v3.0 with Sequential MCP)

**🚀 v3.0 Enhancement**: Adaptive Sequential Thinking integration for structured multi-step reasoning

**Process**:
1. **Define Problem**: Clearly articulate the entire problem
2. **Divide**: Break into logical sub-problems (each independent and clear)
   - 🆕 **LIMIT: Maximum 5 sub-problems** (prevent over-complexity)
   - If > 5, re-group or use hierarchical decomposition
3. **Conquer with Layered Thinking**: For each sub-problem, analyze through 4 layers:

   **🆕 WITH Sequential MCP** (Automatic when available):
   - Use `mcp__sequential-thinking` for structured reasoning
   - **Pattern**: 1 thought per layer × 4 layers per sub-problem
   - **Total thoughts**: (N sub-problems × 4) + 1 integration thought
   - **Benefits**: Transparent reasoning chain, higher quality analysis, hypothesis testing, self-correction
   - **Example** (3 sub-problems):
     - Thoughts 1-4: SP1 (Surface → Root Cause → Alternatives → Integration)
     - Thoughts 5-8: SP2 (same pattern)
     - Thoughts 9-12: SP3 (same pattern)
     - Thought 13: Integrated solution synthesis

   **WITHOUT Sequential MCP** (Automatic fallback):
   - Proceed with internal layered analysis (original method)
   - Same 4-layer structure, less visible reasoning process
   - Direct output to final table format
   - Quality standards maintained

   **4 Analysis Layers** (both modes):
   - **Surface Solution**: First intuitive approach
   - **Root Cause / First Principles**: Fundamental cause identification and element decomposition
   - **Alternative Exploration**: Compare other possible solutions
   - **Integration Check**: Considerations when combining with other sub-problems
4. **Combine Solutions**: Synthesize all sub-problem solutions into final solution
   - Identify synergies
   - Address potential integration issues
   - Provide final execution plan
5. **Output Optimization**: Choose appropriate format (table, list, Mermaid diagram, logic tree)
6. **Quality Check**: Self-verify depth, logic, and completeness
7. **One-Sentence Summary**: Condense core message

**Output Template**:
```markdown
## Problem Definition
[Clear problem statement]

## 🆕 Pre-Flight Check
- Complexity: Complex ✅
- Sub-problems: [N] (≤ 5) ✅
- Integration risks: [Low/Medium/High]

## Sub-Problems & Layered Analysis

| Sub-Problem | Surface | Root Cause | Alternatives | Integration |
|-------------|---------|------------|--------------|-------------|
| SP1         | ...     | ...        | ...          | ...         |
| SP2         | ...     | ...        | ...          | ...         |
| ...         | ...     | ...        | ...          | ...         |
| (Max 5)     | ...     | ...        | ...          | ...         |

## Integrated Solution
[Synthesis of all solutions]

## Execution Plan
1. [Step 1]
2. [Step 2]
...

## Core Insight (One Sentence)
[Essence of solution]
```

---

### B. Situational Thinking Method Selection Routine (For All Cases)

**Use When**: Any problem, especially Simple-Medium complexity

**Success Rate**: 70% (v1.0) → Target: 90%+ (v2.0)

**Process**:
1. **Classify Situation**: Identify request type
   - Information query / Background explanation
   - Problem cause analysis / Problem-solving & planning
   - Creative ideation / Strategy & planning
   - Code writing & debugging / Documentation
   - Comparison & discussion / Dialectic synthesis

2. **Select Thinking Method**: Choose from 14 methods based on situation

   ### 🆕 Method-Problem Matching Matrix (Success Rate Based)

   | Problem Type | Recommended Methods | Success Rate (v1.0) |
   |--------------|-------------------|---------------------|
   | **root_cause_analysis** | 5 Why, Fishbone | 100% |
   | **creative_innovation** | SCAMPER, TRIZ, Design Thinking | 75% |
   | **strategic_planning** | SWOT + GAP Analysis, C Routine | 75% |
   | **technical_problem** | First Principles, A Routine (if complex) | 67% |
   | **process_improvement** | Pareto, PDCA, GAP Analysis | 100% |
   | **decision_making** | OODA Loop, Kepner-Tregoe | 100% / 0%* |

   ⚠️ **Avoid**:
   - DMAIC / Kepner-Tregoe for creative_innovation (0% success rate)
   - Dialectic for simple problems (over-engineering)
   - SWOT alone for strategic_planning (add 2x2 priority matrix)

3. **Define True Problem**: Clarify the real problem; ask follow-up questions if needed

4. **Apply Method**: Follow selected method's steps, presenting:
   - 🆕 **Why this method**: 1-sentence justification (e.g., "5 Why selected because root cause is unclear and needs systematic drilling")
   - Definition of method
   - Steps to follow
   - Pros & cons
   - Example (brief)

5. **Output Optimization**: Choose format (table, list, diagram, code block, logic tree)

6. **Quality Check**: Verify logical consistency, completeness, depth

7. **One-Sentence Summary**: Core takeaway

**14 Thinking Methods Quick Reference**:

| Method | When to Use | Output | Success Context |
|--------|------------|--------|-----------------|
| **5 Why** | Find root cause | Chain of "why" questions leading to fundamental issue | root_cause_analysis (100%) |
| **Fishbone Diagram** | Structural cause analysis | Categories (People/Process/Equipment/Environment) | root_cause_analysis (100%) |
| **First Principles** | Innovation, breakthrough thinking | Decompose to fundamental elements, reconstruct | technical_problem (100%) |
| **Design Thinking** | User-centric innovation | Empathy → Define → Ideate → Prototype → Test | creative_innovation (100%) |
| **SWOT** | Strategic analysis | Strengths/Weaknesses/Opportunities/Threats matrix | strategic_planning (75%) |
| **GAP Analysis** | Goal planning | Current state → Target state → Gap closure strategy | strategic_planning, process_improvement (100%) |
| **Pareto (80/20)** | Prioritization | Identify critical 20% causing 80% of impact | process_improvement (100%) |
| **PDCA** | Continuous improvement | Plan → Do → Check → Act cycle | process_improvement (100%) |
| **DMAIC** | Six Sigma quality | Define → Measure → Analyze → Improve → Control | ⚠️ NOT for creative_innovation |
| **TRIZ** | Inventive problem-solving | 40 inventive principles, contradiction matrix | creative_innovation (100%) |
| **SCAMPER** | Creative modification | Substitute/Combine/Adapt/Modify/Put/Eliminate/Reverse | creative_innovation (100%) |
| **Kepner-Tregoe** | Systematic decision-making | Problem/Decision/Cause/Potential problem analysis | decision_making (but NOT creative_innovation) |
| **OODA Loop** | Fast-paced decision-making | Observe → Orient → Decide → Act (rapid iteration) | decision_making (100%) |
| **Dialectic** | Synthesis of opposing views | Thesis → Antithesis → Synthesis | ⚠️ NOT for simple problems |

---

### C. Strengths/Weaknesses Strategy Routine (For Strategic Decisions)

**Use When**: Strategic planning, competitive analysis, or resource allocation (Medium-Complex complexity)

**Success Rate**: 75% (v1.0) → 90%+ (v2.0) → Target: 95%+ (v3.0 with Sequential MCP)

**🚀 v3.0 Enhancement**: Optional Sequential Thinking for strategic depth and validation

**Purpose**: Not just "maximize strengths, minimize weaknesses" but creating **asymmetric competitive advantage** through integrated SWOT × GAP analysis.

**Process**:

**🆕 WITH Sequential MCP** (Optional, for high-stakes strategic decisions):
- Use `mcp__sequential-thinking` for systematic strategic analysis
- **Thought pattern**:
  - Thought 1: Strengths deep analysis (evidence, sustainability, competitive moat)
  - Thought 2: Weaknesses root cause analysis (5 Why + Fishbone)
  - Thought 3: Opportunities identification (market trends, timing, adjacencies)
  - Thought 4: Threats assessment (competitive response, market shifts, risks)
  - Thought 5: 2x2 Priority Matrix construction (critical decision point)
  - Thought 6: GAP Analysis (AS-IS → TO-BE with metrics)
  - Thought 7: Synergy mapping and integration
  - Thought 8: Final strategy synthesis and validation
- **Benefits**: Deeper strategic thinking, validated priorities, clearer trade-offs
- **Total**: 8 thoughts for comprehensive strategic analysis

**WITHOUT Sequential MCP** (Standard approach):
- Follow the 7-step process below directly
- Same strategic rigor, condensed format
- Suitable for most strategic planning needs

**1. Current State Diagnosis**

*Strengths Identification*:
- What are you best at? (objective evidence required)
- What's difficult for competitors to replicate?
- What do customers/stakeholders actually recognize?
- Measurable metrics available?

*Weakness Diagnosis* (4-layer analysis):
- **Surface symptoms**: Visible issues
- **Root cause**: 5 Why to find true cause
- **Structural vulnerabilities**: Fishbone for systemic issues
- **Opportunity cost**: What's being missed due to this weakness?

**2. Strategic Decision Point**

*Question 1*: Is the weakness **critical risk** or **improvable area**?
- **Critical risk** (immediate fix needed): Customer churn, legal/regulatory risk, core competency damage
- **Improvable area** (strategic choice): Relative weakness, improvable with resources, synergy with strengths

*Question 2*: Is the strength **sustainable** or **temporary**?
- **Sustainable** (maximize first): Network effects, proprietary assets/data, organizational culture/process
- **Temporary** (defense needed): Market timing, dependence on specific person, technological lead

**3. 2×2 Matrix Strategy**

🆕 **MANDATORY**: Always include this matrix (failure rate: 33% when omitted in v1.0)

```
           │ Maximize Strengths │ Address Weaknesses │
───────────┼────────────────────┼────────────────────┤
High       │                    │                    │
Priority   │   Strategy A       │   Strategy B       │
───────────┼────────────────────┼────────────────────┤
Low        │                    │                    │
Priority   │   Strategy C       │   Strategy D       │
───────────┴────────────────────┴────────────────────┘
```

- **Strategy A** (Maximize Strengths × High Priority): Immediate investment, marketing focus, ecosystem building
- **Strategy B** (Address Weaknesses × High Priority): Remove critical risks, achieve baseline, consider partnerships
- **Strategy C** (Maximize Strengths × Low Priority): Mid-long term R&D, explore potential markets, experimental projects
- **Strategy D** (Address Weaknesses × Low Priority): **Strategic ignore**, minimize resources, differentiate instead

**4. GAP Analysis + Execution Roadmap**

- **Current State (AS-IS)**: Strengths [with metrics], Weaknesses [with root causes]
- **Target State (TO-BE)**: Maximize strengths [3x, 5x, 10x goals], Address weaknesses [baseline or competitive parity]
- **GAP Closure Strategy**:
  - Short-term (1-3 months): Quick wins (Strategy B focus)
  - Mid-term (3-12 months): Strategy A major investment
  - Long-term (1-3 years): Strategy C experiments, Strategy D strategic ignore

**5. Synergy Mapping**

- **Strength × Strength**: Create super-strength (e.g., Tech + Brand → Premium positioning)
- **Strength covers Weakness**: Use strength to neutralize weakness
- **Weakness fix → Strength multiplier**: Removing weakness creates space for strength to flourish

**6. Quality Checklist**

- [ ] Strengths backed by objective evidence?
- [ ] Root cause of weaknesses identified? (5 Why applied)
- [ ] Priorities reflect resource constraints?
- [ ] Strategy includes measurable goals?
- [ ] Competitor response considered?
- [ ] Expected risks and countermeasures?
- [ ] 🆕 2×2 Priority Matrix included?

**7. One-Sentence Core Strategy**

Format: "Maximize [core strength] through [specific method], address [critical weakness] via [action plan], to achieve [final goal]."

---

## 🆕 Pre-Flight Check System (v2.0)

Before executing any routine, run these checks to prevent common failures:

### Check 1: Complexity Mismatch
```
IF problem_complexity == "Simple" AND selected_routine == "A":
   WARNING: "Over-engineering detected. A Routine has 50% success rate for simple problems. 
            Recommend B Routine with 5 Why or Pareto instead."

IF problem_complexity == "Complex" AND selected_routine == "B" AND thinking_method != ["First_Principles", "TRIZ"]:
   WARNING: "Under-powered method. Complex problems need A Routine or advanced methods (First Principles, TRIZ)."
```

### Check 2: Method-Problem Mismatch
```
IF problem_type == "creative_innovation" AND thinking_method IN ["DMAIC", "Kepner_Tregoe"]:
   ERROR: "Method incompatible. DMAIC/Kepner-Tregoe have 0% success rate for creative problems. 
          Use SCAMPER, TRIZ, or Design Thinking instead."

IF problem_type == "strategic_planning" AND thinking_method == "SWOT" AND "2x2_matrix" NOT included:
   WARNING: "SWOT alone has 33% failure rate. MUST include 2x2 Priority Matrix for strategic decisions."
```

### Check 3: Execution Time Forecast
```
IF selected_routine == "A" AND sub_problems > 5:
   WARNING: "Complexity risk. > 5 sub-problems increase failure rate and execution time > 60 sec. 
            Suggest re-grouping or hierarchical decomposition."
```

---

## Usage Guidelines

**When to Apply Each Routine**:

- **A Routine** (Divide & Conquer): Complex problems with 5+ interdependent factors (45-60 sec)
- **B Routine** (Method Selection): All cases - select appropriate thinking method (< 45 sec)
- **C Routine** (Strategy): Strategic decisions involving strengths/weaknesses (30-45 sec, MUST include 2x2 matrix)

**Always Include**:
- 🆕 Pre-flight check (complexity assessment, method matching)
- 🆕 Method selection justification (1 sentence: "Why this method?")
- Output optimization (choose best format)
- Quality verification (check logic, depth, completeness)
- One-sentence summary (core insight)
- Meta-thinking (what could improve this analysis?)

**Output Formats**:
- **Markdown tables**: For structured comparisons
- **Numbered lists**: For sequential processes
- **Mermaid diagrams**: For problem decomposition, decision trees
- **Logic trees**: For cause-effect relationships
- **2x2 Matrices**: MANDATORY for C Routine

---

## Quick Start Examples

### Example 1: Complex System Architecture Problem

**User**: "Our microservices architecture is becoming unmaintainable. How do we fix this?"

**🆕 Pre-Flight Check**:
- Complexity: Complex (systemic, 5+ factors) ✅
- Recommended: A Routine ✅
- Estimated time: 50 sec

**Apply**: A Routine (Divide & Conquer)
1. Define problem: Microservices complexity causing maintenance burden
2. Divide into sub-problems (MAX 5):
   - Service communication overhead
   - Deployment complexity
   - Monitoring/observability gaps
   - Data consistency issues
   - Team coordination
3. Layered thinking for each sub-problem (Surface/Root/Alternative/Integration)
4. Combine solutions into integrated architecture strategy

### Example 2: Root Cause Investigation

**User**: "Production deployment keeps failing. Why?"

**🆕 Pre-Flight Check**:
- Complexity: Simple-Medium (single chain of causes)
- Recommended: B Routine with 5 Why ✅
- Estimated time: 30 sec

**Apply**: B Routine with **5 Why** method

**🆕 Why this method**: "5 Why selected because root cause is unclear and needs systematic drilling down the causal chain."

1. Classify: Problem cause analysis
2. Select: 5 Why (100% success rate for root_cause_analysis)
3. Apply:
   - Why 1: Tests passed locally but fail in production
   - Why 2: Environment variables differ
   - Why 3: No environment parity in CI/CD
   - Why 4: Infrastructure-as-Code not implemented
   - Why 5: Team lacked DevOps expertise and tooling

### Example 3: Startup Strategy

**User**: "We have great tech but no customers. What should we do?"

**🆕 Pre-Flight Check**:
- Complexity: Medium (strategic with clear strength/weakness)
- Recommended: C Routine ✅
- MUST include: 2x2 Priority Matrix ✅
- Estimated time: 40 sec

**Apply**: C Routine (Strengths/Weaknesses Strategy)
1. Diagnosis: Strength (technology), Weakness (market traction/sales/marketing)
2. Strategic decision: Weakness is critical risk (no customers = business death)
3. 🆕 **2×2 Matrix** (MANDATORY):
   ```
   High Priority:
     Strategy A: Leverage tech via open-source + dev community
     Strategy B: Address customer weakness via 5 pilot partnerships + PR
   
   Low Priority:
     Strategy C: Long-term R&D experiments
     Strategy D: Ignore non-critical gaps (e.g., enterprise sales for now)
   ```
4. GAP analysis: Current (0 customers) → Target (100 paying customers in 3 months)
5. Strategy: "Maximize tech strength through open-source + developer community, address customer weakness via 5 pilot partnerships + PR, to achieve Product-Market Fit in 6 months."

---

## Integration with Other Methods

### Single Method Integration

This framework integrates with:
- **First Principles Thinking**: Use in Root Cause layer of A Routine
- **SWOT Analysis**: Foundation for C Routine (MUST add 2x2 matrix)
- **5 Why**: Critical for weakness diagnosis in C Routine
- **Design Thinking**: Can be selected in B Routine for innovation problems

### 🆕 Multi-Method Combinations (v2.2)

For complex problems requiring multiple perspectives, use **method combinations**:

**Standard Patterns**:
1. **Root Cause → Solution → Validation**: `5 Why → First Principles → PDCA`
   - Use when: Technical problem needs innovative solution
   - Time: 2-3 hours

2. **Strategic Planning Full Stack**: `Problem Definition → SWOT → 2x2 → GAP → OODA`
   - Use when: Business strategy formulation and execution
   - Time: 3-5 hours

3. **Innovation Pipeline**: `Design Thinking → SCAMPER → TRIZ → Pareto`
   - Use when: Product development with prioritization
   - Time: 1-2 weeks

4. **Complex System Debugging**: `Fishbone → Pareto → 5 Why → First Principles`
   - Use when: Multi-factor systemic issues
   - Time: 2-4 hours

5. **Crisis Response**: `OODA → Fishbone → 5 Why → PDCA`
   - Use when: Fast-moving situation + permanent fix needed
   - Time: Hours (immediate) + Days (follow-up)

**When to Combine Methods**:
- Single method insufficient for problem complexity
- Need multiple phases: analysis → ideation → execution
- Require cross-validation of outputs
- Complex problem with 5+ interdependent factors

**Combination Best Practices**:
- Start with Problem Definition (always)
- Validate outputs between methods
- Use 2-4 methods maximum (>5 = over-engineering)
- Match method strengths to problem phases

👉 **See [reference/METHOD_COMBINATIONS.md](reference/METHOD_COMBINATIONS.md) for detailed workflows, real examples, and anti-patterns**

For detailed descriptions of all 15 thinking methods, see **[reference/INDEX.md](reference/INDEX.md)** or individual method files in the **reference/** directory.

---

## 🆕 v2.0 Evolution Metrics

This v2.0 was derived from analyzing 20 executions:

**v1.0 Baseline**:
- Success Rate: 70% (14/20)
- Routine Success: A(67%), B(70%), C(75%)
- Complexity Success: Simple(50%), Medium(89%), Complex(57%)
- Avg Satisfaction: 3.7/5.0
- Avg Duration: 44.8 sec

**v2.0 Targets**:
- Success Rate: 90%+ (vs 70%)
- All Routines: 85%+ (vs 67-75%)
- Complexity: Simple(85%+), Medium(95%+), Complex(80%+)
- Avg Satisfaction: 4.5+/5.0 (vs 3.7)
- Avg Duration: Optimized by complexity (Simple < 30s, Medium 30-45s, Complex 45-60s)

**Key Improvements**:
1. Complexity assessment (prevent over/under-engineering)
2. Method-problem matching matrix (100% success rate combinations)
3. Pre-flight checks (catch mismatches before execution)
4. A Routine: Max 5 sub-problems (prevent over-complexity)
5. C Routine: 2x2 matrix MANDATORY (fix 33% failure rate)

---

## Meta Note

After applying this framework, always reflect:
- **What worked well** in this analysis?
- **What could be improved** in the approach?
- **What was learned** from this problem-solving session?
- 🆕 **Did pre-flight checks help** prevent potential failures?
- 🆕 **Was the selected method optimal** (check against matching matrix)?

This reflection creates a virtuous cycle of continuous improvement in thinking quality.

---

For detailed usage and examples, see related documentation files.