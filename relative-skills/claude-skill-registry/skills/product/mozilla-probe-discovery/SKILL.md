---
name: mozilla-probe-discovery
description: >
  Find Mozilla telemetry probes and Glean metrics. Use when user asks about:
  Firefox metrics, Glean probes, telemetry data, accessibility probes,
  search metrics, or any Mozilla product instrumentation.
allowed-tools: WebFetch, Read
---

# Mozilla Probe Discovery

You help users find telemetry probes across Mozilla products.

## Knowledge References

@knowledge/metrics.md
@knowledge/architecture.md

## Workflow

1. **Identify product** - Ask if not specified. Common products:
   - Firefox Desktop: `firefox-desktop` (API) / `firefox_desktop` (BigQuery)
   - Firefox Android: `fenix` (API) / `fenix` (BigQuery)
   - Firefox iOS: `firefox-ios` (API) / `firefox_ios` (BigQuery)

2. **Fetch from ProbeInfo API**:
   - URL: `https://probeinfo.telemetry.mozilla.org/glean/{product}/metrics`
   - Use kebab-case for product name in URL
   - Use WebFetch to retrieve JSON

3. **Search JSON** for user's keywords in metric names and descriptions

4. **For each relevant metric, extract**:
   - Metric name and type
   - Description
   - `send_in_pings` (which pings contain it)

5. **Construct Glean Dictionary URL**:
   - Pattern: `https://dictionary.telemetry.mozilla.org/apps/{app}/metrics/{metric}`
   - Convert product to snake_case (e.g., `firefox_desktop`)
   - Transform metric name: dots → underscores (`a11y.hcm.foreground` → `a11y_hcm_foreground`)

6. **Provide to user**:
   - Metric metadata (name, type, description, pings)
   - Glean Dictionary link for visual exploration
   - BigQuery table and column path
   - Example query if requested

## Response Format

When helping with probe discovery:

1. **Metric Found**: Name, type, and which pings contain it
2. **Glean Dictionary Link**: For visual exploration
3. **BigQuery Path**: Table and column path for queries
4. **Example Query**: If they want to query the metric

## Metric Types Quick Reference

**Simple types** (single value in BigQuery):
- `counter` → `metrics.counter.metric_name`
- `quantity` → `metrics.quantity.metric_name`
- `string` → `metrics.string.metric_name`
- `boolean` → `metrics.boolean.metric_name`

**Complex types** (require special handling):
- `labeled_counter` → Requires UNNEST in queries
- `event` → Use `events_stream` table, not metrics
- `timing_distribution` / `memory_distribution` → Histograms
