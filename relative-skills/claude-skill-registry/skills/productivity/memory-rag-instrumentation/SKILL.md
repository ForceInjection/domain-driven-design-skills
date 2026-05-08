---
name: memory-rag-instrumentation
description: Instrument RAG retrieval, memory operations, and context management
triggers:
  - "RAG tracing"
  - "retrieval instrumentation"
  - "vector search observability"
  - "memory tracking"
  - "context window"
priority: 2
---

# Memory and RAG Instrumentation

Instrument retrieval-augmented generation and memory operations for quality debugging.

## Core Principle

RAG observability answers:
1. **What was retrieved?** (sources, scores)
2. **Was it relevant?** (quality signals)
3. **How much context** was used?
4. **Did retrieval affect** the response?

## Retrieval Span Attributes

```python
# Required (P0)
span.set_attribute("retrieval.source", "vector_store")
span.set_attribute("retrieval.query_length", 150)
span.set_attribute("retrieval.results_count", 5)
span.set_attribute("retrieval.latency_ms", 45)

# Quality signals (P1)
span.set_attribute("retrieval.top_score", 0.89)
span.set_attribute("retrieval.avg_score", 0.72)
span.set_attribute("retrieval.min_score", 0.55)
span.set_attribute("retrieval.above_threshold", 4)  # Count above relevance threshold

# Context usage (P1)
span.set_attribute("retrieval.tokens_retrieved", 2500)
span.set_attribute("retrieval.tokens_used", 2000)  # After truncation
span.set_attribute("retrieval.context_window_pct", 0.25)  # % of context window

# Source tracking (P2)
span.set_attribute("retrieval.sources", ["doc1.pdf", "doc2.pdf"])
span.set_attribute("retrieval.collection", "knowledge_base")
```

## Retrieval Pipeline Stages

### Query Processing
```python
with tracer.start_span("retrieval.query_process") as span:
    span.set_attribute("query.original_length", len(query))
    span.set_attribute("query.expanded", bool(expansion))
    span.set_attribute("query.rewritten", bool(rewrite))
    # Process query
```

### Vector Search
```python
with tracer.start_span("retrieval.vector_search") as span:
    span.set_attribute("vector.index", "main_index")
    span.set_attribute("vector.k", 10)
    span.set_attribute("vector.ef_search", 100)  # HNSW param
    span.set_attribute("vector.distance_metric", "cosine")
    # Execute search
```

### Reranking
```python
with tracer.start_span("retrieval.rerank") as span:
    span.set_attribute("rerank.model", "cohere-rerank-v3")
    span.set_attribute("rerank.input_count", 10)
    span.set_attribute("rerank.output_count", 5)
    span.set_attribute("rerank.score_improvement", 0.15)
    # Rerank results
```

### Context Assembly
```python
with tracer.start_span("retrieval.context_assembly") as span:
    span.set_attribute("context.chunks_selected", 5)
    span.set_attribute("context.total_tokens", 2500)
    span.set_attribute("context.max_tokens", 4000)
    span.set_attribute("context.truncated", False)
    # Assemble context
```

## Memory Operations

### Short-term Memory (Conversation)
```python
span.set_attribute("memory.type", "conversation")
span.set_attribute("memory.messages_stored", 10)
span.set_attribute("memory.tokens_stored", 3500)
span.set_attribute("memory.window_size", 20)
span.set_attribute("memory.pruned_count", 5)
```

### Long-term Memory (Persistent)
```python
span.set_attribute("memory.type", "persistent")
span.set_attribute("memory.operation", "write")  # read, write, delete
span.set_attribute("memory.key", "user_preferences")
span.set_attribute("memory.store", "redis")
span.set_attribute("memory.ttl_seconds", 86400)
```

### Episodic Memory
```python
span.set_attribute("memory.type", "episodic")
span.set_attribute("memory.episode_id", "session_123")
span.set_attribute("memory.events_count", 15)
span.set_attribute("memory.summary_generated", True)
```

## Quality Signals

Track signals that indicate retrieval quality:

```python
# Relevance scoring
span.set_attribute("quality.relevance_score", 0.85)
span.set_attribute("quality.coverage_score", 0.70)  # How well query is covered
span.set_attribute("quality.diversity_score", 0.60)  # Source diversity

# Failure signals
span.set_attribute("quality.no_results", False)
span.set_attribute("quality.below_threshold", 2)  # Count below threshold
span.set_attribute("quality.fallback_used", False)
```

## Framework Integration

### LangChain Retrievers
```python
from langchain.retrievers import VectorStoreRetriever
from langfuse.decorators import observe

@observe(name="retrieval.search")
def search_documents(query: str, k: int = 5):
    span = get_current_span()

    results = retriever.get_relevant_documents(query)

    span.set_attribute("retrieval.query_length", len(query))
    span.set_attribute("retrieval.results_count", len(results))
    span.set_attribute("retrieval.top_score", results[0].metadata.get("score", 0))

    return results
```

### LlamaIndex
```python
from llama_index.core import VectorStoreIndex
from langfuse.decorators import observe

@observe(name="retrieval.query")
def query_index(query: str):
    response = index.as_query_engine().query(query)

    span = get_current_span()
    span.set_attribute("retrieval.source_nodes", len(response.source_nodes))

    return response
```

## Context Window Management

Track context usage to avoid truncation issues:

```python
MODEL_CONTEXT_LIMITS = {
    "claude-3-opus": 200_000,
    "claude-3-5-sonnet": 200_000,
    "gpt-4-turbo": 128_000,
    "gpt-4o": 128_000,
}

def track_context_usage(model: str, tokens_used: int):
    limit = MODEL_CONTEXT_LIMITS.get(model, 100_000)
    pct = tokens_used / limit

    span.set_attribute("context.tokens_used", tokens_used)
    span.set_attribute("context.limit", limit)
    span.set_attribute("context.utilization_pct", round(pct, 2))
    span.set_attribute("context.near_limit", pct > 0.8)
```

## Anti-Patterns

- Logging full retrieved documents (storage explosion)
- Missing relevance scores (can't debug quality)
- No reranking metrics (hidden quality drop)
- Ignoring context window usage (truncation bugs)

## Related Skills
- `llm-call-tracing` - LLM instrumentation
- `evaluation-quality` - Quality metrics
