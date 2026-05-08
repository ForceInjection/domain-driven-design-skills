---
name: glide
description: |
  **The primary skill for building Glide apps.** Covers the full workflow, agent coordination, and browser automation.
  Use when building, creating, or modifying any Glide app. Read this first for any Glide project.
---

# Glide App Building

**Start here when building a Glide app.** This skill covers the overall workflow, agent coordination, and technical details for browser automation.

## Build Workflow Summary

1. **Clarify use case** - Understand what the user wants
2. **Create app first** - Get browser auth done early (blank app)
3. **Get API key** - Go to Data Editor, retrieve token from Users table (before spawning data agents)
4. **Analyze file** (if provided) - Use `file-analysis` agent
5. **Create tables via API** - Use `data` agent (faster than UI, in parallel)
6. **Build screens** - Use `build` agent for Playwright automation (in parallel)
7. **Design review** - Apply `design` skill to evaluate and improve screens
8. **QA verification** - Use `qa` agent to verify features actually work
9. **Finalize** - Access settings, testing, publish

## Agents

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| `build` | Browser automation via Playwright | Creating apps, adding screens, configuring UI |
| `file-analysis` | Analyze spreadsheets/data files | User provides a file to build from |
| `data` | Glide API operations | Creating tables, importing data, bulk operations |
| `design-review` | Critique screens for design quality | After building screens, to improve component choices and layouts |
| `qa` | Verify features actually work | Before telling user the app is ready |
| `app-research` | Explore and document existing apps | Understanding an app's structure, answering questions about it |

## Parallel Builds (Multi-Browser) - Maximize Speed

The plugin supports 6 concurrent browser sessions. **Browser automation is slow, so parallelize aggressively.**

### Parallel Strategy for New Apps

**Phase 1: Setup (Sequential)**
1. User provides use case
2. Create blank app (browser 1)
3. **Go to Data Editor and retrieve API key immediately**
   - Click "Data" tab in Glide Builder
   - Open Users table (or any existing table)
   - Click "Show API"
   - Copy the secret token
   - Store in `.glide/config.json` under `apiKey`
4. **Do this BEFORE spawning data agents** - prevents multiple agents trying to get the key in parallel

**Phase 2: Data Creation (Highly Parallel)**
- Spawn N `data` agents in parallel to create all tables (up to 6 concurrent)
- Each agent creates and links one table to the app with real or sample data
- Example: "Create the Tasks table using browser 1, create the Projects table using browser 2, create the Users table using browser 3"
- **WAIT for all tables to exist** - screens cannot be built without their backing tables

**Phase 3: Screen Building (Highly Parallel)**
- Once all tables exist, spawn up to 6 `build` agents in parallel
- Each agent builds screens for one data table (collection + detail view)
- Can start immediately after Phase 2 completes
- Example: "Build screens for Tasks using browser 1, build screens for Projects using browser 2, build screens for Users using browser 3"
- Agents design collections, detail views, and forms independently

**Phase 4: Design Review (One Screen at a Time)**
- Review ONE screen at a time, not the whole app (much more efficient)
- Reuse the same browser from build agents (alternate between building and reviewing)
- As each build agent finishes a screen, spawn design-review for that screen only
- Example workflow:
  1. Builder finishes Tasks screen on browser 1
  2. Design-review agent reviews Tasks using browser 1 (while other builders continue on browsers 2-6)
  3. Get feedback, pass to builder
  4. Builder implements feedback on Tasks (browser 1)
  5. Meanwhile, another builder finishes Projects on browser 2
  6. Design-review reviews Projects on browser 2
- Keep design review focused on one screen at a time for speed

**Phase 5: Implement Feedback (Parallel)**
- Spawn `build` agents to apply design improvements (up to 6)
- Different agents apply feedback to different screens simultaneously
- Example: "Implement design feedback for Tasks using browser 1, implement feedback for Projects using browser 2"

**Phase 6: QA (Parallel)**
- Run `qa` agents on different features in parallel (up to 6)
- Test each screen/feature independently
- Example: "Test Tasks creation using browser 5, test Projects editing using browser 6"

### How to Spawn Parallel Agents

**CRITICAL: Each parallel agent must use a different browser number.**

```
"Create the Tasks table using browser 1"
"Create the Projects table using browser 2"
"Create the Users table using browser 3"
```

**Browser assignment rules:**
- Use browsers 1-6 only
- Each agent gets a unique browser number (no sharing)
- Example: If spawning 3 data agents, assign browsers 1, 2, 3
- Example: If spawning 5 build agents, assign browsers 1, 2, 3, 4, 5
- You cannot have two agents both using browser 2

Each agent will:
- Use ONLY its assigned browser instance (`mcp__plugin_glide_browser-N__browser_*` tools)
- Work independently without blocking others
- Complete when the task is done

### Key Rules for Parallelization

1. **Get API token early** - Create one table in the first browser, grab the token from Data Editor
2. **Each agent needs the app ID** - Pass `appId` to all parallel agents
3. **Tables must exist before screens** - CRITICAL: All tables must be created (Phase 2) before any screens can be built (Phase 3). You can't design a screen without its backing data table.
4. **Data and tables come first** - Ensure real or sample data is imported into each table before building screens for it
5. **Use all 6 browsers** - Don't leave idle browsers when you could be building
6. **Phase dependencies**:
   - Phase 1 (Setup) → Phase 2 (Data) → Phase 3 (Screens) are sequential
   - Phases 4, 5, 6 (Design, Feedback, QA) can overlap and parallelize
7. **Design review one screen at a time** - Review individual screens, not the whole app. Alternate with building on the same browser.
8. **Design review doesn't block** - Review can happen while other builders continue on different browsers
9. **QA is the final stage** - Run QA on all screens in parallel to validate before finishing

**Skills:**
| Skill | Purpose | When to Use |
|-------|---------|-------------|
| `design` | Screen design principles, techniques, and component guidance | Evaluating collection styles, improving layouts, choosing components |

## Step-by-Step

### 1. Clarify Use Case

**Before doing anything, understand what the user wants.**

- If clear: Confirm back ("I'll build a task management app for your team")
- If unclear: Ask what the app should do, who will use it

### 2. Create App First

**Create the app immediately**, before file analysis.

Why:
- Gets browser auth out of the way early
- User sees progress right away

Use `build` agent: go.glideapps.com → "New app" → **"Blank"** → "Create app"

**NEVER use "Import a file"** - always Blank. Data comes via API.

### 3. Get API Key (Before Spawning Data Agents)

**Immediately after creating the app, retrieve the API key.**

This prevents multiple data agents from trying to fetch it in parallel later.

Steps (using `build` agent):
1. Click the "Data" tab
2. Open the "Users" table (or any existing table)
3. Click "Show API" button
4. Copy the secret token
5. Store in `.glide/config.json` under `apiKey`
6. Pass this to all `data` agents

**Why**: Data agents need the API key to create tables. Getting it early and once prevents race conditions.

### 4. Analyze File (If User Has One)

Use `file-analysis` agent with:
- The file path
- Context hints (app purpose, key features, who will use it)

Returns: tables to import, relationships, formulas to rebuild

### 5. Create Tables via API

Use `data` agent - much faster than UI for bulk data.

**Critical**: Always create NEW tables. Never inject into existing ones.

**Always include images**: Use `https://picsum.photos/seed/{id}/400/300` placeholders.

### 6. Build Screens

Use `build` agent to:
1. Set branding (name, icon, colors) - see naming rules below
2. Link tables created via API
3. Add computed columns (relations, rollups, AI)
4. Create screens from data
5. Configure collections and detail views

**App naming rules:**
- **Short**: 2 words maximum
- **No company name**: The app lives in the company's team already
- **No punctuation**: No periods, exclamation marks, etc.
- Good: "Employees", "Task Tracker", "Inventory"
- Bad: "Tesla Employee Directory", "Acme Inc. Tasks."

### 7. Design Review (One Screen at a Time)

**Review screens individually, not the whole app** - much more efficient.

As each `build` agent finishes a screen:
1. Spawn a `design-review` agent for that ONE screen
2. Reuse the same browser that just finished building (save a browser)
3. Get feedback on: mobile/desktop layouts, collection styles, component choices, data density
4. Pass feedback back to builder

Pattern: Builder finishes screen → Review it → Get feedback → Builder implements → Repeat for next screen

**Don't review the entire app at once** - that's slow. Review and improve one screen, then move to the next.

### 8. QA Verification (Critical!)

**Don't tell the user the app is ready until you verify features actually work.**

Use `qa` agent to:
- Verify screens exist and have components (not empty)
- Verify data binding works (real data shows, not placeholders)
- Test forms actually save data (check Data Editor)
- Test buttons/actions actually work
- Verify computed columns have formulas configured
- Check that workflows are set up correctly

The QA agent will produce a report of PASS/FAIL for each feature. Fix any failures before declaring the app complete.

### 9. Finalize

Configure access/privacy, test as different users, publish.

## Key Patterns

**Screen = Table + Collection + Detail**
- Backing table provides data
- Collection shows list/cards
- Detail shows one item

**Calculations are Columns**
- Math for arithmetic
- If-Then-Else for conditions
- Rollups for aggregations
- Lookups for related data

## What NOT to Do

- Don't use "Import a file" - always Blank
- Don't use the Agent tab in Glide Builder
- Don't use Glide's file upload UI - use API
- **Don't inject into existing tables** - always create NEW tables
- **NEVER import into the Users table** - it's reserved for user profiles only
- Don't click inline "Import" links next to tables - use "+" menu instead
- Don't skip images

---

# Builder Reference

## URLs

| URL | Purpose |
|-----|---------|
| `go.glideapps.com` | Dashboard - view/manage apps |
| `go.glideapps.com/app/{appId}/layout` | Layout Editor |
| `go.glideapps.com/app/{appId}/data` | Data Editor |
| `go.glideapps.com/app/{appId}/settings` | App Settings |

## Main Navigation Tabs

1. **Data** - Data Editor for tables and columns
2. **Layout** - Screen and component design
3. **Workflows** - Automation sequences
4. **Settings** - App configuration

**Warning**: There is also an "Agent" tab in the builder. **Do not use it.** Build manually using Data and Layout tabs instead.

## Creating a New App

1. Navigate to `go.glideapps.com`
2. Click "New app" card
3. Select **Blank** (recommended - use API for data import)
4. Click "Create app"

## Data Editor

### Adding Columns (Browser Automation Required)

**All column creation must be done via browser automation** - the Glide API does not support adding columns to existing tables.

**Recommended method** - Keyboard shortcut (fastest):
1. Navigate to Data tab
2. Click on the target table
3. Press **CMD+SHIFT+ENTER** (macOS) or **CTRL+SHIFT+ENTER** (Windows)
4. Type the column **Name**
5. **Explicitly select the Type** from dropdown (required - commits the name)
6. Configure options and click **Save**

**Alternative method** - UI clicks:
1. Click on any column header → "Add column right"
2. Type the column **Name**
3. **Always explicitly select the Type** from dropdown (even for Text)
4. Configure options and click **Save**

**Important**:
- Interacting with the type picker commits the column name. If you skip this step, the name may not save.
- The keyboard shortcut method is significantly faster and more reliable for automation.

### Column Type Categories
- **Basic** - Text, Number, Boolean, Image, Date & Time
- **Computed** - Math, Template, If-Then-Else, Relations
- **AI** - Audio to Text, Generate Text, Text to JSON
- **Integrations** - Call API, Claude, OpenAI, Google Maps

The dropdown is searchable - type to filter.

## Layout Editor

### Adding Screens/Tabs
1. Click "+" in Navigation or Menu section
2. Choose: **Screen from data**, **Custom screen**, or **Form screen**
3. Configure in right panel
4. **Set a short label** - 1-2 words maximum (e.g., "Tasks", "My Team")
5. **Pick an appropriate icon** - click the icon and choose one that matches the content

**Tab labels**: Keep them short! 1-2 words max.
- Good: "Tasks", "Team", "Settings", "Orders"
- Bad: "My Task List", "Team Member Directory"

**Tab icons**: Don't leave random icons. Choose icons that represent the screen's purpose:
- Tasks/Todos: checkmark, clipboard, list
- People/Users: person, people, user
- Settings: gear, cog, sliders
- Home/Dashboard: home, grid, chart
- Messages: chat, envelope, bell
- Calendar/Events: calendar, clock
- Files/Documents: folder, document, file
- Search: magnifying glass
- Add/Create: plus, add

### Adding Components
1. Select a screen
2. Click "+" in Components section
3. Search or browse categories
4. Click to add, configure in right panel

### Collection Styles
Card, List, Table, Data Grid, Checklist, Calendar, Kanban, Custom

## Settings

**Name & Icon** - App name (keep short, 2 words max, no company name), icon, logo
**Appearance** - Accent color, layout (Left/Top), style (Light/Deep/Accent)
**Access** - Who can access the app
**Integrations** - External connections

### Changing App Icon (Emoji Picker)

To change the app icon using the emoji picker:

1. Go to **Settings** tab → **Name & Icon** section
2. **Click the icon image** (not the Upload button) → Opens "Emoji Mart™" picker
3. **Type the emoji name in the search box** (e.g., "rocket", "checkmark", "clipboard")
4. **Click the emoji button** from the search results

**Important**: Always use the search box! Browsing categories is slow and error-prone. The search instantly filters to matching emojis.

Common emoji searches for app icons:
- Tasks: "checkmark", "clipboard", "list"
- People: "person", "people", "user"
- Business: "briefcase", "chart", "money"
- Home: "home", "house"
- Settings: "gear", "wrench"
- Calendar: "calendar", "clock"
- Messages: "chat", "envelope", "bell"
- Food: "pizza", "coffee", "burger"
- Travel: "car", "plane", "rocket"

---

## Browser Automation Tips

**Column names may not save**: Always select the column type explicitly.

**Avoid info icons (ⓘ)**: They trigger tooltips that can block the UI.

### Hide Tooltips

Rich tooltips with class `rich-tooltip-*` can block clicks and interfere with automation. Run this via `browser_evaluate` to hide them:

```javascript
() => {
  document.querySelectorAll('[class*="rich-tooltip"]').forEach(el => el.remove());
  return { removed: true };
}
```

Run this periodically if tooltips keep appearing, or after hovering over info icons accidentally.

**Keyboard shortcuts:**
- `Cmd+K` - Open search
- `Escape` - Close dialogs and panels
- `CMD+SHIFT+ENTER` - Add new column (when in Data Editor with table selected)
- `CMD+Z` (macOS) / `CTRL+Z` (Windows) - Undo last action

**Undo mistakes:**
Glide Builder supports standard undo functionality. If you accidentally delete a component, action, or make an unwanted change, immediately use `CMD+Z` (macOS) or `CTRL+Z` (Windows) to revert it.

**Common scenarios:**
- Deleted the wrong action → CMD+Z to restore it
- Removed a component by mistake → CMD+Z to bring it back
- Changed a setting incorrectly → CMD+Z to revert

**Important**: Undo only works for recent actions in the current session. If you navigate away or refresh, you may not be able to undo.

**If stuck:**
1. Press Escape to clear overlays
2. Click a main navigation tab to reset
3. Take a screenshot to see current state
4. If completely stuck, refresh the page
