---
name: bi-dashboard-commands
description: Provides quick reference for BI Dashboard (Plotly Dash) commands and operations. Activates when user asks how to run, test, or verify the BI Dashboard. Includes startup, shutdown, verification, and troubleshooting procedures.
---

# BI Dashboard Commands

## Purpose
Quick reference for BI Dashboard (Plotly Dash) commands and verification procedures.

## When to Activate
This skill activates automatically when:
- User asks how to run the BI Dashboard
- User mentions "bi dashboard", "plotly dash", or "data coverage dashboard"
- User needs to verify BI Dashboard functionality
- User asks about BI Dashboard troubleshooting

## Quick Command Reference

### Basic Operations

```bash
# Start BI Dashboard (foreground)
just bi-dashboard

# Start BI Dashboard (background)
just bi-dashboard-up

# Stop BI Dashboard
just bi-dashboard-down

# View logs
cd src/interfaces/bi_dashboard && docker-compose logs -f
```

### Alternative Manual Startup

```bash
# Navigate to BI Dashboard directory
cd src/interfaces/bi_dashboard

# Start with Docker Compose
docker-compose up --build

# Start in background
docker-compose up -d --build

# Stop
docker-compose down
```

### Without Docker (Local Development)

```bash
cd src/interfaces/bi_dashboard

# Set database URL
export DATABASE_URL=postgresql://sagebase:sagebase@localhost:5432/sagebase

# Run directly
python app.py
```

## Verification Procedures

### 1. Basic Functionality Check

After starting the BI Dashboard, verify the following:

```bash
# 1. Start the dashboard
just bi-dashboard-up

# 2. Open browser to http://localhost:8050

# 3. Verify the following components are displayed:
#    - Summary cards (総自治体数, データ取得済み, カバレッジ率)
#    - Pie chart (全体カバレッジ率)
#    - Bar chart (組織タイプ別カバレッジ)
#    - Prefecture table (都道府県別カバレッジ)
#    - "データを更新" button

# 4. Click "データを更新" button and verify:
#    - No errors are displayed
#    - Charts update successfully
#    - Data reflects current database state

# 5. Stop the dashboard
just bi-dashboard-down
```

### 2. Detailed Verification Checklist

#### Visual Elements
- [ ] Page loads without errors
- [ ] All three summary cards are displayed with correct numbers
- [ ] Pie chart renders correctly with labels and percentages
- [ ] Bar chart shows stacked bars for each organization type
- [ ] Prefecture table displays top 10 prefectures
- [ ] Table rows have appropriate background colors (green/yellow/red)

#### Interactive Features
- [ ] "データを更新" button is clickable
- [ ] Clicking the button refreshes all charts and data
- [ ] Pie chart is interactive (hover shows details)
- [ ] Bar chart is interactive (hover shows values)
- [ ] Chart legend is functional

#### Data Accuracy
- [ ] Summary card numbers match database counts
- [ ] Coverage rate calculation is correct
- [ ] Organization type breakdown matches database
- [ ] Prefecture rankings are sorted by coverage rate

### 3. Database Connection Verification

```bash
# Verify database is accessible from BI Dashboard
cd src/interfaces/bi_dashboard

# Check Docker network
docker-compose ps

# Test database connection
docker-compose exec bi-dashboard python -c "
from data.data_loader import get_database_url, get_coverage_stats
print('Database URL:', get_database_url())
stats = get_coverage_stats()
print('Coverage Stats:', stats)
"
```

### 4. Troubleshooting

#### Dashboard Won't Start

```bash
# Check if port 8050 is already in use
lsof -i :8050

# Kill existing process if necessary
kill -9 <PID>

# Check Docker daemon is running
docker ps

# Rebuild containers
cd src/interfaces/bi_dashboard
docker-compose down
docker-compose up --build
```

#### No Data Displayed

```bash
# Verify database has data
docker compose -f docker/docker-compose.yml exec postgres \
  psql -U sagebase_user -d sagebase_db \
  -c "SELECT COUNT(*) FROM governing_bodies;"

# Check database connection string
cd src/interfaces/bi_dashboard
docker-compose logs bi-dashboard | grep -i "database\|error"
```

#### Charts Not Rendering

```bash
# Check browser console for JavaScript errors
# Open browser DevTools (F12) and check Console tab

# Verify Plotly is installed
cd src/interfaces/bi_dashboard
docker-compose exec bi-dashboard pip list | grep plotly
```

#### Performance Issues

```bash
# Check database query performance
docker compose -f docker/docker-compose.yml exec postgres \
  psql -U sagebase_user -d sagebase_db \
  -c "EXPLAIN ANALYZE SELECT * FROM governing_bodies LEFT JOIN meetings ON governing_bodies.id = meetings.governing_body_id;"

# Monitor resource usage
docker stats
```

## Architecture Notes

### Clean Architecture Compliance

The BI Dashboard is designed as an **independent application** with its own:
- Docker Compose configuration (`src/interfaces/bi_dashboard/docker-compose.yml`)
- Python dependencies (`requirements.txt`)
- Separation from main Polibase application

**Current State (POC)**:
- Direct database access via SQLAlchemy
- Data loading in `data/data_loader.py`

**Future Integration**:
- Use Repository pattern via domain layer
- Apply Use Cases from application layer
- Use DTOs for data transfer

### Port Configuration

- **BI Dashboard**: Port 8050 (default)
- **Main Streamlit**: Port 8501 (default)
- **Monitoring Dashboard**: Port 8502 (deprecated, see Issue #678)

These ports do not conflict, allowing simultaneous operation.

## Common Use Cases

### Use Case 1: Quick Data Coverage Check

```bash
# Start dashboard
just bi-dashboard-up

# Open http://localhost:8050
# View coverage summary cards

# Stop when done
just bi-dashboard-down
```

### Use Case 2: Detailed Prefecture Analysis

```bash
# Start dashboard
just bi-dashboard

# Navigate to http://localhost:8050
# Review prefecture coverage table
# Identify prefectures with low coverage
# Plan data collection efforts accordingly

# Stop with Ctrl+C
```

### Use Case 3: Integration Testing After Changes

```bash
# After modifying BI Dashboard code
cd src/interfaces/bi_dashboard

# Rebuild and start
docker-compose down
docker-compose up --build

# Verify all functionality (see checklist above)
# Check browser console for errors
# Test interactive features

# Stop
docker-compose down
```

## File Structure

```
src/interfaces/bi_dashboard/
├── app.py                    # Main Dash application
├── layouts/
│   └── main_layout.py       # Layout components
├── callbacks/
│   └── data_callbacks.py    # Interactive callbacks
├── data/
│   └── data_loader.py       # Data retrieval logic
├── Dockerfile               # Docker configuration
├── docker-compose.yml       # Standalone deployment
├── requirements.txt         # Python dependencies
└── README.md               # Detailed documentation
```

## Related Documentation

- [BI Dashboard README](../../../src/interfaces/bi_dashboard/README.md) - Detailed setup and usage
- [Main README](../../../README.md) - Project overview and BI Dashboard section
- [Issue #663](https://github.com/trust-chain-organization/polibase/issues/663) - BI tool selection and POC implementation
- [Issue #678](https://github.com/trust-chain-organization/polibase/issues/678) - Remove deprecated monitoring dashboard

## Notes

- BI Dashboard is excluded from pyright type checking (see `pyrightconfig.json`)
- Uses independent Python environment (not main Polibase dependencies)
- Designed for future Clean Architecture integration
- POC status: Fully functional, ready for enhancement
