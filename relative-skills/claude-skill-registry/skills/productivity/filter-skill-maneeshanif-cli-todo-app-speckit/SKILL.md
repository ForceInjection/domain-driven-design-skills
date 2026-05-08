---
name: filter-skill
description: Filter tasks by priority, status, tags, due dates, and other criteria. Use when implementing filtering functionality.
allowed-tools: Write, Read
---

# Filter Skill

## Purpose
Implement comprehensive filtering for task management.

## Instructions

### Filter by Priority
```python
from typing import List, Optional

def filter_by_priority(self, priority: str) -> List[dict]:
    """Filter tasks by priority level."""
    return self.db.search(self.db.query.priority == priority)

def filter_by_priorities(self, priorities: List[str]) -> List[dict]:
    """Filter tasks by multiple priority levels."""
    return [t for t in self.get_all_tasks() if t.get('priority') in priorities]

def get_urgent_tasks(self) -> List[dict]:
    """Get only urgent and high priority tasks."""
    return self.filter_by_priorities(['urgent', 'high'])
```

### Filter by Status
```python
def filter_by_status(self, status: str) -> List[dict]:
    """Filter tasks by status."""
    return self.db.search(self.db.query.status == status)

def get_pending_tasks(self) -> List[dict]:
    """Get all pending tasks."""
    return self.filter_by_status('pending')

def get_completed_tasks(self) -> List[dict]:
    """Get all completed tasks."""
    return self.filter_by_status('completed')

def get_active_tasks(self) -> List[dict]:
    """Get all non-completed tasks."""
    return self.db.search(self.db.query.status != 'completed')
```

### Filter by Tags
```python
def filter_by_tag(self, tag: str) -> List[dict]:
    """Filter tasks containing a specific tag."""
    tag = tag.lower()
    return self.db.search(
        self.db.query.tags.test(
            lambda tags: tag in [t.lower() for t in tags]
        )
    )

def filter_by_all_tags(self, tags: List[str]) -> List[dict]:
    """Filter tasks containing ALL specified tags."""
    tags = [t.lower() for t in tags]
    return self.db.search(
        self.db.query.tags.test(
            lambda task_tags: all(
                tag in [t.lower() for t in task_tags] 
                for tag in tags
            )
        )
    )

def filter_by_any_tag(self, tags: List[str]) -> List[dict]:
    """Filter tasks containing ANY specified tag."""
    tags = [t.lower() for t in tags]
    return self.db.search(
        self.db.query.tags.test(
            lambda task_tags: any(
                tag in [t.lower() for t in task_tags] 
                for tag in tags
            )
        )
    )
```

### Filter by Due Date
```python
from datetime import datetime, timedelta

def get_overdue_tasks(self) -> List[dict]:
    """Get tasks past their due date."""
    now = datetime.now().isoformat()
    return self.db.search(
        (self.db.query.due_date.exists()) &
        (self.db.query.due_date.test(lambda d: d < now)) &
        (self.db.query.status != 'completed')
    )

def get_due_today(self) -> List[dict]:
    """Get tasks due today."""
    today = datetime.now().date().isoformat()
    tomorrow = (datetime.now().date() + timedelta(days=1)).isoformat()
    return self.db.search(
        (self.db.query.due_date.exists()) &
        (self.db.query.due_date.test(lambda d: today <= d[:10] < tomorrow))
    )

def get_due_this_week(self) -> List[dict]:
    """Get tasks due within the next 7 days."""
    today = datetime.now().date()
    week_end = (today + timedelta(days=7)).isoformat()
    return self.db.search(
        (self.db.query.due_date.exists()) &
        (self.db.query.due_date.test(
            lambda d: today.isoformat() <= d[:10] <= week_end
        ))
    )

def get_tasks_without_due_date(self) -> List[dict]:
    """Get tasks without a due date."""
    return self.db.search(
        ~self.db.query.due_date.exists() | 
        (self.db.query.due_date == None)
    )
```

### Combined Filter Service
```python
class FilterService:
    """Comprehensive filter service with chainable filters."""
    
    def __init__(self, database):
        self.db = database
    
    def filter_tasks(
        self,
        priority: Optional[str] = None,
        priorities: Optional[List[str]] = None,
        status: Optional[str] = None,
        tags: Optional[List[str]] = None,
        tag_mode: str = 'any',  # 'any' or 'all'
        has_due_date: Optional[bool] = None,
        is_overdue: Optional[bool] = None,
        due_before: Optional[str] = None,
        due_after: Optional[str] = None,
    ) -> List[dict]:
        """Apply multiple filters to tasks."""
        
        tasks = self.db.get_all()
        
        # Priority filter
        if priority:
            tasks = [t for t in tasks if t.get('priority') == priority]
        elif priorities:
            tasks = [t for t in tasks if t.get('priority') in priorities]
        
        # Status filter
        if status:
            tasks = [t for t in tasks if t.get('status') == status]
        
        # Tags filter
        if tags:
            tags = [tag.lower() for tag in tags]
            if tag_mode == 'all':
                tasks = [
                    t for t in tasks 
                    if all(tag in [x.lower() for x in t.get('tags', [])] for tag in tags)
                ]
            else:  # 'any'
                tasks = [
                    t for t in tasks 
                    if any(tag in [x.lower() for x in t.get('tags', [])] for tag in tags)
                ]
        
        # Due date presence filter
        if has_due_date is not None:
            if has_due_date:
                tasks = [t for t in tasks if t.get('due_date')]
            else:
                tasks = [t for t in tasks if not t.get('due_date')]
        
        # Overdue filter
        if is_overdue is not None:
            now = datetime.now().isoformat()
            if is_overdue:
                tasks = [
                    t for t in tasks 
                    if t.get('due_date') and t['due_date'] < now and t.get('status') != 'completed'
                ]
            else:
                tasks = [
                    t for t in tasks 
                    if not t.get('due_date') or t['due_date'] >= now
                ]
        
        # Date range filters
        if due_before:
            tasks = [t for t in tasks if t.get('due_date') and t['due_date'] < due_before]
        if due_after:
            tasks = [t for t in tasks if t.get('due_date') and t['due_date'] > due_after]
        
        return tasks
```

## Best Practices

- Handle None/empty filter values gracefully
- Support both single and multiple value filters
- Provide sensible defaults for filter modes
- Combine filters efficiently (filter in memory when possible)
- Cache common filter results if performance is needed
- Normalize tags and other text-based filters
