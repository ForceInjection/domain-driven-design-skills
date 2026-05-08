---
name: distributed-tracing-specialist
description: Configure and use OpenTelemetry distributed tracing with Jaeger in HuleEdu services. Guides tracer initialization, span creation, W3C trace propagation, and correlation with logs/metrics. Integrates with Context7 for latest OpenTelemetry documentation.
---

# Distributed Tracing Specialist

Compact skill for implementing OpenTelemetry distributed tracing with Jaeger in HuleEdu services.

## When to Use

Activate when the user:
- Needs to initialize OpenTelemetry tracing for a service
- Wants to create spans for operations or requests
- Asks about trace context propagation across services
- Needs to correlate traces with logs and metrics
- Wants to understand W3C Trace Context standard
- Mentions OpenTelemetry, Jaeger, distributed tracing, or spans
- Needs help with tracing middleware for Quart/FastAPI

## Core Capabilities

- **Tracer Initialization**: Configure OpenTelemetry with Jaeger OTLP endpoint
- **Span Creation**: Create spans for operations with automatic timing
- **Trace Context Propagation**: W3C Trace Context across HTTP and Kafka
- **Middleware Integration**: Automatic tracing for HTTP requests (Quart/FastAPI)
- **Correlation**: Link traces with correlation IDs, logs, and metrics
- **Error Recording**: Automatic exception recording in spans
- **Context Injection/Extraction**: Propagate traces through event metadata
- **Context7 Integration**: Fetch latest OpenTelemetry/Jaeger documentation

## Quick Workflow

1. Initialize tracer at service startup with service name
2. Setup tracing middleware for automatic HTTP span creation
3. Create spans for important operations
4. Inject trace context when publishing events
5. Extract trace context when consuming events
6. View traces in Jaeger UI (<http://localhost:16686>)

## Tracer Initialization

```python
from huleedu_service_libs.observability.tracing import init_tracing

# In app.py startup
tracer = init_tracing("spellchecker_service")
```

## Middleware Setup

```python
from huleedu_service_libs.middleware.frameworks.quart_middleware import (
    setup_tracing_middleware
)

@app.before_serving
async def startup():
    setup_tracing_middleware(app, tracer)
```

## Span Creation Pattern

```python
from huleedu_service_libs.observability.tracing import trace_operation

async def process_essay(essay_id: str) -> None:
    with trace_operation(
        tracer,
        "process_essay",
        attributes={"essay_id": essay_id}
    ) as span:
        # Work happens here (timed automatically)
        result = await spell_checker.check(essay)
        span.set_attribute("corrections_count", len(result.corrections))
```

## Jaeger UI Access

- **URL**: <http://localhost:16686>
- **Service**: Select service from dropdown
- **Query**: Find traces by service, operation, or tags

## Reference Documentation

- **Detailed Tracing Patterns**: See `reference.md` in this directory
- **Real-World Tracing Examples**: See `examples.md` in this directory
- **Tracing Library**: `/libs/huleedu_service_libs/src/huleedu_service_libs/observability/tracing.py`
- **Middleware**: `/libs/huleedu_service_libs/src/huleedu_service_libs/middleware/frameworks/quart_middleware.py`
