---
name: feature-spec
description: Guide users through structured feature specification creation from idea to complete spec. Use when user wants to create a feature specification, product requirements document (PRD), technical spec for a feature, or similar structured feature planning documentation. This workflow helps users efficiently gather context, explore the codebase, define requirements, draft technical approach, and save the result to JIRA or Confluence. Trigger when user mentions "create a spec", "spec out", "write a PRD", "feature specification", or similar feature planning tasks.
---

# Feature Specification Workflow

This skill provides a structured workflow for guiding users through collaborative feature specification creation. Act as an active facilitator, walking users through three stages: Discovery, Section-by-Section Building, and Finalization.

## When to Offer This Workflow

**Trigger conditions:**
- User mentions creating a feature specification: "create a spec", "spec out", "write a spec"
- User mentions product requirements: "PRD", "product requirements", "feature requirements"
- User describes a feature idea and needs to spec it out
- User asks to plan or design a new feature

**Initial offer:**
Offer the user a structured workflow for creating the feature specification. Explain the three stages:

1. **Discovery Phase**: Gather feature context, explore codebase, search for related work
2. **Section-by-Section Building**: Iteratively build each section (Problem Statement, Requirements, Technical Approach, UI/UX)
3. **Finalization**: Review, polish, and save to JIRA or Confluence

Explain that this approach ensures the spec is informed by the existing codebase, avoids duplicating past work, and results in a complete, implementable specification.

Ask if they want to try this workflow or prefer to work freeform.

If user declines, work freeform. If user accepts, proceed to Stage 1.

## Stage 1: Discovery Phase

**Goal:** Gather context about the feature, explore the codebase, and search for related work to inform the specification.

See `references/workflow.md` for detailed step-by-step instructions. Key steps:

### Step 1: Initial Understanding

Ask essential questions to understand the feature:
- What's the feature idea in one sentence?
- Who is this feature for (target users/personas)?
- What problem does it solve?
- Where should the final spec be saved? (JIRA, Confluence, or both)

Inform them they can answer in shorthand or info-dump however works best.

### Step 2: Search Existing Work

Before building the spec, search JIRA and Confluence for:
- Similar features already implemented
- Related tickets or past decisions
- Architectural context or constraints

Use `mcp__atlassian__search` to find relevant context.

Report findings and ask if they want to review anything before proceeding.

### Step 3: Codebase Exploration

**Always explore the codebase** to understand existing architecture and patterns.

Use the Task tool with subagent_type=Explore to investigate:
- Overall project structure and tech stack
- Similar existing features
- Integration points (APIs, services, database)
- Existing patterns and conventions
- Technical constraints and opportunities

See `references/codebase-analysis.md` for detailed guidance on what to explore.

Report findings clearly:
- Architecture summary
- Similar features found
- Integration points
- Patterns to follow
- Technical considerations

### Step 4: Clarify Sections Needed

Based on the feature type, propose which sections the spec should include.

**Standard sections:**
- Problem Statement & User Needs
- Requirements & Acceptance Criteria
- Technical Approach & Architecture
- UI/UX Design Considerations

See `references/spec-template.md` for detailed section guidance.

Ask if this structure works or should be adjusted.

**Once agreed:**
- If using artifacts (claude.ai/Claude app): Create artifact with section headers and placeholders
- If in Claude Code: Create markdown file with section headers and placeholders

Announce that sections will be built one at a time, starting with whichever has the most unknowns.

## Stage 2: Section-by-Section Building

**Goal:** Build each section iteratively through clarifying questions, drafting, and refinement.

See `references/workflow.md` for complete details. Core pattern for each section:

### Section Selection

Ask which section to start with, but suggest:
- For user-facing features: Start with Problem Statement
- For technical refactors: Start with Technical Approach
- Generally: Start with the section with most unknowns

### Five-Step Pattern (for each section):

**1. Clarifying Questions**
Ask 5-8 specific questions about what should be included in this section.

**2. Brainstorming Key Points**
Generate 8-15 numbered points that might be included.
Offer to brainstorm more if needed.

**3. Curation**
Ask which points to keep, remove, or combine.
Accept freeform feedback - extract intent and proceed.

**4. Gap Check**
Ask if anything important is missing for this section.

**5. Draft the Section**
Use `str_replace` to replace the placeholder with drafted content.
Provide link/confirmation after drafting.

Ask them to indicate what to change rather than editing directly (helps learn their style).

### Iterative Refinement

Continue refining based on feedback:
- Use `str_replace` for all edits (never reprint whole doc)
- Provide link/confirmation after each edit
- If they edit directly, note their changes for future sections

After 3 iterations with no changes, ask if anything can be removed.

When satisfied, confirm section is complete and move to next.

### Section Completion

Repeat the five-step pattern for all sections.

When 80%+ complete, review entire spec for:
- Overall coherence and flow
- Inconsistencies or contradictions
- Generic filler that should be removed
- Whether every sentence carries weight

## Stage 3: Finalization

**Goal:** Polish the spec and save it to JIRA or Confluence.

See `references/jira-confluence.md` for detailed instructions on creating tickets and pages.

### Final Review

When all sections are drafted:
1. Review complete spec for overall quality
2. Check all required sections are present
3. Ensure acceptance criteria are testable
4. Verify technical approach is clear

Provide final suggestions.

Ask: "Ready to save this spec, or do you want to refine anything else?"

### Optional: Validation

If the spec is in a file, offer to run validation:

```bash
python3 scripts/validate_spec.py <spec_file.md>
```

This checks for:
- All required sections present
- Substantive content (not placeholders)
- Testable acceptance criteria
- No TODO markers remaining

### Saving the Spec

Ask the user where to save:
- **JIRA ticket only**: Full spec in ticket description
- **Confluence page only**: Full spec as Confluence page
- **Both (recommended)**: Confluence page with full spec + JIRA ticket with summary and link

**For substantial specs (>2 pages), recommend "Both".**

See `references/jira-confluence.md` for complete instructions on:
- Getting required information (Cloud ID, project key, space ID)
- Creating JIRA tickets
- Creating Confluence pages
- Creating both with proper linking

**After saving, provide the links** so user can review.

## Tips for Effective Facilitation

**Tone and Pacing:**
- Be direct and procedural - don't oversell the process
- Move efficiently without belaboring points
- Give user agency to skip or adjust steps
- Acknowledge blockers and suggest ways to move faster

**Handling Deviations:**
- User wants to skip codebase exploration: Confirm they're okay working without that context
- User has existing draft: Ask if they want to refine it section-by-section or start fresh
- User wants different section order: Follow their preference
- User provides vague feedback: Extract intent and proceed rather than forcing specific format

**Quality Over Speed:**
- Each iteration should make meaningful improvements
- Don't rush through sections to finish
- The goal is a spec that effectively guides implementation

**Context Management:**
- If gaps appear while building a section, stop and clarify
- Don't let assumptions accumulate
- Proactively ask when something isn't clear

**Document Management:**
- Use `create_file` for initial structure (if artifacts available)
- Use `str_replace` for all edits - never reprint entire document
- Provide links/confirmation after every change
- Keep the working document as single source of truth

## Resources

This skill includes reference materials loaded as needed:

### references/spec-template.md
Complete template showing structure and guidance for each section (Problem Statement, Requirements, Technical Approach, UI/UX). Load when you need to understand what each section should contain.

### references/workflow.md
Detailed step-by-step instructions for the hybrid workflow approach. Load when you need specific guidance on any stage of the process.

### references/codebase-analysis.md
Comprehensive guide on what to look for when exploring the codebase. Load when starting the codebase exploration step to understand what to investigate and how to report findings.

### references/jira-confluence.md
Complete instructions for creating and updating JIRA tickets and Confluence pages. Load when ready to save the spec to understand the specific tools and parameters needed.

### scripts/validate_spec.py
Python script to validate a completed spec for completeness and quality. Checks for required sections, substantive content, and testable acceptance criteria. Optional but helpful for final quality check.
