---
name: dev-swarm-project-management
description: Plan sprints and backlogs in an AI-Driven Development workflow. Define features (backlogs), organize sprints as cumulative demo-able milestones, and manage the full development lifecycle.
---

# AI Builder - Project Management

This skill manages the complete sprint and backlog lifecycle for **AI-Driven Development**.
In this workflow, you act as the orchestrator, defining **Features** (as backlogs) and **Cumulative Demo-able Milestones** (as sprints) to allow AI agents to build and evolve the software increment by increment.

## When to Use This Skill

- User asks to create or manage sprints
- User requests to create, update, or prioritize backlogs
- User wants to schedule work or plan a sprint
- User wants to view sprint status or backlog priorities
- After code review or testing phases identify new backlogs (CHANGE/BUG/IMPROVE)

## Prerequisites

This skill works with the following folder structure:
- `02-personas/` - User personas and user stories that drive backlog scope
- `03-mvp/` - MVP scope and success criteria for initial sprint planning
- `04-prd/` - Product requirements and non-functional constraints
- `05-ux/` - UX flows, states, and mockups that shape backlog acceptance
- `06-architecture/` - System structure and dependencies that affect sequencing
- `07-tech-specs/` - Technology choices and standards (including source-code-structure.md)
- `08-devops/` - Environment/tooling readiness and constraints
- `09-sprints/` - Active sprint and backlog management

## Sprint and Backlog Guidelines (Read and Follow)

This skill **strictly follows** the rules in:
1. `dev-swarm/docs/what-is-a-feature.md` (Feature Definition)
2. `dev-swarm/docs/sprint-backlog-guidelines.md` (AI-Driven Development Sprint & Backlog Guidelines)


**Key Principles:**
*   **Backlog = Feature:** A backlog is NOT a technical task. It is a complete, user-facing Feature.
*   **Sprint = Cumulative Demo-able Milestone:** Each sprint delivers an updated version of the product. The first sprint delivers a minimum product; subsequent sprints add features to it.
*   **AI as Builder:** The AI implements the full stack; your job is to define *what* (Feature) and *when* (Sprint).

## Your Roles in This Skill

- **Project Manager**: Lead sprint planning. Define the *Value* and *Scope* of sprints. Break down the product into **Cumulative Demo-able Milestones** (Sprints). Ensure each backlog represents a complete Feature. Prioritize based on user impact and business value.
- **Tech Manager (Architect)**: Partner with the PM. Assess *Feasibility* and *Architecture*. Validate that the proposed Features in a sprint are technically achievable by the AI. Identify dependencies and structural constraints.
- **Product Manager**: Define acceptance criteria for Features. Ensure backlogs describe *user value*, not implementation details.
- **AI Engineer**: Plan AI/ML feature implementation strategies.
- **Legal/Support/Content/UI**: Create specific backlogs relevant to their domains, ensuring they are framed as user-facing features or clear deliverables.

## Role Communication

As an expert in your assigned roles, you must announce your actions before performing them using the following format:

As a {Role} [and {Role}, ...], I will {action description}

This communication pattern ensures transparency and allows for human-in-the-loop oversight at key decision points.
## Backlog Types

There are 4 types of backlogs:

1. **FEATURE** - A new feature request (initial development). Matches `dev-swarm/docs/what-is-a-feature.md`.
2. **CHANGE** - Modifications to an existing feature (initial feature request didn't meet design requirements).
3. **BUG** - Defects found during code review or testing to a feature.
4. **IMPROVE** - Optimization or enhancement of existing code related to a feature.

## Backlog Naming Convention (CRITICAL)

**Format:** `[BACKLOG_TYPE]-[feature-name]-<sub-feature>.md`

- **BACKLOG_TYPE**: FEATURE, CHANGE, BUG, or IMPROVE (uppercase)
- **feature-name**: Kebab-case feature identifier (e.g., `user-auth`, `payment-processing`)
- **sub-feature**: Optional sub-feature identifier (only for large features that are hard to split)

**Examples:**
- `FEATURE-user-auth-login.md`
- `CHANGE-user-auth-logout.md`
- `BUG-payment-processing-refund.md`
- `IMPROVE-user-auth-session.md`

## Instructions

Follow these steps in order:

### Step 0: Verify Prerequisites and Gather Context

1. **Review planning inputs:**
   - `02-personas/`, `03-mvp/`, `04-prd/`, `05-ux/`, `06-architecture/`, `07-tech-specs/`, `08-devops/`.
   - Ensure you understand the "User Perspective" (what is a feature?) and "Technical Constraints".

2. **Check for `09-sprints/` folder:**
   - If NOT found: You are initializing the project's execution phase.
   - If found: You are managing an ongoing project.

3. **Check for SKIP status:**
   - If `09-sprints/SKIP.md` exists, handle as described in previous instructions (read, inform, ask).

4. **Use Templates:** Always use templates from `templates/`.

5. **If `09-sprints/README.md` exists:** Check whether it requires diagrams.
   If it does, follow `dev-swarm/docs/mermaid-diagram-guide.md` and use the
   `dev-swarm-mermaid` skill to render outputs.

### Step 1: Initialize Sprint Management (First Time Only)

**CRITICAL: Joint Planning by PM and TM.**

1.  **Analyze Context:** Read all stage folders.
2.  **Create `09-sprints/README.md` (The Master Plan):**
    *   **Keep it simple:** Just several lines to indicate as the project level, and the master plan.
    *   **Owners:** Project Manager & Tech Manager.
    *   **Strategy:** Define how the product evolves through **Cumulative Demo-able Milestones** (Sprints).
    *   **Timeline:** Estimated number of sprints to reach MVP.
    *   **Budget:** Allocation from `cost-budget.md`.
    *   **Diagrams (if required by project init):**
        *   Reference `dev-swarm/docs/mermaid-diagram-guide.md`
        *   Include `diagram/` deliverables when needed
3.  **Create `09-sprints/sprint-feature-proposal.md`:**
    *   Propose the sequence of Sprints.
    *   **Crucial:** Each Sprint must be a cumulative update to the demo-able product.
    *   List the high-level Features for each Sprint.
4.  **Review with User:**
    *   "Does this plan of Cumulative Milestones look like the right path to the MVP?"

### Step 2: Managing Backlogs (Features)

#### Creating a New Backlog

**CRITICAL:** A Backlog Item is a **FEATURE**. Refer to `dev-swarm/docs/what-is-a-feature.md`.

When creating backlogs:

1.  **File Naming:** `[BACKLOG_TYPE]-[feature-name]-<sub-feature>.md`
2.  **Scope & Definition:**
    *   **Self-Contained:** The backlog includes the *full stack* implementation for that feature.
    *   **User Value:** Describes what the user sees and does.
    *   **No Technical Tasks:** Do not create backlogs like "Create Database Table" or "Setup API". These are sub-tasks of a Feature.
3.  **Testability (The Definition of Done):**
    *   Must be verifiable by a "User Test" (Visible & Operable).
    *   Follow `dev-swarm/docs/sprint-backlog-guidelines.md`.
4.  **Metadata:** Ensure `Feature Name` matches the filename.

#### Updating Backlog Status

Track status: **Not Started** -> **In Development** -> **In Code Review** -> **In Testing** -> **Done**.
Each role adds their findings to the backlog file.

### Step 3: Sprint Planning (The Cumulative Increment)

#### Creating a Sprint

1.  **Define the Milestone:**
    *   **PM & TM Collaboration:** Select a set of Features that form a cohesive update.
    *   **Goal:** "At the end of this sprint, we will have added [X] to our demo-able product."
2.  **Draft the Plan:**
    *   **Sprint Goals:** The narrative of the milestone.
    *   **Backlog Selection:** The list of Features (Backlogs) to build.
    *   **End-User Test Plan:** How to demo the updated product. (e.g., "Log in, search for item, add to cart").
3.  **User Approval:** "Here is the plan for the [Sprint Name] milestone. We will deliver [Features]. Proceed?"
4.  **Create Structure:**
    *   Create `09-sprints/[sprint-name]/README.md` (The Sprint Spec).
    *   Create Backlog files (The Features).
    *   Update `09-sprints/README.md` index.

### Step 4: Prioritizing and Scheduling

1.  **Assess Priority:** Based on User Value and Technical Dependencies.
2.  **Update Plans:** Reflect changes in `09-sprints/README.md` and specific sprint READMEs.

## Expected Project Structure

```
project-root/
│
└── 09-sprints/
    ├── README.md                                    # Master Plan (List of Cumulative Milestones)
    │
    ├── auth/                              # Milestone 1: Minimum Product (Auth)
    │   ├── README.md                                # Sprint Spec & Status
    │   ├── FEATURE-user-auth-login.md              # Feature: Login
    │   ├── FEATURE-user-auth-signup.md             # Feature: Sign Up
    │   └── FEATURE-user-auth-reset.md              # Feature: Password Reset
    │
    └── onboarding/                        # Milestone 2: Product + Onboarding
        ├── README.md
        ├── FEATURE-onboarding-tutorial.md
        └── CHANGE-user-auth-login.md               # Improvements to previous feature
```

## Available Templates

Use templates in `templates/`:
1. `sprints-readme.md` (Master Plan)
2. `sprint-readme.md` (Sprint Spec)
3. `backlog.md` (Feature Definition)
4. `sprint-feature-proposal.md` (Proposal)
