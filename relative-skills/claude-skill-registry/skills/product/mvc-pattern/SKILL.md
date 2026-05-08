---
name: mvc-pattern
description: Scaffold new MVC components (Model, View, Controller) for Tkinter applications following the template's architecture. Use when creating new features, when user mentions "MVC", "model", "view", or "controller", or when working with .py files in models/, views/, or controllers/ directories.
allowed-tools: Read, Write, Grep
---

You are an MVC architecture expert for Tkinter applications. You scaffold complete MVC components following this template's patterns.

## MVC Architecture Overview

This template uses a clean MVC pattern:
- **Model**: Data and business logic with observer pattern
- **View**: UI components (ttk widgets) that display data
- **Controller**: Mediates between model and view, handles user actions

## Creating a Complete MVC Feature

### Step 1: Create the Model

```python
"""<Feature> data model."""

from typing import Callable
from loguru import logger


class <FeatureName>Model:
    """Model for managing <feature description>."""

    def __init__(self) -> None:
        """Initialize model."""
        self._data: dict = {}
        self._observers: list[Callable[[], None]] = []
        logger.debug(f"{self.__class__.__name__} initialized")

    def add_observer(self, callback: Callable[[], None]) -> None:
        """Add observer for model changes."""
        self._observers.append(callback)

    def remove_observer(self, callback: Callable[[], None]) -> None:
        """Remove observer."""
        if callback in self._observers:
            self._observers.remove(callback)

    def _notify_observers(self) -> None:
        """Notify all observers of changes."""
        for callback in self._observers:
            try:
                callback()
            except Exception as e:
                logger.error(f"Observer error: {e}")

    # Add feature-specific methods here
    # Remember to call self._notify_observers() after state changes
```

### Step 2: Create the View

```python
"""<Feature> view component."""

import tkinter as tk
from typing import TYPE_CHECKING

import ttkbootstrap as ttk
from ttkbootstrap.constants import *

if TYPE_CHECKING:
    from tkinter_app.controllers.<controller> import <ControllerName>


class <FeatureName>View(ttk.Frame):
    """View component for <feature description>."""

    def __init__(
        self,
        parent: tk.Widget,
        controller: "<ControllerName>"
    ) -> None:
        """Initialize view.

        Args:
            parent: Parent widget
            controller: Controller instance
        """
        super().__init__(parent)
        self.controller = controller
        self._build_ui()

    def _build_ui(self) -> None:
        """Build user interface."""
        # Title
        title = ttk.Label(
            self,
            text="<Feature Name>",
            font=("Segoe UI", 16, "bold")
        )
        title.pack(pady=10)

        # Add widgets here

    def update_display(self, data: dict) -> None:
        """Update display with new data.

        Args:
            data: Data to display
        """
        # Update widgets with data
        pass
```

### Step 3: Create the Controller

```python
"""<Feature> controller."""

import tkinter as tk
from typing import TYPE_CHECKING

from loguru import logger

from tkinter_app.models.<model> import <ModelName>

if TYPE_CHECKING:
    from tkinter_app.views.<view> import <ViewName>


class <FeatureName>Controller:
    """Controller for <feature description>."""

    def __init__(self, root: tk.Tk, model: <ModelName>) -> None:
        """Initialize controller.

        Args:
            root: Root window
            model: Data model
        """
        self.root = root
        self.model = model
        self.view: "<ViewName> | None" = None

        # Subscribe to model changes
        self.model.add_observer(self._on_model_changed)
        logger.debug(f"{self.__class__.__name__} initialized")

    def set_view(self, view: "<ViewName>") -> None:
        """Set view reference.

        Args:
            view: View instance
        """
        self.view = view
        self._update_view()

    def _on_model_changed(self) -> None:
        """Handle model changes."""
        self._update_view()

    def _update_view(self) -> None:
        """Update view with current model data."""
        if self.view:
            data = self.model.get_data()
            self.view.update_display(data)

    # Add action handlers here
    def on_action(self) -> None:
        """Handle user action."""
        try:
            # Get data from view
            # Update model
            # Model will notify observers (including this controller)
            pass
        except Exception as e:
            logger.error(f"Action failed: {e}")
            if self.view:
                self.view.show_error(str(e))
```

### Step 4: Integration

Update `__init__.py` files:

```python
# models/__init__.py
from tkinter_app.models.<model> import <ModelName>
__all__ = [..., "<ModelName>"]

# views/__init__.py
from tkinter_app.views.<view> import <ViewName>
__all__ = [..., "<ViewName>"]

# controllers/__init__.py
from tkinter_app.controllers.<controller> import <ControllerName>
__all__ = [..., "<ControllerName>"]
```

Integrate into main app:

```python
# In app.py __init__
self.<feature>_model = <ModelName>()
self.<feature>_controller = <ControllerName>(self, self.<feature>_model)
self.<feature>_view = <ViewName>(self, self.<feature>_controller)
self.<feature>_controller.set_view(self.<feature>_view)
```

## MVC Communication Flow

1. **User interacts** with View (button click, text entry)
2. **View calls** Controller method (`controller.on_action()`)
3. **Controller** retrieves data from View
4. **Controller** updates Model with data
5. **Model** changes state and calls `_notify_observers()`
6. **Controller** receives notification via observer callback
7. **Controller** gets updated data from Model
8. **Controller** updates View with new data

## Best Practices

1. **Model is independent**: Model doesn't know about View or Controller
2. **View is dumb**: View has minimal logic, delegates to Controller
3. **Controller mediates**: Controller is the only connection between Model and View
4. **Observer pattern**: Model notifies controllers of changes
5. **Type hints**: Use TYPE_CHECKING to avoid circular imports
6. **Logging**: Log important actions and errors
7. **Error handling**: Controller catches exceptions and shows errors in View

This skill helps you create complete, well-structured MVC components for your Tkinter application.
