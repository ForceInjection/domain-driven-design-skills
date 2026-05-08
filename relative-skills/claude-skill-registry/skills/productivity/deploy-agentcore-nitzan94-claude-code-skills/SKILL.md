---
name: deploy-agentcore
description: Deploy Python agents to AWS Bedrock AgentCore. Use when deploying agents to AWS, setting up serverless agent hosting, configuring AgentCore components (Runtime, Gateway, Memory, Identity, Policy), or troubleshooting deployment errors.
---

<essential_principles>
AWS Bedrock AgentCore is a serverless platform for AI agents at scale.

## Architecture

AgentCore has 6 modular components:
- **Runtime** - Serverless hosting (direct_code_deploy or container)
- **Gateway** - Tool access via MCP (Lambda, OpenAPI, Smithy targets)
- **Memory** - STM (session) and LTM (persistent) storage
- **Identity** - Auth via IAM, Cognito, AWS JWT, external OAuth
- **Observability** - CloudWatch + OpenTelemetry tracing
- **Policy** - Cedar-based governance and authorization

## Entry Point Pattern

All agents use `BedrockAgentCoreApp` with `@app.entrypoint` decorator:

```python
from bedrock_agentcore import BedrockAgentCoreApp

app = BedrockAgentCoreApp()

@app.entrypoint
def invoke(payload: dict) -> dict:
    prompt = payload.get("prompt", "")
    result = your_agent_logic(prompt)
    return {"result": result}

if __name__ == "__main__":
    app.run()
```

## Key CLI Commands

All commands: `uv run agentcore [command]`

Runtime: configure, deploy, invoke, status, destroy, stop-session
Gateway: gateway create-mcp-gateway, gateway create-mcp-gateway-target
Memory: memory create, memory list, memory status
Identity: identity setup-cognito, identity setup-aws-jwt
Policy: policy create-policy-engine, policy create-policy

See references/cli-reference.md for full command list.

## Rules

- Agent names: underscores only (`my_agent` not `my-agent`)
- Never hardcode API keys - use Secrets Manager
- Windows: prefix with `PYTHONIOENCODING=utf-8`
- Memory mode order: `STM_AND_LTM` (not LTM_AND_STM)
</essential_principles>

<intake>
What would you like to do?

1. Deploy a new agent
2. Update existing deployment
3. Add Google OAuth
4. Create chat UI
5. Set up Gateway (MCP tools)
6. Configure Memory
7. Set up Identity/Auth
8. View logs/observability
9. Troubleshoot errors
10. Something else

Wait for response before proceeding.
</intake>

<routing>
| Response | Workflow |
|----------|----------|
| 1, "deploy", "new" | workflows/deploy-agent.md |
| 2, "update", "redeploy" | workflows/update-deployment.md |
| 3, "oauth", "google" | workflows/add-oauth.md |
| 4, "ui", "chat", "streamlit" | workflows/create-chat-ui.md |
| 5, "gateway", "mcp", "tools" | workflows/setup-gateway.md |
| 6, "memory", "stm", "ltm" | workflows/setup-memory.md |
| 7, "identity", "auth", "cognito", "jwt" | workflows/setup-identity.md |
| 8, "logs", "observability", "cloudwatch" | workflows/view-logs.md |
| 9, "error", "troubleshoot", "fix" | workflows/troubleshoot.md |
| 10, other | Clarify, then select |

After reading the workflow, follow it exactly.
</routing>

<reference_index>
All domain knowledge in `references/`:

- architecture.md - All AgentCore components explained
- cli-reference.md - Complete CLI command reference
- prerequisites.md - AWS setup, Python, uv requirements
- memory-modes.md - Memory configuration details
- common-errors.md - Error messages and fixes
- iam-policies.md - IAM role configuration
</reference_index>

<workflows_index>
| Workflow | Purpose |
|----------|---------|
| deploy-agent.md | Deploy Python agent to AgentCore |
| update-deployment.md | Redeploy with code changes |
| add-oauth.md | Add Google OAuth for cloud environment |
| create-chat-ui.md | Create Streamlit chat interface |
| setup-gateway.md | Create MCP gateway with targets |
| setup-memory.md | Configure memory modes |
| setup-identity.md | Set up auth (Cognito, JWT, OAuth) |
| view-logs.md | Access CloudWatch logs and metrics |
| troubleshoot.md | Fix common deployment errors |
</workflows_index>

<templates_index>
| Template | Purpose |
|----------|---------|
| entry_claude_sdk.py | Entry point for Claude SDK agents |
| entry_langchain.py | Entry point for LangChain agents |
| entry_custom.py | Entry point for custom Python agents |
| entry_minimal.py | Bare minimum entry point |
| policy_minimal.json | IAM policy for Secrets Manager only |
| policy_oauth.json | IAM policy for OAuth (Secrets + S3) |
| policy_full.json | IAM policy with all common permissions |
| chat_ui.py | Streamlit chat interface |
</templates_index>

<success_criteria>
Deployment successful when:
- `uv run agentcore deploy` completes without errors
- `uv run agentcore invoke` returns expected response
- Agent handles sessions correctly
- External API keys work via Secrets Manager
</success_criteria>
