---
name: logging-patterns
description: Use when adding logging to features - structured logging with LoggerService categories
---

# Logging Patterns

Use this skill when implementing features that need logging or debugging.

## Checklist

### Setup Logger
- [ ] Import LoggerService: `from app.services import logger_service`
- [ ] Get logger with category: `logger = logger_service.get_logger(__name__, category='[Category]')`
- [ ] Verify category matches feature domain (see categories below)

### Select Appropriate Category
Choose the category that matches your feature domain:
- [ ] `[ModelLoad]` - Model loading operations
- [ ] `[Download]` - Download operations
- [ ] `[Generate]` - Image generation
- [ ] `[API]` - API endpoints
- [ ] `[Database]` - Database operations
- [ ] `[Service]` - Service layer operations
- [ ] `[Socket]` - WebSocket events
- [ ] `[GPU]` - GPU operations

### Use Appropriate Log Level
- [ ] `.debug()` - Detailed diagnostic information (only visible with `LOG_LEVEL=DEBUG`)
- [ ] `.info()` - General informational messages (progress, status updates)
- [ ] `.warning()` - Warning messages (degraded functionality, deprecated usage)
- [ ] `.error()` - Error messages (failures that don't stop execution)
- [ ] `.exception()` - Exceptions with full stack traces (use in except blocks)

### Example Usage

```python
from app.services import logger_service

logger = logger_service.get_logger(__name__, category='ModelLoad')

def load_model(model_path: str):
    logger.info(f'Loading model from {model_path}')
    try:
        # ... model loading logic
        logger.debug('Model loaded successfully')
    except FileNotFoundError as error:
        logger.error(f'Model file not found: {error}')
        raise
```

### Configuration
- [ ] Test with debug logging: `LOG_LEVEL=DEBUG uv run python main.py`
- [ ] Verify logs appear with correct category prefix in output

## Reference

See `app/services/logger.py` for LoggerService implementation.
