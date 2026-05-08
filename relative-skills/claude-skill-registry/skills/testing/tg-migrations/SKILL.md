---
name: tg-migrations
description: Django migration best practices for the World of Darkness application. Use when creating data migrations, handling schema changes with existing data, squashing old migrations, testing migrations in CI/CD, or planning multi-step migrations for breaking changes. Triggers on migration work, database schema changes, or data transformation tasks.
---

# Migration Best Practices

## Core Principles

1. **Never edit applied migrations** - Once in production, migrations are immutable
2. **Test before deployment** - Test both forward and reverse migrations
3. **Keep migrations focused** - One logical change per migration
4. **Document complex migrations** - Explain non-obvious data transformations
5. **Plan multi-step migrations** - For breaking changes, maintain backward compatibility

## Data Migrations for Schema Changes

### When to Use Data Migrations

Create data migrations when you need to:
- Transform existing data during schema changes
- Populate new fields with calculated values
- Migrate data between models (e.g., JSONField to related models)
- Clean up or normalize existing data

### Three-Step Pattern for New Required Fields

**Step 1: Add field as nullable**
```python
operations = [
    migrations.AddField(
        model_name='character',
        name='generation',
        field=models.IntegerField(null=True, blank=True),
    ),
]
```

**Step 2: Populate with data**
```python
def populate_generation(apps, schema_editor):
    Character = apps.get_model('characters', 'Character')
    for char in Character.objects.filter(character_type='vampire', generation__isnull=True):
        char.generation = 13
        char.save(update_fields=['generation'])

def reverse_populate(apps, schema_editor):
    Character = apps.get_model('characters', 'Character')
    Character.objects.update(generation=None)

operations = [
    migrations.RunPython(populate_generation, reverse_populate),
]
```

**Step 3: Make non-nullable**
```python
operations = [
    migrations.AlterField(
        model_name='character',
        name='generation',
        field=models.IntegerField(default=13),
    ),
]
```

## Data Migration Best Practices

### Use Historical Models

```python
def migrate_data(apps, schema_editor):
    # CORRECT - uses historical model state
    Character = apps.get_model('characters', 'Character')

    # WRONG - uses current model which may have different fields
    from characters.models import Character  # Don't do this!
```

### Handle Large Datasets

```python
def migrate_large_dataset(apps, schema_editor):
    Character = apps.get_model('characters', 'Character')

    # Use iterator() to prevent loading all into memory
    for char in Character.objects.iterator(chunk_size=1000):
        char.new_field = calculate_value(char)
        char.save(update_fields=['new_field'])

    # Or use bulk operations
    updates = []
    for char in Character.objects.iterator(chunk_size=1000):
        char.new_field = calculate_value(char)
        updates.append(char)
        if len(updates) >= 1000:
            Character.objects.bulk_update(updates, ['new_field'])
            updates = []
    if updates:
        Character.objects.bulk_update(updates, ['new_field'])
```

### Always Provide Reverse Migrations

```python
operations = [
    migrations.RunPython(
        forward_migration,
        reverse_migration,  # Always provide this
    ),
]
```

### Make Migrations Idempotent

```python
def migrate_data(apps, schema_editor):
    """Migration that can safely run multiple times."""
    Model = apps.get_model('app', 'Model')
    
    # Check before creating
    if not Model.objects.filter(special_flag=True).exists():
        # Perform migration
        pass
```

## Migration Squashing

### When to Squash

- App has 50+ migrations
- Migrations are all applied to production
- Old migrations contain outdated data transformations

### Squashing Process

```bash
# 1. Identify range
python manage.py showmigrations characters

# 2. Create squashed migration
python manage.py squashmigrations characters 0001 0050

# 3. Test on fresh database
python manage.py migrate characters

# 4. Verify and run tests
python manage.py check
python manage.py test characters
```

### After Squashing

After squashed migration is in production for several weeks:
```bash
# Remove old migration files
rm characters/migrations/0001_initial.py
# ... through 0050

# Remove replaces attribute from squashed migration
# Edit and remove: replaces = [...]
```

## Common Migration Patterns

### Renaming a Field (Safe)

```python
# Step 1: Add new field
operations = [migrations.AddField('Model', 'new_name', field=...)]

# Step 2: Copy data
operations = [
    migrations.RunPython(
        lambda apps, se: apps.get_model('app', 'Model').objects.update(new_name=F('old_name'))
    ),
]

# Step 3: Remove old field
operations = [migrations.RemoveField('Model', 'old_name')]
```

### Changing Field Type

```python
# Step 1: Add new field with new type
operations = [migrations.AddField('Model', 'field_new', new_field_type)]

# Step 2: Transform and copy data
def transform_data(apps, schema_editor):
    Model = apps.get_model('app', 'Model')
    for obj in Model.objects.iterator():
        obj.field_new = transform(obj.field_old)
        obj.save(update_fields=['field_new'])

# Step 3: Remove old field
operations = [migrations.RemoveField('Model', 'field_old')]

# Step 4: Rename new field
operations = [migrations.RenameField('Model', 'field_new', 'field_old')]
```

## Testing Migrations

### CI/CD Migration Tests

```bash
# Check for conflicts
python manage.py makemigrations --check --dry-run

# Test forward
python manage.py migrate

# Test backward (last 3)
python manage.py migrate characters 0000
python manage.py migrate characters
```

### Migration Test Class

```python
from django.test import TransactionTestCase
from django.core.management import call_command

class MigrationTestCase(TransactionTestCase):
    migrate_from = None
    migrate_to = None
    app_name = 'characters'

    def setUp(self):
        if self.migrate_from:
            call_command('migrate', self.app_name, self.migrate_from)
        super().setUp()

    def migrate(self, target):
        call_command('migrate', self.app_name, target)

    def test_migration_forward_backward(self):
        if not self.migrate_to or not self.migrate_from:
            self.skipTest("Migration range not specified")
        self.migrate(self.migrate_to)
        self.migrate(self.migrate_from)
```

## Pre-Deployment Checklist

### Before Creating Migration
- [ ] Check if change requires multi-step migration
- [ ] Plan data migration if schema affects existing data
- [ ] Consider performance impact on large tables

### Before Committing
- [ ] Migration name is descriptive
- [ ] Complex logic has comments
- [ ] Reverse migration provided for RunPython
- [ ] Tested on development database

### Before Deploying
- [ ] Tested on production database copy
- [ ] Verified performance on realistic dataset
- [ ] Documented in deployment guide if manual steps needed

## Troubleshooting

### Migration Conflicts

```bash
# Django auto-detects and creates merge migration
python manage.py makemigrations
```

### Fake Migrations (Emergency)

```bash
# Mark as applied without running
python manage.py migrate app_name 0042 --fake

# Only use when database state matches migration
```

### Rolling Back

```bash
# Rollback to previous
python manage.py migrate app_name 0041_previous

# Fix bad migration, create new one
python manage.py makemigrations
python manage.py migrate
```
