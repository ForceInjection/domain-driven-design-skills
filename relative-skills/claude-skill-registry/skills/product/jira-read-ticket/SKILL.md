---
name: jira-read-ticket
description: Use whenever a user mentions or references a Jira ticket and you want to pull out description, comments, or more.
---

# Jira data access instructions

Retrieve Jira issue data from Atlassian Cloud and return only the requested fields in JSON format.

## Inputs

- Jira issue key or ticket URL
- Environment variables: `ATLASSIAN_URL`, `ATLASSIAN_EMAIL`, `ATLASSIAN_API_TOKEN`

## Workflow

### 1) Verify environment variables
- Ensure all required variables are set. Never output or log token values.
- If missing, ask the user to set them before calling the API.

Variables: ATLASSIAN_URL, ATLASSIAN_EMAIL, ATLASSIAN_API_TOKEN

### 2) Identify the issue key
- If the user provides a URL, parse the key (example: `https://.../browse/ABC-123` -> `ABC-123`).
- If the key is missing, ask the user for it.

### 3) Fetch data

Use these scripts before alternatives:
- `scripts/fetch_comments.py`: Gets all ticket comments as JSON.
- `scripts/fetch_assigned_tickets.py`: Gets assigned tickets (JSON array).
- `scripts/fetch_description.py`: Gets description and details for one ticket (JSON).

Alternatively, use Jira REST API v3 with basic authentication, `curl`, and `jq`. Example for assigned tickets with JQL:
<example>
```bash
curl -s \
  -u "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" \
  -H 'Accept: application/json' \
  -H 'Content-Type: application/json' \
  "$ATLASSIAN_URL/rest/api/3/search/jql" \
  --data '{
    "jql": "assignee = currentUser()",
    "fields": ["key", "summary", "status", "issuetype", "project"],
    "maxResults": 100
  }'
```
</example>

- Use the `fields` parameter to limit payload when only specific fields are needed.

### 4) Extract results
- Python scripts return JSON.
- When using `curl`, use `jq` to extract fields of interest.

## Notes

- Jira may return rich text (Atlassian Document Format). Prefer `renderedFields`, fallback to `fields`.
- Use `/rest/api/3/search/jql` for JQL POST requests. `/rest/api/3/search` is deprecated.
- Retry API requests with increased permissions if network restrictions occur.
- Never log or output secrets—reference environment variable names only.
- Read-only operation: do not alter ticket data unless explicitly authorized by the user.
