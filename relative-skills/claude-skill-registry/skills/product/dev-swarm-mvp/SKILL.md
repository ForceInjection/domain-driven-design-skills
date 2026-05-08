---
name: dev-swarm-mvp
description: Define MVP scope, success metrics, and explicit out-of-scope items to focus on the smallest testable product. Use when user asks to define MVP, scope MVP, or start Stage 3 after personas.
---

# AI Builder - MVP Definition

This skill creates/updates the MVP (Minimum Viable Product) definition by identifying the smallest testable product that delivers core value, explicitly defining what NOT to build, and establishing success metrics for validation.

## When to Use This Skill

- User asks to "define MVP" or "scope MVP"
- User requests to start Stage 3 or the next stage after personas
- User wants to identify core features for MVP
- User wants to define success metrics
- User needs to clarify what should be excluded from MVP

## Prerequisites

This skill requires **02-personas** to be completed. The MVP scope will build upon user personas and prioritized user stories (P0/P1/P2) defined in that stage.

## Your Roles in This Skill

- **Product Manager**: Define MVP scope by selecting only P0 (must-have) features. Create success criteria and key metrics for MVP validation. Identify what "viable" means for the specific product. Define learning objectives and what needs to be validated.
- **Tech Manager (Architect)**: Design MVP architecture with future scalability in mind. Identify technical shortcuts acceptable for MVP and document technical debt. Plan for instrumentation and analytics from day one. Define what can be manual vs. automated in MVP.
- **UX Designer**: Simplify designs to MVP essentials. Create streamlined user flows for core features only. Focus on usability over polish. Ensure core user journey is intuitive.

## Role Communication

As an expert in your assigned roles, you must announce your actions before performing them using the following format:

As a {Role} [and {Role}, ...], I will {action description}

This communication pattern ensures transparency and allows for human-in-the-loop oversight at key decision points.
## Instructions

Follow these steps in order:

### Step 0: Verify Prerequisites and Gather Context

1. **Check if `02-personas/` folder exists (mandatory):**
   - If NOT found: Inform user they need to create personas first, then STOP
   - If found: Read all files to understand:
     - User personas and their needs
     - User stories (especially P0 stories)
     - Acceptance criteria
     - Problem statement reference

2. **Check if `00-init-ideas/` folder exists (recommended):**
   - If found: Read to understand:
     - Problem statement
     - Value proposition
     - Owner requirements
     - Cost budget (to understand constraints for this stage)

3. **Check if `01-market-research/` folder exists (optional):**
   - If found: Read to understand:
     - Market gaps
     - Competitor features
     - Validation findings

4. **Check if this stage should be skipped:**
   - Check if `03-mvp/SKIP.md` exists
   - **If SKIP.md exists:**
     - Read SKIP.md to understand why this stage was skipped
     - Inform the user: "Stage 3 (mvp) is marked as SKIP because [reason from SKIP.md]"
     - Ask the user: "Would you like to proceed to the next stage (prd)?"
     - **If user says yes:**
       - Exit this skill and inform them to run the next stage skill
     - **If user says no:**
       - Ask if they want to proceed with MVP anyway
       - If yes, delete SKIP.md and continue with this skill
       - If no, exit the skill

5. **Check if `03-mvp/` folder exists:**
   - If exists: Read all existing files to understand current MVP definition
   - If NOT exists: Will create new structure

6. **If README.md exists:** Check whether it requires diagrams. If it does,
   follow `dev-swarm/docs/mermaid-diagram-guide.md` and use the
   `dev-swarm-mermaid` skill to render outputs.

7. Proceed to Step 1 with gathered context

### Step 1: Refine Design Requirements in README and Get Approval

**CRITICAL: Create/update README.md first based on previous stage results, get user approval, then create other docs.**

1. **Analyze information from previous stages:**
   - Read `02-personas/` to understand user personas and P0 user stories
   - Read `00-init-ideas/` to understand problem statement and value proposition
   - Read `01-market-research/` (if exists) to understand market context
   - Consider cost-budget constraints for this stage

2. **Create or update 03-mvp/README.md with refined requirements:**
   - List deliverables explicitly in README (typical: mvp-scope.md, out-of-scope.md, success-metrics.md)
   - **Stage overview and objectives** (based on previous stage context)
   - **Owners:** Product Manager, Tech Manager, UX Designer
   - **Diagrams (if required by project init):**
     - Reference `dev-swarm/docs/mermaid-diagram-guide.md`
     - Include `diagram/` deliverables when needed
   - **What MVP will be defined:**
     - How P0 features from personas will be scoped into MVP
     - What success metrics will be defined
     - What will be explicitly excluded (out-of-scope)
   - **Methodology:**
     - How MVP scope will be determined (P0 features only)
     - Success metrics approach
   - **Deliverables planned:**
     - List of files that will be created (mvp-scope.md, out-of-scope.md, success-metrics.md, etc.)
   - **Budget allocation for this stage** (from cost-budget.md)
   - **Status:** In Progress (update to "Completed" after implementation)

3. **Present README to user:**
   - Show the MVP approach and what will be defined
   - Show what documentation files will be created
   - Explain how it aligns with previous stages
   - Ask: "Does this MVP definition plan look good? Should I proceed with defining MVP scope and metrics?"

4. **Wait for user approval:**
   - **If user says yes:** Proceed to Step 2
   - **If user says no:**
     - Ask what needs to be changed
     - Update README based on feedback
     - Ask for approval again

### Step 2: Create/Update MVP Structure

**Only after user approves the README:**

1. **Create files as specified in the approved README.md:**

   **IMPORTANT:** The file structure below is a SAMPLE only. The actual files you create must follow what was approved in the README.md in Step 1.

   **Typical structure (example):**
   ```
   03-mvp/
   ├── README.md (already created and approved in Step 1)
   ├── mvp-scope.md (if specified in README)
   ├── out-of-scope.md (if specified in README)
   └── success-metrics.md (if specified in README)
   ```

   **Create only the files listed in the README's "Deliverables planned" section.**

### Step 3: Create/Update MVP Scope Documentation

**IMPORTANT: Only create MVP documentation after README is approved in Step 1.**

**NOTE:** The content structure below provides GUIDELINES for typical MVP documentation. Adapt based on the approved README and project needs.

**mvp-scope.md (if specified in README):**

Define the MVP scope following these principles:

1. **MVP Definition:**
   - What is the Minimum Viable Product for this project?
   - What is the smallest version that delivers the core value proposition?
   - What does "viable" mean for this specific product?

2. **Core Value Proposition:**
   - What is the ONE main problem this MVP solves?
   - How does it solve the problem differently than alternatives?
   - Why would early adopters choose this MVP?

3. **P0 Features Only (Must-Have):**
   - Extract P0 user stories from 02-personas/user-stories.md
   - List each P0 feature with:
     - Feature name and description
     - Which persona(s) it serves
     - Why it's essential for MVP (core value delivery)
     - Acceptance criteria from user stories
   - **Rule**: Only include features that are absolutely necessary to solve the core problem
   - Typically 5-10 P0 features maximum

4. **MVP User Journey:**
   - Describe the end-to-end user journey for the primary persona
   - Identify the critical path through the MVP
   - Ensure journey is complete and testable

5. **Target Users for MVP:**
   - Who are the early adopters/beta testers?
   - How many users are needed to validate the MVP?
   - What characteristics make them ideal for MVP testing?

6. **MVP Timeline:**
   - Estimated sprints to build MVP (typically 1-3 sprints with AI assistance)
   - Key milestones and checkpoints

**out-of-scope.md:**

Explicitly define what will NOT be in the MVP:

1. **P1 Features Deferred (Should-Have, but not MVP):**
   - List each P1 feature from user stories
   - Explain why it's deferred to post-MVP
   - When it should be added (e.g., "after MVP validation", "v1.1")

2. **P2 Features Excluded (Nice-to-Have):**
   - List each P2 feature from user stories
   - Confirm these are post-MVP enhancements

3. **Technical Shortcuts Acceptable for MVP:**
   - What technical debt is acceptable? (document it)
   - What can be manual instead of automated?
   - What third-party services can replace custom development?
   - What optimizations can be deferred?

4. **Design Polish Deferred:**
   - What design refinements are not MVP-critical?
   - What can use basic UI instead of polished design?

5. **Explicit Exclusions:**
   - Features that might seem related but are definitely out of scope
   - Common feature requests to explicitly reject for MVP
   - Integrations or platforms deferred to later

**Purpose**: This document prevents scope creep and keeps the team focused on core value.

**success-metrics.md:**

Define how MVP success will be measured:

1. **Learning Objectives:**
   - What do we need to learn from this MVP?
   - What assumptions are we testing?
   - What questions do we need answered?

2. **Key Metrics (Quantitative):**

   **Activation Metrics:**
   - What does "activated user" mean for this product?
   - Target activation rate (e.g., "60% of signups complete onboarding")

   **Engagement Metrics:**
   - How do we measure engagement? (DAU, WAU, MAU, feature usage, etc.)
   - Target engagement level (e.g., "users perform core action 3x per week")

   **Retention Metrics:**
   - What defines a retained user? (e.g., "returns within 7 days")
   - Target retention rate (e.g., "40% week-1 retention")

   **Conversion Metrics (if applicable):**
   - What conversions matter? (signup, payment, referral, etc.)
   - Target conversion rates

   **Performance Metrics:**
   - Page load time targets
   - API response time targets
   - Uptime targets (e.g., "99% uptime")

3. **Success Criteria (What "Success" Looks Like):**
   - Define minimum thresholds for each key metric
   - What results would indicate "Proceed to Full Product"?
   - What results would indicate "Iterate MVP"?
   - What results would indicate "Pivot"?

4. **Validation Milestones:**
   - Week 1: What should we observe?
   - Week 2-3: What patterns should emerge?
   - Week 4+: What validates product-market fit?

5. **Qualitative Feedback Goals:**
   - How many user interviews? (target: 20-50 users)
   - What feedback mechanisms? (surveys, support tickets, interviews)
   - What questions to ask users?
   - What user behaviors to observe?

6. **Analytics Implementation:**
   - What analytics tools will be used? (Google Analytics, Mixpanel, etc.)
   - What events need to be tracked?
   - What dashboards need to be created?

### Step 4: Ensure Traceability

Make sure MVP scope maps back to:
- P0 user stories from 02-personas/user-stories.md
- Primary persona needs from 02-personas/persona-primary.md
- Problem statement from 00-init-ideas (if available)
- Value proposition from 00-init-ideas (if available)

Ensure out-of-scope clearly excludes P1 and P2 features.

### Step 5: Final User Review

1. **Inform user that MVP definition is complete**
2. **Update README.md:**
   - Change **Status** from "In Progress" to "Completed"
   - Add a **Summary** section with key insights (2-3 paragraphs)
   - Add a **Created Files** section listing all created files

3. **Present completed work to user:**
   - Number of P0 features in MVP scope
   - What's explicitly excluded (P1/P2 features deferred)
   - Success metrics and validation approach
   - Estimated timeline (sprints)
   - Explain the rationale: why this is the smallest testable product

4. Ask if they want to proceed to the next stage (PRD creation)
5. Make adjustments based on user feedback if needed

### Step 6: Commit to Git (if user confirms)

1. **If user confirms MVP definition is complete:**
   - Ask if they want to commit to git
2. **If user wants to commit:**
   - Stage all changes in `03-mvp/`
   - Commit with message: "Define MVP scope and success metrics (Stage 3)"

## Expected Project Structure

```
project-root/
├── 00-init-ideas/
│   └── [existing files]
├── 01-market-research/ (optional)
│   └── [existing files if present]
├── 02-personas/
│   └── [existing files]
└── 03-mvp/
    ├── README.md (with owners and summary)
    ├── mvp-scope.md (P0 features, user journey, timeline)
    ├── out-of-scope.md (P1/P2 deferred, exclusions)
    └── success-metrics.md (quantitative + qualitative metrics)
```

## Key MVP Principles

1. **Focus on Core Value**: Only features that deliver the central value proposition
2. **Smallest Testable Product**: If you can remove it and still solve the problem, it's not MVP
3. **Learn Fast**: Prioritize speed to market over perfection
4. **Measure Everything**: Define metrics before building
5. **Accept Imperfection**: Technical debt and rough edges are acceptable if documented
6. **Manual is OK**: Don't automate everything - some things can be manual in MVP
7. **Explicit Exclusions**: Clearly state what will NOT be built to prevent scope creep

## MVP Feature Selection Criteria

A feature is MVP only if ALL of these are true:
- ✅ **Must solve the core problem** for your target user
- ✅ **Must be testable** - can you measure if it works?
- ✅ **Must be achievable** in 1-3 sprints with AI assistance
- ✅ **Must differentiate** your product from alternatives
- ❌ **Cannot be nice-to-have** - if you can remove it and still solve the problem, it's NOT MVP

## Success Metrics Guidelines

1. **Keep metrics simple**: 3-5 key metrics maximum for MVP
2. **Focus on learning**: Metrics should answer your key questions
3. **Balance quant + qual**: Numbers tell you what, user feedback tells you why
4. **Set realistic targets**: Base targets on research and industry benchmarks
5. **Plan instrumentation**: Analytics must be implemented from day one
6. **Define decision criteria**: What results lead to Proceed/Iterate/Pivot/Perish?

## Deliverables

By the end of this stage, you should have:
- Clear MVP scope with P0 features only (5-10 features typically)
- Complete user journey for primary persona
- Explicit list of what's excluded (P1/P2 features, technical shortcuts)
- Quantitative success metrics with targets
- Qualitative feedback collection plan
- Learning objectives and validation questions
- Analytics implementation plan
- Foundation for PRD creation (next stage)
