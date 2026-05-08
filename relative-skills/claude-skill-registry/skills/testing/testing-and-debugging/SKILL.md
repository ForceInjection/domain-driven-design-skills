---
name: testing-and-debugging
description: Diagnose and debug issues in the vehicle insurance data analysis platform. Use when user encounters errors, data not refreshing, filters not working, charts not displaying, API failures, or performance issues. Provides quick diagnostic checklists and proven troubleshooting steps specific to this Vue 3 + Flask + Pandas stack.
allowed-tools: Read, Bash, Grep, Glob
---

# Testing and Debugging Guide

You are assisting with debugging the vehicle insurance data analysis platform (Vue 3 frontend + Flask backend + Pandas data processing).

## When to Use This Skill

Activate this skill when the user reports:
- Data not updating or refreshing
- Filters/筛选 not working correctly
- Charts/图表 not displaying
- API errors or slow responses
- Style/样式 rendering issues
- Performance problems
- Build or deployment failures

## Quick Diagnostic Workflow

### Step 1: Identify the Problem Layer

Ask the user to describe the symptom, then categorize:

**Frontend Issues** (Vue/UI):
- UI not updating → Check reactive data and computed properties
- Chart not showing → Verify ECharts initialization and data format
- Filters ineffective → Check Store state and API params
- Styles broken → Inspect CSS variables and scoped styles

**Backend Issues** (Flask/Pandas):
- API errors → Check backend logs (`backend/backend.log`)
- Slow responses → Profile Pandas operations
- Missing data → Verify CSV file existence and permissions

**Integration Issues**:
- CORS errors → Check Flask-CORS configuration
- Network failures → Inspect browser Network tab

### Step 2: Run Diagnostic Commands

Guide the user through these checks:

#### For Frontend Issues
```bash
# Check if dev server is running
lsof -i :5173

# View browser console
# Open DevTools (F12) → Console tab → Check for errors

# Check Vue DevTools
# Install Vue DevTools extension → Inspect component state
```

#### For Backend Issues
```bash
# Check if backend is running
lsof -i :5000

# View backend logs
tail -f backend/backend.log

# Test API directly
curl http://localhost:5000/api/latest-date
```

### Step 3: Common Problems & Solutions

Refer to the [Common Issues Reference](./COMMON_ISSUES.md) for detailed troubleshooting steps.

## Current Project Structure (for context)

```
项目/
├── frontend/               # Vue 3 + Vite
│   ├── src/
│   │   ├── components/    # KpiCard, FilterPanel, ChartView
│   │   ├── stores/        # data.js, filter.js, app.js (Pinia)
│   │   ├── views/         # Dashboard.vue
│   │   └── services/      # api.js (Axios)
│   └── package.json       # NO testing libraries installed yet
├── backend/
│   ├── api_server.py      # Flask routes
│   ├── data_processor.py  # Pandas logic
│   └── backend.log        # Runtime logs
└── data/                  # CSV files
```

**Important Context**:
- Project does NOT currently have Vitest, pytest, or any testing framework installed
- Testing is manual through browser DevTools and curl commands
- No CI/CD pipeline configured

## Debugging Strategies by Component

### KpiCard Component Issues

**Symptom**: KPI values not updating

**Diagnostic checklist**:
1. Open Vue DevTools → Components → Find KpiCard instance
2. Check props: `value`, `trend`, `loading`
3. Verify parent Dashboard component is passing correct data
4. Check DataStore state: `store.kpiData`

**Common causes**:
- API returned data but Store didn't update → Check `fetchKpiData()` action
- Store updated but component didn't re-render → Verify reactive refs
- Data is correct but formatting is wrong → Check `valueType` prop

### FilterPanel Issues

**Symptom**: Filters applied but data doesn't change

**Diagnostic steps**:
1. Open Vue DevTools → Pinia → FilterStore
2. Verify `activeInstitution`, `activeTeam`, etc. are updated
3. Check if `applyFilters()` action was triggered
4. Inspect Network tab → Verify API request includes filter params

**Quick fix**:
```javascript
// In browser console
const filterStore = useFilterStore()
console.log('Active filters:', filterStore.activeInstitution, filterStore.activeTeam)

const dataStore = useDataStore()
dataStore.fetchFilteredData()  // Force refresh
```

### ChartView Issues

**Symptom**: Chart not rendering

**Diagnostic checklist**:
1. Open browser console → Check for ECharts errors
2. Verify chart container has non-zero dimensions
3. Check `chartData` prop structure matches ECharts format
4. Confirm ECharts instance initialized

**Quick fixes**:
```javascript
// In ChartView.vue, add logging
onMounted(() => {
  console.log('Chart container:', chartRef.value)
  console.log('Chart data:', props.chartData)
  console.log('Container size:', chartRef.value?.offsetWidth, chartRef.value?.offsetHeight)
})
```

### Backend API Errors

**Symptom**: API returns 500 or 404

**Diagnostic steps**:
1. Check `backend/backend.log` for Python exceptions
2. Test API endpoint with curl:
   ```bash
   curl -X GET 'http://localhost:5000/api/kpi?period=day'
   ```
3. Verify Flask is running: `ps aux | grep api_server`
4. Check if CSV file exists and is readable

**Common causes**:
- `车险清单_2025年10-11月_合并.csv` not found → Run `scan_and_process_new_files()`
- Pandas DataFrame empty → Check data cleaning logic in `data_processor.py`
- Column name mismatch → Verify CSV headers match expected field names

## Performance Debugging

### Slow Data Loading

**Check these**:
1. CSV file size → Large files slow Pandas reads
2. Pandas operations → Avoid row-by-row iteration
3. Network latency → Time API requests in Network tab

**Optimization tips**:
```python
# In data_processor.py
# SLOW (avoid)
for index, row in df.iterrows():
    df.at[index, 'new_col'] = some_function(row)

# FAST (vectorized)
df['new_col'] = df.apply(lambda row: some_function(row), axis=1)
```

### Memory Issues

**Symptoms**: Browser/Python crashes

**Diagnostic**:
```bash
# Check memory usage
# macOS:
top -o MEM

# Check Python process
ps aux | grep python | awk '{print $11, $6/1024 "MB"}'
```

**Solutions**:
- Reduce CSV data loaded into memory
- Clear browser cache
- Restart backend process

## Logging Best Practices

### Frontend Logging

**Current approach** (add to components as needed):
```javascript
// In stores/data.js
export const useDataStore = defineStore('data', {
  actions: {
    async fetchKpiData() {
      console.log('[DataStore] Fetching KPI data...')
      try {
        const response = await api.getKpiData()
        console.log('[DataStore] KPI data loaded:', response.data)
        this.kpiData = response.data
      } catch (error) {
        console.error('[DataStore] Fetch error:', error)
        this.error = error.message
      }
    }
  }
})
```

### Backend Logging

**Current configuration** (already in place):
```python
# backend/api_server.py uses Python logging
import logging

logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s [%(levelname)s] %(name)s: %(message)s',
    handlers=[
        logging.FileHandler('backend/backend.log'),
        logging.StreamHandler()
    ]
)
```

**View logs**:
```bash
# Real-time monitoring
tail -f backend/backend.log

# Search for errors
grep -i "error" backend/backend.log

# Last 50 lines
tail -n 50 backend/backend.log
```

## Browser DevTools Checklist

### Essential Tabs

1. **Console**: JavaScript errors and log messages
2. **Network**: API requests/responses, timing, status codes
3. **Vue DevTools**: Component tree, Pinia stores, events
4. **Elements**: Inspect DOM and CSS

### Common Workflow

```
1. User reports: "Data not refreshing"
2. Open Console → Check for errors
3. Open Network → Filter by XHR → Check API calls
4. Open Vue DevTools → Pinia → Inspect DataStore state
5. If API failed → Check backend logs
6. If API succeeded but UI not updated → Check component reactive data
```

## Quick Reference Links

- [Common Issues Guide](./COMMON_ISSUES.md) - Detailed troubleshooting for 10+ common problems
- [vue-component-dev Skill](../vue-component-dev/SKILL.md) - Component architecture reference
- [backend-data-processor Skill](../backend-data-processor/SKILL.md) - Pandas debugging tips
- [api-endpoint-design Skill](../api-endpoint-design/SKILL.md) - API error codes

## Testing Future Plans

**Note**: Project does not currently have automated testing configured.

If user wants to add testing:
1. **Frontend**: Recommend Vitest + @vue/test-utils
2. **Backend**: Recommend pytest + pytest-flask
3. Refer to [TESTING_SETUP.md](./TESTING_SETUP.md) for installation guide

## Emergency Fixes

### Nuclear Option: Full Restart

```bash
# Stop all processes
pkill -f api_server
pkill -f vite

# Clear caches
rm -rf frontend/node_modules/.vite
rm -rf frontend/dist

# Restart backend
cd backend && python api_server.py &

# Restart frontend
cd frontend && npm run dev
```

### Data Corruption Recovery

```bash
# Backup current data
cp 车险清单_2025年10-11月_合并.csv 车险清单_backup.csv

# Re-scan and rebuild
# (Python)
from data_processor import DataProcessor
processor = DataProcessor()
processor.scan_and_process_new_files()
```

## Summary

This skill focuses on **practical debugging for the current project state**. It assumes:
- No testing framework installed (manual testing only)
- Simple deployment (no Docker/Kubernetes)
- Standard Vue 3 + Flask stack

For advanced testing setup, refer to companion guides. For deployment debugging, use the [deployment-and-ops skill](../deployment-and-ops/SKILL.md).

**Key principle**: Always start with logs (browser Console + backend.log) before diving into code.
