---
name: zhongyi-crud-module
description: Create a new Django CRUD module with complete model, views, forms, serializers, admin, and dashboard integration. Use when adding a new feature module to the zhongyi TCM system that needs Create, Read, Update, Delete operations and should appear in navigation/dashboard.
---

# Zhongyi CRUD Module Generator

This skill guides you through creating a complete CRUD module for the zhongyi TCM system with all necessary components and dashboard integration.

## Module Creation Checklist

When creating a new module, complete ALL of the following steps:

### Step 1: Create Django App Structure

Create the app directory with all required files:

```bash
cd /home/user/zhongyi-system/zhongyi_project
python manage.py startapp <app_name>
```

The app must contain:
```
<app_name>/
├── __init__.py
├── models.py          # Database models
├── views.py           # Class-based views
├── forms.py           # Django forms
├── urls.py            # URL routing
├── admin.py           # Admin configuration
├── serializers.py     # DRF serializers
├── apps.py            # App configuration
└── migrations/
```

### Step 2: Create Model

In `<app_name>/models.py`:

```python
from django.db import models
from django.conf import settings
from django.utils.translation import gettext_lazy as _

class <ModelName>(models.Model):
    """
    <Model description in English and Chinese>
    """

    # Define choices if needed
    class Status(models.TextChoices):
        ACTIVE = 'active', _('Active (活跃)')
        INACTIVE = 'inactive', _('Inactive (非活跃)')

    # Required: Core fields
    name = models.CharField(_('Name (名称)'), max_length=200)
    # Add your specific fields here...

    # Required: Relationship to practitioner
    assigned_practitioner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='<app_name>_items',
        verbose_name=_('Assigned Practitioner (负责医师)')
    )

    # Required: Timestamps
    created_at = models.DateTimeField(_('Created At (创建时间)'), auto_now_add=True)
    updated_at = models.DateTimeField(_('Updated At (更新时间)'), auto_now=True)

    # Required: Soft delete support
    is_active = models.BooleanField(_('Active (活跃)'), default=True)

    class Meta:
        verbose_name = _('<Model Name> (<中文名>)')
        verbose_name_plural = _('<Model Names> (<中文名复数>)')
        ordering = ['-updated_at']

    def __str__(self):
        return self.name
```

### Step 3: Create Forms

In `<app_name>/forms.py`:

```python
from django import forms
from django.utils.translation import gettext_lazy as _
from .models import <ModelName>

class <ModelName>Form(forms.ModelForm):
    class Meta:
        model = <ModelName>
        fields = (
            'name',
            # Add all editable fields
            # Exclude: id, created_at, updated_at, assigned_practitioner (auto-set)
        )
        widgets = {
            'name': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': _('Enter name')
            }),
            # Add widgets for all fields with Bootstrap5 classes:
            # - TextInput: 'form-control'
            # - Select: 'form-select'
            # - Textarea: 'form-control', rows: 4
            # - CheckboxInput: 'form-check-input'
            # - DateInput: 'form-control', type: 'date'
            # - NumberInput: 'form-control'
        }
```

### Step 4: Create Views

In `<app_name>/views.py`:

```python
from django.contrib import messages
from django.contrib.auth.mixins import LoginRequiredMixin, UserPassesTestMixin
from django.db.models import Q
from django.shortcuts import redirect
from django.urls import reverse_lazy
from django.utils.translation import gettext_lazy as _
from django.views.generic import ListView, DetailView, CreateView, UpdateView, DeleteView

from .models import <ModelName>
from .forms import <ModelName>Form


class PractitionerRequiredMixin(LoginRequiredMixin, UserPassesTestMixin):
    """Require user to be practitioner or admin."""
    def test_func(self):
        return self.request.user.is_practitioner or self.request.user.is_admin


class <ModelName>ListView(PractitionerRequiredMixin, ListView):
    model = <ModelName>
    template_name = '<app_name>/<modelname>_list.html'
    context_object_name = 'items'
    paginate_by = 20

    def get_queryset(self):
        queryset = <ModelName>.objects.filter(is_active=True)

        # Filter by practitioner for non-admin users
        if self.request.user.is_practitioner and not self.request.user.is_admin:
            queryset = queryset.filter(assigned_practitioner=self.request.user)

        # Search functionality
        search = self.request.GET.get('search')
        if search:
            queryset = queryset.filter(
                Q(name__icontains=search)
                # Add more searchable fields with |
            )

        return queryset.order_by('-updated_at')


class <ModelName>DetailView(PractitionerRequiredMixin, DetailView):
    model = <ModelName>
    template_name = '<app_name>/<modelname>_detail.html'
    context_object_name = 'item'


class <ModelName>CreateView(PractitionerRequiredMixin, CreateView):
    model = <ModelName>
    form_class = <ModelName>Form
    template_name = '<app_name>/<modelname>_form.html'
    success_url = reverse_lazy('<app_name>:list')

    def form_valid(self, form):
        form.instance.assigned_practitioner = self.request.user
        messages.success(self.request, _('<ModelName> created successfully'))
        return super().form_valid(form)


class <ModelName>UpdateView(PractitionerRequiredMixin, UpdateView):
    model = <ModelName>
    form_class = <ModelName>Form
    template_name = '<app_name>/<modelname>_form.html'
    success_url = reverse_lazy('<app_name>:list')

    def form_valid(self, form):
        messages.success(self.request, _('<ModelName> updated successfully'))
        return super().form_valid(form)


class <ModelName>DeleteView(PractitionerRequiredMixin, DeleteView):
    model = <ModelName>
    template_name = '<app_name>/<modelname>_confirm_delete.html'
    success_url = reverse_lazy('<app_name>:list')

    def delete(self, request, *args, **kwargs):
        self.object = self.get_object()
        # Soft delete
        self.object.is_active = False
        self.object.save()
        messages.success(request, _('<ModelName> deleted successfully'))
        return redirect(self.success_url)
```

### Step 5: Create URLs

In `<app_name>/urls.py`:

```python
from django.urls import path
from . import views

app_name = '<app_name>'

urlpatterns = [
    path('', views.<ModelName>ListView.as_view(), name='list'),
    path('create/', views.<ModelName>CreateView.as_view(), name='create'),
    path('<int:pk>/', views.<ModelName>DetailView.as_view(), name='detail'),
    path('<int:pk>/edit/', views.<ModelName>UpdateView.as_view(), name='update'),
    path('<int:pk>/delete/', views.<ModelName>DeleteView.as_view(), name='delete'),
]
```

### Step 6: Create Admin Configuration

In `<app_name>/admin.py`:

```python
from django.contrib import admin
from django.utils.translation import gettext_lazy as _
from .models import <ModelName>


@admin.register(<ModelName>)
class <ModelName>Admin(admin.ModelAdmin):
    list_display = ('name', 'assigned_practitioner', 'is_active', 'created_at', 'updated_at')
    list_filter = ('is_active', 'assigned_practitioner', 'created_at')
    search_fields = ('name',)  # Add searchable fields
    readonly_fields = ('created_at', 'updated_at')
    ordering = ('-updated_at',)
    date_hierarchy = 'created_at'

    fieldsets = (
        (_('Basic Information (基本信息)'), {
            'fields': ('name',)  # Add main fields
        }),
        (_('Assignment (分配)'), {
            'fields': ('assigned_practitioner', 'is_active')
        }),
        (_('Timestamps (时间戳)'), {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
```

### Step 7: Create Serializers

In `<app_name>/serializers.py`:

```python
from rest_framework import serializers
from .models import <ModelName>


class <ModelName>ListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for list views."""
    assigned_practitioner_name = serializers.CharField(
        source='assigned_practitioner.get_full_name',
        read_only=True
    )

    class Meta:
        model = <ModelName>
        fields = ['id', 'name', 'assigned_practitioner_name', 'created_at']


class <ModelName>DetailSerializer(serializers.ModelSerializer):
    """Full serializer with all fields."""
    assigned_practitioner_id = serializers.PrimaryKeyRelatedField(
        source='assigned_practitioner',
        queryset=__import__('django.contrib.auth', fromlist=['get_user_model']).get_user_model().objects.filter(role='practitioner'),
        write_only=True,
        required=False
    )

    class Meta:
        model = <ModelName>
        fields = '__all__'
        read_only_fields = ['id', 'created_at', 'updated_at']
```

### Step 8: Create Templates

Create the following templates in `templates/<app_name>/`:

#### List Template (`<modelname>_list.html`):

```html
{% extends 'base.html' %}
{% load i18n %}

{% block title %}{% trans "<Model Names>" %}{% endblock %}

{% block content %}
<div class="container my-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2><i class="bi bi-icon-name"></i> {% trans "<Model Names> (<中文名>)" %}</h2>
        <a href="{% url '<app_name>:create' %}" class="btn btn-primary">
            <i class="bi bi-plus-lg"></i> {% trans "Add New" %}
        </a>
    </div>

    <!-- Search -->
    <div class="card mb-4">
        <div class="card-body">
            <form method="get" class="row g-3">
                <div class="col-md-10">
                    <input type="text" name="search" class="form-control"
                           placeholder="{% trans 'Search...' %}"
                           value="{{ request.GET.search }}">
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-outline-primary w-100">
                        <i class="bi bi-search"></i> {% trans "Search" %}
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Results -->
    <div class="card">
        <div class="card-body">
            {% if items %}
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>{% trans "Name" %}</th>
                        <th>{% trans "Created" %}</th>
                        <th>{% trans "Actions" %}</th>
                    </tr>
                </thead>
                <tbody>
                    {% for item in items %}
                    <tr>
                        <td>
                            <a href="{% url '<app_name>:detail' item.pk %}">{{ item.name }}</a>
                        </td>
                        <td>{{ item.created_at|date:"Y-m-d H:i" }}</td>
                        <td>
                            <a href="{% url '<app_name>:update' item.pk %}" class="btn btn-sm btn-outline-primary">
                                <i class="bi bi-pencil"></i>
                            </a>
                            <a href="{% url '<app_name>:delete' item.pk %}" class="btn btn-sm btn-outline-danger">
                                <i class="bi bi-trash"></i>
                            </a>
                        </td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>

            <!-- Pagination -->
            {% if page_obj.has_other_pages %}
            <nav aria-label="Page navigation">
                <ul class="pagination justify-content-center">
                    {% if page_obj.has_previous %}
                    <li class="page-item">
                        <a class="page-link" href="?page={{ page_obj.previous_page_number }}">{% trans "Previous" %}</a>
                    </li>
                    {% endif %}
                    <li class="page-item disabled">
                        <span class="page-link">{{ page_obj.number }} / {{ page_obj.paginator.num_pages }}</span>
                    </li>
                    {% if page_obj.has_next %}
                    <li class="page-item">
                        <a class="page-link" href="?page={{ page_obj.next_page_number }}">{% trans "Next" %}</a>
                    </li>
                    {% endif %}
                </ul>
            </nav>
            {% endif %}

            {% else %}
            <p class="text-muted">{% trans "No items found." %}</p>
            {% endif %}
        </div>
    </div>
</div>
{% endblock %}
```

#### Form Template (`<modelname>_form.html`):

```html
{% extends 'base.html' %}
{% load i18n crispy_forms_tags %}

{% block title %}
{% if object %}{% trans "Edit" %}{% else %}{% trans "Create" %}{% endif %} {% trans "<Model Name>" %}
{% endblock %}

{% block content %}
<div class="container my-4">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">
                    <h4>
                        {% if object %}
                        <i class="bi bi-pencil"></i> {% trans "Edit <Model Name>" %}
                        {% else %}
                        <i class="bi bi-plus-lg"></i> {% trans "Create <Model Name>" %}
                        {% endif %}
                    </h4>
                </div>
                <div class="card-body">
                    <form method="post">
                        {% csrf_token %}
                        {% crispy form %}
                        <div class="d-flex justify-content-between mt-3">
                            <a href="{% url '<app_name>:list' %}" class="btn btn-secondary">
                                <i class="bi bi-arrow-left"></i> {% trans "Back" %}
                            </a>
                            <button type="submit" class="btn btn-primary">
                                <i class="bi bi-check-lg"></i> {% trans "Save" %}
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

#### Detail Template (`<modelname>_detail.html`):

```html
{% extends 'base.html' %}
{% load i18n %}

{% block title %}{{ item.name }}{% endblock %}

{% block content %}
<div class="container my-4">
    <div class="card">
        <div class="card-header d-flex justify-content-between align-items-center">
            <h4><i class="bi bi-info-circle"></i> {{ item.name }}</h4>
            <div>
                <a href="{% url '<app_name>:update' item.pk %}" class="btn btn-outline-primary">
                    <i class="bi bi-pencil"></i> {% trans "Edit" %}
                </a>
                <a href="{% url '<app_name>:delete' item.pk %}" class="btn btn-outline-danger">
                    <i class="bi bi-trash"></i> {% trans "Delete" %}
                </a>
            </div>
        </div>
        <div class="card-body">
            <dl class="row">
                <dt class="col-sm-3">{% trans "Name" %}</dt>
                <dd class="col-sm-9">{{ item.name }}</dd>

                <!-- Add more fields -->

                <dt class="col-sm-3">{% trans "Created At" %}</dt>
                <dd class="col-sm-9">{{ item.created_at|date:"Y-m-d H:i" }}</dd>

                <dt class="col-sm-3">{% trans "Updated At" %}</dt>
                <dd class="col-sm-9">{{ item.updated_at|date:"Y-m-d H:i" }}</dd>
            </dl>
        </div>
        <div class="card-footer">
            <a href="{% url '<app_name>:list' %}" class="btn btn-secondary">
                <i class="bi bi-arrow-left"></i> {% trans "Back to List" %}
            </a>
        </div>
    </div>
</div>
{% endblock %}
```

#### Delete Confirmation Template (`<modelname>_confirm_delete.html`):

```html
{% extends 'base.html' %}
{% load i18n %}

{% block title %}{% trans "Delete" %} {{ object.name }}{% endblock %}

{% block content %}
<div class="container my-4">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="card border-danger">
                <div class="card-header bg-danger text-white">
                    <h4><i class="bi bi-exclamation-triangle"></i> {% trans "Confirm Delete" %}</h4>
                </div>
                <div class="card-body">
                    <p>{% trans "Are you sure you want to delete" %} <strong>{{ object.name }}</strong>?</p>
                    <form method="post">
                        {% csrf_token %}
                        <div class="d-flex justify-content-between">
                            <a href="{% url '<app_name>:list' %}" class="btn btn-secondary">
                                <i class="bi bi-x-lg"></i> {% trans "Cancel" %}
                            </a>
                            <button type="submit" class="btn btn-danger">
                                <i class="bi bi-trash"></i> {% trans "Delete" %}
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
{% endblock %}
```

### Step 9: Register App in Settings

Edit `zhongyi_project/settings.py`:

```python
INSTALLED_APPS = [
    # ... existing apps
    '<app_name>',
]
```

### Step 10: Add to Main URLs

Edit `zhongyi_project/urls.py`:

```python
urlpatterns += i18n_patterns(
    # ... existing patterns
    path('<app_name>/', include('<app_name>.urls')),
    prefix_default_language=False,
)
```

### Step 11: Add to Navigation

Edit `templates/base.html`, add to the navigation menu:

```html
<!-- In the navbar-nav section -->
<li class="nav-item">
    <a class="nav-link {% if request.resolver_match.app_name == '<app_name>' %}active{% endif %}"
       href="{% url '<app_name>:list' %}">
        <i class="bi bi-icon-name"></i> {% trans "<Module Name> (<中文名>)" %}
    </a>
</li>
```

### Step 12: Add to Dashboard/Home

Edit `templates/home.html`, add a quick access card:

```html
<!-- In the quick access grid -->
<div class="col-md-3 col-6">
    <a href="{% url '<app_name>:list' %}" class="card text-center text-decoration-none p-3 h-100">
        <i class="bi bi-icon-name fs-1 text-primary"></i>
        <h6 class="mt-2 mb-1"><中文名></h6>
        <small class="text-muted"><Module Name></small>
    </a>
</div>
```

### Step 13: Add to Dashboard Statistics (Optional)

If you want to show counts on the dashboard, edit `accounts/views.py`:

```python
def dashboard_view(request):
    context = {'user': request.user}

    if request.user.is_practitioner:
        # Add your module count
        from <app_name>.models import <ModelName>
        context['<app_name>_count'] = <ModelName>.objects.filter(
            assigned_practitioner=request.user,
            is_active=True
        ).count()

    return render(request, 'accounts/dashboard.html', context)
```

### Step 14: Add API Endpoint (Optional)

If you need REST API access, edit `api/urls.py`:

```python
from <app_name>.serializers import <ModelName>ListSerializer, <ModelName>DetailSerializer
from rest_framework import viewsets

class <ModelName>ViewSet(viewsets.ModelViewSet):
    queryset = <ModelName>.objects.filter(is_active=True)
    permission_classes = [IsAuthenticated, IsPractitionerOrAdmin]

    def get_serializer_class(self):
        if self.action == 'list':
            return <ModelName>ListSerializer
        return <ModelName>DetailSerializer

# Register in router
router.register(r'<app_name>', <ModelName>ViewSet)
```

### Step 15: Create and Run Migrations

```bash
cd /home/user/zhongyi-system/zhongyi_project
python manage.py makemigrations <app_name>
python manage.py migrate
```

## Quick Reference: Files to Modify

When adding a new module, modify these existing files:

1. **Settings**: `zhongyi_project/settings.py` - Add to INSTALLED_APPS
2. **URLs**: `zhongyi_project/urls.py` - Add URL include
3. **Navigation**: `templates/base.html` - Add nav link
4. **Home**: `templates/home.html` - Add quick access card
5. **Dashboard** (optional): `accounts/views.py` - Add stats
6. **API** (optional): `api/urls.py` - Register ViewSet

## Bootstrap Icons Reference

Common icons for TCM system:
- Health: `bi-heart-pulse`, `bi-activity`
- People: `bi-people`, `bi-person`
- Medical: `bi-clipboard2-pulse`, `bi-capsule`
- Documents: `bi-file-medical`, `bi-journal-text`
- Plants/Herbs: `bi-flower1`, `bi-tree`
- Actions: `bi-plus-lg`, `bi-pencil`, `bi-trash`, `bi-search`

## Example: Creating a "Treatments" Module

To create a new treatments module:

1. Replace `<app_name>` with `treatments`
2. Replace `<ModelName>` with `Treatment`
3. Replace `<modelname>` with `treatment`
4. Add fields like: treatment_type, description, duration, cost
5. Choose icon: `bi-bandaid`
6. Follow all 15 steps above

This will give you a fully functional CRUD module integrated with the dashboard and navigation.
