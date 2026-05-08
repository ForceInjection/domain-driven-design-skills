---
name: atlassian-jira
description: Execute Jira operations including issue retrieval, creation, updates, search, and project management. Use when the user needs to interact with Jira issues, projects, boards, or perform any Jira-related tasks.
---

# Atlassian Jira Tools

Provides type-safe Python tools for interacting with Jira through a progressive loading API that minimizes token usage.

## Current Status

**Available Tools**: 1 (jira_get_issue)
**Planned Tools**: 30+ additional Jira operations

This skill demonstrates the internalized MCP pattern. Additional tools will be added progressively.

## Prerequisites

### Required Environment Variables

Before using any Jira tools, set these environment variables:

```bash
export JIRA_URL="https://your-domain.atlassian.net"
export JIRA_USERNAME="your-email@example.com"
export JIRA_API_TOKEN="your-api-token"
```

**Getting API Token**:
1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
2. Click "Create API token"
3. Give it a name and copy the token
4. Use your email as JIRA_USERNAME and the token as JIRA_API_TOKEN

### Installation

The Python package must be installed in your environment:

```bash
cd /Users/bono/Documents/01.Projects/MCP_Internalization/atlassian-internalized
pip install -e .
```

## Usage Pattern

### Step 1: List Available Tools

```bash
python skills/atlassian-jira/scripts/execute_tool.py --list-tools
```

Returns:
```json
{
  "success": true,
  "tools": ["jira_get_issue"],
  "count": 1
}
```

### Step 2: Get Tool Schema (Optional)

```bash
python skills/atlassian-jira/scripts/execute_tool.py jira_get_issue --schema
```

Returns detailed JSON schema for inputs and outputs.

### Step 3: Execute Tool

```bash
python skills/atlassian-jira/scripts/execute_tool.py jira_get_issue --input '{
  "issue_key": "PROJ-123",
  "fields": "summary,status,assignee",
  "comment_limit": 5
}'
```

## Available Tools

### jira_get_issue

Retrieve comprehensive information about a specific Jira issue.

**Input Parameters**:
- `issue_key` (required): Issue key like "PROJ-123"
- `fields` (optional): Comma-separated fields or "*all" for all fields
- `expand` (optional): Fields to expand (e.g., "changelog,transitions")
- `comment_limit` (optional): Max comments to include (0-100, default: 10)

**Example**:
```bash
# Get basic issue info
python scripts/execute_tool.py jira_get_issue --input '{"issue_key": "PROJ-123"}'

# Get specific fields only
python scripts/execute_tool.py jira_get_issue --input '{
  "issue_key": "PROJ-123",
  "fields": "summary,status,assignee,priority"
}'

# Get all fields with changelog
python scripts/execute_tool.py jira_get_issue --input '{
  "issue_key": "PROJ-123",
  "fields": "*all",
  "expand": "changelog"
}'

# Get issue without comments
python scripts/execute_tool.py jira_get_issue --input '{
  "issue_key": "PROJ-123",
  "comment_limit": 0
}'
```

**Output**:
```json
{
  "success": true,
  "issue": {
    "key": "PROJ-123",
    "id": "10001",
    "fields": {
      "summary": "Implement new feature",
      "status": {"name": "In Progress", "category": "In Progress"},
      "assignee": {"display_name": "John Doe", "email": "john@example.com"},
      "priority": {"name": "High"},
      "created": "2025-01-14T10:00:00.000+0000",
      "updated": "2025-01-14T12:00:00.000+0000",
      "comments": [
        {
          "author": "Jane Smith",
          "body": "This looks good",
          "created": "2025-01-14T11:00:00.000+0000"
        }
      ]
    }
  }
}
```

## Common Workflows

### Get Issue Summary

Quick way to check an issue's current state:

```bash
python scripts/execute_tool.py jira_get_issue --input '{
  "issue_key": "PROJ-123",
  "fields": "summary,status,assignee",
  "comment_limit": 0
}'
```

### Get Full Issue Details

Retrieve all available information:

```bash
python scripts/execute_tool.py jira_get_issue --input '{
  "issue_key": "PROJ-123",
  "fields": "*all",
  "comment_limit": 20
}'
```

### Get Issue with Change History

See what changed over time:

```bash
python scripts/execute_tool.py jira_get_issue --input '{
  "issue_key": "PROJ-123",
  "expand": "changelog"
}'
```

## Error Handling

All tools return structured responses with error information:

```json
{
  "success": false,
  "error": "Issue PROJ-999 not found"
}
```

### Common Errors

**Authentication Failed**:
```
Error: "Authentication failed. Check your credentials"
```
→ Verify JIRA_URL, JIRA_USERNAME, and JIRA_API_TOKEN are correct

**Issue Not Found**:
```
Error: "Issue PROJ-999 not found"
```
→ Check the issue key exists and you have permission to view it

**Missing Environment Variables**:
```
Error: "JIRA_URL environment variable is required"
```
→ Set all required environment variables

**Invalid Input**:
```
Error: "Input validation error: ..."
```
→ Check your input matches the schema (use --schema to see requirements)

## Performance & Token Efficiency

### Progressive Discovery

Tools are discovered without loading their implementation:
- **Tool List**: ~50 tokens
- **Tool Schema**: ~200 tokens per tool
- **Tool Execution**: Only loads when called

### Data Filtering

Use field filters to reduce data transfer:
```bash
# Instead of getting all fields (large response)
python scripts/execute_tool.py jira_get_issue --input '{"issue_key": "PROJ-123"}'

# Get only what you need (small response)
python scripts/execute_tool.py jira_get_issue --input '{
  "issue_key": "PROJ-123",
  "fields": "summary,status",
  "comment_limit": 0
}'
```

### Comment Limiting

Control how many comments are returned:
- `comment_limit: 0` - No comments (fastest)
- `comment_limit: 5` - Recent 5 comments
- `comment_limit: 100` - Maximum allowed

## Troubleshooting

### Tool Not Found

If you get "Tool not found" errors:

1. Verify installation:
   ```bash
   python -c "import atlassian_tools; print(atlassian_tools.list_tools('jira'))"
   ```

2. Check you're in the correct directory:
   ```bash
   cd /Users/bono/Documents/01.Projects/MCP_Internalization/atlassian-internalized
   ```

3. Reinstall if needed:
   ```bash
   pip install -e .
   ```

### Script Execution Errors

If the script won't run:

1. Make it executable:
   ```bash
   chmod +x skills/atlassian-jira/scripts/execute_tool.py
   ```

2. Run with python explicitly:
   ```bash
   python skills/atlassian-jira/scripts/execute_tool.py --list-tools
   ```

### JSON Parsing Errors

If your input JSON is invalid:

1. Use single quotes around the JSON and double quotes inside:
   ```bash
   --input '{"issue_key": "PROJ-123"}'
   ```

2. Escape quotes if needed:
   ```bash
   --input "{\"issue_key\": \"PROJ-123\"}"
   ```

3. Use a JSON file:
   ```bash
   --input "$(cat examples/get_issue.json | jq -c .input)"
   ```

## Direct Python Usage

For programmatic access, use the Python API directly:

```python
import asyncio
import atlassian_tools

# List available tools
tools = atlassian_tools.list_tools(category='jira')
print(tools)  # ['jira_get_issue']

# Execute a tool
async def main():
    result = await atlassian_tools.execute_tool(
        'jira_get_issue',
        {'issue_key': 'PROJ-123', 'comment_limit': 5}
    )

    if result['data']['success']:
        issue = result['data']['issue']
        print(f"Issue: {issue['fields']['summary']}")
    else:
        print(f"Error: {result['data']['error']}")

asyncio.run(main())
```

## Future Tools (Planned)

The following tools are planned for future releases:

- `jira_create_issue` - Create new issues
- `jira_update_issue` - Update existing issues
- `jira_search` - Search issues with JQL
- `jira_add_comment` - Add comments to issues
- `jira_transition_issue` - Move issues through workflow
- `jira_list_projects` - List all accessible projects
- Plus 25+ more operations

## Tips for Claude Code Usage

When using this skill in Claude Code:

1. **Start with discovery**: Ask Claude to list available tools first
2. **Check schemas**: Use `--schema` to understand inputs/outputs
3. **Use examples**: Reference the examples/ directory for common patterns
4. **Filter data**: Always specify which fields you need to reduce tokens
5. **Handle errors**: Check the `success` field in responses

## Related Skills

- `atlassian-confluence` (planned) - Confluence page and space management

## Support

For issues, questions, or contributions:
- Project: atlassian-internalized
- Location: `/Users/bono/Documents/01.Projects/MCP_Internalization/atlassian-internalized`
- Documentation: `docs/internalization-log.md`
