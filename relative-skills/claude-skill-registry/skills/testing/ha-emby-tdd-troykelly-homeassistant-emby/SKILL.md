---
name: ha-emby-tdd
description: Use when implementing ANY code for the Home Assistant Emby integration - enforces strict TDD with RED-GREEN-REFACTOR cycle, requiring tests to fail before implementation and pass after. No exceptions for simple code.
---

# Home Assistant Emby TDD

## Overview

**All code for the HA Emby integration MUST follow strict Test-Driven Development.**

Write the test first. Watch it fail. Write minimal code to pass. Refactor. No exceptions.

## The Iron Law

```
NO CODE WITHOUT A FAILING TEST FIRST
```

This is non-negotiable. Every function, method, class, and feature starts with a test.

**Write code before test? Delete it. Start over.**

**No exceptions:**
- Not for "simple functions"
- Not for "obvious implementations"
- Not for "just adding a property"
- Not for config flow steps
- Not for entity attributes
- Delete means delete - don't keep as "reference"

## RED-GREEN-REFACTOR Cycle

### RED: Write Failing Test

```python
# tests/test_media_player.py
async def test_play_media_sends_correct_api_call(
    hass: HomeAssistant,
    mock_emby_client: MagicMock,
) -> None:
    """Test play_media calls Emby API correctly."""
    entity = create_media_player_entity(hass, mock_emby_client)

    await entity.async_play_media(
        media_type=MediaType.MOVIE,
        media_id="movie-123",
    )

    mock_emby_client.play_item.assert_called_once_with(
        item_id="movie-123",
        play_command="PlayNow",
    )
```

Run the test. **It MUST fail.** If it passes, your test is wrong.

### GREEN: Write Minimal Implementation

```python
# custom_components/embymedia/media_player.py
async def async_play_media(
    self,
    media_type: MediaType,
    media_id: str,
    enqueue: MediaPlayerEnqueue | None = None,
    announce: bool | None = None,
    **kwargs: Any,  # Required by HA interface
) -> None:
    """Play media on the Emby device."""
    await self._client.play_item(
        item_id=media_id,
        play_command="PlayNow",
    )
```

Run the test. **It MUST pass now.**

### REFACTOR: Improve Without Breaking

Only refactor when tests pass. Keep them passing throughout.

## Testing Patterns for HA Emby

### Config Flow Tests

```python
async def test_config_flow_user_step_success(
    hass: HomeAssistant,
    mock_emby_client: MagicMock,
) -> None:
    """Test successful user config flow."""
    result = await hass.config_entries.flow.async_init(
        DOMAIN,
        context={"source": config_entries.SOURCE_USER},
    )
    assert result["type"] is FlowResultType.FORM

    mock_emby_client.authenticate.return_value = True

    result = await hass.config_entries.flow.async_configure(
        result["flow_id"],
        user_input={
            CONF_HOST: "emby.local",
            CONF_PORT: 8096,
            CONF_API_KEY: "test-api-key",
        },
    )

    assert result["type"] is FlowResultType.CREATE_ENTRY
    assert result["title"] == "Emby Server"
```

### Entity Tests

```python
async def test_media_player_state_playing(
    hass: HomeAssistant,
    mock_config_entry: MockConfigEntry,
    mock_emby_client: MagicMock,
) -> None:
    """Test media player reports playing state."""
    mock_emby_client.get_playstate.return_value = PlayState(
        is_playing=True,
        is_paused=False,
    )

    mock_config_entry.add_to_hass(hass)
    await hass.config_entries.async_setup(mock_config_entry.entry_id)
    await hass.async_block_till_done()

    state = hass.states.get("media_player.emby_living_room")
    assert state.state == MediaPlayerState.PLAYING
```

### Fixtures (conftest.py)

```python
@pytest.fixture
def mock_emby_client() -> Generator[MagicMock, None, None]:
    """Mock the Emby API client."""
    with patch(
        "custom_components.embymedia.EmbyClient",
        autospec=True,
    ) as mock:
        client = mock.return_value
        client.authenticate.return_value = True
        client.get_server_info.return_value = ServerInfo(
            name="Test Server",
            id="server-123",
            version="4.8.0",
        )
        yield client


@pytest.fixture
def mock_config_entry() -> MockConfigEntry:
    """Create a mock config entry."""
    return MockConfigEntry(
        domain=DOMAIN,
        data={
            CONF_HOST: "emby.local",
            CONF_PORT: 8096,
            CONF_API_KEY: "test-api-key",
        },
        unique_id="server-123",
    )
```

## Test Coverage Requirements

**Minimum coverage: 100% for all new code**

Every code path must be tested:
- Happy paths
- Error conditions
- Edge cases
- All config flow branches
- All entity states

Run coverage check:
```bash
pytest tests/ --cov=custom_components.embymedia --cov-report=term-missing --cov-fail-under=100
```

## Common Rationalizations (All Wrong)

| Excuse | Reality |
|--------|---------|
| "It's just a property" | Properties have bugs. Test it. |
| "The API client is already tested" | Integration layer needs tests. Test it. |
| "I'll add tests after" | Tests-after prove nothing. Test first. |
| "Config flow is boilerplate" | Boilerplate has bugs. Test it. |
| "It's obvious how this works" | Obvious code breaks. Test it. |
| "Manual testing is enough" | Manual tests don't catch regressions. Write automated tests. |

## Red Flags - STOP and Start Over

If you catch yourself with ANY of these, delete your code and restart with TDD:

- Code exists without corresponding test
- Test was written after implementation
- "I'll refactor the test later"
- "The existing tests cover this"
- "This is too simple to test"
- Test passes on first run (test is wrong)

## Running Tests

```bash
# Run all tests
pytest tests/

# Run with coverage
pytest tests/ --cov=custom_components.embymedia --cov-report=term-missing

# Run specific test file
pytest tests/test_config_flow.py

# Run single test
pytest tests/test_media_player.py::test_play_media_sends_correct_api_call

# Stop on first failure
pytest tests/ -x
```

## Integration with pytest-homeassistant-custom-component

Use the `pytest-homeassistant-custom-component` package for HA-specific fixtures:

```python
from pytest_homeassistant_custom_component.common import (
    MockConfigEntry,
    async_fire_time_changed,
)
```

Key fixtures available:
- `hass` - Mock Home Assistant instance
- `aioclient_mock` - Mock aiohttp client sessions
- `enable_custom_integrations` - Enable custom component loading

## Live Server Testing

For integration tests against a real Emby server, use environment variables.

### Environment Variables

```bash
# Set in .env file (loaded by devcontainer)
EMBY_URL=https://your-emby-server.example.com
EMBY_API_KEY=your-api-key-here
```

### Accessing Environment Variables

**NEVER read `.env` files directly.** Always use `os.environ`:

```python
import os

# CORRECT
emby_url = os.environ.get("EMBY_URL")
emby_api_key = os.environ.get("EMBY_API_KEY")

# WRONG - Never do this
# from dotenv import load_dotenv
# load_dotenv()
```

### Live Test Fixtures

```python
import os
import pytest

@pytest.fixture
def live_emby_url() -> str | None:
    """Get live Emby URL from environment."""
    return os.environ.get("EMBY_URL")

@pytest.fixture
def live_emby_api_key() -> str | None:
    """Get live Emby API key from environment."""
    return os.environ.get("EMBY_API_KEY")

@pytest.fixture
def requires_live_server(
    live_emby_url: str | None,
    live_emby_api_key: str | None,
) -> None:
    """Skip test if live server credentials not available."""
    if not live_emby_url or not live_emby_api_key:
        pytest.skip("EMBY_URL and EMBY_API_KEY required for live tests")
```

### Live Test Example

```python
@pytest.mark.usefixtures("requires_live_server")
async def test_live_server_connection(
    live_emby_url: str,
    live_emby_api_key: str,
) -> None:
    """Test connection to live Emby server."""
    client = EmbyApiClient(url=live_emby_url, api_key=live_emby_api_key)
    server_info = await client.async_get_server_info()
    assert server_info.server_id is not None
```

### Running Live Tests

```bash
# Live tests only run if environment variables are set
pytest tests/ -v

# Skip live tests explicitly
EMBY_URL= EMBY_API_KEY= pytest tests/ -v
```

## The Bottom Line

**Every line of code starts with a failing test.**

No shortcuts. No exceptions. No rationalizations.

RED → GREEN → REFACTOR. Always.
