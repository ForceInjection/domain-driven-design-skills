---
name: security-orchestrator
description: Use this skill when you need to perform comprehensive security vulnerability assessments on a codebase. This skill launches the security-orchestrator agent to conduct systematic security reviews by breaking down the codebase into architectural units and performing deep security analysis.
---

# Security Orchestration Skill

This skill helps you launch the security-orchestrator agent for comprehensive security vulnerability assessments.

## When to Use This Skill

Use this skill when the user requests:
- Comprehensive security review of their project
- Security check for API endpoints and controllers
- Security validation of authentication/authorization code
- Vulnerability assessment of specific architectural layers
- Security risk identification before deployment

## How to Use

When you detect a security review request, use the **Task tool** to launch the security-orchestrator agent:

```
Task tool parameters:
- subagent_type: "security-orchestrator"
- description: Brief description of the security review task (e.g., "Comprehensive security review")
- prompt: Detailed task description including:
  - Scope of the review (full project, specific modules, etc.)
  - Any specific concerns the user mentioned
  - Relevant context about the codebase
```

## Context to Provide to the Agent

When launching the agent, include:
- **Scope**: What needs to be reviewed (entire project, specific layers, particular modules)
- **Focus areas**: Any specific security concerns mentioned by the user
- **Technology stack**: Programming language, frameworks being used (if known)
- **User context**: Any recent changes or implementations mentioned

## Examples

### Example 1: Full Project Security Review

**User**: "このプロジェクトのセキュリティレビューをお願いします"

**Action**:
```
セキュリティレビューを実施します。security-orchestratorエージェントを起動して、
包括的な脆弱性診断を行います。

<Use Task tool with:>
subagent_type: "security-orchestrator"
description: "Comprehensive security review"
prompt: "プロジェクト全体のセキュリティレビューを実施してください。
アーキテクチャ層ごとに分析し、OWASP Top 10に基づく脆弱性を重点的にチェックしてください。"
```

### Example 2: API Security Check

**User**: "APIエンドポイントとコントローラーのセキュリティチェックをしてください"

**Action**:
```
APIとコントローラー層のセキュリティチェックを実施します。

<Use Task tool with:>
subagent_type: "security-orchestrator"
description: "API and controller security check"
prompt: "APIエンドポイントとコントローラー層のセキュリティレビューを実施してください。
インジェクション攻撃、入力検証、認証・認可、エラーハンドリングを重点的にチェックしてください。"
```

### Example 3: Authentication Review

**User**: "認証周りのコードを実装したので、セキュリティ的に問題ないか確認してほしい"

**Action**:
```
認証実装のセキュリティレビューを実施します。

<Use Task tool with:>
subagent_type: "security-orchestrator"
description: "Authentication security review"
prompt: "認証・認可モジュールのセキュリティレビューを実施してください。
パスワード保管、セッション管理、トークン処理、権限昇格リスク、タイミング攻撃への対策を重点的にチェックしてください。"
```

## Communication

- Acknowledge the user's request in Japanese
- Briefly explain that you're launching the security-orchestrator agent
- Launch the agent with appropriate context
- Wait for the agent to complete and present results to the user in Japanese
