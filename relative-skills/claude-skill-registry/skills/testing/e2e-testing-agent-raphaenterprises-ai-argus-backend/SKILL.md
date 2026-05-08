---
name: e2e-testing-agent
description: Build autonomous end-to-end full-stack testing agents using Claude's Computer Use API, LangGraph orchestration, and hybrid Playwright automation. Use this skill when building testing infrastructure, test automation, CI/CD test integration, or self-healing test systems.
version: 1.1.0
author: Vinay
---

# Autonomous E2E Testing Agent Skill

This skill provides comprehensive guidance for building fully autonomous end-to-end testing systems using Claude's capabilities.

## Quick Start

```bash
# Install dependencies
pip install anthropic langgraph playwright httpx pydantic

# Install Playwright browsers
playwright install chromium

# Set up environment
export ANTHROPIC_API_KEY=sk-ant-...

# Run the agent
e2e-agent --codebase /path/to/app --app-url http://localhost:3000
```

### Example Invocations

```python
# Basic usage
from e2e_testing_agent import TestingOrchestrator

orchestrator = TestingOrchestrator(
    codebase_path="/path/to/app",
    app_url="http://localhost:3000"
)
results = await orchestrator.run()

# Single test execution
result = await orchestrator.run_single_test({
    "id": "login-test",
    "name": "User Login Flow",
    "type": "ui",
    "steps": [
        {"action": "goto", "target": "/login"},
        {"action": "fill", "target": "#email", "value": "test@example.com"},
        {"action": "click", "target": "button[type=submit]"}
    ]
})
```

## Requirements

### Dependencies
```toml
anthropic = ">=0.40.0"
langgraph = ">=0.2.0"
playwright = ">=1.48.0"
httpx = ">=0.27.0"
pydantic = ">=2.9.0"
```

### API Compatibility
| Component | Version |
|-----------|---------|
| Computer Use API | `computer-use-2025-01-24` |
| Computer Tool | `computer_20250124` |
| Bash Tool | `bash_20250124` |
| Text Editor | `text_editor_20250728` |

### Supported Models
- **Claude Sonnet 4.5** - Primary testing (best cost/capability)
- **Claude Haiku 4.5** - Quick verifications
- **Claude Opus 4.5** - Complex debugging only

## When to Use This Skill

Use this skill when the user wants to:
- Build automated testing systems with AI capabilities
- Implement Computer Use API for browser automation
- Create self-healing test infrastructure
- Integrate AI-powered testing into CI/CD pipelines
- Build multi-agent testing orchestration with LangGraph

## Core Concepts

### 1. Computer Use API

Claude's Computer Use API enables visual interaction with desktop/browser environments:

```python
import anthropic

client = anthropic.Anthropic()

# Basic Computer Use call
response = client.beta.messages.create(
    model="claude-sonnet-4-5",
    max_tokens=4096,
    tools=[
        {
            "type": "computer_20250124",
            "name": "computer",
            "display_width_px": 1920,
            "display_height_px": 1080,
            "display_number": 1,
        },
        {"type": "bash_20250124", "name": "bash"},
        {"type": "text_editor_20250728", "name": "str_replace_based_edit_tool"}
    ],
    messages=[{"role": "user", "content": "Navigate to example.com and click Login"}],
    betas=["computer-use-2025-01-24"]
)
```

**Available Actions:**
- `screenshot` - Capture current screen state
- `mouse_move` - Move cursor to coordinates
- `left_click`, `right_click`, `double_click`, `triple_click`
- `type` - Enter text
- `key` - Press keyboard shortcuts
- `scroll` - Scroll in direction
- `hold_key` - Hold a key down
- `wait` - Pause for element loading

### 2. Agent Loop Pattern

Always implement Computer Use as an agent loop:

```python
async def run_computer_use_task(task: str, max_iterations: int = 30):
    messages = [{"role": "user", "content": task}]
    
    for i in range(max_iterations):
        response = client.beta.messages.create(
            model="claude-sonnet-4-5",
            max_tokens=4096,
            tools=COMPUTER_USE_TOOLS,
            messages=messages,
            betas=["computer-use-2025-01-24"]
        )
        
        # Check if done
        if response.stop_reason == "end_turn":
            return extract_result(response)
        
        # Process tool calls
        tool_results = []
        for block in response.content:
            if block.type == "tool_use":
                result = await execute_tool(block.name, block.input)
                tool_results.append({
                    "type": "tool_result",
                    "tool_use_id": block.id,
                    "content": result
                })
        
        # Continue conversation
        messages.append({"role": "assistant", "content": response.content})
        messages.append({"role": "user", "content": tool_results})
    
    raise MaxIterationsExceeded()
```

### 3. Hybrid Testing Strategy

Combine Playwright (fast, reliable) with Computer Use (visual verification):

```python
class HybridTester:
    def __init__(self):
        self.playwright = sync_playwright().start()
        self.browser = self.playwright.chromium.launch()
        self.page = self.browser.new_page()
        self.claude_client = anthropic.Anthropic()
    
    async def test_login_flow(self):
        # Use Playwright for fast actions
        await self.page.goto("https://app.example.com/login")
        await self.page.fill("#email", "test@example.com")
        await self.page.fill("#password", "password123")
        await self.page.click("button[type=submit]")
        
        # Use Claude for visual verification
        screenshot = await self.page.screenshot()
        verification = await self.verify_with_claude(
            screenshot,
            "Verify the user is logged in and sees the dashboard"
        )
        
        return verification
    
    async def verify_with_claude(self, screenshot: bytes, assertion: str):
        response = self.claude_client.messages.create(
            model="claude-haiku-4-5",  # Fast model for verification
            max_tokens=500,
            messages=[{
                "role": "user",
                "content": [
                    {
                        "type": "image",
                        "source": {
                            "type": "base64",
                            "media_type": "image/png",
                            "data": base64.b64encode(screenshot).decode()
                        }
                    },
                    {
                        "type": "text",
                        "text": f"Verify: {assertion}\nRespond with JSON: {{\"passed\": boolean, \"reason\": string}}"
                    }
                ]
            }]
        )
        return json.loads(response.content[0].text)
```

### 4. LangGraph Orchestration

Structure the testing system as a state machine:

```python
from langgraph.graph import StateGraph, END
from typing import TypedDict, Annotated
from langgraph.graph.message import add_messages

class TestState(TypedDict):
    messages: Annotated[list, add_messages]
    codebase_context: str
    test_plan: list[dict]
    current_test: int
    results: list[dict]
    failures: list[dict]
    next_step: str

def create_testing_graph():
    graph = StateGraph(TestState)
    
    # Add nodes
    graph.add_node("analyze_code", analyze_codebase)
    graph.add_node("plan_tests", create_test_plan)
    graph.add_node("execute_ui_test", run_ui_test)
    graph.add_node("execute_api_test", run_api_test)
    graph.add_node("self_heal", heal_failed_test)
    graph.add_node("report", generate_report)
    
    # Define edges
    graph.add_edge("analyze_code", "plan_tests")
    graph.add_conditional_edges(
        "plan_tests",
        route_to_test_type,
        {
            "ui": "execute_ui_test",
            "api": "execute_api_test",
            "done": "report"
        }
    )
    graph.add_conditional_edges(
        "execute_ui_test",
        check_test_result,
        {
            "pass": "plan_tests",  # Next test
            "fail": "self_heal",
            "done": "report"
        }
    )
    graph.add_edge("self_heal", "execute_ui_test")  # Retry after healing
    graph.add_edge("report", END)
    
    graph.set_entry_point("analyze_code")
    return graph.compile()
```

### 5. Self-Healing Tests

Implement automatic test repair:

```python
class SelfHealingAgent:
    def __init__(self):
        self.client = anthropic.Anthropic()
    
    async def heal_test(self, test_spec: dict, failure: dict, screenshot: bytes):
        prompt = f"""You are a test self-healing agent. A test has failed.

TEST SPECIFICATION:
{json.dumps(test_spec, indent=2)}

FAILURE DETAILS:
{json.dumps(failure, indent=2)}

CURRENT SCREENSHOT:
[Attached]

Analyze the failure and determine the fix:
1. If selector changed - provide new selector
2. If timing issue - suggest wait strategy
3. If UI changed intentionally - update assertion
4. If real bug - mark as actual failure

Respond with JSON:
{{
    "diagnosis": "selector_changed|timing_issue|ui_change|real_bug",
    "fix": {{
        "type": "update_selector|add_wait|update_assertion|none",
        "old_value": "...",
        "new_value": "..."
    }},
    "confidence": 0.0-1.0,
    "explanation": "..."
}}
"""
        response = self.client.messages.create(
            model="claude-sonnet-4-5",
            max_tokens=1000,
            messages=[{
                "role": "user",
                "content": [
                    {"type": "image", "source": {"type": "base64", "media_type": "image/png", "data": base64.b64encode(screenshot).decode()}},
                    {"type": "text", "text": prompt}
                ]
            }]
        )
        return json.loads(response.content[0].text)
```

### 6. Cost Optimization

Monitor and control API costs:

```python
class CostTracker:
    # Pricing per million tokens (December 2025)
    PRICING = {
        "claude-opus-4-5": {"input": 5.00, "output": 25.00},
        "claude-sonnet-4-5": {"input": 3.00, "output": 15.00},
        "claude-haiku-4-5": {"input": 0.25, "output": 1.25},
    }
    
    # Screenshot token estimates by resolution
    SCREENSHOT_TOKENS = {
        (1024, 768): 1500,
        (1920, 1080): 2500,
        (2560, 1440): 4000,
    }
    
    def __init__(self, budget_limit: float = 10.0):
        self.budget_limit = budget_limit
        self.total_cost = 0.0
        self.usage_log = []
    
    def track_usage(self, model: str, input_tokens: int, output_tokens: int):
        pricing = self.PRICING[model]
        cost = (input_tokens * pricing["input"] + output_tokens * pricing["output"]) / 1_000_000
        self.total_cost += cost
        self.usage_log.append({
            "model": model,
            "input_tokens": input_tokens,
            "output_tokens": output_tokens,
            "cost": cost,
            "cumulative": self.total_cost
        })
        
        if self.total_cost > self.budget_limit:
            raise BudgetExceeded(f"Budget of ${self.budget_limit} exceeded")
        
        return cost
```

### 7. Test Specification Format

Use structured test specifications:

```python
TEST_SPEC_SCHEMA = {
    "id": "string",
    "name": "string",
    "type": "ui|api|db",
    "priority": "critical|high|medium|low",
    "preconditions": ["list of setup steps"],
    "steps": [
        {
            "action": "goto|click|fill|assert|wait|screenshot",
            "target": "selector or url",
            "value": "optional value",
            "timeout": 5000
        }
    ],
    "assertions": [
        {
            "type": "element_visible|text_contains|url_matches|visual_match",
            "target": "...",
            "expected": "..."
        }
    ],
    "cleanup": ["list of teardown steps"],
    "tags": ["regression", "smoke", "critical-path"]
}
```

## Best Practices

### DO:
- ✅ Always set max_iterations to prevent runaway costs
- ✅ Use lower resolution screenshots when possible (1024x768)
- ✅ Implement exponential backoff for retries
- ✅ Cache codebase analysis between test runs
- ✅ Use Haiku for quick verifications, Sonnet for complex reasoning
- ✅ Log all Claude API calls with full context for debugging
- ✅ Run Computer Use in Docker sandboxes only

### DON'T:
- ❌ Never run Computer Use against production systems
- ❌ Don't use Opus unless debugging complex failures
- ❌ Avoid taking screenshots after every action (batch them)
- ❌ Don't store API keys in code - use environment variables
- ❌ Never assume a single screenshot is enough - verify state

## Prompting Guidelines

### For Code Analysis:
```
Analyze this codebase to identify testable surfaces:
1. List all user-facing pages/routes
2. Identify API endpoints
3. Find database models/tables
4. Note authentication flows
5. Map critical user journeys

Focus on areas with: high user traffic, payment/sensitive data, recent changes.
```

### For Test Generation:
```
Generate comprehensive E2E tests for this feature:
- Cover happy path and edge cases
- Include error handling scenarios
- Add visual regression checkpoints
- Consider mobile/responsive views
- Include accessibility checks

Format as structured JSON following the TEST_SPEC_SCHEMA.
```

### For Computer Use Tasks:
```
Execute this test autonomously:
{test_spec}

CRITICAL INSTRUCTIONS:
1. After each action, take a screenshot and verify the result
2. If an element is not found, wait up to 10 seconds before failing
3. If something unexpected happens, document it and continue if possible
4. Take a final screenshot showing the end state
5. Report exactly what you observed vs what was expected
```

### For Self-Healing:
```
Analyze this test failure and determine the root cause:
- Was this a selector change? (element moved/renamed)
- Was this a timing issue? (element not loaded in time)
- Was this an intentional UI change? (expected behavior changed)
- Was this an actual bug? (unexpected behavior)

Provide a specific fix with high confidence, or flag for human review.
```

## Integration Examples

### GitHub Actions Integration:
```yaml
name: AI E2E Tests
on:
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Start test server
        run: docker-compose up -d
        
      - name: Run AI E2E Tests
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          python -m e2e_testing_agent \
            --codebase . \
            --app-url http://localhost:3000 \
            --output results/
            
      - name: Upload Results
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: results/
```

### n8n Webhook Integration:
```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()

class TestRequest(BaseModel):
    repo_url: str
    branch: str
    preview_url: str
    pr_number: int

@app.post("/webhook/run-tests")
async def run_tests(request: TestRequest):
    orchestrator = TestingOrchestrator(
        codebase_url=request.repo_url,
        branch=request.branch,
        app_url=request.preview_url
    )
    
    results = await orchestrator.run_changed_file_tests()
    
    # Post results back to GitHub PR
    await post_github_check(
        pr_number=request.pr_number,
        results=results
    )
    
    return {"status": "completed", "summary": results.summary}
```

## Troubleshooting

### Computer Use Not Working
1. Verify beta header: `betas=["computer-use-2025-01-24"]`
2. Check tool type version: `computer_20250124`
3. Ensure sandbox environment is running
4. Verify screenshot is being captured correctly

### High Token Costs
1. Reduce screenshot resolution
2. Use Haiku for simple verifications
3. Implement prompt caching for system prompts
4. Batch related test assertions

### Flaky Tests
1. Add explicit waits before assertions
2. Use visual verification instead of selectors when possible
3. Implement retry logic with exponential backoff
4. Consider test isolation (fresh browser context)

### Self-Healing Not Working
1. Ensure screenshot is taken at failure point
2. Provide full error context to Claude
3. Set confidence threshold for auto-fixes
4. Review and validate fixes before committing

## MCP (Model Context Protocol) Integration

### Playwright MCP Server

The recommended way to use Playwright with Claude is through MCP. This provides a standardized interface for browser automation.

**Official Package**: `@playwright/mcp` (Microsoft)
- Source: https://www.npmjs.com/package/@playwright/mcp
- GitHub: https://github.com/microsoft/playwright-mcp

#### Installation

```bash
# Run with npx (recommended)
npx @playwright/mcp@latest

# Or install globally
npm install -g @playwright/mcp
```

#### Claude Code Configuration

Add to your `~/.claude/mcp_servers.json`:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"]
    }
  }
}
```

#### Key Features

- **Fast and lightweight** - Uses Playwright's accessibility tree, not pixel-based input
- **LLM-friendly** - No vision models needed, operates purely on structured data
- **Deterministic** - Avoids ambiguity common with screenshot-based approaches

#### Available MCP Tools

| Tool | Description |
|------|-------------|
| `browser_navigate` | Navigate to a URL |
| `browser_snapshot` | Get accessibility snapshot |
| `browser_click` | Click an element |
| `browser_type` | Type text into element |
| `browser_select_option` | Select from dropdown |
| `browser_hover` | Hover over element |
| `browser_drag` | Drag element to target |
| `browser_press_key` | Press keyboard key |
| `browser_take_screenshot` | Take a screenshot |

#### Using MCP in Code

```python
from src.mcp import PlaywrightMCPClient

async def run_test_with_mcp():
    async with PlaywrightMCPClient() as client:
        # Navigate
        await client.navigate("https://example.com/login")

        # Fill form
        await client.fill("#email", "test@example.com")
        await client.fill("#password", "password123")

        # Click submit
        await client.click("button[type=submit]")

        # Take screenshot for verification
        result = await client.screenshot()

        return result
```

#### MCP vs Direct Playwright

| Aspect | MCP | Direct Playwright |
|--------|-----|-------------------|
| Setup | Requires npm server | Python only |
| Standardization | Protocol-based | Library-specific |
| Claude Integration | Native support | Requires wrapper |
| Performance | Slightly slower (IPC) | Faster (in-process) |
| Use Case | Claude Code integration | Standalone scripts |

**Recommendation**: Use MCP for Claude Code integrations, direct Playwright for performance-critical testing.

### Other MCP Servers

#### Filesystem MCP Server

**Package**: `@modelcontextprotocol/server-filesystem`
- Source: https://www.npmjs.com/package/@modelcontextprotocol/server-filesystem
- Provides secure file operations with configurable access controls

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed/dir"]
    }
  }
}
```

#### GitHub MCP Server

**Package**: `@modelcontextprotocol/server-github`
- Source: https://www.npmjs.com/package/@modelcontextprotocol/server-github
- Note: Development moved to https://github.com/github/github-mcp-server

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<YOUR_TOKEN>"
      }
    }
  }
}
```

### Using LangGraph with MCP (langchain-mcp-adapters)

The official way to use MCP with LangGraph is via `langchain-mcp-adapters`:
- Source: https://github.com/langchain-ai/langchain-mcp-adapters

```python
from langchain_mcp_adapters.client import MultiServerMCPClient
from langgraph.prebuilt import create_react_agent
from langchain_anthropic import ChatAnthropic

async with MultiServerMCPClient({
    "playwright": {
        "transport": "stdio",
        "command": "npx",
        "args": ["-y", "@playwright/mcp@latest"],
    }
}) as client:
    tools = await client.get_tools()
    llm = ChatAnthropic(model="claude-sonnet-4-5")
    agent = create_react_agent(llm, tools)

    result = await agent.ainvoke({
        "messages": [("user", "Navigate to example.com")]
    })
```

## Docker Sandbox Setup

**CRITICAL**: Always run Computer Use in an isolated Docker container.

### Dockerfile for Computer Use Sandbox

```dockerfile
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    fluxbox \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt
RUN playwright install chromium

# Set up virtual display
ENV DISPLAY=:99
ENV RESOLUTION=1920x1080x24

# Start script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
```

### entrypoint.sh

```bash
#!/bin/bash
# Start virtual display
Xvfb :99 -screen 0 $RESOLUTION &
sleep 1

# Start window manager
fluxbox &
sleep 1

# Start VNC server (optional, for debugging)
x11vnc -display :99 -forever -nopw -quiet &

# Run the testing agent
exec python -m e2e_testing_agent "$@"
```

### Docker Compose

```yaml
version: '3.8'
services:
  e2e-agent:
    build: .
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - DISPLAY=:99
    volumes:
      - ./test-results:/app/test-results
      - ./codebase:/app/codebase:ro
    ports:
      - "5900:5900"  # VNC for debugging
    security_opt:
      - seccomp:unconfined
    shm_size: 2gb
```

### Sandbox Manager Implementation

```python
import docker
import asyncio
from pathlib import Path

class SandboxManager:
    """Manages Docker containers for safe Computer Use execution."""

    def __init__(self, image: str = "e2e-agent:latest"):
        self.client = docker.from_env()
        self.image = image
        self.container = None

    async def start(self, codebase_path: str) -> str:
        """Start sandbox container, return container ID."""
        self.container = self.client.containers.run(
            self.image,
            detach=True,
            environment={
                "ANTHROPIC_API_KEY": os.environ["ANTHROPIC_API_KEY"],
                "DISPLAY": ":99",
            },
            volumes={
                str(Path(codebase_path).absolute()): {
                    "bind": "/app/codebase",
                    "mode": "ro"
                }
            },
            shm_size="2g",
            security_opt=["seccomp:unconfined"],
        )

        # Wait for display to be ready
        await asyncio.sleep(2)
        return self.container.id

    async def execute(self, command: str) -> str:
        """Execute command in sandbox."""
        if not self.container:
            raise RuntimeError("Sandbox not started")

        exit_code, output = self.container.exec_run(command)
        return output.decode()

    async def screenshot(self) -> bytes:
        """Capture screenshot from sandbox display."""
        exit_code, output = self.container.exec_run(
            "import -window root -display :99 png:-"
        )
        return output

    async def stop(self):
        """Stop and remove sandbox container."""
        if self.container:
            self.container.stop()
            self.container.remove()
            self.container = None
```

## Error Handling Patterns

### Retry with Exponential Backoff

```python
import asyncio
from functools import wraps

def retry_with_backoff(max_retries: int = 3, base_delay: float = 1.0):
    """Decorator for retrying failed operations."""
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            last_exception = None
            for attempt in range(max_retries):
                try:
                    return await func(*args, **kwargs)
                except (TimeoutError, ConnectionError) as e:
                    last_exception = e
                    delay = base_delay * (2 ** attempt)
                    await asyncio.sleep(delay)
                except Exception as e:
                    # Don't retry on non-transient errors
                    raise
            raise last_exception
        return wrapper
    return decorator

# Usage
@retry_with_backoff(max_retries=3)
async def click_element(page, selector: str):
    await page.click(selector, timeout=5000)
```

### Graceful Degradation

```python
class TestExecutor:
    """Execute tests with fallback strategies."""

    async def execute_with_fallback(self, test_spec: dict) -> TestResult:
        """Try Computer Use first, fall back to Playwright."""

        # Try Computer Use (visual, but slower)
        try:
            return await self.execute_with_computer_use(test_spec)
        except ComputerUseError as e:
            logger.warning(f"Computer Use failed: {e}, falling back to Playwright")

        # Fall back to Playwright (faster, but less visual)
        try:
            return await self.execute_with_playwright(test_spec)
        except PlaywrightError as e:
            logger.error(f"Playwright also failed: {e}")
            return TestResult(
                status=TestStatus.FAILED,
                error_message=f"Both execution methods failed: {e}"
            )
```

### Error Classification

```python
from enum import Enum

class ErrorType(Enum):
    TRANSIENT = "transient"      # Retry
    SELECTOR = "selector"        # Self-heal
    TIMEOUT = "timeout"          # Increase wait
    ASSERTION = "assertion"      # Check logic
    INFRASTRUCTURE = "infra"     # Alert ops
    UNKNOWN = "unknown"          # Manual review

def classify_error(error: Exception, screenshot: bytes = None) -> ErrorType:
    """Classify error for appropriate handling."""
    error_str = str(error).lower()

    if "timeout" in error_str:
        return ErrorType.TIMEOUT
    elif "selector" in error_str or "element" in error_str:
        return ErrorType.SELECTOR
    elif "connection" in error_str or "network" in error_str:
        return ErrorType.TRANSIENT
    elif "assert" in error_str:
        return ErrorType.ASSERTION
    elif "docker" in error_str or "container" in error_str:
        return ErrorType.INFRASTRUCTURE

    return ErrorType.UNKNOWN

def handle_error(error_type: ErrorType, test_spec: dict, error: Exception):
    """Route error to appropriate handler."""
    handlers = {
        ErrorType.TRANSIENT: retry_test,
        ErrorType.SELECTOR: queue_for_healing,
        ErrorType.TIMEOUT: increase_timeout_and_retry,
        ErrorType.ASSERTION: mark_as_failed,
        ErrorType.INFRASTRUCTURE: alert_and_abort,
        ErrorType.UNKNOWN: queue_for_review,
    }
    return handlers[error_type](test_spec, error)
```

### Screenshot on Failure

```python
async def execute_test_with_evidence(test_spec: dict) -> TestResult:
    """Always capture screenshot on failure for debugging."""
    screenshots = []

    try:
        for step in test_spec["steps"]:
            # Take before screenshot
            screenshots.append(await capture_screenshot())

            # Execute step
            await execute_step(step)

            # Take after screenshot
            screenshots.append(await capture_screenshot())

        return TestResult(status=TestStatus.PASSED, screenshots=screenshots)

    except Exception as e:
        # Capture failure state
        failure_screenshot = await capture_screenshot()
        screenshots.append(failure_screenshot)

        return TestResult(
            status=TestStatus.FAILED,
            error_message=str(e),
            screenshots=screenshots,
            screenshot_at_failure=failure_screenshot,
        )
```

## Action Mapping Reference

Map test specification actions to Playwright and Computer Use:

| Test Action | Playwright | Computer Use |
|-------------|------------|--------------|
| `goto` | `page.goto(url)` | `{"action": "key", "text": "ctrl+l"}` then type URL |
| `click` | `page.click(selector)` | `{"action": "left_click", "coordinate": [x, y]}` |
| `fill` | `page.fill(selector, value)` | `{"action": "left_click"}` then `{"action": "type", "text": value}` |
| `wait` | `page.wait_for_selector(selector)` | `{"action": "wait", "duration": ms}` |
| `screenshot` | `page.screenshot()` | `{"action": "screenshot"}` |
| `scroll` | `page.mouse.wheel(0, delta)` | `{"action": "scroll", "coordinate": [x, y], "direction": "down"}` |
| `select` | `page.select_option(selector, value)` | Click dropdown + click option |
| `hover` | `page.hover(selector)` | `{"action": "mouse_move", "coordinate": [x, y]}` |
| `press` | `page.keyboard.press(key)` | `{"action": "key", "text": key}` |

```python
class ActionMapper:
    """Map test actions to execution methods."""

    async def execute_action(
        self,
        action: dict,
        page: Page,
        computer_use_client: ComputerUseClient = None
    ):
        """Execute action using Playwright, with Computer Use fallback."""
        action_type = action["action"]
        target = action.get("target")
        value = action.get("value")

        try:
            # Try Playwright first (faster)
            if action_type == "goto":
                await page.goto(target)
            elif action_type == "click":
                await page.click(target, timeout=5000)
            elif action_type == "fill":
                await page.fill(target, value)
            elif action_type == "wait":
                await page.wait_for_selector(target, timeout=int(value or 5000))
            elif action_type == "screenshot":
                return await page.screenshot()
            else:
                raise ValueError(f"Unknown action: {action_type}")

        except Exception as e:
            if computer_use_client:
                # Fall back to Computer Use for visual interaction
                return await self._execute_via_computer_use(
                    computer_use_client, action
                )
            raise
```
