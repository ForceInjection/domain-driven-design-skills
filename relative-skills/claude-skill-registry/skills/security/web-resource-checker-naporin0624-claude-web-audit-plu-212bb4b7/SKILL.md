---
name: web-resource-checker
description: Validates essential web resource files (sitemap.xml, robots.txt, llms.txt, security.txt) for compliance with their specifications. Use when user asks about "sitemap validation", "robots.txt check", "llms.txt", "security.txt", "RFC 9116", "RFC 9309", "web resource audit", "サイトマップ", "セキュリティ", or wants to verify crawler/LLM accessibility files.
---

# Web Resource Checker

Validates essential web resource files for SEO, security, and LLM accessibility compliance.

## Supported Files

| File | Purpose | Specification |
|------|---------|---------------|
| sitemap.xml | URL listing for crawlers | [sitemaps.org](https://www.sitemaps.org/) |
| robots.txt | Crawler access control | [RFC 9309](https://www.rfc-editor.org/rfc/rfc9309.html) |
| llms.txt | LLM site overview | [llmstxt.org](https://llmstxt.org/) |
| llms-full.txt | Complete LLM docs | [llmstxt.org](https://llmstxt.org/) |
| security.txt | Vulnerability disclosure | [RFC 9116](https://www.rfc-editor.org/rfc/rfc9116.html) |
| humans.txt | Team credits | [humanstxt.org](https://humanstxt.org/) |
| ads.txt | Ad transparency | [IAB Tech Lab](https://iabtechlab.com/ads-txt/) |

## Lookup Workflow

1. **Identify the query type**:
   - File specification lookup (e.g., "sitemap.xml format", "security.txt fields")
   - Validation request (e.g., "check my sitemap", "validate robots.txt")

2. **For specification lookup**:
   - Read [web-resources-index.json](web-resources-index.json)
   - Return summary, requirements, and official reference

3. **For validation**:
   - Run the appropriate validator script
   - Return issues found with severity and fix suggestions

## Usage

### Validate All Resources

```bash
# Check local directory
cd ${CLAUDE_PLUGIN_ROOT}/skills/web-resource-checker && npx web-resource-checker ./public

# Check live site
cd ${CLAUDE_PLUGIN_ROOT}/skills/web-resource-checker && npx web-resource-checker https://example.com

# JSON output
cd ${CLAUDE_PLUGIN_ROOT}/skills/web-resource-checker && npx web-resource-checker https://example.com --json

# Check specific files only
cd ${CLAUDE_PLUGIN_ROOT}/skills/web-resource-checker && npx web-resource-checker https://example.com --only=sitemap,robots

# With custom timeout (in milliseconds)
cd ${CLAUDE_PLUGIN_ROOT}/skills/web-resource-checker && npx web-resource-checker https://example.com --timeout=30000
```

### Lookup Specifications

```bash
# Get sitemap.xml specification
cat ${CLAUDE_PLUGIN_ROOT}/skills/web-resource-checker/web-resources-index.json | jq '.files["sitemap.xml"]'

# Get security.txt required fields
cat ${CLAUDE_PLUGIN_ROOT}/skills/web-resource-checker/web-resources-index.json | jq '.files["security.txt"].requiredFields'

# Get llms.txt example
cat ${CLAUDE_PLUGIN_ROOT}/skills/web-resource-checker/web-resources-index.json | jq -r '.files["llms.txt"].example'
```

## Response Format

### For Specification Lookup

```markdown
### [File Name]

**Summary**: [1-2 sentence explanation]

**Required Elements**:
- [Element 1]
- [Element 2]

**Common Issues**:
- [Issue description]

**Official Specification**: [URL]
```

### For Validation Results

```markdown
### [File Name] - [Status]

**Issues Found**: [count]

1. **[Issue Title]** ([severity])
   - Problem: [description]
   - Fix: [suggestion]

2. ...
```

## Quick Reference

### sitemap.xml
- **Location**: `/sitemap.xml`
- **Max URLs**: 50,000 per file
- **Max Size**: 50MB uncompressed
- **Required**: `<urlset>`, `<url>`, `<loc>`
- **Recommended**: `<lastmod>`, `<changefreq>`, `<priority>`

### robots.txt
- **Location**: `/robots.txt` (site root only)
- **Common Directives**: `User-agent`, `Disallow`, `Allow`, `Sitemap`
- **Case**: Directives are case-insensitive
- **Tip**: Always include `Sitemap:` directive

### llms.txt (llmstxt.org)
- **Location**: `/llms.txt`
- **Format**: Markdown
- **Required**: H1 title (# Site Name)
- **Recommended**: Blockquote summary, H2 sections with links

### llms-full.txt
- **Location**: `/llms-full.txt`
- **Purpose**: Complete documentation for LLM context
- **Size**: Should fit in ~100k tokens

### security.txt (RFC 9116)
- **Location**: `/.well-known/security.txt` (preferred) or `/security.txt`
- **Required Fields**: `Contact`, `Expires`
- **Expires Format**: ISO 8601 (e.g., `2025-12-31T23:59:59.000Z`)
- **HTTPS**: Must be served over HTTPS

## Common Patterns

### Complete sitemap.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://example.com/</loc>
    <lastmod>2024-01-15</lastmod>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>https://example.com/about</loc>
    <lastmod>2024-01-10</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.8</priority>
  </url>
</urlset>
```

### Complete robots.txt

```text
User-agent: *
Allow: /
Disallow: /admin/
Disallow: /private/
Disallow: /api/

User-agent: GPTBot
Disallow: /

Sitemap: https://example.com/sitemap.xml
```

### Complete llms.txt

```markdown
# Example Site

> A comprehensive platform for developers to learn and build modern applications.

## Documentation

- [Getting Started](https://example.com/docs/start): Quick start guide for new users
- [API Reference](https://example.com/docs/api): Complete API documentation
- [Tutorials](https://example.com/docs/tutorials): Step-by-step guides

## Optional

- [Blog](https://example.com/blog): Latest updates and articles
- [Changelog](https://example.com/changelog): Version history
```

### Complete security.txt

```text
Contact: mailto:security@example.com
Contact: https://example.com/security-contact
Expires: 2025-12-31T23:59:59.000Z
Encryption: https://example.com/.well-known/pgp-key.txt
Acknowledgments: https://example.com/security/thanks
Preferred-Languages: en, ja
Canonical: https://example.com/.well-known/security.txt
Policy: https://example.com/security-policy
Hiring: https://example.com/careers/security
```

## External Resources

- [Google Search Central - Sitemaps](https://developers.google.com/search/docs/crawling-indexing/sitemaps/overview)
- [Google Search Central - Robots.txt](https://developers.google.com/search/docs/crawling-indexing/robots/intro)
- [llmstxt.org - Official Specification](https://llmstxt.org/)
- [securitytxt.org - Generator](https://securitytxt.org/)
- [CISA - security.txt Recommendation](https://www.cisa.gov/news-events/news/securitytxt-simple-file-big-value)
