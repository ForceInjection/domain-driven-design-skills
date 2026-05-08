---
name: tg-testing
description: Testing patterns and organization for the World of Darkness Django application. Use when writing tests, locating test files, running test commands, or understanding test structure. Triggers on test creation, test execution, test debugging, or pytest/Django unittest work.
---

# Testing Patterns

## Commands

```bash
# Run all tests
python manage.py test

# Run app-specific tests
python manage.py test characters
python manage.py test items
python manage.py test locations

# Run specific test class/method
python manage.py test characters.tests.TestClass.test_method

# Verbose output
python manage.py test --verbosity=2
```

## File Location Pattern

Test structure mirrors source code within each app:

| Source File | Test File |
|-------------|-----------|
| `characters/models/vampire/vampire.py` | `characters/tests/models/vampire/test_vampire.py` |
| `items/views/mage/wonder.py` | `items/tests/views/mage/test_wonder.py` |
| `locations/forms/node.py` | `locations/tests/forms/test_node.py` |

## Directory Structure

```
app/
├── models/
│   └── gameline/
│       └── model.py
├── views/
│   └── gameline/
│       └── view.py
└── tests/
    ├── models/
    │   └── gameline/
    │       └── test_model.py
    └── views/
        └── gameline/
            └── test_view.py
```

## Test Class Pattern

```python
from django.test import TestCase
from django.contrib.auth import get_user_model

User = get_user_model()

class CharacterModelTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='testuser',
            password='testpass123'
        )
    
    def test_character_creation(self):
        # Test implementation
        pass
    
    def test_get_absolute_url(self):
        # Test implementation
        pass
```

## View Test Pattern

```python
from django.test import TestCase, Client
from django.urls import reverse

class CharacterViewTest(TestCase):
    def setUp(self):
        self.client = Client()
        self.user = User.objects.create_user(...)
        self.character = Character.objects.create(owner=self.user, ...)
    
    def test_detail_view_permission(self):
        response = self.client.get(
            reverse('characters:gameline:detail:character', kwargs={'pk': self.character.pk})
        )
        self.assertEqual(response.status_code, 200)
    
    def test_update_view_requires_login(self):
        response = self.client.get(
            reverse('characters:gameline:update:character', kwargs={'pk': self.character.pk})
        )
        self.assertRedirects(response, '/accounts/login/...')
```

## Test Documentation

See `docs/testing/` for detailed test documentation and reports.
