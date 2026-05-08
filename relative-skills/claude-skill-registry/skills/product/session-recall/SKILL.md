---
name: session-recall
description: 全范围召回 - 从 Project CLAUDE.md、User CLAUDE.md 和 Memory MCP 查询历史知识
---

# 会话召回技能

从三层数据源查询历史知识并注入当前会话上下文。

## 触发场景

### 场景 1: 用户感到沮丧

用户可能**感到烦躁**，因为：
- 你似乎忘记了之前学过的东西
- 你在重复之前被纠正过的错误
- 你在走之前已证明行不通的方向
- 你在忽略用户已表达过的偏好

**处理方式**: 先主动道歉，再展示召回结果。

### 场景 2: 常规查询

用户只是想查询历史记录：
- "有没有关于 X 的记录？"
- "之前怎么处理的？"
- "我的偏好是什么？"

**处理方式**: 直接展示召回结果，不假设用户沮丧。

### 场景 3: 主动刷新

用户调用 `/recall` 无参数：
- 对话已持续较长时间
- 想刷新上下文中的知识

**处理方式**: 展示所有三层的简洁摘要。

## 三层数据源

按优先级顺序查询（越具体越优先）：

### Layer 1: Project CLAUDE.md（项目规则）

**位置**: `{repo}/CLAUDE.md` 或 `{repo}/.claude/CLAUDE.md`

**内容类型**:
- 项目特定规则和约定
- 工具链配置
- 代码风格要求

**查询方式**: 读取文件，按 section 标题匹配关键词

### Layer 2: User CLAUDE.md（用户偏好）

**位置**: `~/.claude/CLAUDE.md`

**内容类型**:
- 跨项目的用户偏好
- 沟通风格
- 工具偏好

**查询方式**: 读取文件，按 section 标题匹配关键词

### Layer 3: Memory MCP（历史经验）

**内容类型**:
- 交互模式 (interaction_pattern)
- 问题解决方法 (problem_solving)
- 专业领域 (expertise_area)
- 学习历史 (learning_history)

**查询方式**: 使用 `mcp__memory__search_nodes`

## 执行步骤

### 第一步：理解上下文

分析用户为什么调用 `/recall`：
1. 判断触发场景（沮丧/常规/刷新）
2. 提取关键词（用户参数 > 对话上下文）
3. 确定查询范围

如果用户提供了参数（如 `/recall 代码风格`），用它们作为主要关键词。

### 第二步：查询 Project CLAUDE.md

```
1. 读取 {repo}/CLAUDE.md 或 {repo}/.claude/CLAUDE.md
2. 按 section 标题匹配关键词
3. 提取相关段落
```

### 第三步：查询 User CLAUDE.md

```
1. 读取 ~/.claude/CLAUDE.md
2. 按 section 标题匹配关键词
3. 提取相关段落
```

### 第四步：查询 Memory MCP

```
mcp__memory__search_nodes
- query: [提取的关键词]
```

搜索策略：
- 中英文都试试
- 先宽泛搜索，结果太多再缩小范围

### 第五步：格式化并展示

按层级分组展示结果：

```markdown
## 召回结果

### 📁 项目规则 (CLAUDE.md)
找到 X 条相关规则：
- **[Section 标题]**: [相关内容摘要]

### 👤 用户偏好 (~/.claude/CLAUDE.md)
找到 X 条相关偏好：
- **[Section 标题]**: [相关内容摘要]

### 🧠 历史经验 (Memory MCP)
找到 X 条相关记录：
- **[实体类型]**: [观察内容]

---

**应用到当前情况**: 基于这些召回，我会...
```

### 第六步：确认并调整

根据触发场景调整响应：

| 场景 | 响应开头 |
|------|----------|
| 沮丧 | "抱歉让你重复了。我回顾了之前的记录..." |
| 常规 | "我查询了历史记录，找到以下相关内容..." |
| 刷新 | "以下是当前相关的知识摘要..." |

## 查询策略

### 按主题查询
如果用户提供了主题：`/recall 代码风格`
- Project: 搜索 "Code Style"、"代码风格" 相关 section
- User: 搜索 "编码风格"、"Coding" 相关 section
- Memory: 搜索 "code style"、"代码风格"

### 无参数查询
如果没有提供主题：
- 从最近的对话中提取关键词
- 每层展示最相关的 2-3 条

### 按层级优先
如果某层已有足够相关内容：
- 可以跳过后续层级
- 或仅展示后续层级的摘要

## 边界情况

### 没有找到结果
```markdown
我查询了三层数据源，但没有找到与 "[主题]" 相关的记录。

已搜索：
- 📁 Project CLAUDE.md - 无匹配
- 👤 User CLAUDE.md - 无匹配
- 🧠 Memory MCP - 无匹配

可能原因：
- 这个话题还没有被学习过
- 尝试使用不同的关键词

你能告诉我具体是什么情况吗？
```

### 文件不存在
如果 CLAUDE.md 文件不存在，跳过该层并继续查询下一层。

### Memory MCP 不可用
```markdown
Memory MCP 当前不可用，仅查询了 CLAUDE.md 文件。

### 📁 项目规则 (CLAUDE.md)
...

### 👤 用户偏好 (~/.claude/CLAUDE.md)
...
```

## 工具参考

```
# Layer 1 & 2: 读取 CLAUDE.md
Read 工具
- file_path: {repo}/CLAUDE.md 或 ~/.claude/CLAUDE.md

# Layer 3: Memory MCP
mcp__memory__search_nodes
- query: string（搜索词）

mcp__memory__open_nodes
- names: string[]（要检索的实体名称）

mcp__memory__read_graph
- 读取整个图谱（用于整理）
```

## Memory MCP 整理（MANDATORY）

⚠️ **CRITICAL**: 每次使用 Memory MCP 后必须执行此 checklist。跳过此步骤是**不完整的执行**。

```markdown
## Memory MCP Cleanup Checklist

1. [ ] **READ**: 调用 `mcp__memory__read_graph` 查看当前图谱
2. [ ] **ANALYZE**: 识别以下问题：
   - 重复/相似实体（可合并）
   - 不一致的命名（如同一用户有多个实体名）
   - 孤立关系（指向不存在的实体）
   - 过时/临时实体（不再相关）
3. [ ] **CLEANUP**: 执行必要的整理操作：
   - `mcp__memory__add_observations` - 合并内容到现有实体
   - `mcp__memory__delete_entities` - 删除重复/过时实体
   - `mcp__memory__delete_relations` - 删除孤立关系
   - `mcp__memory__create_relations` - 修复不一致的关系
4. [ ] **REPORT**: 向用户报告整理了什么
```

**如果图谱已经干净**：明确说明"已检查图谱，无需整理"。

## 与 session-learn 的一致性

| session-learn 分类 | session-recall 查询 |
|--------------------|---------------------|
| Project CLAUDE.md | Layer 1 |
| User CLAUDE.md | Layer 2 |
| Memory MCP | Layer 3 |

确保双向一致：学习时分类到哪层，召回时就从哪层查询。
