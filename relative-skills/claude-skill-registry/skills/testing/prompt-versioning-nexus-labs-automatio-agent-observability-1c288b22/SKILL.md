---
name: prompt-versioning
description: Track prompt versions, A/B test variants, and measure prompt performance
triggers:
  - "prompt versioning"
  - "A/B testing prompts"
  - "prompt experiments"
  - "compare prompts"
  - "prompt optimization"
priority: 1
---

# Prompt Versioning & A/B Testing

Track prompt versions in production and compare their performance.

## Core Principle

Every LLM call should be traceable to:
1. **Which prompt template** was used
2. **Which version** of that template
3. **What variables** were injected
4. **How it performed** (quality, cost, latency)

Without this, you can't iterate on prompts with confidence.

## Prompt Version Attributes

```python
# P0 - Always capture
span.set_attribute("prompt.template_id", "researcher_system_v3")
span.set_attribute("prompt.version", "3.2.1")
span.set_attribute("prompt.variant", "control")  # or "treatment_a"

# P1 - For debugging
span.set_attribute("prompt.template_hash", hash(template))
span.set_attribute("prompt.variables", ["task", "context", "tools"])
span.set_attribute("prompt.char_count", len(rendered_prompt))
```

## Basic Version Tracking

```python
from dataclasses import dataclass
from langfuse.decorators import observe, langfuse_context

@dataclass
class PromptVersion:
    template_id: str
    version: str
    template: str

PROMPTS = {
    "researcher_v1": PromptVersion(
        template_id="researcher_system",
        version="1.0.0",
        template="You are a research assistant. {task}",
    ),
    "researcher_v2": PromptVersion(
        template_id="researcher_system",
        version="2.0.0",
        template="""You are an expert research analyst.

Task: {task}

Guidelines:
- Cite sources
- Be concise
- Highlight uncertainties""",
    ),
}

@observe(name="llm.call", as_type="generation")
def call_llm(messages: list, prompt_key: str = "researcher_v2"):
    prompt = PROMPTS[prompt_key]

    langfuse_context.update_current_observation(
        metadata={
            "prompt_template_id": prompt.template_id,
            "prompt_version": prompt.version,
            "prompt_key": prompt_key,
        }
    )

    response = client.messages.create(
        model="claude-3-5-sonnet-latest",
        system=prompt.template.format(**variables),
        messages=messages,
    )

    return response
```

## A/B Testing Framework

```python
import hashlib
from langfuse.decorators import observe, langfuse_context

class PromptExperiment:
    """A/B test prompt variants."""

    def __init__(
        self,
        experiment_id: str,
        variants: dict[str, str],  # variant_name -> prompt
        weights: dict[str, float] = None,  # variant_name -> weight
    ):
        self.experiment_id = experiment_id
        self.variants = variants
        self.weights = weights or {k: 1.0 for k in variants}

    def get_variant(self, user_id: str) -> tuple[str, str]:
        """Deterministic variant assignment based on user_id."""
        # Hash for consistent assignment
        hash_input = f"{self.experiment_id}:{user_id}"
        hash_value = int(hashlib.sha256(hash_input.encode()).hexdigest(), 16)

        # Weighted selection
        total_weight = sum(self.weights.values())
        threshold = (hash_value % 1000) / 1000 * total_weight

        cumulative = 0
        for variant_name, weight in self.weights.items():
            cumulative += weight
            if threshold < cumulative:
                return variant_name, self.variants[variant_name]

        # Fallback to first variant
        first = list(self.variants.keys())[0]
        return first, self.variants[first]

# Define experiment
researcher_experiment = PromptExperiment(
    experiment_id="researcher_prompt_2024_01",
    variants={
        "control": "You are a research assistant.",
        "concise": "You are a research assistant. Be extremely concise.",
        "structured": "You are a research assistant. Use bullet points.",
    },
    weights={"control": 0.5, "concise": 0.25, "structured": 0.25},
)

@observe(name="agent.run")
def run_agent(task: str, user_id: str):
    # Get assigned variant
    variant_name, prompt = researcher_experiment.get_variant(user_id)

    langfuse_context.update_current_observation(
        metadata={
            "experiment_id": researcher_experiment.experiment_id,
            "variant": variant_name,
            "prompt_hash": hashlib.md5(prompt.encode()).hexdigest()[:8],
        }
    )

    # Run with variant
    return call_llm_with_prompt(task, prompt)
```

## Langfuse Prompt Management

```python
from langfuse import Langfuse

langfuse = Langfuse()

# Fetch versioned prompt from Langfuse
prompt = langfuse.get_prompt("researcher_system", version=3)

@observe(name="llm.call", as_type="generation")
def call_llm(messages: list):
    # Compile prompt with variables
    compiled = prompt.compile(task=task, context=context)

    langfuse_context.update_current_observation(
        metadata={
            "prompt_name": prompt.name,
            "prompt_version": prompt.version,
            "prompt_labels": prompt.labels,  # e.g., ["production", "tested"]
        }
    )

    response = client.messages.create(
        model="claude-3-5-sonnet-latest",
        system=compiled,
        messages=messages,
    )

    return response
```

## Tracking Prompt Performance

```python
from langfuse.decorators import observe, langfuse_context

@observe(name="agent.run")
def run_agent_with_tracking(task: str, user_id: str):
    variant_name, prompt = experiment.get_variant(user_id)

    # Run agent
    start = time.time()
    result = run_with_prompt(task, prompt)
    latency = time.time() - start

    # Track performance metrics by variant
    langfuse_context.update_current_observation(
        metadata={
            "experiment_id": experiment.experiment_id,
            "variant": variant_name,
        }
    )

    # Score the result (can be async/later)
    langfuse_context.score_current_trace(
        name="task_completion",
        value=1.0 if result.success else 0.0,
    )

    langfuse_context.score_current_trace(
        name="latency_ms",
        value=latency * 1000,
    )

    return result
```

## Regression Detection

```python
from langfuse import Langfuse
from datetime import datetime, timedelta

langfuse = Langfuse()

def check_prompt_regression(
    prompt_name: str,
    new_version: int,
    baseline_version: int,
    metric: str = "task_completion",
    min_samples: int = 100,
) -> dict:
    """Compare new prompt version against baseline."""

    # Fetch scores for each version
    new_scores = langfuse.get_scores(
        prompt_name=prompt_name,
        prompt_version=new_version,
        score_name=metric,
        limit=min_samples,
    )

    baseline_scores = langfuse.get_scores(
        prompt_name=prompt_name,
        prompt_version=baseline_version,
        score_name=metric,
        limit=min_samples,
    )

    if len(new_scores) < min_samples:
        return {"status": "insufficient_data", "samples": len(new_scores)}

    new_avg = sum(s.value for s in new_scores) / len(new_scores)
    baseline_avg = sum(s.value for s in baseline_scores) / len(baseline_scores)

    delta = new_avg - baseline_avg
    regression = delta < -0.05  # 5% threshold

    return {
        "status": "regression" if regression else "ok",
        "new_avg": new_avg,
        "baseline_avg": baseline_avg,
        "delta": delta,
        "new_samples": len(new_scores),
        "baseline_samples": len(baseline_scores),
    }
```

## Experiment Analysis Dashboard

Track these metrics per variant:

```python
# Metrics to compare across variants
experiment_metrics = {
    # Quality
    "task_completion_rate": "% tasks completed successfully",
    "quality_score_avg": "Average quality score (0-1)",
    "hallucination_rate": "% responses with hallucinations",

    # Efficiency
    "tokens_per_task_avg": "Average tokens used",
    "latency_p50_ms": "Median latency",
    "cost_per_task_avg": "Average cost in USD",

    # User signals
    "thumbs_up_rate": "% positive feedback",
    "follow_up_rate": "% needing clarification",
}

# Span attributes for dashboards
span.set_attribute("experiment.id", experiment_id)
span.set_attribute("experiment.variant", variant_name)
span.set_attribute("experiment.metric.completion", 1.0)
span.set_attribute("experiment.metric.tokens", total_tokens)
span.set_attribute("experiment.metric.latency_ms", latency_ms)
```

## Gradual Rollout

```python
class GradualRollout:
    """Gradually roll out new prompt version."""

    def __init__(
        self,
        old_prompt: str,
        new_prompt: str,
        rollout_pct: float = 0.0,  # Start at 0%
    ):
        self.old_prompt = old_prompt
        self.new_prompt = new_prompt
        self.rollout_pct = rollout_pct

    def get_prompt(self, user_id: str) -> tuple[str, str]:
        """Get prompt based on rollout percentage."""
        hash_value = int(hashlib.md5(user_id.encode()).hexdigest(), 16)
        in_rollout = (hash_value % 100) < (self.rollout_pct * 100)

        if in_rollout:
            return "new", self.new_prompt
        return "old", self.old_prompt

    def increase_rollout(self, new_pct: float):
        """Increase rollout after validating metrics."""
        self.rollout_pct = min(1.0, new_pct)

# Usage
rollout = GradualRollout(
    old_prompt="You are an assistant.",
    new_prompt="You are a helpful, concise assistant.",
    rollout_pct=0.1,  # 10% get new prompt
)

# After validating metrics, increase
rollout.increase_rollout(0.25)  # 25%
rollout.increase_rollout(0.50)  # 50%
rollout.increase_rollout(1.0)   # 100% - full rollout
```

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| No version tracking | Can't reproduce issues | Always log prompt version |
| Random variant assignment | Inconsistent UX per user | Use deterministic hashing |
| No baseline comparison | Don't know if better/worse | Always compare to control |
| Changing prompts without experiment | Can't measure impact | A/B test before full rollout |
| Ignoring cost in comparisons | New prompt might be expensive | Track cost per variant |

## Related Skills

- `evaluation-quality` - Measuring prompt quality
- `llm-call-tracing` - Capturing LLM inputs/outputs
- `token-cost-tracking` - Cost comparison across variants
