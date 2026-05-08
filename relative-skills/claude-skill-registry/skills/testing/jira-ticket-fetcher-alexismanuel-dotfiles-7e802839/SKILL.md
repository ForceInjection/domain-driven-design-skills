---
name: jira-ticket-fetcher
description: This skill should be used when users need to fetch Jira ticket content using either a specific ticket ID (like RD-3891) or search for tickets by title/description. It defaults to searching within the current sprint but can extend to all tickets when needed. The skill uses the Jira CLI to retrieve ticket details, status, assignee, and descriptions.
---

# Jira Ticket Fetcher

## Overview

This skill enables fetching Jira ticket content using the Jira CLI. It supports retrieving specific tickets by ID or searching for tickets by text content, with configurable search scope (current sprint vs all projects).

## Quick Start

To fetch a Jira ticket, determine the input type:

1. **Ticket ID** (e.g., "RD-3891") → Use direct ticket retrieval
2. **Text Search** (e.g., "engine i18n epic") → Use search functionality

## Core Capabilities

### 1. Fetch Ticket by ID

Use when the user provides a specific ticket identifier:

```bash
python scripts/fetch_ticket.py RD-3891
```

The script automatically detects ticket ID patterns (PROJECT-NUMBER format) and retrieves full ticket details including:
- Ticket key and summary
- Current status and assignee
- Issue type and creation dates
- Full description

### 2. Search Tickets by Text

Use when the user provides descriptive text or vague ticket references:

```bash
# Search in current sprint (default)
python scripts/fetch_ticket.py "engine i18n epic"

# Search across all projects
python scripts/fetch_ticket.py "engine i18n epic" --scope=all
```

Search functionality includes:
- Text matching in ticket summaries and descriptions
- Configurable search scope (current sprint vs all projects)
- Multiple result formatting options

### 3. Current Sprint Operations

Get all tickets from the current active sprint:

```bash
python scripts/fetch_ticket.py --current-sprint
```

## Workflow Decision Tree

1. **Is the input a ticket ID?** (Pattern: PROJECT-NUMBER)
   - Yes → Use `get_ticket_by_id()` function
   - No → Proceed to step 2

2. **Is the user looking for current sprint tickets only?**
   - Yes → Use `search_tickets_by_text()` with scope='current'
   - No → Use `search_tickets_by_text()` with scope='all'

3. **Handle errors gracefully**
   - Ticket not found → Suggest searching by text
   - No search results → Suggest broadening search scope
   - CLI errors → Check Jira CLI installation and authentication

## Implementation Details

### Script Functions

The `scripts/fetch_ticket.py` provides these key functions:

- `get_ticket_by_id(ticket_id)`: Retrieves specific ticket details
- `search_tickets_by_text(search_text, scope)`: Searches tickets by content
- `get_current_sprint_tickets()`: Gets all current sprint tickets
- `is_ticket_id(input_text)`: Validates ticket ID format

### Error Handling

The script includes comprehensive error handling for:
- Invalid ticket IDs or access permissions
- Network timeouts and connection issues
- JSON parsing errors
- Empty search results

### Output Formatting

Results are formatted for readability with:
- Emoji indicators for different fields (📋, 📝, 📊, etc.)
- Structured display of key ticket information
- Clear error messages with suggestions

## Resources

### scripts/
- `fetch_ticket.py`: Main Python script for Jira ticket operations
  - Handles ticket ID detection and validation
  - Implements search functionality with scope control
  - Provides formatted output and error handling
  - Includes timeout protection and JSON parsing

### references/
- `jira_cli_commands.md`: Comprehensive Jira CLI command reference
  - Core commands for ticket viewing and searching
  - Search patterns and filter examples
  - Output format specifications
  - Error handling best practices

## Usage Examples

### Example 1: Direct Ticket Lookup
```
User: "Show me ticket RD-3891"
→ Execute: python scripts/fetch_ticket.py RD-3891
→ Returns: Full ticket details with status, assignee, description
```

### Example 2: Text Search in Current Sprint
```
User: "Find the engine i18n epic"
→ Execute: python scripts/fetch_ticket.py "engine i18n epic"
→ Returns: Matching tickets from current sprint
```

### Example 3: Broad Search
```
User: "Search for all tickets about authentication"
→ Execute: python scripts/fetch_ticket.py "authentication" --scope=all
→ Returns: Matching tickets from all projects
```

## Prerequisites

- Jira CLI must be installed and configured
- User must have appropriate Jira access permissions
- Active Jira CLI authentication session