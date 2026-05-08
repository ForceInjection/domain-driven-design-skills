---
name: ansible-playbook-generator
description: Generate Ansible playbook files for infrastructure automation and configuration management. Triggers on "create ansible playbook", "generate ansible config", "ansible automation", "infrastructure playbook".
---

# Ansible Playbook Generator

Generate Ansible playbook files for infrastructure automation.

## Output Requirements

**File Output:** `playbook.yml`, `inventory.yml`, `roles/*/tasks/main.yml`
**Format:** Valid Ansible YAML
**Standards:** Ansible 2.15+

## When Invoked

Immediately generate a complete Ansible playbook with roles and inventory.

## Example Invocations

**Prompt:** "Create Ansible playbook for web server setup"
**Output:** Complete playbook with nginx, node.js, and ssl configuration.
