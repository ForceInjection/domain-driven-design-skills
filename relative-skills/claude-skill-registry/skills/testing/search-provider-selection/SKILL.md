---
name: search-provider-selection
description: Expert knowledge on choosing the right search provider (Serper vs Apify vs ScapeCreators) for Instagram/TikTok/YouTube, cost-benefit analysis, quality vs speed tradeoffs, rate limits, and provider testing scripts. Use this skill when user asks about "which provider", "search provider", "compare providers", "cost optimization", "serper vs apify", or "provider selection".
allowed-tools: Read, Bash, Grep
---

# Search Provider Selection Expert

You are an expert in selecting the optimal search provider for different use cases. This skill provides comprehensive comparison of providers, cost-benefit analysis, and decision frameworks.

## When To Use This Skill

This skill activates when users:
- Choose between Serper and Apify for Instagram searches
- Optimize search costs
- Need quality vs speed tradeoffs
- Compare provider capabilities
- Debug provider-specific issues
- Implement new search providers
- Benchmark provider performance

## Core Knowledge

### Provider Comparison Matrix

| Provider | Type | Cost/Result | Speed | Quality | Best For |
|----------|------|-------------|-------|---------|----------|
| **Serper** | Google SERP | $0.0001 | 1-3s | Handles only | Discovery |
| **Apify** | Direct scraper | $0.01-0.05 | 10-60s | Full profiles | Deep data |
| **ScapeCreators** | API service | $0.005 | 5-15s | Medium data | Screening |
| **Instagram API** | Official | Free (limited) | 1-2s | Full profiles | Verified only |
| **Perplexity Sonar** | AI search | $0.0005 | 3-5s | Context | Semantic |

### Provider Details

#### 1. Serper (Primary for Discovery)

**Endpoint:** `https://google.serper.dev/search`

**Use Case:** Lightweight Instagram handle discovery

**Pros:**
- Extremely cheap ($0.0001 per query)
- Fast (1-3 seconds)
- High volume (100 requests/second)
- No Instagram rate limits (uses Google)
- Returns relevant handles

**Cons:**
- Handles only (no profile data)
- Limited to 20 results per query
- Quality depends on Google ranking
- May miss private accounts

**Cost Example:**
```
10 keywords x $0.001 = $0.01 per search job
1000 search jobs = $10 total
```

**Rate Limits:**
- Free tier: 2,500 requests/month
- Paid tier: 100 requests/second
- No daily cap

**Implementation:** `/lib/instagram-us-reels/clients/serper.ts`

**Testing Script:**
```bash
# Quick test
curl -X POST 'https://google.serper.dev/search' \
  -H 'X-API-KEY: your-key' \
  -H 'Content-Type: application/json' \
  -d '{
    "q": "site:instagram.com \"fitness\" reels",
    "num": 10,
    "gl": "us"
  }'
```

#### 2. Apify (For Deep Enrichment)

**Actors:**
- `apify/instagram-profile-scraper` - Full profiles
- `apify/instagram-post-scraper` - Post details
- `apify/instagram-hashtag-scraper` - Hashtag searches

**Use Case:** Deep profile scraping after discovery

**Pros:**
- Complete profile data (bio, followers, engagement)
- Post content and metrics
- Historical data available
- Handles private account detection

**Cons:**
- Expensive ($0.01-0.05 per profile)
- Slow (10-60 seconds per profile)
- Rate limited by Instagram
- Can get blocked if overused
- Requires actor warm-up time

**Cost Example:**
```
1000 profiles x $0.03 = $30 per enrichment
100 search jobs = $3,000 total (not sustainable!)
```

**Rate Limits:**
- Actor-specific (typically 10-50 concurrent)
- Instagram may block after ~1000 requests/day
- Requires proxy rotation

**Implementation:** `/lib/platforms/instagram-similar/api.ts`

**Testing Scripts:**
```bash
node scripts/test-apify-instagram-simple.js
node scripts/test-apify-instagram-correct.js
node scripts/test-both-hashtag-scrapers.js
```

#### 3. ScapeCreators (Middle Ground)

**API:** Custom API service

**Use Case:** Profile screening before expensive enrichment

**Pros:**
- Moderate cost ($0.005 per profile)
- Medium speed (5-15 seconds)
- Basic profile data (followers, bio, verified)
- Less likely to be blocked
- Good for filtering

**Cons:**
- Not as comprehensive as Apify
- Still relatively expensive for bulk
- May have outdated data
- Limited to public accounts

**Cost Example:**
```
1000 profiles x $0.005 = $5 per screening
100 search jobs = $500 total (affordable)
```

**Implementation:** `/lib/instagram-us-reels/clients/scrapecreators.ts`

#### 4. Instagram Official API

**Use Case:** Verified business accounts, official partnerships

**Pros:**
- Free (within limits)
- No blocking concerns
- Official data
- Reliable

**Cons:**
- Requires app approval
- Limited to business accounts
- Heavy restrictions
- Not viable for discovery

**Not Recommended For:** Influencer discovery platform

#### 5. Perplexity Sonar (AI-Powered)

**API:** Perplexity Sonar API

**Use Case:** Semantic search, keyword expansion, context understanding

**Pros:**
- AI-powered semantic search
- Good for keyword expansion
- Provides context and explanations
- Cheap ($0.0005 per query)

**Cons:**
- Not for direct scraping
- Returns text, not profiles
- Limited structure
- Rate limited

**Cost Example:**
```
10 keyword expansions x $0.0005 = $0.005 per search
```

**Implementation:** `/lib/instagram-us-reels/clients/sonar.ts`

### Provider Selection Decision Tree

```
Start: Need Instagram creators

├─ Discovery Phase (Need 100-1000 handles)
│  ├─ Budget: Low ($0.01-0.10)
│  │  └─ Use: Serper ✓
│  ├─ Budget: Medium ($1-10)
│  │  └─ Use: Serper + ScapeCreators
│  └─ Budget: High ($10+)
│     └─ Use: Serper + Apify (selective)
│
├─ Enrichment Phase (Need full profiles)
│  ├─ Volume: <100 profiles
│  │  └─ Use: Apify ✓
│  ├─ Volume: 100-1000 profiles
│  │  └─ Use: ScapeCreators
│  └─ Volume: >1000 profiles
│     └─ Use: Lazy enrichment (enrich on user click)
│
└─ Semantic Phase (Need keyword expansion)
   └─ Use: Perplexity Sonar + GPT-4 ✓
```

### Current Pipeline Strategy

**Instagram US Reels Pipeline:**

```
1. Keyword Expansion (GPT-4o-mini)
   - Cost: $0.0001
   - Time: 2-5s
   - Input: 1 keyword → Output: 10 keywords

2. Handle Discovery (Serper)
   - Cost: $0.01 (10 queries)
   - Time: 20-30s
   - Input: 10 keywords → Output: 100-200 handles

3. Deduplication (Local)
   - Cost: $0
   - Time: <1s
   - Input: 200 handles → Output: 150 unique handles

4. Lazy Enrichment (On-Demand)
   - Cost: $0 upfront, $0.03 per clicked profile
   - Time: Instant discovery + 10s on click
   - User clicks 10 profiles → $0.30

Total Cost: $0.01 discovery + $0.30 enrichment = $0.31
```

**Cost Comparison (1000 profiles):**

| Strategy | Cost | Time | Quality |
|----------|------|------|---------|
| **Serper only** | $0.01 | 30s | Handles only |
| **Serper + Lazy Enrich** | $0.01 + $0.30/10 clicks | 30s + 10s/click | High |
| **Serper + ScapeCreators** | $5.01 | 30s + 2h | Medium |
| **Apify only** | $30 | 30min-1h | Highest |
| **Serper + Apify (all)** | $30.01 | 30s + 30min | Highest |

### Rate Limit Strategies

**Serper:**
- Sequential processing (1 keyword at a time)
- 2-second delay between queries
- Exponential backoff on 429

**Apify:**
- Parallel runs (10-20 concurrent)
- Actor-level queuing
- Retry failed with longer delay

**ScapeCreators:**
- Batch requests (50-100 at a time)
- Respect API rate limits
- Circuit breaker after N failures

## Common Patterns

### Pattern 1: Cost-Optimized Discovery

```typescript
// Good: Use cheapest provider for discovery
async function discoverCreators(keywords: string[]) {
  // Step 1: Serper for handles ($0.01)
  const handles = [];
  for (const kw of keywords) {
    const batch = await fetchSerperHandles({ query: kw, num: 20 });
    handles.push(...batch);
  }

  // Step 2: Dedupe (free)
  const unique = [...new Set(handles)];

  // Step 3: Return lightweight results
  return unique.map(handle => ({
    username: handle,
    profileUrl: `https://instagram.com/${handle}`,
    source: 'serper'
  }));

  // Step 4: Enrich later (lazy, on-demand)
  // User clicks → Fetch full profile via Apify/ScapeCreators
}
```

### Pattern 2: Quality-Optimized Discovery

```typescript
// Good: Use multiple providers for best quality
async function discoverCreatorsHighQuality(keywords: string[]) {
  // Step 1: Serper for initial handles ($0.01)
  const handles = await fetchSerperHandles(keywords);

  // Step 2: Screen with ScapeCreators ($5)
  const screened = await screenProfiles(handles);

  // Step 3: Filter by quality
  const qualified = screened.filter(p =>
    p.followers > 10000 &&
    p.engagementRate > 0.02 &&
    !p.isPrivate
  );

  // Step 4: Deep enrich top 50 with Apify ($1.50)
  const top50 = qualified.slice(0, 50);
  const enriched = await enrichWithApify(top50);

  return enriched;
}
```

### Pattern 3: Hybrid Approach (Current)

```typescript
// Good: Cheap discovery + lazy enrichment
async function instagramUSReelsSearch(keyword: string, targetResults: number) {
  // Phase 1: Keyword expansion ($0.0001)
  const keywords = await expandKeywords(keyword);

  // Phase 2: Handle discovery ($0.01)
  const handles = await fetchSerperHandles(keywords);

  // Phase 3: Return immediately with handles
  return {
    results: handles.map(h => ({
      username: h,
      profileUrl: `https://instagram.com/${h}`,
      isEnriched: false
    })),
    cost: 0.01,
    enrichmentAvailable: true
  };

  // Phase 4: User triggers enrichment on-demand
  // GET /api/creators/:username/enrich
  // → Calls Apify/ScapeCreators for that one profile ($0.03)
}
```

## Anti-Patterns (Avoid These)

### Anti-Pattern 1: Using Apify for Discovery

```typescript
// BAD: Expensive and slow
async function discoverWithApify(keywords: string[]) {
  const handles = await fetchSerperHandles(keywords); // 100 handles
  const profiles = await apifyClient.call('instagram-profile-scraper', {
    usernames: handles // $3-5, takes 10+ minutes
  });
  return profiles;
}
```

**Why it's bad:** 300x more expensive, much slower

### Anti-Pattern 2: No Provider Fallback

```typescript
// BAD: Single point of failure
async function fetchProfiles(handles: string[]) {
  return await apifyClient.call('instagram-profile-scraper', {
    usernames: handles
  });
  // If Apify is down or rate limited, entire search fails!
}
```

**Why it's bad:** No resilience

**Do this instead:**
```typescript
// GOOD: Fallback chain
async function fetchProfiles(handles: string[]) {
  try {
    return await apifyClient.call('instagram-profile-scraper', { usernames: handles });
  } catch (error) {
    logger.warn('Apify failed, trying ScapeCreators');
    return await scapeCreatorsClient.fetchProfiles(handles);
  }
}
```

### Anti-Pattern 3: Parallel Serper Requests

```typescript
// BAD: Exceeds rate limits
const results = await Promise.all(
  keywords.map(kw => fetchSerperHandles({ query: kw }))
);
```

**Why it's bad:** 429 errors, wasted requests

## Troubleshooting Guide

### Problem: Which Provider Should I Use?

**Decision Matrix:**

**Use Serper when:**
- Need 100-1000 handles quickly
- Budget is tight
- Quality screening done later
- Instagram discovery phase

**Use Apify when:**
- Need full profile data
- Volume <100 profiles
- Budget allows ($0.01-0.05/profile)
- Quality is critical

**Use ScapeCreators when:**
- Need basic profile data
- Volume 100-1000 profiles
- Middle ground on cost/quality
- Pre-screening before Apify

**Use Lazy Enrichment when:**
- User behavior is unpredictable
- Cost optimization critical
- Fast initial results needed
- Only 5-10% profiles viewed

## Related Files

- `/lib/instagram-us-reels/clients/serper.ts` - Serper client
- `/lib/platforms/instagram-similar/api.ts` - Apify integration
- `/lib/instagram-us-reels/clients/scrapecreators.ts` - ScapeCreators client
- `/lib/instagram-us-reels/clients/sonar.ts` - Perplexity client
- `/scripts/test-both-hashtag-scrapers.js` - Comparison script
- `/scripts/quick-test-instagram-apis.js` - Quick test
- `/scripts/test-instagram-keyword-comparison.js` - Benchmark

## Testing Providers

**Compare All Providers:**
```bash
node scripts/test-instagram-keyword-comparison.js
```

**Test Apify:**
```bash
node scripts/test-apify-instagram-simple.js
```

**Test Serper:**
```bash
curl -X POST 'https://google.serper.dev/search' \
  -H 'X-API-KEY: $SERPER_API_KEY' \
  -d '{"q":"site:instagram.com fitness reels","num":10}'
```

## Cost Calculator

**Formula:**
```
Total Cost = (Keywords × $0.001) + (Handles × EnrichmentCost)

Where EnrichmentCost:
- Lazy (5% click): $0.0015 per handle
- ScapeCreators: $0.005 per handle
- Apify: $0.03 per handle
```

**Example:**
```
10 keywords, 1000 handles
- Serper: 10 × $0.001 = $0.01
- Lazy (5% click): 1000 × $0.0015 = $1.50
- Total: $1.51

vs Apify All:
- Serper: $0.01
- Apify: 1000 × $0.03 = $30
- Total: $30.01

Savings: 95%!
```

## Recommendation

**Current Best Practice (Instagram US Reels):**

1. **Discovery:** Serper ($0.01)
2. **Enrichment:** Lazy (on-demand, ~$0.30 for 10 profiles)
3. **Total:** $0.31 average per search job

**Why:** 95% cost savings, instant results, same quality for viewed profiles
