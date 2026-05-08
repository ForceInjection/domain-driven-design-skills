---
name: tool-calling
description: Implement tool calling - function schemas, API integration, validation, and error handling
sasmp_version: "1.3.0"
bonded_agent: 04-tool-calling
bond_type: PRIMARY_BOND
version: "2.0.0"
---

# Tool Calling

Enable LLMs to call functions and interact with external systems.

## When to Use This Skill

Invoke this skill when:
- Adding function calling to agents
- Designing tool schemas
- Integrating external APIs
- Implementing validation and error handling

## Parameter Schema

| Parameter | Type | Required | Description | Default |
|-----------|------|----------|-------------|---------|
| `task` | string | Yes | Tool calling goal | - |
| `provider` | enum | No | `anthropic`, `openai`, `langchain` | `anthropic` |
| `strict_mode` | bool | No | Enable strict validation | `true` |

## Quick Start

### Claude Tool Use
```python
from anthropic import Anthropic

tools = [{
    "name": "get_weather",
    "description": "Get weather for a location",
    "input_schema": {
        "type": "object",
        "properties": {
            "location": {"type": "string"}
        },
        "required": ["location"]
    }
}]

response = client.messages.create(
    model="claude-sonnet-4-20250514",
    tools=tools,
    messages=[{"role": "user", "content": "Weather in Tokyo?"}]
)
```

### LangChain Tools
```python
from langchain_core.tools import tool

@tool
def search(query: str) -> str:
    """Search the web for information."""
    return web_search(query)
```

## Schema Best Practices

```python
# Good: verb_noun, clear description
{
    "name": "search_products",
    "description": """Search product database.
    USE WHEN: User asks about products.
    DO NOT USE: For order status (use get_order instead)."""
}

# Bad: vague
{"name": "helper", "description": "Helps with stuff"}
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Tool not called | Improve description |
| Wrong tool selected | Add "DO NOT USE" conditions |
| Invalid arguments | Enable strict mode |
| Execution timeout | Add timeout, retry logic |

## Best Practices

- Use verb_noun naming convention
- Keep tool count under 20
- Include usage examples in descriptions
- Return errors as tool results

## Related Skills

- `ai-agent-basics` - Agent loops
- `llm-integration` - API setup
- `agent-safety` - Input validation

## References

- [Anthropic Tool Use](https://docs.anthropic.com/en/docs/build-with-claude/tool-use)
- [OpenAI Functions](https://platform.openai.com/docs/guides/function-calling)
