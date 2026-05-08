---
name: using-zellij-docs
description: Use when answering questions about Zellij keyboard shortcuts, configuration options, or feature behavior - ensures version-specific accuracy by checking actual config and docs before providing shortcuts or advice that might not work with custom configurations
---

# Using Zellij Documentation

## Overview

**Never provide Zellij shortcuts or config advice from memory.** Always check the user's actual version, config, and documentation first.

**Core principle:** Zellij has version differences and custom configs often use `clear-defaults=true` which removes ALL default keybindings. Training data shortcuts are frequently wrong.

## When to Use

Use this skill when user asks about:
- Keyboard shortcuts ("how do I split panes?")
- Configuration options ("how do I enable session persistence?")
- Feature behavior ("how do I scroll up?")
- Troubleshooting ("this shortcut doesn't work")

## The Problem

**Common failure pattern:**
1. User asks: "How do I split panes in Zellij?"
2. Agent answers from training data: "Press Ctrl+p then %"
3. User tries it: "Doesn't work"
4. Reality: User has `clear-defaults=true` and custom bindings

**Why this happens:**
- Questions feel simple/routine
- Training data has "common" shortcuts
- Checking seems like overkill
- Speed feels more important than accuracy

## Required Process

**Before answering ANY Zellij question, complete this checklist:**

- [ ] Check Zellij version: `zellij --version`
- [ ] Check if user's config exists: look for `~/.config/zellij/config.kdl`
- [ ] If config exists: read it and check for `clear-defaults=true` (line 1)
- [ ] If `clear-defaults=true`: ALL shortcuts must come from their actual config
- [ ] Search config for the specific command/binding user asked about
- [ ] Provide answer based on THEIR config, not default shortcuts

**NO EXCEPTIONS:**
- NOT for "urgent/production" situations
- NOT when "user needs answer in 10 seconds"
- NOT when "checking might take too long"
- NOT when "default probably works"

**Wrong answer under time pressure = more time wasted fixing it.**

**If no access to user's config:**
1. State clearly you cannot access their config
2. Explain assumptions explicitly: "If you're using default Zellij keybindings..."
3. Provide the command to check their own config: `grep -A 5 "pattern" ~/.config/zellij/config.kdl`
4. Ask for confirmation or offer to help them check their config
5. Never provide default shortcuts as if they're universal

## Quick Reference

### Checking Config for Shortcuts

```bash
# Check version first
zellij --version

# Read config to check for custom keybindings
cat ~/.config/zellij/config.kdl | head -n 20

# Search for specific bindings
grep -A 2 "pane {" ~/.config/zellij/config.kdl
grep "NewPane" ~/.config/zellij/config.kdl
grep "Resize" ~/.config/zellij/config.kdl
```

### Config Analysis

**If line 1 shows:** `keybinds clear-defaults=true`
→ User has ZERO default shortcuts. Every binding must be read from their config.

**If line 1 shows:** `keybinds {` (no clear-defaults)
→ User has defaults + custom additions. Check config for overrides first.

## Common Scenarios

### Scenario: User Asks About Keyboard Shortcut

❌ **Wrong approach:**
```
User: "How do I split panes?"
Agent: "Press Ctrl+p then % for horizontal split"
```

✅ **Correct approach:**
```
User: "How do I split panes?"
Agent: "Let me check your Zellij config..."
*Reads config, sees clear-defaults=true*
*Searches for NewPane bindings*
Agent: "In your config:
- Ctrl+p then d - split horizontally (new pane down)
- Ctrl+p then r - split vertically (new pane right)
- Alt+n - quick new pane from any mode"
```

### Scenario: User Says "This Shortcut Doesn't Work"

❌ **Wrong approach:**
```
Agent: "Try Ctrl+p then = to equalize panes"
User: "Doesn't work"
Agent: "Hmm, try entering pane mode first with Ctrl+p"
```

✅ **Correct approach:**
```
Agent: "Let me check what's actually bound in your config..."
*Reads config*
Agent: "I don't see an 'equalize panes' binding in your config. Your current resize bindings are:
- Alt+- : Resize decrease
- Alt+= : Resize increase
- Alt+[ : Previous layout
- Alt+] : Next layout

Would you like help adding an equalize command?"
```

### Scenario: Version-Specific Features

❌ **Wrong approach:**
```
User: "How do I enable session persistence?"
Agent: "Set session_persistence: true in your config"
```

✅ **Correct approach:**
```
User: "How do I enable session persistence?"
Agent: "Let me check your version and current config..."
*Checks zellij --version → 0.43.1*
*Reads config file*
Agent: "In Zellij 0.43.1, the correct option is session_serialization (not session_persistence). Looking at your config, you already have:
- session_serialization true (line 415)
- serialize_pane_viewport true (line 423)

Session persistence is already enabled. Are you experiencing a specific issue?"
```

## Documentation Sources

### For Specific Versions

Zellij docs are version-specific and change significantly between versions:

- **0.43.x**: Configuration options, keybinding syntax
- **0.39.x**: Different default shortcuts, older config format
- **0.3x.x**: Major differences in features and config

**Always check user's version first**, then reference docs for that version.

### Finding Documentation

```bash
# Check version
zellij --version

# Search for version-specific docs
# Format: https://zellij.dev/documentation/
# Check GitHub releases for version-specific changes
```

## Rationalizations to Reject

| Excuse | Reality |
|--------|---------|
| "Most users have defaults" | Many power users customize extensively |
| "This is the common way" | Common ≠ universal, verify first |
| "Checking would take too long" | Wrong answer wastes more time |
| "It's probably the same across versions" | Versions differ significantly |
| "I'll provide the standard answer" | No standard when clear-defaults=true |
| "It's urgent, default should work immediately" | Wrong urgent answer = more time wasted |
| "Production is down, no time to check" | Giving wrong shortcut makes outage longer |
| "I'll mention both default and custom" | Confusing. Only tell them what actually works |

## Red Flags - STOP and Check Config

- About to mention Ctrl+p + % (tmux-style default)
- About to say "the standard way is..."
- About to provide shortcuts without reading config
- User says shortcut "doesn't work"
- Question about features (might be version-specific)
- Feeling time pressure to answer quickly
- Thinking "default should work for now"
- About to say "if you have custom bindings, let me know"

**All of these mean: Read config and version first.**

## Real-World Impact

**Before skill:**
- User: "How do I equalize panes?"
- Agent: "Press Ctrl+p then ="
- Result: Doesn't work, user frustrated

**With skill:**
- User: "How do I equalize panes?"
- Agent: *checks config* "Your config doesn't have that binding. Here are your resize options..."
- Result: Accurate, helpful answer
