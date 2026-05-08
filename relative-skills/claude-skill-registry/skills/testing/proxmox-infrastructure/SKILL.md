---
name: proxmox-infrastructure
description: Manage the Matrix/Virgo-Core Proxmox VE cluster (nodes Foxtrot, Golf, Hotel - MINISFORUM MS-A2 with AMD Ryzen 9 9955HX). Covers VM provisioning, VLAN networking, CEPH storage, and automation via Python (proxmoxer), Ansible (community.general.proxmox), and Terraform (Telmate/proxmox).
---

# Proxmox Infrastructure: Matrix/Virgo-Core Cluster

Manage 3-node Proxmox VE cluster with CEPH storage, VLAN networking, and cloud-init automation.

## Trigger Phrases

Use this skill when you see:
- "Clone the Ubuntu template to create a new VM"
- "Check CEPH storage health on the cluster"
- "Configure VLAN 30 networking for a Proxmox VM"
- "Create a cloud-init template from Ubuntu noble image"
- "What's the status of nodes Foxtrot, Golf, or Hotel?"
- "Deploy VMs using Terraform and the Proxmox provider"
- "Configure MTU 9000 for CEPH storage networks"
- "Troubleshoot VM deployment or networking issues"
- "Use Ansible community.general.proxmox modules"
- "Validate template configuration via Proxmox API"

## Available Tools

### Python Scripts (uv-based)
- **validate_template.py** - Validate template health via Proxmox API
- **cluster_status.py** - Cluster health metrics and node status
- **check_ceph_health.py** - CEPH storage pool health monitoring
- **check_cluster_health.py** - Comprehensive cluster diagnostics

All scripts support `--help` for usage. Run with: `uv run tools/<script>.py`

### Automation Examples
- **Ansible playbooks** - Template creation, VLAN bridging setup
- **Terraform modules** - VM cloning, multi-node deployments with dual NICs

See examples/ and workflows/ for working configurations.

## Core Capabilities

**Template Management:**
- Ubuntu/Debian cloud-init templates with virtio-scsi
- Serial console configuration for cloud images
- Proper boot order and cloud-init CD-ROM (ide2)

**Network Infrastructure:**
- vmbr0: Management (VLAN 9 for Corosync)
- vmbr1: CEPH Public (192.168.5.0/24, MTU 9000)
- vmbr2: CEPH Private (192.168.7.0/24, MTU 9000)
- VLAN-aware bridging (supports VLANs 2-4094)
- 802.3ad LACP bonding

**CEPH Storage:**
- Multi-OSD configuration (2× 4TB NVMe per node)
- MTU 9000 for storage networks
- Public/private network separation
- Health monitoring and diagnostics

**API Automation:**
- Python via proxmoxer library
- Ansible via community.general.proxmox_* modules
- Terraform via Telmate/proxmox provider

## Cluster Architecture (Matrix)

**Hardware:** 3× MINISFORUM MS-A2
- AMD Ryzen 9 9955HX (16C/32T)
- 64GB DDR5 @ 5600 MT/s
- 3× NVMe: 1× 1TB boot, 2× 4TB CEPH OSDs
- 4× NICs: 2× 10GbE SFP+, 2× 2.5GbE

**Nodes:** Foxtrot, Golf, Hotel

## Quick Examples

**Clone template to VM:**
```bash
qm clone 9000 101 --name web-01
qm set 101 --ipconfig0 ip=192.168.3.100/24,gw=192.168.3.1
qm set 101 --net0 virtio,bridge=vmbr0,tag=30
qm start 101
```

**Check cluster health:**
```bash
uv run tools/cluster_status.py
uv run tools/check_ceph_health.py
```

## For Details

- **reference/** - Cloud-init, networking, API, storage, QEMU guest agent
- **workflows/** - Cluster formation, CEPH deployment automation
- **examples/** - Terraform configs, Ansible playbooks
- **anti-patterns/** - Common mistakes from real deployments
