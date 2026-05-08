---
name: evaluation-metrics
description: LLM evaluation frameworks, benchmarks, and quality metrics for production systems.
sasmp_version: "1.3.0"
bonded_agent: 05-evaluation-monitoring
bond_type: PRIMARY_BOND
---

# Evaluation Metrics

Measure and improve LLM quality systematically.

## Quick Start

### Basic Evaluation with RAGAS
```python
from ragas import evaluate
from ragas.metrics import (
    faithfulness,
    answer_relevancy,
    context_precision,
    context_recall
)
from datasets import Dataset

# Prepare evaluation data
eval_data = {
    "question": ["What is machine learning?"],
    "answer": ["ML is a subset of AI that learns from data."],
    "contexts": [["Machine learning is a field of AI..."]],
    "ground_truth": ["Machine learning is AI that learns patterns."]
}

dataset = Dataset.from_dict(eval_data)

# Run evaluation
results = evaluate(
    dataset,
    metrics=[
        faithfulness,
        answer_relevancy,
        context_precision,
        context_recall
    ]
)

print(results)
```

### LangChain Evaluation
```python
from langchain.evaluation import load_evaluator

# Criteria-based evaluation
evaluator = load_evaluator("criteria", criteria="helpfulness")

result = evaluator.evaluate_strings(
    prediction="Paris is the capital of France.",
    input="What is the capital of France?"
)

print(f"Score: {result['score']}, Reasoning: {result['reasoning']}")
```

## Core Metrics

### Text Generation Metrics
```python
from evaluate import load
import numpy as np

class TextMetrics:
    def __init__(self):
        self.bleu = load("bleu")
        self.rouge = load("rouge")
        self.bertscore = load("bertscore")

    def evaluate(self, predictions: list, references: list) -> dict:
        metrics = {}

        # BLEU - Precision-based n-gram overlap
        bleu_result = self.bleu.compute(
            predictions=predictions,
            references=[[r] for r in references]
        )
        metrics['bleu'] = bleu_result['bleu']

        # ROUGE - Recall-based overlap
        rouge_result = self.rouge.compute(
            predictions=predictions,
            references=references
        )
        metrics['rouge1'] = rouge_result['rouge1']
        metrics['rougeL'] = rouge_result['rougeL']

        # BERTScore - Semantic similarity
        bert_result = self.bertscore.compute(
            predictions=predictions,
            references=references,
            lang="en"
        )
        metrics['bertscore_f1'] = np.mean(bert_result['f1'])

        return metrics
```

### RAG-Specific Metrics
```python
class RAGMetrics:
    def __init__(self, llm):
        self.llm = llm

    def faithfulness(self, answer: str, contexts: list) -> float:
        """Check if answer is supported by retrieved contexts."""
        prompt = f"""Given the following context and answer, determine if the answer
is fully supported by the context.

Context: {' '.join(contexts)}

Answer: {answer}

Score from 0 (not supported) to 1 (fully supported):"""

        response = self.llm.generate(prompt)
        return float(response.strip())

    def relevance(self, question: str, answer: str) -> float:
        """Check if answer is relevant to the question."""
        prompt = f"""Rate how relevant this answer is to the question.

Question: {question}
Answer: {answer}

Score from 0 (irrelevant) to 1 (highly relevant):"""

        response = self.llm.generate(prompt)
        return float(response.strip())

    def context_precision(self, question: str, contexts: list) -> float:
        """Check if retrieved contexts are relevant to question."""
        relevant_count = 0
        for ctx in contexts:
            prompt = f"""Is this context relevant to answering the question?

Question: {question}
Context: {ctx}

Answer Yes or No:"""
            if "yes" in self.llm.generate(prompt).lower():
                relevant_count += 1

        return relevant_count / len(contexts)
```

### Hallucination Detection
```python
class HallucinationDetector:
    def __init__(self, llm, knowledge_base=None):
        self.llm = llm
        self.knowledge_base = knowledge_base

    def detect(self, claim: str, source: str = None) -> dict:
        """Detect potential hallucinations in a claim."""
        results = {
            'claim': claim,
            'is_hallucination': False,
            'confidence': 0.0,
            'reason': ''
        }

        # Check against source if provided
        if source:
            prompt = f"""Determine if this claim is supported by the source.

Source: {source}
Claim: {claim}

Is the claim fully supported? Answer with:
SUPPORTED, PARTIALLY_SUPPORTED, or NOT_SUPPORTED
Reason:"""

            response = self.llm.generate(prompt)
            if "NOT_SUPPORTED" in response:
                results['is_hallucination'] = True
                results['confidence'] = 0.9
            elif "PARTIALLY" in response:
                results['confidence'] = 0.5

        # Check for self-consistency
        regenerations = [
            self.llm.generate(f"Verify: {claim}")
            for _ in range(3)
        ]
        consistency = self._check_consistency(regenerations)
        if consistency < 0.7:
            results['is_hallucination'] = True
            results['reason'] = 'Inconsistent across regenerations'

        return results
```

## Benchmark Suites

### MMLU (Massive Multitask Language Understanding)
```python
from datasets import load_dataset

def evaluate_mmlu(model, tokenizer, subjects=None):
    dataset = load_dataset("cais/mmlu", "all")

    results = {}
    for subject in subjects or dataset.keys():
        correct = 0
        total = 0

        for example in dataset[subject]:
            question = example['question']
            choices = example['choices']
            answer = example['answer']

            # Format prompt
            prompt = f"{question}\n"
            for i, choice in enumerate(choices):
                prompt += f"{chr(65+i)}. {choice}\n"
            prompt += "Answer:"

            # Get model prediction
            response = model.generate(prompt)
            predicted = response[0].upper()

            if predicted == chr(65 + answer):
                correct += 1
            total += 1

        results[subject] = correct / total

    return results
```

### HumanEval (Code Generation)
```python
def evaluate_humaneval(model):
    from human_eval.data import read_problems
    from human_eval.execution import check_correctness

    problems = read_problems()
    results = []

    for task_id, problem in problems.items():
        prompt = problem['prompt']

        # Generate completions
        completions = [model.generate(prompt) for _ in range(10)]

        # Check correctness
        for completion in completions:
            result = check_correctness(problem, completion, timeout=10.0)
            results.append(result['passed'])

    pass_at_1 = sum(results[:len(problems)]) / len(problems)
    return {'pass@1': pass_at_1}
```

## Evaluation Framework

```python
from dataclasses import dataclass
from typing import List, Dict, Callable

@dataclass
class EvaluationConfig:
    metrics: List[str]
    sample_size: int = 100
    confidence_level: float = 0.95

class LLMEvaluator:
    def __init__(self, model, config: EvaluationConfig):
        self.model = model
        self.config = config
        self.metrics_registry: Dict[str, Callable] = {}

    def register_metric(self, name: str, func: Callable):
        self.metrics_registry[name] = func

    def evaluate(self, test_data: List[dict]) -> dict:
        results = {metric: [] for metric in self.config.metrics}

        for sample in test_data[:self.config.sample_size]:
            prediction = self.model.generate(sample['input'])

            for metric_name in self.config.metrics:
                metric_func = self.metrics_registry[metric_name]
                score = metric_func(
                    prediction=prediction,
                    reference=sample.get('expected'),
                    context=sample.get('context')
                )
                results[metric_name].append(score)

        # Aggregate results
        aggregated = {}
        for metric, scores in results.items():
            aggregated[metric] = {
                'mean': np.mean(scores),
                'std': np.std(scores),
                'min': np.min(scores),
                'max': np.max(scores)
            }

        return aggregated
```

## A/B Testing

```python
class ABTester:
    def __init__(self, model_a, model_b, evaluator):
        self.model_a = model_a
        self.model_b = model_b
        self.evaluator = evaluator

    def run_test(self, test_data: List[dict], metric: str) -> dict:
        scores_a = []
        scores_b = []

        for sample in test_data:
            # Get predictions from both models
            pred_a = self.model_a.generate(sample['input'])
            pred_b = self.model_b.generate(sample['input'])

            # Evaluate
            score_a = self.evaluator.evaluate_single(pred_a, sample)
            score_b = self.evaluator.evaluate_single(pred_b, sample)

            scores_a.append(score_a[metric])
            scores_b.append(score_b[metric])

        # Statistical test
        from scipy import stats
        t_stat, p_value = stats.ttest_rel(scores_a, scores_b)

        return {
            'model_a_mean': np.mean(scores_a),
            'model_b_mean': np.mean(scores_b),
            'improvement': (np.mean(scores_b) - np.mean(scores_a)) / np.mean(scores_a),
            'p_value': p_value,
            'significant': p_value < 0.05
        }
```

## Metrics Quick Reference

| Metric | Range | Best For | Interpretation |
|--------|-------|----------|----------------|
| BLEU | 0-1 | Translation | Higher = better n-gram match |
| ROUGE-L | 0-1 | Summarization | Higher = better recall |
| BERTScore | 0-1 | General | Higher = semantic similarity |
| Faithfulness | 0-1 | RAG | Higher = grounded in context |
| Perplexity | 1-∞ | Language model | Lower = better fluency |
| Pass@k | 0-1 | Code gen | Higher = more correct samples |

## Best Practices

1. **Use multiple metrics**: No single metric captures everything
2. **Human evaluation**: Ground truth for subjective quality
3. **Domain-specific metrics**: Customize for your use case
4. **Regular benchmarking**: Track quality over time
5. **Statistical significance**: Use proper sample sizes
6. **Version everything**: Models, prompts, and test data

## Error Handling & Retry

```python
from tenacity import retry, stop_after_attempt

@retry(stop=stop_after_attempt(3))
def evaluate_with_retry(model_output, reference):
    return evaluator.evaluate(model_output, reference)

def batch_evaluate(samples, batch_size=50):
    results = []
    for i in range(0, len(samples), batch_size):
        batch = samples[i:i+batch_size]
        results.extend([evaluate_with_retry(s) for s in batch])
    return results
```

## Troubleshooting

| Symptom | Cause | Solution |
|---------|-------|----------|
| Inconsistent scores | High temperature | Set temp=0 for evaluator |
| Slow evaluation | No batching | Batch evaluations |
| Missing metrics | Wrong format | Check data schema |

## Unit Test Template

```python
def test_faithfulness_metric():
    score = evaluate_faithfulness("Answer", ["Context"])
    assert 0 <= score <= 1
```
