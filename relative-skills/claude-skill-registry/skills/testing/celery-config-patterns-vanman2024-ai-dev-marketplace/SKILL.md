---
name: celery-config-patterns
description: Celery configuration templates for all frameworks (Django, Flask, FastAPI, standalone). Use when configuring Celery, setting up task queues, creating Celery apps, integrating with frameworks, or when user mentions Celery configuration, task queue setup, broker configuration, or framework integration.
allowed-tools: Read, Write, Bash, Glob, Grep
---

# celery-config-patterns

Provides production-ready Celery configuration templates for all major Python frameworks (Django, Flask, FastAPI, standalone) with complete broker setup (Redis, RabbitMQ), security best practices, and framework-specific integration patterns.

## Use When

- Configuring Celery for the first time in any Python project
- Integrating Celery with Django, Flask, FastAPI, or standalone applications
- Setting up Redis or RabbitMQ as message broker
- Creating production-ready Celery configurations
- Implementing task routing and queue configurations
- Setting up monitoring and logging for Celery
- Migrating Celery configurations between frameworks

## Directory Structure

```
celery-config-patterns/
├── SKILL.md                          # This file
├── scripts/
│   ├── validate-config.sh            # Validate Celery configuration
│   ├── detect-framework.sh           # Auto-detect Python framework
│   ├── generate-config.sh            # Generate framework-specific config
│   └── test-broker-connection.sh     # Test broker connectivity
├── templates/
│   ├── celery-app-standalone.py      # Standalone Celery app
│   ├── celery-app-django.py          # Django Celery integration
│   ├── celery-app-flask.py           # Flask Celery integration
│   ├── celery-app-fastapi.py         # FastAPI Celery integration
│   ├── config-redis.py               # Redis broker configuration
│   ├── config-rabbitmq.py            # RabbitMQ broker configuration
│   ├── tasks-example.py              # Sample task definitions
│   └── beat-schedule.py              # Celery Beat schedule config
└── examples/
    ├── django-setup.md               # Complete Django setup guide
    ├── flask-setup.md                # Complete Flask setup guide
    ├── fastapi-setup.md              # Complete FastAPI setup guide
    └── standalone-setup.md           # Standalone Python setup guide
```

## Instructions

### Step 1: Detect Framework

Use the detection script to identify the Python framework:

```bash
bash scripts/detect-framework.sh
```

**Detects:**
- Django (looks for `manage.py`, `settings.py`)
- Flask (looks for Flask imports, `app.py`)
- FastAPI (looks for FastAPI imports, `main.py`)
- Standalone (no framework detected)

### Step 2: Select Template

Based on framework detection, choose the appropriate template:

| Framework | Template | Integration File |
|-----------|----------|------------------|
| Django | `celery-app-django.py` | `projectname/celery.py` |
| Flask | `celery-app-flask.py` | `app/celery.py` or `celery.py` |
| FastAPI | `celery-app-fastapi.py` | `app/celery.py` or `celery.py` |
| Standalone | `celery-app-standalone.py` | `celery_app.py` |

### Step 3: Configure Broker

Choose broker configuration template:

**Redis** (Recommended for simplicity):
```python
# Use templates/config-redis.py
CELERY_BROKER_URL = 'redis://localhost:6379/0'
CELERY_RESULT_BACKEND = 'redis://localhost:6379/0'
```

**RabbitMQ** (Recommended for production):
```python
# Use templates/config-rabbitmq.py
CELERY_BROKER_URL = 'amqp://guest:guest@localhost:5672//'
CELERY_RESULT_BACKEND = 'rpc://'
```

### Step 4: Generate Configuration

Use the generation script:

```bash
bash scripts/generate-config.sh --framework=django --broker=redis
bash scripts/generate-config.sh --framework=flask --broker=rabbitmq
bash scripts/generate-config.sh --framework=fastapi --broker=redis
```

**Script will:**
1. Copy appropriate framework template
2. Apply broker configuration
3. Create environment file with placeholders
4. Add to .gitignore if needed
5. Generate setup documentation

### Step 5: Validate Configuration

Run validation script before starting Celery:

```bash
bash scripts/validate-config.sh
```

**Validates:**
- Celery app exists and is importable
- Broker connection is valid
- Configuration syntax is correct
- Required environment variables are set
- Task discovery paths are correct

### Step 6: Test Broker Connection

Verify broker connectivity:

```bash
bash scripts/test-broker-connection.sh
```

**Tests:**
- Broker URL is reachable
- Authentication credentials are valid
- Connection pool can be established
- Basic message routing works

## Template Descriptions

### celery-app-standalone.py

Standalone Celery application without web framework integration.

**Features:**
- Basic Celery app configuration
- Task autodiscovery from tasks.py
- Configurable broker and backend
- Logging setup
- Beat schedule integration

**Usage:**
```python
# celery_app.py
from celery import Celery

app = Celery('myapp')
app.config_from_object('celeryconfig')

@app.task
def add(x, y):
    return x + y
```

### celery-app-django.py

Django-specific Celery configuration using Django settings.

**Features:**
- Reads configuration from Django settings
- Auto-discovers tasks in all installed apps
- Uses Django's database for result backend (optional)
- Integrates with Django logging
- Supports Django-celery-beat for periodic tasks

**Usage:**
```python
# myproject/celery.py
import os
from celery import Celery

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'myproject.settings')
app = Celery('myproject')
app.config_from_object('django.conf:settings', namespace='CELERY')
app.autodiscover_tasks()
```

### celery-app-flask.py

Flask-specific Celery configuration with Flask app context.

**Features:**
- Flask app factory pattern support
- Celery app context integration
- Uses Flask configuration
- Compatible with Flask-Celery extensions
- Request context handling for tasks

**Usage:**
```python
# celery.py
from celery import Celery

def make_celery(app):
    celery = Celery(app.import_name)
    celery.conf.update(app.config)
    return celery

# app.py
celery = make_celery(app)
```

### celery-app-fastapi.py

FastAPI-specific Celery configuration with async support.

**Features:**
- FastAPI lifespan event integration
- Async task support
- Pydantic model validation in tasks
- Background task coordination
- API endpoint integration examples

**Usage:**
```python
# celery.py
from celery import Celery

celery_app = Celery('fastapi_app')
celery_app.config_from_object('celeryconfig')

# main.py
from fastapi import FastAPI
from celery_app import celery_app
```

### config-redis.py

Redis broker and result backend configuration.

**Features:**
- Connection pooling
- SSL/TLS support
- Sentinel configuration
- Health checks
- Connection retry logic

**Configuration:**
```python
CELERY_BROKER_URL = 'redis://localhost:6379/0'
CELERY_RESULT_BACKEND = 'redis://localhost:6379/0'
CELERY_BROKER_CONNECTION_RETRY_ON_STARTUP = True
CELERY_REDIS_MAX_CONNECTIONS = 50
```

### config-rabbitmq.py

RabbitMQ broker configuration with advanced routing.

**Features:**
- Virtual host configuration
- Exchange and queue declarations
- Routing keys and bindings
- Dead letter queues
- Priority queues

**Configuration:**
```python
CELERY_BROKER_URL = 'amqp://user:pass@localhost:5672//'
CELERY_RESULT_BACKEND = 'rpc://'
CELERY_TASK_ROUTES = {
    'app.tasks.critical': {'queue': 'critical'},
    'app.tasks.normal': {'queue': 'default'},
}
```

### tasks-example.py

Example task definitions with best practices.

**Features:**
- Basic task examples
- Task with retry logic
- Task with rate limiting
- Task with time limits
- Task with custom routing
- Task with result expiration

**Examples:**
```python
@app.task(bind=True, max_retries=3)
def process_data(self, data):
    try:
        # Process data
        return result
    except Exception as exc:
        raise self.retry(exc=exc, countdown=60)

@app.task(rate_limit='10/m')
def send_email(to, subject, body):
    # Send email
    pass
```

### beat-schedule.py

Celery Beat periodic task scheduling.

**Features:**
- Crontab schedules
- Interval schedules
- Solar schedules
- Task arguments and kwargs
- Timezone support

**Examples:**
```python
CELERY_BEAT_SCHEDULE = {
    'cleanup-every-midnight': {
        'task': 'app.tasks.cleanup',
        'schedule': crontab(hour=0, minute=0),
    },
    'report-every-monday': {
        'task': 'app.tasks.weekly_report',
        'schedule': crontab(day_of_week=1, hour=9),
    },
}
```

## Script Usage

### validate-config.sh

Validates Celery configuration for errors.

**Usage:**
```bash
bash scripts/validate-config.sh
bash scripts/validate-config.sh --config=celeryconfig.py
bash scripts/validate-config.sh --app=myapp.celery:app
```

**Checks:**
- Python syntax is valid
- Celery app is importable
- Broker URL format is correct
- Required settings are present
- Task modules can be discovered
- No conflicting configurations

**Exit Codes:**
- 0: Configuration is valid
- 1: Validation errors found
- 2: Import errors

### detect-framework.sh

Detects Python web framework in current project.

**Usage:**
```bash
bash scripts/detect-framework.sh
bash scripts/detect-framework.sh /path/to/project
```

**Output:**
```json
{
  "framework": "django",
  "version": "4.2.0",
  "celery_location": "myproject/celery.py",
  "settings_location": "myproject/settings.py"
}
```

**Detection Logic:**
1. Django: Check for `manage.py` and `settings.py`
2. Flask: Check for Flask imports and `app.py`
3. FastAPI: Check for FastAPI imports and `main.py`
4. Standalone: No framework files detected

### generate-config.sh

Generates framework-specific Celery configuration.

**Usage:**
```bash
bash scripts/generate-config.sh --framework=django --broker=redis
bash scripts/generate-config.sh --framework=flask --broker=rabbitmq --output=celery_config.py
```

**Options:**
- `--framework`: django, flask, fastapi, standalone
- `--broker`: redis, rabbitmq
- `--output`: Custom output file path
- `--with-beat`: Include Celery Beat configuration
- `--with-monitoring`: Include monitoring configuration

**Generated Files:**
- Celery app configuration
- `.env.example` with broker credentials
- Setup documentation
- Example tasks file

### test-broker-connection.sh

Tests message broker connectivity.

**Usage:**
```bash
bash scripts/test-broker-connection.sh
bash scripts/test-broker-connection.sh redis://localhost:6379/0
bash scripts/test-broker-connection.sh amqp://guest:guest@localhost:5672//
```

**Tests:**
1. DNS resolution of broker host
2. Port connectivity
3. Authentication
4. Basic message publish/consume
5. Connection pooling

**Output:**
```
✓ Broker host is reachable
✓ Port 6379 is open
✓ Authentication successful
✓ Message publish successful
✓ Message consume successful
✓ Connection pool working

All tests passed!
```

## Examples

### Django Setup Example

See `examples/django-setup.md` for complete walkthrough:

1. Install dependencies
2. Create Celery app in `myproject/celery.py`
3. Configure in `settings.py`
4. Create tasks in app directories
5. Run worker and beat

### Flask Setup Example

See `examples/flask-setup.md` for complete walkthrough:

1. Install dependencies
2. Create Celery factory function
3. Initialize with Flask app
4. Define tasks
5. Run worker

### FastAPI Setup Example

See `examples/fastapi-setup.md` for complete walkthrough:

1. Install dependencies
2. Create Celery app
3. Integrate with FastAPI lifespan
4. Create async tasks
5. Run worker alongside FastAPI

### Standalone Setup Example

See `examples/standalone-setup.md` for complete walkthrough:

1. Install Celery and broker
2. Create celery_app.py
3. Create celeryconfig.py
4. Define tasks
5. Run worker

## Security Requirements

All configuration templates and examples in this skill follow strict security rules:

**Environment Variables:**
- Broker credentials use placeholders: `your_redis_password_here`
- Connection strings never include real passwords
- All sensitive values read from environment

**Example .env.example:**
```bash
# Redis Configuration
CELERY_BROKER_URL=redis://:your_redis_password_here@localhost:6379/0
CELERY_RESULT_BACKEND=redis://:your_redis_password_here@localhost:6379/0

# RabbitMQ Configuration
CELERY_BROKER_URL=amqp://your_rabbitmq_user:your_rabbitmq_password@localhost:5672//
```

**Code Examples:**
```python
# ALWAYS read from environment
import os
CELERY_BROKER_URL = os.getenv('CELERY_BROKER_URL', 'redis://localhost:6379/0')
```

**Security Checklist:**
- [ ] No hardcoded broker passwords
- [ ] No hardcoded database credentials
- [ ] All examples use environment variables
- [ ] .env added to .gitignore
- [ ] .env.example provided with placeholders
- [ ] Documentation explains credential management

## Configuration Best Practices

**Production Settings:**
```python
# Task execution
CELERY_TASK_SERIALIZER = 'json'
CELERY_RESULT_SERIALIZER = 'json'
CELERY_ACCEPT_CONTENT = ['json']
CELERY_TIMEZONE = 'UTC'
CELERY_ENABLE_UTC = True

# Performance
CELERY_WORKER_PREFETCH_MULTIPLIER = 4
CELERY_WORKER_MAX_TASKS_PER_CHILD = 1000
CELERY_BROKER_POOL_LIMIT = 10

# Reliability
CELERY_TASK_ACKS_LATE = True
CELERY_TASK_REJECT_ON_WORKER_LOST = True
CELERY_TASK_TIME_LIMIT = 300
CELERY_TASK_SOFT_TIME_LIMIT = 240
```

**Development Settings:**
```python
# Easier debugging
CELERY_TASK_ALWAYS_EAGER = True
CELERY_TASK_EAGER_PROPAGATES = True
```

## Troubleshooting

**Broker Connection Failed:**
```bash
# Test broker connectivity
bash scripts/test-broker-connection.sh

# Check broker is running
# Redis: redis-cli ping
# RabbitMQ: rabbitmqctl status
```

**Tasks Not Discovered:**
```bash
# Validate configuration
bash scripts/validate-config.sh

# Check task module paths
celery -A myapp inspect registered
```

**Import Errors:**
```bash
# Verify Python path includes project
export PYTHONPATH="${PYTHONPATH}:/path/to/project"

# Check Celery app is importable
python -c "from myapp.celery import app; print(app)"
```

## Requirements

**Python Packages:**
- celery>=5.3.0
- redis>=4.5.0 (for Redis broker)
- kombu>=5.3.0 (for RabbitMQ broker)

**Framework-Specific:**
- Django: django-celery-beat, django-celery-results
- Flask: Flask-Celery
- FastAPI: No additional packages

**Broker Requirements:**
- Redis: redis-server running on port 6379
- RabbitMQ: rabbitmq-server running on port 5672

**System Tools:**
- bash (for scripts)
- python3 (3.8+)
- Access to broker (Redis/RabbitMQ)

---

**Skill Version:** 1.0.0
**Last Updated:** 2025-11-16
