---
name: artificial-analysis-compare
description: |
  Compare LLM models using the Artificial Analysis API. This skill should be used when the user asks to compare AI models, benchmark LLMs, evaluate model performance, compare pricing between models, or find the best model for a specific use case (coding, math, speed, cost). Triggers on requests like "compare GPT-5 and Claude", "which model is fastest", "cheapest model for coding", "benchmark comparison", "model performance analysis", or "artificial analysis". (user)
---

# Artificial Analysis Model Comparison

Compare LLM models using real-time data from the Artificial Analysis API, providing benchmark scores, pricing, and performance metrics with source attribution.

## Workflow

### Step 0: Environment Warmup (Automatic)

**IMPORTANT:** This step runs automatically every time the skill is invoked. Execute the warmup script first to verify the environment is ready.

```bash
python scripts/warmup.py --json
```

The warmup script checks:
1. **Python runtime** - Detects the best Python command (`uv run python`, `python3`, or `python`)
2. **requests library** - Verifies the HTTP library is available
3. **API key** - Checks if key is stored in skill config or environment

#### Handling Warmup Results

**If warmup returns `ready: true`:**
- Proceed to Step 1

**If warmup returns `ready: false` with API key missing:**
- Use AskUserQuestion to prompt for the API key:

```
header: "API Key"
question: "Please provide your Artificial Analysis API key. Get one free at https://artificialanalysis.ai/insights"
options:
  - label: "I have a key"
    description: "Enter your API key in the text field"
  - label: "I need to get a key"
    description: "I'll open the website to create an account"
multiSelect: false
```

- Once the user provides the key, store it:
```bash
python scripts/warmup.py --set-key "USER_PROVIDED_KEY"
```

**If warmup reports Python issues:**
- Inform the user about the Python requirement
- For systems with `uv`: The skill will use `uv run python`
- For other systems: Ensure `python3` is available with `requests` installed

#### API Key Storage

The API key is stored locally within the skill directory at:
```
.config/config.json
```

This file:
- Has restricted permissions (600) for security
- Is gitignored to prevent accidental commits
- Persists across sessions so users only need to enter their key once

#### Using the Stored Key

When making API requests, the skill can retrieve the key in two ways:

1. **Python scripts** - Load from config:
```python
import json
from pathlib import Path

config_file = Path(__file__).parent.parent / ".config" / "config.json"
if config_file.exists():
    config = json.loads(config_file.read_text())
    api_key = config.get("api_key")
```

2. **curl commands** - Read and use inline:
```bash
API_KEY=$(python3 -c "import json; print(json.load(open('${SKILL_DIR}/.config/config.json')).get('api_key', ''))")
curl -s "https://artificialanalysis.ai/api/v2/data/llms/models" -H "x-api-key: $API_KEY"
```

The environment variable `AA_API_KEY` takes precedence if set, allowing users to override the stored key.

### Step 1: Gather User Requirements

Before fetching any data, use AskUserQuestion to clarify the comparison parameters:

**Question 1 - Comparison Focus:**
```
header: "Focus"
question: "What aspects of the models do you want to compare?"
options:
  - label: "Overall Intelligence"
    description: "AI Intelligence Index, MMLU Pro, GPQA benchmarks"
  - label: "Coding Performance"
    description: "Coding Index, LiveCodeBench, TerminalBench Hard"
  - label: "Math & Reasoning"
    description: "Math Index, AIME 2025, reasoning benchmarks"
  - label: "Cost & Value"
    description: "Pricing per million tokens, cost-effectiveness analysis"
  - label: "Speed & Latency"
    description: "Output tokens/sec, time to first token"
  - label: "Comprehensive"
    description: "All metrics in a detailed comparison"
multiSelect: true
```

**Question 2 - Output Format:**
```
header: "Format"
question: "How should the comparison results be displayed?"
options:
  - label: "Summary Table"
    description: "Compact table with key metrics and winner highlights"
  - label: "Detailed Report"
    description: "Full breakdown with all available metrics per model"
  - label: "Ranked List"
    description: "Models ranked by the selected focus area"
  - label: "Cost-Performance Chart"
    description: "Value analysis showing performance per dollar"
multiSelect: false
```

### Step 2: Verify API Documentation

Before making API calls, always verify the current API structure by fetching the official documentation:

```
WebFetch: https://artificialanalysis.ai/documentation#models-endpoint
Prompt: "Extract the complete API specification: base URL, authentication method, endpoint paths, response structure with all available fields (evaluations, pricing, speed metrics), and any recent changes or updates to the API."
```

This ensures the skill's understanding of the API remains current, as the API may evolve.

### Step 3: Fetch Model Data

Use the Artificial Analysis API to retrieve model data:

**Endpoint:** `GET https://artificialanalysis.ai/api/v2/data/llms/models`

**Authentication:** Header `x-api-key` with value from environment variable `AA_API_KEY`

**Example using curl:**
```bash
curl -s "https://artificialanalysis.ai/api/v2/data/llms/models" \
  -H "x-api-key: $AA_API_KEY" > /tmp/aa_models.json
```

**Response Structure:**
```json
{
  "status": 200,
  "data": [
    {
      "id": "uuid",
      "name": "Model Name (variant)",
      "slug": "model-slug",
      "release_date": "YYYY-MM-DD",
      "model_creator": {
        "id": "uuid",
        "name": "Creator Name",
        "slug": "creator-slug"
      },
      "evaluations": {
        "artificial_analysis_intelligence_index": 72.6,
        "artificial_analysis_coding_index": 61.8,
        "artificial_analysis_math_index": 98.7,
        "mmlu_pro": 0.874,
        "gpqa": 0.903,
        "livecodebench": 0.892,
        "aime_25": 0.987,
        "terminalbench_hard": 0.440,
        "hle": 0.098,
        "scicode": 0.344,
        "ifbench": 0.651,
        "lcr": 0.307,
        "tau2": 0.602
      },
      "pricing": {
        "price_1m_input_tokens": 1.75,
        "price_1m_output_tokens": 14.00,
        "price_1m_blended_3_to_1": 4.81
      },
      "median_output_tokens_per_second": 125.6,
      "median_time_to_first_token_seconds": 35.2,
      "median_time_to_first_answer_token": 8.616
    }
  ]
}
```

### Step 4: Filter and Process Models

When the user specifies model names, search by both `name` and `slug` fields using case-insensitive matching:

```python
# Search patterns for common model families
search_patterns = {
    "gpt-5": ["gpt-5", "gpt5"],
    "claude": ["claude", "opus", "sonnet", "haiku"],
    "gemini": ["gemini"],
    "llama": ["llama", "meta"],
    # Add more as needed
}

# Filter models matching user's query
matches = []
for model in data:
    name_lower = model['name'].lower()
    slug_lower = model['slug'].lower()
    if any(term in name_lower or term in slug_lower for term in search_terms):
        matches.append(model)
```

**Model Variant Awareness:**
Many models have multiple variants:
- `(Non-reasoning)` vs `(Reasoning)` - with/without extended thinking
- `(high)`, `(medium)`, `(low)`, `(minimal)` - compute/quality tiers
- Version suffixes like `(Oct '24)`, `(Sep '25)` - release dates

When comparing, prefer matching variants (e.g., compare reasoning models to reasoning models).

### Step 5: Generate Comparison Output

Based on the user's format preference, generate the appropriate output.

#### Summary Table Format

```
| Metric              | Model A    | Model B    | Model C    |
|---------------------|------------|------------|------------|
| Intelligence Index  | 72.6       | 69.8       | 71.3       |
| Coding Index        | 61.8       | 60.2       | 59.2       |
| Blended $/1M tokens | $4.81      | $10.00     | $1.12      |
| Output tokens/sec   | 125.6      | 53.5       | 220.3      |
```

#### Detailed Report Format

For each model, provide:
- Full name, creator, release date
- All benchmark scores with percentages
- Complete pricing breakdown
- Speed metrics
- Category winner indicators

#### Ranked List Format

```
🏆 RANKING BY [FOCUS AREA]:

1. Model A (Score: 72.6)
   - Key strength: ...
   - Pricing: $X.XX/1M tokens

2. Model B (Score: 71.3)
   ...
```

### Step 6: Provide Source Attribution

Always include source URLs for verification. The Artificial Analysis website provides model-specific pages:

**Model Page URL Pattern:**
```
https://artificialanalysis.ai/models/{model-slug}
```

**Leaderboard URLs:**
- Intelligence: `https://artificialanalysis.ai/leaderboards/intelligence`
- Coding: `https://artificialanalysis.ai/leaderboards/coding`
- Speed: `https://artificialanalysis.ai/providers`
- Pricing: `https://artificialanalysis.ai/models`

**Example Source Section:**
```
Sources:
- [GPT-5.2](https://artificialanalysis.ai/models/gpt-5-2)
- [Claude Opus 4.5](https://artificialanalysis.ai/models/claude-opus-4-5)
- [Gemini 3 Flash](https://artificialanalysis.ai/models/gemini-3-flash)
- [Full Leaderboard](https://artificialanalysis.ai/leaderboards/intelligence)
```

## Metric Definitions

| Metric | Description | Scale |
|--------|-------------|-------|
| `artificial_analysis_intelligence_index` | Composite intelligence score | 0-100 |
| `artificial_analysis_coding_index` | Composite coding ability score | 0-100 |
| `artificial_analysis_math_index` | Composite math/reasoning score | 0-100 |
| `mmlu_pro` | Massive Multitask Language Understanding Pro | 0.0-1.0 |
| `gpqa` | Graduate-level science questions | 0.0-1.0 |
| `livecodebench` | Real-world coding benchmark | 0.0-1.0 |
| `aime_25` | American Invitational Mathematics Exam 2025 | 0.0-1.0 |
| `terminalbench_hard` | Terminal/agentic task performance | 0.0-1.0 |
| `price_1m_input_tokens` | Cost per million input tokens (USD) | $ |
| `price_1m_output_tokens` | Cost per million output tokens (USD) | $ |
| `price_1m_blended_3_to_1` | Blended price (3:1 input:output ratio) | $ |
| `median_output_tokens_per_second` | Generation speed | tokens/sec |
| `median_time_to_first_token_seconds` | Response latency | seconds |

## Error Handling

**Missing API Key:**
If `AA_API_KEY` environment variable is not set, inform the user:
"The Artificial Analysis API key is not configured. Set the `AA_API_KEY` environment variable with your API key from https://artificialanalysis.ai/insights"

**API Rate Limit:**
The free API tier allows 1,000 requests per day. If rate limited, inform the user and suggest checking back later.

**Model Not Found:**
When a requested model isn't found, list similar available models:
"Model 'gpt-6' not found. Available GPT models: gpt-5-2, gpt-5-1-codex, gpt-5-nano..."

## Resources

### scripts/

- `fetch_models.py` - Fetches and caches model data from the API
- `compare_models.py` - Generates comparison tables and rankings

### references/

- `aa-api-docs.md` - Cached API documentation (always verify with WebFetch for currency)
