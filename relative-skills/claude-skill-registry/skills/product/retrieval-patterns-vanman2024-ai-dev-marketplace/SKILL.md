---
name: retrieval-patterns
description: Search and retrieval strategies including semantic, hybrid, and reranking for RAG systems. Use when implementing retrieval mechanisms, optimizing search performance, comparing retrieval approaches, or when user mentions semantic search, hybrid search, reranking, BM25, or retrieval optimization.
allowed-tools: Read, Write, Bash, Grep, Glob
---

# Retrieval Patterns

**Purpose:** Provide comprehensive retrieval strategies, benchmarking tools, and implementation templates for building high-performance RAG retrieval systems using LlamaIndex and LangChain.

**Activation Triggers:**
- Implementing semantic search for RAG systems
- Optimizing retrieval performance and relevance
- Comparing different retrieval strategies
- Setting up hybrid search (vector + keyword)
- Implementing reranking mechanisms
- Benchmarking retrieval quality
- Multi-query retrieval patterns
- Conversational retrieval with context

**Key Resources:**
- `scripts/benchmark-retrieval.py` - Performance testing for different retrieval methods
- `scripts/evaluate-retrieval-quality.py` - Quality metrics (precision, recall, MRR, NDCG)
- `templates/semantic-search.py` - Pure vector similarity search
- `templates/hybrid-search.py` - Combined vector + BM25 search
- `templates/reranking.py` - Cross-encoder and LLM-based reranking
- `templates/multi-query-retrieval.py` - Query expansion and fusion
- `examples/conversational-retrieval.py` - Context-aware retrieval
- `examples/metadata-filtering.py` - Filtered retrieval with metadata

## Retrieval Strategy Comparison

### 1. Semantic Search (Vector Only)

**How it works:** Embed query and documents, compute cosine similarity, return top-k matches

**Strengths:**
- Captures semantic meaning and context
- Works well with paraphrasing and synonyms
- Language-agnostic similarity

**Weaknesses:**
- May miss exact keyword matches
- Sensitive to embedding model quality
- Can struggle with rare terms or proper nouns

**When to use:**
- Natural language queries
- Conceptual similarity needed
- Multi-lingual scenarios

**Performance:** ~50-100ms per query (depends on index size)

**Template:** `templates/semantic-search.py`

### 2. Hybrid Search (Vector + BM25)

**How it works:** Combine semantic vector search with keyword-based BM25, merge results using Reciprocal Rank Fusion (RRF)

**Strengths:**
- Best of both worlds (semantic + lexical)
- Better recall than either method alone
- Robust to different query types

**Weaknesses:**
- More complex implementation
- Slightly higher latency
- Requires tuning fusion weights

**When to use:**
- Production RAG systems (recommended default)
- Mixed query types (conceptual + factual)
- When you need high recall

**Performance:** ~100-200ms per query

**Template:** `templates/hybrid-search.py`

**Reciprocal Rank Fusion (RRF) formula:**
```
RRF_score(d) = sum(1 / (k + rank_i(d)))
where k = 60 (constant), rank_i(d) = rank of document d in retriever i
```

### 3. Reranking

**How it works:** Initial retrieval (semantic or hybrid) returns top-k candidates (e.g., 20), then reranker scores all pairs (query, doc) and returns top-n (e.g., 5)

**Strengths:**
- Significantly improves relevance
- Captures query-document interactions
- Can use more powerful models

**Weaknesses:**
- Adds latency (100-500ms depending on reranker)
- Requires additional API calls or compute
- Only improves results within initial candidate set

**When to use:**
- When quality is critical
- Production systems with quality requirements
- After initial hybrid search

**Performance:** +100-500ms additional latency

**Reranker options:**
- **Cross-encoder models** (most accurate): Cohere rerank, sentence-transformers
- **LLM-based** (flexible): GPT-4, Claude with ranking prompts
- **Custom models** (optimized): Fine-tuned for your domain

**Template:** `templates/reranking.py`

### 4. Multi-Query Retrieval

**How it works:** Generate multiple query variations, retrieve for each, deduplicate and fuse results

**Strengths:**
- Increases recall by covering query ambiguity
- Handles different phrasings
- Can improve diversity of results

**Weaknesses:**
- 3-5x more retrieval calls
- Higher latency and cost
- May retrieve less focused results

**When to use:**
- Complex or ambiguous queries
- When single query formulation may miss relevant docs
- Exploration vs. precision use cases

**Performance:** 3-5x base retrieval time

**Template:** `templates/multi-query-retrieval.py`

## Strategy Selection Decision Tree

```
Start
│
├─ Need highest quality? → Use Hybrid + Reranking
│
├─ Budget/latency constrained?
│  ├─ Yes → Semantic Search (simplest, fastest)
│  └─ No → Hybrid Search (best default)
│
├─ Queries are ambiguous/complex? → Multi-Query Retrieval
│
├─ Need exact keyword matches? → Hybrid Search
│
└─ Multilingual or conceptual similarity? → Semantic Search
```

## Benchmarking Framework

### Performance Metrics

**Script:** `scripts/benchmark-retrieval.py`

**Measures:**
- **Latency** (p50, p95, p99)
- **Throughput** (queries per second)
- **Cost** (API calls, compute)

**Usage:**
```bash
python scripts/benchmark-retrieval.py \
  --strategies semantic,hybrid,reranking \
  --queries queries.jsonl \
  --num-runs 100 \
  --output benchmark-results.json
```

**Output:**
```json
{
  "semantic": {
    "latency_p50": 75.2,
    "latency_p95": 120.5,
    "latency_p99": 180.3,
    "throughput": 13.3,
    "cost_per_query": 0.0001
  },
  "hybrid": {
    "latency_p50": 145.8,
    "latency_p95": 220.1,
    "latency_p99": 300.5,
    "throughput": 6.9,
    "cost_per_query": 0.0002
  }
}
```

### Quality Metrics

**Script:** `scripts/evaluate-retrieval-quality.py`

**Measures:**
- **Precision@k**: Percentage of retrieved docs that are relevant
- **Recall@k**: Percentage of relevant docs that were retrieved
- **MRR (Mean Reciprocal Rank)**: 1/rank of first relevant result
- **NDCG (Normalized Discounted Cumulative Gain)**: Graded relevance scoring
- **Hit Rate**: Percentage of queries with at least 1 relevant result

**Usage:**
```bash
python scripts/evaluate-retrieval-quality.py \
  --strategy hybrid \
  --test-set labeled-queries.jsonl \
  --k-values 1,3,5,10 \
  --output quality-metrics.json
```

**Output:**
```json
{
  "precision@5": 0.78,
  "recall@5": 0.65,
  "mrr": 0.72,
  "ndcg@5": 0.81,
  "hit_rate@5": 0.92
}
```

## Implementation Patterns

### Pattern 1: Simple Semantic Search

**Use case:** Prototype, low latency requirements, conceptual queries

**Template:** `templates/semantic-search.py`

**Implementation:**
```python
from llama_index.core import VectorStoreIndex
from llama_index.embeddings.openai import OpenAIEmbedding

# Initialize
embed_model = OpenAIEmbedding(model="text-embedding-3-small")
index = VectorStoreIndex.from_documents(documents, embed_model=embed_model)

# Retrieve
retriever = index.as_retriever(similarity_top_k=5)
results = retriever.retrieve("query")
```

### Pattern 2: Hybrid Search with Ensemble

**Use case:** Production systems, balanced performance/quality

**Template:** `templates/hybrid-search.py`

**Implementation:**
```python
from langchain.retrievers import EnsembleRetriever, BM25Retriever
from langchain_community.vectorstores import FAISS

# Vector retriever
vector_retriever = FAISS.from_documents(docs, embeddings).as_retriever(
    search_kwargs={"k": 10}
)

# BM25 retriever
bm25_retriever = BM25Retriever.from_documents(docs)
bm25_retriever.k = 10

# Ensemble with RRF
ensemble = EnsembleRetriever(
    retrievers=[vector_retriever, bm25_retriever],
    weights=[0.5, 0.5]
)

results = ensemble.get_relevant_documents("query")
```

### Pattern 3: Reranking Pipeline

**Use case:** Quality-critical applications

**Template:** `templates/reranking.py`

**Implementation:**
```python
from llama_index.postprocessor.cohere_rerank import CohereRerank

# Initial retrieval (hybrid recommended)
initial_results = hybrid_retriever.retrieve("query", top_k=20)

# Rerank
reranker = CohereRerank(api_key=api_key, top_n=5)
reranked = reranker.postprocess_nodes(
    initial_results,
    query_str="query"
)

# Use top 5 reranked results
final_results = reranked[:5]
```

### Pattern 4: Multi-Query Fusion

**Use case:** Complex queries, exploration scenarios

**Template:** `templates/multi-query-retrieval.py`

**Implementation:**
```python
from langchain.retrievers import MultiQueryRetriever
from langchain.llms import OpenAI

# Generate query variations
retriever = MultiQueryRetriever.from_llm(
    retriever=base_retriever,
    llm=OpenAI(temperature=0.7)
)

# Automatically generates variations and fuses results
results = retriever.get_relevant_documents("query")
```

## Advanced Patterns

### Conversational Retrieval

**Use case:** Chatbots, multi-turn interactions

**Example:** `examples/conversational-retrieval.py`

**Key features:**
- Chat history compression
- Query rewriting with context
- Follow-up question handling

**Implementation highlights:**
```python
# Rewrite query with conversation context
standalone_query = rewrite_with_history(current_query, chat_history)

# Retrieve with rewritten query
results = retriever.retrieve(standalone_query)
```

### Metadata Filtering

**Use case:** Filtered search, access control, temporal queries

**Example:** `examples/metadata-filtering.py`

**Key features:**
- Pre-filtering before vector search
- Hybrid metadata + semantic filtering
- Dynamic filter construction

**Implementation highlights:**
```python
# Filter by metadata before retrieval
retriever = index.as_retriever(
    similarity_top_k=5,
    filters=MetadataFilters(
        filters=[
            ExactMatchFilter(key="source", value="documentation"),
            DateFilter(key="timestamp", after="2024-01-01")
        ]
    )
)
```

## Optimization Guidelines

### 1. Embedding Model Selection

**Fast & Cheap:**
- OpenAI `text-embedding-3-small` (1536 dim, $0.02/1M tokens)
- Suitable for most use cases

**High Quality:**
- OpenAI `text-embedding-3-large` (3072 dim, $0.13/1M tokens)
- Cohere `embed-english-v3.0` (1024 dim, $0.10/1M tokens)

**Domain-Specific:**
- Fine-tune open-source models (e.g., sentence-transformers)

### 2. Top-K Tuning

**Initial Retrieval:**
- Semantic only: k=5-10
- Hybrid: k=10-20 (for reranking)
- Multi-query: k=3-5 per query

**Final Results:**
- RAG generation: 3-5 chunks typical
- Search results: 10-20 results

### 3. Latency Optimization

**Techniques:**
- Cache embeddings for common queries
- Use approximate nearest neighbor (ANN) indexes
- Async/parallel retrieval for multi-query
- Batch queries when possible

**Target latencies:**
- Semantic: <100ms
- Hybrid: <200ms
- Hybrid + Reranking: <500ms

### 4. Cost Optimization

**Strategies:**
- Use smaller embedding models for development
- Implement query caching
- Batch embedding generation
- Use open-source rerankers when possible

## Testing & Validation

### Benchmarking Workflow

```bash
# 1. Collect test queries
# Create queries.jsonl with representative queries

# 2. Run performance benchmark
python scripts/benchmark-retrieval.py \
  --strategies semantic,hybrid \
  --queries queries.jsonl \
  --num-runs 100

# 3. Run quality evaluation (requires labeled data)
python scripts/evaluate-retrieval-quality.py \
  --strategy hybrid \
  --test-set labeled-queries.jsonl \
  --k-values 3,5,10

# 4. Compare results
# Analyze benchmark-results.json and quality-metrics.json
```

### A/B Testing

**Pattern:**
```python
import random

def retrieve_with_strategy(query, user_id):
    # A/B test: 50% hybrid, 50% semantic
    strategy = "hybrid" if hash(user_id) % 2 == 0 else "semantic"

    if strategy == "hybrid":
        return hybrid_retriever.retrieve(query)
    else:
        return semantic_retriever.retrieve(query)
```

## Common Pitfalls

### 1. Using Only Semantic Search
**Problem:** Misses exact keyword matches
**Solution:** Default to hybrid search for production

### 2. Not Reranking
**Problem:** Initial retrieval may have poor ordering
**Solution:** Add reranking for quality-critical applications

### 3. Wrong Top-K Values
**Problem:** Too few = miss relevant docs, too many = noise
**Solution:** Benchmark with your data (typically 5-10 for final results)

### 4. Ignoring Latency
**Problem:** Multi-query without caching can be slow
**Solution:** Profile each component, optimize critical paths

### 5. No Quality Metrics
**Problem:** Can't measure improvement
**Solution:** Implement evaluation with labeled test set

## Resources

**Scripts:**
- `benchmark-retrieval.py` - Measure latency, throughput, cost
- `evaluate-retrieval-quality.py` - Precision, recall, MRR, NDCG

**Templates:**
- `semantic-search.py` - Vector-only retrieval
- `hybrid-search.py` - Vector + BM25 with RRF
- `reranking.py` - Cross-encoder and LLM reranking
- `multi-query-retrieval.py` - Query expansion and fusion

**Examples:**
- `conversational-retrieval.py` - Chat context handling
- `metadata-filtering.py` - Filtered retrieval

**Documentation:**
- LlamaIndex Retrievers: https://developers.llamaindex.ai/python/framework/understanding/
- LangChain Retrievers: https://python.langchain.com/docs/modules/data_connection/retrievers/
- Hybrid Search Guide: https://python.langchain.com/docs/how_to/hybrid/
- Ensemble Retrievers: https://python.langchain.com/docs/how_to/ensemble_retriever/

---

**Supported Frameworks:** LlamaIndex, LangChain
**Vector Stores:** FAISS, Chroma, Pinecone, Weaviate, Qdrant
**Rerankers:** Cohere, cross-encoders, LLM-based

**Best Practice:** Start with hybrid search, add reranking if quality is critical, benchmark with your data
