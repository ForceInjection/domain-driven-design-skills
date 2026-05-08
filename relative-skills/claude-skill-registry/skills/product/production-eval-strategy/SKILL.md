---
name: production-eval-strategy
description: Strategies for evaluating agents in production - sampling, baselines, and regression detection
triggers:
  - "production evaluation"
  - "eval strategy"
  - "sampling strategy"
  - "regression detection"
  - "baseline comparison"
  - "online evaluation"
priority: 1
---

# Production Evaluation Strategy

How to evaluate agents in production without breaking the bank or slowing things down.

## Core Principle

Production eval is fundamentally different from offline eval:
- **Offline eval**: Run on test set, comprehensive, blocking
- **Production eval**: Sample real traffic, async, non-blocking

You need both. This skill focuses on production.

## The Production Eval Stack

```
┌─────────────────────────────────────────────────────────────┐
│                    Production Traffic                        │
└─────────────────┬───────────────────────────────────────────┘
                  │
        ┌─────────▼─────────┐
        │   Sampling Layer   │  ← What % to evaluate?
        └─────────┬─────────┘
                  │
    ┌─────────────▼─────────────┐
    │   Async Evaluation Queue   │  ← Non-blocking
    └─────────────┬─────────────┘
                  │
    ┌─────────────▼─────────────┐
    │   Evaluation Workers       │  ← LLM-as-judge, heuristics
    └─────────────┬─────────────┘
                  │
    ┌─────────────▼─────────────┐
    │   Scores → Observability   │  ← Langfuse, etc.
    └─────────────┬─────────────┘
                  │
    ┌─────────────▼─────────────┐
    │   Dashboards & Alerts      │  ← Regression detection
    └─────────────────────────────┘
```

## Sampling Strategies

### Random Sampling

```python
import random
from langfuse.decorators import observe

EVAL_SAMPLE_RATE = 0.1  # Evaluate 10% of traffic

@observe(name="agent.run")
def run_agent(task: str) -> str:
    result = agent.invoke(task)

    # Random sampling
    should_eval = random.random() < EVAL_SAMPLE_RATE

    if should_eval:
        # Queue for async evaluation
        eval_queue.send({
            "trace_id": langfuse_context.get_current_trace_id(),
            "task": task,
            "output": result,
            "timestamp": datetime.utcnow().isoformat(),
        })

    return result
```

### Stratified Sampling

```python
# Different sample rates by segment
SAMPLE_RATES = {
    "new_user": 0.5,      # 50% - more signal needed
    "power_user": 0.05,   # 5% - already know behavior
    "enterprise": 1.0,    # 100% - high stakes
    "default": 0.1,
}

def get_sample_rate(user_id: str, user_tier: str) -> float:
    return SAMPLE_RATES.get(user_tier, SAMPLE_RATES["default"])

@observe(name="agent.run")
def run_agent(task: str, user_id: str, user_tier: str) -> str:
    result = agent.invoke(task)

    sample_rate = get_sample_rate(user_id, user_tier)
    should_eval = random.random() < sample_rate

    langfuse_context.update_current_observation(
        metadata={
            "eval_sampled": should_eval,
            "sample_rate": sample_rate,
            "user_tier": user_tier,
        }
    )

    if should_eval:
        queue_for_eval(task, result)

    return result
```

### Error-Biased Sampling

```python
# Always evaluate errors/edge cases
def should_evaluate(result: dict, sample_rate: float) -> tuple[bool, str]:
    """Determine if we should evaluate, with reason."""

    # Always eval errors
    if result.get("error"):
        return True, "error"

    # Always eval when user gave feedback
    if result.get("has_feedback"):
        return True, "has_feedback"

    # Always eval long-running tasks
    if result.get("duration_ms", 0) > 30000:
        return True, "slow"

    # Always eval high-cost tasks
    if result.get("cost_usd", 0) > 0.50:
        return True, "expensive"

    # Random sample the rest
    if random.random() < sample_rate:
        return True, "random_sample"

    return False, "not_sampled"
```

## Async Evaluation Pipeline

```python
import asyncio
from langfuse import Langfuse

langfuse = Langfuse()

class AsyncEvaluator:
    """Non-blocking evaluation pipeline."""

    def __init__(self, evaluators: list):
        self.evaluators = evaluators
        self.queue = asyncio.Queue()

    async def worker(self):
        """Process eval queue."""
        while True:
            item = await self.queue.get()

            try:
                await self.evaluate(item)
            except Exception as e:
                # Log but don't crash
                logger.error(f"Eval failed: {e}")
            finally:
                self.queue.task_done()

    async def evaluate(self, item: dict):
        """Run all evaluators on an item."""

        for evaluator in self.evaluators:
            try:
                score = await evaluator(item)

                # Submit score to Langfuse
                langfuse.score(
                    trace_id=item["trace_id"],
                    name=evaluator.name,
                    value=score.value,
                    comment=score.reasoning,
                )
            except Exception as e:
                logger.error(f"Evaluator {evaluator.name} failed: {e}")

    def submit(self, item: dict):
        """Non-blocking submit to queue."""
        asyncio.create_task(self.queue.put(item))

# Setup
evaluator = AsyncEvaluator([
    FactualityEvaluator(),
    HelpfulnessEvaluator(),
    SafetyEvaluator(),
])

# Start workers
for _ in range(3):
    asyncio.create_task(evaluator.worker())
```

## Baseline Comparison

```python
from dataclasses import dataclass
from datetime import datetime, timedelta

@dataclass
class Baseline:
    metric: str
    value: float
    calculated_at: datetime
    sample_size: int

class BaselineManager:
    """Manage evaluation baselines."""

    def __init__(self):
        self.baselines: dict[str, Baseline] = {}

    def calculate_baseline(
        self,
        metric: str,
        lookback_days: int = 7,
        min_samples: int = 100,
    ) -> Baseline:
        """Calculate baseline from recent data."""

        scores = langfuse.get_scores(
            name=metric,
            start_time=datetime.utcnow() - timedelta(days=lookback_days),
        )

        if len(scores) < min_samples:
            raise ValueError(f"Insufficient samples: {len(scores)} < {min_samples}")

        baseline = Baseline(
            metric=metric,
            value=sum(s.value for s in scores) / len(scores),
            calculated_at=datetime.utcnow(),
            sample_size=len(scores),
        )

        self.baselines[metric] = baseline
        return baseline

    def compare_to_baseline(
        self,
        metric: str,
        current_value: float,
        threshold: float = 0.05,  # 5% regression threshold
    ) -> dict:
        """Compare current value to baseline."""

        baseline = self.baselines.get(metric)
        if not baseline:
            return {"status": "no_baseline"}

        delta = current_value - baseline.value
        pct_change = delta / baseline.value if baseline.value > 0 else 0

        is_regression = pct_change < -threshold
        is_improvement = pct_change > threshold

        return {
            "status": "regression" if is_regression else "improvement" if is_improvement else "stable",
            "baseline": baseline.value,
            "current": current_value,
            "delta": delta,
            "pct_change": pct_change,
            "threshold": threshold,
        }
```

## Regression Detection

```python
from langfuse import Langfuse

langfuse = Langfuse()

class RegressionDetector:
    """Detect quality regressions in production."""

    def __init__(
        self,
        metrics: list[str],
        window_hours: int = 24,
        baseline_days: int = 7,
        alert_threshold: float = 0.1,  # 10% regression
    ):
        self.metrics = metrics
        self.window_hours = window_hours
        self.baseline_days = baseline_days
        self.alert_threshold = alert_threshold

    def check_regressions(self) -> list[dict]:
        """Check all metrics for regressions."""

        regressions = []

        for metric in self.metrics:
            result = self.check_metric(metric)
            if result["status"] == "regression":
                regressions.append(result)

        return regressions

    def check_metric(self, metric: str) -> dict:
        """Check single metric for regression."""

        now = datetime.utcnow()

        # Recent window
        recent_scores = langfuse.get_scores(
            name=metric,
            start_time=now - timedelta(hours=self.window_hours),
        )

        # Baseline window
        baseline_scores = langfuse.get_scores(
            name=metric,
            start_time=now - timedelta(days=self.baseline_days),
            end_time=now - timedelta(hours=self.window_hours),
        )

        if len(recent_scores) < 10 or len(baseline_scores) < 50:
            return {"metric": metric, "status": "insufficient_data"}

        recent_avg = sum(s.value for s in recent_scores) / len(recent_scores)
        baseline_avg = sum(s.value for s in baseline_scores) / len(baseline_scores)

        delta = recent_avg - baseline_avg
        pct_change = delta / baseline_avg if baseline_avg > 0 else 0

        is_regression = pct_change < -self.alert_threshold

        return {
            "metric": metric,
            "status": "regression" if is_regression else "ok",
            "recent_avg": recent_avg,
            "baseline_avg": baseline_avg,
            "pct_change": pct_change,
            "recent_samples": len(recent_scores),
            "baseline_samples": len(baseline_scores),
        }

# Setup and schedule
detector = RegressionDetector(
    metrics=["task_completion", "helpfulness", "factuality"],
    window_hours=24,
    alert_threshold=0.1,
)

# Run hourly
@scheduled(every="1h")
def check_for_regressions():
    regressions = detector.check_regressions()

    if regressions:
        send_alert(
            title="Quality Regression Detected",
            body=format_regressions(regressions),
            severity="high",
        )
```

## Evaluator Types for Production

```python
# Fast, cheap evaluators for high volume
class HeuristicEvaluators:
    """Rule-based evaluators - fast and cheap."""

    @staticmethod
    def response_length(output: str) -> float:
        """Penalize too short or too long responses."""
        length = len(output)
        if length < 50:
            return 0.3
        if length > 5000:
            return 0.5
        return 1.0

    @staticmethod
    def has_citations(output: str) -> float:
        """Check if response includes citations."""
        citation_patterns = [r"\[\d+\]", r"\(source:", r"according to"]
        return 1.0 if any(re.search(p, output) for p in citation_patterns) else 0.0

    @staticmethod
    def no_refusal(output: str) -> float:
        """Check for unnecessary refusals."""
        refusal_patterns = ["I cannot", "I'm not able", "As an AI"]
        return 0.0 if any(p.lower() in output.lower() for p in refusal_patterns) else 1.0

# Expensive evaluators for sampled traffic
class LLMEvaluators:
    """LLM-as-judge evaluators - slow but accurate."""

    @staticmethod
    async def factuality(task: str, output: str, sources: list) -> float:
        """Check factual accuracy using LLM judge."""

        prompt = f"""Rate the factual accuracy of this response (0-1):

Task: {task}
Response: {output}
Sources: {sources}

Consider:
- Are claims supported by sources?
- Are there any hallucinations?
- Is information current?

Score (0-1):"""

        result = await judge_llm.invoke(prompt)
        return parse_score(result)
```

## Eval Budget Management

```python
class EvalBudget:
    """Manage evaluation costs."""

    def __init__(
        self,
        daily_budget_usd: float,
        cost_per_eval: float,  # Average cost
    ):
        self.daily_budget = daily_budget_usd
        self.cost_per_eval = cost_per_eval
        self.today_spend = 0.0
        self.last_reset = datetime.utcnow().date()

    def can_evaluate(self) -> bool:
        """Check if we have budget for another eval."""
        self._maybe_reset()
        return self.today_spend < self.daily_budget

    def record_eval(self, actual_cost: float = None):
        """Record an evaluation."""
        self.today_spend += actual_cost or self.cost_per_eval

    def get_dynamic_sample_rate(self, base_rate: float) -> float:
        """Adjust sample rate based on remaining budget."""
        self._maybe_reset()

        remaining = self.daily_budget - self.today_spend
        if remaining <= 0:
            return 0.0

        # Reduce rate as budget depletes
        budget_pct = remaining / self.daily_budget
        return base_rate * budget_pct

    def _maybe_reset(self):
        """Reset daily budget."""
        today = datetime.utcnow().date()
        if today > self.last_reset:
            self.today_spend = 0.0
            self.last_reset = today

# Usage
budget = EvalBudget(daily_budget_usd=50.0, cost_per_eval=0.02)

def should_evaluate(base_rate: float = 0.1) -> bool:
    if not budget.can_evaluate():
        return False

    dynamic_rate = budget.get_dynamic_sample_rate(base_rate)
    return random.random() < dynamic_rate
```

## Dashboard Metrics

```python
production_eval_metrics = {
    # Volume
    "traces_total": "Total production traces",
    "traces_evaluated": "Traces that were evaluated",
    "eval_sample_rate": "Actual % evaluated",

    # Quality
    "quality_score_avg": "Average quality score",
    "quality_score_p10": "10th percentile (worst)",
    "regression_alerts": "Regression alerts triggered",

    # Comparison
    "vs_baseline_delta": "Change from baseline",
    "by_prompt_version": "Quality by prompt version",
    "by_model": "Quality by model",

    # Cost
    "eval_cost_daily": "Daily evaluation cost",
    "eval_cost_per_trace": "Avg cost per evaluated trace",
}
```

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Evaluating 100% of traffic | Cost explosion | Sample 1-10% |
| Sync evaluation in request path | Latency | Async queue |
| No baseline | Can't detect regression | Calculate rolling baseline |
| Same sampling for all users | Wastes budget | Stratify by segment |
| Only positive metrics | Miss problems | Track failure rates too |
| No budget limits | Runaway costs | Set daily caps |

## Related Skills

- `evaluation-quality` - Eval implementation
- `prompt-versioning` - A/B testing evals
- `token-cost-tracking` - Eval cost tracking
