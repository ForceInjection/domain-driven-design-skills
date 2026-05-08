---
name: generate-prd
description: Generate or update PRD documents interactively with the user. Use this skill when the user wants to create new product requirements, refine existing PRD docs, or document a new feature. Asks clarifying questions iteratively to produce complete, accurate requirements.
---

# Generate PRD

Interactively create or update Product Requirements Documents through guided conversation with the user.

## When to Use

- User wants to document a new feature or product
- User has a vague idea that needs refinement
- Existing PRD needs expansion or clarification
- Before starting implementation to ensure clear requirements

## Approach

**Interactive and Iterative:**
- Never assume - always ask
- Ask one focused question at a time (or small related group)
- Build understanding incrementally
- Validate assumptions before documenting
- Refine through multiple rounds

## Workflow

### Step 1: Understand Intent

Determine what the user wants:

1. **New PRD** - Creating from scratch
2. **Update PRD** - Modifying existing document
3. **Expand PRD** - Adding detail to existing section

Ask: "Are you creating a new feature/product, or updating an existing PRD?"

If updating, read the existing PRD first.

### Step 2: Gather Core Concept

Start with the big picture:

**Questions to ask:**
- "What problem does this solve?" / "Why is this needed?"
- "Who is this for?" (target users/personas)
- "What's the one-sentence description?"

**Don't proceed until you have:**
- Clear problem statement
- Target audience
- Core value proposition

### Step 3: Define Scope

Clarify boundaries iteratively:

**Questions to ask:**
- "What are the must-have features?" (MVP scope)
- "What is explicitly out of scope?"
- "Are there related features we should NOT include?"
- "What existing functionality does this interact with?"

**Refine with follow-ups:**
- "You mentioned X - does that include Y?"
- "When you say 'users can do Z', do you mean all users or specific roles?"
- "Should this work on mobile/desktop/both?"

### Step 4: Detail Requirements

For each feature/requirement, ask:

**Functional:**
- "What happens when the user does X?"
- "What inputs are required?"
- "What outputs/results should they see?"
- "What are the error cases?"

**Non-functional:**
- "Any performance requirements?" (response time, throughput)
- "Security considerations?" (auth, permissions, data handling)
- "Scalability needs?" (users, data volume)

**Prioritization:**
- "Is this a must-have, should-have, or nice-to-have?"
- "What's the relative priority between X and Y?"

### Step 5: Validate Understanding

Before writing, confirm understanding:

```
"Let me summarize what I understand:

**Problem:** [problem statement]
**Solution:** [high-level approach]
**Users:** [target audience]

**Core Features:**
1. [feature 1]
2. [feature 2]

**Out of Scope:**
- [exclusion 1]

Does this accurately capture your requirements?"
```

Ask for corrections before proceeding.

### Step 6: Draft PRD

Create or update `docs/1-prd/{feature-name}.md`:

```markdown
# {Feature Name}

## Overview
Brief description of the feature and its purpose.

## Problem Statement
What problem this solves and why it matters.

## Target Users
Who this is for and their needs.

## Requirements

### Functional Requirements
| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | Description | Must-have |
| FR-02 | Description | Should-have |

### Non-Functional Requirements
| ID | Requirement | Target |
|----|-------------|--------|
| NFR-01 | Performance | < 200ms response |
| NFR-02 | Security | Role-based access |

## User Stories
- As a [user], I want to [action] so that [benefit]

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Out of Scope
- What is explicitly NOT included

## Dependencies
- Other features or systems this depends on

## Open Questions
- Unresolved items needing decision
```

### Step 7: Review and Refine

Present draft to user:

```
"Here's the draft PRD. Please review:

[Show key sections]

Questions:
1. Is the scope correctly captured?
2. Are the priorities right?
3. Anything missing or incorrect?"
```

**Iterate until user approves:**
- Make requested changes
- Ask follow-up questions if changes are unclear
- Re-validate after significant changes

### Step 8: Finalize

Once approved:
1. Write final version to `docs/1-prd/`
2. Confirm file location with user
3. Suggest next steps (analyze-gaps, sync-planning)

## Question Patterns

**Clarifying vague statements:**
| User Says | Ask |
|-----------|-----|
| "It should be fast" | "What response time is acceptable? Under 1 second? 200ms?" |
| "Users can manage X" | "What actions specifically? Create, edit, delete, view?" |
| "It needs to be secure" | "What security level? Authentication? Authorization? Encryption?" |
| "Like feature Y" | "Which aspects of Y? The UI, the workflow, the data model?" |

**Uncovering hidden requirements:**
- "What happens if the user does X incorrectly?"
- "Who approves/reviews this action?"
- "Is there an audit trail needed?"
- "What notifications should be sent?"
- "How does this affect existing data?"

**Resolving ambiguity:**
- "You mentioned both A and B - are these the same thing or different?"
- "Should this happen automatically or require user action?"
- "Is this per-user, per-organization, or global?"

## Anti-patterns to Avoid

| Don't | Do Instead |
|-------|------------|
| Assume requirements | Ask explicitly |
| Write long PRD before validating | Validate incrementally |
| Ask too many questions at once | One topic at a time |
| Use technical jargon | Match user's language |
| Skip edge cases | Ask about errors/exceptions |
| Guess priorities | Ask user to prioritize |

## Example Conversation Flow

```
User: I want to add a search feature

Claude: I'll help you define the search feature. First, a few questions:
        1. What content will users be searching? (products, documents, users, etc.)
        2. Who needs this search capability?

User: Users need to search through their documents

Claude: Got it - document search for users. To understand the scope:
        - Should this be full-text search or just by title/metadata?
        - Any filters needed? (date, type, author)

User: Full-text, and yes filter by date and document type

Claude: Clear. A few more details:
        - How fast should results appear? Real-time as they type, or after submit?
        - How many documents might a user have? (affects performance needs)

User: Real-time would be nice. Maybe up to 1000 docs per user.

Claude: Let me summarize before drafting:

        **Feature:** Full-text document search
        **Users:** All users searching their own documents
        **Scope:**
        - Full-text search with real-time results
        - Filters: date range, document type
        - Scale: up to 1000 docs per user

        **Out of scope** (confirm):
        - Searching other users' documents
        - Advanced query syntax

        Does this capture it correctly?

User: Yes, that's right

Claude: [Drafts PRD and presents for review]
        [Iterates based on feedback]
        [Writes final version to docs/1-prd/document-search.md]
```

## Integration with Other Skills

| After generate-prd | Use |
|--------------------|-----|
| `analyze-gaps` | Compare new PRD with existing codebase |
| `sync-planning` | Create tickets for the new requirements |

## Output

- New or updated PRD in `docs/1-prd/{feature-name}.md`
- User has validated all requirements
- Ready for implementation planning