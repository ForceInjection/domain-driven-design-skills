---
name: run-benchmark
description: Run and interpret the File API vs Inline benchmark for Gemini performance testing. Use when discussing performance optimization, caching strategies, or comparing document upload approaches.
allowed-tools:
  - Bash
  - Read
---

# Run Benchmark Tool

## Purpose
Compare Gemini File API vs Inline document approaches for performance.

## What It Tests

1. **File API**: Upload documents once, reuse cached URIs for multiple queries
2. **Inline**: Send raw document bytes with each request

The benchmark shuffles document order each round to prevent Gemini's native caching from affecting results.

## Running the Benchmark

### Basic Usage
```bash
export GEMINI_API_KEY="your-key"
make build
./bin/benchmark -docs test_loan_files/loan_file_1_LN-2024-001847
```

### With Options
```bash
./bin/benchmark \
  -docs /path/to/documents \
  -rounds 20 \
  -max-docs 10 \
  -json
```

### CLI Flags
```
-docs string      Directory containing documents (required)
-rounds int       Number of test rounds per method (default 10)
-max-docs int     Maximum income documents to use (default 6)
-json             Output results as JSON
-income           Only use income documents (default true)
```

### Using Makefile
```bash
make benchmark DOCS=test_loan_files/loan_file_1_LN-2024-001847 ROUNDS=10
```

## Understanding Results

### Output Structure
```
PHASE 1: INLINE DOCUMENTS
  Round 1: [shuffled order] -> time, tokens
  ...

PHASE 2: FILE API
  Upload: X seconds (one-time)
  Round 1: [shuffled order] -> time, tokens
  ...

FINAL COMPARISON
  - Total time comparison
  - Average per-query time
  - Token usage
  - Winner & speedup factor
  - Break-even analysis
```

### Key Metrics

| Metric | Meaning |
|--------|---------|
| Upload time | One-time cost for File API |
| Total time | Sum of all operations |
| Avg per round | Mean time per query |
| Min/Max round | Query time variance |
| Speedup | How much faster winner is |
| Break-even | Queries needed for File API to win |

### Interpreting Results

**File API wins when:**
- Many queries against same documents
- Break-even point is low (< 10 queries)
- Per-query savings compound

**Inline wins when:**
- Few queries (< break-even)
- Different documents each time
- Simplicity preferred

## Example Output
```
TIMING COMPARISON
┌─────────────────┬──────────────────┬──────────────────┐
│ Metric          │ File API         │ Inline Docs      │
├─────────────────┼──────────────────┼──────────────────┤
│ Upload (1x)     │           1.976s │              N/A │
│ Total time      │        1m13.733s │        1m14.454s │
│ Avg per round   │           7.176s │           7.445s │
└─────────────────┴──────────────────┴──────────────────┘

BREAK-EVEN ANALYSIS
   Upload overhead:      1.976s
   Savings per query:    270ms
   Break-even at:        7.3 queries
```

## Why Shuffled Order?

Documents are shuffled each round because:
- Gemini may cache based on content/order
- Shuffling ensures each query is "fresh"
- Gives accurate per-query timing
- More realistic for production workloads

## Test Questions

The benchmark uses varied income-related questions:
- Annual/monthly income extraction
- Employer information
- YTD income calculation
- Deductions and withholdings
- Income source classification
- Tax year coverage
- And more...

## Recommendations

| Scenario | Recommendation |
|----------|----------------|
| Underwriter iterating on loan | File API |
| One-off document analysis | Inline |
| Batch processing same docs | File API |
| Real-time different docs | Inline |

## Related Files
- `cmd/benchmark/main.go` - Benchmark implementation
- `internal/gemini/client.go` - Both API approaches
- `internal/gemini/cache.go` - File caching logic
