---
name: auth-provider
description: |
  认证提供商统一接口，支持 Supabase Auth、Clerk、Firebase Auth 等主流认证服务。
  提供用户注册、登录、OAuth、会话管理、权限验证等功能。
version: 1.0.0
author: AgentFlow Team
triggers:
  - auth
  - 认证
  - 認証
  - login
  - 登录
  - ログイン
  - oauth
  - session
  - jwt
  - supabase auth
  - clerk
  - firebase auth
requirements:
  - supabase>=2.0.0
  - pyjwt>=2.8.0
tags:
  - authentication
  - security
  - identity
  - production-ready
examples:
  - "用户注册和登录"
  - "OAuth 社交登录"
  - "JWT 验证"
  - "会话管理"
---

# Auth Provider Skill

## 概述

统一的认证接口，支持主流认证服务，让 Agent 系统快速实现用户认证。

## 支持的提供商

| 提供商 | 类型 | 免费额度 | 特点 |
|--------|------|----------|------|
| **Supabase Auth** | OSS | 50k MAU | RLS 统合、PostgreSQL 一体 |
| **Clerk** | 商用 | 10k MAU | 最佳 DX、预构建 UI |
| **Firebase Auth** | 商用 | 50k MAU | Google 生态、多平台 |
| **Auth0** | 商用 | 7.5k MAU | 企业级、SAML/LDAP |

## 快速开始

### 1. Supabase Auth

```python
from agentflow.skills.builtin.auth_provider import AuthProvider, SupabaseAuthConfig

# 配置
config = SupabaseAuthConfig(
    url="https://xxx.supabase.co",
    anon_key="eyJ...",
    jwt_secret="your-jwt-secret",  # 用于验证 JWT
)

# 初始化
auth = AuthProvider(provider="supabase", config=config)

# 注册
user = await auth.sign_up(
    email="user@example.com",
    password="secure_password_123",
    metadata={"name": "Test User"},
)

# 登录
session = await auth.sign_in(
    email="user@example.com",
    password="secure_password_123",
)
print(f"访问令牌: {session.access_token}")
print(f"用户 ID: {session.user.id}")

# OAuth 登录
oauth_url = await auth.sign_in_with_oauth(
    provider="google",
    redirect_to="https://myapp.com/auth/callback",
)
print(f"重定向用户到: {oauth_url}")
```

### 2. Clerk

```python
from agentflow.skills.builtin.auth_provider import AuthProvider, ClerkConfig

config = ClerkConfig(
    secret_key="sk_test_...",
    publishable_key="pk_test_...",
)

auth = AuthProvider(provider="clerk", config=config)

# 验证会话令牌
user = await auth.verify_session(token="sess_xxx")

# 获取用户信息
user_info = await auth.get_user(user_id="user_xxx")
```

## 用户管理

### 注册

```python
# 邮箱密码注册
user = await auth.sign_up(
    email="user@example.com",
    password="secure_password",
    metadata={
        "name": "John Doe",
        "role": "user",
    },
    email_confirm=True,  # 需要邮箱确认
)

# 手机号注册（需要配置 SMS 服务）
user = await auth.sign_up_with_phone(
    phone="+81901234567",
    password="secure_password",
)
```

### 登录

```python
# 邮箱密码登录
session = await auth.sign_in(
    email="user@example.com",
    password="secure_password",
)

# Magic Link 登录（无密码）
await auth.sign_in_with_magic_link(
    email="user@example.com",
    redirect_to="https://myapp.com/auth/callback",
)

# OTP 登录
await auth.sign_in_with_otp(
    email="user@example.com",  # 或 phone="+81901234567"
)
# 用户收到验证码后
session = await auth.verify_otp(
    email="user@example.com",
    token="123456",
    type="email",
)
```

### 登出

```python
# 登出当前设备
await auth.sign_out()

# 登出所有设备
await auth.sign_out(scope="global")
```

## OAuth 社交登录

### 支持的提供商

- Google
- Apple (iOS 必须支持)
- GitHub
- Microsoft
- Twitter/X
- Discord
- Slack

### 配置 OAuth

```python
# 发起 OAuth 登录
oauth_url = await auth.sign_in_with_oauth(
    provider="google",
    redirect_to="https://myapp.com/auth/callback",
    scopes=["email", "profile"],
)

# 处理回调
session = await auth.handle_oauth_callback(
    code="auth_code_from_callback",
    state="state_from_callback",
)
```

### Sign in with Apple (iOS 必须)

```python
# iOS 应用需要支持 Apple 登录
oauth_url = await auth.sign_in_with_oauth(
    provider="apple",
    redirect_to="https://myapp.com/auth/callback",
)
```

## 会话管理

### 获取当前会话

```python
# 获取当前会话
session = await auth.get_session()

if session:
    print(f"用户: {session.user.email}")
    print(f"过期时间: {session.expires_at}")
else:
    print("未登录")
```

### 刷新令牌

```python
# 刷新访问令牌
new_session = await auth.refresh_session(
    refresh_token=session.refresh_token,
)
```

### 验证 JWT

```python
# 验证并解析 JWT
payload = await auth.verify_jwt(
    token=request.headers.get("Authorization").replace("Bearer ", ""),
)

user_id = payload.get("sub")
email = payload.get("email")
```

## 用户信息

### 获取用户

```python
# 获取当前用户
user = await auth.get_current_user()

# 获取指定用户（需要管理员权限）
user = await auth.get_user(user_id="user_xxx")
```

### 更新用户

```python
# 更新用户信息
await auth.update_user(
    user_id="user_xxx",
    data={
        "name": "New Name",
        "avatar_url": "https://...",
    },
)

# 更新密码
await auth.update_password(
    current_password="old_password",
    new_password="new_password",
)
```

### 删除用户

```python
# 删除用户（需要管理员权限）
await auth.delete_user(user_id="user_xxx")
```

## 密码重置

```python
# 发送重置邮件
await auth.reset_password_for_email(
    email="user@example.com",
    redirect_to="https://myapp.com/auth/reset-password",
)

# 更新密码（在重置页面）
await auth.update_password_with_token(
    token="reset_token",
    new_password="new_secure_password",
)
```

## 多因素认证 (MFA)

### 启用 TOTP

```python
# 生成 TOTP 密钥
totp = await auth.enroll_mfa(
    factor_type="totp",
    friendly_name="Authenticator App",
)

print(f"二维码 URI: {totp.qr_code}")
print(f"密钥: {totp.secret}")

# 验证并激活
await auth.verify_mfa(
    factor_id=totp.id,
    code="123456",  # 来自 Authenticator App
)
```

### MFA 登录挑战

```python
# 登录时需要 MFA
session = await auth.sign_in(email, password)

if session.mfa_required:
    # 发起 MFA 挑战
    challenge = await auth.create_mfa_challenge(
        factor_id=session.mfa_factors[0].id,
    )
    
    # 验证 MFA
    session = await auth.verify_mfa_challenge(
        challenge_id=challenge.id,
        code="123456",
    )
```

## 中间件/保护路由

### FastAPI 集成

```python
from fastapi import FastAPI, Depends, HTTPException
from fastapi.security import HTTPBearer

app = FastAPI()
security = HTTPBearer()

async def get_current_user(token: str = Depends(security)):
    """验证并获取当前用户."""
    try:
        payload = await auth.verify_jwt(token.credentials)
        return payload
    except AuthError:
        raise HTTPException(401, "Invalid token")

@app.get("/protected")
async def protected_route(user: dict = Depends(get_current_user)):
    return {"message": f"Hello {user['email']}"}

# 角色检查
async def require_admin(user: dict = Depends(get_current_user)):
    if user.get("role") != "admin":
        raise HTTPException(403, "Admin required")
    return user

@app.delete("/admin/users/{user_id}")
async def delete_user(user_id: str, admin: dict = Depends(require_admin)):
    await auth.delete_user(user_id)
    return {"deleted": user_id}
```

### Next.js 中间件

```typescript
// middleware.ts
import { createMiddlewareClient } from '@supabase/auth-helpers-nextjs'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(req: NextRequest) {
  const res = NextResponse.next()
  const supabase = createMiddlewareClient({ req, res })
  
  const { data: { session } } = await supabase.auth.getSession()
  
  if (!session && req.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', req.url))
  }
  
  return res
}
```

## Agent 集成示例

```python
from agentflow.skills import SkillEngine

engine = SkillEngine()

@engine.tool("authenticate_user")
async def authenticate_user(email: str, password: str) -> dict:
    """用户登录"""
    try:
        session = await auth.sign_in(email=email, password=password)
        return {
            "success": True,
            "user_id": session.user.id,
            "access_token": session.access_token,
        }
    except AuthError as e:
        return {"success": False, "error": str(e)}

@engine.tool("verify_token")
async def verify_token(token: str) -> dict:
    """验证访问令牌"""
    try:
        payload = await auth.verify_jwt(token)
        return {
            "valid": True,
            "user_id": payload.get("sub"),
            "email": payload.get("email"),
        }
    except AuthError:
        return {"valid": False}

@engine.tool("get_user_info")
async def get_user_info(user_id: str) -> dict:
    """获取用户信息"""
    user = await auth.get_user(user_id)
    return {
        "id": user.id,
        "email": user.email,
        "name": user.metadata.get("name"),
        "created_at": user.created_at.isoformat(),
    }
```

## 最佳实践

### 1. 环境变量

```python
import os

config = SupabaseAuthConfig(
    url=os.environ["SUPABASE_URL"],
    anon_key=os.environ["SUPABASE_ANON_KEY"],
    jwt_secret=os.environ["SUPABASE_JWT_SECRET"],
)
```

### 2. 错误处理

```python
from agentflow.skills.builtin.auth_provider import (
    AuthError,
    InvalidCredentialsError,
    UserNotFoundError,
    TokenExpiredError,
    EmailNotConfirmedError,
)

try:
    session = await auth.sign_in(email, password)
except InvalidCredentialsError:
    return {"error": "邮箱或密码错误"}
except EmailNotConfirmedError:
    return {"error": "请先确认邮箱"}
except TokenExpiredError:
    return {"error": "会话已过期，请重新登录"}
except AuthError as e:
    logger.error(f"认证错误: {e}")
    return {"error": "认证失败"}
```

### 3. 安全配置

```python
# 启用 RLS（Supabase）
# 在数据库中配置 RLS 策略确保数据隔离

# JWT 配置
config = SupabaseAuthConfig(
    ...
    jwt_expiry=3600,  # 1 小时过期
    refresh_token_expiry=604800,  # 7 天
)

# 密码策略
await auth.sign_up(
    email=email,
    password=password,
    password_options={
        "min_length": 12,
        "require_uppercase": True,
        "require_number": True,
        "require_special": True,
    },
)
```

## 提供商选择指南

| 场景 | 推荐 | 理由 |
|------|------|------|
| 使用 PostgreSQL | Supabase Auth | RLS 集成、数据库一体 |
| 最佳开发体验 | Clerk | 预构建 UI、组织管理 |
| Google 生态 | Firebase Auth | Firestore/FCM 集成 |
| 企业 SSO | Auth0 | SAML/LDAP/Active Directory |

