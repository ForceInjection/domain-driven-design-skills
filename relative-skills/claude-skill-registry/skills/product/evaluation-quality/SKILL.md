---
name: evaluation-quality
description: Instrument evaluation metrics, quality scores, and feedback loops
triggers:
  - "agent evaluation"
  - "quality metrics"
  - "response scoring"
  - "evals instrumentation"
  - "feedback tracking"
priority: 2
---

# Evaluation and Quality Instrumentation

Instrument evaluation systems to track agent quality and enable continuous improvement.

## Core Principle

Quality observability answers:
1. **How good** are agent responses?
2. **What types** of errors occur (hallucination, refusal, etc.)?
3. **Is quality improving** over time?
4. **What correlates** with high/low quality?
5. **How does human feedback** compare to automated evals?

## Evaluation Types

### Automated Evals
LLM-as-judge or heuristic scoring:
```python
span.set_attribute("eval.type", "automated")
span.set_attribute("eval.method", "llm_judge")
span.set_attribute("eval.model", "claude-3-opus")
span.set_attribute("eval.criteria", "helpfulness")
span.set_attribute("eval.score", 0.85)
span.set_attribute("eval.confidence", 0.92)
```

### Human Feedback
User ratings and corrections:
```python
span.set_attribute("eval.type", "human")
span.set_attribute("eval.feedback_type", "thumbs")
span.set_attribute("eval.score", 1)  # 1 = thumbs up, 0 = thumbs down
span.set_attribute("eval.user_id", "user_hash")
span.set_attribute("eval.latency_to_feedback_ms", 45000)
```

### Ground Truth Comparison
Compare to known correct answers:
```python
span.set_attribute("eval.type", "ground_truth")
span.set_attribute("eval.metric", "exact_match")
span.set_attribute("eval.score", 1.0)
span.set_attribute("eval.test_case_id", "test_123")
```

## Quality Dimensions

### Correctness
```python
span.set_attribute("quality.factual_accuracy", 0.95)
span.set_attribute("quality.hallucination_detected", False)
span.set_attribute("quality.source_grounded", True)
span.set_attribute("quality.citation_count", 3)
```

### Helpfulness
```python
span.set_attribute("quality.task_completion", 1.0)
span.set_attribute("quality.answered_question", True)
span.set_attribute("quality.actionable", True)
span.set_attribute("quality.conciseness", 0.8)
```

### Safety
```python
span.set_attribute("quality.safety_score", 1.0)
span.set_attribute("quality.refused", False)
span.set_attribute("quality.pii_detected", False)
span.set_attribute("quality.harmful_content", False)
```

### Relevance
```python
span.set_attribute("quality.relevance", 0.9)
span.set_attribute("quality.on_topic", True)
span.set_attribute("quality.context_used", 0.85)
```

## Eval Span Attributes

```python
# Eval metadata (P0)
span.set_attribute("eval.id", str(uuid4()))
span.set_attribute("eval.name", "helpfulness_v2")
span.set_attribute("eval.version", "2.1")
span.set_attribute("eval.timestamp", datetime.utcnow().isoformat())

# Input reference (P0)
span.set_attribute("eval.trace_id", original_trace_id)
span.set_attribute("eval.span_id", original_span_id)
span.set_attribute("eval.agent_name", "researcher")

# Scores (P0)
span.set_attribute("eval.score", 0.85)
span.set_attribute("eval.pass", True)
span.set_attribute("eval.threshold", 0.7)

# Details (P1)
span.set_attribute("eval.reasoning", "Response was accurate and helpful")
span.set_attribute("eval.issues", ["slightly_verbose"])
span.set_attribute("eval.latency_ms", 1500)
```

## Feedback Collection Pattern

```python
from langfuse.decorators import observe

@observe(name="feedback.collect")
def collect_feedback(
    trace_id: str,
    score: int,
    feedback_type: str = "thumbs",
    comment: str = None,
):
    span = get_current_span()
    span.set_attribute("feedback.trace_id", trace_id)
    span.set_attribute("feedback.type", feedback_type)
    span.set_attribute("feedback.score", score)

    if comment:
        span.set_attribute("feedback.has_comment", True)
        span.set_attribute("feedback.comment_length", len(comment))

    # Store feedback
    langfuse.score(
        trace_id=trace_id,
        name=feedback_type,
        value=score,
        comment=comment,
    )
```

## LLM-as-Judge Pattern

```python
@observe(name="eval.llm_judge")
def evaluate_response(
    question: str,
    response: str,
    criteria: str,
) -> float:
    span = get_current_span()
    span.set_attribute("eval.method", "llm_judge")
    span.set_attribute("eval.criteria", criteria)

    judge_prompt = f"""
    Evaluate this response on {criteria} (0-1 scale):

    Question: {question}
    Response: {response}

    Score:
    """

    result = judge_llm.invoke(judge_prompt)
    score = parse_score(result)

    span.set_attribute("eval.score", score)
    span.set_attribute("eval.judge_tokens", result.usage.total_tokens)

    return score
```

## Hallucination Detection

```python
@observe(name="eval.hallucination_check")
def check_hallucination(
    response: str,
    sources: list[str],
) -> dict:
    span = get_current_span()
    span.set_attribute("eval.type", "hallucination")

    # Check each claim against sources
    claims = extract_claims(response)
    span.set_attribute("eval.claims_count", len(claims))

    grounded = 0
    for claim in claims:
        if is_grounded(claim, sources):
            grounded += 1

    score = grounded / len(claims) if claims else 1.0

    span.set_attribute("eval.grounded_claims", grounded)
    span.set_attribute("eval.hallucination_score", 1 - score)
    span.set_attribute("eval.pass", score >= 0.9)

    return {"score": score, "grounded": grounded, "total": len(claims)}
```

## Framework Integration

### Langfuse Scores
```python
from langfuse import Langfuse

langfuse = Langfuse()

# Score a trace
langfuse.score(
    trace_id=trace_id,
    name="helpfulness",
    value=0.85,
    comment="Accurate and complete response",
)

# Score a specific generation
langfuse.score(
    trace_id=trace_id,
    observation_id=generation_id,
    name="factual_accuracy",
    value=1.0,
)
```

### Braintrust Evals
```python
from braintrust import Eval

Eval(
    "agent_quality",
    data=[{"input": q, "expected": a} for q, a in test_cases],
    task=run_agent,
    scores=[
        Factuality(),
        Helpfulness(),
        SafetyCheck(),
    ],
)
```

## Aggregation & Trends

Track quality over time:
```python
# Per-eval run
span.set_attribute("eval.run_id", run_id)
span.set_attribute("eval.test_count", 100)
span.set_attribute("eval.pass_rate", 0.92)
span.set_attribute("eval.avg_score", 0.87)
span.set_attribute("eval.p50_score", 0.89)
span.set_attribute("eval.p10_score", 0.65)

# Comparison to baseline
span.set_attribute("eval.baseline_score", 0.82)
span.set_attribute("eval.improvement", 0.05)
span.set_attribute("eval.regression", False)
```

## Anti-Patterns

- No eval on production data (lab-only testing)
- Missing baseline comparison (can't detect regression)
- Eval without trace linking (can't debug failures)
- Only thumbs up/down (no granular insight)
- No eval versioning (can't compare over time)

## Related Skills
- `human-in-the-loop` - Feedback collection
- `llm-call-tracing` - Generation tracking
