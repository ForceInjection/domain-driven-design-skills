---
name: quarterly-review
description: Conduct a quarterly review of your overall research mission and direction. This is a user-level review stored in ~/.researchAssistant/. Use when the user types /quarterly_review, every 3 months, after major project milestones, or when questioning research direction.
---

# Quarterly Review

> Conduct a quarterly review of your overall research mission and direction.
> This is a user-level review stored in ~/.researchAssistant/

## When to Use
- Every 3 months (RA will prompt)
- After major project milestones
- When questioning research direction
- Before annual reviews or planning

## Execution Steps

### 1. Gather Context

Read these files:
- `~/.researchAssistant/researcher_telos.md` - Research mission
- `~/.researchAssistant/quarterly/` - Previous quarterly reviews
- `.research/project_telos.md` - Current project state
- `.research/logs/monthly/*.md` - Monthly reviews from quarter

### 2. Generate Quarterly Review

Save to `~/.researchAssistant/quarterly/YYYY-QN.md`:

```markdown
# Quarterly Review: [YEAR] Q[N]

*Review period: [Start Date] - [End Date]*

## Research Mission Check

### Your Stated Mission
[From researcher_telos.md]

### This Quarter's Work
[Summary of what you actually worked on]

### Alignment Score: [1-5]
1 = Completely off track
3 = Partially aligned  
5 = Strongly aligned

**Reflection**: [How aligned was your work with your mission?]

## Project Summary

### Active Projects This Quarter

| Project | Phase | Progress | Notes |
|---------|-------|----------|-------|
| [Project 1] | [Phase] | [%] | [Brief status] |
| [Project 2] | [Phase] | [%] | [Brief status] |

### Key Accomplishments
1. [Major accomplishment]
2. [Major accomplishment]
3. [Major accomplishment]

### Papers/Outputs
- [ ] Papers submitted: [N]
- [ ] Papers published: [N]
- [ ] Presentations given: [N]
- [ ] Tools/code released: [N]

## Skill Development

### Skills Used Frequently
- [Skill 1]
- [Skill 2]

### Skills Developed/Improved
- [New or improved skill]

### Skills to Develop
- [Gap identified]

## Energy & Sustainability

### Work Patterns
- Average weekly hours: [Estimate]
- Sustainable pace: [Yes/No/Barely]
- Burnout indicators: [None/Some/Concerning]

### What Energized You
- [Activity or work that was engaging]

### What Drained You
- [Activity or work that was exhausting]

## Strategic Questions

### What Should I Start Doing?
[New habits, approaches, or focuses]

### What Should I Stop Doing?
[Things that aren't serving your mission]

### What Should I Continue Doing?
[What's working well]

## Looking Ahead: Next Quarter

### Top 3 Priorities
1. [Priority] - Why: [Reason]
2. [Priority] - Why: [Reason]
3. [Priority] - Why: [Reason]

### Projects to Focus On
- [Project 1]: [Goal for next quarter]
- [Project 2]: [Goal for next quarter]

### Stretch Goals
- [Ambitious but possible goal]

### Potential Risks
- [What could derail next quarter]
- [Mitigation strategy]

## Mission Refinement

Based on this quarter's experience, should your mission evolve?

**Current mission**: [From researcher_telos.md]

**Proposed update**: [If any changes suggested]
- [ ] Keep mission as-is
- [ ] Minor refinement (same direction, clearer wording)
- [ ] Significant update (new understanding)

## Action Items

- [ ] Update researcher_telos.md with any mission changes
- [ ] Adjust project priorities if needed
- [ ] Schedule any needed conversations (PI, collaborators)
- [ ] Set up systems to address gaps identified

---

*Completed: [TIMESTAMP]*
*Next quarterly review: [DATE]*
```

### 3. Interactive Components

This is a deeper reflection. Ask:

```
Let's do your quarterly reflection. Take a moment to think big-picture.

1. What work this quarter felt most meaningful?

2. What work felt like a distraction from your real goals?

3. If you could go back 3 months, what would you do differently?

4. Are you becoming the researcher you want to be? 
   What's helping? What's hindering?

5. What's one change that would have the biggest positive impact 
   on the next quarter?

Take your time - these answers are just for you.
```

### 4. Update User Profile

If mission has evolved, prompt:
```
Based on your reflection, your research mission might be evolving.

Current: [Old mission statement]
Suggested: [Refined based on responses]

Would you like to update your researcher_telos.md?
```

### 5. Next Steps

```
Quarterly review saved to ~/.researchAssistant/quarterly/[QUARTER].md

Recommended next steps:

A) Update your research mission
   Your reflection suggests some evolution in direction

B) Realign project priorities
   Ensure current projects serve your mission

C) Address sustainability concerns
   [If burnout indicators detected]

D) Celebrate your progress! 🎉
   You accomplished [key wins] this quarter

What would you like to focus on?
```

## Related Skills

- `weekly-review` - Tactical progress
- `monthly-review` - Project alignment
- `next` - Get next suggestion

## Notes

- Quarterly reviews are about strategy, not tactics
- Be honest about what's working and what isn't
- It's okay for your mission to evolve
- This review is private (stored in home directory)
- Patterns over time matter more than any single quarter
