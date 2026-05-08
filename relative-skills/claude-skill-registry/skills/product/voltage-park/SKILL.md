---
name: voltage-park
description: Provision and manage Voltage Park H100 GPU instances. Use when the user needs to spin up H100s, SSH into VP instances, transfer files, or terminate cloud GPU instances.
---

# Voltage Park H100 Management

## Permissions
- NEVER provision without explicit permission
- ASK before spinning up H100s when blocked on GPU tasks
- Do NOT auto-terminate - user may run multi-hour experiments

## API
Token: `$VP_API_TOKEN` in `~/.env_vars`
Base: `https://cloud-api.voltagepark.com/api/v1`

| Endpoint | Method | Path |
|----------|--------|------|
| Availability | GET | /virtual-machines/instant/locations |
| Provision | POST | /virtual-machines/instant |
| List | GET | /virtual-machines/ |
| Terminate | DELETE | /virtual-machines/{id} |
| Power | PUT | /virtual-machines/{id}/power-status |
| Ports | POST | /virtual-machines/{id}/port-forward |

Provision body: `{"config_id":"X","location_id":"X","organization_ssh_keys":{"mode":"selective","ssh_key_ids":["X"]},"name":"X"}`

## Defaults
- SSH user: `user`
- Location: `a3111bd4-550a-47d0-838a-0a52bff2ae3f`
- OS: TensorML 24 Everything
- CUDA: `/usr/local/cuda-12.6/bin`

### SSH Keys (auto-select by hostname)
| Host | ID |
|------|-----|
| macbook-pro | `4419ce92-a31a-40a2-b1da-73de608252ad` |
| theodolos | `fb384362-d726-4498-b9aa-d636d660f930` |

### Presets
| GPUs | ID |
|------|-----|
| 1x H100 | `c6fd6253-cbb6-4ea8-a20c-47644b431f1c` |
| 2x H100 | `928dc7be-5236-49a7-9d7d-c01ba6d783f5` |
| 4x H100 | `2470d2d9-347a-4186-884d-bd0350ace4e3` |
| 8x H100 | `404645e3-4677-4f48-b023-15baaa6621e1` |

## SSH
```bash
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_ed25519 -p <PORT> user@<IP>
```

## Setup (fresh instance)
```bash
source /opt/anaconda3/etc/profile.d/conda.sh && conda activate base
curl -LsSf https://astral.sh/uv/install.sh | sh && source $HOME/.local/bin/env
```
Available: nvcc, conda, PyTorch 2.5.1, git. Missing: cmake, pip3, uv.

## File Transfer
```bash
scp -P <PORT> -i ~/.ssh/id_ed25519 <LOCAL> user@<IP>:<REMOTE>
rsync -avz --progress -e "ssh -i ~/.ssh/id_ed25519 -p <PORT>" <SRC> <DST>
```

## Data Persistence
WARNING: Instances are EPHEMERAL - download results before terminating. Stopping preserves data but costs storage.
