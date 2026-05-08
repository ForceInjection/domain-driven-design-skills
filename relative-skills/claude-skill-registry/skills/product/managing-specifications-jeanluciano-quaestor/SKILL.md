---
name: Managing Specifications
description: Create, manage, and track specifications through their full lifecycle from draft to completion. Use when user wants to plan features, create specs, check progress, activate work, or complete specifications.
allowed-tools: [Write, Read, Edit, Bash, Glob, Grep]
---

# Managing Specifications

I help you work with specifications: creating new specs from requirements, managing their lifecycle (draft → active → completed), and tracking progress automatically.

## When to Use Me

**Auto-activate when:**
- Invoked via `/quaestor:plan` slash command
- User describes a feature with details: "I want to add user authentication with JWT tokens"
- User explicitly requests spec creation: "Create a spec for X", "Write a specification for Y"
- User asks about spec status: "What specs are active?", "Show spec progress"
- User wants to activate work: "Start working on spec-feature-001"
- User wants to complete: "Mark spec-feature-001 as done"
- User checks progress: "How's the authentication feature going?"

**Do NOT auto-activate when:**
- User says only "plan" or "plan it" (slash command handles this)
- User is making general requests without specification context
- Request needs more clarification before creating a spec

## Quick Start

**New to specs?** Just describe what you want to build:
```
"I want to add email notifications when orders are placed"
```

I'll ask a few questions, then create a complete specification for you.

**Have specs already?** Tell me what you need:
```
"Show me my active specs"
"Activate spec-feature-003"
"What's the progress on spec-auth-001?"
```

## How I Work

I detect what you need and adapt automatically:

### Mode 1: Creating Specifications

When you describe a feature or ask me to create a spec, I:
1. Ask clarifying questions (if needed)
2. Generate a unique spec ID (e.g., `spec-feature-001`)
3. Create `.quaestor/specs/draft/[spec-id].md`
4. Report next steps

**See @WRITING.md for the complete specification template and writing process**

### Mode 2: Managing Lifecycle

When you ask about spec status or want to move specs, I:
1. Check current state (scan all folders)
2. Perform the requested action (activate, complete, show status)
3. Update spec metadata automatically
4. Report changes

**See @LIFECYCLE.md for folder-based lifecycle management and progress tracking**

## The 3-Folder System

Specifications live in folders that represent their state:

```
.quaestor/specs/
├── draft/              # New specs (unlimited)
├── active/             # Work in progress (MAX 3)
└── completed/          # Finished work (archived)
```

**The folder IS the state** - no complex tracking needed!

**Why max 3 active?** Forces focus on finishing work before starting new features.

## Progressive Workflows

I provide just enough information for your current task, with details available when needed:

### Creating Your First Spec

**Minimal workflow** (I guide you):
```
You: "Add user authentication"
Me: I'll ask 3-5 questions
Me: Create spec-feature-001.md in draft/
```

### Managing Existing Specs

**Common operations**:
- `"Show active specs"` → List with progress bars
- `"Activate spec-feature-003"` → Move draft/ → active/
- `"Complete spec-auth-001"` → Move active/ → completed/

### Deep Dive Available

When you need more details:
- **@WRITING.md** - Complete template, field descriptions, examples
- **@LIFECYCLE.md** - All lifecycle operations, validation rules, batch operations
- **@TEMPLATE.md** - Field-by-field guide to spec structure

## Key Features

### Smart Spec Creation
✅ Auto-generate unique IDs
✅ Forgiving template (auto-corrects common mistakes)
✅ No placeholders - only real values
✅ Rich metadata (priority, type, timestamps)

### Automatic Lifecycle Management
✅ Folder-based states (simple and visual)
✅ 3-active-spec limit (enforced automatically)
✅ Progress calculation from checkboxes
✅ Metadata updates on state changes

### Progress Tracking
✅ Parse checkbox completion: `- [x]` vs `- [ ]`
✅ Calculate percentage: 4/5 complete = 80%
✅ Visual progress bars
✅ Branch linking support

## Success Criteria

**Creating specs:**
- ✅ Spec has unique ID and proper frontmatter
- ✅ All fields have actual values (no placeholders)
- ✅ Acceptance criteria defined with checkboxes
- ✅ Saved to `.quaestor/specs/draft/[spec-id].md`

**Managing specs:**
- ✅ State transitions work correctly (draft → active → completed)
- ✅ 3-active limit enforced
- ✅ Progress calculated accurately from checkboxes
- ✅ Metadata updates automatically

## Next Steps After Using This Skill

Once you have specifications:
1. **Activate a spec**: "Activate spec-feature-001"
2. **Implement it**: Use `/impl spec-feature-001` or implementing-features skill
3. **Track progress**: "What's the status?" or "Show active specs"
4. **Complete it**: "Complete spec-feature-001" when all criteria checked
5. **Ship it**: Use reviewing-and-shipping skill to create PR

---

*I handle both creation and management of specifications. Just tell me what you need - I'll detect the mode and guide you through it with minimal upfront context.*
