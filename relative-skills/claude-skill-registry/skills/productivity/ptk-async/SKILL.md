---
name: ptk-async
description: This skill should be used when the user asks about "prompt_toolkit Application", "app.run", "run_async", "asyncio", "event loop", "run_in_terminal", "async key binding", "background task", "Application lifecycle", or needs to understand the Application run loop and async patterns in prompt_toolkit.
---

# prompt_toolkit Application & Async Patterns

The Application class is the core of every prompt_toolkit program. It manages the event loop, rendering, and input handling. Understanding its lifecycle and async patterns is essential for building responsive terminal applications.

## Application Basics

```python
from prompt_toolkit.application import Application
from prompt_toolkit.layout import Layout, Window
from prompt_toolkit.layout.controls import FormattedTextControl

app = Application(
    layout=Layout(Window(FormattedTextControl('Hello World'))),
    full_screen=True,
)

# Run synchronously (blocking)
result = app.run()

# Or run asynchronously
import asyncio
result = asyncio.run(app.run_async())
```

## Application Constructor

```python
Application(
    layout: Layout | None = None,
    key_bindings: KeyBindingsBase | None = None,
    style: BaseStyle | None = None,
    full_screen: bool = False,
    mouse_support: bool = False,
    editing_mode: EditingMode = EditingMode.EMACS,
    erase_when_done: bool = False,
    refresh_interval: float | None = None,
    color_depth: ColorDepth | None = None,
)
```

**Key Parameters:**
- `full_screen` - Use entire terminal (vs inline prompt)
- `mouse_support` - Enable mouse events
- `editing_mode` - `EditingMode.EMACS` or `EditingMode.VI`
- `refresh_interval` - Auto-refresh interval in seconds (for dynamic content)
- `erase_when_done` - Clear screen on exit

## Running Applications

### Synchronous
```python
result = app.run()
```

### Asynchronous
```python
async def main():
    result = await app.run_async()
    return result

asyncio.run(main())
```

### With Custom Event Loop
```python
loop = asyncio.new_event_loop()
try:
    result = loop.run_until_complete(app.run_async())
finally:
    loop.close()
```

## Exiting the Application

```python
@kb.add('c-c')
def exit_app(event):
    event.app.exit()

@kb.add('c-q')
def exit_with_result(event):
    event.app.exit(result='user quit')

@kb.add('c-x')
def exit_with_exception(event):
    event.app.exit(exception=KeyboardInterrupt())
```

## Async Key Binding Handlers

Key handlers can be async coroutines:

```python
@kb.add('c-r')
async def refresh_data(event):
    # Non-blocking async operation
    data = await fetch_from_api()
    event.current_buffer.text = data
    # UI automatically refreshes after handler completes
```

## Background Tasks

### Using create_background_task

```python
async def background_worker(app):
    while True:
        await asyncio.sleep(1)
        # Update state
        app.invalidate()  # Request redraw

app = Application(...)

async def main():
    # Start background task
    task = asyncio.create_task(background_worker(app))
    try:
        result = await app.run_async()
    finally:
        task.cancel()
```

### With Application's Background Tasks

```python
async def update_clock(app):
    while True:
        await asyncio.sleep(1)
        app.invalidate()

# Add task when app starts
app.create_background_task(update_clock(app))
```

## run_in_terminal

Execute code while temporarily leaving the app:

```python
from prompt_toolkit.application import run_in_terminal

@kb.add('c-t')
async def run_external(event):
    def show_output():
        print("Running external command...")
        import subprocess
        subprocess.run(['ls', '-la'])
        input("Press Enter to continue...")

    await run_in_terminal(show_output)
```

## Invalidation

Request UI refresh when state changes:

```python
# In async code
app.invalidate()

# In key handler
@kb.add('c-r')
def refresh(event):
    update_data()
    event.app.invalidate()

# Auto-refresh with refresh_interval
app = Application(
    refresh_interval=0.5,  # Refresh every 500ms
)
```

## Application Events

Hook into lifecycle events:

```python
app = Application(...)

# Before first render
app.on_reset += lambda: print("App reset")

# After invalidate called
app.on_invalidate += lambda: print("Invalidated")

# Before each render
app.before_render += lambda app: print("About to render")

# After each render
app.after_render += lambda app: print("Rendered")
```

## Accessing Current Application

```python
from prompt_toolkit.application import get_app, get_app_or_none

# In handlers (always available)
@kb.add('c-i')
def handler(event):
    app = event.app  # Preferred

# In other code
try:
    app = get_app()
except RuntimeError:
    print("No app running")

# Safe version
app = get_app_or_none()
if app:
    app.invalidate()
```

## Common Async Patterns

### Debounced Updates
```python
class DebouncedUpdater:
    def __init__(self, app, delay=0.3):
        self.app = app
        self.delay = delay
        self._task = None

    async def trigger(self):
        if self._task:
            self._task.cancel()
        self._task = asyncio.create_task(self._update())

    async def _update(self):
        await asyncio.sleep(self.delay)
        update_expensive_data()
        self.app.invalidate()
```

### Concurrent Data Loading
```python
async def load_data_parallel(app):
    results = await asyncio.gather(
        fetch_users(),
        fetch_products(),
        fetch_orders(),
    )
    app.data = results
    app.invalidate()
```

## Reference Codebase

For detailed API:
- **Source**: `/Users/brandon/src/python-prompt-toolkit/src/prompt_toolkit/application/application.py`
- **Source**: `/Users/brandon/src/python-prompt-toolkit/src/prompt_toolkit/application/run_in_terminal.py`
- **Examples**: `/Users/brandon/src/python-prompt-toolkit/examples/full-screen/`

## Additional Resources

### Reference Files
- **`references/application-api.md`** - Complete Application API
- **`references/async-patterns.md`** - Production async patterns
