---

# === CORE IDENTITY ===
name: competitive-analysis
title: Competitive Analysis & Intelligence
description: Strategic competitive analysis framework for evaluating skills, commands, agents, and product features against external repositories and competitors
domain: product
subdomain: product-team-general

# === WEBSITE DISPLAY ===
difficulty: intermediate
time-saved: "70% faster competitive analysis, 50% more comprehensive gap coverage"
frequency: "Monthly for strategic planning, quarterly for market reviews"
use-cases:
  - Competitive scorecard generation with weighted dimensions
  - Feature gap analysis and opportunity identification
  - Competitive advantage documentation
  - Adoption prioritization using impact/effort frameworks
  - Strategic positioning assessment

# === RELATIONSHIPS ===
related-agents: [cs-product-strategist, cs-product-manager, cs-business-analyst]
related-skills: []
related-commands: []
orchestrated-by: []

# === TECHNICAL ===
dependencies:
  scripts: []
  references: []
  assets: []
compatibility:
  python-version: 3.8+
  platforms: [macos, linux, windows]
tech-stack: [Python 3.8+, Markdown]

# === EXAMPLES ===
examples:
  -
    title: Competitive Scorecard
    input: "Analyze competitor repository against our skills"
    output: "Visual scorecard with ratings and recommendations"

# === ANALYTICS ===
stats:
  downloads: 0
  stars: 0
  rating: 0.0
  reviews: 0

# === VERSIONING ===
version: v1.1.0
author: Claude Skills Library
contributors: []
created: 2025-11-27
updated: 2025-11-27
license: MIT

# === DISCOVERABILITY ===
tags: [competitive-intelligence, gap-analysis, strategic-planning, scorecard, prioritization, product]
featured: false
verified: true
---

# Competitive Analysis Skill

## Overview

The Competitive Analysis skill provides a structured framework for comparing your skills, commands, agents, and features against competitors. It enables systematic evaluation using weighted scoring dimensions and generates actionable insights for product strategy.

## Core Capabilities

- **Scorecard Generation** - Multi-dimensional comparison with weighted scoring for visual scorecards
- **Gap Analysis** - Identify what competitors have that you don't with prioritized gap lists
- **Advantage Identification** - Document your competitive strengths in differentiation matrices
- **Adoption Prioritization** - Rank improvements by impact and effort for action roadmaps

### When to Use This Skill

- Evaluating new market entrants or competitor updates
- Planning product roadmap priorities
- Identifying feature gaps before releases
- Documenting competitive differentiation for stakeholders
- Strategic planning sessions

---

## Quick Start

```bash
# Run competitive analysis
python scripts/competitive_analyzer.py --competitor-path ./competitor-code --our-path ./

# Generate gap analysis
python scripts/gap_analyzer.py --competitor-path ./competitor

# Create visual scorecard
python scripts/scorecard_generator.py --analysis-file analysis.json
```

---

## Key Workflows

### 1. Competitive Scorecard Generation

**Purpose**: Create a comprehensive comparison scorecard between your product and competitors.

**Trigger**: User provides competitor code/documentation for analysis

**Process**:

1. **Discovery Phase**
   - Inventory competitor's capabilities (skills, commands, agents, features)
   - Catalog your own capabilities for comparison
   - Build comparison matrix with matched items

2. **Analysis Phase**
   - Score each dimension (6 weighted categories)
   - Apply scoring rubric (1-5 stars)
   - Calculate weighted totals

3. **Scoring Dimensions**:

   | Dimension | Weight | What to Evaluate |
   |-----------|--------|------------------|
   | Documentation Completeness | 20% | Metadata, sections, examples, clarity |
   | Tool/Script Quality | 20% | CLI support, error handling, testing |
   | Workflow Coverage | 15% | Number of workflows, depth, practicality |
   | Architecture | 15% | Modularity, portability, dependencies |
   | Automation | 15% | Auto-generation, validation, CI/CD |
   | Reference Depth | 15% | Knowledge bases, templates, examples |

4. **Output Generation**
   - Generate visual scorecard (ASCII box format)
   - Create feature comparison table
   - Summarize overall position (AHEAD / EVEN / BEHIND)

**Deliverable**: Competitive scorecard with visual summary and detailed breakdown

**Example Output**:
```
┌───────────────────────────────────────────────────────────┐
│                 COMPETITIVE SCORECARD                      │
│                 US (claude-skills) vs THEM (Competitor)    │
├───────────────────────────────────────────────────────────┤
│  🏆 WE WIN:     12 areas  (48%)  - Our advantages         │
│  🤝 TIE:         8 areas  (32%)  - At parity              │
│  🔄 DIFFERENT:   3 areas  (12%)  - Neither better         │
│  ❌ THEY WIN:    2 areas  (8%)   - Gaps to address        │
│                                                            │
│  Overall Position: WE ARE AHEAD                            │
│  Confidence: HIGH                                          │
└───────────────────────────────────────────────────────────┘
```

---

### 2. Feature Gap Analysis

**Purpose**: Identify gaps in your product compared to competitors and prioritize which to address.

**Trigger**: After scorecard generation or standalone gap assessment request

**Process**:

1. **Gap Identification** (Always label clearly as US vs THEM)
   - **THEY have, WE don't** → Gaps for us to fill
   - **WE have, THEY don't** → Our advantages to maintain
   - **Different approaches** → Neither better, just different
   - **THEY score higher** → Priority improvements for us

2. **Gap Categorization**

   | Category | Symbol | Action |
   |----------|--------|--------|
   | Critical Gap | 🔴 | Must address immediately |
   | Important Gap | 🟠 | Address in next quarter |
   | Nice-to-Have | 🟡 | Consider for roadmap |
   | Strategic Choice | ⚪ | Intentionally different |

3. **Impact Assessment**
   - User impact (1-5)
   - Competitive urgency (1-5)
   - Strategic alignment (1-5)
   - Implementation effort (1-5)

4. **Priority Calculation**
   ```
   Priority Score = (Impact × 0.4) + (Urgency × 0.3) + (Strategic × 0.2) + (1/Effort × 0.1)
   ```

**Deliverable**: Prioritized gap list with recommended actions

**Example Output**:
```
┌───────────────────────────────────────────────────────────────┐
│                       GAP ANALYSIS                            │
│                   US vs THEM Comparison                        │
├───────────────────────────────────────────────────────────────┤
│                                                                │
│  🏆 WHAT WE HAVE THAT THEY DON'T (Our Advantages)             │
│  ├─ Executable Python tools (they have zero)                   │
│  ├─ Modular package structure (SKILL.md + scripts/)            │
│  ├─ Agent integration                                          │
│  └─ Builder tools for creation/validation                      │
│                                                                │
│  ❌ WHAT THEY HAVE THAT WE DON'T (Gaps to Fill)               │
│  ├─ Industry-specific guidance                                 │
│  ├─ Methodology variants (Agile/Waterfall)                     │
│  └─ Detailed constraint documentation                          │
│                                                                │
│  🟢 RECOMMENDATIONS FOR US                                    │
│  ├─ Add industry guides to our skill                           │
│  ├─ Document methodology variants                              │
│  └─ Add common challenges section                              │
│                                                                │
└───────────────────────────────────────────────────────────────┘
```

**Reference**: See [references/gap-analysis-methodology.md](references/gap-analysis-methodology.md)

---

### 3. Competitive Advantage Identification

**Purpose**: Document and articulate your competitive strengths.

**Trigger**: Strategy sessions, positioning reviews, or marketing alignment

**Process**:

1. **Advantage Discovery**
   - Features only you have
   - Areas where you score higher
   - Unique approaches or innovations
   - Integration capabilities

2. **Advantage Classification**

   | Type | Description | Example |
   |------|-------------|---------|
   | **Technical** | Architecture or implementation superiority | Zero-dependency design |
   | **Quality** | Higher standards or better execution | 100% validation rate |
   | **Coverage** | More comprehensive offerings | 28 skills vs 15 |
   | **Innovation** | Novel approaches or features | AI-assisted builders |
   | **Integration** | Better ecosystem connectivity | MCP server support |

3. **Strength Quantification**
   - Measure the delta (how much better)
   - Identify sustainability (easy to copy?)
   - Assess market value (does it matter to users?)

4. **Messaging Development**
   - Elevator pitch for each advantage
   - Supporting evidence/metrics
   - Competitive positioning statement

**Deliverable**: Competitive advantage matrix with messaging guidance

---

### 4. Adoption Prioritization

**Purpose**: Create a prioritized roadmap for adopting competitor features or innovations.

**Trigger**: After gap analysis, planning sessions, or roadmap reviews

**Process**:

1. **Candidate Identification**
   - Features worth adopting from competitors
   - Improvements needed for parity
   - Innovations to leapfrog competition

2. **Evaluation Criteria**

   | Criterion | Weight | Description |
   |-----------|--------|-------------|
   | User Value | 30% | How much will users benefit? |
   | Competitive Impact | 25% | Does this close a critical gap? |
   | Strategic Fit | 20% | Does it align with our direction? |
   | Implementation Cost | 15% | Resources and time required |
   | Risk Level | 10% | Technical and market risks |

3. **Prioritization Matrix**
   ```
   HIGH IMPACT
        │
        │  ┌─────────┐  ┌─────────┐
        │  │ Quick   │  │ Major   │
        │  │ Wins    │  │Projects │
        │  └─────────┘  └─────────┘
        │
        │  ┌─────────┐  ┌─────────┐
        │  │ Fill    │  │ Consider│
        │  │ Ins     │  │ Later   │
        │  └─────────┘  └─────────┘
        │
        └──────────────────────────→
              LOW EFFORT    HIGH EFFORT
   ```

4. **Timeline Planning**
   - Immediate (this sprint)
   - Short-term (this quarter)
   - Medium-term (next quarter)
   - Long-term (future consideration)

**Deliverable**: Adoption roadmap with prioritized items and timeline

**Template**: See [assets/adoption-plan-template.md](assets/adoption-plan-template.md)

---

## Python Tools

### competitive_analyzer.py

**Purpose**: Core analysis engine for competitive comparison

**Usage**:
```bash
# Analyze competitor against our repo
python scripts/competitive_analyzer.py --competitor-path ./competitor-code --our-path ./

# Scope to specific types
python scripts/competitive_analyzer.py --scope skills --competitor-path ./competitor

# Output JSON for further processing
python scripts/competitive_analyzer.py --output json --competitor-path ./competitor
```

**Features**:
- Auto-detection of skills, commands, agents
- Pattern matching for comparison candidates
- Weighted scoring calculation
- Multiple output formats (markdown, json, console)

---

### gap_analyzer.py

**Purpose**: Identify and categorize feature gaps

**Usage**:
```bash
# Run gap analysis
python scripts/gap_analyzer.py --competitor-path ./competitor

# Focus on critical gaps only
python scripts/gap_analyzer.py --severity critical --competitor-path ./competitor

# Generate prioritized list
python scripts/gap_analyzer.py --prioritize --competitor-path ./competitor
```

**Features**:
- Gap categorization (critical, important, nice-to-have)
- Impact scoring
- Priority calculation
- Actionable recommendations

---

### scorecard_generator.py

**Purpose**: Generate visual scorecards and comparison tables

**Usage**:
```bash
# Generate scorecard from analysis
python scripts/scorecard_generator.py --analysis-file analysis.json

# Custom output format
python scripts/scorecard_generator.py --format ascii --analysis-file analysis.json
python scripts/scorecard_generator.py --format markdown --analysis-file analysis.json

# Include detailed breakdown
python scripts/scorecard_generator.py --detailed --analysis-file analysis.json
```

**Features**:
- ASCII box scorecards
- Markdown tables
- Visual indicators (🟢 ✅ 🟡 ❌)
- Executive summary generation

---

## References

| Reference | Purpose |
|-----------|---------|
| [scoring-framework.md](references/scoring-framework.md) | Detailed scoring criteria and rubrics |
| [gap-analysis-methodology.md](references/gap-analysis-methodology.md) | Gap categorization and prioritization formulas |

---

## Assets/Templates

| Template | Purpose |
|----------|---------|
| [scorecard-template.md](assets/scorecard-template.md) | Blank scorecard for manual analysis |
| [adoption-plan-template.md](assets/adoption-plan-template.md) | Roadmap planning template |

---

## Integration with Agents

This skill integrates with the following product team agents:

### cs-product-strategist

Uses competitive analysis for:
- Market positioning decisions
- Feature prioritization
- Strategic planning sessions

**Invocation**: "Analyze competitor X against our product using the competitive-analysis skill"

### cs-product-manager

Uses competitive analysis for:
- Roadmap planning
- Feature gap identification
- Sprint prioritization

**Invocation**: "Run a competitive scorecard against this repository"

### cs-business-analyst

Uses competitive analysis for:
- Requirements gathering
- Gap documentation
- Stakeholder reporting

**Invocation**: "Generate a gap analysis comparing our capabilities to competitor Y"

---

## Integration with Commands

### /analyze.competition

The slash command version of this skill for quick analysis:

```bash
# Basic usage - paste competitor code after
/analyze.competition

# Scope filtering
/analyze.competition --scope skills
/analyze.competition --scope commands

# Output format
/analyze.competition --output markdown
/analyze.competition --output json
```

**Relationship**:
- **Skill**: Provides deep methodology, multiple workflows, reusable tools
- **Command**: Quick execution for ad-hoc analysis

---

## Best Practices

### Before Analysis

1. **Gather Complete Data**: Ensure you have access to competitor's full codebase or documentation
2. **Define Scope**: Determine what you're comparing (skills, commands, agents, all)
3. **Establish Baseline**: Know your own inventory before comparing

### During Analysis

1. **Use Consistent Criteria**: Apply the same scoring rubric to both sides
2. **Document Assumptions**: Note any gaps in information
3. **Seek Objectivity**: Avoid bias toward your own product

### After Analysis

1. **Validate Findings**: Have stakeholders review the scorecard
2. **Prioritize Ruthlessly**: Focus on high-impact, low-effort items first
3. **Create Action Items**: Convert insights into backlog items
4. **Track Progress**: Revisit gaps quarterly

---

## Example Analysis Session

```bash
# 1. User invokes competitive analysis
/analyze.competition

# 2. System prompts for competitor code
"Please paste the competitor code you want to analyze..."

# 3. User pastes competitor SKILL.md, agent files, etc.
[User pastes code]

# 4. System runs 4-phase analysis
Phase 1: Discovery... inventorying 15 competitor skills
Phase 2: Analysis... scoring across 6 dimensions
Phase 3: Gap Analysis... identifying 8 gaps, 12 advantages
Phase 4: Reporting... generating scorecard

# 5. Output displayed and saved
Report saved to: output/sessions/{user}/{session}/competitive-analysis-2025-11-27.md

┌───────────────────────────────────────────────────────────┐
│                 COMPETITIVE SCORECARD                      │
│                 US (claude-skills) vs THEM (Competitor)    │
├───────────────────────────────────────────────────────────┤
│  🏆 WE WIN:     12 areas  (48%)  - Our advantages         │
│  🤝 TIE:         8 areas  (32%)  - At parity              │
│  🔄 DIFFERENT:   3 areas  (12%)  - Neither better         │
│  ❌ THEY WIN:    2 areas  (8%)   - Gaps to address        │
│                                                            │
│  Overall Position: WE ARE AHEAD                            │
│  Confidence: HIGH                                          │
└───────────────────────────────────────────────────────────┘

## Dimension Comparison

| Dimension | US | THEM | Winner |
|-----------|-----|------|--------|
| Documentation | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 🏆 THEM |
| Python Tools | ⭐⭐⭐⭐⭐ | ⭐⭐ | 🏆 US |
| Workflows | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 🏆 THEM |
| Architecture | ⭐⭐⭐⭐⭐ | ⭐⭐ | 🏆 US |
| Automation | ⭐⭐⭐⭐⭐ | ⭐ | 🏆 US |
| References | ⭐⭐⭐⭐ | ⭐⭐⭐ | 🏆 US |

## Recommendations for US

| What to Improve | Priority | Effort |
|-----------------|----------|--------|
| Add their workflow depth | 🟢 High | Low |
| Adopt their documentation patterns | 🟠 Medium | Medium |
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.1.0 | 2025-11-27 | Clearer US vs THEM labeling in all outputs |
| 1.0.0 | 2025-11-27 | Initial release with 4 workflows |

---

**Maintained By**: Product Team
**Last Updated**: November 27, 2025
**Status**: Production
