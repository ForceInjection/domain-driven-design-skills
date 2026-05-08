---
name: update-dotfiles-trends
description: Research latest trends in dotfiles, tooling, and suggest improvements
---

# Update Dotfiles Based on Latest Trends

This skill researches the latest trends in developer tooling, dotfiles configurations, and suggests improvements.

## Task

You should:

1. Research current trends in:
   - Neovim plugins and LazyVim ecosystem
   - Tmux plugins and configurations
   - Bash/shell improvements (zsh, fish, etc.)
   - Terminal emulators and modern CLI tools
   - AI-assisted development tools

2. Compare current dotfiles setup with best practices

3. Identify outdated configurations or deprecated tools

4. Suggest specific improvements with rationale

## Areas to Research

### Neovim/LazyVim
- New essential plugins
- LazyVim extras worth adding
- Better LSP configurations
- Improved treesitter parsers
- Better AI coding assistants

### Tmux
- New TPM plugins
- Better status line options
- Session management improvements
- Integration with modern terminals

### Shell
- Modern alternatives to classic commands
- Better prompt (starship, oh-my-posh)
- Shell productivity tools
- Environment managers (direnv, asdf)

### Modern CLI Tools
- ripgrep, fd, bat, exa, etc.
- fzf improvements
- Git tools (gh, lazygit, delta)
- Container tools (docker, podman)

## Output Format

For each suggestion:
```markdown
### [Tool/Plugin Name]

**Category**: [neovim/tmux/shell/cli]
**Current**: [what we currently use, or "not installed"]
**Proposed**: [what to install/configure]
**Benefits**: [why this is an improvement]
**Installation**: [how to install/configure]
**Breaking Changes**: [any compatibility concerns]
```

## Search Strategy

Use web search to find:
- "best neovim plugins 2025"
- "modern tmux setup 2025"
- "essential CLI tools for developers 2025"
- "dotfiles best practices 2025"
- Recent blog posts from: ThePrimeagen, TJ DeVries, etc.
