---
name: agents
description: List all AI agents with versions and deployment status. Use when checking agent health, versions, or deployment state.
---

# List Agents

Show all available agents, their versions, and deployment status.

## Arguments

- `agent-name`: Optional specific agent name for detailed info

## Instructions

### List All Agents

```bash
cd /home/al/git/kubani
echo "=== AI Agents ==="
echo ""

for earthfile in agents/*/Earthfile; do
    agent_dir=$(dirname "$earthfile")
    agent_name=$(basename "$agent_dir")
    [ "$agent_name" = "core" ] && continue

    # Get version from pyproject.toml
    version=$(grep '^version = ' "$agent_dir/pyproject.toml" | sed 's/version = "\(.*\)"/\1/')

    # Get deployed image
    deployed=$(KUBECONFIG=/home/al/.kube/config kubectl get deploy $agent_name -n ai-agents -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || echo "not deployed")

    # Get pod status
    status=$(KUBECONFIG=/home/al/.kube/config kubectl get pods -n ai-agents -l app.kubernetes.io/name=$agent_name -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "unknown")

    echo "$agent_name"
    echo "  Source version: $version"
    echo "  Deployed image: $deployed"
    echo "  Pod status: $status"
    echo ""
done
```

### Detailed Agent Info

For a specific agent, also show:

```bash
AGENT_NAME="k8s-monitor"

# Pod details
KUBECONFIG=/home/al/.kube/config kubectl get pods -n ai-agents -l app.kubernetes.io/name=$AGENT_NAME -o wide

# Recent logs
KUBECONFIG=/home/al/.kube/config kubectl logs -n ai-agents -l app.kubernetes.io/name=$AGENT_NAME --tail=20

# Recent deployment history
git log --oneline -5 gitops/apps/ai-agents/$AGENT_NAME/deployment.yaml
```

## Core Library

The `core-agents` library is shared by all agents:

```bash
version=$(grep '^version = ' agents/core/pyproject.toml | sed 's/version = "\(.*\)"/\1/')
echo "core-agents (library): v$version"
```
