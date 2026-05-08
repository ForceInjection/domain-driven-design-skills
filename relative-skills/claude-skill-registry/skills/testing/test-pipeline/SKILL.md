---
name: test-pipeline
description: Run pytest test suite for the video processing pipeline with coverage analysis. Use when the user wants to run tests, check test coverage, validate code quality, or verify pipeline functionality.
---

# Test Pipeline Skill

Run the comprehensive test suite for the VideoChunking project.

## What This Skill Does

Executes the test suite and provides detailed feedback on:
- Test coverage across all modules
- Passing/failing tests with detailed output
- Performance metrics and benchmarks
- Code quality issues and recommendations

## Test Execution Strategy

This skill will:
1. Check if pytest is installed and available
2. Run tests with appropriate markers and verbosity
3. Generate coverage reports showing tested vs untested code
4. Display test results clearly with context
5. Identify failing tests and suggest fixes
6. Recommend improvements for low-coverage areas

## Usage

When invoked, the skill can run:

### Full test suite with coverage
```bash
pytest --cov=src --cov-report=term --tb=short -v
```

### Specific test modules
```bash
pytest tests/test_diarization.py -v
```

### By test category
```bash
pytest -m "not slow"  # Skip slow tests
pytest -k "speaker"   # Only speaker-related tests
```

## Test Categories

The project has comprehensive tests for:

### Core Pipeline Components
- **Audio Processing**: `tests/test_audio_processor.py`
- **Transcription**: `tests/test_transcriber.py`
- **Speaker Diarization**: `tests/test_diarization.py`
- **IC/OOC Classification**: `tests/test_classifier.py`
- **Knowledge Extraction**: `tests/test_knowledge_extractor.py`

### Processing Logic
- **Chunking Logic**: `tests/test_chunker.py`
- **Formatting**: `tests/test_formatter.py`
- **Data Merging**: `tests/test_merger.py`

### Integration Tests
- **End-to-End Pipeline**: Full workflow validation
- **Real-Time Processing**: Live transcription and classification

### Configuration & Validation
- **Party Config**: `tests/test_party_config.py`
- **CLI Interface**: Command-line argument validation

## MCP Tool Integration

This skill can leverage the `mcp__videochunking-dev__analyze_test_coverage` and `mcp__videochunking-dev__run_specific_test` tools for enhanced test execution and reporting.

## Output

Provides:
- Test results summary (passed/failed/skipped/errors)
- Detailed failure messages with stack traces
- Code coverage percentage by module
- Uncovered lines and missing test cases
- Performance benchmarks for slow tests
- Actionable suggestions for fixing failures

## Interpreting Results

- **Green (PASSED)**: Test executed successfully
- **Red (FAILED)**: Assertion or logic error
- **Yellow (SKIPPED)**: Test conditionally skipped
- **Coverage < 80%**: Consider adding more tests
