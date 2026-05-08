---
name: github-runner-setup
description: |
  GitHub Actions self-hosted runner setup and maintenance. Use when setting up dedicated runner users,
  migrating runners from personal accounts, troubleshooting runner issues, or implementing runner isolation.
  Covers systemd services, environment isolation, and skills plane integration.
tags: [github-actions, devops, runner, systemd, infrastructure]
keywords: self-hosted runner, github actions, systemd, runner isolation, runner migration, runner troubleshooting
---

# GitHub Runner Setup & Maintenance

Comprehensive skill for managing self-hosted GitHub Actions runners with dedicated user isolation and systemd service management.

## When to Use This Skill

- Setting up new self-hosted runners with dedicated user accounts
- Migrating runners from personal user accounts to dedicated runner users
- Troubleshooting runner connectivity or execution issues
- Implementing environment isolation to prevent CI/dev environment pollution
- Configuring systemd services for auto-restart on reboot
- Fixing workflow issues related to runner permissions or environment

## Key Principles

1. **Environment Isolation**: Runners run as dedicated `runner` user, not dev user
2. **Systemd Management**: Services auto-start on reboot, managed via systemd
3. **Skills Plane Integration**: Runner user has permanent `~/.agent/skills` mount
4. **Security**: Minimal permissions for runner user (no sudo by default)

## Quick Reference

### Check Runner Status
```bash
# List active runners on GitHub
cd ~/prime-radiant-ai
gh api repos/stars-end/prime-radiant-ai/actions/runners --jq '.runners[] | {id, name, status, busy}'

# Check systemd service status
sudo systemctl status 'actions.runner.stars-end-prime-radiant-ai.*'

# View runner logs
sudo journalctl -u 'actions.runner.stars-end-prime-radiant-ai.*' -f
```

### Common Tasks

**Restart a Runner**:
```bash
sudo systemctl restart actions.runner.stars-end-prime-radiant-ai.*
```

**Update agent-skills for runner user**:
```bash
sudo -u runner git -C ~runner/agent-skills pull origin main
```

**Switch to runner user for debugging**:
```bash
sudo su - runner
```

**Regenerate runner token** (tokens expire after a few hours):
```bash
# Generate new token
cd ~/prime-radiant-ai
TOKEN=$(gh api --method POST repos/stars-end/prime-radiant-ai/actions/runners/registration-token --jq .token)

# Stop service, reconfigure, restart
sudo systemctl stop actions.runner.stars-end-prime-radiant-ai.*
cd /home/runner/actions-runner-prime-radiant
sudo -u runner ./config.sh remove
sudo -u runner ./config.sh --url https://github.com/stars-end/prime-radiant-ai --token $TOKEN --name "$(hostname -s)-prime-radiant" --labels "self-hosted,linux,x64" --work _work --unattended
sudo systemctl start actions.runner.stars-end-prime-radiant-ai.*
```

## Full Setup Guide

**See comprehensive documentation**: `docs/SELF_HOSTED_RUNNER_SETUP.md`

The complete setup guide covers:
- Creating dedicated runner user
- Installing runners with proper isolation
- Systemd service configuration
- Migration from personal user runners
- Troubleshooting common issues
- Security considerations
- Maintenance procedures

## Architecture

```
/home/runner/
├── .agent/
│   └── skills -> /home/runner/agent-skills
├── agent-skills/           # Cloned from stars-end/agent-skills
├── actions-runner-prime-radiant/
│   ├── config.sh
│   ├── run.sh
│   └── svc.sh
└── actions-runner-affordabot/
    ├── config.sh
    ├── run.sh
    └── svc.sh
```

## Troubleshooting

### Runner Not Appearing in GitHub

**Symptoms**: Runner shows as offline or doesn't appear in GitHub UI

**Debug**:
```bash
# Check service status
sudo systemctl status actions.runner.stars-end-prime-radiant-ai.*

# Check recent logs for errors
sudo journalctl -u actions.runner.stars-end-prime-radiant-ai.* -n 50

# Try running manually to see connection errors
sudo -u runner bash
cd ~/actions-runner-prime-radiant
./run.sh  # Press Ctrl+C to stop
```

**Common causes**:
- Token expired → Regenerate token and reconfigure
- Network issues → Check firewall rules for GitHub API access
- Service not running → `sudo systemctl start ...`

### Workflow Fails with "Unable to locate executable file: unzip"

**Symptoms**: Setup actions (`actions/setup-bun`, `actions/setup-node`, etc.) fail with "unzip not found"

**Solution**: Install missing system utilities
```bash
# Install unzip and zip system-wide
sudo apt-get update
sudo apt-get install -y unzip zip

# Verify
sudo -u runner which unzip  # Should show /usr/bin/unzip

# Restart runner to pick up changes
sudo systemctl restart actions.runner.stars-end-prime-radiant-ai.*
```

### Workflow Needs Python 3.13

**Symptoms**: Workflows fail with wrong Python version or Python 3.13 not found

**Solution**: Install Python 3.13 via mise
```bash
# Install mise for runner user (if not already)
sudo -u runner bash -c 'curl https://mise.run | sh'

# Configure shell
sudo -u runner bash -c 'echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> ~/.bashrc'
sudo -u runner bash -c 'echo "eval \"\$(mise activate bash)\"" >> ~/.bashrc'

# Install Python 3.13
sudo -u runner bash -c 'export PATH="$HOME/.local/bin:$PATH" && mise use --global python@3.13 && mise install'

# Verify
sudo -u runner bash --login -c 'python --version'  # Should show 3.13.x

# Restart runner
sudo systemctl restart actions.runner.stars-end-prime-radiant-ai.*
```

### Workflow Fails with "Permission Denied"

**Symptoms**: Workflows fail with permission errors accessing files/directories

**Solution**: Runner user may need additional permissions
```bash
# Add to docker group (if workflows use Docker)
sudo usermod -aG docker runner

# For specific directory access, use ACLs
sudo setfacl -m u:runner:rwx /path/to/directory

# Restart runner service after group changes
sudo systemctl restart actions.runner.stars-end-prime-radiant-ai.*
```

### Skills Mount Corruption (Dev Environment)

**Symptoms**: `~/.agent/skills` in dev user environment points to runner workspace

**Root Cause**: Old workflow configuration that ran as dev user and modified global symlink

**Fix**:
```bash
# Fix dev user's symlink
rm -f ~/.agent/skills && ln -sfn ~/agent-skills ~/.agent/skills

# Verify runner's symlink is isolated (should NOT affect dev user)
sudo -u runner ls -la ~/.agent/skills
# Should show: /home/runner/.agent/skills -> /home/runner/agent-skills
```

**Prevention**: Ensure workflows don't create `~/.agent/skills` symlinks if using dedicated runner user

### Runner Service Won't Start

**Debug steps**:
```bash
# Check if service file exists
ls -la /etc/systemd/system/actions.runner.stars-end-*

# Reload systemd daemon
sudo systemctl daemon-reload

# Check for failed units
sudo systemctl --failed

# View detailed service errors
sudo systemctl status actions.runner.stars-end-prime-radiant-ai.* -l
```

## Workflow Integration

Workflows running on self-hosted runners should be aware of:

### Skills Environment

Runner user has permanent skills mount. Workflows should verify rather than recreate:

```yaml
- name: Setup Skills Environment
  run: |
    # Runner user already has permanent skills mount at ~/.agent/skills → ~/agent-skills
    # Verify the existing mount
    ls -la ~/.agent/skills

    # Workflow checkout is available at $PWD/agent-skills if needed
    ls -la $PWD/agent-skills
```

### Beads CLI

Runner user should have Beads CLI installed:

```yaml
- name: Install Beads CLI
  run: |
    pip install beads-cli
```

### Python/Node Setup

Use mise for consistent toolchain:

```yaml
- name: Setup Python via mise
  uses: ./.github/actions/setup-python-mise
```

## Security Considerations

### Minimal Permissions

Runner user should have:
- ✅ Read/write to its own home directory
- ✅ Execute permissions for required tools (git, docker, mise, etc.)
- ❌ NO sudo access (unless workflows explicitly require it)
- ❌ NO access to other users' home directories

### Secrets Handling

- Never log secrets in workflow output
- Use GitHub secrets for sensitive values
- Runner has access to repository secrets during workflow execution
- Secrets are automatically masked in logs

### Network Isolation

Consider:
- Firewall rules limiting runner's network access
- VPN/bastion for accessing internal resources
- Separate runner for public vs private repos

## Related Documentation

- `docs/SELF_HOSTED_RUNNER_SETUP.md` - Complete setup guide
- `docs/SKILLS_PLANE.md` - Skills mount architecture
- `docs/DX_BOOTSTRAP_CONTRACT.md` - Session startup requirements

## Agent Guidance

When working on runner-related tasks:

1. **First**, check runner status on GitHub and systemd
2. **Read logs** before making changes: `sudo journalctl -u actions.runner...`
3. **Test manually** before modifying systemd services: `sudo -u runner ./run.sh`
4. **Document changes** in commit messages with Feature-Key trailers
5. **Verify isolation** after changes: runner user changes shouldn't affect dev user

## Quick Start for New VM

To set up self-hosted runners on a new VM:

1. Create runner user: `sudo useradd -m -s /bin/bash -c "GitHub Actions Runner" runner`
2. Clone agent-skills for runner: `sudo -u runner git clone https://github.com/stars-end/agent-skills.git ~runner/agent-skills`
3. Setup skills mount: `sudo -u runner bash -c 'mkdir -p ~/.agent && ln -sfn ~/agent-skills ~/.agent/skills'`
4. Follow full setup guide in `docs/SELF_HOSTED_RUNNER_SETUP.md`

## Notes

- Runner tokens expire after a few hours; keep track if reconfiguring
- Systemd services persist across reboots (unlike nohup/screen)
- Runner isolation prevents the "skills mount corruption" problem
- Each repository needs its own runner registration
- Runners can be shared across repos by adding multiple repo registrations
