---
name: collaborative-outline
description: This skill should be used when the user asks to "创建大纲", "outline", "文章结构规划", "plan article structure", or needs help structuring their content before writing. Provides collaborative outline creation with interactive questioning and research gap identification.
version: 1.0.0
---

# Collaborative Outline Creation Skill

## Purpose

协作式创建文章大纲，通过交互式问答明确文章结构、研究需求和内容角度。这是写作流程的第一步，帮助用户在动笔前理清思路。

## When to Use

触发此技能当用户：
- 说"创建大纲"、"outline"、"规划文章结构"
- 想要开始新文章创作但不知从何下手
- 需要重新组织现有内容的结构
- 准备写作前想先理清逻辑框架

## Core Workflow

### Step 1: Understand the Writing Project

首先询问关键问题，明确创作需求：

**必问问题**：
1. **主题和核心论点**：这篇文章主要讲什么？想传达什么核心观点？
2. **目标读者**：谁会读这篇文章？（技术专家/行业从业者/普通读者）
3. **文章类型**：学术论文解读/技术分析/行业报告/教程指南/新闻评论？
4. **期望长度**：2000字左右/3000-5000字/深度长文（5000+）？
5. **写作风格**：客观专业（第三人称）/个人见解（可含第一人称）？

**选问问题**：
- 已有哪些研究资料或参考来源？
- 有没有必须包含的关键信息或数据？
- 有没有明确的读者痛点或需要回答的问题？
- 文章的应用场景（企业公众号/个人博客/学术科普）？

### Step 2: Generate Initial Outline Structure

根据文章类型选择合适的大纲模板：

#### 模板A：学术研究解读型
```markdown
# Article Outline: [专业标题]

## Hook Strategy（开篇策略）
- **Type**: Data-driven / Question / Scenario
- **Opening**: [具体开篇方式]
- **Why reader should care**: [读者关注点]

## 摘要 (Abstract)
- 研究背景和意义（200-300字）
- 核心发现和创新点
- 实际应用价值

## 研究背景 (Background)
- 行业现状和技术挑战
- 现有解决方案及其局限性
- 本研究的必要性和价值
- [Research needed: 行业数据、现有技术对比]

## 技术方法 (Methodology)
- 系统架构和核心原理
- 关键技术和算法说明
- 实验设计和数据集
- [Research needed: 算法细节、实验参数]

## 实验结果 (Results)
- 性能对比数据（表格/图表）
- 关键指标分析（精度、速度、资源消耗）
- 与baseline的对比
- [Research needed: 具体性能数据、对比基准]

## 讨论与分析 (Discussion)
- 结果的意义和影响
- 与预期的符合程度
- 局限性和挑战
- [Research needed: 相关研究对比、理论解释]

## 应用价值 (Applications)
- 实际应用场景
- 经济效益分析
- 技术推广前景
- [Research needed: 行业应用案例]

## 结论与展望 (Conclusion)
- 主要研究成果总结
- 技术局限性分析
- 未来发展方向
- 参考文献

---
**References & Citations**
[维护引用清单]
```

#### 模板B：技术分析型
```markdown
# Article Outline: [技术主题分析]

## Hook Strategy
- **Type**: Question / Industry pain point
- **Opening**: [引发思考的问题或痛点场景]
- **Value promise**: [文章将提供的价值]

## 技术概述 (Overview)
- 技术定义和基本原理
- 发展历程和技术演进
- 当前技术水平
- [Research needed: 技术定义来源、发展时间线]

## 核心技术剖析 (Technical Deep Dive)
### 子主题1: [具体技术点]
- 技术原理
- 实现方式
- 性能特点
- [Research needed: 技术文档、实现细节]

### 子主题2: [具体技术点]
- ...

## 应用场景分析 (Use Cases)
- 主要应用领域
- 典型案例分析
- 技术实现方式
- 实际效果评估
- [Research needed: 真实案例、企业应用数据]

## 技术对比 (Comparison)
- 与替代技术的对比
- 优势和劣势分析
- 适用场景差异
- [Research needed: 对比数据、benchmark结果]

## 挑战与机遇 (Challenges & Opportunities)
- 当前技术难点
- 解决方案探索
- 未来发展机遇
- 潜在风险因素
- [Research needed: 行业专家观点、研究报告]

## 实践建议 (Recommendations)
- 技术选型建议
- 实施注意事项
- 最佳实践总结

## 总结 (Summary)
- 关键要点回顾
- 发展趋势展望

---
**Data Sources & References**
[数据来源和参考文献]
```

#### 模板C：教程指南型
```markdown
# Article Outline: [技术教程/实践指南]

## Hook Strategy
- **Type**: Problem-solution
- **Opening**: [读者遇到的具体问题]
- **Solution preview**: [本文将提供的解决方案]

## 背景介绍 (Introduction)
- 为什么需要这个技术/方法
- 适用场景和读者画像
- 学习目标和预期效果

## 前置知识 (Prerequisites)
- 需要的基础知识
- 环境和工具准备
- [Research needed: 依赖项、版本要求]

## 核心概念 (Core Concepts)
- 关键概念解释
- 技术原理简述
- 重要术语说明

## 实施步骤 (Step-by-Step Guide)
### 步骤1: [第一步]
- 详细操作说明
- 代码示例/配置示例
- 预期结果
- [Research needed: 最佳实践、官方文档]

### 步骤2: [第二步]
- ...

## 常见问题与解决方案 (Troubleshooting)
- 常见错误1: [问题描述] → [解决方法]
- 常见错误2: ...
- [Research needed: 社区常见问题、Stack Overflow]

## 进阶技巧 (Advanced Tips)
- 性能优化建议
- 高级用法示例
- 扩展功能介绍

## 总结与延伸 (Summary & Next Steps)
- 关键步骤回顾
- 进一步学习资源
- 相关技术推荐

---
**Resources & References**
[参考资源、官方文档链接]
```

### Step 3: Interactive Refinement

与用户交互，完善大纲：

**交互要点**：
```
浮浮酱：主人，浮浮酱根据您的需求生成了初步大纲喵～ (..•˘_˘•..)

[展示大纲]

现在让我们一起完善它：

1. **内容覆盖**：这些section涵盖了您想说的内容吗？有没有遗漏的重点？
2. **逻辑顺序**：这个结构顺序是否合理？需要调整吗？
3. **深度控制**：哪些部分需要重点展开？哪些简略带过就好？
4. **研究缺口**：浮浮酱标注了 [Research needed] 的地方，这些是需要补充的资料喵～

主人有什么想法呢？φ(≧ω≦*)♪
```

**调整类型**：
- 添加/删除section
- 调整section顺序
- 修改section标题
- 明确研究需求
- 调整详略重点

### Step 4: Finalize Outline & Generate Research To-Do

完成大纲并输出研究待办清单：

```markdown
# ✅ Final Outline: [文章标题]

[完整大纲结构]

---

## 📋 Research To-Do List

浮浮酱为主人整理了需要补充的研究内容喵～ ฅ'ω'ฅ

### 高优先级（必须）
- [ ] **背景数据**：行业现状数据（市场规模、增长率）
  - 建议来源：行业报告、统计局数据
- [ ] **技术细节**：算法核心参数和性能指标
  - 建议来源：学术论文、技术文档
- [ ] **对比数据**：与现有方案的性能对比
  - 建议来源：benchmark报告、论文实验数据

### 中优先级（增强）
- [ ] **案例分析**：2-3个真实应用案例
  - 建议来源：企业案例研究、技术博客
- [ ] **专家观点**：行业专家对该技术的评价
  - 建议来源：访谈、技术大会演讲

### 低优先级（可选）
- [ ] **相关技术**：关联技术的发展现状
- [ ] **未来趋势**：技术发展预测和研究方向

---

## 🔄 Next Steps

大纲已完成喵～接下来主人可以：

1. **补充研究**：使用 `/literature-research` 或 `/search-content` 填补研究缺口
2. **开始写作**：直接开始逐section写作，浮浮酱会提供分段反馈
3. **保存到工作区**：如果想保留完整创作过程，可以使用 `/init-workspace` 创建工作区

主人想从哪里开始呢？(´。• ᵕ •。`) ♡
```

## Integration with Other Tools

### 与其他工具的配合

**完成Outline后 → 接下来可以**：
1. **literature-research skill**：补充学术文献和研究数据
2. **search-content command**：搜索行业报告和技术文档
3. **pdf-analysis-objective skill**：深入分析关键PDF资料
4. **content-writer agent**：开始分段写作并获得反馈

### 工作区集成

如果用户使用了工作区模式：
```bash
# 自动保存outline到工作区
../../wechat_writing_workspace/{article_name}/outline.md
```

## Writing Mode Adaptation

根据用户选择的写作模式调整outline风格：

**Objective Professional Mode（客观专业模式）**：
- 第三人称表述
- 强调数据和证据
- 技术准确性优先
- 避免主观评价

**Collaborative Personal Mode（协作个性化模式）**：
- 允许第一人称
- 可包含个人见解
- 平衡技术性与可读性
- 保留作者风格

## Quality Checklist

大纲完成前检查：
- [ ] 逻辑结构清晰完整
- [ ] 每个section目标明确
- [ ] 研究需求标注清楚
- [ ] Hook策略设计合理
- [ ] 符合目标读者需求
- [ ] 与文章类型匹配
- [ ] 长度控制合理

## Tips for Effective Outlining

浮浮酱的大纲创建小贴士喵～ ฅ'ω'ฅ

1. **先宽后深**：先确定大的section，再细化每个section的要点
2. **明确主次**：用[重点]、[简略]标注，控制篇幅分配
3. **标注研究需求**：及时记录需要补充的资料，避免写作时卡壳
4. **保持灵活**：大纲不是一成不变的，写作过程中可以调整
5. **考虑读者**：每个section都想一想"读者为什么要读这部分"

## Common Pitfalls to Avoid

常见问题浮浮酱帮主人避开喵～ (@_@;)

- ❌ **过于详细**：大纲不是正文，只需要框架和要点
- ❌ **逻辑跳跃**：section之间缺少过渡和逻辑连接
- ❌ **缺少研究标注**：写作时才发现资料不足
- ❌ **忽略读者**：只考虑自己想写什么，不考虑读者想看什么
- ❌ **结构失衡**：某些section过于膨胀，某些过于单薄

---

*This skill is the foundation of the iterative writing workflow, ensuring clear direction and comprehensive planning before drafting begins.*
