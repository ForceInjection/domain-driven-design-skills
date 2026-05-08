---
name: ntfy-notify
description: Send push notifications via ntfy.sh. Use this skill when the user asks to be notified, wants an alert, or when a long-running task completes and the user should be informed.
---

# ntfy.sh Notifications

Send push notifications to the user's device via ntfy.sh.

## Configuration

- **Topic**: `YOUR_TOPIC`
- **Endpoint**: `https://ntfy.sh/YOUR_TOPIC`

## How to Send Notifications

Use curl to send a notification:

```bash
curl -d "Your message here" ntfy.sh/YOUR_TOPIC
```

### With a Title

```bash
curl -H "Title: Task Complete" -d "Your message here" ntfy.sh/YOUR_TOPIC
```

### With Priority

Priority levels: `min`, `low`, `default`, `high`, `urgent`

```bash
curl -H "Priority: high" -d "Your message here" ntfy.sh/YOUR_TOPIC
```

### With Tags/Emojis

```bash
curl -H "Tags: white_check_mark" -d "Build succeeded" ntfy.sh/YOUR_TOPIC
```

## Click Actions (Deeplinks)

Make the notification clickable - tapping it opens a URL or deeplink.

```bash
curl -H "Click: https://example.com" -d "Click to open" ntfy.sh/YOUR_TOPIC
```

Supports any URI scheme: `https://`, `mailto:`, app deeplinks, etc.

## Action Buttons

Add up to 3 interactive buttons to notifications. Separate multiple actions with semicolons.

### View Action (Open URL/App)

```bash
curl \
  -H "Actions: view, Open Link, https://example.com" \
  -d "Check this out" ntfy.sh/YOUR_TOPIC
```

### HTTP Action (Trigger API)

```bash
curl \
  -H "Actions: http, Run Build, https://api.example.com/build, method=POST" \
  -d "Ready to deploy?" ntfy.sh/YOUR_TOPIC
```

### Multiple Actions

```bash
curl \
  -H "Actions: view, View Logs, https://logs.example.com; http, Retry, https://api.example.com/retry, method=POST" \
  -d "Build failed" ntfy.sh/YOUR_TOPIC
```

### Action Format

```
<type>, <label>, <url>, [options]
```

- **type**: `view` or `http`
- **label**: Button text
- **url**: Target URL or deeplink
- **options**: `method=POST`, `body={"key":"value"}`, `clear=true`

## Combined Example

```bash
curl \
  -H "Title: Deploy Complete" \
  -H "Tags: rocket" \
  -H "Priority: high" \
  -H "Click: https://app.example.com" \
  -H "Actions: view, View Site, https://app.example.com; view, View Logs, https://logs.example.com" \
  -d "Production deployment finished successfully" \
  ntfy.sh/YOUR_TOPIC
```

## When to Use

- After completing a long-running task (builds, tests, deployments)
- When an error occurs that needs attention
- When user explicitly asks to be notified
- When waiting for user input after completing work

## Example Messages

- Task completion: "Build completed successfully"
- Error alert: "Build failed: 3 type errors found"
- Status update: "Deployment to staging complete"
