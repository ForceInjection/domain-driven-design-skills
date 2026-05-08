---
name: lorairo-test-generator
description: Generate pytest unit, integration, and GUI tests for LoRAIro with proper fixtures, mocks, and 75%+ coverage using pytest-qt for PySide6 testing
allowed-tools: mcp__serena__find_symbol, mcp__serena__get_symbols_overview, Read, Write, Bash
---

# LoRAIro Test Generator Skill

このSkillは、LoRAIroプロジェクトにおけるpytest+pytest-qtを使ったテスト生成のベストプラクティスを提供します。

## 使用タイミング

- 新機能実装後のテスト作成
- 既存コードのテストカバレッジ向上
- リファクタリング後の回帰テスト作成
- GUI コンポーネントのテスト実装

## LoRAIroのテスト戦略

### テストカテゴリ (pytest markers)

```python
# Unit tests: ビジネスロジック、単一関数/クラス
@pytest.mark.unit
def test_calculate_score():
    assert calculate_score(10, 20) == 0.5

# Integration tests: 複数コンポーネント統合
@pytest.mark.integration
def test_repository_service_integration():
    service = ImageProcessingService(repository)
    result = service.process_batch(images)
    assert len(result) > 0

# GUI tests: PySide6 ウィジェット
@pytest.mark.gui
def test_widget_interaction(qtbot):
    widget = ThumbnailWidget()
    qtbot.addWidget(widget)
    assert widget.isVisible()
```

### 実行コマンド

```bash
# 全テスト
uv run pytest

# カテゴリ別
uv run pytest -m unit
uv run pytest -m integration
uv run pytest -m gui

# カバレッジ付き
uv run pytest --cov=src --cov-report=html
```

## 1. Unit Test パターン

### Repository Test

```python
import pytest
from src.lorairo.database.db_core import create_test_engine
from src.lorairo.database.db_repository import ImageRepository
from src.lorairo.database.schema import Image
from sqlalchemy.orm import scoped_session, sessionmaker

@pytest.fixture
def test_db_engine():
    """テスト用DBエンジン"""
    return create_test_engine()

@pytest.fixture
def test_repository(test_db_engine):
    """テスト用リポジトリ"""
    session_factory = scoped_session(sessionmaker(bind=test_db_engine))
    repo = ImageRepository(session_factory)
    yield repo
    session_factory.remove()

@pytest.mark.unit
def test_add_image(test_repository):
    """画像追加テスト"""
    image = Image(path="/test/image.jpg", phash="abc123")
    result = test_repository.add(image)

    assert result.id is not None
    assert result.path == "/test/image.jpg"
    assert result.phash == "abc123"

@pytest.mark.unit
def test_get_by_id(test_repository):
    """ID検索テスト"""
    # Arrange
    image = Image(path="/test/img.jpg", phash="xyz")
    added = test_repository.add(image)

    # Act
    result = test_repository.get_by_id(added.id)

    # Assert
    assert result is not None
    assert result.id == added.id
```

### Service Test (Mock使用)

```python
from unittest.mock import Mock, patch
from src.lorairo.services.image_processing_service import ImageProcessingService

@pytest.fixture
def mock_repository():
    """モックリポジトリ"""
    repo = Mock(spec=ImageRepository)
    repo.get_all.return_value = [
        Image(id=1, path="/img1.jpg"),
        Image(id=2, path="/img2.jpg"),
    ]
    return repo

@pytest.mark.unit
def test_process_batch(mock_repository):
    """バッチ処理テスト"""
    service = ImageProcessingService(mock_repository)

    result = service.process_batch(["/img1.jpg", "/img2.jpg"])

    assert len(result) == 2
    mock_repository.add.assert_called()
```

## 2. Integration Test パターン

```python
@pytest.mark.integration
def test_full_workflow(test_repository):
    """完全ワークフローテスト"""
    # 1. データ準備
    images = [
        Image(path=f"/img{i}.jpg", phash=f"hash{i}")
        for i in range(5)
    ]

    # 2. 追加
    added = test_repository.batch_add(images)
    assert len(added) == 5

    # 3. 検索
    criteria = SearchCriteria(min_score=0.5)
    results = test_repository.search(criteria)
    assert isinstance(results, list)

    # 4. 更新
    results[0].score = 0.9
    updated = test_repository.update(results[0])
    assert updated.score == 0.9

    # 5. 削除
    deleted = test_repository.delete(results[0].id)
    assert deleted is True
```

## 3. GUI Test パターン (pytest-qt)

### Widget Test

```python
from PySide6.QtWidgets import QApplication
from PySide6.QtCore import Qt
from src.lorairo.gui.widgets.thumbnail_widget import ThumbnailWidget

@pytest.fixture
def app(qtbot):
    """Qt application"""
    return QApplication.instance() or QApplication([])

@pytest.fixture
def thumbnail_widget(qtbot):
    """Thumbnail widget fixture"""
    widget = ThumbnailWidget()
    qtbot.addWidget(widget)
    return widget

@pytest.mark.gui
def test_widget_initialization(thumbnail_widget):
    """Widget初期化テスト"""
    assert thumbnail_widget.isVisible()
    assert thumbnail_widget.windowTitle() == "Thumbnails"

@pytest.mark.gui
def test_signal_emission(qtbot, thumbnail_widget):
    """Signal発火テスト"""
    with qtbot.waitSignal(
        thumbnail_widget.image_selected,
        timeout=1000
    ) as blocker:
        # Signal発火アクション
        thumbnail_widget.select_image(0)

    # Signal引数確認
    assert blocker.args[0] == "/path/to/image.jpg"

@pytest.mark.gui
def test_button_click(qtbot, thumbnail_widget):
    """ボタンクリックテスト"""
    # ボタンクリックシミュレーション
    qtbot.mouseClick(
        thumbnail_widget._ui.loadButton,
        Qt.LeftButton
    )

    # 結果確認
    assert thumbnail_widget._images_loaded is True

@pytest.mark.gui
def test_text_input(qtbot, thumbnail_widget):
    """テキスト入力テスト"""
    # テキスト入力
    qtbot.keyClicks(thumbnail_widget._ui.searchField, "test query")

    # 入力値確認
    assert thumbnail_widget._ui.searchField.text() == "test query"
```

### Widget間通信テスト

```python
@pytest.mark.gui
def test_widget_communication(qtbot):
    """Widget間通信テスト"""
    thumbnail = ThumbnailWidget()
    details = ImageDetailsWidget()

    qtbot.addWidget(thumbnail)
    qtbot.addWidget(details)

    # 直接接続
    details.connect_to_thumbnail_widget(thumbnail)

    # Signal発火とSlot実行確認
    with qtbot.waitSignal(thumbnail.image_metadata_selected):
        thumbnail.select_image(0)

    # 結果確認
    assert details.current_image_path == "/img.jpg"
```

## 4. Fixture パターン

### 共通Fixture

```python
# conftest.py
import pytest
from pathlib import Path

@pytest.fixture(scope="session")
def test_data_dir():
    """テストデータディレクトリ"""
    return Path(__file__).parent / "resources"

@pytest.fixture
def sample_image(test_data_dir):
    """サンプル画像"""
    return test_data_dir / "sample.jpg"

@pytest.fixture
def mock_config():
    """モック設定"""
    return {
        "database_dir": "/tmp/test_db",
        "max_workers": 4,
    }

@pytest.fixture(autouse=True)
def reset_state():
    """各テスト前後で状態リセット"""
    # Setup
    yield
    # Teardown
    # 必要なクリーンアップ処理
```

### パラメータ化Fixture

```python
@pytest.fixture(params=[1, 5, 10])
def batch_size(request):
    """異なるバッチサイズでテスト"""
    return request.param

def test_batch_processing(batch_size):
    """バッチサイズごとのテスト"""
    result = process_batch(range(batch_size))
    assert len(result) == batch_size
```

## ベストプラクティス

### DO ✅
- **AAA pattern**: Arrange, Act, Assert で構造化
- **1 test, 1 assertion**: 可能な限り単一のアサート
- **Fixture活用**: setup/teardownは fixture で
- **pytest markers**: 適切なマーカー付与
- **カバレッジ75%+**: 最低75%のカバレッジ維持

### DON'T ❌
- **依存順序**: テスト間の依存関係禁止
- **外部依存**: 外部API呼び出しはモック
- **ハードコードパス**: テストデータは`tests/resources/`
- **print デバッグ**: logger や assert メッセージ使用
- **長時間テスト**: ユニットテストは1秒以内

## テストカバレッジ要件

```bash
# カバレッジレポート生成
uv run pytest --cov=src --cov-report=html

# カバレッジ確認
# htmlcov/index.html をブラウザで開く

# 最低カバレッジ: 75%
# 目標: ユニット 90%+, 統合 80%+, GUI 70%+
```

## ファイル配置

```
tests/
├── conftest.py              # 共通fixture
├── resources/               # テストデータ
│   ├── sample.jpg
│   └── test_config.toml
├── database/                # DB tests
│   ├── test_db_repository.py
│   └── test_db_manager.py
├── services/                # Service tests
│   └── test_image_processing_service.py
└── gui/                     # GUI tests
    ├── widgets/
    │   └── test_thumbnail_widget.py
    └── window/
        └── test_main_window.py
```

## 参考リソース
- 既存テスト: `tests/` ディレクトリ
- pytest公式: https://docs.pytest.org/
- pytest-qt: https://pytest-qt.readthedocs.io/
- テストリソース: `tests/resources/`
