---
name: date-timezone
description: |
  Handle date and timezone conversions correctly in forms and displays. Use when working with: Date inputs, new Date(), formatDate, toLocaleDateString, getDate(), getMonth(), getFullYear(), date parsing, UTC conversion, timezone issues, dates displaying wrong day, date-only fields in forms, YYYY-MM-DD parsing. Triggers: dates off by one day, timezone bugs, form date handling, competition dates, event dates, calendar dates.
---

# Date & Timezone Handling

## The Problem

HTML5 date inputs return strings like `"2024-01-15"`. When parsed with `new Date("2024-01-15")`, JavaScript treats this as **UTC midnight**, not local midnight. This causes dates to display incorrectly across timezones.

**Example bug:** User in Pacific timezone (-8) selects Jan 15 → stored as Jan 15 00:00 UTC → displayed using `getDate()` → shows Jan 14 (because UTC midnight is 4pm previous day in Pacific).

## Solution: Use UTC Consistently for Date-Only Fields

For fields that represent calendar dates (not specific moments in time):
1. **Parse** form strings as UTC midnight
2. **Display** using UTC methods

## Utilities in `src/utils/date-utils.ts`

### For Form Inputs

```typescript
import { parseDateInputAsUTC, formatDateInputFromUTC } from "@/utils/date-utils"

// Parsing: form string → Date for server
parseDateInputAsUTC("2024-01-15") // → Date at UTC midnight

// Formatting: Date from DB → form string
formatDateInputFromUTC(date) // → "2024-01-15"
```

### For Display

```typescript
import { formatUTCDateShort, formatUTCDateFull, formatUTCDateRange } from "@/utils/date-utils"

formatUTCDateShort(date)  // → "Jan 15"
formatUTCDateFull(date)   // → "Jan 15, 2024"
formatUTCDateRange(start, end) // → "January 15-17, 2024"
```

## When to Use What

| Scenario | Use |
|----------|-----|
| Date-only form field (start date, end date) | `parseDateInputAsUTC` on submit, `formatDateInputFromUTC` for default value |
| Displaying calendar dates | `formatUTCDateShort`, `formatUTCDateFull`, `formatUTCDateRange` |
| Timestamps (createdAt, updatedAt) | Local time methods are fine (these are actual moments) |

## Common Mistakes to Avoid

```typescript
// BAD - parses as UTC, displays as local
new Date("2024-01-15")
date.getDate()
date.toLocaleDateString()

// GOOD - consistent UTC handling
parseDateInputAsUTC("2024-01-15")
date.getUTCDate()
formatUTCDateFull(date)
```

## Form Pattern

```typescript
// In form component
import { parseDateInputAsUTC, formatDateInputFromUTC } from "@/utils/date-utils"

// Default values (for edit forms)
const form = useForm({
  defaultValues: {
    startDate: formatDateInputFromUTC(existingData.startDate),
  }
})

// On submit
function onSubmit(data) {
  saveToServer({
    startDate: parseDateInputAsUTC(data.startDate),
  })
}
```
