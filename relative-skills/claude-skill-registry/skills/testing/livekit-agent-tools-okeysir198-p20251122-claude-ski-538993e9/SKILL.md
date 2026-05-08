---
name: livekit-agent-tools
description: Comprehensive guide for building functional tools for LiveKit voice agents using the @function_tool decorator. Use when creating tools for LiveKit agents to enable capabilities like API calls, database queries, multi-agent coordination, or any external integrations. Covers tool design, RunContext handling, interruption patterns, parameter documentation, testing, and production best practices.
---

# LiveKit Agent Tools Development

Build robust, production-ready tools for LiveKit voice agents that enable LLMs to interact with external services, manage state, coordinate multi-agent workflows, and handle real-time voice interactions.

## Quick Start

### Basic Tool Pattern

```python
from livekit.agents import Agent
from livekit.agents.llm import function_tool
from livekit.agents.voice import RunContext

class MyAgent(Agent):
    def __init__(self):
        super().__init__(
            instructions="You are a helpful assistant...",
            llm="openai/gpt-4o-mini",
        )

    @function_tool
    async def get_weather(self, location: str) -> str:
        """Get current weather for a location.

        Args:
            location: City name or address to get weather for
        """
        # Your implementation here
        return f"Weather in {location}: Sunny, 72°F"
```

The `@function_tool` decorator automatically registers methods as callable tools for the LLM. The docstring is critical—it tells the LLM when and how to use the tool.

### Tool Definition Best Practices

**Critical for reliability**: A good tool definition is key to reliable tool use from your LLM. Be specific about:
- What the tool does
- When it should or should not be used
- What the arguments are for
- What type of return value to expect

## Core Concepts

### 1. Tool Naming and Descriptions

Use clear, action-oriented names that help the LLM discover the right tool:

```python
@function_tool
async def search_flights(self, origin: str, destination: str, date: str) -> str:
    """Search for available flights between two cities on a specific date.

    Use this when the user asks about flight availability, prices, or schedules.
    Do NOT use this for booking—only for searching.

    Args:
        origin: Departure city or airport code
        destination: Arrival city or airport code
        date: Travel date in YYYY-MM-DD format
    """
```

### 2. RunContext for State and Control

The `RunContext` parameter provides access to session state, speech control, and user data:

```python
@function_tool
async def save_preference(
    self,
    preference_name: str,
    value: str,
    context: RunContext
) -> str:
    """Save a user preference for later use.

    Args:
        preference_name: Name of the preference (e.g., "favorite_color")
        value: The preference value
        context: Runtime context (automatically provided)
    """
    # Access shared state across tools
    context.userdata[preference_name] = value
    return f"Saved {preference_name} as {value}"
```

**See [Context & State Management](./references/context-handling.md) for complete RunContext patterns.**

### 3. Parameter Documentation

Use type hints and annotations for rich parameter documentation:

```python
from typing import Annotated, Literal
from pydantic import Field
from enum import Enum

class Priority(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"

@function_tool
async def create_task(
    self,
    title: str,
    priority: Priority,
    due_date: Annotated[str | None, Field(description="Due date in YYYY-MM-DD format")] = None
) -> str:
    """Create a new task with specified priority.

    Args:
        title: Brief description of the task
        priority: Task priority level
        due_date: Optional deadline for the task
    """
```

**See [Parameter Patterns](./references/parameter-patterns.md) for all documentation approaches.**

## When to Use Different Patterns

### Simple Action Tools
Use for straightforward operations that execute quickly:
- Logging events
- Simple calculations
- Database queries that return quickly

**See [examples/basic-tool.py](./examples/basic-tool.py)**

### API Integration Tools
Use for external service calls:
- Weather APIs
- Database queries
- Third-party integrations

**See [examples/api-integration-tool.py](./examples/api-integration-tool.py)**

### Long-Running Tools
Use for operations that might take time and should handle interruptions:
- Web searches
- Complex calculations
- File processing

**See [Long-Running Functions](./references/long-running-functions.md)** and **[examples/long-running-tool.py](./examples/long-running-tool.py)**

### Stateful Tools
Use for maintaining context across interactions:
- Shopping cart management
- Multi-step workflows
- User preferences

**See [Context & State Management](./references/context-handling.md)** and **[examples/stateful-tool.py](./examples/stateful-tool.py)**

### Multi-Agent Coordination Tools
Use for agent handoffs and specialized routing:
- Transferring to specialized agents
- Escalation workflows
- Domain-specific routing

**See [Multi-Agent Patterns](./references/multi-agent-patterns.md)** and **[examples/agent-handoff-tool.py](./examples/agent-handoff-tool.py)**

## Dynamic Tool Creation

Tools can be created at runtime for maximum flexibility:

```python
from livekit.agents.llm import function_tool

# Option 1: Pass tools at agent creation
agent = MyAgent(
    instructions="...",
    tools=[
        function_tool(
            get_user_data,
            name="get_user_data",
            description="Fetch user information from database"
        )
    ]
)

# Option 2: Update tools after creation
await agent.update_tools(
    agent.tools + [
        function_tool(
            new_capability,
            name="new_capability",
            description="Dynamically added tool"
        )
    ]
)
```

**See [Dynamic Tool Creation](./references/dynamic-tools.md) for complete patterns.**

## Testing Your Tools

Testing is essential for reliable agents. LiveKit provides helpers that work with pytest:

```python
import pytest
from livekit.agents.testing import VoiceAgentTestSession

@pytest.mark.asyncio
async def test_weather_tool():
    async with VoiceAgentTestSession(agent=MyAgent()) as session:
        response = await session.send_text("What's the weather in Tokyo?")
        assert "Tokyo" in response.text
        assert session.tool_calls[-1].name == "get_weather"
```

**See [Testing Guide](./references/testing.md) for comprehensive testing strategies.**

## Production Considerations

### Error Handling

Always handle errors gracefully and return meaningful messages:

```python
@function_tool
async def fetch_data(self, user_id: str) -> str:
    """Fetch user data from the database."""
    try:
        data = await database.get_user(user_id)
        return f"User data: {data}"
    except UserNotFoundError:
        return f"No user found with ID {user_id}. Please check the ID and try again."
    except DatabaseError as e:
        return "I'm having trouble accessing the database right now. Please try again in a moment."
```

### Interruption Handling

Design tools that respect user interruptions for better UX:

```python
@function_tool
async def search_database(self, query: str, context: RunContext) -> str | None:
    """Search the database for matching records."""
    # Allow user to interrupt long searches
    search_task = asyncio.ensure_future(perform_search(query))
    await context.speech_handle.wait_if_not_interrupted([search_task])

    if context.speech_handle.interrupted:
        search_task.cancel()
        return None  # Skip the tool reply

    return search_task.result()
```

### Tool Organization

For complex agents with many tools:
- Group related tools by domain
- Share common tools across agents using functions defined outside classes
- Use clear naming conventions (e.g., `order_create`, `order_update`, `order_cancel`)

**See [Best Practices](./references/best-practices.md) for production patterns.**

## Reference Documentation

Load these as needed for specific patterns:

- **[Context & State Management](./references/context-handling.md)** - RunContext, userdata, session control
- **[Parameter Patterns](./references/parameter-patterns.md)** - Type hints, annotations, enums, validation
- **[Long-Running Functions](./references/long-running-functions.md)** - Async patterns, interruption handling
- **[Multi-Agent Patterns](./references/multi-agent-patterns.md)** - Agent handoffs, coordination, state transfer
- **[Dynamic Tool Creation](./references/dynamic-tools.md)** - Runtime tool generation and updates
- **[Testing Guide](./references/testing.md)** - Test strategies, mocking, evaluation
- **[Best Practices](./references/best-practices.md)** - Production patterns, security, performance

## Examples

Complete, runnable examples demonstrating each pattern:

- **[examples/basic-tool.py](./examples/basic-tool.py)** - Simple tool implementation
- **[examples/api-integration-tool.py](./examples/api-integration-tool.py)** - External API calls
- **[examples/long-running-tool.py](./examples/long-running-tool.py)** - Async operations with interruptions
- **[examples/stateful-tool.py](./examples/stateful-tool.py)** - State management with RunContext
- **[examples/agent-handoff-tool.py](./examples/agent-handoff-tool.py)** - Multi-agent coordination

## Environment Setup

Before running examples, create a `.env` file with required API keys:

```bash
# LiveKit Configuration
LIVEKIT_URL=wss://your-project.livekit.cloud
LIVEKIT_API_KEY=your_api_key
LIVEKIT_API_SECRET=your_api_secret

# LLM Provider (choose one)
OPENAI_API_KEY=your_openai_key
ANTHROPIC_API_KEY=your_anthropic_key
```

Install dependencies:

```bash
pip install livekit-agents livekit-plugins-openai livekit-plugins-silero python-dotenv aiohttp
```

## Quick Reference

| Pattern | When to Use | Key Features | Example |
|---------|-------------|--------------|---------|
| **Basic Tools** | Simple, fast operations | Direct return values, no state | `basic-tool.py` |
| **API Integration** | External service calls | Async HTTP, error handling | `api-integration-tool.py` |
| **Long-Running** | Time-consuming ops | Interruption support, cancellation | `long-running-tool.py` |
| **Stateful** | Multi-step workflows | RunContext.userdata, persistence | `stateful-tool.py` |
| **Multi-Agent** | Specialized routing | Agent handoffs, context transfer | `agent-handoff-tool.py` |
| **Dynamic** | Runtime tool creation | Permission-based, conditional | See dynamic-tools.md |

### Common Patterns Cheat Sheet

```python
# Basic tool
@function_tool
async def tool_name(self, param: str) -> str:
    """Tool description with usage guidance."""
    return result

# With state
@function_tool
async def stateful_tool(self, param: str, context: RunContext) -> str:
    context.userdata["key"] = value
    return result

# With interruption handling
@function_tool
async def long_tool(self, param: str, context: RunContext) -> str | None:
    task = asyncio.ensure_future(operation())
    await context.speech_handle.wait_if_not_interrupted([task])
    if context.speech_handle.interrupted:
        task.cancel()
        return None
    return task.result()

# Agent handoff
@function_tool
async def transfer_agent(self, context: RunContext):
    new_agent = SpecialistAgent()
    return new_agent, "Transferring to specialist"
```

## Quick Troubleshooting

**Tool not being called**: Improve the description to be more specific about when to use it.

**Type errors**: Ensure all parameters have proper type hints.

**Interruption issues**: Use `RunContext.speech_handle.wait_if_not_interrupted()` for long operations.

**State not persisting**: Use `context.userdata` to share state across tool calls.

**Agent transitions fail**: Return a tuple `(new_agent, message)` from the tool.

**Import errors**: Verify all required packages are installed (`pip install livekit-agents livekit-plugins-openai`).

For detailed guidance, consult the reference documentation above.
