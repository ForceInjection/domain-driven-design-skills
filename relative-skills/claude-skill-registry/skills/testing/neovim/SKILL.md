---
name: neovim
description: Use when editing ANY Neovim configuration including init.lua, plugins, keymaps, LSP settings, or theme configuration. Provides file structure guidance and VHS testing workflow.
---

# Neovim Skill

## Configuration Locations

- Main config: `home/.config/nvim/init.lua`
- Plugins: `home/.config/nvim/lua/plugins.lua`
- Config modules: `home/.config/nvim/lua/config/`
  - `keymaps.lua` - Key mappings
  - `lsp.lua` - LSP configuration
  - `completion.lua` - Completion settings
  - `which-key.lua` - Which-key mappings
  - `treesitter.lua` - Treesitter config
  - `telescope.lua` - Telescope config
  - `lualine.lua` - Statusline config
  - `oil.lua` - Oil file manager config
- Always edit files in `~/dev/dotfiles/`, not symlinked files in `~/.config/`

## File Structure

```
home/.config/nvim/
├── init.lua           # Base config, options, rustaceanvim settings
├── lua/
│   ├── plugins.lua    # Lazy.nvim plugin definitions with opts
│   └── config/
│       ├── init.lua   # Loads all config modules
│       ├── keymaps.lua
│       ├── lsp.lua
│       └── ...
├── after/             # Filetype-specific settings
├── selene.toml        # Lua linter config
└── stylua.toml        # Lua formatter config
```

## Plugin Configuration Pattern

Plugins use lazy.nvim with inline `opts` or `config` functions:

```lua
{
  "plugin/name",
  opts = {
    setting = value,
  },
}
```

For plugins requiring setup logic:

```lua
{
  "plugin/name",
  config = function(_, opts)
    require("plugin").setup(opts)
  end,
}
```

## VHS Testing

**CRITICAL: NEVER run nvim commands that affect the user's active session. VHS creates its own isolated terminal.**

**CRITICAL: ALWAYS use the tape in this skill folder. NEVER create ad-hoc tape files with different output names.**

Use VHS to verify visual changes:

1. Run the tape: `vhs .claude/skills/neovim/neovim.tape`
2. Output screenshot goes to `tmp/neovim.png`
3. Read the screenshot to verify before telling user the fix is complete

The tape opens neovim in a clean environment, waits for it to load, and captures a screenshot.

## Color Scheme

Uses Catppuccin Mocha theme. Set in init.lua:
```lua
vim.cmd.colorscheme("catppuccin-mocha")
```

## Key Mappings

Leader key is Space. Mappings defined in:
- `lua/config/keymaps.lua` - General keymaps
- `lua/config/which-key.lua` - Which-key groups and mappings
- `lua/plugins.lua` - Plugin-specific mappings in plugin specs

## LSP Setup

LSP configured via:
- Mason for LSP server installation
- mason-lspconfig for automatic setup
- Individual server configs in `lua/config/lsp.lua`
- Rustaceanvim configured separately in `init.lua` (must load before plugins)

## Verification Checklist

Before declaring a config change complete:
1. Confirm you edited files in `~/dev/dotfiles/home/.config/nvim/`
2. Run VHS tape to capture screenshot
3. Verify neovim starts without errors
4. Test the specific feature you changed
5. Check no Lua errors in `:messages`

## Common Issues

- **Plugin errors**: Check lazy.nvim lockfile at `~/.local/share/nvim/lazy-lock.json`
- **LSP not starting**: Check `:LspInfo` and `:Mason`
- **Treesitter errors**: Run `:TSUpdate`
- **Config reload**: Use `<leader>R` or `:source %` on init.lua
