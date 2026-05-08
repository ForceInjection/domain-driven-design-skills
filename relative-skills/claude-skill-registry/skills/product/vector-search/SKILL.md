---
name: vector-search
description: Semantic search using vector embeddings and similarity metrics. Apply when implementing search with embeddings (OpenAI, Sentence Transformers) or distance-based ranking. Covers cosine similarity, Euclidean distance, dot product, and threshold selection.
type: skill
version: 1.0.0
---

# Vector Search Skill

Implement semantic search and similarity-based ranking using vector embeddings.

## What This Skill Provides

- **Similarity Metrics**: Cosine similarity, Euclidean distance, dot product
- **Range Understanding**: Mathematical domains for each metric
- **Threshold Selection**: Setting appropriate minScore/maxDistance values
- **Implementation Patterns**: Database queries, filtering, ranking

## When to Use

- Implementing semantic search (text, images, audio)
- Ranking results by similarity to query
- Recommendation systems (find similar items)
- Clustering or classification based on embeddings
- When user mentions: "vector search", "embeddings", "similarity", "semantic search"

## Primitives Included

- **Instructions**: `similarity-metrics.instructions.md` - Metric selection and threshold guidance
- **Instructions**: `embedding-integration.instructions.md` - OpenAI, Sentence Transformers patterns

## Key Concepts

### Similarity Metrics Cheat Sheet

| Metric | Range | When to Use |
|--------|-------|-------------|
| Cosine Similarity | [-1, 1] | Text embeddings, direction matters |
| Euclidean Distance | [0, ∞) | Spatial data, magnitude matters |
| Dot Product | (-∞, ∞) | Raw similarity, not normalized |
| Jaccard Similarity | [0, 1] | Set overlap, binary features |

### Critical: Understand the Range

**Most common bug**: Setting `minScore=0` for cosine similarity and filtering out valid negative scores.

**Example**:
```typescript
// ❌ Wrong - filters out negative scores
function search(embedding, minScore = 0) {
  return results.filter(r => r.score >= minScore); 
  // Cosine can be negative!
}

// ✅ Correct - includes full range
function search(embedding, minScore = -1) {
  return results.filter(r => r.score >= minScore);
  // -1 to 1 for cosine similarity
}
```

## Example: Semantic Bird Search

```typescript
// Generate embedding for query
const queryEmbedding = await openai.embeddings.create({
  model: 'text-embedding-3-small',
  input: 'red bird with black wings'
});

// Search with cosine similarity
const results = await db.query(`
  SELECT 
    id,
    name,
    1 - (embedding <=> $1) as similarity
  FROM birds
  WHERE 1 - (embedding <=> $1) >= $2
  ORDER BY similarity DESC
  LIMIT 10
`, [queryEmbedding.data[0].embedding, 0.3]);
```

**Note**: PostgreSQL pgvector uses `<=>` for cosine distance (0 to 2), so `1 - distance` gives similarity (-1 to 1).

## Dependencies

- Database: SQLite with BLOB, PostgreSQL with pgvector, or specialized vector DB
- Embedding Model: OpenAI API, Sentence Transformers, or custom model
- Math Library: For similarity calculations if not database-native

---

**Related Skills**: `fullstack-expertise`, `claude-framework` (E-1 validation)
