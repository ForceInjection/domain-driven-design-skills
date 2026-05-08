---
name: zellij
description: Use when editing ANY zellij configuration including layouts, swap layouts, keybindings, or zjstatus plugin. Provides rules for powerline characters, VHS testing, and verification.
---

# Zellij Skill

## Configuration Locations

- Layout files: `home/.config/zellij/layouts/`
- Plugin file: `home/.config/zellij/plugins/zjstatus.wasm`
- Always edit files in the dotfiles repo, not symlinked files in `~/.config/`

## Powerline Characters

Claude Code strips unicode characters. Use placeholders in the layout file (`layout.kdl` in this skill folder):

- `{{PL_RIGHT}}` - right-pointing arrow (U+E0B0)
- `{{PL_LEFT}}` - left-pointing arrow (U+E0B2)

After editing the layout, run the converter:

```bash
.claude/skills/zellij/convert-layout
```

This reads `layout.kdl` from the skill folder, replaces placeholders with actual powerline chars, and writes to `~/.config/zellij/layouts/layout.kdl`.

## VHS Testing

**CRITICAL: NEVER run zellij commands in the user's active session. VHS creates its own isolated terminal.**

**CRITICAL: ALWAYS use the tapes in this skill folder. NEVER create ad-hoc tape files with different output names.**

Use VHS to verify visual changes:

1. Delete any existing test session: `zellij delete-session zellij-test`
2. Run the appropriate tape from `.claude/skills/zellij/`:
   - `layout.tape` - Tests tabs and zjstatus bar appearance
   - `swap-layout.tape` - Tests swap layouts with multiple panes (creates 3 panes, cycles through layouts)
3. Output screenshot ALWAYS goes to `tmp/zellij.png` (same name, no versioning)
4. Read the screenshot to verify before telling user the fix is complete
5. Clean up the test session: `zellij delete-session zellij-test`

The tapes create a dedicated `zellij-test` session. Never use `zellij action` commands directly - they affect the user's current session.

## Color Scheme

Use Catppuccin Mocha colors. Reference by name in requirements:
- base, surface1, lavender, text (not hex codes)

## Top Bar Layout

- Session name, tabs with powerline arrows, hostname/username
- Arrows between tabs use base color as foreground
- Active tab: accent background, base text color
- Inactive tabs: surface background, text color

## Bottom Bar Layout

- Mode indicator, active tab name only, datetime
- Show only active tab name (no inactive tabs)

## Verification Checklist

Before declaring complete, verify:
- Top bar arrows use dark/base color between all tabs
- No accent color triangles between inactive tabs
- Bottom bar shows only active tab name
- Bottom bar has no powerline triangles
- Session name arrow transitions correctly to first tab
