---
name: research-orchestration
description: Use when brainstorming completes and user selects research-first option - manages parallel research subagents (up to 4) across codebase, library docs, web, and GitHub sources, synthesizing findings and auto-saving to memory before planning
---

# Research Orchestration

Use this skill to manage parallel research subagents and synthesize findings from multiple sources.

## When to Use

After brainstorming completes and user selects "B) research first" option.

## Selection Algorithm

### Default Selection

Based on brainstorm context, intelligently select researchers:

**serena-explorer** [✓ ALWAYS]
- Always need codebase understanding
- No keywords required - default ON

**context7-researcher** [✓ if library mentioned]
- Select if: new library, framework, official docs needed
- Keywords: "using [library]", "integrate [framework]", "best practices for [tool]"
- Example: "using React hooks" → ON

**web-researcher** [✓ if patterns mentioned]
- Select if: best practices, tutorials, modern approaches, expert opinions
- Keywords: "industry standard", "common pattern", "how to", "best approach"
- Example: "authentication best practices" → ON

**github-researcher** [☐ usually OFF]
- Select if: known issues, community solutions, similar features, troubleshooting
- Keywords: "GitHub issue", "others solved", "similar to [project]", "known problems"
- Example: "known issues with SSR" → ON

### User Presentation

Present recommendations with context:

```markdown
Based on the brainstorm, I recommend these researchers:

[✓] Codebase (serena-explorer)
    → Understand current architecture and integration points

[✓] Library docs (context7-researcher)
    → React hooks patterns and official recommendations

[✓] Web (web-researcher)
    → Authentication best practices and security patterns

[ ] GitHub (github-researcher)
    → Not needed unless we hit specific issues

Adjust selection? (Y/n)
```

If **Y**: Interactive toggle
```
Toggle researchers: (C)odebase (L)ibrary (W)eb (G)itHub (D)one
User input: L G D
Result: Toggled OFF context7-researcher, ON github-researcher, Done
```

If **n**: Use defaults and proceed

## Spawning Subagents

**Run up to 4 in parallel** using Task tool:

```typescript
// Spawn all selected researchers in parallel
const results = await Promise.all([
  // Always spawn serena-explorer
  Task({
    subagent_type: "serena-explorer",
    description: "Explore codebase architecture",
    prompt: `
      Analyze the current codebase for ${feature} implementation.

      Find:
      - Current architecture relevant to ${feature}
      - Similar existing implementations we can learn from
      - Integration points where ${feature} should hook in
      - Patterns used in similar features

      Provide all findings with file:line references.
    `
  }),

  // Conditionally spawn context7-researcher
  ...(useContext7 ? [Task({
    subagent_type: "context7-researcher",
    description: "Research library documentation",
    prompt: `
      Research official documentation for ${libraries}.

      Find:
      - Recommended patterns for ${useCase}
      - API best practices and examples
      - Security considerations
      - Performance recommendations

      Include Context7 IDs, benchmark scores, and code examples.
    `
  })] : []),

  // Conditionally spawn web-researcher
  ...(useWeb ? [Task({
    subagent_type: "web-researcher",
    description: "Research best practices",
    prompt: `
      Search for ${topic} best practices and expert opinions.

      Find:
      - Industry standard approaches for ${useCase}
      - Recent articles (2024-2025) on ${topic}
      - Expert recommendations with rationale
      - Common gotchas and solutions

      Cite sources with authority assessment and publication dates.
    `
  })] : []),

  // Conditionally spawn github-researcher
  ...(useGithub ? [Task({
    subagent_type: "github-researcher",
    description: "Research GitHub issues/PRs",
    prompt: `
      Search GitHub for ${topic} issues and solutions.

      Find:
      - Closed issues related to ${problem}
      - Merged PRs implementing ${feature}
      - Community discussions on ${topic}
      - Known gotchas and workarounds

      Focus on ${relevantRepos} repositories.
      Provide issue links, status, and consensus solutions.
    `
  })] : [])
])
```

**Key points:**
- All spawned in single Task call block (parallel execution)
- Each has specific prompt tailored to feature context
- Prompts reference brainstorm decisions
- Results returned when all complete

## Synthesis

After all subagents complete, synthesize findings:

### Structure

```markdown
# Research: ${feature-name}

## Brainstorm Summary

${brief-summary-of-brainstorm-decisions}

## Codebase Findings (serena-explorer)

### Current Architecture
- **${component}:** `${file}:${line}`
  - ${description}

### Similar Implementations
- **${existing-feature}:** `${file}:${line}`
  - ${pattern-used}
  - ${why-relevant}

### Integration Points
- **${location}:** `${file}:${line}`
  - ${how-to-hook-in}

## Library Documentation (context7-researcher)

### ${Library-Name}
**Context7 ID:** ${id}
**Benchmark Score:** ${score}

**Relevant APIs:**
- **${api-name}:** ${description}
  ```${lang}
  ${code-example}
  ```

**Best Practices:**
1. ${practice-1}
2. ${practice-2}

## Web Research (web-researcher)

### ${Topic}

**Source:** ${author} - "${title}" (${date})
**Authority:** ${stars} (${justification})
**URL:** ${url}

**Key Recommendations:**
1. **${recommendation}**
   > "${quote}"

   - ${implementation-detail}

**Trade-offs:**
- ${trade-off-1}
- ${trade-off-2}

## GitHub Research (github-researcher)

### ${Issue-Topic}

**Source:** ${repo}#${number} (${status})
**URL:** ${url}

**Problem:** ${description}

**Solution:**
```${lang}
${code-example}
```

**Caveats:**
- ${caveat-1}
- ${caveat-2}

## Synthesis

### Recommended Approach

Based on all research, recommend ${approach} because:

1. **Codebase fit:** ${how-it-fits-existing-patterns}
2. **Library support:** ${official-patterns-available}
3. **Industry proven:** ${expert-consensus}
4. **Community validated:** ${github-evidence}

### Key Decisions

- **${decision-1}:** ${rationale}
- **${decision-2}:** ${rationale}

### Risks & Mitigations

- **Risk:** ${risk}
  - **Mitigation:** ${mitigation}

## Next Steps

Ready to write implementation plan with this research context.
```

## Auto-Save

After synthesis completes, automatically save to memory:

```typescript
// Use state-persistence skill
await saveResearchMemory({
  feature: extractFeatureName(brainstorm),
  content: synthesizedResearch,
  type: "research"
})
```

**Filename:** `YYYY-MM-DD-${feature-name}-research.md`

**Location:** Serena MCP memory (via write_memory tool)

## Handoff

After save completes, report to user:

```markdown
Research complete and saved to memory: ${filename}

I've synthesized findings from ${count} sources:
- Codebase: ${summary-of-serena-findings}
- Library docs: ${summary-of-context7-findings}
- Web: ${summary-of-web-findings}
- GitHub: ${summary-of-github-findings}

Key recommendation: ${one-sentence-approach}

Ready to write the implementation plan with this research context.
```

Then invoke `writing-plans` skill automatically.

## Error Handling

**If subagent fails:**
1. Continue with other subagents
2. Note missing research in synthesis
3. Offer to re-run failed researcher

**If no results found:**
1. Note in synthesis
2. Don't block workflow
3. Proceed with available research

**If all subagents fail:**
1. Report failure
2. Offer to proceed without research
3. User can retry or continue to planning
