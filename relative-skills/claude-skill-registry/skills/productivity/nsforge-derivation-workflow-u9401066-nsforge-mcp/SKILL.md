---
name: nsforge-derivation-workflow
description: 步進式推導工作流。觸發詞：推導, derive, 組合公式, 建立模型。
---

# 推導工作流 Skill

## 核心原則

> **SymPy-MCP 做計算，NSForge 記錄知識！**
> **每步都要顯示給用戶看！** 使用：
> - `derivation_show()` (NSForge) - 顯示當前推導狀態
> - `print_latex_expression()` (SymPy-MCP) - 顯示計算結果

## ⚠️ 黃金法則：永遠向用戶展示公式！

```
❌ 錯誤：執行計算後直接下一步
✅ 正確：執行計算 → derivation_show() 或 print_latex_expression() → 等用戶確認 → 下一步
```

## 工作流程

```
Phase 1: derivation_start(name, description)
    ↓
Phase 2: 循環 {
    SymPy-MCP: intro_many → introduce_expression → 計算 → print_latex_expression
    NSForge:   derivation_record_step(expression, description, notes?)
    NSForge:   derivation_show()  ← 🆕 顯示當前狀態！
    NSForge:   derivation_add_note(note, note_type?)  # 可選
}
    ↓
Phase 3: derivation_complete(description, assumptions?, limitations?, references?)
         derivation_show()  ← 🆕 顯示最終結果！
```

## 工具速查

| 階段 | MCP | 工具 | 用途 |
|------|-----|------|------|
| 開始 | NSForge | `derivation_start(name, description)` | 建立會話 |
| 計算 | SymPy | `intro_many`, `introduce_expression`, `substitute_expression`... | 符號計算 |
| 顯示 | SymPy | `print_latex_expression` | ⚠️ 必須！ |
| 記錄 | NSForge | `derivation_record_step(expr, desc, notes?, source?)` | 記錄步驟+知識 |
| 🆕 顯示 | NSForge | `derivation_show(format?, show_steps?)` | ⚠️ 必須！顯示當前狀態 |
| 說明 | NSForge | `derivation_add_note(note, note_type?)` | 純文字洞見 |
| 完成 | NSForge | `derivation_complete(...)` | 存檔+元資料 |

**note_type**: `assumption`, `limitation`, `observation`, `correction`, `clinical`, `physical`

### 🆕 步驟 CRUD 操作

| 操作 | 工具 | 用途 |
|------|------|------|
| 📖 Read | `derivation_get_step(step_number)` | 查看單一步驟詳情 |
| ✏️ Update | `derivation_update_step(step_number, notes?, assumptions?, ...)` | 更新步驟元資料 |
| 🗑️ Delete | `derivation_delete_step(step_number)` | 刪除最後一步 |
| ⏪ Rollback | `derivation_rollback(to_step)` | ⚡ 回滾到指定步驟 |
| 📝 Insert | `derivation_insert_note(after_step, note, note_type?)` | 在指定位置插入說明 |

## Handoff：NSForge 做不到時

⚠️ **Phase 2 後更新**：Laplace/Fourier 變換已實作，無需 Handoff！

當需要 ODE/PDE、矩陣運算、聯立方程組：

```python
# 1. 導出
result = derivation_export_for_sympy()
# → 返回 intro_many_command, current_expression

# 2. SymPy-MCP 計算
intro_many([...])
dsolve_ode(...) / solve_linear_system(...)
print_latex_expression(...)

# 3. 導入回 NSForge
derivation_import_from_sympy(
    expression="...",
    operation_performed="Solved ODE",
    sympy_tool_used="dsolve_ode",
    notes="...",
    assumptions_used=[...],
    limitations=[...]
)
```

## 調用範例

```python
# Phase 1
derivation_start("temp_mm", "Temperature-corrected Michaelis-Menten")

# Phase 2a: SymPy 計算
intro_many([{"name": "V_max", "assumptions": ["positive"]}, ...])
mm = introduce_expression("V_max * C / (K_m + C)")
print_latex_expression(mm)

# Phase 2b: NSForge 記錄
derivation_record_step(
    expression="V_max * C / (K_m + C)",
    description="Base Michaelis-Menten",
    notes="假設溫度恆定"
)

# Phase 2c: 加入洞見
derivation_add_note("酵素在 >42°C 會變性", note_type="limitation")

# Phase 3
derivation_complete(
    description="...",
    assumptions=["Michaelis-Menten kinetics"],
    limitations=["Valid for 32-42°C"],
    tags=["enzyme", "temperature"]
)
```

### 🆕 步驟 CRUD 範例

```python
# 📖 Read: 查看第 11 步詳情
derivation_get_step(11)
→ {"step": {"description": "...", "notes": "...", "output_latex": "..."}}

# ✏️ Update: 更新第 11 步的說明
derivation_update_step(
    step_number=11,
    notes="此假設在高溫時不成立",
    limitations=["Valid only for T < 42°C"]
)

# ⏪ Rollback: 發現第 11 步開始走錯，回滾到第 10 步
derivation_rollback(to_step=10)
→ {"deleted_count": 6, "deleted_steps": [11, 12, ...], "current_expression": "..."}
# 現在可以從第 10 步重新開始推導！

# 📝 Insert: 在步驟 5 和 6 之間插入說明
derivation_insert_note(
    after_step=5,
    note="此處假設達穩態",
    note_type="assumption"
)
```
