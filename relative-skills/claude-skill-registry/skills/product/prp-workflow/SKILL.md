---
name: prp-workflow
description: Comprehensive PRP (Product Requirements Prompt) workflow for feature implementation. Use when user wants to implement complex features, needs a structured implementation plan, or mentions PRPs, feature implementation, or systematic development. Handles PRP generation from requirements, clarification of ambiguities, and execution for implementation. Three modes - Generation (create PRP), Clarification (resolve ambiguities), Execution (implement feature).
---

# PRP Workflow Skill

This skill implements a comprehensive Product Requirements Prompt (PRP) workflow for systematic feature implementation with proper context engineering.

## When to Use This Skill

Activate this skill when the user:

- Mentions implementing a new feature or component
- Asks to create a PRP or use the PRP workflow
- Needs a systematic approach to complex development tasks
- Wants comprehensive planning before implementation
- References feature files or implementation requirements
- Mentions PRPs, context engineering, or structured development

## Core Concepts

### What is a PRP?

A PRP (Product Requirements Prompt) is similar to a PRD (Product Requirements Document) but specifically engineered for AI coding assistants. It includes:

- **Complete Context**: All documentation, examples, and patterns needed
- **Implementation Blueprint**: Step-by-step tasks with pseudocode
- **Validation Gates**: Executable tests and checks for self-correction
- **Error Handling**: Common pitfalls and gotchas
- **Success Criteria**: Clear measurable outcomes

### Why PRPs Work

1. **Context is King**: AI failures are usually context failures, not model failures
2. **Self-Validation**: Built-in validation loops allow iterative refinement
3. **Pattern Following**: References to existing code ensure consistency
4. **One-Pass Success**: Comprehensive context enables working code on first try

## Workflow Modes

This skill operates in three modes:

### Mode 1: PRP Generation

Generate a comprehensive PRP from a feature request or requirements document.

### Mode 2: PRP Clarification

Identify and resolve underspecified areas in an existing PRP through structured questioning (recommended before execution).

### Mode 3: PRP Execution

Implement a feature using an existing PRP file.

## Mode 1: PRP Generation

### Input Requirements

The user should provide:

- Feature description (can be a file path or inline description)
- Examples to follow (if available)
- Documentation references (API docs, libraries, etc.)
- Other considerations (gotchas, constraints, requirements)

### Research Process

Before generating the PRP, conduct thorough research:

#### 1. Codebase Analysis

- Search for similar features/patterns in the codebase using Grep and Glob
- Identify files to reference in the PRP
- Note existing conventions to follow (imports, structure, naming)
- Check test patterns for validation approach
- Run `tree` command to understand project structure

#### 2. External Research

- Search for similar features/patterns online using WebSearch
- Find library documentation (include specific URLs)
- Look for implementation examples (GitHub/StackOverflow/blogs)
- Research best practices and common pitfalls
- Include version-specific gotchas

#### 3. User Clarification (if needed)

Use AskUserQuestion tool to clarify:

- Specific patterns to mirror and where to find them
- Integration requirements and dependencies
- Authentication or configuration needs
- Performance requirements

### PRP Generation Structure

Create a comprehensive PRP using this structure:

````yaml
name: "[Feature Name] PRP"
description: |

## Purpose
[What this PRP enables the AI to build]

## Core Principles
1. **Context is King**: Include ALL necessary documentation, examples, and caveats
2. **Validation Loops**: Provide executable tests/lints the AI can run and fix
3. **Information Dense**: Use keywords and patterns from the codebase
4. **Progressive Success**: Start simple, validate, then enhance
5. **Global rules**: Follow all rules in CLAUDE.md (if exists)

---

## Goal
[What needs to be built - be specific about the end state]

## Why
- [Business value and user impact]
- [Integration with existing features]
- [Problems this solves and for whom]

## What
[User-visible behavior and technical requirements]

### Success Criteria
- [ ] [Specific measurable outcome 1]
- [ ] [Specific measurable outcome 2]
- [ ] [Specific measurable outcome 3]

## All Needed Context

### Documentation & References
```yaml
# MUST READ - Include these in your context window
- url: [Official API docs URL]
  why: [Specific sections/methods you'll need]

- file: [path/to/example.py]
  why: [Pattern to follow, gotchas to avoid]

- doc: [Library documentation URL]
  section: [Specific section]
  critical: [Key insight that prevents common errors]

- docfile: [specs/ai_docs/file.md]
  why: [User-provided documentation]
````

### Current Codebase Tree

```bash
[Output from tree command - shows current structure]
```

### Desired Codebase Tree

```bash
[New files to be added with their responsibilities]
```

### Known Gotchas & Library Quirks

```python
# CRITICAL: [Library name] requires [specific setup]
# CRITICAL: [Framework] version [X] has [specific behavior]
# CRITICAL: [Common pitfall to avoid]
```

## Implementation Blueprint

### Data Models and Structure

[Define core data structures, Pydantic models, ORM models, etc.]

### List of Tasks

```yaml
Task 1: [Task Name]
  MODIFY/CREATE [file path]:
    - [Specific action 1]
    - [Specific action 2]
  PATTERN: [Reference to similar code]

Task 2: [Task Name]
  ...

Task N: [Final Task]
  ...
```

### Per Task Pseudocode

```python
# Task 1: [Task Name]
# High-level pseudocode showing CRITICAL details
def feature_function(param: Type) -> Result:
    # PATTERN: Always validate input (see file:line)
    # GOTCHA: This library requires X
    # CRITICAL: API has rate limit of Y
    pass
```

### Integration Points

```yaml
DATABASE:
  - migration: [SQL or migration description]
  - index: [Index requirements]

CONFIG:
  - add to: [config file path]
  - pattern: [How to add config]

ROUTES/ENDPOINTS:
  - add to: [router file]
  - pattern: [How to register]
```

## Validation Loop

### Level 1: Syntax & Style

```bash
# Language-specific linting commands
# Examples:
# Python: ruff check . --fix && mypy .
# TypeScript: eslint . --fix && tsc --noEmit
# Go: go fmt ./... && go vet ./...
```

### Level 2: Unit Tests

```python
# Define required test cases:
# 1. Happy path test
# 2. Edge case test
# 3. Error handling test
```

```bash
# Run command
# Example: pytest tests/ -v
```

### Level 3: Integration Test

```bash
# Manual test commands
# Example: curl commands, CLI commands, etc.
```

## Final Validation Checklist

- [ ] All tests pass
- [ ] No linting errors
- [ ] No type errors
- [ ] Manual test successful
- [ ] Error cases handled
- [ ] Documentation updated

---

## Anti-Patterns to Avoid

- ❌ Don't create new patterns when existing ones work
- ❌ Don't skip validation steps
- ❌ Don't ignore failing tests
- ❌ Don't hardcode values that should be config
- ❌ [Domain-specific anti-patterns]

```

### PRP Output

**CRITICAL: Always save PRPs in the `specs` directory with auto-incrementing naming**

Follow this process:
1. Ensure the `specs` directory exists (create if needed)
2. Find the highest numbered PRP in `specs` (e.g., if `003-auth.md` exists, next is 004)
3. Generate a sensible kebab-case filename from the feature name (e.g., "User Authentication" → "user-authentication")
4. Save as `specs/{XXX}-{feature-name}.md` where XXX is zero-padded 3-digit number

Examples:
- First PRP: `specs/001-user-authentication.md`
- Second PRP: `specs/002-payment-integration.md`
- Tenth PRP: `specs/010-api-rate-limiting.md`
- 100th PRP: `specs/100-advanced-analytics.md`

**Filename generation rules:**
- Convert to lowercase
- Replace spaces with hyphens
- Remove special characters (keep only alphanumeric and hyphens)
- Keep it concise (max 50 characters for the name part)
- Use the core feature name, not full description

### PRP Quality Checklist

Before finalizing, verify:
- [ ] All necessary context included
- [ ] Validation gates are executable by AI
- [ ] References existing patterns with file paths
- [ ] Clear implementation path with specific tasks
- [ ] Error handling documented
- [ ] Success criteria are measurable

**Score the PRP confidence level (1-10)** for one-pass implementation success.

## Mode 2: PRP Clarification

### Purpose

Identify and resolve underspecified areas in a PRP through structured questioning BEFORE implementation. This reduces downstream rework risk and ensures requirements are clear enough for one-pass implementation success.

### When to Use

- After PRP generation, before execution
- When ambiguities or missing decision points are suspected
- To validate that requirements are implementation-ready
- User can skip if explicitly doing exploratory work (but warn about rework risk)

### Clarification Process

#### Step 1: Locate PRP

Ask user for PRP file path, or search for it in `specs/` directory with patterns like:
- `specs/###-*.md` (numbered PRPs)
- `prp.md`, `requirements.md` in current directory

If no PRP exists, instruct user to generate one first (Mode 1).

#### Step 2: Coverage Analysis

Load the PRP and perform structured ambiguity scan using this taxonomy. Internally mark each category as: **Clear** / **Partial** / **Missing**.

**Coverage Taxonomy:**

1. **Functional Scope & Behavior**
   - Core user goals & success criteria
   - Explicit out-of-scope declarations
   - User roles / personas differentiation
   - Primary workflows and interactions

2. **Domain & Data Model**
   - Entities, attributes, relationships
   - Identity & uniqueness rules
   - Lifecycle/state transitions
   - Data volume / scale assumptions

3. **Interaction & UX Flow**
   - Critical user journeys / sequences
   - Error/empty/loading states
   - Accessibility or localization requirements
   - Input validation rules

4. **Non-Functional Quality Attributes**
   - Performance (latency, throughput targets)
   - Scalability (horizontal/vertical, limits)
   - Reliability & availability (uptime, recovery)
   - Observability (logging, metrics, tracing)
   - Security & privacy (auth, data protection, threats)
   - Compliance / regulatory constraints

5. **Integration & External Dependencies**
   - External services/APIs and failure modes
   - Data import/export formats
   - Protocol/versioning assumptions
   - Third-party library constraints

6. **Edge Cases & Failure Handling**
   - Negative scenarios (invalid input, missing data)
   - Rate limiting / throttling
   - Conflict resolution (concurrent edits)
   - Degraded mode operations

7. **Constraints & Tradeoffs**
   - Technical constraints (language, storage, hosting)
   - Explicit tradeoffs or rejected alternatives
   - Budget/timeline constraints affecting scope

8. **Terminology & Consistency**
   - Canonical glossary terms
   - Avoided synonyms / deprecated terms
   - Domain-specific language definitions

9. **Completion Signals**
   - Acceptance criteria testability
   - Measurable Definition of Done indicators
   - Success metrics

10. **Misc / Placeholders**
    - TODO markers / unresolved decisions
    - Ambiguous adjectives ("robust", "intuitive", "fast")
    - Vague requirements without concrete criteria

**Consider for clarification** if Partial/Missing AND:
- Would materially impact implementation or validation strategy
- Not better deferred to execution phase

#### Step 3: Generate Question Queue

Internally create prioritized question queue (max 5 questions). **Do NOT output all at once.**

**Question Constraints:**
- Maximum 5 questions per session (absolute limit)
- Each answerable with EITHER:
  - Multiple-choice (2-5 mutually exclusive options), OR
  - Short phrase (≤5 words)
- Only include if materially impacts:
  - Architecture, data modeling, task decomposition
  - Test design, UX behavior, operational readiness
  - Compliance validation

**Prioritization:**
- Use (Impact × Uncertainty) heuristic
- Cover highest-impact categories first
- Balance coverage across categories
- Exclude already-answered questions
- Exclude trivial preferences
- Exclude execution details (unless blocking)
- Favor questions that reduce rework risk

#### Step 4: Interactive Questioning with Native UI

Use the `AskUserQuestion` tool to present clarification questions using Claude's native questioning UI.

**Question Batch Preparation:**

1. Prepare 1-4 questions from the prioritized queue (max 4 per batch due to tool limits)
2. For each question, determine:
   - Clear question text ending with "?"
   - Short header (≤12 chars) for the chip/tag display
   - 2-4 option choices (tool automatically adds "Other" for custom input)
   - Whether multiSelect should be enabled (default: false for mutually exclusive choices)

**Question Format Guidelines:**

- **header**: Ultra-concise label (e.g., "Auth method", "Data store", "API style")
- **question**: Full question text with context
- **options**: Array of 2-4 choices, each with:
  - **label**: Short choice name (1-5 words)
  - **description**: Explanation of what this choice means and its implications
- **multiSelect**: Set to `true` only if choices are not mutually exclusive

**Answer Processing:**

- Tool returns user selections in `answers` object keyed by question text
- If user selects "Other", they provide custom text input
- All answers are automatically validated by the tool
- Record each answer and proceed to integration step

**Batching Strategy:**

- Present up to 4 questions at once if they're independent
- If answers to earlier questions affect later questions, batch accordingly
- Respect 5-question total limit across all batches
- After each batch, integrate answers before potentially asking more

**Stop Conditions:**

- All critical ambiguities resolved (remaining questions unnecessary)
- 5 questions total asked across all batches
- No more questions in queue
- User explicitly indicates completion via custom responses

**Example Tool Usage:**

```typescript
AskUserQuestion({
  questions: [
    {
      question: "Which authentication method should the system use?",
      header: "Auth method",
      multiSelect: false,
      options: [
        {
          label: "OAuth 2.0 with JWT",
          description: "Standard, secure, scalable for web/mobile apps. Stateless authentication."
        },
        {
          label: "Session cookies",
          description: "Traditional approach, requires session storage, good for server-rendered apps."
        },
        {
          label: "API keys",
          description: "Simple but less secure, suitable for service-to-service auth only."
        }
      ]
    },
    {
      question: "What is the target API response latency at p95?",
      header: "Latency",
      multiSelect: false,
      options: [
        {
          label: "<100ms",
          description: "High performance, requires caching and optimization"
        },
        {
          label: "<200ms",
          description: "Standard for responsive web apps, balanced approach"
        },
        {
          label: "<500ms",
          description: "Acceptable for non-critical operations"
        }
      ]
    }
  ]
})
```

#### Step 5: Incremental Integration

After EACH batch of answers (from AskUserQuestion tool), update PRP immediately:

1. **First batch only:** Ensure structure exists
   - Create `## Clarifications` section (after overview/context)
   - Create `### Session YYYY-MM-DD` subheading

2. **Record Q&A for each answer in batch:**
   - Append: `- Q: <question> → A: <answer>` for each question/answer pair

3. **Apply clarification to appropriate sections:**

   | Type                 | Target Section                     | Action                                  |
   | -------------------- | ---------------------------------- | --------------------------------------- |
   | Functional ambiguity | Success Criteria / Requirements    | Add/update specific capability          |
   | User interaction     | User Stories / Workflows           | Add clarified role/constraint/scenario  |
   | Data model           | Data Models and Structure          | Add fields, types, relationships        |
   | Non-functional       | Success Criteria                   | Add measurable criteria (vague→metric)  |
   | Edge case            | Known Gotchas / Edge Cases         | Add bullet or subsection                |
   | Terminology          | Throughout                         | Normalize term, add "(formerly X)" once |
   | Security/privacy     | Implementation Blueprint / Gotchas | Add auth/data protection rules          |
   | Performance          | Success Criteria / Gotchas         | Add latency/throughput/capacity targets |
   | Integration          | Integration Points / Context       | Add service details, failure modes      |

4. **Handle contradictions:**
   - Replace invalidated statements (don't duplicate)
   - Remove obsolete placeholders
   - No contradictory text remains

5. **Write to disk:**
   - Save PRP after EACH batch integration (atomic)
   - Preserve formatting (don't reorder)
   - Keep heading hierarchy intact
   - Keep insertions minimal and testable

#### Step 6: Validation

After each write, verify:

- [ ] Clarifications section has one bullet per answer (no duplicates)
- [ ] Total questions ≤ 5
- [ ] No lingering vague placeholders in updated sections
- [ ] No contradictory statements
- [ ] Valid markdown structure
- [ ] Only new headings: `## Clarifications`, `### Session YYYY-MM-DD`
- [ ] Terminology consistent across updated sections

#### Step 7: Completion Report

After questioning ends, provide:

**Session Summary:**

- Questions asked & answered
- Path to updated PRP
- Sections touched (list names)

**Coverage Summary Table:**

| Category                   | Status                              | Notes                   |
| -------------------------- | ----------------------------------- | ----------------------- |
| Functional Scope           | Resolved/Clear/Deferred/Outstanding | Brief note if not Clear |
| Domain & Data Model        | ...                                 | ...                     |
| Interaction & UX Flow      | ...                                 | ...                     |
| Non-Functional Attributes  | ...                                 | ...                     |
| Integration & Dependencies | ...                                 | ...                     |
| Edge Cases & Failures      | ...                                 | ...                     |
| Constraints & Tradeoffs    | ...                                 | ...                     |
| Terminology                | ...                                 | ...                     |
| Completion Signals         | ...                                 | ...                     |

**Status Definitions:**

- **Resolved**: Was Partial/Missing, now addressed
- **Clear**: Already sufficient
- **Deferred**: Exceeds quota OR better for execution phase
- **Outstanding**: Still Partial/Missing but low impact

**Recommendations:**

- If high-impact Outstanding/Deferred remain: flag and suggest re-run or proceed with caution
- Suggest next step:
  - "Proceed to execution (Mode 3)" if sufficient clarity
  - "Run clarification again for [categories]" if critical gaps
  - "Review PRP before execution" if major changes

### Clarification Behavior Rules

**Early Exit:**

- **No ambiguities**: Report "No critical ambiguities detected" and suggest proceeding
- **PRP missing**: Instruct to generate PRP first (Mode 1)

**Constraints:**

- Never exceed 5 questions total across all batches
- Present up to 4 questions per batch (tool limitation)
- Avoid tech stack questions unless blocking functional clarity
- If no questions due to full coverage, output compact summary (all Clear)
- If quota reached with unresolved high-impact items, flag under Deferred with rationale
- Batch independent questions together for efficiency
- Process answers and integrate into PRP after each batch

### Example Clarification Scenarios

**Scenario 1: Authentication & Performance Batch**

```typescript
AskUserQuestion({
  questions: [
    {
      question: "Which authentication method should the system use?",
      header: "Auth method",
      multiSelect: false,
      options: [
        { label: "OAuth 2.0 with JWT", description: "Standard, secure, scalable for web/mobile. Stateless auth." },
        { label: "Session cookies", description: "Traditional, requires session storage, good for SSR apps." },
        { label: "API keys", description: "Simple but less secure, for service-to-service only." },
        { label: "SSO (SAML/OIDC)", description: "Enterprise integration, complex setup." }
      ]
    },
    {
      question: "What is the target API response latency at p95?",
      header: "Latency",
      multiSelect: false,
      options: [
        { label: "<100ms", description: "High performance, requires caching and optimization" },
        { label: "<200ms", description: "Standard for responsive web apps, balanced approach" },
        { label: "<500ms", description: "Acceptable for non-critical operations" }
      ]
    }
  ]
})
```

**User selects:** "OAuth 2.0 with JWT" and "<200ms"

**Integration:**

After receiving answers:
- Clarifications:
  - `- Q: Authentication method? → A: OAuth 2.0 with JWT`
  - `- Q: Target API latency? → A: <200ms p95`
- Known Gotchas: `# CRITICAL: Use OAuth 2.0 with JWT for stateless auth`
- Data Models: Add User entity with OAuth provider fields
- Success Criteria: Add "[ ] API responds <200ms at p95 under normal load"

**Scenario 2: Multi-Select for Features**

```typescript
AskUserQuestion({
  questions: [
    {
      question: "Which optional features should be included in the initial release?",
      header: "Features",
      multiSelect: true,
      options: [
        { label: "Email notifications", description: "Send alerts via email, requires SMTP setup" },
        { label: "Export to CSV", description: "Allow users to download data as CSV files" },
        { label: "Dark mode", description: "Theme toggle for UI, affects all components" },
        { label: "Audit logging", description: "Track all user actions, increases storage needs" }
      ]
    }
  ]
})
```

**User selects:** "Email notifications", "Export to CSV", "Dark mode"

**Integration:**

- Clarifications: `- Q: Optional features? → A: Email notifications, Export to CSV, Dark mode`
- Success Criteria: Add checkboxes for each selected feature
- Implementation Blueprint: Add tasks for each feature

## Mode 3: PRP Execution

### Execution Process

When executing a PRP to implement a feature:

#### 1. Load PRP

- Read the specified PRP file completely (from `specs` directory)
- Understand all context and requirements
- Note all success criteria and validation gates
- Identify any gaps that need additional research

#### 2. ULTRATHINK & Plan

**CRITICAL: Think deeply before executing**

- Create a comprehensive implementation plan
- Break down complex tasks into smaller steps using TodoWrite
- Identify implementation patterns from existing code
- Determine execution order considering dependencies
- Plan validation strategy for each component

#### 3. Additional Research (if needed)

- Perform web searches for any unclear concepts
- Explore codebase for additional context
- Read referenced documentation thoroughly
- Clarify ambiguities with user using AskUserQuestion

#### 4. Execute Implementation

- Work through tasks systematically
- Update TodoWrite status as you progress
- Follow patterns from PRP and existing code
- Implement all code, tests, and documentation
- Keep exactly ONE task in_progress at a time

#### 5. Validate Continuously

- Run validation commands from PRP after each major step
- Fix any failures immediately
- Re-run until validation passes
- Don't proceed to next task if validation fails

#### 6. Final Validation

- Run complete validation suite from PRP
- Verify all success criteria are met
- Run all tests (unit, integration, manual)
- Ensure all linting and type checking passes
- Re-read the PRP to confirm everything is implemented

#### 7. Complete & Report

- Mark all tasks as completed
- Report completion status to user
- Highlight what was built
- Note any deviations from original PRP (with justification)

### Validation Loop Philosophy

**CRITICAL**: If validation fails, never skip or ignore:

1. Read the error message carefully
2. Understand the root cause
3. Fix the underlying issue (don't just patch)
4. Re-run validation
5. Repeat until passing

### PRP Reference

Throughout execution, you can always:

- Re-read the PRP for clarity
- Reference specific sections
- Use it as source of truth for requirements

## Best Practices

### For PRP Generation

1. **Be thorough in research** - More context = better success
2. **Include specific file paths and line numbers** when referencing patterns
3. **Make validation gates executable** - Provide exact commands
4. **Score confidence honestly** - Low scores indicate missing context
5. **Think about the AI executor** - What would you need to implement this?

### For PRP Execution

1. **Read the entire PRP first** - Don't skip ahead
2. **Use TodoWrite from the start** - Track progress visibly
3. **Follow patterns exactly** - Don't introduce new patterns
4. **Validate continuously** - Don't batch validation at the end
5. **Fix failures immediately** - Don't accumulate technical debt
6. **Mark tasks completed promptly** - Update status after each task

### Context Engineering Principles

1. **More is more** - Over-context rather than under-context
2. **Show, don't tell** - Include code examples, not just descriptions
3. **Be specific** - "Use pattern from file.py:123" not "follow similar patterns"
4. **Include URLs** - Direct links to docs and examples
5. **Document gotchas** - What commonly goes wrong?

## Common Pitfalls to Avoid

### During Generation

- ❌ Assuming the executor knows your codebase conventions
- ❌ Skipping research phase to save time
- ❌ Writing vague task descriptions
- ❌ Forgetting to include validation commands
- ❌ Not specifying exact file paths

### During Execution

- ❌ Skipping the planning phase (ULTRATHINK)
- ❌ Not using TodoWrite to track progress
- ❌ Implementing without understanding the full PRP
- ❌ Ignoring validation failures
- ❌ Creating new patterns instead of following existing ones
- ❌ Marking tasks complete before validation passes

## Integration with Project Rules

If the project contains a `CLAUDE.md` file:

1. Read it at the start of the session
2. Follow all rules specified there
3. Reference it in the PRP under "Core Principles"
4. Ensure generated PRP aligns with project conventions

## Success Metrics

A successful PRP workflow achieves:

- ✅ Working code on first execution pass
- ✅ All tests passing
- ✅ No linting or type errors
- ✅ Follows project conventions
- ✅ Meets all success criteria from PRP
- ✅ Self-corrects failures through validation loops

## Example Usage Patterns

### Pattern 1: User provides feature file

```
User: "I have a feature request in INITIAL.md, can you implement it using the PRP workflow?"

AI: [Activates this skill]
     1. Reads INITIAL.md
     2. Researches codebase and external resources
     3. Generates comprehensive PRP in specs/XXX-feature-name.md (auto-incremented)
     4. Asks if user wants to execute immediately or review first
     5. If approved, executes the PRP with full workflow
```

### Pattern 2: User provides inline requirements

```
User: "Build an async web scraper using BeautifulSoup that extracts product data, handles rate limiting, and stores in PostgreSQL"

AI: [Activates this skill]
     1. Clarifies any ambiguities
     2. Researches relevant patterns in codebase
     3. Searches for BeautifulSoup + async + PostgreSQL patterns
     4. Generates PRP with comprehensive context
     5. Asks for approval to execute
     6. Implements with validation loops
```

### Pattern 3: User wants to clarify PRP

```
User: "Clarify the PRP in specs/002-api-integration.md"
OR
User: "Review the requirements in specs/002-api-integration.md for ambiguities"

AI: [Activates this skill in clarification mode]
     1. Reads specs/002-api-integration.md completely
     2. Analyzes coverage across all taxonomy categories
     3. Generates prioritized question queue (max 5 total)
     4. Uses AskUserQuestion tool to present questions in batches (up to 4 per batch)
     5. Updates PRP incrementally after each batch of answers
     6. Provides coverage summary and next step recommendation
```

### Pattern 4: User has existing PRP

```
User: "Execute the PRP in specs/003-web-scraper.md"

AI: [Activates this skill in execution mode]
     1. Reads specs/003-web-scraper.md completely
     2. Creates implementation plan with TodoWrite
     3. Executes systematically with validation
     4. Reports completion
```

## Skill Invocation Examples

This skill should activate when user says things like:

**For PRP Generation (Mode 1):**

- "Create a PRP for [feature]"
- "Generate a comprehensive implementation plan for [feature]"
- "Use the PRP workflow to build [feature]"
- "I want to build [feature] with proper context engineering"
- "Help me implement [feature] systematically"

**For PRP Clarification (Mode 2):**

- "Clarify the PRP in [file]"
- "Review [PRP file] for ambiguities"
- "Check if [PRP file] has unclear requirements"
- "Help me refine the requirements in [file]"
- "What's missing from [PRP file]?"
- "Are there any gaps in [PRP file]?"

**For PRP Execution (Mode 3):**

- "Execute PRP [filename]"
- "Implement the feature described in [file]"
- "Build from [PRP file]"
- "Run the PRP in [file]"

## Output Format

### When Generating PRP (Mode 1)

1. Announce: "I'll generate a comprehensive PRP for [feature]"
2. Show research findings as you discover them
3. Ask clarifying questions if needed
4. Present PRP location when complete
5. Score confidence level (1-10)
6. Ask if user wants to clarify or execute immediately

### When Clarifying PRP (Mode 2)

1. Announce: "I'll analyze [PRP file] for ambiguities and missing decision points"
2. Load and analyze PRP against coverage taxonomy
3. Use AskUserQuestion tool to present questions in batches (up to 4 per batch, max 5 total)
4. Update PRP after each batch of answers
5. Provide coverage summary table
6. Recommend next step (execute, re-clarify, or review)

### When Executing PRP (Mode 3)

1. Announce: "I'll implement this feature using the PRP workflow"
2. Create TodoWrite task list
3. Update progress as you work
4. Show validation results
5. Report completion with summary

## Notes

- This skill implements a three-phase workflow: Generation → Clarification → Execution
- It's designed to be autonomous - Claude decides when to use it
- The skill emphasizes context engineering principles for AI success
- Clarification mode (Mode 2) is recommended between generation and execution to reduce rework risk
- Validation loops are critical for self-correcting implementation
- The goal is one-pass implementation success through comprehensive context

## Recommended Workflow Sequence

1. **Generate PRP** (Mode 1) - Create comprehensive requirements with context
2. **Clarify PRP** (Mode 2) - Resolve ambiguities before implementation (optional but recommended)
3. **Execute PRP** (Mode 3) - Implement with validation loops

Users can skip Mode 2 for exploratory work, but should be warned about increased rework risk.
