---
name: sagebase-commands
description: Provides quick reference for all Sagebase CLI commands and Docker operations. Activates when user asks how to run application, test, format code, manage database, or execute any Sagebase operation. Includes just commands, unified CLI, testing, formatting, and database management.
---

# Sagebase Commands

## Purpose
Quick reference for all Sagebase CLI commands and Docker operations.

## When to Activate
This skill activates automatically when:
- User asks how to run the application
- User mentions "run", "execute", "test", "format", or "database"
- User asks about Docker commands
- User needs to perform any Sagebase operation

## Quick Command Reference

### Just Commands (Recommended)

```bash
just up              # Start containers and launch Streamlit
just down            # Stop and remove containers
just db              # Connect to database
just test            # Run tests with type checking
just format          # Format code with ruff
just lint            # Lint and auto-fix code
just monitoring      # Launch monitoring dashboard
just process-minutes # Process meeting minutes
just logs            # View container logs
just ports           # Show current port configuration
```

See [reference.md](reference.md) for all just commands.

### Main Application Commands

```bash
# Process minutes
just exec uv run sagebase process-minutes

# Scrape politicians
just exec uv run sagebase scrape-politicians --all-parties

# Launch Streamlit UI
just exec uv run sagebase streamlit

# Launch monitoring
just exec uv run sagebase monitoring

# Show coverage stats
just exec uv run sagebase coverage
```

### Testing Commands

```bash
# Run all tests
just test

# Run specific test file
just exec uv run pytest tests/unit/domain/test_speaker_domain_service.py

# Run with coverage
just exec uv run pytest --cov=src --cov-report=html
```

### Code Quality Commands

```bash
# Format code
just format

# Lint code
just lint

# Type check (local only)
uv run --frozen pyright
```

### Database Commands

```bash
# Connect to PostgreSQL
just db

# Backup database
just exec uv run sagebase database backup

# Restore database
just exec uv run sagebase database restore backup.sql

# Reset database
just clean && just up
```

### Migration Commands (Alembic)

```bash
# Run migrations (apply all pending)
just migrate

# Rollback last migration
just migrate-rollback

# Show current version
just migrate-current

# Show migration history
just migrate-history

# Create new migration
just migrate-new "add_column_to_table"
```

## Command Categories

1. **Environment Setup**: Docker, dependencies, GCS
2. **Application Execution**: Process minutes, scrape, UI
3. **Testing**: pytest, coverage, evaluation
4. **Code Quality**: ruff, pyright, pre-commit
5. **Database**: backup, restore, connect
6. **Migrations**: Alembic (migrate, rollback, history)
7. **Conference Members**: Extract, match, create affiliations
8. **Parliamentary Groups**: Extract, match, memberships

## Detailed Reference

For complete command documentation with all options and examples, see [reference.md](reference.md).

## Workflow Examples

For common workflows combining multiple commands, see [examples.md](examples.md).

## Templates and Scripts

- `templates/`: Command templates for common operations
- `scripts/`: Helper scripts for complex workflows
