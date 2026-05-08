---
name: consultant
description: Multi-model AI consultation and research. Supports CONSULTATION MODE (ask single expert), RESEARCH MODE (parallel multi-agent), or DELIBERATION MODE (agents debate and refine). USE WHEN user says 'ask gemini', 'consult codex' (consultation), 'do research' (research), or 'deliberate on' (deliberation).
---

# Consultant Skill

## Three Operation Modes

### CONSULTATION MODE (Single Expert)
Ask a specific AI model for focused analysis or second opinion.

**Trigger Patterns:**
- "Ask [model] about X"
- "Consult [model] on Y"
- "What does [model] think about Z"
- "Get [model]'s opinion on X"
- "[Model], analyze this problem"

**Available Consultants:**
- **codex** / **gpt5** - OpenAI GPT-5 Codex (advanced reasoning, technical analysis)
- **gemini** - Google Gemini (multi-perspective analysis)
- **grok** - xAI Grok (alternative LLM perspective)
- **perplexity** - Perplexity Sonar (web research with citations)
- **claude** - Claude WebSearch (web research, detailed analysis)

**Examples:**
- "Ask Gemini about the best approach to implement this feature"
- "Consult Codex on this architectural decision"
- "What does Grok think about this code pattern?"
- "Get Perplexity's research on latest React trends"

### RESEARCH MODE (Multi-Agent Parallel)
Launch multiple agents simultaneously for comprehensive coverage.

**Trigger Patterns:**
- "Do research on X"
- "Quick research: X"
- "Extensive research on X"
- "Research this topic"
- "Investigate X"

**Three Research Intensities:**

#### QUICK RESEARCH
- Launch 5 agents (1 of each type)
- Timeout: 2 minutes
- Best for: Simple queries, fast answers

#### STANDARD RESEARCH (Default)
- Launch 15 agents (3 of each type)
- Timeout: 3 minutes
- Best for: Comprehensive coverage, balanced depth

#### EXTENSIVE RESEARCH
- Launch 40 agents (8 of each type)
- Timeout: 10 minutes
- Best for: Deep-dive analysis, exhaustive reports

### DELIBERATION MODE (Multi-Round Debate)
Agents critique each other's answers and refine through peer review.

**Trigger Patterns:**
- "Deliberate on X"
- "Have the consultants debate X"
- "What do the models think about X after discussing?"
- "Peer review: X"

**How It Works:**

**Round 1: Initial Perspectives (all 5 agents)**
- Each agent provides initial analysis independently
- No agent sees others' responses yet

**Round 2: Critique & Challenge (all 5 agents)**
- Share all Round 1 responses with all agents
- Each agent reviews others' answers
- Point out errors, gaps, strong points
- Challenge assumptions
- Add missing information

**Round 3: Refinement (all 5 agents)**
- Share all critiques
- Agents revise their positions based on feedback
- Acknowledge valid points from others
- Defend or modify their stance
- Identify emerging consensus

**Round 4: Final Synthesis (main session)**
- Analyze convergence vs divergence
- Highlight consensus points (all/most agents agree)
- Present unresolved disagreements with reasoning from each side
- Rate confidence based on agent agreement

**Timeout:** 5 minutes total (agents work in rounds)

**Best for:**
- Critical decisions needing peer review
- Complex problems where single perspective is risky
- Catching errors through multiple reviews
- Finding consensus among experts
- Identifying trade-offs through debate

**Example:**
```
User: "Deliberate on: Should we use REST or GraphQL for our API?"

Round 1 (Initial):
- Codex: "GraphQL for flexible querying"
- Gemini: "REST for simplicity"
- Perplexity: [web research on adoption trends]

Round 2 (Critique):
- Codex: "Gemini's simplicity claim ignores client complexity - REST needs many endpoints"
- Gemini: "Codex didn't mention GraphQL's caching challenges"
- Perplexity: "Both missing recent data: GraphQL adoption is 45% in 2025"

Round 3 (Refinement):
- Codex: "Valid point on caching. Recommend REST for simple CRUD, GraphQL for complex reads"
- Gemini: "Agree with Codex's nuanced position"
- Consensus: Both viable, choose based on read complexity

Synthesis:
- CONSENSUS: Use REST for simple APIs, GraphQL for complex data fetching
- AGREEMENT: Both have trade-offs, no universal answer
- DISAGREEMENT: None (all converged)
```

## Available Agents

- **perplexity-researcher**: Web search with Perplexity Sonar models
- **claude-researcher**: Web search with Claude WebSearch
- **gemini-researcher**: Analysis with Google Gemini
- **codex-researcher**: Deep analysis with GPT-5 Codex
- **grok-researcher**: Analysis with xAI Grok

## How Consultation Mode Works

1. **Detect consultation request** from trigger patterns
2. **Identify target model** (gemini, codex, grok, perplexity, claude)
3. **Launch single agent** of that type
4. **Return focused analysis** from that one expert

**Speed**: ~10-30 seconds per consultation

## How Research Mode Works

1. **Query Decomposition**: Break into 5-40 sub-questions
2. **Parallel Launch**: All agents in SINGLE message
3. **Collection**: Wait for timeout (2/3/10 minutes)
4. **Synthesis**: Integrate findings with confidence ratings

**Speed**:
- Quick: ~30-60 seconds
- Standard: ~30-90 seconds
- Extensive: ~1-3 minutes

## Agent Capabilities

**Web Search Agents:**
- perplexity: Citations, Sonar models, current data
- claude: Built-in WebSearch, detailed analysis

**LLM Analysis Agents:**
- codex: GPT-5 with high reasoning, technical deep-dives
- gemini: Multi-perspective synthesis
- grok: Alternative LLM perspective

## Best Practices

**For Consultation:**
- Use when you want ONE expert opinion
- Good for second opinions, alternative perspectives
- Faster and cheaper than research mode

**For Research:**
- Use when you need comprehensive coverage
- Multiple perspectives reveal blind spots
- Higher confidence through corroboration

**Agent Selection:**
- Codex/GPT-5: Complex technical problems, deep reasoning
- Gemini: Creative solutions, multi-angle analysis
- Grok: Alternative perspective, different training data
- Perplexity: Current web information, citations needed
- Claude: Web research, detailed synthesis
