---
name: multi-agent-coordination
description: Instrument multi-agent workflows, handoffs, and parent-child relationships
triggers:
  - "multi-agent tracing"
  - "agent handoffs"
  - "parent child spans"
  - "agent coordination"
  - "supervisor agent"
priority: 1
---

# Multi-Agent Coordination Instrumentation

Instrument multi-agent systems to trace coordination, handoffs, and hierarchies.

## Core Principle

Multi-agent traces must answer:
1. **Which agent** started the workflow?
2. **Which agents** were involved?
3. **How did work flow** between agents?
4. **Why did handoffs** occur?
5. **What was the hierarchy** (parent-child)?

## Trace Hierarchy

```
Session/Conversation (root span)
└── Supervisor Agent Run
    ├── Planning Phase (span)
    │   └── LLM Call (span)
    ├── Delegate to Agent A (span)
    │   └── Agent A Run (child trace)
    │       ├── LLM Call
    │       └── Tool Call
    ├── Delegate to Agent B (span)
    │   └── Agent B Run (child trace)
    │       └── LLM Call
    └── Synthesis Phase (span)
        └── LLM Call
```

## Essential Span Attributes

### Agent Identity
```python
span.set_attribute("agent.name", "researcher")
span.set_attribute("agent.type", "worker")  # supervisor, worker, critic
span.set_attribute("agent.run_id", str(uuid4()))
span.set_attribute("agent.framework", "langgraph")
```

### Parent-Child Linking
```python
# Parent agent creates child context
child_context = create_child_context(current_span)
span.set_attribute("agent.parent_id", parent_run_id)
span.set_attribute("agent.parent_name", "supervisor")

# Pass context to child agent
child_agent.run(input, trace_context=child_context)
```

### Handoff Tracking
```python
# Log handoff decision
span.set_attribute("handoff.from_agent", "supervisor")
span.set_attribute("handoff.to_agent", "researcher")
span.set_attribute("handoff.reason", "needs_web_search")
span.set_attribute("handoff.task_summary", "Find pricing data")
```

### Workflow State
```python
span.set_attribute("workflow.step", "research")
span.set_attribute("workflow.total_steps", 4)
span.set_attribute("workflow.agents_involved", 3)
span.set_attribute("workflow.state", "in_progress")
```

## Framework Patterns

### LangGraph
```python
from langgraph.graph import StateGraph
from langfuse.decorators import observe

@observe(name="agent.supervisor")
def supervisor_node(state):
    # Supervisor logic
    span = get_current_span()
    span.set_attribute("agent.name", "supervisor")
    span.set_attribute("agent.decision", state["next_agent"])
    return state

@observe(name="agent.worker")
def worker_node(state):
    span = get_current_span()
    span.set_attribute("agent.name", "worker")
    span.set_attribute("agent.parent_name", "supervisor")
    return state

graph = StateGraph()
graph.add_node("supervisor", supervisor_node)
graph.add_node("worker", worker_node)
```

### CrewAI
```python
from crewai import Agent, Crew, Task
from langfuse.decorators import observe

@observe(name="crew.run")
def run_crew(topic: str):
    span = get_current_span()
    span.set_attribute("crew.name", "research_crew")
    span.set_attribute("crew.agent_count", 3)

    researcher = Agent(name="researcher", ...)
    writer = Agent(name="writer", ...)
    editor = Agent(name="editor", ...)

    crew = Crew(agents=[researcher, writer, editor], ...)
    return crew.kickoff(inputs={"topic": topic})
```

### AutoGen
```python
from autogen import AssistantAgent, UserProxyAgent
from langfuse.decorators import observe

@observe(name="conversation.run")
def run_conversation(message: str):
    span = get_current_span()
    span.set_attribute("conversation.initiator", "user_proxy")
    span.set_attribute("conversation.participants", 2)

    assistant = AssistantAgent("assistant", ...)
    user_proxy = UserProxyAgent("user_proxy", ...)

    user_proxy.initiate_chat(assistant, message=message)
```

## Coordination Patterns

### Hub-and-Spoke (Supervisor)
```python
span.set_attribute("coordination.pattern", "hub_and_spoke")
span.set_attribute("coordination.hub", "supervisor")
span.set_attribute("coordination.spokes", ["researcher", "writer", "critic"])
```

### Pipeline (Sequential)
```python
span.set_attribute("coordination.pattern", "pipeline")
span.set_attribute("coordination.sequence", ["intake", "research", "draft", "review"])
span.set_attribute("coordination.current_stage", 2)
```

### Parallel (Fan-out/Fan-in)
```python
span.set_attribute("coordination.pattern", "parallel")
span.set_attribute("coordination.parallel_agents", 4)
span.set_attribute("coordination.completed", 2)
span.set_attribute("coordination.pending", 2)
```

### Hierarchical
```python
span.set_attribute("coordination.pattern", "hierarchical")
span.set_attribute("coordination.depth", 3)
span.set_attribute("coordination.level", 2)
```

## Context Propagation

**Critical**: Pass trace context to child agents:

```python
# LangGraph - use config
def parent_node(state, config):
    # Context automatically propagated via config
    return child_graph.invoke(state, config)

# Manual propagation
from opentelemetry import trace
from opentelemetry.propagate import inject

def delegate_to_agent(agent, input):
    carrier = {}
    inject(carrier)  # Inject current context

    # Pass carrier to child agent
    return agent.run(input, trace_headers=carrier)
```

## Anti-Patterns

See `references/anti-patterns/multi-agent.md`:
- Orphaned child spans (no parent link)
- Missing handoff context
- No agent identification
- Broken context propagation
- Logging full inter-agent messages

## Related Skills
- `instrumentation-planning` - Overall planning
- `session-conversation-tracking` - Session context
