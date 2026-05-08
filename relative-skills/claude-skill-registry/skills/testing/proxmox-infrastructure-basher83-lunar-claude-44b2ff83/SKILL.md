---
name: proxmox-infrastructure
description: Proxmox VE cluster management including VM provisioning, template creation with cloud-init, QEMU guest
  agent integration, storage pool management, VLAN-aware bridge configuration, and Proxmox API interactions. Use when
  working with Proxmox VE, creating VM templates, configuring Proxmox networking, managing CEPH storage, troubleshooting
  VM deployment issues, or interacting with Proxmox API.
---

# Proxmox Infrastructure Management

Expert guidance for managing Proxmox VE clusters, creating templates, provisioning VMs, and configuring network
infrastructure.

## Quick Start

### Common Tasks

**Create VM Template:**

```bash
# See tools/build-template.yml for automated playbook
cd ansible && uv run ansible-playbook playbooks/proxmox-build-template.yml
```

**Clone Template to VM:**

```bash
qm clone <template-id> <new-vmid> --name <vm-name>
qm set <new-vmid> --sshkey ~/.ssh/id_rsa.pub
qm set <new-vmid> --ipconfig0 ip=192.168.1.100/24,gw=192.168.1.1
qm start <new-vmid>
```

**Check Cluster Status:**

```bash
# Use tools/cluster_status.py
./tools/cluster_status.py
```

## When to Use This Skill

Activate this skill when:

- Creating or managing Proxmox VM templates
- Provisioning VMs via cloning or Terraform
- Configuring Proxmox networking (bridges, VLANs, bonds)
- Troubleshooting VM deployment or network issues
- Managing CEPH storage pools
- Working with QEMU guest agent
- Interacting with Proxmox API via Python or Ansible

## Core Workflows

### 1. Template Creation

#### Method 1: Using Ansible (Recommended)

See [tools/build-template.yml](tools/build-template.yml) for complete automation.

#### Method 2: Manual CLI

See [reference/cloud-init-patterns.md](reference/cloud-init-patterns.md) for detailed steps.

Key points:

- Use `virtio-scsi-pci` controller for Ubuntu images
- Add cloud-init CD-ROM drive (`ide2`)
- Configure serial console for cloud images
- Convert to template with `qm template <vmid>`

### 2. VM Provisioning

**From Ansible:**
Analyze existing playbook: [../../ansible/playbooks/proxmox-build-template.yml](../../ansible/playbooks/proxmox-build-template.yml)

**From Terraform:**
See examples in [../../terraform/netbox-vm/](../../terraform/netbox-vm/)

**Key Configuration:**

```yaml
# Ansible example
proxmox_kvm:
  node: foxtrot
  api_host: 192.168.3.5
  vmid: 101
  name: docker-01
  clone: ubuntu-template
  storage: local-lvm
  # Network with VLAN
  net:
    net0: 'virtio,bridge=vmbr0,tag=30'
  ipconfig:
    ipconfig0: 'ip=192.168.3.100/24,gw=192.168.3.1'
```

### 3. Network Configuration

This Virgo-Core cluster uses:

- **vmbr0**: Management (192.168.3.0/24, VLAN 9 for Corosync)
- **vmbr1**: CEPH Public (192.168.5.0/24, MTU 9000)
- **vmbr2**: CEPH Private (192.168.7.0/24, MTU 9000)

See [reference/networking.md](reference/networking.md) for:

- VLAN-aware bridge configuration
- Bond setup (802.3ad LACP)
- Routed vs bridged vs NAT setups

## Architecture Reference

### This Cluster ("Matrix")

**Nodes:** Foxtrot, Golf, Hotel (3× MINISFORUM MS-A2)

**Hardware per Node:**

- AMD Ryzen 9 9955HX (16C/32T)
- 64GB DDR5 @ 5600 MT/s
- 3× NVMe: 1× 1TB (boot), 2× 4TB (CEPH)
- 4× NICs: 2× 10GbE SFP+, 2× 2.5GbE

**Network Architecture:**

```text
enp4s0 → vmbr0 (mgmt + vlan9 for corosync)
enp5s0f0np0 → vmbr1 (ceph public, MTU 9000)
enp5s0f1np1 → vmbr2 (ceph private, MTU 9000)
```

See [../../docs/goals.md](../../docs/goals.md) for complete specs.

## Tools Available

### Python Scripts (uv)

**validate_template.py** - Validate template health via API

```bash
./tools/validate_template.py --template-id 9000
```

**vm_diagnostics.py** - VM health checks

```bash
./tools/vm_diagnostics.py --vmid 101
```

**cluster_status.py** - Cluster health metrics

```bash
./tools/cluster_status.py
```

### Ansible Playbooks

**build-template.yml** - Automated template creation

- Downloads cloud image
- Creates VM with proper configuration
- Converts to template

**configure-networking.yml** - VLAN bridge setup

- Creates VLAN-aware bridges
- Configures bonds
- Sets MTU for storage networks

### OpenTofu Modules

**vm-module-example/** - Reusable VM provisioning

- Clone-based deployment
- Cloud-init integration
- Network configuration

See [examples/](examples/) directory.

**Real Examples from Repository**:

- **Multi-VM Cluster**: [../../terraform/examples/microk8s-cluster](../../terraform/examples/microk8s-cluster) - Comprehensive
  3-node MicroK8s deployment using `for_each` pattern, cross-node cloning, **dual NIC with VLAN** (VLAN 30 primary,
  VLAN 2 secondary), Ansible integration
- **Template with Cloud-Init**:
  [../../terraform/examples/template-with-custom-cloudinit](../../terraform/examples/template-with-custom-cloudinit) -
  Custom cloud-init snippet configuration
- **VLAN Bridge Configuration**:
  [../../ansible/playbooks/proxmox-enable-vlan-bridging.yml](../../ansible/playbooks/proxmox-enable-vlan-bridging.yml) -
  Enable VLAN-aware bridging on Proxmox nodes (supports VLANs 2-4094)

## Troubleshooting

Common issues and solutions:

### Template Creation Issues

**Serial console required:**
Many cloud images need serial console configured.

```bash
qm set <vmid> --serial0 socket --vga serial0
```

**Boot order:**

```bash
qm set <vmid> --boot order=scsi0
```

### Network Issues

**VLAN not working:**

1. Check bridge is VLAN-aware:

   ```bash
   grep "bridge-vlan-aware" /etc/network/interfaces
   ```

2. Verify VLAN in bridge-vids:

   ```bash
   bridge vlan show
   ```

**MTU problems (CEPH):**
Ensure MTU 9000 on storage networks:

```bash
ip link show vmbr1 | grep mtu
```

### VM Won't Start

1. Check QEMU guest agent:

   ```bash
   qm agent <vmid> ping
   ```

2. Review cloud-init logs (in VM):

   ```bash
   cloud-init status --wait
   cat /var/log/cloud-init.log
   ```

3. Validate template exists:

   ```bash
   qm list | grep template
   ```

For more issues, see [troubleshooting/](troubleshooting/) directory.

## Best Practices

1. **Always use templates** - Clone for consistency
2. **SSH keys only** - Never use password auth
3. **VLAN-aware bridges** - Enable for flexibility
4. **MTU 9000 for storage** - Essential for CEPH performance
5. **Serial console** - Required for most cloud images
6. **Guest agent** - Enable for IP detection and graceful shutdown
7. **Tag VMs** - Use meaningful tags for organization

## Progressive Disclosure

For deeper knowledge:

### Advanced Automation Workflows (from ProxSpray Analysis)

- [Cluster Formation](workflows/cluster-formation.md) - Complete cluster automation with idempotency
- [CEPH Deployment](workflows/ceph-deployment.md) - Automated CEPH storage deployment

### Core Reference

- [Cloud-Init patterns](reference/cloud-init-patterns.md) - Complete template creation guide
- [Network configuration](reference/networking.md) - VLANs, bonds, routing, NAT
- [API reference](reference/api-reference.md) - Proxmox API interactions
- [Storage management](reference/storage-management.md) - CEPH, LVM, datastores
- [QEMU guest agent](reference/qemu-guest-agent.md) - Integration and troubleshooting

### Anti-Patterns & Common Mistakes

- [Common Mistakes](anti-patterns/common-mistakes.md) - Real-world pitfalls from OpenTofu/Ansible deployments, template
  creation, and remote backend configuration

## Related Skills

- **NetBox + PowerDNS Integration** - Automatic DNS for Proxmox VMs
- **Ansible Best Practices** - Playbook patterns used in this cluster
