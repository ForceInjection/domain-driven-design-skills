---
name: verification-enforcer
description: Enforce comprehensive verification and testing before declaring completion. Use when implementing features, making changes, or completing tasks. Prevents insufficient verification (FP-10).
---

# Verification Enforcer

**Version**: 1.0.0
**対策対象**: FP-10 (検証不足)
**優先度**: 高
**出典**: vibration-diagnosis-prototype失敗事例, びーぐるPDF

## The Iron Law

> Verification is not optional. It is mandatory.

**定義**: 検証 = 実装が仕様を満たし、期待通りに動作することを確認すること

---

## 4-Level Verification Process

### Level 1: Smoke Test (基本動作確認)

**目的**: 基本的な動作を確認

**実行内容**:
```
□ プログラムが起動するか？
□ エラーなく実行できるか？
□ 基本的な入出力が動作するか？
```

**例**:
```bash
# Python
$ python app.py
# エラーなく起動 ✅

# Node.js
$ node app.js
# エラーなく起動 ✅

# 基本動作確認
$ curl http://localhost:3000/
# レスポンスあり ✅
```

**完了基準**:
```
✅ 起動できる
✅ エラーメッセージなし
✅ 基本的な処理が実行できる
```

---

### Level 2: Edge Case Test (境界値テスト)

**目的**: 境界値・特殊ケースでの動作を確認

**テストケース**:
```
□ 空入力（空文字列、空配列、null等）
□ 境界値（最小値、最大値）
□ 異常値（負の数、巨大な値）
□ 特殊文字（スペース、改行、記号）
```

**例**:
```python
# Edge Case Tests

# Test 1: 空入力
result = process_data([])
assert result == []  # 空配列を正しく処理

# Test 2: 境界値
result = process_data([0, 100])  # 最小値・最大値
assert result is not None

# Test 3: 異常値
with pytest.raises(ValueError):
    process_data([-1])  # 負の数は拒否

# Test 4: 特殊文字
result = process_data(["Hello World", "Line\nBreak"])
assert len(result) == 2
```

**完了基準**:
```
✅ 空入力を正しく処理
✅ 境界値を正しく処理
✅ 異常値を正しく拒否
✅ 特殊文字を正しく処理
```

---

### Level 3: Error Case Test (エラーケーステスト)

**目的**: エラー処理が正しく動作することを確認

**テストケース**:
```
□ 不正な入力でエラーを返すか？
□ エラーメッセージは適切か？
□ エラーハンドリングが機能するか？
□ ログが正しく出力されるか？
```

**例**:
```python
# Error Case Tests

# Test 1: Type error
with pytest.raises(TypeError):
    process_data("invalid type")  # 文字列は拒否

# Test 2: Value error
with pytest.raises(ValueError) as exc_info:
    process_data([1000])  # 範囲外の値
assert "out of range" in str(exc_info.value)  # エラーメッセージ確認

# Test 3: File not found
with pytest.raises(FileNotFoundError):
    load_data("nonexistent.txt")

# Test 4: Error logging
process_invalid_input()
assert "ERROR" in read_log_file()  # ログ確認
```

**完了基準**:
```
✅ 不正な入力を拒否する
✅ 適切なエラーメッセージを返す
✅ エラーハンドリングが動作する
✅ エラーログが出力される
```

---

### Level 4: Stress Test (負荷テスト)

**目的**: 大量データ・負荷下での動作を確認

**テストケース**:
```
□ 大量データを処理できるか？
□ 長時間動作できるか？
□ メモリリークはないか？
□ パフォーマンスは許容範囲か？
```

**例**:
```python
# Stress Tests

# Test 1: Large dataset
large_data = list(range(10000))
start_time = time.time()
result = process_data(large_data)
duration = time.time() - start_time

assert len(result) == 10000  # 全データ処理
assert duration < 5.0  # 5秒以内

# Test 2: Memory usage
import tracemalloc
tracemalloc.start()

for i in range(100):
    process_data(list(range(1000)))

current, peak = tracemalloc.get_traced_memory()
assert peak < 100 * 1024 * 1024  # 100MB未満
tracemalloc.stop()

# Test 3: Continuous operation
for i in range(1000):
    result = process_data([i])
    assert result is not None  # 1000回連続実行
```

**完了基準**:
```
✅ 大量データを処理できる
✅ 長時間動作できる
✅ メモリリークなし
✅ パフォーマンス許容範囲内
```

---

## Verification Workflow

### Phase 1: Pre-Implementation Verification Plan（実装前検証計画）

**目的**: 何をどう検証するか事前に決める

**計画内容**:
```markdown
## Verification Plan

### Test Cases（テストケース）
1. Smoke Test:
   - [ ] 基本動作確認
   - [ ] エラーなし確認

2. Edge Case Test:
   - [ ] 空入力
   - [ ] 境界値
   - [ ] 異常値

3. Error Case Test:
   - [ ] Type error
   - [ ] Value error
   - [ ] Exception handling

4. Stress Test:
   - [ ] Large dataset
   - [ ] Memory usage
   - [ ] Performance

### Verification Methods（検証方法）
- Unit Test: pytest
- Integration Test: 手動テスト
- E2E Test: Playwright

### Success Criteria（成功基準）
- All tests pass
- Code coverage > 80%
- No critical bugs
```

---

### Phase 2: Implementation with Verification（検証しながら実装）

**実行内容**:
```
□ 実装を段階的に進める
□ 各段階でテストを実行
□ テストがパスしてから次へ
```

**推奨フロー**:
```
1. Level 1機能を実装
2. Smoke Test実行 → パス
3. Level 2機能を実装
4. Edge Case Test実行 → パス
5. Level 3機能を実装
6. Error Case Test実行 → パス
7. 最適化実施
8. Stress Test実行 → パス
→ 完了
```

---

### Phase 3: Post-Implementation Verification（実装後検証）

**4レベルすべて実行**:
```
✅ Level 1: Smoke Test - パス
✅ Level 2: Edge Case Test - パス
✅ Level 3: Error Case Test - パス
✅ Level 4: Stress Test - パス
→ 完了
```

**不合格の場合**:
```
❌ Level 2: Edge Case Test - 失敗
→ 実装を修正
→ 再テスト
→ 全レベルパス後に完了
```

---

### Phase 4: Definition of Done（完了基準）

**必須条件**:
```yaml
✅ All 4 levels pass
✅ Code coverage > 80% (Unit Tests)
✅ No critical bugs
✅ Performance acceptable
✅ Documentation updated
→ 完了
```

**未完了の例**:
- ❌ "実装しました" だけで完了宣言
- ❌ Smoke Testだけで完了
- ❌ "動いているようです" 状態
- ❌ テスト未実行

---

## Prohibited Patterns (アンチパターン)

### Anti-Pattern 1: No Verification（検証なし）

**症状** (vibration-diagnosis-prototype):
```
User: "機能を実装してください"
❌ Bad:
"実装しました。完了です。"
（テスト未実行、動作確認なし）
```

**正しい対応**:
```
User: "機能を実装してください"
✅ Good:
"実装しました。検証を実施します。

Level 1: Smoke Test
$ python app.py
✅ 起動成功

Level 2: Edge Case Test
$ pytest tests/test_edge_cases.py
✅ 全テストパス

Level 3: Error Case Test
$ pytest tests/test_errors.py
✅ 全テストパス

Level 4: Stress Test
$ pytest tests/test_stress.py
✅ パフォーマンス許容範囲内

完了です。"
```

---

### Anti-Pattern 2: Smoke Test Only（基本動作確認のみ）

**症状**:
```
❌ Bad:
"実行してみました。動きました。完了です。"
（Edge Case, Error Case, Stress Test未実施）
```

**正しい対応**:
```
✅ Good:
"Level 1: Smoke Test → ✅ パス
Level 2: Edge Case Test → ✅ パス
Level 3: Error Case Test → ✅ パス
Level 4: Stress Test → ✅ パス
完了です。"
```

---

### Anti-Pattern 3: Manual Test Only（手動テストのみ）

**症状**:
```
❌ Bad:
"手動で確認しました。動きました。完了です。"
（自動テストなし、再現性なし）
```

**正しい対応**:
```
✅ Good:
"自動テストを作成しました:
- tests/test_feature.py（29 tests）
$ pytest tests/
✅ 29 passed in 2.5s

手動テストも実施:
✅ ブラウザで動作確認

完了です。"
```

---

## Verification Templates

### Template 1: Unit Test（単体テスト）

```python
import pytest

class TestFeatureName:
    """Feature Name のテスト"""

    # Level 1: Smoke Test
    def test_basic_functionality(self):
        """基本動作確認"""
        result = feature_function(input_data)
        assert result is not None

    # Level 2: Edge Case Test
    def test_empty_input(self):
        """空入力"""
        result = feature_function([])
        assert result == []

    def test_boundary_values(self):
        """境界値"""
        result = feature_function([0, 100])
        assert result is not None

    def test_special_characters(self):
        """特殊文字"""
        result = feature_function(["Test\nLine", "Tab\tChar"])
        assert len(result) == 2

    # Level 3: Error Case Test
    def test_invalid_type(self):
        """不正な型"""
        with pytest.raises(TypeError):
            feature_function("invalid")

    def test_invalid_value(self):
        """不正な値"""
        with pytest.raises(ValueError) as exc:
            feature_function([-1])
        assert "range" in str(exc.value)

    # Level 4: Stress Test
    def test_large_dataset(self):
        """大量データ"""
        large_data = list(range(10000))
        result = feature_function(large_data)
        assert len(result) == 10000
```

---

### Template 2: Integration Test（統合テスト）

```python
import pytest

class TestIntegration:
    """統合テスト"""

    def test_end_to_end_flow(self):
        """エンドツーエンドフロー"""
        # Setup
        setup_test_environment()

        # Execute
        result = run_full_workflow(test_data)

        # Verify
        assert result.status == "success"
        assert result.output is not None

        # Cleanup
        cleanup_test_environment()

    def test_error_recovery(self):
        """エラーリカバリ"""
        # Simulate error
        inject_error()

        # Execute
        result = run_full_workflow(test_data)

        # Verify recovery
        assert result.status == "recovered"
```

---

### Template 3: Verification Checklist（検証チェックリスト）

```markdown
# Verification Checklist

## Level 1: Smoke Test
- [ ] プログラム起動確認
- [ ] エラーなし確認
- [ ] 基本動作確認

## Level 2: Edge Case Test
- [ ] 空入力テスト
- [ ] 境界値テスト
- [ ] 異常値テスト
- [ ] 特殊文字テスト

## Level 3: Error Case Test
- [ ] Type errorテスト
- [ ] Value errorテスト
- [ ] Exception handlingテスト
- [ ] Error loggingテスト

## Level 4: Stress Test
- [ ] Large datasetテスト
- [ ] Memory usageテスト
- [ ] Performanceテスト
- [ ] Continuous operationテスト

## Additional Checks
- [ ] Code coverage > 80%
- [ ] No critical bugs
- [ ] Documentation updated
- [ ] Manual test passed

## Definition of Done
- [ ] All tests pass
- [ ] All checks complete
- [ ] Ready for deployment
```

---

## Multi-layer Defense (3層防御)

**Layer 1: Rules** (弱)
- `test-process-requirements.md` - テストプロセス要件
- `docs/rules/test.md` - テスト品質ルール
- LLMが無視する可能性あり

**Layer 2: Skills** (中) ← **このSkill**
- **verification-enforcer**: 検証強制
- タスク開始時に自動適用

**Layer 3: Hooks** (強)
- `quality_check.sh`: テスト実行確認
- 最も強力な防御

---

## Invocation Examples

### Example 1: 機能実装後

**User**: "機能を実装しました"

**Skill Response**:
```
Verification Enforcer が起動しました。

検証を実施します。

Level 1: Smoke Test
□ 起動確認
□ エラーなし確認

Level 2: Edge Case Test
□ 空入力テスト
□ 境界値テスト

Level 3: Error Case Test
□ エラーハンドリング確認

Level 4: Stress Test
□ パフォーマンス確認

全レベルパス後に完了宣言します。
```

---

### Example 2: バグ修正後

**User**: "バグを修正しました"

**Skill Response**:
```
Verification Enforcer が起動しました。

修正の検証を実施します。

1. Regression Test（回帰テスト）
   □ 既存機能が壊れていないか確認

2. Bug Fix Verification（バグ修正確認）
   □ バグが再現しないか確認

3. 4-Level Verification
   □ Smoke/Edge/Error/Stress Test実施

全テストパス後に完了宣言します。
```

---

## Best Practices

### 1. Test Automation（テスト自動化）

**推奨**:
```
- Unit Test: pytest, jest等で自動化
- Integration Test: できる限り自動化
- E2E Test: Playwright, Selenium等で自動化
```

**利点**:
- 再現性が高い
- 回帰テストが容易
- CI/CDに組み込める

---

### 2. Test Coverage（テストカバレッジ）

**目標**:
```
- Unit Test: 80%以上
- Critical Path: 100%
```

**測定方法**:
```bash
# Python
pytest --cov=src tests/

# JavaScript
npm test -- --coverage
```

---

### 3. Continuous Verification（継続的検証）

**推奨フロー**:
```
1. 実装
2. テスト実行
3. コミット前に全テスト実行
4. CI/CDで自動テスト実行
5. デプロイ前に全テスト実行
```

---

## Related Resources

### Internal
- `test-process-requirements.md` - テストプロセス要件詳細
- `docs/rules/test.md` - テスト品質ルール

### External
- びーぐるPDF - テスト品質のベストプラクティス
- pytest documentation - テスト自動化

### Phase 3成果物
- `step3.5-failure-case-analysis.md` - FP-10詳細分析
- `CRITICAL_FAILURE_REPORT_20251226.md` - vibration-diagnosis-prototype失敗事例

---

## Completion Criteria

```yaml
✅ Level 1: Smoke Test - パス
✅ Level 2: Edge Case Test - パス
✅ Level 3: Error Case Test - パス
✅ Level 4: Stress Test - パス
✅ Code Coverage > 80%
✅ No Critical Bugs
```

**検証なしの完了宣言は禁止**

---

**注意**: このSkillは自動的に起動されます。無効化したい場合は `.claude/settings.local.json` から削除してください。
