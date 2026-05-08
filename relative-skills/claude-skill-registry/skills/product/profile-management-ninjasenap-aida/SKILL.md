---
name: profile-management
description: Interactive profile setup and management. Use when user wants to view, update, or set up their profile. Auto-triggers on phrases like "min profil", "uppdatera profil", "ändra profil", "profile setup", "inställningar", "preferences".
allowed-tools: Bash, Read, Write
---

# Profile Management Skill

## Purpose

Provides interactive profile management including:
- New profile setup wizard for first-time users
- Profile viewing and section exploration
- Interactive updates through conversation
- Profile gap analysis and suggestions
- Integration with auto-learning observations

## Triggers

- **Auto-triggers**: "min profil", "uppdatera profil", "ändra profil", "profile setup", "inställningar", "preferences"
- **NOT auto-triggered**: "visa profil" (direct CLI query), observation-related phrases (route to profile-learner agent)

## Relationship to profile-learner Agent

This skill has a clear integration with the profile-learner agent:

**profile-management skill** = View/update profile (user-initiated CRUD operations)
**profile-learner agent** = Analyze patterns, create observations (background analysis)

### Routing Flow for Observation-Related Requests

```
User: "vad har du lärt dig om mig?" / "granska observationer"
  ↓
Main agent routes to @agent-profile-learner
  ↓
Agent analyzes data, creates/updates observations
  ↓
Agent invokes this skill (via skills: profile-management)
  ↓
OBSERVATIONS-REVIEW.md displays results
```

**Phrases that route to profile-learner agent first:**
- "vad har du lärt dig om mig?" (What have you learned about me?)
- "granska observationer" (review observations)
- "har du sett några mönster?" (have you seen any patterns?)

**Phrases that trigger this skill directly:**
- "min profil" (my profile)
- "uppdatera profil" / "ändra profil" (update profile)
- "profile setup"
- "inställningar" / "preferences"

**Phrases that use direct CLI query (not this skill):**
- "visa min profil" → `profile getFullProfile`

## Critical Rules

- **ALL profile operations MUST use `aida-cli.ts`** with the `profile` module
- **NEVER expose raw JSON** to user - always format nicely in Swedish
- **Use Swedish** for user-facing output
- **Ask one question at a time** during setup
- **Validate before saving** any changes
- **Show observations transparently** - user should understand what AIDA has learned

## Tool Contract

**Allowed CLI Operations (profile module only):**
- **FULL ACCESS**: profileExists, getProfile, getSection, getAttribute, updateAttribute, initializeProfile
- **TIME QUERIES**: getCurrentTimePeriod, getCurrentEnergyLevel, getActivitiesForEnergy
- **OBSERVATIONS**: getObservations, applyObservationSuggestion, getSuggestionAcceptanceRate

**Forbidden Operations:**
- Any task operations
- Any journal operations
- Any role/project management
- Profile deletion (if such function exists)

**Update Requirements:**
- source: always "user" (this skill represents user-initiated changes)
- reason: required for all updates

**File Access:**
- **Read**: `personal-profile.json`
- **No direct file writes** - All updates via CLI

## 🚨 How to Access Profile

**ONLY use the `aida-cli.ts` tool for ALL profile operations:**

```bash
# Get full profile
bun run src/aida-cli.ts profile getProfile

# Get specific section
bun run src/aida-cli.ts profile getSection "identity"
bun run src/aida-cli.ts profile getSection "energy_pattern"
bun run src/aida-cli.ts profile getSection "neurotype"

# Get nested attribute
bun run src/aida-cli.ts profile getAttribute "identity.name"
bun run src/aida-cli.ts profile getAttribute "neurotype.challenges"
bun run src/aida-cli.ts profile getAttribute "roles.1.label"

# Update attribute
bun run src/aida-cli.ts profile updateAttribute "identity.location.city" '"Stockholm"' "user" "User moved to Stockholm"

# Get current time period and energy
bun run src/aida-cli.ts profile getCurrentTimePeriod
bun run src/aida-cli.ts profile getCurrentEnergyLevel
bun run src/aida-cli.ts profile getActivitiesForEnergy "high"

# Initialize new profile
bun run src/aida-cli.ts profile initializeProfile '{"name":"Henrik"}'

# Check if profile exists
bun run src/aida-cli.ts profile profileExists

# Learning observations
bun run src/aida-cli.ts profile getObservations
bun run src/aida-cli.ts profile getObservations "energy"
bun run src/aida-cli.ts profile applyObservationSuggestion "<observation-id>"

# Feedback history
bun run src/aida-cli.ts profile getSuggestionAcceptanceRate "task_suggestion"
```

## Workflows

### 1. Profile Setup Wizard (No Profile Exists)

See [SETUP-WIZARD.md](SETUP-WIZARD.md) for step-by-step procedure.

**Summary:**
1. Welcome user, explain AIDA's purpose and how profile helps
2. Collect required fields progressively (name, time definitions, energy pattern, at least one role)
3. Ask about optional neurotype information (sensitively)
4. Ask about optional sections (values, tools, background)
5. Validate and create profile
6. Confirm creation and show friendly summary

### 2. View Profile Summary

See [VIEW-PROFILE.md](VIEW-PROFILE.md) for formatting rules.

**Summary:**
1. Check if profile exists
2. Load profile sections
3. Format in user-friendly Swedish
4. Highlight active roles and current energy level
5. Show observation count if any exist
6. Offer to explore specific sections or make updates

### 3. Update Profile Section

See [UPDATE-FLOW.md](UPDATE-FLOW.md) for interaction pattern.

**Summary:**
1. Identify what user wants to update
2. Show current value
3. Ask for new value with guidance and examples
4. Validate input
5. Confirm change before applying
6. Log update with source and reason

### 4. Review Learning Observations

See [OBSERVATIONS-REVIEW.md](OBSERVATIONS-REVIEW.md) for display format.

**Summary:**
1. Fetch active observations
2. Show each observation with:
   - Pattern description
   - Evidence supporting it
   - Confidence level
   - Suggested profile update
3. For each observation, ask user: Apply / Dismiss / Keep observing
4. If apply, update profile automatically and mark observation as applied
5. If dismiss, mark as dismissed and optionally ask why
6. Show summary of applied changes

## Supporting Documentation

- [SETUP-WIZARD.md](SETUP-WIZARD.md) - New profile creation flow
- [VIEW-PROFILE.md](VIEW-PROFILE.md) - Profile display formatting
- [UPDATE-FLOW.md](UPDATE-FLOW.md) - Update interaction patterns
- [OBSERVATIONS-REVIEW.md](OBSERVATIONS-REVIEW.md) - Learning observation review

## Design Principles

1. **Progressive disclosure** - Show summaries first, details on request
2. **One question at a time** - Never overwhelm with forms
3. **Validation with explanation** - Explain why something is invalid
4. **Transparency** - Show what changes will be made before saving
5. **Non-judgmental** - Profile is personal, no "wrong" answers
6. **Privacy-aware** - Be sensitive when asking about neurotype and challenges

## Example Invocations

### User: "Visa min profil"

**Response**:
```
Här är din profil, Henrik! 👤

**Identitet**
Namn: Henrik
Plats: Stockholm, Sverige

**Energimönster** (just nu: eftermiddag, medium energi)
- Hög energi: Djuparbete, kreativt arbete (morgon)
- Medium energi: Möten, kodgranskning (eftermiddag)
- Låg energi: Admin, läsning (kväll)

**Aktiva roller** (4 st)
1. 💼 Developer (40%) - work
2. 📚 Personal Development (30%) - personal
3. 💪 Health & Fitness (20%) - private
4. 🎨 Hobby Projects (10%) - hobby

**Inlärning**
AIDA har gjort 3 observationer om dina arbetsmönster.
Vill du granska dem? (ja/nej)

Vad vill du göra?
- Uppdatera en sektion
- Visa detaljer för en sektion
- Granska AIDA:s observationer
```

### User: "Vad har du lärt dig om mig?"

**Response**:
```
Jag har observerat 3 mönster i ditt arbete:

**1. Energimönster** (förtroende: 85%)
Du slutför 80% av deep work-uppgifter mellan 06:00-09:00.
→ Förslag: Uppdatera "deep_work.preferred_time" till "morning"

Bevis:
- 2025-12-10: Arkitekturdok färdigt kl 07:30
- 2025-12-11: Kodgranskning kl 08:15
- 2025-12-12: Problemlösning kl 08:00

**2. Rollfokus** (förtroende: 90%)
90% av dina completions är i Developer-rollen.
→ Förslag: Öka balance_target från 40% till 50%

**3. Eftermiddagsenergi** (förtroende: 70%)
70% av eftermiddags-check-ins visar låg energi.
→ Förslag: Justera energy_pattern för afternoons

Vill du applicera någon av dessa? (1/2/3/alla/nej)
```

## Success Criteria

- [ ] User can create a profile in < 5 minutes
- [ ] User understands what each section is for
- [ ] Profile displays in friendly, scannable Swedish
- [ ] Updates are confirmed before saving
- [ ] Learning observations are transparent and user-controllable
- [ ] No raw JSON exposed to user
