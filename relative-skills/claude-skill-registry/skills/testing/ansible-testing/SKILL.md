---
name: ansible-testing
description: >
  This skill should be used when running ansible-lint, configuring linting rules,
  testing Ansible playbooks, validating playbook syntax, or setting up integration
  tests. Covers ansible-lint configuration and testing strategies.
---

# Ansible Testing

Testing strategies and ansible-lint configuration for Ansible automation.

## ansible-lint

### Running Lint

```bash
# Via mise (recommended)
mise run ansible-lint

# Directly with uv
uv run ansible-lint ansible/playbooks/

# Specific file
uv run ansible-lint ansible/playbooks/my-playbook.yml

# With verbose output
uv run ansible-lint -v ansible/
```

### Configuration File

Located at `ansible/.ansible-lint`:

```yaml
---
# Profile: null, min, basic, moderate, safety, shared, production
profile: moderate

# Offline mode - don't download Galaxy requirements
offline: true

# Exclude paths
exclude_paths:
  - .cache/
  - .venv/
  - .git/
  - "*/templates/"
  - "*.j2"
  - .deprecated/

# Rules to skip completely
skip_list:
  - var-naming[no-role-prefix]  # We use descriptive names
  - run-once[task]              # Safe with our strategy
  - command-instead-of-module   # CLI tools require command
  - yaml[line-length]           # Long lines in infra configs

# Rules to warn but not fail
warn_list:
  - fqcn[action-core]
  - fqcn[action]
  - no-handler
  - name[play]
```

### Common Rule Categories

| Category | Description |
|----------|-------------|
| `fqcn` | Fully qualified collection names |
| `yaml` | YAML formatting (indentation, line length) |
| `name` | Task/play naming conventions |
| `command-instead-of-module` | Using command when module exists |
| `no-changed-when` | Missing changed_when on command |
| `risky-file-permissions` | Missing explicit file permissions |

### Fixing Common Issues

**Missing name on task:**

```yaml
# BAD
- ansible.builtin.apt:
    name: nginx

# GOOD
- name: Install nginx
  ansible.builtin.apt:
    name: nginx
```

**Short module name:**

```yaml
# BAD (triggers fqcn warning)
- name: Install package
  apt:
    name: nginx

# GOOD
- name: Install package
  ansible.builtin.apt:
    name: nginx
```

**Using shell instead of command:**

```yaml
# BAD (when no shell features needed)
- name: List files
  ansible.builtin.shell: ls -la /tmp

# GOOD
- name: List files
  ansible.builtin.command: ls -la /tmp
  changed_when: false
```

**Missing changed_when:**

```yaml
# BAD (always shows changed)
- name: Check status
  ansible.builtin.command: systemctl status app

# GOOD
- name: Check status
  ansible.builtin.command: systemctl status app
  register: status_check
  changed_when: false
  failed_when: false
```

## Syntax Checking

Validate playbook syntax before running:

```bash
# Check syntax only
uv run ansible-playbook --syntax-check playbooks/my-playbook.yml

# Check mode (dry run)
uv run ansible-playbook playbooks/my-playbook.yml --check

# Diff mode (show changes)
uv run ansible-playbook playbooks/my-playbook.yml --check --diff
```

## Idempotency Testing

Verify playbooks are idempotent by running twice:

```bash
# First run - may show changes
uv run ansible-playbook playbooks/setup.yml

# Second run - should show 0 changes
uv run ansible-playbook playbooks/setup.yml

# If second run shows changes, playbook is NOT idempotent
```

### Automated Idempotency Check

```bash
#!/bin/bash
set -euo pipefail

PLAYBOOK="$1"

echo "First run..."
uv run ansible-playbook "$PLAYBOOK"

echo "Second run (checking idempotency)..."
OUTPUT=$(uv run ansible-playbook "$PLAYBOOK" 2>&1)

if echo "$OUTPUT" | grep -q "changed=0"; then
    echo "✓ Playbook is idempotent"
    exit 0
else
    echo "✗ Playbook is NOT idempotent"
    echo "$OUTPUT" | grep -E "(changed|failed)="
    exit 1
fi
```

## Integration Testing

### Test Against Real Infrastructure

```bash
# Limit to test hosts
uv run ansible-playbook playbooks/deploy.yml --limit test_hosts

# With verbose output
uv run ansible-playbook playbooks/deploy.yml --limit test_hosts -vv
```

### Pre-flight Validation

Add validation tasks at playbook start:

```yaml
---
- name: Deploy with validation
  hosts: all
  become: true

  pre_tasks:
    - name: Validate target environment
      ansible.builtin.assert:
        that:
          - ansible_distribution == "Debian"
          - ansible_distribution_major_version | int >= 11
        fail_msg: "Requires Debian 11+"

    - name: Check connectivity
      ansible.builtin.ping:

    - name: Verify disk space
      ansible.builtin.assert:
        that:
          - ansible_mounts | selectattr('mount', 'equalto', '/') | map(attribute='size_available') | first > 1073741824
        fail_msg: "Insufficient disk space"
```

## Test Playbook Pattern

Create test playbooks for validation:

```yaml
# playbooks/test-role.yml
---
- name: Test role functionality
  hosts: test_hosts
  become: true

  vars:
    test_mode: true

  roles:
    - role: my_role

  tasks:
    - name: Verify service is running
      ansible.builtin.systemd:
        name: myservice
      register: service_status
      failed_when: service_status.status.ActiveState != "active"

    - name: Verify config file exists
      ansible.builtin.stat:
        path: /etc/myservice/config.yml
      register: config_stat
      failed_when: not config_stat.stat.exists

    - name: Verify port is listening
      ansible.builtin.wait_for:
        port: 8080
        timeout: 10
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Ansible Lint

on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.13'

      - name: Install uv
        run: pip install uv

      - name: Install dependencies
        run: uv sync

      - name: Run ansible-lint
        run: uv run ansible-lint ansible/
```

## Debugging Playbooks

### Verbose Output

```bash
# Increase verbosity
uv run ansible-playbook playbook.yml -v    # Basic
uv run ansible-playbook playbook.yml -vv   # More detail
uv run ansible-playbook playbook.yml -vvv  # Connection debugging
uv run ansible-playbook playbook.yml -vvvv # Maximum detail
```

### Debug Tasks

```yaml
- name: Debug variable value
  ansible.builtin.debug:
    var: my_variable

- name: Debug with message
  ansible.builtin.debug:
    msg: "The value is {{ my_variable }}"

- name: Debug registered result
  ansible.builtin.debug:
    var: command_result
  when: ansible_verbosity > 0
```

### Step Mode

```bash
# Pause after each task
uv run ansible-playbook playbook.yml --step
```

## Lint Profiles

Choose appropriate profile based on needs:

| Profile | Strictness | Use Case |
|---------|------------|----------|
| `min` | Lowest | Legacy code, quick fixes |
| `basic` | Low | Development |
| `moderate` | Medium | General infrastructure |
| `safety` | High | Security-sensitive |
| `production` | Highest | Production deployments |

## Additional Resources

For detailed testing patterns and techniques, consult:

- **`references/testing-comprehensive.md`** - ansible-lint configuration, integration testing strategies, CI/CD patterns

## Related Skills

- **ansible-fundamentals** - Core Ansible patterns
- **ansible-idempotency** - Ensuring tasks are idempotent
