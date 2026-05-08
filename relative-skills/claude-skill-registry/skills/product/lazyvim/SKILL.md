---
name: lazyvim
description: Help with LazyVim configuration, plugins, keybindings, and Neovim setup. Use when the user asks about LazyVim, Neovim configuration, plugins, or text editor customization.
---

# LazyVim Skill

## Configuration Location

The LazyVim configuration is located at:

- **Config directory**: `/Users/trent/.config/nvim/`
- **Main entry point**: `/Users/trent/.config/nvim/init.lua`
- **Lazy.nvim setup**: `/Users/trent/.config/nvim/lua/config/lazy.lua`
- **Custom keymaps**: `/Users/trent/.config/nvim/lua/config/keymaps.lua`
- **Options/settings**: `/Users/trent/.config/nvim/lua/config/options.lua`
- **Plugin configs**: `/Users/trent/.config/nvim/lua/plugins/*.lua`
- **LazyVim extras**: `/Users/trent/.config/nvim/lazyvim.json`

## Official Documentation

Always reference the official LazyVim and Neovim documentation when helping:

- **LazyVim Docs**: https://www.lazyvim.org/
- **LazyVim Configuration Guide**: https://www.lazyvim.org/configuration
- **LazyVim Plugins**: https://www.lazyvim.org/plugins
- **LazyVim Extras**: https://www.lazyvim.org/extras
- **LazyVim Keymaps**: https://www.lazyvim.org/keymaps
- **Neovim Docs**: https://neovim.io/doc/
- **Lazy.nvim Plugin Manager**: https://github.com/folke/lazy.nvim

## Current User Setup

### Installed LazyVim Extras
The user has the following LazyVim extras installed (from lazyvim.json):
- `lazyvim.plugins.extras.coding.yanky` (yank history)
- `lazyvim.plugins.extras.editor.mini-files` (file explorer)
- `lazyvim.plugins.extras.lang.json`
- `lazyvim.plugins.extras.lang.markdown`
- `lazyvim.plugins.extras.lang.toml`

### Custom Plugins
The user has custom plugin configurations in `/Users/trent/.config/nvim/lua/plugins/`:
- `lunarvim-extras.lua` - LunarVim-inspired extras
- `vim-tmux-navigator.lua` - Seamless tmux/vim navigation
- `tokyonight.lua` - Tokyo Night colorscheme
- `python-indent.lua` - Python indentation
- `snacks.lua` - Snacks plugin configuration
- `mason.lua` - LSP/DAP/linter installer
- `firenvim.lua` - Neovim in browser

### Key User Preferences
- **Colorscheme**: Tokyo Night (forced via `vim.g.lazyvim_colorscheme = "tokyonight"`)
- **Auto-reload**: Enabled for files changed externally
- **Animations**: Disabled (`vim.g.snacks_animate = false`)

### Custom Keymaps
Notable custom keybindings:
- `<leader>o` / `<leader>i` - Jump back/forward in jumplist
- `<leader>1-9` - Quick buffer navigation by number
- `<C-w>hjkl` - Window resizing (small increments)
- `<C-w>HJKL` - Window resizing (large increments)

## LazyVim Architecture

### File Loading Order
1. `init.lua` - Entry point, requires `config.lazy`
2. `lua/config/lazy.lua` - Sets up lazy.nvim and imports plugins
3. `lua/config/options.lua` - Loaded before lazy.nvim startup
4. `lua/config/keymaps.lua` - Loaded on VeryLazy event
5. `lua/config/autocmds.lua` - Loaded on VeryLazy event
6. `lua/plugins/*.lua` - All Lua files automatically loaded by lazy.nvim

### Plugin Configuration Patterns

**Method 1: Create a new file in `lua/plugins/`**
```lua
-- lua/plugins/example.lua
return {
  "author/plugin-name",
  opts = {
    -- plugin options here
  },
  keys = {
    -- global keymaps here
  },
}
```

**Method 2: Override/extend existing LazyVim plugins**
```lua
return {
  "LazyVim/LazyVim",
  opts = {
    -- override LazyVim defaults
  },
}
```

### Keymap Configuration Locations

1. **`lua/config/keymaps.lua`**: For core Neovim/LazyVim keybindings not specific to plugins
2. **Plugin `keys` field**: For global Normal mode keybindings that trigger plugin functionality
3. **Plugin `opts` field**: For plugin-specific keymaps that only apply when the plugin is active

## When Helping Users

1. Always read the relevant config files first before making changes
2. Reference official LazyVim and Neovim documentation for syntax and best practices
3. Respect the user's existing configuration style and preferences
4. Explain changes clearly with examples
5. Use the lazy.nvim plugin specification format
6. Test that Lua syntax is valid
7. Consider whether changes should go in:
   - A new plugin file (`lua/plugins/name.lua`)
   - An existing plugin file
   - `keymaps.lua` for general keybindings
   - `options.lua` for Neovim settings

## Common Tasks

- Adding/modifying plugins
- Configuring keybindings
- Setting up LSP servers via Mason
- Customizing colorschemes
- Adding LazyVim extras
- Configuring file navigation
- Setting up language-specific features
- Managing plugin lazy-loading
- Debugging plugin issues

## Useful Commands

- `:Lazy` - Open lazy.nvim plugin manager
- `:LazyExtras` - Browse and install LazyVim extras
- `:Mason` - Open Mason installer for LSP/DAP/linters
- `:checkhealth` - Run Neovim health checks
- `:help lazy.nvim` - View lazy.nvim documentation
- `:help lazyvim` - View LazyVim documentation

## Listing All Keybindings

### For Claude: Extracting Keybindings Programmatically

**IMPORTANT FOR CLAUDE**: When the user asks you to list keybindings or you need to discover what keybindings are available, use this command:

```bash
nvim --headless +"lua local keymaps = vim.api.nvim_get_keymap('n'); for _, map in ipairs(keymaps) do if map.lhs:match('^%s') and map.desc then print(string.format('%s|%s', map.lhs:gsub('%s', '<leader>'), map.desc)) end end" +quit 2>&1 | sort
```

**What this does:**
- Runs Neovim headlessly (no UI)
- Extracts all normal mode keymaps (`vim.api.nvim_get_keymap('n')`)
- Filters for leader keybindings (those starting with space)
- Prints in format: `<leader>key|Description`
- Sorts the output alphabetically

**Output format example:**
```
<leader>ff|Find Files (Root Dir)
<leader>fg|Find Files (git-files)
<leader>gB|Browse git link
<leader>sk|Keymaps
```

**To extract ALL modes (not just normal):**
```bash
nvim --headless +"lua for _, mode in ipairs({'n', 'v', 'i', 'x', 't'}) do local maps = vim.api.nvim_get_keymap(mode); for _, map in ipairs(maps) do if map.desc then print(string.format('[%s] %s|%s', mode, map.lhs, map.desc)) end end end" +quit 2>&1 | sort
```

**To get raw keymap data (includes callbacks, functions, etc.):**
```bash
nvim --headless -c "lua vim.print(vim.inspect(vim.api.nvim_get_keymap('n')))" -c "quit"
```

### Official Documentation References
- **Online**: https://www.lazyvim.org/keymaps
- **Source**: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
