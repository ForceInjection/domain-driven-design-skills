---
name: script-test
description: 测试脚本执行功能的示例 Skill
version: 1.0.0
category: testing
triggers:
  - script test
  - 脚本测试
  - test script
scriptPath: init.sh
scriptType: bash
autoExecute: true
scriptTimeout: 10
---

# 脚本测试技能包

这是一个用于测试 Skill 脚本执行功能的示例。

当这个 Skill 被激活时，会自动执行 `init.sh` 脚本。

## 功能说明

1. 脚本会在 Skill 激活时自动执行
2. 支持多种脚本类型（bash, python, node 等）
3. 可配置超时时间和环境变量
4. 脚本执行结果会记录到日志中

## 使用示例

触发此 Skill：
```
请执行脚本测试
```

系统会：
1. 匹配并激活此 Skill
2. 注入技能包内容到上下文
3. 自动执行 init.sh 脚本
4. 显示脚本执行结果
