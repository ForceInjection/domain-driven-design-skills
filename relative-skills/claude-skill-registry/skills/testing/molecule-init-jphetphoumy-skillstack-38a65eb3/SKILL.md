---
name: molecule-init
description: Initialize Molecule testing framework for Ansible roles with Docker-based TDD setup. Use when creating new Ansible roles, setting up molecule scenarios, or when user asks to initialize molecule testing.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

# Molecule Testing Framework Initializer

This skill sets up the Molecule testing framework for Ansible roles using Docker containers and Ansible playbooks (no Molecule plugins required).

## When to Use This Skill

Automatically activate when:
- User creates a new Ansible role with `ansible-galaxy init`
- User asks to "initialize molecule", "setup molecule", or "add molecule testing"
- User requests TDD setup for an Ansible role
- User wants to create a new molecule scenario

## Prerequisites Check

Before starting, verify:
1. Docker is installed and running: `docker --version`
2. Ansible is installed: `ansible --version`
3. Molecule is installed: `molecule --version`
4. We're in an Ansible role directory (contains `tasks/`, `handlers/`, `defaults/`, `meta/` directories)

## Setup Process

### Step 1: Gather Information

Ask the user:
1. **Target OS/Platform**: Which Docker image to use?
   - Debian 12 (default): `geerlingguy/docker-debian12-ansible:latest`
   - Ubuntu 22.04: `geerlingguy/docker-ubuntu2204-ansible:latest`
   - Ubuntu 20.04: `geerlingguy/docker-ubuntu2004-ansible:latest`
   - CentOS 8: `geerlingguy/docker-centos8-ansible:latest`

2. **Scenario Name**: Default is "default", but allow custom names for multiple scenarios

3. **Role namespace and name**: Extract from `meta/main.yml` if exists, otherwise ask

### Step 2: Verify Role Metadata

Ensure `meta/main.yml` contains required fields:
```yaml
galaxy_info:
  role_name: <role_name>
  namespace: <namespace>
```

If missing, update or create the file with proper structure.

### Step 3: Create Directory Structure

Create the following structure:
```
role-directory/
├── molecule/
│   └── <scenario-name>/
│       ├── tasks/
│       │   └── create-fail.yml
│       ├── molecule.yml
│       ├── create.yml
│       ├── converge.yml
│       ├── verify.yml
│       └── destroy.yml
└── requirements.yml (if not exists)
```

### Step 4: Create requirements.yml

In the role root directory:
```yaml
---
collections:
  - name: community.docker
    version: ">=3.10.4"
```

### Step 5: Create molecule.yml

```yaml
---
dependency:
  name: galaxy
  options:
    requirements-file: requirements.yml
platforms:
  - name: instance
    image: <selected-docker-image>
```

**IMPORTANT:** DO NOT USE DELEGATED DRIVER WHEN CREATING THE molecule.yml.

### Step 6: Create create.yml

Create the container creation playbook (Ansible-managed inventory using `community.docker` connection):
```yaml
---
- name: Create
  hosts: localhost
  gather_facts: false
  vars:
    molecule_inventory:
      all:
        hosts: {}
        molecule: {}
  tasks:
    - name: Create a container
      community.docker.docker_container:
        name: "{{ item.name }}"
        image: "{{ item.image }}"
        state: started
        command: sleep 1d
        log_driver: json-file
      register: result
      loop: "{{ molecule_yml.platforms }}"

    - name: Print some info
      ansible.builtin.debug:
        msg: "{{ result.results }}"

    - name: Fail if container is not running
      when: >
        item.container.State.ExitCode != 0 or
        not item.container.State.Running
      ansible.builtin.include_tasks:
        file: tasks/create-fail.yml
      loop: "{{ result.results }}"
      loop_control:
        label: "{{ item.container.Name }}"

    - name: Add container to molecule_inventory
      vars:
        inventory_partial_yaml: |
          all:
            children:
              molecule:
                hosts:
                  "{{ item.name }}":
                    ansible_connection: community.docker.docker
      ansible.builtin.set_fact:
        molecule_inventory: >
          {{ molecule_inventory | combine(inventory_partial_yaml | from_yaml, recursive=true) }}
      loop: "{{ molecule_yml.platforms }}"
      loop_control:
        label: "{{ item.name }}"

    - name: Dump molecule_inventory
      ansible.builtin.copy:
        content: |
          {{ molecule_inventory | to_yaml }}
        dest: "{{ molecule_ephemeral_directory }}/inventory/molecule_inventory.yml"
        mode: "0600"

    - name: Force inventory refresh
      ansible.builtin.meta: refresh_inventory

    - name: Fail if molecule group is missing
      ansible.builtin.assert:
        that: "'molecule' in groups"
        fail_msg: |
          molecule group was not found inside inventory groups: {{ groups }}
      run_once: true  # noqa: run-once[task]

- name: Validate that inventory was refreshed
  hosts: molecule
  gather_facts: false
  tasks:
    - name: Check uname
      ansible.builtin.raw: uname -a
      register: result
      changed_when: false

    - name: Display uname info
      ansible.builtin.debug:
        msg: "{{ result.stdout }}"
```

### Step 7: Create create-fail.yml

Create error handling in `molecule/<scenario-name>/tasks/create-fail.yml`:
```yaml
---
- name: Retrieve container log
  ansible.builtin.command:
    cmd: >-
      docker logs
      {{ item.container.Name }}
  changed_when: false
  register: logfile_cmd

- name: Display container log
  ansible.builtin.fail:
    msg: "{{ logfile_cmd.stderr }}"
```

### Step 8: Create converge.yml

Create a basic converge playbook (raw command, no SSH/Python dependency):
```yaml
---
- name: Fail if molecule group is missing
  hosts: localhost
  tasks:
    - name: Print some info
      ansible.builtin.debug:
        msg: "{{ groups }}"

    - name: Assert group existence
      ansible.builtin.assert:
        that: "'molecule' in groups"
        fail_msg: |
          molecule group was not found inside inventory groups: {{ groups }}

- name: Converge
  hosts: molecule
  gather_facts: false
  tasks:
    - name: Check uname
      ansible.builtin.raw: uname -a
      register: result
      changed_when: false

    - name: Print some info
      ansible.builtin.assert:
        that: result.stdout is ansible.builtin.search("^Linux")
```

### Step 9: Create verify.yml

Ask the user what to verify, or create a basic template:
```yaml
---
- name: Verify
  hosts: molecule
  gather_facts: false
  tasks:
    - name: Placeholder verification task
      ansible.builtin.debug:
        msg: "Add your verification tasks here"
```

Explain that they should add specific verification tasks based on what their role does.

### Step 10: Create destroy.yml

```yaml
---
- name: Destroy molecule containers
  hosts: molecule
  gather_facts: false
  tasks:
    - name: Stop and remove container
      delegate_to: localhost
      community.docker.docker_container:
        name: "{{ inventory_hostname }}"
        state: absent
        auto_remove: true

- name: Remove dynamic molecule inventory
  hosts: localhost
  gather_facts: false
  tasks:
    - name: Remove dynamic inventory file
      ansible.builtin.file:
        path: "{{ molecule_ephemeral_directory }}/inventory/molecule_inventory.yml"
        state: absent
```

### Step 11: Install Dependencies and Test

Run:
```bash
ansible-galaxy collection install -r requirements.yml
molecule test
```

**IMPORTANT:** Setting up molecule is only done if molecule test return no errors

## TDD Workflow Guidance

After setup, guide the user on the TDD workflow:

1. **Write tests first** in `verify.yml`
2. **Run tests** with `molecule verify` (should fail)
3. **Implement role** in `tasks/main.yml`
4. **Apply and verify** with `molecule converge && molecule verify`
5. **Test idempotence** with `molecule idempotence`

## Common Commands Reference

Provide the user with these commands:
- `molecule create` - Create test container
- `molecule converge` - Apply role
- `molecule verify` - Run verification tests
- `molecule test` - Full test suite
- `molecule destroy` - Remove containers
- `molecule login` - SSH into test container

## Error Handling

If errors occur:
1. Check Docker is running
2. Verify role metadata has `role_name` and `namespace`
3. Ensure collections are installed
4. Check YAML syntax in all files
5. Review container logs if creation fails
6. Avoid systemd/SSH expectations; the provided create play uses `community.docker.docker` to bypass SSH in lightweight images.

## Success Criteria

The skill completes successfully when:
1. All molecule files are created
2. `meta/main.yml` has correct role_name and namespace
3. `requirements.yml` exists with required collections
4. `molecule test` runs without errors (or user confirms manual test)

## Output

Provide the user with:
- Confirmation of created files
- Next steps for TDD workflow
- Reference to useful molecule commands
- Link to full setup guide if available
