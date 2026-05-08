---
name: web-scraper
description: This skill should be used when users need to scrape content from websites, extract text from web pages, crawl and follow links, or download documentation from online sources. It features concurrent URL processing, automatic deduplication, content filtering, domain restrictions, and proper directory hierarchy based on URL structure. Use for documentation gathering, content extraction, web archival, or research data collection.
---

# Web Scraper

## Overview

Recursively scrape web pages with concurrent processing, extracting clean text content while following links. The scraper automatically handles URL deduplication, creates proper directory hierarchies based on URL structure, filters out unwanted content, and respects domain boundaries.

## When to Use This Skill

Use this skill when users request:
- Scraping content from websites
- Downloading documentation from online sources
- Extracting text from web pages at scale
- Crawling websites to gather information
- Archiving web content locally
- Following and downloading linked pages
- Research data collection from web sources
- Building text datasets from websites

## Prerequisites

Install required dependencies:

```bash
pip install aiohttp beautifulsoup4 lxml aiofiles
```

These libraries provide:
- `aiohttp` - Async HTTP client for concurrent requests
- `beautifulsoup4` - HTML parsing and content extraction
- `lxml` - Fast HTML/XML parser
- `aiofiles` - Async file I/O

## Core Capabilities

### 1. Basic Single-Page Scraping

Scrape a single page without following links:

```bash
python scripts/scrape.py <URL> <output-directory> --depth 0
```

**Example:**
```bash
python scripts/scrape.py https://example.com/article output/
```

This downloads only the specified page, extracts clean text content, and saves it to `output/example.com/article.txt`.

### 2. Recursive Scraping with Link Following

Scrape a page and follow links up to a specified depth:

```bash
python scripts/scrape.py <URL> <output-directory> --depth <N>
```

**Example:**
```bash
python scripts/scrape.py https://docs.example.com output/ --depth 2
```

Depth levels:
- `--depth 0` - Only the start URL(s)
- `--depth 1` - Start URLs + all links on those pages
- `--depth 2` - Start URLs + links + links found on those linked pages
- `--depth 3+` - Continue following links to the specified depth

### 3. Limiting the Number of Pages

Prevent excessive scraping by setting a maximum page limit:

```bash
python scripts/scrape.py <URL> <output-directory> --depth 3 --max-pages 100
```

**Example:**
```bash
python scripts/scrape.py https://docs.example.com output/ --depth 3 --max-pages 50
```

Useful for:
- Testing scraper configuration before full run
- Limiting resource usage
- Sampling content from large sites
- Staying within rate limits

### 4. Concurrent Processing

Control the number of simultaneous requests for faster scraping:

```bash
python scripts/scrape.py <URL> <output-directory> --concurrent <N>
```

**Example:**
```bash
python scripts/scrape.py https://docs.example.com output/ --depth 2 --concurrent 20
```

Default is 10 concurrent requests. Increase for faster scraping, decrease for more conservative resource usage.

**Guidelines:**
- Small sites or slow servers: `--concurrent 5`
- Medium sites: `--concurrent 10` (default)
- Large, fast sites: `--concurrent 20-30`
- Be respectful of server resources

### 5. Domain Restrictions

By default, the scraper only follows links on the same domain as the start URL. This can be controlled:

**Same domain only (default):**
```bash
python scripts/scrape.py https://example.com output/ --depth 2
```

**Follow external links:**
```bash
python scripts/scrape.py https://example.com output/ --depth 2 --follow-external
```

**Specify allowed domains:**
```bash
python scripts/scrape.py https://example.com output/ --depth 2 --allowed-domains example.com docs.example.com blog.example.com
```

Use `--allowed-domains` when:
- Documentation is split across multiple subdomains
- Content spans related domains
- You want to limit to specific trusted domains

### 6. Multiple Start URLs

Scrape from multiple starting points simultaneously:

```bash
python scripts/scrape.py <URL1> <URL2> <URL3> <output-directory>
```

**Example:**
```bash
python scripts/scrape.py https://example.com/docs https://example.com/guides https://example.com/tutorials output/ --depth 2
```

All start URLs are processed with the same configuration (depth, domain restrictions, etc.).

### 7. Request Configuration

Customize HTTP request behavior:

```bash
python scripts/scrape.py <URL> <output-directory> --user-agent "MyBot/1.0" --timeout 60
```

**Options:**
- `--user-agent` - Custom User-Agent header (default: "Mozilla/5.0 (compatible; WebScraper/1.0)")
- `--timeout` - Request timeout in seconds (default: 30)

**Example:**
```bash
python scripts/scrape.py https://example.com output/ --depth 2 --user-agent "MyResearchBot/1.0 (+https://mysite.com/bot)" --timeout 45
```

### 8. Verbose Output

Enable detailed logging to monitor scraping progress:

```bash
python scripts/scrape.py <URL> <output-directory> --verbose
```

Verbose mode shows:
- Each URL being fetched
- Successful saves with file paths
- Errors and timeouts
- Detailed error information

## Output Structure

### Directory Hierarchy

The scraper creates a directory hierarchy that mirrors the URL structure:

```
output/
├── example.com/
│   ├── index.txt              # https://example.com/
│   ├── about.txt              # https://example.com/about
│   ├── docs/
│   │   ├── index.txt          # https://example.com/docs/
│   │   ├── getting-started.txt
│   │   └── api/
│   │       └── reference.txt
│   └── blog/
│       ├── post-1.txt
│       └── post-2.txt
├── docs.example.com/
│   └── guide.txt
└── _metadata.json
```

### File Format

Each scraped page is saved as a text file with the following structure:

```
URL: https://example.com/docs/guide
Title: Getting Started Guide
Scraped: 2025-10-21T14:30:00

================================================================================

[Clean extracted text content]
```

### Metadata File

`_metadata.json` contains scraping session information:

```json
{
  "start_time": "2025-10-21T14:30:00",
  "end_time": "2025-10-21T14:35:30",
  "pages_scraped": 42,
  "total_visited": 45,
  "errors": {
    "https://example.com/broken": "HTTP 404",
    "https://example.com/slow": "Timeout"
  }
}
```

## Content Extraction and Filtering

### What Gets Extracted

The scraper extracts clean text content by:

1. **Focusing on main content** - Prioritizes `<main>`, `<article>`, or `<body>` tags
2. **Removing unwanted elements** - Strips out:
   - Scripts and styles
   - Navigation menus
   - Headers and footers
   - Sidebars (aside tags)
   - Iframes and embedded content
   - SVG graphics
   - Comments

3. **Filtering common patterns** - Removes:
   - Cookie consent messages
   - Privacy policy links
   - Terms of service boilerplate
   - UI elements (arrows, single numbers)
   - Very short lines (likely navigation items)

4. **Preserving structure** - Maintains line breaks between content blocks

### What Gets Filtered Out

Common unwanted patterns automatically removed:
- "Accept cookies" / "Reject all"
- "Cookie settings"
- "Privacy policy"
- "Terms of service"
- Navigation arrows (←, →, ↑, ↓)
- Isolated numbers
- Lines shorter than 3 characters

## Common Usage Patterns

### Download Documentation Site

Scrape an entire documentation site with reasonable limits:

```bash
python scripts/scrape.py https://docs.example.com docs-archive/ --depth 3 --max-pages 200 --concurrent 15
```

### Archive a Blog

Download all blog posts from a blog (following pagination):

```bash
python scripts/scrape.py https://blog.example.com blog-archive/ --depth 2 --max-pages 500
```

### Research Data Collection

Gather text content from multiple related sources:

```bash
python scripts/scrape.py https://research.edu/papers https://research.edu/publications research-data/ --depth 2 --allowed-domains research.edu --concurrent 20
```

### Sample a Large Site

Test configuration on a small sample before full scrape:

```bash
python scripts/scrape.py https://largeSite.com sample/ --depth 2 --max-pages 20 --verbose
```

Then run full scrape after confirming results:

```bash
python scripts/scrape.py https://largeSite.com full-archive/ --depth 3 --max-pages 500 --concurrent 15
```

### Multi-Domain Knowledge Base

Scrape across multiple authorized domains:

```bash
python scripts/scrape.py https://main.example.com knowledge-base/ --depth 3 --allowed-domains main.example.com docs.example.com wiki.example.com --max-pages 300
```

## Implementation Approach

When users request web scraping:

1. **Identify the scope**:
   - What URLs to start from?
   - Should links be followed? How deep?
   - Any domain restrictions needed?
   - Is there a reasonable page limit?

2. **Configure the scraper**:
   - Set appropriate depth (typically 1-3)
   - Set max-pages to avoid runaway scraping
   - Choose concurrent level based on site size
   - Determine domain restrictions

3. **Run with monitoring**:
   - Start with verbose mode or small sample
   - Monitor output for errors or unexpected content
   - Adjust configuration if needed

4. **Verify output**:
   - Check the output directory structure
   - Review `_metadata.json` for statistics
   - Sample a few text files for quality
   - Check for errors in metadata

5. **Process the content**:
   - Text files are ready for loading into context
   - Use Read tool to examine specific files
   - Use Grep to search across all scraped content
   - Load files as needed for analysis

## Quick Reference

**Command structure:**
```bash
python scripts/scrape.py <URL> [URL2 ...] <output-dir> [options]
```

**Essential options:**
- `-d, --depth N` - Maximum link depth (default: 2)
- `-m, --max-pages N` - Maximum pages to scrape
- `-c, --concurrent N` - Concurrent requests (default: 10)
- `-f, --follow-external` - Follow external links
- `-a, --allowed-domains` - Specify allowed domains
- `-v, --verbose` - Detailed output
- `-u, --user-agent` - Custom User-Agent
- `-t, --timeout` - Request timeout in seconds

**Get full help:**
```bash
python scripts/scrape.py --help
```

## Best Practices

1. **Start small** - Test with `--depth 1 --max-pages 10` before large scrapes
2. **Respect servers** - Use reasonable concurrency and timeouts
3. **Set limits** - Always use `--max-pages` for initial runs
4. **Check robots.txt** - Manually verify the site allows scraping
5. **Use verbose mode** - Monitor for errors and unexpected behavior
6. **Identify yourself** - Use a descriptive User-Agent with contact info
7. **Monitor output** - Check `_metadata.json` for errors and statistics
8. **Handle errors gracefully** - Review error log in metadata for problematic URLs

## Troubleshooting

**Common issues:**

- **"Missing required dependency"**: Run `pip install aiohttp beautifulsoup4 lxml aiofiles`
- **Too many timeouts**: Increase `--timeout` or reduce `--concurrent`
- **Scraping too slow**: Increase `--concurrent` (e.g., 20-30)
- **Memory issues with large scrapes**: Reduce `--concurrent` or use `--max-pages` to chunk the work
- **Following too many links**: Reduce `--depth` or enable same-domain-only (default)
- **Missing content**: Some sites may require JavaScript; this scraper only handles static HTML
- **HTTP errors**: Check `_metadata.json` errors section for specific issues

**Limitations:**

- Does not execute JavaScript (single-page apps may not work)
- Does not handle authentication or login
- Does not follow links in JavaScript or dynamically loaded content
- No built-in rate limiting (use `--concurrent` to control request rate)

## Advanced Use Cases

### Loading Scraped Content

After scraping, use the Read tool to load content into context:

```bash
# Read a specific scraped page
Read file_path: output/docs.example.com/guide.txt

# Search across all scraped content
Grep pattern: "API endpoint" path: output/ -r
```

### Selective Re-scraping

The scraper tracks visited URLs in memory during a session but doesn't persist this between runs. To avoid re-downloading:

1. Run initial scrape with limits
2. Check output directory for what was downloaded
3. Run additional scrapes with different start URLs or configurations

### Combining with Other Tools

Chain the scraper with other processing:

```bash
# Scrape then process with custom script
python scripts/scrape.py https://example.com output/ --depth 2
python your_analysis_script.py output/
```

## Resources

### scripts/scrape.py

The main web scraping tool implementing concurrent crawling, content extraction, and intelligent filtering. Key features:

- **Async/concurrent processing** - Uses `asyncio` and `aiohttp` for high-performance concurrent requests
- **URL normalization** - Removes fragments and trailing slashes for proper deduplication
- **Visited tracking** - Maintains `visited_urls` and `queued_urls` sets to prevent re-downloading
- **Smart content extraction** - Removes scripts, styles, navigation, and common unwanted patterns
- **Directory hierarchy** - Converts URLs to safe filesystem paths maintaining structure
- **Error handling** - Tracks and reports errors in metadata file
- **Metadata generation** - Creates `_metadata.json` with scraping statistics and errors

The script can be executed directly and includes comprehensive command-line help via `--help`.
