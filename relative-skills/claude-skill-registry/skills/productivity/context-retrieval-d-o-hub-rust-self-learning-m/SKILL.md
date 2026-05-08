---
name: context-retrieval
description: Retrieve relevant episodic context from memory for informed decision-making. Use when you need past episodes, patterns, or solutions to similar tasks.
---

# Context Retrieval

Retrieve relevant episodic context from memory for informed decision-making.

## Purpose
Find and return the most relevant past episodes and patterns to inform current task execution.

## Retrieval Methods

### 1. Semantic Search (Preferred)
When embedding service is configured, use vector similarity:

```rust
let context = memory
    .retrieve_relevant_context(
        "implement async batch updates",
        task_context,
        limit: 5
    )
    .await?;
```

**Advantages**:
- Finds semantically similar tasks
- Better recall for novel queries
- Captures intent beyond keywords

**Requirements**:
- Embedding service configured
- Embeddings computed for episodes
- Vector index built

### 2. Keyword/Index Search (Fallback)
When embeddings unavailable, use SQL indexes:

```rust
// Search by task_type and tags
SELECT * FROM episodes
WHERE task_type = ?
  AND tags LIKE '%' || ? || '%'
ORDER BY timestamp DESC
LIMIT ?;
```

**Advantages**:
- Fast, no embedding computation
- Works without external services
- Deterministic results

**Limitations**:
- Misses semantic similarity
- Requires exact tag matches
- Vocabulary mismatch issues

## Retrieval Strategy

1. **Parse query**: Extract key terms, domain, task type
2. **Check embedding availability**: Prefer semantic if available
3. **Query storage**:
   - Try redb cache first (fast)
   - Fall back to Turso if cache miss
4. **Rank results**: By relevance score or recency
5. **Filter and limit**: Apply filters, return top-N
6. **Format context**: Structure for consumption

## Context Filtering

### By Domain
```rust
let context = TaskContext {
    domain: "storage".to_string(),
    ..Default::default()
};
```
Returns only episodes in the "storage" domain.

### By Task Type
```rust
// Find similar implementation tasks
task_type_filter: Some("implementation")
```

### By Recency
```rust
// Last 30 days only
since: Some(now - Duration::days(30))
```

### By Success
```rust
// Only successful episodes
verdict: Some(Verdict::Success)
```

## Result Ranking

### Semantic (Embedding-based)
1. Compute query embedding
2. Calculate cosine similarity with stored embeddings
3. Sort by similarity score (descending)
4. Return top-N

### Index-based
1. Exact match on task_type (highest priority)
2. Tag overlap count
3. Recency (timestamp DESC)
4. Success rate

## Response Format

```rust
pub struct RetrievedContext {
    pub episodes: Vec<EpisodeSummary>,
    pub patterns: Vec<Pattern>,
    pub heuristics: Vec<Heuristic>,
    pub relevance_scores: Vec<f32>,
}

pub struct EpisodeSummary {
    pub id: String,
    pub task_description: String,
    pub verdict: Verdict,
    pub key_steps: Vec<String>,
    pub reflection: String,
    pub artifacts: Vec<String>,
    pub relevance: f32,
}
```

## Usage Examples

### Retrieve for Similar Task
```rust
let query = "fix failing async test with Tokio runtime";
let context = TaskContext {
    language: "rust".to_string(),
    domain: "testing".to_string(),
    tags: vec!["tokio".to_string(), "async".to_string()],
};

let retrieved = memory
    .retrieve_relevant_context(query, context, 10)
    .await?;

// Use retrieved context to inform approach
for episode in retrieved.episodes {
    println!("Similar task: {}", episode.task_description);
    println!("Outcome: {:?}", episode.verdict);
    println!("Key insight: {}", episode.reflection);
}
```

### Retrieve Patterns for Code Generation
```rust
// Find common tool sequences for storage implementation
let patterns = memory
    .get_patterns_by_type("ToolSequence")
    .filter(|p| p.domain == "storage")
    .await?;

// Apply learned patterns
for pattern in patterns {
    if pattern.success_rate > 0.8 {
        println!("Recommended approach: {:?}", pattern.sequence);
    }
}
```

### Retrieve Error Solutions
```rust
// Find how similar errors were resolved
let query = "error: cannot borrow as mutable while immutable borrow exists";
let solutions = memory
    .retrieve_error_resolutions(query, 5)
    .await?;

for solution in solutions {
    println!("Resolution: {}", solution.fix);
    println!("Success rate: {}", solution.success_rate);
}
```

## Performance Optimization

### Cache Frequently Queried Context
- Keep hot patterns in memory
- Cache common query results
- Use LRU eviction policy

### Limit Result Size
- Return summaries, not full episodes
- Paginate large result sets
- Stream results when possible

### Index Optimization
- Compound indexes on (task_type, timestamp)
- Tag GIN/JSONB indexes for flexible filtering
- Regularly update statistics

## Embedding Service Configuration

```toml
[embedding]
enabled = true
provider = "openai"  # or "local", "huggingface"
model = "text-embedding-3-small"
cache_embeddings = true
batch_size = 32
```

## Troubleshooting

**Low recall**:
- Check embeddings are computed
- Verify task_type is set correctly
- Expand tag vocabulary
- Increase limit parameter

**Slow retrieval**:
- Check redb cache is populated
- Verify indexes exist and are used
- Monitor Turso latency
- Consider smaller result sets

**Poor relevance**:
- Use semantic search if available
- Improve query descriptions
- Add more context tags
- Filter by domain/task type

## Monitoring Metrics

- Retrieval latency (p50, p95, p99)
- Cache hit rate
- Embedding computation time
- Result relevance scores
- Query patterns (for optimization)
