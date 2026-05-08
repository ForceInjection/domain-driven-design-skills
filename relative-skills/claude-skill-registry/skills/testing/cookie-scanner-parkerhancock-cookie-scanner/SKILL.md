---
name: cookie-scanner
description: |
  Analyze website cookie consent compliance by testing consent banner behavior.
  Use when asked to audit cookies, check GDPR/CCPA compliance, analyze tracking,
  or assess consent mechanisms on websites.
---

# Cookie Consent Compliance Scanner

This skill provides tools for analyzing website cookie consent compliance by testing
multiple consent scenarios (accept all, reject all, customize options) and generating
detailed reports suitable for legal review.

## Installation Check

Before using, verify the package is installed by checking for the marker file:

```python
from pathlib import Path
skill_dir = Path(__file__).parent  # or use the skill's base path
installed_marker = skill_dir / ".installed"
if not installed_marker.exists():
    # Run install.sh first
    import subprocess
    subprocess.run(["bash", str(skill_dir / "install.sh")], check=True)
```

Or simply try importing and catch the error:

```python
try:
    from cookie_scanner import run_consent_scan
except ImportError:
    # Run install.sh
    pass
```

## Python API

### Main Functions

#### `run_consent_scan(url, output_dir=None, max_depth=2, max_pages=10, scenarios=None)`

Run a complete cookie consent compliance scan.

```python
import asyncio
from cookie_scanner import run_consent_scan

# Basic scan (all scenarios)
output_dir, results = asyncio.run(run_consent_scan("https://example.com"))

# Quick scan (fewer pages, key scenarios only)
output_dir, results = asyncio.run(run_consent_scan(
    "https://example.com",
    max_depth=1,
    max_pages=5,
    scenarios=["no_interaction", "reject_all", "accept_all"]
))

# Full audit
output_dir, results = asyncio.run(run_consent_scan(
    "https://example.com",
    max_depth=2,
    max_pages=10,
    scenarios=None  # All 8 scenarios
))
```

**Parameters:**
- `url`: Website URL to scan (e.g., "https://example.com")
- `output_dir`: Output directory path. If None, creates timestamped directory.
- `max_depth`: Maximum crawl depth from homepage (default: 2)
- `max_pages`: Maximum pages to scan per scenario (default: 10)
- `scenarios`: List of scenario names to test, or None for all

**Returns:** Tuple of (output_directory_path, list_of_CrawlScanResult)

#### `get_available_scenarios()`

Get list of available consent scenarios.

```python
from cookie_scanner import get_available_scenarios

scenarios = get_available_scenarios()
# Returns: [{"name": "no_interaction", "description": "..."}, ...]
```

#### `generate_excel_report(results, output_path)`

Generate Excel report from scan results.

```python
from cookie_scanner import generate_excel_report

generate_excel_report(results, "report.xlsx")
```

#### `generate_comparison_summary(url, results, max_depth, max_pages)`

Generate comparison summary dictionary.

```python
from cookie_scanner import generate_comparison_summary

summary = generate_comparison_summary(url, results, max_depth, max_pages)
```

### Result Objects

#### `CrawlScanResult`

Contains results for one consent scenario:

```python
result.scenario          # e.g., "reject_all"
result.description       # e.g., "Click 'Reject Non-Essential' button"
result.pages_scanned     # Number of pages scanned
result.total_cookies     # Total unique cookies found
result.all_third_party_domains  # Dict[domain, bytes_sent]
result.trackers_by_category     # Dict[category, List[tracker_info]]
result.cookie_inventory  # List of all cookies with details
result.page_results      # List[PageScanResult] per-page data
```

#### `PageScanResult`

Contains results for one page:

```python
page.url                    # Page URL
page.cookies                # List of cookies set on this page
page.third_party_domains    # Dict[domain, bytes_sent]
page.trackers_by_category   # Dict[category, List[tracker_info]]
```

### Tracker Database

Categorize domains using the git-synced tracker database (4386+ domains):

```python
from cookie_scanner import categorize_domain, get_tracker_database

# Single domain
category = categorize_domain("doubleclick.net")  # Returns "Advertising"

# Get database for batch operations
db = get_tracker_database()
category = db.categorize("google-analytics.com")  # "Analytics"
company = db.get_company("hubspot.com")  # "HubSpot"
```

**Database Location:** The tracker database is stored at `~/.cookie-scanner/tracker-database/`
and synced via git. This allows updates to be shared across machines.

#### Database Status

```python
from cookie_scanner import get_database_status

status = get_database_status()
# Returns: {"path": "...", "domain_count": 4386, "is_external": True, ...}
```

#### Manual Sync

```python
from cookie_scanner import sync_tracker_database

# Pull latest changes from remote
sync_tracker_database()
```

### Updating the Tracker Database (Auto-Commits to Git)

After scanning, you may find domains categorized as "Unknown". When you add new trackers,
**they are automatically committed and pushed to the git repository** - no manual git
operations needed.

#### Find Unknown Domains

```python
from cookie_scanner import get_unknown_domains

# From scan results, get all third-party domains
all_domains = []
for result in results:
    all_domains.extend(result.all_third_party_domains.keys())

# Find which ones are unknown
unknown = get_unknown_domains(list(set(all_domains)))
print(f"Unknown domains: {unknown}")
```

#### Add Single Tracker (Auto-Commits & Pushes)

```python
from cookie_scanner import add_tracker

# Add a new tracker - automatically commits and pushes to git!
add_tracker("newtracker.com", "NewTracker Inc", "Analytics")
# Commit message: "Add tracker: newtracker.com (Analytics)"
```

#### Add Multiple Trackers (Batch Commit)

```python
from cookie_scanner import add_trackers_batch

# Add multiple at once - single commit for all
add_trackers_batch([
    {"domain": "tracker1.com", "company": "Company A", "category": "Analytics"},
    {"domain": "tracker2.com", "company": "Company B", "category": "Advertising"},
    {"domain": "cdn.example.com", "company": "Example CDN", "category": "Content"},
])
# Commit message: "Add 3 trackers: tracker1.com, tracker2.com, cdn.example.com"
```

#### If Push Fails

If pushing to main fails (e.g., due to permissions or conflicts), the code automatically:
1. Creates a new branch: `tracker-update-YYYYMMDD_HHMMSS`
2. Pushes to that branch
3. Logs the branch name for later merge

#### Valid Categories

| Category | Description |
|----------|-------------|
| `Advertising` | Ad networks, ad tech, marketing automation |
| `Analytics` | Web analytics, session replay, UX analytics |
| `Social` | Social media widgets and trackers |
| `Content` | CDNs, video hosts, embedded content |
| `TagManager` | Tag management systems (GTM, Tealium, Segment) |
| `ConsentManagers` | Cookie consent platforms |
| `FingerprintingInvasive` | Invasive browser fingerprinting |
| `FingerprintingGeneral` | General fingerprinting techniques |
| `Cryptomining` | Cryptocurrency mining scripts |
| `Email` | Email tracking pixels |

#### Workflow for Unknown Domains

1. **Run scan** and collect results
2. **Extract unknown domains** using `get_unknown_domains()`
3. **Research each domain** to identify company and purpose
4. **Add to database** using `add_tracker()` or `add_trackers_batch()` - **auto-pushed to git!**
5. **Re-run scan** or regenerate reports for updated categorization

```python
import asyncio
from cookie_scanner import (
    run_consent_scan,
    get_unknown_domains,
    add_trackers_batch,
    generate_excel_report,
    VALID_CATEGORIES,
)

async def scan_and_update_db(url: str):
    # Initial scan
    output_dir, results = await run_consent_scan(url, max_depth=1, max_pages=5)

    # Find unknown domains
    all_domains = set()
    for r in results:
        all_domains.update(r.all_third_party_domains.keys())

    unknown = get_unknown_domains(list(all_domains))

    if unknown:
        print(f"Found {len(unknown)} unknown domains:")
        for d in unknown:
            print(f"  - {d}")

        print(f"\nValid categories: {VALID_CATEGORIES}")

        # After researching, add them (auto-commits and pushes!):
        # add_trackers_batch([
        #     {"domain": "unknown1.com", "company": "...", "category": "..."},
        # ])

        # Regenerate report with updated categories
        # generate_excel_report(results, output_dir / "updated_report.xlsx")

    return output_dir, results

asyncio.run(scan_and_update_db("https://example.com"))
```

## Available Scenarios

| Name | Description |
|------|-------------|
| `no_interaction` | Fresh page load without interacting with cookie banner |
| `reject_all` | Click "Reject Non-Essential" button |
| `accept_all` | Click "Accept All" button |
| `essential_only` | Customize panel with nothing enabled |
| `functional_only` | Enable only Functional cookies |
| `analytics_only` | Enable only Analytics cookies |
| `advertisement_only` | Enable only Advertisement cookies |
| `all_non_essential` | Enable all non-essential cookies |

## Output Files

Scans create a timestamped directory containing:

- `comparison_summary.json` - Aggregate metrics per scenario
- `scan_[scenario].json` - Detailed results per scenario
- `tracker_analysis.xlsx` - Professional Excel report with:
  - Executive Summary sheet
  - Scenario Comparison sheet
  - Per-scenario sheets (URLs as rows, trackers as columns)
  - Cookie Inventory sheet

## Example: Full Compliance Audit

```python
import asyncio
import json
from pathlib import Path
from cookie_scanner import run_consent_scan, get_available_scenarios

async def audit_website(url: str):
    """Run a full cookie compliance audit."""

    # Run scan with all scenarios
    output_dir, results = await run_consent_scan(
        url,
        max_depth=2,
        max_pages=10
    )

    # Analyze results
    print(f"Results saved to: {output_dir}")

    # Compare reject vs accept
    reject = next((r for r in results if r.scenario == "reject_all"), None)
    accept = next((r for r in results if r.scenario == "accept_all"), None)
    no_action = next((r for r in results if r.scenario == "no_interaction"), None)

    if reject and no_action:
        # Check if reject actually reduces tracking
        reject_domains = len(reject.all_third_party_domains)
        no_action_domains = len(no_action.all_third_party_domains)

        if reject_domains >= no_action_domains:
            print("WARNING: 'Reject All' doesn't reduce third-party domains!")

    # Check for pre-consent tracking
    if no_action:
        pre_consent_cookies = no_action.total_cookies
        pre_consent_domains = len(no_action.all_third_party_domains)
        print(f"Pre-consent: {pre_consent_cookies} cookies, {pre_consent_domains} 3P domains")

    return output_dir, results

# Run the audit
output_dir, results = asyncio.run(audit_website("https://example.com"))
```

## Supported Consent Platforms

Currently optimized for **CookieYes** consent banners. The scanner detects consent
platforms by checking for specific selectors and button attributes.
