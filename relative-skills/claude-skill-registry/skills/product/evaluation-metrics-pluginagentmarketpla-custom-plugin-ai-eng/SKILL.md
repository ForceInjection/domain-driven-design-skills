---
name: evaluation-metrics
description: Automatically applies when evaluating LLM performance. Ensures proper eval datasets, metrics computation, A/B testing, LLM-as-judge patterns, and experiment tracking.
category: ai-llm
---

# Evaluation Metrics for LLM Applications

When evaluating LLM performance, follow these patterns for rigorous, reproducible evaluation.

**Trigger Keywords**: evaluation, eval, metrics, benchmark, test set, A/B test, LLM judge, performance testing, accuracy, precision, recall, F1, BLEU, ROUGE, experiment tracking

**Agent Integration**: Used by `ml-system-architect`, `performance-and-cost-engineer-llm`, `llm-app-engineer`

## ✅ Correct Pattern: Evaluation Dataset

```python
from typing import List, Dict, Optional
from pydantic import BaseModel, Field
from datetime import datetime
import json


class EvalExample(BaseModel):
    """Single evaluation example."""

    id: str
    input: str
    expected_output: str
    metadata: Dict[str, any] = Field(default_factory=dict)
    tags: List[str] = Field(default_factory=list)


class EvalDataset(BaseModel):
    """Evaluation dataset with metadata."""

    name: str
    description: str
    version: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
    examples: List[EvalExample]

    def save(self, path: str):
        """Save dataset to JSON file."""
        with open(path, "w") as f:
            json.dump(self.model_dump(), f, indent=2, default=str)

    @classmethod
    def load(cls, path: str) -> "EvalDataset":
        """Load dataset from JSON file."""
        with open(path) as f:
            data = json.load(f)
        return cls(**data)

    def filter_by_tag(self, tag: str) -> "EvalDataset":
        """Filter dataset by tag."""
        filtered = [ex for ex in self.examples if tag in ex.tags]
        return EvalDataset(
            name=f"{self.name}_{tag}",
            description=f"Filtered by tag: {tag}",
            version=self.version,
            examples=filtered
        )


# Create evaluation dataset
eval_dataset = EvalDataset(
    name="summarization_eval",
    description="Evaluation set for document summarization",
    version="1.0",
    examples=[
        EvalExample(
            id="sum_001",
            input="Long document text...",
            expected_output="Concise summary...",
            tags=["short", "technical"]
        ),
        EvalExample(
            id="sum_002",
            input="Another document...",
            expected_output="Another summary...",
            tags=["long", "business"]
        )
    ]
)

eval_dataset.save("eval_data/summarization_v1.json")
```

## Evaluation Metrics

```python
from typing import Protocol, List
import numpy as np
from sklearn.metrics import accuracy_score, precision_recall_fscore_support
import re


class Metric(Protocol):
    """Protocol for evaluation metrics."""

    def compute(
        self,
        predictions: List[str],
        references: List[str]
    ) -> float:
        """Compute metric score."""
        ...


class ExactMatch:
    """Exact match metric (case-insensitive)."""

    def compute(
        self,
        predictions: List[str],
        references: List[str]
    ) -> float:
        """
        Compute exact match accuracy.

        Returns:
            Fraction of exact matches (0-1)
        """
        matches = sum(
            p.strip().lower() == r.strip().lower()
            for p, r in zip(predictions, references)
        )
        return matches / len(predictions)


class TokenOverlap:
    """Token overlap metric (precision, recall, F1)."""

    def tokenize(self, text: str) -> set:
        """Simple whitespace tokenization."""
        return set(text.lower().split())

    def compute_f1(
        self,
        prediction: str,
        reference: str
    ) -> Dict[str, float]:
        """
        Compute precision, recall, F1 for single example.

        Returns:
            Dict with precision, recall, f1 scores
        """
        pred_tokens = self.tokenize(prediction)
        ref_tokens = self.tokenize(reference)

        if not pred_tokens or not ref_tokens:
            return {"precision": 0.0, "recall": 0.0, "f1": 0.0}

        overlap = pred_tokens & ref_tokens

        precision = len(overlap) / len(pred_tokens)
        recall = len(overlap) / len(ref_tokens)

        if precision + recall == 0:
            f1 = 0.0
        else:
            f1 = 2 * (precision * recall) / (precision + recall)

        return {
            "precision": precision,
            "recall": recall,
            "f1": f1
        }

    def compute(
        self,
        predictions: List[str],
        references: List[str]
    ) -> Dict[str, float]:
        """
        Compute average metrics across all examples.

        Returns:
            Dict with average precision, recall, f1
        """
        scores = [
            self.compute_f1(p, r)
            for p, r in zip(predictions, references)
        ]

        return {
            "precision": np.mean([s["precision"] for s in scores]),
            "recall": np.mean([s["recall"] for s in scores]),
            "f1": np.mean([s["f1"] for s in scores])
        }


class SemanticSimilarity:
    """Semantic similarity using embeddings."""

    def __init__(self, embedding_model):
        self.embedding_model = embedding_model

    async def compute(
        self,
        predictions: List[str],
        references: List[str]
    ) -> float:
        """
        Compute average cosine similarity.

        Returns:
            Average similarity score (0-1)
        """
        # Embed predictions and references
        pred_embeddings = await self.embedding_model.embed(predictions)
        ref_embeddings = await self.embedding_model.embed(references)

        # Compute cosine similarities
        similarities = []
        for pred_emb, ref_emb in zip(pred_embeddings, ref_embeddings):
            similarity = np.dot(pred_emb, ref_emb) / (
                np.linalg.norm(pred_emb) * np.linalg.norm(ref_emb)
            )
            similarities.append(similarity)

        return float(np.mean(similarities))


# Usage
exact_match = ExactMatch()
token_overlap = TokenOverlap()

predictions = ["The cat sat on mat", "Python is great"]
references = ["The cat sat on the mat", "Python is awesome"]

em_score = exact_match.compute(predictions, references)
overlap_scores = token_overlap.compute(predictions, references)

print(f"Exact Match: {em_score:.2f}")
print(f"F1 Score: {overlap_scores['f1']:.2f}")
```

## LLM-as-Judge Evaluation

```python
class LLMJudge:
    """Use LLM to evaluate outputs."""

    def __init__(self, llm_client):
        self.llm = llm_client

    async def judge_single(
        self,
        input: str,
        prediction: str,
        reference: Optional[str] = None,
        criteria: List[str] = None
    ) -> Dict[str, any]:
        """
        Evaluate single prediction using LLM.

        Args:
            input: Original input
            prediction: Model prediction
            reference: Optional reference answer
            criteria: Evaluation criteria

        Returns:
            Dict with score and reasoning
        """
        criteria = criteria or [
            "accuracy",
            "relevance",
            "completeness",
            "clarity"
        ]

        prompt = self._build_judge_prompt(
            input, prediction, reference, criteria
        )

        response = await self.llm.complete(prompt, temperature=0.0)

        # Parse response (expects JSON)
        import json
        try:
            result = json.loads(response)
            return result
        except json.JSONDecodeError:
            return {
                "score": 0,
                "reasoning": "Failed to parse response",
                "raw_response": response
            }

    def _build_judge_prompt(
        self,
        input: str,
        prediction: str,
        reference: Optional[str],
        criteria: List[str]
    ) -> str:
        """Build prompt for LLM judge."""
        criteria_str = ", ".join(criteria)

        prompt = f"""Evaluate this model output on: {criteria_str}

Input:
{input}

Model Output:
{prediction}"""

        if reference:
            prompt += f"""

Reference Answer:
{reference}"""

        prompt += """

Provide evaluation as JSON:
{
  "score": <1-10>,
  "reasoning": "<explanation>",
  "criteria_scores": {
    "accuracy": <1-10>,
    "relevance": <1-10>,
    ...
  }
}"""

        return prompt

    async def batch_judge(
        self,
        examples: List[Dict[str, str]],
        criteria: List[str] = None
    ) -> List[Dict[str, any]]:
        """
        Judge multiple examples in batch.

        Args:
            examples: List of dicts with input, prediction, reference
            criteria: Evaluation criteria

        Returns:
            List of judgment results
        """
        import asyncio

        tasks = [
            self.judge_single(
                input=ex["input"],
                prediction=ex["prediction"],
                reference=ex.get("reference"),
                criteria=criteria
            )
            for ex in examples
        ]

        return await asyncio.gather(*tasks)


# Usage
judge = LLMJudge(llm_client)

result = await judge.judge_single(
    input="What is Python?",
    prediction="Python is a programming language.",
    reference="Python is a high-level programming language.",
    criteria=["accuracy", "completeness", "clarity"]
)

print(f"Score: {result['score']}/10")
print(f"Reasoning: {result['reasoning']}")
```

## A/B Testing Framework

```python
from typing import Callable, Dict, List
from dataclasses import dataclass
from datetime import datetime
import random


@dataclass
class Variant:
    """A/B test variant."""

    name: str
    model_fn: Callable
    traffic_weight: float = 0.5


@dataclass
class ABTestResult:
    """Result from A/B test."""

    variant_name: str
    example_id: str
    prediction: str
    metrics: Dict[str, float]
    latency_ms: float
    timestamp: datetime


class ABTest:
    """A/B testing framework for LLM variants."""

    def __init__(
        self,
        name: str,
        variants: List[Variant],
        metrics: List[Metric]
    ):
        self.name = name
        self.variants = variants
        self.metrics = metrics
        self.results: List[ABTestResult] = []

        # Normalize weights
        total_weight = sum(v.traffic_weight for v in variants)
        for v in variants:
            v.traffic_weight /= total_weight

    def select_variant(self) -> Variant:
        """Select variant based on traffic weight."""
        r = random.random()
        cumulative = 0.0

        for variant in self.variants:
            cumulative += variant.traffic_weight
            if r <= cumulative:
                return variant

        return self.variants[-1]

    async def run_test(
        self,
        eval_dataset: EvalDataset,
        samples_per_variant: Optional[int] = None
    ) -> Dict[str, any]:
        """
        Run A/B test on evaluation dataset.

        Args:
            eval_dataset: Evaluation dataset
            samples_per_variant: Samples per variant (None = all)

        Returns:
            Test results with metrics per variant
        """
        import time

        samples = samples_per_variant or len(eval_dataset.examples)

        # Run predictions for each variant
        for variant in self.variants:
            for i, example in enumerate(eval_dataset.examples[:samples]):
                start = time.time()

                # Get prediction from variant
                prediction = await variant.model_fn(example.input)

                latency = (time.time() - start) * 1000

                # Compute metrics
                variant_metrics = {}
                for metric in self.metrics:
                    score = metric.compute([prediction], [example.expected_output])
                    variant_metrics[metric.__class__.__name__] = score

                # Store result
                self.results.append(ABTestResult(
                    variant_name=variant.name,
                    example_id=example.id,
                    prediction=prediction,
                    metrics=variant_metrics,
                    latency_ms=latency,
                    timestamp=datetime.utcnow()
                ))

        return self.analyze_results()

    def analyze_results(self) -> Dict[str, any]:
        """
        Analyze A/B test results.

        Returns:
            Statistics per variant
        """
        variant_stats = {}

        for variant in self.variants:
            variant_results = [
                r for r in self.results
                if r.variant_name == variant.name
            ]

            if not variant_results:
                continue

            # Aggregate metrics
            metric_names = variant_results[0].metrics.keys()
            avg_metrics = {}

            for metric_name in metric_names:
                scores = [r.metrics[metric_name] for r in variant_results]
                avg_metrics[metric_name] = {
                    "mean": np.mean(scores),
                    "std": np.std(scores),
                    "min": np.min(scores),
                    "max": np.max(scores)
                }

            # Latency stats
            latencies = [r.latency_ms for r in variant_results]

            variant_stats[variant.name] = {
                "samples": len(variant_results),
                "metrics": avg_metrics,
                "latency": {
                    "mean_ms": np.mean(latencies),
                    "p50_ms": np.percentile(latencies, 50),
                    "p95_ms": np.percentile(latencies, 95),
                    "p99_ms": np.percentile(latencies, 99)
                }
            }

        return variant_stats


# Usage
variants = [
    Variant(
        name="baseline",
        model_fn=lambda x: model_v1.complete(x),
        traffic_weight=0.5
    ),
    Variant(
        name="candidate",
        model_fn=lambda x: model_v2.complete(x),
        traffic_weight=0.5
    )
]

ab_test = ABTest(
    name="summarization_v1_vs_v2",
    variants=variants,
    metrics=[ExactMatch(), TokenOverlap()]
)

results = await ab_test.run_test(eval_dataset, samples_per_variant=100)
```

## Experiment Tracking

```python
from typing import Dict, Any, Optional
import json
from pathlib import Path


class ExperimentTracker:
    """Track experiments and results."""

    def __init__(self, experiments_dir: str = "experiments"):
        self.experiments_dir = Path(experiments_dir)
        self.experiments_dir.mkdir(exist_ok=True)

    def log_experiment(
        self,
        name: str,
        config: Dict[str, Any],
        metrics: Dict[str, float],
        metadata: Optional[Dict[str, Any]] = None
    ) -> str:
        """
        Log experiment configuration and results.

        Args:
            name: Experiment name
            config: Model configuration
            metrics: Evaluation metrics
            metadata: Additional metadata

        Returns:
            Experiment ID
        """
        from datetime import datetime
        import uuid

        experiment_id = str(uuid.uuid4())[:8]
        timestamp = datetime.utcnow()

        experiment = {
            "id": experiment_id,
            "name": name,
            "timestamp": timestamp.isoformat(),
            "config": config,
            "metrics": metrics,
            "metadata": metadata or {}
        }

        # Save to file
        filename = f"{timestamp.strftime('%Y%m%d_%H%M%S')}_{name}_{experiment_id}.json"
        filepath = self.experiments_dir / filename

        with open(filepath, "w") as f:
            json.dump(experiment, f, indent=2)

        return experiment_id

    def load_experiment(self, experiment_id: str) -> Optional[Dict[str, Any]]:
        """Load experiment by ID."""
        for filepath in self.experiments_dir.glob(f"*_{experiment_id}.json"):
            with open(filepath) as f:
                return json.load(f)
        return None

    def list_experiments(
        self,
        name: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """List all experiments, optionally filtered by name."""
        experiments = []

        for filepath in sorted(self.experiments_dir.glob("*.json")):
            with open(filepath) as f:
                exp = json.load(f)
                if name is None or exp["name"] == name:
                    experiments.append(exp)

        return experiments

    def compare_experiments(
        self,
        experiment_ids: List[str]
    ) -> Dict[str, Any]:
        """Compare multiple experiments."""
        experiments = [
            self.load_experiment(exp_id)
            for exp_id in experiment_ids
        ]

        # Extract metrics for comparison
        comparison = {
            "experiments": []
        }

        for exp in experiments:
            if exp:
                comparison["experiments"].append({
                    "id": exp["id"],
                    "name": exp["name"],
                    "metrics": exp["metrics"]
                })

        return comparison


# Usage
tracker = ExperimentTracker()

exp_id = tracker.log_experiment(
    name="summarization_v2",
    config={
        "model": "claude-sonnet-4",
        "temperature": 0.3,
        "max_tokens": 512,
        "prompt_version": "2.0"
    },
    metrics={
        "exact_match": 0.45,
        "f1": 0.78,
        "semantic_similarity": 0.85
    },
    metadata={
        "dataset": "summarization_v1.json",
        "num_examples": 100
    }
)

print(f"Logged experiment: {exp_id}")
```

## ❌ Anti-Patterns

```python
# ❌ No evaluation dataset
def test_model():
    result = model("test this")  # Single example!
    print("Works!")

# ✅ Better: Use proper eval dataset
eval_dataset = EvalDataset.load("eval_data.json")
results = await evaluator.run(model, eval_dataset)


# ❌ Only exact match metric
score = sum(p == r for p, r in zip(preds, refs)) / len(preds)

# ✅ Better: Multiple metrics
metrics = {
    "exact_match": ExactMatch().compute(preds, refs),
    "f1": TokenOverlap().compute(preds, refs)["f1"],
    "semantic_sim": await SemanticSimilarity().compute(preds, refs)
}


# ❌ No experiment tracking
model_v2_score = 0.78  # Lost context!

# ✅ Better: Track all experiments
tracker.log_experiment(
    name="model_v2",
    config={"version": "2.0"},
    metrics={"f1": 0.78}
)


# ❌ Cherry-picking examples
good_examples = [ex for ex in dataset if model(ex) == expected]

# ✅ Better: Use full representative dataset
results = evaluate_on_full_dataset(model, dataset)
```

## Best Practices Checklist

- ✅ Create representative evaluation datasets
- ✅ Version control eval datasets
- ✅ Use multiple complementary metrics
- ✅ Include LLM-as-judge for qualitative evaluation
- ✅ Run A/B tests for variant comparison
- ✅ Track all experiments with config and metrics
- ✅ Measure latency alongside quality metrics
- ✅ Use statistical significance testing
- ✅ Evaluate on diverse examples (easy, medium, hard)
- ✅ Include edge cases and adversarial examples
- ✅ Document evaluation methodology
- ✅ Set up automated evaluation in CI/CD

## Auto-Apply

When evaluating LLM systems:
1. Create EvalDataset with representative examples
2. Compute multiple metrics (exact match, F1, semantic similarity)
3. Use LLM-as-judge for qualitative assessment
4. Run A/B tests comparing variants
5. Track experiments with ExperimentTracker
6. Measure latency alongside quality
7. Save results for reproducibility

## Related Skills

- `prompting-patterns` - For prompt engineering
- `llm-app-architecture` - For LLM integration
- `monitoring-alerting` - For production metrics
- `model-selection` - For choosing models
- `performance-profiling` - For optimization
