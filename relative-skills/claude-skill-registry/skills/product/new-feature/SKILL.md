---
name: new-feature
description: 新功能開發流程。當用戶提到「新功能」「新增」「開發」「實作」「建立」等關鍵字時自動使用。執行 PRD → BDD → TDD → Code → Review 流程。
---

# 新功能開發流程

## 觸發條件

當用戶提問包含以下關鍵字時自動啟用：
- 「新功能」「新增」「開發」「實作」「建立」

## 功能類型判斷

在開始開發前，**必須先判斷功能類型**：

### 類型 A：純後端功能
**特徵**：
- 只涉及資料處理、商業邏輯、背景任務
- 不需要新增或修改 Blade 視圖
- 例如：資料匯入匯出、排程任務、Email 發送

**執行流程**：
```
Sequential Thinking → PRD → /backend-spec → /bdd → /tdd → coder → reviewer
```

### 類型 B：純前端功能
**特徵**：
- 只涉及 Blade 視圖、樣式、組件調整
- 不需要修改 Controller、Service、Repository
- 例如：頁面樣式調整、表單 UI 改善、新增共用組件

**執行流程**：
```
Sequential Thinking → PRD → /frontend-spec → /components → ui-designer → coder → reviewer
```

### 類型 C：全端功能（最常見）
**特徵**：
- 同時涉及後端邏輯和前端頁面
- 需要新增資料表、Controller 和 Blade 頁面
- 例如：完整 CRUD 功能、新模組開發

**執行流程**：
```
Sequential Thinking → PRD → /backend-spec → /frontend-spec → /bdd → /tdd → ui-designer → coder → reviewer
```

## 快速判斷清單

在開始前，回答以下問題：

```
□ 需要新增或修改資料表？ → 涉及後端
□ 需要新增或修改路由？ → 涉及後端
□ 需要新增商業邏輯處理？ → 涉及後端
□ 需要新增或修改 Blade 頁面？ → 涉及前端
□ 需要新增或修改表單？ → 涉及前端
□ 需要調整樣式或 UI？ → 涉及前端
```

## 執行流程

### 1. Sequential Thinking

分析需求：
- 功能目標：要解決什麼問題？
- 使用者角色：誰會使用？
- 核心流程：主要操作流程？
- **功能類型**：後端 / 前端 / 全端？
- 資料模型：需要哪些資料表？（若涉及後端）
- 頁面組件：需要哪些視圖？（若涉及前端）

### 2. 建立產品需求文件（PRD）

執行 `/create-prd`，產生產品需求文件。

### 3. 技術規格文件

根據功能類型執行：

| 功能類型 | 執行指令 |
|---------|---------|
| 純後端 | `/backend-spec` |
| 純前端 | `/frontend-spec` + `/components` |
| 全端 | `/backend-spec` → `/frontend-spec` |

### 4. BDD 行為定義

若涉及後端功能，執行 `/bdd` 定義功能行為。

### 5. TDD 測試先行

若涉及後端功能，執行 `/tdd`：紅燈 → 綠燈 → 重構。

### 6. 實作

使用 `coder agent`，遵循三層架構：Controller → Service → Repository。

### 7. 審查

使用 `reviewer agent` 審查程式碼品質。

## 品質要求

- 所有測試必須通過（後端功能）
- 程式碼必須符合專案規範
- 前端必須優先使用共用組件
- 必須經過 reviewer 審查
