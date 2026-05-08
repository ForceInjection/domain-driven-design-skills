---
name: "deliberation-tester"
description: "Test-Driven Development patterns for testing AI deliberation features. Use when adding new deliberation features, adapters, convergence detection, or decision graph components. Encodes TDD workflow: write test first → implement → verify."
---

# Deliberation Tester Skill

## Purpose

This skill teaches Test-Driven Development (TDD) patterns for the AI Counsel deliberation system. Follow the **red-green-refactor** cycle: write failing test first, implement feature, verify passing, then refactor.

## When to Use This Skill

- Adding new CLI or HTTP adapters
- Implementing deliberation engine features
- Building convergence detection logic
- Adding decision graph functionality
- Extending voting or transcript systems
- Any feature that affects multi-round deliberations

## Test Organization

The project has 113+ tests organized into three categories:

```
tests/
├── unit/              # Fast tests with mocked dependencies
├── integration/       # Tests with real CLI tools or system integration
├── e2e/              # End-to-end tests with real API calls (slow, expensive)
├── conftest.py       # Shared pytest fixtures
└── fixtures/
    └── vcr_cassettes/ # Recorded HTTP responses for replay
```

## TDD Workflow

### 1. Write Test First (RED)

Before implementing any feature, write a test that will fail:

```python
# tests/unit/test_new_feature.py
import pytest
from my_module import NewFeature

class TestNewFeature:
    """Tests for NewFeature."""

    def test_feature_does_something(self):
        """Test that feature performs expected behavior."""
        feature = NewFeature()
        result = feature.do_something()
        assert result == "expected output"
```

Run the test to verify it fails:
```bash
pytest tests/unit/test_new_feature.py -v
```

### 2. Implement Feature (GREEN)

Write minimal code to make the test pass:

```python
# my_module.py
class NewFeature:
    def do_something(self):
        return "expected output"
```

Run the test to verify it passes:
```bash
pytest tests/unit/test_new_feature.py -v
```

### 3. Refactor (REFACTOR)

Improve code quality while keeping tests green:
- Extract duplicated logic
- Improve naming
- Optimize performance
- Add type hints

Run all tests to ensure nothing broke:
```bash
pytest tests/unit -v
```

## Unit Test Patterns

### Pattern 1: Mock Adapters for Engine Tests

Use shared fixtures from `conftest.py` to mock adapters:

```python
# tests/unit/test_engine.py
from deliberation.engine import DeliberationEngine
from models.schema import Participant

class TestDeliberationEngine:
    """Tests for DeliberationEngine."""

    def test_engine_initialization(self, mock_adapters):
        """Test engine initializes with adapters."""
        engine = DeliberationEngine(mock_adapters)
        assert engine.adapters == mock_adapters
        assert len(engine.adapters) == 2

    @pytest.mark.asyncio
    async def test_execute_round_single_participant(self, mock_adapters):
        """Test executing single round with one participant."""
        engine = DeliberationEngine(mock_adapters)

        participants = [
            Participant(cli="claude", model="claude-3-5-sonnet", stance="neutral")
        ]

        # Configure mock return value
        mock_adapters["claude"].invoke_mock.return_value = "This is Claude's response"

        responses = await engine.execute_round(
            round_num=1,
            prompt="What is 2+2?",
            participants=participants,
            previous_responses=[],
        )

        assert len(responses) == 1
        assert responses[0].response == "This is Claude's response"
        assert responses[0].participant == "claude-3-5-sonnet@claude"
```

**Key Points:**
- Use `@pytest.mark.asyncio` for async tests
- Use `mock_adapters` fixture from `conftest.py`
- Configure mock return values with `invoke_mock.return_value`
- Assert on response structure and content

### Pattern 2: Mock Subprocesses for CLI Adapter Tests

Use `unittest.mock.patch` to mock subprocess execution:

```python
# tests/unit/test_adapters.py
from unittest.mock import AsyncMock, Mock, patch
import pytest
from adapters.claude import ClaudeAdapter

class TestClaudeAdapter:
    """Tests for ClaudeAdapter."""

    @pytest.mark.asyncio
    @patch("adapters.base.asyncio.create_subprocess_exec")
    async def test_invoke_success(self, mock_subprocess):
        """Test successful CLI invocation."""
        # Mock subprocess
        mock_process = Mock()
        mock_process.communicate = AsyncMock(
            return_value=(b"Claude Code output\n\nActual model response here", b"")
        )
        mock_process.returncode = 0
        mock_subprocess.return_value = mock_process

        adapter = ClaudeAdapter(
            args=["-p", "--model", "{model}", "{prompt}"]
        )
        result = await adapter.invoke(
            prompt="What is 2+2?",
            model="claude-3-5-sonnet-20241022"
        )

        assert result == "Actual model response here"
        mock_subprocess.assert_called_once()

    @pytest.mark.asyncio
    @patch("adapters.base.asyncio.create_subprocess_exec")
    async def test_invoke_timeout(self, mock_subprocess):
        """Test timeout handling."""
        mock_process = Mock()
        mock_process.communicate = AsyncMock(side_effect=asyncio.TimeoutError())
        mock_subprocess.return_value = mock_process

        adapter = ClaudeAdapter(args=["-p", "{model}", "{prompt}"], timeout=1)

        with pytest.raises(RuntimeError, match="timeout"):
            await adapter.invoke(prompt="test", model="sonnet")
```

**Key Points:**
- Patch `asyncio.create_subprocess_exec` at the import path
- Mock `communicate()` to return `(stdout, stderr)` tuple
- Use `AsyncMock` for async methods
- Test both success and error cases

### Pattern 3: HTTP Adapter Tests with Mock Responses

Test HTTP adapters without making real API calls:

```python
# tests/unit/test_ollama_adapter.py
from adapters.ollama import OllamaAdapter
import pytest

class TestOllamaAdapter:
    """Tests for Ollama HTTP adapter."""

    def test_adapter_initialization(self):
        """Test adapter initializes with correct base_url and defaults."""
        adapter = OllamaAdapter(base_url="http://localhost:11434", timeout=60)
        assert adapter.base_url == "http://localhost:11434"
        assert adapter.timeout == 60
        assert adapter.max_retries == 3

    def test_build_request_structure(self):
        """Test build_request returns correct endpoint, headers, body."""
        adapter = OllamaAdapter(base_url="http://localhost:11434")

        endpoint, headers, body = adapter.build_request(
            model="llama2", prompt="What is 2+2?"
        )

        assert endpoint == "/api/generate"
        assert headers["Content-Type"] == "application/json"
        assert body["model"] == "llama2"
        assert body["prompt"] == "What is 2+2?"
        assert body["stream"] is False

    def test_parse_response_extracts_content(self):
        """Test parse_response extracts 'response' field from JSON."""
        adapter = OllamaAdapter(base_url="http://localhost:11434")

        response_json = {
            "model": "llama2",
            "response": "The answer is 4.",
            "done": True,
        }

        result = adapter.parse_response(response_json)
        assert result == "The answer is 4."

    def test_parse_response_missing_field_raises_error(self):
        """Test parse_response raises error if 'response' field missing."""
        adapter = OllamaAdapter(base_url="http://localhost:11434")

        response_json = {"model": "llama2", "done": True}

        with pytest.raises(KeyError) as exc_info:
            adapter.parse_response(response_json)

        assert "response" in str(exc_info.value).lower()
```

**Key Points:**
- Test `build_request()` separately from `parse_response()`
- Verify request structure (endpoint, headers, body)
- Test response parsing with valid and invalid JSON
- Use `pytest.raises()` for error cases

### Pattern 4: Pydantic Model Validation Tests

Test data models with valid and invalid inputs:

```python
# tests/unit/test_models.py
import pytest
from pydantic import ValidationError
from models.schema import Participant, Vote

class TestParticipant:
    """Tests for Participant model."""

    def test_valid_participant(self):
        """Test participant creation with valid data."""
        p = Participant(cli="claude", model="sonnet", stance="neutral")
        assert p.cli == "claude"
        assert p.model == "sonnet"
        assert p.stance == "neutral"

    def test_invalid_cli_raises_error(self):
        """Test invalid CLI name raises validation error."""
        with pytest.raises(ValidationError) as exc_info:
            Participant(cli="invalid", model="test", stance="neutral")

        assert "cli" in str(exc_info.value).lower()

    def test_invalid_stance_raises_error(self):
        """Test invalid stance raises validation error."""
        with pytest.raises(ValidationError) as exc_info:
            Participant(cli="claude", model="sonnet", stance="maybe")

        assert "stance" in str(exc_info.value).lower()

class TestVote:
    """Tests for Vote model."""

    def test_valid_vote(self):
        """Test vote creation with valid data."""
        vote = Vote(
            option="Option A",
            confidence=0.85,
            rationale="Strong evidence supports this",
            continue_debate=False
        )
        assert vote.confidence == 0.85
        assert vote.continue_debate is False

    def test_confidence_out_of_range_raises_error(self):
        """Test confidence outside 0.0-1.0 raises error."""
        with pytest.raises(ValidationError) as exc_info:
            Vote(option="A", confidence=1.5, rationale="test")

        assert "confidence" in str(exc_info.value).lower()
```

**Key Points:**
- Test valid model creation
- Test each validation rule with invalid data
- Use `pytest.raises(ValidationError)` for schema violations
- Check error message contains the problematic field

## Integration Test Patterns

### Pattern 5: Real Adapter Integration Tests

Test adapters with real CLI invocations (requires tools installed):

```python
# tests/integration/test_engine_convergence.py
import pytest
from deliberation.engine import DeliberationEngine
from models.config import load_config
from models.schema import Participant

@pytest.mark.integration
class TestEngineConvergenceIntegration:
    """Test convergence detection integrated with deliberation engine."""

    @pytest.fixture
    def config(self):
        """Load test config."""
        return load_config("config.yaml")

    @pytest.mark.asyncio
    async def test_engine_detects_convergence_with_similar_responses(
        self, config, mock_adapters
    ):
        """Engine should detect convergence when responses are similar."""
        from deliberation.convergence import ConvergenceDetector

        engine = DeliberationEngine(adapters=mock_adapters)
        engine.convergence_detector = ConvergenceDetector(config)
        engine.config = config

        # Mock adapters to return similar responses
        mock_adapters["claude"].invoke = AsyncMock(
            side_effect=[
                "TypeScript is better for large projects",
                "TypeScript is better for large projects due to type safety",
            ]
        )

        # Execute rounds and verify convergence detection
        # ... test logic here
```

**Key Points:**
- Mark with `@pytest.mark.integration`
- Load real config with `load_config()`
- Can use real CLI tools or mocked responses
- Test feature integration, not just units

### Pattern 6: VCR Cassettes for HTTP Tests

Record and replay HTTP responses for consistent testing:

```python
# tests/integration/test_ollama_integration.py
import pytest
import vcr
from adapters.ollama import OllamaAdapter

# Configure VCR to record/replay HTTP interactions
my_vcr = vcr.VCR(
    cassette_library_dir='tests/fixtures/vcr_cassettes/ollama',
    record_mode='once',  # Record once, then replay
    match_on=['method', 'scheme', 'host', 'port', 'path', 'query', 'body'],
)

@pytest.mark.integration
class TestOllamaIntegration:
    """Integration tests for Ollama adapter with VCR."""

    @pytest.mark.asyncio
    @my_vcr.use_cassette('ollama_generate_success.yaml')
    async def test_real_ollama_request(self):
        """Test real Ollama request (recorded to cassette)."""
        adapter = OllamaAdapter(base_url="http://localhost:11434", timeout=60)

        result = await adapter.invoke(
            prompt="What is 2+2?",
            model="llama2"
        )

        assert isinstance(result, str)
        assert len(result) > 0
```

**Key Points:**
- Install VCR: `pip install vcrpy`
- Configure cassette directory and match criteria
- First run records HTTP interactions to YAML file
- Subsequent runs replay from cassette (no network calls)
- Commit cassettes to repo for CI/CD consistency

### Pattern 7: Performance and Latency Tests

Test performance characteristics of features:

```python
# tests/integration/test_performance.py
import pytest
import time
from decision_graph.cache import DecisionCache

@pytest.mark.integration
class TestCachePerformance:
    """Performance tests for decision graph cache."""

    @pytest.mark.asyncio
    async def test_cache_hit_latency(self):
        """Test cache hit latency is under 5μs."""
        cache = DecisionCache(max_size=200)

        # Warm up cache
        cache.set("test_key", "test_value")

        # Measure cache hit time
        start = time.perf_counter()
        for _ in range(1000):
            result = cache.get("test_key")
        elapsed = time.perf_counter() - start

        avg_latency_us = (elapsed / 1000) * 1_000_000
        assert avg_latency_us < 5, f"Cache hit too slow: {avg_latency_us}μs"
        assert result == "test_value"

    @pytest.mark.asyncio
    async def test_query_latency_with_1000_nodes(self):
        """Test query latency stays under 100ms with 1000 nodes."""
        # Setup: create 1000 decision nodes
        # ... setup code

        start = time.perf_counter()
        results = await query_engine.search_similar("test question", limit=5)
        elapsed = time.perf_counter() - start

        assert elapsed < 0.1, f"Query too slow: {elapsed*1000}ms"
        assert len(results) <= 5
```

**Key Points:**
- Use `time.perf_counter()` for high-resolution timing
- Test realistic data volumes (1000+ nodes)
- Assert on performance targets (p95, p99 latencies)
- Run separately from fast unit tests

## Test Naming Conventions

Follow these naming patterns for clarity:

```python
# Test class: Test<ComponentName>
class TestDeliberationEngine:
    pass

# Test method: test_<what>_<condition>_<outcome>
def test_engine_initialization_with_adapters_succeeds(self):
    pass

def test_invoke_with_timeout_raises_runtime_error(self):
    pass

def test_parse_response_with_missing_field_raises_key_error(self):
    pass
```

**Patterns:**
- Class: `Test<ComponentName>` (PascalCase)
- Method: `test_<action>_<condition>_<result>` (snake_case)
- Use descriptive names that explain the test scenario
- Group related tests in classes

## Running Tests

### Run All Tests
```bash
# All tests with coverage
pytest --cov=. --cov-report=html

# View coverage report
open htmlcov/index.html
```

### Run Specific Test Types
```bash
# Unit tests only (fast, no external dependencies)
pytest tests/unit -v

# Integration tests (requires CLI tools)
pytest tests/integration -v -m integration

# End-to-end tests (real API calls, slow)
pytest tests/e2e -v -m e2e
```

### Run Specific Tests
```bash
# Single file
pytest tests/unit/test_engine.py -v

# Single test class
pytest tests/unit/test_engine.py::TestDeliberationEngine -v

# Single test method
pytest tests/unit/test_engine.py::TestDeliberationEngine::test_engine_initialization -v

# Tests matching pattern
pytest -k "convergence" -v
```

### Debugging Tests
```bash
# Show print statements
pytest tests/unit/test_engine.py -v -s

# Drop into debugger on failure
pytest tests/unit/test_engine.py -v --pdb

# Show full diff on assertion failures
pytest tests/unit/test_engine.py -v -vv
```

## Code Quality Checks

After writing tests, run quality checks:

```bash
# Format code (black)
black .

# Lint (ruff)
ruff check .

# Type check (optional, mypy)
mypy .
```

## TDD Example: Adding a New CLI Adapter

### Step 1: Write Failing Test

```python
# tests/unit/test_new_cli.py
import pytest
from adapters.new_cli import NewCLIAdapter

class TestNewCLIAdapter:
    """Tests for NewCLIAdapter."""

    def test_adapter_initialization(self):
        """Test adapter initializes with correct command."""
        adapter = NewCLIAdapter(args=["--model", "{model}", "{prompt}"])
        assert adapter.command == "new-cli"
        assert adapter.timeout == 60

    def test_parse_output_extracts_response(self):
        """Test parse_output extracts model response."""
        adapter = NewCLIAdapter(args=[])
        raw = "Some CLI header\n\nActual response here"
        result = adapter.parse_output(raw)
        assert result == "Actual response here"
```

Run test: `pytest tests/unit/test_new_cli.py -v` (FAILS)

### Step 2: Implement Adapter

```python
# adapters/new_cli.py
from adapters.base import BaseCLIAdapter

class NewCLIAdapter(BaseCLIAdapter):
    """Adapter for new-cli tool."""

    def __init__(self, args: list[str], timeout: int = 60):
        super().__init__(command="new-cli", args=args, timeout=timeout)

    def parse_output(self, raw_output: str) -> str:
        """Extract response from CLI output."""
        lines = raw_output.strip().split("\n")
        # Skip header, return content
        return "\n".join(lines[2:]).strip()
```

Run test: `pytest tests/unit/test_new_cli.py -v` (PASSES)

### Step 3: Add Integration Test

```python
# tests/integration/test_new_cli_integration.py
import pytest
from adapters.new_cli import NewCLIAdapter

@pytest.mark.integration
class TestNewCLIIntegration:
    """Integration tests for NewCLI adapter."""

    @pytest.mark.asyncio
    async def test_real_cli_invocation(self):
        """Test real CLI invocation (requires new-cli installed)."""
        adapter = NewCLIAdapter(args=["--model", "{model}", "{prompt}"])

        result = await adapter.invoke(
            prompt="What is 2+2?",
            model="default-model"
        )

        assert isinstance(result, str)
        assert len(result) > 0
```

### Step 4: Register Adapter

```python
# adapters/__init__.py
from adapters.new_cli import NewCLIAdapter

def create_adapter(name: str, config):
    """Factory function for creating adapters."""
    cli_adapters = {
        "claude": ClaudeAdapter,
        "codex": CodexAdapter,
        "new_cli": NewCLIAdapter,  # Add here
    }
    # ... rest of factory logic
```

### Step 5: Update Schema

```python
# models/schema.py
class Participant(BaseModel):
    """Participant in deliberation."""
    cli: Literal["claude", "codex", "droid", "gemini", "new_cli"]  # Add here
    model: str
    stance: Literal["for", "against", "neutral"]
```

### Step 6: Run All Tests

```bash
# Verify no regressions
pytest tests/unit -v
pytest tests/integration -v -m integration

# Check coverage
pytest --cov=adapters --cov-report=term-missing
```

## Common Testing Pitfalls

### 1. Not Using Async Fixtures
```python
# WRONG: Mixing sync and async
def test_async_function(self):
    result = my_async_function()  # Returns coroutine, not result

# RIGHT: Mark test as async
@pytest.mark.asyncio
async def test_async_function(self):
    result = await my_async_function()
```

### 2. Mock Path Mismatch
```python
# WRONG: Patching where defined
@patch("adapters.base.asyncio")  # Won't work if imported in subclass

# RIGHT: Patch where used
@patch("adapters.base.asyncio.create_subprocess_exec")
```

### 3. Forgetting to Reset Mocks
```python
# WRONG: Reusing mock without reset
mock_adapter.invoke_mock.return_value = "first"
# ... test 1
mock_adapter.invoke_mock.return_value = "second"
# ... test 2 (but test 1 state might leak)

# RIGHT: Use fixtures or reset
@pytest.fixture(autouse=True)
def reset_mocks(self, mock_adapters):
    yield
    for adapter in mock_adapters.values():
        adapter.invoke_mock.reset_mock()
```

### 4. Not Testing Error Cases
```python
# INCOMPLETE: Only testing happy path
def test_adapter_invoke_success(self):
    result = await adapter.invoke("prompt", "model")
    assert result == "response"

# COMPLETE: Test errors too
def test_adapter_invoke_timeout(self):
    with pytest.raises(RuntimeError, match="timeout"):
        await adapter.invoke("prompt", "model")

def test_adapter_invoke_invalid_response(self):
    with pytest.raises(ValueError, match="invalid"):
        adapter.parse_response({})
```

## Shared Fixtures Reference

Located in `tests/conftest.py`:

```python
# mock_adapters fixture
def test_with_mocks(self, mock_adapters):
    """Use pre-configured mock adapters."""
    claude = mock_adapters["claude"]
    codex = mock_adapters["codex"]
    # Both have invoke_mock configured

# sample_config fixture
def test_with_config(self, sample_config):
    """Use sample configuration dict."""
    assert sample_config["defaults"]["rounds"] == 2
```

## Test Coverage Goals

- **Unit tests**: 90%+ coverage of core logic
- **Integration tests**: Critical workflows (engine execution, convergence, voting)
- **E2E tests**: Minimal, focused on user-facing scenarios
- **Total**: 113+ tests currently, growing with each feature

## Final Checklist

Before committing new features:

- [ ] Write unit test first (RED)
- [ ] Implement minimal feature (GREEN)
- [ ] Add integration test if needed
- [ ] Refactor while keeping tests green
- [ ] Run `pytest tests/unit -v` (all pass)
- [ ] Run `black . && ruff check .` (no errors)
- [ ] Check coverage: `pytest --cov=. --cov-report=term-missing`
- [ ] Update CLAUDE.md if architecture changed
- [ ] Commit with clear message describing what was tested

## Resources

- **Pytest docs**: https://docs.pytest.org/
- **Async testing**: https://pytest-asyncio.readthedocs.io/
- **VCR.py docs**: https://vcrpy.readthedocs.io/
- **Project tests**: `/Users/harrison/Github/ai-counsel/tests/`
- **CLAUDE.md**: `/Users/harrison/Github/ai-counsel/CLAUDE.md`

---

**Remember**: Tests are documentation. Write tests that explain *what* the feature does and *why* it's important.
