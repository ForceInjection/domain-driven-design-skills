---
name: Check Visual Test Status
description: Check the status of Vizzly visual regression tests. Use when the user asks about test status, test results, what's failing, how tests are doing, or wants a summary of visual tests. Works with both local TDD and cloud modes.
allowed-tools: mcp__plugin_vizzly_vizzly__get_tdd_status, mcp__plugin_vizzly_vizzly__detect_context
---

# Check Visual Test Status

Automatically check Vizzly visual test status when the user asks about their tests. Provides a quick summary of passed, failed, and new screenshots.

## When to Use This Skill

Activate this Skill when the user:
- Asks "How are my tests doing?"
- Asks "Are there any failing tests?"
- Asks "What's the status of visual tests?"
- Asks "Show me test results"
- Asks "What's failing?"
- Wants a summary of visual regression tests

## How This Skill Works

1. **Detect context** (local TDD or cloud mode)
2. **Fetch TDD status** from the local server
3. **Analyze results** to identify failures, new screenshots, and passes
4. **Provide summary** with actionable information
5. **Link to dashboard** for detailed review

## Instructions

### Step 1: Get TDD Status

Use the `get_tdd_status` tool from the Vizzly MCP server to fetch current comparison results.

This returns:
- Total screenshot count
- Passed, failed, and new screenshot counts
- List of all comparisons with details
- Dashboard URL (if TDD server is running)

### Step 2: Analyze the Results

Examine the comparison data:
- Count total, passed, failed, and new screenshots
- Identify which specific screenshots failed
- Note diff percentages for failures
- Check if new screenshots need baselines

### Step 3: Provide Clear Summary

Format the output to be scannable and actionable:

```
Vizzly TDD Status:
✅ Total: [count] screenshots
✅ Passed: [count]
❌ Failed: [count] (exceeded threshold)
🆕 New: [count] (no baseline)

Failed Comparisons:
- [name] ([diff]% diff) - Exceeds [threshold]% threshold
- [name] ([diff]% diff) - Exceeds [threshold]% threshold

New Screenshots:
- [name] (no baseline for comparison)

Dashboard: http://localhost:47392
```

### Step 4: Suggest Next Steps

Based on the results, provide guidance:

**If there are failures:**
- Suggest using the debug-visual-regression Skill for detailed analysis
- Provide dashboard link for visual review
- Mention accept/reject options

**If there are new screenshots:**
- Explain that new screenshots need baseline approval
- Show how to accept them from dashboard or CLI

**If all passed:**
- Confirm tests are passing
- No action needed

## Example Output

```
User: "How are my tests?"

Vizzly TDD Status:
✅ Total: 15 screenshots
✅ Passed: 12
❌ Failed: 2 (exceeded threshold)
🆕 New: 1 (no baseline)

Failed Comparisons:
- homepage (2.3% diff) - Exceeds 0.1% threshold
  Check .vizzly/diffs/homepage.png
- login-form (1.8% diff) - Exceeds 0.1% threshold
  Check .vizzly/diffs/login-form.png

New Screenshots:
- dashboard (no baseline for comparison)

Dashboard: http://localhost:47392

Next Steps:
- Review diff images to understand what changed
- Accept baselines from dashboard if changes are intentional
- For detailed analysis of failures, ask me to debug specific screenshots
- Fix visual issues if changes are unintentional
```

## Example When All Pass

```
User: "Are my visual tests passing?"

Vizzly TDD Status:
✅ Total: 15 screenshots
✅ All passed!

No visual regressions detected. All screenshots match their baselines.

Dashboard: http://localhost:47392
```

## Example When TDD Not Running

```
User: "How are my tests?"

Vizzly TDD Status:
❌ TDD server is not running

To start TDD mode:
  vizzly tdd start

Then run your tests to capture screenshots.
```

## Important Notes

- **Quick status check** - Designed for fast overview, not detailed analysis
- **Use dashboard for visuals** - Link to dashboard for image review
- **Suggest next steps** - Always provide actionable guidance
- **Detect TDD mode** - Only works with local TDD server running
- **For detailed debugging** - Suggest using debug-visual-regression Skill

## Focus on Actionability

Always end with clear next steps:
- What to investigate
- Which tools to use (dashboard, debug Skill)
- How to accept/reject baselines
- When to fix code vs accept changes
