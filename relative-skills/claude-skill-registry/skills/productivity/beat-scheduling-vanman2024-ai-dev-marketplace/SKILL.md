---
name: beat-scheduling
description: Periodic task scheduling patterns with Celery Beat (crontab, interval, solar). Use when configuring periodic tasks, setting up task schedules, implementing recurring jobs, configuring django-celery-beat, or creating dynamic schedules.
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, WebFetch
---

# Beat Scheduling Skill

Provides comprehensive patterns and templates for implementing periodic task scheduling with Celery Beat, including crontab, interval, and solar schedules.

## Use When

- Configuring periodic/scheduled tasks in Celery applications
- Setting up cron-like schedules for recurring jobs
- Implementing interval-based task execution
- Configuring solar-based scheduling (sunrise/sunset triggers)
- Setting up django-celery-beat for database-backed schedules
- Creating dynamic schedules that can be modified at runtime
- Migrating from cron to Celery Beat
- Implementing time-zone aware scheduling

## Core Capabilities

### 1. Crontab Schedule Configuration

Generate crontab-based schedules with precise timing control:

```python
# See templates/crontab-schedule.py for complete implementation
from celery.schedules import crontab

app.conf.beat_schedule = {
    'daily-report': {
        'task': 'tasks.generate_report',
        'schedule': crontab(hour=0, minute=0),  # Midnight daily
    },
    'business-hours': {
        'task': 'tasks.process_orders',
        'schedule': crontab(hour='9-17', minute='*/15', day_of_week='mon-fri'),
    }
}
```

**Key patterns:**
- Daily, weekly, monthly schedules
- Business hours execution
- Complex cron expressions with multiple constraints
- Timezone-aware scheduling

### 2. Interval Schedule Configuration

Simple interval-based recurring tasks:

```python
# See templates/interval-schedule.py for complete implementation
from celery.schedules import schedule

app.conf.beat_schedule = {
    'every-30-seconds': {
        'task': 'tasks.check_status',
        'schedule': 30.0,  # Execute every 30 seconds
    },
    'every-hour': {
        'task': 'tasks.cleanup',
        'schedule': timedelta(hours=1),
    }
}
```

**Key patterns:**
- Fixed interval execution
- Relative vs absolute timing
- Preventing task overlap

### 3. Solar Schedule Configuration

Event-based scheduling using solar calculations:

```python
# See templates/solar-schedule.py for complete implementation
from celery.schedules import solar

app.conf.beat_schedule = {
    'morning-task': {
        'task': 'tasks.sunrise_routine',
        'schedule': solar('sunrise', 40.7128, -74.0060),  # NYC coordinates
    }
}
```

**Supported events:** sunrise, sunset, dawn_civil, dusk_astronomical, solar_noon

### 4. Django Celery Beat Integration

Database-backed dynamic schedules:

```python
# See templates/django-celery-beat.py for complete implementation
# Schedules stored in Django database, editable via Django Admin
INSTALLED_APPS += ['django_celery_beat']
CELERY_BEAT_SCHEDULER = 'django_celery_beat.schedulers:DatabaseScheduler'
```

**Benefits:**
- Edit schedules without code changes
- Django Admin interface for schedule management
- Persistence across deployments
- Multiple scheduler instances coordination

### 5. Dynamic Schedule Updates

Programmatic schedule registration:

```python
# See templates/dynamic-schedules.py for complete implementation
from celery import Celery

app = Celery('tasks')

@app.on_after_configure.connect
def setup_periodic_tasks(sender, **kwargs):
    # Add tasks programmatically
    sender.add_periodic_task(30.0, check_status.s(), name='status-check')
    sender.add_periodic_task(
        crontab(hour=7, minute=30),
        morning_report.s(),
        name='morning-report'
    )
```

## Template Usage

### Crontab Schedule Template
**File:** `templates/crontab-schedule.py`

Use for precise timing requirements:
- Daily/weekly/monthly reports
- Business hours processing
- End-of-day batch jobs
- Time-zone specific execution

### Interval Schedule Template
**File:** `templates/interval-schedule.py`

Use for fixed interval tasks:
- Health checks every N seconds
- Regular cleanup jobs
- Polling external services
- Rate-limited API calls

### Solar Schedule Template
**File:** `templates/solar-schedule.py`

Use for location-based timing:
- Outdoor equipment control
- Photography/lighting automation
- Energy optimization based on daylight
- Agricultural/environmental monitoring

### Django Celery Beat Template
**File:** `templates/django-celery-beat.py`

Use for runtime schedule management:
- Multi-tenant applications with per-tenant schedules
- User-configurable recurring tasks
- Dynamic schedule requirements
- Administrative schedule control

### Dynamic Schedules Template
**File:** `templates/dynamic-schedules.py`

Use for programmatic configuration:
- Environment-based schedule setup
- Plugin/module-based task registration
- Conditional schedule activation
- Testing and development schedules

## Script Tools

### validate-schedule.sh
Validates schedule configuration syntax and structure.

**Usage:**
```bash
bash scripts/validate-schedule.sh <config-file>
```

**Checks:**
- Valid crontab expressions
- Proper schedule type usage
- Timezone configuration
- Task name references
- Schedule conflict detection

### test-beat.sh
Tests Celery Beat configuration and execution.

**Usage:**
```bash
bash scripts/test-beat.sh <celery-app>
```

**Tests:**
- Beat scheduler startup
- Schedule registration
- Task execution timing
- Timezone handling

## Implementation Workflow

### 1. Choose Schedule Type
Determine the appropriate scheduling pattern:
- **Crontab:** Specific times (daily at 3am, weekdays at 9am)
- **Interval:** Fixed frequency (every 30 seconds, hourly)
- **Solar:** Sun-based events (sunrise, sunset)

### 2. Select Template
Load the appropriate template for your schedule type:
```bash
# For crontab schedules
Read: templates/crontab-schedule.py

# For interval schedules
Read: templates/interval-schedule.py

# For Django integration
Read: templates/django-celery-beat.py
```

### 3. Configure Schedule
Customize the template with your task details:
- Task name and function reference
- Schedule expression
- Task arguments and options
- Timezone settings

### 4. Validate Configuration
Run validation to catch errors:
```bash
bash scripts/validate-schedule.sh celeryconfig.py
```

### 5. Test Execution
Verify schedule works as expected:
```bash
bash scripts/test-beat.sh myapp
```

### 6. Deploy Beat Scheduler
Start Celery Beat in production:
```bash
celery -A myapp beat --loglevel=info
```

## Best Practices

### Schedule Design
- Use crontab for time-of-day requirements
- Use intervals for fixed frequency needs
- Consider timezone implications for distributed systems
- Avoid overlapping executions with proper task design

### Production Deployment
- Run beat scheduler as separate process (not embedded in worker)
- Use persistent schedule storage (django-celery-beat) for production
- Monitor beat scheduler health and uptime
- Implement locking for tasks that shouldn't overlap

### Testing
- Test schedules with shorter intervals in development
- Verify timezone handling across environments
- Test task execution at scheduled times
- Monitor task queue depth for schedule correctness

### Performance
- Limit number of scheduled tasks (beat scheduler overhead)
- Use appropriate schedule precision (avoid unnecessary frequent checks)
- Consider batch processing vs individual schedules
- Monitor beat scheduler memory and CPU usage

## Common Patterns

### Daily Reports
```python
'daily-report': {
    'task': 'reports.generate_daily',
    'schedule': crontab(hour=0, minute=0),
}
```

### Business Hours Processing
```python
'business-hours-sync': {
    'task': 'sync.external_api',
    'schedule': crontab(hour='9-17', minute='*/15', day_of_week='mon-fri'),
}
```

### Health Checks
```python
'health-check': {
    'task': 'monitoring.check_services',
    'schedule': 30.0,  # Every 30 seconds
}
```

### Weekend Maintenance
```python
'weekend-cleanup': {
    'task': 'maintenance.cleanup',
    'schedule': crontab(hour=2, minute=0, day_of_week='sat,sun'),
}
```

## Security Compliance

This skill follows strict security rules:
- All code examples use placeholder values only
- No real API keys, passwords, or secrets
- Environment variable references in all code
- `.gitignore` protection documented

## Troubleshooting

### Schedule Not Executing
- Verify beat scheduler is running
- Check schedule syntax with validation script
- Review beat scheduler logs for errors
- Confirm task name matches actual task

### Timezone Issues
- Set explicit timezone: `app.conf.timezone = 'UTC'`
- Use timezone-aware datetime objects
- Test schedule across timezone boundaries
- Review Celery timezone documentation

### Task Overlap
- Implement task locking (Redis/database)
- Use `expires` option to prevent old task execution
- Monitor task execution duration
- Adjust schedule frequency if needed

## Examples

See `examples/` directory for detailed implementation examples:
- `crontab-examples.md` - Comprehensive crontab schedule patterns
- `interval-examples.md` - Interval schedule use cases
- `django-celery-beat-setup.md` - Complete Django integration guide

## References

- **Celery Documentation:** https://docs.celeryq.dev/en/stable/userguide/periodic-tasks.html
- **Django Celery Beat:** https://django-celery-beat.readthedocs.io/
- **Crontab Reference:** https://crontab.guru/
- **Solar Events:** https://docs.celeryq.dev/en/stable/reference/celery.schedules.html#celery.schedules.solar
