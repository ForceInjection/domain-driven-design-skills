---
name: Testing & Quality Assurance
description: Автоматизация тестирования и проверки качества кода
version: 2.0.0
author: Family Budget Team
tags: [testing, pytest, quality, coverage, linting, shared-budget]
dependencies: [api-development]
---

# Testing & Quality Assurance Skill

Автоматизация создания тестов и проверки качества кода для проекта Family Budget.

## Когда использовать этот скил

Используй этот скил когда нужно:
- Создать unit тесты для endpoint/модели
- Создать integration тесты для workflow
- Создать e2e тесты для user journey
- Запустить тесты с coverage
- Проверить качество кода (linting, formatting, type checking)
- Создать тесты для Telegram bot handlers

Скил автоматически вызывается при запросах типа:
- "Создай тесты для endpoint X"
- "Добавь unit тесты для модели Y"
- "Запусти все тесты с coverage"
- "Проверь качество кода"

## Контекст проекта

Проект использует:
- **pytest 7.4+** для тестирования
- **pytest-asyncio** для async тестов
- **httpx.AsyncClient** для тестирования API
- **pytest-cov** для coverage отчетов
- **ruff 0.1+** для linting
- **black 23.11+** для formatting
- **mypy 1.7+** для type checking
- **Shared Family Budget** модель - тесты БЕЗ user_id фильтрации

## Структура тестов

```
backend/tests/
├── unit/                  # Unit тесты (изолированные)
│   ├── models/            # Тесты моделей
│   ├── services/          # Тесты сервисов (SCD2, JWT, etc.)
│   └── core/              # Тесты core модулей
├── integration/           # Integration тесты (с БД)
│   ├── test_auth_flow.py
│   ├── test_article_hierarchy.py
│   ├── test_scd_type2_versioning.py
│   └── test_user_isolation.py
├── e2e/                   # End-to-end тесты
│   ├── test_user_journey.py
│   └── test_admin_journey.py
├── endpoints/             # API endpoint тесты
│   ├── test_auth.py
│   ├── test_articles.py
│   ├── test_facts.py
│   └── test_users.py
└── conftest.py            # Fixtures и setup

bot/tests/
├── test_start_handler.py
├── test_add_handler.py
├── test_summary_handler.py
└── conftest.py
```

## Шаблон Unit теста для Endpoint

Создавай unit тесты для каждого endpoint со следующей структурой:

```python
"""
Unit tests for {ModelName} endpoints.

Tests:
- CRUD operations (create, read, update, delete, list)
- User isolation
- SCD Type 2 versioning (for dimension tables)
- Error handling (404, 403, 401, 422)
- Input validation
"""

import pytest
from httpx import AsyncClient
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.app.models.user import User
from backend.app.models.{model_name} import {ModelName}


@pytest.mark.asyncio
async def test_create_{model_name}_success(
    client: AsyncClient,
    test_user_token: str,
    test_user: User,
):
    """Test creating a {model_name} successfully."""
    payload = {
        "name": "Test {ModelName}",
        "description": "Test description",
    }

    response = await client.post(
        "/api/v1/{model_name}s",
        json=payload,
        headers={"Authorization": f"Bearer {test_user_token}"},
    )

    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Test {ModelName}"
    assert data["user_id"] == test_user.id
    assert data["is_current"] is True
    assert "id" in data
    assert "created_at" in data


@pytest.mark.asyncio
async def test_create_{model_name}_unauthorized(client: AsyncClient):
    """Test that unauthenticated request returns 401."""
    payload = {"name": "Test"}

    response = await client.post(
        "/api/v1/{model_name}s",
        json=payload,
    )

    assert response.status_code == 401


@pytest.mark.asyncio
async def test_create_{model_name}_validation_error(
    client: AsyncClient,
    test_user_token: str,
):
    """Test validation error with invalid data."""
    payload = {
        "name": "",  # Empty name should fail validation
    }

    response = await client.post(
        "/api/v1/{model_name}s",
        json=payload,
        headers={"Authorization": f"Bearer {test_user_token}"},
    )

    assert response.status_code == 422


@pytest.mark.asyncio
async def test_get_{model_name}_success(
    client: AsyncClient,
    test_user_token: str,
    test_{model_name}: {ModelName},
):
    """Test getting a {model_name} by ID."""
    response = await client.get(
        f"/api/v1/{model_name}s/{test_{model_name}.id}",
        headers={"Authorization": f"Bearer {test_user_token}"},
    )

    assert response.status_code == 200
    data = response.json()
    assert data["id"] == test_{model_name}.id
    assert data["name"] == test_{model_name}.name


@pytest.mark.asyncio
async def test_get_{model_name}_not_found(
    client: AsyncClient,
    test_user_token: str,
):
    """Test 404 when {model_name} not found."""
    response = await client.get(
        "/api/v1/{model_name}s/99999",
        headers={"Authorization": f"Bearer {test_user_token}"},
    )

    assert response.status_code == 404


@pytest.mark.asyncio
async def test_update_{model_name}_creates_new_version(
    client: AsyncClient,
    test_user_token: str,
    test_{model_name}: {ModelName},
    session: AsyncSession,
):
    """Test that update creates new SCD Type 2 version."""
    old_id = test_{model_name}.id
    old_name = test_{model_name}.name

    # Update name
    payload = {"name": "Updated Name"}
    response = await client.put(
        f"/api/v1/{model_name}s/{old_id}",
        json=payload,
        headers={"Authorization": f"Bearer {test_user_token}"},
    )

    assert response.status_code == 200
    data = response.json()

    # New version has different ID
    assert data["id"] != old_id
    assert data["name"] == "Updated Name"
    assert data["is_current"] is True

    # Old version still exists but is_current=False
    await session.refresh(test_{model_name})
    assert test_{model_name}.id == old_id
    assert test_{model_name}.name == old_name
    assert test_{model_name}.is_current is False
    assert test_{model_name}.valid_to.year != 9999  # Closed


@pytest.mark.asyncio
async def test_delete_{model_name}_soft_delete(
    client: AsyncClient,
    test_user_token: str,
    test_{model_name}: {ModelName},
    session: AsyncSession,
):
    """Test soft delete (sets is_current=False)."""
    response = await client.delete(
        f"/api/v1/{model_name}s/{test_{model_name}.id}",
        headers={"Authorization": f"Bearer {test_user_token}"},
    )

    assert response.status_code == 204

    # Record still exists but is_current=False
    await session.refresh(test_{model_name})
    assert test_{model_name}.is_current is False


@pytest.mark.asyncio
async def test_list_{model_name}s_pagination(
    client: AsyncClient,
    test_user_token: str,
):
    """Test pagination in list endpoint."""
    response = await client.get(
        "/api/v1/{model_name}s?skip=0&limit=10",
        headers={"Authorization": f"Bearer {test_user_token}"},
    )

    assert response.status_code == 200
    data = response.json()
    assert "items" in data
    assert "total" in data
    assert "skip" in data
    assert "limit" in data
    assert isinstance(data["items"], list)


@pytest.mark.asyncio
async def test_shared_budget_{model_name}(
    client: AsyncClient,
    test_user_token: str,
    other_user_{model_name}: {ModelName},
):
    """Test Shared Family Budget - all users see all records."""
    # IMPORTANT: Shared Family Budget model - NO user_id filtering!
    # User can see records created by OTHER users
    response = await client.get(
        f"/api/v1/{model_name}s/{other_user_{model_name}.id}",
        headers={"Authorization": f"Bearer {test_user_token}"},
    )

    # Should return 200 (Shared Budget - all see all)
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == other_user_{model_name}.id
```

## Шаблон Integration теста

Для тестирования сложных workflow используй integration тесты:

```python
"""
Integration test for {workflow_name}.

Tests complete workflow end-to-end with real database.
"""

import pytest
from httpx import AsyncClient
from sqlmodel import select
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.app.models.user import User
from backend.app.models.article import Article
from backend.app.models.fact import BudgetFact


@pytest.mark.asyncio
async def test_{workflow_name}_complete_flow(
    client: AsyncClient,
    session: AsyncSession,
    test_user_token: str,
    test_user: User,
):
    """
    Test complete {workflow_name} workflow.

    Steps:
    1. Create article
    2. Create fact with article
    3. Update fact
    4. Verify SCD Type 2 versioning
    5. Delete fact
    6. Verify soft delete
    """
    # Step 1: Create article
    article_payload = {
        "name": "Food",
        "type": "expense",
        "description": "Food expenses"
    }
    article_response = await client.post(
        "/api/v1/articles",
        json=article_payload,
        headers={"Authorization": f"Bearer {test_user_token}"},
    )
    assert article_response.status_code == 201
    article = article_response.json()

    # Step 2: Create fact
    fact_payload = {
        "article_id": article["id"],
        "amount": 100.50,
        "date": "2025-10-22",
        "record_type": "fact",
    }
    fact_response = await client.post(
        "/api/v1/facts",
        json=fact_payload,
        headers={"Authorization": f"Bearer {test_user_token}"},
    )
    assert fact_response.status_code == 201
    fact = fact_response.json()

    # Step 3: Update fact amount
    update_payload = {"amount": 150.75}
    update_response = await client.put(
        f"/api/v1/facts/{fact['id']}",
        json=update_payload,
        headers={"Authorization": f"Bearer {test_user_token}"},
    )
    assert update_response.status_code == 200
    updated_fact = update_response.json()

    # Step 4: Verify new version created
    assert updated_fact["amount"] == 150.75
    # For fact table (not SCD Type 2), ID should be same
    assert updated_fact["id"] == fact["id"]

    # Step 5: Delete fact
    delete_response = await client.delete(
        f"/api/v1/facts/{fact['id']}",
        headers={"Authorization": f"Bearer {test_user_token}"},
    )
    assert delete_response.status_code == 204

    # Step 6: Verify fact is deleted
    get_response = await client.get(
        f"/api/v1/facts/{fact['id']}",
        headers={"Authorization": f"Bearer {test_user_token}"},
    )
    assert get_response.status_code == 404
```

## Fixtures в conftest.py

Создай reusable fixtures для тестов:

```python
"""
Pytest fixtures for tests.

Provides:
- Database session
- Authenticated test client
- Test users with JWT tokens
- Test models (articles, facts, etc.)
"""

import asyncio
import pytest
from typing import AsyncGenerator
from httpx import AsyncClient
from sqlmodel import SQLModel
from sqlmodel.ext.asyncio.session import AsyncSession

from backend.app.db.session import engine, get_async_session
from backend.app.main import app
from backend.app.models.user import User
from backend.app.models.article import Article
from backend.app.services.jwt import create_access_token


@pytest.fixture(scope="session")
def event_loop():
    """Create event loop for async tests."""
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()


@pytest.fixture(scope="function")
async def session() -> AsyncGenerator[AsyncSession, None]:
    """Create test database session."""
    async with AsyncSession(engine) as session:
        # Create tables
        async with engine.begin() as conn:
            await conn.run_sync(SQLModel.metadata.create_all)

        yield session

        # Cleanup
        async with engine.begin() as conn:
            await conn.run_sync(SQLModel.metadata.drop_all)


@pytest.fixture(scope="function")
async def client(session: AsyncSession) -> AsyncGenerator[AsyncClient, None]:
    """Create test HTTP client."""

    async def override_get_session():
        yield session

    app.dependency_overrides[get_async_session] = override_get_session

    async with AsyncClient(app=app, base_url="http://test") as client:
        yield client

    app.dependency_overrides.clear()


@pytest.fixture
async def test_user(session: AsyncSession) -> User:
    """Create test user."""
    user = User(
        telegram_id=123456789,
        username="testuser",
        first_name="Test",
        last_name="User",
        is_admin=False,
        is_active=True,
    )
    session.add(user)
    await session.commit()
    await session.refresh(user)
    return user


@pytest.fixture
def test_user_token(test_user: User) -> str:
    """Create JWT token for test user."""
    return create_access_token(user_id=test_user.id)


@pytest.fixture
async def admin_user(session: AsyncSession) -> User:
    """Create admin user."""
    user = User(
        telegram_id=987654321,
        username="admin",
        first_name="Admin",
        last_name="User",
        is_admin=True,
        is_active=True,
    )
    session.add(user)
    await session.commit()
    await session.refresh(user)
    return user


@pytest.fixture
def admin_token(admin_user: User) -> str:
    """Create JWT token for admin user."""
    return create_access_token(user_id=admin_user.id)


@pytest.fixture
async def test_article(session: AsyncSession, test_user: User) -> Article:
    """Create test article."""
    article = Article(
        user_id=test_user.id,
        name="Test Article",
        type="expense",
        description="Test description",
        is_global=False,
    )
    session.add(article)
    await session.commit()
    await session.refresh(article)
    return article


@pytest.fixture
async def other_user_{model_name}(session: AsyncSession) -> {ModelName}:
    """Create {model_name} owned by different user (for isolation tests)."""
    other_user = User(
        telegram_id=111222333,
        username="otheruser",
        first_name="Other",
        last_name="User",
    )
    session.add(other_user)
    await session.flush()

    {model_name_lower} = {ModelName}(
        user_id=other_user.id,
        name="Other User {ModelName}",
    )
    session.add({model_name_lower})
    await session.commit()
    await session.refresh({model_name_lower})
    return {model_name_lower}
```

## Команды для тестирования

### Запуск всех тестов

```bash
# Backend тесты
cd backend
pytest

# Bot тесты
cd bot
pytest
```

### Запуск конкретного типа тестов

```bash
# Only unit tests
pytest tests/unit

# Only integration tests
pytest tests/integration

# Only e2e tests
pytest tests/e2e

# Only specific endpoint tests
pytest tests/endpoints/test_articles.py

# Only specific test function
pytest tests/endpoints/test_articles.py::test_create_article_success
```

### Coverage отчет

```bash
# Run with coverage
pytest --cov=backend --cov-report=html

# Open HTML report
open htmlcov/index.html

# Terminal coverage report
pytest --cov=backend --cov-report=term-missing
```

### Code Quality проверки

```bash
# Linting (ruff)
ruff check backend/

# Auto-fix linting issues
ruff check --fix backend/

# Formatting (black)
black backend/

# Check formatting without changes
black --check backend/

# Type checking (mypy)
mypy backend/

# All quality checks at once
ruff check backend/ && black --check backend/ && mypy backend/
```

## Проверочный чеклист

После создания тестов проверь:

- [ ] Unit тесты покрывают все CRUD операции
- [ ] Протестирована user isolation (404 для чужих данных)
- [ ] Протестировано SCD Type 2 versioning (для dimension таблиц)
- [ ] Протестированы error cases (401, 403, 404, 422)
- [ ] Протестирована валидация входных данных
- [ ] Integration тесты покрывают complete workflows
- [ ] Coverage >= 80%
- [ ] Все тесты проходят (green)
- [ ] Нет linting errors
- [ ] Code отформатирован (black)
- [ ] Type hints проверены (mypy)

## Связанные скилы

- **api-development**: для тестирования созданных endpoints
- **db-management**: для тестирования миграций
- **bot-development**: для тестирования bot handlers

## Примеры использования

### Пример 1: Создать тесты для endpoint

```
Создай unit тесты для endpoint /api/v1/articles.
Покрой все CRUD операции, user isolation, SCD Type 2 versioning.
```

### Пример 2: Запустить тесты с coverage

```
Запусти все backend тесты с coverage отчетом.
Покажи файлы с coverage < 80%.
```

### Пример 3: Проверить quality

```
Проверь качество кода в backend/:
- Запусти ruff linting
- Проверь formatting (black)
- Запусти type checking (mypy)
Исправь найденные проблемы.
```

## Часто задаваемые вопросы

**Q: Как мокировать API client в bot тестах?**

A: Используй pytest-mock или unittest.mock:
```python
@pytest.mark.asyncio
async def test_bot_handler(mocker):
    mock_api = mocker.patch("bot.utils.api_client.get_api_client")
    mock_api.return_value.list_articles.return_value = {"articles": [...]}
    # Test handler
```

**Q: Как тестировать SCD Type 2?**

A: Проверяй что:
1. UPDATE создает новую запись с новым ID
2. Старая запись имеет is_current=False
3. Старая запись имеет valid_to != 9999-12-31
4. Новая запись имеет is_current=True

**Q: Нужно ли тестировать каждый endpoint?**

A: Да! Минимум: success case, 401 unauthorized, 404 not found, user isolation.
