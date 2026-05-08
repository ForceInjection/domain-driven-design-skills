---
name: write-spec
description: Write a detailed feature specification from requirements. Use after shaping to create spec.md with goals, user stories, requirements, and technical approach.
---

# Write Spec

Create a comprehensive specification document from gathered requirements.

## When to Use
- Requirements are gathered in `planning/requirements.md`
- Ready to document the technical specification
- Need a clear spec before task breakdown

## Workflow

1. **Analyze Inputs**
   - Read `amp-os/specs/[feature]/planning/requirements.md`
   - Review any visuals in `planning/visuals/`
   - Load relevant standards skills

2. **Search for Reusable Code**
   - Use `finder` to locate similar implementations
   - Document patterns to reuse
   - Note existing components to leverage

3. **Write Specification**
   - Follow template exactly from [spec-template.md](resources/spec-template.md)
   - Save to `amp-os/specs/[feature]/spec.md`

4. **Generate Architecture Diagram**
   - Load `amp-os-architecture-diagrams` skill
   - Create system/component diagram with `mermaid`

5. **Verify Spec Quality**
   - Load `amp-os-spec-verifier` skill
   - Ensure completeness and feasibility

## Important Constraints
- Do NOT write actual code in spec.md
- Keep sections concise and skimmable
- Reference visual assets when available
- Follow template structure exactly

## Resources
- [Spec Template](resources/spec-template.md)

## Amp Tools to Use
- `finder` - Find similar implementations
- `mermaid` - Architecture diagrams
- `oracle` - Review spec for completeness
