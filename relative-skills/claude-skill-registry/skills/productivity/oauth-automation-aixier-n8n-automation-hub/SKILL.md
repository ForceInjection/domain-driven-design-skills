---
name: oauth-automation
description: Use when OAuth tokens expire frequently, need automatic token refresh, YouTube/Google API integration, or when workflows fail due to expired credentials
---

# OAuth Token Automation

**When to use**: Workflows using OAuth (YouTube, Google, Facebook, etc.) that need automatic token refresh without manual intervention.

## Problem Statement

**OAuth tokens expire** (typically 1 hour), breaking workflows that run on schedules. Manual token refresh via n8n UI is not sustainable for production workflows.

## Solutions Overview

| Solution | Reliability | Performance | Complexity | Use Case |
|----------|-------------|-------------|------------|----------|
| **Real-time Refresh** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | Best for critical workflows |
| **Scheduled Update** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | Good for daily workflows |
| **Hybrid Mode** | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | Recommended balance |
| Hardcoded | ⭐ | ⭐⭐⭐ | ⭐ | ❌ Not recommended |

## Solution 1: Real-Time Refresh (Recommended)

**Pattern**: Workflow refreshes token at start of every execution.

### Workflow Structure
```
[Trigger]
    ↓
[Get Refresh Token from n8n DB]
    Read credential: id=123
    ↓
[Refresh OAuth Token]
    POST to token endpoint
    ↓
[Store Access Token for Use]
    Pass to downstream nodes
    ↓
[YouTube/Google API Call]
    Use fresh access_token
```

### Implementation

```javascript
// Code Node: Refresh OAuth Token
var https = require('https');

var clientId = process.env.GOOGLE_CLIENT_ID;
var clientSecret = process.env.GOOGLE_CLIENT_SECRET;
var refreshToken = process.env.GOOGLE_REFRESH_TOKEN;

var postData = JSON.stringify({
  client_id: clientId,
  client_secret: clientSecret,
  refresh_token: refreshToken,
  grant_type: 'refresh_token'
});

var options = {
  hostname: 'oauth2.googleapis.com',
  path: '/token',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData)
  }
};

var tokenData = await new Promise(function(resolve, reject) {
  var req = https.request(options, function(res) {
    var data = '';
    res.on('data', function(chunk) { data += chunk; });
    res.on('end', function() {
      if (res.statusCode === 200) {
        resolve(JSON.parse(data));
      } else {
        reject(new Error('Token refresh failed: ' + data));
      }
    });
  });
  req.on('error', reject);
  req.write(postData);
  req.end();
});

return {
  json: {
    access_token: tokenData.access_token,
    expires_in: tokenData.expires_in,
    token_type: tokenData.token_type
  }
};
```

```javascript
// Code Node: Use Token in API Call
var accessToken = $input.first().json.access_token;
var videoId = 'abc123';

var options = {
  hostname: 'www.googleapis.com',
  path: '/youtube/v3/videos?part=snippet&id=' + videoId,
  method: 'GET',
  headers: {
    'Authorization': 'Bearer ' + accessToken
  }
};

var result = await makeRequest(options);
return {json: result};
```

**Pros**:
- ✅ Always uses fresh tokens
- ✅ No risk of expiration mid-workflow
- ✅ Works for any schedule

**Cons**:
- ⚠️ Extra API call per execution (~500ms)
- ⚠️ Refresh token must be secure

## Solution 2: Scheduled Update via n8n API

**Pattern**: Separate workflow updates main workflow code every 30 minutes.

### Architecture
```
[Schedule Trigger: Every 30min]
    ↓
[Refresh OAuth Token]
    ↓
[Update Workflow Code via n8n API]
    PATCH /workflows/{id}
    Replace token in Code node
    ↓
[Main Workflow Uses Updated Token]
```

### Implementation

```javascript
// Scheduled Workflow: Update Token in Main Workflow
var https = require('https');

// Step 1: Refresh token (same as Solution 1)
var tokenData = await refreshOAuthToken();

// Step 2: Get current workflow
var workflowId = 'main-workflow-id';
var n8nApiKey = process.env.N8N_API_KEY;

var getOptions = {
  hostname: 'localhost',
  port: 5678,
  path: '/api/v1/workflows/' + workflowId,
  method: 'GET',
  headers: {
    'X-N8N-API-KEY': n8nApiKey
  }
};

var workflow = await makeRequest(getOptions);

// Step 3: Update token in Code node
var nodes = workflow.nodes;
for (var i = 0; i < nodes.length; i++) {
  if (nodes[i].name === 'YouTube API Call') {
    var code = nodes[i].parameters.jsCode;
    // Replace token in code
    var newCode = code.replace(
      /const ACCESS_TOKEN = '[^']+'/,
      "const ACCESS_TOKEN = '" + tokenData.access_token + "'"
    );
    nodes[i].parameters.jsCode = newCode;
  }
}

// Step 4: Update workflow
var updateOptions = {
  hostname: 'localhost',
  port: 5678,
  path: '/api/v1/workflows/' + workflowId,
  method: 'PATCH',
  headers: {
    'X-N8N-API-KEY': n8nApiKey,
    'Content-Type': 'application/json'
  }
};

var updateBody = JSON.stringify({nodes: nodes});
await makeRequest(updateOptions, updateBody);

return {json: {success: true, token_expires: tokenData.expires_in}};
```

**Pros**:
- ✅ No performance overhead in main workflow
- ✅ Works even if workflow doesn't run for days

**Cons**:
- ⚠️ Tokens may still expire if schedule misses
- ⚠️ Requires n8n API access

## Solution 3: Hybrid Mode (Recommended)

Combines both approaches:
1. **Scheduled update** keeps token fresh in code
2. **Real-time refresh** as fallback on API errors

```javascript
// Try using token from code
var accessToken = 'token-from-scheduled-update';

try {
  var result = await callAPI(accessToken);
  return {json: result};
} catch (error) {
  if (error.statusCode === 401) {
    // Token expired, refresh now
    var newToken = await refreshOAuthToken();
    var result = await callAPI(newToken.access_token);
    return {json: result};
  }
  throw error;
}
```

## Configuration

### Environment Variables
```bash
# .env or startup script
export GOOGLE_CLIENT_ID=your_client_id
export GOOGLE_CLIENT_SECRET=your_client_secret
export GOOGLE_REFRESH_TOKEN=1//0xxx...  # Long-lived refresh token
export N8N_API_KEY=n8n_api_xxx  # For Solution 2
```

### Get Refresh Token
```bash
# 1. Get authorization code (browser)
https://accounts.google.com/o/oauth2/v2/auth?
  client_id=YOUR_CLIENT_ID&
  redirect_uri=http://localhost&
  response_type=code&
  scope=https://www.googleapis.com/auth/youtube.readonly&
  access_type=offline&
  prompt=consent

# 2. Exchange code for tokens
curl -X POST https://oauth2.googleapis.com/token \
  -d "client_id=YOUR_CLIENT_ID" \
  -d "client_secret=YOUR_CLIENT_SECRET" \
  -d "code=AUTHORIZATION_CODE" \
  -d "redirect_uri=http://localhost" \
  -d "grant_type=authorization_code"

# Response includes refresh_token (save this!)
```

## Best Practices

1. **Store Refresh Token Securely**: Environment variable, not in code
2. **Handle Errors**: Retry on network failures, alert on auth failures
3. **Log Token Refresh**: Track when tokens are refreshed for debugging
4. **Use HTTPS**: Always use secure connections for token requests
5. **Rotate Tokens**: Periodically regenerate refresh tokens for security

## Troubleshooting

### Invalid refresh token
```
Error: invalid_grant
Solution: Re-authorize and get new refresh_token
```

### Token refresh rate limit
```
Error: rate_limit_exceeded
Solution: Cache access_token, only refresh when needed (check expires_in)
```

### n8n API authentication failed
```
Error: 401 Unauthorized
Solution: Check N8N_API_KEY is correct and has workflow:write permission
```

## Integration with Other Skills

- **video-processing**: Use fresh token for YouTube API
- **error-handling**: Retry on token refresh failures
- **notion-operations**: Log token refresh events

## Full Code and Documentation

Complete implementations:
`/mnt/d/work/n8n_agent/n8n-skills/n8n-oauth-automation/`

Files:
- `oauth-token-refresh.js` - Token refresh implementation
- `n8n-api-workflow-update.js` - Scheduled update pattern
- `code-node-https-example.js` - HTTP request template
- `README.md` - Complete guide with all solutions
