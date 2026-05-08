---
name: routing-strategies
description: Task routing and queue management patterns for Celery including priority queues, topic exchanges, worker-specific routing, and advanced queue configurations. Use when configuring task routing, managing queues, setting up priority queues, implementing worker routing, configuring topic exchanges, or when user mentions task routing, queue management, Celery routing, worker assignments, or message broker routing.
allowed-tools: Bash, Read, Write, Edit
---

# Celery Task Routing Strategies Skill

This skill provides comprehensive templates, scripts, and patterns for implementing advanced task routing and queue management in Celery applications, including priority queues, topic-based routing, and worker-specific queue assignments.

## Overview

Effective task routing is crucial for:

1. **Performance Optimization** - Route compute-intensive tasks to dedicated workers
2. **Priority Management** - High-priority tasks bypass slower queues
3. **Resource Isolation** - Separate critical operations from background jobs
4. **Scalability** - Independent scaling of different task types

This skill covers routing with RabbitMQ, Redis, and custom broker configurations.

## Available Scripts

### 1. Test Routing Configuration

**Script**: `scripts/test-routing.sh <config-file>`

**Purpose**: Validates routing configuration and tests queue connectivity

**Checks**:
- Broker connectivity (RabbitMQ/Redis)
- Queue declarations
- Exchange configurations
- Routing key patterns
- Worker queue bindings
- Priority queue setup

**Usage**:
```bash
# Test routing configuration
./scripts/test-routing.sh ./celery_config.py

# Test with custom broker URL
BROKER_URL=amqp://user:password@localhost:5672// ./scripts/test-routing.sh ./celery_config.py

# Verbose output
VERBOSE=1 ./scripts/test-routing.sh ./celery_config.py
```

**Exit Codes**:
- `0`: All routing tests passed
- `1`: Configuration errors detected
- `2`: Broker connection failed

### 2. Validate Queue Configuration

**Script**: `scripts/validate-queues.sh <project-dir>`

**Purpose**: Validates queue setup across application code

**Checks**:
- Task decorators use valid queues
- No hardcoded queue names (use config)
- All queues defined in routing configuration
- Priority settings are valid (0-255)
- Exchange types match routing patterns
- Worker configurations reference valid queues

**Usage**:
```bash
# Validate current project
./scripts/validate-queues.sh .

# Validate specific directory
./scripts/validate-queues.sh /path/to/celery-app

# Generate detailed report
REPORT=1 ./scripts/validate-queues.sh . > queue-validation-report.md
```

**Exit Codes**:
- `0`: Validation passed
- `1`: Validation failed (must fix issues)

## Available Templates

### 1. Basic Queue Configuration

**Template**: `templates/queue-config.py`

**Features**:
- Default queue setup
- Named queues for different task types
- Queue-to-exchange bindings
- Priority settings
- Worker routing configuration

**Usage**:
```python
from celery import Celery
from templates.queue_config import CELERY_ROUTES, CELERY_QUEUES

app = Celery('myapp')
app.conf.task_routes = CELERY_ROUTES
app.conf.task_queues = CELERY_QUEUES
```

**Configuration Example**:
```python
CELERY_QUEUES = (
    Queue('default', Exchange('default'), routing_key='default'),
    Queue('high_priority', Exchange('default'), routing_key='high'),
    Queue('low_priority', Exchange('default'), routing_key='low'),
    Queue('emails', Exchange('emails'), routing_key='email.*'),
    Queue('reports', Exchange('reports'), routing_key='report.*'),
)

CELERY_ROUTES = {
    'myapp.tasks.send_email': {'queue': 'emails', 'routing_key': 'email.send'},
    'myapp.tasks.generate_report': {'queue': 'reports', 'routing_key': 'report.generate'},
    'myapp.tasks.urgent_task': {'queue': 'high_priority', 'priority': 9},
}
```

### 2. Dynamic Routing Rules

**Template**: `templates/routing-rules.py`

**Features**:
- Pattern-based routing
- Conditional routing logic
- Dynamic queue selection
- Routing by task name patterns
- Routing by task arguments

**Key Functions**:
```python
def route_task(name, args, kwargs, options, task=None, **kw):
    """
    Dynamic routing based on task name or arguments
    """
    if name.startswith('urgent.'):
        return {'queue': 'high_priority', 'priority': 9}

    if 'priority' in kwargs and kwargs['priority'] == 'high':
        return {'queue': 'high_priority'}

    if name.startswith('email.'):
        return {'queue': 'emails', 'exchange': 'emails'}

    return {'queue': 'default'}

app.conf.task_routes = (route_task,)
```

### 3. Priority Queue Setup

**Template**: `templates/priority-queues.py`

**Features**:
- Multi-level priority queues (0-255)
- Priority inheritance
- Default priority configuration
- Queue priority enforcement

**Priority Levels**:
```python
# Priority queue configuration
CELERY_QUEUES = (
    Queue('critical', Exchange('tasks'), routing_key='critical',
          queue_arguments={'x-max-priority': 10}),
    Queue('high', Exchange('tasks'), routing_key='high',
          queue_arguments={'x-max-priority': 10}),
    Queue('normal', Exchange('tasks'), routing_key='normal',
          queue_arguments={'x-max-priority': 10}),
    Queue('low', Exchange('tasks'), routing_key='low',
          queue_arguments={'x-max-priority': 10}),
)

# Task priority mapping
PRIORITY_LEVELS = {
    'critical': 10,  # Highest priority
    'high': 7,
    'normal': 5,
    'low': 2,
}

# Apply priority to task
@app.task(priority=PRIORITY_LEVELS['high'])
def urgent_processing():
    pass
```

### 4. Topic Exchange Routing

**Template**: `templates/topic-exchange.py`

**Features**:
- Topic-based routing patterns
- Wildcard routing keys
- Multi-queue routing
- Pattern matching

**Topic Patterns**:
```python
from kombu import Exchange, Queue

# Topic exchange setup
task_exchange = Exchange('tasks', type='topic', durable=True)

CELERY_QUEUES = (
    # Match specific patterns
    Queue('user.notifications', exchange=task_exchange,
          routing_key='user.notification.*'),

    # Match all email types
    Queue('emails', exchange=task_exchange,
          routing_key='email.#'),

    # Match processing tasks
    Queue('processing', exchange=task_exchange,
          routing_key='*.processing.*'),

    # Match all reports
    Queue('reports', exchange=task_exchange,
          routing_key='report.*'),
)

# Routing configuration
CELERY_ROUTES = {
    'myapp.tasks.send_welcome_email': {
        'exchange': 'tasks',
        'routing_key': 'email.welcome.send'
    },
    'myapp.tasks.notify_user': {
        'exchange': 'tasks',
        'routing_key': 'user.notification.send'
    },
}
```

### 5. Worker-Specific Routing

**Template**: `templates/worker-routing.py`

**Features**:
- Dedicated worker pools
- Worker-specific queues
- CPU vs I/O task separation
- Geographic routing
- Resource-based routing

**Worker Configuration**:
```python
# Worker pool definitions
WORKER_POOLS = {
    'cpu_intensive': {
        'queues': ['ml_training', 'video_processing', 'data_analysis'],
        'concurrency': 4,
        'prefetch_multiplier': 1,
    },
    'io_intensive': {
        'queues': ['api_calls', 'file_uploads', 'emails'],
        'concurrency': 50,
        'prefetch_multiplier': 10,
    },
    'general': {
        'queues': ['default', 'background'],
        'concurrency': 10,
        'prefetch_multiplier': 4,
    },
}

# Start workers
# celery -A myapp worker --queues=ml_training,video_processing -c 4 -n cpu_worker@%h
# celery -A myapp worker --queues=api_calls,file_uploads -c 50 -n io_worker@%h
```

## Available Examples

### 1. Priority Queue Setup Guide

**Example**: `examples/priority-queue-setup.md`

**Demonstrates**:
- Configuring RabbitMQ priority queues
- Setting task priorities
- Priority inheritance patterns
- Testing priority routing
- Monitoring priority queue performance

**Key Concepts**:
- Priority range: 0 (lowest) to 255 (highest)
- RabbitMQ `x-max-priority` argument
- Priority at task definition vs runtime
- Queue argument configuration

### 2. Topic-Based Routing Implementation

**Example**: `examples/topic-routing.md`

**Demonstrates**:
- Topic exchange setup
- Routing key patterns (* and # wildcards)
- Multi-queue routing
- Pattern matching strategies
- Consumer binding patterns

**Routing Key Patterns**:
- `*` - Matches exactly one word
- `#` - Matches zero or more words
- Example: `email.*.send` matches `email.welcome.send`, `email.notification.send`
- Example: `user.#` matches `user.create`, `user.update.profile`

### 3. Worker Queue Assignment Strategy

**Example**: `examples/worker-queue-assignment.md`

**Demonstrates**:
- CPU-bound vs I/O-bound task separation
- Worker pool configuration
- Queue-to-worker mapping
- Scaling strategies per worker type
- Resource allocation patterns

**Worker Types**:
```bash
# CPU-intensive workers (low concurrency)
celery -A myapp worker -Q ml_training,video_processing -c 4 -n cpu@%h

# I/O-intensive workers (high concurrency)
celery -A myapp worker -Q api_calls,emails -c 50 -n io@%h

# General purpose workers
celery -A myapp worker -Q default,background -c 10 -n general@%h
```

## Routing Strategies Comparison

### 1. Direct Exchange (Default)
- **Use Case**: Simple queue-to-task mapping
- **Pros**: Simple, predictable, fast
- **Cons**: Limited flexibility
- **Example**: Each task type goes to one specific queue

### 2. Topic Exchange
- **Use Case**: Pattern-based routing, hierarchical task categories
- **Pros**: Flexible, supports wildcards, multi-queue routing
- **Cons**: More complex configuration
- **Example**: `email.*.send` routes all email types to email queue

### 3. Fanout Exchange
- **Use Case**: Broadcasting tasks to multiple queues
- **Pros**: Simple broadcast mechanism
- **Cons**: No routing logic, all queues receive all messages
- **Example**: Notifications sent to multiple consumer types

### 4. Headers Exchange
- **Use Case**: Complex routing based on message headers
- **Pros**: Very flexible, metadata-based routing
- **Cons**: Performance overhead, complex configuration
- **Example**: Route by `priority=high` and `region=us-east`

## Performance Considerations

### 1. Queue Configuration
- **Durable queues**: Messages persist across broker restarts (use for critical tasks)
- **Transient queues**: Faster but messages lost on restart (use for disposable tasks)
- **Queue length limits**: Prevent memory issues with `x-max-length`

### 2. Prefetch Settings
- **CPU-bound tasks**: Low prefetch (1-2) to prevent blocking
- **I/O-bound tasks**: High prefetch (10+) to keep workers busy
- **Configure per worker**: `celery worker --prefetch-multiplier=4`

### 3. Priority Queue Performance
- **RabbitMQ**: Native priority support, efficient
- **Redis**: Priority emulation via separate queues, less efficient
- **Trade-off**: Priority checking adds overhead, use only when needed

## Security Compliance

This skill follows strict security rules:
- All code examples use placeholder values only
- No real broker credentials, passwords, or secrets
- Environment variable references in all code (BROKER_URL, BACKEND_URL)
- `.gitignore` protection documented
- Broker URLs use placeholder format: `amqp://user:password@localhost:5672//`

**Never hardcode**:
```python
# ❌ WRONG
BROKER_URL = 'amqp://myuser:secretpass123@rabbitmq.example.com:5672//'

# ✅ CORRECT
import os
BROKER_URL = os.environ.get('CELERY_BROKER_URL', 'amqp://guest:guest@localhost:5672//')
```

## Best Practices

1. **Use Environment-Based Configuration** - Different queues for dev/staging/prod
2. **Separate Critical Tasks** - High-priority queue for time-sensitive operations
3. **Match Worker to Task Type** - CPU workers for compute, I/O workers for network/disk
4. **Monitor Queue Lengths** - Alert on queue buildup indicating bottlenecks
5. **Use Topic Exchanges for Hierarchical Tasks** - Cleaner routing than multiple direct exchanges
6. **Test Routing Configuration** - Validate routes before deploying to production
7. **Document Routing Logic** - Especially for complex pattern-based routing
8. **Use Priority Sparingly** - Overuse defeats the purpose and adds overhead
9. **Configure Prefetch Per Worker Type** - Optimize based on task characteristics
10. **Plan for Scaling** - Design routing to allow independent queue scaling

## Requirements

- Celery 5.0+
- Message broker (RabbitMQ 3.8+ or Redis 6.0+)
- Python 3.8+
- kombu library (included with Celery)
- Environment variables:
  - `CELERY_BROKER_URL` (required)
  - `CELERY_RESULT_BACKEND` (optional)
- For RabbitMQ priority queues: RabbitMQ 3.5+
- For testing scripts: netcat/telnet for connectivity checks

## Progressive Disclosure

For advanced routing patterns, see:
- `examples/priority-queue-setup.md` - Priority queue implementation
- `examples/topic-routing.md` - Topic exchange patterns
- `examples/worker-queue-assignment.md` - Worker pool strategies

## Troubleshooting

### Queue Not Receiving Tasks
1. Check routing configuration matches task name
2. Verify queue declaration in CELERY_QUEUES
3. Ensure workers are listening to correct queues
4. Check broker connectivity with test script

### Priority Not Working
1. Verify `x-max-priority` set on queue (RabbitMQ only)
2. Check tasks are setting priority correctly
3. Confirm workers consuming from priority queue
4. Redis: Implement separate high/low priority queues

### Worker Not Processing Tasks
1. Verify worker queue list matches routed queues
2. Check prefetch_multiplier isn't too low
3. Ensure no task failures blocking queue
4. Monitor worker logs for errors

---

**Plugin**: celery
**Version**: 1.0.0
**Last Updated**: 2025-11-16
