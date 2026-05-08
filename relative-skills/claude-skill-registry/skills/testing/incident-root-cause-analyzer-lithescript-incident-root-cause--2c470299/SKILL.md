---
name: incident-root-cause-analyzer
description: Comprehensive incident root cause analysis skill for distributed systems. Analyzes logs, metrics, and traces to identify cascading failures, resource contention, and root causes through systematic anomaly detection, timeline correlation, and evidence-based hypothesis testing.
license: MIT
allowed-tools: ["code-interpreter", "file-system"]
metadata:
  version: "1.0.0"
  author: "Analysis Team"
---

# Incident Root Cause Analyzer

This skill provides a comprehensive methodology for analyzing production incidents in distributed systems, with special focus on cascading failures, resource contention, and backpressure propagation.

## When to Use This Skill

Use this skill when:
- Analyzing production incidents with timeout errors or performance degradation
- Investigating cascading failures across multiple services
- Identifying resource contention and backpressure issues
- Tracing root causes through metrics, logs, and traces
- Generating evidence-based root cause analysis reports

## Analysis Methodology

### Phase 1: Data Collection and Preparation

1. **Collect Evidence**:
   - Log files (structured and unstructured)
   - Metrics data (Prometheus, Datadog, etc.)
   - Trace data (if available)
   - Incident timeline (error counts, time windows)

2. **Data Cleaning**:
   - Parse structured logs (JSON, key-value pairs)
   - Extract key fields: timestamp, service, API path, latency, error codes
   - Normalize timestamps to common format
   - Filter and consolidate by service/host

3. **Data Validation**:
   - Check data completeness
   - Identify missing metrics or time windows
   - Validate timestamp ranges match incident window

### Phase 2: Anomaly Detection

1. **Metric Anomaly Scoring**:
   - Calculate baseline metrics (P50, P95, P99) for normal periods
   - Compute anomaly scores for each metric at incident time
   - Use statistical methods (z-score, IQR) for outlier detection
   - **Critical**: Identify highest anomaly score (likely root trigger)

2. **Temporal Pattern Analysis**:
   - Align metrics by timestamp
   - Identify which anomalies occurred FIRST
   - Track cascade sequence (downstream → upstream or vice versa)

3. **Key Metrics to Analyze**:
   - **Throughput** (QPS): Did it increase (traffic surge) or decrease (capacity collapse)?
   - **Error Rate**: When did errors spike relative to throughput?
   - **Latency Metrics**: P95, P99, long-tail patterns
   - **Resource Metrics**: CPU, memory, thread pool, GPU utilization
   - **Network Metrics**: TX/RX traffic, connection counts

### Phase 3: Root Cause Hypothesis Generation

1. **Evidence Review**:
   - **Evidence 1**: Throughput analysis (stable vs. changing)
   - **Evidence 2**: Error timing relative to latency spikes
   - **Evidence 3**: Highest anomaly score (root trigger candidate)
   - **Evidence 4**: Timeline correlation (what happened first)
   - **Evidence 5**: Resource contention patterns

2. **Hypothesis Testing**:

   **Hypothesis 1: Downstream Pressure → Backpressure → Resource Starvation** ⭐⭐⭐⭐⭐
   - Pattern: Throughput stable, error rate spikes, extreme long-tail latency
   - Timeline: Downstream service anomaly → upstream latency spike → resource starvation
   - Evidence: Memory/CPU anomaly in downstream service BEFORE upstream issues

   **Hypothesis 2: Traffic Surge** ⭐⭐
   - Pattern: Throughput increases, resources exhausted
   - Evidence: QPS spike, simultaneous latency increase
   - Rejection: If throughput didn't increase, reject this hypothesis

   **Hypothesis 3: Capacity Collapse** ⭐⭐⭐
   - Pattern: Throughput decreases, all metrics degrade simultaneously
   - Evidence: Service health metrics all fail together
   - Distinction: Different from backpressure (backpressure = stable throughput, high latency)

3. **Evidence Chain Construction**:
   - Build causal chain: Root Trigger → First Cascade → Resource Contention → Second Cascade → Incident
   - Verify temporal order (root cause must precede cascades)
   - Calculate time gaps between events

### Phase 4: Visualization Generation

1. **Evidence Charts** (6 critical visualizations):
   - **Evidence 1**: Root trigger metric (highest anomaly score) - time series
   - **Evidence 2**: First cascade point (cut phase latency spike)
   - **Evidence 3**: Second cascade point (detection phase latency spike)
   - **Evidence 4**: Resource contention (thread pool, active/wait queue)
   - **Evidence 5**: Timeline correlation (all metrics aligned)
   - **Evidence 6**: Network traffic anomaly (TX/RX spikes)

2. **Charts Must Include**:
   - Clear English labels
   - Incident time window highlighted
   - Anomaly scores and peak values annotated
   - Temporal markers (e.g., "06:55:00 - First cascade")

3. **Fault Evolution Diagram**:
   - Create Mermaid diagram showing:
     - Root trigger → Cascades → Resource contention → Incident
     - Time points and key metrics
     - Causal relationships

### Phase 5: Report Generation

1. **Executive Summary**:
   - Incident description (what, when, impact)
   - Root cause statement (concise, evidence-based)
   - Key findings (3-5 bullet points)

2. **Detailed Analysis**:
   - Evidence review (5 critical evidence points)
   - Hypothesis evaluation (ranked by likelihood)
   - Root cause chain (temporal sequence)

3. **Recommendations**:
   - Immediate actions (fix root cause)
   - Short-term (mitigate cascades)
   - Long-term (architectural improvements)

## Key Principles

### 1. Temporal Causality
- **Root cause MUST precede cascades in time**
- Build timeline showing: Root trigger → Cascade 1 → Cascade 2 → Incident
- Calculate time gaps (e.g., "5 minutes before incident")

### 2. Anomaly Score Hierarchy
- **Highest anomaly score = most likely root trigger**
- Compare all metric anomaly scores
- Don't ignore metrics with highest scores

### 3. Throughput vs. Error Rate Analysis
- **Stable throughput + spiking errors = resource contention** (not traffic surge)
- **Increasing throughput + errors = traffic surge** (capacity issue)
- **Decreasing throughput + errors = capacity collapse** (service failure)

### 4. Long-tail Latency Patterns
- **Consistent extreme long-tail** (~5000ms) = resource starvation (queuing)
- **Random spikes** = transient issues or model complexity
- **Long-tail timing** = when did it start? (after first cascade?)

### 5. Resource Contention Indicators
- Thread pool: High active + Low wait queue = threads blocked
- Memory: High usage + GC pressure = performance degradation
- Network: High TX traffic = data backlog or retry storms

## Output Structure

### Required Outputs

1. **Root Cause Analysis Report** (`ROOT_CAUSE_REANALYSIS.md`):
   - Executive summary
   - Critical evidence review
   - Hypothesis evaluation
   - Root cause chain
   - Recommendations

2. **Evidence Visualizations** (6 PNG files):
   - Root trigger metric
   - First cascade
   - Second cascade
   - Resource contention
   - Timeline correlation
   - Network traffic

3. **Fault Evolution Diagram** (`fault_evolution_path.md`):
   - Mermaid diagrams (multiple views)
   - Timeline view
   - Component interaction view
   - Sequence diagram

4. **Evidence README** (`root_cause_evidence/README.md`):
   - Evidence index
   - Chart descriptions
   - Data points summary
   - Evidence chain explanation

## Execution Workflow

1. **Initialize Analysis**:
   ```bash
   # Set up analysis directory structure
   mkdir -p analysis/reports/metrics/anomaly_detection/{root_cause_evidence,core_charts}
   ```

2. **Load and Process Data**:
   ```python
   # Use scripts/analyze_metrics.py to:
   # - Load metric CSV files
   # - Calculate anomaly scores
   # - Generate time series data
   ```

3. **Generate Visualizations**:
   ```python
   # Use scripts/generate_evidence_charts.py to:
   # - Create 6 evidence charts
   # - Add annotations and highlights
   # - Export as PNG files
   ```

4. **Build Root Cause Chain**:
   ```python
   # Use scripts/root_cause_analysis.py to:
   # - Evaluate hypotheses
   # - Build causal chain
   # - Generate timeline alignment
   ```

5. **Generate Reports**:
   ```python
   # Use scripts/generate_report.py to:
   # - Create markdown reports
   # - Generate Mermaid diagrams
   # - Build evidence index
   ```

## Example Analysis Flow

**Scenario**: 685 HTTP 504 Gateway Timeout errors at 07:00:00

1. **Data Collection**: Load metrics for 06:30-07:30 window
2. **Anomaly Detection**: Calculate scores, find highest = Ctlgo-Center memory (2316.86)
3. **Timeline Analysis**: 
   - 06:55:00 - Memory pressure (root trigger)
   - 06:55:00 - Cut phase spike (first cascade)
   - 06:56:00 - Detection spike (second cascade)
   - 07:00:00 - Timeout incident
4. **Hypothesis**: Ctlgo-Center memory pressure → Backpressure → Resource starvation
5. **Evidence**: Throughput stable, extreme long-tail latency, temporal causality confirmed
6. **Conclusion**: Root cause = Ctlgo-Center memory pressure triggering cascading resource starvation

## Scripts Reference

- `scripts/analyze_metrics.py`: Anomaly detection and scoring
- `scripts/generate_evidence_charts.py`: Visualization generation
- `scripts/root_cause_analysis.py`: Hypothesis evaluation and chain building
- `scripts/generate_report.py`: Report generation with Mermaid diagrams

## References

See `references/` directory for:
- `analysis_methodology.md`: Detailed methodology
- `hypothesis_patterns.md`: Common failure patterns
- `visualization_templates.md`: Chart templates and styles

