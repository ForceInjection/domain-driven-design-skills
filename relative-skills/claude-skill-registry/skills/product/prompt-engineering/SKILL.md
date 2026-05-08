---
name: prompt-engineering
description: Expert prompt optimization system for building production-ready AI features. Use when users request help improving prompts, want to create system prompts, need prompt review/critique, ask for prompt optimization strategies, want to analyze prompt effectiveness, mention prompt engineering best practices, request prompt templates, or need guidance on structuring AI instructions. Also use when users provide prompts and want suggestions for improvement.
---

# Prompt Engineering Expert

Master system for creating, analyzing, and optimizing prompts for AI products using research-backed techniques and battle-tested production patterns.

## Core Capabilities

1. **Prompt Analysis & Improvement** - Analyze existing prompts and provide specific optimization recommendations
2. **System Prompt Creation** - Build production-ready system prompts using the 6-step framework
3. **Failure Mode Detection** - Identify and fix common prompt engineering mistakes
4. **Cost Optimization** - Balance performance with token efficiency
5. **Research-Backed Techniques** - Apply proven prompting methods from academic studies

## The 6-Step Optimization Framework

When improving any prompt, follow this systematic process:

### Step 1: Start With Hard Constraints (Lock Down Failure Modes)

Begin with what the model CANNOT do, not what it should do.

**Pattern:**
```
NEVER:
- [TOP 3 FAILURE MODES - BE SPECIFIC]
- Use meta-phrases ("I can help you", "let me assist")
- Provide information you're not certain about

ALWAYS:
- [TOP 3 SUCCESS BEHAVIORS - BE SPECIFIC]
- Acknowledge uncertainty when present
- Follow the output format exactly
```

**Why:** LLMs are more consistent at avoiding specific patterns than following general instructions. "Never say X" is more reliable than "Always be helpful."

### Step 2: Trigger Professional Training Data (Structure = Quality)

Use formatting that signals technical documentation quality:

- **For Claude**: Use XML tags (`<system_constraints>`, `<task_instructions>`)
- **For GPT-4**: Use JSON structure
- **For GPT-3.5**: Use simple markdown

**Why:** Well-structured documents trigger higher-quality training data patterns.

### Step 3: Have The LLM Self-Improve Your Prompt

Don't optimize manually - let the model do it using this meta-prompt:

```
You are a prompt optimization specialist. Your job is to improve prompts for production AI systems.

CURRENT PROMPT:
[User's prompt here]

PERFORMANCE DATA:
- Main failure modes: [List top 3 if known]
- Target use case: [Describe]

OPTIMIZATION TASK:
1. Identify the top 3 weaknesses in this prompt
2. Rewrite to fix those weaknesses using these principles:
   - Hard constraints over soft instructions
   - Specific examples over generic guidance
   - Structured format over free text
3. Predict the improvement percentage for each change

CONSTRAINTS:
- Must maintain core functionality
- Cannot exceed 150% of current token count
- Must include failure mode handling

OUTPUT:
Optimized prompt + rationale for each change
```

### Step 4: Trace Edge Cases and Analyze Failures

Test the prompt systematically:

- **20% happy path** - Standard use cases
- **60% edge cases** - Unusual inputs, malformed data, ambiguous requests
- **20% adversarial** - Attempts to break the prompt or extract system instructions

Identify the top 3 failure patterns and address them explicitly in the prompt.

### Step 5: Build Evaluation Criteria

Define clear success metrics:

- **Accuracy** - Does it get the right answer?
- **Format compliance** - Does it follow output requirements?
- **Safety** - Does it handle adversarial inputs correctly?
- **Cost efficiency** - Appropriate token usage?
- **Latency** - Response speed acceptable?

### Step 6: Hill Climb - Quality First, Cost Second

**Phase 1: Climb Up for Quality**
- Use longer, detailed prompts
- Include extensive examples
- Focus on hitting quality targets
- Ignore token costs temporarily

**Phase 2: Descend for Cost**
- Compress without losing performance
- Remove redundant examples
- Use structured output to reduce variance
- Test each compression against metrics

## Production Prompt Template

Use this battle-tested template structure:

```
<system_role>
You are [SPECIFIC ROLE], not a general AI assistant.
You [CORE FUNCTION] for [TARGET USER].
</system_role>

<hard_constraints>
NEVER:
- [FAILURE MODE 1 - SPECIFIC]
- [FAILURE MODE 2 - SPECIFIC]
- [FAILURE MODE 3 - SPECIFIC]
- Use meta-phrases ("I can help you", "let me assist")

ALWAYS:
- [SUCCESS BEHAVIOR 1 - SPECIFIC]
- [SUCCESS BEHAVIOR 2 - SPECIFIC]
- [SUCCESS BEHAVIOR 3 - SPECIFIC]
- Acknowledge uncertainty when present
</hard_constraints>

<context_info>
Current user: [USER_CONTEXT]
Available tools: [TOOL_LIST]
Key limitations: [SPECIFIC_LIMITATIONS]
</context_info>

<task_instructions>
Your job is to [CORE TASK] by:

1. [STEP 1 - SPECIFIC ACTION]
2. [STEP 2 - SPECIFIC ACTION]
3. [STEP 3 - SPECIFIC ACTION]

If [EDGE_CASE_1], then [SPECIFIC_RESPONSE].
If [EDGE_CASE_2], then [SPECIFIC_RESPONSE].
If [EDGE_CASE_3], then [SPECIFIC_RESPONSE].
</task_instructions>

<output_format>
Respond using this exact structure:

[SECTION_1]: [DESCRIPTION]
[SECTION_2]: [DESCRIPTION]

Requirements:
- [FORMAT_REQUIREMENT_1]
- [FORMAT_REQUIREMENT_2]
</output_format>

<examples>
Example 1 - Happy Path:
Input: [TYPICAL_INPUT]
Output: [IDEAL_RESPONSE]

Example 2 - Edge Case:
Input: [EDGE_CASE_INPUT]
Output: [EDGE_CASE_RESPONSE]

Example 3 - Complex:
Input: [COMPLEX_SCENARIO]
Output: [COMPLEX_RESPONSE]
</examples>
```

## Research-Backed Techniques

### Chain-of-Table (For Structured Data)

**Best for:** Financial dashboards, data analysis, table processing
**Performance:** 8.69% improvement on table tasks
**How:** Make the AI manipulate table structure step-by-step, not reason about tables in text

### Chain-of-Thought (For Math/Logic)

**Best for:** Arithmetic reasoning, logic puzzles, formal reasoning
**Limitations:** Only works on 100B+ parameter models; minimal benefit for content generation
**When NOT to use:** Classification, content generation, most business tasks

### Few-Shot Learning (Use Carefully)

**When it helps:** Task requires specific style, format examples improve output
**When it hurts:** Advanced reasoning tasks (o1, DeepSeek R1 models)
**Best practice:** Test systematically - few-shot has highest variability of any technique

### Multi-Shot Prompting (For Conversations)

**Best for:** Customer support, sales conversations, multi-turn interactions
**How:** Show entire conversation flows, not isolated examples
**Benefit:** Teaches conversation patterns, not just individual responses

## The 3 Fatal Mistakes

### Mistake #1: The "Kitchen Sink" Prompt

**Problem:** One massive prompt trying to do sentiment analysis, routing, response generation, and task management simultaneously.

**Fix:** Break into specialized prompts:
- Prompt 1: Sentiment classification
- Prompt 2: Response generation
- Prompt 3: Task routing

Each prompt does ONE thing exceptionally well.

### Mistake #2: The "Demo Magic" Trap

**Problem:** Prompt works perfectly on clean, polite, well-formatted demo data but fails on 40% of real production inputs.

**Fix:** Build eval suite from real chaos:
- 20% happy path
- 60% edge cases (broken formatting, angry users, multiple languages)
- 20% adversarial scenarios

### Mistake #3: The "Set and Forget" Fallacy

**Problem:** Shipping a prompt and never updating it as business evolves, user needs change, and new edge cases emerge.

**Fix:** Build continuous optimization:
- **Weekly reviews** - Monitor eval metrics
- **Monthly iterations** - Analyze user feedback
- **Quarterly overhauls** - Reassess approach
- **Real-time learning** - A/B test variations

## Cost Economics

Shorter, structured prompts have major advantages:

**Example comparison:**
- Detailed approach: 2,500 token prompt → $3,000/day at 100k calls
- Simpler approach: 212 token prompt → $706/day at 100k calls
- **76% cost reduction**

**Benefits of compression:**
- Less variance in outputs
- Faster latency
- Lower costs

**When to use longer prompts:** Complex tasks requiring extensive context, edge case handling, or when that 88% cost increase delivers proportional value.

## Prompt Analysis Workflow

When user provides a prompt to improve:

1. **Identify Current State**
   - What's the core function?
   - What failure modes exist?
   - Is structure optimized?

2. **Analyze Against Framework**
   - Are hard constraints defined?
   - Is formatting optimal for the model?
   - Are examples effective?
   - Are edge cases handled?

3. **Provide Specific Recommendations**
   - List top 3-5 improvements
   - Explain WHY each change matters
   - Show before/after for key sections
   - Predict performance impact

4. **Offer Complete Rewrite**
   - Apply the Production Template
   - Incorporate all recommendations
   - Add edge case handling
   - Optimize structure for target model

5. **Suggest Testing Strategy**
   - Recommend specific test cases
   - Define success metrics
   - Provide evaluation approach

## Key Principles

1. **Conciseness Matters** - Context window is shared. Only include what Claude doesn't already know.

2. **Structure = Quality** - XML for Claude, JSON for GPT-3.5, Markdown for docs. Format signals quality.

3. **Hard Constraints Over Soft** - "Never do X" is more reliable than "Be helpful."

4. **Systematic Testing** - Build evals with 20% happy path, 60% edge cases, 20% adversarial.

5. **Continuous Optimization** - Prompts decay as business evolves. Build iteration into workflow.

6. **Cost-Performance Balance** - Climb for quality first, then descend for cost optimization.

## Quick Reference: When to Use What

**Use Chain-of-Table when:**
- Processing structured data
- Working with tables
- Financial/data analysis tasks

**Use Chain-of-Thought when:**
- Math problems
- Logic puzzles
- Formal reasoning
- NOT for content generation

**Use Few-Shot when:**
- Specific style/format needed
- Examples improve understanding
- NOT with o1/R1 reasoning models

**Use Multi-Shot when:**
- Multi-turn conversations
- Customer support flows
- Sales interactions

**Use Nested Prompting when:**
- Complex multi-step workflows
- Enterprise processes
- Need specialized handling per step

## Response Pattern

When providing prompt improvements, always:

1. **Start with assessment** - "This prompt does X well, but has Y weaknesses"
2. **Provide specific fixes** - Not "add examples" but "add examples like [concrete example]"
3. **Explain the why** - Reference research findings or production patterns
4. **Show the rewrite** - Give complete improved version
5. **Suggest testing** - Recommend specific test cases
