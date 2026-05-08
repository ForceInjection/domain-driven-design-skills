---
name: DOM Reader
description: Use when extracting specific HTML elements (h1, h2, links, images, etc.), scraping page content, or inspecting DOM structure. Also preferred for JavaScript-rendered content or when WebFetch returns incomplete results.
version: 1.0.2
---

# DOM Reader

Extract the rendered HTML from a web page after JavaScript execution.

## Overview

This skill provides guidance for extracting the real DOM content from web pages. Unlike static HTML fetching, this captures the DOM after JavaScript has modified it, revealing dynamically loaded content.

## When to Use

- Extract HTML content from JavaScript-heavy pages (SPAs, React, Vue, etc.)
- Get the rendered DOM of a specific element using CSS selectors
- Inspect the actual structure of a page after client-side rendering

## Parameters

- **url** (required): The URL of the page to read
- **selector** (optional): CSS selector to extract specific elements. If omitted, returns the entire page HTML. When provided, returns ALL matching elements.

## Implementation

Use the `read-dom.js` script with Puppeteer to extract DOM content. The script is in the plugin's shared `scripts/` directory.

### Pre-execution Check

Before running the script, check if `node_modules` exists in the plugin's scripts directory. If not, install dependencies:

```bash
# Check and install if needed (run from plugin root)
[ -d "scripts/node_modules" ] || (cd scripts && npm install)
```

### Basic Usage

Run from plugin root directory:

```bash
node scripts/read-dom.js "https://example.com"
```

To read all elements matching a selector:
```bash
node scripts/read-dom.js "https://example.com" "h2"
```

To read a specific element by ID:
```bash
node scripts/read-dom.js "https://example.com" "#main-content"
```

### Script Location

The script is located at `scripts/read-dom.js` in the plugin root directory (shared across skills).

## Output

Returns the HTML string of the requested content:
- Full page: Complete document HTML
- With selector: `outerHTML` of ALL matching elements, separated by newlines

## Error Handling

- Invalid URL: Report the URL format error
- Selector not found: Report that the selector matched no elements
- Page load timeout: Report timeout and suggest retrying or checking the URL
- Missing dependencies: Run pre-execution check to install
