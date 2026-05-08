---
name: implementation-plan-generator
description: >
  Generate phased implementation plans from requirements and UI wireframes.
  Use when the user provides requirements documents and/or UI wireframes and
  wants to create a detailed, phased implementation plan. Triggers on requests
  like "create implementation plan", "plan the implementation", or when asked
  to design an implementation approach for a project with existing requirements.
  Produces description-only plans (no code) with clear phases, dependencies,
  and testing checklists.
---

# Implementation Plan Generator

## Overview

This skill generates structured, phased implementation plans from requirements documents and UI wireframes. Plans include an index file with phase summary and dependency graph, plus individual phase files with detailed specifications.

**Inputs:**
- Requirements document (features, business rules, user roles)
- UI wireframes/specifications (pages, components, interactions) - optional but recommended

**Outputs:**
- `index.md` - Overview, phase table, dependency graph, key files
- `phase-XX-name.md` - Individual phase files with specifications

## Workflow

### Step 1: Analyze Requirements

Read the requirements document and extract:
- Core features and functionality
- Business rules and constraints
- User roles and permissions
- Data entities and relationships
- Integration points with external systems

### Step 2: Analyze UI Wireframes

If UI wireframes are provided, identify:
- Pages and routes
- Components and their interactions
- Data displayed on each page
- User flows and navigation
- State management needs

### Step 3: Identify Phases

Group work into logical phases following this order:

1. **Foundation phases** (always first)
   - Data models and schema
   - Core infrastructure (auth, API structure)

2. **Domain logic phases**
   - Business logic libraries
   - Calculation and validation functions

3. **API/Backend phases**
   - API routes for CRUD operations
   - Integration endpoints

4. **UI/Frontend phases**
   - Pages and layouts
   - Interactive components

5. **Integration phases** (always last)
   - Audit logging
   - Reporting
   - Dashboard aggregations

### Step 4: Map Dependencies

For each phase, determine:
- Which phases must complete first
- Which phases can run in parallel
- The critical path through the phases

### Step 5: Generate Index

Create `index.md` following [index-template.md](references/index-template.md):
- Write overview matching project context
- Build phase summary table
- Draw ASCII dependency graph
- List key files by category
- Summarize critical business rules

### Step 6: Generate Phase Files

For each phase, create `phase-XX-name.md` following [phase-template.md](references/phase-template.md):
- Write clear goal (1-2 sentences)
- Provide background context
- Use appropriate content sections for phase type
- Add testing checklist
- Link dependencies and next phase

## Phase Type Guidelines

### Database/Model Phases
- List each model with field tables
- Define enums with value descriptions
- Document relations and constraints
- Include migration notes

### API/Backend Phases
- Specify route paths and HTTP methods
- Define request/response as TypeScript interfaces
- List validation rules
- Note authorization requirements

### UI/Frontend Phases
- Define page routes and purposes
- Include ASCII wireframes for complex layouts
- List components with props and features
- Describe client-side state and logic

### Integration Phases
- Document data flows between systems
- Specify event triggers and handlers
- Define error handling strategies

## Output Guidelines

1. **Description-only** - No implementation code, only specifications
2. **TypeScript interfaces** - Use interface syntax for API contracts
3. **Props and features** - Describe components by their interface
4. **Testing checklists** - Verification items for each phase
5. **File paths** - Specify exact paths for files to create/modify
6. **ASCII wireframes** - Use for complex UI layouts (optional)

## Example Phase Naming

Use consistent naming: `phase-XX-short-name.md`

- `phase-01-data-models.md`
- `phase-02-auth-integration.md`
- `phase-03-api-routes.md`
- `phase-04-user-dashboard.md`
- `phase-05-reporting.md`

## References

- [Index Template](references/index-template.md) - Structure for implementation plan index
- [Phase Template](references/phase-template.md) - Structure for individual phase files
