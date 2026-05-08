---
name: gemini-batch
description: This skill should be used when the user asks to "use Gemini Batch API", "process documents at scale", "submit a batch job", "upload files to Gemini", or needs large-scale LLM processing. Includes production gotchas and best practices.
---

# Gemini Batch API Skill

Large-scale asynchronous document processing using Google's Gemini models.

## When to Use

- Process thousands of documents with the same prompt
- Cost-effective bulk extraction (50% cheaper than synchronous API)
- Jobs that can tolerate 24-hour completion windows

## Quick Start

```python
from examples.batch_processor import GeminiBatchProcessor

processor = GeminiBatchProcessor(
    bucket_name="my-batch-bucket",  # Must be in us-central1
    model="gemini-2.0-flash-lite"
)

results = processor.run_pipeline(
    input_dir="./documents",
    prompt="Extract as JSON: {title, date, summary}",
    output_dir="./results"
)
```

## Core Workflow

1. **Upload files** to GCS bucket (us-central1 region required)
2. **Create JSONL** request file with document URIs and prompts
3. **Submit batch job** via `genai.batches.create()`
4. **Poll for completion** (jobs expire after 24 hours)
5. **Download and parse** results from output URI
6. **Handle failures** gracefully (partial failures are common)

## Key Gotchas

| Issue | Solution |
|-------|----------|
| Region mismatch | Use `us-central1` bucket only |
| Wrong URI format | Use `gs://` not `https://` |
| Invalid JSONL | Use `scripts/validate_jsonl.py` |
| Duplicate IDs | Hash file content + prompt for unique IDs |
| Large PDFs fail | Split at 50 pages / 50MB max |
| JSON parsing fails | Use robust extraction (see gotchas.md) |
| Output not found | Output URI is prefix, not file path |

See `references/gotchas.md` for detailed solutions.

## Rate Limits

| Limit | Value |
|-------|-------|
| Max requests per JSONL | 10,000 |
| Max concurrent jobs | 10 |
| Max job size | 100MB |
| Job expiration | 24 hours |

## Recommended Models

| Model | Use Case | Cost |
|-------|----------|------|
| `gemini-2.0-flash-lite` | Most batch jobs | Lowest |
| `gemini-2.0-flash` | Complex extraction | Medium |
| `gemini-1.5-pro` | Highest accuracy | Highest |

## Additional Resources

### References
- `references/gotchas.md` - 9 critical production gotchas with solutions
- `references/best-practices.md` - Idempotent IDs, state tracking, validation
- `references/troubleshooting.md` - Common errors and debugging
- `references/vertex-ai.md` - Enterprise alternative with comparison
- `references/cli-reference.md` - gsutil and gcloud commands

### Examples
- `examples/batch_processor.py` - Complete GeminiBatchProcessor class
- `examples/pipeline_template.py` - Customizable pipeline template

### Scripts
- `scripts/validate_jsonl.py` - Validate JSONL before submission
- `scripts/test_single.py` - Test single request before batch

## External Documentation

- [Gemini Batch API Guide](https://ai.google.dev/gemini-api/docs/batch)
- [Google Cloud Storage](https://cloud.google.com/python/docs/reference/storage/latest)
- [Vertex AI Batch Prediction](https://cloud.google.com/vertex-ai/docs/predictions/batch-predictions)
