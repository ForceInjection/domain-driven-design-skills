---
name: learning-about-you
description: "Proactively learn about the user through onboarding and ongoing observation. Use at session start and when you notice potential preferences."
allowed-tools:
  - mcp__shared-memory__get_user_profile
  - mcp__shared-memory__update_user_profile
  - mcp__shared-memory__propose_profile_inference
  - mcp__shared-memory__confirm_profile_update
  - mcp__shared-memory__reject_profile_update
  - mcp__shared-memory__get_onboarding_questions
  - mcp__shared-memory__analyze_codebase_for_profile
  - mcp__shared-memory__add_memory
  - Bash
  - Read
---

# Learning About You

This skill helps me remember who you are, what you prefer, and how you like to work. The goal is to make our interactions more personalized over time, while keeping you in control of what I learn.

## When to Use This Skill

- **Session start**: Check profile, ask onboarding questions if incomplete
- **New project context**: Analyze codebase for tech preferences
- **Preference signals**: When user expresses likes/dislikes, expertise, or goals
- **Periodically**: Every few sessions, fill in profile gaps

## Onboarding Flow

### First Interaction (Profile Empty)

1. Call `get_user_profile` to check current state
2. If identity is empty, warmly introduce and ask 2-3 quick questions:
   - "What name should I use for you?"
   - "What's your timezone?" (helps with greetings!)
   - "What's your primary role?" (developer, founder, student, etc.)
3. Store answers with `update_user_profile`

### Subsequent Sessions

- Check `meta.lastOnboardingPrompt` - don't ask new questions if < 3 days
- Gradually fill gaps over sessions:
  - **Session 2-3**: Technical preferences (languages, frameworks, editor)
  - **Session 4-5**: Working style (verbosity, communication)
  - **Later**: Personal context (interests, goals) - only if user seems open

### Question Guidelines

- **Never more than 2-3 questions at once**
- Frame as helpful: "Knowing X helps me Y"
- Always offer skip: "Feel free to skip if you'd rather not say"
- Be conversational, not form-like
- Respect "I'd rather not say" - don't ask again

## Ongoing Learning

### Detecting Preferences from Conversation

Watch for signals:

**Explicit statements:**
- "I prefer TypeScript" → `technical.languages`
- "I use VS Code" → `technical.editors`
- "I'm learning Rust" → `knowledge.learning`
- "Keep it brief" → `workingStyle.verbosity: concise`

**Implicit signals:**
- Verbose code comments → `workingStyle` may be 'detailed'
- Lots of "why" questions → `learningPace` may be 'thorough'
- Quick, terse responses → `verbosity` likely 'concise'

### Confirmation Protocol

When you detect a preference with medium+ confidence:

1. Call `propose_profile_inference` with evidence
2. Present naturally in conversation:
   - "I noticed you seem to prefer TypeScript - should I remember that?"
   - "You mentioned you're learning Rust. Want me to keep that in mind?"
3. Wait for user response
4. If confirmed → `confirm_profile_update`
5. If rejected → `reject_profile_update` (won't ask again)

### Codebase Analysis

When starting work in a new project:

1. Call `analyze_codebase_for_profile` with the project directory
2. Review detected preferences
3. Present high-confidence inferences naturally for confirmation
4. Skip low-confidence ones unless highly relevant

## Using Profile Data

When responding to the user:

- Adjust explanation depth based on `knowledge.expert` vs `knowledge.learning`
- Match verbosity to `workingStyle.verbosity`
- Reference their timezone for time-related suggestions
- Use their name occasionally (not every message)
- Remember their goals when suggesting solutions

## Profile Structure

```
identity:
  name, pronouns, timezone, location, role, organization

technical:
  languages[], frameworks[], tools[], editors[], patterns[]

workingStyle:
  verbosity (concise|detailed|adaptive)
  learningPace (fast|thorough|adaptive)
  priorities[]

knowledge:
  expert[], proficient[], learning[], interests[]

personal:
  interests[] (hobbies)
  goals[] (personal/professional)
  context[] (life context, freeform)
```

## Privacy Principles

- All data stays local unless user enables Mem0 sync
- Never store sensitive info (passwords, API keys, financial)
- User can view/edit profile anytime
- Respect "I'd rather not say" responses
- Don't infer age, health, politics, religion

## Example Interactions

### First Session
```
Agent: Hi! I'd love to personalize our interactions. Quick questions:
       - What name should I use for you?
       - What's your timezone?
       - What's your primary role?

       (Feel free to skip any you'd rather not answer)
```

### Detecting a Preference
```
User: I always use TypeScript for new projects
Agent: Got it! Should I remember that you prefer TypeScript?
User: Yes
Agent: [calls confirm_profile_update] Perfect, I'll keep that in mind.
```

### Using Profile Context
```
User: How should I structure this?
Agent: [checks profile: user is expert in React, learning Go]
       Since you're experienced with React, you might appreciate
       a component-based approach. For the Go backend, I'll explain
       the patterns in more detail since you mentioned you're learning it.
```
