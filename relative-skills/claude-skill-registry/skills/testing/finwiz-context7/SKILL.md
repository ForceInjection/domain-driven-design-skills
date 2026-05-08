---
name: finwiz-context7
description: "Automatically uses Context7 MCP tools to fetch up-to-date library documentation when working with external libraries. Use when implementing code with CrewAI, Pydantic, pytest, or any external library to ensure accuracy and compatibility."
allowed-tools: ["mcp_context7_resolve_library_id", "mcp_context7_get_library_docs", "Read", "Edit"]
---

# FinWiz Context7 Integration

**Key Principle**: Proactively use Context7 MCP tools to fetch current library documentation. Don't wait for explicit requests - if you're implementing something with an external library, automatically get the docs.

## When to Use Context7

Use Context7 tools **automatically** for:

- **Code generation** involving external libraries (CrewAI, Pydantic, pytest, etc.)
- **Setup and configuration** steps for dependencies  
- **Library/API documentation** lookups for accurate implementation
- **Version-specific features** to ensure compatibility
- **Best practices** for library usage patterns

## Context7 Workflow

### Step 1: Resolve Library ID

```javascript
// Use MCP tool to find the correct library
mcp_context7_resolve_library_id("crewai")
// Returns: "/joaomdmoura/crewai"
```

### Step 2: Get Library Documentation

```javascript
// Fetch relevant documentation
mcp_context7_get_library_docs(
  "/joaomdmoura/crewai", 
  topic="flow state management",
  tokens=5000
)
```

### Step 3: Implement Using Current Patterns

Use the fetched documentation to implement code with:
- Current API methods (not deprecated ones)
- Proper parameter names and types
- Best practices from the library maintainers
- Version-compatible features

## FinWiz-Specific Libraries

Common libraries that benefit from Context7 lookup:

| Library | Context7 ID | Common Topics |
|---------|-------------|---------------|
| **CrewAI** | `/joaomdmoura/crewai` | flow, agents, tasks, crews |
| **Pydantic** | `/pydantic/pydantic` | validation, strict mode, v2 |
| **pytest** | `/pytest-dev/pytest` | fixtures, markers, parametrize |
| **pytest-mock** | `/pytest-dev/pytest-mock` | mocker fixture, patching |
| **httpx** | `/encode/httpx` | async client, authentication |
| **pandas** | `/pandas-dev/pandas` | dataframes, operations |
| **FastAPI** | `/tiangolo/fastapi` | endpoints, dependencies |

## Example Usage Patterns

### CrewAI Flow Implementation

```javascript
// 1. Resolve library
mcp_context7_resolve_library_id("crewai")

// 2. Get Flow documentation
mcp_context7_get_library_docs(
  "/joaomdmoura/crewai", 
  topic="flow state management pydantic models",
  tokens=7000
)

// 3. Implement using current patterns
```

### Pydantic Model Validation

```javascript
// Get current Pydantic v2 patterns
mcp_context7_get_library_docs(
  "/pydantic/pydantic",
  topic="strict mode validation extra forbid",
  tokens=4000
)
```

### Testing with pytest-mock

```javascript
// Get current pytest-mock patterns (unittest.mock is BANNED)
mcp_context7_get_library_docs(
  "/pytest-dev/pytest-mock",
  topic="mocker fixture patching best practices",
  tokens=3000
)
```

## Benefits

### Accuracy
- **Current APIs**: Use latest library methods, not deprecated ones
- **Correct Parameters**: Get proper parameter names and types
- **Version Compatibility**: Ensure code works with installed versions

### Efficiency  
- **Avoid Errors**: Prevent using outdated or incorrect patterns
- **Best Practices**: Follow library maintainer recommendations
- **Faster Development**: Get accurate info immediately

### Compliance
- **Library Standards**: Follow official library patterns
- **FinWiz Standards**: Combine with existing FinWiz steering rules
- **Quality Assurance**: Reduce bugs from incorrect usage

## Integration with FinWiz Standards

Context7 documentation should be used **in conjunction with** FinWiz steering rules:

- **Validate patterns** against `finwiz-crewai` skill
- **Ensure testing** follows `finwiz-testing` skill  
- **Apply validation** per `finwiz-validation` skill
- **Maintain quality** per `finwiz-development` skill

## Proactive Usage Examples

### When You See These Patterns, Use Context7:

```python
# Implementing CrewAI Flow → Get CrewAI docs
class MyFlow(Flow[StateModel]):
    # Auto-fetch CrewAI Flow documentation

# Creating Pydantic models → Get Pydantic docs  
class MyModel(BaseModel):
    # Auto-fetch Pydantic v2 documentation

# Writing tests with mocker → Get pytest-mock docs
def test_example(mocker):
    # Auto-fetch pytest-mock documentation

# Making HTTP requests → Get httpx docs
async with httpx.AsyncClient() as client:
    # Auto-fetch httpx documentation
```

## Token Management

Adjust token limits based on complexity:

- **Simple lookups**: 3000 tokens
- **Standard usage**: 5000 tokens (default)
- **Complex implementations**: 7000-10000 tokens
- **Comprehensive guides**: 15000+ tokens

## Error Handling

If Context7 lookup fails:

1. **Continue with existing knowledge** but note the limitation
2. **Use FinWiz steering rules** as fallback guidance
3. **Document the assumption** in code comments
4. **Suggest manual verification** if critical

## Quality Assurance

After using Context7:

- **Verify patterns** match FinWiz standards
- **Test implementation** thoroughly
- **Document any deviations** from standard patterns
- **Update FinWiz skills** if new patterns emerge

Remember: Context7 provides the **what** (current library APIs), FinWiz skills provide the **how** (project-specific patterns and standards).