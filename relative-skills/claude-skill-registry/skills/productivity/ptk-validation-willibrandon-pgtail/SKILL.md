---
name: ptk-validation
description: This skill should be used when the user asks about "prompt_toolkit Validator", "validation", "input validation", "ValidationError", "History", "FileHistory", "InMemoryHistory", "auto_suggest", "AutoSuggest", or needs to validate user input or implement command history in prompt_toolkit applications.
---

# prompt_toolkit Validation & History

Validation ensures user input meets requirements before acceptance. History provides access to previous inputs for navigation and auto-suggestion.

## Validation

### Basic Validator

```python
from prompt_toolkit.validation import Validator, ValidationError

class NumberValidator(Validator):
    def validate(self, document):
        text = document.text
        if not text.isdigit():
            raise ValidationError(
                cursor_position=len(text),
                message='Please enter a number',
            )
```

### From Callable

```python
from prompt_toolkit.validation import Validator

validator = Validator.from_callable(
    lambda text: len(text) >= 3,
    error_message='Minimum 3 characters required',
    move_cursor_to_end=True,
)
```

### Using with Buffer

```python
from prompt_toolkit.buffer import Buffer

buffer = Buffer(
    validator=my_validator,
    validate_while_typing=False,  # Only validate on accept
)
```

### Async Validation

```python
class AsyncValidator(Validator):
    async def validate_async(self, document):
        # Check against remote service
        exists = await api.check_username(document.text)
        if exists:
            raise ValidationError(message='Username taken')

    def validate(self, document):
        # Sync fallback (optional)
        pass
```

### ThreadedValidator

For slow validators:

```python
from prompt_toolkit.validation import ThreadedValidator

validator = ThreadedValidator(SlowValidator())
```

### Common Validators

```python
# Email validator
class EmailValidator(Validator):
    def validate(self, document):
        if '@' not in document.text or '.' not in document.text:
            raise ValidationError(
                cursor_position=len(document.text),
                message='Invalid email format',
            )

# Range validator
class RangeValidator(Validator):
    def __init__(self, min_val, max_val):
        self.min_val = min_val
        self.max_val = max_val

    def validate(self, document):
        try:
            value = int(document.text)
            if not (self.min_val <= value <= self.max_val):
                raise ValueError
        except ValueError:
            raise ValidationError(
                message=f'Enter a number between {self.min_val} and {self.max_val}',
            )

# Regex validator
import re
class RegexValidator(Validator):
    def __init__(self, pattern, message='Invalid format'):
        self.pattern = re.compile(pattern)
        self.message = message

    def validate(self, document):
        if not self.pattern.match(document.text):
            raise ValidationError(message=self.message)
```

## History

### InMemoryHistory

```python
from prompt_toolkit.history import InMemoryHistory

history = InMemoryHistory()
# Optionally pre-populate
history = InMemoryHistory(history_strings=['cmd1', 'cmd2'])
```

### FileHistory

Persistent history saved to file:

```python
from prompt_toolkit.history import FileHistory

history = FileHistory('~/.myapp_history')
```

### ThreadedHistory

Load history in background:

```python
from prompt_toolkit.history import ThreadedHistory, FileHistory

history = ThreadedHistory(FileHistory('~/.myapp_history'))
```

### Using with Buffer

```python
buffer = Buffer(
    history=FileHistory('.history'),
    enable_history_search=True,  # Up/Down searches matching prefix
)
```

### History Navigation

In key bindings:

```python
@kb.add('up')
def _(event):
    event.current_buffer.history_backward()

@kb.add('down')
def _(event):
    event.current_buffer.history_forward()
```

## Auto-Suggest

Show suggestions from history as you type:

```python
from prompt_toolkit.auto_suggest import AutoSuggestFromHistory

buffer = Buffer(
    auto_suggest=AutoSuggestFromHistory(),
    history=FileHistory('.history'),
)
```

### Custom AutoSuggest

```python
from prompt_toolkit.auto_suggest import AutoSuggest, Suggestion

class CommandAutoSuggest(AutoSuggest):
    def __init__(self, commands):
        self.commands = commands

    def get_suggestion(self, buffer, document):
        text = document.text
        for cmd in self.commands:
            if cmd.startswith(text) and cmd != text:
                return Suggestion(cmd[len(text):])
        return None
```

### Accept Suggestion Key Binding

```python
from prompt_toolkit.filters import has_suggestion

@kb.add('right', filter=has_suggestion())
def _(event):
    suggestion = event.current_buffer.suggestion
    if suggestion:
        event.current_buffer.insert_text(suggestion.text)
```

## Validation Toolbar

Display validation errors:

```python
from prompt_toolkit.layout import ConditionalContainer, Window
from prompt_toolkit.layout.controls import FormattedTextControl
from prompt_toolkit.filters import has_validation_error

def get_validation_text():
    if buffer.validation_error:
        return buffer.validation_error.message
    return ''

validation_toolbar = ConditionalContainer(
    content=Window(
        FormattedTextControl(get_validation_text),
        height=1,
        style='class:validation-toolbar',
    ),
    filter=has_validation_error(),
)
```

## Reference Codebase

For detailed API:
- **Source**: `/Users/brandon/src/python-prompt-toolkit/src/prompt_toolkit/validation.py`
- **Source**: `/Users/brandon/src/python-prompt-toolkit/src/prompt_toolkit/history.py`
- **Source**: `/Users/brandon/src/python-prompt-toolkit/src/prompt_toolkit/auto_suggest.py`

## Additional Resources

### Reference Files
- **`references/validation-api.md`** - Complete Validator API
- **`references/history-api.md`** - Complete History API
