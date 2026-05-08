---
name: streamlit-uv-development
description: Use this skill when developing Streamlit applications with uv package manager. Covers project setup, running apps, testing (unit/e2e), and development workflows. Trigger when user mentions "streamlit", "uv run streamlit", "streamlit testing", or asks about building data apps with Python.
---

# Streamlit Development with uv

## Overview

This skill enables rapid Streamlit application development using uv as the package manager. It covers project initialization, running apps, testing strategies, and production-ready development patterns.

## Quick Start

### Create New Streamlit Project

```bash
# Create project directory
mkdir my-streamlit-app && cd my-streamlit-app

# Initialize with uv
uv init --name my-streamlit-app

# Add streamlit dependency
uv add streamlit

# Create main app file
cat > app.py << 'EOF'
import streamlit as st

st.set_page_config(page_title="My App", page_icon="📊", layout="wide")

st.title("Hello, Streamlit!")
st.write("Welcome to your new app.")
EOF

# Run the app
uv run streamlit run app.py
```

### Run Existing Streamlit App

```bash
# With uv (preferred)
uv run streamlit run app.py

# With options
uv run streamlit run app.py --server.port 8501 --server.headless true

# With browser disabled (for CI/testing)
uv run streamlit run app.py --server.headless true --browser.serverAddress localhost
```

## Project Structure

### Recommended Layout

```
my-streamlit-app/
├── pyproject.toml          # Project config with uv
├── uv.lock                  # Lock file (commit this)
├── .python-version          # Python version pin
├── app.py                   # Main entry point (or src/app.py)
├── pages/                   # Multi-page app pages
│   ├── 1_📊_Dashboard.py
│   ├── 2_📈_Analytics.py
│   └── 3_⚙️_Settings.py
├── components/              # Custom components
│   └── sidebar.py
├── utils/                   # Helper functions
│   ├── __init__.py
│   ├── data.py
│   └── charts.py
├── tests/                   # Test files
│   ├── conftest.py
│   ├── test_utils.py
│   └── e2e/
│       └── test_app.py
├── .streamlit/              # Streamlit config
│   ├── config.toml
│   └── secrets.toml         # (gitignored)
└── data/                    # Static data files
```

### pyproject.toml Example

```toml
[project]
name = "my-streamlit-app"
version = "0.1.0"
description = "A Streamlit data application"
requires-python = ">=3.10"
dependencies = [
    "streamlit>=1.40.0",
    "pandas>=2.0.0",
    "plotly>=5.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "pytest-playwright>=0.5.0",
    "ruff>=0.8.0",
]

[tool.uv]
dev-dependencies = [
    "pytest>=8.0.0",
    "pytest-playwright>=0.5.0",
    "ruff>=0.8.0",
]

[tool.ruff]
line-length = 100
target-version = "py310"

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
```

## Testing Strategies

### Unit Testing (Logic & Utils)

Test business logic without Streamlit context:

```python
# tests/test_utils.py
import pytest
from utils.data import process_data, validate_input

def test_process_data_with_valid_input():
    data = {"value": 10, "multiplier": 2}
    result = process_data(data)
    assert result == 20

def test_validate_input_rejects_negative():
    with pytest.raises(ValueError, match="must be positive"):
        validate_input(-5)
```

Run unit tests:

```bash
uv run pytest tests/test_utils.py -v
```

### Testing Streamlit Components with AppTest

Use Streamlit's built-in `AppTest` for headless testing:

```python
# tests/test_app.py
import pytest
from streamlit.testing.v1 import AppTest

def test_app_loads():
    """Test that the app loads without errors."""
    at = AppTest.from_file("app.py")
    at.run()
    assert not at.exception

def test_sidebar_selection():
    """Test sidebar widget interactions."""
    at = AppTest.from_file("app.py")
    at.run()

    # Interact with selectbox
    at.selectbox[0].select("Option B").run()
    assert at.session_state["selected"] == "Option B"

def test_button_click_updates_state():
    """Test button click behavior."""
    at = AppTest.from_file("app.py")
    at.run()

    # Click button
    at.button[0].click().run()
    assert "result" in at.session_state

def test_form_submission():
    """Test form with multiple inputs."""
    at = AppTest.from_file("app.py")
    at.run()

    # Fill form fields
    at.text_input[0].input("John Doe").run()
    at.number_input[0].set_value(25).run()
    at.button("Submit").click().run()

    # Check success message appears
    assert len(at.success) > 0
```

### E2E Testing with Playwright

For full browser-based testing:

```python
# tests/e2e/test_app.py
import pytest
from playwright.sync_api import Page, expect
import subprocess
import time

@pytest.fixture(scope="module")
def streamlit_app():
    """Start Streamlit app for testing."""
    proc = subprocess.Popen(
        ["uv", "run", "streamlit", "run", "app.py",
         "--server.headless", "true", "--server.port", "8599"],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    time.sleep(5)  # Wait for startup
    yield "http://localhost:8599"
    proc.terminate()
    proc.wait()

def test_homepage_loads(page: Page, streamlit_app: str):
    """Test that homepage renders correctly."""
    page.goto(streamlit_app)
    expect(page.locator("h1")).to_contain_text("Hello")

def test_sidebar_navigation(page: Page, streamlit_app: str):
    """Test sidebar navigation works."""
    page.goto(streamlit_app)
    page.click("text=Dashboard")
    expect(page).to_have_url(f"{streamlit_app}/Dashboard")

def test_data_input_and_display(page: Page, streamlit_app: str):
    """Test data entry workflow."""
    page.goto(streamlit_app)
    page.fill("input[aria-label='Enter value']", "42")
    page.click("button:has-text('Calculate')")
    expect(page.locator(".stSuccess")).to_be_visible()
```

Run E2E tests:

```bash
# Install playwright browsers first
uv run playwright install chromium

# Run E2E tests
uv run pytest tests/e2e/ -v
```

### Test Fixtures for Streamlit

```python
# tests/conftest.py
import pytest
import pandas as pd
from streamlit.testing.v1 import AppTest

@pytest.fixture
def sample_dataframe():
    """Provide sample data for tests."""
    return pd.DataFrame({
        "name": ["Alice", "Bob", "Charlie"],
        "value": [100, 200, 300],
    })

@pytest.fixture
def app_test():
    """Provide fresh AppTest instance."""
    at = AppTest.from_file("app.py")
    at.run()
    return at

@pytest.fixture
def app_with_session_state():
    """Provide AppTest with preset session state."""
    at = AppTest.from_file("app.py")
    at.session_state["user_authenticated"] = True
    at.session_state["username"] = "testuser"
    at.run()
    return at
```

## Development Workflows

### Live Development with Hot Reload

```bash
# Start with auto-reload (default)
uv run streamlit run app.py

# Disable for production testing
uv run streamlit run app.py --server.runOnSave false
```

### Multi-Page App Development

```python
# pages/1_📊_Dashboard.py
import streamlit as st

st.set_page_config(page_title="Dashboard", page_icon="📊")
st.title("Dashboard")

# Access shared session state
if "data" not in st.session_state:
    st.session_state.data = None

# Page-specific content
col1, col2 = st.columns(2)
with col1:
    st.metric("Total Users", 1234, delta=56)
with col2:
    st.metric("Revenue", "$45,678", delta="12%")
```

### Environment & Secrets Management

```bash
# .streamlit/secrets.toml (gitignored)
[database]
host = "localhost"
port = 5432
username = "admin"
password = "secret123"

[api]
key = "sk-..."
```

```python
# Access in app
import streamlit as st

db_host = st.secrets["database"]["host"]
api_key = st.secrets["api"]["key"]
```

### Docker Deployment

```dockerfile
# Dockerfile
FROM python:3.11-slim

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

WORKDIR /app

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install dependencies
RUN uv sync --frozen --no-dev

# Copy app code
COPY . .

# Expose port
EXPOSE 8501

# Health check
HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health

# Run app
CMD ["uv", "run", "streamlit", "run", "app.py", \
     "--server.port=8501", "--server.address=0.0.0.0", \
     "--server.headless=true"]
```

Build and run:

```bash
docker build -t my-streamlit-app .
docker run -p 8501:8501 my-streamlit-app
```

## Common Patterns

### Session State Management

```python
import streamlit as st

# Initialize state
if "counter" not in st.session_state:
    st.session_state.counter = 0

# Update with callback
def increment():
    st.session_state.counter += 1

st.button("Increment", on_click=increment)
st.write(f"Count: {st.session_state.counter}")
```

### Caching Data and Resources

```python
import streamlit as st
import pandas as pd

@st.cache_data(ttl=3600)  # Cache for 1 hour
def load_data(url: str) -> pd.DataFrame:
    return pd.read_csv(url)

@st.cache_resource  # Cache across sessions
def get_database_connection():
    return create_connection()

# Use cached data
df = load_data("https://example.com/data.csv")
```

### Error Handling in Apps

```python
import streamlit as st

try:
    result = risky_operation()
    st.success(f"Operation completed: {result}")
except ValueError as e:
    st.error(f"Invalid input: {e}")
except ConnectionError:
    st.warning("Connection failed. Please try again.")
    if st.button("Retry"):
        st.rerun()
except Exception as e:
    st.exception(e)  # Shows full traceback
```

### Forms for Batch Input

```python
import streamlit as st

with st.form("user_form"):
    name = st.text_input("Name")
    age = st.number_input("Age", min_value=0, max_value=120)
    email = st.text_input("Email")

    submitted = st.form_submit_button("Submit")

    if submitted:
        if not name or not email:
            st.error("Name and email are required")
        else:
            st.success(f"Welcome, {name}!")
            # Process form data
```

## Troubleshooting

### Common Issues

**Port already in use:**
```bash
# Find and kill process
lsof -i :8501 | grep LISTEN
kill -9 <PID>

# Or use different port
uv run streamlit run app.py --server.port 8502
```

**Import errors with uv:**
```bash
# Ensure dependencies are synced
uv sync

# Check installed packages
uv pip list
```

**Widget state issues:**
```python
# Use key parameter for dynamic widgets
for i, item in enumerate(items):
    st.text_input(f"Item {i}", key=f"input_{i}")
```

**Slow app reload:**
```python
# Move expensive operations outside main flow
@st.cache_data
def expensive_computation():
    # This runs once and is cached
    return compute_result()
```

## Resources

- [Streamlit Documentation](https://docs.streamlit.io)
- [Streamlit AppTest API](https://docs.streamlit.io/develop/api-reference/app-testing)
- [uv Documentation](https://docs.astral.sh/uv/)
- [Playwright Python](https://playwright.dev/python/)
