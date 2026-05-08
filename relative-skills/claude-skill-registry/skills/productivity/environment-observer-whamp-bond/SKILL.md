---
name: environment-observer
description: Perform heuristic environment discovery beyond basic directory listing. Check installed packages, analyze folder structure, inspect running processes, and assess system state. Use proactively when starting new tasks or when environment context is unclear.
allowed-tools: Execute, Read, Grep, Glob
---

# Environment Observer

Apex2's heuristic environment observation phase implemented as a Claude Code skill. Goes far beyond simple `ls` to provide meaningful system context.

## Instructions

When invoked, perform comprehensive environment discovery to understand the current state:

### 1. Package and Dependency Discovery
Identify what's available in the current environment:

```bash
# Python packages (if Python detected)
pip list | head -20
python -m pip list 2>/dev/null | head -20

# Node.js packages (if package.json detected)
npm list --depth=0 2>/dev/null
yarn list --depth=0 2>/dev/null

# System packages (distribution-specific)
dpkg -l | grep -E "(python|node|npm|git)" 2>/dev/null
rpm -qa | grep -E "(python|node|npm|git)" 2>/dev/null || brew list | grep -E "(python|node|npm|git)" 2>/dev/null
```

### 2. Folder and File Structure Analysis
Understand the project organization:

```bash
# Key configuration files
find . -regex ".*\.\(json\|yaml\|yml\|conf\|ini\|toml\|cfg\)" -type f | head -10

# Programming languages detected
find . -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.java" -o -name "*.cpp" -o -name "*.go" -o -name "*.rb" -o -name "*.php" 2>/dev/null | head -20

# Documentation and setup files
find . -name "README*" -o -name "CHANGELOG*" -o -name "LICENSE*" -o -name "Makefile" -o -name "*.md" 2>/dev/null | head -10

# Test files
find . -name "*test*" -o -name "*spec*" -type f | head -10
```

### 3. Running Processes and Services
Check what's currently active:

```bash
# Python processes
ps aux | grep python | grep -v grep
ps aux | grep node | grep -v grep
ps aux | grep npm | grep -v grep

# Development servers
lsof -i :3000 -i :8000 -i :5000 -i :8080 2>/dev/null

# Database connections
ps aux | grep -E "(postgres|mysql|mongo|redis)" | grep -v grep

# Background services
systemctl list-units --type=service --state=running 2>/dev/null | head -10
```

### 4. System State and Resources
Assess available resources and constraints:

```bash
# Disk space
df -h

# Memory usage
free -h

# CPU info
nproc 2>/dev/null
cat /proc/cpuinfo | grep processor | wc -l 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null

# Network connectivity
ping -c 1 google.com 2>/dev/null | head -2  # Just check connectivity

# Current directory permissions
ls -la
```

### 5. Development Environment Context
Check for development tools and configurations:

```bash
# Version control status
git status 2>/dev/null
git branch --show-current 2>/dev/null

# Container presence (Docker, podman)
docker ps -a 2>/dev/null | head -5
podman ps -a 2>/dev/null | head -5

# Environment variables
printenv | grep -E "(PYTHON|NODE|JAVA|VIRTUAL)" | head -10

# Shell and terminal type
echo $SHELL
echo $TERM
```

### 6. Key File Content Discovery
Read selected critical files to understand project setup:

- `package.json`, `requirements.txt`, `Cargo.toml` (dependency info)
- `.env.example`, `config/settings.py` (configuration structure)
- `README.md`, `CONTRIBUTING.md` (project documentation)
- `.gitignore` (what's excluded from version control)

## Analysis Process

1. Use Execute to run discovery commands safely
2. Use Read to examine critical files discovered  
3. Use Grep to search for specific patterns in configuration files
4. Use Glob to find related files by pattern
5. Synthesize findings into comprehensive environment report

## Output Format

Provide structured environment analysis:

```
Environment Context:

Development Stack:
  Primary Languages: [detected languages]
  Package Managers: [npm/pip/cargo/etc]
  Frameworks: [react/django/flask/etc]
  Testing Tools: [jest/pytest/cucumber/etc]

System Resources:
  CPU: [cores/info]
  Memory: [available/total]
  Disk: [free space on key partitions]
  Network: [connectivity status]

Active Services:
  Running: [list important services]
  Ports in use: [important port numbers]
  Processes: [development processes running]

Project Structure:
  Configuration files: [key config files found]
  Test organization: [test structure]
  Documentation: [available docs]
  Build tools: [make/webpack/etc]

Development Environment:
  Shell: [shell type]
  Containers: [docker/podman status]
  Version Control: [git status and branch]
  Environment Setup: [virtual env, nvm, etc.]

Key Findings:
  - [important observation 1]
  - [important observation 2]
  - [potential issue 1]
  - [recommendation 1]

Next Steps:
  - [action 1]
  - [action 2]
```

## Discovery Categories

### Python Projects
Look for: `requirements.txt`, `pyproject.toml`, `setup.py`, `.venv/` or `venv/`
Check: Virtual environment activation, package versions, test framework

### Node.js Projects  
Look for: `package.json`, `node_modules/`, `.nvmrc`
Check: Node version, npm vs yarn, development vs production deps

### Containerized Projects
Look for: `Dockerfile`, `docker-compose.yml`, `.dockerignore`
Check: Container status, image availability, port mappings

### Multi-language Projects
Identify polyglot setups and integration points between different language components

## When to Use

This observer is valuable when:
- Starting work in a new project
- Encountering unexpected behavior
- Debugging environment-related issues
- Planning deployment or testing
- Needing to understand project capabilities
- Setting up new开发 environment

The goal is to go beyond surface-level file listing to provide meaningful insights about what's actually available, running, and configured in the environment.
