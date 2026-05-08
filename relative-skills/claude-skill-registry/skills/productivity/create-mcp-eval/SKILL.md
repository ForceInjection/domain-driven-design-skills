---
name: Create MCP Eval
description: Create or modify evaluations for MCP Server(s). Use whenever you are tasked with changed MCP evals.
---

# Create MCP Eval

## Instructions

Every eval is made up of an eval yaml that specifies which agent file to use, which mcp config file to use, which tasks to run,
and which MCP-specific assertions to check (if any).

### Creating evals from scratch

When creating a full eval from scratch, you will need to:

1. Create one or more tasks, see [tasks.md](tasks.md)
2. Create a mcp config file, see [mcpConfig.md](mcpConfig.md)
3. Create an agent file, see [agent.md](agent.md)
4. Create a top-level eval file that references the rest of the files, see [eval.yaml](eval.yaml)

However, in most cases you will not be creating an entirely new set of evals from scratch - you will just be modifying or
extending an existing eval. In this case, you will only need to modify some of these files.

### Running evals

To run the evals, use:

```bash
gevals run <path to eval yaml file>
```

The `gevals` binary may or may not be in the `$PATH`. If it is not in the path, ask the user where it is.

## Examples

### Create a full new set of evals

This example creates a full set of evals with a single task. The evals aim to test a kubernetes mcp server, and assume that:
1. There is a correctly configured kubernetes cluster that the user can access through their kubeconfig
2. There is a kubernetes mpc server running on `http://localhost:8080`

### Example Setup

**eval.yaml** - Main config:
```yaml
kind: Eval
metadata:
  name: "kubernetes-test"
config:
  agentFile: agent.yaml           # How to run your AI agent
  mcpConfigFile: mcp-config.yaml  # Your MCP server config
  taskSets:
    - path: tasks/create-pod.yaml
      assertions:
        toolsUsed:
          - server: kubernetes
            toolPattern: "pods_.*"  # Agent must use pod-related tools
        minToolCalls: 1
        maxToolCalls: 10
```

**mcp-config.yaml** - MCP server to test:
```yaml
mcpServers:
  kubernetes:
    type: http
    url: http://localhost:8080/mcp
    enableAllTools: true
```

**agent.yaml** - AI agent configuration:
```yaml
kind: Agent
metadata:
  name: "claude-code"
commands:
  argTemplateMcpServer: "--mcp-config {{ .File }}"
  argTemplateAllowedTools: "mcp__{{ .ServerName }}__{{ .ToolName }}"
  runPrompt: |-
    claude {{ .McpServerFileArgs }} --print "{{ .Prompt }}"
```

**tasks/create-pod.yaml** - Test task:
```yaml
kind: Task
metadata:
  name: "create-nginx-pod"
  difficulty: easy
steps:
  setup:
    file: setup.sh      # Creates test namespace
  verify:
    file: verify.sh     # Checks pod is running
  cleanup:
    file: cleanup.sh    # Deletes pod
  prompt:
    inline: Create a nginx pod named web-server in the test-namespace
```

#### Test Scripts

Scripts return exit 0 for success, non-zero for failure:

**setup.sh** - Prepare environment:
```bash
#!/usr/bin/env bash
kubectl create namespace test-ns
```

**verify.sh** - Check task succeeded:
```bash
#!/usr/bin/env bash
kubectl wait --for=condition=Ready pod/web-server -n test-ns --timeout=120s
```

**cleanup.sh** - Remove resources:
```bash
#!/usr/bin/env bash
kubectl delete pod web-server -n test-ns
```

Or use inline scripts in the task YAML:
```yaml
steps:
  setup:
    inline: |-
      #!/usr/bin/env bash
      kubectl create namespace test-ns
```
