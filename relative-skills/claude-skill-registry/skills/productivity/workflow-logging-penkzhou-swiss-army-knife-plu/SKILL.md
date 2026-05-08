---
name: workflow-logging
description: 工作流过程日志格式规范和写入模式。定义 JSONL 和文本两种格式的日志结构、事件类型、级别定义和写入方法。
---

# 工作流过程日志规范

本规范定义了 Swiss Army Knife 插件所有工作流的日志格式和写入模式。

## 日志级别

| 级别 | 代码 | 用途 |
|------|------|------|
| INFO | `I` | 正常流程事件（Phase/Agent 开始结束） |
| DEBUG | `D` | 详细调试信息（完整 agent I/O，仅 --verbose） |
| WARN | `W` | 可恢复的警告（如 Git 不可用） |
| ERROR | `E` | 错误和失败 |
| DECISION | `X` | 决策点（置信度决策、用户交互） |

## 日志事件类型

### 会话事件

| 类型 | 说明 | 时机 |
|------|------|------|
| SESSION_START | 会话开始 | 工作流初始化后 |
| SESSION_END | 会话结束 | 工作流完成或失败后 |

### Phase 事件

| 类型 | 说明 | 时机 |
|------|------|------|
| PHASE_START | Phase 开始 | 每个 Phase 执行前 |
| PHASE_END | Phase 结束 | 每个 Phase 完成后 |

### Agent 事件（Coordinator 级）

| 类型 | 说明 | 时机 |
|------|------|------|
| AGENT_CALL | Agent 调用 | Task 工具调用前 |
| AGENT_RESULT | Agent 返回 | Task 工具返回后 |

### Agent 内部事件（Phase Agent 级）

| 类型 | 说明 | 时机 |
|------|------|------|
| STEP_START | 步骤开始 | Agent 内部每个主要步骤开始 |
| STEP_END | 步骤结束 | Agent 内部每个主要步骤结束 |
| TOOL_USE | 工具调用 | Agent 使用 Read/Bash/Glob 等工具 |
| DATA_COLLECTED | 数据收集 | 关键数据收集完成（配置、测试输出等） |
| ANALYSIS_RESULT | 分析结果 | 错误分类、根因分析等结果 |

### 决策事件

| 类型 | 说明 | 时机 |
|------|------|------|
| CONFIDENCE_DECISION | 置信度决策 | 根因分析等置信度检查点 |
| USER_INTERACTION | 用户交互 | AskUserQuestion 调用 |

### Review 事件

| 类型 | 说明 | 时机 |
|------|------|------|
| REVIEW_PARALLEL_START | 并行审查开始 | 6 个 review agents 启动 |
| REVIEW_PARALLEL_END | 并行审查结束 | 6 个 agents 全部返回 |
| REVIEW_FIX_ITERATION | Fix 循环迭代 | 每次 review-fix 循环 |

### 警告和错误

| 类型 | 说明 | 时机 |
|------|------|------|
| WARNING | 警告信息 | 可恢复的问题 |
| ERROR | 错误信息 | 失败和异常 |

---

## JSONL 格式规范

每行一条完整的 JSON 记录，字段定义：

### 通用字段

```json
{
  "ts": "YYYY-MM-DDTHH:MM:SS.000Z",  // ISO 8601 时间戳（必填）
  "level": "I",                       // 日志级别（必填）
  "type": "PHASE_START",              // 事件类型（必填）
  "session_id": "a1b2c3d4"            // 会话 ID（必填）
}
```

> **注意**：以下示例中的时间戳仅为演示，实际使用时应替换为当前时间。

### SESSION_START

```json
{
  "ts": "2024-12-06T14:30:52.123Z",
  "level": "I",
  "type": "SESSION_START",
  "session_id": "a1b2c3d4",
  "workflow": "bugfix",
  "stack": "frontend",
  "command": "/swiss-army-knife:fix-frontend --log",
  "args": {
    "phase": "all",
    "dry_run": false,
    "log": true,
    "verbose": false
  },
  "env": {
    "project_root": "/path/to/project",
    "plugin_version": "1.0.0",
    "git_branch": "feature/login"
  }
}
```

### SESSION_END

```json
{
  "ts": "2024-12-06T14:40:00.000Z",
  "level": "I",
  "type": "SESSION_END",
  "session_id": "a1b2c3d4",
  "status": "success",
  "total_duration_ms": 548000,
  "phases_completed": ["phase_0", "phase_1", "phase_2", "phase_3", "phase_4", "phase_5"],
  "summary": {
    "errors_fixed": 3,
    "files_changed": 2,
    "review_issues_fixed": 4,
    "user_interactions": 2
  }
}
```

### PHASE_START / PHASE_END

```json
{
  "ts": "2024-12-06T14:30:53.456Z",
  "level": "I",
  "type": "PHASE_START",
  "session_id": "a1b2c3d4",
  "phase": "phase_0",
  "phase_name": "问题收集与分类",
  "agents": ["frontend-init-collector", "frontend-error-analyzer"]
}
```

```json
{
  "ts": "2024-12-06T14:31:05.789Z",
  "level": "I",
  "type": "PHASE_END",
  "session_id": "a1b2c3d4",
  "phase": "phase_0",
  "status": "success",
  "duration_ms": 12333,
  "summary": {
    "errors_found": 3,
    "test_status": "test_failed"
  }
}
```

### AGENT_CALL / AGENT_RESULT

```json
{
  "ts": "2024-12-06T14:30:53.500Z",
  "level": "I",
  "type": "AGENT_CALL",
  "session_id": "a1b2c3d4",
  "phase": "phase_0",
  "agent": "frontend-init-collector",
  "model": "sonnet",
  "input_summary": "加载配置和收集测试输出"
}
```

```json
{
  "ts": "2024-12-06T14:30:58.200Z",
  "level": "I",
  "type": "AGENT_RESULT",
  "session_id": "a1b2c3d4",
  "phase": "phase_0",
  "agent": "frontend-init-collector",
  "status": "success",
  "duration_ms": 4700,
  "output_summary": {
    "config_loaded": true,
    "test_output_lines": 150,
    "warnings_count": 1
  }
}
```

### STEP_START / STEP_END（Agent 内部）

```json
{
  "ts": "2024-12-06T14:30:54.000Z",
  "level": "I",
  "type": "STEP_START",
  "session_id": "a1b2c3d4",
  "phase": "phase_0",
  "agent": "frontend-init-collector",
  "step": "config_loading",
  "step_name": "加载配置",
  "step_index": 1,
  "total_steps": 3
}
```

```json
{
  "ts": "2024-12-06T14:30:55.500Z",
  "level": "I",
  "type": "STEP_END",
  "session_id": "a1b2c3d4",
  "phase": "phase_0",
  "agent": "frontend-init-collector",
  "step": "config_loading",
  "status": "success",
  "duration_ms": 1500,
  "result_summary": {
    "default_config": true,
    "project_config": true,
    "merged": true
  }
}
```

### TOOL_USE（Agent 内部）

```json
{
  "ts": "2024-12-06T14:30:54.200Z",
  "level": "D",
  "type": "TOOL_USE",
  "session_id": "a1b2c3d4",
  "phase": "phase_0",
  "agent": "frontend-init-collector",
  "step": "config_loading",
  "tool": "Read",
  "target": "config/defaults.yaml",
  "status": "success"
}
```

### DATA_COLLECTED（Agent 内部）

```json
{
  "ts": "2024-12-06T14:30:56.000Z",
  "level": "I",
  "type": "DATA_COLLECTED",
  "session_id": "a1b2c3d4",
  "phase": "phase_0",
  "agent": "frontend-init-collector",
  "data_type": "test_output",
  "summary": {
    "lines": 150,
    "exit_code": 1,
    "status": "test_failed",
    "source": "auto_run"
  }
}
```

### ANALYSIS_RESULT（Agent 内部）

```json
{
  "ts": "2024-12-06T14:31:02.000Z",
  "level": "I",
  "type": "ANALYSIS_RESULT",
  "session_id": "a1b2c3d4",
  "phase": "phase_0",
  "agent": "frontend-error-analyzer",
  "analysis_type": "error_classification",
  "result": {
    "errors_found": 3,
    "categories": {
      "mock_conflict": 2,
      "async_timing": 1
    },
    "files_affected": ["Button.test.tsx", "Form.test.tsx"]
  }
}
```

### CONFIDENCE_DECISION

```json
{
  "ts": "2024-12-06T14:31:15.100Z",
  "level": "X",
  "type": "CONFIDENCE_DECISION",
  "session_id": "a1b2c3d4",
  "phase": "phase_1",
  "confidence_score": 65,
  "threshold": {
    "auto_continue": 60,
    "ask_user": 40,
    "stop": 0
  },
  "decision": "auto_continue",
  "factors": {
    "clarity": 70,
    "specificity": 60,
    "context": 65,
    "reproducibility": 55
  }
}
```

### USER_INTERACTION

```json
{
  "ts": "2024-12-06T14:32:00.000Z",
  "level": "X",
  "type": "USER_INTERACTION",
  "session_id": "a1b2c3d4",
  "phase": "phase_3",
  "interaction_type": "AskUserQuestion",
  "question": "Bugfix 方案已生成，请查看 docs/bugfix/xxx.md。确认后开始实施。",
  "options": ["确认执行", "调整方案", "取消"],
  "user_response": "确认执行",
  "wait_duration_ms": 15000
}
```

### REVIEW_PARALLEL_START / REVIEW_PARALLEL_END

```json
{
  "ts": "2024-12-06T14:35:00.000Z",
  "level": "I",
  "type": "REVIEW_PARALLEL_START",
  "session_id": "a1b2c3d4",
  "phase": "phase_5",
  "agents": [
    "review-code-reviewer",
    "review-silent-failure-hunter",
    "review-code-simplifier",
    "review-test-analyzer",
    "review-comment-analyzer",
    "review-type-design-analyzer"
  ]
}
```

```json
{
  "ts": "2024-12-06T14:35:30.000Z",
  "level": "I",
  "type": "REVIEW_PARALLEL_END",
  "session_id": "a1b2c3d4",
  "phase": "phase_5",
  "duration_ms": 30000,
  "results": [
    {"agent": "review-code-reviewer", "status": "success", "issues": 2},
    {"agent": "review-silent-failure-hunter", "status": "success", "issues": 1},
    {"agent": "review-code-simplifier", "status": "success", "issues": 0},
    {"agent": "review-test-analyzer", "status": "success", "issues": 1},
    {"agent": "review-comment-analyzer", "status": "failed", "error": "timeout"},
    {"agent": "review-type-design-analyzer", "status": "success", "issues": 0}
  ],
  "total_issues": 4,
  "fixable_issues": 3
}
```

### REVIEW_FIX_ITERATION

```json
{
  "ts": "2024-12-06T14:36:00.000Z",
  "level": "I",
  "type": "REVIEW_FIX_ITERATION",
  "session_id": "a1b2c3d4",
  "phase": "phase_5",
  "iteration": 1,
  "issues_before": 4,
  "issues_after": 1,
  "fixed_count": 3,
  "termination_reason": null
}
```

### WARNING / ERROR

```json
{
  "ts": "2024-12-06T14:31:10.500Z",
  "level": "W",
  "type": "WARNING",
  "session_id": "a1b2c3d4",
  "phase": "phase_0",
  "code": "GIT_UNAVAILABLE",
  "message": "Git 信息收集失败：not a git repository",
  "impact": "根因分析将缺少版本控制上下文"
}
```

```json
{
  "ts": "2024-12-06T14:33:00.000Z",
  "level": "E",
  "type": "ERROR",
  "session_id": "a1b2c3d4",
  "phase": "phase_1",
  "code": "CONFIDENCE_TOO_LOW",
  "message": "根因分析置信度 35% 低于阈值 40%",
  "agent": "frontend-root-cause",
  "recoverable": false
}
```

### DEBUG: AGENT_IO（仅 --verbose）

```json
{
  "ts": "2024-12-06T14:30:53.500Z",
  "level": "D",
  "type": "AGENT_IO",
  "session_id": "a1b2c3d4",
  "phase": "phase_0",
  "agent": "frontend-init-collector",
  "direction": "input",
  "content": "... 完整的 agent 输入 ..."
}
```

---

## 文本格式规范

人类可读的时间线格式，每行一条记录：

```
[{timestamp}] {LEVEL} | {TYPE} | {message}
```

### 格式示例

```
[2024-12-06 14:30:52.123] INFO | SESSION_START | Bugfix Frontend (a1b2c3d4)
[2024-12-06 14:30:52.123] INFO | ENV          | project=/path/to/project branch=feature/login
[2024-12-06 14:30:53.456] INFO | PHASE_START  | Phase 0: 问题收集与分类
[2024-12-06 14:30:53.500] INFO | AGENT_CALL   | frontend-init-collector (sonnet)
[2024-12-06 14:30:58.200] INFO | AGENT_RESULT | frontend-init-collector | success | 4700ms
[2024-12-06 14:31:05.789] INFO | PHASE_END    | Phase 0 | success | 12333ms | errors_found=3
[2024-12-06 14:31:06.000] INFO | PHASE_START  | Phase 1: 诊断分析
[2024-12-06 14:31:15.100] DECN | CONFIDENCE   | score=65 | decision=auto_continue | threshold=60
[2024-12-06 14:31:20.000] INFO | PHASE_END    | Phase 1 | success | 14000ms
[2024-12-06 14:32:00.000] DECN | USER_ASK     | "确认后开始实施" | options=[确认执行,调整方案,取消]
[2024-12-06 14:32:15.000] DECN | USER_ANSWER  | "确认执行" | wait=15000ms
[2024-12-06 14:35:00.000] INFO | REVIEW_START | 6 agents: code-reviewer,silent-failure-hunter,...
[2024-12-06 14:35:30.000] INFO | REVIEW_END   | 30000ms | issues=4 | fixable=3
[2024-12-06 14:36:00.000] INFO | REVIEW_FIX   | iteration=1 | before=4 | after=1 | fixed=3
[2024-12-06 14:40:00.000] INFO | SESSION_END  | success | 548000ms | files=2 | issues_fixed=4
```

### 级别对齐

```
INFO  - 正常信息（4 字符 + 空格）
DEBUG - 调试信息（5 字符）
WARN  - 警告（4 字符 + 空格）
ERROR - 错误（5 字符）
DECN  - 决策（4 字符 + 空格）
```

---

## 日志写入方法

### 使用 Bash 追加写入

由于 Write 工具会覆盖文件，**必须使用 Bash 追加**：

```bash
# JSONL 格式
echo '{"ts":"2024-12-06T14:30:52.123Z","level":"I","type":"PHASE_START",...}' >> "${jsonl_file}"

# 文本格式
echo '[2024-12-06 14:30:52.123] INFO | PHASE_START  | Phase 0: 问题收集与分类' >> "${log_file}"
```

### JSON 转义注意事项

JSON 字符串中的特殊字符需要正确转义：
- 双引号 `"` → `\"`
- 反斜杠 `\` → `\\`
- 换行符 → `\n`

### 时间戳格式

- **JSONL**: ISO 8601 格式 `2024-12-06T14:30:52.123Z`
- **文本**: 人类可读 `[2024-12-06 14:30:52.123]`

获取当前时间戳：
```bash
# ISO 8601 格式（用于 JSONL）
date -u +"%Y-%m-%dT%H:%M:%S.000Z"

# 人类可读格式（用于文本）
date +"%Y-%m-%d %H:%M:%S.000"
```

---

## 日志上下文传递

### 层级 1: 命令层 → Master Coordinator

命令层传递给 coordinator 的 logging 上下文：

```json
{
  "logging": {
    "enabled": true,
    "level": "info",
    "session_id": "a1b2c3d4"
  }
}
```

### 层级 2: Master Coordinator → Phase Agent

Master Coordinator 初始化日志文件后，传递给每个 Phase Agent：

```json
{
  "logging": {
    "enabled": true,
    "level": "info",
    "session_id": "a1b2c3d4",
    "phase": "phase_0",
    "log_files": {
      "jsonl": ".claude/logs/swiss-army-knife/bugfix/2024-12-06_143052_frontend_a1b2c3d4.jsonl",
      "text": ".claude/logs/swiss-army-knife/bugfix/2024-12-06_143052_frontend_a1b2c3d4.log"
    }
  }
}
```

### Phase Agent 日志记录模式

Phase Agent 收到 logging 上下文后，在每个主要步骤记录日志：

```markdown
## 日志记录

如果 `logging.enabled` 为 `true`，在每个步骤记录日志：

### 步骤开始

\`\`\`bash
# JSONL
echo '{"ts":"'$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")'","level":"I","type":"STEP_START","session_id":"${session_id}","phase":"${phase}","agent":"${agent_name}","step":"config_loading","step_name":"加载配置","step_index":1,"total_steps":3}' >> "${jsonl_file}"

# 文本
echo "[$(date +"%Y-%m-%d %H:%M:%S.000")] INFO | STEP_START  | ${agent_name} | 步骤 1/3: 加载配置" >> "${log_file}"
\`\`\`

### 步骤结束

\`\`\`bash
# JSONL
echo '{"ts":"'$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")'","level":"I","type":"STEP_END","session_id":"${session_id}","phase":"${phase}","agent":"${agent_name}","step":"config_loading","status":"success","duration_ms":1500}' >> "${jsonl_file}"

# 文本
echo "[$(date +"%Y-%m-%d %H:%M:%S.000")] INFO | STEP_END    | ${agent_name} | 步骤 1/3 完成 | 1500ms" >> "${log_file}"
\`\`\`
```

### Coordinator 内部维护

Coordinator 初始化后计算日志文件路径：

```python
log_dir = ".claude/logs/swiss-army-knife/{workflow}"
timestamp = "2024-12-06_143052"
session_id = input.logging.session_id

jsonl_file = f"{log_dir}/{timestamp}_{identifier}_{session_id}.jsonl"
log_file = f"{log_dir}/{timestamp}_{identifier}_{session_id}.log"
```

### 传递给子 Coordinator（如 review-coordinator）

```json
{
  "logging": {
    "enabled": true,
    "level": "info",
    "session_id": "a1b2c3d4",
    "log_files": {
      "jsonl": ".claude/logs/swiss-army-knife/bugfix/xxx.jsonl",
      "text": ".claude/logs/swiss-army-knife/bugfix/xxx.log"
    }
  }
}
```

---

## 日志查询示例

### 使用 jq 查询 JSONL

```bash
# 查看会话摘要
jq 'select(.type == "SESSION_START" or .type == "SESSION_END")' xxx.jsonl

# 查看所有错误
jq 'select(.level == "E")' xxx.jsonl

# 查看 Phase 耗时
jq 'select(.type == "PHASE_END") | {phase, duration_ms, status}' xxx.jsonl

# 查看置信度决策
jq 'select(.type == "CONFIDENCE_DECISION")' xxx.jsonl

# 查看用户交互
jq 'select(.type == "USER_INTERACTION")' xxx.jsonl

# 按时间排序
jq -s 'sort_by(.ts)' xxx.jsonl

# 计算总耗时
jq 'select(.type == "SESSION_END") | .total_duration_ms / 1000 | "\(.) 秒"' xxx.jsonl
```

### 使用 grep 查询文本日志

```bash
# 查看所有错误
grep "ERROR" xxx.log

# 查看 Phase 耗时
grep "PHASE_END" xxx.log

# 查看决策点
grep "DECN" xxx.log

# 查看特定 agent
grep "frontend-root-cause" xxx.log
```
