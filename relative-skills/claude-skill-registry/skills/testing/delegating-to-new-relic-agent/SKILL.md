---
name: Delegating to New Relic Agent
description: Recognize New Relic queries and delegate to specialized sub-agent to avoid context pollution
keywords: newrelic, nrql, monitoring, alerts, apm, logs, drop-rules, observability, delegate, agent
when_to_use: When user mentions "newrelic", "nrql", "alerts", "drop rules", or asks to query/search New Relic monitoring data. ALWAYS delegate to sub-agent.
version: 1.0.0
---

# Delegating to New Relic Agent

## Core Principle

**Never handle New Relic operations directly.** Always delegate to a specialized sub-agent to keep your context clean and costs low.

## Recognition Patterns

Delegate when user says:
- "query newrelic for..."
- "show me nrql results"
- "list drop rules"
- "any alerts firing?"
- "search newrelic logs"
- "what applications are monitored?"
- "verify this nrql query"
- Any mention of: newrelic, nrql, monitoring, alerts, apm, drop-rules, observability

## How to Delegate

Use the Task tool with a specialized prompt:

```
Task(
  subagent_type: "general-purpose",
  description: "Query New Relic monitoring",
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
You are a New Relic monitoring specialist. Your job is to query New Relic using shell wrappers and return clean results.

<AGENT INSTRUCTIONS HERE>

USER REQUEST: Show me active alerts

Return a clean summary with:
- Alert severity
- Entity names
- Alert conditions
- Status
```

## After Agent Returns

1. **Present results cleanly** to user
2. **Offer follow-up** if relevant (e.g., "Would you like to see logs for that service?")
3. **Don't expose mechanics** (NerdGraph, GraphQL, auth, etc.) to user

## Benefits

- ✅ Main context stays clean
- ✅ Cheaper queries (sub-agent uses less expensive model)
- ✅ Specialized knowledge isolated
- ✅ Scalable pattern for other monitoring services

## Example Flow

```
User: "show me active alerts"

Main Assistant: [Recognizes New Relic query]
              → Invokes Task tool with agent instructions
              → Agent runs monitoring-alerts wrapper
              → Agent returns formatted results

Main Assistant: "You have 2 active alerts:

                CRITICAL: federated-graphql - High error rate
                WARNING: nginx-gateway - Response time elevated

                Would you like details on either of these?"
```

## Common Query Types

**NRQL Queries:**
- "query logs for errors"
- "count transactions"
- "average response time"

**Drop Rules:**
- "show drop rules"
- "list log filters"
- "verify nrql before dropping"

**Alerts:**
- "any alerts?"
- "critical alerts"
- "what's alerting?"

**Applications:**
- "list monitored apps"
- "find nginx service"

**Logs:**
- "search logs for 502"
- "nginx error logs"

## Red Flags

**DON'T:**
- ❌ Try to run monitoring-* scripts yourself
- ❌ Construct NerdGraph GraphQL queries in main session
- ❌ Load detailed New Relic API knowledge
- ❌ Handle authentication directly
- ❌ Parse complex monitoring data structures

**DO:**
- ✅ Immediately delegate on New Relic keywords
- ✅ Trust the sub-agent's results
- ✅ Present clean summaries to user
- ✅ Suggest relevant follow-up queries

## Version History

- 1.0.0 (2025-10-15): Initial delegation skill created to reduce context pollution
