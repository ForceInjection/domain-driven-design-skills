---
name: finwiz-testing
description: "FinWiz testing standards using pytest-mock. Use when writing tests, mocking dependencies, or fixing test failures. Includes unittest.mock ban enforcement and CrewAI testing patterns."
allowed-tools: ["Read", "Edit", "Bash"]
---

# FinWiz Testing Standards

Comprehensive testing standards for FinWiz using pytest-mock exclusively.

## Core Testing Principles

### 1. Mock All External Dependencies

- **Always use `pytest-mock`** (never `unittest.mock`)
- **unittest.mock is BANNED** - 4 enforcement layers prevent its use
- Mock APIs, file system, network requests, LLM calls
- No real external calls in tests
- Deterministic test execution

### unittest.mock Enforcement (CRITICAL)

**unittest.mock is COMPLETELY BANNED from this codebase.**

We have 4 layers of enforcement:

1. **Ruff Linting** - TID rules automatically catch unittest.mock imports
2. **Pre-commit Hook** - Blocks commits containing unittest.mock
3. **Runtime Blocker** - Raises ImportError if unittest.mock is imported
4. **Manual Check** - `make check-unittest-mock` for verification

### Migration Required

```python
# ❌ BANNED - Will be blocked by all 4 enforcement layers
from unittest.mock import Mock, patch, MagicMock, AsyncMock

# ✅ REQUIRED - Only acceptable approach
def test_example(mocker):
    mock_obj = mocker.patch('module.function')
    mock_obj.return_value = 'test'
```

## Standard Test Structure

### Arrange-Act-Assert Pattern

```python
def test_should_return_buy_recommendation_when_strong_metrics(mocker):
    # Arrange - Set up test data and mocks
    mock_api = mocker.patch('finwiz.tools.yahoo_finance_tool.get_data')
    mock_api.return_value = {'pe_ratio': 15, 'growth': 0.25}
    
    # Act - Execute the code under test
    result = analyze_stock('AAPL')
    
    # Assert - Verify the results
    assert result.recommendation == 'BUY'
    mock_api.assert_called_once_with('AAPL')
```

## Common Mocking Patterns

### Mock API Calls

```python
def test_should_fetch_stock_data_when_valid_ticker(mocker):
    # Mock external API call
    mock_get = mocker.patch('finwiz.tools.yahoo_finance_tool.yf.Ticker')
    mock_ticker = mocker.Mock()
    mock_ticker.info = {'symbol': 'AAPL', 'price': 150.0}
    mock_get.return_value = mock_ticker
    
    # Test the function
    result = get_stock_data('AAPL')
    
    # Verify
    assert result['symbol'] == 'AAPL'
    assert result['price'] == 150.0
    mock_get.assert_called_once_with('AAPL')
```

### Mock File Operations

```python
def test_should_read_config_file(mocker):
    mock_open = mocker.patch('builtins.open', mocker.mock_open(read_data='{"key": "value"}'))
    
    result = load_config('config.json')
    
    assert result['key'] == 'value'
    mock_open.assert_called_once_with('config.json')
```

### Mock Environment Variables

```python
def test_should_use_api_key_from_env(mocker):
    mocker.patch.dict('os.environ', {'API_KEY': 'test_key'})
    
    result = get_api_key()
    
    assert result == 'test_key'
```

### Mock Datetime

```python
def test_should_use_current_timestamp(mocker):
    mock_now = mocker.patch('datetime.datetime')
    mock_now.now.return_value = datetime(2025, 3, 10)
    
    result = generate_report()
    
    assert '2025-03-10' in result.timestamp
```

## CrewAI Testing Standards (CRITICAL)

### The Problem with CrewAI Testing

**CRITICAL LESSON LEARNED**: Do not attempt to unit test full CrewAI crew execution. It leads to hanging tests and is impractical.

### The Solution: Test What Matters

Focus unit tests on **testable business logic**, NOT framework execution:

#### ✅ DO Test

1. **Configuration loading** - Verify YAML files load correctly
2. **Tool routing logic** - Test `get_tools_for_asset_class()` method logic
3. **Input validation** - Test parameter validation (asset_class, ticker)
4. **Method existence** - Verify required methods exist
5. **File existence** - Verify configuration files exist

#### ❌ DON'T Test

1. **Crew execution** - Don't call `crew.kickoff()` in unit tests
2. **Agent creation** - Don't instantiate agents with `@agent` decorator
3. **Task execution** - Don't execute tasks with `@task` decorator
4. **LLM calls** - Don't mock OpenAI/LLM responses
5. **Full workflow** - Don't test end-to-end crew workflows

### CrewAI Testing Examples

#### ✅ GOOD - Tests configuration and logic

```python
def test_should_load_agent_configurations_from_yaml(self):
    """Fast, focused test of configuration loading."""
    import yaml
    from pathlib import Path
    
    config_path = Path("src/finwiz/crews/deep_analysis/config/agents.yaml")
    with open(config_path) as f:
        config = yaml.safe_load(f)
    
    # Verify structure
    assert "asset_analyst" in config
    assert "role" in config["asset_analyst"]

def test_should_validate_asset_class_parameter(self):
    """Test validation logic without instantiating crew."""
    valid_asset_classes = ["stock", "etf", "crypto"]
    
    for asset_class in valid_asset_classes:
        assert asset_class.lower() in ["stock", "etf", "crypto"]
```

#### ❌ BAD - Tries to test crew execution

```python
def test_crew_execution(self, mocker):
    """This will hang or timeout!"""
    crew = DeepAnalysisCrew()  # Hangs during initialization
    
    # Mock everything (impractical)
    mocker.patch.object(crew, "asset_analyst", return_value=mock_agent)
    
    # This will still hang or be very slow
    result = crew.kickoff(inputs={"ticker": "AAPL", "asset_class": "stock"})
```

## Test Data Generation

### Using Faker

```python
from faker import Faker

fake = Faker()

def test_portfolio_analysis():
    # Generate realistic test data
    ticker = fake.stock_symbol()
    price = fake.pyfloat(min_value=10, max_value=1000, right_digits=2)
    company_name = fake.company()
    
    # Use in test
    result = analyze_holding(ticker, price, company_name)
    assert result is not None
```

## Test Organization

### Directory Structure

```
tests/
├── unit/               # Unit tests (fast, mocked)
│   ├── tools/
│   ├── crews/
│   ├── schemas/
│   └── utils/
├── integration/        # Integration tests (slow, real APIs)
├── fixtures/           # Shared test fixtures
└── conftest.py        # pytest configuration
```

### Test Markers

```python
# Unit tests (default)
def test_should_calculate_score():
    pass

# Integration tests
@pytest.mark.integration
def test_should_fetch_real_stock_data():
    pass

# Slow tests
@pytest.mark.slow
def test_should_backtest_strategy():
    pass
```

## Running Tests

### Essential Commands

```bash
# Unit tests only (fast)
uv run pytest -m "not integration"

# Integration tests (requires API keys)
uv run pytest -m integration

# Specific test file
uv run pytest tests/unit/tools/test_alternative_finder_tool.py

# With coverage
uv run pytest --cov=src/finwiz --cov-report=html

# Stop on first failure
uv run pytest -x
```

## Quality Checklist

Before committing tests:

- [ ] **No unittest.mock** - Use pytest-mock exclusively (ENFORCED)
- [ ] **All external dependencies mocked**
- [ ] **Fast execution** (< 5 seconds for unit tests)
- [ ] **Independent tests** (no shared state)
- [ ] **Descriptive names** (test_should_X_when_Y)
- [ ] **Arrange-Act-Assert** structure
- [ ] **Clear assertions** with messages
- [ ] **Edge cases covered**
- [ ] **No real API calls**
- [ ] **Proper fixtures** used
- [ ] **Coverage** maintained (65%+)

## Anti-Patterns (Avoid)

❌ **Using unittest.mock** - BANNED with 4-layer enforcement
❌ **Real API calls** - Mock all external dependencies
❌ **Shared state** - Each test should be independent
❌ **Long tests** - Keep unit tests fast (< 5 seconds)
❌ **Testing CrewAI execution** - Test configuration and logic only
❌ **Unclear names** - Use descriptive test names
❌ **No assertions** - Every test must have assertions

## Quick Fixes

### unittest.mock Violations

If you see `unittest.mock` anywhere:

1. **It's a bug** - Report or fix immediately
2. **Cannot be committed** - Pre-commit hook blocks it
3. **Cannot pass linting** - Ruff TID rules catch it
4. **Cannot run tests** - Runtime blocker prevents import

**Quick Fix:**

```python
# Remove this line
from unittest.mock import patch

# Add mocker parameter
def test_example(mocker):
    mock_obj = mocker.patch('module.function')
```

Apply these testing standards consistently across all FinWiz test code.
