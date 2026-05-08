---
name: powershell-skill
description: Execute PowerShell commands on Windows systems with security constraints
version: 1.0.0
author: Agent Skills Template
---

## Purpose
This skill allows the agent to execute safe PowerShell commands for:
- System information gathering (Get-ComputerInfo, Get-Process)
- File system queries (Get-ChildItem, Test-Path)
- Date/time operations (Get-Date)
- Service status checks (Get-Service)

## When to Use
- User requests system information
- Need to check file existence or directory contents
- Querying running processes or services
- Getting current date, time, or location

## Instructions
1. **Validate Intent**: Ensure the user's request is safe and appropriate
2. **Review Security**: Check security.md for constraints before execution
3. **Use Allowed Cmdlets**: Only use cmdlets from the whitelist
4. **Explain Actions**: Tell the user what command you're running and why
5. **Handle Errors**: If execution fails, explain the error clearly

## Parameters
- `command` (string, required): The PowerShell command to execute
- `timeout` (int, optional): Maximum execution time in seconds (default: 10)

## Example Usage
```python
from skills.powershell import execute

# Get current date
result = execute('Get-Date')
if result['success']:
    print(result['output'])

# List directory contents
result = execute('Get-ChildItem -Path C:\\Users')
```

## Additional Context
- See reference.md for PowerShell cmdlet documentation
- See security.md for security boundaries and constraints
