---
name: find-local-events
description: Search for local events, activities, and happenings in a specified location and timeframe. Use when the user asks about events, concerts, festivals, meetups, or things to do in a specific area.
license: MIT
---

# Find Local Events

Search for local events, activities, concerts, festivals, and happenings in a specified location and timeframe.

## When to Use This Skill

Use this skill when:

- User asks about events in a specific location
- User wants to find things to do in an area
- User requests information about concerts, festivals, or activities
- User asks what's happening on a specific date or timeframe
- User wants to discover local happenings or meetups

## Critical Parameters

### Location

**ALWAYS clarify the location before searching**. Location can be specified as:

- City name (e.g., "Seattle", "Portland")
- City with state/country (e.g., "Portland, OR" vs "Portland, ME")
- Neighborhood or district (e.g., "Capitol Hill, Seattle")
- Venue name (e.g., "The Paramount Theatre")
- ZIP code or postal code

**Location Disambiguation**: If location is ambiguous or not provided:

1. Check CONTEXT.md for user's default location
2. If no default, ask user to specify location
3. For common city names, ask for clarification (e.g., "Did you mean Portland, OR or Portland, ME?")

### DateTime

**ALWAYS clarify the timeframe before searching**. TimeFrames include:

- Specific date (e.g., "December 15", "next Friday")
- Date range (e.g., "this weekend", "next week")
- Relative time (e.g., "tonight", "tomorrow", "this month")
- Open-ended (e.g., "upcoming events")

**DateTime Handling**:

1. Current date/time is critical for interpreting relative dates
2. Default to user's timezone (check CONTEXT.md)
3. If timeframe is vague, ask for clarification
4. Always convert relative dates to specific dates before searching

**Examples of Date Clarification**:

- "this weekend" → Confirm which Saturday/Sunday dates
- "next week" → Clarify Monday-Sunday date range
- "soon" → Ask if they mean this week, this month, etc.

## Process

### Step 1: Parse User Request

Extract key information:

1. **Location** (required)
2. **DateTime/Timeframe** (required)
3. **Event type** (optional: concerts, sports, festivals, etc.)
4. **Additional filters** (optional: free events, family-friendly, etc.)

### Step 2: Verify Parameters with User

Before searching, confirm:

- Location is specific and unambiguous
- DateTime range is clear
- User's timezone is correct
- Event type preferences (check CONTEXT.md for user's interests)

### Step 3: Search for Events

Use available tools to search:

1. Web search for event listings
2. Check event aggregator sites (Eventbrite, Meetup, etc.)
3. Search local venue calendars
4. Look for community calendars and listing sites

**Search Strategy**:

```bash
# Example web search query construction
"events in [LOCATION] on [DATE]"
"[EVENT_TYPE] in [LOCATION] [TIMEFRAME]"
"things to do in [LOCATION] [TIMEFRAME]"
```

### Step 4: Filter and Personalize Results

1. Filter by event type based on user interests (see CONTEXT.md)
2. Prioritize events matching user's stated preferences
3. Exclude event types user typically avoids
4. Sort by date/relevance

### Step 5: Present Results

Format event information clearly:

- Event name and type
- Date and time (in user's timezone)
- Location/venue with address
- Brief description
- Link for more information
- Price/cost if applicable

## Examples

### Example 1: Basic Event Search

**User Input**:
"What events are happening in Seattle this weekend?"

**Process**:

1. Extract location: "Seattle"
2. Extract timeframe: "this weekend"
3. Clarify: "This weekend is December 16-17, 2023. Is that correct?"
4. Check CONTEXT.md for user's event preferences
5. Search for events in Seattle on those dates
6. Filter based on user interests

**Expected Output**:

```text
Events in Seattle this weekend (Dec 16-17, 2023):

Saturday, December 16:
• Seattle Symphony - Holiday Pops Concert
  When: 7:30 PM
  Where: Benaroya Hall, 200 University St
  Cost: $45-85
  More info: seattlesymphony.org

• Capitol Hill Art Walk
  When: 6:00 PM - 9:00 PM
  Where: Various galleries on Capitol Hill
  Cost: Free
  More info: capitolhillartwalk.com

Sunday, December 17:
• Pike Place Market Festival
  When: 10:00 AM - 4:00 PM
  Where: Pike Place Market
  Cost: Free
  More info: pikeplacemarket.org
```

### Example 2: Specific Event Type

**User Input**:
"Are there any live music shows in Portland next Friday?"

**Process**:

1. Location ambiguity detected
2. Ask: "Which Portland - Portland, OR or Portland, ME?"
3. User clarifies: "Portland, OR"
4. Calculate next Friday's date
5. Search specifically for live music/concerts
6. Present results

**Expected Output**:

```text
Live music in Portland, OR on Friday, December 22, 2023:

• The Decemberists
  When: 8:00 PM
  Where: Crystal Ballroom, 1332 W Burnside St
  Cost: $35-50
  Genre: Indie Folk
  More info: crystalballroompdx.com

• Jazz Night at Jimmy Mak's
  When: 9:00 PM
  Where: Jimmy Mak's, 221 NW 10th Ave
  Cost: $15
  Genre: Jazz
  More info: jimmymaks.com
```

### Example 3: Open-Ended Discovery

**User Input**:
"What's happening in Austin next month?"

**Process**:

1. Extract location: "Austin" (assume Austin, TX)
2. Timeframe: "next month" is January 2024
3. Check CONTEXT.md for user preferences
4. Broad search across event types
5. Filter to user's top interests
6. Present diverse selection

**Expected Output**:

```text
Upcoming events in Austin, TX (January 2024):

Highlighted for you (based on your interests):

Tech Events:
• Austin Tech Meetup - AI in Practice
  When: Jan 10, 6:30 PM
  Where: Capital Factory
  Cost: Free

Music:
• Austin City Limits - Winter Series
  When: Jan 15, 7:00 PM
  Where: ACL Live at the Moody Theater
  Cost: $40-75

Food & Drink:
• Austin Food + Wine Festival
  When: Jan 20-22
  Where: Auditorium Shores
  Cost: $75-150 per day

[Show 15 more events...]
```

## Best Practices

### Location Handling

- Always confirm location if ambiguous
- Use full city names with state/country for clarity
- Store user's default location in CONTEXT.md
- Handle neighborhood-level specificity when provided

### DateTime Handling

- Never assume dates - always calculate from current date
- Confirm timezone (default to user's timezone from CONTEXT.md)
- Be explicit about date ranges
- Handle "this weekend" vs "next weekend" carefully
- Account for events spanning multiple days

### Personalization

- Reference CONTEXT.md for user's event preferences
- Prioritize event types user enjoys
- Note dietary restrictions for food events
- Consider accessibility needs if specified
- Remember past event interests

### Search Quality

- Use multiple sources for comprehensive results
- Verify event details are current (check date posted)
- Include both mainstream and niche events
- Filter out past events
- Note if events require registration/tickets

## Common Pitfalls

- **Ambiguous locations**: Portland, Springfield, Cambridge - always clarify
- **Timezone confusion**: Event times vs user timezone
- **Outdated information**: Verify events are still happening
- **Missing location**: User says "here" - must clarify actual location
- **Vague timeframes**: "soon", "later" - get specific dates
- **Sold out events**: Check availability before recommending
- **Recurring events**: Clarify which occurrence user wants

## Dependencies

- Web search capability
- Current date/time for relative date calculations
- CONTEXT.md for user preferences and default location
- Access to event aggregator sites

## Error Handling

**Location Not Specified**:

```text
I need to know the location to search for events.
Where would you like to find events?
```

**Ambiguous Location**:

```text
There are multiple cities named "Springfield".
Did you mean Springfield, IL, Springfield, MA, or Springfield, MO?
```

**No Events Found**:

```text
I couldn't find any [EVENT_TYPE] events in [LOCATION] on [DATE].
Would you like to:
1. Expand the date range?
2. Search for different event types?
3. Try a nearby location?
```

**Timeframe Not Specified**:

```text
What timeframe are you interested in?
- Today/Tonight
- This weekend
- Next week
- Specific date
```

**Past Date Specified**:

```text
That date has already passed. Did you mean [NEXT_OCCURRENCE]?
Or would you like to search for upcoming events instead?
```

## Integration with CONTEXT.md

This skill relies heavily on CONTEXT.md for personalization:

1. **Default location**: User's home city/preferred search area
2. **Event preferences**: Types of events user typically enjoys
3. **Timezone**: User's local timezone for date/time calculations
4. **Accessibility needs**: Any requirements for venue accessibility
5. **Budget preferences**: Free events only, price ranges, etc.
6. **Past interests**: Events user has asked about before

Always check CONTEXT.md first to provide personalized, relevant results.
