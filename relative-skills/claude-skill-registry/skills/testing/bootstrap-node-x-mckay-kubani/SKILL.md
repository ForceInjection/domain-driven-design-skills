---
name: bootstrap-node
description: Bootstrap a new node for Kubernetes without joining it to the cluster. Use when preparing nodes in advance, testing setup, or staging hardware.
---

# Bootstrap a New Node

Prepare a node for Kubernetes cluster membership without actually joining it.

Useful when:
- Preparing multiple nodes before adding them
- Testing the bootstrap process
- Setting up nodes that will be added later

## Instructions

### Step 1: Verify Tailscale Connectivity

```bash
tailscale status | grep -i <node_name>
```

Get the Tailscale IP address.

### Step 2: Ensure Node in Inventory

Check `ansible/inventory/hosts.yml`, add if missing:

```yaml
workers:
  hosts:
    <node_name>:
      ansible_host: <tailscale_ip>
      tailscale_ip: <tailscale_ip>
      reserved_cpu: "2"
      reserved_memory: "4Gi"
      node_labels:
        node-role: worker
        workstation: "true"

bootstrap:
  hosts:
    <node_name>: {}
```

### Step 3: Setup SSH Access

```bash
ssh -o BatchMode=yes -o ConnectTimeout=5 <tailscale_ip> echo "SSH OK" 2>/dev/null
```

If fails: `ssh-copy-id <user>@<tailscale_ip>`

### Step 4: Run Bootstrap Playbook

```bash
cd /home/al/git/kubani
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/bootstrap_node.yml --limit <node_name>
```

### Step 5: Validate

```bash
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/preflight_checks.yml --limit <node_name>
```

## What Bootstrap Does

- Updates system packages
- Installs: curl, git, vim, htop, jq, iptables, conntrack
- Configures Tailscale
- Sets up SSH key authentication
- Hardens SSH (disables password auth, root login)
- Configures passwordless sudo
- Sets hostname and timezone
- Enables IP forwarding and bridge netfilter
- Loads kernel modules (br_netfilter, overlay)
- Disables swap
- Configures UFW firewall

## Next Steps

Add to cluster with:
```bash
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/add_node.yml --limit "<node_name>,sparky"
```

Or use the add-node skill.
