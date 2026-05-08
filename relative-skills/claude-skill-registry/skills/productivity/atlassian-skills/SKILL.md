---
name: atlassian-skills
description: Execute Atlassian operations for both Jira and Confluence, including issue management, page retrieval, search, creation, and updates. Use when the user needs to interact with Jira issues, Confluence pages, or any Atlassian-related tasks.
---

# Atlassian Skills (Jira + Confluence)

Provides type-safe Python tools for interacting with both Jira and Confluence through a progressive loading API that minimizes token usage.

## Current Status

**Available Tools**: 42 total operations
- 31 Jira operations (issue management, search, workflows, etc.)
- 11 Confluence operations (page management, search, comments, etc.)

**Test Coverage**: 99% (effectively 100% of executable code)

All tools are fully implemented and tested with comprehensive error handling.

## Prerequisites

### Required Environment Variables

Before using Atlassian tools, set these environment variables:

**For Jira:**
```bash
export JIRA_URL="https://your-domain.atlassian.net"
export JIRA_USERNAME="your-email@example.com"
export JIRA_API_TOKEN="your-api-token"
```

**For Confluence:**
```bash
export CONFLUENCE_URL="https://your-domain.atlassian.net/wiki"
export CONFLUENCE_USERNAME="your-email@example.com"
export CONFLUENCE_API_TOKEN="your-api-token"
```

**Note**: You can use the same API token for both Jira and Confluence.

**Getting API Token**:
1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
2. Click "Create API token"
3. Give it a name and copy the token
4. Use your email as username and the token for both Jira and Confluence

### Installation

The Python package must be installed in your environment:

```bash
cd /Users/yn9w5j6tlc/Documents/01.Areas/Repo/Productivty4Kurly/projects/atlassian-skill-test/atlassian-internalized
source .venv/bin/activate
pip install -e .
```

## Available Tools

### Jira Tools (31 operations)

For detailed Jira tool documentation, see the [atlassian-jira skill](../atlassian-jira/SKILL.md).

**Key Jira operations**:
- Issue management: get, create, update, delete, search
- Workflows: transitions, assignments, comments
- Project data: projects, fields, priorities, resolutions
- Advanced: worklogs, watchers, links, batch operations
- Agile: sprint issues, board issues, epic issues

### Confluence Tools (11 operations)

#### Read Operations

#### confluence_get_page
Retrieve a Confluence page by ID.

**Input**:
- `page_id` (required): Page ID

**Example**:
```bash
# Using atlassian-skills
python skills/atlassian-skills/scripts/execute_tool.py confluence_get_page --input '{"page_id": "5359832916"}'

# Or list all available tools
python skills/atlassian-skills/scripts/execute_tool.py --list-tools
```

#### confluence_search
Search Confluence using CQL (Confluence Query Language).

**Input**:
- `cql` (required): CQL query string
- `limit` (optional): Max results (default: 25)

**Example**:
```bash
python skills/atlassian-skills/scripts/execute_tool.py confluence_search --input '{
  "cql": "space = PMO1 and type = page",
  "limit": 10
}'
```

#### confluence_get_page_children
Get child pages of a page.

**Input**:
- `page_id` (required): Parent page ID
- `limit` (optional): Max results (default: 25)

#### confluence_get_page_ancestors
Get ancestor pages (breadcrumb trail).

**Input**:
- `page_id` (required): Page ID

#### confluence_get_labels
Get labels attached to a page.

**Input**:
- `page_id` (required): Page ID

#### confluence_get_comments
Get comments on a page.

**Input**:
- `page_id` (required): Page ID
- `limit` (optional): Max comments (default: 25)

### Write Operations

#### confluence_create_page
Create a new page.

**Input**:
- `space_key` (required): Space key
- `title` (required): Page title
- `content` (required): Page content (HTML or storage format)
- `parent_id` (optional): Parent page ID

#### confluence_update_page
Update an existing page.

**Input**:
- `page_id` (required): Page ID
- `title` (required): New title
- `content` (required): New content
- `version_number` (required): Current version number

#### confluence_delete_page
Delete a page.

**Input**:
- `page_id` (required): Page ID

#### confluence_add_label
Add a label to a page.

**Input**:
- `page_id` (required): Page ID
- `label` (required): Label name

#### confluence_add_comment
Add a comment to a page.

**Input**:
- `page_id` (required): Page ID
- `comment` (required): Comment text

## Common Workflows

### Get Page Content

```bash
python skills/atlassian-skills/scripts/execute_tool.py confluence_get_page --input '{
  "page_id": "123456"
}'
```

### Search for Pages

```bash
python skills/atlassian-skills/scripts/execute_tool.py confluence_search --input '{
  "cql": "space = MYSPACE and title ~ \"meeting notes\"",
  "limit": 20
}'
```

### Get Page with Comments

```bash
# First get the page
python skills/atlassian-skills/scripts/execute_tool.py confluence_get_page --input '{"page_id": "123456"}'

# Then get comments
python skills/atlassian-skills/scripts/execute_tool.py confluence_get_comments --input '{"page_id": "123456"}'
```

## Error Handling

All tools return structured responses with error information:

```json
{
  "success": false,
  "error": "Page not found"
}
```

### Common Errors

**Authentication Failed**:
```
Error: "Authentication failed"
```
→ Verify CONFLUENCE_URL, CONFLUENCE_USERNAME, and CONFLUENCE_API_TOKEN are correct

**Page Not Found**:
```
Error: "Page 123456 not found"
```
→ Check the page ID exists and you have permission to view it

**Missing Environment Variables**:
```
Error: "CONFLUENCE_URL environment variable is required"
```
→ Set all required environment variables

## Direct Python Usage

For programmatic access, use the Python API directly:

```python
import asyncio
import atlassian_tools

# List available tools
tools = atlassian_tools.list_tools(category='confluence')
print(tools)

# Execute a tool
async def main():
    result = await atlassian_tools.execute_tool(
        'confluence_get_page',
        {'page_id': '123456'}
    )

    if result['data']['success']:
        page = result['data']['page']
        print(f"Title: {page['title']}")
        print(f"Content: {page['content']}")
    else:
        print(f"Error: {result['data']['error']}")

asyncio.run(main())
```

## Related Skills

- `atlassian-jira` - Jira issue and project management

## Support

For issues, questions, or contributions:
- Project: atlassian-internalized
- Location: `/Users/yn9w5j6tlc/Documents/01.Areas/Repo/Productivty4Kurly/projects/atlassian-skill-test/atlassian-internalized`
