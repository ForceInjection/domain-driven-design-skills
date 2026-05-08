---
name: visualize-portfolio
description: Automatically find the latest portfolio CSVs, process them, and display visualizations in web browser. Use when you want a complete portfolio analysis with one command.
allowed-tools: Bash(python:*), Read
---

# Visualize Portfolio

This skill provides a one-command solution to visualize your complete portfolio. It automatically finds the latest CSV files from Fidelity and Tastytrade, processes the data, detects synthetic positions, generates visualizations, and opens them in your web browser.

## Instructions

When you want to visualize your portfolio:

1. **Run the visualization script**
   - Execute `python tools/visualize.py` from the skill directory
   - Or use: `python .claude/skills/visualize-portfolio/tools/visualize.py` from project root
   - Script automatically finds latest CSVs, processes data, and opens plots

2. **Review the visualizations**
   - Plots open automatically in your default web browser
   - HTML file contains all charts embedded as images
   - Expiring options report saved as CSV

3. **Check output files**
   - `plots.html` - Interactive HTML with all visualizations
   - `expiring_options.csv` - Options expiring in next 90 days

## What This Skill Does

**Automatic Workflow:**
1. 🔍 Finds latest Fidelity and Tastytrade CSV files in ~/Downloads
2. 📊 Parses and harmonizes data from both brokers
3. 🎯 Detects synthetic long positions (LC + SP pairs)
4. 📈 Generates comprehensive visualizations:
   - Current value by stock position (linear & log scale)
   - Portfolio allocation pie charts
   - Options exposure per ticker
   - Strike ladders
   - Options expiry timelines with current price lines
5. 📋 Creates expiring options report
6. 🌐 Opens all plots in web browser

**What Gets Visualized:**
- Stock positions by current value
- Portfolio allocation (major positions and small positions)
- Options exposure grouped by ticker
- Options exposure by type (Long Call, Short Call, Long Put, Short Put, Synthetic Long)
- Strike ladders showing position values at each strike
- Expiration timelines (short-term < 60 DTE, long-term ≥ 60 DTE)
- Current stock price lines on expiry plots (via yfinance)

## Usage

### Basic Usage (Most Common)

```bash
# From skill directory
cd .claude/skills/visualize-portfolio
python tools/visualize.py

# Or from project root
python .claude/skills/visualize-portfolio/tools/visualize.py
```

This uses smart defaults:
- Searches ~/Downloads for latest CSVs
- Outputs to ~/Desktop
- Opens browser automatically

### Custom Directories

```bash
# Search different directory for CSVs
python tools/visualize.py --directory ~/custom/downloads

# Output to different location
python tools/visualize.py --output ~/Documents/portfolio-reports

# Both custom
python tools/visualize.py \
    --directory ~/data/broker-exports \
    --output ~/portfolio-analysis
```

### Quiet Mode

```bash
# Minimal output (for scripting or cron jobs)
python tools/visualize.py --quiet

# Quiet mode without opening browser
python tools/visualize.py --quiet --no-browser
```

### Skip Browser

```bash
# Generate plots but don't open browser
python tools/visualize.py --no-browser
```

## Command-Line Options

| Option | Default | Description |
|--------|---------|-------------|
| `--directory` | `~/Downloads` | Directory to search for CSV files |
| `--output` | `~/Desktop` | Directory to save plots and reports |
| `--no-browser` | `False` | Don't open browser automatically |
| `--quiet` | `False` | Minimal console output |

## Output Files

All files are saved to the output directory (default: ~/Desktop):

**plots.html**
- Contains all visualizations as embedded images
- Self-contained HTML file
- Opens automatically in browser
- Can be emailed or archived

**expiring_options.csv**
- Options expiring in next 90 days
- Columns: ticker, strike, options_type, expiration, days_to_expiry, bucket
- Buckets: Today, Less Than a Week, Less Than a Month, Less Than a Quarter

## Console Output Example

```
Finding latest portfolio files...
  ✓ Fidelity: Portfolio_Positions_Jan-04-2026.csv (modified 2026-01-04 14:30)
  ✓ Tastytrade: tastytrade_positions_x5WY76408_260104.csv (modified 2026-01-04 14:32)

Processing portfolio data...
  ✓ Parsed 42 stock positions
  ✓ Parsed 64 options positions
  ✓ Detected 7 synthetic long positions
  ✓ Harmonized data across brokers

Generating visualizations...
  ✓ Current value plots
  ✓ Portfolio allocation charts
  ✓ Options exposure by ticker (12 tickers)
  ✓ Expiration report

Output saved to: /Users/username/Desktop/
  - plots.html
  - expiring_options.csv

Opening plots in web browser...
✓ Complete!
```

## Error Handling

**No CSV files found:**
```
ERROR: No portfolio CSV files found in ~/Downloads

Please download your portfolio files:
  - Fidelity: Account Positions → Download CSV
  - Tastytrade: Positions → Export CSV

Then try again.
```

**Only one CSV found:**
```
WARNING: Only Fidelity CSV found. Tastytrade CSV missing.
Proceeding with Fidelity data only...
```

**CSV parsing error:**
```
ERROR: Failed to parse Fidelity CSV
Details: [error message]

Please ensure the CSV is a valid Fidelity portfolio export.
```

## Integration with Other Skills

### With find-latest-portfolio

This skill uses `find-latest-portfolio` internally. You can also use them together:

```bash
# First find the files
cd .claude/skills/find-latest-portfolio
python tools/file_finder.py

# Then visualize (optional, visualize-portfolio does this automatically)
cd ../visualize-portfolio
python tools/visualize.py
```

### With portfolio-analyzer

For deeper analysis beyond visualization:

```bash
# Visualize first
python .claude/skills/visualize-portfolio/tools/visualize.py

# Then use portfolio-analyzer for specific analysis
# (invoke via Claude)
```

### With pine-script-generator

After visualizing, generate Pine scripts:

```bash
# Visualize portfolio
python .claude/skills/visualize-portfolio/tools/visualize.py

# Generate Pine list for TradingView
bash bin/generate_pine_list.sh
```

## Common Scenarios

### Daily Portfolio Check

```bash
# Add to daily routine or cron job
python .claude/skills/visualize-portfolio/tools/visualize.py --quiet
```

### Before Market Open

```bash
# Download latest CSVs from brokers, then:
python .claude/skills/visualize-portfolio/tools/visualize.py
# Review plots in browser
# Check expiring_options.csv for upcoming expirations
```

### Archive Portfolio Snapshot

```bash
# Create dated snapshot
OUTPUT_DIR=~/portfolio-snapshots/$(date +%Y-%m-%d)
mkdir -p "$OUTPUT_DIR"
python .claude/skills/visualize-portfolio/tools/visualize.py --output "$OUTPUT_DIR"
```

### Weekly Portfolio Review

```bash
# Generate plots with detailed output
python .claude/skills/visualize-portfolio/tools/visualize.py
# Review in browser
# Check synthetic positions detected
# Review expiring options report
```

## Troubleshooting

**Browser doesn't open:**
- Check that you have a default browser configured
- Use `--no-browser` flag and open plots.html manually
- Check console for error messages

**Old CSV files being used:**
- Download fresh CSVs from your brokers
- CSVs in ~/Downloads are sorted by modification time
- The most recently modified file is used

**Plots look wrong:**
- Verify CSV files are from correct date
- Check that CSVs are complete (not truncated downloads)
- Ensure CSVs are in expected format (Fidelity/Tastytrade standard exports)

**Missing positions:**
- Check both broker CSVs were found
- Review console output for parsing warnings
- Verify positions exist in the source CSV files

**Synthetic positions not detected:**
- Requires matching Long Call + Short Put
- Same ticker, strike, and expiration
- If quantities don't match, only partial synthetic is created

## Technical Details

**Dependencies:**
- Uses `find_latest_files()` from find-latest-portfolio skill
- Uses `harmonize_and_store()` from UpdatePositionCSVs
- Uses `process_synthetics()` for SYN_LONG detection
- Uses `PlotPositions` class for all visualizations
- Uses `yfinance` for current stock prices on expiry plots

**Processing Steps:**
1. File discovery via find_latest_files()
2. CSV parsing via FidelityParser and TastytradeParser
3. Data harmonization and value calculations
4. Synthetic position detection
5. Visualization generation (matplotlib → base64 → HTML)
6. Browser launch via webbrowser module

**Configuration:**
- Colors and styling from `config/visualization.json`
- Current price line can be disabled in visualization.json
- Column mapping from `config/harmonization.json`

## Tips and Best Practices

- **Download CSVs regularly** - More frequent data = better analysis
- **Check expiring_options.csv** - Plan ahead for upcoming expirations
- **Review synthetic positions** - Verify LC+SP pairs are correctly identified
- **Use quiet mode for automation** - Add to scripts or cron jobs
- **Archive important snapshots** - Save plots for historical reference
- **Keep CSVs fresh** - Latest data provides most accurate analysis

## See Also

- [find-latest-portfolio](../find-latest-portfolio/SKILL.md) - Find latest CSV files
- [portfolio-analyzer](../portfolio-analyzer/SKILL.md) - Detailed portfolio analysis
- [pine-script-generator](../pine-script-generator/SKILL.md) - TradingView integration
