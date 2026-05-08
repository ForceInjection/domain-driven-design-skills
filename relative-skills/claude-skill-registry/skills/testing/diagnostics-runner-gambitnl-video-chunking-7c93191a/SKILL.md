---
name: diagnostics-runner
description: Run comprehensive system diagnostics including dependency checks, test suite execution, git status, and pipeline health verification. Use when troubleshooting issues, verifying system readiness, or preparing for a release.
---

# Diagnostics Runner Skill

Comprehensive system health checks and diagnostics for the VideoChunking project.

## What This Skill Does

This skill provides multi-level diagnostics to ensure system health:

1. **Dependency Verification**: Check all required packages and tools are installed
2. **System Health**: Verify FFmpeg, Ollama, and other components are functional
3. **Test Suite Execution**: Run pytest with coverage analysis
4. **Configuration Validation**: Check party configs, settings, and data files
5. **Git Status Review**: Report repository state and uncommitted changes
6. **Data Integrity**: Verify session data and knowledge base files
7. **Performance Benchmarks**: Test critical operations for performance issues
8. **Cleanup Recommendations**: Identify temporary files and optimization opportunities

## Diagnostic Levels

### Quick Check (30 seconds)
- FFmpeg availability
- Ollama status
- Critical dependencies
- Git branch and status

### Standard Check (2 minutes)
- All dependencies with versions
- System health (FFmpeg, Ollama, PyAnnote)
- Quick test run (no full suite)
- Configuration file validation
- Recent session data integrity

### Comprehensive Check (5-10 minutes)
- Full dependency audit
- Complete test suite with coverage
- All configuration validation
- All session data verification
- Performance benchmarks
- Disk space and resource analysis
- Detailed recommendations

## Usage

### Quick Diagnostics
User: "Check if the system is ready to process"
User: "Is everything working?"
User: "Quick health check"

### Standard Diagnostics
User: "Run diagnostics"
User: "Check system health"
User: "Verify the pipeline is healthy"

### Comprehensive Diagnostics
User: "Run full diagnostics"
User: "Complete system check before release"
User: "Thorough health check and tests"

## Command Reference

```bash
# Quick health check
python cli.py health

# MCP tool: Check pipeline health
# Via MCP: check_pipeline_health

# Run test suite
pytest --cov=src --cov-report=term

# MCP tool: Analyze test coverage
# Via MCP: analyze_test_coverage

# MCP tool: Run full diagnostics
# Via MCP: run_diagnostics_suite

# Validate specific configuration
python cli.py validate-config --party default

# MCP tool: Validate party config
# Via MCP: validate_party_config
```

## MCP Tool Integration

This skill orchestrates multiple MCP tools:

### check_pipeline_health
Returns:
```json
{
  "ffmpeg": true/false,
  "ollama": true/false,
  "ollama_models": "list of available models",
  "pyannote_models": true/false,
  "whisper": true/false,
  "dependencies": [
    {"package": "faster-whisper", "installed": true, "version": "1.2.0"},
    {"package": "pyannote.audio", "installed": true, "version": "4.0.1"},
    ...
  ]
}
```

### run_diagnostics_suite
Returns:
```json
{
  "timestamp": "2024-11-03T21:45:00",
  "python_version": "Python 3.10.6",
  "git_status": "modified files...",
  "test_status": "45 tests collected",
  "dependencies": "package status..."
}
```

### analyze_test_coverage
Runs full pytest with coverage and returns detailed report.

### validate_party_config
Validates party configuration files:
```json
{
  "configs": [
    {
      "file": "party_default.json",
      "valid": true,
      "player_count": 4,
      "character_count": 4,
      "errors": [],
      "warnings": []
    }
  ]
}
```

### list_available_models
Lists Ollama models for IC/OOC classification.

### list_processed_sessions
Shows recently processed sessions to verify data integrity.

## Diagnostic Components

### 1. Dependency Verification

Checks required Python packages:
```
✅ faster-whisper    v1.2.0
✅ pyannote.audio    v4.0.1
✅ gradio            v5.49.1
✅ torch             v2.9.0
✅ groq              v0.32.0
✅ click             v8.1.7
✅ rich              v13.7.0
❌ opencv-python     NOT INSTALLED
```

### 2. System Health

Verifies external tools:
```
FFmpeg:
  ✅ Installed: v6.0
  ✅ Accessible: f:/Repos/VideoChunking/ffmpeg/bin/ffmpeg.exe
  ✅ Features: Audio encoding, video encoding, filters

Ollama:
  ✅ Running: localhost:11434
  ✅ Models: mistral (active), llama3 (available)
  ✅ Response time: 124ms

PyAnnote:
  ✅ Models downloaded: yes
  ✅ Segmentation model: pyannote/segmentation
  ✅ Embedding model: pyannote/embedding
```

### 3. Test Suite Execution

Runs pytest and reports:
```
Test Results:
  ✅ Passed: 42
  ❌ Failed: 3
  ⚠️  Skipped: 2

Failed Tests:
  tests/test_classifier.py::test_ic_ooc_accuracy
  tests/test_diarization.py::test_speaker_count
  tests/test_knowledge_extractor.py::test_npc_extraction

Coverage: 78% (target: 80%)
  src/audio_processor.py:    95%
  src/transcriber.py:        92%
  src/classifier.py:         65% ⚠️ LOW
  src/knowledge_extractor.py: 58% ⚠️ LOW
```

### 4. Configuration Validation

Checks configuration files:
```
Party Configurations:
  ✅ party_default.json: Valid (4 players, 4 characters, 1 DM)
  ✅ party_oneshot.json: Valid (5 players, 5 characters, 1 DM)
  ❌ party_custom.json: INVALID - Missing 'dm' field

Settings:
  ✅ src/config.py: Valid
  ✅ .env.example: Valid
  ⚠️  .env: Not found (expected for production)
```

### 5. Git Status Review

Reports repository state:
```
Git Repository:
  Branch: main
  Ahead of remote: 3 commits
  Behind remote: 0 commits

Uncommitted Changes:
  Modified:   src/classifier.py
  Modified:   tests/test_classifier.py
  Untracked:  temp_output/

Recommendations:
  ⚠️  Commit changes before processing new sessions
  ⚠️  Push commits to backup work
  ℹ️  .coverage file can be added to .gitignore
```

### 6. Data Integrity

Validates data files:
```
Campaign Knowledge:
  ✅ File exists: data/campaign_knowledge.json
  ✅ Valid JSON: yes
  ✅ Entity counts: 47 NPCs, 23 locations, 15 quests
  ✅ Last updated: 2024-11-02 18:45:23

Party Configurations:
  ✅ Files: 2 valid, 1 invalid
  ⚠️  party_custom.json has validation errors

Recent Sessions:
  ✅ session_010: Complete (all output files present)
  ✅ session_011: Complete (all output files present)
  ⚠️  session_012: Incomplete (missing knowledge extraction)

Recommendations:
  ⚠️  Re-run knowledge extraction for session_012
  ⚠️  Fix validation errors in party_custom.json
```

### 7. Performance Benchmarks

Tests critical operations:
```
Performance Benchmarks:
  Audio extraction (10s video):    1.2s ✅
  Transcription (1min audio):      8.4s ✅
  Diarization (1min audio):        12.1s ✅
  Classification (100 segments):   3.7s ✅
  Knowledge extraction:            5.2s ✅

Memory Usage:
  Idle: 450MB
  Transcription: 2.1GB ✅
  Diarization: 1.8GB ✅
  Peak: 2.8GB ✅ (within 16GB available)
```

### 8. Cleanup Recommendations

Identifies optimization opportunities:
```
Disk Space:
  Total: 512GB
  Used: 387GB
  Available: 125GB

Temporary Files:
  output/temp/: 2.3GB (45 files)
  .pytest_cache/: 12MB
  __pycache__/: 8MB

Recommendations:
  ℹ️  Clean temporary output files: rm -rf output/temp/
  ℹ️  Remove pytest cache: rm -rf .pytest_cache/
  ℹ️  Clear Python cache: find . -type d -name __pycache__ -exec rm -rf {} +
  ⚠️  Low disk space: Consider archiving old session outputs
```

## Output Formats

### Summary View (Default)
Concise overview suitable for quick checks:
```
System Health: ✅ HEALTHY
Dependencies: ✅ ALL INSTALLED
Tests: ⚠️  3 FAILED (42 passed, 78% coverage)
Configuration: ⚠️  1 INVALID (2 valid)
Data: ✅ INTACT
Git: ⚠️  UNCOMMITTED CHANGES

Action Required:
  1. Fix 3 failing tests
  2. Validate party_custom.json
  3. Commit pending changes
```

### Detailed View
Expanded report with specifics for each component.

### JSON Export
Machine-readable format:
```json
{
  "timestamp": "2024-11-03T21:45:00Z",
  "overall_health": "warning",
  "components": {
    "dependencies": {"status": "ok", "details": {...}},
    "system_health": {"status": "ok", "details": {...}},
    "tests": {"status": "warning", "failed": 3, "passed": 42},
    "configuration": {"status": "warning", "invalid": 1},
    "data": {"status": "ok", "details": {...}},
    "git": {"status": "warning", "uncommitted": 2}
  },
  "recommendations": [...]
}
```

## Automated Diagnostics

### Pre-Commit Hook
Run quick diagnostics before commits:
```bash
# .git/hooks/pre-commit
pytest tests/ --tb=short
python cli.py health --quick
```

### CI/CD Integration
Run comprehensive diagnostics in CI:
```yaml
# .github/workflows/diagnostics.yml
- name: Run diagnostics
  run: python cli.py diagnostics --comprehensive --json > report.json
```

### Scheduled Health Checks
Periodic system verification:
```bash
# Cron job or Windows Task Scheduler
0 9 * * * cd /path/to/project && python cli.py health --email-report
```

## Troubleshooting Guide

Based on diagnostic results:

### FFmpeg Not Found
```
Symptoms: ffmpeg=false in health check
Solutions:
  1. Install FFmpeg
  2. Add FFmpeg to system PATH
  3. Update config with FFmpeg path
  4. Run: ffmpeg -version to verify
```

### Ollama Not Running
```
Symptoms: ollama=false in health check
Solutions:
  1. Start Ollama: ollama serve
  2. Check port 11434 is available
  3. Verify model is pulled: ollama list
  4. Test: curl http://localhost:11434/api/tags
```

### Tests Failing
```
Symptoms: test_status shows failures
Solutions:
  1. Read failure messages carefully
  2. Run specific failed test: pytest tests/test_X.py -v
  3. Check if data dependencies exist
  4. Review recent code changes
  5. Update test fixtures if needed
```

### Low Coverage
```
Symptoms: coverage <80%
Solutions:
  1. Identify uncovered code: pytest --cov-report=html
  2. Open htmlcov/index.html in browser
  3. Write tests for uncovered functions
  4. Add edge case tests
```

### Invalid Configuration
```
Symptoms: Configuration validation errors
Solutions:
  1. Review error messages
  2. Compare with .json schema
  3. Check for missing required fields
  4. Verify JSON syntax is valid
  5. Use JSON validator tool
```

### Data Integrity Issues
```
Symptoms: Corrupt or missing session data
Solutions:
  1. Re-process affected sessions
  2. Restore from backups if available
  3. Manually correct JSON files
  4. Run data migration scripts
```

## Best Practices

1. **Regular Checks**: Run diagnostics weekly or before major processing batches
2. **Before Releases**: Always run comprehensive diagnostics before tagging releases
3. **After Updates**: Check system health after dependency updates
4. **Monitor Trends**: Track test coverage and performance over time
5. **Document Issues**: Log diagnostic results when reporting bugs
6. **Automate**: Set up pre-commit hooks and CI checks
7. **Review Recommendations**: Act on cleanup and optimization suggestions

## Integration with Other Skills

- **test-pipeline**: Focuses specifically on test execution and coverage
- **debug-ffmpeg**: Deep dive into FFmpeg-specific issues
- **party-validator**: Detailed party configuration validation
- **session-processor**: Use diagnostics before starting session processing
- **campaign-analyzer**: Verify knowledge base integrity

## Example Workflows

### Pre-Processing Workflow
```
User: "I'm about to process several new sessions. Is the system ready?"

Assistant uses diagnostics-runner:
1. Runs check_pipeline_health MCP tool
2. Validates party configurations
3. Checks recent session data integrity
4. Verifies sufficient disk space
5. Reviews git status for uncommitted changes
6. Reports: "System healthy, ready to process"
```

### Troubleshooting Workflow
```
User: "Session processing failed. Help me figure out why."

Assistant uses diagnostics-runner:
1. Runs comprehensive diagnostics
2. Identifies: Ollama not running
3. Provides solution: Start Ollama service
4. Verifies: Re-runs health check
5. Confirms: "Ollama now running, ready to retry"
```

### Release Preparation Workflow
```
User: "Preparing for v2.0 release. Run full diagnostics."

Assistant uses diagnostics-runner:
1. Runs comprehensive diagnostics
2. Executes full test suite with coverage
3. Validates all configurations
4. Checks git status
5. Generates JSON report
6. Provides release readiness assessment
```

## Advanced Features

### Custom Diagnostic Scripts
```python
# custom_diagnostics.py
from src.diagnostics import DiagnosticsRunner

runner = DiagnosticsRunner()
results = runner.run_all()

# Custom checks
if results['disk_space_gb'] < 50:
    print("WARNING: Low disk space")

# Send to monitoring system
send_to_datadog(results)
```

### Diagnostic Dashboard
Create a monitoring dashboard:
```bash
# Generate HTML report
python cli.py diagnostics --html > diagnostics.html

# Serve with Python
python -m http.server 8000
# Open: http://localhost:8000/diagnostics.html
```

### Integration with Monitoring
```python
# Export metrics
python cli.py diagnostics --prometheus > metrics.txt
# Scrape with Prometheus for alerting
```
