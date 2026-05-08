---
name: kiro-project-scaffolder
description: |
  Automatically scaffolds spec-driven projects when user mentions creating new projects with specifications, type safety, or TDD requirements.
---

# Kiro Project Scaffolder Skill

## What This Skill Does

This skill enables Claude to automatically recognize when a user wants to create a spec-driven software project and scaffold it using kiro.dev methodology with typix, nickel contracts, and TDD workflows.

## When It Activates

Claude autonomously activates this skill when the user mentions:

**Direct triggers:**
- "create a new project with specifications"
- "scaffold a spec-driven application"
- "set up a kiro project"
- "I want to build [something] with TDD and type safety"
- "help me design a project with contracts"

**Implicit triggers:**
- Describes a new project and mentions: specifications, contracts, type safety, TDD, nix
- Asks about project structure best practices for testable code
- Wants to start a project with clear documentation and requirements
- Mentions needing both specifications and implementation

**Context clues:**
- User is in an empty directory or wants to start fresh
- Mentions team coordination or shared understanding
- Wants to ensure quality from the start
- Previous conversation about software architecture

## How It Works

### Phase 1: Recognition
Claude identifies that the user wants a spec-driven project and confirms:

```
I can help you create a spec-driven project using kiro.dev methodology. This will include:
- Complete project specifications (requirements, design, tasks)
- Typix integration for Nix-based development
- Nickel language contracts for type safety  
- TDD workflow setup with test templates
- Comprehensive documentation structure

Would you like to proceed with interactive Q&A to design your project, or provide a description for me to infer the structure?
```

### Phase 2: Interactive or Headless

**Interactive Mode** (invokes Kiro Architect agent):
- Conducts structured Q&A
- Gathers requirements systematically
- Validates understanding
- Designs architecture collaboratively

**Headless Mode** (autonomous inference):
- Analyzes user's project description
- Infers requirements and tech stack
- Proposes structure for confirmation
- Generates scaffold

### Phase 3: Scaffold Generation

Creates complete project structure:

```
Generating your kiro-scaffolded project...

✓ Created directory structure
✓ Initialized git repository
✓ Generated master specifications
  - .kiro/spec/requirements.md
  - .kiro/spec/design.md
  - .kiro/spec/tasks.md
✓ Set up documentation
  - CLAUDE.md
  - .aidocs/ with kiro, typix, nickel docs
✓ Created nickel contracts scaffold
  - .contracts/ mirroring planned structure
✓ Configured development environment
  - flake.nix with typix integration
✓ Set up TDD workflow
  - Test templates with assertions
  - RED-to-GREEN documentation

Your project is ready! Here's what to do next:
1. Review .kiro/spec/requirements.md
2. Run /kiro-scope <path> to create implementation areas
3. Start with TDD workflow in first scope

Initial commit created. Happy coding!
```

### Phase 4: Guidance

Provides next steps and can:
- Create first scoped implementation area
- Write first failing test
- Explain the workflow
- Invoke TDD Coach for implementation

## Integration with Other Components

This skill works with:
- **Kiro Architect Agent**: For interactive design
- **TDD Coach Agent**: For implementation guidance
- **Kiro Evaluator Agent**: For quality validation
- **Commands**: Uses `/kiro-new`, `/kiro-scope` internally

## Technical Implementation

When activated, this skill:

1. **Analyzes Context**
   ```
   - Empty directory? → Fresh project
   - Existing code? → Migration to kiro
   - Monorepo? → Workspace setup
   ```

2. **Gathers Information**
   ```
   - Project type (API, CLI, library, etc.)
   - Language and framework preferences
   - Database requirements
   - Scale expectations
   - Team size and experience
   ```

3. **Generates Structure**
   ```
   - Creates directory hierarchy
   - Writes specification templates
   - Configures nix/typix
   - Sets up contracts scaffold
   - Initializes git with good .gitignore
   ```

4. **Provides Documentation**
   ```
   - CLAUDE.md with project context
   - .aidocs/ with kiro.dev documentation
   - README.md with getting started guide
   - CONTRIBUTING.md if team project
   ```

5. **Validates Quality**
   ```
   - Runs /kiro-eval to ensure scaffold is correct
   - Fixes any issues found
   - Confirms all required files present
   ```

## Examples of Activation

### Example 1: Explicit Request
```
User: I want to create a new API service with proper specifications and TDD

Claude: [Activates skill] I'll help you create a spec-driven API service using kiro.dev methodology...
```

### Example 2: Implicit Context
```
User: I'm starting a new project. It needs to be well-documented, have type safety, and use TDD. How should I structure it?

Claude: [Activates skill] It sounds like you want a spec-driven project! I can scaffold this for you using kiro.dev methodology...
```

### Example 3: Team Coordination Need
```
User: Our team is building a microservice and we need everyone on the same page about requirements and architecture

Claude: [Activates skill] Perfect use case for spec-driven development! I can create a kiro.dev project that includes...
```

## Quality Assurance

After scaffolding, this skill:
- Validates structure against kiro standards
- Ensures all required files present
- Confirms nickel contracts are valid
- Checks CLAUDE.md completeness
- Runs quick evaluation

## Best Practices Encoded

This skill ensures:
- Specifications written before implementation
- Clear acceptance criteria for all features
- Type safety through nickel contracts
- TDD workflow is default approach
- Documentation is comprehensive
- Team alignment through shared specs

## Customization

The skill adapts to:
- Solo vs team projects
- Startup vs enterprise contexts
- MVP vs full product scope
- Different programming languages
- Various tech stacks
- Organization-specific conventions

## Success Indicators

The skill successfully completed when:
- Project structure matches kiro.dev standards
- All specifications are complete and clear
- Development environment is reproducible
- TDD workflow is documented and ready
- User understands next steps

## See Also

- Kiro Architect Agent - For complex project design
- TDD Coach Agent - For implementation guidance
- Kiro Evaluator Agent - For quality checking
