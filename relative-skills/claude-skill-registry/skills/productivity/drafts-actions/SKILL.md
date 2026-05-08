---
name: drafts-actions
description: Create and script actions for the Drafts app. Use this skill when the user needs help creating custom Drafts actions, understanding action steps, using template tags, scripting with JavaScript, or configuring action workflows for automation and productivity.
---

# Drafts Actions

## Overview

This skill provides comprehensive guidance for creating custom actions in Drafts, the text capture and automation app for iOS and macOS. Actions are powerful automation workflows that combine multiple steps to process text, integrate with external services, and automate repetitive tasks.

## Core Concepts

### What Are Actions

Actions in Drafts are automation workflows consisting of one or more sequential steps. Each action can:
- Process and transform draft content
- Send data to external services
- Create files, emails, messages, and tasks
- Run custom JavaScript code
- Integrate with other apps via URL schemes

### Action Components

Every action has three core components:

1. **Metadata**: Name, icon (including SF Symbols), color, keyboard shortcut
2. **Steps**: Sequential operations to perform (System, Services, Utility, Advanced)
3. **Configuration**: Behavior after success (archive, tag, etc.), notifications, logging

### When Actions Execute

Actions can be triggered via:
- Action bars (keyboard row or action list)
- External keyboard shortcuts
- URL schemes (`drafts://x-callback-url/runAction`)
- Scheduled automation (via Shortcuts)

## Creating Actions

### UI-Based Creation

To create an action through the Drafts interface:

**iOS:**
1. Open action list
2. Tap "+" button
3. Configure name, icon, and tint color
4. Tap "Steps" to add action steps
5. Configure "After Success" behavior if needed

**macOS:**
1. Open action list
2. Click "+" button or File → New Action
3. Follow same configuration process

### Programmatic Creation

Actions can be created dynamically via JavaScript scripts within Drafts:

```javascript
// Get or create an action group
let group = ActionGroup.find("My Actions");

// Create new action
let action = Action.create();
action.name = "My Custom Action";

// Add a script step
let step = action.addStep();
step.type = "script";
step.script = `
  let content = draft.content.toUpperCase();
  draft.content = content;
  draft.update();
`;

// Add to action group
action.actionGroup = group;
action.update();
```

### Action Sharing and Export

Actions can be shared via URL schemes:
- Export: Right-click action → "Share" → Copy URL
- Import: Open action URL or use `drafts://action?data=[URL-encoded-JSON]`
- Directory: Post to the Drafts Directory for public sharing

## Action Steps

Actions consist of sequential steps from four categories:

### System Steps (11 types)

Built-in iOS/macOS integration steps:

1. **Share**: Send to system share sheet
2. **Clipboard**: Replace, append, or prepend to clipboard
3. **Mail**: Create email via Mail.app or background service (supports HTML)
4. **Message**: Send iMessage to recipients
5. **Reminder**: Create individual reminder
6. **List in Reminders**: Convert draft lines to multiple reminders
7. **Event**: Create calendar event
8. **Export**: Save files to Files.app with folder selection
9. **Open in...**: Share files via document interaction (iOS only)
10. **Print**: Send to AirPrint printer (text or HTML)
11. **Speak Text**: Use text-to-speech with auto-start/close

### Service Steps (22 integrations)

External service integrations:

**File Storage:**
- File (iCloud Drive/local), Dropbox, Google Drive, Box, OneDrive, WebDAV

**Task Management:**
- Google Tasks, Microsoft To Do, Todoist

**Notes & Documentation:**
- Evernote (iOS only), OneNote, Notion

**Email Services:**
- Gmail, Outlook

**Publishing:**
- WordPress, Ghost, Medium, Mastodon

**Data:**
- Airtable (insert records with up to 5 fields)

### Utility Steps (4 types)

Internal Drafts operations:

1. **Create Draft**: Generate new draft with content, tags, syntax, and location (inbox/archive)
2. **Insert Text**: Insert templated content at cursor position (best for keyboard actions)
3. **Define Template Tag**: Create custom template tag from template content
4. **Configure Window**: Control UI visibility (draft list, action list, action bar, tag entry)

### Advanced Steps

Scripting and advanced automation:

1. **Script**: Execute JavaScript with Drafts API access
   - Enable "Allow asynchronous execution" for async operations
   - Call `script.complete()` when async work finishes

2. **Include Action**: Reuse steps from another action (prevents duplication)

3. **Run Shortcut**: Execute Apple Shortcuts with optional response waiting

4. **Run AppleScript**: macOS-only AppleScript execution

5. **HTML Preview**: Display interactive HTML with forms that send data back to actions

6. **Prompt**: Collect user input with customizable buttons and text fields

7. **Callback URL**: Send requests to apps supporting x-callback-url protocol

8. **Open URL**: Launch web URLs or app-specific URL schemes

9. **Configured Value**: Create user-configurable action parameters

## HTMLPreview Forms

HTMLPreview allows you to create custom HTML-based user interfaces that go beyond standard prompts. This is useful for complex forms, multi-step wizards, draft selection interfaces, and any interaction requiring custom styling.

### The Working Pattern

The reliable pattern for HTMLPreview in a Script step:

```javascript
var preview = HTMLPreview.create();
preview.hideInterface = true;  // Hide default toolbar for custom buttons

if (preview.show(html)) {
  var vals = context.previewValues["formValues"];
  if (vals && vals.choice) {
    // Process the user's choice
  }
} else {
  // User cancelled
  context.cancel();
}
```

### Key Points

1. **Use `context.previewValues`** to access data sent from HTML
2. **Check `preview.show()` return value** - `true` if continued, `false` if cancelled
3. **Call `Drafts.send(key, value)`** in HTML JavaScript to send data
4. **Call `Drafts.continue()`** to close the preview and continue execution

### Basic HTML Template

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body {
      font-family: -apple-system, sans-serif;
      padding: 20px;
      background: #fff;
      color: #000;
    }
    @media (prefers-color-scheme: dark) {
      body { background: #1c1c1e; color: #f5f5f7; }
    }
    button {
      display: block;
      width: 100%;
      padding: 14px;
      margin: 10px 0;
      border-radius: 12px;
      font-size: 16px;
    }
    .primary {
      background: #007aff;
      color: white;
      border: none;
    }
  </style>
</head>
<body>
  <h1>Choose an Option</h1>
  <button class="primary" onclick="choose('yes')">Yes</button>
  <button onclick="choose('no')">No</button>
  <script>
    function choose(choice) {
      Drafts.send("formValues", { choice: choice });
      Drafts.continue();
    }
  </script>
</body>
</html>
```

### Form Data Collection

For forms with multiple fields:

```html
<form id="data-form">
  <input type="text" id="title" value="">
  <textarea id="notes"></textarea>
  <input type="checkbox" id="flagged">
</form>
<button onclick="submitForm()">Submit</button>

<script>
function submitForm() {
  var form = document.getElementById('data-form');
  var data = {};
  for (var e of form.elements) {
    if (e.type === 'checkbox') {
      data[e.id] = e.checked;
    } else if (e.id) {
      data[e.id] = e.value;
    }
  }
  Drafts.send("formValues", data);
  Drafts.continue();
}
</script>
```

Then in your script:

```javascript
if (preview.show(html)) {
  var vals = context.previewValues["formValues"];
  var title = vals.title;
  var notes = vals.notes;
  var flagged = vals.flagged;
}
```

### Sequential Prompts

You can show multiple HTMLPreview prompts in a loop:

```javascript
var items = Draft.query("", "inbox", [], [], "created", false);

for (var i = 0; i < items.length; i++) {
  var html = buildPromptHTML(items[i], i + 1, items.length);
  
  var preview = HTMLPreview.create();
  preview.hideInterface = true;
  
  if (preview.show(html)) {
    var vals = context.previewValues["formValues"];
    if (vals.choice === "stop") break;
    // Process choice...
  } else {
    break;
  }
}
```

### Escaping User Content

Always escape user content before inserting into HTML:

```javascript
function escapeHtml(text) {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

var html = `<div>${escapeHtml(draft.content)}</div>`;
```

### Common Mistakes

1. **Don't use `preview.actionLog`** - use `context.previewValues` instead
2. **Don't forget `Drafts.continue()`** - preview won't close without it
3. **Don't skip checking `preview.show()` return** - user may have cancelled
4. **Don't use `let`/`const` across multiple Script steps** - causes duplicate variable errors

See **references/htmlpreview-forms-reference.md** for complete documentation including dark mode CSS, button styles, progress bars, and full working examples.

## Template System

Drafts uses a lightweight template engine with `[[tag]]` syntax for dynamic content.

### Core Template Tags

**Identifier Tags:**
- `[[uuid]]`: Unique draft identifier
- `[[permalink]]`: Shareable draft URL

**Content Tags:**
- `[[draft]]`: Full draft text
- `[[title]]`: First line of draft
- `[[body]]`: All lines after first line
- `[[safe_title]]`: First line with path-unsafe characters removed (\\/:*?<>|#)
- `[[selection]]`: Currently selected text
- `[[selection_only]]`: Selected text or empty string if no selection

**Location Tags:**
- `[[latitude]]`, `[[longitude]]`: Current location
- `[[created_latitude]]`, `[[created_longitude]]`: Location when draft was created
- `[[modified_latitude]]`, `[[modified_longitude]]`: Location when draft was last modified

**Metadata Tags:**
- `[[tags]]`: Comma-separated tag list
- `[[line|n]]`: Specific line number (e.g., `[[line|2]]` for second line)
- `[[line|n..m]]`: Line range (e.g., `[[line|2..5]]`)

### Date/Time Formatting

Two formatting systems available:

**strftime formats (traditional):**
```
[[date|%Y-%m-%d]]          → 2025-10-21
[[date|%B %d, %Y]]         → October 21, 2025
[[created_date|%Y-%m-%d]]  → Creation date
[[modified_date|%Y-%m-%d]] → Modification date
```

**DateFormatter patterns (localized):**
```
[[date|=shortDate]]    → 10/21/25
[[date|=longDate]]     → October 21, 2025
[[date|=iso8601]]      → 2025-10-21T14:30:00Z
[[date|~yyyy-MM-dd]]   → 2025-10-21
```

### Date Adjustment

Modify dates relative to current time:
```
[[date|+1 day|%Y-%m-%d]]      → Tomorrow
[[date|-1 week|%Y-%m-%d]]     → Last week
[[date|+1 year|%Y-%m-%d]]     → Next year
[[date|+3 hours|%H:%M]]       → 3 hours from now
```

### Template Modifiers

**Case transformation:**
- `[[title:upper]]`: UPPERCASE
- `[[title:lower]]`: lowercase

**Length limiting:**
- `[[title:max=50]]`: Truncate to 50 characters

**URL encoding:**
- Use `{{ }}` syntax for URL encoding: `{{title}}`

**Markdown conversion:**
- Use `%% %%` syntax to convert to Markdown: `%%draft%%`

### Custom Template Tags

Create custom tags in scripts:
```javascript
draft.setTemplateTag("word_count", draft.content.split(/\s+/).length);
// Use as [[word_count]] in templates
```

### Template Files

Load external templates from iCloud Drive:
```
[[template|path/to/template.txt]]
```

### Escaping

Prevent template evaluation with backslash:
```
\[[title]]  → Renders as literal "[[title]]"
```

## JavaScript Scripting

Drafts provides a complete JavaScript runtime (ECMAScript 6) with extensive APIs.

### Core Objects

**Draft object:**
```javascript
// Access current draft
draft.content              // Full text content
draft.title                // First line
draft.body                 // All lines after first
draft.tags                 // Array of tags
draft.isFlagged           // Boolean flag status
draft.isArchived          // Boolean archive status
draft.createdAt           // Date created
draft.modifiedAt          // Date modified

// Modify draft
draft.content = "New content";
draft.addTag("important");
draft.removeTag("old");
draft.update();           // Save changes

// Template processing
let processed = draft.processTemplate("[[title]] - [[date]]");

// Custom template tags
draft.setTemplateTag("custom", "value");
```

**Editor object:**
```javascript
// Access editor state
editor.getText()                    // Current text
editor.getSelectedText()           // Selected text
editor.getSelectedRange()          // [start, length]
editor.getTextInRange(0, 10)      // Get specific range

// Modify editor
editor.setText("New text");
editor.setSelectedText("Replacement");
editor.setSelectedRange(0, 5);    // Select range
editor.activate();                 // Focus editor
```

**App object:**
```javascript
// App state
app.currentWorkspace              // Active workspace
app.isIdleDisabled               // Idle timer state

// User interaction
app.displayInfoMessage("Info");
app.displayWarningMessage("Warning");
app.displayErrorMessage("Error");

// Open URLs
app.openURL("https://example.com");
```

**Context object:**
```javascript
// Access action context
context.callbackURL               // x-callback-url that triggered action
context.configuredValues          // User-configured values for action

// Example: Access configured value
let folderName = context.configuredValues["folderName"];
```

### Working with Drafts

**Query drafts:**
```javascript
// Find drafts
let all = Draft.query("", "all", [], [], "accessed");
let tagged = Draft.query("", "inbox", ["important"], [], "created");

// Parameters: content, filter, tags, omit_tags, sort
// filter: "inbox", "archive", "flagged", "all"
// sort: "created", "modified", "accessed"
```

**Create new drafts:**
```javascript
let d = Draft.create();
d.content = "New draft content";
d.addTag("auto-created");
d.update();
```

**Process multiple drafts:**
```javascript
let drafts = Draft.query("todo", "inbox", [], [], "created");
for (let d of drafts) {
  d.addTag("processed");
  d.update();
}
```

### Asynchronous Operations

For HTTP requests, delays, or async operations:

```javascript
// Enable "Allow asynchronous execution" in Script step settings

// HTTP request example
let http = HTTP.create();
let response = http.request({
  "url": "https://api.example.com/data",
  "method": "POST",
  "encoding": "json",  // CRITICAL: Required to serialize data as JSON
  "data": {
    "title": draft.title
  },
  "headers": {
    "Content-Type": "application/json",
    "Authorization": "Bearer YOUR_API_KEY"
  }
});

if (response.success) {
  app.displayInfoMessage("Posted successfully");
} else {
  app.displayErrorMessage("Request failed");
  context.fail();
}

// REQUIRED: Signal completion
script.complete();
```

**Important HTTP Request Parameters:**
- `"encoding": "json"` - **CRITICAL**: Tells Drafts to automatically JSON-serialize the `data` object. Without this, the request body will be empty!
- `"data"` - Pass as a JavaScript object, NOT a JSON string. Drafts will serialize it automatically when `encoding: "json"` is set.
- `"headers"` - Object containing HTTP headers
- `"method"` - HTTP verb ("GET", "POST", "PUT", "DELETE", etc.)

**Common mistake:** Omitting `"encoding": "json"` or trying to JSON.stringify() the data manually. Always use `"encoding": "json"` with an object in the `"data"` field.

### Integration Examples

**Mail integration:**
```javascript
let mail = Mail.create();
mail.toRecipients = ["user@example.com"];
mail.subject = draft.title;
mail.body = draft.body;
mail.isHTML = false;

let success = mail.send();
if (!success) {
  context.fail();
}
```

**Dropbox integration:**
```javascript
let db = Dropbox.create();
let success = db.write(
  `/notes/${draft.title}.txt`,
  draft.content,
  "add",  // Mode: "add", "overwrite"
  false   // Not a folder
);

if (!success) {
  app.displayErrorMessage("Dropbox write failed");
  context.fail();
}
```

## Action Configuration

Actions support user-configurable values for flexibility without editing.

### Adding Configured Values

1. Add "Configured Value" action step
2. Set properties:
   - **Name**: Display label ("Folder Name")
   - **Description**: Usage explanation
   - **Key**: Identifier for accessing value ("folderName")
   - **Value Type**: String, number, or boolean
   - **Default Values**: Optional suggestions
   - **Requires Configuration**: Make mandatory or optional

### Accessing Configured Values

**In templates:**
```
[[folderName]]
```

**In scripts:**
```javascript
let folder = context.configuredValues["folderName"];
```

### Configuration Workflow

Users configure actions via context menu:
- **iOS**: Long press → "Configure"
- **Mac**: Right-click → "Configure"

Only actions with configured values show "Configure" option.

## Best Practices

### Action Organization

1. **Use descriptive names**: "Send to Notion" vs. "Action 1"
2. **Choose meaningful icons**: Use SF Symbols for clarity
3. **Group related actions**: Organize in action groups by workflow
4. **Create aliases**: Maintain single source of truth, use aliases in multiple groups

### Template Efficiency

1. **Use safe_title for filenames**: Prevents path issues
2. **Test date formats**: Verify output matches expectations
3. **Leverage template files**: Reuse complex templates
4. **Create custom tags**: Simplify repeated complex templates

### Scripting Best Practices

1. **Handle errors gracefully**: Use `context.fail()` for failures
2. **Provide user feedback**: Use `app.displayInfoMessage()` for status
3. **Test with sample data**: Verify behavior with test drafts
4. **Use async for network**: Enable async execution for HTTP requests
5. **Update drafts explicitly**: Call `draft.update()` after modifications

### Action Step Ordering

1. **Validate first**: Check conditions before expensive operations
2. **Process then send**: Transform content before external steps
3. **Prompt early**: Get user input before processing
4. **Log appropriately**: Use error-only logging for production, all for debugging

## Common Action Patterns

### Quick Capture to Service

Convert draft to task/note in external service:

**Steps:**
1. Service step (e.g., Todoist, Notion)
   - Title: `[[title]]`
   - Content: `[[body]]`
2. After Success: Archive draft, add tag "processed"

### File Export with Date

Save draft as file with timestamp:

**Steps:**
1. Export step
   - Filename: `[[date|%Y-%m-%d]]-[[safe_title]].md`
   - Content: `[[draft]]`
   - Folder: Select destination
2. After Success: Add tag "exported"

### Email with Template

Send formatted email from template:

**Steps:**
1. Mail step
   - To: `user@example.com`
   - Subject: `[[title]]`
   - Body: Use template file with placeholders
   - HTML: Enabled
2. After Success: Archive draft

### Multi-Service Publishing

Post to multiple platforms simultaneously:

**Steps:**
1. Mastodon step (post status)
2. Medium step (create story)
3. WordPress step (create post)
4. After Success: Archive, add tag "published"

### Conditional Processing

Use script to check conditions:

```javascript
// Check if draft has specific tag
if (draft.tags.includes("urgent")) {
  // Create high-priority task
  let reminder = Reminder.create();
  reminder.title = draft.title;
  reminder.priority = 1;
  reminder.update();
} else {
  // Regular processing
  draft.addTag("normal");
  draft.update();
}
```

### Text Transformation

Transform draft content in-place:

```javascript
// Convert to uppercase
draft.content = draft.content.toUpperCase();
draft.update();

// Add line numbers
let lines = draft.content.split("\n");
let numbered = lines.map((line, i) => `${i+1}. ${line}`).join("\n");
draft.content = numbered;
draft.update();

// Word count
let words = draft.content.split(/\s+/).length;
draft.setTemplateTag("count", words);
app.displayInfoMessage(`Word count: ${words}`);
```

### Batch Processing

Process multiple drafts matching criteria:

```javascript
// Find all flagged drafts
let drafts = Draft.query("", "flagged", [], [], "created");

for (let d of drafts) {
  // Add tag and unflag
  d.addTag("reviewed");
  d.isFlagged = false;
  d.update();
}

app.displayInfoMessage(`Processed ${drafts.length} drafts`);
```

### API Integration: Claude Translation

Complete working example calling the Claude API to translate draft content:

```javascript
// Get the current draft content
const originalText = draft.content;

// Your Anthropic API key (set this in Drafts credentials)
const credential = Credential.create("Anthropic API", "Enter your Anthropic API key");
credential.addPasswordField("apiKey", "API Key");
credential.authorize();
const apiKey = credential.getValue("apiKey");

if (!apiKey) {
    alert("API key not found. Please set up your Anthropic API key.");
    context.fail();
}

// Claude API endpoint
const endpoint = "https://api.anthropic.com/v1/messages";

// Prepare the API request
const http = HTTP.create();

const requestData = {
    "model": "claude-3-5-haiku-20241022",
    "max_tokens": 4096,
    "messages": [
        {
            "role": "user",
            "content": `Translate the following text to English. Only provide the translation, no explanations or additional text:\n\n${originalText}`
        }
    ]
};

// Make the API call
const response = http.request({
    "url": endpoint,
    "method": "POST",
    "encoding": "json",  // CRITICAL: Required for JSON serialization
    "data": requestData,
    "headers": {
        "x-api-key": apiKey,
        "anthropic-version": "2023-06-01"
    }
});

// Check if the request was successful
if (response.success) {
    const responseData = JSON.parse(response.responseText);
    const translation = responseData.content[0].text;

    // Append translation below original text
    draft.content = originalText + "\n\n---\n\n**English Translation:**\n\n" + translation;
    draft.update();

    app.displaySuccessMessage("Translation completed!");
} else {
    // Try to parse error message
    let errorMsg = "Translation failed. Status code: " + response.statusCode;
    try {
        const errorData = JSON.parse(response.responseText);
        if (errorData.error && errorData.error.message) {
            errorMsg += "\n\nError: " + errorData.error.message;
        }
    } catch (e) {
        errorMsg += "\n\nResponse: " + response.responseText;
    }

    alert(errorMsg);
    context.fail();
}
```

**Key Points:**
- Uses Drafts' Credential system for secure API key storage
- Demonstrates proper error handling with detailed error messages
- Shows how to parse JSON responses and extract specific fields
- Appends result to original draft content

## Resources

This skill includes reference documentation with detailed information:

### references/action-steps-reference.md

Comprehensive documentation of all action step types with examples and configuration options. Load this reference when working with specific step types or needing detailed parameter information.

### references/scripting-api-reference.md

Detailed JavaScript API reference covering all major objects (Draft, Editor, App, HTTP, etc.) with method signatures, parameters, and return values. Load when scripting complex actions or working with specific API features.

### references/template-tags-reference.md

Complete reference for Drafts template tag syntax covering all built-in tags (identifier, content, location, date/time, utility), formatting options (strftime, DateFormatter), date adjustment, special markup, and escaping. Load when working with templates or needing detailed syntax beyond the core template concepts in this skill.

### references/htmlpreview-forms-reference.md

Comprehensive guide to creating custom HTML-based user interfaces using HTMLPreview. Covers the working pattern for `context.previewValues`, form data collection, sequential prompts, dark mode CSS, button styles, progress bars, escaping user content, and common mistakes to avoid. Load when building custom HTML interfaces that go beyond standard prompts.

Use these references as needed for detailed implementation guidance beyond the core concepts covered in this skill.
