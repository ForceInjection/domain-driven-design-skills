---
name: Delegating to Jira Agent
description: Recognize Jira queries and delegate to specialized sub-agent to avoid context pollution
keywords: jira, atlassian, devops, issue, ticket, bug, task, search, comment, delegate, agent
when_to_use: When user mentions "jira", "issue", "ticket", or asks to view/create/search/update Acme Jira issues. ALWAYS delegate to sub-agent.
version: 1.0.0
---

# Delegating to Jira Agent

## Core Principle

**Never handle Jira operations directly.** Always delegate to a specialized sub-agent to keep your context clean and costs low.

## Recognition Patterns

Delegate when user says:
- "show me jira issue PROJ-1234"
- "what jira issues do I have?"
- "search jira for nginx"
- "create a jira for this work"
- "add a comment to PROJ-1234"
- Any mention of: jira, issue, ticket, PROJ-*, AcmeED-*

## How to Delegate

Use the Task tool with a specialized prompt:

```
Task(
  subagent_type: "general-purpose",
  description: "Query Acme Jira",
  prompt: "<full agent instructions from AGENT-INSTRUCTIONS.md>"
)
```

## Agent Prompt Template

When delegating, include:
1. The complete agent instructions (see AGENT-INSTRUCTIONS.md)
2. The user's specific request
3. Clear output format requirements

**Example:**

```
You are a Acme Jira specialist. Your job is to query Acme's Atlassian Jira using shell wrappers and return clean results.

<AGENT INSTRUCTIONS HERE>

USER REQUEST: Show me my jira issues for production-main

Return a clean summary with:
- Issue keys
- Summaries
- Status
- URLs
```

## After Agent Returns

1. **Present results cleanly** to user
2. **Offer follow-up** if relevant (e.g., "Would you like details on PROJ-1234?")
3. **Don't expose mechanics** (curl, auth, etc.) to user

## Benefits

- ✅ Main context stays clean
- ✅ Cheaper queries (sub-agent uses less expensive model)
- ✅ Specialized knowledge isolated
- ✅ Scalable pattern for other services

## Example Flow

```
User: "show me my open jira issues"

Main Assistant: [Recognizes Jira query]
              → Invokes Task tool with agent instructions
              → Agent runs issuetracker-mine wrapper
              → Agent returns formatted results

Main Assistant: "You have 20 open issues. Here are the highlights:
                - PROJ-1638: production-main (In Development)
                - PROJ-2216: Reduce catdv log noise (Scheduled)
                ..."
```

## Red Flags

**DON'T:**
- ❌ Try to run issuetracker-* scripts yourself
- ❌ Construct curl commands in main session
- ❌ Load detailed Jira API knowledge
- ❌ Handle authentication directly

**DO:**
- ✅ Immediately delegate on Jira keywords
- ✅ Trust the sub-agent's results
- ✅ Present clean summaries to user

## Version History

- 1.0.0 (2025-10-14): Initial delegation skill created to reduce context pollution
