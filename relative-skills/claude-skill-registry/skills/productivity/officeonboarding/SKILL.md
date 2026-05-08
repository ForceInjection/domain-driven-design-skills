---
name: office:onboarding
description: Set up your personal productivity style and preferences. Use when you first install office or want to customize your workflow patterns.
---

# Office Onboarding

Welcome to **Office**! This skill helps you set up your personal productivity style so that the assistant can help you manage email, calendar, and contacts in a way that matches YOUR preferences.

## When to Use This Skill

- First time installing office-admin
- Want to update your productivity style preferences
- Need to configure how email drafts should sound
- Setting up your working hours and calendar preferences
- Defining your CRM workflow patterns

## Onboarding Process

### Step 1: Introduce Yourself

Ask the user:
1. **What should I call you?** (Their preferred name/nickname)
2. **What's your timezone?** (Default: America/Chicago)
3. **What are your typical working hours?** (Default: 9:30am - 4:30pm, lunch 12:00-1:30pm)

### Step 2: Email Communication Style

Ask about their email preferences:

1. **Email Tone** - How do you typically write emails?
   - Ultra-terse (1-2 lines, no fluff, get to point)
   - Conversational (casual but complete)
   - Professional (formal, structured)
   - Warm (friendly, personal touch)

2. **Email Signatures** - Do you use signatures?
   - None (no signatures or sign-offs)
   - Minimal ("Best," or "Thanks,")
   - Full signature block

3. **Formality Level**
   - Super casual (lowercase is fine, minimal punctuation)
   - Standard (proper grammar and capitalization)
   - Formal (perfect grammar, structured sentences)

4. **Response Length**
   - Minimal (one-liners when possible)
   - Balanced (2-3 sentences typical)
   - Detailed (thorough explanations)

5. **Specific Patterns** - Any phrases or patterns you always use?
   - Examples: "Does [time] work for you?", "Let's sync on this", specific greetings

### Step 3: Calendar Preferences

Ask about calendar management:

1. **Default meeting duration** (Default: 30 minutes)
2. **Buffer time between meetings** (Default: 15 minutes)
3. **Calendar link for scheduling** (If they have one)
4. **Event naming preferences** (Include location? Attendee names?)
5. **Auto-add events from email?** (Yes/No - should calendar skill proactively add events)

### Step 4: CRM Workflow

Ask about contact management:

1. **What type of contacts do you manage?**
   - Professional (colleagues, clients, vendors)
   - Personal (friends, family, social)
   - Mixed (both personal and professional)

2. **How detailed should contact notes be?**
   - Minimal (just basics)
   - Standard (basic context about relationship)
   - Detailed (thorough interaction logging)

3. **Relationship tracking**
   - Track how you know people (who introduced you)
   - Log all interactions automatically
   - Manual logging only

### Step 5: Generate Configuration

After gathering preferences, create a configuration file at:
`~/.claude/office-admin-config.json`

**Format:**
```json
{
  "version": "1.0",
  "personal": {
    "name": "User's Name",
    "timezone": "America/Chicago",
    "workingHours": {
      "start": "09:30",
      "end": "16:30",
      "lunchStart": "12:00",
      "lunchEnd": "13:30"
    }
  },
  "email": {
    "tone": "ultra-terse",
    "signature": "none",
    "formality": "casual",
    "responseLength": "minimal",
    "patterns": [
      "how about [time]?",
      "that works perfect"
    ],
    "customGuidelines": "Additional freeform guidelines from user"
  },
  "calendar": {
    "defaultDuration": 30,
    "bufferMinutes": 15,
    "schedulingLink": "https://user.cal.com/schedule",
    "autoAddFromEmail": true,
    "eventNaming": {
      "includeLocation": true,
      "includeAttendees": false
    }
  },
  "crm": {
    "contactTypes": "mixed",
    "detailLevel": "standard",
    "autoLogInteractions": true,
    "trackRelationships": true
  }
}
```

### Step 6: MCP Server Setup Guide

After configuration, provide guidance on required MCP servers:

**Required Servers:**
1. **Gmail** - For email management
   - Installation: Follow Gmail MCP setup docs
   - Scopes needed: read, send, drafts, labels

2. **Google Calendar** - For calendar management
   - Installation: Follow Calendar MCP setup docs
   - Scopes needed: read, write events

3. **Pagen CRM** (optional) - For contact/company/deal management
   - Installation: Set up Pagen MCP server
   - Requires: Database configuration

4. **Notion** (optional) - For advanced note-taking integration
   - Installation: Follow Notion MCP setup docs

Provide installation links and next steps.

### Step 7: Create Personal Style Guide

Generate a markdown file at `~/.claude/docs/office-admin-style.md` with:

```markdown
# My Office Admin Style Guide

## About Me
- Name: [User's Name]
- Timezone: [Timezone]
- Working Hours: [Hours]

## Email Style

### Tone
[Description of their tone with 3-4 example phrases]

### Typical Responses
- Scheduling: [Example]
- Quick confirms: [Example]
- Declining: [Example]

### What NOT to Do
- [Anti-patterns based on their preferences]

## Calendar Preferences
[Summary of their calendar settings]

## CRM Workflow
[Summary of their contact management approach]
```

## Completing Onboarding

After setup:
1. Confirm configuration was saved
2. Show the user their style guide
3. Suggest they try `/triage-email` or `/draft-email` to test
4. Remind them they can re-run `/setup-office-admin` to update preferences

## Example Interaction

```
Assistant: I'm using the office:onboarding skill to help you set up your personal productivity style.

What should I call you?

User: Call me Alex