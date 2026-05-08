---
name: wp-testing-core
description: Core WordPress testing procedures and patterns for browser-based plugin testing. Use when testing WordPress plugins, logging into WordPress admin, verifying plugin activation, or navigating WordPress UI.
---

# WordPress Testing Core Procedures

This Skill provides foundational WordPress testing knowledge and procedures for browser automation testing.

## WordPress Login Procedure

### Standard WordPress Admin Login

**URL Pattern:** `http://localhost:8082/wp-admin` (or your WordPress URL + /wp-admin)

**Steps:**
1. Navigate to WordPress admin URL
2. Take snapshot to see login form state
3. Locate username field (usually ID: `user_login`)
4. Locate password field (usually ID: `user_pass`)
5. Fill username: "admin"
6. Fill password: "password"
7. Click submit button (ID: `wp-submit`)
8. Wait for dashboard to load
9. Verify successful login (look for "Dashboard" in page title or admin bar)

**Example Chrome DevTools Flow:**
```
1. navigate_page(url: "http://localhost:8082/wp-admin")
2. take_snapshot() - Verify login form is visible
3. fill(uid: "username-field-uid", value: "admin")
4. fill(uid: "password-field-uid", value: "password")
5. click(uid: "submit-button-uid")
6. wait_for(text: "Dashboard")
7. take_snapshot() - Confirm admin dashboard loaded
```

**Common Issues:**
- If WordPress installation screen appears instead of login, WordPress needs setup
- If "Site Health" warnings appear, they can usually be ignored for testing
- If login fails, verify credentials in test.sh script or wp-config.php

## Plugin Activation Verification

### Via test.sh Script (Recommended for Setup)

**Check plugin status:**
```bash
cd /Users/mikkelfreltoftkrogsholm/Projekter/wp-plugins && ./test.sh plugins
```

**Activate plugin:**
```bash
cd /Users/mikkelfreltoftkrogsholm/Projekter/wp-plugins && ./test.sh activate [plugin-slug]
```

**Deactivate plugin:**
```bash
cd /Users/mikkelfreltoftkrogsholm/Projekter/wp-plugins && ./test.sh deactivate [plugin-slug]
```

### Via Browser UI (For Verification)

**URL:** `http://localhost:8082/wp-admin/plugins.php`

**Steps:**
1. Navigate to Plugins page
2. Take snapshot to see plugin list
3. Verify plugin appears in list
4. Check if "Activate" or "Deactivate" link is present
5. If showing "Activate", plugin is inactive
6. If showing "Deactivate", plugin is active

**Visual Indicators:**
- Active plugins have white/light background
- Inactive plugins have grey background
- Recently activated plugins show notification banner

## WordPress Admin Navigation Patterns

### Admin Menu Structure

**Common Menu Items:**
- Dashboard (dashboard)
- Posts (edit.php)
- Media (upload.php)
- Pages (edit.php?post_type=page)
- Comments (edit-comments.php)
- Appearance (themes.php)
- Plugins (plugins.php)
- Users (users.php)
- Tools (tools.php)
- Settings (options-general.php)

**Plugin Custom Menus:**
Plugins typically add menu items in two ways:
1. Top-level menu (appears in main sidebar)
2. Submenu under existing menu (e.g., under Settings)

**URL Pattern for Plugin Pages:**
```
/wp-admin/admin.php?page=[plugin-slug]
/wp-admin/admin.php?page=[plugin-slug]-settings
```

### Settings Pages

**Common Settings Submenus:**
- General (options-general.php)
- Writing (options-writing.php)
- Reading (options-reading.php)
- Discussion (options-discussion.php)
- Media (options-media.php)
- Permalinks (options-permalink.php)
- Plugin settings often appear here

**Testing Settings Pages:**
1. Navigate to Settings menu
2. Click plugin's settings submenu
3. Verify page loads without errors
4. Check for proper nonce fields in forms
5. Test save functionality (if needed)

## WordPress Frontend Patterns

### Post/Page Structure

**Single Post URL Pattern:**
```
http://localhost:8082/[post-slug]/
http://localhost:8082/?p=[post-id]
```

**Archive/List Pages:**
```
http://localhost:8082/blog/
http://localhost:8082/category/[category-slug]/
```

**Testing Frontend Features:**
1. Create test post/page (or use existing)
2. Navigate to post URL
3. Take snapshot to see post content
4. Verify plugin elements appear (buttons, widgets, etc.)
5. Check console for JavaScript errors
6. Test interactions (click buttons, etc.)

### Creating Test Content

**Via WP-CLI (Fastest):**
```bash
cd /Users/mikkelfreltoftkrogsholm/Projekter/wp-plugins && ./test.sh wp post create --post_title="Test Post" --post_content="Test content for plugin testing" --post_status=publish
```

**Via Browser:**
1. Navigate to Posts > Add New
2. Enter title and content
3. Click Publish button
4. Note the post URL for testing

## REST API Testing

### WordPress REST API Patterns

**Base URL:** `http://localhost:8082/wp-json/`

**Common Endpoints:**
- Core API: `/wp-json/wp/v2/`
- Plugin custom endpoints: `/wp-json/{namespace}/v1/`

**Testing REST Endpoints:**

**Method 1: Using evaluate_script (In Browser)**
```javascript
async () => {
  const response = await fetch('/wp-json/seo-llm/v1/content/1/markdown');
  const data = await response.json();
  return {
    status: response.status,
    ok: response.ok,
    data: data
  };
}
```

**Method 2: Using Bash (Command Line)**
```bash
curl -s http://localhost:8082/wp-json/seo-llm/v1/content/1/markdown
```

**What to Verify:**
- Response status code (200, 404, 401, etc.)
- Response content-type (application/json)
- JSON structure matches expectations
- Error responses have proper format
- Authentication works (if required)

### REST API Authentication

**Public Endpoints:**
- No authentication needed
- Test directly with fetch or curl

**Protected Endpoints:**
- May require nonce, cookie, or token
- If testing from logged-in browser, cookies should work
- Check plugin documentation for auth requirements

## Console Error Checking

### Monitoring JavaScript Errors

**Get all console messages:**
```
list_console_messages(types: ["error", "warn", "log"])
```

**Filter to errors only:**
```
list_console_messages(types: ["error"])
```

**Common WordPress Console Errors:**
- "jQuery is not defined" - jQuery loading issue
- "Uncaught ReferenceError" - Missing JavaScript dependency
- "404 for .js file" - Asset not enqueued or wrong path
- "Uncaught TypeError: Cannot read property" - JavaScript logic error

**When to Worry:**
- Critical errors preventing functionality
- 404s for plugin assets
- Security warnings
- Multiple repeated errors

**When to Ignore:**
- Browser extension errors
- Third-party tracking script issues
- Deprecated warnings (if plugin still works)

## Network Request Analysis

### Checking Asset Loading

**List all network requests:**
```
list_network_requests()
```

**Filter to specific resource types:**
```
list_network_requests(resourceTypes: ["script", "stylesheet"])
```

**Common Resource Types:**
- script - JavaScript files
- stylesheet - CSS files
- xhr - AJAX requests
- fetch - Fetch API requests
- document - HTML pages

**What to Check:**
- Plugin assets loaded successfully (200 status)
- No 404s for plugin files
- AJAX requests return expected data
- No excessive requests (performance issue)

### Analyzing Failed Requests

**Get specific request details:**
```
get_network_request(reqid: [request-id])
```

**Common Failure Patterns:**
- 404 Not Found - File doesn't exist or wrong path
- 500 Internal Server Error - PHP error in plugin
- 403 Forbidden - Permission issue
- 0 status - Request blocked or CORS issue

## Browser Automation Best Practices

### Taking Snapshots

**Always snapshot before interactions:**
```
take_snapshot() - See what's on page now
fill(uid: "field-uid", value: "test")
click(uid: "button-uid")
take_snapshot() - See result of interaction
```

**Use verbose mode for debugging:**
```
take_snapshot(verbose: true) - Shows detailed element tree
```

**Save snapshots for documentation:**
```
take_snapshot(filePath: "/path/to/snapshot.txt")
```

### Waiting for Dynamic Content

**Wait for specific text to appear:**
```
wait_for(text: "Success", timeout: 5000)
```

**Common wait scenarios:**
- After form submission (wait for success message)
- After AJAX request (wait for content to appear)
- After page navigation (wait for new page to load)

### Handling Timeouts

**Increase timeout for slow operations:**
```
navigate_page(url: "...", timeout: 30000) - 30 seconds
```

**When to use longer timeouts:**
- WordPress admin pages can be slow
- First load after Docker start takes longer
- Pages with lots of plugins loading

## Common WordPress Testing Patterns

### Pattern 1: Verify Admin Menu Item

```
1. Login to WordPress admin
2. Take snapshot of admin sidebar
3. Look for plugin menu item text
4. Verify menu item is present
5. Click menu item
6. Verify settings page loads
```

### Pattern 2: Test Frontend Button

```
1. Navigate to published post
2. Take snapshot to see post content
3. Locate plugin button (by text or ID)
4. Take screenshot of button for documentation
5. Click button
6. Verify expected action (modal opens, etc.)
7. Check console for errors
```

### Pattern 3: Test Settings Form

```
1. Navigate to plugin settings page
2. Take snapshot of form
3. Verify all fields render correctly
4. Fill form fields with test data
5. Click Save button
6. Wait for success message
7. Verify settings were saved (reload page and check)
```

### Pattern 4: Test REST API Endpoint

```
1. Use evaluate_script to call endpoint
2. Verify response status code
3. Check response data structure
4. Test error cases (invalid ID, etc.)
5. Verify authentication (if required)
```

## WordPress-Specific Element Patterns

### Common Element Selectors

**Admin Elements:**
- Admin bar: ID `wpadminbar`
- Main menu: ID `adminmenu`
- Content area: ID `wpbody-content`
- Submit buttons: class `button-primary`
- Form tables: class `form-table`

**Frontend Elements:**
- Post content: class `entry-content`
- Post title: class `entry-title`
- Comments: ID `comments`
- Sidebar: ID `secondary` or class `sidebar`

**Forms:**
- Nonce fields: input with name ending in `_wpnonce`
- Submit buttons: type `submit`
- Settings: wrapped in `<table class="form-table">`

## Debugging WordPress Issues

### Check WordPress Debug Log

```bash
cd /Users/mikkelfreltoftkrogsholm/Projekter/wp-plugins && ./test.sh debug
```

**Common PHP Errors:**
- Fatal error - Plugin code has syntax error or missing file
- Warning - Non-critical issue but should be fixed
- Notice - Minor issue, often undefined variable

### Check Docker Logs

```bash
cd /Users/mikkelfreltoftkrogsholm/Projekter/wp-plugins && ./test.sh logs
```

**What to look for:**
- PHP fatal errors
- MySQL connection issues
- WordPress installation problems
- Apache/Nginx errors

### Environment Reset

**If WordPress is misbehaving:**
```bash
cd /Users/mikkelfreltoftkrogsholm/Projekter/wp-plugins && ./test.sh reset
cd /Users/mikkelfreltoftkrogsholm/Projekter/wp-plugins && ./test.sh install-wp
```

**When to reset:**
- WordPress won't load
- Database is corrupted
- Plugins conflict with each other
- Need clean slate for testing

## Performance Considerations

### Page Load Times

**Normal load times for testing environment:**
- Admin dashboard: 2-5 seconds
- Plugin settings page: 1-3 seconds
- Frontend post: 1-2 seconds

**Slow page indicators:**
- Over 10 seconds to load
- Multiple slow network requests
- Database query issues

### Network Request Volume

**Typical request counts:**
- Admin page: 20-40 requests
- Frontend page: 10-30 requests
- Settings page: 15-25 requests

**Excessive requests:**
- Over 100 requests on single page load
- Repeated duplicate requests
- Unnecessary external API calls

## Security Verification

### Nonce Verification

**All WordPress forms should have nonces:**
- Look for hidden input with name ending in `_wpnonce`
- Nonce value should be long random string
- Form submission should verify nonce on server

### Capability Checks

**Plugin admin pages should check capabilities:**
- Only administrators should access plugin settings
- Check if logged-out users can access admin features (they shouldn't)

### Input Sanitization

**Test with special characters:**
- Try: `<script>alert('XSS')</script>`
- Try: `' OR '1'='1`
- Verify plugin sanitizes input (doesn't execute/display raw)

**Note:** Don't actually try to exploit vulnerabilities, just verify sanitization exists.

## Summary

**Key WordPress Testing Procedures:**
1. Login to admin (user_login, user_pass fields)
2. Navigate using admin menu structure
3. Verify plugin activation status
4. Test both admin and frontend features
5. Monitor console for JavaScript errors
6. Check network requests for failed assets
7. Use test.sh for environment management
8. Create test content for realistic testing
9. Test REST API endpoints with fetch
10. Document with snapshots and screenshots

**WordPress URLs to Know:**
- Admin: `/wp-admin/`
- Plugins: `/wp-admin/plugins.php`
- Settings: `/wp-admin/options-general.php`
- Add Post: `/wp-admin/post-new.php`
- REST API: `/wp-json/`

**Common Issues:**
- 404 for assets (check asset enqueue)
- JavaScript errors (check dependencies)
- Form submissions fail (check nonces)
- Slow loading (check network requests)
- White screen (check PHP errors in debug.log)
