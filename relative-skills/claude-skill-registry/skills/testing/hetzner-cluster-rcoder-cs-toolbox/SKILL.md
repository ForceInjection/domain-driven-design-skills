---
name: hetzner-cluster
description: Toolkit for creating and managing server clusters on Hetzner Cloud using Terraform. Use this skill when users request deploying VMs, creating test infrastructure, or setting up server clusters on Hetzner Cloud. The skill provides Terraform templates optimized for network testing with strict firewall rules, public and private network interfaces, and support for ZeroTier VPN.
---

# Hetzner Cluster

## Overview

Create and manage VM clusters on Hetzner Cloud using Terraform templates optimized for hands-on testing and network experimentation. The skill provides pre-configured Terraform templates with secure networking (public + private interfaces), strict firewall rules (SSH, HTTPS, ZeroTier), automatic ZeroTier network creation and node provisioning, and support for multiple datacenters. Each cluster automatically creates its own isolated ZeroTier network with unique subnets to avoid conflicts between deployments.

## When to Use This Skill

Use this skill when users request:
- Creating server clusters on Hetzner Cloud
- Deploying VMs for testing or development
- Setting up infrastructure for network testing
- Provisioning servers with specific network configurations
- Creating cost-effective cloud infrastructure
- Setting up ZeroTier demo environments or test networks
- Creating isolated overlay networks for product demonstrations

## Quick Start

To deploy a cluster with automatic ZeroTier network setup:

1. **Set up environment variables**: Copy `envrc.example` to `.envrc` and add your API tokens:
   ```bash
   cp envrc.example .envrc
   # Edit .envrc with your tokens:
   # - Hetzner Cloud API token (from https://console.hetzner.cloud/)
   # - ZeroTier Central API token (from https://my.zerotier.com/account)
   direnv allow  # Load the environment variables
   ```
2. **Create a cluster directory**: `mkdir -p clusters/<cluster-name>` (e.g., `clusters/demo-cluster`)
3. **Copy the Terraform template** from `assets/terraform-hetzner-cluster/` to the cluster directory
4. **Configure SSH key path** (defaults to `~/.ssh/id_ed25519`)
5. **Create configuration** either manually or using `scripts/deploy_cluster.sh`
6. **Deploy** with `terraform init`, `terraform plan`, and `terraform apply`

The deployment automatically:
- Creates a ZeroTier network with unique subnet (10.X.0.0/24)
- Installs ZeroTier on all nodes
- Joins nodes to the network and authorizes them
- Provides network ID and member IPs in outputs

## Core Capabilities

### 1. Cluster Configuration

The Terraform templates support flexible cluster configurations:

**Server Types (CCX Line):**
- `ccx13`: 2 vCPU, 8GB RAM, 80GB NVMe (~$8.90/month)
- `ccx23`: 4 vCPU, 16GB RAM, 160GB NVMe (~$17.80/month)
- `ccx33`: 8 vCPU, 32GB RAM, 240GB NVMe (~$35.60/month)

**Datacenters:**
- `hillsboro`: Hillsboro, OR, USA (hil-dc1) - Default
- `singapore`: Singapore (sin-dc1)
- `germany`: Falkenstein, Germany (fsn1-dc14)

**Node Count:**
- Default: 3 nodes
- Range: 1-10 nodes
- Customizable per deployment

**Example Configuration:**
```hcl
cluster_name   = "test-cluster"
node_count     = 3
server_type    = "ccx13"
datacenter     = "hillsboro"
```

### 2. Network Architecture

Each cluster includes:

**Public Interface:**
- Public IPv4 address per node
- IPv6 /64 subnet
- Protected by strict firewall rules

**Private Network:**
- 10.0.0.0/16 private network range
- 10.0.1.0/24 subnet for cluster nodes
- Static IP assignment (10.0.1.10, 10.0.1.11, etc.)
- Unrestricted inter-node communication

**Firewall Rules:**
- **Inbound (public)**: SSH (22), HTTPS (443), ZeroTier (9993/UDP)
- **Inbound (private)**: All TCP, UDP, and ICMP from 10.0.0.0/16
- **Outbound**: All traffic allowed

Refer to `references/network-config.md` for detailed network specifications.

### 3. ZeroTier Network Automation

Each cluster deployment automatically creates and configures a ZeroTier software-defined network:

**Automatic Network Creation:**
- Creates a private ZeroTier network on ZeroTier Central
- Assigns unique random subnet (10.X.0.0/24) to avoid conflicts between deployments
- Configures IP assignment pool (10.X.0.1 - 10.X.0.254)
- Sets up routing for the allocated subnet

**Automatic Node Provisioning:**
- Installs ZeroTier One client on each cluster node
- Waits for ZeroTier service to start and generate node identity
- Joins each node to the newly created network
- Authorizes all nodes automatically
- Retrieves and stores ZeroTier node IDs for reference

**Network Isolation:**
- Each cluster gets its own isolated ZeroTier network
- Random subnet allocation prevents IP conflicts when joining multiple clusters
- Private network mode ensures only authorized members can join

**Integration Benefits:**
- Nodes can communicate via ZeroTier IPs regardless of physical location
- Enables multi-region cluster connectivity
- Allows external devices to join the network for testing
- Provides encrypted overlay network for secure communication

**Example Outputs:**
```
zerotier_network_id     = "1c33c1ced02a5a44"
zerotier_network_subnet = "10.147.0.0/24"
zerotier_node_ids = {
  "happy-turtle-01" = "a1b2c3d4e5"
  "happy-turtle-02" = "f6g7h8i9j0"
  "happy-turtle-03" = "k1l2m3n4o5"
}
zerotier_member_ips = {
  "happy-turtle-01" = ["10.147.0.1"]
  "happy-turtle-02" = ["10.147.0.2"]
  "happy-turtle-03" = ["10.147.0.3"]
}
```

### 4. Deployment Methods

**Method A: Using the Helper Script (Recommended)**

The `scripts/deploy_cluster.sh` script automates the entire deployment process:

```bash
# Set required API tokens
export HCLOUD_TOKEN='your-hetzner-api-token'
export ZEROTIER_API_TOKEN='your-zerotier-api-token'

# Optional: Set SSH key path (defaults to ~/.ssh/id_ed25519)
export SSH_KEY_PATH="$HOME/.ssh/id_ed25519"

# Create cluster directory and copy script
mkdir -p clusters/my-cluster
cd clusters/my-cluster
cp ../../scripts/deploy_cluster.sh .
chmod +x deploy_cluster.sh

# Deploy with defaults (3 nodes, ccx13, hillsboro)
./deploy_cluster.sh

# Or deploy with custom configuration
./deploy_cluster.sh 5 ccx23 singapore
```

The script will:
1. Verify API tokens are set
2. Verify SSH key pair exists
3. Generate `terraform.tfvars` with all configuration
4. Initialize Terraform
5. Show plan and prompt for confirmation
6. Deploy cluster with ZeroTier network
7. Display connection and ZeroTier network information

**Method B: Manual Deployment**

For more control or customization:

1. **Create cluster directory and copy templates:**
   ```bash
   mkdir -p clusters/<cluster-name>
   cp -r assets/terraform-hetzner-cluster/* clusters/<cluster-name>/
   cd clusters/<cluster-name>
   ```

2. **Create terraform.tfvars:**
   ```hcl
   hcloud_token         = "your-hetzner-api-token"
   zerotier_api_token   = "your-zerotier-api-token"
   cluster_name         = ""  # Leave empty for random name
   node_count           = 3
   server_type          = "ccx13"
   datacenter           = "hillsboro"
   ssh_private_key_path = "~/.ssh/id_ed25519"
   ```

3. **Deploy:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **View outputs including ZeroTier network info:**
   ```bash
   terraform output
   terraform output zerotier_network_id
   terraform output zerotier_member_ips
   ```

### 5. Accessing Cluster Nodes

After deployment, Terraform outputs provide connection details for both direct SSH and ZeroTier access:

**View all outputs:**
```bash
terraform output
```

**Get SSH commands:**
```bash
terraform output -json ssh_commands | jq -r '.[]'
```

**Example output:**
```
ssh root@<public-ip-1>
ssh root@<public-ip-2>
ssh root@<public-ip-3>
```

**View IP addresses:**
```bash
# Public IPs
terraform output public_ips

# Private IPs (Hetzner private network)
terraform output private_ips

# ZeroTier IPs
terraform output zerotier_member_ips
```

**ZeroTier Network Access:**
```bash
# Get ZeroTier network ID
terraform output zerotier_network_id

# Get join command for other devices
terraform output -raw zerotier_join_command

# View ZeroTier node IDs
terraform output zerotier_node_ids
```

**Example: SSH via ZeroTier IP:**
```bash
# After nodes are authorized and have ZeroTier IPs
ssh root@10.147.0.1  # Replace with actual ZeroTier IP from output
```

### 6. Cluster Management

**View cluster status:**
```bash
terraform show
```

**Modify cluster:**
1. Edit `terraform.tfvars` (e.g., change node_count)
2. Run `terraform plan` to preview changes
3. Run `terraform apply` to apply changes

**Destroy cluster:**
```bash
terraform destroy
```

**Note:**
- Always destroy test clusters when done to avoid unnecessary costs
- Destroying the cluster also deletes the ZeroTier network and removes all members
- ZeroTier node IDs are permanently removed from ZeroTier Central

## Common Workflows

### Workflow 1: Create a Basic Test Cluster with ZeroTier

User request: *"Create a 3-node test cluster on Hetzner with ZeroTier networking"*

1. Set up environment: Copy `envrc.example` to `.envrc` and add API tokens
2. Create cluster directory: `mkdir -p clusters/demo-cluster`
3. Copy Terraform templates to cluster directory
4. Use `scripts/deploy_cluster.sh` with defaults or create `terraform.tfvars` manually
5. Deploy with `terraform apply`
6. Provide outputs including:
   - SSH commands for direct access
   - ZeroTier network ID
   - ZeroTier member IPs
   - Join command for additional devices

### Workflow 2: Create a Multi-Region Cluster

User request: *"Set up clusters in both Singapore and Germany for latency testing"*

1. Create two separate directories (e.g., `clusters/singapore/`, `clusters/germany/`)
2. Copy Terraform templates to each directory
3. Configure each with appropriate datacenter:
   - `clusters/singapore/terraform.tfvars`: `datacenter = "singapore"`
   - `clusters/germany/terraform.tfvars`: `datacenter = "germany"`
4. Deploy each cluster independently
5. Provide connection details for both clusters

### Workflow 3: Create a Larger Cluster with More Resources

User request: *"I need a 5-node cluster with more powerful servers for performance testing"*

1. Create cluster directory: `mkdir -p clusters/performance-test`
2. Copy Terraform templates to cluster directory
3. Configure with increased resources:
   ```hcl
   node_count  = 5
   server_type = "ccx23"  # 4 vCPU, 16GB RAM
   ```
4. Deploy and provide connection details

### Workflow 4: Join External Device to Cluster ZeroTier Network

User request: *"I want to join my laptop to the cluster's ZeroTier network for testing"*

1. Deploy cluster using standard workflow
2. Get ZeroTier network ID from outputs:
   ```bash
   terraform output -raw zerotier_network_id
   ```
3. On the external device (laptop, workstation, etc.):
   - Install ZeroTier: `curl -s https://install.zerotier.com | bash`
   - Join the network: `zerotier-cli join <network-id>`
4. Authorize the new member on ZeroTier Central:
   - Go to https://my.zerotier.com
   - Find the network
   - Authorize the new member
5. User can now access cluster nodes via their ZeroTier IPs
6. Test connectivity: `ping 10.X.0.1` (use actual ZeroTier IP from outputs)

## Reference Material

Detailed specifications and documentation are available in the `references/` directory:

- **`references/hetzner-specs.md`**: Complete server type specifications, datacenter details, and pricing information
- **`references/network-config.md`**: Detailed network architecture, firewall rules, and connectivity options

Load these references when users need detailed information about:
- Server type selection and specifications
- Datacenter locations and network zones
- Network configuration details
- Firewall rule explanations

## Troubleshooting

**SSH key pair not found:**
- Ensure both `~/.ssh/id_ed25519` and `~/.ssh/id_ed25519.pub` exist
- Generate new key pair: `ssh-keygen -t ed25519 -C "user@example.com"`
- Or set custom path: `export SSH_KEY_PATH="/path/to/key"`

**HCLOUD_TOKEN not set:**
- Get token from https://console.hetzner.cloud/
- Export as environment variable: `export HCLOUD_TOKEN='your-token'`

**ZEROTIER_API_TOKEN not set:**
- Get token from https://my.zerotier.com/account
- Export as environment variable: `export ZEROTIER_API_TOKEN='your-token'`
- Ensure token has permission to create networks

**ZeroTier installation fails:**
- Check internet connectivity from Hetzner servers
- Verify firewall allows outbound HTTPS (443)
- Check ZeroTier install script is accessible: `curl -I https://install.zerotier.com`

**ZeroTier nodes not joining network:**
- Wait 30-60 seconds for service to fully start
- Check ZeroTier service status: `ssh root@<ip> 'systemctl status zerotier-one'`
- Verify node joined: `ssh root@<ip> 'zerotier-cli listnetworks'`

**ZeroTier members not authorized:**
- Terraform should auto-authorize, but check ZeroTier Central
- Go to https://my.zerotier.com and verify members are authorized
- Check terraform state: `terraform show | grep zerotier_member`

**Terraform errors:**
- Ensure Terraform >= 1.0 is installed
- Run `terraform init` in the correct directory
- Check both API tokens have appropriate permissions

**Invalid datacenter/location:**
- Use only supported datacenters: hillsboro, singapore, germany
- Location codes are auto-derived from datacenter selection

**Network zone mismatch:**
- Private networks must be in the same network zone
- Don't mix servers from different zones in one cluster

**Provisioner connection failures:**
- Ensure SSH private key path is correct
- Check SSH private key has proper permissions (chmod 600)
- Verify public key was uploaded to Hetzner
- Wait a few seconds after server creation before provisioning

## Resources

### scripts/
- `get_ssh_key.py`: Finds and returns SSH public key from ~/.ssh/ (legacy, now optional)
- `deploy_cluster.sh`: Complete deployment automation script with ZeroTier integration, API token verification, and interactive prompts

### references/
- `hetzner-specs.md`: Server specifications, datacenter locations, and pricing
- `network-config.md`: Network architecture, firewall rules, and ZeroTier connectivity details

### assets/
- `terraform-hetzner-cluster/`: Complete Terraform templates ready for deployment
  - `main.tf`: Core infrastructure (servers, networks, firewalls, ZeroTier network, provisioners)
  - `variables.tf`: Input variables with validation and defaults (includes ZeroTier API token)
  - `outputs.tf`: Connection information, cluster details, and ZeroTier network info
  - `versions.tf`: Terraform and provider version requirements (Hetzner, Random, ZeroTier)
  - `terraform.tfvars.example`: Example configuration file with all required variables
