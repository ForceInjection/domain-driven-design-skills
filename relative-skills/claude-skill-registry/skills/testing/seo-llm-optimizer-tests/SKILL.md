---
name: seo-llm-optimizer-tests
description: Test specifications for SEO & LLM Optimizer WordPress plugin. Use when testing the SEO & LLM Optimizer plugin, verifying Copy for AI functionality, or checking markdown/RAG export features.
---

# SEO & LLM Optimizer - Test Specification

This Skill defines comprehensive test procedures for the SEO & LLM Optimizer WordPress plugin.

## Plugin Overview

**Plugin Name:** SEO & LLM Optimizer
**Plugin Slug:** seo-llm-optimizer
**Version:** 1.0.0
**Purpose:** Convert WordPress content to AI-friendly formats (Markdown, RAG-ready chunks)

**Key Features:**
- Frontend "Copy for AI" button on posts/pages
- 3 chunking strategies (hierarchical, fixed-size, semantic)
- REST API with 8 endpoints
- Multiple export formats (Universal, LangChain, LlamaIndex)
- Rate limiting and caching
- Settings page for configuration

## Test Environment Setup

**Required Content:**
Create at least one published post for frontend testing:
```bash
cd /Users/mikkelfreltoftkrogsholm/Projekter/wp-plugins && ./test.sh wp post create \
  --post_title="AI-Optimized Test Post" \
  --post_content="<h2>Introduction</h2><p>This is a test post for the SEO & LLM Optimizer plugin. It contains multiple paragraphs and headings for proper chunk testing.</p><h2>Main Content</h2><p>The plugin should convert this content to markdown format and create chunks based on the selected strategy.</p><h3>Subheading</h3><p>This paragraph tests hierarchical chunking.</p>" \
  --post_status=publish
```

**Plugin Activation:**
```bash
cd /Users/mikkelfreltoftkrogsholm/Projekter/wp-plugins && ./test.sh activate seo-llm-optimizer
```

## Test Suite

### 1. Plugin Activation Verification

**Objective:** Verify plugin activates without errors

**Steps:**
1. Check plugin status: `./test.sh plugins`
2. Verify "seo-llm-optimizer" shows as "active"
3. Check WordPress debug log for PHP errors: `./test.sh debug`
4. Verify no fatal errors or warnings

**Expected Result:**
- Plugin status shows "active"
- No PHP errors in debug log
- WordPress admin accessible

**Category:** Installation

---

### 2. Admin Menu Presence

**Objective:** Verify plugin adds admin menu item

**Steps:**
1. Login to WordPress admin
2. Take snapshot of admin sidebar
3. Look for "SEO & LLM Optimizer" menu item
4. Click menu item
5. Verify settings page loads

**Expected Result:**
- Menu item "SEO & LLM Optimizer" appears in admin sidebar
- Clicking menu navigates to plugin settings page
- URL matches pattern: `/wp-admin/admin.php?page=seo-llm-optimizer`

**Category:** UI - Admin

---

### 3. Settings Page Rendering

**Objective:** Verify settings page renders correctly

**Steps:**
1. Navigate to plugin settings: `/wp-admin/admin.php?page=seo-llm-optimizer`
2. Take snapshot of settings page
3. Take screenshot for documentation
4. Verify presence of settings sections:
   - Chunking Strategy
   - Export Format
   - Rate Limiting
   - Caching
5. Check console for JavaScript errors
6. Verify submit button present

**Expected Result:**
- Settings page loads without errors
- All settings sections visible
- Form fields render correctly
- No JavaScript console errors
- Save button present with proper styling

**Category:** UI - Admin

---

### 4. Settings Save Functionality

**Objective:** Verify settings can be saved

**Steps:**
1. Navigate to settings page
2. Change chunking strategy (select different option)
3. Change export format (select different option)
4. Click "Save Settings" button
5. Wait for success message
6. Reload page
7. Verify settings persisted

**Expected Result:**
- Save button triggers form submission
- Success message appears
- Settings persist after page reload
- No console errors during save

**Category:** Functionality - Admin

---

### 5. Frontend "Copy for AI" Button - Presence

**Objective:** Verify button appears on published posts

**Steps:**
1. Navigate to published post URL (get from test content creation)
2. Take snapshot of post page
3. Scroll through page content
4. Look for "Copy for AI" button
5. Take screenshot showing button location
6. Verify button styling matches theme

**Expected Result:**
- "Copy for AI" button visible on post page
- Button has appropriate styling (not broken CSS)
- Button appears in logical location (below content or in sidebar)

**Element Identifiers to Look For:**
- Button text: "Copy for AI" or "Copy Markdown" or similar
- Possible IDs: `copy-for-ai-button`, `seo-llm-copy-button`
- Possible classes: `copy-ai-btn`, `seo-llm-button`

**Category:** UI - Frontend

---

### 6. Frontend "Copy for AI" Button - Click Interaction

**Objective:** Verify button click triggers expected behavior

**Steps:**
1. Navigate to published post
2. Locate "Copy for AI" button
3. Click button
4. Check for modal/dialog appearing
5. OR check for clipboard action (success message)
6. Verify expected UI response

**Expected Result:**
- Button click triggers action (no 404 or console error)
- Modal appears with markdown content, OR
- Clipboard copy success message appears, OR
- Download of markdown file initiates
- No JavaScript errors in console

**Category:** Functionality - Frontend

---

### 7. JavaScript Asset Loading

**Objective:** Verify plugin JavaScript loads correctly

**Steps:**
1. Navigate to published post
2. Open network requests: `list_network_requests(resourceTypes: ["script"])`
3. Look for plugin JavaScript files
4. Verify all plugin JS files return 200 status
5. Check console for any script errors

**Expected Plugin Assets:**
- May include: `copy-for-ai.js`, `seo-llm-optimizer.js`, or similar
- Should load from `/wp-content/plugins/seo-llm-optimizer/assets/js/`

**Expected Result:**
- All plugin JavaScript files load successfully (200)
- No 404 errors for plugin assets
- No console errors related to missing scripts

**Category:** Assets - Frontend

---

### 8. CSS Asset Loading

**Objective:** Verify plugin styles load correctly

**Steps:**
1. Navigate to published post
2. Open network requests: `list_network_requests(resourceTypes: ["stylesheet"])`
3. Look for plugin CSS files
4. Verify all plugin CSS files return 200 status
5. Inspect button styling to confirm CSS applied

**Expected Plugin Assets:**
- May include: `copy-for-ai.css`, `seo-llm-optimizer.css`, or similar
- Should load from `/wp-content/plugins/seo-llm-optimizer/assets/css/`

**Expected Result:**
- All plugin CSS files load successfully (200)
- Button has proper styling (not default browser button)
- No broken/missing styles

**Category:** Assets - Frontend

---

### 9. REST API - Endpoint Availability

**Objective:** Verify REST API endpoints are registered

**Steps:**
1. Use evaluate_script to discover endpoints:
```javascript
async () => {
  const response = await fetch('/wp-json/');
  const data = await response.json();
  return data.routes;
}
```
2. Look for plugin namespace: `/seo-llm/v1`
3. Verify expected endpoints present

**Expected Endpoints:**
- `/wp-json/seo-llm/v1/content/{id}/markdown`
- `/wp-json/seo-llm/v1/content/{id}/chunks`
- `/wp-json/seo-llm/v1/content/{id}/export`
- Additional endpoints as documented

**Expected Result:**
- Plugin namespace `/seo-llm/v1` present in API routes
- All documented endpoints registered
- Endpoints return proper route definitions

**Category:** API

---

### 10. REST API - Get Markdown Endpoint

**Objective:** Verify markdown conversion endpoint works

**Steps:**
1. Get ID of test post (from post creation or use 1)
2. Use evaluate_script to call endpoint:
```javascript
async () => {
  const response = await fetch('/wp-json/seo-llm/v1/content/1/markdown');
  const data = await response.json();
  return {
    status: response.status,
    ok: response.ok,
    contentType: response.headers.get('content-type'),
    data: data
  };
}
```
3. Verify response structure

**Expected Result:**
- Response status: 200
- Content-Type: application/json
- Response contains markdown content
- Markdown includes post title and content
- HTML properly converted to markdown (headings, paragraphs)

**Category:** API

---

### 11. REST API - Get Chunks Endpoint

**Objective:** Verify content chunking endpoint works

**Steps:**
1. Use evaluate_script to call chunks endpoint:
```javascript
async () => {
  const response = await fetch('/wp-json/seo-llm/v1/content/1/chunks');
  const data = await response.json();
  return {
    status: response.status,
    chunks: data.chunks ? data.chunks.length : 0,
    data: data
  };
}
```
2. Verify response contains chunks array

**Expected Result:**
- Response status: 200
- Response contains `chunks` array
- Each chunk has expected properties (text, metadata)
- Number of chunks > 0 for test content

**Category:** API

---

### 12. REST API - Error Handling (Invalid Post ID)

**Objective:** Verify API returns proper errors for invalid requests

**Steps:**
1. Use evaluate_script to call endpoint with invalid ID:
```javascript
async () => {
  const response = await fetch('/wp-json/seo-llm/v1/content/99999/markdown');
  const data = await response.json();
  return {
    status: response.status,
    data: data
  };
}
```

**Expected Result:**
- Response status: 404 (Not Found)
- Response contains error message
- Error message is meaningful (not generic PHP error)

**Category:** API - Error Handling

---

### 13. REST API - Rate Limiting

**Objective:** Verify rate limiting protects API

**Steps:**
1. Use evaluate_script to make multiple rapid requests:
```javascript
async () => {
  const results = [];
  for (let i = 0; i < 20; i++) {
    const response = await fetch('/wp-json/seo-llm/v1/content/1/markdown');
    results.push({
      attempt: i + 1,
      status: response.status
    });
  }
  return results;
}
```
2. Check if rate limiting kicks in

**Expected Result:**
- First several requests succeed (200)
- After threshold, requests return 429 (Too Many Requests)
- OR all requests succeed if rate limit is high for testing

**Note:** Rate limit behavior depends on plugin configuration

**Category:** API - Security

---

### 14. Settings - Chunking Strategy Options

**Objective:** Verify different chunking strategies work

**Steps:**
1. Navigate to settings page
2. Verify chunking strategy options present:
   - Hierarchical (based on headings)
   - Fixed-size (by character count)
   - Semantic (by content meaning)
3. Select each strategy and save
4. Call chunks API endpoint
5. Verify chunks differ based on strategy

**Expected Result:**
- All three strategies available in settings
- Strategy selection saves correctly
- API chunks endpoint respects selected strategy
- Different strategies produce different chunk boundaries

**Category:** Functionality - Settings

---

### 15. Settings - Export Format Options

**Objective:** Verify export format options work

**Steps:**
1. Navigate to settings page
2. Verify export format options present:
   - Universal (generic JSON)
   - LangChain (LangChain format)
   - LlamaIndex (LlamaIndex format)
3. Select each format and save
4. Call export endpoint
5. Verify format matches selection

**Expected Result:**
- All export formats available in settings
- Format selection saves correctly
- Export endpoint returns data in selected format
- Different formats have distinct structures

**Category:** Functionality - Settings

---

### 16. Console Error Sweep

**Objective:** Comprehensive check for JavaScript errors

**Steps:**
1. Navigate to admin settings page
2. Check console: `list_console_messages(types: ["error"])`
3. Navigate to frontend post page
4. Check console: `list_console_messages(types: ["error"])`
5. Click "Copy for AI" button
6. Check console again
7. Document any errors found

**Expected Result:**
- Zero JavaScript errors on admin page
- Zero JavaScript errors on frontend page
- Zero JavaScript errors after button interaction
- Any errors are documented with context

**Category:** Quality Assurance

---

### 17. Network Performance Check

**Objective:** Verify reasonable network performance

**Steps:**
1. Navigate to frontend post page
2. List all network requests: `list_network_requests()`
3. Count total requests
4. Check for slow requests (over 1 second)
5. Verify no duplicate requests

**Expected Result:**
- Reasonable request count (under 50 for simple page)
- Plugin assets load quickly (under 500ms)
- No duplicate/redundant requests
- No excessive API calls

**Category:** Performance

---

### 18. Mobile Responsiveness (Optional)

**Objective:** Verify button works on mobile viewport

**Steps:**
1. Resize page to mobile: `resize_page(width: 375, height: 667)`
2. Navigate to post page
3. Take screenshot
4. Verify button visible and usable
5. Test button click on mobile size

**Expected Result:**
- Button visible on mobile viewport
- Button tap target is adequate (not too small)
- Button functionality works on mobile

**Category:** UI - Responsive

---

### 19. Accessibility - Keyboard Navigation

**Objective:** Verify button is keyboard accessible

**Steps:**
1. Navigate to post page
2. Use press_key to tab to button: `press_key(key: "Tab")`
3. Verify button receives focus
4. Press Enter to activate: `press_key(key: "Enter")`
5. Verify button action triggers

**Expected Result:**
- Button is reachable via keyboard navigation
- Button shows focus indicator
- Enter key activates button
- Functionality works without mouse

**Category:** Accessibility

---

### 20. Security - Nonce Verification (Settings Form)

**Objective:** Verify settings form uses security nonces

**Steps:**
1. Navigate to settings page
2. Take snapshot with verbose mode: `take_snapshot(verbose: true)`
3. Look for hidden input fields with name containing "nonce" or "_wpnonce"
4. Verify nonce field present

**Expected Result:**
- Settings form contains WordPress nonce field
- Nonce field name ends with "_wpnonce" or similar
- Nonce value is non-empty random string

**Category:** Security

---

## Test Execution Order

**Recommended test sequence:**

1. **Setup Phase:**
   - Plugin Activation Verification (Test 1)
   - Create test content

2. **Admin Interface Phase:**
   - Admin Menu Presence (Test 2)
   - Settings Page Rendering (Test 3)
   - Settings Save Functionality (Test 4)
   - Settings - Chunking Strategy Options (Test 14)
   - Settings - Export Format Options (Test 15)

3. **Frontend Interface Phase:**
   - Frontend "Copy for AI" Button - Presence (Test 5)
   - JavaScript Asset Loading (Test 7)
   - CSS Asset Loading (Test 8)
   - Frontend "Copy for AI" Button - Click Interaction (Test 6)

4. **API Testing Phase:**
   - REST API - Endpoint Availability (Test 9)
   - REST API - Get Markdown Endpoint (Test 10)
   - REST API - Get Chunks Endpoint (Test 11)
   - REST API - Error Handling (Test 12)
   - REST API - Rate Limiting (Test 13)

5. **Quality Assurance Phase:**
   - Console Error Sweep (Test 16)
   - Network Performance Check (Test 17)
   - Mobile Responsiveness (Test 18)
   - Accessibility - Keyboard Navigation (Test 19)
   - Security - Nonce Verification (Test 20)

## Common Issues and Debugging

### Issue: "Copy for AI" Button Not Visible

**Possible Causes:**
- JavaScript not enqueued on frontend
- CSS not loaded
- Button only shows for logged-in users
- Button only shows on certain post types

**Debugging Steps:**
1. Check network tab for JS/CSS 404s
2. Check console for JavaScript errors
3. Try logging in before viewing post
4. Check if post type is 'post' (not 'page')
5. Inspect DOM source to see if button element exists but hidden

### Issue: REST API Endpoints Return 404

**Possible Causes:**
- Permalinks not flushed after plugin activation
- REST API route registration failed
- Namespace mismatch

**Debugging Steps:**
1. Flush permalinks: `./test.sh wp rewrite flush`
2. Check if any REST endpoints work: `/wp-json/`
3. Check plugin code for REST route registration
4. Check debug.log for PHP errors during init

### Issue: Button Click Does Nothing

**Possible Causes:**
- JavaScript event handler not attached
- JavaScript error preventing execution
- Missing dependency (jQuery, etc.)

**Debugging Steps:**
1. Check console for errors after click
2. Verify JavaScript loaded successfully
3. Use evaluate_script to test if event handler exists
4. Check if button has onclick attribute or event listener

### Issue: Chunks API Returns Empty Array

**Possible Causes:**
- Post content is too short
- Chunking strategy issue
- Content parsing failed

**Debugging Steps:**
1. Verify post has substantial content
2. Try different chunking strategies
3. Check if markdown endpoint works (test text extraction)
4. Check debug.log for PHP warnings during chunking

## Success Criteria

**Minimum passing requirements:**
- Plugin activates without errors (Test 1)
- Admin menu appears (Test 2)
- Settings page loads (Test 3)
- Frontend button appears (Test 5)
- At least one REST API endpoint works (Tests 9-10)
- No critical JavaScript errors (Test 16)

**Full pass requirements:**
- All 20 tests pass
- Zero JavaScript errors
- All API endpoints functional
- Security measures in place (nonces, rate limiting)
- Acceptable performance metrics

## Test Report Template

When reporting results, include:
- Total tests executed
- Pass/fail counts
- Screenshots of failures
- Console errors (if any)
- Network issues (if any)
- Recommendations for fixes
- Next steps

See wp-plugin-tester agent's JSON output format for structured reporting.
