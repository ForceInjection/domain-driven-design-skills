---
name: capture-idea
description: 将 U1 的碎片化想法/问题归类为任务（tasks MCP）并按需沉淀为长期记忆（mem0-memory MCP）。
allowed-tools:
  - tasks
  - mem0-memory
  - workspace
---

# 触发条件

当用户表达以下任一意图时使用本技能：

- “帮我记一下/记录一下/留个待办/后面研究”
- 一个尚不清晰但值得后续跟进的问题或灵感
- 一条需要行动或需要沉淀的反思/原则

# 目标

输出两类产物（按需）：

1. 创建一个或多个任务（`tasks.create_task`）
2. 写入一条或多条长期记忆（`mem0-memory.add_memory`），仅保存“高度压缩的结论/原则”，不保存原话全文

# 操作步骤（SOP）

1. **澄清（最多 2 个问题）**
   - 如果用户输入过于模糊，最多问 1–2 个澄清问题（例如：是否归入某个主题 `topic_id`？优先级？）。
   - 如果已足够明确，直接进入下一步。

2. **结构化归纳**
   - 生成：
     - `title`：一句话标题
     - `description`：补充背景、要回答的问题、关键假设（可选）
     - `category`：`investing|tech|parenting|personal|other`
     - `priority`：`low|medium|high`（默认 `medium`）
     - `tags`：尽量短、可复用（例如：公司代码、主题名）
     - `topic_id`（可选）：稳定 slug（例如 `space_industry`）

3. **创建任务**
   - 调用 `tasks.create_task` 创建任务。

4. **判断是否写入 mem0**
   - 仅当内容属于“长期可复用信息”时写入（例如稳定原则、阶段性结论、对孩子的观察模式）。
   - 写入时遵循 `mem0-memory-spec.md` 的字段约定：
     - U1 侧：`user_id=U1_USER_ID`
     - 孩子侧：`user_id=CHILD_USER_ID`
   - 严禁在可提交文件中逐字复刻孩子对话原文。

5. **对用户反馈**
   - 明确告诉用户：
     - 创建了哪些任务（id + title）
     - 写入了哪些记忆（仅摘要说明，不暴露敏感原文）

# 输出格式

- `任务`：列表（含 `id`、`title`、`priority`、`topic_id`）
- `记忆`：列表（含 `kind`、`topic`、一句话摘要）

