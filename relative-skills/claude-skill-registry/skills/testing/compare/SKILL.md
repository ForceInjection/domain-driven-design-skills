---
description: 比較原始 spec-kit 與當前版本在設計上的差異
argument-hint: [ 版本號 ]
allowed-tools: Bash(make diff:*)
---

分析原始 spec-kit 與當前重製版本在**設計理念**、**使用方式**和**工作流程**上的差異。

## 執行流程

### 1. 解析參數與取得技術差異

技術上的差異如下：

```
!`make diff VERSION=$ARGUMENTS`
```
]
### 2. 產生語義差異報告

著重於「為什麼改變」和「改變的意義」，而非技術細節的逐行比對。
