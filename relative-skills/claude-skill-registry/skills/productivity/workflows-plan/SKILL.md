---
name: workflows-plan
description: This skill should be used when transforming feature descriptions, bug reports, or improvement ideas into well-structured project plans following project conventions and best practices.
---

# Create a Plan for a New Feature or Bug Fix

**Note: The current year is 2025.** Use this when dating plans and searching for recent documentation.

Transform feature descriptions, bug reports, or improvement ideas into well-structured markdown plan files that follow project conventions and best practices.

## Getting Started

If no feature description is provided, ask:

> What would you like to plan? Please describe the feature, bug fix, or improvement you have in mind.

Do not proceed until a clear feature description is available.

## Main Tasks

### 1. Repository Research & Context Gathering

Spawn three sub-agents in parallel to research:

1. **Repository Research** - Analyze the codebase for existing patterns, similar implementations, and project conventions
2. **Best Practices Research** - Search for industry best practices and patterns relevant to the feature
3. **Framework Documentation Research** - Find relevant framework/library documentation for the implementation

**Reference Collection:**

-  [ ] Document all research findings with specific file paths (e.g., `app/services/example_service.rb:42`)
-  [ ] Include URLs to external documentation and best practices guides
-  [ ] Create a reference list of similar issues or PRs
-  [ ] Note any team conventions discovered in `AGENTS.md` or team documentation

### 2. Issue Planning & Structure

**Title & Categorization:**

-  [ ] Draft clear, searchable issue title using conventional format (e.g., `feat:`, `fix:`, `docs:`)
-  [ ] Determine issue type: enhancement, bug, refactor

**Stakeholder Analysis:**

-  [ ] Identify who will be affected (end users, developers, operations)
-  [ ] Consider implementation complexity and required expertise

**Content Planning:**

-  [ ] Choose appropriate detail level based on issue complexity and audience
-  [ ] List all necessary sections for the chosen template
-  [ ] Gather supporting materials (error logs, screenshots, design mockups)
-  [ ] Prepare code examples or reproduction steps if applicable

### 3. SpecFlow Analysis

After planning the issue structure, spawn a sub-agent to validate and refine the feature specification:

-  Analyze the feature description and research findings for completeness
-  Identify gaps, edge cases, and potential issues
-  Update acceptance criteria based on findings

### 4. Choose Implementation Detail Level

Select how comprehensive the plan should be—simpler is mostly better.

#### 📄 MINIMAL (Quick Issue)

**Best for:** Simple bugs, small improvements, clear features

**Includes:**

-  Problem statement or feature description
-  Basic acceptance criteria
-  Essential context only

**Structure:**

````markdown
[Brief problem/feature description]

## Acceptance Criteria

-  [ ] Core requirement 1
-  [ ] Core requirement 2

## Context

[Any critical information]

## MVP

### example.rb

```ruby
class Example
  def initialize
    @name = "example"
  end
end
```
````

## References

-  Related issue: #[issue_number]
-  Documentation: [relevant_docs_url]

````

#### 📋 MORE (Standard Issue)

**Best for:** Most features, complex bugs, team collaboration

**Includes everything from MINIMAL plus:**
- Detailed background and motivation
- Technical considerations
- Success metrics
- Dependencies and risks
- Basic implementation suggestions

**Structure:**

```markdown
## Overview

[Comprehensive description]

## Problem Statement / Motivation

[Why this matters]

## Proposed Solution

[High-level approach]

## Technical Considerations

- Architecture impacts
- Performance implications
- Security considerations

## Acceptance Criteria

- [ ] Detailed requirement 1
- [ ] Detailed requirement 2
- [ ] Testing requirements

## Success Metrics

[How we measure success]

## Dependencies & Risks

[What could block or complicate this]

## References & Research

- Similar implementations: [file_path:line_number]
- Best practices: [documentation_url]
- Related PRs: #[pr_number]
````

#### 📚 A LOT (Comprehensive Issue)

**Best for:** Major features, architectural changes, complex integrations

**Includes everything from MORE plus:**

-  Detailed implementation plan with phases
-  Alternative approaches considered
-  Extensive technical specifications
-  Resource requirements and timeline
-  Future considerations and extensibility
-  Risk mitigation strategies
-  Documentation requirements

**Structure:**

```markdown
## Overview

[Executive summary]

## Problem Statement

[Detailed problem analysis]

## Proposed Solution

[Comprehensive solution design]

## Technical Approach

### Architecture

[Detailed technical design]

### Implementation Phases

#### Phase 1: [Foundation]

-  Tasks and deliverables
-  Success criteria
-  Estimated effort

#### Phase 2: [Core Implementation]

-  Tasks and deliverables
-  Success criteria
-  Estimated effort

#### Phase 3: [Polish & Optimization]

-  Tasks and deliverables
-  Success criteria
-  Estimated effort

## Alternative Approaches Considered

[Other solutions evaluated and why rejected]

## Acceptance Criteria

### Functional Requirements

-  [ ] Detailed functional criteria

### Non-Functional Requirements

-  [ ] Performance targets
-  [ ] Security requirements
-  [ ] Accessibility standards

### Quality Gates

-  [ ] Test coverage requirements
-  [ ] Documentation completeness
-  [ ] Code review approval

## Success Metrics

[Detailed KPIs and measurement methods]

## Dependencies & Prerequisites

[Detailed dependency analysis]

## Risk Analysis & Mitigation

[Comprehensive risk assessment]

## Resource Requirements

[Team, time, infrastructure needs]

## Future Considerations

[Extensibility and long-term vision]

## Documentation Plan

[What docs need updating]

## References & Research

### Internal References

-  Architecture decisions: [file_path:line_number]
-  Similar features: [file_path:line_number]
-  Configuration: [file_path:line_number]

### External References

-  Framework documentation: [url]
-  Best practices guide: [url]
-  Industry standards: [url]

### Related Work

-  Previous PRs: #[pr_numbers]
-  Related issues: #[issue_numbers]
-  Design documents: [links]
```

### 5. Issue Creation & Formatting

**Content Formatting:**

-  [ ] Use clear, descriptive headings with proper hierarchy (##, ###)
-  [ ] Include code examples in triple backticks with language syntax highlighting
-  [ ] Add screenshots/mockups if UI-related
-  [ ] Use task lists (- [ ]) for trackable items
-  [ ] Add collapsible sections for lengthy logs using `<details>` tags
-  [ ] Apply appropriate emoji for visual scanning (🐛 bug, ✨ feature, 📚 docs, ♻️ refactor)

**Cross-Referencing:**

-  [ ] Link to related issues/PRs using #number format
-  [ ] Reference specific commits with SHA hashes when relevant
-  [ ] Link to code using permanent links
-  [ ] Mention relevant team members if needed
-  [ ] Add links to external resources with descriptive text

**AI-Era Considerations:**

-  [ ] Account for accelerated development with AI pair programming
-  [ ] Include prompts or instructions that worked well during research
-  [ ] Note which AI tools were used for initial exploration
-  [ ] Emphasize comprehensive testing given rapid implementation
-  [ ] Document any AI-generated code that needs human review

### 6. Final Review & Submission

**Pre-submission Checklist:**

-  [ ] Title is searchable and descriptive
-  [ ] Labels accurately categorize the issue
-  [ ] All template sections are complete
-  [ ] Links and references are working
-  [ ] Acceptance criteria are measurable
-  [ ] Add names of files in pseudo code examples and todo lists
-  [ ] Add an ERD mermaid diagram if applicable for new model changes

## Output Format

Write the plan to `plans/<issue_title>.md`

## Post-Generation Options

After writing the plan file, present these options:

> Plan ready at `plans/<issue_title>.md`. What would you like to do next?
>
> 1. **Open plan in editor** - Open the plan file for review
> 2. **Deepen plan** - Enhance each section with parallel research (best practices, performance, UI)
> 3. **Review plan** - Get feedback from reviewers (reference `@guidance/reviewers/` if available)
> 4. **Start work** - Begin implementing this plan (reference `@workflows-work` skill)
> 5. **Create Issue** - Create issue in project tracker (GitHub/Linear)
> 6. **Simplify** - Reduce detail level

Based on selection:

-  **Open plan** → Run `open plans/<issue_title>.md`
-  **Deepen plan** → Spawn sub-agents to research and enhance each section
-  **Review plan** → Reference `@guidance/reviewers/` for reviewer perspectives
-  **Start work** → Reference `@workflows-work` skill to begin implementation
-  **Create Issue** → See "Issue Creation" section below
-  **Simplify** → Ask "What should I simplify?" then regenerate simpler version

Loop back to options after Simplify or other changes until implementation or review begins.

## Issue Creation

When creating an issue, detect the project tracker from `AGENTS.md`:

1. **Check for tracker preference** in AGENTS.md (global or project):

   -  Look for `project_tracker: github` or `project_tracker: linear`

2. **If GitHub:**

   ```bash
   gh issue create --title "feat: [Plan Title]" --body-file plans/<issue_title>.md
   ```

3. **If Linear:**

   ```bash
   linear issue create --title "[Plan Title]" --description "$(cat plans/<issue_title>.md)"
   ```

4. **If no tracker configured:**
   Ask: "Which project tracker do you use? (GitHub/Linear/Other)"
   Suggest adding `project_tracker: github` or `project_tracker: linear` to AGENTS.md

5. **After creation:**
   -  Display the issue URL
   -  Ask if implementation or review should proceed

**NEVER CODE! Just research and write the plan.**
