---
name: event-scraper
description: Create new event scraping scripts for websites. Use when adding a new event source to the Asheville Event Feed. ALWAYS start by detecting the CMS/platform and trying known API endpoints first. Browser scraping is NOT supported (Vercel limitation). Handles API-based, HTML/JSON-LD, and hybrid patterns with comprehensive testing workflows.
---

# Event Scraper Skill

Create new event scrapers that integrate with the Asheville Event Feed codebase. This skill provides patterns and guidance for the full lifecycle: exploration, development, testing, and production integration.

---

## ⚠️ CRITICAL: API-First Approach

**Scrapers run automatically on Vercel which does NOT support browser automation.**

You MUST find the site's API before considering any other approach. Modern websites almost always fetch event data from a backend API - your job is to find and use that same API.

### Priority Order (STRICTLY follow this order):

1. **🥇 Known CMS API** - Check the Quick API Lookup table below FIRST
2. **🥈 Internal JSON API** - Site's own API endpoints (found via page analysis)
3. **🥉 Public API** - Official documented API (Ticketmaster, Eventbrite, etc.)
4. **🏅 HTML with JSON-LD** - Structured data embedded in HTML pages
5. **❌ Browser scraping** - NOT SUPPORTED on Vercel!

---

## 🚀 Quick API Endpoint Lookup (TRY THESE FIRST!)

Before doing any exploration, check if the site uses a known CMS/platform and try these endpoints directly:

| CMS/Plugin | Detection Signs | API Endpoint | Key Parameters |
|------------|-----------------|--------------|----------------|
| **WordPress + Tribe Events** | `/wp-content/`, "The Events Calendar" | `/wp-json/tribe/events/v1/events` | `start_date`, `per_page`, `page` |
| **WordPress + All Events** | "All-in-One Event Calendar" | `/wp-json/osec/v1/events` | `start`, `end` |
| **WordPress REST** | `/wp-content/`, `/wp-admin/` | `/wp-json/wp/v2/posts?type=event` | `per_page`, `page` |
| **Squarespace** | `squarespace.com`, `static1.squarespace.com` | `{any-page}?format=json` | Append to URL |
| **Next.js** | `/_next/`, `__NEXT_DATA__` | `/_next/data/{buildId}/{page}.json` | Check page source |
| **Eventbrite** | `eventbrite.com` | Internal API (see eventbrite.ts) | Complex - see example |
| **Ticketmaster Venues** | Venue ticket sales | Discovery API | `venueId`, `apikey` |

### Example: Detecting and Using Tribe Events API

If you detect WordPress + Tribe Events, immediately try:
```
GET https://example.com/wp-json/tribe/events/v1/events?start_date=2025-01-01&per_page=50&page=1
```

This often returns rich JSON with all event data, proper timezone handling, and pagination.

---

## Required Output Format

Every scraper MUST return `ScrapedEvent[]`:

```typescript
interface ScrapedEvent {
  sourceId: string;      // Unique ID from source platform (prefix with source, e.g., "mx-123")
  source: EventSource;   // Add to types.ts if new source
  title: string;
  description?: string;
  startDate: Date;       // UTC Date object - see Timezone Decision Tree
  location?: string;     // Format: "Venue, Address, City, State"
  zip?: string;          // Zip code (from API or fallback utilities)
  organizer?: string;
  price?: string;        // "Free", "$20", "$15 - $30", "Unknown"
  url: string;           // Unique event URL (used for deduplication)
  imageUrl?: string;
  interestedCount?: number;
  goingCount?: number;
  timeUnknown?: boolean; // True if source only provided date, no time
}
```

---

# PHASE 1: EXPLORATION

## Step 1.1: Detect CMS/Platform

Use WebFetch to analyze the target site:

```
WebFetch URL: https://example.com/events/
Prompt: "Analyze this page:
1. What CMS/platform is it? (WordPress, Squarespace, Next.js, custom)
2. Look for: wp-content, wp-json, squarespace, _next, __NEXT_DATA__
3. Is there JSON-LD structured data in script tags?
4. What event plugin is used? (Tribe Events, All Events Calendar, etc.)
5. Any hints about API endpoints in the HTML?"
```

## Step 1.2: Try Known API Endpoints

Based on CMS detection, **immediately try the known API endpoints** from the Quick Lookup table:

```
WebFetch URL: https://example.com/wp-json/tribe/events/v1/events?per_page=5
Prompt: "Analyze this API response:
1. Is it returning JSON event data?
2. What fields are available? (title, start_date, venue, cost, etc.)
3. Is there timezone information?
4. What pagination mechanism is used?
5. List all available fields for each event"
```

## Step 1.3: Test API Parameters

Once you find a working API, test common parameters:

| Parameter | Common Names | Purpose |
|-----------|--------------|---------|
| Future filter | `start_date`, `after`, `from`, `startDate` | Only get future events |
| Page size | `per_page`, `limit`, `count`, `pageSize` | Control results per page |
| Pagination | `page`, `offset`, `cursor`, `skip` | Navigate pages |
| Sort | `orderby`, `sort`, `sortValue` | Order results |

```
WebFetch URL: https://example.com/wp-json/tribe/events/v1/events?start_date=2025-01-01&per_page=50
Prompt: "Does this API support:
1. start_date parameter for filtering future events?
2. per_page parameter for controlling page size?
3. What's the maximum per_page allowed?
4. How does pagination work (page number, next_url, etc.)?"
```

## Step 1.4: Document Field Mapping

Create a mental map of API fields to ScrapedEvent fields:

| API Field | ScrapedEvent Field | Transform Needed |
|-----------|-------------------|------------------|
| `id` | `sourceId` | Prefix: `"mx-${id}"` |
| `title` | `title` | `decodeHtmlEntities()` |
| `utc_start_date` | `startDate` | `new Date(utc + 'Z')` |
| `cost` | `price` | Use directly or "Unknown" |
| `venue.venue` | `location` | Build string, decode entities |
| `venue.zip` | `zip` | Use directly or fallback |
| `url` | `url` | Use directly |

---

## ⏰ Timezone Decision Tree (CRITICAL!)

Getting timezone right is crucial. Follow this decision tree:

```
Does the API provide a UTC field (utc_start_date, utc_time, etc.)?
├─ YES → Use directly: new Date(utcField.replace(' ', 'T') + 'Z')
│        This is the SIMPLEST and most reliable approach.
│
└─ NO → Does the API provide ISO 8601 with offset? (e.g., "2025-12-16T19:00:00-05:00")
        ├─ YES → Use directly: new Date(isoString)
        │
        └─ NO → Does the API provide local time + timezone name? (e.g., "America/New_York")
                ├─ YES → Use parseAsEastern(dateStr, timeStr)
                │
                └─ NO → DANGER! Ambiguous local time.
                        - Assume Eastern for NC events
                        - Use parseAsEastern(dateStr, timeStr)
                        - Verify with test insertion!
```

### Timezone Verification

ALWAYS verify timezone handling by comparing:
1. API's local time field (e.g., `start_date: "2025-12-16 19:00:00"`)
2. API's UTC field (e.g., `utc_start_date: "2025-12-17 00:00:00"`)
3. Your parsed Date displayed in Eastern (should match #1)

Example verification:
```
API local:  19:00:00 (7 PM Eastern)
API UTC:    00:00:00 next day (midnight UTC = 7 PM EST, correct!)
Our parsed: 7:00:00 PM Eastern ✓
```

---

## 📍 Location String Best Practices

Location strings often have issues. Follow these rules:

### 1. Always Decode HTML Entities
```typescript
const venueName = decodeHtmlEntities(venue.venue); // "Rock & Roll" not "Rock &amp; Roll"
const address = decodeHtmlEntities(venue.address);
```

### 2. Avoid Duplicate City Names
APIs often include city in both venue name and city field:
```typescript
// BAD: "Turgua Brewing, Fairview, Fairview, NC"
// GOOD: "Turgua Brewing, 123 Main St, Fairview, NC"

if (venue.city && !venue.address?.includes(venue.city)) {
  parts.push(venue.city);
}
```

### 3. Standard Format
```typescript
// Format: "Venue, Address, City, State"
const parts = [venueName];
if (venue.address) parts.push(decodeHtmlEntities(venue.address));
if (venue.city && !venue.address?.includes(venue.city)) {
  parts.push(venue.city);
}
if (venue.state) parts.push(venue.state);
location = parts.join(', ');
```

### 4. Zip Code Fallbacks
```typescript
let zip = venue?.zip || undefined;
if (!zip && venue?.geo_lat && venue?.geo_lng) {
  zip = getZipFromCoords(venue.geo_lat, venue.geo_lng);
}
if (!zip && venue?.city) {
  zip = getZipFromCity(venue.city);
}
```

---

# PHASE 2: DEVELOPMENT

## Step 2.1: Add Source Type

Add to `lib/scrapers/types.ts`:

```typescript
export type EventSource = 'AVL_TODAY' | ... | 'YOUR_SOURCE';
```

## Step 2.2: Create Scraper

Create `lib/scrapers/yoursource.ts`:

```typescript
import { ScrapedEvent } from './types';
import { fetchWithRetry } from '@/lib/utils/retry';
import { isNonNCEvent } from '@/lib/utils/geo';
import { decodeHtmlEntities } from '@/lib/utils/parsers';
import { getZipFromCoords, getZipFromCity } from '@/lib/utils/geo';
import { getTodayStringEastern } from '@/lib/utils/timezone';

const API_BASE = 'https://example.com/wp-json/tribe/events/v1/events';
const PER_PAGE = 50;
const MAX_PAGES = 40;
const DELAY_MS = 200;

const API_HEADERS = {
  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
  'Accept': 'application/json',
};

export async function scrapeYourSource(): Promise<ScrapedEvent[]> {
  console.log('[YourSource] Starting scrape...');

  const allEvents: ScrapedEvent[] = [];
  const today = getTodayStringEastern();
  let page = 1;
  let hasMore = true;

  while (hasMore && page <= MAX_PAGES) {
    try {
      const url = new URL(API_BASE);
      url.searchParams.set('start_date', today);
      url.searchParams.set('per_page', PER_PAGE.toString());
      url.searchParams.set('page', page.toString());

      console.log(`[YourSource] Fetching page ${page}...`);

      const response = await fetchWithRetry(
        url.toString(),
        { headers: API_HEADERS, cache: 'no-store' },
        { maxRetries: 3, baseDelay: 1000 }
      );

      const data = await response.json();
      const events = data.events || [];

      console.log(`[YourSource] Page ${page}: ${events.length} events`);

      for (const event of events) {
        const formatted = formatEvent(event);
        if (formatted) allEvents.push(formatted);
      }

      hasMore = !!data.next_rest_url && page < data.total_pages;
      page++;

      if (hasMore) await new Promise(r => setTimeout(r, DELAY_MS));
    } catch (error) {
      console.error(`[YourSource] Error on page ${page}:`, error);
      break;
    }
  }

  // Filter non-NC events
  const ncEvents = allEvents.filter(ev => !isNonNCEvent(ev.title, ev.location));
  console.log(`[YourSource] Found ${ncEvents.length} NC events`);

  return ncEvents;
}

function formatEvent(event: ApiEvent): ScrapedEvent | null {
  // Parse UTC date (see Timezone Decision Tree)
  const startDate = new Date(event.utc_start_date.replace(' ', 'T') + 'Z');

  if (isNaN(startDate.getTime()) || startDate < new Date()) {
    return null;
  }

  // Build location (see Location Best Practices)
  const venue = event.venue;
  let location: string | undefined;
  if (venue?.venue) {
    const parts = [decodeHtmlEntities(venue.venue)];
    if (venue.address) parts.push(decodeHtmlEntities(venue.address));
    if (venue.city && !venue.address?.includes(venue.city)) parts.push(venue.city);
    if (venue.state) parts.push(venue.state);
    location = parts.join(', ');
  }

  // Zip with fallbacks
  let zip = venue?.zip || undefined;
  if (!zip && venue?.geo_lat && venue?.geo_lng) {
    zip = getZipFromCoords(venue.geo_lat, venue.geo_lng);
  }

  return {
    sourceId: `ys-${event.id}`,
    source: 'YOUR_SOURCE',
    title: decodeHtmlEntities(event.title),
    description: event.description ? decodeHtmlEntities(event.description) : undefined,
    startDate,
    location,
    zip,
    organizer: event.organizer?.[0]?.organizer,
    price: event.cost || 'Unknown',
    url: event.url,
    imageUrl: event.image?.url,
    timeUnknown: event.all_day || false,
  };
}
```

## Step 2.3: Create Test Script

Create `scripts/scrapers/test-yoursource.ts`:

```typescript
import 'dotenv/config';
import * as fs from 'fs';
import * as path from 'path';

const DEBUG_DIR = path.join(process.cwd(), 'debug-scraper-yoursource');
if (!fs.existsSync(DEBUG_DIR)) {
  fs.mkdirSync(DEBUG_DIR, { recursive: true });
}

async function main() {
  console.log('='.repeat(60));
  console.log('SCRAPER TEST - YourSource');
  console.log('='.repeat(60));

  // Import scraper
  const { scrapeYourSource } = await import('../lib/scrapers/yoursource');

  // Run scraper
  const startTime = Date.now();
  const events = await scrapeYourSource();
  const duration = Date.now() - startTime;

  // Save results
  fs.writeFileSync(
    path.join(DEBUG_DIR, 'events.json'),
    JSON.stringify(events, null, 2)
  );

  // Display summary
  console.log(`\nCompleted in ${(duration / 1000).toFixed(1)}s`);
  console.log(`Found ${events.length} events`);

  // Field completeness
  const withImages = events.filter(e => e.imageUrl).length;
  const withPrices = events.filter(e => e.price && e.price !== 'Unknown').length;
  const withZips = events.filter(e => e.zip).length;

  console.log(`\nField Completeness:`);
  console.log(`  Images: ${withImages}/${events.length} (${Math.round(withImages/events.length*100)}%)`);
  console.log(`  Prices: ${withPrices}/${events.length} (${Math.round(withPrices/events.length*100)}%)`);
  console.log(`  Zips: ${withZips}/${events.length} (${Math.round(withZips/events.length*100)}%)`);

  // Sample events with timezone verification
  console.log(`\nSample Events (verify timezone!):`);
  for (const e of events.slice(0, 5)) {
    console.log(`\n${e.title}`);
    console.log(`  UTC:     ${e.startDate.toISOString()}`);
    console.log(`  Eastern: ${e.startDate.toLocaleString('en-US', { timeZone: 'America/New_York' })}`);
    console.log(`  Location: ${e.location || 'N/A'}`);
    console.log(`  Price: ${e.price}`);
  }

  console.log(`\nDebug files saved to: ${DEBUG_DIR}`);
}

main().catch(console.error);
```

## Step 2.4: Add to package.json

```json
"test:yoursource": "npx tsx scripts/scrapers/test-yoursource.ts"
```

---

# PHASE 3: VALIDATION

Run the test script and verify output:

```bash
npm run test:yoursource
```

## Validation Checklist

- [ ] **Timezone correct**: Eastern times match expected (7 PM event shows as 7 PM ET)
- [ ] **No HTML entities**: Titles/locations decoded (`&` not `&amp;`)
- [ ] **No duplicate cities**: Location format is clean
- [ ] **Prices reasonable**: Mix of Free, $X, Unknown
- [ ] **Zip codes populated**: Most events have zips
- [ ] **URLs unique**: No duplicates
- [ ] **Future events only**: No past dates

---

# PHASE 4: DATABASE TESTING

## ⚠️ MANDATORY: You MUST Complete This Phase

**DO NOT declare production-ready until you have inserted test events into the real database and verified they display correctly.**

Scraper output validation alone is NOT sufficient. Database insertion can reveal:
- Timezone conversion issues
- Field truncation
- Constraint violations
- Display problems

## Step 4.1: Insert Test Events

```typescript
// scripts/scrapers/test-yoursource-db.ts
import 'dotenv/config';
import { db } from '../lib/db';
import { events } from '../lib/db/schema';
import { eq } from 'drizzle-orm';
import { scrapeYourSource } from '../lib/scrapers/yoursource';

async function main() {
  // Check existing
  const existing = await db.select().from(events).where(eq(events.source, 'YOUR_SOURCE'));
  console.log(`Existing YOUR_SOURCE events: ${existing.length}`);

  // Scrape a few events
  const scraped = await scrapeYourSource();
  const testEvents = scraped.slice(0, 5);

  // Insert
  for (const event of testEvents) {
    await db.insert(events).values({
      ...event,
      tags: [],
      lastSeenAt: new Date(),
    }).onConflictDoUpdate({
      target: events.url,
      set: { lastSeenAt: new Date() },
    });
    console.log(`Inserted: ${event.title}`);
  }

  // Verify - THIS IS THE CRITICAL CHECK
  console.log('\n=== VERIFICATION ===\n');
  const inserted = await db.select().from(events).where(eq(events.source, 'YOUR_SOURCE'));

  for (const e of inserted) {
    console.log(`${e.title}`);
    console.log(`  DB Date:  ${e.startDate}`);
    console.log(`  Eastern:  ${e.startDate.toLocaleString('en-US', { timeZone: 'America/New_York' })}`);
    console.log(`  Location: ${e.location}`);
    console.log(`  Zip:      ${e.zip}`);
    console.log(`  Price:    ${e.price}`);
    console.log('');
  }

  console.log('To cleanup: DELETE FROM events WHERE source = \'YOUR_SOURCE\';');
}

main().catch(console.error);
```

## Step 4.2: Verify Checklist

- [ ] Events inserted without errors
- [ ] Dates display correctly in Eastern time
- [ ] All fields populated as expected
- [ ] No HTML entities in text
- [ ] Zip codes present

## Step 4.3: Cleanup Test Data

```bash
npx tsx -e "
import 'dotenv/config';
import { db } from './lib/db';
import { events } from './lib/db/schema';
import { eq } from 'drizzle-orm';
db.delete(events).where(eq(events.source, 'YOUR_SOURCE')).then(() => console.log('Cleaned up'));
"
```

---

# PHASE 5: PRODUCTION INTEGRATION

## Step 5.1: Update Cron Route

Edit `app/api/cron/scrape/route.ts`:

```typescript
// Add import
import { scrapeYourSource } from '@/lib/scrapers/yoursource';

// Add to Promise.allSettled array
const [..., yourSourceResult] = await Promise.allSettled([
  ...,
  scrapeYourSource(),
]);

// Extract results
const yourSourceEvents = yourSourceResult.status === 'fulfilled' ? yourSourceResult.value : [];

// Log failures
if (yourSourceResult.status === 'rejected')
  console.error('[Scrape] YourSource failed:', yourSourceResult.reason);

// Add to stats
stats.scraping.total = ... + yourSourceEvents.length;

// Add to allEvents
const allEvents = [..., ...yourSourceEvents];

// Update log message
console.log(`... YourSource: ${yourSourceEvents.length} ...`);
```

## Step 5.2: Verify TypeScript Compiles

```bash
npx tsc --noEmit
```

---

# PHASE 6: CLEANUP

```bash
# Remove debug folder
rm -rf debug-scraper-yoursource

# Remove test DB script if created
rm scripts/scrapers/test-yoursource-db.ts
```

---

## Integration Checklist

- [ ] **Exploration**
  - [ ] Detected CMS/platform
  - [ ] Tried known API endpoints
  - [ ] Tested API parameters (start_date, per_page, page)
  - [ ] Documented field mapping
  - [ ] Identified timezone handling approach

- [ ] **Development**
  - [ ] Added source to `types.ts`
  - [ ] Created scraper file
  - [ ] Created test script
  - [ ] Added npm script

- [ ] **Validation**
  - [ ] Timezone verified (Eastern times correct)
  - [ ] HTML entities decoded
  - [ ] Location strings clean (no duplicates)
  - [ ] Field completeness acceptable

- [ ] **Database Testing (MANDATORY)**
  - [ ] Inserted test events
  - [ ] Verified dates in database
  - [ ] Confirmed all fields correct
  - [ ] Cleaned up test data

- [ ] **Production**
  - [ ] Added to cron route
  - [ ] TypeScript compiles
  - [ ] Ready for deployment

---

## Common Utilities Reference

### Timezone
```typescript
import { getTodayStringEastern, parseAsEastern } from '@/lib/utils/timezone';

// Get today's date in Eastern (for API start_date param)
const today = getTodayStringEastern(); // "2025-12-16"

// Parse ambiguous local time as Eastern
const date = parseAsEastern('2025-12-25', '19:00:00');
```

### Price Formatting
```typescript
import { formatPrice } from '@/lib/utils/parsers';

formatPrice(0);        // "Free"
formatPrice(25.50);    // "$26"
formatPrice(null);     // "Unknown"
```

### HTML Entities
```typescript
import { decodeHtmlEntities } from '@/lib/utils/parsers';

decodeHtmlEntities('Rock &amp; Roll &#8211; Live');
// "Rock & Roll – Live"
```

### Location Filtering
```typescript
import { isNonNCEvent } from '@/lib/utils/geo';

// Returns true if event should be EXCLUDED (not in NC)
if (isNonNCEvent(event.title, event.location)) continue;
```

### Zip Code Fallbacks
```typescript
import { getZipFromCoords, getZipFromCity } from '@/lib/utils/geo';

let zip = venue.zip || getZipFromCoords(lat, lng) || getZipFromCity(city);
```

---

## Troubleshooting

### API Returns 403/429
- Add realistic headers (User-Agent, Accept, Referer)
- Increase delays between requests (200-500ms)
- Some APIs require `Referer` header matching the site

### Dates Off by Hours
- Check Timezone Decision Tree above
- Verify API returns UTC vs local time
- Compare API local time with your parsed Eastern time

### Duplicate Events
- Ensure `url` is unique per event
- For recurring events, append date to URL: `${url}#${date}`

### Missing Events
- Check pagination (off-by-one errors)
- Verify `start_date` parameter format
- API may have max page limit

### HTML in Titles/Locations
- Apply `decodeHtmlEntities()` to ALL text fields
- Check for `<br>`, `<p>` tags that need stripping

### Duplicate City in Location
- Check if city already in address before appending
- Common with APIs that include full address + separate city field
