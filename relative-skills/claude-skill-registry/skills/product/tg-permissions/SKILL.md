---
name: tg-permissions
description: Permission and access control patterns for the World of Darkness Django application. Use when implementing view permissions, checking user access levels, creating limited forms for owners, using PermissionManager vs is_st(), or working with view mixins. Triggers on permission checks, ST-only features, owner restrictions, or access control logic.
---

# Permission System

Two permission systems exist—use the right one for the context.

## Quick Reference

| Use Case | Method |
|----------|--------|
| Object-level access (detail/update/delete views) | `PermissionManager` |
| Role-based checks (forms, templates, general ST features) | `is_st()` |
| Owner editing restrictions | Limited forms |

## PermissionManager (Object-Level)

For checking permissions on specific objects:

```python
# In views - use permission mixins
class CharacterDetailView(ViewPermissionMixin, DetailView):
    pass  # Automatically checks VIEW_FULL permission

class CharacterUpdateView(EditPermissionMixin, MessageMixin, UpdateView):
    pass  # Automatically checks EDIT_FULL permission

# Explicit permission checks
from core.permissions import PermissionManager
pm = PermissionManager()
if pm.check_permission(user, character, 'edit_full'):
    # Allow editing
```

## is_st() (Role-Based)

For general storyteller checks not tied to specific objects:

```python
# In forms - determine available options
if user.profile.is_st():
    # Show ST-only form fields

# In templates
{% if user.profile.is_st %}
    <!-- ST-only controls -->
{% endif %}
```

## View Mixins

All mixins in `core/mixins.py`:

```python
from core.mixins import (
    ViewPermissionMixin,      # VIEW_FULL permission
    EditPermissionMixin,      # EDIT_FULL permission
    SpendXPPermissionMixin,   # XP spending permission
    SpendFreebiesPermissionMixin,  # Freebie spending permission
    VisibilityFilterMixin,    # Filter queryset by visibility
    OwnerRequiredMixin,       # Must be object owner
    STRequiredMixin,          # Must be storyteller
    MessageMixin,             # Success and error messages
)
```

### Mixin Stacking Order (left to right)

```python
class MyView(EditPermissionMixin, MessageMixin, UpdateView): pass
class MyListView(VisibilityFilterMixin, ListView): pass
class MyCreateView(LoginRequiredMixin, MessageMixin, CreateView): pass
class MySTView(STRequiredMixin, MessageMixin, CreateView): pass
```

## Limited Forms for Owners

Owners can only edit descriptive fields:

```python
def get_form_class(self):
    if self.request.user.profile.is_st() or self.request.user.is_staff:
        return CharacterForm  # Full form
    return LimitedCharacterEditForm  # Restricted fields only
```

### Limited Form Pattern

```python
class LimitedCharacterEditForm(forms.ModelForm):
    class Meta:
        model = Character
        fields = ["notes", "description", "public_info", "image", "history", "goals"]
```

Only allow: `notes`, `description`, `public_info`, `image`, `history`, `goals`.
Never allow owners to edit: stats, XP, status, mechanical fields.

## Detailed Documentation

For comprehensive implementation details, see:
- [references/implementation-guide.md](references/implementation-guide.md) - Full PermissionManager implementation, query optimization, view patterns
- [references/user-profile-pattern.md](references/user-profile-pattern.md) - User + Profile architecture, performance tips

## Guidelines

- Use **PermissionManager/mixins** for detail/update/delete views
- Use **is_st()** for forms, templates, general role checks
- Use **Limited forms** to restrict owner editing
- Permission mixins handle view-level checks automatically
- See `docs/design/permissions_system.md` for full design documentation
