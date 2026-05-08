---
name: ctx:researcher
description: Efficiently research topics using parallel agents via Contextune's /ctx:research command. Use when users ask to research, investigate, find information about topics, compare options, or evaluate libraries/tools. Activate for questions like "research best X", "what's the best library for Y", or "investigate Z".
keywords:
  - research
  - investigate
  - find information
  - compare
  - whats the best
  - which library
  - evaluate options
---

# CTX:Researcher Skill

Efficiently research topics using parallel agents via Contextune's `/ctx:research` command.

## When to Activate

This skill should be used when the user:
- Explicitly mentions: "research", "investigate", "find information about", "look into"
- Asks comparative questions: "what's the best X for Y?", "compare A and B"
- Requests library/tool evaluations: "which library should I use?"
- Wants to understand solutions: "how do other projects handle X?"

## What This Skill Does

When activated, this skill executes the `/ctx:research` command which:

1. **Spawns 3 parallel Haiku agents** (~$0.07, 1-2 minutes):
   - **Agent 1**: Web search for similar solutions and implementations
   - **Agent 2**: Web search for libraries, tools, and frameworks
   - **Agent 3**: Codebase pattern analysis (existing approaches)

2. **Returns comprehensive research** including:
   - Top 3-5 options with pros/cons
   - Implementation examples
   - Migration/adoption considerations
   - Community adoption and maturity

## Workflow

### Step 1: Execute the Research Command

```
/ctx:research [user's query]
```

**Important**: Pass the user's query verbatim to capture intent.

### Step 2: Wait for Results

The command runs in background. You'll receive results from all 3 agents simultaneously.

### Step 3: Synthesize Findings

Present results in this structure:

```markdown
## Research Findings: [Topic]

### Summary
[1-2 sentence overview of landscape]

### Top Options

#### 1. [Option Name] ⭐ Recommended
- **Pros**: [key advantages]
- **Cons**: [key drawbacks]
- **Best for**: [use cases]
- **Adoption**: [community size, maturity]

#### 2. [Option Name]
[same structure]

#### 3. [Option Name]
[same structure]

### Implementation Examples
[Code snippets or links if available]

### Migration Considerations
- [Key steps to adopt]
- [Potential challenges]
- [Time/effort estimation]

### Recommendation
[Clear recommendation based on user's context]
```

## Example Usage

**User Query:**
```
research best React state management libraries
```

**Your Action:**
```
/ctx:research best React state management libraries 2025
```

**Expected Output After Agents Complete:**
```markdown
## Research Findings: React State Management (2025)

### Summary
The React state management landscape has matured significantly, with Zustand and Jotai emerging as modern alternatives to Redux, optimized for React 18+ features.

### Top Options

#### 1. Zustand ⭐ Recommended
- **Pros**:
  - Minimal boilerplate (~1KB)
  - TypeScript-first design
  - No providers needed
  - React 18 concurrent mode support

- **Cons**:
  - Smaller ecosystem than Redux
  - Less established patterns for large apps

- **Best for**: New projects, simple-medium complexity, teams wanting minimal setup
- **Adoption**: 40K+ GitHub stars, growing rapidly

#### 2. Jotai
- **Pros**:
  - Atomic state model
  - Excellent TypeScript inference
  - Built for React 18

- **Cons**:
  - Steeper learning curve (atomic concepts)
  - Newer, less community content

- **Best for**: Complex state requirements, fine-grained reactivity
- **Adoption**: 15K+ stars, backed by Poimandres team

#### 3. Redux Toolkit
- **Pros**:
  - Mature, massive ecosystem
  - Excellent DevTools
  - Industry standard

- **Cons**:
  - More boilerplate
  - Provider setup required

- **Best for**: Large teams, existing Redux codebases, need for middleware
- **Adoption**: 60K+ stars (core Redux), widely used in enterprise

### Recommendation

For your project, I recommend **Zustand** because:
- Modern codebase starting fresh
- Team values simplicity over complexity
- Don't need advanced middleware ecosystem
- Want TypeScript-first experience

Migration from existing useState: ~2-4 hours for typical app.
```

## Integration Notes

- This skill wraps the `/ctx:research` command for seamless execution
- The command is part of the Contextune plugin
- Research is grounded in current date (avoids outdated results)
- Agents search web + analyze existing codebase patterns

## Error Handling

If `/ctx:research` fails:
1. Check if Contextune plugin is installed
2. Verify user has run `/ctx:configure` for setup
3. Fall back to manual web search if needed

## Tips for Best Results

- **Be specific**: "React state management 2025" better than just "state management"
- **Include context**: "for real-time chat app" helps agents focus
- **Specify constraints**: "must be TypeScript-first" filters results
- **Current year**: Always include year for technology research (2025)
