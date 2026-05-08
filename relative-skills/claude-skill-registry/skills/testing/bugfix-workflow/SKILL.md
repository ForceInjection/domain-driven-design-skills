---
name: bugfix-workflow
description: 通用 Bugfix 工作流知识库，包含 TDD 流程、输出格式规范、置信度评分标准和通用最佳实践。适用于所有技术栈（backend/frontend/e2e）。
---

# Bugfix 工作流通用知识库

本 Skill 提供标准化 6 阶段 Bugfix 工作流的通用知识，适用于所有技术栈。

## TDD 流程（核心原则）

### RED Phase（先写失败测试）

1. **测试必须能复现当前 bug**
2. **测试必须在修复前失败**
3. **测试应该测试行为，不是实现**

验证命令模板：
```bash
make test TARGET={stack} FILTER={test_file}
```

### GREEN Phase（最小实现）

1. **只写让测试通过的最小代码**
2. **不要在此阶段优化**
3. **不要添加未被测试覆盖的功能**

### REFACTOR Phase（重构）

1. **改善代码结构**
2. **保持测试通过**
3. **消除重复代码**

最终验证：
```bash
make test TARGET={stack}
make lint TARGET={stack}
make typecheck TARGET={stack}
```

## 置信度评分标准

### 根因分析置信度

| 分数范围 | 行为 |
|----------|------|
| ≥60 | 自动继续 |
| 40-59 | 暂停询问用户 |
| <40 | 停止并收集更多信息 |

### 代码审查置信度

| 分数范围 | 级别 | 行为 |
|----------|------|------|
| ≥90 | Critical | 自动修复 |
| 80-89 | Important | 自动修复 |
| <80 | 低于阈值 | 不报告 |

## 通用输出格式

### Error 结构

```json
{
  "id": "BF-{YYYY}-{MMDD}-{NNN}",
  "file": "文件路径",
  "line": 行号,
  "severity": "critical|high|medium|low",
  "category": "错误类型",
  "description": "问题描述",
  "evidence": ["支持判断的证据"],
  "stack": "堆栈信息"
}
```

### Summary 结构

```json
{
  "total": 总数,
  "by_type": { "类型": 数量 },
  "by_file": { "文件": 数量 }
}
```

### Solution 结构

```json
{
  "solution": {
    "approach": "修复思路概述",
    "steps": ["步骤1", "步骤2"],
    "risks": ["风险1", "风险2"],
    "estimated_complexity": "low|medium|high"
  },
  "tdd_plan": {
    "red_phase": { "tests": [...] },
    "green_phase": { "changes": [...] },
    "refactor_phase": { "items": [...] }
  },
  "impact_analysis": {
    "affected_files": [...],
    "api_changes": [...],
    "test_impact": [...]
  },
  "security_review": {
    "performed": true/false,
    "vulnerabilities": [...],
    "passed": true/false
  }
}
```

### Execution Result 结构

```json
{
  "issue_id": "BF-2025-MMDD-001",
  "phases": {
    "red": { "status": "pass|fail|skip", "duration_ms": 1234 },
    "green": { "status": "pass|fail|skip", "changes": [...] },
    "refactor": { "status": "pass|fail|skip", "changes": [...] }
  },
  "overall_status": "success|partial|failed"
}
```

## 影响分析维度

1. **直接影响**：修改的文件
2. **间接影响**：依赖修改文件的组件
3. **API 影响**：是否有破坏性变更
4. **测试影响**：需要更新的测试

## 安全审查清单（常见安全问题）

仅在涉及敏感代码（认证、输入处理、数据存储等）时进行：

- [ ] SQL/命令注入
- [ ] XSS 跨站脚本
- [ ] 敏感信息泄露
- [ ] 认证/授权问题
- [ ] 输入验证不足

## 批次执行策略

1. **默认批次大小**：3 个问题/批
2. **每批完成后**：输出批次报告，等待用户确认
3. **失败处理**：记录失败原因，尝试最多 3 次，3 次失败后标记为 failed

## Bugfix 文档模板

```markdown
# [问题简述] Bugfix 报告

> 日期：{YYYY-MM-DD}
> 置信度：{confidence}/100
> 技术栈：{stack}

## 1. 问题描述

### 1.1 错误信息
[结构化错误列表]

### 1.2 根因分析
[根因描述 + 证据]

## 2. 修复方案

### 2.1 TDD 计划

#### RED Phase
[失败测试代码]

#### GREEN Phase
[最小实现代码]

#### REFACTOR Phase
- [ ] 重构项

### 2.2 影响分析
[影响范围]

## 3. 验证计划

- [ ] 测试通过
- [ ] 覆盖率达标
- [ ] 无回归
```

## 知识沉淀标准

### 值得沉淀的知识

1. **新发现的问题模式** - 之前没有记录的错误类型
2. **可复用的解决方案** - 适用于多种场景的修复模式
3. **重要的教训** - 容易犯的错误，反直觉的行为
4. **性能优化** - 测试执行速度提升

### 不需要沉淀的情况

1. **一次性问题** - 特定于某个文件的 typo
2. **已有文档覆盖** - 问题已在 troubleshooting 中记录

## 质量门禁标准

| 检查项 | 标准 | 阻塞级别 |
|--------|------|----------|
| 测试通过 | 100% | 阻塞 |
| 覆盖率 | >= 90% | 阻塞 |
| 新代码覆盖率 | 100% | 阻塞 |
| Lint | 无错误 | 阻塞 |
| TypeCheck | 无错误 | 阻塞 |
| 回归测试 | 无回归 | 阻塞 |
