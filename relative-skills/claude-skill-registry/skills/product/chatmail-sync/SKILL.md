---
name: chatmail-sync
description: Synchronize NixOS chatmail modules with upstream relay project. Use when user wants to update modules from relay source, check for new features, or sync configurations. Explores the ENTIRE relay project. (project)
---

# Chatmail Sync

Synchronize NixOS modules with the upstream relay project.

## When to use

- User asks to sync/update modules from relay
- User asks to check for new features in relay
- User asks to update configurations from upstream
- User mentions "source of truth" or "relay upstream"

## Arguments

This skill accepts optional directory arguments:

| Argument | Description | Default |
|----------|-------------|---------|
| `--relay PATH` | Path to relay repository | `../forks/relay` (relative to project) |
| `--nixpkgs PATH` | Path to nixpkgs repository | `../forks/nixpkgs` (relative to project) |

Example usage:
```
/chatmail-sync
/chatmail-sync --relay ~/projects/relay --nixpkgs ~/nixpkgs
```

## Source paths

| Variable | Default | Description |
|----------|---------|-------------|
| `$RELAY_PATH` | `../forks/relay` relative to project | Upstream relay repository |
| `$PROJECT_PATH` | Current working directory | This project root |
| `$NIXPKGS_PATH` | `../forks/nixpkgs` or system nixpkgs | nixpkgs for API reference |

## CRITICAL: Update sources first

**ALWAYS pull latest changes before any sync work.**

### Step 0: Update relay repository

```bash
cd "$RELAY_PATH" && git pull origin main
cd "$PROJECT_PATH"
```

## CRITICAL: Exploration first

**NEVER assume you know the relay structure. ALWAYS explore thoroughly first.**

### Step 1: Discover relay structure

```bash
tree -a "$RELAY_PATH" -I '.git|__pycache__|*.pyc|.mypy_cache'

find "$RELAY_PATH" -type f \( -name "*.conf*" -o -name "*.ini*" -o -name "*.j2" -o -name "*.toml" -o -name "*.yaml" -o -name "*.yml" -o -name "*.lua" \)

find "$RELAY_PATH" -type f -name "*.service*" -o -name "*.timer*"

find "$RELAY_PATH" -type f -name "*.py" | head -50
```

### Step 2: Check recent changes

```bash
cd "$RELAY_PATH"

git log --oneline -30

git diff HEAD~20 --name-only

git log --oneline -10 -- chatmaild/
git log --oneline -10 -- cmdeploy/
```

### Step 3: Deep dive into components

For EACH component you need to sync:

1. **Search for ALL related files** in relay:
   ```bash
   grep -r "component_name" "$RELAY_PATH" --include="*.py" --include="*.j2" --include="*.conf*"
   ```

2. **Read the actual implementation** - don't guess

3. **Check for dependencies** between components

### Step 4: Compare with NixOS implementation

```bash
ls -la "$PROJECT_PATH/modules/"
ls -la "$PROJECT_PATH/pkgs/"

diff <(grep -h "key_setting" "$RELAY_PATH"/**/*.j2 2>/dev/null) \
     <(grep -h "key_setting" "$PROJECT_PATH/modules/"*.nix 2>/dev/null)
```

### Step 4.5: Sync packages

```bash
grep -E "rev|hash" "$PROJECT_PATH/pkgs/chatmail-www/default.nix"

cd "$RELAY_PATH" && git log --oneline -1

grep -E "version|rev|hash" "$PROJECT_PATH/pkgs/chatmaild/default.nix"
```

### Step 5: Check nixpkgs for native support

Before implementing anything custom, check if nixpkgs has it:

```bash
find "$NIXPKGS_PATH/nixos/modules/services/" -name "*.nix" | xargs grep -l "feature_name"

grep -A 20 "options\." "$NIXPKGS_PATH/nixos/modules/services/mail/dovecot.nix"
```

## Sync checklist

### Discovery phase (REQUIRED)
- [ ] Ran `tree` on relay project
- [ ] Found ALL config files (not just expected ones)
- [ ] Found ALL systemd units
- [ ] Checked git history for recent changes
- [ ] Identified ALL Python modules in chatmaild

### Comparison phase
- [ ] Compared each relay component with NixOS module
- [ ] Checked INI template vs INI generation
- [ ] Compared systemd services
- [ ] Compared config file contents
- [ ] Compared package versions with relay

### Extra additions phase (NixOS → relay)
- [ ] Checked for nginx locations not in relay
- [ ] Checked for deprecated components (`present=False` in deployers.py)
- [ ] Searched relay for each NixOS feature to confirm it exists
- [ ] Removed features that don't exist in relay

### Implementation phase
- [ ] Checked nixpkgs for native support first
- [ ] Updated NixOS modules to match relay
- [ ] Added missing options
- [ ] Removed extra additions not in relay
- [ ] Updated INI generation if needed
- [ ] Updated package revisions if needed

### Verification phase
- [ ] Nix syntax is valid
- [ ] All relay features are implemented
- [ ] No extra features added (strict relay compatibility)

## Common patterns

### Finding what chatmaild reads from INI

```bash
grep -E "params\[|params\.get|self\." "$RELAY_PATH/chatmaild/src/chatmaild/config.py"
```

### Finding how relay configures a service

```bash
grep -r "dovecot" "$RELAY_PATH" --include="*.py" --include="*.j2" --include="*.conf*" -l
```

### Checking what ports relay uses

```bash
grep -rE "port|PORT|:([0-9]{2,5})" "$RELAY_PATH" --include="*.py" --include="*.j2" --include="*.conf*"
```

### Finding extra additions in NixOS

```bash
grep -E "location\s+/" "$RELAY_PATH/cmdeploy/src/cmdeploy/nginx/nginx.conf.j2"
grep -E '"/[^"]*"\s*=' "$PROJECT_PATH/modules/nginx.nix"

grep -r "feature_name" "$RELAY_PATH" --include="*.j2" --include="*.conf*" --include="*.py"
```

### Finding deprecated components

```bash
grep -B2 -A2 "present=False" "$RELAY_PATH/cmdeploy/src/cmdeploy/deployers.py"
grep -B2 -A2 "running=False\|enabled=False" "$RELAY_PATH/cmdeploy/src/cmdeploy/deployers.py"
```

**Known deprecated components (NOT to be implemented):**
- `mta-sts-daemon` - removed from relay (present=False)
- `echobot.service` - disabled in relay (running=False, enabled=False)
- `rspamd` - removed from relay (present=False)
- `doveauth-dictproxy.service` - legacy, replaced by doveauth.service

### Checking INI options with relay defaults

Before removing or modifying any INI option, check if relay has a default:

```bash
grep -E "params\.get\(\"OPTION\"" "$RELAY_PATH/chatmaild/src/chatmaild/config.py"
grep -r "config\.OPTION\|self\.OPTION" "$RELAY_PATH/chatmaild/src/chatmaild/"*.py
grep -r "OPTION" "$PROJECT_PATH/modules/"*.nix
```

**Rule:**
```
If relay has: params.get("option", default)
And NixOS uses: different_value
Then: MUST set in INI (cannot rely on relay default)
```

**Before removing any INI option:**
1. Check if relay has `params.get()` default
2. Compare relay default with NixOS value
3. Check if option is used by multiple services
4. If values differ → keep in INI

### Verifying each NixOS feature exists in relay

For EACH feature in NixOS modules:
1. Search for it in relay: `grep -r "feature" "$RELAY_PATH"`
2. If not found → it's our addition → remove it
3. If found with `present=False` → deprecated → remove it

## NixOS-native vs Debian workarounds

Relay is designed for Debian/pyinfra deployment. NixOS has native declarative solutions for many things that Debian requires workarounds for.

### Principle

**Don't copy Debian-specific patterns. Find the NixOS-native way.**

### How to identify Debian workarounds in relay

```bash
grep -E "Environment=" "$RELAY_PATH/cmdeploy/src/cmdeploy/service/"*.service*
grep -E "server\.shell|run_shell" "$RELAY_PATH/cmdeploy/src/cmdeploy/deployers.py"
grep -E "apt\.|packages\." "$RELAY_PATH/cmdeploy/src/cmdeploy/deployers.py"
find "$RELAY_PATH" -name "*.cron*" -o -name "*cron*.j2"
grep -E "files\.put|files\.template" "$RELAY_PATH/cmdeploy/src/cmdeploy/deployers.py"
```

### Decision process

For each Debian pattern found:

1. **Identify the intent** - what is relay trying to achieve?
2. **Search nixpkgs for native support**:
   ```bash
   find "$NIXPKGS_PATH/nixos/modules/" -name "*.nix" | xargs grep -l "feature"
   ```
3. **If NixOS has native option** → use it instead of copying Debian approach
4. **If no native option** → implement following relay's approach

### Common patterns

| Relay Pattern | Check NixOS For |
|---------------|-----------------|
| `Environment=VAR=...` in systemd | Global NixOS option that sets this |
| `/etc/cron.d/*` files | `systemd.timers` |
| `acmetool` / certbot scripts | `security.acme` module |
| `apt install package` | Service module dependencies |
| `useradd`/`groupadd` | `users.users`/`users.groups` |
| `iptables` commands | `networking.firewall` |
| Template to `/etc/file` | Service's `configFile` or `extraConfig` |

### Verification

Before adding any relay systemd setting to NixOS:

```bash
grep -r "SETTING_NAME" "$NIXPKGS_PATH/nixos/modules/"
grep -A5 "mkOption" "$NIXPKGS_PATH/nixos/modules/services/mail/SERVICE.nix"
```

## Output

After sync, report:

1. **Files examined** in relay
2. **Changes made** to NixOS modules
3. **Package updates** (rev/hash changes)
4. **Features added** from relay (if any)
5. **Extra additions removed** (features that were in NixOS but not in relay)
6. **Deprecated components removed** (relay has `present=False`)
7. **Discrepancies** found and resolved
