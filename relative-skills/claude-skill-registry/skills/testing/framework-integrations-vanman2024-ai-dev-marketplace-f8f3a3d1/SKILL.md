---
name: framework-integrations
description: Django, Flask, FastAPI integration patterns for Celery. Use when integrating Celery with Django, Flask, or FastAPI, setting up framework-specific configurations, handling application contexts, managing database transactions with tasks, configuring async workers, or when user mentions Django Celery, Flask Celery, FastAPI background tasks, framework integration, or web framework task queues.
allowed-tools: Read, Write, Bash, Glob, Grep
---

# Framework Integrations

**Purpose:** Integrate Celery with Django, Flask, and FastAPI using framework-specific patterns and best practices.

**Activation Triggers:**
- Setting up Celery with Django/Flask/FastAPI
- Application context issues in tasks
- Database transaction handling
- Framework-specific configuration
- Async worker setup
- Request context in background tasks

**Key Resources:**
- `templates/django-integration/` - Django app structure with Celery
- `templates/flask-integration/` - Flask factory pattern with Celery
- `templates/fastapi-integration/` - FastAPI async integration
- `templates/transaction-safe-django.py` - Django transaction handling
- `templates/fastapi-background.py` - FastAPI BackgroundTasks vs Celery
- `templates/flask-context.py` - Flask app context in tasks
- `scripts/test-integration.sh` - Test framework integration
- `scripts/validate-framework.sh` - Validate framework setup
- `examples/` - Complete integration examples

## Integration Patterns

### Django + Celery

**Core Setup:**

1. **Install packages:**
```bash
pip install celery django-celery-beat django-celery-results
```

2. **Project structure:**
```
myproject/
├── myproject/
│   ├── __init__.py
│   ├── celery.py      # Celery app configuration
│   ├── settings.py    # Django settings with Celery config
│   └── urls.py
├── myapp/
│   ├── tasks.py       # Task definitions
│   └── views.py       # Views that call tasks
└── manage.py
```

3. **Use template:**
```bash
# Copy Django integration template
cp -r templates/django-integration/* /path/to/project/
```

**Key Patterns:**

**Transaction-Safe Tasks:**
- Template: `templates/transaction-safe-django.py`
- Use `transaction.on_commit()` to delay task execution
- Prevents tasks from running before database commits
- Essential for tasks that depend on database state

**Django ORM in Tasks:**
- Always use ORM (don't pass model instances)
- Pass primary keys, reload in task
- Close connections explicitly if needed
- Use `CELERY_BROKER_CONNECTION_RETRY_ON_STARTUP = True`

**Configuration:**
- Set `CELERY_BROKER_URL` in settings.py
- Configure `CELERY_RESULT_BACKEND` for task results
- Use `django-celery-beat` for periodic tasks (admin UI)
- Use `django-celery-results` to store results in Django DB

### Flask + Celery

**Core Setup:**

1. **Install packages:**
```bash
pip install celery flask
```

2. **Factory pattern structure:**
```
myapp/
├── __init__.py        # Flask app factory
├── celery.py          # Celery app with Flask context
├── tasks.py           # Task definitions
├── views.py           # Routes
└── config.py          # Configuration
```

3. **Use template:**
```bash
# Copy Flask integration template
cp -r templates/flask-integration/* /path/to/project/
```

**Key Patterns:**

**Application Context:**
- Template: `templates/flask-context.py`
- Use `app.app_context()` for database/config access
- Required for Flask-SQLAlchemy, Flask-Mail, etc.
- Push context in task decorator

**Factory Pattern:**
- Create Celery app that creates Flask app internally
- Subclass Celery task to push app context
- Allows tasks to access Flask extensions
- Essential for modular Flask apps

**Configuration:**
- Use Flask config for broker/backend URLs
- Set `CELERY_BROKER_URL` from `app.config`
- Share config between Flask and Celery
- Load different configs per environment

### FastAPI + Celery

**Core Setup:**

1. **Install packages:**
```bash
pip install celery fastapi uvicorn
```

2. **Async structure:**
```
app/
├── main.py            # FastAPI app
├── celery_app.py      # Celery configuration
├── tasks.py           # Task definitions
├── routers/
│   └── api.py         # API routes
└── config.py          # Settings
```

3. **Use template:**
```bash
# Copy FastAPI integration template
cp -r templates/fastapi-integration/* /path/to/project/
```

**Key Patterns:**

**Async Tasks:**
- Celery tasks can be async or sync
- FastAPI endpoints are async by default
- Use `.delay()` or `.apply_async()` from sync context
- Use `asyncio.create_task()` for FastAPI BackgroundTasks

**BackgroundTasks vs Celery:**
- Template: `templates/fastapi-background.py`
- **FastAPI BackgroundTasks:** Short tasks (<30s), no retries, dies with request
- **Celery:** Long tasks, retries, persistent, distributed workers
- Use both: BackgroundTasks for logging, Celery for heavy work

**Dependency Injection:**
- Don't inject FastAPI dependencies into Celery tasks
- Tasks run in separate worker processes
- Pass data explicitly, not dependency objects
- Reload database objects in task

**Configuration:**
- Use Pydantic Settings for both FastAPI and Celery
- Share config class between apps
- Set broker/backend from environment variables
- Use `app.state` for shared resources (if needed)

## Common Integration Issues

### Database Connections

**Problem:** "Lost connection to MySQL/Postgres during task"

**Solution:**
```python
# Close connections before task runs (Django)
from django.db import connection
connection.close()

# Or configure connection pooling
CELERY_BROKER_POOL_LIMIT = None  # Unlimited
DATABASES = {
    'default': {
        'CONN_MAX_AGE': 0,  # Close after request
    }
}
```

### Application Context

**Problem:** "Working outside of application context" (Flask)

**Solution:**
```python
# Use context template
from templates.flask_context import make_celery
celery = make_celery(app)

# Or manually push context
@celery.task
def my_task():
    with app.app_context():
        # Access db, config, etc.
        pass
```

### Transaction Timing

**Problem:** Task runs before database commit (Django)

**Solution:**
```python
# Use on_commit
from django.db import transaction

def my_view(request):
    obj = MyModel.objects.create(name="test")
    transaction.on_commit(
        lambda: process_object.delay(obj.id)
    )
```

### Async/Sync Mixing

**Problem:** "Cannot call async function from sync context" (FastAPI)

**Solution:**
```python
# Celery task (sync or async)
@celery.task
async def process_data(data):
    # Can use async here
    result = await some_async_function(data)
    return result

# FastAPI endpoint (async)
@app.post("/process")
async def process(data: dict):
    # Call Celery from async context
    task = process_data.delay(data)
    return {"task_id": task.id}
```

## Validation & Testing

### Validate Framework Setup

```bash
# Check integration is configured correctly
./scripts/validate-framework.sh django
./scripts/validate-framework.sh flask
./scripts/validate-framework.sh fastapi
```

**Checks:**
- Required packages installed
- Celery app configured correctly
- Framework config has broker URL
- Task discovery working
- App context handling (Flask)
- Transaction handling (Django)

### Test Integration

```bash
# Run integration tests
./scripts/test-integration.sh django
./scripts/test-integration.sh flask
./scripts/test-integration.sh fastapi
```

**Tests:**
- Task execution from framework
- Database access in tasks
- Context handling
- Transaction safety
- Async task execution (FastAPI)
- Error propagation

## Security Considerations

**CRITICAL: Never hardcode credentials in integration code**

✅ **CORRECT:**
```python
# Django settings.py
CELERY_BROKER_URL = os.getenv('CELERY_BROKER_URL', 'redis://your_redis_url_here')

# Flask config.py
CELERY_BROKER_URL = os.environ.get('CELERY_BROKER_URL', 'redis://your_redis_url_here')

# FastAPI config.py
class Settings(BaseSettings):
    celery_broker_url: str = "redis://your_redis_url_here"

    class Config:
        env_file = ".env"
```

❌ **WRONG:**
```python
CELERY_BROKER_URL = "redis://actual-password@redis.example.com"
CELERY_BROKER_URL = "amqp://user:real_password@rabbitmq"
```

**Always:**
- Use environment variables for broker URLs
- Use placeholders in examples: `your_redis_url_here`
- Add `.env` to `.gitignore`
- Document where to obtain credentials
- Never commit actual connection strings

## Framework-Specific Resources

### Django
- **Template:** `templates/django-integration/`
- **Transaction Safety:** `templates/transaction-safe-django.py`
- **Example:** `examples/django-complete-setup.md`
- Includes: settings.py, celery.py, tasks.py, views.py

### Flask
- **Template:** `templates/flask-integration/`
- **Context Handling:** `templates/flask-context.py`
- **Example:** `examples/flask-factory-pattern.md`
- Includes: Factory pattern, app context, extensions

### FastAPI
- **Template:** `templates/fastapi-integration/`
- **Background Tasks:** `templates/fastapi-background.py`
- **Example:** `examples/fastapi-async.md`
- Includes: Async tasks, dependency injection, BackgroundTasks vs Celery

## Quick Reference

| Framework | Context Needed | Transaction Safe | Async Support |
|-----------|---------------|------------------|---------------|
| Django    | Auto          | Use on_commit    | Via celery    |
| Flask     | Manual push   | N/A              | Via celery    |
| FastAPI   | Not needed    | N/A              | Native        |

| Package | Purpose | Required For |
|---------|---------|--------------|
| `django-celery-beat` | Periodic tasks UI | Django admin scheduling |
| `django-celery-results` | Store results in DB | Django result persistence |
| `flask` | Web framework | Flask integration |
| `fastapi[all]` | Async web framework | FastAPI integration |

---

**Supported Frameworks:** Django 4+, Flask 2+, FastAPI 0.100+
**Celery Version:** 5.3+
**Python:** 3.9+
