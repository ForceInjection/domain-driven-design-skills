---
name: tg-character-templates
description: Character template system for World of Darkness character creation. Use when implementing template selection in character creation flows, creating/managing CharacterTemplate objects, adding template support to new character types, or working with the template import/export features. Triggers on character template work, pre-configured character concepts, template selection views.
---

# Character Template System

Pre-configured character concepts from sourcebooks that speed up character creation.

## Overview

- **30 pre-configured templates** (5 per gameline)
- Optional template selection during character creation
- Full customization after template application
- Usage tracking and admin management at `/admin/core/charactertemplate/`

## Template Data Structure

```python
CharacterTemplate(
    # Identity
    name="Template Name",
    gameline="mta",  # vtm, wta, mta, wto, ctd, dtf
    character_type="mage",
    concept="Concept Name",
    
    # Character Data (JSONFields)
    basic_info={"nature": "FK:Archetype:Name", "demeanor": "FK:Archetype:Name"},
    attributes={"strength": 2, "perception": 4, ...},
    abilities={"alertness": 2, "investigation": 3, ...},
    backgrounds=[{"name": "Contacts", "rating": 3}],
    powers={"auspex": 2, "celerity": 1},
    merits_flaws=[{"name": "Merit Name", "rating": 2}],
    specialties=["Ability (Specialty)"],
    languages=["English", "Latin"],
    
    # Metadata
    is_official=True,
    is_public=True,
    times_used=0,  # Auto-incremented
)
```

Note: Use `"FK:Model:Name"` format for foreign key references (resolved during apply).

## Adding Template Selection to Character Types

### Step 1: Add Form and View (in character views file)

```python
from core.models import CharacterTemplate
from django import forms

class CharacterTemplateSelectionForm(forms.Form):
    template = forms.ModelChoiceField(
        queryset=CharacterTemplate.objects.none(),
        required=False,
        empty_label="No template - build from scratch",
        widget=forms.RadioSelect,
    )

    def __init__(self, *args, gameline="vtm", character_type="vampire", **kwargs):
        super().__init__(*args, **kwargs)
        self.fields["template"].queryset = CharacterTemplate.objects.filter(
            gameline=gameline, character_type=character_type, is_public=True
        ).order_by("name")

class VampireTemplateSelectView(LoginRequiredMixin, FormView):
    form_class = CharacterTemplateSelectionForm
    template_name = "characters/vampire/vampire/template_select.html"

    def dispatch(self, request, *args, **kwargs):
        self.object = get_object_or_404(Vampire, pk=kwargs["pk"], owner=request.user)
        if self.object.creation_status > 0:
            return redirect("characters:vampire:vampire_creation", pk=self.object.pk)
        return super().dispatch(request, *args, **kwargs)

    def get_form_kwargs(self):
        kwargs = super().get_form_kwargs()
        kwargs["gameline"] = "vtm"
        kwargs["character_type"] = "vampire"
        return kwargs

    def form_valid(self, form):
        template = form.cleaned_data.get("template")
        if template:
            template.apply_to_character(self.object)
            messages.success(self.request, f"Applied template '{template.name}'.")
        self.object.creation_status = 1
        self.object.save()
        return redirect("characters:vampire:vampire_creation", pk=self.object.pk)
```

### Step 2: Add URL

```python
path("vampire/<int:pk>/template/", VampireTemplateSelectView.as_view(), name="vampire_template"),
```

### Step 3: Update Basics View

```python
def get_success_url(self):
    return reverse("characters:vampire:vampire_template", kwargs={"pk": self.object.pk})
```

### Step 4: Create Template Selection Template

```html
{% extends "core/base.html" %}
{% block content %}
<div class="tg-card mb-4" data-gameline="vtm">
    <div class="tg-card-header">
        <h4 class="tg-card-title vtm_heading">Choose a Starting Template</h4>
    </div>
    <div class="tg-card-body">
        <form method="post">
            {% csrf_token %}
            {% for template in available_templates %}
            <div class="template-option" onclick="selectTemplate(this, {{ template.pk }})">
                <h5>{{ template.name }}</h5>
                <p>{{ template.description|truncatewords:30 }}</p>
            </div>
            {% endfor %}
            <div class="template-option" onclick="selectTemplate(this, '')">
                <h5>Build from Scratch</h5>
            </div>
            <input type="hidden" name="template" id="selected-template" value="">
            <button type="submit" class="btn btn-primary mt-3">Continue</button>
        </form>
    </div>
</div>
{% endblock %}
```

## Loading Templates

```bash
# Load all templates
python populate_db/character_templates/__init__.py

# Load specific gameline
python populate_db/character_templates/vampire_templates.py
```

## Template Application Logic

`CharacterTemplate.apply_to_character(character)`:
1. Resolves `"FK:Model:Name"` → actual objects
2. Sets attributes and abilities directly
3. Creates BackgroundRating entries
4. Sets power ratings (disciplines/spheres/gifts)
5. Creates MeritFlawRating entries
6. Links Language objects
7. Creates Specialty entries
8. Creates TemplateApplication record
9. Increments times_used counter

## Reference Implementation

Mage (MtAHuman) is fully integrated. Files:
- `characters/views/mage/mtahuman.py` - Template selection view
- `characters/urls/mage/detail.py` - Template and creation URLs
- `characters/templates/characters/mage/mtahuman/template_select.html`
