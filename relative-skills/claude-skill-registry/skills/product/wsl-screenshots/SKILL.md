---
name: wsl-screenshots
description: View Windows screenshots from WSL. Use when user mentions screenshot, screen capture, or asks to look at an image they just took.
---

# WSL Screenshots

When the user references a screenshot or asks you to look at an image:

1. Find the most recent screenshot:
   ```bash
   ls -t ~/screenshots/ | head -1
   ```

2. View the file using the Read tool with the full path:
   ```
   ~/screenshots/<filename>
   ```

The `~/screenshots` directory is symlinked to the Windows Screenshots folder.

## Notes
- Screenshots are typically PNG files
- Filenames include timestamps (e.g., `Screenshot 2024-01-15 143052.png`)
- The symlink is created by the dotfiles bootstrap script
- If ~/screenshots doesn't exist, the symlink wasn't created (non-WSL or missing Windows folder)
