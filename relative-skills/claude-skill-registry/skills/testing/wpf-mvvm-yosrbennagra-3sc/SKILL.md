---
name: wpf-mvvm
description: Build and maintain WPF MVVM patterns using CommunityToolkit.Mvvm for a .NET 8 widget-host app. Use when creating ViewModels, commands, observable state, validation, view bindings, and viewmodel-first navigation behaviors. Avoid Prism and heavy region managers; keep ViewModels testable and UI-agnostic.
---

# Wpf Mvvm

## Overview

Apply MVVM conventions with CommunityToolkit.Mvvm, ensuring view models are UI-agnostic and ready for the widget shell architecture.

## Constraints

- Target .NET 8
- CommunityToolkit.Mvvm
- ViewModel-first navigation (custom service)
- No Prism, no heavy region manager

## Core conventions

### Definition of done (DoD)

- ViewModel has no WPF dependencies (Window, UserControl, etc.)
- Commands use `[RelayCommand]` attribute from CommunityToolkit.Mvvm
- Observable properties use `[ObservableProperty]` attribute
- Async commands have proper cancellation support where applicable
- ViewModel behavior is covered by unit tests

### ViewModel base

- Use `ObservableObject` (or `ObservableRecipient` if messaging is required).
- Keep view models free of `Window`, `UserControl`, or `DependencyObject` references.

### Commands

- Use `[RelayCommand]` for commands.
- Prefer async commands for IO or long-running work.
- Use `CanExecute` or `CanExecute` backing fields for stateful enable/disable.

### State and updates

- Use `[ObservableProperty]` for state.
- Keep state immutable when practical; update via methods.
- Avoid direct access to `Application.Current` inside view models.

### Validation

- Use `ObservableValidator` for data validation.
- Prefer `INotifyDataErrorInfo` via toolkit attributes.

## Typical workflow

1. Create or update view model using toolkit attributes.
2. Add command handlers and validation rules.
3. Bind view to view model with XAML.
4. Add DataTemplate mapping for viewmodel-first navigation.
5. Write tests for business logic and command behavior.

## Example ViewModel

```csharp
public partial class WidgetViewModel : ObservableObject
{
    [ObservableProperty]
    private string _title = "Widget";

    [RelayCommand]
    private void Refresh()
    {
        // Fetch or recompute widget state.
    }
}
```

## Binding guidance

- Bind directly to VM properties with `Mode=TwoWay` only when needed.
- Use `UpdateSourceTrigger=PropertyChanged` for live edits.
- Keep converters minimal; prefer derived properties in the VM.

## References

- `references/viewmodel-patterns.md` for structure patterns.
- `references/commands-and-async.md` for command and async guidance.
- `references/validation.md` for validation recipes.
