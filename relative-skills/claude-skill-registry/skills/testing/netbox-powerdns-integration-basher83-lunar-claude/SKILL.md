---
name: netbox-powerdns-integration
description: NetBox IPAM and PowerDNS integration for automated DNS record management.
---

# NetBox PowerDNS Integration

Expert guidance for implementing NetBox as your source of truth for infrastructure documentation and
automating DNS record management with PowerDNS.

## Quick Start

### Common Tasks

**Query NetBox API:**

```bash
# List all sites
./tools/netbox_api_client.py sites list

# Get device details
./tools/netbox_api_client.py devices get --name foxtrot

# List VMs in cluster
./tools/netbox_api_client.py vms list --cluster matrix

# Query IPs
./tools/netbox_api_client.py ips query --dns-name docker-01
```

**Create VM in NetBox:**

```bash
# Create VM with auto-assigned IP
./tools/netbox_vm_create.py --name docker-02 --cluster matrix --vcpus 4 --memory 8192

# Create VM with specific IP
./tools/netbox_vm_create.py --name k8s-01-master --cluster matrix --ip 192.168.3.50/24
```

**IPAM Queries:**

```bash
# Get available IPs
./tools/netbox_ipam_query.py available --prefix 192.168.3.0/24

# Check prefix utilization
./tools/netbox_ipam_query.py utilization --site matrix

# View IP assignments
./tools/netbox_ipam_query.py assignments --prefix 192.168.3.0/24
```

**Validate DNS Naming:**

```bash
./tools/validate_dns_naming.py --name "docker-01-nexus.spaceships.work"
```

**Deploy from NetBox Inventory:**

```bash
cd ansible && uv run ansible-playbook -i tools/netbox-dynamic-inventory.yml deploy-from-netbox.yml
```

## When to Use This Skill

Activate this skill when:

- **Querying NetBox API** - Sites, devices, VMs, IPs, prefixes, VLANs
- **Setting up NetBox IPAM** - Prefixes, IP management, VRFs
- **Implementing automated DNS** - PowerDNS sync plugin configuration
- **Creating DNS naming conventions** - `service-NN-purpose.domain` pattern
- **Managing VMs in NetBox** - Creating, updating, IP assignment
- **Using Terraform with NetBox** - Provider configuration and resources
- **Setting up Ansible dynamic inventory** - NetBox as inventory source
- **Troubleshooting NetBox-PowerDNS sync** - Tag matching, zone configuration
- **Migrating to NetBox** - From manual DNS or spreadsheet tracking
- **Infrastructure documentation** - Using NetBox as source of truth

## Core Workflows

### 1. NetBox API Usage

**Query infrastructure data:**

```python
#!/usr/bin/env -S uv run --script --quiet
# /// script
# requires-python = ">=3.11"
# dependencies = ["pynetbox>=7.0.0", "infisical-python>=2.3.3"]
# ///

import pynetbox
from infisical import InfisicalClient

# Get token from Infisical
client = InfisicalClient()
token = client.get_secret(
    secret_name="NETBOX_API_TOKEN",
    project_id="7b832220-24c0-45bc-a5f1-ce9794a31259",
    environment="prod",
    path="/matrix"
).secret_value

# Connect to NetBox
nb = pynetbox.api('https://netbox.spaceships.work', token=token)

# Query devices in Matrix cluster
site = nb.dcim.sites.get(slug='matrix')
devices = nb.dcim.devices.filter(site='matrix')

for device in devices:
    print(f"{device.name}: {device.primary_ip4.address if device.primary_ip4 else 'No IP'}")
```

See [reference/netbox-api-guide.md](reference/netbox-api-guide.md) for complete API reference.

### 2. DNS Naming Convention

This infrastructure uses the pattern: `<service>-<number>-<purpose>.<domain>`

**Examples:**

- `docker-01-nexus.spaceships.work` - Docker host #1 running Nexus
- `proxmox-foxtrot-mgmt.spaceships.work` - Proxmox node Foxtrot management interface
- `k8s-01-master.spaceships.work` - Kubernetes cluster master node #1

**Implementation:**

```python
# tools/validate_dns_naming.py validates this pattern
pattern = r'^[a-z0-9-]+-\d{2}-[a-z0-9-]+\.[a-z0-9.-]+$'
```

See [workflows/naming-conventions.md](workflows/naming-conventions.md) for complete rules.

### 3. NetBox + PowerDNS Sync Setup

#### Step 1: Install Plugin

```bash
# In NetBox virtualenv
pip install netbox-powerdns-sync
```

#### Step 2: Configure Plugin

```python
# /opt/netbox/netbox/netbox/configuration.py
PLUGINS = ['netbox_powerdns_sync']

PLUGINS_CONFIG = {
    "netbox_powerdns_sync": {
        "powerdns_managed_record_comment": "netbox-managed",
        "post_save_enabled": True,  # Real-time sync
    },
}
```

#### Step 3: Create Zones in NetBox

Configure zones with:

- Zone name (e.g., `spaceships.work`)
- PowerDNS server connection
- Tag matching rules (e.g., `production-dns`)
- DNS name generation method

See [reference/sync-plugin-reference.md](reference/sync-plugin-reference.md) for details.

### 4. Terraform Integration

**Provider Setup:**

```hcl
terraform {
  required_providers {
    netbox = {
      source  = "e-breuninger/netbox"
      version = "~> 5.0.0"
    }
  }
}

provider "netbox" {
  server_url = "https://netbox.spaceships.work"
  api_token  = var.netbox_api_token
}
```

**Create IP with Auto-DNS:**

```hcl
resource "netbox_ip_address" "docker_host" {
  ip_address  = "192.168.1.100/24"
  dns_name    = "docker-01-nexus.spaceships.work"
  description = "Docker host for Nexus registry"

  tags = [
    "terraform",
    "production-dns"  # Triggers auto DNS sync
  ]
}
```

DNS records created automatically by plugin!

See [reference/terraform-provider-guide.md](reference/terraform-provider-guide.md) and [examples/netbox-terraform-provider.tf](examples/netbox-terraform-provider.tf).

### 5. Ansible Dynamic Inventory

**Use NetBox as Inventory Source:**

```yaml
# tools/netbox-dynamic-inventory.yml
plugin: netbox.netbox.nb_inventory
api_endpoint: https://netbox.spaceships.work
token: !vault |
  $ANSIBLE_VAULT;...
group_by:
  - device_roles
  - tags
```

**Deploy Using NetBox Data:**

```bash
ansible-playbook -i tools/netbox-dynamic-inventory.yml deploy-from-netbox.yml
```

See [workflows/ansible-dynamic-inventory.md](workflows/ansible-dynamic-inventory.md).

## Architecture Reference

### DNS Automation Flow

```text
1. Create/Update resource in NetBox
   └→ IP Address with dns_name and tags

2. NetBox PowerDNS Sync Plugin activates
   └→ Matches IP to zone based on tags
   └→ Generates DNS records

3. PowerDNS API called
   └→ A record: docker-01-nexus.spaceships.work → 192.168.1.100
   └→ PTR record: 100.1.168.192.in-addr.arpa → docker-01-nexus.spaceships.work

4. DNS propagates automatically
   └→ No manual DNS configuration needed
```

### Integration with Proxmox

```text
Terraform/Ansible
  ↓
Creates VM in Proxmox
  ↓
Registers in NetBox (via API)
  ├→ Device object
  ├→ IP Address with dns_name
  └→ Tags (production-dns)
  ↓
NetBox PowerDNS Sync
  ↓
DNS Records in PowerDNS
  ↓
Ansible Dynamic Inventory
  ↓
Automated configuration management
```

## Tools Available

### NetBox API Tools (Python + uv)

**netbox_api_client.py** - Comprehensive NetBox API client

```bash
# List sites, devices, VMs, IPs
./tools/netbox_api_client.py sites list
./tools/netbox_api_client.py devices get --name foxtrot
./tools/netbox_api_client.py vms list --cluster matrix
./tools/netbox_api_client.py ips query --dns-name docker-01
./tools/netbox_api_client.py prefixes available --prefix 192.168.3.0/24
```

**netbox_vm_create.py** - Create VMs in NetBox with IP assignment

```bash
# Create VM with auto IP
./tools/netbox_vm_create.py --name docker-02 --cluster matrix --vcpus 4 --memory 8192

# Create VM with specific IP
./tools/netbox_vm_create.py --name k8s-01-master --cluster matrix --ip 192.168.3.50/24
```

**netbox_ipam_query.py** - Advanced IPAM queries

```bash
# Available IPs
./tools/netbox_ipam_query.py available --prefix 192.168.3.0/24

# Prefix utilization
./tools/netbox_ipam_query.py utilization --site matrix

# IP assignments
./tools/netbox_ipam_query.py assignments --prefix 192.168.3.0/24

# IPAM summary
./tools/netbox_ipam_query.py summary --site matrix
```

**validate_dns_naming.py** - Validate DNS naming conventions

```bash
./tools/validate_dns_naming.py --name "docker-01-nexus.spaceships.work"
```

### Terraform Modules

**netbox-data-sources.tf** - Examples using NetBox provider

- Query existing NetBox resources
- Use as data sources for other resources

### Ansible Playbooks

**deploy-from-netbox.yml** - Deploy using NetBox inventory

- Dynamic inventory from NetBox
- Tag-based host selection
- Automatic IP and hostname discovery

See [examples/](examples/) directory.

## Troubleshooting

### DNS Records Not Syncing

#### Check 1: Tag Matching

```bash
# Verify IP has correct tags
./tools/netbox_query.py --ip 192.168.1.100 | jq '.tags'
```

#### Check 2: Zone Configuration

- Ensure zone exists in NetBox
- Verify tag rules match
- Check PowerDNS server connectivity

#### Check 3: Sync Results

```bash
./tools/powerdns_sync_check.py --zone spaceships.work --verbose
```

### Naming Convention Violations

**Validate names before creating:**

```bash
./tools/validate_dns_naming.py --name "my-proposed-name.domain"
```

**Common mistakes:**

- Uppercase letters (use lowercase only)
- Missing service number (must be XX format)
- Wrong domain
- Special characters (use hyphens only)

### Terraform Provider Issues

**Version mismatch:**

```text
Warning: NetBox version 4.3.0 not supported by provider 3.9.0
```

**Solution:** Update provider version:

```hcl
version = "~> 5.0.0"  # Match NetBox 4.3.x
```

### Dynamic Inventory Not Working

**Check API connectivity:**

```bash
curl -H "Authorization: Token YOUR_TOKEN" \
  https://netbox.spaceships.work/api/dcim/devices/
```

**Verify inventory plugin:**

```bash
ansible-inventory -i tools/netbox-dynamic-inventory.yml --list
```

See [troubleshooting/](reference/) for more details.

## Best Practices

1. **Consistent naming** - Always follow `service-NN-purpose.domain` pattern
2. **Use tags** - Tag resources for auto-DNS (`production-dns`, `lab-dns`)
3. **Document in NetBox** - Single source of truth for all infrastructure
4. **Real-time sync** - Enable `post_save_enabled` for immediate DNS updates
5. **Terraform everything** - Manage NetBox resources as IaC
6. **Dynamic inventory** - Never maintain static Ansible inventory
7. **Audit regularly** - Run `dns_record_audit.py` to verify sync

## DNS Naming Patterns

### Service Types

- `docker-NN-<app>` - Docker hosts
- `k8s-NN-<role>` - Kubernetes nodes
- `proxmox-<node>-<iface>` - Proxmox infrastructure
- `storage-NN-<purpose>` - Storage systems
- `db-NN-<dbtype>` - Database servers

### Examples from This Infrastructure

```text
docker-01-nexus.spaceships.work       # Nexus container registry
k8s-01-master.spaceships.work         # K8s control plane
k8s-02-worker.spaceships.work         # K8s worker node
proxmox-foxtrot-mgmt.spaceships.work  # Proxmox mgmt interface
proxmox-foxtrot-ceph.spaceships.work  # Proxmox CEPH interface
storage-01-nas.spaceships.work        # NAS storage
db-01-postgres.spaceships.work        # PostgreSQL database
```

## Progressive Disclosure

For deeper knowledge:

### NetBox API & Integration

- [NetBox API Guide](reference/netbox-api-guide.md) - Complete REST API reference with pynetbox examples
- [NetBox Data Models](reference/netbox-data-models.md) - Data model relationships and hierarchy
- [NetBox Best Practices](reference/netbox-best-practices.md) - Security, performance, automation patterns

### DNS & PowerDNS Integration

- [Sync Plugin Reference](reference/sync-plugin-reference.md) - PowerDNS sync plugin installation and config
- [Terraform Provider Guide](reference/terraform-provider-guide.md) - Complete provider documentation
- [Naming Conventions](workflows/naming-conventions.md) - Detailed DNS naming rules
- [DNS Automation](workflows/dns-automation.md) - End-to-end automation workflows

### Ansible Integration

- [Ansible Dynamic Inventory](workflows/ansible-dynamic-inventory.md) - Using NetBox as inventory source

### Anti-Patterns & Common Mistakes

- [Common Mistakes](anti-patterns/common-mistakes.md) - DNS naming violations, cluster domain errors, master node targeting,
  and NetBox integration pitfalls for spaceships.work infrastructure

## Related Skills

- **Proxmox Infrastructure** - VMs auto-registered in NetBox with DNS
- **Ansible Best Practices** - Dynamic inventory and secrets management
