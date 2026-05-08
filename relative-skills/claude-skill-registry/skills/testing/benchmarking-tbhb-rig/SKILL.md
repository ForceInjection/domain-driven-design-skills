---
name: benchmarking
description: Performance benchmarking practices using pytest-benchmark. Activated when working with benchmarks, performance testing, or optimization.
---

# Benchmarking

## Purpose

Guide for performance benchmarking using pytest-benchmark. Covers benchmark design, execution, comparison, and regression detection.

## When to use

This skill activates when:

- Writing performance benchmarks
- Measuring execution time
- Comparing performance between versions
- Detecting performance regressions
- Optimizing critical paths

## Core principles

### Measure, don't guess

- NEVER optimize without benchmarking first
- Establish baselines before making changes
- Verify improvements with data

### Benchmark design

- Test realistic scenarios
- Use appropriate data sizes
- Control for external factors
- Verify correctness in benchmarks

## Writing benchmarks

### Basic benchmark

```python
def test_benchmark_processing(benchmark):
    """Benchmark data processing."""
    data = setup_test_data(size=1000)

    result = benchmark(process_data, data)

    # Always verify correctness
    assert result is not None
    assert len(result) == 1000
```

### Benchmark with setup

```python
def test_benchmark_with_setup(benchmark):
    """Benchmark with separate setup phase."""
    def setup():
        return setup_complex_data()

    def teardown(data):
        cleanup(data)

    result = benchmark.pedantic(
        process_data,
        setup=setup,
        teardown=teardown,
        rounds=100,
        warmup_rounds=10,
    )

    assert result.success
```

### Parameterized benchmarks

```python
import pytest

@pytest.mark.parametrize('size', [100, 1000, 10000])
def test_benchmark_scaling(benchmark, size):
    """Benchmark processing at different scales."""
    data = generate_data(size)

    result = benchmark(process_data, data)

    assert len(result) == size
```

## Running benchmarks

```bash
# Run all benchmarks
uv run pytest tests/benchmarks/ --benchmark-only

# Run with comparison to saved baseline
uv run pytest tests/benchmarks/ --benchmark-compare

# Save baseline for future comparison
uv run pytest tests/benchmarks/ --benchmark-autosave

# Show detailed statistics
uv run pytest tests/benchmarks/ --benchmark-verbose

# Generate JSON output
uv run pytest tests/benchmarks/ --benchmark-json=results.json
```

## Benchmark organization

```text
tests/
└── benchmarks/
    ├── microbenchmarks/
    │   ├── test_processing_benchmark.py
    │   └── test_validation_benchmark.py
    ├── integration/
    │   └── test_end_to_end_benchmark.py
    └── memory/
        └── test_memory_usage.py
```

## Naming conventions

```python
# Microbenchmarks
def test_benchmark_process_single_item(benchmark):
    ...

def test_benchmark_process_batch(benchmark):
    ...

# Memory benchmarks
def test_memory_peak_usage(benchmark):
    ...
```

## Interpreting results

### Key metrics

- **Mean**: Average execution time
- **Stddev**: Variation in times
- **Min/Max**: Extremes
- **Rounds**: Number of iterations
- **OPS**: Operations per second

### Warning signs

- High stddev indicates inconsistent performance
- Large gap between min and max
- Unexpected scaling behavior

## Regression detection

```bash
# Save baseline after known-good state
uv run pytest tests/benchmarks/ --benchmark-autosave

# After changes, compare
uv run pytest tests/benchmarks/ --benchmark-compare

# Fail CI on significant regression
uv run pytest tests/benchmarks/ --benchmark-compare-fail=mean:5%
```

## Best practices

1. **Isolate benchmarks**: Run in dedicated environment
2. **Multiple rounds**: Use enough iterations for statistical significance
3. **Warmup**: Include warmup rounds to avoid cold-start effects
4. **Verify correctness**: Always assert results are correct
5. **Control variables**: Minimize external factors

## Checklist

- [ ] Benchmark tests realistic scenarios
- [ ] Correctness verified in each benchmark
- [ ] Baseline saved for comparison
- [ ] Results are statistically significant
- [ ] No external factors affecting results

---

**Additional resources:**

- [pytest-benchmark documentation](https://pytest-benchmark.readthedocs.io/)
