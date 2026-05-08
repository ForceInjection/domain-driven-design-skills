---
name: e2e-page-test
description: Systematically test all pages for errors, functionality, and proper rendering using Playwright MCP
---

# E2E Page Testing Skill

## Overview

This skill systematically tests every page in an application using Playwright MCP. It verifies page loading, element rendering, interaction functionality, and error detection.

## Standard Test Plan Location

**Plan file**: `tests/e2e-test-plan.md`

This skill reads the page inventory from the test plan at `tests/e2e-test-plan.md`. If the plan file doesn't exist, the calling command should invoke the `e2e-test-plan` skill first to generate it.

## Purpose

Ensure that:
- All pages load without errors
- All expected elements are present
- All interactions work correctly
- No console or network errors occur
- Pages are accessible and functional

## Workflow

### Step -1: Test Plan Verification (REQUIRED FIRST)

**CRITICAL**: Before testing pages, verify the test plan exists.

1. **Check for Test Plan**
   - Look for `tests/e2e-test-plan.md`
   - If the file exists, read the "Pages to Test" section
   - If the file does NOT exist, STOP and report that the plan must be generated first

2. **Read Page List from Plan**
   - Extract public pages
   - Extract authenticated pages
   - Extract admin pages
   - Use this list for testing

### Step 0: Build Assets & Verify URL (CRITICAL - DO THIS FIRST)

**Before testing any pages, build assets and verify the application is accessible.**

#### 0a. Build Application Assets

Missing assets are a common cause of E2E test failures. Before testing:

1. **Check for package.json**
   ```
   Look for package.json in project root
   If found, assets likely need building
   ```

2. **Run Build Commands**
   ```
   npm install      # If node_modules missing
   npm run build    # Compile production assets
   # or for dev server:
   npm run dev      # Start Vite/webpack dev server
   ```

3. **Detect Build Issues**
   After loading a page, check for:
   - Unstyled content (missing CSS)
   - Blank pages (missing JS)
   - Console errors: "Failed to load resource"
   - Network 404s for .js, .css, .png files
   - Errors about /build/, /dist/, /assets/

   If assets are missing:
   - Stop testing
   - Run `npm install && npm run build`
   - Restart and retest

#### 0b. URL/Port Verification

1. **Navigate to Base URL**
   ```
   browser_navigate({ url: base_url })
   browser_snapshot()
   ```

2. **Verify Correct Application**
   Check the snapshot for:
   - ✅ Application name, logo, or known branding
   - ✅ Expected navigation structure
   - ✅ Known page elements from codebase analysis
   - ❌ Default server pages ("Welcome to nginx!", "It works!", "Apache2 Ubuntu Default Page")
   - ❌ Connection errors ("This site can't be reached", "Connection refused")
   - ❌ Different/unexpected application content

3. **Port Discovery (if verification fails)**
   If the page doesn't match expected application:
   ```
   Common ports to try:
   - http://localhost:8000  (Laravel/Django)
   - http://localhost:8080  (Common alternative)
   - http://localhost:3000  (Node.js/React/Next.js)
   - http://localhost:5173  (Vite dev server)
   - http://localhost:5174  (Vite alternative port)
   - http://localhost:5000  (Flask/Python)
   - http://localhost:4200  (Angular)
   - http://localhost:8888  (Jupyter/custom)
   ```

   For each port:
   ```
   browser_navigate({ url: "http://localhost:{port}" })
   browser_snapshot()
   // Check if this matches the expected application
   // If yes, use this as the new base URL
   ```

4. **Check Project Configuration**
   If port discovery fails, look for hints in:
   - `.env` file (APP_PORT, PORT, VITE_PORT, SERVER_PORT)
   - `package.json` scripts (look for --port flags)
   - `vite.config.js/ts` (server.port setting)
   - `docker-compose.yml` (port mappings)
   - `.env.example` for default port values

5. **Proceed or Stop**
   - If correct URL found: Update base_url and continue testing
   - If URL differs from provided: Log warning in test report
   - If no working URL found: **STOP TESTING** and report error
     - "Application not accessible at {provided_url}"
     - "Ports attempted: 8000, 8080, 3000, 5173, 5000, 4200"
     - "Suggestion: Verify the development server is running"

### Step 1: Page Inventory

1. **List All Pages**
   - Extract from route definitions
   - Include dynamic route patterns
   - Note authentication requirements

2. **Categorize Pages**
   - Public pages
   - Authenticated pages
   - Admin pages
   - Special pages (error pages, maintenance, etc.)

3. **Define Expected Elements**
   - Navigation elements
   - Main content areas
   - Forms and inputs
   - Action buttons
   - Footer elements

### Step 2: Page Load Testing

For EACH page:

1. **Navigate to Page**
   ```
   browser_navigate({ url: "/page-path" })
   ```

2. **Wait for Load**
   ```
   browser_wait_for({ text: "Expected content" })
   OR
   browser_wait_for({ time: 2 })
   ```

3. **Capture Snapshot**
   ```
   browser_snapshot()
   ```

4. **Check Console Messages**
   ```
   browser_console_messages({ level: "error" })
   ```

5. **Check Network Requests**
   ```
   browser_network_requests()
   ```

### Step 3: Element Verification

For each page, verify:

1. **Navigation**
   - Header present
   - Menu items visible
   - Logo displayed
   - Navigation links work

2. **Main Content**
   - Title/heading present
   - Expected content visible
   - Images loaded
   - Data displayed (if applicable)

3. **Forms (if present)**
   - All inputs visible
   - Labels present
   - Submit button enabled
   - Validation messages work

4. **Footer**
   - Footer visible
   - Links work
   - Copyright present

### Step 4: Interaction Testing

1. **Link Testing**
   ```
   For each link on page:
     browser_click on link
     browser_snapshot to verify destination
     browser_navigate_back
   ```

2. **Button Testing**
   ```
   For each button:
     browser_click on button
     Verify expected action occurs
     Check for errors
   ```

3. **Form Testing**
   ```
   browser_fill_form with test data
   browser_click submit
   Verify success or validation errors
   ```

4. **Dropdown Testing**
   ```
   browser_select_option on dropdowns
   Verify selection applied
   ```

### Step 5: Error Detection

1. **Console Errors**
   ```
   browser_console_messages({ level: "error" })

   Common errors to detect:
   - Uncaught exceptions
   - Failed to load resource
   - CORS errors
   - API errors
   - Component errors
   ```

2. **Network Errors**
   ```
   browser_network_requests()

   Check for:
   - 4xx errors (client errors)
   - 5xx errors (server errors)
   - Failed requests
   - Timeout errors
   ```

3. **Visual Errors**
   ```
   browser_snapshot()

   Look for:
   - Broken layout
   - Missing images
   - Overlapping elements
   - Unreadable text
   ```

### Step 6: Responsive Testing

Test each page at multiple viewports:

1. **Desktop (1920x1080)**
   ```
   browser_resize({ width: 1920, height: 1080 })
   browser_navigate to page
   browser_snapshot
   Verify desktop layout
   ```

2. **Tablet (768x1024)**
   ```
   browser_resize({ width: 768, height: 1024 })
   browser_navigate to page
   browser_snapshot
   Verify tablet layout
   ```

3. **Mobile (375x812)**
   ```
   browser_resize({ width: 375, height: 812 })
   browser_navigate to page
   browser_snapshot
   Verify mobile layout
   Verify mobile menu works
   ```

## Test Patterns

### Asset Build Verification (RUN BEFORE TESTING)
```
// Step 1: Check if assets need building
1. Check for package.json in project root
2. If node_modules missing: run npm install
3. Run npm run build (or npm run prod)

// Step 2: Verify assets after page load
4. browser_navigate to any page
5. browser_snapshot() - check for styled content
6. browser_console_messages({ level: "error" })
   - Look for "Failed to load resource"
   - Look for "404 (Not Found)"
   - Look for module/import errors
7. browser_network_requests()
   - Check for 404s on .js, .css, .png files
   - Check for failed requests to /build/, /dist/, /assets/

// If assets missing:
8. STOP testing
9. Report: "Assets not built. Run: npm install && npm run build"
10. After build, restart testing
```

### URL Verification Test (RUN FIRST)
```
// Step 1: Try provided URL
1. browser_navigate({ url: base_url })
2. snapshot = browser_snapshot()

// Step 2: Check if correct application
3. If snapshot shows:
   - "Welcome to nginx!" → WRONG URL
   - "It works!" → WRONG URL
   - "Apache2 Ubuntu Default Page" → WRONG URL
   - "This site can't be reached" → CONNECTION ERROR
   - Expected app content → CORRECT URL ✓

// Step 3: Port discovery if needed
4. If WRONG URL:
   ports = [8000, 8080, 3000, 5173, 5174, 5000, 4200]
   for port in ports:
     browser_navigate({ url: `http://localhost:${port}` })
     snapshot = browser_snapshot()
     if snapshot shows expected app content:
       base_url = `http://localhost:${port}`
       break

// Step 4: Report result
5. If correct URL found:
   Log: "Application verified at {base_url}"
   Continue with testing

6. If no correct URL:
   STOP TESTING
   Report: "Cannot find application. Ports tried: ..."
```

### Basic Page Test
```
1. browser_navigate({ url: "/page" })
2. browser_wait_for({ time: 2 }) // Wait for load
3. snapshot = browser_snapshot()
4. errors = browser_console_messages({ level: "error" })
5. requests = browser_network_requests()

// Verify
Assert: snapshot contains expected elements
Assert: errors is empty
Assert: no failed requests in network
```

### Form Page Test
```
1. browser_navigate({ url: "/form-page" })
2. browser_snapshot() // Verify form present

// Test empty submission
3. browser_click({ element: "Submit button", ref: "[submit-ref]" })
4. browser_snapshot() // Should show validation errors

// Test valid submission
5. browser_fill_form({
     fields: [
       { name: "Name", type: "textbox", ref: "[name-ref]", value: "Test User" },
       { name: "Email", type: "textbox", ref: "[email-ref]", value: "test@example.com" }
     ]
   })
6. browser_click({ element: "Submit button", ref: "[submit-ref]" })
7. browser_wait_for({ text: "Success" })
8. browser_snapshot() // Verify success
```

### Navigation Test
```
1. browser_navigate({ url: "/" })
2. browser_snapshot() // Get all navigation refs

For each nav link:
3. browser_click({ element: "Nav link", ref: "[link-ref]" })
4. browser_snapshot() // Verify correct page loaded
5. browser_navigate_back()
```

### Dynamic Content Test
```
1. browser_navigate({ url: "/data-page" })
2. browser_wait_for({ text: "Loading..." }) // Wait for loading state
3. browser_wait_for({ textGone: "Loading..." }) // Wait for content
4. browser_snapshot() // Verify data displayed
5. browser_console_messages({ level: "error" }) // Check for errors
```

## Common Page Types

### Home Page
```markdown
Expected Elements:
- Hero section with headline
- Feature highlights
- Call-to-action buttons
- Navigation header
- Footer

Tests:
- [ ] Hero content visible
- [ ] CTA buttons clickable
- [ ] Navigation works
- [ ] Footer links work
```

### Login Page
```markdown
Expected Elements:
- Email/username field
- Password field
- Submit button
- Forgot password link
- Register link

Tests:
- [ ] Form displays correctly
- [ ] Empty submission shows errors
- [ ] Invalid credentials show error
- [ ] Valid credentials redirect
- [ ] Forgot password link works
```

### Dashboard Page
```markdown
Expected Elements:
- Welcome message
- Statistics/widgets
- Navigation sidebar
- User menu
- Action buttons

Tests:
- [ ] Loads for authenticated users
- [ ] Redirects unauthenticated users
- [ ] Widgets display data
- [ ] Actions are functional
```

### List Page
```markdown
Expected Elements:
- Data table or list
- Pagination
- Search/filter
- Action buttons (edit, delete)

Tests:
- [ ] Data displays correctly
- [ ] Pagination works
- [ ] Search filters data
- [ ] Actions are functional
- [ ] Empty state handled
```

### Form Page
```markdown
Expected Elements:
- Form fields
- Labels
- Validation messages
- Submit button
- Cancel button

Tests:
- [ ] All fields editable
- [ ] Validation works
- [ ] Submit saves data
- [ ] Cancel returns to list
- [ ] Required fields enforced
```

## Output Format

### Page Test Results
```markdown
# Page Test Results

## Pre-Test Verification

### Asset Build Status
- Build command run: npm run build ✓
- Assets compiled: Yes
- CSS loaded: Yes
- JavaScript loaded: Yes
- No 404 errors on assets: Yes

(or if assets were missing:)
- Build command run: No ⚠️
- Assets compiled: No
- Issue: Missing /build/assets/app.js (404)
- Resolution: Ran `npm install && npm run build`
- Retested: All assets now loading ✓

### URL Verification
- Provided URL: http://localhost:8000
- Verified URL: http://localhost:8000 ✓
- Status: Application confirmed

(or if port was different:)
- Provided URL: http://localhost:8000
- Verified URL: http://localhost:3000 ⚠️
- Status: Application found on different port
- Note: Server appears to be running on port 3000

## Summary
- Total Pages: 25
- Passed: 23
- Failed: 2
- Skipped: 0

## Detailed Results

### Public Pages

#### Home (/)
- Status: PASSED
- Load Time: 1.2s
- Console Errors: 0
- Network Errors: 0
- Elements Verified:
  - [x] Header navigation
  - [x] Hero section
  - [x] Feature cards
  - [x] Footer

#### About (/about)
- Status: PASSED
- Load Time: 0.8s
- Console Errors: 0
- Network Errors: 0
- Elements Verified:
  - [x] Page title
  - [x] Content sections
  - [x] Team members

### Authenticated Pages

#### Dashboard (/dashboard)
- Status: FAILED
- Load Time: 2.5s
- Console Errors: 1
  - Error: "Cannot read property 'name' of undefined"
- Network Errors: 0
- Elements Verified:
  - [x] Welcome message
  - [ ] Statistics widget - MISSING
  - [x] Recent activity

#### Profile (/profile)
- Status: PASSED
- Load Time: 1.1s
- Console Errors: 0
- Network Errors: 0
- Elements Verified:
  - [x] User information
  - [x] Edit button
  - [x] Avatar

### Responsive Tests

#### Home Page
- Desktop (1920x1080): PASSED
- Tablet (768x1024): PASSED
- Mobile (375x812): FAILED
  - Issue: Navigation menu overlaps content

## Errors Found

1. **Dashboard Widget Error**
   - Page: /dashboard
   - Error: Cannot read property 'name' of undefined
   - Likely Cause: User data not loaded before rendering

2. **Mobile Navigation Issue**
   - Page: /home
   - Issue: Navigation overlaps on mobile
   - Likely Cause: CSS media query issue

## Recommendations

1. Fix Dashboard data loading sequence
2. Adjust mobile navigation CSS
3. Add loading states for async data
```

## Best Practices

1. **Wait for Page Load** - Don't check elements too quickly
2. **Use Snapshots** - Capture state at each step
3. **Check Console/Network** - Look for hidden errors
4. **Test All Viewports** - Responsive issues are common
5. **Document Everything** - Note all elements tested
6. **Test Interactions** - Don't just check static content
7. **Handle Dynamic Content** - Wait for data to load
