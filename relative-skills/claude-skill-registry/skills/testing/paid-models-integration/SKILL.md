---
name: Paid Models Integration
description: Expert guidance for integrating paid AI model APIs including Claude (Anthropic), OpenAI, Google Gemini, Groq, and others with Python applications
version: 1.0.0
---

# Paid AI Models Integration

Complete guide for integrating commercial AI model APIs with Python applications.

## Overview

This skill covers integration with major paid AI model providers:
- **Anthropic Claude** - Advanced reasoning and coding
- **OpenAI** - GPT-4o, GPT-4, GPT-3.5
- **Google Gemini** - Multimodal capabilities
- **Groq** - Fast inference (paid tier)
- **Amazon Bedrock** - AWS-hosted models
- **Azure OpenAI** - Enterprise OpenAI

## Anthropic Claude Integration

### Setup

```bash
# Install SDK
pip install anthropic

# Set API key
export ANTHROPIC_API_KEY='your-api-key'
```

### Basic Usage

```python
import anthropic

client = anthropic.Anthropic(
    api_key="your-api-key"
)

# Simple message
response = client.messages.create(
    model="claude-3-7-sonnet-20250219",
    max_tokens=1024,
    messages=[
        {"role": "user", "content": "Explain quantum computing"}
    ]
)

print(response.content[0].text)
```

### Advanced Features

```python
from anthropic import Anthropic

client = Anthropic()

# Streaming response
with client.messages.stream(
    model="claude-3-7-sonnet-20250219",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Write a story"}]
) as stream:
    for text in stream.text_stream:
        print(text, end="", flush=True)

# With system prompt
response = client.messages.create(
    model="claude-3-7-sonnet-20250219",
    max_tokens=2048,
    system="You are a Python expert. Provide clear, well-documented code.",
    messages=[
        {"role": "user", "content": "Write a binary search function"}
    ]
)
```

### Tool Use (Function Calling)

```python
import anthropic

client = anthropic.Anthropic()

# Define tools
tools = [
    {
        "name": "get_weather",
        "description": "Get weather for a location",
        "input_schema": {
            "type": "object",
            "properties": {
                "location": {
                    "type": "string",
                    "description": "City name"
                }
            },
            "required": ["location"]
        }
    }
]

# Request with tools
response = client.messages.create(
    model="claude-3-7-sonnet-20250219",
    max_tokens=1024,
    tools=tools,
    messages=[
        {"role": "user", "content": "What's the weather in Paris?"}
    ]
)

# Process tool calls
for content in response.content:
    if content.type == "tool_use":
        print(f"Tool: {content.name}")
        print(f"Input: {content.input}")

        # Execute tool and send result back
        tool_result = get_weather(content.input["location"])

        # Continue conversation with tool result
        response = client.messages.create(
            model="claude-3-7-sonnet-20250219",
            max_tokens=1024,
            tools=tools,
            messages=[
                {"role": "user", "content": "What's the weather in Paris?"},
                {"role": "assistant", "content": response.content},
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "tool_result",
                            "tool_use_id": content.id,
                            "content": tool_result
                        }
                    ]
                }
            ]
        )
```

### Vision (Image Analysis)

```python
import base64
import anthropic

client = anthropic.Anthropic()

# Read image
with open("image.jpg", "rb") as f:
    image_data = base64.b64encode(f.read()).decode("utf-8")

response = client.messages.create(
    model="claude-3-7-sonnet-20250219",
    max_tokens=1024,
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "image",
                    "source": {
                        "type": "base64",
                        "media_type": "image/jpeg",
                        "data": image_data
                    }
                },
                {
                    "type": "text",
                    "text": "Describe this image"
                }
            ]
        }
    ]
)

print(response.content[0].text)
```

### Prompt Caching (Cost Optimization)

```python
# Enable prompt caching for repeated content
response = client.messages.create(
    model="claude-3-7-sonnet-20250219",
    max_tokens=1024,
    system=[
        {
            "type": "text",
            "text": "You are an expert in Python programming...",
            "cache_control": {"type": "ephemeral"}
        }
    ],
    messages=[
        {"role": "user", "content": "Explain decorators"}
    ]
)

# Check cache usage
print(f"Cache read tokens: {response.usage.cache_read_input_tokens}")
print(f"Cache creation tokens: {response.usage.cache_creation_input_tokens}")
```

## OpenAI Integration

### Setup

```bash
pip install openai

export OPENAI_API_KEY='your-api-key'
```

### Basic Usage

```python
from openai import OpenAI

client = OpenAI(api_key="your-api-key")

# Chat completion
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": "You are a helpful assistant"},
        {"role": "user", "content": "Explain async programming"}
    ],
    temperature=0.7,
    max_tokens=1000
)

print(response.choices[0].message.content)
```

### Streaming

```python
stream = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Write a poem"}],
    stream=True
)

for chunk in stream:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end="", flush=True)
```

### Function Calling

```python
functions = [
    {
        "name": "get_stock_price",
        "description": "Get current stock price",
        "parameters": {
            "type": "object",
            "properties": {
                "symbol": {
                    "type": "string",
                    "description": "Stock symbol (e.g., AAPL)"
                }
            },
            "required": ["symbol"]
        }
    }
]

response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "What's the price of Apple stock?"}],
    functions=functions,
    function_call="auto"
)

# Process function call
if response.choices[0].message.function_call:
    function_call = response.choices[0].message.function_call
    print(f"Function: {function_call.name}")
    print(f"Arguments: {function_call.arguments}")
```

### Vision

```python
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "text", "text": "What's in this image?"},
                {
                    "type": "image_url",
                    "image_url": {
                        "url": "https://example.com/image.jpg"
                    }
                }
            ]
        }
    ]
)
```

### Embeddings

```python
response = client.embeddings.create(
    model="text-embedding-3-large",
    input="Your text here"
)

embedding = response.data[0].embedding
print(f"Embedding dimensions: {len(embedding)}")
```

### Assistants API

```python
# Create assistant
assistant = client.beta.assistants.create(
    name="Math Tutor",
    instructions="You are a math tutor. Help with math problems.",
    model="gpt-4o",
    tools=[{"type": "code_interpreter"}]
)

# Create thread
thread = client.beta.threads.create()

# Add message
message = client.beta.threads.messages.create(
    thread_id=thread.id,
    role="user",
    content="Solve: 3x + 11 = 14"
)

# Run assistant
run = client.beta.threads.runs.create(
    thread_id=thread.id,
    assistant_id=assistant.id
)

# Wait for completion
import time
while run.status != "completed":
    time.sleep(1)
    run = client.beta.threads.runs.retrieve(
        thread_id=thread.id,
        run_id=run.id
    )

# Get messages
messages = client.beta.threads.messages.list(thread_id=thread.id)
for msg in messages.data:
    print(f"{msg.role}: {msg.content[0].text.value}")
```

## Google Gemini Integration

### Setup

```bash
pip install google-generativeai

export GOOGLE_API_KEY='your-api-key'
```

### Basic Usage

```python
import google.generativeai as genai

genai.configure(api_key="your-api-key")

# Create model
model = genai.GenerativeModel('gemini-2.0-flash-exp')

# Generate content
response = model.generate_content("Explain machine learning")
print(response.text)
```

### Streaming

```python
response = model.generate_content(
    "Write a long story",
    stream=True
)

for chunk in response:
    print(chunk.text, end="", flush=True)
```

### Multimodal (Vision + Text)

```python
import PIL.Image

# Load image
image = PIL.Image.open('photo.jpg')

# Analyze image
model = genai.GenerativeModel('gemini-2.0-flash-exp')
response = model.generate_content([
    "What's in this image?",
    image
])

print(response.text)
```

### Function Calling

```python
def get_exchange_rate(currency_from: str, currency_to: str) -> dict:
    """Get exchange rate between currencies"""
    return {"rate": 1.12, "from": currency_from, "to": currency_to}

model = genai.GenerativeModel(
    'gemini-2.0-flash-exp',
    tools=[get_exchange_rate]
)

response = model.generate_content(
    "What's the exchange rate from USD to EUR?"
)

# Check for function calls
for part in response.parts:
    if fn := part.function_call:
        print(f"Calling: {fn.name}")
        print(f"Args: {fn.args}")
```

## Groq Integration

### Setup

```bash
pip install groq

export GROQ_API_KEY='your-api-key'
```

### Basic Usage

```python
from groq import Groq

client = Groq(api_key="your-api-key")

# Fast inference
response = client.chat.completions.create(
    model="llama-3.3-70b-versatile",
    messages=[
        {"role": "system", "content": "You are a helpful assistant"},
        {"role": "user", "content": "Explain neural networks"}
    ],
    temperature=0.7,
    max_tokens=1000
)

print(response.choices[0].message.content)
```

### Streaming

```python
stream = client.chat.completions.create(
    model="llama-3.3-70b-versatile",
    messages=[{"role": "user", "content": "Tell me a story"}],
    stream=True
)

for chunk in stream:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end="", flush=True)
```

## Amazon Bedrock Integration

### Setup

```bash
pip install boto3

# Configure AWS credentials
aws configure
```

### Basic Usage

```python
import boto3
import json

bedrock = boto3.client(
    service_name='bedrock-runtime',
    region_name='us-east-1'
)

# Claude on Bedrock
body = json.dumps({
    "anthropic_version": "bedrock-2023-05-31",
    "max_tokens": 1024,
    "messages": [
        {"role": "user", "content": "Explain cloud computing"}
    ]
})

response = bedrock.invoke_model(
    modelId='anthropic.claude-3-sonnet-20240229-v1:0',
    body=body
)

response_body = json.loads(response['body'].read())
print(response_body['content'][0]['text'])
```

## Azure OpenAI Integration

### Setup

```bash
pip install openai

export AZURE_OPENAI_API_KEY='your-api-key'
export AZURE_OPENAI_ENDPOINT='https://your-resource.openai.azure.com/'
```

### Basic Usage

```python
from openai import AzureOpenAI

client = AzureOpenAI(
    api_key="your-api-key",
    api_version="2024-02-15-preview",
    azure_endpoint="https://your-resource.openai.azure.com/"
)

response = client.chat.completions.create(
    model="gpt-4o",  # Your deployment name
    messages=[
        {"role": "user", "content": "Hello!"}
    ]
)

print(response.choices[0].message.content)
```

## Unified Interface with Agno

### Multi-Provider Support

```python
from agno.agent import Agent
from agno.models.anthropic import Claude
from agno.models.openai import OpenAIChat
from agno.models.gemini import Gemini
from agno.models.groq import Groq

# Create agents with different providers
claude_agent = Agent(
    model=Claude(id="claude-3-7-sonnet-latest"),
    description="Claude-powered agent"
)

openai_agent = Agent(
    model=OpenAIChat(id="gpt-4o"),
    description="OpenAI-powered agent"
)

gemini_agent = Agent(
    model=Gemini(id="gemini-2.0-flash-exp"),
    description="Gemini-powered agent"
)

groq_agent = Agent(
    model=Groq(id="llama-3.3-70b-versatile"),
    description="Groq-powered agent"
)

# Use the same interface
for agent in [claude_agent, openai_agent, gemini_agent, groq_agent]:
    response = agent.run("Explain AI")
    print(f"{agent.description}: {response.content[:100]}...")
```

## Production Patterns

### Retry Logic with Exponential Backoff

```python
import time
from functools import wraps
from anthropic import Anthropic, RateLimitError, APIError

def retry_with_backoff(max_retries=3, initial_delay=1):
    """Retry decorator with exponential backoff"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            delay = initial_delay
            for attempt in range(max_retries):
                try:
                    return func(*args, **kwargs)
                except RateLimitError as e:
                    if attempt == max_retries - 1:
                        raise
                    print(f"Rate limited, retrying in {delay}s...")
                    time.sleep(delay)
                    delay *= 2
                except APIError as e:
                    if attempt == max_retries - 1:
                        raise
                    print(f"API error, retrying in {delay}s...")
                    time.sleep(delay)
                    delay *= 2
        return wrapper
    return decorator

@retry_with_backoff(max_retries=3)
def call_claude(prompt: str):
    client = Anthropic()
    response = client.messages.create(
        model="claude-3-7-sonnet-20250219",
        max_tokens=1024,
        messages=[{"role": "user", "content": prompt}]
    )
    return response.content[0].text
```

### Rate Limiting

```python
import asyncio
from asyncio import Semaphore
from anthropic import AsyncAnthropic

class RateLimitedClient:
    """Rate-limited API client"""

    def __init__(self, max_concurrent=5, requests_per_minute=60):
        self.client = AsyncAnthropic()
        self.semaphore = Semaphore(max_concurrent)
        self.requests_per_minute = requests_per_minute
        self.request_times = []

    async def call(self, prompt: str):
        """Make rate-limited API call"""
        async with self.semaphore:
            # Wait if we've hit rate limit
            await self._wait_if_needed()

            response = await self.client.messages.create(
                model="claude-3-7-sonnet-20250219",
                max_tokens=1024,
                messages=[{"role": "user", "content": prompt}]
            )

            self.request_times.append(asyncio.get_event_loop().time())
            return response.content[0].text

    async def _wait_if_needed(self):
        """Wait if rate limit would be exceeded"""
        now = asyncio.get_event_loop().time()
        minute_ago = now - 60

        # Remove old requests
        self.request_times = [t for t in self.request_times if t > minute_ago]

        # Wait if needed
        if len(self.request_times) >= self.requests_per_minute:
            sleep_time = 60 - (now - self.request_times[0])
            if sleep_time > 0:
                await asyncio.sleep(sleep_time)
```

### Cost Tracking

```python
from dataclasses import dataclass
from typing import Dict

@dataclass
class TokenUsage:
    """Track token usage"""
    input_tokens: int = 0
    output_tokens: int = 0
    cache_read_tokens: int = 0
    cache_creation_tokens: int = 0

class CostTracker:
    """Track API costs"""

    # Pricing per 1M tokens (adjust based on current pricing)
    PRICING = {
        "claude-3-7-sonnet-20250219": {
            "input": 3.00,
            "output": 15.00,
            "cache_write": 3.75,
            "cache_read": 0.30
        },
        "gpt-4o": {
            "input": 2.50,
            "output": 10.00
        }
    }

    def __init__(self):
        self.usage: Dict[str, TokenUsage] = {}

    def track(self, model: str, response):
        """Track usage from response"""
        if model not in self.usage:
            self.usage[model] = TokenUsage()

        usage = self.usage[model]

        # Handle different response formats
        if hasattr(response, 'usage'):
            # Anthropic format
            usage.input_tokens += response.usage.input_tokens
            usage.output_tokens += response.usage.output_tokens
            if hasattr(response.usage, 'cache_read_input_tokens'):
                usage.cache_read_tokens += response.usage.cache_read_input_tokens or 0
            if hasattr(response.usage, 'cache_creation_input_tokens'):
                usage.cache_creation_tokens += response.usage.cache_creation_input_tokens or 0
        elif hasattr(response, 'usage'):
            # OpenAI format
            usage.input_tokens += response.usage.prompt_tokens
            usage.output_tokens += response.usage.completion_tokens

    def calculate_cost(self, model: str) -> float:
        """Calculate total cost for model"""
        if model not in self.usage or model not in self.PRICING:
            return 0.0

        usage = self.usage[model]
        pricing = self.PRICING[model]

        cost = 0.0
        cost += (usage.input_tokens / 1_000_000) * pricing["input"]
        cost += (usage.output_tokens / 1_000_000) * pricing["output"]

        if "cache_write" in pricing:
            cost += (usage.cache_creation_tokens / 1_000_000) * pricing["cache_write"]
        if "cache_read" in pricing:
            cost += (usage.cache_read_tokens / 1_000_000) * pricing["cache_read"]

        return cost

    def report(self):
        """Generate cost report"""
        total = 0.0
        print("\n=== API Cost Report ===")
        for model, usage in self.usage.items():
            cost = self.calculate_cost(model)
            total += cost
            print(f"\n{model}:")
            print(f"  Input tokens: {usage.input_tokens:,}")
            print(f"  Output tokens: {usage.output_tokens:,}")
            if usage.cache_read_tokens:
                print(f"  Cache read: {usage.cache_read_tokens:,}")
            if usage.cache_creation_tokens:
                print(f"  Cache write: {usage.cache_creation_tokens:,}")
            print(f"  Cost: ${cost:.4f}")
        print(f"\nTotal cost: ${total:.4f}")
        return total
```

### Environment Configuration

```python
from pydantic_settings import BaseSettings
from typing import Optional

class AIConfig(BaseSettings):
    """AI API configuration"""

    # API Keys
    anthropic_api_key: Optional[str] = None
    openai_api_key: Optional[str] = None
    google_api_key: Optional[str] = None
    groq_api_key: Optional[str] = None

    # Default models
    default_model: str = "claude-3-7-sonnet-20250219"

    # Limits
    max_tokens: int = 4096
    temperature: float = 0.7
    timeout: int = 30

    class Config:
        env_file = ".env"
        case_sensitive = False

# Usage
config = AIConfig()

client = Anthropic(api_key=config.anthropic_api_key)
```

## Best Practices

1. **Use environment variables for API keys** - Never hardcode
2. **Implement retry logic** - Handle transient failures
3. **Track token usage and costs** - Monitor spending
4. **Use streaming for long responses** - Better UX
5. **Cache prompts when possible** - Reduce costs
6. **Set reasonable timeouts** - Prevent hanging
7. **Handle rate limits gracefully** - Exponential backoff
8. **Validate inputs** - Use Pydantic
9. **Log API calls** - Debug and audit
10. **Use prompt caching** - Save on repeated content

## Model Selection Guide

### When to Use Claude
- Complex reasoning tasks
- Code generation and review
- Long context understanding (200K tokens)
- Safety-critical applications
- Document analysis

### When to Use GPT-4o
- General purpose tasks
- Function calling
- Vision tasks
- Fastest OpenAI model
- Good balance of cost/performance

### When to Use Gemini
- Multimodal tasks (text + image + video)
- Cost-effective for simple tasks
- Long context (2M tokens with Gemini Pro)
- Fast inference

### When to Use Groq
- Ultra-fast inference needed
- Real-time applications
- Cost-effective for simple tasks
- Open source models

## Resources

- Anthropic Docs: https://docs.anthropic.com/
- OpenAI Docs: https://platform.openai.com/docs
- Google AI Docs: https://ai.google.dev/docs
- Groq Docs: https://console.groq.com/docs
- AWS Bedrock: https://aws.amazon.com/bedrock/
- Azure OpenAI: https://azure.microsoft.com/en-us/products/ai-services/openai-service
