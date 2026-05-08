---
name: qcc-release
description: Use for version release, GoReleaser automation, and publishing workflows in qcc_plus project
---

# QCC Plus 版本发布

## 语义化版本

格式：`vX.Y.Z`

| 版本号 | 说明 | 示例 |
|--------|------|------|
| X (主版本) | 不兼容的 API 变更 | v2.0.0 |
| Y (次版本) | 向后兼容的功能新增 | v1.1.0 |
| Z (修订号) | 向后兼容的问题修正 | v1.1.1 |

## GoReleaser 自动化发布（推荐）

发布新版本只需：

```bash
git tag v1.2.0
git push origin v1.2.0
```

GitHub Actions 自动完成：
- 构建多平台 Go 二进制（Linux/macOS/Windows，amd64/arm64）
- 注入版本信息（version、git commit、build date）
- 构建并推送 Docker 镜像（amd64 + arm64 multi-arch）
- 生成分类 CHANGELOG
- 创建 GitHub Release 并上传构建产物
- 更新 Docker Hub 仓库信息

## 发布流程

### 阶段 1: 测试环境验证
```bash
git checkout test
# 开发 → 提交 → 推送
git push origin test  # 自动部署到测试环境
```

### 阶段 2: Pre-release（可选）
```bash
git tag v1.3.0-beta.1
git push origin v1.3.0-beta.1  # 发布到 Docker Hub (Pre-release)
```

### 阶段 3: 正式发布
```bash
git tag v1.x.x
git push origin v1.x.x  # 发布到 Docker Hub + GitHub Release
```

## 发布后更新

1. 更新 CLAUDE.md 中的"当前版本"字段
2. 更新 CHANGELOG.md
3. 验证 Docker 镜像：`docker pull yxhpy520/qcc_plus:vX.Y.Z`
4. 验证版本信息：`curl http://localhost:8000/version`

## 重要提醒

- Docker Hub 用户名是 `yxhpy520`（不是 yxhpy）
- `latest` 标签始终指向最新稳定版本
- 发布前必须确保代码已通过所有测试
- 版本信息通过构建时 ldflags 注入，无需手动修改代码

## 本地测试

```bash
# 检查配置
goreleaser check

# 构建测试（快照模式）
goreleaser build --snapshot --clean

# 完整发布测试（不推送）
goreleaser release --snapshot --clean --skip=publish
```

## GitHub Secrets 配置

| Secret | 说明 |
|--------|------|
| `DOCKER_USERNAME` | Docker Hub 用户名（yxhpy520） |
| `DOCKER_TOKEN` | Docker Hub Personal Access Token |

## Pre-release 版本号规范

- `v1.3.0-alpha.1` - 内部测试，功能不完整
- `v1.3.0-beta.1` - 公开测试，功能基本完整
- `v1.3.0-rc.1` - Release Candidate，准备发布的候选版本
