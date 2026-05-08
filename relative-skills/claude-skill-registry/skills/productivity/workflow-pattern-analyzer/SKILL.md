---
name: workflow-pattern-analyzer
description: Analyzes recent conversation history using chat tools to identify recurring workflow patterns and generate Custom Skills recommendations with statistical rigor. Use when users request workflow analysis, pattern identification, skill generation suggestions, or automation opportunities based on their AI usage patterns without requiring conversation exports.
---

# Workflow Pattern Analyzer

## Instructions

This skill provides comprehensive conversation pattern analysis using Claude's native chat history tools (`recent_chats` and `conversation_search`) to identify skill-worthy automation opportunities with the statistical rigor of export-based analysis.

**Core Capabilities:**
- Web interface compatible (no exports required)
- Statistical pattern validation and scoring
- Frequency analysis and temporal tracking
- Evidence-based skill recommendations
- Complete skill package generation

## Analysis Framework

This skill uses the **[shared analysis methodology](../../shared/analysis-methodology.md)** with tool-based data collection adaptations.

### Phase 1: Data Collection Strategy

**Determine Analysis Scope:**

Ask user: "How deep should I analyze your conversation history?"

**Options:**
- **Quick Scan** (20-30 conversations, ~2-3 min): Recent patterns and immediate opportunities
- **Standard Analysis** (50-75 conversations, ~5-7 min): Comprehensive pattern detection
- **Deep Dive** (100+ conversations, ~10-15 min): Full workflow mapping with temporal trends
- **Targeted Search** (variable): Focus on specific topics or time periods

**Data Collection Process:**

1. **Broad Sampling**: Use `recent_chats(n=30)` multiple times with varied parameters to get diverse coverage
2. **Temporal Distribution**: Sample conversations across different time periods (recent, 1 week ago, 1 month ago)
3. **Topic Exploration**: Use `conversation_search` for domains mentioned by user or detected in initial sampling
4. **Depth vs Breadth**: Balance comprehensive coverage with processing efficiency

### Phase 2-6: Core Analysis

Apply the **[shared analysis methodology](../../shared/analysis-methodology.md)** phases:

- **Phase 2**: Pattern Discovery & Classification (explicit, implicit, domain, temporal)
- **Phase 3**: Frequency Analysis & Validation (occurrence metrics, statistical validation)
- **Phase 4**: Skill-Worthiness Scoring (0-50 composite scale across 5 dimensions)
- **Phase 5**: Relationship Mapping & Consolidation (overlap detection, boundary optimization)
- **Phase 6**: Prioritization Matrix & Recommendations (frequency vs impact visualization)

See [shared methodology](../../shared/analysis-methodology.md) for complete scoring rubrics and quality standards.

### Phase 7: Skill Package Generation

**For each approved skill, create:**

**A. Skill Specification Document:**

```markdown
## [Skill Name]

**Pattern Evidence:**
- Frequency: [X instances in Y conversations (Z%)]
- Consistency: [X/10 score]
- Time savings: [X hours/month]

**Composite Score: [X/50]**
- Frequency: [X/10]
- Consistency: [X/10]
- Complexity: [X/10]
- Time Savings: [X/10]
- Error Reduction: [X/10]

**Example Conversations:**
1. [Date]: [Brief excerpt showing pattern]
2. [Date]: [Brief excerpt showing pattern]
3. [Date]: [Brief excerpt showing pattern]

**Pattern Components:**
- **Consistent elements**: [What stays the same]
- **Variable elements**: [What changes per instance]
- **Common refinements**: [Typical adjustments user makes]

**Proposed Skill Structure:**

SKILL.md sections:
1. Overview & trigger conditions
2. [Main workflow methodology]
3. Quality standards
4. Examples

Supporting files needed:
- reference.md: [Detailed framework/methodology]
- templates/: [Reusable output templates]
- examples.md: [Additional use cases]
```

**B. Complete SKILL.md File:**

Generate production-ready skill with:
- Proper YAML frontmatter (name, description with triggers)
- Clear instructions based on pattern analysis
- Evidence-based examples from actual conversations
- Quality standards derived from user refinement patterns
- Progressive disclosure (link to references for detail)

## Output Formats

**After analysis completion, present:**

### Summary Report

```markdown
# Workflow Pattern Analysis Report
**Analysis Date**: [Timestamp]
**Conversations Analyzed**: [X conversations across Y time period]
**Patterns Identified**: [X patterns]
**Skills Recommended**: [Y skills]

## 🔥 HIGH-PRIORITY OPPORTUNITIES

### 1. [Skill Name]
**Score: [X/50]** (Frequency: X/10, Consistency: X/10, Complexity: X/10, Time: X/10, Error: X/10)

**Pattern Description**: [What you do repeatedly]

**Evidence**:
- Found in [X] conversations ([Y%] of analyzed sample)
- First seen: [Date], Most recent: [Date]
- Average time per instance: [X minutes]

**Example Occurrences**:
1. [Date]: "[Brief excerpt]"
2. [Date]: "[Brief excerpt]"

**Proposed Skill**: "[One-line skill description]"

**Time Savings**: [X hours/month]

---

[Repeat for top 5-8 patterns]

## 💡 MODERATE OPPORTUNITIES
[Briefer summaries of medium-priority patterns]

## 🎯 QUICK AUTOMATION CANDIDATES
[Simple, high-frequency patterns]

## ⏸️  DEFERRED PATTERNS
[Patterns that didn't meet skill-worthiness thresholds]

## 📊 ANALYSIS METADATA
- Total conversations: [X]
- Date range: [earliest] to [latest]
- Unique patterns identified: [X]
- Patterns validated: [Y]
- Cross-pattern overlaps: [Z]
- Recommended consolidations: [N]
```

### Interactive Follow-Up Options

```
What would you like to do next?

A. Generate complete SKILL.md files for [top 3-5 skills]
B. Deep dive into specific pattern: [skill name]
C. Expand analysis with more conversations
D. Focus on specific domain/topic area
E. Adjust scoring weights and recalculate priorities
```

## Quality Standards

All quality standards follow the **[shared analysis methodology](../../shared/analysis-methodology.md#quality-standards)**:

- Pattern validation requirements (frequency, consistency, evidence)
- Skill consolidation rules (max 8-12 skills, clear boundaries)
- Skill package generation standards
- Anti-patterns to avoid

## Progressive Disclosure Strategy

**Keep this SKILL.md concise by referencing:**
- **Core methodology**: [shared/analysis-methodology.md](../../shared/analysis-methodology.md)
- **Detailed scoring rubrics**: See methodology Phase 4
- **Quality standards**: See methodology Quality Standards section
- **Anti-patterns**: See methodology Anti-Patterns section

**Load additional context only when:**
- User requests deep dive on specific pattern
- Generating complete skill packages (not just analysis)
- User wants to understand scoring methodology in detail
- Building reference materials for complex domains

## Examples

### Example 1: Quick Scan Request

**User**: "Analyze my recent chats for automation opportunities"

**Claude**:
I'll perform a quick scan of your recent conversation history to identify skill opportunities.

[Uses recent_chats(n=30) multiple times]

📊 **Quick Scan Results** (30 conversations analyzed)

🔥 **TOP OPPORTUNITY**:

**"Email Response Composer"** - Score: 42/50
- Found in 9 conversations (30%)
- Pattern: You regularly ask me to draft professional emails with specific tone and structure requirements
- Time savings: ~90 min/month (10 min per email × 9 emails)
- Evidence: Consistent 3-paragraph structure with greeting, main content, action items

Want me to:
A. Generate complete skill package for this
B. Continue analysis for more patterns (expand to 50-75 conversations)
C. Focus on other domains

### Example 2: Targeted Domain Analysis

**User**: "Find patterns in how I use you for coding tasks"

**Claude**:
I'll analyze your coding-related conversations to identify workflow patterns.

[Uses conversation_search for coding terms + recent_chats filtering]

📊 **Coding Workflow Analysis** (18 relevant conversations)

🔥 **TOP PATTERNS**:

1. **"Code Review Checklist Generator"** - Score: 38/50
   - Found in 7 code review discussions
   - Pattern: You ask for language-specific review checklists before reviewing PRs
   - Consistency: 85% (always includes security, performance, style sections)

2. **"API Documentation Humanizer"** - Score: 35/50
   - Found in 5 documentation tasks
   - Pattern: Converting technical API specs into developer-friendly guides
   - Structure: Always includes quick start, common use cases, troubleshooting

Want me to build skills for these patterns?

### Example 3: Deep Dive Analysis

**User**: "Do a comprehensive analysis of my workflow over the last few months"

**Claude**:
I'll perform a deep analysis of your conversation history. This will take 10-15 minutes to ensure comprehensive coverage.

[Uses recent_chats extensively, conversation_search for discovered topics, temporal sampling]

📊 **Comprehensive Workflow Analysis**
- **Conversations analyzed**: 120
- **Date range**: [3 months]
- **Patterns identified**: 15
- **Skills recommended**: 6

🔥 **CRITICAL PRIORITY** (Score 40-50):

1. **"Weekly Status Report Generator"** - Score: 47/50
   - Frequency: 12 instances (10% of conversations)
   - Consistency: 95% - always same structure
   - Evidence: Every Monday, you format updates in identical 5-section template
   - Time savings: 240 min/month (20 min/week × 4 weeks × 3 months avg)

⭐ **HIGH PRIORITY** (Score 30-39):

2. **"Client Proposal Framework"** - Score: 36/50
3. **"Meeting Notes Structurer"** - Score: 34/50
4. **"Technical Concept Explainer"** - Score: 31/50

[Full analysis report with evidence, prioritization matrix, skill specifications]

**Recommended Implementation Path**:
1. Start with "Weekly Status Report Generator" (highest ROI)
2. Build "Client Proposal Framework" and "Meeting Notes Structurer" next (complementary workflows)
3. Evaluate remaining patterns after 2-4 weeks of usage

Generate complete skill packages now? [Y/N]

## When to Use This Skill

**✅ Use this skill when:**
- User requests analysis of their conversation patterns
- User wants to identify automation opportunities
- User asks what skills they should create
- User mentions repetitive tasks or workflows
- User wants evidence-based skill recommendations
- User is in web interface (can't use export-based analysis)

**❌ Don't use this skill when:**
- User has conversation export files available (use export-based plugin instead for more comprehensive analysis)
- User wants cross-platform ChatGPT + Claude analysis (requires exports)
- User has very few conversations (<10) making pattern detection unreliable
- User wants to build specific skill they already have in mind
- User is asking about existing skills or community skills

**⚡ Proactive Use:**
When you detect potential patterns during normal conversation, offer:
```
💭 Pattern detected: This is the [Xth] time you've asked me to [action].

Would you like me to analyze your conversation history for similar 
patterns and recommend a Custom Skill? I can identify other automation 
opportunities you might not have noticed.

[Yes, analyze] [Not now]
```

## Anti-Patterns to Avoid

See **[shared methodology anti-patterns](../../shared/analysis-methodology.md#anti-patterns-to-avoid)** for complete guidance on:
- Tasks not suitable for skills
- Red flags in patterns
- When to use MCP vs skills
- Common recommendation pitfalls
