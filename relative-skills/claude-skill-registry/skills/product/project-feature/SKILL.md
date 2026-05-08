---
name: project-feature
description: Adds new fields or features to Project entity. Use when extending project schema, adding new properties, updating forms, or modifying project display. Includes type updates, API changes, and validation.
---

# Add Project Feature Skill

## Instructions

When adding a new field to Project:

1. **Update Types**
   - `src/lib/types.ts` - Frontend interface
   - `src/lib/db-types.ts` - Firestore doc & API response

2. **Add Validation** (if needed)
   - `src/lib/security-utils.ts` - CONTENT_LIMITS & validators

3. **Update API Routes**
   - `POST /api/projects` - Create
   - `GET /api/projects/[id]` - Read
   - `PATCH /api/projects/[id]` - Update

4. **Update Form Components**
   - `src/app/menu/register/page.tsx`
   - `src/app/menu/edit/[id]/page.tsx`

5. **Update Display Components**
   - `src/components/ProjectCard.tsx`
   - `src/app/menu/[id]/page.tsx`

For complete checklist with code examples, see [reference.md](reference.md).
