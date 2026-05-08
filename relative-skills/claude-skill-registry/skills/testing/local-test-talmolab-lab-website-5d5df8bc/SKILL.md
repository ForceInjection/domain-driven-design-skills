---
name: local-test
description: Test local Jekyll build and visualize pages using Playwright MCP. Starts the development server, navigates through key pages, captures screenshots, and validates rendering. Use when testing local changes before deployment.
version: 1.0.0
allowed-tools: Bash, BashOutput, KillShell, mcp__playwright__browser_navigate, mcp__playwright__browser_snapshot, mcp__playwright__browser_take_screenshot, mcp__playwright__browser_click, TodoWrite
---

# Local Testing with Playwright MCP

This skill helps you test the Jekyll site locally and visualize pages using Playwright MCP browser automation.

## When to Use This Skill

Use this skill when:
- "Test the local build"
- "Preview the site locally"
- "Visualize local changes"
- "Test with Playwright"
- "Check how the site looks"
- Before committing major changes
- After updating member profiles or content
- When debugging layout or rendering issues

## Prerequisites

Ensure Playwright MCP is installed:
```bash
claude mcp add playwright npx '@playwright/mcp@latest'
```

## Workflow

### Step 1: Start Jekyll Server

1. **Launch the server in background**:
   ```bash
   bundle exec jekyll serve --force_polling --livereload
   ```

   Use `run_in_background: true` to keep the server running while testing.

2. **Wait for server initialization** (8-10 seconds):
   ```bash
   sleep 8
   ```

3. **Check server output**:
   - Use `BashOutput` to verify server started successfully
   - Confirm it's running at `http://127.0.0.1:4000/`
   - Look for "Server running..." message

### Step 2: Navigate to Homepage

1. **Open homepage with Playwright**:
   ```
   mcp__playwright__browser_navigate
   url: http://127.0.0.1:4000/
   ```

2. **Verify page loaded**:
   - Check page title: "Talmo Lab - Home"
   - Review page snapshot structure
   - Look for key elements (banner, navigation, content)

3. **Capture full-page screenshot**:
   ```
   mcp__playwright__browser_take_screenshot
   filename: homepage-screenshot.png
   type: png
   fullPage: true
   ```

### Step 3: Test Key Pages

Navigate and capture screenshots of important pages:

#### Team Page
```
mcp__playwright__browser_navigate
url: http://127.0.0.1:4000/team/
```
- Verify all member portraits load
- Check alumni section formatting
- Take full-page screenshot: `team-page-screenshot.png`

#### Research Page
```
mcp__playwright__browser_navigate
url: http://127.0.0.1:4000/research/
```
- Verify research areas display correctly
- Check images and formatting
- Take screenshot: `research-page-screenshot.png`

#### Publications Page
```
mcp__playwright__browser_navigate
url: http://127.0.0.1:4000/publications/
```
- Verify citations render properly
- Check publication cards/entries
- Take screenshot: `publications-page-screenshot.png`

#### Individual Member Profile
```
mcp__playwright__browser_navigate
url: http://127.0.0.1:4000/members/talmo-pereira.html
```
- Verify profile image displays
- Check bio formatting
- Verify social links work
- Take screenshot: `member-profile-screenshot.png`

### Step 4: Test Interactive Elements (Optional)

If testing navigation or interactive features:

1. **Click navigation links**:
   ```
   mcp__playwright__browser_click
   element: "Research navigation link"
   ref: [element reference from snapshot]
   ```

2. **Hover over portraits**:
   ```
   mcp__playwright__browser_hover
   element: "Member portrait"
   ref: [element reference]
   ```

3. **Test responsive behavior**:
   ```
   mcp__playwright__browser_resize
   width: 375
   height: 667
   ```
   Then take screenshots at mobile size.

### Step 5: Check Console for Errors

Look for any JavaScript errors or 404s:
```
mcp__playwright__browser_console_messages
onlyErrors: true
```

Common issues to check:
- Missing images (404 errors)
- Failed CSS/JS loads
- JavaScript runtime errors

### Step 6: Review Screenshots

Present screenshots to user:
- Show what pages were tested
- Highlight any rendering issues
- Note any console errors found
- Summarize overall build health

### Step 7: Cleanup

1. **Kill the Jekyll server**:
   ```
   KillShell
   shell_id: [server shell ID]
   ```

2. **Confirm cleanup**:
   - Verify server stopped
   - Note that screenshots are saved in `.playwright-mcp/` (gitignored)

## Common Testing Scenarios

### Testing New Member Profile

When adding a new member:

1. Start server
2. Navigate to team page → verify member appears
3. Navigate to member profile → verify all fields render
4. Check profile image displays correctly
5. Verify links (email, GitHub, etc.) are present
6. Take screenshots of both pages

### Testing Layout Changes

When modifying CSS or templates:

1. Start server with livereload
2. Navigate to affected pages
3. Take "before" screenshots
4. Make changes (livereload will auto-refresh)
5. Take "after" screenshots
6. Compare visually

### Testing Publications

When updating `_data/sources.yaml`:

1. Run `./cite.sh` to generate citations
2. Start server
3. Navigate to publications page
4. Verify new publications appear
5. Check formatting of citations
6. Verify links and images

### Full Site Regression Test

Before major deployments:

1. Test all main pages (home, team, research, publications, join)
2. Test sample member profiles (PI, PhD, undergrad, alumni)
3. Check footer and navigation on all pages
4. Test at desktop and mobile sizes
5. Review console for any errors
6. Capture screenshots of all tested pages

## Screenshot Storage

All screenshots are saved to `.playwright-mcp/` directory:
- This directory is automatically gitignored
- Screenshots are for local review only
- Filenames should be descriptive (e.g., `team-page-screenshot.png`)
- Full-page screenshots recommended for complete context

## Troubleshooting

### Server Won't Start

**Error: "Address already in use"**
- Check if Jekyll is already running: `lsof -i :4000`
- Kill existing process: `kill -9 [PID]`
- Restart server

**Error: "Permission denied"**
- Don't run `./start.sh` directly (may not be executable)
- Use: `bundle exec jekyll serve --force_polling --livereload`

### Playwright Can't Connect

**Error: "Navigation failed"**
- Ensure server is fully started (wait 8-10 seconds)
- Check server logs with `BashOutput`
- Verify URL is `http://127.0.0.1:4000/` (not localhost)

**Error: "Browser not installed"**
- Run: `mcp__playwright__browser_install`

### Page Rendering Issues

**Images not loading**
- Check file paths in frontmatter
- Verify images exist in `images/` directory
- Look for 404 errors in console

**Styling broken**
- Check for CSS compilation errors in server logs
- Verify `_sass/` files are valid
- Check browser console for CSS load failures

**Content missing**
- Verify frontmatter is valid YAML
- Check Jekyll build output for warnings
- Look for Liquid template errors in server logs

## Best Practices

1. **Always test locally before committing**:
   - Catches rendering issues early
   - Validates new content appears correctly
   - Ensures no broken links or images

2. **Use descriptive screenshot filenames**:
   - Include page name and purpose
   - Add date for tracking changes over time
   - Example: `team-page-new-members-2025-10-31.png`

3. **Test multiple page types**:
   - Don't just test homepage
   - Verify collection pages (team, publications)
   - Check individual item pages (member profiles)

4. **Keep server logs**:
   - Check `BashOutput` periodically
   - Look for build warnings
   - Note any deprecation notices

5. **Clean up after testing**:
   - Always kill the server when done
   - Review and delete old screenshots
   - Check for any uncommitted test files

## Integration with Development Workflow

### Standard Development Cycle

1. Make changes to content/code
2. Run this skill to test locally
3. Review screenshots and console output
4. Fix any issues found
5. Re-test until satisfied
6. Commit changes
7. Push to GitHub (auto-deploys via GitHub Actions)

### Pre-Commit Hook Integration

Consider testing before commits:
```bash
# In .git/hooks/pre-commit
bundle exec jekyll build --quiet
```

### Continuous Testing

For ongoing development:
- Leave server running with livereload
- Make changes and watch auto-refresh
- Use Playwright to capture specific states
- Take screenshots at milestones

## See Also

- [Jekyll Documentation](https://jekyllrb.com/docs/)
- [Playwright MCP Documentation](https://github.com/anthropics/mcp-playwright)
- CLAUDE.md - Project-specific development guidelines
- `.github/workflows/` - CI/CD configuration
