---
name: bash-executor
description: Execute bash commands and scripts safely with validation, error handling, and security checks. Use for system operations, file management, text processing, and command-line tools.
version: 1.0.0
author: Production Skills Team
plugin: my-first-plugin
tags: [bash, shell, linux, unix, scripting, cli]
---

# Bash Executor Skill

Execute bash commands and shell scripts safely with comprehensive error handling, security validation, and best practices.

> **Plugin**: my-first-plugin | **Version**: 1.0.0

## When to Use This Skill

Use this skill when the user needs to:
- Execute system commands and utilities
- Process text files (grep, sed, awk, cut, sort)
- Manage files and directories
- Run CLI tools (curl, wget, git, docker)
- Create shell scripts for automation
- Parse command output and logs
- Execute batch operations
- System administration tasks

## Core Capabilities

1. **Safe Command Execution**: Validates commands before running
2. **Error Handling**: Comprehensive exit code checking
3. **Security Validation**: Blocks dangerous patterns
4. **Dry-Run Mode**: Preview commands before execution
5. **Output Capture**: Structured stdout/stderr handling
6. **Timeout Protection**: Prevents hanging processes
7. **Script Generation**: Creates reusable bash scripts

## Execution Workflow

### Step 1: Understand the Task
Determine if bash is the right tool:
- ✅ System operations, file management
- ✅ Text processing with standard tools
- ✅ CLI tool orchestration
- ❌ Complex logic (use Python/Node.js)
- ❌ API calls (use Node.js/Python)

### Step 2: Validate Commands
Check for dangerous patterns:
```bash
bash scripts/validate_command.sh "<command>"
```

### Step 3: Execute Safely
Use the helper script:
```bash
bash scripts/execute_bash.sh "<command>" [timeout]
# OR for scripts:
bash scripts/execute_bash.sh <script-file> [timeout]
```

### Step 4: Handle Errors
Check exit codes and provide meaningful feedback:
- Exit 0: Success
- Exit 1-127: Command-specific errors
- Exit 124: Timeout
- Exit 126: Permission denied
- Exit 127: Command not found

## Security Guidelines

### CRITICAL: Always Block These Patterns

❌ **NEVER Allow**:
```bash
rm -rf /              # System destruction
dd if=/dev/zero       # Disk wiping
:(){ :|:& };:        # Fork bombs
chmod 777 /          # Permission destruction
curl | bash          # Arbitrary code execution
eval $user_input     # Code injection
mkfs.*               # Filesystem formatting
```

✅ **Safe Patterns**:
```bash
ls -la                        # Directory listing
grep "pattern" file.txt       # Text search
find . -name "*.log"          # File finding
tar -czf backup.tar.gz dir/   # Archiving
sed 's/old/new/g' file.txt   # Text replacement
```

### Command Validation Rules

1. **No Root Operations**: Reject commands requiring sudo/root
2. **Path Restrictions**: Operations only in current directory or subdirectories
3. **No Destructive Commands**: Block rm -rf, dd, mkfs without confirmation
4. **No Arbitrary Downloads**: Validate URLs before wget/curl
5. **No Process Killing**: Restrict kill, killall commands

## Error Handling Best Practices

### Always Check Exit Codes
```bash
#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures

if some_command; then
    echo "Success"
else
    echo "Failed with exit code: $?"
    exit 1
fi
```

### Use Trap for Cleanup
```bash
#!/bin/bash

cleanup() {
    echo "Cleaning up..."
    rm -f /tmp/tempfile
}

trap cleanup EXIT ERR

# Your commands here
```

### Validate Input
```bash
#!/bin/bash

FILE="${1:-}"

if [[ -z "$FILE" ]]; then
    echo "Error: File argument required" >&2
    exit 1
fi

if [[ ! -f "$FILE" ]]; then
    echo "Error: File not found: $FILE" >&2
    exit 1
fi
```

## Common Use Cases

### 1. File Management

**Create Directory Structure**:
```bash
mkdir -p project/{src,tests,docs,config}
echo "Created project structure"
```

**Find and Process Files**:
```bash
#!/bin/bash
# Find all .log files modified in last 7 days
find . -name "*.log" -mtime -7 -type f | while read -r file; do
    echo "Processing: $file"
    # Process each file
done
```

**Bulk Rename Files**:
```bash
#!/bin/bash
# Rename all .txt files to .md
for file in *.txt; do
    if [[ -f "$file" ]]; then
        mv "$file" "${file%.txt}.md"
        echo "Renamed: $file -> ${file%.txt}.md"
    fi
done
```

### 2. Text Processing

**Search and Extract**:
```bash
#!/bin/bash
# Extract email addresses from file
grep -Eo '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' input.txt | \
    sort -u > emails.txt
echo "Extracted $(wc -l < emails.txt) unique emails"
```

**CSV Processing**:
```bash
#!/bin/bash
# Extract specific columns from CSV
cut -d',' -f1,3,5 input.csv | \
    grep -v "^#" | \
    sort > output.csv
```

**Log Analysis**:
```bash
#!/bin/bash
# Count error types in log file
awk '/ERROR/ {print $5}' app.log | \
    sort | uniq -c | sort -rn
```

### 3. System Operations

**Disk Usage Analysis**:
```bash
#!/bin/bash
# Find largest directories
du -h --max-depth=1 2>/dev/null | \
    sort -hr | head -20
```

**Process Management**:
```bash
#!/bin/bash
# Check if process is running
if pgrep -f "myapp" > /dev/null; then
    echo "Process is running"
    pgrep -f "myapp" | xargs ps -p
else
    echo "Process is not running"
fi
```

**Archive and Compress**:
```bash
#!/bin/bash
# Create dated backup
DATE=$(date +%Y%m%d)
tar -czf "backup_${DATE}.tar.gz" \
    --exclude='node_modules' \
    --exclude='.git' \
    ./project/
echo "Backup created: backup_${DATE}.tar.gz"
```

### 4. Data Pipeline

**Download and Process**:
```bash
#!/bin/bash
set -euo pipefail

URL="https://example.com/data.json"
OUTPUT="processed_data.json"

# Download
curl -fsSL "$URL" -o raw_data.json

# Process with jq
jq '.items[] | select(.status == "active")' raw_data.json > "$OUTPUT"

echo "Processed data saved to $OUTPUT"
```

**Multi-Step Pipeline**:
```bash
#!/bin/bash
set -euo pipefail

# Step 1: Download
echo "Downloading data..."
wget -q https://example.com/data.csv -O data.csv

# Step 2: Clean
echo "Cleaning data..."
sed 's/\r$//' data.csv | # Remove carriage returns
    grep -v '^$' |        # Remove empty lines
    tr -s ' ' > cleaned.csv

# Step 3: Analyze
echo "Analyzing..."
awk -F',' '{sum+=$3} END {print "Total:", sum}' cleaned.csv

echo "Pipeline completed"
```

### 5. Git Operations

**Repository Setup**:
```bash
#!/bin/bash
set -euo pipefail

REPO_NAME="${1:-my-repo}"

mkdir -p "$REPO_NAME"
cd "$REPO_NAME"

git init
echo "# $REPO_NAME" > README.md
echo "node_modules/" > .gitignore
echo ".env" >> .gitignore

git add .
git commit -m "Initial commit"

echo "Repository initialized: $REPO_NAME"
```

**Branch Management**:
```bash
#!/bin/bash
# Create feature branch from main
git checkout main
git pull origin main
git checkout -b feature/new-feature
echo "Created and switched to feature/new-feature"
```

### 6. Docker Operations

**Container Management**:
```bash
#!/bin/bash
# Stop and remove all containers
docker ps -aq | xargs -r docker stop
docker ps -aq | xargs -r docker rm
echo "All containers stopped and removed"
```

**Image Cleanup**:
```bash
#!/bin/bash
# Remove dangling images
docker images -f "dangling=true" -q | xargs -r docker rmi
echo "Dangling images removed"
```

## Advanced Patterns

### Parallel Execution
```bash
#!/bin/bash
# Process files in parallel
find . -name "*.txt" -print0 | \
    xargs -0 -P 4 -I {} bash -c 'process_file "$@"' _ {}
```

### Progress Monitoring
```bash
#!/bin/bash
# Show progress for long operations
TOTAL=$(ls -1 *.txt | wc -l)
COUNT=0

for file in *.txt; do
    COUNT=$((COUNT + 1))
    echo "Processing $COUNT/$TOTAL: $file"
    # Process file
done
```

### Error Recovery
```bash
#!/bin/bash
# Retry on failure
MAX_RETRIES=3
RETRY_DELAY=5

for i in $(seq 1 $MAX_RETRIES); do
    if some_command; then
        echo "Success on attempt $i"
        break
    else
        echo "Failed attempt $i/$MAX_RETRIES"
        if [[ $i -lt $MAX_RETRIES ]]; then
            echo "Retrying in ${RETRY_DELAY}s..."
            sleep $RETRY_DELAY
        fi
    fi
done
```

## Helper Scripts Available

### Execute Command/Script
```bash
bash scripts/execute_bash.sh "<command>" [timeout]
bash scripts/execute_bash.sh script.sh [timeout]
```

### Validate Command
```bash
bash scripts/validate_command.sh "<command>"
```

### Generate Script Template
```bash
bash scripts/generate_script.sh script_name.sh "Description"
```

### Dry Run Mode
```bash
DRY_RUN=1 bash scripts/execute_bash.sh "<command>"
```

## Debugging Techniques

### Enable Verbose Mode
```bash
#!/bin/bash
set -x  # Print commands as they execute

# Your commands here

set +x  # Disable verbose mode
```

### Check Variables
```bash
#!/bin/bash
set -u  # Error on undefined variables

echo "DEBUG: Variable value: ${MY_VAR:-not set}"
```

### Trace Execution
```bash
bash -x script.sh  # Run with tracing
```

## Performance Optimization

### Use Built-in Commands
```bash
# Slow: external command
result=$(cat file.txt | grep pattern)

# Fast: built-in
result=$(grep pattern < file.txt)
```

### Avoid Unnecessary Pipes
```bash
# Slow
cat file.txt | grep pattern | wc -l

# Fast
grep -c pattern file.txt
```

### Use Parallel Processing
```bash
# Serial (slow)
for file in *.txt; do
    process "$file"
done

# Parallel (fast)
ls *.txt | xargs -P 4 -I {} process {}
```

## Environment Variables

### Common Variables
```bash
HOME        # User home directory
PATH        # Executable search path
USER        # Current username
PWD         # Present working directory
OLDPWD      # Previous directory
SHELL       # Current shell
```

### Set Variables Safely
```bash
#!/bin/bash
# Set with default
VAR="${VAR:-default_value}"

# Export for child processes
export API_KEY="secret"

# Unset after use
unset API_KEY
```

## Troubleshooting

### "Permission denied"
```bash
# Check permissions
ls -la script.sh

# Fix permissions
chmod +x script.sh
```

### "Command not found"
```bash
# Check if command exists
command -v mycommand

# Check PATH
echo $PATH

# Use full path
/usr/bin/mycommand
```

### "No such file or directory"
```bash
# Check file exists
[[ -f file.txt ]] && echo "Exists" || echo "Not found"

# Use absolute path
realpath file.txt
```

### Script Hangs
```bash
# Use timeout
timeout 30s ./script.sh

# Or in script
set -euo pipefail
```

## Best Practices Summary

1. ✅ Always use `set -euo pipefail` for safety
2. ✅ Quote variables: `"$variable"` not `$variable`
3. ✅ Check exit codes: `if command; then ...`
4. ✅ Use `[[ ]]` for conditions, not `[ ]`
5. ✅ Validate input before processing
6. ✅ Use meaningful variable names
7. ✅ Add comments for complex operations
8. ✅ Use trap for cleanup
9. ❌ Never use `eval` with user input
10. ❌ Avoid parsing `ls` output

## When NOT to Use This Skill

- Complex data structures (use Python/Node.js)
- API interactions (use Node.js/Python)
- Heavy calculations (use Python)
- Cross-platform scripts (use Python)
- GUI applications (use appropriate tools)

## References

For more complex bash operations:
- `scripts/execute_bash.sh` - Safe command executor
- `scripts/validate_command.sh` - Command validator
- `scripts/generate_script.sh` - Script generator
- Bash manual: https://www.gnu.org/software/bash/manual/
- ShellCheck: https://www.shellcheck.net/
