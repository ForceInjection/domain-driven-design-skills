---
name: ha-emby-bug-triage
description: Use when investigating bugs that need reproduction - covers local HA/Emby testing, evidence gathering, root cause analysis, and updating issues with findings and fix recommendations.
---

# Home Assistant Emby Bug Triage

## Overview

**Systematic investigation of bug reports to confirm, diagnose, and prepare fix recommendations.**

This skill covers reproducing bugs locally, gathering evidence, performing root cause analysis, and updating GitHub issues with findings.

## When to Use

- Issue has `bug` label but NOT `confirmed`
- Issue has `ai-triaged` and needs investigation
- Routed here by `ha-emby-issue-selector`
- User asks to "investigate" or "reproduce" a bug

## The Investigation Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    BUG TRIAGE WORKFLOW                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. PARSE ISSUE ─────────────────────────────────────────────   │
│     Extract: versions, clients, steps, logs                    │
│                                                                 │
│  2. SETUP ENVIRONMENT ───────────────────────────────────────   │
│     Start HA, connect Emby, match reporter config              │
│                                                                 │
│  3. REPRODUCE ───────────────────────────────────────────────   │
│     Follow exact steps, document results                       │
│                                                                 │
│  4. GATHER EVIDENCE ─────────────────────────────────────────   │
│     Logs, API traces, screenshots, diagnostics                 │
│                                                                 │
│  5. ROOT CAUSE ANALYSIS ─────────────────────────────────────   │
│     Trace code path, identify failure point                    │
│                                                                 │
│  6. UPDATE ISSUE ────────────────────────────────────────────   │
│     Add findings, labels, fix recommendation                   │
│                                                                 │
│  7. DECIDE NEXT STEP ────────────────────────────────────────   │
│     Fix now? Defer? Need more info?                            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Step 1: Parse Issue Data

Read the issue and extract key information (matches bug report template fields):

```bash
# Get full issue details
gh issue view {N} --json title,body,labels,comments
```

**Extract from issue body:**

| Field | Template Section | Example |
|-------|------------------|---------|
| Integration Version | `integration_version` | 0.4.0 |
| HA Version | `ha_version` | 2025.11.x |
| HA Installation | `ha_installation` | Home Assistant OS |
| Emby Version | `emby_version` | 4.9.x |
| Affected Clients | `emby_client` | Android TV, Web |
| Bug Description | `description` | When I try to... |
| Expected Behavior | `expected` | Media should play... |
| Reproduction Steps | `reproduction` | 1. Open... 2. Click... |
| Debug Logs | `logs` | [log content] |
| Diagnostics | `diagnostics` | [JSON content] |

**Document what's missing:**
- No debug logs? → May need to request
- Vague steps? → May need clarification
- Old version? → May be fixed already

## Step 2: Setup Local Environment

### Home Assistant Devcontainer

```bash
# HA is available at localhost:8123 in devcontainer
# Check if running
curl -s http://localhost:8123/api/ | head -1
```

**Environment Variables (from .env):**
```bash
# Required for HA API access
HOMEASSISTANT_URL=http://localhost:8123
HOMEASSISTANT_TOKEN=<from HA profile>

# Required for Emby testing
EMBY_URL=https://your-emby-server.example.com
EMBY_API_KEY=<from Emby dashboard>
```

### Configure to Match Reporter

1. **Check integration version matches:**
   ```bash
   # Current version in manifest
   cat custom_components/embymedia/manifest.json | grep version
   ```

2. **Configure similar options if relevant:**
   - WebSocket enabled/disabled
   - Scan interval
   - Ignored devices

3. **Connect similar client types:**
   - If reporter uses Android TV, test with Android TV
   - If reporter uses Web client, test with Web client

### Enable Debug Logging

Add to HA configuration or via UI:

```yaml
logger:
  default: warning
  logs:
    custom_components.embymedia: debug
    custom_components.embymedia.api: debug
    custom_components.embymedia.websocket: debug
    custom_components.embymedia.coordinator: debug
```

## Step 3: Reproduce the Bug

### Follow Exact Steps

Read reproduction steps from issue and follow **exactly**:

```
Reporter's steps:
1. Play a movie on Android TV client
2. Pause playback from HA
3. Wait 30 seconds
4. Try to resume from HA

My reproduction:
1. ✅ Playing movie on Android TV client
2. ✅ Called media_player.media_pause service
3. ✅ Waited 30 seconds
4. ❌ Resume works fine / ✅ Resume fails as reported
```

### Document Results

| Outcome | Next Step |
|---------|-----------|
| **Reproduced** | Proceed to evidence gathering |
| **Partially reproduced** | Note differences, may be timing/env dependent |
| **Cannot reproduce** | Document environment differences, may need more info |

### Environment Differences to Note

- Different Emby server version?
- Different client type/version?
- Different network configuration?
- Different HA installation type?
- Different integration options?

## Step 4: Gather Evidence

### Debug Logs

```bash
# From HA: Settings → System → Logs
# Or download via API:
curl -H "Authorization: Bearer $HOMEASSISTANT_TOKEN" \
  "$HOMEASSISTANT_URL/api/error_log"
```

**What to look for:**
- Exceptions and tracebacks
- Warning messages
- Unexpected state transitions
- API errors
- WebSocket disconnections

### API Traces

```bash
# Test specific Emby endpoint
curl -v "$EMBY_URL/emby/Sessions?api_key=$EMBY_API_KEY" 2>&1

# Check specific item
curl -v "$EMBY_URL/emby/Users/{user_id}/Items/{item_id}?api_key=$EMBY_API_KEY"
```

### Diagnostics Download

```
Settings → Devices & Services → Emby Media → ⋮ → Download diagnostics
```

**Diagnostics contain:**
- Server info (redacted)
- Active sessions
- Coordinator state
- Cache statistics
- WebSocket status
- Recent errors

### Screenshots

Capture:
- HA entity state
- Emby client state
- Browser DevTools (Network tab for API calls)
- Error dialogs

## Step 5: Root Cause Analysis

### Trace the Code Path

1. **Identify the entry point:**
   - Service call? → `services.py`
   - Entity property? → `media_player.py`
   - Coordinator update? → `coordinator.py`
   - WebSocket event? → `websocket.py`

2. **Follow the execution:**
   ```python
   # Example: Tracing media_pause
   # media_player.py:async_media_pause()
   #   → api.py:async_send_playback_command()
   #     → POST /Sessions/{id}/Playing/Pause
   ```

3. **Identify failure point:**
   - API returns error?
   - State not updated?
   - Exception thrown?
   - Wrong data format?

### Common Root Causes

| Symptom | Likely Cause | Check |
|---------|--------------|-------|
| State not updating | WebSocket disconnect | websocket.py connection status |
| Wrong media info | API parsing error | models.py, TypedDict handling |
| Service fails silently | Exception caught too broadly | Exception handlers |
| Intermittent failures | Race condition | Async timing, locks |
| Works on some clients | Client-specific behavior | Session capabilities |

### Check Related Code

```bash
# Find related code
grep -r "the_function_name" custom_components/embymedia/

# Check recent changes to file
git log --oneline -10 -- custom_components/embymedia/media_player.py

# Check if similar issues exist
gh issue list --search "similar keywords" --state all
```

## Step 6: Update Issue

### Add Investigation Comment

```bash
gh issue comment {N} --body "$(cat <<'EOF'
## Investigation Results

### Environment
- **HA Version:** 2025.11.x (devcontainer)
- **Integration Version:** 0.4.0
- **Emby Version:** 4.9.x
- **Client Tested:** Android TV, Web

### Reproduction
- **Status:** ✅ Confirmed
- **Steps followed:** As reported
- **Behavior observed:** [Exact behavior seen]

### Evidence

<details>
<summary>Debug Logs</summary>

```
[relevant log excerpts]
```

</details>

### Root Cause Analysis

**Failure Point:** `media_player.py:245` in `async_media_pause()`

**Cause:** The session ID becomes stale when the WebSocket reconnects, but the entity still holds the old session ID.

**Code Path:**
1. WebSocket disconnects (server restart, network blip)
2. WebSocket reconnects, new session established
3. Entity still references old session ID
4. API call fails with 404 (session not found)

### Recommended Fix

**Approach:** Update entity session ID when coordinator receives new session data.

**Files to Change:**
- `custom_components/embymedia/media_player.py` - Add session ID refresh in `_handle_coordinator_update`
- `custom_components/embymedia/coordinator.py` - Emit session change event

**Complexity:** Medium

**Breaking Changes:** None

### Test Cases Needed
- [ ] Test session ID refresh on reconnect
- [ ] Test playback control after reconnect
- [ ] Test with forced WebSocket disconnect
EOF
)"
```

### Update Labels

```bash
# Add confirmed label
gh issue edit {N} --add-label "confirmed"

# Remove investigation-related labels
gh issue edit {N} --remove-label "needs-reproduction"

# Add component label if not present
gh issue edit {N} --add-label "component: websocket"
```

### If Cannot Reproduce

```bash
gh issue comment {N} --body "$(cat <<'EOF'
## Investigation Results

### Environment
- **HA Version:** 2025.11.x (devcontainer)
- **Integration Version:** 0.4.0
- **Emby Version:** 4.9.x

### Reproduction Attempt
- **Status:** ❌ Could not reproduce
- **Steps followed:** As reported
- **Behavior observed:** [What I saw instead]

### Environment Differences
- Reporter using HA OS, I'm using devcontainer
- Reporter using Emby 4.8.x, I have 4.9.x
- Different client version

### Next Steps
Could you please provide:
1. Full debug logs from when the issue occurs
2. Diagnostics download from the integration
3. Confirmation of exact client version

I'll investigate further once I have more details.
EOF
)"

# Add needs-info label
gh issue edit {N} --add-label "needs-info"
```

## Step 7: Decide Next Step

| Situation | Action |
|-----------|--------|
| Bug confirmed, fix is clear | → Use `ha-emby-issue-executor` to implement fix |
| Bug confirmed, complex fix | → Add detailed plan to issue, may need breakdown |
| Cannot reproduce | → Request more info, add `needs-info` label |
| Upstream issue | → Add `upstream` label, explain to reporter |
| Won't fix | → Add `status: wontfix` label, explain reasoning |

### Route to Implementation

If proceeding to fix:

```bash
# Update status
gh issue edit {N} --remove-label "status: investigating"
gh issue edit {N} --add-label "status: in-progress"

# Announce transition
gh issue comment {N} --body "Investigation complete. Proceeding to implementation."
```

Then use `ha-emby-issue-executor` skill.

## Evidence Checklist

Before updating the issue, ensure you have:

- [ ] Reproduction status (confirmed / not reproduced)
- [ ] Environment details documented
- [ ] Debug logs captured (if reproduced)
- [ ] Root cause identified (if reproduced)
- [ ] Files to change identified
- [ ] Complexity estimate
- [ ] Test cases outlined

## Related Skills

| When | Skill | Purpose |
|------|-------|---------|
| Ready to fix | `ha-emby-issue-executor` | TDD implementation |
| GitHub updates | `ha-emby-github` | Labels, comments, issue operations |
| Understanding code | `ha-emby-integration` | HA patterns reference |
| Media player bugs | `ha-emby-media-player` | MediaPlayerEntity specifics |

**Cross-references:**
- For label meanings → See `ha-emby-github` § "Label Reference"
- For HA async patterns → See `ha-emby-integration` § "Async Patterns"
- For media player states → See `ha-emby-media-player` § "State Mapping"

## The Bottom Line

1. **Parse issue thoroughly** - Don't miss details
2. **Match reporter's environment** - As close as possible
3. **Follow exact steps** - Don't assume
4. **Document everything** - Logs, screenshots, traces
5. **Find root cause** - Don't just describe symptoms
6. **Update issue completely** - Findings, recommendation, next steps
7. **Route appropriately** - Fix now or gather more info
