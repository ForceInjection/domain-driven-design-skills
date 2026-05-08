---
name: spec-synthesis
description: Transform ambiguous requirements into precise specifications. Use before any non-trivial implementation.
---

# Specification Synthesis

Convert tickets, feature requests, or informal requirements into a structured specification document.

## Process

1. Extract the core problem being solved
2. List functional requirements (what the system must do)
3. List non-functional requirements (performance, security, UX)
4. Define clear acceptance criteria
5. Identify edge cases and constraints

## Output

Create `spec.md` using the template in `templates/spec.md`.

## Tips

- Use numbered requirements for traceability
- Each requirement should be testable
- Distinguish must-have from nice-to-have
- Ask clarifying questions before assuming
- Reference existing patterns in the codebase
