---
name: radulator-qa-tester
description: Automated QA testing for Radulator's 18 medical calculators across radiology, hepatology/liver, and urology specialties. Tests accuracy, collects browser diagnostics, generates Playwright tests, and manages three-branch Git workflow (dev1→test1→main). Use when testing Radulator calculators, reviewing PRs with qa label, verifying medical formulas, generating test reports, or creating comprehensive test suites.
---

# Radulator QA Tester

Comprehensive automated testing system for the Radulator medical calculator web application. This skill acts as a highly-competent manual tester that reads test specifications, runs the web app, collects diagnostics, verifies calculations, and produces detailed test reports.

## Supported Calculators (18 Total)

### Radiology (6)
1. Adrenal CT Washout
2. Adrenal MRI Chemical Shift Index (CSI)
3. Prostate Volume & PSA Density
4. Renal Cyst (Bosniak Classification)
5. Spleen Size (Upper Limit of Normal)
6. Hip Dysplasia Indices (DDH)

### Hepatology/Liver (9)
7. ALBI Score (Albumin-Bilirubin Grade)
8. Adrenal Vein Sampling - Cortisol (Cushing)
9. Adrenal Vein Sampling - Aldosterone (Hyperaldosteronism)
10. BCLC Staging (Barcelona Clinic Liver Cancer)
11. Child-Pugh Score
12. Milan Criteria (HCC Transplant Eligibility)
13. MELD-Na Score
14. MR Elastography (Liver Fibrosis Staging)
15. Y-90 Radiation Segmentectomy

### Urology (3)
16. IPSS (International Prostate Symptom Score)
17. RENAL Nephrometry Score
18. SHIM Score (Sexual Health Inventory for Men)

## Quick Start

When a Radulator PR is opened with the `qa` label:

1. Identify which calculator(s) changed
2. Run automated tests using Playwright MCP
3. Verify calculations against expected formulas
4. Collect diagnostics (console logs, network requests, screenshots)
5. Generate Playwright regression tests
6. Post test report to PR via GitHub MCP
7. Merge if tests pass, otherwise request fixes

## Prerequisites

This skill requires two MCP servers configured via **Docker Desktop MCP Toolkit** (recommended):

- **Playwright MCP**: Browser automation for testing (21 tools)
- **GitHub MCP**: Repository management and PR operations (40+ tools)

### Quick Setup (Claude Code CLI)

1. **Install Docker Desktop** with MCP Toolkit enabled
2. **Add MCP servers** via Docker Desktop UI:
   - Playwright (from catalog)
   - GitHub Official (from catalog, requires OAuth)
3. **Create `.mcp.json`** in Radulator project root:
   ```json
   {
     "mcpServers": {
       "MCP_DOCKER": {
         "command": "docker",
         "args": ["mcp", "gateway", "run"],
         "type": "stdio"
       }
     }
   }
   ```
4. **Connect Claude Code**:
   ```bash
   docker mcp client connect claude-code
   ```
5. **Verify**: `docker mcp tools ls` should show ~67 tools

See `references/mcp_setup.md` for detailed installation and configuration instructions.

## Core Testing Process

### Step 1: Detect Calculator Changes

When a PR is opened:

```
Use GitHub MCP to:
1. Get PR details and diff
2. Search diff for: src/components/calculators/*.jsx
3. Extract calculator name from changed files
```

### Step 2: Setup Test Environment

```bash
# Clone PR branch
git clone <repo-url> --branch <pr-branch>
cd radulator

# Install dependencies
npm install

# Start dev server
npm run dev
# Wait for "ready" message, note the port (typically 5173)
```

### Step 3: Run Playwright Tests

For each changed calculator:

1. **Navigate**: Use Playwright MCP to open `http://localhost:PORT`
2. **Select Calculator**: Click sidebar item matching calculator name
3. **Load Test Data**: Read test cases from `references/test_cases.md`
4. **Fill Inputs**: Use `browser_type` to enter test values
5. **Execute**: Click "Calculate" button
6. **Capture Results**: Extract output values from results section

### Step 4: Verify Calculations

```bash
# Run verification script
python scripts/verify_calculators.py <calculator_name> '<test_case_json>'

# Compare actual vs expected values
# Tolerance: ±0.1 for percentages, ±0.01 for densities
```

### Step 5: Collect Diagnostics

```
Use Playwright MCP to gather:
- browser_console_messages: Capture JavaScript errors/warnings
- browser_network_requests: Verify no unexpected API calls
- browser_take_screenshot: Document test state
```

### Step 6: Generate Regression Tests

```bash
# Use Playwright MCP
browser_generate_playwright_test

# Or use helper script
python scripts/generate_playwright_test.py "<calculator_name>" '<test_data_json>'

# Save to: tests/<calculator-name>.spec.js
# Commit to branch: qa/<calculator-name>
```

### Step 7: Report Results

Create a test report comment on the PR with:

```markdown
## QA Test Report: <Calculator Name>

### Test Case: <Test Name>

**Inputs:**
- Input 1: <value>
- Input 2: <value>
- ...

**Expected Results:**
- Output 1: <expected> (formula: <formula>)
- Output 2: <expected> (formula: <formula>)

**Actual Results:**
- Output 1: <actual> ✅ / ❌
- Output 2: <actual> ✅ / ❌

**Status:** PASS / FAIL

**Diagnostics:**
- Console Errors: <count> errors (details below)
- Network Requests: <count> requests
- Render Time: <time> ms

<If tests failed:>
**Recommended Fixes:**
1. <specific fix suggestion>
2. <code reference if applicable>

**Screenshots:**
![Test Results](<screenshot_url>)

**Console Logs:**
```
<error details if any>
```
```

### Step 8: Merge or Request Changes

```
If ALL tests PASS:
  - Post comment: "✅ QA: All tests passed"
  - Merge PR into test1 via GitHub MCP
  
If ANY test FAILS:
  - Post comment with detailed failure report
  - Do NOT merge
  - Wait for developer to fix and push updates
```

## Calculator-Specific Testing

### Adrenal CT Washout

**Test Inputs** (from `references/test_cases.md`):
- Typical adenoma: unenh=10, portal=100, delayed=40
- Non-adenoma: unenh=20, portal=80, delayed=70

**Verification Script:**
```python
from scripts.verify_calculators import adrenal_ct_washout
result = adrenal_ct_washout(10, 100, 40)
# Expected: absolute_washout=66.7%, relative_washout=60.0%
```

**UI Selectors:**
- Input: `input[name="unenh"]`, `input[name="portal"]`, `input[name="delayed"]`
- Results: `.results` container

### Prostate Volume & PSA Density

**Test Inputs:**
- Normal: length=4, height=3, width=3.5, psa=2
- Elevated: length=3.5, height=2.5, width=3, psa=5.5

**Verification Script:**
```python
from scripts.verify_calculators import prostate_volume_psa_density
result = prostate_volume_psa_density(4, 3, 3.5, 2)
# Expected: volume=21.84 mL, psa_density=0.092 ng/mL²
```

### Other Calculators

See `references/test_cases.md` for complete test data for all six calculators:
1. Adrenal CT Washout
2. Adrenal MRI Chemical Shift
3. Prostate Volume & PSA Density
4. Renal Cyst (Bosniak)
5. Spleen Size (Upper Limit)
6. Hip Dysplasia Indices

## Three-Branch Workflow

Radulator uses: **dev1** → **test1** → **main**

### PR from dev1 → test1

1. Developer creates PR with `qa` label
2. This skill runs automated tests
3. If tests pass → merge to test1
4. If tests fail → request fixes

### PR from test1 → main

1. After successful test1 merge, create PR to main
2. Re-run tests to catch regressions
3. If tests pass → merge to production
4. Deploy to radulator.com

See `references/workflow.md` for detailed workflow documentation.

## Quality Gates

### Before Merging to test1:
- ✅ Calculations accurate within tolerance
- ✅ No console errors
- ✅ Results render in < 500ms
- ✅ All inputs properly validated
- ✅ Interpretation text correct

### Before Merging to main:
- ✅ All test1 gates passed
- ✅ No regressions detected
- ✅ Playwright tests committed
- ✅ Documentation updated
- ✅ References section complete

## Example Test Report

```markdown
## QA Test Report: Adrenal CT Washout Calculator

### Test Case: Typical Adenoma

**Inputs:**
- Unenhanced HU: 10
- Portal Venous HU: 100
- Delayed (15 min) HU: 40

**Expected Results:**
- Absolute Washout: 66.7% (formula: ((portal - delayed)/(portal - unenh)) × 100)
- Relative Washout: 60.0% (formula: ((portal - delayed)/portal) × 100)
- Interpretation: "Suggests benign adenoma"

**Actual Results:**
- Absolute Washout: 66.7% ✅
- Relative Washout: 60.0% ✅
- Interpretation: "Suggests benign adenoma" ✅

**Status:** ✅ PASS

**Diagnostics:**
- Console Errors: 0
- Network Requests: 3 (all to localhost)
- Render Time: 142 ms

**Generated Regression Test:**
Committed to: `tests/adrenal-ct-washout.spec.js`

---

✅ **QA: All tests passed. Safe to merge to test1.**
```

## Troubleshooting

### Common Issues

**Issue**: Calculator not found in sidebar
**Fix**: Check calculator name matches `calcDefs` array in `App.jsx`

**Issue**: Input field selectors not working
**Fix**: Inspect actual input field names/IDs, update selectors

**Issue**: Results not rendering
**Fix**: Check for console errors, verify Calculate button click registered

**Issue**: Math precision errors
**Fix**: Use `.toBeCloseTo()` with appropriate precision tolerance

### Debugging Tools

```javascript
// Get all input fields
await page.$$eval('input', els => els.map(e => ({name: e.name, value: e.value})))

// Get results container HTML
await page.locator('.results').innerHTML()

// Monitor all console messages
page.on('console', msg => console.log('Browser:', msg.text()))
```

## Best Practices

1. **Verify MCP connection** before starting tests:
   ```bash
   docker mcp client ls  # Check connection status
   docker mcp tools ls   # Verify tools available
   ```
2. **Use Docker Desktop MCP Toolkit** for team consistency and CI/CD readiness
3. **Commit `.mcp.json`** to version control for team collaboration
4. **Run tests in headless mode** for CI, headful for debugging
5. **Take screenshots** after every major step for documentation
6. **Keep test data in sync** with medical literature references
7. **Generate Playwright tests** for all calculators to build regression suite
8. **Document deviations clearly** with formula references and code snippets
9. **Test on multiple browsers** (Chrome, Firefox, Safari) using Playwright
10. **Monitor token usage** - simplify Playwright interactions if needed

## Resources

- Test Cases: `references/test_cases.md`
- Workflow Guide: `references/workflow.md`
- MCP Setup: `references/mcp_setup.md`
- Verification Scripts: `scripts/verify_calculators.py`
- Test Generator: `scripts/generate_playwright_test.py`

## Notes

- **Recommended for Claude Code CLI users**: This skill uses Docker Desktop MCP Toolkit
- Docker MCP Gateway provides team collaboration and CI/CD-ready configuration
- For CI/CD integration, see `references/workflow.md` GitHub Actions section
- Playwright runs identically on macOS, Linux, and Windows via Docker
- All test data based on peer-reviewed medical literature
- Generated Playwright tests can run independently in CI pipelines
- `.mcp.json` should be committed to git for team sharing
