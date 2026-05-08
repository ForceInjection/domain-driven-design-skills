---
description: Comprehensive debugging toolkit for complex issues - diagnosis, reproduction, log analysis, performance, and memory debugging
argument-hint: <operation> [parameters...]
model: inherit
---

# Debug Skill - Advanced Debugging Operations

You are routing requests to specialized debugging operations. Parse the `$ARGUMENTS` to determine which debugging operation to execute.

## Available Operations

- **diagnose** - Comprehensive diagnosis and root cause analysis across all stack layers
- **reproduce** - Create reliable reproduction strategies and test cases for issues
- **fix** - Implement targeted fixes with verification and prevention measures
- **analyze-logs** - Deep log analysis with pattern detection and timeline correlation
- **performance** - Performance debugging, profiling, and optimization
- **memory** - Memory leak detection, analysis, and optimization

## Routing Logic

Extract the first word from `$ARGUMENTS` as the operation name, and pass the remainder as operation parameters.

**Arguments received**: `$ARGUMENTS`

**Routing Instructions**:

1. **Parse the operation**: Extract the first word from `$ARGUMENTS`
2. **Load operation instructions**: Read the corresponding operation file from `.claude/commands/debug/`
3. **Execute with context**: Follow the operation's instructions with the remaining parameters
4. **Leverage agent**: All operations can leverage the 10x-fullstack-engineer agent for deep expertise

## Operation Routing

```
diagnose → Read and follow: .claude/commands/debug/diagnose.md
reproduce → Read and follow: .claude/commands/debug/reproduce.md
fix → Read and follow: .claude/commands/debug/fix.md
analyze-logs → Read and follow: .claude/commands/debug/analyze-logs.md
performance → Read and follow: .claude/commands/debug/performance.md
memory → Read and follow: .claude/commands/debug/memory.md
```

## Base Directory

All operation files are located at: `.claude/commands/debug/`

## Error Handling

If no operation is specified or the operation is not recognized:

**Available debugging operations**:
- `/debug diagnose issue:"..." [environment:"..."] [logs:"..."]` - Comprehensive diagnosis
- `/debug reproduce issue:"..." [environment:"..."] [data:"..."]` - Create reproduction strategy
- `/debug fix issue:"..." root_cause:"..." [verification:"..."]` - Implement targeted fix
- `/debug analyze-logs path:"..." [pattern:"..."] [timeframe:"..."]` - Deep log analysis
- `/debug performance component:"..." [metric:"..."] [threshold:"..."]` - Performance debugging
- `/debug memory component:"..." [symptom:"..."] [duration:"..."]` - Memory debugging

**Example usage**:
```
/debug diagnose issue:"Users getting 500 errors on file upload" environment:"production" logs:"logs/app.log"
/debug reproduce issue:"Payment webhook fails intermittently" environment:"staging" data:"sample-webhook-payload.json"
/debug fix issue:"Race condition in order processing" root_cause:"Missing transaction lock" verification:"run-integration-tests"
/debug analyze-logs path:"logs/application.log" pattern:"ERROR.*timeout" timeframe:"last-24h"
/debug performance component:"api-endpoint:/orders" metric:"response-time" threshold:"200ms"
/debug memory component:"background-worker" symptom:"growing-heap" duration:"6h"
```

Please specify an operation and provide the necessary parameters.

## Integration with 10x-fullstack-engineer Agent

All debugging operations are designed to work seamlessly with the 10x-fullstack-engineer agent, which provides:
- Cross-stack debugging expertise
- Systematic root cause analysis
- Production-grade debugging strategies
- Performance and security awareness
- Prevention-focused mindset

## Execution

Based on the parsed operation from `$ARGUMENTS`, read the appropriate operation file and follow its instructions with the remaining parameters.
