---
name: basilica-miner
description: This skill should be used when setting up, managing, or troubleshooting Basilica GPU miner operations on Bittensor Subnet 39 (mainnet) or 387 (testnet). Use it for GPU provider tasks including SSH configuration, validator authentication setup, node registration, performance monitoring, uptime optimization, and resolving common issues like SSH access problems, validator discovery failures, or GPU validation errors. Critical for miners struggling with SSH key deployment to GPU nodes or validator connectivity.
---

# Basilica Miner Skill

## Overview

Set up and operate Basilica GPU mining nodes to earn rewards by providing compute resources on the Bittensor decentralized GPU marketplace (Subnet 39 mainnet, 387 testnet). This skill provides expert guidance for GPU providers on miner setup, SSH configuration, validator interaction, monitoring, and troubleshooting.

**Key Innovation**: Basilica uses SSH-based direct access where validators SSH directly to GPU nodes for verification, eliminating intermediary trust requirements while maintaining security through cryptographic verification.

## Core Capabilities

### 1. MINER SETUP WORKFLOW

**Prerequisites Check** before starting:
- Linux server (Ubuntu 22.04+ recommended): 8+ CPU cores, 16GB+ RAM
- GPU nodes with NVIDIA drivers (H100/H200/A100), CUDA ≥12.8, Docker + NVIDIA Container Toolkit
- Bittensor wallet registered to subnet 39 (mainnet) or 387 (testnet)
- Public IP or port forwarding for miner server
- SSH access from miner server to all GPU nodes

**Quick Start (6-Phase Setup)**:

1. **Generate SSH Keys**
   ```bash
   ./scripts/setup_ssh_keys.sh
   ```
   - Creates miner SSH key pair
   - Deploys to all GPU nodes
   - Verifies connectivity and GPU access

2. **Generate Configuration**
   ```bash
   ./scripts/generate_config.sh miner.toml
   ```
   - Interactive configuration wizard
   - Collects network, wallet, and node details
   - Creates production-ready miner.toml

3. **Verify Setup**
   ```bash
   python scripts/check_miner_health.py --config miner.toml
   ```
   - Comprehensive health checks
   - Validates SSH connectivity
   - Tests GPU availability
   - Checks wallet registration

4. **Build Miner**
   ```bash
   git clone https://github.com/one-covenant/basilica
   cd basilica
   ./scripts/miner/build.sh --release
   ```

5. **Deploy**
   ```bash
   sudo mkdir -p /opt/basilica/{config,data}
   sudo cp basilica-miner /opt/basilica/
   sudo cp miner.toml /opt/basilica/config/
   ```

6. **Start Miner**
   ```bash
   # Create systemd service
   sudo tee /etc/systemd/system/basilica-miner.service > /dev/null << 'EOF'
   [Unit]
   Description=Basilica Miner
   After=network-online.target

   [Service]
   Type=simple
   User=root
   WorkingDirectory=/opt/basilica
   ExecStart=/opt/basilica/basilica-miner --config /opt/basilica/config/miner.toml
   Restart=always
   RestartSec=10

   [Install]
   WantedBy=multi-user.target
   EOF

   # Enable and start
   sudo systemctl daemon-reload
   sudo systemctl enable basilica-miner
   sudo systemctl start basilica-miner

   # Monitor
   sudo journalctl -u basilica-miner -f
   ```

### 2. SSH CONFIGURATION (CRITICAL FOR SUCCESS)

**The #1 Issue**: Miners struggling to set up SSH access properly for validators to reach GPU nodes.

**SSH Architecture**:
```
Miner Server ──(miner_node_key)──> GPU Nodes
Validator ────(ephemeral key)────> GPU Nodes (deployed by miner)
```

**Step-by-Step SSH Setup**:

1. **Generate Miner's SSH Key**
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/miner_node_key -C "basilica-miner" -N ""
   chmod 600 ~/.ssh/miner_node_key
   chmod 644 ~/.ssh/miner_node_key.pub
   ```

2. **Create Dedicated User on Each GPU Node**
   ```bash
   # On each GPU node
   sudo useradd -m -s /bin/bash basilica
   sudo usermod -aG docker basilica
   sudo mkdir -p /home/basilica/.ssh
   sudo chmod 700 /home/basilica/.ssh
   sudo chown -R basilica:basilica /home/basilica/.ssh
   ```

3. **Deploy Miner's Public Key to Nodes**
   ```bash
   # Automated
   ssh-copy-id -i ~/.ssh/miner_node_key.pub basilica@node_ip

   # Or use the setup script
   ./scripts/setup_ssh_keys.sh --nodes "basilica@node1 basilica@node2"
   ```

4. **Verify Connectivity**
   ```bash
   ssh -i ~/.ssh/miner_node_key basilica@node_ip "nvidia-smi"
   ```

5. **Harden SSH on GPU Nodes** (`/etc/ssh/sshd_config`):
   ```
   PermitRootLogin no
   PasswordAuthentication no
   PubkeyAuthentication yes
   MaxStartups 30:30:100
   MaxSessions 100
   ```

6. **Configure miner.toml**:
   ```toml
   [ssh_session]
   miner_node_key_path = "~/.ssh/miner_node_key"

   [node_management]
   nodes = [
     { host = "192.168.1.100", port = 22, username = "basilica" },
     { host = "192.168.1.101", port = 22, username = "basilica" },
   ]
   ```

**How Validator Access Works**:
1. Validator sends gRPC authentication request with SSH public key
2. Miner verifies validator signature (Bittensor hotkey)
3. Miner deploys validator's SSH key to all nodes (tagged as `validator-{hotkey}`)
4. Validator SSH's directly to nodes for GPU verification
5. Miner removes validator's key after session expiry (default: 1 hour)

**Common SSH Issues** → See [Troubleshooting](#6-troubleshooting-common-issues) section

### 3. VALIDATOR INTERACTION & AUTHENTICATION

**How Validators Discover and Verify Miners**:

1. **Discovery** (Every 10 minutes)
   - Validator queries Bittensor metagraph for subnet miners
   - Extracts miner endpoints (axon IP:port)

2. **Authentication** (gRPC)
   - Validator sends: hotkey + signature + SSH public key + nonce
   - Miner verifies: signature matches validator hotkey, timestamp fresh (<5 min), target miner hotkey correct

3. **SSH Key Deployment**
   - Miner validates SSH key format
   - Tags key with `validator-{hotkey}`
   - Deploys to all configured nodes via SSH

4. **Node Discovery**
   - Validator requests node connection details
   - Miner responds with: node IDs, hostnames, ports, usernames, status

5. **Direct Verification** (Two-tier strategy)
   - **Full** (every 6 hours): Execute GPU attestation binary, verify hardware
   - **Lightweight** (every 10 min): SSH connectivity test only

6. **Cleanup**
   - Miner removes validator's SSH key after session expires

**Validator Assignment Strategies**:

**Highest Stake (Recommended)**:
```toml
[validator_assignment]
enabled = true
strategy = "highest_stake"
min_stake_threshold = 12000.0  # TAO
validator_hotkey = "5G3qVaXz..."  # Optional: pin to specific validator
```
- Most secure (single trusted validator)
- Simplest operations
- Best for production

**Open Access (Testing Only)**:
```toml
[validator_assignment]
enabled = false
```
- Any validator can access
- Higher security risk
- Only for testnet/debugging

### 4. SCORING & REWARDS

**Node Scoring Formula**:
```
Node Score = (50% × SSH Success Rate) + (50% × Binary Validation Result)
Miner Score = Average(all node scores)
```

**Uptime Ramp-Up System (14-Day Model)**:
- New nodes start at 0% reward multiplier
- Linear increase to 100% over 14 days of continuous uptime
- **Any validation failure resets counter to 0**
- Effective GPU count = actual count × uptime multiplier

**GPU Requirements for Rewards**:
- **Eligible**: H100, H200, B200
- **Ineligible**: A100, V100, RTX series (still validated, no rewards)
- **Minimum CUDA Capability**: ≥8.7
- **Minimum CUDA Version**: ≥12.8

**Target Metrics for Top Miners**:
- SSH Success Rate: >95%
- Binary Validation Pass Rate: 100%
- Uptime: 99.9% (minimize resets)
- Response Time: <5s for SSH connections
- Node Count: More nodes → more rewards

**Weight Distribution**:
- Weights set every 360 blocks (~1 hour)
- Based on: GPU category, validation success, effective GPU count
- Burn percentage: 80%+ sent to burn address

### 5. MONITORING & MAINTENANCE

**Built-in Health Checks**:

```bash
# Miner health endpoint
curl http://localhost:8080/health

# Prometheus metrics
curl http://localhost:9090/metrics

# Key metrics to watch:
# - basilica_miner_node_count (should match configured nodes)
# - basilica_miner_validator_connections_total (growing)
# - basilica_miner_ssh_deployments_total (growing)
# - basilica_miner_authentication_success_total (high rate)
```

**Automated Health Monitoring**:
```bash
# Use the health check script regularly
python scripts/check_miner_health.py --config /opt/basilica/config/miner.toml

# Schedule with cron for alerts
*/15 * * * * python /path/to/check_miner_health.py --config /opt/basilica/config/miner.toml || mail -s "Miner Health Alert" admin@example.com
```

**Manual Node Testing**:
```bash
# Test all nodes
for node in node1 node2 node3; do
  echo "Testing $node..."
  ssh -i ~/.ssh/miner_node_key basilica@$node << 'EOF'
    echo "=== GPU Status ==="
    nvidia-smi --query-gpu=index,name,driver_version --format=csv
    echo "=== Docker GPU ==="
    docker run --rm --gpus all nvidia/cuda:12.8.0-base-ubuntu24.04 nvidia-smi
    echo "=== Storage ==="
    df -h / | tail -1
EOF
done
```

**Log Monitoring**:
```bash
# Watch for key events
sudo journalctl -u basilica-miner -f | grep -E "(authenticated|deployed|ERROR|WARN)"

# Important patterns to monitor:
# - "Successfully authenticated validator"
# - "Deployed SSH key to node"
# - "Node connectivity lost"
# - "ERROR" / "WARN"
```

**Critical Alert Thresholds**:
| Metric | Alert If | Impact |
|--------|----------|--------|
| SSH Success Rate | <90% | Score penalty, potential uptime reset |
| Validator Auth Rate | <90% | Not being discovered properly |
| Node Health Check | Any failing >1 hour | Node offline, losing rewards |
| Last Validator Seen | >6 hours | Not attracting validators |

### 6. TROUBLESHOOTING COMMON ISSUES

**Issue: SSH Permission Denied**

Symptoms:
```
Error: Failed to connect to node: Permission denied (publickey)
```

Solutions:
```bash
# 1. Verify miner's public key is deployed
ssh basilica@node_ip "cat ~/.ssh/authorized_keys | grep miner_node_key"

# 2. Deploy if missing
ssh-copy-id -i ~/.ssh/miner_node_key.pub basilica@node_ip

# 3. Check key permissions (must be 600)
ls -la ~/.ssh/miner_node_key  # Should show: -rw-------

# 4. Fix permissions
chmod 600 ~/.ssh/miner_node_key
chmod 644 ~/.ssh/miner_node_key.pub

# 5. Test connection with verbose output
ssh -i ~/.ssh/miner_node_key -v basilica@node_ip
```

**Issue: Validator Authentication Failed**

Symptoms:
```
ERROR: Validator authentication failed: Invalid signature
WARN: No validators discovered
```

Solutions:
```bash
# 1. Check system clock is synchronized (critical!)
timedatectl
# Should show: "System clock synchronized: yes"

# 2. Sync time if needed
sudo timedatectl set-ntp true
sudo systemctl restart systemd-timesyncd

# 3. Verify wallet registration
btcli wallet overview --wallet.name ${WALLET_NAME} --wallet.hotkey ${HOTKEY_NAME} --netuid 39

# 4. Check validator assignment config
grep -A 5 "validator_assignment" /opt/basilica/config/miner.toml

# 5. Lower stake threshold for testing
# [validator_assignment]
# min_stake_threshold = 1000.0
```

**Issue: GPU Validation Failing**

Symptoms:
```
Binary validation failed
CUDA version check failed
Docker GPU access denied
```

Solutions:
```bash
# 1. Verify CUDA version (must be ≥12.8)
ssh basilica@node "nvcc --version"

# 2. Test Docker GPU access
ssh basilica@node "docker run --rm --gpus all nvidia/cuda:12.8.0-base-ubuntu24.04 nvidia-smi"

# 3. Install NVIDIA Container Toolkit if failed
ssh basilica@node << 'EOF'
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
EOF

# 4. Verify compute capability (must be ≥8.7)
ssh basilica@node "nvidia-smi --query-gpu=compute_cap --format=csv,noheader"
```

For more troubleshooting scenarios and detailed solutions, see `references/troubleshooting_guide.md`.

### 7. MAINTENANCE & BEST PRACTICES

**Uptime Optimization** (Critical for 14-day ramp-up):
- Use systemd with auto-restart enabled
- Monitor node health every 60 seconds (default)
- Set up alerts for node failures
- Plan maintenance during low-traffic periods
- Test updates on testnet first

**Security Checklist**:
- [ ] SSH keys have 600 permissions (private) and 644 (public)
- [ ] Password authentication disabled on GPU nodes
- [ ] Firewall configured (only miner can SSH to nodes)
- [ ] Validator signature verification enabled (production)
- [ ] System clock synchronized (NTP)
- [ ] Regular security updates on all systems
- [ ] Audit logs monitored for unusual SSH activity

**Scaling Strategy**:
1. Start with 1-2 nodes to verify setup
2. Monitor validation success and uptime
3. Add nodes incrementally after stable operation
4. Each node increases potential rewards
5. Maintain >95% uptime across all nodes

**Configuration Management**:
```bash
# Backup configuration
cp /opt/basilica/config/miner.toml /opt/basilica/config/miner.toml.backup.$(date +%s)

# Version control recommended
cd /opt/basilica/config
git init
git add miner.toml
git commit -m "Initial miner configuration"

# Test configuration before deploying
./basilica-miner --config miner.toml config validate
```

## Resources

### Scripts

All scripts located in `scripts/` directory:

- **check_miner_health.py**: Comprehensive health check (system, SSH, nodes, wallet, service)
  - Verifies environment and system requirements
  - Tests SSH connectivity to all GPU nodes
  - Validates GPU availability and driver versions
  - Checks Bittensor wallet registration
  - Monitors miner service status

- **setup_ssh_keys.sh**: Automated SSH key generation and deployment to GPU nodes
  - Generates Ed25519 SSH key pair
  - Deploys public key to all configured nodes
  - Verifies connectivity and GPU access
  - Provides configuration snippets for miner.toml

- **generate_config.sh**: Interactive configuration file generator
  - Guided prompts for network, wallet, and node details
  - Creates production-ready miner.toml
  - Validates inputs and provides recommendations

### References

Detailed documentation in `references/` directory:

- **basilica_architecture.md**: Complete system architecture, component interaction, direct SSH access model
- **troubleshooting_guide.md**: Comprehensive issue diagnosis and solutions with code references
- **scoring_system.md**: Detailed scoring formulas, uptime ramp-up, reward distribution

### External Resources

- **GitHub**: https://github.com/one-covenant/basilica
- **Miner Docs**: https://github.com/one-covenant/basilica/blob/main/docs/miner.md
- **Discord**: https://discord.gg/GyzhzRWJBQ
- **Basilica Website**: https://basilica.ai/
- **Covenant AI**: https://covenant.ai/ (Basilica's parent company)
- **Bittensor Docs**: https://docs.learnbittensor.org

## Task Execution Guidelines

When helping users with Basilica mining:

1. **Always check SSH setup first** - 90% of issues are SSH-related
   - Use `scripts/setup_ssh_keys.sh` for automated setup
   - Verify with `scripts/check_miner_health.py`

2. **Validate prerequisites** before deployment
   - Run health check script
   - Ensure wallet is registered
   - Confirm GPU eligibility (H100/H200/B200)

3. **Use scripts for reliability**
   - Don't manually write configs (use `generate_config.sh`)
   - Automate SSH deployment to avoid human error
   - Regular automated health checks

4. **Monitor key metrics** for optimization
   - SSH success rate >95%
   - Binary validation 100%
   - Validator authentication rate >90%
   - Uptime continuity (14-day ramp-up)

5. **Troubleshoot systematically**
   - Start with health check script output
   - Check logs: `sudo journalctl -u basilica-miner -f`
   - Test SSH manually if connectivity issues
   - Verify validator signatures and time sync

6. **Plan for uptime** (critical for rewards)
   - Minimize downtime (resets 14-day counter)
   - Test changes on testnet first
   - Use systemd auto-restart
   - Monitor and alert proactively

7. **Security first**
   - Never disable signature verification in production
   - Harden SSH on GPU nodes
   - Use validator assignment strategy
   - Regular security audits

## Code References

When referencing Basilica code, use the pattern `file_path:line_number`:

- Miner main: `crates/basilica-miner/src/main.rs:1-500`
- Validator comms: `crates/basilica-miner/src/validator_comms.rs:1-400`
- Node manager: `crates/basilica-miner/src/node_manager.rs:1-600`
- SSH session: `crates/basilica-miner/src/ssh.rs:1-300`
- Configuration: `crates/basilica-miner/src/config.rs:1-200`

See `references/basilica_architecture.md` for complete file structure and detailed line references.

The goal is to help GPU providers successfully set up and operate Basilica miners with high uptime, proper validation, and maximum rewards through systematic setup, proactive monitoring, and rapid troubleshooting.
