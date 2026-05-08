---
name: proposal-execution
description: Use when executing approved proposals. Researchers can execute ANY approved proposal (not just their own) to perform actions like memory cleanup, marking proposals ready for ticket/skill creation.
---

# Proposal Execution

## Overview

Researchers can create proposals, but they cannot execute them directly - they need approval first. Once a proposal is **approved** by a human/reviewer, **any** researcher can use `execute_proposal` to carry out the proposed action.

## When to Use

Use `execute_proposal` when:
- Your proposal has been **approved** (status = "approved")
- You want to perform the action described in the proposal

## Important: Two-Step Workflow for task, autonomous_task, and skill_proposal

For `task`, `autonomous_task`, and `skill_proposal` types, execution does **NOT** automatically create the artifact (ticket or skill file). Instead:

1. **Execute the proposal** → Returns "ready_for_*" message
2. **Do your research** → Investigate the codebase, gather context
3. **Create the artifact** → Use `create_ticket_from_proposal` or create the skill file manually

This allows researchers to do proper research after approval but before creating artifacts.

**Key differences:**
- `autonomous_task` and `test_gap` can be approved by reviewer (not requiring human approval)
- Tickets from autonomous workflow proposals start in **backlog** status (skip draft)
- Tickets from human workflow proposals start in **draft** status

## Execution Workflow by Proposal Type

### memory_cleanup
Deletes agent memories specified in `metadata.memory_ids_to_delete`.

**Execution result:**
```json
{
  "action": "deleted_memories",
  "count": 3,
  "memory_ids": [1, 2, 3]
}
```

**Example:**
```bash
execute_proposal(proposal_id: 42)
# Deletes memories [10, 15, 20] per proposal #42
```

### task
Marks the proposal as ready for ticket creation. Does NOT create a ticket automatically.

**Execution result:**
```json
{
  "action": "ready_for_ticket_creation",
  "message": "Proposal approved. Use create_ticket_from_proposal to create the ticket after your research."
}
```

**Next steps:**
1. Do your research (investigate codebase, understand requirements)
2. Use `create_ticket_from_proposal` to create the ticket
3. The proposal will be marked as executed when the ticket is created

### task (withdrawal)
If the proposal has `metadata.target_proposal_id`, it withdraws the target proposal instead of creating a ticket.

**Execution result:**
```json
{
  "action": "withdrew_proposal",
  "target_proposal_id": 41,
  "target_title": "Obsolete proposal"
}
```

### autonomous_task
Marks the proposal as ready for ticket creation. Same as `task`, but can be approved by reviewer (not requiring human approval). Created tickets start in **backlog** status.

**Execution result:**
```json
{
  "action": "ready_for_ticket_creation",
  "message": "Proposal approved. Use create_ticket_from_proposal to create the ticket after your research.",
  "workflow": "autonomous"
}
```

**Next steps:**
1. Do your research (investigate codebase, understand requirements)
2. Use `create_ticket_from_proposal` to create the ticket
3. Ticket will be created in **backlog** status (not draft)
4. The proposal will be marked as executed when the ticket is created

### refactor
Creates a refactor ticket automatically with evidence links.

**Execution result:**
```json
{
  "action": "created_ticket",
  "ticket_id": 124,
  "ticket_title": "Refactor: Improve database query performance"
}
```

### test_gap
Creates a ticket for adding tests automatically. Starts in **backlog** status (autonomous workflow).

**Execution result:**
```json
{
  "action": "created_ticket",
  "ticket_id": 125,
  "ticket_title": "Add tests: Payment processing edge cases"
}
```

### skill_proposal
Marks the proposal as ready for skill file creation. Does NOT create the skill file automatically.

**Execution result:**
```json
{
  "action": "ready_for_skill_creation",
  "message": "Proposal approved. Create the skill file after your research.",
  "skill_name": "code_review_helper"
}
```

**Next steps:**
1. Do your research (understand requirements, check existing skills)
2. Use `create_ticket_from_proposal` to create the ticket
3. The proposal will be marked as executed when the ticket is created

## Example Workflows

### Memory Cleanup (Immediate Execution)
```ruby
# 1. Create a memory cleanup proposal
create_proposal(
  title: "Clean up obsolete test memories",
  proposal_type: "memory_cleanup",
  reasoning: "These memories are from old test runs and are no longer relevant",
  confidence: 75,
  priority: "low",
  metadata: {
    memory_ids_to_delete: [100, 101, 102],
    evidence_links: [
      { type: "memory", id: 100, description: "Outdated test configuration" }
    ]
  }
)

# 2. Check if approved
my_proposals = list_proposals(status: "approved")

# 2. Execute the approved proposal
execute_proposal(proposal_id: 42)
# => Deletes memories 100, 101, 102
# => Marks proposal #42 as "executed"
```

### Task (Two-Step Workflow)
```ruby
# 1. Execute the proposal
execute_proposal(proposal_id: 43)
# => Returns "ready_for_ticket_creation"

# 2. Do your research
memories = search_memory("authentication patterns")
# ... investigate codebase ...

# 3. Create the ticket with your research findings
create_ticket_from_proposal(
  proposal_id: 43,
  title: "Implement OAuth authentication",
  description: "Based on research, we should use Devise OAuth gem...",
  ticket_type: "story"
)
# => Creates ticket and marks proposal #43 as "executed"
```

### Autonomous Task (Two-Step Workflow, Reviewer Approval)
```ruby
# 1. Execute the proposal (approved by reviewer, not human)
execute_proposal(proposal_id: 44)
# => Returns "ready_for_ticket_creation", workflow: "autonomous"

# 2. Do your research
memories = search_memory("documentation patterns")
# ... investigate codebase ...

# 3. Create the ticket (starts in backlog, not draft)
create_ticket_from_proposal(
  proposal_id: 44,
  title: "Update README with new docs",
  description: "Documentation needs to reflect recent API changes...",
  ticket_type: "task"
)
# => Creates ticket in backlog status
# => Marks proposal #44 as "executed"
```

### Skill Proposal (Two-Step Workflow)
```ruby
# 1. Execute the proposal
execute_proposal(proposal_id: 44)
# => Returns "ready_for_skill_creation"

# 2. Do your research
# ... understand skill requirements ...

# 3. Create the skill file manually
# Create .claude/skills/my-custom-skill/SKILL.md
# => Proposal #44 is already marked as "executed"
```

## Error Handling

### Not Approved
```json
{
  "success": false,
  "error": "Forbidden",
  "message": "Can only execute approved proposals",
  "status": "pending"
}
```

### Already Executed
```json
{
  "success": false,
  "error": "Forbidden",
  "message": "Proposal already executed",
  "status": "executed"
}
```
