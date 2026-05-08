---
name: plan-product
description: Create and refine a multi-phase product roadmap. Use when starting a new project, planning features, or updating the product roadmap. Leverages oracle for strategic planning.
---

# Plan Product

Create a comprehensive product roadmap using spec-driven development.

## When to Use
- Starting a new project
- Planning the next development cycle
- Adding major features to roadmap

## Workflow

1. **Analyze Current State**
   - Read `amp-os/product/roadmap.md` if exists
   - Use `finder` to understand existing codebase structure
   - Review `AGENTS.md` for project context

2. **Strategic Planning with Oracle**
   - Call `oracle` with: "Review this project and help plan the product roadmap"
   - Include: current features, goals, constraints, timeline

3. **Create/Update Roadmap**
   - Use template from [roadmap-template.md](resources/roadmap-template.md)
   - Save to `amp-os/product/roadmap.md`

4. **Sync with Todo System**
   - Use `todo_write` to create high-level milestones

## Resources
- [Roadmap Template](resources/roadmap-template.md)

## Amp Tools to Use
- `oracle` - Strategic planning and risk analysis
- `finder` - Codebase exploration
- `todo_write` - Milestone tracking
- `mermaid` - Timeline/dependency visualization
