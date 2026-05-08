---
skill_name: notebook-tester
description: Validates Jupyter notebook execution, outputs, and educational quality metrics
version: 1.0.0
author: Educational Notebook System
tags: [testing, validation, jupyter, quality-assurance, automation]
activation_keywords: [test notebook, validate notebook, check execution, verify notebook, notebook quality]
dependencies: [jupyter, nbconvert, pytest]
---

# Notebook Tester Skill

## Purpose

This skill provides comprehensive testing and validation capabilities for educational Jupyter notebooks, ensuring they execute correctly, produce expected outputs, and meet quality standards.

## When to Use This Skill

Activate this skill when you need to:
- Validate that notebooks execute without errors
- Check notebook outputs and results
- Measure educational quality metrics
- Test notebooks across different environments
- Verify notebooks meet quality standards
- Automate notebook testing in CI/CD pipelines

## Testing Levels

### Level 1: Smoke Test (Quick Validation)
**Purpose**: Fast check that notebook doesn't crash
**Time**: 1-2 minutes
**Command**:
```bash
jupyter nbconvert --to notebook --execute notebook.ipynb \
    --output tested.ipynb \
    --ExecutePreprocessor.timeout=300
```

**Pass criteria**: No exceptions raised

### Level 2: Execution Test (Standard)
**Purpose**: Verify complete execution with logging
**Time**: 3-5 minutes
**Command**:
```bash
jupyter nbconvert --to notebook --execute notebook.ipynb \
    --output tested.ipynb \
    --ExecutePreprocessor.timeout=600 \
    --log-level=INFO
```

**Pass criteria**:
- All cells execute
- No CellExecutionError
- Reasonable execution time

### Level 3: Quality Test (Comprehensive)
**Purpose**: Check educational quality metrics
**Time**: 5-10 minutes
**Tool**: Custom quality checker (see scripts/)

**Pass criteria**:
- Markdown ratio ≥ 30%
- Exercise count ≥ 3
- Learning objectives present
- Prerequisites documented

## Validation Scripts

### Basic Execution Validator

Located in `scripts/validate_execution.py`:

```python
#!/usr/bin/env python
"""
Basic notebook execution validator.
Returns exit code 0 for success, 1 for failure.
"""
import sys
import subprocess
import json
from pathlib import Path

def validate_notebook(notebook_path, timeout=600):
    """Execute notebook and check for errors"""
    output_path = Path(notebook_path).with_suffix('.tested.ipynb')

    # Execute notebook
    cmd = [
        'jupyter', 'nbconvert',
        '--to', 'notebook',
        '--execute', str(notebook_path),
        '--output', str(output_path),
        f'--ExecutePreprocessor.timeout={timeout}'
    ]

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            check=True
        )
        print(f"✅ PASS: {notebook_path}")

        # Check for errors in output cells
        with open(output_path, 'r', encoding='utf-8') as f:
            nb = json.load(f)

        errors = []
        for i, cell in enumerate(nb['cells']):
            if cell['cell_type'] == 'code':
                for output in cell.get('outputs', []):
                    if output.get('output_type') == 'error':
                        errors.append({
                            'cell': i,
                            'error': output.get('ename'),
                            'message': output.get('evalue')
                        })

        if errors:
            print(f"⚠️  Errors found in outputs:")
            for err in errors:
                print(f"  Cell {err['cell']}: {err['error']} - {err['message']}")
            return False

        return True

    except subprocess.CalledProcessError as e:
        print(f"❌ FAIL: {notebook_path}")
        print(f"Error: {e.stderr}")
        return False

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python validate_execution.py <notebook.ipynb>")
        sys.exit(1)

    notebook = sys.argv[1]
    timeout = int(sys.argv[2]) if len(sys.argv) > 2 else 600

    success = validate_notebook(notebook, timeout)
    sys.exit(0 if success else 1)
```

### Quality Metrics Calculator

Located in `scripts/calculate_quality.py`:

```python
#!/usr/bin/env python
"""
Calculate educational quality metrics for notebooks.
"""
import json
import sys
from pathlib import Path

def calculate_metrics(notebook_path):
    """Calculate notebook quality metrics"""
    with open(notebook_path, 'r', encoding='utf-8') as f:
        nb = json.load(f)

    cells = nb['cells']
    markdown_cells = [c for c in cells if c['cell_type'] == 'markdown']
    code_cells = [c for c in cells if c['cell_type'] == 'code']

    # Calculate character counts
    markdown_chars = sum(
        len(''.join(c['source']))
        for c in markdown_cells
    )
    code_chars = sum(
        len(''.join(c['source']))
        for c in code_cells
    )

    total_chars = markdown_chars + code_chars
    markdown_ratio = markdown_chars / total_chars if total_chars > 0 else 0

    # Count exercises
    exercise_keywords = ['exercise', 'task', 'todo', 'try it', 'your turn', 'practice']
    exercises = sum(
        1 for c in markdown_cells
        if any(keyword in ''.join(c['source']).lower()
              for keyword in exercise_keywords)
    )

    # Check for learning objectives
    has_objectives = any(
        'learning objective' in ''.join(c['source']).lower()
        for c in markdown_cells
    )

    # Check for prerequisites
    has_prerequisites = any(
        'prerequisite' in ''.join(c['source']).lower()
        for c in markdown_cells
    )

    # Calculate average cell length
    avg_cell_length = total_chars / len(cells) if cells else 0

    metrics = {
        'total_cells': len(cells),
        'markdown_cells': len(markdown_cells),
        'code_cells': len(code_cells),
        'markdown_ratio': round(markdown_ratio, 3),
        'exercises_count': exercises,
        'has_learning_objectives': has_objectives,
        'has_prerequisites': has_prerequisites,
        'avg_cell_length': round(avg_cell_length, 1)
    }

    return metrics

def check_quality_gates(metrics):
    """Check if metrics meet minimum standards"""
    issues = []

    if metrics['markdown_ratio'] < 0.30:
        issues.append(
            f"Markdown ratio {metrics['markdown_ratio']:.1%} below 30% target"
        )

    if metrics['exercises_count'] < 3:
        issues.append(
            f"Only {metrics['exercises_count']} exercises found (target: ≥3)"
        )

    if not metrics['has_learning_objectives']:
        issues.append("Learning objectives not found")

    if not metrics['has_prerequisites']:
        issues.append("Prerequisites not documented")

    return issues

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python calculate_quality.py <notebook.ipynb>")
        sys.exit(1)

    notebook = sys.argv[1]
    metrics = calculate_metrics(notebook)

    print(f"\n📊 Quality Metrics for {Path(notebook).name}")
    print("=" * 50)
    print(f"Total cells: {metrics['total_cells']}")
    print(f"Markdown cells: {metrics['markdown_cells']}")
    print(f"Code cells: {metrics['code_cells']}")
    print(f"Markdown ratio: {metrics['markdown_ratio']:.1%} (target: ≥30%)")
    print(f"Exercises: {metrics['exercises_count']} (target: ≥3)")
    print(f"Learning objectives: {'✅' if metrics['has_learning_objectives'] else '❌'}")
    print(f"Prerequisites: {'✅' if metrics['has_prerequisites'] else '❌'}")
    print(f"Avg cell length: {metrics['avg_cell_length']:.0f} chars")

    issues = check_quality_gates(metrics)
    if issues:
        print(f"\n⚠️  Quality Issues Found:")
        for issue in issues:
            print(f"  - {issue}")
        sys.exit(1)
    else:
        print(f"\n✅ All quality gates passed!")
        sys.exit(0)
```

## Test Report Format

### Standard Test Report Template

```markdown
# Test Report: {Notebook Name}

**Date**: {timestamp}
**Status**: ✅ PASS / ❌ FAIL / ⚠️ WARNING
**Execution Time**: {duration} seconds

## Execution Results
- Total Cells: {count}
- Code Cells: {count}
- Cells Executed: {count}
- Cells with Errors: {count}

## Quality Metrics
- Markdown Ratio: {percentage}% (Target: ≥30%)
- Exercise Count: {count} (Target: ≥3)
- Learning Objectives: {present/missing}
- Prerequisites: {present/missing}
- Average Cell Length: {chars} characters

## Issues Found

### Critical Issues (🔴)
{List of blocking issues}

### Warnings (🟡)
{List of non-blocking issues}

## Recommendations
{Specific suggestions for improvement}

## Test Environment
- Python Version: {version}
- Jupyter Version: {version}
- Key Libraries: {versions}
```

## Common Issues and Solutions

### Issue: Import Errors
**Symptom**: `ModuleNotFoundError`
**Check**:
```bash
pip list | grep {module_name}
```
**Fix**: Add to requirements.txt and reinstall

### Issue: File Not Found
**Symptom**: `FileNotFoundError`
**Check**: Verify relative paths and data file existence
**Fix**:
- Use paths relative to notebook location
- Add data validation cells
- Document data requirements clearly

### Issue: Timeout
**Symptom**: `TimeoutError: Cell execution timed out`
**Check**: Identify slow cells
**Fix**:
- Increase timeout for compute-intensive notebooks
- Use data sampling for demonstrations
- Add progress indicators

### Issue: Memory Error
**Symptom**: `MemoryError` or kernel crash
**Check**: Dataset sizes and memory usage
**Fix**:
- Use smaller sample datasets
- Add cleanup cells (`del` + `gc.collect()`)
- Process data in chunks

### Issue: Inconsistent Outputs
**Symptom**: Outputs vary between runs
**Check**: Random operations without seeds
**Fix**:
- Set random seeds at notebook start
- Document expected output ranges
- Use output sanitization

### Issue: Visualization Not Displaying
**Symptom**: No plots in output
**Check**: Backend configuration
**Fix**:
```python
%matplotlib inline
import matplotlib.pyplot as plt
plt.show()  # Explicitly show
```

## Automated Testing with pytest

### pytest Integration

Create `conftest.py`:
```python
import pytest
from pathlib import Path

@pytest.fixture
def notebooks_dir():
    """Return path to notebooks directory"""
    return Path("notebooks")

@pytest.fixture
def sample_data_dir():
    """Return path to sample data directory"""
    return Path("data/sample")

@pytest.fixture(params=["beginner", "intermediate", "advanced"])
def difficulty_level(request):
    """Parameterize tests across difficulty levels"""
    return request.param
```

Create `tests/test_notebooks.py`:
```python
import pytest
import subprocess
from pathlib import Path

def test_notebook_executes(notebook_path):
    """Test that notebook executes without errors"""
    cmd = [
        'jupyter', 'nbconvert',
        '--to', 'notebook',
        '--execute', str(notebook_path),
        '--output', '/tmp/test.ipynb',
        '--ExecutePreprocessor.timeout=600'
    ]
    result = subprocess.run(cmd, capture_output=True)
    assert result.returncode == 0, f"Notebook failed: {result.stderr}"

def test_quality_metrics(notebook_path):
    """Test notebook meets quality standards"""
    from scripts.calculate_quality import calculate_metrics, check_quality_gates

    metrics = calculate_metrics(notebook_path)
    issues = check_quality_gates(metrics)

    assert len(issues) == 0, f"Quality issues: {issues}"

# Run with: pytest tests/
```

## CI/CD Integration

### GitHub Actions Workflow

Create `.github/workflows/test-notebooks.yml`:
```yaml
name: Test Notebooks

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ['3.9', '3.10', '3.11']

    steps:
    - uses: actions/checkout@v3

    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}

    - name: Install dependencies
      run: |
        pip install -r requirements.txt
        pip install pytest nbconvert

    - name: Test notebook execution
      run: |
        python .claude/skills/notebook-tester/scripts/validate_execution.py notebooks/*.ipynb

    - name: Check quality metrics
      run: |
        python .claude/skills/notebook-tester/scripts/calculate_quality.py notebooks/*.ipynb
```

## Best Practices

### Before Testing
- [ ] Ensure clean kernel state (restart kernel)
- [ ] Verify all data files are available
- [ ] Check all dependencies are installed
- [ ] Review notebook for obvious issues

### During Testing
- [ ] Run with logging enabled
- [ ] Monitor memory usage
- [ ] Track execution time per cell
- [ ] Capture stdout/stderr

### After Testing
- [ ] Document any failures with details
- [ ] Provide actionable feedback
- [ ] Re-test after fixes applied
- [ ] Archive test reports

## Using This Skill

When this skill is activated, you can:

1. **Run validation scripts** from `scripts/` directory
2. **Generate test reports** in standardized format
3. **Check quality metrics** against defined standards
4. **Integrate with CI/CD** using provided workflows
5. **Diagnose issues** using common solutions guide

## Success Criteria

A well-tested notebook:
- ✅ Executes completely without errors
- ✅ Produces expected outputs
- ✅ Meets quality metrics (≥30% markdown, ≥3 exercises)
- ✅ Has learning objectives and prerequisites
- ✅ Runs within reasonable time (<5 min typically)
- ✅ Works across Python versions
- ✅ Passes all automated checks
- ✅ Can be reproduced reliably

## Quick Reference

```bash
# Basic execution test
jupyter nbconvert --to notebook --execute notebook.ipynb \
    --output tested.ipynb --ExecutePreprocessor.timeout=600

# Quality metrics
python .claude/skills/notebook-tester/scripts/calculate_quality.py notebook.ipynb

# Full validation
python .claude/skills/notebook-tester/scripts/validate_execution.py notebook.ipynb

# pytest integration
pytest tests/test_notebooks.py -v

# Test all notebooks in directory
for nb in notebooks/*.ipynb; do
    python .claude/skills/notebook-tester/scripts/validate_execution.py "$nb"
done
```
