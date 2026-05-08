---
name: forge-lang-ansible
description: Ansible automation safety practices. Enforces check-mode-first workflow. Use when working with playbooks, roles, or inventory files.
---

# Ansible Development

## Safety Rules

**NEVER run without --check first:**
- `ansible-playbook` on production
- Any playbook that modifies systems

**ALWAYS use:**
- `--check` for dry run
- `--diff` to show changes
- `-v` for verbosity

## Workflow

```
┌────────────────────────────────────────────────┐
│  LINT → CHECK → DIFF → REVIEW → RUN           │
└────────────────────────────────────────────────┘
```

### Step 1: Lint

```bash
ansible-lint playbook.yml
```

### Step 2: Check Mode (Dry Run)

```bash
ansible-playbook playbook.yml --check --diff
```

**Show output to user and wait for confirmation.**

### Step 3: Run (only after explicit approval)

```bash
ansible-playbook playbook.yml --diff
```

## Linting

```bash
# Ansible-lint
ansible-lint playbook.yml

# Lint entire project
ansible-lint

# YAML formatting
yamlfmt -w .
```

## Testing with Molecule

```bash
# Run full test cycle
molecule test

# Create and converge only
molecule converge

# Verify
molecule verify

# Destroy
molecule destroy
```

## Project Structure

```
project/
├── ansible.cfg
├── inventory/
│   ├── production/
│   │   └── hosts.yml
│   └── staging/
│       └── hosts.yml
├── group_vars/
│   └── all.yml
├── host_vars/
├── roles/
│   └── my_role/
│       ├── tasks/
│       ├── handlers/
│       ├── templates/
│       ├── files/
│       ├── vars/
│       ├── defaults/
│       └── meta/
├── playbooks/
│   └── site.yml
└── README.md
```

## Pre-Run Checklist

```
Ansible Checklist:
- [ ] ansible-lint passed
- [ ] --check mode completed
- [ ] --diff output reviewed
- [ ] Inventory correct for target env
- [ ] User confirmed changes
- [ ] Ready to run
```

## Inventory Safety

- Never hardcode production hosts
- Use inventory groups
- Separate prod/staging inventories
- Use `--limit` for targeted runs

```bash
# Limit to specific hosts
ansible-playbook playbook.yml --limit webservers

# Limit to single host
ansible-playbook playbook.yml --limit host1.example.com
```

## Syntax Checking

```bash
# Syntax check
ansible-playbook playbook.yml --syntax-check

# List tasks
ansible-playbook playbook.yml --list-tasks

# List hosts
ansible-playbook playbook.yml --list-hosts

# List tags
ansible-playbook playbook.yml --list-tags
```

## Role Template

```yaml
# roles/my_role/tasks/main.yml
---
- name: Ensure package is installed
  ansible.builtin.package:
    name: "{{ package_name }}"
    state: present
  become: true

- name: Template configuration file
  ansible.builtin.template:
    src: config.j2
    dest: /etc/myapp/config.yml
    owner: root
    group: root
    mode: '0644'
  notify: Restart myapp
```
