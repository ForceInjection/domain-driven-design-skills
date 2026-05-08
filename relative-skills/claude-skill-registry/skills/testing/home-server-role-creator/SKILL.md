---
name: home-server-role-creator
description: Complete guide for adding new self-hosted applications to the home-server Ansible infrastructure. Use this skill when the user wants to add a new service, create a new role, or deploy a new self-hosted application. Covers role structure, integration patterns (firewall, NGINX, SELinux, DNS), installation methods (binary, package, container), and testing procedures.
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
---

# Home Server Role Creator

## Purpose

This skill provides comprehensive guidance for adding new self-hosted applications to the home-server Ansible infrastructure. It documents all established patterns, conventions, and integration requirements to ensure consistent, secure, and maintainable role implementations.

## When to Use This Skill

Activate this skill when:
- Adding a new self-hosted service to the home server
- Creating a new Ansible role for a service
- Deploying a new application that needs web access via NGINX
- Integrating a new service with firewall, SELinux, or DNS

## Reference Files

This skill includes detailed reference files for in-depth information:

- **`references/role-examples.md`** - Complete real-world examples:
  - FileBrowser (binary service)
  - Jellyfin (package service)
  - Immich (container service with Podman Quadlet)

- **`references/checklists.md`** - Comprehensive checklists:
  - Pre-development checklist
  - Role structure checklist
  - Variable definition checklist
  - Task implementation checklist
  - Integration checklists (firewall, NGINX, SELinux, DNS)
  - Pre-deployment checklist
  - Post-deployment verification checklist
  - Troubleshooting guides

Load these reference files when detailed examples or comprehensive checklists are needed.

## Role Creation Workflow

Follow this workflow for every new service:

### 1. Planning Phase

**Determine Installation Method:**
```
Is the service containerized?
├─ Yes → Use Podman Quadlet pattern (see references/role-examples.md: Immich)
└─ No → Is it available in DNF/RPM repositories?
    ├─ Yes → Use Package installation (see references/role-examples.md: Jellyfin)
    └─ No → Use Binary download/installation (see references/role-examples.md: FileBrowser)
```

**Identify Required Integrations:**
- [ ] Web interface? → Needs NGINX reverse proxy
- [ ] Needs firewall port access? → Firewall configuration
- [ ] Custom storage locations? → SELinux contexts required
- [ ] Subdomain access? → DNS rewrite in AdGuard

### 2. Directory Setup

Create the role directory structure:

```bash
mkdir -p roles/[service_name]/{defaults,tasks,handlers,templates,meta}
```

Required directories:
- `defaults/` - Default variables (always created)
- `tasks/` - Task files (always created)
- `handlers/` - Event handlers (always created)
- `templates/` - Jinja2 templates (if service needs config files or systemd units)
- `meta/` - Role metadata (always created)

### 3. Core Implementation

#### Step 3.1: Create defaults/main.yml

Define all configurable variables following this pattern:

```yaml
---
# Default variables for [Service] role

# Service user configuration
service_user: ndelucca
service_group: ndelucca

# Directory configuration
service_base_dir: /opt/service  # or /srv/service
service_working_dir: "{{ service_base_dir }}/data"
service_config_dir: "{{ service_base_dir }}/config"

# Service configuration
service_name: service
service_enabled: true
service_state: started

# Network configuration
service_bind_address: 127.0.0.1  # ALWAYS 127.0.0.1 for web services
service_port: 8080

# Firewall settings
service_firewall_enabled: false  # false if behind NGINX
service_firewall_zone: FedoraServer

# SELinux configuration
service_manage_selinux: true
```

See `references/checklists.md` for complete variable definition checklist.

#### Step 3.2: Create tasks/main.yml

Orchestration file that imports modular task files:

```yaml
---
# Main entry point for [Service] role

- name: Include preflight checks
  ansible.builtin.import_tasks: preflight.yml
  tags: ['service', 'preflight']

- name: Install [Service]
  ansible.builtin.import_tasks: install.yml
  tags: ['service', 'install']

- name: Configure [Service] application
  ansible.builtin.import_tasks: configure.yml
  tags: ['service', 'configure']
  when: service_use_config_file | bool

- name: Configure systemd service
  ansible.builtin.import_tasks: service.yml
  tags: ['service', 'systemd']

- name: Configure SELinux
  ansible.builtin.import_tasks: selinux.yml
  tags: ['service', 'selinux']
  when: service_manage_selinux | bool
```

#### Step 3.3: Task Files

Create these task files based on service type:

**Always Required:**
- `preflight.yml` - OS verification, directory creation
- `install.yml` - Service installation (method varies by type)
- `service.yml` - Systemd service management
- `selinux.yml` - SELinux contexts and ports

**Conditional:**
- `configure.yml` - If service needs configuration files
- `repository.yml` - If package needs external repository
- `quadlet.yml` - If using Podman containers

For detailed implementation examples, see `references/role-examples.md`.

#### Step 3.4: Create handlers/main.yml

**Standard Services:**
```yaml
---
# Handlers for [Service] role

- name: daemon-reload
  ansible.builtin.systemd:
    daemon_reload: true
  become: true

- name: restart service
  ansible.builtin.systemd:
    name: "{{ service_name }}"
    state: restarted
  become: true

- name: apply selinux context
  ansible.builtin.command: "restorecon -Rv {{ item }}"
  become: true
  loop:
    - "{{ service_install_dir }}/service"
    - "{{ service_working_dir }}"
  changed_when: false
```

**Rootless Podman Services:**
```yaml
---
# Handlers for rootless Podman service

- name: daemon-reload-user
  ansible.builtin.systemd:
    daemon_reload: true
    scope: user
  become: true
  become_user: "{{ service_user }}"
  environment:
    XDG_RUNTIME_DIR: "/run/user/{{ service_uid }}"

- name: restart service-pod
  ansible.builtin.systemd:
    name: "{{ service_name }}"
    state: restarted
    scope: user
  become: true
  become_user: "{{ service_user }}"
  environment:
    XDG_RUNTIME_DIR: "/run/user/{{ service_uid }}"
```

#### Step 3.5: Create meta/main.yml

```yaml
---
galaxy_info:
  author: Naza
  description: Install and configure [Service] on Fedora
  license: MIT
  min_ansible_version: '2.13'
  platforms:
    - name: Fedora
      versions:
        - all

dependencies: []

collections:
  - community.general
  - ansible.posix
```

### 4. Integration

#### Step 4.1: Firewall Integration

Create `roles/firewall/tasks/[service_name].yml`:

**Pattern A: Service Behind NGINX (Most Common)**
```yaml
---
# [Service] is behind NGINX reverse proxy
# Access via [subdomain].ndelucca-server.com on ports 80/443

- name: Remove old direct port from firewall
  ansible.posix.firewalld:
    port: "{{ service_port }}/tcp"
    zone: "{{ service_firewall_zone }}"
    permanent: true
    immediate: true
    state: disabled
  become: true
  notify: reload firewalld
  ignore_errors: true
```

**Pattern B: Service Needs Direct Access**
```yaml
---
# Firewall configuration for [Service]

- name: Configure firewall ports
  ansible.posix.firewalld:
    port: "{{ service_port }}/tcp"
    zone: "{{ service_firewall_zone }}"
    permanent: true
    immediate: true
    state: enabled
  become: true
  notify: reload firewalld
```

Add import to `roles/firewall/tasks/main.yml`:
```yaml
- name: Configure firewall for [Service]
  ansible.builtin.import_tasks: service.yml
  when: service_firewall_enabled | default(true)
  tags: ['firewall-service']
```

#### Step 4.2: NGINX Reverse Proxy Integration

If service has web interface:

1. Add port variable to `roles/nginx/defaults/main.yml`:
   ```yaml
   nginx_service_port: 8080
   ```

2. Create `roles/nginx/templates/conf.d/[service].conf.j2`:
   ```nginx
   # HTTP
   server {
       listen 80;
       server_name [subdomain].{{ nginx_domain }};

       location / {
           proxy_pass http://127.0.0.1:{{ nginx_service_port }};
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }

   # HTTPS
   server {
       listen 443 ssl;
       http2 on;
       server_name [subdomain].{{ nginx_domain }};

       ssl_certificate {{ nginx_ssl_certificate }};
       ssl_certificate_key {{ nginx_ssl_certificate_key }};

       add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

       location / {
           proxy_pass http://127.0.0.1:{{ nginx_service_port }};
           # ... same proxy headers as HTTP
       }
   }
   ```

**NGINX Features to Add When Needed:**
- **WebSocket support**: For real-time features (Jellyfin, Immich)
  ```nginx
  proxy_http_version 1.1;
  proxy_set_header Upgrade $http_upgrade;
  proxy_set_header Connection "upgrade";
  ```

- **Large upload support**: For file/media services (FileBrowser, Immich)
  ```nginx
  client_max_body_size 50G;
  client_body_timeout 600s;
  proxy_read_timeout 600s;
  proxy_buffering off;
  proxy_request_buffering off;
  ```

3. Add template to `roles/nginx/tasks/configure.yml` loop

#### Step 4.3: SELinux Integration

Standard SELinux configuration in `tasks/selinux.yml`:

```yaml
---
# Configure SELinux for [Service]

- name: Check SELinux status
  ansible.builtin.command: getenforce
  register: selinux_status
  changed_when: false

- name: Install SELinux packages
  ansible.builtin.dnf:
    name: policycoreutils-python-utils
    state: present
  become: true
  when: selinux_status.stdout == "Enforcing"

- name: Set SELinux context for binary
  community.general.sefcontext:
    target: "{{ service_install_dir }}/service"
    setype: bin_t
    state: present
  become: true
  when: selinux_status.stdout == "Enforcing"
  notify: apply selinux context

- name: Set SELinux context for directories
  community.general.sefcontext:
    target: "{{ item.path }}(/.*)?"
    setype: "{{ item.type }}"
    state: present
  become: true
  loop:
    - { path: "{{ service_working_dir }}", type: "var_lib_t" }
    - { path: "{{ service_data_dir }}", type: "container_file_t" }  # or public_content_rw_t
  when: selinux_status.stdout == "Enforcing"
  notify: apply selinux context

- name: Allow service to bind to custom port
  community.general.seport:
    ports: "{{ service_port }}"
    proto: tcp
    setype: http_port_t
    state: present
  become: true
  when:
    - selinux_status.stdout == "Enforcing"
    - service_port != 80 and service_port != 443
```

**Common SELinux Types:**
- `bin_t` - Executables
- `var_lib_t` - Service directories
- `public_content_rw_t` - Writable content
- `container_file_t` - Container volumes
- `http_port_t` - HTTP ports

#### Step 4.4: DNS Rewrite Integration

Add to `inventory/host_vars/ndelucca-server.yml`:

```yaml
adguard_dns_rewrites:
  # ... existing entries ...
  - domain: [subdomain].ndelucca-server.com
    answer: 192.168.10.10
    enabled: true
```

Subdomain naming: Use short, descriptive names (files, jellyfin, torrent, gallery, cockpit)

### 5. Playbook Creation

#### Step 5.1: Create Service Playbook

Create `playbooks/[service].yml`:

```yaml
---
# [Service]-specific playbook
# Usage: ansible-playbook playbooks/[service].yml -l ndelucca-server

- name: Install and configure [Service]
  hosts: homeservers
  gather_facts: true

  roles:
    - [service_name]
```

#### Step 5.2: Update Site Playbook

Add role to `playbooks/site.yml`:

```yaml
    - role: [service_name]
      tags: ['service', 'category']
```

### 6. Testing and Deployment

#### Step 6.1: Syntax Check

```bash
ansible-playbook playbooks/[service].yml --syntax-check -l ndelucca-server
```

#### Step 6.2: Deploy

**CRITICAL: Always use ansible-host-limiter skill when running playbooks!**

```bash
ansible-playbook playbooks/[service].yml -l ndelucca-server
```

#### Step 6.3: Verification

Use `references/checklists.md` for comprehensive post-deployment verification checklist.

Essential checks:
```bash
# Service status
ansible ndelucca-server -m ansible.builtin.systemd -a "name=[service]" --become

# Service listening
ansible ndelucca-server -m shell -a "ss -tlnp | grep [port]"

# Test web access (if applicable)
curl http://[subdomain].ndelucca-server.com
curl https://[subdomain].ndelucca-server.com
```

## Installation Method Patterns

### Binary Installation (FileBrowser, Cloud Torrent)

**Key tasks:**
1. Download archive from GitHub/URL
2. Extract to temporary directory
3. Copy binary to `/usr/local/bin`
4. Create systemd unit file
5. Deploy configuration file

**See:** `references/role-examples.md` - FileBrowser example

### Package Installation (Jellyfin, Cockpit)

**Key tasks:**
1. Add external repository (if needed)
2. Install via DNF
3. Use system-managed systemd service
4. Configure via files or web UI

**See:** `references/role-examples.md` - Jellyfin example

### Container Installation (Immich)

**Key tasks:**
1. Install Podman (>= 4.4)
2. Enable user lingering
3. Create Kubernetes YAML pod definition
4. Deploy Quadlet .kube unit
5. Manage as systemd user service

**See:** `references/role-examples.md` - Immich example

## Mandatory Rules and Conventions

### Critical Rules

1. **Always use ansible-host-limiter skill** - Every ansible-playbook command MUST include `-l ndelucca-server`

2. **Service locality** - All web services MUST bind to `127.0.0.1`, never `0.0.0.0`

3. **NGINX as gateway** - All web services MUST be accessed through NGINX reverse proxy

4. **Firewall orchestration** - Firewall rules live in central `roles/firewall/`, not in service roles

5. **SELinux is mandatory** - Always configure SELinux contexts and ports

6. **User consistency** - Default to `ndelucca` user for all services

7. **Rootless when possible** - Prefer rootless Podman over rootful containers

### Variable Naming Convention

All service role variables follow this pattern:

```
[service]_user              # Service user (default: ndelucca)
[service]_group             # Service group (default: ndelucca)
[service]_port              # Service port
[service]_bind_address      # Bind address (default: 127.0.0.1)
[service]_base_dir          # Base directory (/srv or /opt)
[service]_working_dir       # Working/data directory
[service]_config_dir        # Configuration directory
[service]_service_name      # Systemd service name
[service]_service_enabled   # Enable on boot (default: true)
[service]_service_state     # Service state (default: started)
[service]_firewall_enabled  # Enable firewall (default: false if behind NGINX)
[service]_firewall_zone     # Firewall zone (default: FedoraServer)
[service]_manage_selinux    # Manage SELinux (default: true)
```

### File Naming Convention

```
roles/[service_name]/                          # Role directory (lowercase, underscores)
playbooks/[service_name].yml                   # Playbook (matches role name)
roles/firewall/tasks/[service_name].yml        # Firewall tasks
roles/nginx/templates/conf.d/[service].conf.j2 # NGINX config (short name)
/etc/systemd/system/[service_name].service     # Systemd unit
[subdomain].ndelucca-server.com                # DNS subdomain (short, descriptive)
```

### Directory Structure Conventions

**Binary installations:**
- Binary: `/usr/local/bin/[service]`
- Data: `/opt/[service]` or `/srv/[service]`

**Package installations:**
- Binary: System-managed
- Data: `/var/lib/[service]` or system default

**Container installations:**
- Config: `/srv/[service]/config`
- Data: `/srv/[service]/data` or custom location
- Quadlet: `/etc/containers/systemd/users/[uid]/`

## Common Patterns

### Pattern: External Repository Required

For services needing external repository (e.g., RPMFusion):

Create `tasks/repository.yml`:
```yaml
---
- name: Check if repository is enabled
  ansible.builtin.command: dnf repolist --enabled
  register: repo_list
  changed_when: false

- name: Install repository
  ansible.builtin.dnf:
    name: "[repository_rpm_url]"
    state: present
    disable_gpg_check: true
  become: true
  when: "'repo-name' not in repo_list.stdout"
```

### Pattern: Custom Storage Location

For services using custom storage (e.g., external disk):

1. Define variable in `defaults/main.yml`:
   ```yaml
   service_data_location: "{{ service_base_dir }}/data"
   ```

2. Override in `host_vars/ndelucca-server.yml`:
   ```yaml
   service_data_location: /srv/disks/D-Draco/media/Service
   ```

3. Apply SELinux context in `tasks/selinux.yml`:
   ```yaml
   - name: Set SELinux context for custom storage
     community.general.sefcontext:
       target: "{{ service_data_location }}(/.*)?"
       setype: container_file_t  # or public_content_rw_t
       state: present
   ```

### Pattern: Chained Handlers

For dependent services (e.g., AdGuard must start before NGINX):

```yaml
---
# Use 'listen' to chain handlers

- name: restart service
  ansible.builtin.systemd:
    name: "{{ service_name }}"
    state: restarted
  become: true
  listen: restart service

- name: wait for service
  ansible.builtin.wait_for:
    host: 127.0.0.1
    port: "{{ service_port }}"
  listen: restart service

- name: start dependent service
  ansible.builtin.systemd:
    name: dependent-service
    state: started
  become: true
  listen: restart service
```

## Quick Reference

### Typical Role Creation Time

- **Binary service**: 30-45 minutes
- **Package service**: 20-30 minutes
- **Container service**: 60-90 minutes

### Files Typically Modified

For each new service, expect to create/modify:
- Role directory: 6-10 files
- Firewall: 1 file + 1 import line
- NGINX: 1 template + 1 variable + 1 loop entry
- DNS: 1 rewrite entry
- Playbooks: 1 new playbook + 1 site.yml entry

### Most Common Issues

1. **Service won't start** → Check SELinux denials: `ausearch -m avc`
2. **Not accessible via NGINX** → Check SELinux boolean: `httpd_can_network_connect`
3. **Port conflicts** → Verify port not already in use: `ss -tlnp`
4. **Permission denied** → Check file ownership and SELinux contexts

### Essential Commands

```bash
# Syntax check
ansible-playbook playbooks/service.yml --syntax-check -l ndelucca-server

# Deploy
ansible-playbook playbooks/service.yml -l ndelucca-server

# Check service
ansible ndelucca-server -m systemd -a "name=service" --become

# Check logs
ansible ndelucca-server -m shell -a "journalctl -u service -n 50" --become

# Check SELinux
ansible ndelucca-server -m shell -a "ausearch -m avc -ts recent" --become
```

## Summary

When adding a new service:

1. **Plan**: Choose installation method, identify integrations
2. **Create**: Role structure with required files
3. **Implement**: Follow patterns for chosen installation method
4. **Integrate**: Firewall, NGINX, SELinux, DNS
5. **Test**: Syntax check, deploy with `-l ndelucca-server`, verify
6. **Document**: Update references if new patterns emerge

**Critical reminders:**
- Always use ansible-host-limiter skill
- Services bind to 127.0.0.1
- Configure SELinux for all directories
- Use reference files for detailed examples and checklists

For detailed examples, see `references/role-examples.md`.
For comprehensive checklists, see `references/checklists.md`.
