---
name: testing-benchmarking-infrastructure
description: "Testing suite with benchmarking for version-to-version performance comparison"
author: Claude Code
date: 2026-01-02
---

# Testing & Benchmarking Infrastructure - Research Notes

## Experiment Overview
| Item | Details |
|------|---------|
| **Date** | 2026-01-02 |
| **Goal** | Implement comprehensive testing with benchmarking for version comparison |
| **Environment** | Python 3.10/3.11, pytest 8.4.2, pytest-benchmark 4.0+ |
| **Status** | Success |

## Context
Trading systems evolve through versions (v2.3 -> v2.7) with different feature counts and action spaces. Need to:
1. Track performance regressions between versions
2. Ensure backwards compatibility for model loading
3. Validate feature computation consistency
4. Support both GPU and CPU testing (CI compatibility)

Without proper benchmarking, performance regressions go unnoticed until production.

## Verified Workflow

### 1. Directory Structure
```
tests/
  conftest.py              # Shared fixtures, GPU mocking
  test_benchmarks.py       # pytest-benchmark tests
  test_feature_regression.py  # Version compatibility tests
  integration/
    __init__.py
    test_training_pipeline.py
    test_inference_pipeline.py

benchmark_results/         # Stores version-tagged results
  v2.6.0/
  v2.7.0/
  v2.7.0_report.md

pytest.ini                 # Test configuration
.coveragerc                # Coverage thresholds
```

### 2. Shared Fixtures with GPU Mocking (conftest.py)
```python
@pytest.fixture
def mock_cuda():
    """Mock CUDA environment for GPU tests on CPU-only machines."""
    mock_props = MagicMock()
    mock_props.total_memory = 42949672960  # 40GB (A100)
    mock_props.name = "NVIDIA A100-PCIE-40GB"

    with patch('torch.cuda.is_available', return_value=True), \
         patch('torch.cuda.get_device_properties', return_value=mock_props), \
         patch('torch.cuda.get_device_name', return_value='NVIDIA A100-PCIE-40GB'), \
         patch('torch.cuda.get_device_capability', return_value=(8, 0)), \
         patch('torch.cuda.synchronize'):
        yield

@pytest.fixture(scope="module")
def sample_prices():
    """Deterministic price data for reproducibility."""
    np.random.seed(42)
    returns = np.random.randn(10000) * 0.01
    return 100 * np.exp(np.cumsum(returns))
```

### 3. Benchmark Categories
```python
# Feature Engineering benchmarks
def test_markov_chain_step_benchmark(benchmark, sample_prices):
    """Measures Markov state transition speed."""
    result = benchmark(lambda: markov.get_regime_state(prices))

# GPU Environment benchmarks (with mock fallback)
@pytest.mark.gpu
def test_env_step_throughput_benchmark(benchmark, mock_cuda):
    """Measures environment steps/sec."""

# Validation Metrics benchmarks
def test_profit_factor_benchmark(benchmark, benchmark_rewards):
    """Measures profit factor calculation on 100k samples."""
```

### 4. Version Comparison Script
```bash
# Save benchmarks for current version
python scripts/run_version_benchmarks.py --save

# Compare two versions
python scripts/run_version_benchmarks.py --compare v2.6.0 v2.7.0

# Generate detailed report
python scripts/run_version_benchmarks.py --report v2.7.0
```

### 5. Feature Regression Tests
```python
@pytest.mark.parametrize("version,n_features,n_actions,obs_dim", [
    ("2.3.0", 53, 3, 5300),
    ("2.4.0", 56, 3, 5600),
    ("2.7.0", 59, 7, 5900),
])
def test_version_spec_consistency(self, version, n_features, n_actions, obs_dim):
    """Verify version specs match documented values."""
    spec = MODEL_SPECS[version]
    assert spec.n_features == n_features
    assert spec.n_actions == n_actions
```

### 6. pytest.ini Configuration
```ini
[pytest]
testpaths = tests
markers =
    benchmark: performance benchmark test
    slow: marks tests as slow (> 10s)
    gpu: requires CUDA GPU (mocked if unavailable)
    integration: integration test
addopts = -v --tb=short --strict-markers
```

### 7. Coverage Configuration (.coveragerc)
```ini
[run]
source = alpaca_trading
branch = True

[report]
# Per DEVELOPMENT_PRACTICES.md
# 70% minimum, 85% for risk/signals modules
fail_under = 70
```

## Failed Attempts (Critical)

| Attempt | Why it Failed | Lesson Learned |
|---------|---------------|----------------|
| Benchmark config in pytest.ini | pytest-benchmark options not recognized without plugin | Pass via command line or use helper script |
| Running GPU tests without mock | Tests skip entirely on CPU machines | Use mock_cuda fixture for CI compatibility |
| Single benchmark file with all categories | Hard to run specific categories | Organize by class: TestFeatureEngineering, TestGPU, etc. |
| Fixtures without scope="module" | Slow test execution, re-creating data | Use module scope for expensive fixtures |
| Hardcoded version specs in tests | Breaks when versions change | Import from model_version.py |
| time.time() for performance tests | Not statistically rigorous | Use pytest-benchmark for proper stats |

## Final Parameters
```python
# conftest.py fixture scopes
scope="session"  # benchmark_output_dir, model_version
scope="module"   # sample_prices, sample_ohlcv, gpu_prices
scope="function" # mock_cuda, mock_broker

# pytest markers for test selection
markers = ["benchmark", "slow", "gpu", "live", "integration"]

# Coverage thresholds (per DEVELOPMENT_PRACTICES.md)
minimum_coverage = 70  # Standard modules
critical_coverage = 85  # risk/, signals/ modules

# Benchmark report columns
columns = ["min", "max", "mean", "stddev", "median", "iqr", "rounds"]
```

## Key Insights
- **GPU mocking is essential** - Tests must run on CPU-only CI machines
- **Fixtures reduce duplication** - Shared conftest.py cuts test code by ~30%
- **Version comparison needs automation** - Helper script makes it easy
- **Regression tests catch breaking changes** - Parametrize across versions
- **Integration tests go in separate directory** - Per DEVELOPMENT_PRACTICES.md
- **Markers enable selective execution** - Run fast tests on commit, full on PR
- **Deterministic seeds required** - Use np.random.seed(42) for reproducibility

## Usage Commands
```bash
# Run all tests with coverage
pytest tests/ --cov=alpaca_trading --cov-report=html

# Run fast tests only (pre-commit)
pytest tests/ -m "not (benchmark or slow or gpu or integration or live)"

# Run benchmarks and save
python scripts/run_version_benchmarks.py --save

# Compare versions
python scripts/run_version_benchmarks.py --compare v2.6.0 v2.7.0 --threshold 10

# Run integration tests
pytest tests/integration/ -v
```

## Testing Checklist
```
1. [x] conftest.py with shared fixtures
2. [x] GPU mocking for CI compatibility
3. [x] pytest.ini with custom markers
4. [x] .coveragerc with 70%/85% thresholds
5. [x] Benchmark tests (21 tests, 4 categories)
6. [x] Feature regression tests (28 tests)
7. [x] Integration tests (23 tests)
8. [x] Version comparison script
9. [x] pre-commit hook excludes slow tests
```

## Files Created
| File | Purpose |
|------|---------|
| tests/conftest.py | Shared fixtures, GPU mocking |
| pytest.ini | Test configuration |
| .coveragerc | Coverage thresholds |
| tests/test_benchmarks.py | 21 benchmark tests |
| tests/test_feature_regression.py | 28 regression tests |
| tests/integration/ | Pipeline integration tests |
| scripts/run_version_benchmarks.py | Version comparison tool |
| benchmark_results/.gitkeep | Results storage |

## References
- DEVELOPMENT_PRACTICES.md: Testing strategy, coverage requirements
- pytest-benchmark documentation: https://pytest-benchmark.readthedocs.io/
- CLAUDE.md: Version protocol (v2.3 -> v2.7)
