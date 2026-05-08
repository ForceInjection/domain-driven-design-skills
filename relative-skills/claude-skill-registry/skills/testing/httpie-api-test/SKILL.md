---
name: httpie-api-test
description: API 接口测试工作流，使用 HTTPie 作为核心工具。当用户需要测试 API 接口、执行接口调用、生成测试报告、管理接口依赖关系、或在项目中建立标准化的接口测试流程时使用此 skill。适用于 RESTful API 测试、接口联调、回归测试等场景。
---

# HTTPie API Test

使用 HTTPie 进行 API 测试的标准化工作流。

## 核心工具

HTTPie 比 curl 更优雅。安装:

```bash
# macOS
brew install httpie

# Ubuntu/Debian
apt install httpie

# pip
pip install httpie
```

## API 注册表

在项目根目录创建 `api-registry.md` 作为接口测试的神经中枢。完整格式见 [references/api-registry.md](references/api-registry.md)。

### 基本结构

```markdown
# API Registry

## Environment
| Name | Value |
|------|-------|
| BASE_URL | https://api.example.com |
| TOKEN | Bearer xxx |

## Endpoints

### [GET] /users - 获取用户列表
- Status: tested
- Depends: none
- Last tested: 2024-01-15

**Request:**
http GET $BASE_URL/users Authorization:$TOKEN

**Expected:** 200, 返回用户数组

---

### [POST] /users - 创建用户
- Status: pending
- Depends: none

**Request:**
http POST $BASE_URL/users Authorization:$TOKEN \
  name="张三" email="test@example.com"

**Expected:** 201, 返回新用户对象
```

## 工作流

### 1. 初始化

在项目根目录创建 `api-registry.md`，定义环境变量和接口列表。

### 2. 执行测试

读取注册表，按依赖顺序执行:

```bash
# 设置环境变量
export BASE_URL="https://api.example.com"
export TOKEN="Bearer your-token"

# GET
http GET $BASE_URL/users Authorization:$TOKEN

# POST with JSON body
http POST $BASE_URL/users Authorization:$TOKEN \
  name="测试" email="test@example.com"

# 保存响应
http GET $BASE_URL/users Authorization:$TOKEN > response.json
```

### 3. 更新状态

测试完成后更新注册表中的 `Status` 和 `Last tested` 字段。

### 4. 生成报告

```bash
python scripts/generate_report.py api-registry.md -o test-report.md
```

## HTTPie 速查

```bash
# Headers
http url Header:Value

# 认证
http -a user:pass url

# 表单提交
http -f POST url field=value

# 仅显示 headers
http --headers url

# 详细模式
http --verbose url
```

## 依赖管理

用 `Depends` 字段声明依赖关系:

```markdown
### [DELETE] /users/{id} - 删除用户
- Status: pending
- Depends: POST /users
```

测试时按依赖拓扑排序执行。

## 状态标记

| Status | 含义 |
|--------|------|
| pending | 待测试 |
| tested | 已通过 |
| failed | 测试失败 |
| blocked | 被阻塞 |
| deprecated | 已废弃 |
