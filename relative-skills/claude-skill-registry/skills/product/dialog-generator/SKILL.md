---
name: dialog-generator
description: Generate modal and modeless dialog windows for Tkinter applications. Use when creating dialogs, popups, or secondary windows, when user mentions "dialog", "popup", "modal", or when working with files in views/dialogs/ directory.
allowed-tools: Read, Write
---

You are a Tkinter dialog expert. You create modal and modeless dialogs following best practices.

## Dialog Types

### 1. Modal Dialog (blocks parent until closed)

```python
"""<Description> dialog."""

import tkinter as tk
from typing import Any

import ttkbootstrap as ttk
from ttkbootstrap.constants import *


class <DialogName>Dialog(tk.Toplevel):
    """Modal <description> dialog."""

    def __init__(self, parent: tk.Tk, title: str = "Dialog") -> None:
        super().__init__(parent)
        self.title(title)
        self.result: Any | None = None

        # Make modal
        self.transient(parent)
        self.grab_set()

        # Build UI
        self._build_ui()

        # Center on parent
        self._center_on_parent(parent)

        # Handle window close
        self.protocol("WM_DELETE_WINDOW", self.on_cancel)

    def _build_ui(self) -> None:
        """Build dialog UI."""
        main_frame = ttk.Frame(self, padding=20)
        main_frame.pack(fill=BOTH, expand=True)

        # Dialog content here

        # Button frame
        button_frame = ttk.Frame(main_frame)
        button_frame.pack(side=BOTTOM, fill=X, pady=(15, 0))

        ttk.Button(
            button_frame,
            text="OK",
            command=self.on_ok,
            bootstyle=PRIMARY,
            width=10,
        ).pack(side=RIGHT, padx=(5, 0))

        ttk.Button(
            button_frame,
            text="Cancel",
            command=self.on_cancel,
            width=10,
        ).pack(side=RIGHT)

    def _center_on_parent(self, parent: tk.Tk) -> None:
        """Center dialog on parent."""
        self.update_idletasks()
        x = parent.winfo_x() + (parent.winfo_width() - self.winfo_width()) // 2
        y = parent.winfo_y() + (parent.winfo_height() - self.winfo_height()) // 2
        self.geometry(f"+{x}+{y}")

    def on_ok(self) -> None:
        """Handle OK button."""
        self.result = self.get_result()
        self.destroy()

    def on_cancel(self) -> None:
        """Handle Cancel button."""
        self.result = None
        self.destroy()

    def get_result(self) -> Any:
        """Get dialog result."""
        # Return form data or result
        return {}

    @staticmethod
    def show_dialog(parent: tk.Tk) -> Any | None:
        """Show dialog and return result."""
        dialog = <DialogName>Dialog(parent)
        parent.wait_window(dialog)
        return dialog.result
```

### 2. Input Dialog (get user input)

```python
class InputDialog(tk.Toplevel):
    """Simple input dialog."""

    def __init__(self, parent: tk.Tk, title: str, prompt: str):
        super().__init__(parent)
        self.title(title)
        self.result: str | None = None

        self.transient(parent)
        self.grab_set()

        # Build UI
        frame = ttk.Frame(self, padding=20)
        frame.pack(fill=BOTH, expand=True)

        ttk.Label(frame, text=prompt).pack(pady=(0, 10))

        self.entry_var = tk.StringVar()
        self.entry = ttk.Entry(frame, textvariable=self.entry_var, width=30)
        self.entry.pack(fill=X, pady=(0, 15))
        self.entry.focus()
        self.entry.bind("<Return>", lambda e: self.on_ok())

        # Buttons
        btn_frame = ttk.Frame(frame)
        btn_frame.pack()

        ttk.Button(
            btn_frame,
            text="OK",
            command=self.on_ok,
            bootstyle=PRIMARY,
        ).pack(side=LEFT, padx=5)

        ttk.Button(
            btn_frame,
            text="Cancel",
            command=self.on_cancel,
        ).pack(side=LEFT, padx=5)

        self._center_on_parent(parent)
        self.protocol("WM_DELETE_WINDOW", self.on_cancel)

    def _center_on_parent(self, parent: tk.Tk) -> None:
        self.update_idletasks()
        x = parent.winfo_x() + (parent.winfo_width() - self.winfo_width()) // 2
        y = parent.winfo_y() + (parent.winfo_height() - self.winfo_height()) // 2
        self.geometry(f"+{x}+{y}")

    def on_ok(self) -> None:
        self.result = self.entry_var.get()
        self.destroy()

    def on_cancel(self) -> None:
        self.result = None
        self.destroy()

    @staticmethod
    def get_input(parent: tk.Tk, title: str, prompt: str) -> str | None:
        """Show input dialog and return result."""
        dialog = InputDialog(parent, title, prompt)
        parent.wait_window(dialog)
        return dialog.result
```

### 3. Confirmation Dialog

```python
from tkinter import messagebox

# Simple confirmation
if messagebox.askyesno("Confirm", "Are you sure?"):
    perform_action()

# With warning style
if messagebox.askokcancel("Confirm Delete", "This cannot be undone"):
    delete_item()
```

### 4. Progress Dialog

```python
from tkinter_app.utils import ProgressDialog

# Built-in progress dialog
result, error = ProgressDialog.run_with_dialog(
    parent=self,
    task=long_running_function,
    title="Processing",
    message="Please wait..."
)
```

### 5. Modeless Dialog (non-blocking)

```python
class ToolPalette(tk.Toplevel):
    """Modeless tool palette."""

    def __init__(self, parent: tk.Tk):
        super().__init__(parent)
        self.title("Tools")

        # Don't make modal (no grab_set)
        self.transient(parent)  # Keep on top of parent

        # Build UI
        self._build_ui()

        # Handle close
        self.protocol("WM_DELETE_WINDOW", self.on_close)

    def _build_ui(self) -> None:
        # Tool buttons
        pass

    def on_close(self) -> None:
        """Hide instead of destroy."""
        self.withdraw()

    def show(self) -> None:
        """Show dialog."""
        self.deiconify()
```

## Dialog Patterns

### Form Dialog

```python
class FormDialog(tk.Toplevel):
    """Dialog with form fields."""

    def _build_ui(self) -> None:
        frame = ttk.Frame(self, padding=20)
        frame.pack(fill=BOTH, expand=True)

        # Name field
        ttk.Label(frame, text="Name:").grid(row=0, column=0, sticky=W, pady=5)
        self.name_var = tk.StringVar()
        ttk.Entry(frame, textvariable=self.name_var).grid(
            row=0, column=1, sticky=EW, pady=5, padx=(10, 0)
        )

        # Email field
        ttk.Label(frame, text="Email:").grid(row=1, column=0, sticky=W, pady=5)
        self.email_var = tk.StringVar()
        ttk.Entry(frame, textvariable=self.email_var).grid(
            row=1, column=1, sticky=EW, pady=5, padx=(10, 0)
        )

        frame.columnconfigure(1, weight=1)

        # Buttons...

    def get_result(self) -> dict:
        return {
            "name": self.name_var.get(),
            "email": self.email_var.get(),
        }
```

## Best Practices

1. **Always make modal**: Use `transient()` and `grab_set()` for modal dialogs
2. **Center on parent**: Calculate position relative to parent window
3. **Handle window close**: Set `protocol("WM_DELETE_WINDOW")` handler
4. **Keyboard shortcuts**: Bind Enter to OK, Escape to Cancel
5. **Focus management**: Set focus to primary input field
6. **Return vs Cancel**: Distinguish between OK (return data) and Cancel (return None)
7. **Static helper method**: Provide `show_dialog()` for easy usage
8. **Validation**: Validate form data before accepting

This skill helps you create professional, well-behaved dialog windows for your Tkinter application.
