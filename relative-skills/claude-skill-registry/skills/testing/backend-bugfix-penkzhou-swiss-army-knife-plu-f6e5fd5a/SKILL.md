---
name: backend-bugfix
description: |
  This skill should be used when the user asks to "debug backend tests", "fix pytest failures", "analyze Python errors", "fix FastAPI bugs", or mentions keywords like "pytest", "IntegrityError", "ValidationError", "SQLAlchemy", "FastAPI". It provides the complete bugfix workflow knowledge including error classification, confidence scoring, and TDD best practices for Python/FastAPI backends.
version: 2.1.0
---

# Backend Bugfix Workflow Skill

本 skill 提供后端测试 bugfix 的完整工作流知识，包括错误分类体系、置信度评分系统和 TDD 最佳实践。

## 错误分类体系

后端测试失败主要分为以下类型（按频率排序）：

### 1. 数据库错误（30%）

**症状**：数据库连接失败、查询错误、事务问题

**识别特征**：

- `IntegrityError`、`OperationalError`
- `sqlalchemy.exc.*` 异常
- `UNIQUE constraint failed`
- 事务未提交或未回滚

**解决策略**：正确处理事务边界

```python
# Before - 事务未正确处理
def create_user(db: Session, user: UserCreate):
    db_user = User(**user.dict())
    db.add(db_user)
    db.commit()  # 失败时无回滚
    return db_user

# After - 使用 try/except 确保事务安全
def create_user(db: Session, user: UserCreate):
    try:
        db_user = User(**user.dict())
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        return db_user
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=409, detail="User already exists")
```

### 2. 验证错误（25%）

**症状**：输入验证失败、Schema 不匹配

**识别特征**：

- `ValidationError`
- `pydantic.error_wrappers`
- `422 Unprocessable Entity`
- `field required` 错误

**解决策略**：完善 Pydantic Schema

```python
# Before - 缺少验证
class UserCreate(BaseModel):
    email: str  # 没有格式验证

# After - 使用 Pydantic 验证器
class UserCreate(BaseModel):
    email: EmailStr

    @field_validator('email')
    @classmethod
    def email_must_be_valid(cls, v):
        if not v or '@' not in v:
            raise ValueError('Invalid email format')
        return v.lower()
```

### 3. API 错误（20%）

**症状**：端点返回错误状态码、路由不匹配

**识别特征**：

- `HTTPException`
- `404 Not Found`、`405 Method Not Allowed`
- 响应格式不符合预期

**解决策略**：检查路由定义和请求方法

```python
# 确保端点定义正确
@router.get("/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
```

### 4. 认证错误（10%）

**症状**：认证失败、权限不足

**识别特征**：

- `401 Unauthorized`
- `403 Forbidden`
- Token 相关错误
- `credentials` 验证失败

**解决策略**：检查认证流程和 Token 处理

```python
# 确保 Token 验证正确
async def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    return user_id
```

### 5. 异步错误（8%）

**症状**：异步操作超时、并发问题

**识别特征**：

- `TimeoutError`
- `CancelledError`
- `asyncio` 相关异常
- 缺少 `await` 关键字

**解决策略**：正确使用 async/await

```python
# Before - 忘记 await
async def get_data():
    result = fetch_from_external_api()  # 缺少 await
    return result

# After - 正确等待异步操作
async def get_data():
    result = await fetch_from_external_api()
    return result
```

### 6. 配置错误（5%）

**症状**：配置加载失败、环境变量缺失

**识别特征**：

- `KeyError`
- `environment` 相关错误
- `settings` 加载失败

**解决策略**：使用 Pydantic Settings 管理配置

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    secret_key: str

    class Config:
        env_file = ".env"

settings = Settings()
```

## 置信度评分系统

### 评分标准（0-100）

| 分数 | 级别 | 行为 |
| ------ | ------ | ------ |
| 80+ | 高 | 自动执行 |
| 60-79 | 中 | 标记验证后继续 |
| 40-59 | 低 | 暂停询问用户 |
| <40 | 不确定 | 停止收集信息 |

### 置信度计算

```text
置信度 = 证据质量(40%) + 模式匹配(30%) + 上下文完整性(20%) + 可复现性(10%)
```

**证据质量**：

- 高：有完整堆栈、行号、可稳定复现
- 中：有错误信息但缺上下文
- 低：仅有模糊描述

**模式匹配**：

- 高：完全匹配已知错误模式
- 中：部分匹配
- 低：未知错误类型

**上下文完整性**：

- 高：测试代码 + 源代码 + 配置 + 数据库 Schema
- 中：只有测试或源代码
- 低：只有错误信息

**可复现性**：

- 高：每次运行都复现
- 中：偶发（可能与数据或并发相关）
- 低：环境相关

## TDD 流程

### RED Phase（写失败测试）

```python
import pytest
from fastapi.testclient import TestClient

def test_create_user_duplicate_email(client: TestClient, db_session):
    """测试重复邮箱应返回 409"""
    # 1. 设置前置条件
    client.post("/api/users", json={"email": "test@example.com", "name": "User 1"})

    # 2. 执行被测操作
    response = client.post("/api/users", json={"email": "test@example.com", "name": "User 2"})

    # 3. 断言期望结果
    assert response.status_code == 409
    assert "already exists" in response.json()["detail"]
```

### GREEN Phase（最小实现）

```python
# 只写让测试通过的最小代码
# 不要优化，不要添加额外功能
def create_user(db: Session, user: UserCreate):
    existing = db.query(User).filter(User.email == user.email).first()
    if existing:
        raise HTTPException(status_code=409, detail="User already exists")
    # ... 创建用户逻辑
```

### REFACTOR Phase（重构）

```python
# 改善代码结构
# 保持测试通过
# 消除重复
# 提取公共逻辑到服务层
```

## 质量门禁

| 检查项 | 标准 |
| ---------- | ------ |
| 测试通过率 | 100% |
| 代码覆盖率 | >= 90% |
| 新代码覆盖率 | 100% |
| Lint (flake8) | 无错误 |
| TypeCheck (mypy) | 无错误 |

## pytest 常用模式

### Fixtures

```python
@pytest.fixture
def db_session():
    """创建测试数据库会话"""
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    Session = sessionmaker(bind=engine)
    session = Session()
    yield session
    session.close()

@pytest.fixture
def client(db_session):
    """创建测试客户端"""
    def override_get_db():
        yield db_session
    app.dependency_overrides[get_db] = override_get_db
    return TestClient(app)
```

### 异步测试

```python
import pytest

@pytest.mark.asyncio
async def test_async_operation():
    result = await some_async_function()
    assert result is not None
```

### 参数化测试

```python
@pytest.mark.parametrize("status_code,detail", [
    (400, "Invalid input"),
    (404, "Not found"),
    (409, "Already exists"),
])
def test_error_responses(client, status_code, detail):
    # 测试多种错误场景
    pass
```

## 常用命令

```bash
# 运行后端测试
make test TARGET=backend

# 运行特定测试
make test TARGET=backend FILTER=test_create_user

# 或使用 pytest 直接运行
pytest tests/ -k "test_create_user" -v

# 覆盖率检查
pytest --cov=app --cov-report=term-missing --cov-fail-under=90

# Lint 检查
flake8 app/ tests/

# 类型检查
mypy app/

# 完整 QA
make qa
```

## 相关文档

文档路径由配置指定（`best_practices_dir`），使用以下关键词搜索：

- **测试最佳实践**：关键词 "testing", "pytest", "backend"
- **数据库操作**：关键词 "database", "sqlalchemy", "transaction"
- **API 设计**：关键词 "api", "endpoint", "fastapi"
- **问题诊断**：关键词 "troubleshooting", "debugging"
