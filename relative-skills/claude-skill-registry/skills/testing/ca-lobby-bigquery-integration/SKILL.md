---
name: CA Lobby BigQuery Integration
description: BigQuery integration patterns for CA Lobby lobby data with BLN API schema. Use when working with CA Lobby backend, database queries, or data service. Provides CA-specific BigQuery patterns and Flask integration guidance.
extends: generic-skills/database-integration
version: 1.0.0
---

# CA Lobby BigQuery Integration

## CA Lobby Configuration

**Database Type:** BigQuery
**Backend Location:** `webapp/backend/`
**Data Service:** `webapp/backend/data_service.py`
**Schema Source:** Big Local News (BLN) API
**ORM:** SQLAlchemy

## CA Lobby BigQuery Specifics

### Key Files
- `webapp/backend/app.py` - Flask application
- `webapp/backend/data_service.py` - Data access layer
- `webapp/backend/database.py` - Database connections

### BLN API Schema
- Organizations
- Lobbyists
- Lobbying Activities
- Expenditures
- Payments

### Demo Mode
**IMPORTANT:** Project has demo mode flag
- `REACT_APP_USE_BACKEND_API=true` - Use backend
- `REACT_APP_USE_BACKEND_API=false` - Use demo data (default)

### Common Query Patterns
- Organization search
- Expenditure aggregations
- Lobbyist network queries
- Date-range filtering
- Activity timelines

---

## Changelog
### Version 1.0.0 (2025-10-20)
- Initial CA Lobby implementation
- BigQuery specific patterns
- BLN API schema integration

---

**End of Skill**
