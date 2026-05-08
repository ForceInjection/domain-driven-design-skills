---
name: incident-log-analyzer
description: Analyze incident logs, extract error patterns, identify root causes, generate insights and metrics. Use when user mentions logs, incidents, errors, failures, debugging, troubleshooting, log analysis, or investigating production issues.
allowed-tools: Read, Grep, Glob, RunCommand
---

# Incident Log Analyzer

Analyze logs to identify patterns, extract errors, and generate actionable insights for incident response.

## Instructions

1. **Discovery Phase**
   - Locate log files using Glob tool
   - Identify log format (JSON, plain text, structured)
   - Determine time range of incident

2. **Analysis Phase**
   - Run [scripts/parse_logs.py](scripts/parse_logs.py) to extract structured data
   - Use [scripts/pattern_detector.py](scripts/pattern_detector.py) to find error patterns
   - Identify:
     - Error frequency and distribution
     - Affected components/services
     - Timeline of events
     - Potential root causes

3. **Report Phase**
   - Generate incident summary with key metrics
   - Provide timeline visualization
   - List top errors with context
   - Suggest next investigation steps

## Usage Examples

### Example 1: Analyze application logs
```
User: "Analyze the logs in /var/logs/app/ for errors in the last hour"

Claude executes:
1. python scripts/parse_logs.py /var/logs/app/ --since "1 hour ago"
2. python scripts/pattern_detector.py --input parsed_logs.json
3. Generates report with findings
```

### Example 2: Root cause analysis
```
User: "Why did the API start failing at 3 PM?"

Claude executes:
1. Filters logs around 3 PM
2. Identifies spike in 500 errors
3. Traces error source to database connection pool exhaustion
4. Provides evidence and recommendations
```

### Example 3: Multi-service correlation
```
User: "Check if the frontend errors are related to backend issues"

Claude:
1. Analyzes frontend logs
2. Analyzes backend logs
3. Correlates timestamps and error patterns
4. Maps frontend errors to backend failures
```

## Scripts

### parse_logs.py
Parses log files and extracts structured data.

**Usage**:
```bash
python scripts/parse_logs.py <log_directory> [options]

Options:
  --format json|text|auto     Log format (default: auto)
  --since "time"              Start time (e.g., "1 hour ago", "2024-01-01")
  --until "time"              End time
  --level error|warn|info     Filter by log level
  --output FILE               Output file (default: parsed_logs.json)
```

**Output**: JSON file with structured log entries

### pattern_detector.py
Detects patterns, clusters similar errors, generates statistics.

**Usage**:
```bash
python scripts/pattern_detector.py [options]

Options:
  --input FILE                Input JSON from parse_logs.py
  --threshold N               Minimum occurrences to report (default: 5)
  --output FILE               Output report file
```

**Output**: JSON report with error patterns and statistics

### timeline_visualizer.py
Generates ASCII timeline visualization of incidents.

**Usage**:
```bash
python scripts/timeline_visualizer.py --input parsed_logs.json
```

**Output**: ASCII chart showing error frequency over time

## Report Format

```markdown
# Incident Log Analysis Report
**Analysis Period**: 2024-01-01 14:00 - 15:00
**Logs Analyzed**: 45,234 entries
**Errors Found**: 1,247

## Summary
Critical errors detected in payment service causing cascade failures
across dependent services.

## Timeline
```
14:05 ████░░░░░░░░  First errors appear (DB connection)
14:15 ████████████  Error spike (payment service)
14:30 ████████░░░░  Partial recovery
14:45 ██░░░░░░░░░░  Normal operation resumed
```

## Top Errors
1. **DatabaseConnectionError** (423 occurrences)
   - First seen: 14:05:23
   - Last seen: 14:32:15
   - Affected: payment-service, order-service
   - Pattern: Connection pool exhausted

2. **PaymentTimeoutException** (312 occurrences)
   - First seen: 14:08:45
   - Last seen: 14:28:33
   - Affected: payment-service
   - Pattern: Downstream service timeout

## Root Cause Analysis
**Primary**: Database connection pool exhausted
**Contributing factors**:
- Sudden traffic spike (3x normal)
- Connection timeout too high (30s)
- No connection pooling limits

## Recommendations
1. Increase connection pool size
2. Reduce connection timeout to 5s
3. Implement circuit breaker
4. Add connection pool monitoring

## Evidence
```
[14:05:23] ERROR [payment-service] DatabaseConnectionError: 
  Cannot get connection from pool (exhausted)
  at ConnectionPool.getConnection()
  
[14:08:45] ERROR [payment-service] PaymentTimeoutException:
  Timeout waiting for payment processor response
  at PaymentGateway.processPayment()
```
```

## Advanced Features

### Correlation Analysis
The analyzer can correlate errors across multiple services by:
- Matching request IDs across logs
- Analyzing temporal proximity
- Identifying cascade failures

### Anomaly Detection
Detects unusual patterns:
- Sudden error rate changes
- New error types
- Missing expected log entries
- Irregular timing patterns

### Metrics Extraction
Automatically extracts:
- Error rate (errors/minute)
- Mean time between failures (MTBF)
- Error distribution by severity
- Service availability percentage

## Integration with Subagents

This Skill can delegate to:
- **log-slicer** subagent: For detailed log segmentation
- **sre-incident-scribe** style: For incident documentation

## Best Practices

1. **Always specify time range**: Reduces noise and speeds analysis
2. **Check multiple log sources**: Single source may not show full picture
3. **Look for patterns, not just errors**: Warnings often precede failures
4. **Correlate with deployments**: Check if errors started after deploy
5. **Preserve evidence**: Copy relevant log sections for postmortem

## Dependencies

Scripts require Python 3.8+ with:
```bash
pip install python-dateutil pandas numpy
```

For JSON logs: `jq` command-line tool (optional, improves performance)
