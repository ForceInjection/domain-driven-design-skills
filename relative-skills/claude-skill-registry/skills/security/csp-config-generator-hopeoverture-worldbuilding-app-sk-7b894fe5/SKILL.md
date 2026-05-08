---
name: csp-config-generator
description: This skill should be used when the user requests to generate, create, or configure Content Security Policy (CSP) headers for Next.js applications to prevent XSS attacks and control resource loading. It analyzes the application to determine appropriate CSP directives and generates configuration via next.config or middleware. Trigger terms include CSP, Content Security Policy, security headers, XSS protection, generate CSP, configure CSP, strict CSP, nonce-based CSP, CSP directives.
---

# CSP Config Generator

To generate a strict Content Security Policy configuration for Next.js applications, follow these steps systematically.

## Step 1: Analyze Application Resources

Identify all resource types used in the application.

### Discover External Resources

Use Grep to find external resource references:

**Scripts**:
```
- "<script.*src="
- "import.*from.*http"
- "next/script"
```

**Stylesheets**:
```
- "<link.*stylesheet"
- "@import.*url"
- "next/font"
```

**Images**:
```
- "<img.*src="
- "next/image"
- "background-image.*url"
```

**Fonts**:
```
- "@font-face"
- "next/font/google"
- "fonts.googleapis.com"
```

**APIs and Connections**:
```
- "fetch("
- "axios"
- "WebSocket"
```

**Media**:
```
- "<video"
- "<audio"
- "<iframe"
```

### Extract Domains

Collect all unique domains used:
- CDNs (cdnjs.cloudflare.com, unpkg.com)
- APIs (api.stripe.com, *.supabase.co)
- Analytics (google-analytics.com, vercel.com)
- Fonts (fonts.googleapis.com, fonts.gstatic.com)
- Images (cloudinary.com, s3.amazonaws.com)

Consult `references/csp-directives.md` for directive documentation.

## Step 2: Determine CSP Strategy

Choose the appropriate CSP implementation strategy:

### Strategy A: Nonce-Based CSP (Recommended)

Most secure for Next.js apps with inline scripts:
- Use nonce for inline scripts and styles
- Strict directives
- Works with Next.js App Router

### Strategy B: Hash-Based CSP

For static content:
- Use SHA-256 hashes for specific inline scripts
- More restrictive
- Requires rebuilding hashes on changes

### Strategy C: Unsafe-Inline (Not Recommended)

Least secure, only for migration:
- Allows all inline scripts
- Use only temporarily while migrating

Recommend Strategy A (nonce-based) for modern Next.js apps.

## Step 3: Generate CSP Directives

Build CSP directives based on discovered resources.

### Default Directives

```typescript
const cspDirectives = {
  'default-src': ["'self'"],
  'script-src': [
    "'self'",
    "'nonce-{NONCE}'", // Will be replaced dynamically
    "'strict-dynamic'",
  ],
  'style-src': [
    "'self'",
    "'nonce-{NONCE}'",
    // Add specific domains if needed
  ],
  'img-src': [
    "'self'",
    'data:',
    'blob:',
    // Add CDN domains
  ],
  'font-src': [
    "'self'",
    'data:',
    // Add font provider domains
  ],
  'connect-src': [
    "'self'",
    // Add API domains
  ],
  'frame-src': [
    "'self'",
    // Add allowed iframe sources
  ],
  'object-src': ["'none'"],
  'base-uri': ["'self'"],
  'form-action': ["'self'"],
  'frame-ancestors': ["'none'"],
  'upgrade-insecure-requests': [],
}
```

### Add Discovered Domains

For each resource type, add discovered domains:

```typescript
// If using Vercel Analytics
cspDirectives['script-src'].push('https://va.vercel-scripts.com')
cspDirectives['connect-src'].push('https://vitals.vercel-insights.com')

// If using Google Fonts
cspDirectives['font-src'].push('https://fonts.gstatic.com')
cspDirectives['style-src'].push('https://fonts.googleapis.com')

// If using Supabase
cspDirectives['connect-src'].push('https://*.supabase.co')

// If using Cloudinary for images
cspDirectives['img-src'].push('https://res.cloudinary.com')
```

## Step 4: Generate Nonce Implementation

Create nonce generation and middleware.

### Generate Nonce Utility

```typescript
// lib/csp/nonce.ts
import { headers } from 'next/headers'

export function generateNonce(): string {
  return Buffer.from(crypto.randomUUID()).toString('base64')
}

export function getNonce(): string | undefined {
  return headers().get('x-nonce') ?? undefined
}
```

### Generate Middleware with Nonce

```typescript
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  const nonce = Buffer.from(crypto.randomUUID()).toString('base64')

  const cspHeader = generateCSPHeader(nonce)

  const requestHeaders = new Headers(request.headers)
  requestHeaders.set('x-nonce', nonce)
  requestHeaders.set('Content-Security-Policy', cspHeader)

  const response = NextResponse.next({
    request: {
      headers: requestHeaders,
    },
  })

  response.headers.set('Content-Security-Policy', cspHeader)

  return response
}

function generateCSPHeader(nonce: string): string {
  const csp = [
    { name: 'default-src', values: ["'self'"] },
    { name: 'script-src', values: ["'self'", `'nonce-${nonce}'`, "'strict-dynamic'"] },
    { name: 'style-src', values: ["'self'", `'nonce-${nonce}'`] },
    { name: 'img-src', values: ["'self'", 'data:', 'blob:'] },
    { name: 'font-src', values: ["'self'", 'data:'] },
    { name: 'connect-src', values: ["'self'"] },
    { name: 'frame-src', values: ["'self'"] },
    { name: 'object-src', values: ["'none'"] },
    { name: 'base-uri', values: ["'self'"] },
    { name: 'form-action', values: ["'self'"] },
    { name: 'frame-ancestors', values: ["'none'"] },
  ]

  return csp
    .map(({ name, values }) => `${name} ${values.join(' ')}`)
    .join('; ')
}

export const config = {
  matcher: [
    {
      source: '/((?!api|_next/static|_next/image|favicon.ico).*)',
      missing: [
        { type: 'header', key: 'next-router-prefetch' },
        { type: 'header', key: 'purpose', value: 'prefetch' },
      ],
    },
  ],
}
```

### Update Root Layout with Nonce

```typescript
// app/layout.tsx
import { getNonce } from '@/lib/csp/nonce'

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const nonce = getNonce()

  return (
    <html lang="en">
      <head nonce={nonce}>
        {/* Head content will use nonce */}
      </head>
      <body nonce={nonce}>{children}</body>
    </html>
  )
}
```

### Update Script Tags

```typescript
// Use Next.js Script component with nonce
import Script from 'next/script'
import { getNonce } from '@/lib/csp/nonce'

export function AnalyticsScript() {
  const nonce = getNonce()

  return (
    <Script
      src="https://analytics.example.com/script.js"
      strategy="afterInteractive"
      nonce={nonce}
    />
  )
}
```

## Step 5: Generate next.config.ts Configuration

Alternative approach using headers in next.config.ts:

```typescript
// next.config.ts
import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'Content-Security-Policy',
            value: generateCSP(),
          },
        ],
      },
    ]
  },
}

function generateCSP(): string {
  const csp = [
    { name: 'default-src', values: ["'self'"] },
    {
      name: 'script-src',
      values: [
        "'self'",
        "'unsafe-eval'", // Required for React dev mode
        "'unsafe-inline'", // Required for Next.js hydration
        // Add specific domains
        'https://va.vercel-scripts.com',
      ],
    },
    {
      name: 'style-src',
      values: [
        "'self'",
        "'unsafe-inline'", // Required for Next.js styles
        'https://fonts.googleapis.com',
      ],
    },
    {
      name: 'img-src',
      values: ["'self'", 'data:', 'blob:', 'https:'],
    },
    {
      name: 'font-src',
      values: ["'self'", 'data:', 'https://fonts.gstatic.com'],
    },
    {
      name: 'connect-src',
      values: [
        "'self'",
        'https://vitals.vercel-insights.com',
        'https://*.supabase.co',
      ],
    },
    { name: 'frame-src', values: ["'self'"] },
    { name: 'object-src', values: ["'none'"] },
    { name: 'base-uri', values: ["'self'"] },
    { name: 'form-action', values: ["'self'"] },
    { name: 'frame-ancestors', values: ["'none'"] },
  ]

  // Remove 'unsafe-inline' and 'unsafe-eval' in production
  if (process.env.NODE_ENV === 'production') {
    const scriptSrc = csp.find(({ name }) => name === 'script-src')
    if (scriptSrc) {
      scriptSrc.values = scriptSrc.values.filter(
        (value) => value !== "'unsafe-eval'" && value !== "'unsafe-inline'"
      )
    }
  }

  return csp
    .map(({ name, values }) => `${name} ${values.join(' ')}`)
    .join('; ')
}

export default nextConfig
```

## Step 6: Handle Development vs Production

Create environment-specific CSP:

```typescript
// lib/csp/config.ts
const isDevelopment = process.env.NODE_ENV === 'development'

export function getCSPDirectives() {
  const baseDirectives = {
    'default-src': ["'self'"],
    'script-src': [
      "'self'",
      isDevelopment && "'unsafe-eval'", // React Fast Refresh
    ].filter(Boolean),
    'style-src': [
      "'self'",
      isDevelopment && "'unsafe-inline'", // Development styles
    ].filter(Boolean),
    // ... other directives
  }

  return baseDirectives
}
```

## Step 7: Generate CSP Testing Suite

Create tests to verify CSP configuration:

```typescript
// tests/csp.test.ts
import { describe, it, expect } from 'vitest'

describe('CSP Configuration', () => {
  it('includes required directives', () => {
    const csp = generateCSPHeader('test-nonce')

    expect(csp).toContain("default-src 'self'")
    expect(csp).toContain("object-src 'none'")
    expect(csp).toContain('nonce-test-nonce')
  })

  it('does not include unsafe-inline in production', () => {
    process.env.NODE_ENV = 'production'
    const csp = generateCSPHeader('test-nonce')

    expect(csp).not.toContain("'unsafe-inline'")
    expect(csp).not.toContain("'unsafe-eval'")
  })

  it('allows development-specific directives', () => {
    process.env.NODE_ENV = 'development'
    const csp = generateCSPHeader('test-nonce')

    // Development may include unsafe-eval for React Fast Refresh
    expect(csp).toBeDefined()
  })
})
```

## Step 8: Generate CSP Violation Reporting

Set up CSP violation reporting:

```typescript
// app/api/csp-report/route.ts
import { NextResponse } from 'next/server'

export async function POST(request: Request) {
  try {
    const report = await request.json()

    // Log violation
    console.error('CSP Violation:', {
      blockedURI: report['csp-report']['blocked-uri'],
      violatedDirective: report['csp-report']['violated-directive'],
      originalPolicy: report['csp-report']['original-policy'],
      documentURI: report['csp-report']['document-uri'],
    })

    // Optionally send to monitoring service
    // await sendToMonitoring(report)

    return NextResponse.json({ received: true })
  } catch (error) {
    return NextResponse.json({ error: 'Invalid report' }, { status: 400 })
  }
}
```

Add report-uri to CSP:

```typescript
const csp = [
  // ... other directives
  { name: 'report-uri', values: ['/api/csp-report'] },
  { name: 'report-to', values: ['csp-endpoint'] },
]
```

## Step 9: Generate Documentation

Create comprehensive CSP documentation using template from `assets/csp-documentation-template.md`:

```markdown
# Content Security Policy Configuration

## Overview
This application uses a strict Content Security Policy to prevent XSS attacks.

## Implementation
CSP is implemented via [middleware/next.config] using [nonce-based/hash-based] strategy.

## Directives
- `default-src 'self'` - Only load resources from same origin
- `script-src 'self' 'nonce-{NONCE}'` - Scripts require nonce
- [etc.]

## Adding New Resources
To add a new external resource:
1. Identify the resource type
2. Add domain to appropriate directive
3. Test in development
4. Update documentation

## Troubleshooting
Common CSP violations and fixes...
```

## Step 10: Validate CSP Configuration

Generate validation checklist:

```markdown
# CSP Validation Checklist

- [ ] All external scripts have nonce or are in script-src
- [ ] All external styles are in style-src
- [ ] All API endpoints are in connect-src
- [ ] object-src is set to 'none'
- [ ] frame-ancestors is configured
- [ ] No 'unsafe-inline' in production script-src
- [ ] CSP violations are being reported
- [ ] Development mode works correctly
- [ ] Production build passes CSP checks
```

## Consulting References

Throughout generation:
- Consult `references/csp-directives.md` for directive documentation
- Consult `references/csp-best-practices.md` for security guidelines
- Use templates from `assets/csp-config-template.ts`
- Use documentation template from `assets/csp-documentation-template.md`

## Output Format

Generate files:
```
lib/csp/
  nonce.ts
  config.ts
middleware.ts (enhanced)
app/api/csp-report/
  route.ts
docs/
  csp-configuration.md
tests/
  csp.test.ts
```

## Verification Checklist

Before completing:
- [ ] All resource types analyzed
- [ ] CSP directives generated
- [ ] Nonce implementation complete
- [ ] Middleware configured
- [ ] Development/production handled
- [ ] Violation reporting set up
- [ ] Documentation created
- [ ] Tests generated

## Completion

When finished:
1. Display generated CSP configuration
2. List all allowed domains
3. Explain implementation approach
4. Provide testing instructions
5. Offer to implement or adjust configuration
