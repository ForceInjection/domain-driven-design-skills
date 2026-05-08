---
name: pytest-test-generator
description: Generate pytest test templates for LiquidationHeatmap modules following TDD patterns. Automatically creates RED phase tests with fixtures, coverage markers, and integration test stubs.
---

# Pytest Test Generator

Generate standardized pytest tests for LiquidationHeatmap modules following strict TDD discipline.

## Quick Start

**User says**: "Generate tests for liquidation model"

**Skill generates**:
```python
# tests/test_liquidation.py
import pytest
from src.models.liquidation import LiquidationCalculator

@pytest.fixture
def calculator():
    """Fixture for LiquidationCalculator"""
    return LiquidationCalculator()

def test_long_liquidation_price(calculator):
    """Test long position liquidation price calculation"""
    result = calculator.calculate_liq_price(
        entry_price=100.0,
        leverage=10,
        side="long"
    )
    assert result == pytest.approx(90.0, rel=0.01)

def test_short_liquidation_price(calculator):
    """Test short position liquidation price calculation"""
    result = calculator.calculate_liq_price(
        entry_price=100.0,
        leverage=10,
        side="short"
    )
    assert result == pytest.approx(110.0, rel=0.01)
```

## Templates

### 1. Model Test Template
```python
import pytest
from src.models.{module} import {ClassName}

@pytest.fixture
def {module_instance}():
    """{Description}"""
    return {ClassName}()

def test_{function_name}({module_instance}):
    """Test {description}"""
    result = {module_instance}.{method}()
    assert result is not None
```

### 2. DuckDB Test Template
```python
import pytest
import duckdb
from src.data.{module} import {ClassName}

@pytest.fixture
def db_connection(tmp_path):
    """Create temporary DuckDB database"""
    db_path = tmp_path / "test.duckdb"
    conn = duckdb.connect(str(db_path))
    yield conn
    conn.close()

def test_{function_name}(db_connection):
    """Test {description}"""
    # Setup test data
    db_connection.execute("CREATE TABLE test (id INTEGER, value DOUBLE)")
    db_connection.execute("INSERT INTO test VALUES (1, 100.0)")

    # Test query
    result = db_connection.execute("SELECT * FROM test").fetchall()
    assert len(result) == 1
```

### 3. Integration Test Template
```python
import pytest
from src.models.{module1} import {Class1}
from src.models.{module2} import {Class2}

@pytest.mark.integration
def test_{module1}_to_{module2}_integration():
    """Test {module1} → {module2} integration"""
    upstream = {Class1}()
    downstream = {Class2}()

    # Generate test data
    input_data = upstream.process()

    # Process through pipeline
    output_data = downstream.process(input_data)

    # Validate integration
    assert output_data is not None
```

### 4. Coverage Marker Template
```python
@pytest.mark.cov
def test_{function_name}():
    """Test with coverage tracking"""
    pass
```

## Usage Patterns

### Pattern 1: New Module
```
User: "Create tests for src/models/heatmap.py"

Skill:
1. Detect module type (model/data/service)
2. Generate fixture
3. Create 3-5 core tests (RED phase)
4. Add integration test stub
5. Write to tests/test_heatmap.py
```

### Pattern 2: Add Test to Existing File
```
User: "Add test for calculate_density function"

Skill:
1. Read existing tests/test_heatmap.py
2. Generate new test function
3. Append to file
```

### Pattern 3: Integration Test
```
User: "Create integration test for ingestion → heatmap"

Skill:
1. Generate integration test in tests/integration/
2. Include both modules
3. Create end-to-end flow test
```

## Test Naming Conventions

| Pattern | Example | Use Case |
|---------|---------|----------|
| `test_{module}_*` | `test_liquidation_long` | Unit test |
| `test_{action}_*` | `test_calculate_density` | Action-based test |
| `test_{module1}_to_{module2}` | `test_ingest_to_heatmap` | Integration |
| `test_{edge_case}` | `test_zero_leverage` | Edge case |

## Fixtures Library

### LiquidationHeatmap Test Fixtures
```python
@pytest.fixture
def sample_trades_df():
    """Load sample trades DataFrame"""
    return pd.DataFrame({
        "timestamp": pd.date_range("2025-01-01", periods=100, freq="1min"),
        "price": [100.0 + i * 0.1 for i in range(100)],
        "volume": [1.0] * 100,
    })

@pytest.fixture
def sample_positions():
    """Sample open positions for testing"""
    return [
        {"entry_price": 100.0, "leverage": 10, "side": "long", "size": 1.0},
        {"entry_price": 105.0, "leverage": 5, "side": "short", "size": 0.5},
    ]
```

### DuckDB Fixtures
```python
@pytest.fixture
def populated_db(db_connection):
    """DuckDB with sample data"""
    db_connection.execute("""
        CREATE TABLE trades (
            timestamp TIMESTAMP,
            price DOUBLE,
            volume DOUBLE
        )
    """)
    # Insert sample data
    return db_connection
```

## Coverage Configuration

Auto-generate `pytest.ini`:
```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
markers =
    integration: integration test
    slow: slow test (deselect with -m 'not slow')
addopts =
    --cov=src
    --cov-report=term-missing
    --cov-report=html
    --cov-fail-under=80
```

## Output Format

**Generated test file**:
```python
"""
Tests for {module_name}
Coverage target: >80%
"""
import pytest
from src.models.{module} import {ClassName}

# Fixtures
@pytest.fixture
def {fixture_name}():
    """..."""
    pass

# Unit Tests (RED phase - should fail initially)
def test_{feature_1}():
    """Test {description}"""
    assert False  # RED: Not implemented yet

def test_{feature_2}():
    """Test {description}"""
    assert False  # RED: Not implemented yet

# Integration Tests
@pytest.mark.integration
def test_integration():
    """Test module integration"""
    pass
```

## Automatic Invocation

**Triggers**:
- "generate tests for [module]"
- "create test file for [file]"
- "add test for [function]"
- "write integration test for [module1] and [module2]"

**Does NOT trigger**:
- Complex test logic design (use subagent)
- Full TDD enforcement (use tdd-guard subagent)
- Test debugging (use general debugging)
