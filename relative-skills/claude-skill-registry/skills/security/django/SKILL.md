---
name: django
description: Django framework best practices including project structure, ORM, and security.
globs: ["**/settings.py", "**/urls.py", "**/views.py", "**/models.py", "**/manage.py"]
priority: 90
tags: ["framework"]
---

# Django Best Practices

## Project Structure
- Keep apps small and focused
- Use apps/ directory for apps
- Separate settings per environment
- Use environment variables for secrets

## Models
- Use verbose_name for fields
- Add indexes for queried fields
- Use select_related/prefetch_related
- Avoid N+1 queries
- Use custom managers for common queries

## Views
- Use class-based views for CRUD
- Use function views for simple logic
- Return proper HTTP status codes
- Use Django REST Framework for APIs

## Security
- Never disable CSRF protection
- Use Django's ORM (no raw SQL)
- Validate all inputs
- Use Django's auth system
- Keep DEBUG=False in production

## Performance
- Use Django Debug Toolbar in dev
- Cache with Redis/Memcached
- Use database connection pooling
- Optimize querysets
- Use lazy loading
