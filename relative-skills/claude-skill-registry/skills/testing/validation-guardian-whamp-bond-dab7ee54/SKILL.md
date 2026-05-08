---
name: validation-guardian
description: Prevent premature task completion by checking for parsing errors, execution failures, incomplete test results, and missing expected outputs. Acts as final quality gate before declaring tasks complete. Use proactively after major operations or when task success needs verification.
allowed-tools: Read, Execute, Grep
---

# Validation Guardian

Apex2's final validation tuning implemented as a Claude Code skill. Prevents false completion signals through thorough verification.

## Instructions

When invoked (typically after claiming task completion), perform comprehensive validation to ensure the task is actually done correctly:

### 1. Parsing and Syntax Validation
Check that all generated/modified code is syntactically correct:

**Python Code:**
```bash
# Syntax check all Python files
find . -name "*.py" -exec python -m py_compile {} \;
# or more comprehensively
python -c "
import ast, sys
for file in ['file1.py', 'file2.py']:
    try:
        with open(file) as f:
            ast.parse(f.read())
        print(f"✓ {file}: Syntax OK")
    except SyntaxError as e:
        print(f"✗ {file}: Syntax Error - {e}")
"
```

**JavaScript/TypeScript:**
```bash
# Check syntax
find . -name "*.js" -exec node -c {} \;
# With ESLint if available
npx eslint . --ext .js,.ts
```

**Configuration Files:**
```bash
# JSON syntax
python -c "import json; [json.load(open(f)) for f in ['config1.json', 'config2.json']]"

# YAML syntax
python -c "import yaml; [yaml.safe_load(open(f)) for f in ['config.yaml', 'config.yml']]"
```

### 2. Execution Error Detection
Check for runtime errors and failed processes:

**Log Analysis:**
```bash
# Look for error indicators in common log patterns
grep -R -i "error\|exception\|failed\|traceback" . --include="*.log" --include="*.txt"

# Check for recent error exits
find . -name "*.py" -exec python {} \; 2>&1 | grep -i error
```

**Process Status:**
```bash
# Check if services are running that should be
ps aux | grep -E "(node|python|java)" | grep -v grep

# Check for crashed processes
journalctl -u service-name --since "5 minutes ago" | grep -i error
```

### 3. Test Result Validation
Ensure tests actually passed, not just were run:

**Test Output Verification:**
```bash
# Python pytest
pytest --tb=short -q | grep -E "(passed|failed|error)"

# JavaScript Jest
npm test 2>&1 | grep -E "(Tests:|✓|✗)"

# Look for failed assertions
grep -R "assert.*fail" test_results/
```

**Coverage Reports:**
```bash
# Check coverage meets minimum standards
pytest --cov --cov-report=term-missing | grep -E "TOTAL|missing"
```

### 4. Expected Output Verification
Confirm that required outputs, files, or results actually exist and match expectations:

**File Existence and Content:**
```bash
# Check required files exist
for file in expected_output.txt results.csv report.html; do
    if [[ -f "$file" ]]; then
        echo "✓ $file exists ($(wc -c < "$file") bytes)"
    else
        echo "✗ $file missing"
    fi
done

# Check file content is not empty (real validation)
find . -name "*.json" -exec sh -c 'if [ -s "$1" ]; then echo "✓ $1 has content"; else echo "✗ $1 empty"; done' _ {} \;
```

**Database/Service Validation:**
```bash
# Check database table creation
mysql -u user -ppassword database -e "SHOW TABLES LIKE 'expected_table';"

# Verify API endpoints respond
curl -f -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health

# Check service health status
curl -s http://localhost:8080/health | jq -r '.status'
```

### 5. Integration and System Validation
Verify the solution works in the larger context:

**Integration Points:**
```bash
# Check that modified code doesn't break existing functionality
python -m pytest tests/integration/ -v

# Verify package dependencies resolve
pip check

# Check imports work
python -c "
try:
    import new_module, existing_module
    print('✓ All imports successful')
except ImportError as e:
    print(f'✗ Import failed: {e}')
"
```

**Performance Validation (when applicable):**
```bash
# Check response times are reasonable
time curl http://localhost:3000/api/endpoint

# Verify memory usage is acceptable
free -h | head -4

# Check disk space usage is reasonable
du -sh ./
```

### 6. Documentation and Metadata Validation
Ensure supporting documentation is updated and consistent:

**Documentation Consistency:**
```bash
# Check README reflects current state
grep -E "(TODO|FIXME|placeholder)" README.md || echo "✓ No obvious placeholders"

# Verify API docs match implementation
# (specific to your documentation system)
```

**Version and Build Info:**
```bash
# Check version numbers consistent
grep -r "version=" package.json config.json requirements.txt
```

## Validation Categories

### Software Development Tasks
- All files compile without syntax errors
- Tests pass with expected coverage
- Documentation is updated
- Integration tests pass
- No obvious performance regressions

### Data Processing Tasks
- Output files exist and have reasonable size
- Data format is valid (JSON, CSV, etc.)
- Row counts or record counts match expectations
- No obvious data corruption or truncation

### System Administration Tasks
- Services are running with correct configuration
- Configuration files are valid
- Permissions are correctly set
- Backup or rollback capabilities exist
- Related services still function

### Installation/Deployment Tasks
- Application runs successfully
- Health checks pass
- Required ports are accessible
- Dependent services are reachable
- Load balancer/proxy configuration works

## Validation Process

1. **Define Expected Success Criteria**
   - What should exist when task is complete?
   - What should happen when tested?
   - What should NOT happen (errors, failures)?

2. **Execute Validation Checks**
   - Run syntax and parsing checks
   - Verify outputs and files
   - Test functionality
   - Check system/health status

3. **Analyze Results**
   - Identify any failures or issues
   - Determine root causes
   - Categorize severity (blocking, warning, cosmetic)

4. **Report Findings**
   - Clear pass/fail status
   - Specific issues found
   - Recommended fixes
   - Overall quality assessment

## Output Format

Provide comprehensive validation report:

```
Validation Results:
  Overall Status: [PASS/FAIL/PARTIAL]
  Validations Run: [number]
  Issues Found: [number]

Syntax and Parsing:
  Python files: [status] - [details]
  Config files: [status] - [details]
  Other files: [status] - [details]

Execution Status:
  Tests: [pass/fail] - [summary]
  Services: [running/stopped]
  Processes: [healthy/unhealthy]

Expected Outputs:
  Files created: [count] / [expected]
  Content validation: [status]
  Format validation: [status]

System Integration:
  API endpoints: [status]
  Database access: [status]
  Dependencies: [status]

Issues Identified:
  Critical: [blocking issues]
  Warnings: [potential problems]
  Informational: [minor concerns]

Recommendations:
  Immediate: [actions to fix critical issues]
  Optional: [suggested improvements]
  Monitoring: [what to watch going forward]

Final Assessment:
  Task Complete: [YES/NO/CONDITIONAL]
  Confidence Level: [high/medium/low]
  Next Steps: [what happens next]
```

## When to Use

This validator should be invoked:
**After claiming task completion:**
- Always validate major code changes
- Verify installation/deployment success
- Confirm data processing completed correctly
- Check system administration changes

**Before declaring victory:**
- When dealing with complex, multi-step tasks
- When changes affect multiple components
- When success criteria are subjective
- When consequences of failure are significant

The goal is to build confidence that tasks are actually completed, not just appeared to complete. prevents false positives and ensures reliable deliverables.
