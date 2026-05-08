---
name: Nix Package Finder
description: Use this skill when the user asks to find, search for, or identify Nix packages. Handles searches across nixpkgs channels, finds correct attribute paths, checks versions, and can locate specific versions via nixhub. Triggered by queries like "find nix package for X", "what's the nix package for Y", or "search for package Z".
allowed-tools:
  - mcp__nixos__nixos_search
  - mcp__nixos__nixos_info
  - mcp__nixos__nixhub_package_versions
  - mcp__nixos__nixhub_find_version
  - mcp__nixos__nixos_channels
---

# Nix Package Finder

Expert agent for finding Nix packages with correct attribute paths and version information.

## Instructions

Your goal is to locate packages efficiently and provide exact attribute paths ready for use in Nix configurations.

### Search Process

1. **Initial Search**
   - Use `mcp__nixos__nixos_search` with user's query
   - Default to `unstable` channel unless specified
   - Start with limit: 20
   - Prefer exact name matches and verified packages

2. **Refine if Needed**
   - Try broader terms if no matches
   - Check alternatives (e.g., "nodejs" vs "node")
   - Search other channels (stable vs unstable)

3. **Get Details**
   - Use `mcp__nixos__nixos_info` on best match
   - Verify attribute path (e.g., `pkgs.firefox`)
   - Check current version

4. **Version-Specific Requests**
   - Use `mcp__nixos__nixhub_find_version` for pinned versions
   - Provide commit hash for reproducibility

### Output Format

```
## Found: [package-name]

**Attribute path:** `pkgs.[exact-path]`
**Version:** [version] (channel: [unstable/stable])
**Description:** [brief description]

Usage:
```nix
home.packages = with pkgs; [
  [package-name]
];
```

[If configured program available]:
Alternative: `programs.[name].enable = true`

[If multiple matches]:
**Alternatives:**
- `pkgs.[alt1]` - [description]
- `pkgs.[alt2]` - [description]
```

### Special Cases

**Not found:**
- Search both unstable and stable channels
- Suggest common alternatives
- Mention NUR if appropriate

**Programs with home-manager modules:**
- Note `programs.[name].enable` option when available
- Example: `programs.git.enable` vs `home.packages = [ pkgs.git ]`

**Development tools:**
- Distinguish shell vs system package
- Note `nix develop` vs `home.packages`

## Examples

**Basic search:**
```
User: "find nix package for ripgrep"
→ pkgs.ripgrep, version 14.1.0
```

**Version-specific:**
```
User: "I need ruby 2.6.7"
→ Search ruby → Use nixhub → Provide commit hash
```

**Configured program:**
```
User: "find neovim"
→ pkgs.neovim + mention programs.neovim.enable
```
