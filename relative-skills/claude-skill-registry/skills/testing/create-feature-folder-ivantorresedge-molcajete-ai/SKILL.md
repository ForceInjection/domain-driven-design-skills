---
name: create-feature-folder
description: Helper for creating timestamped feature directories. Use when creating new feature specs.
---

# Create Feature Folder Skill

## When to Use

- Creating new feature directories in .molcajete/prd/specs/
- Need timestamped folder names (YYYYMMDD-feature_name format)

## Usage

The timestamp logic is inlined directly in commands for portability:

```bash
FEATURE_DIR=$(python3 -c "from datetime import datetime; from pathlib import Path; import sys; name = sys.argv[1].replace('-', '_'); timestamp = datetime.now().strftime('%Y%m%d'); dir_name = f'{timestamp}-{name}'; Path(f'.molcajete/prd/specs/{dir_name}').mkdir(parents=True, exist_ok=True); print(dir_name)" "<feature-name>")
```

**Output:** Returns the timestamped directory name (e.g., `20251112-feature_name`)

**How it works:**
1. Converts feature name from kebab-case to snake_case
2. Gets current date in YYYYMMDD format
3. Creates directory name: `{timestamp}-{feature_name}`
4. Creates directory at: `.molcajete/prd/specs/{timestamp}-{feature_name}/`
5. Returns just the directory name for use in subsequent commands

## Example

```bash
# Create folder for "user-authentication" feature
FEATURE_DIR=$(python3 -c "from datetime import datetime; from pathlib import Path; import sys; name = sys.argv[1].replace('-', '_'); timestamp = datetime.now().strftime('%Y%m%d'); dir_name = f'{timestamp}-{name}'; Path(f'.molcajete/prd/specs/{dir_name}').mkdir(parents=True, exist_ok=True); print(dir_name)" "user-authentication")
# Creates: .molcajete/prd/specs/20251112-user_authentication/
# Returns: 20251112-user_authentication

# Use in subsequent commands
echo "Feature directory: ${FEATURE_DIR}"
# Output: Feature directory: 20251112-user_authentication
```

