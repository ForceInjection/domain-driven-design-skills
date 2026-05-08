---
name: manage-agents
description: MUST INVOKE this skill when working with subagents, setting up agent configurations, understanding how agents work, or using delegation tools to launch specialized agents. Create, audit, and maintain AI subagents and delegation tools.
---

# Objective

Subagents are specialized Claude instances that run in isolated contexts with focused roles and limited tool access. This skill teaches you how to create effective subagents, write strong system prompts, configure tool access, and orchestrate multi-agent workflows using the Task tool.

Subagents enable delegation of complex tasks to specialized agents that operate autonomously without user interaction, returning their final output to the main conversation.

# Quick Start

## When to Create an Agent

Use agents for **isolated context** and **specialized expertise**:

1. **Separate Context Required**: Deep thinking and analysis
2. **System Maintenance**: Maintaining AI infrastructure
3. **Specialized Expertise**: Domain-specific knowledge

See references/context-reset.md for detailed guidance.

## Workflow

1. **Default**: Project-level (`.claude/agents/`) for portability
   **Alternative**: User-level (`~/.claude/agents/`) only if specifically requested
2. Define the agent:
   - **name**: lowercase-with-hyphens
   - **description**: "Persona for [specialization]. SHOULD BE TASKED via Task tool for [use case]"
   - **tools**: Optional comma-separated list
   - **skills**: List relevant skills
3. Write system prompt using normal conversational language
4. Test with real delegation

## Agent Persona Example

**brainstormer**: Strategic thinking specialist

```markdown
---
name: brainstormer
description: Persona for Strategic thinking specialist. SHOULD BE TASKED via Task tool for complex strategic tasks requiring isolated context to avoid polluting the main chat.
tools: Read, Write, Edit, Glob, Grep, Bash, TodoWrite, AskUserQuestion, SlashCommand
skills: thinking-frameworks
---

## Role

You are a strategic thinking engine tasked with deep reasoning and strategic analysis. You operate in an isolated context when delegated complex reasoning tasks to keep the user's main chat focused. Your primary tool is the `thinking-frameworks` skill.

## Process

1. **Understand Context**: Thoroughly read the user's request...
2. **Select Framework**: Choose the most appropriate framework...
3. **Apply Framework**: Invoke the skill to access and apply...
4. **Present Results**: Structure the output clearly...

## Purpose

This agent provides a separate context window for deep, structured thinking and analysis, keeping the main chat clean while enabling comprehensive problem-solving.
```

See references/agent-personas.md for more examples.

# File Structure

| Type | Location | Scope | Priority |
|------|----------|-------|----------|
| **Project** (default) | `.claude/agents/` | Current project only, portable | Highest |
| **User** (if requested) | `~/.claude/agents/` | All projects | Lower |
| **Plugin** | Plugin's `agents/` dir | All projects | Lowest |

Project-level subagents override user-level when names conflict. Use project location for portability.

# Configuration

## Name Field

- Lowercase letters and hyphens only
- Must be unique

## Description Field

- Natural language description of purpose
- Include when Claude should invoke this subagent
- Used for automatic subagent selection

## Tools Field

- Comma-separated list: `Read, Write, Edit, Bash, Grep`
- If omitted: inherits all tools from main thread
- Use `/agents` interface to see all available tools

## Model Field

- `sonnet`, `opus`, `haiku`, or `inherit`
- `inherit`: uses same model as main conversation
- If omitted: defaults to configured subagent model (usually sonnet)

# Execution Model

## Critical Constraint

**Subagents are black boxes that cannot interact with users.**

Subagents run in isolated contexts and return their final output to the main conversation. They:

- ✅ Can use tools like Read, Write, Edit, Bash, Grep, Glob
- ✅ Can access MCP servers and other non-interactive tools
- ❌ **Cannot use AskUserQuestion** or any tool requiring user interaction
- ❌ **Cannot present options or wait for user input**
- ❌ **User never sees subagent's intermediate steps**

The main conversation sees only the subagent's final report/output.

## Workflow Design

**Designing workflows with subagents:**

Use **main chat** for:

- Gathering requirements from user (AskUserQuestion)
- Presenting options or decisions to user
- Any task requiring user confirmation/input
- Work where user needs visibility into progress

Use **subagents** for:

- Research tasks (API documentation lookup, code analysis)
- Code generation based on pre-defined requirements
- Analysis and reporting (security review, test coverage)
- Context-heavy operations that don't need user interaction

**Example workflow pattern:**

```
Main Chat: Ask user for requirements (AskUserQuestion)
  ↓
Subagent: Research API and create documentation (no user interaction)
  ↓
Main Chat: Review research with user, confirm approach
  ↓
Subagent: Generate code based on confirmed plan
  ↓
Main Chat: Present results, handle testing/deployment
```

# Workflows

## Create New Agent

Use the [create-new-agent workflow](workflows/create-new-agent.md) to create specialized agents following Cat Toolkit best practices:

- Identifies valid use cases for isolated context
- Defines clear agent personas
- Uses normal conversational language
- Lists relevant skills in YAML
- Creates context reset guidance

## Create New Agent (Advanced)

For complex multi-agent orchestration or advanced delegation patterns, see the reference guides in the references/ directory.

## Audit Existing Agent

To audit an existing agent for best practices compliance:

```
Audit the agent at: [path-to-agent-file]
```

Use the [audit workflow](workflows/audit.md) to evaluate:
- YAML frontmatter quality (name, description, tools, skills)
- Role definition clarity and specialization
- Workflow specification presence and clarity
- Constraints definition with strong boundaries
- Contextual judgment based on complexity

# System Prompt Guidelines

## Be Specific

Clearly define the subagent's role, capabilities, and constraints.

## Use Clear Structure

Structure the system prompt clearly. Use markdown headings for general structure, XML for highly structured elements like workflows:

```markdown
---
name: security-reviewer
description: Reviews code for security vulnerabilities
tools: Read, Grep, Glob, Bash
model: sonnet
---

## Role

You are a senior code reviewer specializing in security.

## Focus Areas

- SQL injection vulnerabilities
- XSS attack vectors
- Authentication/authorization issues
- Sensitive data exposure

## Workflow

1. Read the modified files
2. Identify security risks
3. Provide specific remediation steps
4. Rate severity (Critical/High/Medium/Low)
```

## Task-Specific

Tailor instructions to the specific task domain. Don't create generic "helper" subagents.

❌ Bad: "You are a helpful assistant that helps with code"
✅ Good: "You are a React component refactoring specialist. Analyze components for hooks best practices, performance anti-patterns, and accessibility issues."

# Subagent Structure

Subagent.md files are system prompts. Use clear structure with markdown headings for organization.

## Recommended Structure

Common sections for subagent structure:

- `## Role` - Who the subagent is and what it does
- `## Constraints` - Hard rules (NEVER/MUST/ALWAYS)
- `## Focus Areas` - What to prioritize
- `## Workflow` - Step-by-step process
- `## Output Format` - How to structure deliverables
- `## Success Criteria` - Completion criteria
- `## Validation` - How to verify work

## Intelligence Rules

**Simple subagents** (single focused task):

- Use role + constraints + workflow minimum
- Example: api-researcher, test-runner

**Medium subagents** (multi-step process):

- Add workflow steps, output format, success criteria
- Example: api-researcher, documentation-generator

**Complex subagents** (research + generation + validation):

- Add all sections as appropriate including validation, examples
- Example: mcp-api-researcher, comprehensive-auditor

## Formatting Guidance

Use markdown headings for structure. Keep markdown formatting within content (bold, italic, lists, code blocks, links).

For structure principles, invoke the `manage-skills` skill if deeper guidance on skill organization is needed.

# Invocation

## Context Management (CRITICAL)

**When invoking subagents via Task tool, you MUST provide complete context.**

Subagents are like new hires who started 5 seconds ago. They know NOTHING about:

- The project structure or tech stack
- Previous conversation history
- Decisions made earlier
- What files exist or where they are located

**When you invoke a subagent, compile a Context Payload:**

1. **Project State:**
   - What is the tech stack? (Node/Python/Rust/etc.)
   - What frameworks are in use?
   - What is the project structure?

2. **Immediate Goal:**
   - What specifically needs to be done?
   - Why is this task being done?

3. **Relevant Files (Context Saturation):**
   - Do not just reference file paths
   - You must READ key files and either:
     - PASTE their relevant contents into the task prompt, OR
     - Explicitly instruct the subagent to read specific paths

4. **Constraints:**
   - What must they NOT do?
   - What patterns must they follow?

**Example good delegation:**

```
Write a test for the auth service.

**Project Context:**
- Node.js project using TypeScript and Jest
- Located in src/services/auth.ts

**What I Found:**
I read src/auth.ts and it exports a login(username, password) function that returns a JWT token.

**Dependencies:**
- Uses src/utils/jwt.ts for token generation
- Uses src/models/user.ts for user lookup

**Requirements:**
- Create test at src/auth.test.ts
- Test with valid credentials and error handling
- Follow existing test patterns from src/user/user.test.ts
- Do not modify the auth service, only add tests
```

**Example bad delegation:**

```
Write a test for the auth service.
```

**Why this matters:**

- The subagent starts with ZERO context
- Without tech stack, wrong test framework
- Without function signature, guessing parameters
- Without file location, creates files in wrong place

## Automatic

Claude automatically selects subagents based on the `description` field when it matches the current task.

## Explicit

You can explicitly invoke a subagent:

```
> Use the api-researcher subagent to investigate this API
```

```
> Have the test-writer subagent create tests for the new API endpoints
```

# Management

## Using /agents Command

Run `/agents` for an interactive interface to:

- View all available subagents
- Create new subagents
- Edit existing subagents
- Delete custom subagents

## Manual Editing

You can also edit subagent files directly:

- **Default**: `.claude/agents/subagent-name.md` (project, portable)
- **Alternative**: `~/.claude/agents/subagent-name.md` (if specifically requested)

# Reference Guides

**Core references**:

**Subagent usage and configuration**: [references/subagents.md](references/subagents.md)

- File format and configuration
- Model selection (Sonnet 4.5 + Haiku 4.5 orchestration)
- Tool security and least privilege
- Prompt caching optimization
- Complete examples

**Writing effective prompts**: [references/writing-subagent-prompts.md](references/writing-subagent-prompts.md)

- Core principles and XML structure
- Description field optimization for routing
- Extended thinking for complex reasoning
- Security constraints and strong modal verbs
- Success criteria definition

**Advanced topics**:

**Evaluation and testing**: [references/evaluation-and-testing.md](references/evaluation-and-testing.md)

- Evaluation metrics (task completion, tool correctness, robustness)
- Testing strategies (offline, simulation, online monitoring)
- Evaluation-driven development
- G-Eval for custom criteria

**Error handling and recovery**: [references/error-handling-and-recovery.md](references/error-handling-and-recovery.md)

- Common failure modes and causes
- Recovery strategies (graceful degradation, retry, circuit breakers)
- Structured communication and observability
- Anti-patterns to avoid

**Context management**: [references/context-management.md](references/context-management.md)

- Memory architecture (STM, LTM, working memory)
- Context strategies (summarization, sliding window, scratchpads)
- Managing long-running tasks
- Prompt caching interaction

**Orchestration patterns**: [references/orchestration-patterns.md](references/orchestration-patterns.md)

- Sequential, parallel, hierarchical, coordinator patterns
- Sonnet + Haiku orchestration for cost/performance
- Multi-agent coordination
- Pattern selection guidance

**Debugging and troubleshooting**: [references/debugging-agents.md](references/debugging-agents.md)

- Logging, tracing, and correlation IDs
- Common failure types (hallucinations, format errors, tool misuse)
- Diagnostic procedures
- Continuous monitoring

# Success Criteria

A well-configured subagent has:

- Valid YAML frontmatter (name matches file, description includes triggers)
- Clear role definition in system prompt
- Appropriate tool restrictions (least privilege)
- Well-structured system prompt with role, approach, and constraints
- Description field optimized for automatic routing
- Successfully tested on representative tasks
- Model selection appropriate for task complexity (Sonnet for reasoning, Haiku for simple tasks)
