---
name: amplitude-navigator
description: Comprehensive guide for Amplitude MCP queries. Use when analyzing product analytics, user behavior, funnels, retention, experiments, or metrics. Reduces context overhead by documenting query patterns, event taxonomies, and RDC-specific configurations. Triggers on Amplitude, product analytics, user behavior, funnel analysis, retention, experiment analysis, or metric queries.
---

# Amplitude Navigator

This skill provides efficient navigation of the Amplitude MCP tools, reducing context overhead by documenting common query patterns, event taxonomies, and RDC-specific configurations.

## RDC Context

### Organization
- **Organization ID**: `228133`
- **Organization URL**: `realtor`
- **Organization Name**: Realtor.com

### Key Projects

| Project | App ID | Description | Use Case |
|---------|--------|-------------|----------|
| **Realtor - Production** | `558383` | Primary clickstream data | Main analytics, experiments |
| **Realtor - Leads 2.0** | `678364` | Lead submission data | Lead analysis, attribution, click attributed EFR |
| **Consumer Marketing Data Braze** | `674963` | Braze notification events | Push/email engagement |
| **Consumer Marketing Data Cordial** | `678109` | Cordial email events | Email performance |
| **Real Time SDK - Prod** | `675822` | Browser SDK with Session Replay | Session replay, real-time |
| **Realtor - QA** | `645393` | QA/Alpha/Beta environments | Testing only |
| **Seller Leads Exploration** | `717063` | Seller vertical data | Seller analytics |

**Default Project**: `558383` (Realtor - Production)

## Tool Selection Matrix

| Task | Tool | When to Use |
|------|------|-------------|
| **Discover content** | `search` | Find existing charts, events, metrics, experiments, dashboards |
| **Ad-hoc analysis** | `query_dataset` | Custom queries not covered by existing charts |
| **Existing chart data** | `query_charts` | When you have chart IDs (max 3 per call) |
| **Saved metric data** | `query_metric` | Query predefined metrics by ID |
| **Experiment results** | `query_experiment` | A/B test statistical analysis |
| **Event properties** | `get_event_properties` | Get properties for a specific event type |
| **Full experiment details** | `get_experiments` | Retrieve experiment configuration, state, decisions |
| **Dashboard contents** | `get_dashboard` | Get all charts in a dashboard |
| **Session recordings** | `get_session_replays` | Find user session recordings |
| **URL lookup** | `get_from_url` | Parse Amplitude URLs to get objects |

### Workflow Pattern

1. **Search first** - Use `search` to discover existing charts/events before building custom queries
2. **Get properties** - Use `get_event_properties` after finding exact event names
3. **Query or build** - Use existing charts (`query_charts`) or build custom (`query_dataset`)
4. **Always reference** - Include chart/metric links in responses for validation

## Query Types Reference

### Events Segmentation (Trends)

For time-series analysis of events.

```python
{
  "name": "Daily Active Users",
  "type": "eventsSegmentation",
  "app": "558383",
  "params": {
    "range": "Last 30 Days",
    "events": [{"event_type": "_active", "filters": [], "group_by": []}],
    "metric": "uniques",
    "countGroup": "User",
    "groupBy": [],
    "interval": 1,
    "segments": [{"conditions": []}]
  }
}
```

**Metric Options**:
- `uniques` - Unique users
- `totals` - Event count
- `average` - Per user average
- `pct_dau` - % of DAU
- `frequency` - Distribution
- `sums` - Property sum (requires property in group_by)
- `value_avg` - Property average

### Funnels (Conversion Analysis)

For step-by-step conversion analysis.

```python
{
  "name": "Lead Funnel",
  "type": "funnels",
  "app": "558383",
  "params": {
    "range": "Last 30 Days",
    "events": [
      {"event_type": "pageview", "filters": [], "group_by": []},
      {"event_type": "cobrokelead", "filters": [], "group_by": []}
    ],
    "countGroup": "User",
    "segments": [{"conditions": []}]
  }
}
```

**Key Parameters**:
- `conversionWindow`: `{"value": 1, "unit": "day"}` - Time limit for completion
- `order`: `"this_order"` (default), `"any_order"`, `"exact_order"`

### Retention

For cohort retention analysis.

```python
{
  "name": "New User Retention",
  "type": "retention",
  "app": "558383",
  "params": {
    "range": "Last 90 Days",
    "startEvent": {"event_type": "_new", "filters": [], "group_by": []},
    "retentionEvents": [{"event_type": "_active", "filters": [], "group_by": []}],
    "retentionMethod": "nday",
    "countGroup": "User",
    "interval": 1,
    "segments": [{"conditions": []}]
  }
}
```

**Retention Methods**:
- `nday` - Return on specific day
- `rolling` - Return on or after day
- `bracket` - Custom ranges via `retentionBrackets`

### Sessions

For session-based metrics.

```python
{
  "name": "Average Session Length",
  "type": "sessions",
  "app": "558383",
  "params": {
    "range": "Last 30 Days",
    "sessions": [{"filters": [], "group_by": []}],
    "countGroup": "User",
    "sessionType": "average",
    "segments": [{"conditions": []}]
  }
}
```

**Session Types**: `average`, `totalSessions`, `peruser`, `averageTimePerUser`, `totalTime`, `length`

## Meta Event Types

Special system events available in all queries:

| Event Type | Description | Use Case |
|------------|-------------|----------|
| `_active` | Any active event | DAU, MAU, active users |
| `_new` | First event by new users | New user analysis, retention start |
| `_all` | Any tracked event | Total event volume |
| `_any_revenue_event` | Revenue events | Revenue analysis |
| `$popularEvents` | Top events by volume | Taxonomy exploration |

## Property Syntax

### Property Sources

| Source | Prefix | Example |
|--------|--------|--------|
| Amplitude Core | None | `country`, `platform`, `device_type` |
| Customer (Custom) | `gp:` | `gp:vertical`, `gp:page_type` |
| Experiment Flags | `gp:[Experiment]` | `gp:[Experiment] MBL2510_FEATURE` |

### Common Amplitude Core Properties

**User/Session**: `user_id`, `amplitude_id`, `device_id`, `session_id`
**Geographic**: `country`, `city`, `region`, `dma`
**Device**: `platform`, `device`, `device_type`, `os`, `language`
**Application**: `version`, `start_version`, `library`

### Filter Syntax

**Segment-level filter** (applies to all events):
```python
"segments": [{
  "conditions": [{
    "type": "property",
    "group_type": "User",
    "prop_type": "user",
    "prop": "country",
    "op": "is",
    "values": ["United States"]
  }]
}]
```

**Event-level filter** (applies to specific event):
```python
"events": [{
  "event_type": "pageview",
  "filters": [{
    "group_type": "User",
    "subprop_key": "page_type",
    "subprop_op": "is",
    "subprop_type": "event",
    "subprop_value": ["ldp"]
  }],
  "group_by": []
}]
```

**Filter Operators**: `is`, `is not`, `contains`, `does not contain`, `set is`, `set is not`, `greater than`, `less than`

### Group By Syntax

**Event property**:
```python
"group_by": [{"type": "event", "value": "platform"}]
```

**User property**:
```python
"group_by": [{"type": "user", "value": "country"}]
```

**Top-level groupBy** (across all events):
```python
"groupBy": [{"type": "user", "value": "country", "group_type": "User"}]
```

## Time Parameters

### Range Strings
- `"Last N Days"` - Last 7 Days, Last 30 Days, Last 90 Days
- `"Last N Weeks"` - Last 4 Weeks
- `"Last N Months"` - Last 3 Months
- `"This Week"`, `"This Month"`, `"This Quarter"`, `"This Year"`

### Unix Timestamps
For precise boundaries:
```python
"start": 1727740800,
"end": 1730419199
```

### ISO Dates
```python
"start": "2025-01-01",
"end": "2025-01-31"
```

### Interval Values

| Value | Granularity |
|-------|-------------|
| `-3600000` | Hourly |
| `1` | Daily (default) |
| `7` | Weekly |
| `30` | Monthly |
| `90` | Quarterly |

**Important**: Only these exact values are valid. Arbitrary intervals (2, 3, 14) will error.

## Common RDC Events

### Lead Events
| Event | Description |
|-------|-------------|
| `cobrokelead` | Cobroke listing lead submission |
| `advantagelead` | Advantage listing lead |
| `rentallead` | Rental property lead |
| `farlead` | Find a Realtor lead |
| `newconstructiondirectlead` | New construction lead |
| `forsaleagentconnection` | Agent connection lead |

### Engagement Events
| Event | Description |
|-------|-------------|
| `pageview` | Page view |
| `search` | Search performed |
| `refinedsearch` | Search filter applied |
| `click` | Generic click |
| `saveditem` | Listing/search saved |
| `listingclick` | Listing card click |

### User Events
| Event | Description |
|-------|-------------|
| `signup` | Account created |
| `signin` | User signed in |
| `signout` | User signed out |
| `claimhome` | Home claimed |

### Experiment Events
| Event | Description |
|-------|-------------|
| `[Experiment] Exposure` | Experiment variant exposure |
| `[Experiment] Assignment` | Variant assignment |
| `expexposure` | Legacy exposure event |

## Experiment Analysis

### Querying Experiments

1. **Search for experiment**:
```python
Amplitude:search(entityTypes=["EXPERIMENT"], query="feature_name")
```

2. **Get experiment details**:
```python
Amplitude:get_experiments(ids=["123456"])
```

3. **Query results** (primary metric only by default):
```python
Amplitude:query_experiment(id="123456")
```

4. **With segment breakdown**:
```python
Amplitude:query_experiment(
  id="123456",
  groupBy=[{"type": "user", "value": "platform", "group_type": "User"}]
)
```

### Interpreting Results

**Key Fields**:
- `pValue` - Statistical significance (< 0.05 = significant)
- `relativeLift` - Percentage change vs control
- `absoluteLift` - Raw metric difference
- `ssrmTimeseries.srmDetected` - Sample Ratio Mismatch flag
- `recommendation` - "rollout", "rollback", or null

**Decision Framework**:
- **Significant + Positive Lift + No SRM** → Rollout
- **SRM Detected** → Rollback (data quality issue)
- **>30 days + p=1.0** → Consider terminating
- **<14 days** → Continue running

## Session Replay

### Basic Search
```python
Amplitude:get_session_replays(
  projectId="558383",
  segmentFilters=[{"conditions": []}],
  limit=10
)
```

### By Experiment Variant
```python
Amplitude:get_session_replays(
  projectId="558383",
  segmentFilters=[{
    "conditions": [{
      "type": "property",
      "group_type": "User",
      "prop_type": "user",
      "prop": "gp:[Experiment] feature_flag",
      "op": "is",
      "values": ["treatment"]
    }]
  }],
  limit=10
)
```

### With Event Filters
```python
Amplitude:get_session_replays(
  projectId="558383",
  eventCountFilters=[{
    "count": "1",
    "operator": "greater or equal",
    "event": {"event_type": "cobrokelead", "filters": [], "group_by": []}
  }],
  limit=10
)
```

## Response Parsing

### CSV Response (isCsvResponse: true)
- Header rows contain metadata
- Data header row has column labels (dates)
- Data rows: label columns + value columns
- Values may be prefixed with `\t`

### JSON Response (isCsvResponse: false)
```javascript
{
  timeSeries: [[{value: 614}, {value: 1769}]],
  overallSeries: [[{value: 2383}]],
  seriesMetadata: [{segmentIndex: 0, formulaIndex: 0}],
  xValuesForTimeSeries: ["2025-01-01T00:00:00", "2025-01-02T00:00:00"]
}
```

## Reference Documents

- **[query_patterns.md](references/query_patterns.md)** - Detailed query templates
- **[events_taxonomy.md](references/events_taxonomy.md)** - Complete event reference

## Tips for Efficient Queries

1. **Search before building** - Existing charts are pre-optimized
2. **Always name queries** - Include descriptive `name` field
3. **Use correct project** - Production (558383) vs Leads (678364)
4. **Limit group by values** - Use `groupByLimit` to control cardinality
5. **Exclude incomplete data** - Set `excludeIncompleteDatapoints: true` for accurate trends
6. **Reference charts in responses** - Always provide links for validation
7. **Batch experiment queries** - Query 3-5 at a time to avoid timeouts
