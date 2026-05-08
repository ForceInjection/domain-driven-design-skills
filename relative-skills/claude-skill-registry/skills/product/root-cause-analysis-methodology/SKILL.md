---
name: Root Cause Analysis Methodology
description: This skill should be used when the user asks to "perform root cause analysis", "investigate production issue", "analyze incident", "find root cause", "debug production error", "trace the cause", or mentions investigating production problems, alerts, or outages. Provides systematic RCA methodology and investigation workflows.
version: 0.1.0
---

# Root Cause Analysis Methodology

## Overview

Root cause analysis (RCA) is a systematic investigation process to identify the underlying cause of production incidents, errors, and outages. This skill provides structured methodologies for conducting effective RCA that goes beyond surface-level symptoms to find actionable root causes.

## When to Use This Skill

Apply this skill when:
- Production alerts fire indicating system degradation
- Users report errors or unexpected behavior
- Incidents occur requiring post-mortem investigation
- Metrics show anomalous patterns
- Any situation requiring systematic debugging of production issues

## Core RCA Principles

### 1. Timeline Reconstruction

Establish a clear timeline of events:
- Identify when the issue first appeared (error logs, metrics, user reports)
- Note when alerts fired or detection occurred
- Map recent changes (deployments, configuration changes, infrastructure changes)
- Identify when the issue resolved (if applicable)

Create a visual timeline connecting:
- **WHEN**: Timestamps of key events
- **WHAT**: What changed or broke at each point
- **WHERE**: Which systems, services, or components were affected

### 2. Symptom vs. Root Cause

Distinguish between symptoms and root causes:

**Symptoms** are observable effects:
- "API returning 500 errors"
- "Database queries timing out"
- "Memory usage at 95%"

**Root causes** are underlying reasons:
- "Connection pool exhausted due to size reduction in deployment"
- "Missing database index causing full table scans"
- "Memory leak introduced in commit abc123"

Always trace from symptoms to root causes by asking "why?" repeatedly.

### 3. The Five Whys Technique

Ask "why?" five times to drill down from symptom to root cause:

**Example:**
1. **Why** are users seeing errors? → API is returning 500s
2. **Why** is API returning 500s? → Database queries are timing out
3. **Why** are queries timing out? → Connection pool is exhausted
4. **Why** is connection pool exhausted? → Pool size was reduced from 100 to 10
5. **Why** was pool size reduced? → Deployment of commit abc123 changed configuration

Root cause: Configuration change in commit abc123 reduced pool size inappropriately.

### 4. Data-Driven Investigation

Base conclusions on evidence:
- **Metrics**: Error rates, latency percentiles, resource utilization
- **Logs**: Error messages, stack traces, debug output
- **Code**: Recent commits, blame information, diff analysis
- **Configuration**: Recent changes to config files, environment variables
- **Infrastructure**: Deployment logs, scaling events, resource changes

Avoid speculation—validate hypotheses with data.

## RCA Investigation Workflow

### Step 1: Gather Initial Information

Collect the triggering incident data:
- Alert details (name, severity, time, affected systems)
- Error messages and stack traces
- Relevant metrics (error rates, latency, resource usage)
- User reports or issue descriptions

### Step 2: Establish Scope and Impact

Determine:
- **Scope**: Which services, endpoints, or features are affected?
- **Severity**: How many users impacted? Revenue impact?
- **Duration**: When did it start? Is it ongoing?
- **Frequency**: One-time or recurring issue?

### Step 3: Build Timeline of Events

Construct chronological timeline:
1. Query metrics to find when anomaly started
2. Identify recent deployments or changes before incident
3. Note when alerts fired
4. Map any correlated events (scaling, traffic spikes, dependency failures)

### Step 4: Search Codebase for Related Code

Identify relevant code:
- Search for error messages in logs
- Find files/functions mentioned in stack traces
- Locate services or components mentioned in alerts
- Use grep to find error-handling code, API endpoints, database queries

Focus on:
- Entry points (API endpoints, event handlers)
- Data access layer (database queries, cache operations)
- External integrations (third-party APIs, message queues)

### Step 5: Analyze Recent Changes

Use git to find recent changes to relevant code:
- **git log**: Recent commits to affected files
- **git blame**: Who changed specific lines and when
- **git diff**: What changed between working and broken versions
- **git bisect**: Binary search to find breaking commit (for regressions)

Prioritize commits made shortly before incident started.

### Step 6: Correlate Changes with Timeline

Connect code changes to incident timeline:
- Did deployment coincide with error spike?
- Was configuration changed near incident start?
- Did dependency update introduce regression?

Look for temporal correlation between changes and symptoms.

### Step 7: Identify Root Cause

Synthesize findings to pinpoint root cause:
- What specific code, configuration, or infrastructure change caused symptoms?
- Why did this change cause the problem?
- What assumption or validation was missing?

Ensure root cause is:
- **Specific**: Not "the code is buggy" but "missing null check in function X"
- **Actionable**: Can be fixed with specific changes
- **Validated**: Supported by evidence (metrics, logs, code)

### Step 8: Verify Root Cause Hypothesis

Validate the identified root cause:
- Confirm timeline alignment (change introduced before symptoms appeared)
- Check if reverting change would resolve issue
- Look for similar patterns in logs or metrics
- Test hypothesis in staging environment if possible

### Step 9: Document Findings

Create RCA report including:
- **Summary**: One-paragraph overview of incident and root cause
- **Timeline**: Chronological event sequence
- **Root Cause**: Specific code/config change that caused issue
- **Impact**: Scope, severity, duration, affected users
- **Evidence**: Metrics, logs, commits supporting conclusion
- **Suggested Fix**: How to resolve and prevent recurrence

See `examples/rca-report-template.md` for report structure.

## Investigation Techniques

### Searching for Error Patterns

When analyzing error messages:
1. Extract key terms from error message (excluding variable values)
2. Search codebase for error string
3. Find where error is raised or logged
4. Trace backwards to identify trigger conditions

**Example:**
Error: `ConnectionPoolExhausted: Could not acquire connection within timeout`

Search for: `ConnectionPoolExhausted` or `Could not acquire connection`
Find: Connection pool configuration and usage
Trace: Recent changes to pool size or connection usage patterns

### Using Git Blame Effectively

Git blame identifies when lines were last changed:
```bash
git blame path/to/file.js
```

Focus on:
- Lines mentioned in stack traces
- Configuration values that seem incorrect
- Error-handling code paths
- Recently changed lines (within incident timeframe)

Cross-reference blame timestamps with incident timeline.

### Analyzing Metrics Patterns

Look for metric patterns indicating root cause:
- **Sudden spike**: Deployment, configuration change, traffic surge
- **Gradual increase**: Memory leak, resource exhaustion, unbounded growth
- **Periodic pattern**: Cron job, scheduled task, batch process
- **Correlation**: Multiple metrics changing together (cause and effect)

Compare metrics before, during, and after incident.

### Dependency Analysis

Consider dependencies that could cause issues:
- Third-party API failures or slowdowns
- Database performance degradation
- Message queue backlogs
- Infrastructure resource constraints
- Network issues or DNS resolution failures

Check dependency health metrics and status pages.

## Common Root Cause Categories

### Code Changes
- New bugs introduced in recent commits
- Logic errors in conditionals or loops
- Missing error handling or validation
- Resource leaks (memory, connections, file handles)
- Race conditions or concurrency issues

### Configuration Changes
- Incorrect values (pool sizes, timeouts, limits)
- Missing required configuration
- Environment variable changes
- Feature flag toggles

### Infrastructure Changes
- Scaling events (too few or too many instances)
- Resource limits (CPU, memory, disk)
- Network configuration changes
- Load balancer settings

### Dependency Changes
- Library or framework version updates
- Third-party API changes or outages
- Database schema migrations
- Message queue or cache issues

### Data Issues
- Unexpected data volumes (traffic spikes)
- Malformed data triggering edge cases
- Data migration problems
- Schema changes breaking assumptions

## Best Practices

### Do:
- Start with evidence (metrics, logs, errors)
- Build clear timeline before theorizing
- Use Five Whys to drill down from symptoms
- Validate hypotheses with data
- Focus on specific, actionable root causes
- Document findings thoroughly

### Don't:
- Jump to conclusions without evidence
- Stop at symptoms ("database is slow" isn't a root cause)
- Blame individuals (focus on systems and processes)
- Ignore timeline correlations
- Leave findings undocumented

## Integration with Thufir Tools

This skill works in conjunction with:
- **prometheus-analysis skill**: Query and interpret Prometheus metrics
- **platform-integration skill**: Fetch GitHub/GitLab issues and commits
- **git-investigation skill**: Use git tools for detailed code analysis
- **RCA agent**: Autonomous investigation from alert to report

The RCA agent orchestrates these skills to perform end-to-end investigation.

## Additional Resources

### Reference Files

For detailed patterns and advanced techniques:
- **`references/rca-patterns.md`** - Common incident patterns and solutions
- **`references/investigation-checklist.md`** - Step-by-step investigation checklist

### Example Files

Working examples in `examples/`:
- **`rca-report-template.md`** - Standard RCA report format

## Quick Reference

**Five Whys**: Ask "why?" five times to find root cause
**Timeline**: Map when issue started, what changed, when detected
**Evidence**: Metrics + Logs + Code + Config changes
**Root Cause**: Specific, actionable, validated cause (not symptom)
**Report**: Summary, timeline, root cause, evidence, fix

---

Apply this systematic methodology to transform vague production issues into clear, actionable root causes supported by evidence.
