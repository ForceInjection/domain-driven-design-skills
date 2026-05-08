---
name: evaluating-rag
description: Evaluate RAG systems with hit rate, MRR, faithfulness metrics and compare retrieval strategies. Use when testing retrieval quality, generating evaluation datasets, comparing embeddings or retrievers, A/B testing, or measuring production RAG performance.
---

# Evaluating RAG Systems

Guide for measuring RAG performance, comparing strategies, and implementing continuous evaluation. Focus on key metrics and practical testing approaches.

## When to Use This Skill

- Testing retrieval quality and accuracy
- Generating evaluation datasets for your domain
- Comparing different retrieval strategies (vector vs BM25 vs hybrid)
- A/B testing embedding models or rerankers
- Measuring production RAG performance
- Validating improvements after optimizations
- Comparing your 7 retrieval strategies in `src/` or `src-iLand/`

## Key Evaluation Metrics

### Retrieval Metrics

**Hit Rate**: Fraction of queries where correct answer found in top-k
- **Perfect**: 1.0 (all queries found relevant docs)
- **Good**: 0.85+ (85%+ queries successful)
- **Needs work**: <0.70

**MRR (Mean Reciprocal Rank)**: Quality of ranking
- **Perfect**: 1.0 (relevant doc always rank 1)
- **Good**: 0.80+ (relevant doc typically in top 2-3)
- **Formula**: Average of 1/rank across queries

### Response Metrics

**Faithfulness**: No hallucinations, grounded in context
**Correctness**: Factually accurate vs reference answer
**Relevancy**: Directly addresses the query

## Quick Decision Guide

### When to Evaluate
- **After implementing** → Baseline performance
- **After optimization** → Validate improvements
- **Before production** → Quality gate
- **In production** → Continuous monitoring

### What to Measure
- **Development** → Hit rate + MRR (retrieval quality)
- **Production** → All metrics (retrieval + response quality)
- **A/B testing** → Comparative metrics

### Dataset Size
- **Quick test** → 20-50 Q&A pairs
- **Thorough eval** → 100-200 pairs
- **Production** → 500+ pairs

## Quick Start Patterns

### Pattern 1: Basic Retrieval Evaluation

```python
from llama_index.core.evaluation import RetrieverEvaluator

# Create evaluator
evaluator = RetrieverEvaluator.from_metric_names(
    ["mrr", "hit_rate"],
    retriever=retriever
)

# Run evaluation
eval_results = await evaluator.aevaluate_dataset(qa_dataset)

print(f"Hit Rate: {eval_results['hit_rate']:.3f}")
print(f"MRR: {eval_results['mrr']:.3f}")
```

### Pattern 2: Generate Evaluation Dataset

```python
from llama_index.core.evaluation import generate_question_context_pairs
from llama_index.llms.openai import OpenAI

# Generate Q&A pairs from your documents
llm = OpenAI(model="gpt-4o-mini")
qa_dataset = generate_question_context_pairs(
    nodes,
    llm=llm,
    num_questions_per_chunk=2
)

# Filter invalid entries
qa_dataset = filter_qa_dataset(qa_dataset)

# Save for reuse
qa_dataset.save_json("evaluation_dataset.json")
```

### Pattern 3: Compare Multiple Strategies

```python
strategies = {
    "vector": vector_retriever,
    "bm25": bm25_retriever,
    "hybrid": hybrid_retriever,
    "metadata": metadata_retriever,
}

results = {}
for strategy_name, retriever in strategies.items():
    evaluator = RetrieverEvaluator.from_metric_names(
        ["mrr", "hit_rate"],
        retriever=retriever
    )
    eval_result = await evaluator.aevaluate_dataset(qa_dataset)
    results[strategy_name] = eval_result
    print(f"{strategy_name}: {eval_result}")

# Find best strategy
best_strategy = max(results, key=lambda x: results[x]['hit_rate'])
print(f"\nBest strategy: {best_strategy}")
```

### Pattern 4: Compare With/Without Reranking

```python
# Without reranking
retriever_no_rerank = index.as_retriever(similarity_top_k=5)

# With reranking
from llama_index.postprocessor.cohere_rerank import CohereRerank
retriever_with_rerank = index.as_retriever(
    similarity_top_k=10,
    node_postprocessors=[CohereRerank(top_n=5)]
)

# Evaluate both
for name, retriever in [("No Rerank", retriever_no_rerank),
                        ("With Rerank", retriever_with_rerank)]:
    evaluator = RetrieverEvaluator.from_metric_names(
        ["mrr", "hit_rate"],
        retriever=retriever
    )
    results = await evaluator.aevaluate_dataset(qa_dataset)
    print(f"{name}: Hit Rate={results['hit_rate']:.3f}, MRR={results['mrr']:.3f}")

# Calculate improvement
improvement = (rerank_results['hit_rate'] - no_rerank_results['hit_rate']) / no_rerank_results['hit_rate']
print(f"Improvement: {improvement * 100:.1f}%")
```

### Pattern 5: Response Quality Evaluation

```python
from llama_index.core.evaluation import (
    FaithfulnessEvaluator,
    RelevancyEvaluator
)

# Initialize evaluators
faithfulness_evaluator = FaithfulnessEvaluator()
relevancy_evaluator = RelevancyEvaluator()

# Generate response
response = query_engine.query("What is machine learning?")

# Evaluate faithfulness (no hallucinations)
faithfulness_result = faithfulness_evaluator.evaluate_response(
    response=response
)
print(f"Faithfulness: {faithfulness_result.passing}")

# Evaluate relevancy
relevancy_result = relevancy_evaluator.evaluate_response(
    query="What is machine learning?",
    response=response
)
print(f"Relevancy: {relevancy_result.passing}")
```

## Your Codebase Integration

### For `src/` Pipeline (7 Strategies)

**Compare All Strategies**:
```python
strategies = {
    "vector": "src/10_basic_query_engine.py",
    "summary": "src/11_document_summary_retriever.py",
    "recursive": "src/12_recursive_retriever.py",
    "metadata": "src/14_metadata_filtering.py",
    "chunk_decoupling": "src/15_chunk_decoupling.py",
    "hybrid": "src/16_hybrid_search.py",
    "planner": "src/17_query_planning_agent.py",
}

# Create evaluation framework to compare all 7
```

**Baseline Performance**:
1. Generate Q&A dataset from your documents
2. Evaluate each strategy
3. Identify best performer
4. Use as baseline for improvements

### For `src-iLand/` Pipeline (Thai Land Deeds)

**Thai-Specific Evaluation**:
```python
# Generate Thai Q&A pairs
llm = OpenAI(model="gpt-4o-mini")  # Supports Thai
qa_dataset = generate_question_context_pairs(
    thai_nodes,
    llm=llm,
    num_questions_per_chunk=2
)

# Test with Thai queries
thai_queries = [
    "โฉนดที่ดินในกรุงเทพ",  # Land deeds in Bangkok
    "นส.3 คืออะไร",  # What is NS.3
    "ที่ดินในสมุทรปราการ"  # Land in Samut Prakan
]
```

**Router Evaluation** (`src-iLand/retrieval/router.py`):
- Test index classification accuracy
- Test strategy selection appropriateness
- Measure end-to-end performance

**Fast Metadata Testing**:
- Validate <50ms response time
- Test filtering accuracy
- Compare with/without fast indexing

## Detailed References

Load these when you need comprehensive details:

- **reference-metrics.md**: Complete evaluation guide
  - All metrics (hit rate, MRR, faithfulness, correctness)
  - Dataset generation techniques
  - A/B testing frameworks
  - Production monitoring
  - Statistical significance testing

- **reference-agents.md**: Advanced techniques
  - Agents (FunctionAgent, ReActAgent)
  - Multi-agent systems
  - Query engines (Router, SubQuestion)
  - Workflow orchestration
  - Observability and debugging

## Common Workflows

### Workflow 1: Create Evaluation Dataset

- [ ] **Step 1**: Prepare representative documents
  - Sample from different categories
  - Include edge cases

- [ ] **Step 2**: Generate Q&A pairs
  ```python
  qa_dataset = generate_question_context_pairs(
      nodes, llm=llm, num_questions_per_chunk=2
  )
  ```

- [ ] **Step 3**: Filter invalid entries
  - Remove auto-generated artifacts
  - Load `reference-metrics.md` for filtering code

- [ ] **Step 4**: Manual review (optional)
  - Check 10-20 samples
  - Ensure question quality

- [ ] **Step 5**: Save for reuse
  ```python
  qa_dataset.save_json("eval_dataset.json")
  ```

### Workflow 2: Compare Retrieval Strategies

- [ ] **Step 1**: Load evaluation dataset
  ```python
  from llama_index.core.llama_dataset import LabelledRagDataset
  qa_dataset = LabelledRagDataset.from_json("eval_dataset.json")
  ```

- [ ] **Step 2**: Define strategies to compare
  - List all retrievers to test
  - For `src/`: All 7 strategies
  - For `src-iLand/`: Router + individual strategies

- [ ] **Step 3**: Run evaluation for each
  ```python
  for name, retriever in strategies.items():
      results[name] = evaluate(retriever, qa_dataset)
  ```

- [ ] **Step 4**: Compare results
  - Identify best hit rate
  - Identify best MRR
  - Consider trade-offs (latency, cost)

- [ ] **Step 5**: Document findings
  - Record baseline performance
  - Note best strategies for different query types

### Workflow 3: A/B Test an Optimization

- [ ] **Step 1**: Measure baseline
  ```python
  baseline_results = evaluate(current_retriever, qa_dataset)
  ```

- [ ] **Step 2**: Apply optimization
  - Add reranking
  - Change embedding model
  - Adjust chunk size
  - etc.

- [ ] **Step 3**: Measure optimized version
  ```python
  optimized_results = evaluate(optimized_retriever, qa_dataset)
  ```

- [ ] **Step 4**: Calculate improvement
  ```python
  improvement = (optimized - baseline) / baseline * 100
  print(f"Hit Rate improvement: {improvement:.1f}%")
  ```

- [ ] **Step 5**: Decide based on data
  - If improvement > 5%: Deploy
  - If improvement < 2%: Consider cost/complexity
  - If negative: Rollback

### Workflow 4: Production Monitoring

- [ ] **Step 1**: Create production evaluation set
  - Sample real user queries
  - Include ground truth when available

- [ ] **Step 2**: Set up continuous evaluation
  ```python
  class ProductionEvaluator:
      def evaluate_query(self, query, response):
          # Log metrics
          # Track over time
  ```

- [ ] **Step 3**: Define alerts
  - Hit rate < 0.80 → Alert
  - MRR < 0.70 → Alert
  - Latency p95 > 2s → Alert

- [ ] **Step 4**: Monitor trends
  - Daily/weekly metrics
  - Detect degradation early

- [ ] **Step 5**: Iterate based on data
  - Identify failure patterns
  - Generate new test cases
  - Improve weak areas

### Workflow 5: Evaluate All 7 Strategies (src/)

- [ ] **Step 1**: Generate comprehensive dataset
  - Cover different query types
  - Factual, summarization, comparison

- [ ] **Step 2**: Run each strategy
  ```bash
  python src/10_basic_query_engine.py  # Vector
  python src/11_document_summary_retriever.py  # Summary
  python src/12_recursive_retriever.py  # Recursive
  python src/14_metadata_filtering.py  # Metadata
  python src/15_chunk_decoupling.py  # Chunk decoupling
  python src/16_hybrid_search.py  # Hybrid
  python src/17_query_planning_agent.py  # Planner
  ```

- [ ] **Step 3**: Collect metrics
  - Hit rate for each
  - MRR for each
  - Latency for each

- [ ] **Step 4**: Create comparison table
  | Strategy | Hit Rate | MRR | Latency | Use Case |
  |----------|----------|-----|---------|----------|
  | Vector | ... | ... | ... | General |
  | Hybrid | ... | ... | ... | Best overall |
  | ... | ... | ... | ... | ... |

- [ ] **Step 5**: Document recommendations
  - Best for factual queries
  - Best for complex queries
  - Best for production (speed + quality)

## Evaluation Metrics Reference

### Hit Rate Interpretation
- **1.0** → Perfect (all queries successful)
- **0.90+** → Excellent
- **0.80-0.89** → Good
- **0.70-0.79** → Acceptable
- **<0.70** → Needs improvement

### MRR Interpretation
- **1.0** → Perfect ranking (relevant doc always #1)
- **0.85+** → Excellent (relevant doc typically #1 or #2)
- **0.70-0.84** → Good
- **0.50-0.69** → Acceptable
- **<0.50** → Poor ranking quality

### Latency Targets
- **<100ms** → Excellent
- **100-500ms** → Good
- **500ms-1s** → Acceptable
- **>1s** → Needs optimization

## Performance Benchmarks

### Embedding Model Comparison (from reference docs)
| Embedding | Reranker | Hit Rate | MRR |
|-----------|----------|----------|-----|
| JinaAI Base | bge-reranker-large | 0.938 | 0.869 |
| JinaAI Base | CohereRerank | 0.933 | 0.874 |
| OpenAI | CohereRerank | 0.927 | 0.866 |
| OpenAI | bge-reranker-large | 0.910 | 0.856 |

### Typical Improvements
- **Adding reranking**: +5-15% hit rate
- **Hybrid vs vector**: +3-8% hit rate
- **Optimal chunk size**: +2-5% hit rate
- **Better embeddings**: +3-10% hit rate

## Scripts

This skill includes utility scripts in the `scripts/` directory:

### generate_qa_dataset.py
Generate evaluation Q&A pairs from documents:
```bash
python .claude/skills/evaluating-rag/scripts/generate_qa_dataset.py \
    --documents-dir ./data \
    --output eval_dataset.json \
    --num-questions-per-chunk 2
```

### compare_retrievers.py
Compare multiple retrieval strategies:
```bash
python .claude/skills/evaluating-rag/scripts/compare_retrievers.py \
    --dataset eval_dataset.json \
    --strategies vector,bm25,hybrid \
    --output comparison_results.json
```

Outputs:
- Hit rate and MRR for each strategy
- Performance comparison table
- Recommendations

### run_evaluation.py
Run comprehensive evaluation:
```bash
python .claude/skills/evaluating-rag/scripts/run_evaluation.py \
    --retriever-config config.yaml \
    --dataset eval_dataset.json \
    --metrics hit_rate,mrr,faithfulness
```

Reports:
- All requested metrics
- Per-query breakdown
- Summary statistics

## Key Reminders

**Dataset Quality**:
- Generate from your actual documents
- Include diverse query types
- Filter invalid auto-generated entries
- Manual review recommended for critical domains

**Evaluation Best Practices**:
- Start with baseline (before optimization)
- Test one change at a time (for clear attribution)
- Use same dataset for comparisons
- Statistical significance matters (>5% improvement)

**Production Monitoring**:
- Continuous evaluation on sample queries
- Track trends over time
- Alert on degradation
- Regular dataset refresh

**For Your Pipelines**:
- `src/`: Compare all 7 strategies systematically
- `src-iLand/`: Test with Thai queries and metadata
- Both: Establish baselines before optimizations

## Next Steps

After evaluation:
- **Optimize**: Use `optimizing-rag` skill to improve low scores
- **Implement**: Use `implementing-rag` skill to rebuild weak components
- **Monitor**: Set up continuous evaluation in production
- **Iterate**: Regular evaluation → optimization → re-evaluation cycle
