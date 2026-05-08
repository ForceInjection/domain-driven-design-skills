---
name: claude-mobile-ios-testing
description: Use when testing iOS apps on simulator, capturing screenshots for validation gates, automating UI testing with expo-mcp and xc-mcp, or verifying visual correctness - combines expo-mcp autonomous testing (React Native level) with xc-mcp simulator management (iOS level)
---

# iOS Testing Automation - expo-mcp + xc-mcp Hybrid

## Overview

Autonomous iOS testing combining expo-mcp (React Native component testing) with xc-mcp (simulator management).

**Core principle:** expo-mcp for UI testing (testID-based). xc-mcp for simulator lifecycle. AI validates visually.

**Announce at start:** "I'm using the claude-mobile-ios-testing skill for autonomous iOS testing."

## When to Use

- Testing iOS app with visual verification (Gates 4A, 6A-E)
- Capturing screenshots with AI analysis
- Automating UI interactions by testID
- Multi-device testing (iPhone SE, 14, Pro Max)
- Verifying React Native components work correctly

## Tool Selection Matrix

| Operation | Tool | Why |
|-----------|------|-----|
| Install packages | expo-mcp | Correct Expo SDK versioning + usage docs |
| Search docs | expo-mcp | Natural language Expo documentation search |
| Screenshot | expo-mcp | automation_take_screenshot (React Native level) |
| Find element | expo-mcp | automation_find_view_by_testid (by testID prop) |
| Tap element | expo-mcp | automation_tap_by_testid (by testID, React Native level) |
| Boot simulator | xc-mcp | simctl-boot (iOS simulator management) |
| Install .app | xc-mcp | simctl-install (after xcodebuild) |
| Launch app | xc-mcp | simctl-launch (iOS app lifecycle) |
| Low-level tap | xc-mcp | idb-ui-tap (when testID not available, use coordinates) |
| Accessibility tree | xc-mcp | idb-ui-describe (iOS accessibility API) |

## Hybrid Workflow

### 1. Simulator Setup (xc-mcp)

```typescript
// Boot iPhone simulator
mcp__xc-mcp__simctl-boot({
  deviceId: "iPhone 14",
  waitForBoot: true,
  openGui: true
});
```

### 2. Install and Launch (xc-mcp)

```typescript
// Install .app bundle (after xcodebuild or expo run:ios)
mcp__xc-mcp__simctl-install({
  udid: "booted",
  appPath: "/Users/nick/Desktop/claude-mobile-expo/claude-code-mobile/ios/build/Build/Products/Debug-iphonesimulator/claudecodemobile.app"
});

// Launch app
mcp__xc-mcp__simctl-launch({
  udid: "booted",
  bundleId: "com.yourcompany.claudecodemobile"
});
```

### 3. Autonomous Testing (expo-mcp)

**Requires**: Metro running with `EXPO_UNSTABLE_MCP_SERVER=1`

**Visual Verification**:
```
"Take screenshot of Chat screen empty state"
```

AI analyzes screenshot:
- ✅ Purple gradient background (#0f0c29→#302b63→#24243e)?
- ✅ Input field visible?
- ✅ Send button visible?
- ✅ Colors match spec?

**Element Verification**:
```
"Find view with testID 'message-input' and verify it's accessible"
```

expo-mcp returns: `{found: true, accessible: true, enabled: true}`

**Interaction Testing**:
```
"Tap button with testID 'send-button'"
```

expo-mcp: Taps element successfully

**Outcome Verification**:
```
"Take screenshot and verify message appeared in chat"
```

AI analyzes: Message bubble visible ✅, correct styling ✅

### 4. Complete Test Cycle

```typescript
// Test workflow for Chat screen
const tests = [
  "Take screenshot of Chat screen empty state, verify gradient background",
  "Find view with testID 'message-input'",
  "Tap view with testID 'message-input'",
  "Take screenshot and verify keyboard appeared",
  "Find view with testID 'settings-button'",
  "Tap button with testID 'settings-button'",
  "Take screenshot and verify Settings screen loaded",
];

for (const test of tests) {
  // AI executes test via expo-mcp prompt
  // AI analyzes result
  // AI determines pass/fail
}
```

## testID Requirements

**ALL interactive elements MUST have testID**:

```typescript
// ✅ CORRECT
<TouchableOpacity testID="send-button" onPress={handleSend}>
<TextInput testID="message-input" />
<Pressable testID="settings-button" onPress={openSettings}>
<FlatList testID="message-list" />
```

**Why**: expo-mcp automation_tap_by_testid and automation_find_view_by_testid require testID props

## Multi-Device Testing

```typescript
const devices = ["iPhone SE (3rd generation)", "iPhone 14", "iPhone 14 Pro Max"];

for (const device of devices) {
  // 1. Boot (xc-mcp)
  mcp__xc-mcp__simctl-boot({deviceId: device});
  
  // 2. Install and launch (xc-mcp)
  // ... (same as above)
  
  // 3. Test with expo-mcp
  "Take screenshot of Chat screen on ${device} and verify layout correct"
  
  // 4. AI verifies responsive layout
  
  // 5. Shutdown
  mcp__xc-mcp__simctl-shutdown({deviceId: "booted"});
}
```

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| "Use npm install" | WRONG. Use expo-mcp "Add package-name". |
| "Use xc-mcp screenshot" | WRONG for RN testing. Use expo-mcp automation_take_screenshot. |
| "Tap by coordinates always" | WRONG. Use expo-mcp automation_tap_by_testid with testID. |
| "Skip testID props" | WRONG. Required for expo-mcp automation. |
| "Manual visual verification" | WRONG. AI verifies screenshots autonomously. |

## Red Flags

- "npm install is faster" → WRONG. expo-mcp provides correct versioning.
- "xc-mcp screenshot is fine" → WRONG. expo-mcp works at React Native level.
- "testIDs are optional" → WRONG. Required for autonomous testing.
- "I'll verify manually" → WRONG. AI verifies via screenshot analysis.

**All mean: Use expo-mcp for RN testing. Add testIDs. Let AI verify.**

## Integration

- **Use WITH**: `@claude-mobile-metro-manager` (start Metro with MCP flag)
- **Use WITH**: `@claude-mobile-validation-gate` (complete gate execution)
- **Provides to**: Gate 4A, Gates 6A-E (visual validation)
