---
name: everhour-integration
version: 1.0
description: Complete Everhour time tracking integration for accessing and managing time entries via REST API
---

# Everhour Integration Skill

Comprehensive time tracking integration using the Everhour REST API v1.

## Overview

This skill provides complete programmatic access to Everhour time tracking data, including:
- User time entries and summaries
- Project and task time tracking
- Timer operations (start/stop)
- Task estimates and budgets
- Jira issue integration
- Team time reporting

**API Base URL:** `https://api.everhour.com`

## Prerequisites

1. **Everhour Account:** Active account with vividcg.atlassian.net
2. **API Token:** Get from Everhour → Settings → My Profile → API Token
3. **Team Plan:** Required for API access
4. **Python Dependencies:** `requests`, `python-dotenv`

## Environment Configuration

**Required Environment Variables:**

```bash
EVERHOUR_API_TOKEN=your_api_token_here
EVERHOUR_BASE_URL=https://api.everhour.com
```

## Core Functions

### 1. Authentication Helper

```python
import os
from dotenv import load_dotenv
import requests

def get_everhour_auth():
    """Load Everhour credentials from environment."""
    load_dotenv()

    api_token = os.getenv('EVERHOUR_API_TOKEN')

    if not api_token:
        raise ValueError("EVERHOUR_API_TOKEN must be set in environment")

    return {
        'api_token': api_token,
        'base_url': os.getenv('EVERHOUR_BASE_URL', 'https://api.everhour.com'),
        'headers': {
            'X-Api-Key': api_token,
            'Content-Type': 'application/json'
        }
    }
```

### 2. Get Current User

```python
def get_current_user():
    """Get current user information."""
    auth = get_everhour_auth()

    response = requests.get(
        f"{auth['base_url']}/users/me",
        headers=auth['headers']
    )
    response.raise_for_status()

    user = response.json()
    return {
        'id': user.get('id'),
        'name': user.get('name'),
        'email': user.get('email'),
        'status': user.get('status'),
        'role': user.get('role'),
        'team': user.get('team', {}).get('name')
    }
```

### 3. Get Projects

```python
def get_projects(platform_filter=None):
    """Get all projects, optionally filtered by platform.

    Args:
        platform_filter: Filter by platform (e.g., 'jira', 'asana', None for all)

    Returns:
        List of project dictionaries
    """
    auth = get_everhour_auth()

    response = requests.get(
        f"{auth['base_url']}/projects",
        headers=auth['headers']
    )
    response.raise_for_status()

    projects = response.json()

    if platform_filter:
        # Note: Some projects don't have 'type' field
        projects = [p for p in projects if p.get('type') == platform_filter]

    return projects
```

### 4. Get Project Tasks

```python
def get_project_tasks(project_id):
    """Get all tasks for a project.

    Args:
        project_id: Project ID (e.g., 'jr:6091-12165' for Jira projects)

    Returns:
        List of task dictionaries with time tracking data
    """
    auth = get_everhour_auth()

    response = requests.get(
        f"{auth['base_url']}/projects/{project_id}/tasks",
        headers=auth['headers']
    )
    response.raise_for_status()

    return response.json()
```

### 5. Get Task Details

```python
def get_task(task_id):
    """Get task details by ID or Jira issue key.

    Args:
        task_id: Everhour task ID (e.g., 'jr:6091-38923') or Jira key (e.g., 'DP01-74')

    Returns:
        Task dictionary with time tracking details
    """
    auth = get_everhour_auth()

    response = requests.get(
        f"{auth['base_url']}/tasks/{task_id}",
        headers=auth['headers']
    )

    if response.status_code == 404:
        return None

    response.raise_for_status()

    task = response.json()

    # Calculate total hours
    total_ms = task.get('time', {}).get('total', 0)
    total_hours = total_ms / 3600000

    return {
        'id': task.get('id'),
        'name': task.get('name'),
        'status': task.get('status'),
        'total_time_ms': total_ms,
        'total_hours': round(total_hours, 2),
        'users': task.get('time', {}).get('users', {}),
        'estimate_ms': task.get('estimate', 0),
        'estimate_hours': round(task.get('estimate', 0) / 3600000, 2),
        'projects': task.get('projects', [])
    }
```

### 6. Get User Time Entries

```python
from datetime import datetime, timedelta

def get_my_time_entries(start_date=None, end_date=None, days=30):
    """Get time entries for current user.

    Args:
        start_date: Start date (YYYY-MM-DD) or None for auto-calculate
        end_date: End date (YYYY-MM-DD) or None for today
        days: Number of days to look back if start_date is None

    Returns:
        List of time entry dictionaries
    """
    auth = get_everhour_auth()

    if end_date is None:
        end_date = datetime.now().strftime("%Y-%m-%d")

    if start_date is None:
        start_date = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")

    params = {
        "from": start_date,
        "to": end_date,
        "limit": 1000
    }

    response = requests.get(
        f"{auth['base_url']}/users/me/time",
        headers=auth['headers'],
        params=params
    )
    response.raise_for_status()

    entries = response.json()

    # Enrich with calculated hours
    for entry in entries:
        entry['hours'] = round(entry.get('time', 0) / 3600000, 2)

    return entries
```

### 7. Add Time to Task

```python
def add_time_to_task(task_id, hours, date=None, comment=None):
    """Add time entry to a task.

    Args:
        task_id: Everhour task ID or Jira issue key (e.g., 'DP01-74')
        hours: Time in hours (converted to milliseconds)
        date: Date in YYYY-MM-DD format (defaults to today)
        comment: Optional description (max 1000 chars for Jira sync)

    Returns:
        Response from API
    """
    auth = get_everhour_auth()

    if date is None:
        date = datetime.now().strftime("%Y-%m-%d")

    time_ms = int(hours * 3600000)

    payload = {
        "time": time_ms,
        "date": date
    }

    if comment:
        payload["comment"] = comment[:1000]  # Limit for Jira sync

    response = requests.post(
        f"{auth['base_url']}/tasks/{task_id}/time",
        headers=auth['headers'],
        json=payload
    )
    response.raise_for_status()

    return response.json()
```

### 8. Update Time Entry

```python
def update_time_entry(task_id, hours, date):
    """Update existing time entry for a task on a specific date.

    Args:
        task_id: Everhour task ID or Jira issue key
        hours: New time in hours
        date: Date in YYYY-MM-DD format

    Returns:
        Response from API
    """
    auth = get_everhour_auth()

    time_ms = int(hours * 3600000)

    payload = {
        "time": time_ms,
        "date": date
    }

    response = requests.put(
        f"{auth['base_url']}/tasks/{task_id}/time",
        headers=auth['headers'],
        json=payload
    )
    response.raise_for_status()

    return response.json()
```

### 9. Delete Time Entry

```python
def delete_time_entry(task_id, date):
    """Delete time entry for a task on a specific date.

    Args:
        task_id: Everhour task ID or Jira issue key
        date: Date in YYYY-MM-DD format

    Returns:
        Response from API
    """
    auth = get_everhour_auth()

    payload = {"date": date}

    response = requests.delete(
        f"{auth['base_url']}/tasks/{task_id}/time",
        headers=auth['headers'],
        json=payload
    )
    response.raise_for_status()

    return response.json()
```

### 10. Timer Operations

```python
def start_timer(task_id):
    """Start timer for a task.

    Args:
        task_id: Everhour task ID or Jira issue key

    Returns:
        Timer response
    """
    auth = get_everhour_auth()

    payload = {"task": task_id}

    response = requests.post(
        f"{auth['base_url']}/timers",
        headers=auth['headers'],
        json=payload
    )
    response.raise_for_status()

    return response.json()

def stop_timer():
    """Stop currently running timer.

    Returns:
        Timer response
    """
    auth = get_everhour_auth()

    payload = {"status": "stopped"}

    response = requests.post(
        f"{auth['base_url']}/timers/current",
        headers=auth['headers'],
        json=payload
    )
    response.raise_for_status()

    return response.json()

def get_running_timer():
    """Get currently running timer.

    Returns:
        Timer response or None if no timer running
    """
    auth = get_everhour_auth()

    response = requests.get(
        f"{auth['base_url']}/timers/current",
        headers=auth['headers']
    )

    if response.status_code == 404:
        return None

    response.raise_for_status()
    return response.json()
```

### 11. Task Estimates

```python
def set_task_estimate(task_id, hours):
    """Set estimate for a task.

    Args:
        task_id: Everhour task ID or Jira issue key
        hours: Estimated time in hours

    Returns:
        Response from API
    """
    auth = get_everhour_auth()

    time_ms = int(hours * 3600000)

    payload = {"total": time_ms}

    response = requests.post(
        f"{auth['base_url']}/tasks/{task_id}/estimate",
        headers=auth['headers'],
        json=payload
    )
    response.raise_for_status()

    return response.json()

def delete_task_estimate(task_id):
    """Delete estimate for a task.

    Args:
        task_id: Everhour task ID or Jira issue key

    Returns:
        Response from API
    """
    auth = get_everhour_auth()

    response = requests.delete(
        f"{auth['base_url']}/tasks/{task_id}/estimate",
        headers=auth['headers']
    )
    response.raise_for_status()

    return response.json()
```

## Jira Integration Specifics

### Getting Jira Issue Time

```python
def get_jira_issue_time(jira_key):
    """Get time tracking summary for a Jira issue.

    Args:
        jira_key: Jira issue key (e.g., 'DP01-74')

    Returns:
        Dictionary with time summary or None if issue not found
    """
    task = get_task(jira_key)

    if not task:
        return None

    return {
        'jira_key': jira_key,
        'task_name': task['name'],
        'status': task['status'],
        'total_hours': task['total_hours'],
        'estimate_hours': task['estimate_hours'],
        'users': task['users']
    }
```

### Sync Status

**Important:** Everhour → Jira sync is one-way:
- ✅ Time logged in Everhour appears in Jira work logs
- ❌ Native Jira work logs do NOT sync to Everhour
- ❌ Historical data before sync enabled is NOT synchronized
- ⚠️ Comments limited to 1000 characters for Jira sync
- ⚠️ Text formatting and emojis removed in sync

## Common Use Cases

### Use Case 1: Daily Time Report

```python
from collections import defaultdict

def generate_daily_time_report(date=None):
    """Generate report of time entries for a specific date."""
    if date is None:
        date = datetime.now().strftime("%Y-%m-%d")

    entries = get_my_time_entries(start_date=date, end_date=date)

    report = {
        'date': date,
        'total_hours': 0,
        'entries': []
    }

    for entry in entries:
        hours = entry['hours']
        report['total_hours'] += hours

        # Get task details
        task = get_task(entry['task'])

        report['entries'].append({
            'task_id': entry['task'],
            'task_name': task['name'] if task else 'Unknown',
            'hours': hours,
            'comment': entry.get('comment', '')
        })

    return report
```

### Use Case 2: Project Time Summary

```python
def get_project_time_summary(project_id):
    """Get total time logged for all tasks in a project."""
    tasks = get_project_tasks(project_id)

    total_time_ms = 0
    task_summaries = []

    for task in tasks:
        task_time = task.get('time', {}).get('total', 0)
        total_time_ms += task_time

        if task_time > 0:  # Only include tasks with time
            task_summaries.append({
                'id': task.get('id'),
                'name': task.get('name'),
                'status': task.get('status'),
                'hours': round(task_time / 3600000, 2)
            })

    # Sort by time descending
    task_summaries.sort(key=lambda x: x['hours'], reverse=True)

    return {
        'project_id': project_id,
        'total_hours': round(total_time_ms / 3600000, 2),
        'task_count': len(task_summaries),
        'tasks': task_summaries
    }
```

### Use Case 3: Budget Tracking Alert

```python
def check_task_budget(task_id, budget_hours):
    """Check if a task is approaching budget limit."""
    task = get_task(task_id)

    if not task:
        return None

    logged_hours = task['total_hours']
    estimated_hours = task['estimate_hours']

    budget_remaining = budget_hours - logged_hours
    percent_used = (logged_hours / budget_hours * 100) if budget_hours > 0 else 0

    return {
        'task_id': task_id,
        'task_name': task['name'],
        'logged_hours': logged_hours,
        'estimated_hours': estimated_hours,
        'budget_hours': budget_hours,
        'budget_remaining': budget_remaining,
        'percent_used': round(percent_used, 1),
        'over_budget': logged_hours > budget_hours,
        'approaching_budget': percent_used >= 80 and not logged_hours > budget_hours
    }
```

### Use Case 4: DP01 Project Time Tracking

```python
def get_dp01_time_summary():
    """Get time tracking summary for DP01 - Datapage project."""
    # DP01 project ID from Everhour
    DP01_PROJECT_ID = "jr:6091-12165"

    summary = get_project_time_summary(DP01_PROJECT_ID)

    print(f"DP01 - Datapage Phase 1 Time Summary")
    print(f"=" * 60)
    print(f"Total Time: {summary['total_hours']} hours")
    print(f"Tasks with Time: {summary['task_count']}")
    print(f"\nTop 10 Tasks by Time:")

    for task in summary['tasks'][:10]:
        print(f"  {task['hours']}h - {task['name']} ({task['status']})")

    return summary
```

## Integration with Jira Automation Skill

Combine with the [Jira Automation skill](../jira-automation/SKILL.md) for comprehensive tracking:

```python
from jira_automation import get_jira_auth, get_jira_config
import requests

def get_combined_issue_data(jira_key):
    """Get combined data from Jira and Everhour for an issue."""

    # Get Jira issue details
    jira_config = get_jira_config()
    jira_response = requests.get(
        f"{jira_config['api_url']}/issue/{jira_key}",
        auth=jira_config['auth']
    )
    jira_issue = jira_response.json()

    # Get Everhour time tracking
    everhour_time = get_jira_issue_time(jira_key)

    # Combined data
    return {
        'jira_key': jira_key,
        'summary': jira_issue['fields']['summary'],
        'status': jira_issue['fields']['status']['name'],
        'assignee': jira_issue['fields']['assignee']['emailAddress'] if jira_issue['fields']['assignee'] else None,
        'everhour_total_hours': everhour_time['total_hours'] if everhour_time else 0,
        'everhour_users': everhour_time['users'] if everhour_time else {},
        'jira_time_spent_seconds': jira_issue['fields'].get('timetracking', {}).get('timeSpentSeconds', 0)
    }
```

## Rate Limits & Best Practices

1. **Rate Limits:** Stay under 100 requests per minute
2. **Bulk Queries:** Use `/projects/{id}/tasks` instead of individual task queries
3. **Error Handling:** Implement retry logic with exponential backoff for 429 errors
4. **Caching:** Cache project and task lists to reduce API calls
5. **Permissions:** `/team/time` endpoint requires admin permissions; use `/users/me/time` for user-level access

## Error Handling

```python
def safe_api_call(func, *args, **kwargs):
    """Wrapper for API calls with error handling."""
    try:
        return func(*args, **kwargs)
    except requests.exceptions.HTTPError as e:
        if e.response.status_code == 403:
            print(f"[ERROR] Access denied - check permissions")
        elif e.response.status_code == 404:
            print(f"[ERROR] Resource not found")
        elif e.response.status_code == 429:
            print(f"[ERROR] Rate limit exceeded - retry later")
        else:
            print(f"[ERROR] HTTP {e.response.status_code}: {e.response.text}")
        return None
    except requests.exceptions.RequestException as e:
        print(f"[ERROR] Network error: {e}")
        return None
```

## Testing

Test scripts available in `/scripts/`:
- `test-everhour-api.py` - Basic API connectivity test
- `find-dp01-project.py` - Find DP01 project and list tasks
- `get-my-time-entries.py` - Get your time entries

## Known Limitations

1. **Historical Data:** Pre-integration time entries are not synced
2. **One-Way Sync:** Native Jira work logs don't flow back to Everhour
3. **Comment Length:** Max 1,000 characters for Jira sync
4. **No Formatting:** Text formatting and emojis removed in sync
5. **Paid Plan Required:** API access requires Everhour Team plan
6. **Admin Endpoints:** `/team/time` requires admin role

## Related Documentation

- [EVERHOUR_API_INTEGRATION_GUIDE.md](../../../docs/planning/EVERHOUR_API_INTEGRATION_GUIDE.md) - Complete API reference
- [jira-automation](../jira-automation/SKILL.md) - Jira REST API integration
- [Official Everhour API Docs](https://everhour.docs.apiary.io/)

## Version History

- **1.0** (2025-12-15): Initial release with core API functions

---

**Maintained By:** Connect 2.0 Platform Development Team
**Last Updated:** December 15, 2025
