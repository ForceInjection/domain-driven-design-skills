---
name: llm-integration
description: Integrate LLMs into applications - APIs, prompting, fine-tuning, and context management
sasmp_version: "1.3.0"
bonded_agent: 02-llm-integration
bond_type: PRIMARY_BOND
version: "2.0.0"
---

# LLM Integration

Integrate Large Language Models with production-grade reliability.

## When to Use This Skill

Invoke this skill when:
- Connecting to Claude, OpenAI, or other LLM APIs
- Designing effective prompts and system messages
- Optimizing token usage and costs
- Implementing streaming responses

## Parameter Schema

| Parameter | Type | Required | Description | Default |
|-----------|------|----------|-------------|---------|
| `provider` | enum | Yes | `anthropic`, `openai`, `google`, `local` | - |
| `task` | string | Yes | Integration goal | - |
| `streaming` | bool | No | Enable streaming | `true` |
| `max_tokens` | int | No | Response token limit | `4096` |

## Quick Start

```python
# Anthropic Claude
from anthropic import Anthropic

client = Anthropic()
response = client.messages.create(
    model="claude-sonnet-4-20250514",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello!"}]
)

# OpenAI
from openai import OpenAI

client = OpenAI()
response = client.chat.completions.create(
    model="gpt-4-turbo",
    messages=[{"role": "user", "content": "Hello!"}]
)
```

## Prompt Templates

### System Prompt
```python
SYSTEM = """You are {role}, an expert in {domain}.
Your task: {task}
Constraints: {constraints}
Output format: {format}"""
```

### Chain-of-Thought
```python
COT = """Think step by step:
1. Understand the problem
2. Break it down
3. Solve each part
4. Combine results"""
```

## Cost Optimization

| Model | Input $/1M | Output $/1M | Best For |
|-------|------------|-------------|----------|
| Claude Haiku | $0.25 | $1.25 | High volume |
| Claude Sonnet | $3 | $15 | Complex tasks |
| Claude Opus | $15 | $75 | Most demanding |

## Troubleshooting

| Issue | Solution |
|-------|----------|
| 429 Rate Limited | Exponential backoff |
| Context overflow | Truncate/summarize |
| Poor output quality | Add examples, lower temp |
| High costs | Use cheaper model, cache |

## Best Practices

- Always implement retry with backoff
- Use streaming for better UX
- Cache repeated queries
- Monitor token usage

## Related Skills

- `ai-agent-basics` - Agent architecture
- `rag-systems` - Retrieval augmentation
- `tool-calling` - Function calling

## References

- [Anthropic API](https://docs.anthropic.com/)
- [OpenAI API](https://platform.openai.com/docs)
