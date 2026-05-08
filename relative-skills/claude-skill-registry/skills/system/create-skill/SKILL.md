---
name: create-skill
type: meta
category: system
description: Interactive wizard to create a new skill for specialized, reusable workflows and domain-specific expertise
---

# Create Skill Command

## Purpose

Guides you through creating a new skill for the Hospeda project. Skills are specialized, reusable workflows that can be invoked by agents during task execution. This wizard ensures skills follow project standards, integrate properly with agents, and provide clear, actionable workflows.

## When to Use

- **Reusable Workflows**: When a process is used by multiple agents
- **Domain Expertise**: When specialized knowledge needs to be codified
- **Complex Procedures**: When multi-step workflows need documentation
- **Best Practices**: When standardizing approaches across the project

## Usage

```bash
/create-skill [options]
```

### Options

- `--name <name>`: Skill name (kebab-case)
- `--category <category>`: Skill category (testing, development, validation, documentation)
- `--interactive`: Full interactive mode (default)
- `--template <type>`: Use template (workflow, validation, utility)

### Examples

```bash
/create-skill                                    # Interactive mode
/create-skill --name api-testing --category testing
/create-skill --template validation --interactive
```

## Skill Creation Process

### Step 1: Skill Discovery & Planning

**Questions Asked:**

1. **Skill Name** (kebab-case):
   - Examples: `api-integration-testing`, `git-workflow-helper`, `performance-profiling`
   - Must be unique, descriptive, action-oriented
   - Validation: lowercase, hyphens only

2. **Skill Category**:
   - `testing` - Testing workflows and validation
   - `development` - Development tools and helpers
   - `validation` - Quality and compliance validation
   - `documentation` - Documentation generation and management
   - `automation` - Process automation
   - `analysis` - Code and architecture analysis

3. **One-Line Description**:
   - Clear, concise explanation of skill purpose
   - Used in skill listings
   - Should explain WHAT the skill does

4. **Detailed Purpose** (2-3 paragraphs):
   - What problem does this skill solve?
   - What specialized knowledge does it provide?
   - What workflow does it automate?

5. **Primary Users** (which agents will use this skill):
   - Examples: `qa-engineer`, `tech-lead`, `all-agents`
   - Determines where skill is documented

6. **Skill Type**:
   - `workflow` - Multi-step process automation
   - `validation` - Checks and validations
   - `utility` - Helper functions and tools
   - `template` - Template generation
   - `analysis` - Code/architecture analysis

### Step 2: Workflow Definition

**Workflow Steps:**

1. **Input Requirements**:
   - What information is needed?
   - What files should exist?
   - What state should the project be in?

2. **Process Steps**:
   - Step-by-step workflow
   - Decision points
   - Error handling
   - Success criteria

3. **Output/Deliverables**:
   - What does the skill produce?
   - What files are created/modified?
   - What information is returned?

4. **Success Criteria**:
   - How do you know the skill completed successfully?
   - What validations should pass?

### Step 3: Skill File Generation

**File Created**: `.claude/skills/{category}/{skill-name}.md`

**YAML Frontmatter Template**:

```yaml
---
name: {skill-name}
category: {category}
description: {one-line description}
usage: How and when agents should invoke this skill
input: What the skill requires to execute
output: What the skill produces
---
```

**Markdown Structure**:

```markdown
# {Skill Name}

## Overview

**Purpose**: {What this skill does}
**Category**: {category}
**Primary Users**: {agents that use this}

## When to Use This Skill

{Scenarios and conditions for using this skill}

## Prerequisites

**Required:**
- {prerequisite-1}
- {prerequisite-2}

**Optional:**
- {optional-1}

## Input

{What the skill needs}

## Workflow

### Step 1: {Step Name}

**Objective**: {what this step accomplishes}

**Actions**:
1. {action-1}
2. {action-2}

**Validation**:
- [ ] {check-1}
- [ ] {check-2}

**Output**: {what this step produces}

### Step 2: {Step Name}

[Similar structure...]

## Output

**Produces**:
- {output-1}
- {output-2}

**Success Criteria**:
- {criterion-1}
- {criterion-2}

## Examples

### Example 1: {Scenario}

**Context**: {situation}
**Invocation**: {how skill is called}
**Process**: {what happens}
**Result**: {outcome}

## Error Handling

### Error: {Error Type}

**Cause**: {why it happens}
**Resolution**: {how to fix}

## Best Practices

{Usage best practices}

## Related Skills

{Related skills}

## Notes

{Additional notes}
```

### Step 4: Integration & Documentation

**Updates Required:**

1. **`.claude/skills/README.md`**:
   - Add skill to category section
   - Update skill count
   - Add usage example if needed

2. **Agent Documentation** (if skill is agent-specific):
   - Update agent's tool list to include Skill
   - Reference skill in agent's workflow section

3. **`.claude/docs/quick-start.md`** (if widely used):
   - Add to common skills section

### Step 5: Validation & Testing

**Validation Checks**:

- [ ] Skill name follows conventions
- [ ] YAML frontmatter valid
- [ ] All sections complete
- [ ] Workflow steps clear and actionable
- [ ] Prerequisites clearly defined
- [ ] Success criteria measurable
- [ ] Error handling documented
- [ ] File in correct directory
- [ ] Documentation updated

**Test Execution**:

Invoke skill from an agent context:

```
Use the {skill-name} skill to {task}
```

Verify:

- Skill loads correctly
- Workflow is clear and actionable
- Output is as documented
- Error handling works

### Step 6: Commit & Documentation

**Commit Message Format**:

```bash
feat(skills): add {skill-name} skill

- Add {skill-name} in {category} category
- {Brief description of functionality}
- Primary users: {agents}

Workflow:
  {key workflow steps}

Output:
  {what skill produces}

Updates:
- .claude/skills/{category}/{skill-name}.md (new)
- .claude/skills/README.md (updated)

PF004-XX (if during P-004 workflow)
```

## Interactive Wizard Flow

```
🎯 Create New Skill Wizard
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 Step 1: Skill Identity
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Skill Name (kebab-case): api-integration-testing
Category:
  1. testing - Testing workflows ✓
  2. development - Development tools
  3. validation - Quality validation
  4. documentation - Documentation management
  5. automation - Process automation
  6. analysis - Code analysis

Select category (1-6): 1

One-line description:
> Comprehensive workflow for testing API integrations with
> validation, error cases, and documentation

Skill Type:
  1. workflow - Multi-step process ✓
  2. validation - Checks and validations
  3. utility - Helper functions
  4. template - Template generation
  5. analysis - Analysis tools

Select type (1-5): 1

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Step 2: Purpose & Users
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Detailed Purpose (2-3 paragraphs):
> Provides a systematic approach to testing API integrations,
> ensuring all endpoints are properly tested with positive and
> negative test cases, edge cases are handled, and documentation
> is accurate.

Primary users (comma-separated agents):
> qa-engineer, hono-engineer, tech-lead

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔧 Step 3: Workflow Definition
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Define workflow steps:

Step 1 Title: Test Planning
  Actions (one per line, empty when done):
  - Identify all API endpoints to test
  - Review API documentation and schemas
  - Define test scenarios (happy path, error cases, edge cases)
  - Prepare test data and mocks
  -

Step 2 Title: Test Implementation
  Actions:
  - Write integration tests for each endpoint
  - Test authentication and authorization
  - Validate request/response schemas
  - Test error handling
  -

Step 3 Title: Validation & Documentation
  Actions:
  - Run all tests and verify coverage
  - Document test results
  - Update API documentation if discrepancies found
  -

Step 4 Title:

Input Requirements (what skill needs):
> - API routes defined
> - Zod schemas available
> - Test framework configured (Vitest)

Output/Deliverables (what skill produces):
> - Integration test files
> - Test coverage report
> - API documentation validation

Success Criteria:
> - All endpoints have tests
> - 90%+ test coverage
> - All tests passing
> - Documentation matches implementation

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 Step 4: Review & Confirm
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Skill Summary:
  Name: api-integration-testing
  Category: testing
  Type: workflow
  Description: Comprehensive workflow for testing API...

  Primary Users:
    - qa-engineer
    - hono-engineer
    - tech-lead

  Workflow Steps: 3 defined
  Input: API routes, schemas, test framework
  Output: Test files, coverage, documentation

File will be created at:
  .claude/skills/testing/api-integration-testing.md

Documentation updates:
  - .claude/skills/README.md

Proceed with creation? (y/n): y

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✨ Creating Skill
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Generated skill file
✓ Updated skills README
✓ Validation passed

📄 Skill created successfully!

File: .claude/skills/testing/api-integration-testing.md

Next steps:
1. Review and customize the generated content
2. Add specific examples for your use case
3. Test skill invocation from agent
4. Commit changes

Usage (from agent):
  "Use the api-integration-testing skill to test the booking API"

Suggested commit message:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
feat(skills): add api-integration-testing skill

- Add api-integration-testing in testing category
- Systematic workflow for API endpoint testing
- Covers positive, negative, and edge cases
- Primary users: qa-engineer, hono-engineer, tech-lead

Workflow:
  - Test planning and scenario definition
  - Test implementation with schema validation
  - Validation and documentation

Output:
  - Integration test files
  - Coverage reports
  - Documentation validation

Updates:
- .claude/skills/testing/api-integration-testing.md (new)
- .claude/skills/README.md (updated)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Skill Templates

### Workflow Skill Template

```markdown
---
name: {skill-name}
category: {category}
description: {description}
usage: Invoke this skill when {usage-context}
input: {input-requirements}
output: {output-produced}
---

# {Skill Name}

## Overview

**Purpose**: {what-skill-does}
**Category**: {category}
**Primary Users**: {agents}

## When to Use This Skill

{Use-case scenarios}

## Prerequisites

**Required:**
- {required-1}

**Optional:**
- {optional-1}

## Input

{Input-details}

## Workflow

### Step 1: {Step-Name}

**Objective**: {objective}

**Actions**:
1. {action}

**Validation**:
- [ ] {check}

**Output**: {step-output}

## Output

**Produces**:
- {output}

**Success Criteria**:
- {criterion}

## Examples

### Example: {Scenario}

**Context**: {context}
**Process**: {process}
**Result**: {result}

## Error Handling

### Error: {Error-Type}

**Cause**: {cause}
**Resolution**: {resolution}

## Best Practices

{practices}

## Related Skills

{related}

## Notes

{notes}
```

### Validation Skill Template

```markdown
---
name: {skill-name}
category: validation
description: {description}
usage: Use to validate {what-is-validated}
input: {what-needs-validation}
output: Validation report with pass/fail status
---

# {Skill Name}

## Overview

**Purpose**: {validation-purpose}
**Category**: validation
**Primary Users**: {agents}

## When to Use This Skill

{When-to-validate}

## Prerequisites

{Prerequisites}

## Input

{What-to-validate}

## Validation Checklist

### Category 1: {Category}

- [ ] {check-1}
- [ ] {check-2}

### Category 2: {Category}

- [ ] {check-1}

## Validation Process

{Process-steps}

## Output Format

```

{example-output}

```

## Error Handling

{error-handling}

## Examples

{examples}

## Related Skills

{related}
```

### Utility Skill Template

```markdown
---
name: {skill-name}
category: {category}
description: {description}
usage: Use to {what-it-does}
input: {input}
output: {output}
---

# {Skill Name}

## Overview

**Purpose**: {purpose}
**Category**: {category}
**Primary Users**: {agents}

## When to Use

{when-to-use}

## Usage

{how-to-use}

## Process

{process}

## Output

{output}

## Examples

{examples}

## Notes

{notes}
```

## Validation Rules

### Skill Name

- **Format**: kebab-case only
- **Length**: 3-40 characters
- **Pattern**: `^[a-z][a-z0-9-]*[a-z0-9]$`
- **Uniqueness**: Must not conflict with existing skills
- **Descriptive**: Should clearly indicate function

### YAML Frontmatter

- **Required Fields**: name, category, description, usage, input, output
- **Valid Categories**: testing, development, validation, documentation, automation, analysis
- **Description**: One-line summary
- **Usage**: When to invoke
- **Input**: What is required
- **Output**: What is produced

### Directory Structure

```
.claude/skills/
├── testing/          # Testing workflows
├── development/      # Development utilities
├── validation/       # Validation workflows
├── documentation/    # Documentation management
├── automation/       # Process automation
└── analysis/         # Analysis tools
```

### File Naming

- **Pattern**: `{skill-name}.md`
- **Location**: `.claude/skills/{category}/{skill-name}.md`
- **Case**: All lowercase
- **Extension**: `.md` only

## Best Practices for Skill Design

### Reusability

- **Generic**: Design for multiple use cases
- **Parameterized**: Accept context-specific input
- **Modular**: Break complex workflows into steps

### Clarity

- **Clear Steps**: Each step has clear objective
- **Actionable**: Steps are concrete and executable
- **Validated**: Include validation at each step

### Documentation

- **Examples**: Include realistic examples
- **Error Cases**: Document error scenarios
- **Prerequisites**: Clearly state requirements

### Integration

- **Agent Aware**: Design for agent invocation
- **Tool Compatible**: Work with available tools
- **Workflow Integrated**: Fit into existing workflows

## Common Skill Patterns

### Testing Workflow

- Prerequisites check
- Test planning
- Test implementation
- Validation
- Documentation

### Validation Workflow

- Input validation
- Criteria checking
- Result compilation
- Report generation

### Utility Workflow

- Input processing
- Operation execution
- Output formatting

## Related Commands

- `/create-agent` - Create new agent
- `/create-command` - Create new command
- `/help` - Get system help

## Notes

- **Skills vs Commands**: Skills are invoked by agents, commands by users
- **Scope**: Keep skills focused on single responsibility
- **Documentation**: Comprehensive docs are critical for agent understanding
- **Testing**: Test skill invocation from actual agent context
- **Evolution**: Skills can evolve as patterns emerge
- **Naming**: Use action-oriented names (verb-noun pattern preferred)

This command streamlines skill creation while ensuring reusability, clarity, and proper integration with the agent system.

---

## Changelog

| Version | Date | Changes | Author | Related |
|---------|------|---------|--------|---------|
| 1.0.0 | 2025-10-31 | Initial version | @tech-lead | P-004 |
