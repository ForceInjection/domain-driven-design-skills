---
name: python-hr-analytics-tutor
description: Specialized Python tutoring for HR analytics professionals. Use when working on HR/talent analytics tasks involving turnover, time-to-fill, retention, headcount, recruiting analytics, or other People Analytics metrics. Loads HR-specific patterns and examples.
---

# Python for HR Analytics Tutor

Specialized skill for HR analytics Python work. General teaching preferences (explain WHY, beginner-friendly, error handling, etc.) are defined in the global `claude.md` — this skill adds HR-specific context and patterns.

## When to Load References

**Load these files based on the task:**

- **`references/python-basics.md`** — For foundational Python concepts (data types, variables, DataFrames, basic operators, errors). Use when revisiting fundamentals.

- **`references/hr-patterns.md`** — For specific HR analytics operations (turnover calculations, time-to-fill, cohort analysis, data merging, aggregations). Use for "how do I do X" questions.

- **`references/complete-examples.md`** — For end-to-end workflows (comprehensive turnover analysis, recruiting funnel, retention cohorts, forecasting). Use for understanding full analytical processes.

**Loading strategy:**
- Basic concept questions → `python-basics.md`
- Specific pandas/HR operations → `hr-patterns.md`
- Complete workflow examples → `complete-examples.md`
- Complex projects → may need multiple references

## HR Analytics Domain Context

### Common Metrics
- **Turnover rate**: (terminations / headcount) × 100 — voluntary, involuntary, by segment
- **Time-to-fill**: Days from req open to offer accept — by role, office, aged reqs
- **Retention rate**: Cohort-based (% still employed after X months) or milestone-based
- **Headcount**: Point-in-time counts, trending by month/segment
- **Span of control**: Direct reports per manager

### Common Data Operations
- Merging employee data across systems (HRIS, ATS, payroll)
- Fuzzy name matching across sources
- Date range filtering (active during period, hired between dates)
- Aggregating by multiple dimensions (role + office + tenure band)
- Creating derived fields (tenure buckets, age bands, performance tiers)

### Analysis Types
- **Cohort analysis**: Retention by hire period
- **Funnel analysis**: Recruiting stages and conversion rates
- **Trend analysis**: Metrics over time
- **Segment comparison**: By role, office, tenure, performance
- **Forecasting**: Headcount projections, attrition predictions

## HR-Specific Code Patterns

### Turnover Rate by Segment
```python
# Count terminations per segment
terms = df[df['is_terminated']].groupby('segment').size()

# Count total headcount per segment
headcount = df.groupby('segment').size()

# Calculate rate
turnover_rate = (terms / headcount * 100).round(2)
```

### Time-to-Fill Calculation
```python
# Convert dates and calculate days
df['req_open'] = pd.to_datetime(df['req_open'])
df['offer_accept'] = pd.to_datetime(df['offer_accept'])
df['time_to_fill'] = (df['offer_accept'] - df['req_open']).dt.days

# Average by role
ttf_by_role = df.groupby('role')['time_to_fill'].mean().round(1)
```

### Tenure Calculation
```python
# Calculate tenure in years (accounting for leap years)
df['tenure_years'] = (pd.Timestamp.now() - df['hire_date']).dt.days / 365.25

# Create tenure bands
df['tenure_band'] = pd.cut(
    df['tenure_years'],
    bins=[0, 1, 3, 5, 10, float('inf')],
    labels=['<1 yr', '1-3 yrs', '3-5 yrs', '5-10 yrs', '10+ yrs']
)
```

### Cohort Retention
```python
# Create hire cohort (year-month)
df['hire_cohort'] = df['hire_date'].dt.to_period('M')

# Calculate months since hire
df['months_since_hire'] = (
    (pd.Timestamp.now() - df['hire_date']).dt.days / 30.44
).astype(int)

# Retention at milestone
milestone = 12  # months
cohort_size = df.groupby('hire_cohort').size()
still_active = df[
    (df['is_active']) & (df['months_since_hire'] >= milestone)
].groupby('hire_cohort').size()
retention_rate = (still_active / cohort_size * 100).round(1)
```

### Recruiting Funnel
```python
# Stage conversion rates
funnel = df.groupby('stage').size().reset_index(name='count')
funnel['conversion'] = (
    funnel['count'] / funnel['count'].iloc[0] * 100
).round(1)

# Stage-to-stage drop-off
funnel['stage_conversion'] = (
    funnel['count'] / funnel['count'].shift(1) * 100
).round(1)
```

## Data Source Context

Typical data sources in this environment:
- **BigQuery**: Primary data warehouse
- **Workday RaaS**: HR system reports
- **CSV/Excel exports**: Ad-hoc data pulls

Common data quality issues to watch for:
- Multiple records per employee (need to deduplicate or filter to latest)
- Date fields as strings (need pd.to_datetime conversion)
- Inconsistent department/role naming across systems
- Missing termination dates for active employees (expected, not an error)
