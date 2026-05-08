---
name: Configuring Neovim
description: This skill guides working with Neovim configuration including testing changes headlessly, managing plugins with lazy.nvim, configuring LSP servers, and troubleshooting startup errors. Use this when modifying nvim config files or debugging nvim issues.
allowed-tools: [Bash, Read, Write, Edit]
---

# Configuring Neovim

This skill provides patterns for modifying and testing Neovim configuration safely and efficiently.

## What This Skill Does

- Tests nvim configuration changes without manual launch
- Verifies plugins load correctly via headless testing
- Configures LSP servers with mason.nvim
- Debugs startup errors and plugin loading issues
- Tests LSP attachment and functionality
- Manages plugin configuration with lazy.nvim

## Key Technique: Headless Testing

The critical pattern for working with nvim configuration is **testing headlessly** before manually launching nvim. This catches errors immediately without disrupting your workflow.

### Basic Headless Test

```bash
# Test if nvim loads without errors
nvim --headless -c "echo 'Config loaded successfully'" -c "quit" 2>&1
```

**What this does:**
- `--headless`: Run without UI
- `-c "command"`: Execute vim command
- `-c "quit"`: Exit after commands
- `2>&1`: Capture stderr to see errors

**Success output:**
```
Config loaded successfully
```

**Error output shows:**
- File and line number where error occurred
- Stack trace
- Specific error message

### Testing Specific Features

```bash
# Test plugin loading
nvim --headless -c "lua print('Plugins loaded')" -c "sleep 2" -c "quit" 2>&1

# Test LSP configuration
nvim --headless -c "lua print('LSP config:', vim.inspect(vim.lsp))" -c "quit" 2>&1

# Test with a specific file type
cd /tmp && echo 'print("test")' > test.lua && \
  nvim --headless test.lua -c "lua print('Buffer filetype:', vim.bo.filetype)" -c "quit" 2>&1
```

### Testing LSP Server Attachment

```bash
# Test if LSP attaches to a buffer (requires servers installed)
cd /tmp && echo 'print("hello")' > test.lua && \
  nvim --headless test.lua \
    -c "lua vim.defer_fn(function() print('LSP clients:', vim.inspect(vim.lsp.get_clients())) end, 2000)" \
    -c "sleep 3" \
    -c "quit" 2>&1 | grep -A5 "LSP clients"
```

**Why defer_fn?** LSP servers need time to start and attach. The 2000ms delay allows initialization.

## Prerequisites

### Required Tools
- **nvim** - Neovim 0.9+
- **git** - For plugin installation

### Configuration Location
- Main config: `~/.config/nvim/init.lua`
- Plugins: `~/.config/nvim/lua/plugins/*.lua`
- User config: `~/.config/nvim/lua/user/*.lua`
- Plugin manager: `~/.config/nvim/lua/config/lazy.lua`

## Common Configuration Tasks

### Adding a New Plugin

1. **Create plugin file** in `~/.config/nvim/lua/plugins/`:

```lua
-- ~/.config/nvim/lua/plugins/my-plugin.lua
return {
  "username/plugin-name",
  lazy = false,  -- Load immediately (or set to true for lazy loading)
  config = function()
    require("plugin-name").setup({
      -- Plugin configuration here
    })
  end,
}
```

2. **Test the plugin loads** without errors:

```bash
nvim --headless -c "lua print('Testing plugin load')" -c "sleep 2" -c "quit" 2>&1
```

3. **Launch nvim normally** - lazy.nvim will auto-install the plugin

### Configuring LSP with Mason

The modern approach uses three plugins:
- `mason.nvim` - Installs language servers
- `mason-lspconfig.nvim` - Bridges mason and lspconfig
- `nvim-lspconfig` - Configures LSP clients

**Recommended structure** (`~/.config/nvim/lua/plugins/lsp.lua`):

```lua
return {
  -- Mason for installing language servers
  {
    "williamboman/mason.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("mason").setup()
    end,
  },

  -- LSP configuration (load early as dependency)
  {
    "neovim/nvim-lspconfig",
    lazy = false,
  },

  -- Mason-lspconfig bridge
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Setup mason-lspconfig
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",      -- Lua
          "pyright",     -- Python
          "ts_ls",       -- TypeScript/JavaScript
          "rust_analyzer", -- Rust
          -- Add more servers as needed
        },
      })

      -- Define on_attach for keymaps
      local on_attach = function(_, bufnr)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end

        -- Navigation
        map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        map("n", "gr", vim.lsp.buf.references, "Go to references")
        map("n", "K", vim.lsp.buf.hover, "Hover documentation")
      end

      -- Get capabilities
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Configure each server
      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
      })
      -- Add more server configs as needed
    end,
  },
}
```

**Test LSP config loads:**

```bash
nvim --headless -c "lua print('Testing LSP')" -c "sleep 2" -c "quit" 2>&1
```

**Common errors:**
- `attempt to call field 'setup_handlers'` - Don't use `setup_handlers`, configure servers manually
- `module 'cmp_nvim_lsp' not found` - Add nvim-cmp as dependency
- Priority issues - Set explicit `priority` values (1000, 900, 800)

### Modifying Existing Configuration

1. **Read the current config:**

```bash
cat ~/.config/nvim/lua/plugins/target-plugin.lua
```

2. **Make your changes** using the Edit tool

3. **Test headlessly immediately:**

```bash
nvim --headless -c "lua print('Config updated')" -c "quit" 2>&1
```

4. **If errors appear**, fix them before launching nvim normally

5. **Launch nvim** to verify behavior

## Verification Workflows

### After Plugin Changes

```bash
# Check plugin loads
nvim --headless -c "lua print('Plugins OK')" -c "sleep 2" -c "quit" 2>&1

# Check for errors (should be empty)
nvim --headless -c "quit" 2>&1 | grep -i error
```

### After LSP Changes

```bash
# Verify LSP config loads
nvim --headless -c "lua print('LSP:', vim.inspect(vim.lsp))" -c "quit" 2>&1

# Test with actual file (after servers installed)
cd /tmp && echo 'def hello(): pass' > test.py && \
  nvim --headless test.py -c "sleep 3" -c "lua print('Clients:', #vim.lsp.get_clients())" -c "quit" 2>&1
```

### After Keymap Changes

```bash
# Check specific keymap exists
nvim --headless -c "lua print('Leader key:', vim.g.mapleader)" -c "quit" 2>&1
```

## Troubleshooting

### Error: Failed to run `config` for plugin

**Symptom:** Error during plugin config function execution

**Cause:** Lua error in plugin's `config = function()` block

**Solution:**
1. Look at the stack trace for file:line number
2. Read the specific line in the config file
3. Common issues:
   - Calling function that doesn't exist yet (dependency loading order)
   - Typo in module name
   - Missing `require()` statement

**Fix dependency loading:**
```lua
-- Add explicit dependencies and priority
{
  "my-plugin",
  dependencies = { "required-plugin" },
  priority = 900,  -- Lower number = loads later
}
```

### Error: Module not found

**Symptom:** `module 'xyz' not found`

**Cause:** Plugin not installed or wrong name

**Solution:**
```bash
# Check if plugin directory exists
ls ~/.local/share/nvim/lazy/

# Launch nvim normally to let lazy.nvim install
nvim

# Or force plugin sync
nvim --headless -c "lua require('lazy').sync()" -c "sleep 5" -c "quit"
```

### Error: Attempt to call field (a nil value)

**Symptom:** `attempt to call field 'setup' (a nil value)`

**Cause:**
- Function doesn't exist in that module
- Module not loaded yet
- Wrong module name

**Solution:**
1. Verify correct module name in plugin docs
2. Check if module needs to be required first
3. Ensure dependencies load before this plugin

### LSP Not Attaching

**Symptom:** LSP features don't work, no diagnostics

**Diagnosis:**
```bash
# Check if LSP clients exist
nvim some-file.lua -c "lua vim.defer_fn(function() print(vim.inspect(vim.lsp.get_clients())) end, 2000)" -c "sleep 3" -c "quit"
```

**Common causes:**
1. **Server not installed** - Run `:Mason` in nvim to install
2. **Server not configured** - Add to lspconfig setup
3. **File type not detected** - Check `:set filetype?` in nvim
4. **Server crashed** - Check `:LspInfo` for errors

**Solution:**
```bash
# Verify mason installed servers
ls ~/.local/share/nvim/mason/bin/

# Check server executable works
~/.local/share/nvim/mason/bin/lua-language-server --version
```

### Deprecation Warning: lspconfig framework deprecated

**Symptom:** Warning about `require('lspconfig')` being deprecated

**Cause:** Neovim 0.11+ has new LSP config API

**Impact:** Warning only - still works fine

**Future fix:** Migration guide will be available when nvim-lspconfig v3.0.0 releases

### Performance: Slow Startup

**Diagnosis:**
```bash
# Profile startup time
nvim --startuptime startup.log -c "quit"
cat startup.log | tail -20
```

**Common causes:**
- Too many plugins loading at startup
- Heavy plugins not lazy-loaded
- Expensive config functions

**Solution:**
```lua
-- Lazy load plugins
{
  "heavy-plugin",
  lazy = true,  -- Don't load at startup
  event = "VeryLazy",  -- Load after UI renders
  -- or
  cmd = "PluginCommand",  -- Load on command
  -- or
  ft = "python",  -- Load on filetype
}
```

## Best Practices

### Always Test Headlessly First

```bash
# GOOD: Test before manual launch
nvim --headless -c "echo 'OK'" -c "quit" 2>&1 && echo "Safe to launch nvim"

# BAD: Edit config, launch nvim, hit error, can't see anything
nvim  # Might crash immediately
```

### Use Explicit Loading Order

```lua
-- For plugins that depend on each other, set priorities
{
  "base-plugin",
  priority = 1000,  -- Loads first
}
{
  "dependent-plugin",
  priority = 900,   -- Loads second
  dependencies = { "base-plugin" },
}
```

### Keep Configs Modular

```
~/.config/nvim/
├── init.lua              # Entry point (minimal)
├── lua/
│   ├── config/
│   │   └── lazy.lua      # Plugin manager setup
│   ├── plugins/          # One file per plugin
│   │   ├── lsp.lua
│   │   ├── telescope.lua
│   │   └── treesitter.lua
│   └── user/             # User settings
│       ├── mappings.lua
│       └── settings.lua
```

**Benefits:**
- Easy to find/edit specific plugin config
- Can remove plugins by deleting one file
- Clear separation of concerns

### Document Your Configurations

```lua
-- Good: Explain why
{
  "williamboman/mason.nvim",
  priority = 1000,  -- Must load before mason-lspconfig
  lazy = false,     -- Required at startup for LSP
  config = function()
    require("mason").setup()
  end,
}

-- Bad: No context
{
  "williamboman/mason.nvim",
  config = function()
    require("mason").setup()
  end,
}
```

### Test in Clean Environment

When debugging mysterious issues:

```bash
# Start nvim with no config
nvim -u NONE

# Start with minimal config
echo "vim.opt.number = true" > /tmp/minimal.lua
nvim -u /tmp/minimal.lua
```

### Back Up Before Major Changes

```bash
# Before restructuring LSP config
cp ~/.config/nvim/lua/plugins/lsp.lua ~/.config/nvim/lua/plugins/lsp.lua.backup

# Or use git
cd ~/.config/nvim
git diff  # Review changes
git checkout -- file.lua  # Revert if needed
```

## Common Patterns

### Testing a Complete Config Change

```bash
# 1. Make your changes
# 2. Test headlessly
nvim --headless -c "quit" 2>&1

# 3. If errors, see the stack trace and fix
# 4. When clean, test with a file
cd /tmp && echo 'test' > test.txt && nvim --headless test.txt -c "quit" 2>&1

# 5. Launch normally
nvim
```

### Adding a Language Server

```bash
# 1. Add to ensure_installed in lsp.lua
# 2. Add server config in lsp.lua
# 3. Test config loads
nvim --headless -c "quit" 2>&1

# 4. Launch nvim - mason auto-installs
nvim

# 5. Wait for mason to finish installing
# 6. Open a file of that language
# 7. Verify LSP attached: :LspInfo
```

### Removing a Plugin

```bash
# 1. Delete plugin file
rm ~/.config/nvim/lua/plugins/unwanted-plugin.lua

# 2. Test config loads
nvim --headless -c "quit" 2>&1

# 3. Launch nvim
nvim

# 4. Clean up plugin directory
# In nvim: :Lazy clean
```

## Quick Reference Commands

```bash
# Test config loads
nvim --headless -c "quit" 2>&1

# Test with delay for async operations
nvim --headless -c "sleep 2" -c "quit" 2>&1

# Test LSP configuration
nvim --headless -c "lua print(vim.inspect(vim.lsp))" -c "quit" 2>&1

# Test with specific file type
nvim --headless test.lua -c "quit" 2>&1

# Check plugin installation
ls ~/.local/share/nvim/lazy/

# Check LSP servers installed
ls ~/.local/share/nvim/mason/bin/

# Profile startup time
nvim --startuptime startup.log -c "quit" && tail -20 startup.log

# Launch with no config (debugging)
nvim -u NONE

# Force plugin sync
nvim --headless -c "lua require('lazy').sync()" -c "sleep 10" -c "quit"
```

## Related Skills

- **Creating Claude Code Skills** - For documenting reusable nvim patterns as skills
- **Git Workflows** - For version controlling nvim config changes

## Advanced Topics

### Testing Specific Plugin Loading

```bash
# Test if specific plugin is loaded
nvim --headless -c "lua print('Telescope:', require('telescope') ~= nil)" -c "quit" 2>&1
```

### Debugging Plugin Load Order

```bash
# Add prints in config functions to trace loading
config = function()
  print("Loading plugin X...")
  require("plugin").setup()
  print("Plugin X loaded")
end
```

### Testing Keymaps Work

```bash
# Open file and try keymap programmatically
nvim --headless test.lua \
  -c "normal gd" \
  -c "echo 'Keymap executed'" \
  -c "quit" 2>&1
```

This pattern lets you verify keymaps trigger without manual testing.

## Summary

The most important practice: **always test nvim config changes headlessly before launching nvim manually**. This catches errors immediately and shows you exactly where the problem is.

The basic workflow:
1. Edit config
2. `nvim --headless -c "quit" 2>&1`
3. Fix any errors shown
4. Repeat until clean
5. Launch nvim normally

This saves enormous amounts of time and frustration compared to trial-and-error with manual launches.
