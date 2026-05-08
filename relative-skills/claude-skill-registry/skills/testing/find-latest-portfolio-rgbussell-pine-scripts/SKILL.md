---
name: find-latest-portfolio
description: Find the most recently downloaded Fidelity and Tastytrade portfolio CSV files from Downloads directory. Use when you need to locate the latest portfolio data files before analysis or processing.
allowed-tools: Bash, Read, Glob
---

# Find Latest Portfolio Files

This skill automatically finds the most recently downloaded portfolio CSV files from the `~/Downloads` directory for both Fidelity and Tastytrade accounts. It returns both file paths for use in portfolio analysis and visualization workflows.

## Instructions

When you need to locate the latest portfolio data files, use the tools provided in the `tools/` directory:

1. **Use file_finder.py to find portfolio files**
   - Run `python tools/file_finder.py` from the skill directory
   - Searches for both Fidelity and Tastytrade files
   - Handles version marks like `(1)`, `(2)` automatically
   - Returns structured output with file paths
   - Exit codes: 0 (both found), 1 (one missing), 2 (both missing)

2. **Or import as Python module**
   - Import `file_finder` from the tools directory
   - Call `find_latest_files()` to get both files as dict
   - Use `find_latest_fidelity()` or `find_latest_tastytrade()` for individual files
   - Returns None if files not found

3. **Get additional file information**
   - Use `./tools/get_file_info.sh <file_path>` to get details
   - Shows modification date, file size, and full path
   - Useful for confirming file freshness

4. **Error handling**
   - Tools return clear "NOT_FOUND" messages when files are missing
   - Both files are typically needed for complete portfolio analysis

## File Patterns

The skill recognizes these portfolio file naming patterns:

**Fidelity Files:**
- Pattern: `Portfolio_Positions_MMM-DD-YYYY.csv`
- Examples:
  - `Portfolio_Positions_Jan-04-2026.csv`
  - `Portfolio_Positions_Dec-19-2025.csv`
  - `Portfolio_Positions_Jan-04-2026 (1).csv` (with version mark)

**Tastytrade Files:**
- Pattern: `tastytrade_positions_XXXXXXXXX_YYMMDD.csv`
- Examples:
  - `tastytrade_positions_123456789_260104.csv`
  - `tastytrade_positions_987654321_251219.csv`
  - `tastytrade_positions_123456789_260104 (2).csv` (with version mark)

**Version Marks:**
- When files are downloaded multiple times on the same day, browsers append `(1)`, `(2)`, etc.
- The skill uses modification time, not filename, to determine the most recent file

## Tools

This skill provides tools in the `tools/` directory:

### `file_finder.py` - Find portfolio files

Python module that can be used as CLI or imported:

**As CLI:**
- Usage: `python tools/file_finder.py [downloads_dir]`
- Outputs: `FIDELITY: /path/to/file.csv` and `TASTYTRADE: /path/to/file.csv`
- Exit codes: 0 (both found), 1 (one missing), 2 (both missing)

**As Python module:**
- Import functions: `find_latest_fidelity()`, `find_latest_tastytrade()`, `find_latest_files()`
- Returns file paths or None if not found
- Used by unit tests

### `get_file_info.sh` - Get file information

Shell script to get detailed file information:
- Usage: `./tools/get_file_info.sh <file_path>`
- Outputs: File name, path, size, and modification date

## Common Tasks

### Find Both Latest Portfolio Files

```bash
# From the skill directory
cd .claude/skills/find-latest-portfolio
python tools/file_finder.py

# Or with custom directory
python tools/file_finder.py ~/custom/path
```

### Find Files and Get Detailed Information

```bash
# Find the files
output=$(python tools/file_finder.py)

# Extract file paths (parse the output)
fidelity_file=$(echo "$output" | grep "FIDELITY:" | cut -d' ' -f2-)
tastytrade_file=$(echo "$output" | grep "TASTYTRADE:" | cut -d' ' -f2-)

# Get detailed info for each file
if [ "$fidelity_file" != "NOT_FOUND" ]; then
    echo "=== Fidelity File Info ==="
    ./tools/get_file_info.sh "$fidelity_file"
fi

if [ "$tastytrade_file" != "NOT_FOUND" ]; then
    echo "=== Tastytrade File Info ==="
    ./tools/get_file_info.sh "$tastytrade_file"
fi
```

### Use as Python Module

```python
# Add tools directory to path
import sys
sys.path.insert(0, '.claude/skills/find-latest-portfolio/tools')

# Import and use
from file_finder import find_latest_files

files = find_latest_files()
print(f"Fidelity: {files['fidelity']}")
print(f"Tastytrade: {files['tastytrade']}")
```

## Output Guidelines

When presenting results to the user:

1. **Display both file paths clearly**
   - Show the full path or just the filename for readability
   - Include modification date/time to confirm freshness

2. **Format example:**
   ```
   Found latest portfolio files:

   Fidelity:
     File: Portfolio_Positions_Jan-04-2026.csv
     Modified: 2026-01-04 09:30:15

   Tastytrade:
     File: tastytrade_positions_123456789_260104.csv
     Modified: 2026-01-04 09:32:47
   ```

3. **Handle missing files gracefully:**
   ```
   Found latest portfolio files:

   Fidelity: Portfolio_Positions_Jan-04-2026.csv ✓
   Tastytrade: No file found - please download from Tastytrade
   ```

## Examples

### Example 1: Successfully finding both files

When invoked, the skill will:
1. Search ~/Downloads for Portfolio_Positions_*.csv files
2. Search ~/Downloads for tastytrade_positions_*.csv files
3. Return both paths with modification times
4. Ready for use with portfolio-analyzer or pine-script-generator

### Example 2: Handling missing Tastytrade file

If only Fidelity file exists:
1. Return the Fidelity file path successfully
2. Inform user that Tastytrade file was not found
3. Suggest downloading fresh Tastytrade data if needed for analysis

### Example 3: Files with version marks

If Downloads contains:
- `Portfolio_Positions_Jan-04-2026.csv` (modified 9:00 AM)
- `Portfolio_Positions_Jan-04-2026 (1).csv` (modified 9:30 AM)

The skill will return the second file because it has the most recent modification time, regardless of the version mark in the filename.

## Integration with Other Skills

### With portfolio-analyzer

After finding the files, pass them to the portfolio-analyzer skill:
```bash
# Find files and extract paths
cd .claude/skills/find-latest-portfolio
output=$(python tools/file_finder.py)
fidelity_file=$(echo "$output" | grep "FIDELITY:" | cut -d' ' -f2-)
tastytrade_file=$(echo "$output" | grep "TASTYTRADE:" | cut -d' ' -f2-)

# Then analyze with both files
cd ../../..
/portfolio-analyzer "$fidelity_file" "$tastytrade_file"
```

### With pine-script-generator

After finding the files, use them to generate Pine scripts:
```bash
# Find files using the tool
cd .claude/skills/find-latest-portfolio
python tools/file_finder.py

# Copy to data directory for pine-script-generator
cd ../../..
# ... then use /pine-script-generator
```

### Copying to data/ directory

If you need to copy the files to the project's data directory:
```bash
# Find and copy files using Python
cd .claude/skills/find-latest-portfolio
python -c "
import sys
sys.path.insert(0, 'tools')
from file_finder import find_latest_files
import shutil
files = find_latest_files()
if files['fidelity']: shutil.copy(files['fidelity'], '../../../data/')
if files['tastytrade']: shutil.copy(files['tastytrade'], '../../../data/')
"
```

## Tips and Best Practices

- The skill searches only the top level of ~/Downloads (not subdirectories)
- Modification time is more reliable than filename for determining "most recent"
- Both files are typically needed for complete portfolio analysis
- If files are very old, consider downloading fresh data from your brokers
- The skill is read-only and never modifies or moves files

## See Also

- [portfolio-analyzer](../portfolio-analyzer/SKILL.md) - Analyze portfolio data
- [pine-script-generator](../pine-script-generator/SKILL.md) - Generate TradingView visualizations
