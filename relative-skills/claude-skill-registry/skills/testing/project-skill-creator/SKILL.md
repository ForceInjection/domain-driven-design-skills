---
name: project-skill-creator
description: Use when setting up project-specific skills via /cc:setup-project or when user requests custom skills for their codebase - analyzes project to create specialized skills that capture architecture knowledge, coding conventions, testing patterns, and deployment workflows
---

# Project Skill Creator

## Overview

**Creating project-specific skills captures institutional knowledge and patterns that generic skills cannot provide.**

This skill analyzes your project and creates specialized skills (e.g., `project-architecture`, `project-conventions`, `project-testing`) that document project-specific patterns, standards, and workflows that all agents and future developers should follow.

**Core principle:** Project-specific skills transform tribal knowledge into discoverable documentation.

**REQUIRED BACKGROUND:** Use `writing-skills` for skill creation methodology. This skill applies those principles to project-specific content.

## When to Use

Use this skill when:
- User runs `/cc:setup-project` command
- User requests "create custom skills for my project"
- Project has unique architecture or patterns to document
- Team needs standardized conventions
- Onboarding new developers or agents

Do NOT use for:
- Generic patterns already covered by existing skills
- One-off projects without reusable patterns
- Projects still in early prototyping phase

## Project-Specific Skills to Create

### 1. project-architecture
**Purpose:** Document and explain the system architecture

**When to create:** Always (if project has clear architecture)

**Content:**
- High-level architecture diagram/description
- Component responsibilities
- Data flow and interactions
- Key design decisions and trade-offs
- How to extend the architecture

**Example trigger:** "Use when implementing features, adding components, or understanding system design - documents THIS project's architecture, component responsibilities, and design patterns"

### 2. project-conventions
**Purpose:** Capture code style and naming conventions

**When to create:** If project has specific conventions beyond standard linters

**Content:**
- Naming conventions (files, classes, functions)
- Code organization patterns
- Import/export conventions
- Comment and documentation standards
- File/directory structure rules

**Example trigger:** "Use when writing new code in this project - enforces naming conventions, code organization, and style patterns specific to this codebase"

### 3. project-testing
**Purpose:** Document testing approach and patterns

**When to create:** If project has specific testing patterns

**Content:**
- Testing philosophy and requirements
- Test organization (unit/integration/e2e)
- Fixture patterns and test utilities
- Mocking strategies
- Coverage requirements
- Example test patterns from project

**Example trigger:** "Use when writing tests - follows THIS project's testing patterns, fixture conventions, and test organization structure"

### 4. project-deployment
**Purpose:** Document build, release, and deployment process

**When to create:** If project has specific deployment workflow

**Content:**
- Build process and commands
- Environment setup
- Deployment steps
- Release checklist
- CI/CD pipeline explanation
- Rollback procedures

**Example trigger:** "Use when deploying, releasing, or setting up environments - documents THIS project's build process, deployment steps, and release workflow"

### 5. project-domain
**Purpose:** Capture domain-specific knowledge

**When to create:** If project has unique business domain

**Content:**
- Domain terminology and glossary
- Business rules and constraints
- Domain models and relationships
- Common workflows and use cases
- Domain-specific patterns

**Example trigger:** "Use when implementing business logic or understanding domain concepts - documents THIS project's business domain, terminology, and domain-specific rules"

## Project Analysis Workflow

### Phase 1: Project Understanding

**1. Architecture Discovery**

Analyze project structure:
```bash
# Get overview of directory structure
ls -R | head -100

# Look for architecture documentation
find . -name "README*" -o -name "ARCHITECTURE*" -o -name "DESIGN*"

# Analyze directory organization
tree -d -L 3
```

Identify architectural patterns:
- Monolith vs microservices
- Layered architecture (presentation/business/data)
- Clean architecture (domain/application/infrastructure)
- MVC, MVVM, or other patterns
- Frontend architecture (components, state management)

**2. Convention Discovery**

Sample 10-15 files to find patterns:
- File naming: kebab-case, snake_case, PascalCase?
- Class naming conventions
- Function naming patterns
- Import organization
- Comment styles

**3. Testing Pattern Discovery**

Examine test files:
```bash
# Find test files
find . -name "*test*" -o -name "*spec*" | head -20

# Read sample tests to understand patterns
```

Identify:
- Test organization structure
- Fixture patterns
- Mocking approach
- Assertion style
- Test naming conventions

**4. Deployment Process Discovery**

Check for:
- CI/CD configuration (`.github/workflows`, `.gitlab-ci.yml`)
- Build scripts (`package.json scripts`, `Makefile`, `justfile`)
- Docker setup (`Dockerfile`, `docker-compose.yml`)
- Deployment documentation

### Phase 2: Interactive Planning

**CRITICAL: Present findings and proposed skills to user.**

Create summary:

```markdown
## Project Analysis Summary

**Architecture Pattern:** {discovered pattern}
**Key Components:**
- {component 1} - {purpose}
- {component 2} - {purpose}

**Conventions Found:**
- File naming: {pattern}
- Class naming: {pattern}
- Import organization: {pattern}

**Testing Approach:**
- Test organization: {structure}
- Fixture patterns: {description}
- Coverage: {requirements}

**Deployment:**
- Build process: {description}
- CI/CD: {platform and approach}

## Recommended Skills

I recommend creating these project-specific skills:

1. **project-architecture** - Document {architecture pattern} and component responsibilities
2. **project-conventions** - Capture {naming} and {organization} conventions
3. **project-testing** - Document {testing approach} and fixture patterns
4. **project-deployment** - Document {build process} and deployment steps

Should I create these skills?
```

Get user approval before proceeding.

### Phase 3: Skill Generation

For each approved skill, follow `writing-skills` methodology:

**1. Create Skill Directory**
```bash
mkdir -p .claude/skills/project-{skill-name}
```

**2. Generate SKILL.md**

Use template:

```yaml
---
name: project-{skill-name}
description: Use when {specific triggers} - {what this skill provides specific to THIS project}
---

# Project {Skill Name}

## Overview

{One paragraph explaining what this skill provides for THIS project}

**Core principle:** {Key principle from project}

## {Main Content Sections}

{Content specific to this skill type - see templates below}

## When NOT to Use

- {Situations where this skill doesn't apply}
- {Edge cases or exceptions}

## Examples from This Project

{2-3 concrete examples from actual project code}

## Common Mistakes

{Project-specific anti-patterns to avoid}
```

**3. Populate with Project-Specific Content**

**For project-architecture:**
```markdown
## Architecture Overview

{High-level description}

**Pattern:** {Architecture pattern name}

## Component Responsibilities

### {Component 1}
**Location:** `{path}`
**Purpose:** {what it does}
**Dependencies:** {what it depends on}

### {Component 2}
{...}

## Data Flow

{How data moves through the system}

## Key Design Decisions

### Decision: {Decision name}
**Rationale:** {why this decision was made}
**Trade-offs:** {what we gave up}
**Alternatives considered:** {what else was considered}

## Extending the Architecture

When adding new features:
1. {Step 1 with specific guidance}
2. {Step 2}

{Include actual examples from project}
```

**For project-conventions:**
```markdown
## File Naming

**Pattern:** {discovered pattern}

Examples from this project:
- {actual file 1}
- {actual file 2}

## Class/Component Naming

**Pattern:** {discovered pattern}

Examples:
```{language}
{actual code example 1}
{actual code example 2}
```

## Import Organization

**Pattern:** {discovered pattern}

Standard import order:
```{language}
{actual example from project}
```

## Code Organization

**Pattern:** One {unit} per file

Example structure:
```
{actual directory tree from project}
```

## Documentation Standards

{How comments and docs should be written}

Example:
```{language}
{actual documented code from project}
```
```

**For project-testing:**
```markdown
## Testing Philosophy

{What project values in tests}

## Test Organization

```
{actual test directory structure}
```

**Unit tests:** `{location}` - {what they test}
**Integration tests:** `{location}` - {what they test}
**E2E tests:** `{location}` - {what they test}

## Fixture Patterns

{Describe how project uses fixtures}

Example from this project:
```{language}
{actual fixture code}
```

## Test Naming

**Pattern:** {discovered pattern}

Examples:
- {actual test name 1}
- {actual test name 2}

## Mocking Strategy

{How project handles mocking}

Example:
```{language}
{actual mock code}
```

## Coverage Requirements

{Project coverage standards}

## Running Tests

```bash
{actual commands from project}
```
```

**For project-deployment:**
```markdown
## Build Process

**Command:** `{actual command}`

**Steps:**
1. {step 1 from actual build}
2. {step 2}

## Environment Setup

{How to configure environments}

## Deployment Steps

### Development
```bash
{actual deployment commands}
```

### Production
```bash
{actual production deployment}
```

## CI/CD Pipeline

{Describe actual CI/CD setup}

**Stages:**
1. {stage 1} - {what happens}
2. {stage 2} - {what happens}

## Release Checklist

- [ ] {actual checklist item 1}
- [ ] {actual checklist item 2}

## Rollback Procedure

{How to rollback in this project}
```

## Implementation Steps

**Use TodoWrite to create todos for each step:**

1. [ ] Analyze project architecture and structure
2. [ ] Discover naming and code conventions
3. [ ] Examine testing patterns and approach
4. [ ] Review deployment and build process
5. [ ] Identify domain-specific knowledge to capture
6. [ ] Create analysis summary
7. [ ] Present findings and proposed skills to user
8. [ ] Get user approval for skill creation
9. [ ] For each approved skill:
   - [ ] Create skill directory
   - [ ] Generate SKILL.md with frontmatter
   - [ ] Populate with project-specific examples
   - [ ] Include actual code from project
10. [ ] Confirm skills created with user

## Examples

### Example 1: FastAPI Project

**Analysis:**
- Clean Architecture (domain/application/infrastructure)
- Repository pattern for data access
- Dependency injection via FastAPI
- pytest with async support

**Skills Created:**

1. `project-architecture` - Documents Clean Architecture layers, repository pattern usage
2. `project-testing` - Documents pytest async patterns, fixture conventions
3. `project-deployment` - Documents Docker build, migrations, deployment to AWS

### Example 2: React Project

**Analysis:**
- Component-based architecture
- Custom hooks in `src/hooks/`
- Compound component patterns
- Vitest for testing

**Skills Created:**

1. `project-architecture` - Documents component structure, state management approach
2. `project-conventions` - Documents component naming, hook conventions, file organization
3. `project-testing` - Documents Vitest setup, testing-library patterns

## Quality Checklist

Before considering skills complete:

- [ ] All skills include actual code examples from project
- [ ] Frontmatter description includes specific triggers
- [ ] Content is project-specific (not generic advice)
- [ ] File paths and commands are exact (not placeholders)
- [ ] Examples are real code from the project
- [ ] "When NOT to Use" section included
- [ ] User has approved all skills
- [ ] Skills saved to `.claude/skills/project-{name}/`

## Common Mistakes

### ❌ Generic Content
Writing generic advice instead of project-specific patterns
**Fix:** Include actual code examples and exact file paths

### ❌ Placeholder Examples
Using generic placeholders like `{your-component}.tsx`
**Fix:** Use actual filenames and code from project

### ❌ Missing Context
Not explaining WHY patterns exist
**Fix:** Document decisions, trade-offs, and rationale

### ❌ Too Verbose
Creating encyclopedic documentation
**Fix:** Keep skills focused and scannable (< 500 lines)

### ❌ Skipping Approval
Generating skills without user review
**Fix:** Always present findings and get approval

## Integration with writing-skills

Follow these `writing-skills` principles:

- **Test-driven:** Verify skills help agents solve real tasks
- **Concise:** Target < 500 words for frequently-loaded skills
- **Examples over explanation:** Show actual project code
- **Cross-reference:** Reference other skills by name
- **Claude Search Optimization:** Rich description with triggers

## Skill Naming Convention

**CRITICAL:** Use `project-{name}` format:

- ✅ `project-architecture`
- ✅ `project-conventions`
- ✅ `project-testing`
- ✅ `project-deployment`
- ✅ `project-domain`
- ❌ `architecture-guide` (not discoverable as project-specific)
- ❌ `my-testing-patterns` (unclear scope)

The `project-` prefix ensures:
- Clear distinction from generic skills
- Consistent discovery pattern
- No naming conflicts

## Updating Skills

As project evolves, skills need updates:

**Triggers for updates:**
- Architecture changes
- New conventions adopted
- Testing approach evolves
- Deployment process changes

**Update workflow:**
1. Identify what changed
2. Update skill content
3. Add changelog note in skill
4. Test with real scenarios

## Storage Location

**All project-specific skills:** `.claude/skills/project-{name}/SKILL.md`

**Never store in:**
- `cc/skills/` (that's for generic CrispyClaude skills)
- Project source directories (not discoverable)
- Documentation folder (wrong tool for the job)
