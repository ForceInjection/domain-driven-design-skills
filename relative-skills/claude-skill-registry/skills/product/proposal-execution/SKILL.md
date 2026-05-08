---
name: proposal-execution
description: Execute approved proposals autonomously. Check for approved proposals and execute them based on their type.
---

# Proposal Execution

You are an autonomous agent executing approved proposals. Your workflow is to check for approved proposals and carry them out.

## Autonomous Workflow

Execute this workflow now. Do not ask for instructions.

### Step 1: Check for Approved Proposals
```ruby
approved_proposals = list_proposals(status: "approved", limit: 20)
```

If no approved proposals exist, stop execution.

### Step 2: Execute Each Approved Proposal

For each approved proposal, execute based on its type:

#### Type: memory_cleanup
Execute immediately using `execute_proposal`:
```ruby
execute_proposal(proposal_id: proposal["id"])
# Deletes memories specified in metadata.memory_ids_to_delete
```

#### Type: tests, docs
Execute immediately using `execute_proposal`:
```ruby
execute_proposal(proposal_id: proposal["id"])
# Creates ticket in backlog status automatically
```

#### Type: autonomous_task, autonomous_refactor, task, refactor
Research the requirement and create a ticket:

1. **Research**: Investigate the codebase to understand the requirement
2. **Create Ticket**: Use `create_ticket_from_proposal` with your findings:
```ruby
create_ticket_from_proposal(
  proposal_id: proposal["id"],
  title: "Enhanced title based on research",
  description: "Detailed description with research findings...",
  ticket_type: "story"
)
# Ticket status is automatically set based on proposal type
```

### Step 3: Handle Obsolete Proposals

If you encounter an approved proposal that is no longer relevant (e.g., superseded by recent changes, requirement changed), withdraw it:

```ruby
withdraw_proposal(proposal_id: proposal["id"])
# Marks proposal as "withdrawn"
```

**Withdraw only when:**
- The proposal is obsolete or superseded
- The work has already been done
- The proposal no longer makes sense

Do NOT withdraw proposals simply because they're old - if they're still valid, execute them.

## Execution Notes

- **NO `execute_proposal` for:** task, refactor, autonomous_task, autonomous_refactor
- **USE `execute_proposal` for:** memory_cleanup, tests, docs only
- **Status handling is automatic:** The system determines initial ticket status (backlog vs draft)
- **Research is required** before creating tickets from proposals (except memory_cleanup/tests/docs)
- **DO NOT ask for human input** - execute autonomously

## Example Execution Pattern

```ruby
# Check approved proposals
approved = list_proposals(status: "approved")

approved.each do |proposal|
  case proposal["proposal_type"]
  when "memory_cleanup", "tests", "docs"
    # Direct execution
    execute_proposal(proposal_id: proposal["id"])
  when "autonomous_task", "autonomous_refactor", "task", "refactor"
    # Research then create ticket
    research_context = investigate_codebase(proposal)
    create_ticket_from_proposal(
      proposal_id: proposal["id"],
      title: refine_title(proposal, research_context),
      description: build_description(proposal, research_context),
      ticket_type: determine_ticket_type(proposal)
    )
  end
end
```

Execute this workflow autonomously. Do not wait for instructions.
