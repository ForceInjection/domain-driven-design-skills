---
name: plan-prd
description: Create product requirement documents when user wants to plan features, write specs, or document new functionality. Supports minimal core features, focused expansions, and task-based changes. Automatically loads context from related PRDs to maintain consistency.
---

# Plan PRD

Create structured PRDs using the **"land then expand"** approach with automatic context management for consistency.

**Communication Style**: In all interactions and commit messages, be extremely concise and sacrifice grammar for the sake of concision.

## Philosophy: Land Then Expand

Modern Claude models work best when they establish patterns first, then layer complexity. This skill creates:

1. **Core PRDs**: Minimal foundation with essential fields only (2-4 substories max)
2. **Expansion PRDs**: Focused enhancements building on completed core with auto-loaded context

**Why**: Large comprehensive PRDs lead to incorrect assumptions, token inefficiency, and inconsistent results.

## Activation Context

Use when user says things like:
- "plan a feature for..."
- "write a PRD for..."
- "I want to build..."
- "document requirements for..."
- "create a spec for..."
- "plan [feature name]"
- Any request to plan, design, or document new functionality

## Workflow

### Phase 0: Validate Prerequisites

**FIRST: Check for CLAUDE.md**

```bash
if [[ ! -f "CLAUDE.md" ]]; then
    cat <<EOF
❌ ERROR: CLAUDE.md file not found in project root

This workflow requires a CLAUDE.md file documenting your project conventions.

To create one, start a new Claude Code session and type:
  /init

Then describe your project, and Claude will help create CLAUDE.md.

Exiting...
EOF
    exit 1
fi
```

**Show confirmation:**
```
✅ CLAUDE.md found
📋 Ready to plan PRD
```

### Phase 1: Determine PRD Type and Load Context

**Step 1: Ask PRD Type**

**CRITICAL**: Ask user to determine the PRD type:

```
Is this:
1. 🌱 A new core feature (minimal foundation to establish patterns)
2. 🔧 An expansion of existing feature (builds on completed core)
3. ⚡ A task-based change (infrastructure, migration, optimization, refactor, etc.)

Choose [1/2/3]:
```

**If user chooses "1 - Core Feature":**
- Create minimal foundation PRD
- Max 2-4 substories in single phase
- Essential fields only
- File: `.claude/prds/YYYY-MM-DD-{feature}-core.md`
- Goal: Establish patterns and working code, NOT completeness
- Initialize context: `.claude/prds/context/YYYY-MM-DD-{feature}-core.json`

**If user chooses "2 - Expansion":**
- Ask: "Which core feature does this expand?" or auto-detect from `.claude/prds/`
- **VALIDATE CORE PRD EXISTS AND IS COMPLETE:**
  ```bash
  # Check core PRD exists
  if [[ ! -f "$core_prd_file" ]]; then
      echo "❌ ERROR: Core PRD not found"
      exit 1
  fi

  # Check core PRD is marked complete
  if ! grep -q "Status.*Complete" "$core_prd_file"; then
      echo "⚠️  WARNING: Core PRD not marked complete"
      echo "Expansion PRDs should build on completed cores."
      echo "Continue anyway? [yes/no]"
  fi

  # Check context file exists
  if [[ ! -f ".claude/prds/context/{core-prd-name}.json" ]]; then
      echo "⚠️  WARNING: No context file found for core PRD"
      echo "Context may be limited. Continue? [yes/no]"
  fi
  ```
- **AUTOMATICALLY LOAD CORE CONTEXT:**
  1. Read core PRD file (parse frontmatter, substories, acceptance criteria)
  2. Load `.claude/prds/context/{core-prd-name}.json` (structured context)
  3. Extract files_created, patterns, libraries, architectural_decisions
  4. Read actual core implementation files (analyze code patterns)
  5. Document established patterns with examples
  6. Present findings to user before asking questions
- Create focused expansion PRD building on core
- File: `.claude/prds/YYYY-MM-DD-{feature}-{expansion-name}.md`
- Goal: Add ONE focused aspect using established patterns

**If user chooses "3 - Task-based Change":**
- Use task-oriented format instead of substories
- File: `.claude/prds/YYYY-MM-DD-{task-name}-task.md`
- Format: Checklist of concrete steps instead of phases/substories
- Examples: Database migration, CI/CD setup, performance optimization, refactoring, security patch
- Goal: Complete specific technical task with clear acceptance criteria

**Step 2: Understand Feature Scope**

Ask scoping question:
```
"Describe the [core feature/expansion] briefly (1-2 sentences):"
```

**For Core PRDs - Enforce Minimalism:**
If user describes complex multi-part feature, push back:
```
🌱 Core PRD Mode: Let's start with the absolute minimum.

You described: [user's description]

What's the simplest version with just essential fields?
Example: If building invoices, start with just number, date, amount.
Everything else (customers, line items, tax) comes later as expansions.

Simplest core version:
```

**For Expansion PRDs:**
Ask specifically what this expansion adds to the core.

**Step 3: Explore Existing Codebase**

**Before asking detailed questions, understand what exists:**

```bash
# Read project conventions from CLAUDE.md in project root
# This file contains project-specific conventions, tech stack, patterns, etc.
# Example: Read CLAUDE.md
```

**For Core PRDs:**
Explore to understand project patterns and conventions from CLAUDE.md and existing codebase.

**For Expansion PRDs (CRITICAL - AUTO-LOAD):**

**Execute comprehensive context loading:**

```bash
# Source context manager
source skills/shared/scripts/context-manager.sh

# 1. Load core PRD file
core_prd_content=$(cat "$core_prd_file")

# 2. Load core context file
core_context=$(read_context "$core_prd_file")

# 3. Extract structured information
core_files=$(echo "$core_context" | jq -r '.files_created[]')
core_patterns=$(echo "$core_context" | jq -r '.patterns')
core_libraries=$(echo "$core_context" | jq -r '.libraries')
core_decisions=$(echo "$core_context" | jq -r '.architectural_decisions[]')

# 4. Read actual implementation files to understand patterns
echo "📖 Reading core implementation files..."
for file in $core_files; do
    if [[ -f "$file" ]]; then
        # Read file to analyze patterns, naming conventions, structure
        # Focus on: class/function naming, code organization, error handling
    fi
done

# 5. Analyze patterns from code
# - Identify naming conventions (e.g., *Service, *Repository, *Controller)
# - Detect architectural patterns (e.g., MVC, service layer, repository pattern)
# - Note error handling approaches
# - Identify validation patterns
# - Observe data flow patterns
```

**Document comprehensive findings:**
```
🔍 Context Analysis Complete:

[For Core PRDs:]
Project Conventions (from CLAUDE.md):
- Tech stack: [framework, language, key technologies]
- Architecture: [architectural pattern from CLAUDE.md]
- Testing: [testing framework and approach]
- Code style: [linting, formatting standards]

Existing Patterns (from codebase exploration):
- Similar features found: [list related features]
- Common patterns: [list patterns observed]
- File organization: [describe structure]
- Naming conventions: [describe conventions]

[For Expansion PRDs - AUTO-LOADED:]
✅ Core Context Loaded: docs/prds/YYYY-MM-DD-{feature}-core.md

Implementation Files ([X] files):
[List actual files with brief description of each]
- path/to/file1.ext - [what it does]
- path/to/file2.ext - [what it does]

Established Patterns ([Y] patterns):
[List specific patterns with examples from code]
- Pattern 1: [name] - [where used, how implemented]
- Pattern 2: [name] - [where used, how implemented]

Libraries in Use ([Z] libraries):
[List with purpose]
- library1 - [purpose in core]
- library2 - [purpose in core]

Architectural Decisions ([W] decisions):
[List key decisions with rationale]
1. [Decision 1]: [rationale from context]
2. [Decision 2]: [rationale from context]

Code Analysis Insights:
- Naming convention: [pattern observed, e.g., "FeatureNameService"]
- Error handling: [approach used, e.g., "Custom exception classes"]
- Validation: [approach used, e.g., "Schema validators"]
- Data access: [pattern used, e.g., "Repository pattern"]

✅ Expansion will extend these patterns consistently.
```

### Phase 1: Requirements Gathering

**CRITICAL: Always use AskUserQuestion tool for interactive UX**

Do NOT just output questions as text. Use the `AskUserQuestion` tool to create an interactive experience where users can navigate through options.

**How to ask questions:**
1. Use `AskUserQuestion` tool with clear, specific questions
2. Provide 2-4 options when applicable (e.g., "Yes/No", "Small/Medium/Large scope")
3. For open-ended questions, the tool automatically provides "Other" option for text input
4. Ask questions ONE AT A TIME or in small groups (max 2-3 related questions per tool call)
5. Build on previous answers - reference what user said before

**Example - Good UX:**
```
AskUserQuestion(
  questions: [
    {
      question: "What problem does this feature solve?",
      header: "Problem",
      options: [
        {label: "User pain point", description: "Solving a specific user frustration"},
        {label: "Business need", description: "Meeting a business requirement"},
        {label: "Technical debt", description: "Improving existing system"}
      ],
      multiSelect: false
    }
  ]
)
```

**Example - Bad UX (Don't do this):**
```
Just outputting: "What problem does this solve? Who is this for? What's the scope?"
```

**Adapt questions based on PRD type:**

**CORE PRD MODE** - Ask focused essential questions (5-8 questions):

**Question flow (ask interactively with AskUserQuestion):**

1. **Problem & Context** (Group 1):
   ```
   AskUserQuestion(
     questions: [
       {
         question: "What problem does this feature solve?",
         header: "Problem",
         options: [
           {label: "User pain point", description: "Addressing user frustration"},
           {label: "Business need", description: "Meeting business requirement"},
           {label: "Technical improvement", description: "Enhancing existing system"}
         ]
       },
       {
         question: "Who will use this feature?",
         header: "Users",
         options: [
           {label: "End users", description: "Direct product users"},
           {label: "Admin users", description: "System administrators"},
           {label: "Developers", description: "Development team"}
         ]
       }
     ]
   )
   ```

2. **Minimal Scope** (Group 2):
   ```
   AskUserQuestion(
     questions: [
       {
         question: "Describe the simplest version that solves the core problem (1-2 sentences)",
         header: "Core scope",
         options: [
           {label: "Very minimal", description: "Absolute bare minimum"},
           {label: "Basic features", description: "Essential features only"},
           {label: "Need guidance", description: "Help me scope this down"}
         ]
       },
       {
         question: "What are the absolute minimum data/fields needed?",
         header: "Data model",
         options: [
           {label: "Simple (1-3 fields)", description: "Very basic data"},
           {label: "Moderate (4-7 fields)", description: "Essential data points"},
           {label: "Need examples", description: "Show me similar features"}
         ]
       }
     ]
   )
   ```

3. **Success & Boundaries** (Group 3):
   ```
   AskUserQuestion(
     questions: [
       {
         question: "How will we measure success?",
         header: "Success",
         options: [
           {label: "User adoption", description: "Number of users"},
           {label: "Performance", description: "Speed/efficiency metrics"},
           {label: "Business metric", description: "Revenue/conversion/etc"}
         ],
         multiSelect: true
       },
       {
         question: "What should we explicitly NOT include in v1?",
         header: "Out of scope",
         options: [
           {label: "List features", description: "I'll list what to exclude"},
           {label: "Everything extra", description: "Only absolute minimum"},
           {label: "Need suggestions", description: "Help me identify scope creep"}
         ]
       }
     ]
   )
   ```

4. **Technical Constraints** (Group 4 - only if needed):
   Ask these as follow-ups if applicable based on previous answers

**Approach**: Ask questions conversationally, not as a rigid checklist. If answers suggest complexity, push back:
```
💡 That sounds complex for a core PRD. Core should be minimal (2-4 substories).

You mentioned: [complex features A, B, C]

Simplest core version: [essential feature only]
Future expansions: [B], [C]

Does that work?
```

**EXPANSION PRD MODE** - Ask focused questions about the expansion (6-10 questions):

**First, present loaded context:**
```
✅ Core context loaded from: [core PRD name]

Found:
- [X] implementation files
- [Y] established patterns
- [Z] libraries in use
- [W] architectural decisions

I'll ask questions to understand how this expansion builds on these patterns.
```

**Then ask expansion-specific questions (use AskUserQuestion tool):**

1. **Expansion Goal** (Group 1):
   ```
   AskUserQuestion(
     questions: [
       {
         question: "What specific capability does this add to the core?",
         header: "Enhancement",
         options: [
           {label: "New feature", description: "Adds new functionality"},
           {label: "Data expansion", description: "Adds fields/relationships"},
           {label: "Integration", description: "Connects to external system"},
           {label: "UX improvement", description: "Enhances user experience"}
         ]
       },
       {
         question: "What user need or use case does this address?",
         header: "Use case",
         options: [
           {label: "Common request", description: "Frequently requested feature"},
           {label: "Power user", description: "Advanced user capability"},
           {label: "Business requirement", description: "Required for business"}
         ]
       }
     ]
   )
   ```

2. **Data & Integration** (Group 2):
   ```
   AskUserQuestion(
     questions: [
       {
         question: "What new data/fields are needed for this expansion?",
         header: "Data model",
         options: [
           {label: "Few fields (1-3)", description: "Small data addition"},
           {label: "Moderate (4-7)", description: "Several new fields"},
           {label: "New relationships", description: "Linking to other entities"},
           {label: "Describe custom", description: "I'll describe specific needs"}
         ]
       },
       {
         question: "How does this connect to existing core code?",
         header: "Integration",
         options: [
           {label: "Extend existing", description: "Modify core files"},
           {label: "New files", description: "Create separate files"},
           {label: "Both", description: "Mix of extending and creating"}
         ]
       }
     ]
   )
   ```

3. **Pattern Consistency** (Group 3):
   Reference loaded patterns explicitly:
   ```
   AskUserQuestion(
     questions: [
       {
         question: "I see the core uses [Pattern X] for [Purpose]. Should this expansion follow the same pattern?",
         header: "Pattern",
         options: [
           {label: "Yes, use same", description: "Keep consistency with core"},
           {label: "Slight variation", description: "Similar but adapted"},
           {label: "Different approach", description: "Need different pattern (explain why)"}
         ]
       }
     ]
   )
   ```

4. **Success & Scope** (Group 4):
   ```
   AskUserQuestion(
     questions: [
       {
         question: "How will we know this expansion works?",
         header: "Success",
         options: [
           {label: "Feature complete", description: "All functionality works"},
           {label: "Tests pass", description: "Comprehensive test coverage"},
           {label: "User validation", description: "User acceptance criteria met"}
         ],
         multiSelect: true
       },
       {
         question: "What's out of scope for THIS expansion?",
         header: "Boundaries",
         options: [
           {label: "List exclusions", description: "I'll list what to exclude"},
           {label: "Single focus", description: "Just this one aspect"},
           {label: "Future expansion", description: "Leave room for next expansion"}
         ]
       }
     ]
   )
   ```

**Important**:
- Expansion PRDs are FOCUSED on ONE aspect (e.g., customer details OR line items, not both)
- Must build on core patterns, not introduce conflicting approaches
- If scope seems large, suggest splitting into multiple expansions

### Phase 2: Document Generation

**CRITICAL**: Structure differs for core vs expansion PRDs.

#### Core PRD Structure

File: `.claude/prds/YYYY-MM-DD-{feature}-core.md`

```markdown
# [Feature Name] - Core

**Type:** Core Feature
**Created:** YYYY-MM-DD
**Status:** Planning
**Context File:** `.claude/prds/context/YYYY-MM-DD-{feature}-core.json`

## Overview

### Problem Statement
[Clear articulation of problem]

### Core Solution
[Minimal viable solution - essential fields/functionality ONLY]

### Users
[Target users]

### Success Criteria
- [Basic measurable criteria]

### SLC Commitment
**This PRD defines an SLC (Simple, Lovable, Complete) - *not* an MVP.** The release must feel complete, polished, and delightful even with a tight scope.

## Core Requirements

### Essential Data/Fields
[ONLY the minimum viable fields - example: invoice number, date, amount]

### Core User Flow
[Single primary happy path only]

### Out of Scope (Future Expansions)
[List everything NOT in core - these become expansion PRDs]
Examples:
- Customer details → expansion PRD
- Line items → expansion PRD
- Tax calculations → expansion PRD

## Implementation

**RULE**: Maximum ONE phase with 2-4 substories

### Phase 1: Core Foundation
**Goal:** Establish minimal working feature with essential patterns

#### Substory 1.1: [Minimal Model/Component]
**Description:** [Create basic entity with essential fields only]

**Acceptance Criteria:**
- [ ] [Essential field 1] works
- [ ] [Essential field 2] works
- [ ] Basic CRUD operations

**Status:** ⏳ Not Started

#### Substory 1.2: [Basic Interface/API]
**Description:** [Simple create/read operations]

**Acceptance Criteria:**
- [ ] Can create with essential fields
- [ ] Can retrieve

**Status:** ⏳ Not Started

[2-4 substories maximum]

## Project-Specific Notes
[Minimal project-specific details for core only - reference CLAUDE.md]

## Next Expansions
After core is complete, consider these expansion PRDs:
1. [Expansion 1 name]
2. [Expansion 2 name]
3. [Expansion 3 name]

## Context
This PRD has an associated context file at `.claude/prds/context/YYYY-MM-DD-{feature}-core.json` which tracks:
- Architectural decisions
- Patterns established
- Libraries chosen
- Files created

This context is automatically loaded when creating expansion PRDs.
```

#### Expansion PRD Structure

File: `.claude/prds/YYYY-MM-DD-{feature}-{expansion-name}.md`

```markdown
# [Feature Name] - [Expansion Name]

**Type:** Expansion
**Builds On:** [Link to core PRD: .claude/prds/YYYY-MM-DD-{feature}-core.md]
**Created:** YYYY-MM-DD
**Status:** Planning
**Context File:** `.claude/prds/context/YYYY-MM-DD-{feature}-{expansion}.json` (inherits from core)

## Overview

### What This Expansion Adds
[Specific enhancement to core]

### Core Implementation Reference (AUTO-LOADED)

**Core PRD:** `.claude/prds/YYYY-MM-DD-{feature}-core.md`

**Files created in core:**
[AUTO-POPULATED from context file - actual file paths from your project]

**Patterns established in core:**
[AUTO-POPULATED from context file - actual patterns used in your codebase]

**Libraries in use:**
[AUTO-POPULATED from context file - actual libraries chosen during core implementation]

**Architectural decisions:**
[AUTO-POPULATED from context file - actual decisions made during core implementation]

### Success Criteria
- [Measurable criteria for this expansion]

### SLC Commitment
**This PRD defines an SLC (Simple, Lovable, Complete) - *not* an MVP.** The release must feel complete, polished, and delightful even with a tight scope.

## Expansion Requirements

### New Data/Fields
[What's added to the core data model]

### Enhanced/New User Flows
[How this changes or adds to core flows]

### Integration with Core
[How this connects to existing core implementation]

## Implementation

### Phase 1: [Expansion Name]
**Goal:** [Expansion objective]

#### Substory 1.1: [Enhancement 1]
**Description:** [Building on core patterns]

**Core Files to Modify:**
- [existing file from core]

**Core Patterns to Follow:**
- [reference established patterns from auto-loaded context]

**Acceptance Criteria:**
- [ ] [Criterion 1]

**Status:** ⏳ Not Started

[Add substories as needed for focused expansion]

## Testing Strategy
[Test approach following core's testing framework]

## Security Considerations
[Following core's security patterns]

## Performance Considerations
[Optimizations specific to this expansion]

## Dependencies
**Internal:**
- Requires: [Core PRD completion]

**External:**
- [New third-party services if any]

## Context
This expansion inherits context from core and adds expansion-specific context to `.claude/prds/context/YYYY-MM-DD-{feature}-{expansion}.json`.
```

#### Task-Based PRD Structure

File: `.claude/prds/YYYY-MM-DD-{task-name}-task.md`

```markdown
# [Task Name]

**Type:** Task
**Created:** YYYY-MM-DD
**Status:** Planning
**Context File:** `.claude/prds/context/YYYY-MM-DD-{task-name}-task.json`

## Overview

### Problem/Goal
[Clear description of what needs to be done and why]

### Success Criteria
- [Measurable criteria for completion]

## Technical Approach

[Describe the approach, technology choices, and reasoning]

## Implementation Checklist

**Each checkbox represents a concrete step:**

### Preparation
- [ ] [Step 1: e.g., Backup database, review current config]
- [ ] [Step 2: e.g., Set up test environment]

### Execution
- [ ] [Step 3: e.g., Create migration scripts]
- [ ] [Step 4: e.g., Update configuration files]
- [ ] [Step 5: e.g., Deploy changes]

### Validation
- [ ] [Step 6: e.g., Run integration tests]
- [ ] [Step 7: e.g., Verify monitoring/alerts]
- [ ] [Step 8: e.g., Document changes]

**Status:** ⏳ Not Started

## Testing Strategy
[How to verify this task is complete]

## Rollback Plan
[How to revert if something goes wrong]

## Dependencies
**Internal:** [Other PRDs or systems affected]
**External:** [Third-party services, tools required]

## Project-Specific Notes
[Any project-specific details from CLAUDE.md]

## Context
Task-based PRDs use simplified context tracking focused on steps completed rather than phases/substories.
```

### Phase 3: Context Initialization

**After creating PRD:**

```bash
# Source context manager
source skills/shared/scripts/context-manager.sh

# Initialize context file
context_file=$(init_context "$prd_file")

# For expansions: inherit core context
if [[ "$prd_type" == "expansion" ]]; then
    # Copy core context as base
    core_context=$(read_context "$core_prd_file")
    # Add expansion-specific fields
    # Update context with expansion name
fi

# For tasks: simpler context structure
if [[ "$prd_type" == "task" ]]; then
    # Task-based context focuses on checklist completion
    # No phases/substories tracking needed
fi
```

### Phase 4: Validation and Next Steps

**After Core PRD creation:**
- Verify it's truly minimal (2-4 substories max)
- Confirm essential fields only
- Suggest expansion PRDs for excluded features
- Confirm context file created
- Output message:
```
✅ Core PRD created: .claude/prds/YYYY-MM-DD-{feature}-core.md
📋 Context file: .claude/prds/context/YYYY-MM-DD-{feature}-core.json

📋 Core includes: [brief summary]
🚫 Out of scope (future expansions): [list]

💡 What would you like to do next?
```

**Then use AskUserQuestion tool:**
```javascript
AskUserQuestion(
  questions: [
    {
      question: "What would you like to do next with this Core PRD?",
      header: "Next Step",
      options: [
        {
          label: "Implement now",
          description: "Start building core foundation with auto-testing and review"
        },
        {
          label: "Plan expansion",
          description: "Create expansion PRD for: Customer details, Line items, etc."
        }
      ],
      multiSelect: false
    }
  ]
)
```

**After Expansion PRD creation:**
- Verify it builds on completed core
- Confirm focused on ONE aspect
- Reference core implementation patterns
- Confirm context inherited and extended
- Output message:
```
✅ Expansion PRD created: .claude/prds/YYYY-MM-DD-{feature}-{expansion}.md
📋 Context file: .claude/prds/context/YYYY-MM-DD-{feature}-{expansion}.json

🔧 Expands: {core feature name}
📋 Adds: [brief summary]
🎯 Auto-loaded from core:
   - [X] files created
   - [Y] patterns
   - [Z] libraries
   - [W] architectural decisions

💡 What would you like to do next?
```

**Then use AskUserQuestion tool:**
```javascript
AskUserQuestion(
  questions: [
    {
      question: "What would you like to do next with this Expansion PRD?",
      header: "Next Step",
      options: [
        {
          label: "Implement now",
          description: "Build this expansion following core patterns with auto-testing"
        },
        {
          label: "Plan another expansion",
          description: "Create additional expansion PRD for other features"
        }
      ],
      multiSelect: false
    }
  ]
)
```

**After Task-Based PRD creation:**
- Verify checklist is concrete and actionable
- Confirm rollback plan is included
- Confirm success criteria are measurable
- Output message:
```
✅ Task PRD created: .claude/prds/YYYY-MM-DD-{task-name}-task.md
📋 Context file: .claude/prds/context/YYYY-MM-DD-{task-name}-task.json

⚡ Task: [brief summary]
📋 Steps: [X] concrete steps defined
✅ Success criteria: [brief list]
🔄 Rollback plan: Included

💡 What would you like to do next?
```

**Then use AskUserQuestion tool:**
```javascript
AskUserQuestion(
  questions: [
    {
      question: "What would you like to do next with this Task PRD?",
      header: "Next Step",
      options: [
        {
          label: "Execute task now",
          description: "Implement this task checklist with validation and rollback plan"
        },
        {
          label: "Plan another task",
          description: "Create additional task-based PRD for other changes"
        }
      ],
      multiSelect: false
    }
  ]
)
```

## Guidelines

**Critical Rules:**
- **ALWAYS use AskUserQuestion tool** - For interactive UX with navigable options (see Phase 1 for examples)
- **ALWAYS ask core vs expansion first** - This determines everything
- **For Core: Enforce minimalism** - Push back on complexity, max 2-4 substories
- **For Expansion: AUTO-LOAD core context** - Read core PRD and context file automatically
- **Initialize context files** - Always create/update `.claude/prds/context/{prd-name}.json`
- **Naming convention**:
  - Core: `.claude/prds/YYYY-MM-DD-{feature}-core.md`
  - Expansion: `.claude/prds/YYYY-MM-DD-{feature}-{expansion-name}.md`

**Project Conventions:**
- Read `CLAUDE.md` from project root for project-specific conventions
- Use project-defined terminology and patterns from CLAUDE.md
- Follow tech stack, architecture, and coding standards documented in CLAUDE.md

**Context Management:**
- Create context file on PRD creation
- For expansions: inherit core context automatically
- Store: patterns, libraries, architectural decisions from CLAUDE.md and codebase
- Used by `implement` skill for consistency

**Quality Checks:**
- Ensure acceptance criteria are testable
- Document assumptions explicitly
- Reference project patterns from CLAUDE.md and existing codebase
- For expansions: explicitly reference and auto-load core implementation patterns
- Verify context files are created and populated

## Auto-Loading Core Context (Expansion Mode)

When creating an expansion PRD, the skill **automatically**:

1. **Validates core PRD**:
   - Checks core PRD file exists
   - Warns if core is not marked complete
   - Checks context file exists
   - Verifies context file is valid JSON

2. **Loads core information**:
   - Reads core PRD file content (parse frontmatter, substories)
   - Reads `.claude/prds/context/{core-prd-name}.json` file
   - Extracts structured data (files, patterns, libraries, decisions)

3. **Analyzes implementation**:
   - Reads actual implementation files from `files_created`
   - Analyzes code patterns: naming conventions, structure, error handling
   - Identifies architectural patterns in use
   - Documents specific examples from code

4. **Presents findings before questions**:
   ```
   ✅ Core context loaded successfully

   Implementation files analyzed:
   - src/models/invoice.rb - Core data model with validations
   - src/services/invoice_service.rb - Business logic service
   - src/api/invoices_controller.rb - RESTful API endpoints

   Patterns identified:
   - Service objects for business logic (InvoiceService)
   - ActiveRecord models with validations
   - RESTful API with JSON serialization
   - RSpec for testing

   Libraries in use:
   - ActiveRecord (ORM)
   - ActiveModel::Serializers (JSON API)

   Now I'll ask how this expansion builds on these patterns...
   ```

5. **Uses context during PRD creation**:
   - Auto-fills "Core Implementation Reference" section with real data
   - References specific patterns in substory descriptions
   - Suggests extending existing files vs creating new ones
   - Inherits architectural decisions

6. **Creates expansion context**:
   - Expansion context starts with core context as base
   - Adds expansion-specific patterns, files, decisions
   - Maintains link to core PRD

**This ensures expansions are consistent with core through automated context awareness.**

## Directory Structure

The skill maintains this directory structure:

```
.claude/prds/
├── YYYY-MM-DD-feature-core.md              # Active PRD files
├── YYYY-MM-DD-feature-expansion.md
├── context/                                 # Active context files
│   ├── YYYY-MM-DD-feature-core.json
│   └── YYYY-MM-DD-feature-expansion.json
└── archive/                                 # Manual archival (user responsibility)
    ├── old-feature.md                       # Archived PRD
    └── context/
        └── old-feature.json                 # Archived context
```

**Archive Usage:**
- The `archive/` folder is created but managed by users
- When archiving a completed PRD, move **both** files:
  - `.claude/prds/feature.md` → `.claude/prds/archive/feature.md`
  - `.claude/prds/context/feature.json` → `.claude/prds/archive/context/feature.json`
- This keeps PRD and context paired together
- Only archive PRDs that are fully complete, shipped, and no longer actively referenced

## Directory Initialization

Before creating any PRD, validate and create required directories:

```bash
# Ensure .claude directory structure exists
mkdir -p .claude/prds/context
mkdir -p .claude/prds/archive/context
mkdir -p .claude/checkpoints

# Ensure checkpoints are gitignored (created by code-prd skill)
if [[ -f ".gitignore" ]]; then
    if ! grep -q "\.claude/checkpoints" .gitignore; then
        echo "\n.claude/checkpoints/" >> .gitignore
    fi
fi

# Note: archive/ is for user manual archival only
# Users should move both .md and corresponding .json to archive/
# to keep PRD and context paired together
```
