---
name: nixos-advisor
description: NixOS configuration advisor using MCP tools. Use when helping with NixOS/Home Manager configs, searching packages/options, or providing NixOS-specific guidance. Validates packages exist before suggesting them.
---

# NixOS Configuration Advisor

Provides expert guidance for NixOS and Home Manager configurations using the NixOS MCP server tools.

## MCP Tools Available

The nixos MCP server provides these tools:
- `nixos_search` - Search NixOS packages, options, programs, or flakes
- `nixos_info` - Get detailed info about a package or option
- `nixos_channels` - List available NixOS channels
- `nixos_stats` - Get statistics for a channel
- `home_manager_search` - Search Home Manager options
- `home_manager_info` - Get detailed info about Home Manager option
- `darwin_search` - Search nix-darwin options (macOS)
- `darwin_info` - Get info about nix-darwin option

## Required Workflow

**ALWAYS follow this process when suggesting packages or options:**

1. **Search first**: Use MCP tools to verify package/option exists
2. **Check details**: Get full info including description and version
3. **Verify channel**: Note if package is in stable/unstable
4. **Suggest config**: Provide NixOS/Home Manager configuration
5. **Rebuild command**: Provide appropriate rebuild command

### Example: Adding a Package

User asks: "Add Firefox"

1. Search: `nixos_search(query="firefox", search_type="packages")`
2. Verify: `nixos_info(name="firefox", type="package")`
3. Check channel availability and current version
4. Suggest config:
```nix
environment.systemPackages = with pkgs; [
  firefox
];
```
5. Provide rebuild: `sudo nixos-rebuild switch --flake .#hostname`

### Example: Configuring Options

User asks: "Enable SSH"

1. Search: `nixos_search(query="openssh", search_type="options")`
2. Get details: `nixos_info(name="services.openssh.enable", type="option")`
3. Suggest config:
```nix
services.openssh = {
  enable = true;
  settings = {
    PermitRootLogin = "no";
    PasswordAuthentication = false;
  };
};
```

### Example: Home Manager

User asks: "Configure git"

1. Search: `home_manager_search(query="git")`
2. Get info: `home_manager_info(name="programs.git.enable")`
3. Suggest config:
```nix
programs.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your.email@example.com";
};
```

## Channel Awareness

- **Unstable**: Latest packages, may have breaking changes
- **Stable (24.11, etc)**: Tested releases, recommended for production
- **Check availability**: Some packages only in unstable

Use `nixos_channels()` to see available channels and their status.

## Best Practices

### DO:
- Always validate packages/options with MCP before suggesting
- Check channel differences and inform user
- Provide complete, working configuration examples
- Use `pkgs.unstable.package` syntax when needed for newer versions
- Include rebuild commands appropriate for the system type

### DON'T:
- Never suggest packages without MCP verification
- Don't assume package names (firefox-esr vs firefox)
- Don't skip checking if option exists
- Don't suggest destructive commands without warning

## System Detection

Detect system type from context:
- **NixOS**: `sudo nixos-rebuild switch --flake .#hostname`
- **Darwin (macOS)**: `darwin-rebuild switch --flake .#hostname`
- **Home Manager standalone**: `home-manager switch --flake .#user@hostname`

## Flake Structure

User's typical flake structure:
```
.
├── flake.nix
├── host/
│   ├── nixos/
│   └── darwin/
├── home/
│   ├── common/
│   └── users/
└── modules/
```

## Common Tasks

### Search packages
```
nixos_search(query="package-name", search_type="packages", limit=10)
```

### Find options
```
nixos_search(query="service", search_type="options", limit=20)
```

### Get package details
```
nixos_info(name="package-name", type="package")
```

### Check Home Manager option
```
home_manager_info(name="programs.package.enable")
```

### List channels
```
nixos_channels()
```

## Error Handling

- **Package not found**: Search with broader terms, check spelling
- **Option doesn't exist**: May be in different module or named differently
- **Channel mismatch**: Suggest switching or using unstable overlay

## Notes

- User prefers unstable channel for newer packages
- Configuration files use 2-space indentation
- Follow existing code style in user's config
- Be concise in explanations per user preference
