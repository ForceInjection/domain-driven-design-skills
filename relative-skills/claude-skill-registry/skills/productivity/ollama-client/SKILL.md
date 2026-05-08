---
name: ollama-client
description: Phi-4 LLM interaction skill for generating text completions via Ollama API. Use for all LLM inference tasks including section detection, summarization, recommendation generation, and quality evaluation.
---

# Ollama Client Skill

## Overview

This skill provides a Python wrapper for interacting with Ollama's REST API to generate text completions using the Phi-4 model (14B parameters, 16K context window). It handles timeouts, retries, and structured logging for all LLM operations.

## When to Use

Use this skill when you need to:
- Generate text completions from Phi-4
- Run prompts for clinical analysis tasks
- Generate JSON-structured outputs from LLM
- Handle LLM inference with timeout protection

## Installation

**IMPORTANT**: This skill has its own isolated virtual environment (`.venv`) managed by `uv`. Do NOT use system Python.

Initialize the skill's environment:
```bash
# From the skill directory
cd .agent/skills/ollama-client
uv sync  # Creates .venv and installs dependencies from pyproject.toml
```

Dependencies are in `pyproject.toml`:
- `requests` - HTTP client for Ollama API

## Usage

**CRITICAL**: Always use `uv run` to execute code with this skill's `.venv`, NOT system Python.

### Basic Text Generation

```python
# From .agent/skills/ollama-client/ directory
# Run with: uv run python -c "..."
from ollama_client import OllamaClient

# Initialize client
client = OllamaClient(
    host="http://localhost:11434",  # Default from OLLAMA_HOST env var
    model="phi4:14b",                 # Default from OLLAMA_MODEL env var
    timeout=300                       # 5 minutes default
)

# Generate completion
result = client.generate(
    prompt="Summarize the following clinical note: ...",
    temperature=0.1,      # Low temperature for deterministic outputs
    max_tokens=1000,      # Optional token limit
    stop_sequences=["END"]  # Optional stop sequences
)

print(result["response"])
print(f"Execution time: {result['execution_time_ms']}ms")
```

### With Environment Variables

```python
import os

# Set in .env or docker-compose.yml
os.environ['OLLAMA_HOST'] = 'http://localhost:11434'
os.environ['OLLAMA_MODEL'] = 'phi4:14b'

# Client uses env vars automatically
client = OllamaClient()
```

### Using from Another Module

When importing this skill from agents or other code:
```python
import sys
from pathlib import Path

# Add skill to path (use relative path from your location)
skill_path = Path(__file__).parent.parent.parent / ".agent/skills/ollama-client"
sys.path.insert(0, str(skill_path))

from ollama_client import OllamaClient
client = OllamaClient()
```

### Health Check

```python
# Check if Ollama server is accessible
if client.is_available():
    print("Ollama server is healthy")
else:
    print("Ollama server unavailable")
```

## Configuration

**Environment Variables**:
- `OLLAMA_HOST`: Server URL (default: `http://localhost:11434`)
- `OLLAMA_MODEL`: Model name (default: `phi4:14b`)

**Parameters**:
- `temperature`: Sampling temperature (0.0-1.0, default: 0.1 for deterministic outputs)
- `max_tokens`: Maximum tokens to generate (optional)
- `stop_sequences`: List of strings to stop generation (optional)
- `timeout`: Request timeout in seconds (default: 300)

## Error Handling

The skill raises exceptions for:
- **Timeout**: If request exceeds timeout duration
- **Connection Error**: If Ollama server is unreachable
- **API Error**: If Ollama returns an error response

All errors include execution time for debugging.

## Best Practices

1. **Low Temperature**: Use `temperature=0.1` for clinical tasks requiring consistency
2. **Timeouts**: Set appropriate timeouts based on prompt complexity (simple: 60s, complex: 300s)
3. **Health Checks**: Verify server availability before critical operations
4. **Error Logging**: Always log errors with execution time for troubleshooting

## Integration with Agents

Agents use this skill for all LLM operations:
- **ToC Subagent**: Section topic segmentation
- **Summary Subagent**: Clinical entity extraction
- **Recommendation Subagent**: Treatment plan generation
- **Evaluator Agent**: Quality validation reasoning

## Implementation

See `ollama_client.py` for the full Python implementation.
