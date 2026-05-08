---
name: aap-vault-ssh
description: |
  Integrate Red Hat Ansible Automation Platform (AAP) with HashiCorp Vault Enterprise for dynamic SSH credential management. Use when: (1) Configuring Vault SSH secrets engine with AppRole auth for AAP, (2) Creating AAP credentials backed by Vault signed SSH certificates, (3) Provisioning infrastructure with Terraform/Ansible for AAP-Vault integration, (4) Setting up multi-tenant credential management, (5) Configuring golden images to trust Vault SSH CA, (6) Implementing credential rotation strategies. Based on HashiCorp validated pattern.
---

# AAP + Vault SSH Integration

Dynamically signed SSH credentials replacing static key management.

## Architecture

```
AAP Job → AppRole Auth → Vault SSH CA → Signed Certificate → Target Host
```

1. AAP authenticates to Vault via AppRole
2. AAP credential plugin submits SSH key for signing
3. Vault SSH CA signs certificate (2hr TTL)
4. AAP uses signed cert for SSH access

## Quick Start

### 1. Vault Configuration (Terraform)

```hcl
# Enable SSH secrets engine
resource "vault_mount" "ssh" {
  path = "ssh"
  type = "ssh"
}

resource "vault_ssh_secret_backend_ca" "ssh" {
  backend              = vault_mount.ssh.path
  generate_signing_key = true
}

# AppRole for AAP
resource "vault_approle_auth_backend_role" "aap" {
  backend        = "approle"
  role_name      = var.tenant
  token_policies = ["aap-ssh"]
}

# SSH signing role
resource "vault_ssh_secret_backend_role" "aap" {
  backend                 = vault_mount.ssh.path
  name                    = var.tenant
  key_type                = "ca"
  allow_user_certificates = true
  default_user            = "aap"
  allowed_users           = "aap,ansible"
  ttl                     = "7200"
  default_extensions      = { "permit-pty" = "" }
}
```

**Full Terraform config**: See [references/vault-config.md](references/vault-config.md)

### 2. AAP Credential Setup (Ansible)

```yaml
# Vault SSH credential
- name: Create Vault SSH Credential
  ansible.controller.credential:
    name: "vault_ssh_{{ tenant }}"
    credential_type: "HashiCorp Vault Signed SSH"
    inputs:
      url: "{{ vault_url }}"
      role_id: "{{ role_id }}"
      secret_id: "{{ secret_id }}"
      default_auth_path: "approle"

# Machine credential linked to Vault
- name: Create Machine Credential
  ansible.controller.credential:
    name: "machine_{{ tenant }}"
    credential_type: "Machine"
    inputs:
      username: "aap"
  register: machine_cred

- name: Link to Vault Source
  ansible.controller.credential_input_source:
    input_field_name: "ssh_public_key_data"
    target_credential: "{{ machine_cred.id }}"
    source_credential: "vault_ssh_{{ tenant }}"
    metadata:
      role: "{{ tenant }}"
      secret_path: "ssh"
```

**Full AAP config**: See [references/aap-config.md](references/aap-config.md)

### 3. Golden Image (Packer + Ansible)

Target hosts must trust Vault's SSH CA:

```yaml
- name: Download Vault SSH CA
  ansible.builtin.get_url:
    url: "{{ vault_url }}/v1/ssh/public_key"
    headers:
      X-Vault-Namespace: "{{ vault_namespace }}"
    dest: /etc/ssh/trusted-user-ca-keys.pem

- name: Configure SSH CA Trust
  ansible.builtin.lineinfile:
    path: /etc/ssh/sshd_config
    line: "TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem"
  notify: Restart SSH
```

**Full image config**: See [references/golden-image.md](references/golden-image.md)

## Multi-Tenancy

Map tenants across both platforms:

| AAP | Vault |
|-----|-------|
| Organization | Namespace |
| Credential | AppRole + SSH Role |
| Team | Entity/Group |

**Policy templating** for dynamic paths:
```hcl
path "ssh/sign/{{identity.entity.name}}" {
  capabilities = ["read", "update"]
}
```

## Credential Rotation

### Self-Rotation (Recommended)

AAP job rotates its own secret_id daily:

```hcl
# Vault policy allowing self-rotation
path "auth/approle/role/{{ tenant }}/secret-id" {
  capabilities = ["update"]
}
```

Schedule AAP job template to run rotation playbook.

## Troubleshooting

| Issue | Check |
|-------|-------|
| Auth failure | Verify role_id/secret_id, check namespace |
| Signing failure | Verify allowed_users includes target user |
| SSH rejected | Verify TrustedUserCAKeys on target, check CA fingerprint |
| Certificate expired | Check TTL settings (default 2hr) |

## References

- [references/vault-config.md](references/vault-config.md) - Complete Terraform for Vault SSH + AppRole
- [references/aap-config.md](references/aap-config.md) - Complete Ansible for AAP credentials
- [references/golden-image.md](references/golden-image.md) - Packer/Ansible for target host images
