---
name: shape-spec
description: Research and gather requirements for a new feature spec. Use when you have a feature idea and need to understand scope, gather requirements, and document visuals before writing a spec.
---

# Shape Spec

Research and define requirements before writing a detailed specification.

## When to Use
- You have a feature idea to explore
- Need to gather requirements before implementation
- Want to scope out a roadmap item

## Workflow

1. **Initialize Spec Directory**
   ```
   amp-os/specs/[feature-name]/
   ├── planning/
   │   ├── requirements.md
   │   └── visuals/
   ```

2. **Research with Oracle**
   - Call `oracle`: "Help me research and scope this feature: [description]"
   - Include: user goals, constraints, existing patterns

3. **Codebase Analysis**
   - Use `finder` to find related existing code
   - Identify reusable patterns and components
   - Load `amp-os-code-analysis` skill for structured analysis

4. **Gather Requirements**
   - Document user stories
   - Define acceptance criteria
   - Note technical constraints
   - Save to `planning/requirements.md` using [requirements-template.md](resources/requirements-template.md)

5. **Collect Visuals**
   - Add mockups/screenshots to `planning/visuals/`

## Resources
- [Requirements Template](resources/requirements-template.md)

## Amp Tools to Use
- `oracle` - Scope analysis and feasibility
- `finder` - Find related code patterns
- `Read` - Analyze existing implementations
