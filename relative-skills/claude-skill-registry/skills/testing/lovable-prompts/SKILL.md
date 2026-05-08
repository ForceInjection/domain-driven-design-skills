---
name: lovable-prompts
description: Use when user asks to "create lovable prompts", "convert PRD to lovable", "generate lovable sequence", or provides a PRD file and asks to break it into implementation prompts. Converts PRDs into sequenced Lovable prompts with frontend mocks first, then backend integration.
---

# Lovable Prompts Generator

Convert Product Requirement Documents into a sequence of Lovable prompts that implement features step-by-step with clear, human-verifiable deliverables.

## Table of Contents
- [Core Principles](#core-principles)
- [Process](#process)
- [Lovable Best Practices](#lovable-best-practices)
- [Prompt Generation Rules](#prompt-generation-rules)
- [Validation](#validation)

## Core Principles

**Frontend-First with Mocks**: Build UI components with dummy data/mock adapters first, then replace with real implementations in later prompts.

**Incremental & Focused**: Each prompt tackles ONE feature or component. Never ask for entire complex apps in one prompt.

**Human-Verifiable Deliverables**: Every prompt must include a checklist that both the user and Lovable can verify before proceeding.

**Scope-Limited**: Each prompt explicitly states what NOT to touch to prevent unintended changes.

## Process

### 1. Read & Analyze PRD

- Read the PRD file provided by user
- Extract:
  - **Tech stack** (frameworks, libraries, backend)
  - **Core features** (list of capabilities)
  - **In-scope** (what to build)
  - **Out-of-scope** (what NOT to build)
  - **User flows** (how users interact)
  - **Integrations needed** (APIs, external services)

### 2. Identify Integrations

Map PRD requirements to Lovable integrations using `[Integration Name]` syntax:
- AI/LLMs: `[AI model]`, `[OpenAI]`, `[Anthropic]`
- UI Components: `[shadcn/ui]`, `[Chakra UI]`
- Payments: `[Stripe]`
- Backend: `[Supabase]`
- Maps: `[Mapbox]`, `[Google Maps]`
- Others: See prompt-integrations.md reference

Flag integrations that need API keys for setup prompts.

### 3. Sequence Implementation Phases

Break implementation into ordered phases:

**Phase 0: Project Setup** (1 prompt)
- Create Knowledge Base entry with full PRD
- Define tech stack and project structure
- List all integrations needed with API key requirements
- NO coding yet, just planning in Chat Mode

**Phase 1-N: Frontend Mocks** (1 prompt per feature/component)
- Build UI components with TypeScript types
- Use dummy data (hardcoded arrays/objects)
- Create mock adapter classes/functions for future backend calls
- Focus on ONE feature per prompt
- Each includes clear deliverables checklist

**Phase N+1-M: Backend Integration** (1 prompt per integration)
- Replace mocks with real implementations
- Integrate actual APIs, databases, auth
- Keep frontend behavior identical
- Test and verify each integration

**Phase M+1: Polish & Refinement** (if needed)
- Responsiveness fixes
- UI/UX improvements
- Error handling enhancements

### 4. Generate Numbered Prompt Files

Create files in current directory:
- `00-setup-knowledge-base.md` - Initial setup prompt
- `01-dashboard-mock.md` - First feature mock
- `02-user-profile-mock.md` - Second feature mock
- `03-integrate-supabase-auth.md` - Backend integration
- etc.

Each file is **self-contained** - user can copy-paste directly into Lovable.

### 5. Use Structured Prompt Format

Every prompt must follow this structure (see [prompt-template.md](prompt-template.md)):

```
## Context
[Tech stack, project background, link to Knowledge Base]

## Task
[Specific deliverable for this prompt]

## Guidelines
- [Key implementation details]
- [Patterns to follow]
- [Integration syntax if needed]

## Constraints
- **Do NOT modify**: [list files/features to leave untouched]
- **Focus only on**: [specific component/page]
- **Use [Integration Name] for**: [external services]

## Deliverables Checklist
- [ ] Human-readable verification step 1
- [ ] Human-readable verification step 2
- [ ] Human-readable verification step 3
```

## Lovable Best Practices

### CLEAR Framework
- **Concise**: Direct language, no fluff
- **Logical**: Step-by-step, ordered instructions
- **Explicit**: State exactly what to do and NOT do
- **Adaptive**: Acknowledge follow-up prompts will refine
- **Reflective**: Include notes on what to verify after

### Chat Mode vs Default Mode
- **Phase 0 (Setup)**: Use Chat Mode - planning only, no code changes
- **Phases 1-N (Implementation)**: Use Default Mode - direct building
- **Debugging**: Use Chat Mode - analyze before fixing

State the recommended mode at the top of each prompt.

### Scope Limiting
ALWAYS include explicit scope constraints:
```
Do NOT modify the following files:
- `AuthProvider.tsx` (authentication working correctly)
- `api/payments.ts` (payment logic is stable)

Focus changes ONLY on:
- `Dashboard.tsx` and related dashboard components
```

### Hallucination Prevention
- Reference the Knowledge Base/PRD in every prompt
- Provide exact field names, types, data structures
- Include example data formats when relevant
- Tell Lovable to ask for clarification if uncertain

### Integration Syntax
Use backtick notation: `[Integration Name]`

Example: "Use `[Supabase]` for authentication and database"
Example: "Generate images with `[AI model]`"

## Prompt Generation Rules

<critical>
1. ONE feature per prompt - never combine unrelated features
2. Frontend mocks MUST use dummy data or mock adapter classes
3. Every prompt MUST have explicit "Do NOT modify" constraints
4. Deliverables MUST be human-verifiable (not just "code works")
5. Reference Knowledge Base in every prompt after Phase 0
6. Use proper `[Integration Name]` syntax for all external services
7. Files numbered sequentially: 00, 01, 02... with descriptive names
8. Each prompt file is self-contained and copy-pasteable
</critical>

## Validation

After generating all prompts, verify:

- [ ] Phase 0 creates Knowledge Base and uses Chat Mode
- [ ] Frontend prompts use mocks/dummy data only
- [ ] Backend prompts clearly state "replace mock with real implementation"
- [ ] Each prompt has 3-5 human-verifiable deliverables
- [ ] Every prompt includes explicit scope constraints
- [ ] Integration syntax `[Name]` used consistently
- [ ] Files numbered sequentially with clear names
- [ ] Total prompts reasonable (typically 5-15 for most PRDs)

## Resources

- [prompt-template.md](prompt-template.md) - Reusable prompt structure
- [examples.md](examples.md) - Example prompts for different phases
