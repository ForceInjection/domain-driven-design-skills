---
name: nushell-install-utils
description: Install Nushell utilities (zoxide, starship, carapace) with cross-platform support. Use when the user wants to set up Nushell integrations for common CLI tools.
---

# Nushell Utilities Installer

Cross-platform tool to install and configure Nushell integrations for popular utilities.

## Supported Utilities

- **zoxide**: Smarter cd command that learns your habits
- **starship**: Fast, customizable prompt
- **carapace**: Multi-shell completion generator

## Commands

### List Available Utilities

Shows installation status of all supported utilities.

```bash
python .claude/skills/nushell-install-utils/install.py --list
```

### Install All Utilities

Installs configuration files for all available utilities.

```bash
python .claude/skills/nushell-install-utils/install.py --all
```

### Install Specific Utilities

Install only the utilities you need.

```bash
python .claude/skills/nushell-install-utils/install.py zoxide starship
```

### Force Overwrite

Overwrite existing configuration files.

```bash
python .claude/skills/nushell-install-utils/install.py --all --force
```

## What It Does

For each utility:
1. Checks if the utility is installed in your PATH
2. Runs the utility's init command (e.g., `zoxide init nushell`)
3. Saves the output to `~/.config/nushell/<utility>.nu`

## Installation Locations

- **Linux/macOS**: `~/.config/nushell/` (or `$XDG_CONFIG_HOME/nushell/`)
- **Windows**: `%APPDATA%\nushell\`

## Output Files

- `zoxide.nu` - Zoxide integration
- `starship.nu` - Starship prompt
- `carapace.nu` - Carapace completions

## Next Steps

After installation:
1. Add source commands to your `config.nu`:
   ```nushell
   source ~/.config/nushell/zoxide.nu
   source ~/.config/nushell/starship.nu
   source ~/.config/nushell/carapace.nu
   ```
2. Restart your shell or run: `source $nu.config-path`

## Usage

When user says:
- "install nushell utilities" -> run `--all`
- "install zoxide for nushell" -> run with `zoxide`
- "setup starship" -> run with `starship`
- "show nushell utils" -> run `--list`

## Prerequisites

The utilities must be installed on your system first:
- **zoxide**: https://github.com/ajeetdsouza/zoxide
- **starship**: https://starship.rs/
- **carapace**: https://github.com/carapace-sh/carapace-bin

Install them via your package manager (e.g., `brew install zoxide starship`, `cargo install carapace`)
