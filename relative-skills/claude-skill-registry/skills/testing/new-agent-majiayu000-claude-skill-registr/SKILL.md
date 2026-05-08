---
name: new-agent
description: Create a new AI agent from template. Use when adding a new agent to the cluster, starting a new monitoring or automation project.
---

# Create New AI Agent

Scaffold a new AI agent using the established patterns.

## Arguments

- `agent-name`: Name for the new agent (lowercase, hyphenated)

## Instructions

### 1. Create Directory Structure

```bash
cd /home/al/git/kubani
AGENT_NAME="my-agent"

mkdir -p agents/${AGENT_NAME}/{src/${AGENT_NAME//-/_},tests}
```

### 2. Create pyproject.toml

```toml
[project]
name = "${AGENT_NAME}"
version = "0.1.0"
description = "Description of what this agent does"
readme = "README.md"
requires-python = ">=3.11"
dependencies = [
    "strands-agents>=1.20.0",
    "temporalio>=1.7.0",
    "httpx>=0.27.0",
    "pydantic>=2.5.0",
    "openai>=1.0.0",
    "core-agents",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4.0",
    "pytest-asyncio>=0.23.0",
    "ruff>=0.8.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["src/${AGENT_NAME//-/_}"]

[tool.uv.sources]
core-agents = { path = "../core", editable = true }
```

### 3. Create Earthfile

```dockerfile
VERSION 0.8

FROM python:3.11-slim
WORKDIR /app

# Copy and install dependencies
COPY pyproject.toml .
RUN pip install uv && uv pip install --system .

# Copy source
COPY src/ src/

docker:
    ARG VERSION=latest
    ENTRYPOINT ["python", "-m", "${AGENT_NAME//-/_}.worker"]
    SAVE IMAGE registry.almckay.io/${AGENT_NAME}:$VERSION
```

### 4. Create Worker

Create `src/${AGENT_NAME//-/_}/worker.py` with:
- Temporal worker setup
- Activity definitions
- Workflow definitions

### 5. Create GitOps Manifests

```bash
mkdir -p gitops/apps/ai-agents/${AGENT_NAME}
```

Create:
- `deployment.yaml`
- `service.yaml` (if needed)
- `kustomization.yaml`

### 6. Register with Flux

Add to `gitops/apps/ai-agents/kustomization.yaml`:
```yaml
resources:
  - ${AGENT_NAME}
```

## Template Files

Reference the k8s-monitor agent for:
- Worker structure: `agents/k8s-monitor/src/k8s_monitor/worker.py`
- Workflows: `agents/k8s-monitor/src/k8s_monitor/workflows.py`
- Deployment: `gitops/apps/ai-agents/k8s-monitor/deployment.yaml`

## Post-Creation

1. Build: `/build ${AGENT_NAME} push`
2. Deploy: Apply GitOps manifests
3. Verify: Check pods and logs
