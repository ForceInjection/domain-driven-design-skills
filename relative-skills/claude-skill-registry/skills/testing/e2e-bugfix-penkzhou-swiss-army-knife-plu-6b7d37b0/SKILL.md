---
name: e2e-bugfix
description: |
  This skill should be used when the user asks to "debug E2E tests", "fix Playwright failures", "fix Cypress tests", "analyze timeout errors", or mentions keywords like "Playwright", "Cypress", "Timeout exceeded", "locator", "selector", "flaky test". It provides the complete bugfix workflow knowledge including error classification, confidence scoring, and E2E-specific debugging techniques.
version: 2.1.0
---

# E2E Bugfix Workflow Skill

本 skill 提供端到端测试 bugfix 的完整工作流知识，包括错误分类体系、置信度评分系统和 E2E 特有的调试技巧。

## 错误分类体系

E2E 测试失败主要分为以下类型（按频率排序）：

### 1. 超时错误（35%）

**症状**：元素等待超时、操作超时

**识别特征**：

- `Timeout 30000ms exceeded`
- `waiting for locator`
- `waiting for element`
- `TimeoutError`

**解决策略**：使用显式等待和合理超时

```typescript
// Before - 硬编码等待
await page.waitForTimeout(5000);
await page.click('.submit-button');

// After - 等待特定条件
await page.waitForSelector('.submit-button', { state: 'visible' });
await page.click('.submit-button');

// 或使用 Playwright 的自动等待
await page.getByRole('button', { name: 'Submit' }).click();
```

**常见原因**：

- 页面加载慢
- 动态内容未渲染
- 网络请求延迟
- 元素被遮挡或不可见

### 2. 选择器错误（25%）

**症状**：找不到元素、选择器匹配多个元素

**识别特征**：

- `strict mode violation`
- `resolved to X elements`
- `element not found`
- `locator.click: Error`

**解决策略**：使用更精确的选择器

```typescript
// Before - 模糊选择器
await page.click('button');  // 可能匹配多个

// After - 精确选择器
// 方法 1：使用 data-testid
await page.click('[data-testid="submit-button"]');

// 方法 2：使用角色和文本
await page.getByRole('button', { name: 'Submit' }).click();

// 方法 3：使用组合选择器
await page.locator('.form-container').getByRole('button').click();
```

**Playwright 推荐选择器优先级**：

1. `getByRole()` - 最语义化
2. `getByTestId()` - 最稳定
3. `getByText()` - 用户可见
4. CSS/XPath - 最后手段

### 3. 断言错误（15%）

**症状**：期望值与实际值不匹配

**识别特征**：

- `expect(...).toHave*`
- `Expected:` vs `Received:`
- `AssertionError`

**解决策略**：使用正确的断言和等待

```typescript
// Before - 立即断言
expect(await page.textContent('.message')).toBe('Success');

// After - 使用自动重试的断言
await expect(page.locator('.message')).toHaveText('Success');

// 异步内容断言
await expect(page.locator('.user-list')).toContainText('John');

// 可见性断言
await expect(page.locator('.modal')).toBeVisible();
```

### 4. 网络错误（12%）

**症状**：API 请求失败、网络拦截问题

**识别特征**：

- `Route handler` 错误
- `net::ERR_*`
- `request failed`
- Mock 数据不生效

**解决策略**：正确配置网络拦截

```typescript
// Mock API 响应
await page.route('**/api/users', async (route) => {
  await route.fulfill({
    status: 200,
    contentType: 'application/json',
    body: JSON.stringify({ users: [{ id: 1, name: 'Test' }] }),
  });
});

// 等待网络请求完成
const responsePromise = page.waitForResponse('**/api/users');
await page.click('.load-users');
const response = await responsePromise;
expect(response.status()).toBe(200);
```

### 5. 导航错误（8%）

**症状**：页面导航失败、URL 不匹配

**识别特征**：

- `page.goto: Error`
- `ERR_NAME_NOT_RESOLVED`
- `navigation timeout`
- URL 重定向问题

**解决策略**：正确处理导航

```typescript
// 等待导航完成
await page.goto('http://localhost:3000/login');
await page.waitForURL('**/dashboard');

// 处理重定向
await Promise.all([
  page.waitForNavigation(),
  page.click('.login-button'),
]);

// 验证 URL
await expect(page).toHaveURL(/.*dashboard/);
```

### 6. 环境错误（3%）

**症状**：浏览器启动失败、测试环境问题

**识别特征**：

- `browser.launch` 失败
- `Target closed`
- `context` 错误
- 端口冲突

**解决策略**：检查环境配置

```typescript
// playwright.config.ts
export default defineConfig({
  webServer: {
    command: 'npm run start',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 120 * 1000,
  },
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
});
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

- 高：有截图、trace、完整堆栈
- 中：有错误信息但缺上下文
- 低：仅有失败描述

**模式匹配**：

- 高：完全匹配已知错误模式
- 中：部分匹配
- 低：未知错误类型

**上下文完整性**：

- 高：测试代码 + 页面代码 + trace + 截图
- 中：只有测试代码
- 低：只有错误信息

**可复现性**：

- 高：每次运行都复现
- 中：偶发（flaky test）
- 低：仅在特定环境失败

## E2E 调试技巧

### 使用 Trace Viewer

```bash
# 运行测试并收集 trace
npx playwright test --trace on

# 查看 trace
npx playwright show-trace trace.zip
```

### 使用 UI 模式调试

```bash
# 启动 UI 模式
npx playwright test --ui

# 或使用调试模式
npx playwright test --debug
```

### 截图和录像

```typescript
// 测试失败时自动截图
test.afterEach(async ({ page }, testInfo) => {
  if (testInfo.status !== 'passed') {
    await page.screenshot({ path: `screenshots/${testInfo.title}.png` });
  }
});

// 录制视频
// playwright.config.ts
use: {
  video: 'on-first-retry',
}
```

### 处理 Flaky Tests

```typescript
// 重试不稳定的测试
test.describe.configure({ retries: 2 });

// 或在配置中设置
export default defineConfig({
  retries: process.env.CI ? 2 : 0,
});
```

## TDD 流程

### RED Phase（写失败测试）

```typescript
import { test, expect } from '@playwright/test';

test('should display error message on invalid login', async ({ page }) => {
  // 1. 导航到页面
  await page.goto('/login');

  // 2. 执行操作
  await page.fill('[data-testid="email"]', 'invalid@email');
  await page.fill('[data-testid="password"]', 'wrong');
  await page.click('[data-testid="submit"]');

  // 3. 断言期望结果
  await expect(page.locator('.error-message')).toHaveText('Invalid credentials');
});
```

### GREEN Phase（最小实现）

```typescript
// 只实现让测试通过的最小功能
// 不要优化，不要添加额外功能
```

### REFACTOR Phase（重构）

```typescript
// 改善测试结构
// 提取 Page Object
// 复用测试辅助函数
```

## Page Object 模式

```typescript
// pages/LoginPage.ts
export class LoginPage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.page.fill('[data-testid="email"]', email);
    await this.page.fill('[data-testid="password"]', password);
    await this.page.click('[data-testid="submit"]');
  }

  async getErrorMessage() {
    return this.page.locator('.error-message');
  }
}

// 使用 Page Object
test('login with invalid credentials', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.goto();
  await loginPage.login('invalid@email', 'wrong');
  await expect(loginPage.getErrorMessage()).toHaveText('Invalid credentials');
});
```

## 质量门禁

| 检查项 | 标准 |
| ---------- | ------ |
| 测试通过率 | 100% |
| 代码覆盖率 | >= 90%（如适用） |
| Lint | 无错误 |
| Flaky Rate | < 5% |

## 常用命令

```bash
# 运行所有 E2E 测试
make test TARGET=e2e

# 或使用 Playwright 直接运行
npx playwright test

# 运行特定测试文件
npx playwright test tests/login.spec.ts

# 运行带标签的测试
npx playwright test --grep @smoke

# 运行 UI 模式
npx playwright test --ui

# 生成测试代码
npx playwright codegen localhost:3000

# 查看测试报告
npx playwright show-report
```

## Playwright 配置示例

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
  ],
  webServer: {
    command: 'npm run start',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

## 相关文档

文档路径由配置指定（`best_practices_dir`），使用以下关键词搜索：

- **选择器策略**：关键词 "selector", "locator", "data-testid"
- **等待策略**：关键词 "wait", "timeout", "retry"
- **网络拦截**：关键词 "intercept", "mock", "route"
- **问题诊断**：关键词 "troubleshooting", "debugging", "flaky"
