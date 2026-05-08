---
name: update-neovim-plugins
description: Update LazyVim and all neovim plugins to their latest versions
---

# Update Neovim Plugins

This skill updates all neovim plugins managed by lazy.nvim to their latest versions.

## Task

You should:

1. Check if neovim is installed and accessible
2. Open neovim and run the lazy.nvim sync command to update all plugins
3. Check for any errors or warnings during the update
4. Report which plugins were updated
5. Suggest any breaking changes or configuration updates needed

## Commands

To update plugins in neovim:
```bash
nvim --headless "+Lazy! sync" +qa
```

To check the lazy.nvim log:
```bash
cat ~/.local/state/nvim/lazy.nvim.log
```

## What to Check

- LazyVim itself
- All plugins in `~/.dotfiles/nvim/lua/plugins/`
- Any deprecated plugins or APIs
- Breaking changes in major version updates
- Compatibility with current neovim version

## Output

Provide a summary of:
- Number of plugins updated
- Any new features available
- Any configuration changes recommended
- Any errors encountered
