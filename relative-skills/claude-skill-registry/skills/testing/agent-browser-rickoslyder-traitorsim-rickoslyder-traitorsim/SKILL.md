---
name: agent-browser
description: Browser automation CLI for AI-driven UI testing and review. Use when asked to "test the UI", "review the website", "check the site visually", "audit the frontend", or perform automated browser testing. Leverages accessibility snapshots for deterministic element interaction.
---

# Agent Browser Skill

Automate browser interactions for UI testing, accessibility audits, and visual reviews using the `agent-browser` CLI. This skill enables AI-driven browser automation with deterministic element selection via accessibility tree snapshots.

## Quick Start

```bash
# Install (one-time)
npm install -g agent-browser
agent-browser install  # Download Chromium

# Basic workflow
agent-browser open https://traitorsim.rbnk.uk
agent-browser snapshot -i -c  # Interactive elements, compact
agent-browser click @e5       # Click element by ref
agent-browser screenshot page.png
```

## Core Commands

### Navigation
```bash
agent-browser open <url>                    # Navigate to URL
agent-browser open https://example.com --wait networkidle
agent-browser back                          # Go back
agent-browser forward                       # Go forward
agent-browser reload                        # Reload page
```

### Snapshots (AI-Optimized)
```bash
agent-browser snapshot                      # Full accessibility tree
agent-browser snapshot -i                   # Interactive elements only
agent-browser snapshot -c                   # Compact (no empty elements)
agent-browser snapshot -d 3                 # Limit depth to 3
agent-browser snapshot -s "#main"           # Scope to selector
agent-browser snapshot -i -c -d 5           # Combined filters
```

The snapshot returns refs like `@e1`, `@e2` for deterministic element selection.

### Element Interaction
```bash
agent-browser click @e5                     # Click by ref
agent-browser fill @e3 "hello@example.com"  # Fill input
agent-browser type @e3 "search query"       # Type text
agent-browser press Enter                   # Press key
agent-browser scroll down 500               # Scroll pixels
agent-browser hover @e7                     # Hover element
```

### Semantic Finders
```bash
agent-browser find role button click --name "Submit"
agent-browser find label "Email" fill "user@example.com"
agent-browser find text "Sign In" click
agent-browser find placeholder "Search..." fill "query"
agent-browser find testid "submit-btn" click
```

### Screenshots
```bash
agent-browser screenshot                    # Save to screenshot.png
agent-browser screenshot page.png           # Custom filename
agent-browser screenshot --fullpage full.png # Full page
agent-browser screenshot --selector "#hero" hero.png
```

### Element State Checks
```bash
agent-browser is visible @e5                # Returns true/false
agent-browser is enabled @e3
agent-browser is checked @e8
agent-browser get text @e5                  # Get text content
agent-browser get html @e5                  # Get innerHTML
agent-browser get value @e3                 # Get input value
```

### Browser Configuration
```bash
agent-browser set viewport 1920 1080        # Desktop size
agent-browser set viewport 375 667          # Mobile size
agent-browser set device "iPhone 14"        # Device emulation
agent-browser set media dark                # Dark mode
agent-browser set geo 51.5074 -0.1278       # London location
```

### Network Control
```bash
agent-browser network requests              # List network requests
agent-browser network route "*/api/*" --abort  # Block API calls
agent-browser network route "*/analytics*" --abort  # Block analytics
```

### Sessions
```bash
agent-browser --session review1 open site.com   # Named session
agent-browser --session review1 snapshot -i
AGENT_BROWSER_SESSION=review1 agent-browser click @e5
```

## UI Review Workflow

### 1. Accessibility Audit
```bash
# Check all interactive elements are accessible
agent-browser open https://traitorsim.rbnk.uk
agent-browser snapshot -i > snapshot.txt

# Look for:
# - Buttons without aria-labels
# - Links without descriptive text
# - Form inputs without labels
# - Missing role attributes
```

### 2. Navigation Testing
```bash
# Test all main navigation paths
agent-browser open https://site.com
agent-browser snapshot -i -c
agent-browser click @e2  # Click nav item
agent-browser snapshot -i -c
# Compare snapshots to verify page changed
```

### 3. Form Testing
```bash
agent-browser open https://site.com/form
agent-browser snapshot -i
agent-browser fill @e3 "test@example.com"
agent-browser fill @e4 "Test User"
agent-browser click @e5  # Submit
agent-browser snapshot -i  # Check for validation errors
```

### 4. Responsive Testing
```bash
# Desktop
agent-browser set viewport 1920 1080
agent-browser screenshot desktop.png

# Tablet
agent-browser set viewport 768 1024
agent-browser screenshot tablet.png

# Mobile
agent-browser set viewport 375 667
agent-browser screenshot mobile.png
```

### 5. Dark Mode Testing
```bash
agent-browser set media dark
agent-browser screenshot dark-mode.png
agent-browser set media light
agent-browser screenshot light-mode.png
```

## TraitorSim-Specific Review

### Review Dashboard
```bash
agent-browser open https://traitorsim.rbnk.uk
agent-browser snapshot -i -c

# Test sidebar game selection
agent-browser find role button click --name "game"
agent-browser snapshot -i

# Test tab navigation
agent-browser find text "Trust Network" click
agent-browser snapshot -i
agent-browser find text "Players" click
agent-browser find text "Voting" click
agent-browser find text "Events" click
agent-browser find text "Analysis" click
agent-browser find text "Story Mode" click
```

### Test Timeline Controls
```bash
agent-browser find role button click --name "Play"
agent-browser find role slider fill "5"  # Scrub to day 5
agent-browser snapshot -i
```

### Test POV Selector
```bash
agent-browser find text "Viewing Mode" click
agent-browser find role combobox click
agent-browser snapshot -i  # Check dropdown options
```

### Full Screenshot Suite
```bash
# Create review screenshots
agent-browser open https://traitorsim.rbnk.uk
agent-browser set viewport 1920 1080

# Each tab
agent-browser find text "Trust Network" click
agent-browser screenshot review/trust-network.png

agent-browser find text "Players" click
agent-browser screenshot review/players.png

agent-browser find text "Voting" click
agent-browser screenshot review/voting.png

agent-browser find text "Events" click
agent-browser screenshot review/events.png

agent-browser find text "Analysis" click
agent-browser screenshot review/analysis.png

agent-browser find text "Story Mode" click
agent-browser screenshot review/story.png
```

## Troubleshooting

### Element Not Found
```bash
# Use snapshot to see available elements
agent-browser snapshot -i | grep -i "button"

# Try semantic finder
agent-browser find text "Submit" click
```

### Page Not Loading
```bash
# Wait for network idle
agent-browser open https://slow-site.com --wait networkidle

# Increase timeout
agent-browser --timeout 60000 open https://slow-site.com
```

### Snapshot Too Large
```bash
# Filter to interactive only and limit depth
agent-browser snapshot -i -c -d 4

# Scope to specific section
agent-browser snapshot -s "#main-content" -i
```

## When to Use This Skill

Use agent-browser when:
- Performing automated UI testing
- Conducting accessibility audits
- Taking screenshots for documentation
- Testing responsive layouts
- Verifying form behavior
- Testing dark mode
- Reviewing site after code changes

## When NOT to Use This Skill

Don't use agent-browser for:
- API testing (use curl/httpie)
- Static code analysis (use linters)
- Performance benchmarking (use Lighthouse)
- Unit testing (use Jest/Vitest)
