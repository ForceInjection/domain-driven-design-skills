---
name: Christmas Bundle Order Counter
description: Count and report on Christmas bundle orders (XMAS prefix AND Status='Processed' only). Includes day-of-week analysis. Use when user asks about Christmas bundle orders, holiday bundles, XMAS orders, most popular day of week for orders, or wants to know how many Christmas gift boxes have been ordered. DO NOT use for breast cancer awareness bundles (BCA prefix). ONLY count Processed orders, NOT Archived or Open orders.
---

# Christmas Bundle Order Counter Skill

This skill queries the Caspio database to retrieve and count Christmas bundle orders specifically.

## What This Skill Does

Fetches quote sessions from the database that meet BOTH criteria:
1. QuoteID starts with "XMAS"
2. Status = "Processed"

Provides:
- Total count of PROCESSED Christmas bundle orders only
- List of processed orders with key details (QuoteID, customer name, quantity, amount)
- Total revenue from processed Christmas bundles
- Total quantity of bundles in processed orders
- Breakdown by sales representative (Processed orders only)
- **Top selling products** by category (Jackets, Hoodies, Beanies, Gloves) with style numbers and percentages
- **Day-of-week analysis** showing which days receive the most orders with weekday vs weekend breakdown

## When to Use This Skill

Use this skill when the user asks questions like:
- "How many Christmas bundle orders do I have?"
- "Show me my Christmas bundle orders"
- "What's the status of holiday bundles?"
- "How many XMAS orders came in?"
- "Which sales rep has the most Christmas bundle orders?"
- "Show me Christmas bundles by sales rep"
- "What are the top selling products in Christmas bundles?"
- "What jacket/hoodie is selling best?"
- "Which jacket style is most popular?"
- "What day of the week do we get the most Christmas bundle orders?"
- "Which day is most popular for XMAS orders?"
- "Show me Christmas orders by day of week"

## Implementation

**Use this exact working code pattern to query and process Christmas bundle orders.**

### Step 1: Fetch Quote Sessions from API

```bash
# Save all quote sessions to a file
curl -s "https://caspio-pricing-proxy-ab30a049961a.herokuapp.com/api/quote_sessions" -o /c/Users/erik/Downloads/quotes_full.json
```

### Step 2: Fetch Quote Items from API

```bash
# Save all quote items to analyze product selections
curl -s "https://caspio-pricing-proxy-ab30a049961a.herokuapp.com/api/quote_items" -o /c/Users/erik/Downloads/all_items.json
```

### Step 3: Process Data with Python

```bash
cd /c/Users/erik/Downloads && python3 << 'PYEOF'
import json
from collections import defaultdict, Counter

# Load quote sessions
with open('quotes_full.json', 'r') as f:
    sessions = json.load(f)

# Load quote items
with open('all_items.json', 'r') as f:
    all_items = json.load(f)

# CRITICAL: Apply TWO filters (BOTH must be true)
processed_xmas = [
    order for order in sessions
    if order.get('QuoteID', '').startswith('XMAS')     # Filter 1: XMAS prefix
    and order.get('Status') == 'Processed'              # Filter 2: Processed status
]

print(f'Total Processed XMAS Orders: {len(processed_xmas)}')
print()

# Calculate totals
total_revenue = sum(float(order.get('TotalAmount', 0)) for order in processed_xmas)
total_quantity = sum(int(order.get('TotalQuantity', 0)) for order in processed_xmas)

print(f'Total Revenue: ${total_revenue:,.2f}')
print(f'Total Bundles: {total_quantity}')
print()

# Group by sales rep
by_rep = defaultdict(lambda: {'count': 0, 'revenue': 0, 'quantity': 0})

for order in processed_xmas:
    # Priority: SalesRepName, then SalesRep, then Unassigned
    rep = order.get('SalesRepName') or order.get('SalesRep') or 'Unassigned'
    by_rep[rep]['count'] += 1
    by_rep[rep]['revenue'] += float(order.get('TotalAmount', 0))
    by_rep[rep]['quantity'] += int(order.get('TotalQuantity', 0))

# Display sales rep breakdown
print('Sales Rep Breakdown:')
for rep in sorted(by_rep.keys(), key=lambda r: by_rep[r]['count'], reverse=True):
    stats = by_rep[rep]
    pct = (stats['count'] / len(processed_xmas) * 100) if processed_xmas else 0
    avg = stats['revenue'] / stats['count'] if stats['count'] > 0 else 0
    print(f"  {rep}: {stats['count']} orders ({pct:.0f}%) | ${stats['revenue']:,.2f} revenue | {stats['quantity']} bundles | Avg: ${avg:.2f}/order")

print()
print("=" * 60)
print("TOP SELLING CHRISTMAS BUNDLE PRODUCTS")
print("=" * 60)
print()

# Get processed XMAS quote IDs
processed_xmas_ids = set(order['QuoteID'] for order in processed_xmas)

# Filter items for Processed XMAS orders
xmas_items = [
    item for item in all_items
    if item.get('QuoteID') in processed_xmas_ids
]

# Parse BundleConfiguration to extract product selections
jackets = []
hoodies = []
beanies = []
gloves = []

for item in xmas_items:
    bundle_config = item.get('BundleConfiguration')
    if bundle_config:
        try:
            config = json.loads(bundle_config)

            # CRITICAL: Count ORDERS not bundle quantity!
            # Each ORDER has one jacket style choice, one hoodie style choice, etc.
            # Even if someone orders 4 bundles (Quantity=4), all 4 bundles have the SAME jacket
            # So we count this as 1 order choosing that jacket style
            # Do NOT multiply by Quantity - just count the order once

            if 'jacket' in config:
                jacket_full = config['jacket']
                jacket_style = jacket_full.split(' - ')[0] if ' - ' in jacket_full else jacket_full
                jackets.append(jacket_style)  # Count once per order

            if 'hoodie' in config:
                hoodie_full = config['hoodie']
                hoodie_style = hoodie_full.split(' - ')[0] if ' - ' in hoodie_full else hoodie_full
                hoodies.append(hoodie_style)  # Count once per order

            if 'beanie' in config:
                beanie_full = config['beanie']
                beanie_style = beanie_full.split(' - ')[0] if ' - ' in beanie_full else beanie_full
                beanies.append(beanie_style)  # Count once per order

            if 'gloves' in config:
                gloves_full = config['gloves']
                gloves_style = gloves_full.split(' - ')[0] if ' - ' in gloves_full else gloves_full
                gloves.append(gloves_style)  # Count once per order

        except Exception as e:
            pass

# Display top selling products
if jackets:
    jacket_counter = Counter(jackets)
    print("TOP JACKETS:")
    for style, count in jacket_counter.most_common(10):
        pct = (count / len(jackets) * 100) if jackets else 0
        print(f"  {style}: {count} orders ({pct:.1f}%)")
    print()

if hoodies:
    hoodie_counter = Counter(hoodies)
    print("TOP HOODIES:")
    for style, count in hoodie_counter.most_common(10):
        pct = (count / len(hoodies) * 100) if hoodies else 0
        print(f"  {style}: {count} orders ({pct:.1f}%)")
    print()

if beanies:
    beanie_counter = Counter(beanies)
    print("TOP BEANIES:")
    for style, count in beanie_counter.most_common(10):
        pct = (count / len(beanies) * 100) if beanies else 0
        print(f"  {style}: {count} orders ({pct:.1f}%)")
    print()

if gloves:
    gloves_counter = Counter(gloves)
    print("TOP GLOVES:")
    for style, count in gloves_counter.most_common(10):
        pct = (count / len(gloves) * 100) if gloves else 0
        print(f"  {style}: {count} orders ({pct:.1f}%)")

print()
print("=" * 60)
print("DAY OF WEEK ANALYSIS")
print("=" * 60)
print()

# Analyze day of week from CreatedAt field
from datetime import datetime

days_of_week = []

for order in processed_xmas:
    created_at = order.get('CreatedAt')
    if created_at:
        try:
            # Parse the datetime string
            dt = datetime.strptime(created_at, '%Y-%m-%dT%H:%M:%S')

            # Get day of week (0=Monday, 6=Sunday)
            day_num = dt.weekday()
            day_names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
            day_name = day_names[day_num]

            days_of_week.append(day_name)
        except Exception as e:
            pass

# Count orders by day of week
day_counter = Counter(days_of_week)

print("ORDERS BY DAY OF WEEK:")
print()

# Display in order Monday-Sunday
day_order = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
for day in day_order:
    count = day_counter.get(day, 0)
    pct = (count / len(days_of_week) * 100) if days_of_week else 0
    bar = '█' * int(pct / 2)  # Visual bar chart
    print(f"  {day:12} : {count:3} orders ({pct:5.1f}%) {bar}")

print()
if day_counter:
    most_popular = day_counter.most_common(1)[0]
    print(f"Most Popular Day: {most_popular[0]} with {most_popular[1]} orders")

print()
print("WEEKDAY vs WEEKEND:")
weekday_count = sum(day_counter.get(day, 0) for day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'])
weekend_count = sum(day_counter.get(day, 0) for day in ['Saturday', 'Sunday'])

if days_of_week:
    weekday_pct = (weekday_count / len(days_of_week) * 100)
    weekend_pct = (weekend_count / len(days_of_week) * 100)
    print(f"  Weekdays (Mon-Fri): {weekday_count} orders ({weekday_pct:.1f}%)")
    print(f"  Weekends (Sat-Sun): {weekend_count} orders ({weekend_pct:.1f}%)")
PYEOF
```

### Expected Output

Running this code should return approximately:

**Order Statistics:**
- **80 Processed XMAS orders**
- **Total Revenue: ~$23,657.00**
- **Total Bundles: ~320**

**Sales Rep Breakdown:**
- **Nika: ~47 orders (59%)**
- **Taneisha: ~33 orders (41%)**

**Top Selling Products:**
- **Top Jacket:** CT104670 (~46 orders, 56.8%)
- **Top Hoodie:** CTK121 (~61 orders, 75.3%)
- **Top Beanie:** CT104597 (100% - standard option)
- **Top Gloves:** CTGD0794 (100% - standard option)

**Day of Week Analysis:**
- **Most Popular Day:** Thursday with ~26 orders (32.5%)
- **Second Place:** Friday with ~16 orders (20.0%)
- **Weekdays:** ~77 orders (96.2%)
- **Weekends:** ~3 orders (3.8%)

## Usage in Response

When responding to the user:

1. **Call the API** using the fetch pattern above
2. **Present the summary** with key statistics:
   - Total number of Christmas bundle orders
   - Total revenue
   - Total quantities
   - Breakdown by status
   - Breakdown by sales representative (count, revenue, quantity per rep)
3. **List recent orders** (limit to 10 most recent unless user asks for more)
4. **Format currency** with $ and 2 decimal places
5. **Include dates** in readable format (e.g., "January 15, 2025")
6. **Sort sales rep breakdown** by order count (highest first)

## Example Response Format

```
📊 Christmas Bundle Order Summary (PROCESSED ONLY)

Total PROCESSED Orders: 20
Total Revenue: $5,712.00
Total Bundles: 80

Sales Rep Breakdown (Processed Orders Only):
👤 Taneisha: 11 orders (55%) | $3,181.00 revenue | 44 bundles | Avg: $289.18/order
👤 Nika: 9 orders (45%) | $2,531.00 revenue | 36 bundles | Avg: $281.22/order

Recent Processed Orders:
1. XMAS1020-1128 - Kelsie Stroud (Nika) - 4 bundles - $283.00 - Processed
2. XMAS1017-2560 - April M Edwards (Taneisha) - 4 bundles - $238.00 - Processed
[... continue list ...]

Note: This report ONLY includes orders with Status="Processed".
Archived and Open orders are excluded from all totals.
```

## Important Notes

- **CRITICAL: TWO-PART FILTER REQUIRED**
  1. QuoteID must start with "XMAS" (not BCA, not any other prefix)
  2. Status must equal "Processed" (not "Archived", not "Open")
  - **Both conditions must be true** - do not count orders that don't meet both criteria
- **Exclude Archived orders** - Even if they have XMAS prefix, if Status="Archived" they should NOT be counted
- **Exclude Open orders** - Even if they have XMAS prefix, if Status="Open" they should NOT be counted
- **Check QuoteID field** for the prefix, not other fields
- **Handle missing data gracefully** - Some fields may be null or empty strings
- **Always show currency with 2 decimals** - Format as $X,XXX.XX
- **Sort by date** - Most recent first when showing lists (use CreatedAt field)
- **Sales rep field priority**: Use `SalesRepName` first, fall back to `SalesRep`, then "Unassigned"
- **Use Bash tool with curl** to fetch the data from API
- **Count manually** from the JSON response or use simple grep/awk commands
- **Show percentages** when displaying sales rep breakdown to show distribution
- **Calculate averages**: Average order value, average bundles per order
