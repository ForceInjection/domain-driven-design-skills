---
name: human-in-the-loop
description: Instrument human approval workflows, feedback loops, and escalations
triggers:
  - "human approval tracking"
  - "human in the loop"
  - "approval workflow"
  - "human feedback"
  - "escalation tracking"
priority: 2
---

# Human-in-the-Loop Instrumentation

Instrument human intervention points to understand approval workflows and feedback.

## Core Principle

HITL observability answers:
1. **When did the agent request** human input?
2. **Why was human input** needed?
3. **How long did humans take** to respond?
4. **What was the outcome** of human intervention?
5. **How often do agents escalate** vs. proceed autonomously?

## Human Intervention Types

### Approval Request
Agent requests permission before proceeding:
```python
span.set_attribute("human.type", "approval")
span.set_attribute("human.action_requested", "execute_trade")
span.set_attribute("human.risk_level", "high")
span.set_attribute("human.auto_approve_eligible", False)
```

### Clarification Request
Agent needs more information:
```python
span.set_attribute("human.type", "clarification")
span.set_attribute("human.question", "Which account to use?")
span.set_attribute("human.options_provided", 3)
```

### Error Escalation
Agent encountered unrecoverable error:
```python
span.set_attribute("human.type", "escalation")
span.set_attribute("human.reason", "tool_failure")
span.set_attribute("human.error_type", "APIError")
span.set_attribute("human.retry_count_before_escalation", 3)
```

### Feedback Request
Agent requests quality feedback:
```python
span.set_attribute("human.type", "feedback")
span.set_attribute("human.feedback_on", "response_quality")
span.set_attribute("human.optional", True)
```

## Request Span Attributes

```python
# Request metadata (P0)
span.set_attribute("human.request_id", str(uuid4()))
span.set_attribute("human.type", "approval")
span.set_attribute("human.agent_name", "executor")
span.set_attribute("human.timestamp", datetime.utcnow().isoformat())

# Context (P1)
span.set_attribute("human.action_summary", "Delete 50 records")
span.set_attribute("human.risk_assessment", "medium")
span.set_attribute("human.reversible", True)
span.set_attribute("human.deadline", "2024-01-15T10:00:00Z")

# Routing (P2)
span.set_attribute("human.assigned_to", "team_ops")
span.set_attribute("human.priority", "high")
span.set_attribute("human.channel", "slack")
```

## Response Span Attributes

```python
# Response metadata (P0)
span.set_attribute("human.response_id", str(uuid4()))
span.set_attribute("human.decision", "approved")  # approved, rejected, modified
span.set_attribute("human.responded_at", datetime.utcnow().isoformat())
span.set_attribute("human.wait_time_ms", 45000)

# Responder (P1)
span.set_attribute("human.responder_id", "user_123")  # Hashed
span.set_attribute("human.responder_role", "admin")

# Modifications (if applicable)
span.set_attribute("human.modified", True)
span.set_attribute("human.modification_summary", "Reduced to 25 records")

# Feedback (if applicable)
span.set_attribute("human.feedback_score", 4)  # 1-5
span.set_attribute("human.feedback_comment_length", 150)
```

## Timing Metrics

Track wait times for SLA monitoring:

```python
# Request-to-response timing
span.set_attribute("human.time_to_response_ms", 45000)
span.set_attribute("human.time_to_first_view_ms", 12000)
span.set_attribute("human.sla_target_ms", 300000)  # 5 min SLA
span.set_attribute("human.sla_met", True)

# Queue metrics
span.set_attribute("human.queue_position", 3)
span.set_attribute("human.queue_wait_ms", 30000)
```

## Workflow Patterns

### Synchronous Approval
Agent blocks until human responds:
```python
with tracer.start_span("human.approval_sync") as span:
    span.set_attribute("human.blocking", True)
    span.set_attribute("human.timeout_ms", 300000)

    request_id = request_approval(action)
    decision = wait_for_decision(request_id, timeout=300)

    span.set_attribute("human.decision", decision)
    span.set_attribute("human.wait_time_ms", elapsed)
```

### Asynchronous Approval
Agent proceeds with other work:
```python
with tracer.start_span("human.approval_async") as span:
    span.set_attribute("human.blocking", False)
    span.set_attribute("human.callback_url", callback_url)

    request_id = request_approval_async(action, callback_url)
    span.set_attribute("human.request_id", request_id)
    # Agent continues with other work
```

### Auto-Approval with Override
Low-risk actions auto-approve:
```python
with tracer.start_span("human.auto_approval") as span:
    risk = assess_risk(action)
    span.set_attribute("human.risk_score", risk)

    if risk < RISK_THRESHOLD:
        span.set_attribute("human.auto_approved", True)
        span.set_attribute("human.override_available", True)
        proceed(action)
    else:
        span.set_attribute("human.auto_approved", False)
        request_approval(action)
```

## Aggregation Metrics

Track patterns over time:
```python
# Per-agent metrics
span.set_attribute("agent.human_requests_today", 15)
span.set_attribute("agent.approval_rate", 0.85)
span.set_attribute("agent.avg_wait_time_ms", 35000)

# Per-workflow metrics
span.set_attribute("workflow.human_touchpoints", 3)
span.set_attribute("workflow.autonomous_steps", 12)
span.set_attribute("workflow.automation_rate", 0.80)
```

## Framework Integration

### LangGraph Human Node
```python
from langgraph.prebuilt import create_react_agent
from langfuse.decorators import observe

@observe(name="human.interrupt")
def human_approval_node(state):
    span = get_current_span()
    span.set_attribute("human.type", "approval")
    span.set_attribute("human.state_summary", summarize(state))

    # Request human input
    decision = interrupt(state)

    span.set_attribute("human.decision", decision)
    return {"approved": decision == "approve"}
```

### CrewAI Human Input
```python
from crewai import Agent
from langfuse.decorators import observe

@observe(name="human.feedback")
def request_human_feedback(output: str) -> str:
    span = get_current_span()
    span.set_attribute("human.type", "feedback")

    feedback = human_input(f"Review: {output}")

    span.set_attribute("human.feedback_length", len(feedback))
    return feedback
```

## Anti-Patterns

- Missing wait time tracking (SLA blindness)
- No decision logging (can't audit)
- Blocking without timeout (hung agents)
- No escalation tracking (hidden failures)

## Related Skills
- `error-retry-tracking` - Escalation patterns
- `evaluation-quality` - Feedback integration
