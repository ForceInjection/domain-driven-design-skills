---
name: performance-audit
description: Run Lighthouse audit and verify Core Web Vitals. Use at project end before release. Triggers on "performance", "Lighthouse", "Core Web Vitals", "speed test", "page speed".
---

# Performance Audit

Verify website performance meets Core Web Vitals standards.

## Core Web Vitals Targets

| Metric | Target | What it measures |
|--------|--------|------------------|
| LCP | < 2.5s | Largest Contentful Paint (loading) |
| FID | < 100ms | First Input Delay (interactivity) |
| CLS | < 0.1 | Cumulative Layout Shift (stability) |

## Audit Process

### 1. Run Lighthouse

```bash
# Using Chrome DevTools
# 1. Open site in Chrome
# 2. DevTools > Lighthouse tab
# 3. Run audit (Mobile + Desktop)

# Or CLI
npx lighthouse https://localhost:3000 --view
```

### 2. Check Results

**Target Scores:**
- Performance: > 90
- Accessibility: > 90
- Best Practices: > 90
- SEO: > 90

### 3. Common Issues & Fixes

**LCP Issues:**
- [ ] Add `priority` to above-fold images
- [ ] Preload critical fonts
- [ ] Use Next.js Image component
- [ ] Enable image optimization

**CLS Issues:**
- [ ] Set explicit width/height on images
- [ ] Reserve space for dynamic content
- [ ] Avoid layout shifts from fonts

**FID Issues:**
- [ ] Minimize JavaScript bundle
- [ ] Use dynamic imports for heavy components
- [ ] Defer non-critical scripts

## Checklist

**Images:**
- [ ] All images use WebP format
- [ ] Above-fold images have `priority`
- [ ] Images have width/height set
- [ ] Responsive images use `sizes` prop

**Fonts:**
- [ ] Fonts loaded via next/font
- [ ] Font display: swap enabled
- [ ] No flash of unstyled text

**JavaScript:**
- [ ] No unused dependencies
- [ ] Dynamic imports for heavy components
- [ ] No render-blocking scripts

**General:**
- [ ] Lighthouse Performance > 90
- [ ] No console errors
- [ ] Mobile responsive
- [ ] HTTPS enabled
