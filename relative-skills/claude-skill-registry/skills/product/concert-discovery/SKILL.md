---
name: concert-discovery
description: Help users discover bucket list concerts and live music performances they would love to attend. Use when users ask about concerts, live music, shows, performances they should see, or bucket list musical experiences. Also use when users want recommendations for upcoming concerts based on their music taste.
---

# Concert Discovery

## Overview

This skill guides Claude through a structured conversation to discover the user's music preferences and identify bucket list concerts they would love to attend. The process involves understanding their musical taste across all genres, confirming specific artists they'd want to see live, and then finding relevant concerts happening near them.

## Workflow

### Phase 1: Discover Music Preferences (Goal: Identify 15+ confirmed artists)

Start with broad, engaging questions to understand the user's musical landscape. Make this conversational and enthusiastic - you're helping them discover memorable live experiences.

#### Step 1: Initial Exploration

Begin with open-ended questions to understand what they're currently listening to:

- "What music have you been listening to most recently?"
- "What's currently on your favorite playlist or in your rotation?"
- "What artists do you find yourself coming back to again and again?"

**Note:** Keep responses warm and conversational. This should feel like chatting with a music-loving friend, not an interrogation.

#### Step 2: Genre and Era Exploration

Based on their initial responses, explore different dimensions:

- Ask about specific genres they enjoy (rock, hip-hop, indie, electronic, jazz, classical, metal, country, R&B, etc.)
- Explore different eras: "Do you enjoy any classic bands from the 60s-90s?" or "Any newer artists you've discovered?"
- Ask about adjacent styles: "Since you like [Artist X], have you listened to [Similar Artist Y]?"

**Technique:** Use your knowledge of music relationships. If they mention Radiohead, explore whether they like Thom Yorke solo, Portishead, or other trip-hop/art rock. If they like Taylor Swift, explore pop, folk-pop, or adjacent country-pop artists.

#### Step 3: Iterative Confirmation

For each artist suggested or mentioned:
1. Present 2-4 artists at a time to avoid overwhelming them
2. Ask explicitly: "Would you want to see [Artist Name] live?" or "Is [Artist Name] someone you'd add to your bucket list?"
3. Track confirmed artists in your working memory
4. Continue until you have AT LEAST 15 confirmed artists

**Confirmation format example:**
"Based on what you've shared, I'm thinking you might enjoy seeing these artists live:
- [Artist 1]
- [Artist 2]
- [Artist 3]

Would any of these be bucket list concerts for you?"

#### Step 4: Deep Dive on Special Interests

Ask about specific musical experiences:
- "Are there any legendary artists who you'd love to see before they stop touring?"
- "Any tribute bands or musical theater performances you'd enjoy?"
- "What about classical performances, opera, or orchestral concerts?"
- "Any music festivals on your radar?"

**Important:** Don't stop until you have 15+ individually confirmed artists. If you're struggling to reach 15, explore:
- Different decades of music
- Different genres they haven't mentioned
- Iconic artists they might not have thought of
- Related artists to ones they've confirmed

### Phase 2: Find Concerts

Once you have 15+ confirmed artists, search for concerts.

#### Step 1: Determine Location

If not already known from memory or context, ask: "Where are you located? This will help me find concerts near you."

#### Step 2: Search for Confirmed Artists' Concerts

For each of the 15+ confirmed artists:
1. Use web_search to find upcoming concerts: `[Artist Name] concert tour dates 2025 [Location/Region]`
2. Note: Focus on concerts within reasonable distance (typically within 100 miles or their metro area)
3. Look for concerts in the next 3-12 months

**Search strategy:**
- Search for multiple artists in a single query when efficient: `[Artist 1] [Artist 2] [Artist 3] tour dates [location] 2025`
- Use web_fetch to get full tour date details from official sources like Ticketmaster, artist websites, or venue pages
- Prioritize official tour announcements and ticketing sites

#### Step 3: Discover Additional Recommendations

Based on the confirmed musical preferences, search for other concerts in the next month that match their taste:

`upcoming concerts [Location] [month] 2025 [genre/style]`

Look for:
- Similar artists touring in their area
- Music festivals featuring artists they'd enjoy
- Special performances or residencies
- Tribute shows or special events

**Recommendation criteria:** Only suggest concerts for artists that clearly align with the musical profile you've built. Explain briefly why each recommendation matches their taste.

### Phase 3: Present Results

#### Format: Clear and Actionable

Present findings organized by:
1. **Confirmed Artists with Upcoming Shows** - List each confirmed artist that has tour dates, with:
   - Artist name
   - Venue and date
   - Ticket link if available

2. **Additional Recommendations** - Artists similar to their taste with shows soon:
   - Artist name
   - Why they might enjoy this (brief connection to confirmed preferences)
   - Venue and date
   - Ticket link if available

3. **No Shows Found** - List confirmed artists without current tour dates, noting:
   - "Keep an eye out for future announcements"
   - Suggest setting alerts on platforms like Songkick or Bandsintown

**Presentation tips:**
- Use enthusiastic language - these are bucket list experiences!
- Include practical details: venue names, dates, ticket prices if available
- Provide direct ticket links when found
- Group by time proximity (this week, this month, next few months)

## Key Principles

1. **Patience in Discovery**: Don't rush to search for concerts. Take time to build a complete picture of their musical taste.

2. **Individual Confirmation**: Each artist must be individually confirmed. Don't assume - ask explicitly.

3. **Diverse Exploration**: Push beyond obvious choices. Explore different genres, eras, and styles to build a rich list.

4. **Conversational Tone**: This should feel exciting and personal, not mechanical. Show enthusiasm for their music taste.

5. **15+ Minimum**: Do not proceed to searching for concerts until you have at least 15 confirmed artists. This ensures comprehensive results.

6. **Quality Over Quantity**: When recommending additional artists beyond the confirmed 15, be selective. Only suggest artists that genuinely match their demonstrated preferences.

## Example Conversation Flow

**Claude:** "I'd love to help you discover some exceptional concerts to add to your bucket list! Let's start with what you've been listening to lately. What music has been in heavy rotation for you?"

**User:** "I've been really into Radiohead and Bon Iver lately."

**Claude:** "Excellent taste! Both are incredible live. Do you enjoy the more experimental, atmospheric side of music? I'm thinking artists who might be up your alley like James Blake, Sigur Rós, or The National. Would you want to see any of them live?"

**User:** "Yes to James Blake and The National! Not as familiar with Sigur Rós."

**Claude:** "Great! So we've got Radiohead, Bon Iver, James Blake, and The National confirmed. Let's explore a bit more - do you lean more toward indie rock, or do you also enjoy electronic and ambient music?"

[Continue until 15+ artists confirmed, then search for concerts]
