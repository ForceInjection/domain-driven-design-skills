---
name: skill-description-evaluator
description: Automates multi-model skill description analysis using sequential-thinking. Evaluates invocation likelihood (Sonnet 4.5, Haiku), authority level against competing prompts, semantic clarity, user request matching. Generates 0-100 ratings with actionable recommendations. Use when evaluating skill descriptions or saying 'evaluate skill', 'test skill description', 'analyze skill effectiveness'.
allowed-tools:
  - AskUserQuestion
  - Read
  - mcp__sequential-thinking__sequentialthinking
---

# Skill: Evaluating Skill Description Effectiveness

## When to Use This Skill

Use this skill when evaluating whether a skill description is likely to be invoked by Claude models (Sonnet 4.5 or Haiku) when competing against system prompt instructions, or when assessing skill description quality.

Use other skills for: creating new skills (manual process), modifying existing skills (Edit tool directly).

## Workflow Description

Evaluates skill descriptions through structured analysis using sequential-thinking. Assesses invocation likelihood for Sonnet 4.5 and Haiku, semantic clarity, authority level, and user request pattern matching. Outputs ratings with actionable improvement recommendations.

Extract from user request: skill description (inline text or file path), competing system instructions (optional), target model (default: both Sonnet 4.5 and Haiku)

---

## Phase 1: Gather Input

**Objective**: Collect skill description and optional competing instructions.

**Steps**:

1. Check user request for skill description input:
   - Inline text: Description provided directly in request
   - File path: Path to SKILL.md or text file containing description
   - Prompt: Ask user if neither provided

2. IF file path provided:

   ```text
   Use Read tool to read file at specified path
   Extract description from YAML frontmatter if SKILL.md format
   Otherwise use full file content as description
   ```

3. IF inline text provided:
   - Use provided text as description
   - Store for Phase 3

4. IF neither provided:
   - Use AskUserQuestion to request description:
     - Question: "Please provide the skill description to evaluate. You can paste the description text or provide a file path."
     - Header: "Description"
     - Options:
       - **Paste text**: "I'll paste the description directly"
       - **Provide path**: "I'll provide a file path to read"
   - WAIT for user response via "Other" option
   - Parse response and re-enter Step 2 or 3

5. Check for competing system instructions:
   - Look in user request for phrases like: "compare with", "competing against", "vs system prompt"
   - IF found: Extract or ask user to provide system instruction text
   - IF not found: Set competing_instructions = null

**Validation Gate: Description Retrieved**

IF description is empty or invalid:
  STOP immediately
  EXPLAIN: "Cannot evaluate empty or invalid skill description"
  EXIT workflow

IF description successfully retrieved:
  Store: description, competing_instructions (optional)
  Continue to Phase 2

Phase 1 complete. Continue to Phase 2.

---

## Phase 2: Analyze Competing Instructions (Conditional)

**Objective**: Understand competing system prompt patterns if provided.

**Skip**: IF competing_instructions = null (no comparison requested)

**Steps**:

1. Parse competing instructions for:
   - Directive language: "MUST", "ALWAYS", "NEVER", "DO NOT"
   - Tool recommendations: "use Bash", "prefer grep", "invoke"
   - Workflow patterns: Step-by-step instructions, examples
   - Authority level: Imperative vs. suggestive tone

2. Categorize competing instruction strength:
   - **High authority**: Multiple imperatives, absolute language, explicit tool directives
   - **Medium authority**: Mix of suggestions and requirements, conditional directives
   - **Low authority**: Mostly suggestive, prefer/consider language, optional guidance

3. Store analysis for Phase 3 comparison

Phase 2 complete. Continue to Phase 3.

---

## Phase 3: Structured Evaluation

**Objective**: Conduct comprehensive multi-dimensional analysis of skill description.

**THINKING CHECKPOINT**: Use `mcp__sequential-thinking__sequentialthinking` to:

### Evaluation Dimensions

Analyze the skill description across these dimensions, scoring each 0-100:

**1. User Request Pattern Matching (0-100)**

- How well does the description match common user request patterns?
- Does it include example phrases users might say?
- Are the verbs and actions natural language triggers?
- Does it cover variations of the same intent?

Consider:

- Presence of example user phrases ("saying 'X', 'Y', 'Z'")
- Verb diversity (multiple ways to express same intent)
- Natural language patterns vs. technical jargon
- Breadth of triggering scenarios

Score interpretation:

- 90-100: Excellent coverage with multiple natural variants
- 70-89: Good coverage with some variants
- 50-69: Moderate coverage, missing common variants
- 30-49: Limited coverage, too narrow or technical
- 0-29: Poor coverage, unlikely to match user requests

**2. Authority Level vs. System Prompt (0-100)**

- How authoritative is the description compared to competing instructions?
- Which authority level does it use: Replacive (80-85%), Integrative (75-80%), or Collaborative (60-70%)?
- Will it overcome competing system instructions?
- Does it integrate system terminology to appear native?

Consider:

- IF competing_instructions provided: Compare authority levels directly
- IF competing_instructions = null: Assess absolute authority level
- Language patterns: Replacive ("Primary [X] replacing..."), Integrative ("Implements [protocol]..."), Collaborative ("Automates...")
- System integration: References to protocols, safety features
- Trust signals: Automation benefits, workflow clarity, positioning indicators ("Primary", "Standard")

Score interpretation:

- 90-100: Strong authority, likely to override competing instructions
- 70-89: Good authority, competitive with most instructions
- 50-69: Moderate authority, may lose to strong imperatives
- 30-49: Weak authority, likely overshadowed by system prompts
- 0-29: Very weak, will almost never compete successfully

**3. Sonnet 4.5 Invocation Likelihood (0-100)**

- How likely is Sonnet 4.5 to invoke this skill vs. bash workflows?
- Does it emphasize automation and safety benefits?
- Is the value proposition clear for complex workflows?
- Does it integrate advanced features (sequential-thinking, MCP tools)?

Consider:

- Sonnet 4.5 characteristics: Strong reasoning, prefers structured workflows, values safety
- Competing with bash: Does description highlight advantages over manual commands?
- Complexity threshold: Is the task complex enough to warrant skill invocation?
- Safety emphasis: Does it reference protocols, validation gates, error handling?

Score interpretation:

- 90-100: Highly likely to invoke, clear complexity and safety benefits
- 70-89: Likely to invoke for appropriate tasks
- 50-69: May invoke, depends on task complexity
- 30-49: Unlikely unless explicitly guided
- 0-29: Very unlikely, would prefer bash/direct tools

**4. Haiku Invocation Likelihood (0-100)**

- How likely is Haiku to invoke this skill vs. bash workflows?
- Is the description simple and direct enough for Haiku's faster reasoning?
- Does it have clear, unambiguous triggering conditions?
- Is the value proposition immediately obvious?

Consider:

- Haiku characteristics: Faster reasoning, prefers clear directives, less exploratory
- Simplicity: Is the trigger condition obvious and unambiguous?
- Length: Shorter descriptions may work better for Haiku
- Competing with bash: Haiku more likely to default to bash without strong cues

Score interpretation:

- 90-100: Highly likely to invoke, crystal clear triggers
- 70-89: Likely to invoke with clear user intent
- 50-69: May invoke, could go either way
- 30-49: Unlikely, probably defaults to bash
- 0-29: Very unlikely, too complex or ambiguous

**5. Semantic Clarity and Discoverability (0-100)**

- Is the description self-contained and understandable?
- Does it clearly articulate when to use vs. not use the skill?
- Is the scope well-defined without ambiguity?
- Can Claude understand the skill purpose from description alone?

Consider:

- Self-documentation: Does description explain full purpose?
- Boundary clarity: When to use vs. when to use other skills?
- Technical specificity: Balance between detailed and concise
- Scannable structure: Can be quickly understood at a glance

Score interpretation:

- 90-100: Excellent clarity, completely self-documenting
- 70-89: Good clarity, minor ambiguities
- 50-69: Moderate clarity, some confusion possible
- 30-49: Poor clarity, significant ambiguity
- 0-29: Very poor, confusing or misleading

### Evaluation Process

For each dimension:

1. State the evaluation criterion
2. Analyze the skill description against the criterion
3. Compare with competing_instructions if provided (for dimension 2)
4. Consider model-specific characteristics (for dimensions 3-4)
5. Assign score (0-100) with justification
6. Note specific strengths and weaknesses

### Evaluation Output

Generate structured analysis in JSON format:

```json
{
  "description_analyzed": "<the skill description>",
  "competing_instructions": "<competing instructions or null>",
  "evaluations": {
    "user_request_matching": {
      "score": <0-100>,
      "justification": "<detailed reasoning>",
      "strengths": ["<strength 1>", "<strength 2>"],
      "weaknesses": ["<weakness 1>", "<weakness 2>"]
    },
    "authority_level": {
      "score": <0-100>,
      "justification": "<detailed reasoning>",
      "comparison": "<comparison with competing instructions if provided>",
      "strengths": ["<strength 1>", "<strength 2>"],
      "weaknesses": ["<weakness 1>", "<weakness 2>"]
    },
    "sonnet_invocation": {
      "score": <0-100>,
      "justification": "<detailed reasoning for Sonnet 4.5>",
      "strengths": ["<strength 1>", "<strength 2>"],
      "weaknesses": ["<weakness 1>", "<weakness 2>"]
    },
    "haiku_invocation": {
      "score": <0-100>,
      "justification": "<detailed reasoning for Haiku>",
      "strengths": ["<strength 1>", "<strength 2>"],
      "weaknesses": ["<weakness 1>", "<weakness 2>"]
    },
    "semantic_clarity": {
      "score": <0-100>,
      "justification": "<detailed reasoning>",
      "strengths": ["<strength 1>", "<strength 2>"],
      "weaknesses": ["<weakness 1>", "<weakness 2>"]
    }
  },
  "overall_assessment": {
    "average_score": <calculated average>,
    "grade": "<A/B/C/D/F based on average>",
    "summary": "<2-3 sentence overall assessment>"
  }
}
```

Phase 3 complete. Continue to Phase 4.

---

## Phase 4: Generate Improvement Recommendations

**Objective**: Identify actionable improvements for the skill description.

**THINKING CHECKPOINT**: Use `mcp__sequential-thinking__sequentialthinking` to:

### Recommendation Analysis

1. Review all weaknesses from Phase 3 evaluations
2. Prioritize by impact: Which improvements would yield highest score gains?
3. For each priority weakness, generate specific, actionable recommendation
4. Draft improved description incorporating top recommendations
5. Verify improved version addresses key weaknesses

### Recommendation Categories

**High Priority** (score impact: +10 to +20 points):

- Missing user request patterns → Add example phrases
- Weak authority language → Strengthen using authority spectrum (Replacive/Integrative/Collaborative)
- Unclear scope boundaries → Add "Use when" vs. "Use other skills for" clarity
- Missing value proposition → Add automation/safety benefits

**Medium Priority** (score impact: +5 to +10 points):

- Technical jargon → Simplify for better matching
- Ambiguous triggers → Make conditions more explicit
- Length issues → Optimize for target word count (45-52)
- Missing system integration → Add protocol/safety references

**Low Priority** (score impact: +1 to +5 points):

- Minor wording improvements
- Additional example phrases
- Formatting consistency
- Tone adjustments

### Recommendation Output

Generate recommendations in structured format:

```json
{
  "recommendations": [
    {
      "priority": "<high|medium|low>",
      "dimension": "<which evaluation dimension>",
      "issue": "<specific weakness identified>",
      "recommendation": "<actionable improvement>",
      "example": "<concrete example or before/after>",
      "estimated_impact": "<score point improvement>"
    }
  ],
  "improved_description": "<rewritten description incorporating high priority recommendations>",
  "improvement_summary": "<explanation of changes made>"
}
```

Phase 4 complete. Continue to Phase 5.

---

## Phase 5: Present Results

**Objective**: Deliver comprehensive evaluation report with standardized formatting.

**Steps**:

1. Combine outputs from Phases 3 and 4
2. Format using standardized reporting template:

```text
✓ Skill Description Evaluation Completed

OVERALL GRADE: <grade> (Average Score: <average>/100)

SCORES BY DIMENSION:
- User Request Matching: <score>/100
- Authority Level: <score>/100
- Sonnet 4.5 Invocation: <score>/100
- Haiku Invocation: <score>/100
- Semantic Clarity: <score>/100

KEY STRENGTHS:
<bullet list of top 3 strengths across all dimensions>

KEY WEAKNESSES:
<bullet list of top 3 weaknesses across all dimensions>

TOP RECOMMENDATIONS:
<numbered list of high priority recommendations with estimated impact>

IMPROVED DESCRIPTION:
---
<improved description text>
---

DETAILED ANALYSIS:
<full JSON output from Phase 3 for reference>
```

1. Present report to user

2. Optionally ask: "Would you like me to save this evaluation report to a file?"
   - IF yes: Use Write tool to save as markdown file
   - IF no: Complete workflow

Phase 5 complete. Workflow complete.

---

## Implementation Notes

### Model-Specific Considerations

**Sonnet 4.5**:

- Strong reasoning capabilities favor complex, multi-phase workflows
- Values safety protocols and validation gates
- More likely to invoke skills that emphasize automation benefits
- Can handle longer, more detailed descriptions
- Looks for integration with advanced features (sequential-thinking, MCP)

**Haiku**:

- Faster reasoning prefers clear, simple triggers
- More likely to default to bash for straightforward tasks
- Shorter descriptions may perform better
- Needs very obvious value proposition
- Simpler language and fewer clauses work better

### Evaluation Framework

Refer to reference.md for:

- Detailed scoring rubrics
- Model invocation pattern analysis
- Example evaluations with before/after
- Best practices for skill description writing

### Output Formats

This is a user-facing skill that uses standardized reporting templates for consistency and professionalism. The detailed JSON analysis is included for reference but presented after the human-readable summary.
