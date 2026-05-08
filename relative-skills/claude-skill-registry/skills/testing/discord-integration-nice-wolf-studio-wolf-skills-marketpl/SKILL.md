---
name: discord-integration
version: 1.0.1
description: Use when sending Discord messages or encountering bot permission errors - provides three-tier integration methods with automatic fallback (MCP → REST API → Gateway); prevents wasted time on OAuth scope issues
triggers:
  - discord
  - send message
  - permission error
  - bot access
  - discord.js
  - mcp discord
---

# Discord Integration

Comprehensive skill for working with Discord from Claude Code using multiple methods with automatic fallback.

## When to Use This Skill

Use this skill when the user wants to:
- Send messages to Discord channels
- Read messages from Discord channels
- Troubleshoot Discord bot connection or permission issues
- Set up or configure Discord bot access
- Choose the best method for Discord interaction

**Trigger phrases:**
- "Send a message to Discord"
- "Post to #channel-name"
- "Read messages from Discord"
- "Discord bot isn't working"
- "Can't access Discord channel"

## When NOT to Use This Skill

**Do NOT use this skill for:**
- **Discord server management** - Use Discord's admin panel for creating channels, managing roles, or configuring server settings
- **Complex bot features** - For advanced slash commands, persistent state, or complex workflows, build a dedicated bot application
- **Real-time message listening** - This skill focuses on sending/reading; continuous message monitoring requires a persistent Gateway connection outside this skill's scope
- **Voice channel interactions** - This skill only handles text channels

## Available Bots on This Machine

### 1. Sombra (Local MCP Bot)
- **Purpose:** Claude Code MCP integration (this machine only)
- **Token Location:** `~/.claude/discordmcp/.env`
- **Client ID:** 1435274653126889544
- **Guild:** Nice Wolf Studio (745376918030909471)
- **Connection:** discord.js Gateway via MCP server
- **Use For:** Claude Code sessions, automated workflows

### 2. GladOSv3 (tjr-suite Bot)
- **Purpose:** Trading bot application
- **Token Location:** `~/Dev/tjr-suite/.env`
- **Client ID:** 1425850836277395506
- **Guild:** Nice Wolf Studio (745376918030909471)
- **Connection:** discord.js Gateway (always running)
- **Use For:** Trading signals, slash commands, application-specific tasks

**Important:** These are separate bots. Do not confuse their configurations.

## Three Integration Methods (Priority Order)

### Method 1: MCP Tools (PREFERRED)
**Availability:** After Claude Code full restart
**Tools:** `mcp__discord__send-message`, `mcp__discord__read-messages`

**Pros:**
- Clean, native Claude Code integration
- No manual script execution
- Persistent connection via discord.js Gateway
- Smart auto-discovery (find channels by name or ID)

**Cons:**
- Requires full Claude Code restart to load
- Not available immediately after config changes

### Method 2: Discord.js Gateway Script (FALLBACK)
**Availability:** Always (if bot token configured)
**Script:** `~/.claude/discordmcp/send-test-message.js`

**Pros:**
- Works immediately, no restart needed
- Direct access to discord.js library
- Can be customized easily
- Reliable connection

**Cons:**
- Requires manual script execution
- Less integrated than MCP tools

### Method 3: REST API (LAST RESORT)
**Availability:** Always
**Method:** Direct curl to Discord API v10

**Pros:**
- No dependencies
- Quick for testing

**Cons:**
- Often gets "Missing Access" (OAuth scope issues)
- Requires exact permissions
- Less reliable than Gateway methods

## Integration Method Selection (MANDATORY)

**ALWAYS follow this priority order - do NOT skip steps:**

```
User requests Discord interaction
  ↓
STEP 1: Are MCP tools available? (mcp__discord__send-message)
  YES → REQUIRED: Use MCP tools (Method 1)
  NO ↓
  ↓
STEP 2: Can we use send-test-message.js? (file exists, token configured)
  YES → REQUIRED: Use Gateway script (Method 2)
  NO ↓
  ↓
STEP 3: Try REST API (Method 3) with warning about limitations
  ↓
FALLBACK LOGIC:
  - If Method 1 fails → Immediately try Method 2
  - If Method 2 fails → Try Method 3
  - If Method 3 fails → Report error with troubleshooting steps
```

**CRITICAL:** You MUST attempt Method 1 (MCP) first, even if you think it won't work. Only fall back after confirming failure.

## Step-by-Step Instructions

### Step 1: Check Method Availability

**Before attempting any Discord interaction, determine which method is available:**

1. **Try MCP tools first:**
   ```javascript
   // Attempt to use MCP tool
   mcp__discord__send-message({
     channel: "CHANNEL_ID",
     message: "Test"
   })
   ```

   If you get "No such tool available" error → MCP not loaded

2. **Fall back to Gateway script:**
   ```bash
   # Check if script exists
   ls -la ~/.claude/discordmcp/send-test-message.js

   # Check if token configured
   grep DISCORD_TOKEN ~/.claude/discordmcp/.env
   ```

3. **REST API as last resort** (expect permission issues)

### Step 2: Execute Based on Available Method

#### Using Method 1: MCP Tools

**Send Message:**
```javascript
mcp__discord__send-message({
  channel: "1420759585349697710",  // Channel ID or name
  message: "Your message here"
})
```

**Read Messages:**
```javascript
mcp__discord__read-messages({
  channel: "1420759585349697710",
  limit: 10  // 1-100
})
```

#### Using Method 2: Gateway Script

**Send Message:**
```bash
cd ~/.claude/discordmcp
node send-test-message.js CHANNEL_ID "Optional custom message"

# Example:
node send-test-message.js 1420759585349697710 "Hello from Claude Code"
```

**Custom Message:**
Create a modified version of the script or pass message as argument.

#### Using Method 3: REST API

**Send Message:**
```bash
curl -X POST "https://discord.com/api/v10/channels/CHANNEL_ID/messages" \
  -H "Authorization: Bot ${DISCORD_BOT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"content": "Your message"}'
```

**Note:** Will likely fail with "Missing Access" - see troubleshooting.

### Step 3: Handle Errors

See troubleshooting section below for specific error codes and solutions.

## Red Flags - STOP

**If you encounter these situations, STOP and address them immediately:**

❌ **Skipping MCP method without trying first**
- **Why it's bad:** MCP is the most reliable method; skipping wastes time with inferior fallbacks
- **Fix:** Always attempt `mcp__discord__send-message` before assuming it won't work

❌ **Not checking bot permissions before sending**
- **Why it's bad:** Results in repeated "Missing Access" errors and wasted API calls
- **Fix:** Verify bot has "View Channel" and "Send Messages" permissions first

❌ **Retrying same failed method repeatedly**
- **Why it's bad:** Same input = same output; you're wasting time and rate limits
- **Fix:** After one failure, switch to next method in priority order

❌ **Missing token/credentials setup**
- **Why it's bad:** Nothing will work without valid authentication
- **Fix:** Verify token exists in appropriate .env file and test with `/users/@me` endpoint

❌ **Not handling 403 Forbidden errors properly**
- **Why it's bad:** 403 means permission issue, not connection issue
- **Fix:** Check channel-specific permissions or switch to Gateway method (better permission handling)

❌ **Using REST API when Gateway methods are available**
- **Why it's bad:** REST API has OAuth scope limitations that cause "Missing Access" errors
- **Fix:** Use MCP tools or Gateway script instead - they have proper intents

## Verification Checklist

**Before marking Discord integration as complete, verify:**

- [ ] **MCP tools attempted first** - You tried `mcp__discord__send-message` before other methods
- [ ] **Permissions verified for channel** - Bot has "View Channel" and "Send Messages" in target channel
- [ ] **Message sent successfully** - Received confirmation (not just "no error")
- [ ] **Error handling implemented** - Code handles failures gracefully with fallback or clear error message
- [ ] **Correct bot used** - Sombra for MCP/local, GladOSv3 for tjr-suite (not mixed up)
- [ ] **Token validated** - Tested token with `/users/@me` endpoint returns valid bot info

## Prerequisites

### General Requirements
- Bot must be in the target Discord server
- Bot must have proper permissions in the target channel
- Valid bot token must be configured

### For MCP Tools
- Claude Code must be fully restarted after mcp.json changes
- MCP server must be configured in `~/.claude/mcp.json`
- Discord MCP server must be built: `cd ~/.claude/discordmcp && npm run build`

### For Gateway Script
- Node.js installed
- discord.js package available (in discordmcp directory)
- Token in `~/.claude/discordmcp/.env`

### For REST API
- `DISCORD_BOT_TOKEN` environment variable set
- Bot must have been added with proper OAuth2 scopes

## Troubleshooting

### Error: "No such tool available: mcp__discord__send-message"

**Cause:** Discord MCP server not loaded in Claude Code.

**Solutions:**
1. **Verify MCP configuration exists:**
   ```bash
   grep -A 5 '"discord"' ~/.claude/mcp.json
   ```

   Should show:
   ```json
   "discord": {
     "type": "stdio",
     "command": "node",
     "args": ["/Users/USERNAME/.claude/discordmcp/build/index.js"]
   }
   ```

2. **Verify MCP server is built:**
   ```bash
   ls -la ~/.claude/discordmcp/build/index.js
   ```

3. **Test MCP server manually:**
   ```bash
   cd ~/.claude/discordmcp
   node build/index.js
   ```
   Should see: "Discord bot is ready!" and "Discord MCP Server running on stdio"

4. **Fully restart Claude Code:**
   - Quit completely (Cmd+Q or equivalent)
   - Relaunch application
   - Start new session

5. **If still not available, use Method 2 (Gateway script) instead.**

### Error: "Missing Access" (Code 50001)

**Cause:** Bot doesn't have permission to access that channel.

**Solutions:**

1. **Verify bot is in the server:**
   ```bash
   curl -H "Authorization: Bot TOKEN" \
     https://discord.com/api/v10/users/@me/guilds
   ```

2. **Check channel-specific permissions:**
   - Right-click channel in Discord
   - Edit Channel → Permissions
   - Add the bot (Sombra or GladOSv3)
   - Enable: View Channel, Send Messages, Read Message History

3. **Grant server-wide permissions:**
   - Server Settings → Roles
   - Find bot's role
   - Enable Send Messages permission

4. **If using REST API, switch to Gateway method** (discord.js or MCP tools)

### Error: "Unknown Guild" (Code 10004)

**Cause:** Bot is not in that Discord server.

**Solutions:**

1. **Verify bot membership:**
   ```bash
   curl -H "Authorization: Bot TOKEN" \
     https://discord.com/api/v10/users/@me/guilds
   ```

2. **Invite bot to server using OAuth2 URL:**

   **For Sombra (Local MCP):**
   ```
   https://discord.com/api/oauth2/authorize?client_id=1435274653126889544&permissions=69632&scope=bot
   ```

   **For GladOSv3 (tjr-suite):**
   ```
   https://discord.com/api/oauth2/authorize?client_id=1425850836277395506&permissions=69632&scope=bot
   ```

3. **After inviting, wait a few seconds for bot to join**

4. **Verify the bot appears in server member list**

### Error: Connection Timeout or "Discord bot is ready!" but MCP fails

**Cause:** Token invalid or bot permissions insufficient.

**Solutions:**

1. **Verify token is correct:**
   ```bash
   curl -H "Authorization: Bot TOKEN" \
     https://discord.com/api/v10/users/@me
   ```
   Should return bot user info, not error.

2. **Check token hasn't been regenerated:**
   - Go to Discord Developer Portal
   - Applications → Your Bot → Bot
   - If token was regenerated, update configs

3. **Verify bot has proper Gateway intents:**
   - In Developer Portal: Bot → Privileged Gateway Intents
   - Enable: Guilds, Guild Messages (Message Content if reading)

4. **Check .env file syntax:**
   ```bash
   cat ~/.claude/discordmcp/.env
   ```
   No extra spaces, quotes, or newlines around token.

### Error: "Channel not found or not a text channel"

**Cause:** Invalid channel ID or bot can't see it.

**Solutions:**

1. **Verify channel ID is correct:**
   - Right-click channel in Discord
   - Copy Channel ID (enable Developer Mode if needed)
   - Channel IDs are 17-19 digit numbers

2. **Check bot can see the channel:**
   - Bot must have "View Channel" permission
   - Channel must not be in a category the bot can't access

3. **Try using channel name instead of ID** (if using MCP tools):
   ```javascript
   mcp__discord__send-message({
     channel: "bot-testing-grounds",  // Name instead of ID
     message: "Test"
   })
   ```

## Bot Configuration Reference

### Sombra (Local MCP) Configuration

**Files:**
- **Token:** `~/.claude/discordmcp/.env`
- **MCP Config:** `~/.claude/mcp.json` (lines 55-61)
- **Source:** `~/.claude/discordmcp/src/index.ts`
- **Built:** `~/.claude/discordmcp/build/index.js`

**Environment Variables:**
```env
DISCORD_TOKEN=MTQzNTI3NDY1MzEyNjg4OTU0NA...
DISCORD_CLIENT_ID=1435274653126889544
DISCORD_GUILD_ID=745376918030909471
DISCORD_ENABLED=true
```

**Rebuild after changes:**
```bash
cd ~/.claude/discordmcp
npm run build
```

### GladOSv3 (tjr-suite) Configuration

**Files:**
- **Token:** `~/Dev/tjr-suite/.env`
- **Source:** `~/Dev/tjr-suite/packages/app/src/services/discord/`
- **HTTP API:** Running on `http://localhost:3000`

**Environment Variables:**
```env
DISCORD_TOKEN=MTQyNTg1MDgzNjI3NzM5NTUwNg...
DISCORD_CLIENT_ID=1425850836277395506
DISCORD_GUILD_ID=745376918030909471
DISCORD_ENABLED=true
```

**Note:** GladOSv3 is always running as part of tjr-suite. Do not confuse with Sombra.

## Common Channel IDs

**Nice Wolf Studio Server:**
- **Guild ID:** 745376918030909471
- **#bot-testing-grounds:** 1420759585349697710

## Permission Reference

### Required Bot Permissions

**Minimum (for message sending):**
- View Channels (1024)
- Send Messages (2048)

**Recommended:**
- Read Message History (65536)
- Add Reactions (64)

**Permission Integer:** 69632 (includes all recommended)

### How to Calculate Custom Permissions

Visit: https://discordapi.com/permissions.html

Enter desired permissions, copy the integer for OAuth2 URL.

## Testing Checklist

When setting up or troubleshooting Discord integration:

- [ ] Bot token is valid (test with `/users/@me` endpoint)
- [ ] Bot is in the correct server (check `/users/@me/guilds`)
- [ ] Bot has View Channel permission
- [ ] Bot has Send Messages permission in target channel
- [ ] Channel ID is correct (17-19 digit number)
- [ ] Token configured in correct .env file
- [ ] MCP server built (if using MCP tools)
- [ ] Claude Code restarted (if using MCP tools)

## Quick Reference Commands

### Verify Token
```bash
curl -H "Authorization: Bot TOKEN" https://discord.com/api/v10/users/@me
```

### List Guilds
```bash
curl -H "Authorization: Bot TOKEN" https://discord.com/api/v10/users/@me/guilds
```

### Test MCP Server
```bash
cd ~/.claude/discordmcp && node build/index.js
```

### Send via Gateway Script
```bash
cd ~/.claude/discordmcp && node send-test-message.js CHANNEL_ID "Message"
```

### Check MCP Config
```bash
grep -A 5 '"discord"' ~/.claude/mcp.json
```

## Examples

See `examples.md` in this skill directory for complete working examples.

## Related Documentation

- **Setup Guide:** `~/.claude/discordmcp/SETUP_COMPLETE.md`
- **Validation Report:** `~/.claude/discordmcp/VALIDATION_REPORT.md`
- **Gateway Script:** `~/.claude/discordmcp/send-test-message.js`
- **Discord.js Docs:** https://discord.js.org/
- **Discord API:** https://discord.com/developers/docs

---

## After Using This Skill

**REQUIRED NEXT STEPS:**

1. **Verify message sent successfully** - Check verification checklist (6 items) to confirm integration worked
2. **Document method used** - Record which method succeeded (MCP/Gateway/REST) for future reference
3. **Test error handling** - Verify fallback logic works if primary method fails

**OPTIONAL NEXT STEPS:**

- **Set up logging** - Track Discord API calls, errors, and response times for debugging
- **Create reusable wrapper** - Build abstraction around working method for consistent usage
- **Monitor bot health** - Set up alerts for token expiration or permission changes

---

## Changelog

### Version 1.0.1 (2025-11-14)
- **Added** superpowers-style improvements for better agent guidance
- **Added** "When NOT to Use" section to prevent misuse
- **Enhanced** Integration Method Selection with MANDATORY fallback logic
- **Added** "Red Flags - STOP" section with 6 common anti-patterns
- **Added** "Verification Checklist" for completion validation
- **Improved** frontmatter with version, triggers, and clearer description
- **Updated** description to emphasize automatic fallback and OAuth scope issue prevention

### Version 1.0.0 (Initial)
- Initial discord-integration skill
- Three-tier integration methods (MCP, Gateway, REST API)
- Comprehensive troubleshooting for common errors
- Configuration reference for Sombra and GladOSv3 bots
