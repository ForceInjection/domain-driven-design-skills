---
name: zsh-completions-setup
description: This skill should be used when the user asks to "set up shell completions", "fix zsh completions", "configure tab completion", "add completions for brew/npm/cargo", "troubleshoot missing completions", or mentions fpath, compinit, or Oh My Zsh completion issues.
tags: [zsh, completions, oh-my-zsh, homebrew, shell, fpath, compinit]
---

# Zsh Completions Setup

Set up and troubleshoot zsh tab completions for command-line tools, with special focus on Homebrew integration and Oh My Zsh configurations.

## Quick Start: The Essential Fix

The most common completion issue occurs when the Homebrew completions path is added to `fpath` AFTER `compinit` runs. Oh My Zsh calls `compinit` automatically when sourcing `oh-my-zsh.sh`, so Homebrew completions must be added to `fpath` BEFORE that line.

Add this to `~/.zshrc` BEFORE `source $ZSH/oh-my-zsh.sh`:

```zsh
# Homebrew completions (MUST be before oh-my-zsh.sh)
if type brew &>/dev/null; then
  fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
fi

source $ZSH/oh-my-zsh.sh
```

After adding this, rebuild the completion cache:

```bash
rm -f ~/.zcompdump* && exec zsh
```

## How Zsh Completions Work

### The Three-Part System

Zsh completions rely on three components working together:

1. **`fpath`** - An array of directories where zsh searches for completion files
2. **`compinit`** - A function that scans `fpath` and registers all completions
3. **Completion files** - Files named `_commandname` containing completion logic

### The Loading Sequence

```
1. Zsh starts
2. ~/.zshrc executes
3. Directories are added to fpath
4. compinit runs (scans current fpath)
5. Completion functions are registered
6. Tab completion becomes available
```

**Critical:** Once `compinit` runs, it caches the state of `fpath`. Adding paths after `compinit` has no effect until the cache is rebuilt.

## The fpath Order Problem

### Why Order Matters

```zsh
# WRONG - Won't work
source $ZSH/oh-my-zsh.sh  # Calls compinit internally
fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)  # Too late!

# RIGHT - Works correctly
fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)  # Added first
source $ZSH/oh-my-zsh.sh  # Compinit sees the path
```

Oh My Zsh automatically calls `compinit` when `oh-my-zsh.sh` is sourced. Any `fpath` modifications after this line are invisible to the completion system.

### Manual compinit Calls

Never call `compinit` manually when using Oh My Zsh:

```zsh
# WRONG - Conflicts with Oh My Zsh
autoload -U compinit && compinit
source $ZSH/oh-my-zsh.sh  # Calls compinit again

# RIGHT - Let Oh My Zsh handle it
source $ZSH/oh-my-zsh.sh  # Calls compinit automatically
```

## Homebrew Completions

### Installation Paths

Homebrew stores completions at different paths depending on the platform:

| Platform | Path |
|----------|------|
| Apple Silicon (M1/M2/M3) | `/opt/homebrew/share/zsh/site-functions` |
| Intel Mac | `/usr/local/share/zsh/site-functions` |
| Linux (Linuxbrew) | `/home/linuxbrew/.linuxbrew/share/zsh/site-functions` |

### Portable Configuration

Use `brew --prefix` for cross-platform compatibility:

```zsh
if type brew &>/dev/null; then
  fpath=("$(brew --prefix)/share/zsh/site-functions" $fpath)
fi
```

This works on any platform where Homebrew is installed.

### What Homebrew Provides

Homebrew automatically installs completions for formulas that provide them:

- Core tools: `_brew`, `_git`, `_gh` (GitHub CLI)
- Modern CLI tools: `_bat`, `_fd`, `_rg` (ripgrep), `_zoxide`
- Programming tools: `_rbenv`, `_rustup` (if installed via Homebrew)

Check available completions:

```bash
ls $(brew --prefix)/share/zsh/site-functions/_*
```

## Generating Completions for CLI Tools

Many modern CLI tools can generate their own completions but don't install them automatically. Identify these tools and generate completions to the Homebrew directory.

### Common Generation Patterns

Test these patterns to check if a tool supports completion generation:

```bash
<tool> completion zsh        # Most common (gh, kubectl, helm)
<tool> completions zsh       # Rust tools (rustup)
<tool> complete zsh          # Less common (fclones)
<tool> gen-completions --shell zsh    # Some tools (atuin)
<tool> generate-shell-completion zsh  # Modern tools (uv)
<tool> --help | grep -i completion    # Discovery
```

### Verified Working Commands

| Tool | Command | Category |
|------|---------|----------|
| rustup | `rustup completions zsh rustup` | Rust toolchain |
| cargo | `rustup completions zsh cargo` | Rust package manager |
| starship | `starship completions zsh` | Shell prompt |
| uv | `uv generate-shell-completion zsh` | Python packages |
| atuin | `atuin gen-completions --shell zsh` | Shell history |
| op | `op completion zsh` | 1Password CLI |
| fclones | `fclones complete zsh` | Duplicate finder |
| gh | `gh completion -s zsh` | GitHub CLI |
| rclone | `rclone completion zsh -` | Cloud sync |

### Where to Save Generated Completions

Save completions to Homebrew's directory for automatic discovery:

```bash
# Generate completion to Homebrew location
rustup completions zsh rustup > $(brew --prefix)/share/zsh/site-functions/_rustup

# Or to a custom directory (requires adding to fpath)
mkdir -p ~/.zsh/completions
rustup completions zsh rustup > ~/.zsh/completions/_rustup
```

## Verification and Testing

### Check if a Completion Exists

Use `whence -v` to verify a completion function is available:

```bash
whence -v _brew     # Should show: _brew is an autoload shell function from /path
whence -v _rustup   # Should show path to _rustup file
whence -v _unknown  # Shows: _unknown not found
```

### View Current fpath

```bash
echo $fpath | tr " " "\n"
```

Look for these directories in the output:
- `/opt/homebrew/share/zsh/site-functions` (or `/usr/local/...`)
- `~/.oh-my-zsh/custom/plugins/zsh-completions/src` (if using zsh-completions plugin)
- System paths: `/usr/share/zsh/site-functions`

### Rebuild Completion Cache

When completions aren't working after configuration changes:

```bash
# Delete all cache files
rm -f ~/.zcompdump*

# Restart shell (triggers compinit)
exec zsh
```

### Test Tab Completion

Press TAB after a command to test:

```bash
brew <TAB>        # Should show brew subcommands
rustup <TAB>      # Should show rustup options
cargo <TAB>       # Should show cargo subcommands
```

## Oh My Zsh Integration

### Plugin-Based Completions

Oh My Zsh provides completions through plugins. Enable plugins in `~/.zshrc`:

```zsh
plugins=(git brew docker npm)
```

Common plugins with completions:
- `brew` - Homebrew commands and casks
- `git` - Git commands and branches
- `docker` - Docker commands and containers
- `npm` - npm commands and scripts
- `1password` - 1Password CLI (generates completion dynamically)

### The zsh-completions Plugin

Install additional completions with the zsh-completions plugin:

```bash
# Clone to custom plugins directory
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
```

Add to `~/.zshrc`:

```zsh
# Add to fpath BEFORE sourcing oh-my-zsh.sh
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

source $ZSH/oh-my-zsh.sh
```

This provides 200+ additional completions for tools without built-in completion support.

### Custom Completions Directory

For completions not in Homebrew or plugins, create a custom directory:

```zsh
# Add to ~/.zshrc BEFORE oh-my-zsh.sh
fpath=(~/.zsh/completions $fpath)

source $ZSH/oh-my-zsh.sh
```

Then create the directory and add completions:

```bash
mkdir -p ~/.zsh/completions
# Add custom completion files here
```

## Troubleshooting Common Issues

### Completions Not Working After Configuration

**Symptom:** Added `fpath` entry but completions still don't work

**Cause:** Completion cache not rebuilt

**Fix:**
```bash
rm -f ~/.zcompdump* && exec zsh
```

### brew Completion Not Found

**Symptom:** `whence -v _brew` shows "not found"

**Cause:** Homebrew path not in `fpath`, or added after `compinit`

**Fix:** Verify Homebrew path is added BEFORE `source $ZSH/oh-my-zsh.sh`

### Permission Issues on Generated Completions

**Symptom:** Cannot write to `/opt/homebrew/share/zsh/site-functions/`

**Cause:** Directory owned by different user

**Fix:** Use `~/.zsh/completions` instead and add to `fpath`

### Completions Work but Show Old/Wrong Content

**Symptom:** Completion shows outdated options

**Cause:** Stale `.zwc` compiled cache files

**Fix:**
```bash
rm -f ~/.zcompdump*.zwc
exec zsh
```

## Reference Resources

For detailed information, consult the reference files:

- **`references/completion-generators.md`** - Complete list of tools with built-in completion generation
- **`references/troubleshooting.md`** - Detailed troubleshooting for specific scenarios
- **`references/oh-my-zsh-integration.md`** - Deep dive into Oh My Zsh completion system

## Example Files

Working examples in `examples/`:

- **`zshrc-completions.zsh`** - Complete .zshrc configuration snippet
- **`generate-completions.sh`** - Script to generate all common completions

## Utility Scripts

Helper scripts in `scripts/`:

- **`discover-completions.sh`** - Scan installed tools for completion support
- **`verify-completions.sh`** - Verify completions are loaded correctly
