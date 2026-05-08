---
name: tool-testing
description: Write pytest tests for Tool Master tools. Use this skill FIRST when the user asks to write tests, add tests, create tests, or improve test coverage for any tool. Handles mocking, fixtures, and async test patterns.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
---

# Tool Testing Skill

## Quick Start

Test files go in `tests/` and follow the naming pattern `test_<toolname>_tools.py`.

### Basic Test File Structure

```python
"""Tests for <category> tools."""
import pytest
from tool_master import Tool, ToolParameter, ToolResult
from tool_master.schemas.tool import ParameterType

# Import the tools to test
from tool_master.tools.<module> import tool_name, another_tool


class TestToolName:
    """Tests for tool_name tool."""

    def test_schema_has_correct_name(self):
        """Verify tool has correct name."""
        assert tool_name.name == "tool_name"

    def test_schema_has_required_parameters(self):
        """Verify required parameters are defined."""
        param_names = [p.name for p in tool_name.parameters]
        assert "required_param" in param_names

    @pytest.mark.asyncio
    async def test_basic_execution(self):
        """Test successful execution with valid inputs."""
        result = await tool_name.execute(required_param="value")
        assert result.success is True
        assert "expected_key" in result.data

    @pytest.mark.asyncio
    async def test_missing_required_param(self):
        """Test error when required param is missing."""
        result = await tool_name.execute()
        assert result.success is False
        assert "required" in result.error.lower()

    @pytest.mark.asyncio
    async def test_invalid_input(self):
        """Test error handling for invalid input."""
        result = await tool_name.execute(required_param="invalid")
        assert result.success is False
```

## Testing Patterns

### Pattern 1: Sync Handler (Standalone Tools)

For tools like `datetime_tools.py` and `dice_tools.py` that don't make API calls:

```python
from tool_master.tools.datetime_tools import get_unix_timestamp, format_date


class TestGetUnixTimestamp:
    @pytest.mark.asyncio
    async def test_returns_timestamp(self):
        result = await get_unix_timestamp.execute()
        assert result.success is True
        assert "unix_timestamp" in result.data
        assert isinstance(result.data["unix_timestamp"], float)

    @pytest.mark.asyncio
    async def test_includes_iso_format(self):
        result = await get_unix_timestamp.execute()
        assert "iso" in result.data
        assert "T" in result.data["iso"]  # ISO format check


class TestFormatDate:
    @pytest.mark.asyncio
    async def test_default_format(self):
        result = await format_date.execute(date_string="2024-01-15")
        assert result.success is True
        assert result.data == "January 15, 2024"

    @pytest.mark.asyncio
    async def test_custom_format(self):
        result = await format_date.execute(
            date_string="2024-01-15",
            output_format="%d/%m/%Y"
        )
        assert result.data == "15/01/2024"

    @pytest.mark.asyncio
    async def test_invalid_date_raises_error(self):
        result = await format_date.execute(date_string="not-a-date")
        assert result.success is False
        assert "error" in result.error.lower() or "invalid" in result.error.lower()
```

### Pattern 2: Async Handler with API Mocking

For tools that make HTTP requests (e.g., `weather_tools.py`, `currency_tools.py`):

```python
import pytest
from unittest.mock import patch, AsyncMock
import httpx

from tool_master.tools.currency_tools import convert_currency


class TestConvertCurrency:
    @pytest.mark.asyncio
    async def test_successful_conversion(self):
        """Test with mocked API response."""
        mock_response = {
            "amount": 100.0,
            "base": "USD",
            "date": "2024-01-15",
            "rates": {"EUR": 0.92}
        }

        with patch("tool_master.tools.currency_tools.httpx.AsyncClient") as mock_client:
            mock_instance = AsyncMock()
            mock_instance.get.return_value = AsyncMock(
                status_code=200,
                json=lambda: mock_response
            )
            mock_client.return_value.__aenter__.return_value = mock_instance

            result = await convert_currency.execute(
                amount=100.0,
                from_currency="USD",
                to_currency="EUR"
            )

        assert result.success is True
        assert result.data["from_currency"] == "USD"
        assert result.data["to_currency"] == "EUR"

    @pytest.mark.asyncio
    async def test_api_error_handling(self):
        """Test handling of API errors."""
        with patch("tool_master.tools.currency_tools.httpx.AsyncClient") as mock_client:
            mock_instance = AsyncMock()
            mock_instance.get.return_value = AsyncMock(
                status_code=404,
                text="Currency not found"
            )
            mock_client.return_value.__aenter__.return_value = mock_instance

            result = await convert_currency.execute(
                amount=100.0,
                from_currency="USD",
                to_currency="INVALID"
            )

        assert result.success is False

    @pytest.mark.asyncio
    async def test_timeout_handling(self):
        """Test handling of request timeout."""
        with patch("tool_master.tools.currency_tools.httpx.AsyncClient") as mock_client:
            mock_instance = AsyncMock()
            mock_instance.get.side_effect = httpx.TimeoutException("timeout")
            mock_client.return_value.__aenter__.return_value = mock_instance

            result = await convert_currency.execute(
                amount=100.0,
                from_currency="USD",
                to_currency="EUR"
            )

        assert result.success is False
```

### Pattern 3: Environment Variable Mocking

For tools requiring API keys (e.g., `weather_tools.py`, `news_tools.py`):

```python
import os
import pytest
from unittest.mock import patch

from tool_master.tools.weather_tools import get_weather


class TestGetWeather:
    @pytest.mark.asyncio
    async def test_missing_api_key_error(self):
        """Test error when API key is not set."""
        with patch.dict(os.environ, {}, clear=True):
            # Also patch the module-level variable
            with patch("tool_master.tools.weather_tools.WEATHER_API_KEY", ""):
                result = await get_weather.execute(location="London")

        assert result.success is False
        assert "api key" in result.error.lower()

    @pytest.mark.asyncio
    async def test_with_valid_api_key(self):
        """Test with mocked API key and response."""
        mock_response = {
            "location": {"name": "London", "country": "UK"},
            "current": {"temp_c": 15, "condition": {"text": "Cloudy"}}
        }

        with patch.dict(os.environ, {"WEATHER_API_KEY": "test-key"}):
            with patch("tool_master.tools.weather_tools.httpx.AsyncClient") as mock:
                mock_instance = AsyncMock()
                mock_instance.get.return_value = AsyncMock(
                    status_code=200,
                    json=lambda: mock_response
                )
                mock.return_value.__aenter__.return_value = mock_instance

                result = await get_weather.execute(location="London")

        assert result.success is True
```

### Pattern 4: External Library Mocking

For tools using external libraries (e.g., `finance_tools.py` with yfinance):

```python
import pytest
from unittest.mock import patch, MagicMock

from tool_master.tools.finance_tools import get_stock_quote


class TestGetStockQuote:
    @pytest.mark.asyncio
    async def test_successful_quote(self):
        """Test with mocked yfinance response."""
        mock_ticker = MagicMock()
        mock_ticker.info = {
            "regularMarketPrice": 150.25,
            "shortName": "Apple Inc.",
            "symbol": "AAPL",
            "regularMarketChange": 2.50,
            "regularMarketChangePercent": 1.69,
        }

        with patch("tool_master.tools.finance_tools.yf.Ticker", return_value=mock_ticker):
            result = await get_stock_quote.execute(symbol="AAPL")

        assert result.success is True
        assert result.data["symbol"] == "AAPL"
        assert result.data["price"]["current"] == 150.25

    @pytest.mark.asyncio
    async def test_invalid_symbol(self):
        """Test handling of invalid stock symbol."""
        mock_ticker = MagicMock()
        mock_ticker.info = {"regularMarketPrice": None}

        with patch("tool_master.tools.finance_tools.yf.Ticker", return_value=mock_ticker):
            result = await get_stock_quote.execute(symbol="INVALID123")

        assert result.success is False

    @pytest.mark.asyncio
    async def test_library_not_installed(self):
        """Test error when yfinance is not installed."""
        with patch.dict("sys.modules", {"yfinance": None}):
            with patch("tool_master.tools.finance_tools.yf", None):
                # The import guard in the handler should catch this
                result = await get_stock_quote.execute(symbol="AAPL")

        # Depends on implementation - may succeed if already imported
```

### Pattern 5: File I/O Tools

For tools in `file_tools.py`:

```python
import pytest
import tempfile
import os
from pathlib import Path

from tool_master.tools.file_tools import read_json, write_json, read_csv


class TestReadJson:
    @pytest.mark.asyncio
    async def test_read_valid_json(self, tmp_path):
        """Test reading a valid JSON file."""
        json_file = tmp_path / "test.json"
        json_file.write_text('{"key": "value", "number": 42}')

        result = await read_json.execute(file_path=str(json_file))

        assert result.success is True
        assert result.data["key"] == "value"
        assert result.data["number"] == 42

    @pytest.mark.asyncio
    async def test_read_nonexistent_file(self):
        """Test error when file doesn't exist."""
        result = await read_json.execute(file_path="/nonexistent/file.json")

        assert result.success is False
        assert "not found" in result.error.lower() or "exist" in result.error.lower()

    @pytest.mark.asyncio
    async def test_read_invalid_json(self, tmp_path):
        """Test error when file contains invalid JSON."""
        json_file = tmp_path / "invalid.json"
        json_file.write_text("not valid json {")

        result = await read_json.execute(file_path=str(json_file))

        assert result.success is False


class TestWriteJson:
    @pytest.mark.asyncio
    async def test_write_and_read_back(self, tmp_path):
        """Test writing JSON and reading it back."""
        json_file = tmp_path / "output.json"
        data = {"name": "test", "values": [1, 2, 3]}

        write_result = await write_json.execute(
            file_path=str(json_file),
            data=data
        )
        assert write_result.success is True

        read_result = await read_json.execute(file_path=str(json_file))
        assert read_result.success is True
        assert read_result.data == data
```

## Fixtures

### Reusable Test Tool Fixture

Based on the pattern in `tests/test_executors.py`:

```python
@pytest.fixture
def sample_tool():
    """Create a simple test tool with handler."""
    def handler(message: str, count: int = 1) -> str:
        return message * count

    return Tool(
        name="repeat_message",
        description="Repeat a message multiple times",
        parameters=[
            ToolParameter(
                name="message",
                type=ParameterType.STRING,
                description="The message to repeat",
                required=True,
            ),
            ToolParameter(
                name="count",
                type=ParameterType.INTEGER,
                description="Number of times to repeat",
                required=False,
                default=1,
            ),
        ],
        category="text",
        tags=["string", "utility"],
    ).set_handler(handler)
```

### Mock HTTP Client Fixture

```python
@pytest.fixture
def mock_httpx_client():
    """Create a reusable mock httpx client."""
    with patch("httpx.AsyncClient") as mock:
        mock_instance = AsyncMock()
        mock.return_value.__aenter__.return_value = mock_instance
        yield mock_instance
```

### Temporary File Fixture

```python
@pytest.fixture
def temp_json_file(tmp_path):
    """Create a temporary JSON file for testing."""
    file_path = tmp_path / "test_data.json"
    file_path.write_text('{"test": true}')
    return file_path
```

## Testing Checklist

When writing tests for a tool, cover:

1. **Schema Tests**

   - [ ] Tool name is correct
   - [ ] Description is meaningful
   - [ ] Required parameters are marked required
   - [ ] Optional parameters have defaults

2. **Happy Path Tests**

   - [ ] Basic execution with minimal params
   - [ ] Execution with all optional params
   - [ ] Various valid input combinations

3. **Error Handling Tests**

   - [ ] Missing required parameters
   - [ ] Invalid parameter types
   - [ ] Invalid parameter values (out of range, bad format)
   - [ ] Missing API keys (if applicable)
   - [ ] API errors (timeout, 404, 500)
   - [ ] Missing dependencies (import guards)

4. **Edge Cases**
   - [ ] Empty inputs where applicable
   - [ ] Boundary values (max/min)
   - [ ] Special characters in strings
   - [ ] Unicode handling

## Running Tests

```bash
# Run all tests
pytest

# Run specific test file
pytest tests/test_datetime_tools.py

# Run with coverage
pytest --cov=tool_master --cov-report=html

# Run only async tests
pytest -m asyncio

# Run with verbose output
pytest -v
```

## Project Configuration

From `pyproject.toml`:

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
asyncio_mode = "auto"
```

The `asyncio_mode = "auto"` means `@pytest.mark.asyncio` is automatically applied to async test functions.
