---
name: web-test-case-gen
description: Generate persistent test cases from project analysis, or add individual test cases interactively. Supports full project analysis or adding single test cases via prompt description with browser exploration.
license: MIT
compatibility: Node.js 18+
metadata:
  author: AI Agent
  version: 2.0.0
allowed-tools: Bash Read Write Glob Grep WebSearch WebFetch Skill
---

# Test Case Generation

Generate persistent test cases that can be committed to version control for repeatable testing.

## What This Skill Does

### Full Project Analysis Mode
1. **Runs web-test-research** - Full code tree traversal, UI screenshots, role analysis
2. **Generates comprehensive test cases** - 8 test types for complete coverage
3. **Saves to ./tests/** - In the TARGET PROJECT (not agent-skills)
4. **Ready for git commit** - Test cases persist across sessions

### Test Coverage Types

```
╔════════════════════════════════════════════════════════════════╗
║  8 TYPES OF TEST CASES FOR COMPLETE COVERAGE                   ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  1. FLOW TESTS (FLOW-*)                                        ║
║     - Complete user journey from start to finish               ║
║     - Each module's happy path                                 ║
║     - Alternative paths and error recovery                     ║
║                                                                ║
║  2. UI LAYOUT TESTS (LAYOUT-*)                                 ║
║     - Desktop (1920x1080) layout verification                  ║
║     - Tablet (768x1024) layout verification                    ║
║     - Mobile (375x667) layout verification                     ║
║     - Responsive transitions                                   ║
║                                                                ║
║  3. FUNCTIONALITY TESTS (FUNC-*)                               ║
║     - Input validation (required fields, format, range)        ║
║     - Form submission success and failure                      ║
║     - Error messages and user feedback                         ║
║     - Edge cases and boundary conditions                       ║
║                                                                ║
║  4. NETWORK TESTS (NET-*)                                      ║
║     - High latency behavior (3s+ delay)                        ║
║     - Request timeout handling                                 ║
║     - Network error recovery                                   ║
║     - Retry logic verification                                 ║
║                                                                ║
║  5. ROLE & PERMISSION TESTS (ROLE-*)                           ║
║     - Guest user access restrictions                           ║
║     - Regular user permissions                                 ║
║     - Admin privileges                                         ║
║     - Unauthorized access attempts                             ║
║                                                                ║
║  6. NEGATIVE TESTS (NEG-*)                                     ║
║     - Invalid input handling                                   ║
║     - Error state recovery                                     ║
║     - Transaction rejection                                    ║
║     - Missing data handling                                    ║
║                                                                ║
║  7. SEO & META TESTS (SEO-*)                                   ║
║     - Head element validation (title, description, keywords)   ║
║     - Open Graph meta tags (og:title, og:description, etc)     ║
║     - Twitter Card meta tags                                   ║
║     - Favicon and charset verification                         ║
║                                                                ║
║  8. EXTERNAL LINK TESTS (LINK-*)                               ║
║     - External link accessibility                              ║
║     - 404/Not Found detection                                  ║
║     - Broken link identification                               ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

## Quick Start

### Generate All Test Cases (Full Analysis)

```
Generate test cases for this project
```

### Add Single Test Case (Interactive)

```
Add a test case for: [describe the feature you want to test]
```

## Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│  web-test-case-gen - COMPLETE TEST COVERAGE                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Step 1: Run web-test-research                                  │
│          ↓                                                      │
│          - Full code tree traversal                             │
│          - Module & function mapping                            │
│          - UI screenshots (Desktop/Tablet/Mobile)               │
│          - Role & permission analysis                           │
│          ↓                                                      │
│  Step 2: Generate 8 types of test cases                         │
│          ↓                                                      │
│          - FLOW tests for each module                           │
│          - LAYOUT tests for each viewport                       │
│          - FUNC tests for each function                         │
│          - NET tests for API interactions                       │
│          - ROLE tests for each user role                        │
│          - NEG tests for error scenarios                        │
│          - SEO tests for meta tags & head elements              │
│          - LINK tests for external link validation              │
│          ↓                                                      │
│  Step 3: Write test files                                       │
│          ↓                                                      │
│          - tests/config.yaml                                    │
│          - tests/test-cases.yaml                                │
│          - tests/case-summary.md                                │
│          - tests/README.md                                      │
│          ↓                                                      │
│  Step 4: Output ready for git commit                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Test Type 1: Flow Tests (FLOW-*)

**Purpose:** Verify complete user journeys work correctly.

Based on research module map, generate flow tests for each module:

```yaml
# Flow Test Example: Complete Swap Journey
- id: FLOW-SWAP-001
  name: Complete Token Swap Journey
  type: flow
  module: swap
  feature: Token Swap
  priority: critical
  web3: true
  wallet_popups: 1
  depends_on: [WALLET-001]
  description:
    purpose: |
      Test the complete swap flow from token selection to transaction confirmation.
      Verifies the entire user journey works as designed.
    coverage:
      - Token selection UI
      - Amount input and validation
      - Quote display and refresh
      - Transaction submission
      - Success confirmation
  preconditions:
    - Wallet connected
    - Has native token balance
  steps:
    - action: navigate
      url: /swap
    - action: screenshot
      name: flow-swap-initial
    - action: click
      selector: source token dropdown
    - action: click
      selector: ETH option
    - action: fill
      selector: amount input
      value: "0.1"
    - action: wait
      ms: 2000
      reason: Wait for quote
    - action: screenshot
      name: flow-swap-quote-ready
    - action: click
      selector: destination token dropdown
    - action: click
      selector: USDC option
    - action: click
      selector: Swap button
    - action: wallet-approve
    - action: wait
      ms: 3000
      reason: Wait for transaction
    - action: screenshot
      name: flow-swap-complete
  expected:
    - Token selector shows available tokens
    - Quote displays exchange rate
    - Transaction popup appears
    - Success message after confirmation
    - Balance updated

# Flow Test: Alternative Path (Skip token selection)
- id: FLOW-SWAP-002
  name: Swap with Pre-selected Tokens
  type: flow
  module: swap
  feature: Token Swap
  priority: high
  web3: true
  wallet_popups: 1
  depends_on: [WALLET-001]
  description:
    purpose: |
      Test swap when tokens are already selected from URL params or previous session.
  steps:
    - action: navigate
      url: /swap?from=ETH&to=USDC
    - action: screenshot
      name: flow-swap-preselected
    - action: fill
      selector: amount input
      value: "0.05"
    - action: wait
      ms: 2000
      reason: Wait for quote
    - action: click
      selector: Swap button
    - action: wallet-approve
    - action: screenshot
      name: flow-swap-preselected-complete
  expected:
    - Tokens pre-selected from URL
    - Can proceed directly to amount entry
    - Swap completes successfully
```

## Test Type 2: UI Layout Tests (LAYOUT-*)

**Purpose:** Verify UI displays correctly on different screen sizes.

```yaml
# Desktop Layout Test
- id: LAYOUT-DESKTOP-001
  name: Desktop Layout - Homepage
  type: layout
  module: ui
  feature: Responsive Design
  priority: high
  web3: false
  wallet_popups: 0
  depends_on: []
  viewport:
    width: 1920
    height: 1080
    isMobile: false
  description:
    purpose: |
      Verify homepage displays correctly on desktop (1920x1080).
      Check navigation, content layout, and element spacing.
    layout_checks:
      - Navigation horizontal at top
      - Content centered with max-width
      - Sidebar visible (if applicable)
      - Footer at bottom
  steps:
    - action: set-viewport
      width: 1920
      height: 1080
    - action: navigate
      url: /
    - action: screenshot
      name: layout-desktop-home
    - action: scroll
      direction: down
      pixels: 500
    - action: screenshot
      name: layout-desktop-home-scrolled
  expected:
    - Full horizontal navigation visible
    - Content properly centered
    - No horizontal scroll
    - All elements properly sized
    - Text readable (not too small)

# Tablet Layout Test
- id: LAYOUT-TABLET-001
  name: Tablet Layout - Homepage
  type: layout
  module: ui
  feature: Responsive Design
  priority: high
  web3: false
  wallet_popups: 0
  depends_on: []
  viewport:
    width: 768
    height: 1024
    isMobile: false
  description:
    purpose: |
      Verify homepage displays correctly on tablet (768x1024).
      Check layout adaptation for medium screens.
    layout_checks:
      - Navigation may be condensed
      - Content stacks vertically if needed
      - Touch targets adequately sized
  steps:
    - action: set-viewport
      width: 768
      height: 1024
    - action: navigate
      url: /
    - action: screenshot
      name: layout-tablet-home
  expected:
    - Layout adapts to tablet width
    - Content readable without zoom
    - No overlapping elements
    - Touch targets >= 44x44px

# Mobile Layout Test
- id: LAYOUT-MOBILE-001
  name: Mobile Layout - Homepage
  type: layout
  module: ui
  feature: Responsive Design
  priority: high
  web3: false
  wallet_popups: 0
  depends_on: []
  viewport:
    width: 375
    height: 667
    deviceScaleFactor: 2
    isMobile: true
  description:
    purpose: |
      Verify homepage displays correctly on mobile (375x667 iPhone SE).
      Check mobile-specific navigation and layout.
    layout_checks:
      - Hamburger menu replaces horizontal nav
      - Content single column
      - Touch-friendly buttons
      - Font size >= 16px
  steps:
    - action: set-viewport
      width: 375
      height: 667
      isMobile: true
    - action: navigate
      url: /
    - action: screenshot
      name: layout-mobile-home
    - action: click
      selector: hamburger menu icon
    - action: wait
      ms: 500
      reason: Wait for menu animation
    - action: screenshot
      name: layout-mobile-nav-open
  expected:
    - Hamburger menu visible (not desktop nav)
    - Single column layout
    - No horizontal scroll
    - Text readable without zoom
    - Mobile menu slides in correctly

# Mobile Layout Test - Key Features
- id: LAYOUT-MOBILE-002
  name: Mobile Layout - Swap Page
  type: layout
  module: ui
  feature: Responsive Design
  priority: high
  web3: false
  wallet_popups: 0
  depends_on: []
  viewport:
    width: 375
    height: 667
    isMobile: true
  description:
    purpose: |
      Verify swap page works correctly on mobile.
      Critical for mobile-first users.
  steps:
    - action: set-viewport
      width: 375
      height: 667
      isMobile: true
    - action: navigate
      url: /swap
    - action: screenshot
      name: layout-mobile-swap
    - action: click
      selector: token dropdown
    - action: screenshot
      name: layout-mobile-token-selector
  expected:
    - Swap form fills screen width
    - Token selector opens as bottom sheet or full screen
    - Buttons easily tappable
    - Virtual keyboard doesn't obscure form
```

## Test Type 3: Functionality Tests (FUNC-*)

**Purpose:** Verify each function works correctly with valid and invalid inputs.

```yaml
# Functionality Test: Valid Input
- id: FUNC-SWAP-VALID-001
  name: Swap Valid Amount
  type: functionality
  module: swap
  feature: Token Swap - Amount Input
  priority: high
  web3: true
  wallet_popups: 0
  depends_on: [WALLET-001]
  description:
    purpose: |
      Verify swap form accepts valid amount input.
      Test that quote loads and form becomes actionable.
  steps:
    - action: navigate
      url: /swap
    - action: fill
      selector: amount input
      value: "0.1"
    - action: wait
      ms: 2000
      reason: Wait for quote
    - action: screenshot
      name: func-swap-valid-amount
  expected:
    - Amount displayed correctly
    - Quote loads and displays
    - Swap button becomes enabled
    - No error messages

# Functionality Test: Empty Input
- id: FUNC-SWAP-EMPTY-001
  name: Swap Empty Amount Validation
  type: functionality
  module: swap
  feature: Token Swap - Validation
  priority: high
  web3: true
  wallet_popups: 0
  depends_on: [WALLET-001]
  description:
    purpose: |
      Verify swap button is disabled when no amount entered.
      Form should show "Enter an amount" or similar prompt.
  steps:
    - action: navigate
      url: /swap
    - action: screenshot
      name: func-swap-empty
  expected:
    - Swap button disabled or shows "Enter an amount"
    - No quote displayed
    - Form in idle state

# Functionality Test: Insufficient Balance
- id: FUNC-SWAP-INSUFFICIENT-001
  name: Swap Insufficient Balance Error
  type: functionality
  module: swap
  feature: Token Swap - Validation
  priority: high
  web3: true
  wallet_popups: 0
  depends_on: [WALLET-001]
  description:
    purpose: |
      Verify error when amount exceeds balance.
      User should see clear error message.
  steps:
    - action: navigate
      url: /swap
    - action: fill
      selector: amount input
      value: "999999999"
    - action: wait
      ms: 1000
      reason: Wait for validation
    - action: screenshot
      name: func-swap-insufficient
  expected:
    - Error message "Insufficient balance" or similar
    - Swap button disabled
    - Input may show error styling (red border)

# Functionality Test: Form Submission
- id: FUNC-FORM-SUBMIT-001
  name: Form Submission with Valid Data
  type: functionality
  module: forms
  feature: Form Handling
  priority: high
  web3: false
  wallet_popups: 0
  depends_on: []
  description:
    purpose: |
      Verify form submits successfully with valid data.
      Test complete form filling and submission flow.
  steps:
    - action: navigate
      url: /contact
    - action: fill
      selector: name input
      value: "Test User"
    - action: fill
      selector: email input
      value: "test@example.com"
    - action: fill
      selector: message textarea
      value: "Test message content"
    - action: click
      selector: Submit button
    - action: wait
      ms: 2000
      reason: Wait for submission
    - action: screenshot
      name: func-form-submitted
  expected:
    - Form submits successfully
    - Success message displayed
    - Form may reset or redirect

# Functionality Test: Form Validation Error
- id: FUNC-FORM-INVALID-001
  name: Form Invalid Email Validation
  type: functionality
  module: forms
  feature: Form Handling - Validation
  priority: high
  web3: false
  wallet_popups: 0
  depends_on: []
  description:
    purpose: |
      Verify form shows error for invalid email format.
      Client-side validation should prevent submission.
  steps:
    - action: navigate
      url: /contact
    - action: fill
      selector: email input
      value: "invalid-email"
    - action: click
      selector: Submit button
    - action: screenshot
      name: func-form-invalid-email
  expected:
    - Inline error message visible
    - Error text mentions email format
    - Form NOT submitted
    - Submit button may show loading then reset
```

## Test Type 4: Network Tests (NET-*)

**Purpose:** Verify app handles network conditions gracefully.

### Available Network Commands

| Command | Usage | Description |
|---------|-------|-------------|
| `set-network` | `--latency <ms>` | Add delay to all requests |
| `set-network` | `--offline` | Simulate offline mode |
| `set-network` | `--online` | Restore online mode |
| `mock-route` | `<pattern> --status <code> --body <text>` | Mock API response |
| `mock-api-error` | `<pattern> --status <code>` | Mock API error |
| `mock-timeout` | `<pattern>` | Make request hang/timeout |
| `throttle-network` | `<preset>` | Throttle (slow-3g, fast-3g, offline, none) |
| `clear-network` | | Clear all network mocks |

```yaml
# Network Test: High Latency
- id: NET-LATENCY-001
  name: API Response with 3s Delay
  type: network
  module: api
  feature: Network Handling
  priority: medium
  web3: false
  wallet_popups: 0
  depends_on: []
  description:
    purpose: |
      Verify app handles high latency (3+ seconds) gracefully.
      User should see loading indicator, not frozen UI.
  steps:
    - action: set-network
      options: "--latency 3000"
      comment: Add 3s delay to all requests
    - action: navigate
      url: /
    - action: screenshot
      name: net-latency-loading
    - action: wait
      ms: 4000
      reason: Wait for delayed response
    - action: screenshot
      name: net-latency-loaded
    - action: clear-network
      comment: Restore normal network
  expected:
    - Loading indicator shown during wait
    - UI remains responsive (not frozen)
    - Content loads after delay
    - No timeout error

# Network Test: Request Timeout
- id: NET-TIMEOUT-001
  name: API Request Timeout Handling
  type: network
  module: api
  feature: Network Handling - Errors
  priority: high
  web3: false
  wallet_popups: 0
  depends_on: []
  description:
    purpose: |
      Verify app handles request timeout gracefully.
      Should show error message and offer retry.
  steps:
    - action: mock-timeout
      pattern: "**/api/data"
      comment: Make /api/data request hang forever
    - action: navigate
      url: /dashboard
    - action: wait
      ms: 10000
      reason: Wait for app's timeout handling
    - action: screenshot
      name: net-timeout-error
    - action: clear-network
  expected:
    - Error message displayed (not crash)
    - Message mentions timeout or network issue
    - Retry button available
    - User can try again

# Network Test: Offline Behavior
- id: NET-OFFLINE-001
  name: Offline Mode Handling
  type: network
  module: api
  feature: Network Handling - Offline
  priority: medium
  web3: false
  wallet_popups: 0
  depends_on: []
  description:
    purpose: |
      Verify app handles offline state gracefully.
      Should show offline indicator and cached content if available.
  steps:
    - action: navigate
      url: /
    - action: set-network
      options: "--offline"
    - action: navigate
      url: /dashboard
    - action: screenshot
      name: net-offline-state
    - action: set-network
      options: "--online"
      comment: Restore online mode
  expected:
    - Offline indicator shown
    - Cached content displayed (if applicable)
    - Clear message about offline status
    - Reconnection attempt on online

# Network Test: API Error Response
- id: NET-ERROR-001
  name: API 500 Error Handling
  type: network
  module: api
  feature: Network Handling - Server Error
  priority: high
  web3: false
  wallet_popups: 0
  depends_on: []
  description:
    purpose: |
      Verify app handles server error (500) gracefully.
      Should show user-friendly error, not technical details.
  steps:
    - action: mock-api-error
      pattern: "**/api/data"
      options: "--status 500"
    - action: navigate
      url: /dashboard
    - action: screenshot
      name: net-server-error
    - action: clear-network
  expected:
    - User-friendly error message
    - No raw error or stack trace shown
    - Retry option available
    - Other parts of UI still functional

# Network Test: Slow 3G Simulation
- id: NET-SLOW3G-001
  name: Slow 3G Network Simulation
  type: network
  module: api
  feature: Network Handling - Slow Connection
  priority: medium
  web3: false
  wallet_popups: 0
  depends_on: []
  description:
    purpose: |
      Verify app works on slow network connections.
      Simulates slow-3g with 2s latency and limited bandwidth.
  steps:
    - action: throttle-network
      preset: "slow-3g"
    - action: navigate
      url: /
    - action: screenshot
      name: net-slow3g-loading
    - action: wait
      ms: 5000
      reason: Wait for slow load
    - action: screenshot
      name: net-slow3g-loaded
    - action: throttle-network
      preset: "none"
      comment: Remove throttling
  expected:
    - App loads (slowly but successfully)
    - Loading states shown appropriately
    - Images may lazy load
    - Core functionality works
```

## Test Type 5: Role & Permission Tests (ROLE-*)

**Purpose:** Verify each user role can access their permitted features and cannot access restricted ones.

```yaml
# Role Test: Guest User
- id: ROLE-GUEST-001
  name: Guest User - Public Access
  type: role
  module: auth
  feature: Permission Control
  priority: high
  web3: false
  wallet_popups: 0
  depends_on: []
  role: guest
  description:
    purpose: |
      Verify guest (unauthenticated) user can access public pages.
      Should see public content and login/connect prompts.
  steps:
    - action: clear-session
      comment: Ensure no authentication
    - action: navigate
      url: /
    - action: screenshot
      name: role-guest-home
  expected:
    - Public content visible
    - Connect/Login button visible
    - No user-specific data shown
    - Can browse public pages

# Role Test: Guest User - Protected Route
- id: ROLE-GUEST-002
  name: Guest User - Protected Route Blocked
  type: role
  module: auth
  feature: Permission Control
  priority: high
  web3: false
  wallet_popups: 0
  depends_on: []
  role: guest
  description:
    purpose: |
      Verify guest cannot access protected routes.
      Should redirect to login or show access denied.
  steps:
    - action: clear-session
    - action: navigate
      url: /dashboard
    - action: screenshot
      name: role-guest-protected
  expected:
    - Redirected to login page OR
    - Access denied message shown
    - Cannot see protected content
    - Clear call-to-action to authenticate

# Role Test: Regular User
- id: ROLE-USER-001
  name: Regular User - Feature Access
  type: role
  module: auth
  feature: Permission Control
  priority: high
  web3: true
  wallet_popups: 1
  depends_on: [WALLET-001]
  role: user
  description:
    purpose: |
      Verify authenticated user can access user features.
      Should see their dashboard and transaction history.
  steps:
    - action: navigate
      url: /dashboard
    - action: screenshot
      name: role-user-dashboard
    - action: navigate
      url: /transactions
    - action: screenshot
      name: role-user-transactions
  expected:
    - Dashboard loads with user data
    - Transaction history visible
    - User-specific content shown
    - Can access user-level features

# Role Test: Regular User - Admin Blocked
- id: ROLE-USER-002
  name: Regular User - Admin Route Blocked
  type: role
  module: auth
  feature: Permission Control
  priority: high
  web3: true
  wallet_popups: 0
  depends_on: [WALLET-001]
  role: user
  description:
    purpose: |
      Verify regular user cannot access admin routes.
      Should see access denied message.
  steps:
    - action: navigate
      url: /admin
    - action: screenshot
      name: role-user-admin-blocked
  expected:
    - Access denied message OR redirect
    - Cannot see admin content
    - No admin actions available

# Role Test: Admin User
- id: ROLE-ADMIN-001
  name: Admin User - Admin Panel Access
  type: role
  module: auth
  feature: Permission Control
  priority: high
  web3: true
  wallet_popups: 1
  depends_on: [ADMIN-LOGIN-001]
  role: admin
  description:
    purpose: |
      Verify admin can access admin panel.
      Should see user management and system settings.
  preconditions:
    - Logged in as admin
  steps:
    - action: navigate
      url: /admin
    - action: screenshot
      name: role-admin-panel
    - action: click
      selector: User Management link
    - action: screenshot
      name: role-admin-users
  expected:
    - Admin panel loads
    - User management visible
    - System settings accessible
    - Admin-only actions available

# Role Test: Permission Escalation Attempt
- id: ROLE-ESCALATION-001
  name: User Cannot Escalate to Admin
  type: role
  module: auth
  feature: Permission Control - Security
  priority: critical
  web3: true
  wallet_popups: 0
  depends_on: [WALLET-001]
  role: user
  description:
    purpose: |
      Verify regular user cannot perform admin actions via API.
      Tests security of permission system.
  steps:
    - action: navigate
      url: /admin/users/delete/1
    - action: screenshot
      name: role-escalation-attempt
  expected:
    - 403 Forbidden OR redirect
    - Action NOT performed
    - No data modified
    - Security log entry (if applicable)
```

## Test Type 6: Negative Tests (NEG-*)

**Purpose:** Verify error handling and recovery for failure scenarios.

```yaml
# Negative Test: Transaction Rejection
- id: NEG-TX-REJECT-001
  name: Wallet Transaction Rejected
  type: negative
  module: wallet
  feature: Error Handling
  priority: high
  web3: true
  wallet_popups: 1
  depends_on: [WALLET-001]
  description:
    purpose: |
      Verify app handles transaction rejection gracefully.
      User clicks "Reject" in wallet popup.
  steps:
    - action: navigate
      url: /swap
    - action: fill
      selector: amount input
      value: "0.01"
    - action: wait
      ms: 2000
      reason: Wait for quote
    - action: click
      selector: Swap button
    - action: wallet-reject
    - action: wait
      ms: 1000
      reason: Wait for error handling
    - action: screenshot
      name: neg-tx-rejected
  expected:
    - Error message displayed
    - Message mentions rejection (not technical error)
    - Form remains usable
    - Can retry the action
    - No balance change

# Negative Test: Invalid Input
- id: NEG-INPUT-INVALID-001
  name: Non-Numeric Amount Input
  type: negative
  module: swap
  feature: Input Validation
  priority: high
  web3: true
  wallet_popups: 0
  depends_on: [WALLET-001]
  description:
    purpose: |
      Verify app rejects non-numeric input in amount field.
  steps:
    - action: navigate
      url: /swap
    - action: fill
      selector: amount input
      value: "abc!@#"
    - action: screenshot
      name: neg-input-invalid
  expected:
    - Input rejected or sanitized
    - No quote attempted
    - Clear error or input restriction

# Negative Test: Negative Amount
- id: NEG-INPUT-NEGATIVE-001
  name: Negative Amount Input
  type: negative
  module: swap
  feature: Input Validation
  priority: high
  web3: true
  wallet_popups: 0
  depends_on: [WALLET-001]
  description:
    purpose: |
      Verify app rejects negative amount input.
  steps:
    - action: navigate
      url: /swap
    - action: fill
      selector: amount input
      value: "-10"
    - action: screenshot
      name: neg-input-negative
  expected:
    - Input rejected or converted to positive
    - Cannot proceed with negative amount

# Negative Test: Missing Required Data
- id: NEG-MISSING-DATA-001
  name: Required Field Empty Submission
  type: negative
  module: forms
  feature: Form Validation
  priority: high
  web3: false
  wallet_popups: 0
  depends_on: []
  description:
    purpose: |
      Verify form prevents submission with empty required fields.
  steps:
    - action: navigate
      url: /register
    - action: click
      selector: Submit button
    - action: screenshot
      name: neg-missing-data
  expected:
    - Validation errors shown for all required fields
    - Form NOT submitted
    - Focus moved to first error field
    - Clear error messages

# Negative Test: Wallet Disconnected During Action
- id: NEG-DISCONNECT-001
  name: Wallet Disconnects Mid-Flow
  type: negative
  module: wallet
  feature: Error Recovery
  priority: high
  web3: true
  wallet_popups: 0
  depends_on: [WALLET-001]
  description:
    purpose: |
      Verify app handles wallet disconnection during an action.
  steps:
    - action: navigate
      url: /swap
    - action: fill
      selector: amount input
      value: "0.1"
    - action: wait
      ms: 2000
      reason: Wait for quote
    - action: wallet-disconnect
    - action: screenshot
      name: neg-disconnect-midflow
  expected:
    - Connect wallet prompt appears
    - Form resets or shows connect message
    - No crash or undefined error
    - Can reconnect and continue
```

## Test Type 7: SEO & Meta Tests (SEO-*)

**Purpose:** Verify that all essential SEO and meta tags are present in the page head element.

```yaml
# SEO Test: Essential Head Elements
- id: SEO-HEAD-001
  name: Essential Head Elements Check
  type: seo
  module: seo
  feature: SEO & Meta Tags
  priority: high
  web3: false
  wallet_popups: 0
  depends_on: []
  description:
    purpose: |
      Verify that the page contains all essential head elements for SEO and social sharing.
      These elements are critical for search engine indexing and social media previews.
    required_elements:
      - title tag
      - meta description
      - meta keywords
      - meta charset
      - meta viewport
      - favicon link
  steps:
    - action: navigate
      url: /
    - action: check-head
      elements:
        - selector: "title"
          required: true
          validate: "not empty"
        - selector: "meta[name='description']"
          required: true
          attribute: "content"
          validate: "not empty"
        - selector: "meta[name='keywords']"
          required: true
          attribute: "content"
          validate: "not empty"
        - selector: "meta[charset]"
          required: true
        - selector: "meta[name='viewport']"
          required: true
          attribute: "content"
          validate: "contains width="
        - selector: "link[rel='icon'], link[rel='shortcut icon']"
          required: true
          attribute: "href"
          validate: "not empty"
    - action: screenshot
      name: seo-head-check
  expected:
    - Title tag exists and has content
    - Meta description exists with meaningful content
    - Meta keywords exist
    - Charset is defined (usually utf-8)
    - Viewport meta tag is set for responsive design
    - Favicon link is present and valid

# SEO Test: Open Graph Meta Tags
- id: SEO-OG-001
  name: Open Graph Meta Tags Check
  type: seo
  module: seo
  feature: Social Sharing - Open Graph
  priority: high
  web3: false
  wallet_popups: 0
  depends_on: []
  description:
    purpose: |
      Verify that Open Graph meta tags are present for proper social media sharing.
      These tags control how the page appears when shared on Facebook, LinkedIn, etc.
    required_elements:
      - og:title
      - og:description
      - og:url
      - og:image
      - og:type
  steps:
    - action: navigate
      url: /
    - action: check-head
      elements:
        - selector: "meta[property='og:title']"
          required: true
          attribute: "content"
          validate: "not empty"
        - selector: "meta[property='og:description']"
          required: true
          attribute: "content"
          validate: "not empty"
        - selector: "meta[property='og:url']"
          required: true
          attribute: "content"
          validate: "starts with http"
        - selector: "meta[property='og:image']"
          required: true
          attribute: "content"
          validate: "starts with http"
        - selector: "meta[property='og:type']"
          required: true
          attribute: "content"
          validate: "not empty"
    - action: screenshot
      name: seo-og-check
  expected:
    - og:title is set (e.g., "Why 1RPC | The Web3 relay to protect your privacy")
    - og:description provides a clear description
    - og:url is the canonical URL of the page
    - og:image points to a valid image URL
    - og:type is set (e.g., "website", "article")

# SEO Test: Twitter Card Meta Tags
- id: SEO-TWITTER-001
  name: Twitter Card Meta Tags Check
  type: seo
  module: seo
  feature: Social Sharing - Twitter
  priority: high
  web3: false
  wallet_popups: 0
  depends_on: []
  description:
    purpose: |
      Verify that Twitter Card meta tags are present for proper Twitter sharing.
      These tags control how the page appears when shared on Twitter/X.
    required_elements:
      - twitter:card
      - twitter:title
      - twitter:description
      - twitter:image
  steps:
    - action: navigate
      url: /
    - action: check-head
      elements:
        - selector: "meta[name='twitter:card']"
          required: true
          attribute: "content"
          validate: "in [summary, summary_large_image, app, player]"
        - selector: "meta[name='twitter:title']"
          required: true
          attribute: "content"
          validate: "not empty"
        - selector: "meta[name='twitter:description']"
          required: true
          attribute: "content"
          validate: "not empty"
        - selector: "meta[name='twitter:image']"
          required: true
          attribute: "content"
          validate: "starts with http"
    - action: screenshot
      name: seo-twitter-check
  expected:
    - twitter:card is set (typically "summary_large_image" for visual impact)
    - twitter:title matches or complements og:title
    - twitter:description provides a clear summary
    - twitter:image points to a valid image URL

# SEO Test: Complete Meta Tags Validation
- id: SEO-COMPLETE-001
  name: Complete SEO Meta Tags Validation
  type: seo
  module: seo
  feature: Complete SEO Check
  priority: critical
  web3: false
  wallet_popups: 0
  depends_on: []
  description:
    purpose: |
      Comprehensive check of all SEO-related meta tags.
      This is the complete validation covering all essential elements.
    example_tags: |
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>Why 1RPC | The Web3 relay to protect your privacy</title>
      <meta name="description" content="Experience how 1RPC protects users...">
      <meta name="keywords" content="1RPC,Web3,privacy,RPC relay,blockchain">
      <meta property="og:title" content="Why 1RPC | The Web3 relay...">
      <meta property="og:description" content="Experience how 1RPC protects...">
      <meta property="og:url" content="https://why.1rpc.io/">
      <meta property="og:image" content="https://why-1rpc-web.vercel.app/og-image.png">
      <meta property="og:type" content="website">
      <meta name="twitter:card" content="summary_large_image">
      <meta name="twitter:title" content="Why 1RPC | The Web3 relay...">
      <meta name="twitter:description" content="Experience how 1RPC protects...">
      <meta name="twitter:image" content="https://why-1rpc-web.vercel.app/og-image.png">
      <link rel="icon" href="/favicon.ico" sizes="256x256" type="image/x-icon">
  steps:
    - action: navigate
      url: /
    - action: check-head
      elements:
        # Basic meta tags
        - selector: "title"
          required: true
        - selector: "meta[charset]"
          required: true
        - selector: "meta[name='viewport']"
          required: true
        - selector: "meta[name='description']"
          required: true
        - selector: "meta[name='keywords']"
          required: true
        - selector: "link[rel='icon'], link[rel='shortcut icon']"
          required: true
        # Open Graph tags
        - selector: "meta[property='og:title']"
          required: true
        - selector: "meta[property='og:description']"
          required: true
        - selector: "meta[property='og:url']"
          required: true
        - selector: "meta[property='og:image']"
          required: true
        - selector: "meta[property='og:type']"
          required: true
        # Twitter Card tags
        - selector: "meta[name='twitter:card']"
          required: true
        - selector: "meta[name='twitter:title']"
          required: true
        - selector: "meta[name='twitter:description']"
          required: true
        - selector: "meta[name='twitter:image']"
          required: true
    - action: screenshot
      name: seo-complete-check
  expected:
    - All basic meta tags present (title, description, keywords, charset, viewport, favicon)
    - All Open Graph tags present (og:title, og:description, og:url, og:image, og:type)
    - All Twitter Card tags present (twitter:card, twitter:title, twitter:description, twitter:image)
    - No missing required tags
```

## Test Type 8: External Link Tests (LINK-*)

**Purpose:** Verify that all external links on the page are accessible and do not return 404 or "Not Found" errors.

```yaml
# External Link Test: Homepage External Links
- id: LINK-HOME-001
  name: Homepage External Links Check
  type: external-link
  module: links
  feature: External Link Validation
  priority: high
  web3: false
  wallet_popups: 0
  depends_on: []
  description:
    purpose: |
      Verify that all external links on the homepage are accessible.
      Opens each external link in the browser and checks for 404/Not Found responses.
    what_is_checked:
      - HTTP status code (should not be 404)
      - Page content does not contain "404" or "Not Found" text
      - Link is reachable (no timeout or connection errors)
  steps:
    - action: navigate
      url: /
    - action: collect-external-links
      selector: "a[href^='http']"
      exclude_domains:
        - localhost
        - 127.0.0.1
    - action: check-external-links
      timeout: 10000
      check_for_404: true
      check_for_not_found_text: true
    - action: screenshot
      name: link-home-check
  expected:
    - All external links return HTTP 200 or redirect to valid pages
    - No external link returns 404 status
    - No external link page contains "404" or "Not Found" text
    - All links are reachable within timeout

# External Link Test: Footer Links
- id: LINK-FOOTER-001
  name: Footer External Links Check
  type: external-link
  module: links
  feature: External Link Validation - Footer
  priority: medium
  web3: false
  wallet_popups: 0
  depends_on: []
  description:
    purpose: |
      Verify that all external links in the footer are accessible.
      Footer often contains important links like social media, legal pages, etc.
  steps:
    - action: navigate
      url: /
    - action: scroll
      direction: down
      to: "footer"
    - action: collect-external-links
      selector: "footer a[href^='http']"
      exclude_domains:
        - localhost
        - 127.0.0.1
    - action: check-external-links
      timeout: 10000
      check_for_404: true
      check_for_not_found_text: true
    - action: screenshot
      name: link-footer-check
  expected:
    - All footer external links are accessible
    - Social media links work
    - Legal/policy page links work
    - No broken links

# External Link Test: Social Media Links
- id: LINK-SOCIAL-001
  name: Social Media Links Check
  type: external-link
  module: links
  feature: External Link Validation - Social
  priority: medium
  web3: false
  wallet_popups: 0
  depends_on: []
  description:
    purpose: |
      Verify that all social media links are accessible.
      Checks Twitter/X, Discord, Telegram, GitHub, etc.
  steps:
    - action: navigate
      url: /
    - action: collect-external-links
      selector: "a[href*='twitter.com'], a[href*='x.com'], a[href*='discord'], a[href*='telegram'], a[href*='github.com'], a[href*='linkedin'], a[href*='facebook']"
    - action: check-external-links
      timeout: 15000
      check_for_404: true
      check_for_not_found_text: true
    - action: screenshot
      name: link-social-check
  expected:
    - All social media links are accessible
    - Twitter/X profile exists
    - Discord server invite is valid
    - GitHub repository exists
    - No 404 or suspended accounts

# External Link Test: Documentation Links
- id: LINK-DOCS-001
  name: Documentation Links Check
  type: external-link
  module: links
  feature: External Link Validation - Documentation
  priority: high
  web3: false
  wallet_popups: 0
  depends_on: []
  description:
    purpose: |
      Verify that all documentation links are accessible.
      Broken documentation links create poor user experience.
  steps:
    - action: navigate
      url: /
    - action: collect-external-links
      selector: "a[href*='docs'], a[href*='documentation'], a[href*='gitbook'], a[href*='notion']"
    - action: check-external-links
      timeout: 15000
      check_for_404: true
      check_for_not_found_text: true
    - action: screenshot
      name: link-docs-check
  expected:
    - All documentation links are accessible
    - Gitbook/Notion pages load correctly
    - No "Page not found" errors

# External Link Test: All Pages External Links Scan
- id: LINK-ALL-001
  name: Full Site External Links Scan
  type: external-link
  module: links
  feature: External Link Validation - Complete
  priority: critical
  web3: false
  wallet_popups: 0
  depends_on: []
  description:
    purpose: |
      Comprehensive scan of all external links across all pages.
      Crawls internal pages and validates all external links found.
    algorithm: |
      1. Start from homepage
      2. Collect all internal links
      3. For each internal page, collect external links
      4. Deduplicate external links
      5. Check each unique external link once
      6. Report all broken links with source pages
  steps:
    - action: navigate
      url: /
    - action: collect-internal-links
      base_url: /
    - action: for-each-internal-link
      steps:
        - action: navigate
          url: "{internal_link}"
        - action: collect-external-links
          selector: "a[href^='http']"
          exclude_domains:
            - localhost
            - 127.0.0.1
    - action: deduplicate-links
    - action: check-external-links
      timeout: 10000
      check_for_404: true
      check_for_not_found_text: true
      report_source_page: true
    - action: screenshot
      name: link-all-check
  expected:
    - All external links across all pages are accessible
    - Report identifies any broken links with their source pages
    - No 404 errors
    - No "Not Found" text on linked pages
```

### External Link Check Implementation

When executing external link tests, the test runner should:

1. **Collect all external links** from the page using the specified selector
2. **Open each link in the browser** (in a new tab or by navigation)
3. **Check the HTTP status** - fail if 404
4. **Check page content** - fail if page contains "404" or "Not Found" (case insensitive)
5. **Report broken links** with:
   - Link URL
   - Source page where link was found
   - Error type (404 status, Not Found text, timeout, etc.)

```javascript
// Example implementation for check-external-links action
async function checkExternalLinks(page, links, options) {
  const results = [];

  for (const link of links) {
    try {
      const response = await page.goto(link.url, { timeout: options.timeout });
      const status = response.status();

      // Check HTTP status
      if (status === 404) {
        results.push({
          url: link.url,
          source: link.sourcePage,
          status: 'FAIL',
          reason: 'HTTP 404 Not Found'
        });
        continue;
      }

      // Check page content for 404/Not Found text
      const content = await page.content();
      const lowerContent = content.toLowerCase();
      if (lowerContent.includes('404') || lowerContent.includes('not found') || lowerContent.includes('page not found')) {
        // Additional check: verify it's actually a 404 page, not just text mentioning 404
        const title = await page.title();
        if (title.toLowerCase().includes('404') || title.toLowerCase().includes('not found')) {
          results.push({
            url: link.url,
            source: link.sourcePage,
            status: 'FAIL',
            reason: 'Page contains 404/Not Found content'
          });
          continue;
        }
      }

      results.push({
        url: link.url,
        source: link.sourcePage,
        status: 'PASS'
      });

    } catch (error) {
      results.push({
        url: link.url,
        source: link.sourcePage,
        status: 'FAIL',
        reason: error.message
      });
    }
  }

  return results;
}
```

## Test Count Guidelines Per Module

Based on research output, generate minimum tests:

```
╔════════════════════════════════════════════════════════════════╗
║  MINIMUM TEST CASES PER MODULE                                 ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  For each module found in research:                            ║
║                                                                ║
║  FLOW tests:                                                   ║
║  - 1 complete happy path                                       ║
║  - 1 alternative path (if applicable)                          ║
║  - 1 error recovery path                                       ║
║                                                                ║
║  LAYOUT tests (for each viewport):                             ║
║  - 1 Desktop (1920x1080)                                       ║
║  - 1 Tablet (768x1024)                                         ║
║  - 1 Mobile (375x667)                                          ║
║                                                                ║
║  FUNC tests (for each function):                               ║
║  - 1 valid input test                                          ║
║  - 2+ validation tests (required, format, range)               ║
║  - 1 edge case test                                            ║
║                                                                ║
║  NET tests (if module has API calls):                          ║
║  - 1 latency test                                              ║
║  - 1 timeout test                                              ║
║  - 1 error response test                                       ║
║                                                                ║
║  ROLE tests (for each role):                                   ║
║  - 1 permitted access test                                     ║
║  - 1 restricted access test                                    ║
║                                                                ║
║  NEG tests:                                                    ║
║  - 1 per error scenario identified                             ║
║  - 1 per validation rule                                       ║
║                                                                ║
║  SEO tests (global, run once per site):                        ║
║  - 1 basic head elements check                                 ║
║  - 1 Open Graph meta tags check                                ║
║  - 1 Twitter Card meta tags check                              ║
║  - 1 complete SEO validation                                   ║
║                                                                ║
║  LINK tests (global, run once per site):                       ║
║  - 1 homepage external links check                             ║
║  - 1 footer links check                                        ║
║  - 1 social media links check                                  ║
║  - 1 documentation links check                                 ║
║  - 1 full site external links scan                             ║
║                                                                ║
║  TOTAL: 15-25 tests per major module                           ║
║  + 4 SEO tests + 5 LINK tests (global)                         ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

## ID Naming Convention

| Test Type | Prefix | Example |
|-----------|--------|---------|
| Flow | FLOW- | FLOW-SWAP-001 |
| Layout | LAYOUT- | LAYOUT-DESKTOP-001 |
| Functionality | FUNC- | FUNC-SWAP-VALID-001 |
| Network | NET- | NET-LATENCY-001 |
| Role/Permission | ROLE- | ROLE-GUEST-001 |
| Negative | NEG- | NEG-TX-REJECT-001 |
| SEO/Meta | SEO- | SEO-HEAD-001 |
| External Link | LINK- | LINK-HOME-001 |
| Wallet (Web3) | WALLET- | WALLET-001 |

## Output Files

**Location:** `./tests/` (in the project being tested)

```
<target-project>/
├── tests/                  # Test case definitions (this skill creates these)
│   ├── config.yaml         # Project configuration
│   ├── test-cases.yaml     # All test cases
│   ├── case-summary.md     # Human-readable summary
│   └── README.md           # How to run tests
└── test-output/            # Runtime artifacts (created by web-test, NOT here!)
    └── screenshots/        # Screenshots saved here during test execution
```

**IMPORTANT:** Screenshots are saved to `test-output/screenshots/`, NOT `tests/screenshots/`.
The `tests/` directory only contains test case definitions (YAML/MD files).

### tests/config.yaml

```yaml
project:
  name: [from research]
  url: http://localhost:3000
  framework: [from research]

web3:
  enabled: [true/false]
  wallet: metamask
  network: [from research]

# Screen sizes for layout tests
viewports:
  desktop:
    width: 1920
    height: 1080
  tablet:
    width: 768
    height: 1024
  mobile:
    width: 375
    height: 667
    isMobile: true

# User roles for permission tests
roles:
  - id: guest
    name: Guest
    description: Unauthenticated visitor
    setup: clear-session
  - id: user
    name: Regular User
    description: Authenticated user
    setup: WALLET-001
  - id: admin
    name: Administrator
    description: Admin privileges
    setup: ADMIN-LOGIN-001

# Modules from research
modules:
  - id: wallet
    name: Wallet
    description: Wallet connection
  - id: swap
    name: Token Swap
    description: Token swap functionality
  # ... more modules

generated:
  date: [current date]
  by: web-test-case-gen
  version: 2.0.0

# Test counts per type
test_summary:
  flow: 10
  layout: 9
  functionality: 25
  network: 6
  role: 12
  negative: 15
  total: 77

execution_order:
  # Dependencies respected
  - WALLET-001
  - FLOW-SWAP-001
  - FUNC-SWAP-VALID-001
  # ... all test IDs in order
```

### tests/case-summary.md

```markdown
# Test Case Summary

Generated by web-test-case-gen v2.0.0 on [date].

## Coverage Overview

| Test Type | Count | Purpose |
|-----------|-------|---------|
| FLOW | 10 | Complete user journeys |
| LAYOUT | 9 | Desktop/Tablet/Mobile layouts |
| FUNC | 25 | Input validation & functionality |
| NET | 6 | Network error handling |
| ROLE | 12 | Permission control |
| NEG | 15 | Error scenarios |
| **TOTAL** | **77** | |

## Test Cases by Type

### FLOW Tests (User Journeys)

| ID | Name | Module | Priority |
|----|------|--------|----------|
| FLOW-SWAP-001 | Complete Token Swap | swap | Critical |
| FLOW-SWAP-002 | Pre-selected Tokens | swap | High |
| ... | ... | ... | ... |

### LAYOUT Tests (Responsive Design)

| ID | Name | Viewport | Priority |
|----|------|----------|----------|
| LAYOUT-DESKTOP-001 | Desktop Homepage | 1920x1080 | High |
| LAYOUT-TABLET-001 | Tablet Homepage | 768x1024 | High |
| LAYOUT-MOBILE-001 | Mobile Homepage | 375x667 | High |
| ... | ... | ... | ... |

### FUNC Tests (Functionality)

| ID | Name | Module | Priority |
|----|------|--------|----------|
| FUNC-SWAP-VALID-001 | Valid Amount | swap | High |
| FUNC-SWAP-EMPTY-001 | Empty Amount | swap | High |
| ... | ... | ... | ... |

### NET Tests (Network)

| ID | Name | Scenario | Priority |
|----|------|----------|----------|
| NET-LATENCY-001 | 3s Delay | latency | Medium |
| NET-TIMEOUT-001 | Request Timeout | timeout | High |
| ... | ... | ... | ... |

### ROLE Tests (Permissions)

| ID | Name | Role | Priority |
|----|------|------|----------|
| ROLE-GUEST-001 | Public Access | guest | High |
| ROLE-GUEST-002 | Protected Blocked | guest | High |
| ROLE-USER-001 | User Features | user | High |
| ... | ... | ... | ... |

### NEG Tests (Error Handling)

| ID | Name | Scenario | Priority |
|----|------|----------|----------|
| NEG-TX-REJECT-001 | Tx Rejected | wallet | High |
| NEG-INPUT-INVALID-001 | Invalid Input | validation | High |
| ... | ... | ... | ... |

---

## Detailed Test Cases

[Full details for each test case...]
```

### tests/README.md

```markdown
# Test Cases for [Project Name]

Generated by `web-test-case-gen` on [date].

## How to Add New Test Cases

Ask Claude Code to add a test case:

\`\`\`
Add a test case for [describe what you want to test]
\`\`\`

Examples:
\`\`\`
Add a test case for verifying the swap button is disabled when amount is zero
\`\`\`

\`\`\`
Add a negative test for transaction rejection
\`\`\`

\`\`\`
Add a layout test for mobile wallet connection
\`\`\`

## How to Run Tests

Ask Claude Code to run the tests:

\`\`\`
Run all tests
\`\`\`

\`\`\`
Run the swap module tests
\`\`\`

\`\`\`
Run SWAP-001 test
\`\`\`

### Run Options

| Command | Description |
|---------|-------------|
| "Run all tests" | Execute all test cases in order |
| "Run [module] module" | Run all tests in a specific module (e.g., "Run swap module") |
| "Run [ID] test" | Run a specific test case (e.g., "Run SWAP-001") |
| "Run critical tests" | Run only critical priority tests |
| "Run negative tests" | Run only error/edge case tests |

> **Note:** The dev server will be started automatically. No manual setup required.

## Available Modules

| Module | Description | Test Count |
|--------|-------------|------------|
| [module_id] | [module_description] | [count] |
| ... | ... | ... |

*(This table is auto-generated based on modules defined in config.yaml)*

## Test Case Types

| Prefix | Type | Example |
|--------|------|---------|
| FLOW- | User journey | FLOW-SWAP-001 |
| FUNC- | Functionality | FUNC-INPUT-001 |
| LAYOUT- | Responsive design | LAYOUT-MOBILE-001 |
| NET- | Network conditions | NET-OFFLINE-001 |
| ROLE- | Permissions | ROLE-GUEST-001 |
| NEG- | Error handling | NEG-TX-FAIL-001 |
| WALLET- | Web3 wallet | WALLET-001 |

## File Structure

\`\`\`
tests/
├── config.yaml       # Project config & execution order
├── test-cases.yaml   # All test case definitions
├── case-summary.md   # Human-readable summary
└── README.md         # This file
\`\`\`
```

## Add Single Test Case (Interactive Mode)

When user provides a specific test case description:

```
╔════════════════════════════════════════════════════════════════╗
║  SINGLE TEST CASE WORKFLOW                                     ║
╠════════════════════════════════════════════════════════════════╣
║                                                                ║
║  Step 1: Parse user description                                ║
║          - Extract feature name                                ║
║          - Determine test type (FLOW/FUNC/NEG/etc)             ║
║          - Identify expected behavior                          ║
║                                                                ║
║  Step 2: Check existing config                                 ║
║          - If no tests/config.yaml, run research first         ║
║          - If exists, read current state                       ║
║                                                                ║
║  Step 3: Read related source code (REQUIRED)                   ║
║          - Search for feature in codebase                      ║
║          - Read component/function implementation              ║
║          - Understand validation and error handling            ║
║                                                                ║
║  Step 4: Launch browser and explore (REQUIRED)                 ║
║          - Navigate to feature page                            ║
║          - Take screenshots                                    ║
║          - Identify UI elements and selectors                  ║
║                                                                ║
║  Step 5: Generate test case YAML                               ║
║          - Create unique ID with proper prefix                 ║
║          - Define steps based on exploration                   ║
║          - Add expected outcomes                               ║
║                                                                ║
║  Step 6: Update all test files                                 ║
║          - Append to test-cases.yaml                           ║
║          - Append to case-summary.md                           ║
║          - Update README.md table                              ║
║          - Update config.yaml execution_order                  ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

## Related Skills

| Skill | Relationship |
|-------|-------------|
| web-test-research | Called automatically first |
| web-test | Uses generated test cases |
| web-test-report | References test case IDs |
| web-test-cleanup | Clean up after test generation |

## After Generation

1. **Review** - Check generated test cases cover all scenarios
2. **Commit** - `git add tests/ && git commit -m "Add comprehensive test cases"`
3. **Run** - `skill web-test` to execute tests
