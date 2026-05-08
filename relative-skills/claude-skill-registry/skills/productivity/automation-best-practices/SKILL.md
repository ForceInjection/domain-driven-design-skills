---
name: automation-best-practices
description: Best practices for writing reliable browser automation scripts with Intuned. Use when writing, reviewing, or editing automation code, scraping scripts, or browser-based workflows. Provides guidance on selectors, waiting strategies, anti-detection, performance optimization, and SDK patterns.
allowed-tools: Read, Glob, Grep, Edit, Write
---
# Intuned Automation Best Practices

This skill provides comprehensive guidance for writing reliable, efficient, and maintainable browser automation scripts using the Intuned platform and SDK.

---

# Performance optimization

> **Reference:** [docs/03-how-to/solve/make-automations-faster.mdx](docs/03-how-to/solve/make-automations-faster.mdx)

## Waiting strategies

**Never use arbitrary delays:**

```typescript
// Bad - wastes time or fails unpredictably
await page.waitForTimeout(5000);

// Good - waits for specific conditions
await page.locator("#data-table").waitFor({ state: "visible" });
```

**Use DOM and network settling helpers:**

```typescript
// After actions that modify the DOM
await waitForDomSettled({
  source: page,
  settleDurationMs: 500,
  timeoutInMs: 30000
});

// After navigation or API calls
await withNetworkSettledWait(async (page) => {
  await page.click("button.load-data");
}, { page, timeoutInMs: 30000 });
```

**Set shorter timeouts for fast pages:**

```typescript
page.setDefaultTimeout(10000); // 10 seconds instead of 30
```

## Network interception for data extraction

> **Reference:** [docs/01-learn/recipes/network-interception.mdx](docs/01-learn/recipes/network-interception.mdx)

Intercept API responses directly instead of parsing the DOM (often 10x faster):

```typescript
let apiData: any;

page.on("response", async (response) => {
  if (response.url().includes("/api/products")) {
    apiData = await response.json();
  }
});

await withNetworkSettledWait(async (page) => {
  await page.click("button.load-products");
}, { page });

return apiData;
```

## Efficient list extraction

**Avoid iterating with locators** - each locator auto-waits, adding overhead per item:

```typescript
// Bad - multiple round trips
const items = await page.locator(".product-card").all();
for (const item of items) {
  const name = await item.locator(".name").textContent();
}

// Good - wait once, extract all in single evaluate
await page.locator(".product-card").first().waitFor({ state: "visible" });
const products = await page.evaluate(() => {
  return Array.from(document.querySelectorAll(".product-card")).map(card => ({
    name: card.querySelector(".name")?.textContent?.trim(),
    price: card.querySelector(".price")?.textContent?.trim()
  }));
});
```

## Use fill() instead of pressSequentially()

```typescript
// Slow - types character by character
await page.locator("input").pressSequentially("hello@example.com");

// Fast - instant input
await page.locator("input").fill("hello@example.com");
```

## Build URLs directly

```typescript
// Slow - clicking through filters
await page.click("[data-category='electronics']");

// Fast - navigate directly with query params
await page.goto("https://example.com/products?category=electronics");
```

---

# Cost optimization

> **Reference:** [docs/03-how-to/solve/optimize-cost.mdx](docs/03-how-to/solve/optimize-cost.mdx)

## Compute optimization

- Follow all performance tips (faster automations use less compute)
- Combine related operations (pagination in single run vs. multiple runs)
- Speed up AuthSession checks
- Reduce retries by fixing root causes

## AI cost optimization

- Use cheaper models when appropriate
- Leverage Intuned SDK caching
- Replace AI with deterministic code when possible

## Defer heavy processing

Move expensive operations outside the browser context:

```typescript
// Bad - heavy processing in browser
const result = await page.evaluate(() => {
  return processData(document.body.innerHTML);
});

// Good - extract raw data, process afterward
const rawData = await page.evaluate(() => document.body.innerHTML);
const result = processData(rawData);
```

---

# Anti-detection strategies

> **Reference:** [docs/02-features/stealth-mode-captcha-solving-proxies.mdx](docs/02-features/stealth-mode-captcha-solving-proxies.mdx)

## Incremental feature enablement

Start simple and add features only as needed:

| Blocking type | Solution |
| --- | --- |
| IP-based blocking | Proxies |
| Headless detection | Headful mode |
| Fingerprint/automation detection | Stealth mode + Headful |
| CAPTCHAs | CAPTCHA solving (requires Headful) |

## Proxy strategy

- **Test without proxies first** - many sites work fine without them
- **Start with cheaper options:** Datacenter → ISP → Residential (only for heavily protected sites)
- **Rotate proxies** to avoid rate limiting
- **Use consistent IPs for authenticated sessions** - configure at AuthSession level
- **Monitor residential proxy usage** - they bill per GB

## Headful mode

Enable for sites with fingerprint detection:

```json
{
  "browserMode": "headful"
}
```

Required for CAPTCHA solving and better browser fingerprints.

## Stealth mode

Patches automation framework leaks:

```json
{
  "stealthMode": true
}
```

Notes: Requires Playwright v1.55+, works best with headful mode, platform only.

## CAPTCHA solving

Supported types: Google reCAPTCHA v2, hCaptcha, AWS CAPTCHA, Cloudflare managed challenge, GeeTest, Lemin, custom image/text CAPTCHAs.

---

# Pagination and infinite content

## Pagination

> **Reference:** [docs/01-learn/recipes/pagination.mdx](docs/01-learn/recipes/pagination.mdx)

```typescript
async function scrapeAllPages(page: Page) {
  const allProducts: Product[] = [];
  let currentPage = 1;
  const maxPages = 100;

  while (currentPage <= maxPages) {
    const products = await extractProducts(page);
    allProducts.push(...products);

    const nextButton = page.locator("button.next-page");
    if (!(await nextButton.isVisible())) break;

    await nextButton.click();
    await page.waitForLoadState("networkidle");
    currentPage++;
  }

  return allProducts;
}
```

## Load more buttons

> **Reference:** [docs/01-learn/recipes/load-more-button.mdx](docs/01-learn/recipes/load-more-button.mdx)

```typescript
async function loadAllContent(page: Page) {
  const maxClicks = 50;
  let clicks = 0;
  const loadMoreButton = page.locator("button:has-text('Load More')");

  while (clicks < maxClicks) {
    if (!(await loadMoreButton.isVisible())) break;
    await loadMoreButton.click();
    await waitForDomSettled({ source: page });
    clicks++;
  }

  return await extractAllProducts(page);
}
```

## Infinite scrolling

> **Reference:** [docs/01-learn/recipes/infinite-scrolling.mdx](docs/01-learn/recipes/infinite-scrolling.mdx)

```typescript
await scrollToLoadContent({
  source: page,
  maxScrolls: 50,
  delayInMs: 100,
  minHeightChange: 100
});

const products = await extractProducts(page);
```

---

# Data extraction patterns

## AI-based extraction

> **Reference:** [docs/01-learn/recipes/ai-scraper.mdx](docs/01-learn/recipes/ai-scraper.mdx)

Use when page structure is unpredictable:

```typescript
import { z } from "zod";

const ProductSchema = z.object({
  name: z.string(),
  price: z.number(),
  rating: z.number().optional(),
  inStock: z.boolean()
});

const products = await extractStructuredData({
  source: page,
  dataSchema: ProductSchema,
  prompt: "Extract all product information from this page"
});
```

```python
from pydantic import BaseModel

class Product(BaseModel):
    name: str
    price: float
    rating: float | None = None
    in_stock: bool

products = await extract_structured_data(
    page=page,
    data_schema=Product,
    prompt="Extract all product information from this page"
)
```

**When to use:** Unpredictable page structures, content that varies, fallback when selectors fail.

**When NOT to use:** Predictable structures (use deterministic code), high-volume scraping (adds cost).

---

# Authentication and sessions

## AuthSessions

> **Reference:** [docs/02-features/auth-sessions.mdx](docs/02-features/auth-sessions.mdx)

**Implement lightweight check API:**

```typescript
// check.ts - runs before every Run
export default async function check(page: Page) {
  // Check for authenticated content, not absence of login
  const userMenu = page.locator("[data-testid='user-menu']");
  return await userMenu.isVisible({ timeout: 5000 });
}
```

**Choose the right type:**
- `credentials`: Standard login flows
- `runtime`: Changing credentials (OTPs, temporary tokens)
- `recorder`: Complex MFA, biometrics, human interaction

**Session management:**
- Never share AuthSessions across users
- Keep check API fast (runs before every Run)

## 2FA/OTP handling

> **Reference:** [docs/01-learn/recipes/two-FA.mdx](docs/01-learn/recipes/two-FA.mdx)

```typescript
import TOTP from "totp-generator";

async function loginWith2FA(page: Page, username: string, password: string, totpSecret: string) {
  await page.fill("[name='username']", username);
  await page.fill("[name='password']", password);
  await page.click("button[type='submit']");

  await page.locator("[name='otp']").waitFor({ state: "visible" });

  const otp = TOTP.generate(totpSecret, { digits: 6 }).otp;
  await page.fill("[name='otp']", otp);
  await page.click("button[type='submit']");
}
```

---

# Project structure

> **Reference:** [docs/03-how-to/solve/structure-intuned-projects.mdx](docs/03-how-to/solve/structure-intuned-projects.mdx)

## API design principles

- **One API per logical unit of work** - each can succeed/fail independently
- **Make APIs retriable** - same parameters should work on retry

**Common patterns:**

| Pattern | APIs | Use case |
| --- | --- | --- |
| List + Details | `list`, `details` | Entity scrapers |
| Map + Scrape | `map`, `scrape` | Crawlers |
| Single action | `check`, `download` | Utilities |

## When to split projects

**Split when:** Different sites, different auth, changing independently.

**Combine when:** Same platform, shared auth, shared code.

---

# File operations

## Download files

> **Reference:** [docs/01-learn/recipes/download-file.mdx](docs/01-learn/recipes/download-file.mdx)

```typescript
const download = await downloadFile({
  page,
  trigger: page.locator("a.download"),
  timeoutInMs: 5000
});

const filename = download.suggestedFilename();
```

## Upload to S3

> **Reference:** [docs/01-learn/recipes/upload-files.mdx](docs/01-learn/recipes/upload-files.mdx)

```typescript
const uploaded = await uploadFileToS3({
  file: download,
  s3Key: "downloads/file.pdf"
});

const signedUrl = await uploaded.getSignedUrl();
```

---

# Long-running operations

## Timeout extension

> **Reference:** [docs/01-learn/recipes/long-running-api.mdx](docs/01-learn/recipes/long-running-api.mdx), [docs/05-references/runtime-sdk-typescript/extend-timeout.mdx](docs/05-references/runtime-sdk-typescript/extend-timeout.mdx)

For operations exceeding the default 10-minute timeout (supports up to 6 hours):

```typescript
while (hasMorePages) {
  await processPage(page);
  extendTimeout(); // Reset timer after each unit of work
}
```

## Payload extension

> **Reference:** [docs/01-learn/recipes/extend-payload.mdx](docs/01-learn/recipes/extend-payload.mdx), [docs/05-references/runtime-sdk-typescript/extend-payload.mdx](docs/05-references/runtime-sdk-typescript/extend-payload.mdx)

Chain follow-up API calls dynamically:

```typescript
const products = await extractProducts(page);

for (const product of products) {
  extendPayload({
    api: "details",
    params: { productId: product.id }
  });
}
```

---

# Error handling and debugging

> **Reference:** [docs/02-features/observability-monitoring-logs.mdx](docs/02-features/observability-monitoring-logs.mdx), [docs/05-references/error-codes.mdx](docs/05-references/error-codes.mdx)

## Debugging with trace viewer

- Replay browser session step-by-step
- Inspect network requests
- Check DOM snapshots
- Analyze failed selectors

## Retry strategy

- Use AuthSession auto-recreation for auth failures
- Fix root causes instead of relying on retries
- Reduce retries for failing runs (each retry consumes compute)

---

# Intuned SDK reference

## Navigation

> **SDK Source:** [intuned-sdk/typescript-sdk/src/helpers/gotoUrl.ts](intuned-sdk/typescript-sdk/src/helpers/gotoUrl.ts)

```typescript
await goToUrl({
  page,
  url: "https://example.com",
  waitForLoadState: "load",
  retries: 3,
  timeoutInMs: 30000
});
```

## DOM monitoring

> **SDK Source:** [intuned-sdk/typescript-sdk/src/helpers/waitForDomSettled.ts](intuned-sdk/typescript-sdk/src/helpers/waitForDomSettled.ts), [intuned-sdk/typescript-sdk/src/helpers/withNetworkSettledWait.ts](intuned-sdk/typescript-sdk/src/helpers/withNetworkSettledWait.ts)

```typescript
await waitForDomSettled({
  source: page,
  settleDurationMs: 500,
  timeoutInMs: 30000
});

await withNetworkSettledWait(async (page) => {
  await page.click("button");
}, { page, timeoutInMs: 30000 });
```

## Scrolling and loading

> **SDK Source:** [intuned-sdk/typescript-sdk/src/helpers/scrollToLoadContent.ts](intuned-sdk/typescript-sdk/src/helpers/scrollToLoadContent.ts), [intuned-sdk/typescript-sdk/src/helpers/clickUntilExhausted.ts](intuned-sdk/typescript-sdk/src/helpers/clickUntilExhausted.ts)

```typescript
await scrollToLoadContent({
  source: page,
  maxScrolls: 50,
  minHeightChange: 100
});

await clickUntilExhausted({
  page,
  buttonLocator: page.locator("button.load-more"),
  containerLocator: page.locator(".results"),
  maxClicks: 50
});
```

## AI extraction

> **SDK Source:** [intuned-sdk/typescript-sdk/src/ai/extractStructuredData.ts](intuned-sdk/typescript-sdk/src/ai/extractStructuredData.ts)

```typescript
const data = await extractStructuredData({
  source: page,
  dataSchema: MySchema,
  strategy: "HTML", // or "IMAGE", "MARKDOWN"
  enableCache: true,
  maxRetries: 3
});
```

## File operations

> **SDK Source:** [intuned-sdk/typescript-sdk/src/helpers/downloadFile.ts](intuned-sdk/typescript-sdk/src/helpers/downloadFile.ts), [intuned-sdk/typescript-sdk/src/helpers/uploadFileToS3.ts](intuned-sdk/typescript-sdk/src/helpers/uploadFileToS3.ts)

```typescript
const download = await downloadFile({
  page,
  trigger: page.locator("a.download"),
  timeoutInMs: 5000
});

const uploaded = await uploadFileToS3({
  file: download,
  s3Key: "downloads/file.pdf"
});
```

---

# Claude recommendations

The following are general best practices not explicitly documented in Intuned docs but recommended for reliable automation:

## Core principles

- **Reliability over speed.** A slow automation that always works is better than a fast one that fails intermittently.
- **Explicit over implicit.** Wait for specific conditions, not arbitrary timeouts.
- **Simple over clever.** Start with the simplest approach. Add complexity only when needed.

## Selector best practices

**Use stable, specific selectors.** Avoid brittle selectors that depend on element order or styling.

**Prefer semantic selectors** (Playwright's role-based queries are more resilient to DOM changes):

```typescript
// Preferred - semantic selectors
page.getByRole("button", { name: "Submit" })
page.getByText("Add to cart")
page.getByLabel("Email address")
page.getByPlaceholder("Enter your name")
page.getByTestId("product-card")

// Avoid - fragile selectors
page.locator("div:nth-child(3) > button")
page.locator(".btn-primary")
```

**Selector priority order:**

1. `data-testid` or similar test attributes
2. `getByRole()` with accessible name
3. `getByLabel()` for form elements
4. `getByText()` for unique text content
5. `getByPlaceholder()` for inputs
6. CSS selectors with IDs
7. CSS selectors with stable classes (last resort)

## Batch evaluate calls

Each `evaluate()` is a round trip to the browser:

```typescript
// Bad - multiple round trips
const title = await page.evaluate(() => document.title);
const url = await page.evaluate(() => window.location.href);

// Good - single batched call
const data = await page.evaluate(() => ({
  title: document.title,
  url: window.location.href
}));
```

## Navigate to iframe URLs directly

```typescript
// Slow - using frameLocator
const frame = page.frameLocator("iframe#content");
await frame.locator("button").click();

// Fast - navigate directly to iframe source
const iframeSrc = await page.locator("iframe#content").getAttribute("src");
await page.goto(iframeSrc);
```

## Respectful automation

- Check site's `robots.txt` and terms of service
- Add delays between requests for high-volume scraping
- Don't overwhelm target servers

## Common error patterns

| Error | Likely cause | Solution |
| --- | --- | --- |
| Timeout | Slow page, wrong selector | Increase timeout, fix selector |
| Element not found | DOM changed, wrong selector | Update selector, use stable attributes |
| Navigation failed | Page blocked, network issue | Add proxy, retry with backoff |
| Auth expired | Session timeout | Implement session refresh |

## Common pitfalls to avoid

| Pitfall | Better approach |
| --- | --- |
| Using `waitForTimeout()` with fixed delays | Wait for specific conditions |
| Returning large data from `evaluate()` | Extract only needed fields |
| Iterating with locators for large lists | Batch extract with single `evaluate()` |
| Checking for login form absence | Verify authenticated content presence |
| Over-using AI agents | Use deterministic code for known patterns |
| Not closing resources | Always close pages/browsers in finally blocks |
| Using `pressSequentially()` for input | Use `fill()` for instant input |
| Generic selectors like `.btn-primary` | Use semantic selectors or test attributes |
| Hard-coded credentials in code | Use environment variables or 1Password |

## Code review checklist

Before deploying automation code, verify:

- [ ] Selectors use stable attributes (data-testid, roles, labels)
- [ ] No arbitrary `waitForTimeout()` calls
- [ ] Network/DOM settling helpers used appropriately
- [ ] Lists extracted in single `evaluate()` call
- [ ] Error handling for expected failures
- [ ] Timeouts set appropriately for page complexity
- [ ] AuthSession check API is lightweight
- [ ] No hard-coded credentials or secrets
- [ ] Proxy strategy matches site requirements
- [ ] Anti-detection features enabled only if needed
- [ ] Resources cleaned up (pages closed, etc.)
- [ ] Pagination has max limit to prevent infinite loops

---

# Output format

When reviewing automation code, use this structure:

```markdown
## Automation Code Review

**Files Reviewed:** [list]
**Overall Assessment:** [brief summary]

### Issues by Priority

#### High Priority
[Reliability issues - incorrect waits, fragile selectors]

#### Medium Priority
[Performance issues - inefficient extraction, missing batching]

#### Low Priority
[Style and maintainability]

### Detailed Feedback

#### [Filename:line]
**Issue:** [description]
**Current:** `[code]`
**Suggested:** `[code]`
**Reason:** [explanation]

### What Works Well
[Positive highlights]
```
