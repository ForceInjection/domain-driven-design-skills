---
name: "Error Handling Strategies"
description: "Implement robust error handling with proper validation, recovery mechanisms, and clear feedback for system stability"
category: "implementation"
required_tools: ["Read", "Write", "Edit", "Grep"]
---

# Error Handling Strategies

## Purpose
Implement robust error handling that gracefully manages failures, provides clear feedback, and maintains system stability.

## When to Use
- Writing any code that can fail
- Handling external API calls
- Processing user input
- Managing file I/O operations
- Dealing with network requests

## Key Capabilities
1. **Error Detection** - Identify potential failure points
2. **Error Recovery** - Implement fallback strategies
3. **Error Communication** - Provide clear, actionable messages

## Approach
1. Identify what can go wrong (invalid input, network failure, etc.)
2. Validate inputs before processing
3. Use try-catch or error returns appropriately
4. Provide context in error messages
5. Log errors with sufficient debugging information
6. Implement retry logic for transient failures

## Example
**Context**: File reading operation
````python
def read_config(filepath):
    try:
        with open(filepath, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        logger.error(f"Config file not found: {filepath}")
        return get_default_config()
    except json.JSONDecodeError as e:
        logger.error(f"Invalid JSON in {filepath}: {e}")
        raise ConfigurationError(f"Config file is malformed at line {e.lineno}")
    except PermissionError:
        logger.error(f"Cannot read {filepath}: Permission denied")
        raise ConfigurationError(f"Insufficient permissions for {filepath}")
````

## Best Practices
- ✅ Fail fast for programming errors
- ✅ Recover gracefully from external failures
- ✅ Include context in error messages
- ❌ Avoid: Silent failures or generic error messages