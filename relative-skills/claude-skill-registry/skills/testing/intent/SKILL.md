---
name: intent
description: Interactive conversation to clarify user intent step-by-step before creating specifications or solutions. Use when requirements are unclear or user has a new idea to explore.
---

# Intent Clarification Skill

## Purpose
Guide the user through a structured conversation to deeply understand their intent before creating specifications or solutions. Ensure alignment at each step.

## Instructions

### Introduction Phase
Start by asking the user to describe their idea or problem in their own words. Be warm and encouraging:
- "Before we dive into specifics, could you describe your idea or the problem you're trying to solve in your own words?"
- Listen actively and acknowledge their response before proceeding

### Step 1: Understanding Core Intent

Ask each question **one at a time**, wait for the response, then acknowledge before moving to the next:

**Q1: Core Problem/Need**
- Ask: "What is the core problem or need that this solution should address?"
- Provide example: "For instance, you might say: 'We need a tool that helps new team members onboard more quickly by centralizing our documentation.'"
- If the answer is vague, ask follow-up questions to get specificity

**Q2: Primary Users & Expectations**
- Ask: "Who will be the primary users or audience for this solution, and what do they expect to achieve?"
- Provide example: "For example: 'The primary users are new hires who need to find all onboarding materials in one place without asking multiple people.'"
- Probe for specific user personas if needed

**Q3: Constraints & Conditions**
- Ask: "Are there any constraints or specific conditions we should be aware of before designing the solution?"
- Provide example: "Such as: 'The solution must be accessible on mobile devices and integrate with our existing single sign-on system.'"
- Ask about technical, budget, timeline, or organizational constraints

**Summary Checkpoint:**
- Synthesize what you've heard into 2-3 clear bullet points
- Ask: "Based on what you've shared, here's what I understand... Does this accurately capture your intent so far?"
- If no, iterate until aligned

### Step 2: Confirming Alignment

**Q4: One-Sentence Goal**
- Ask: "If you had to describe the overall goal of this project in just one sentence, what would it be?"
- This forces clarity and reveals priorities

**Final Confirmation:**
- Summarize the complete intent including:
  - Core problem being solved
  - Target users and their needs
  - Key constraints
  - Overall goal
- Ask: "Does this summary fully reflect what you want to achieve before we move on to the specification phase?"

### Output Deliverable

Once confirmed, create a structured intent document with:
1. **Problem Statement**: Clear articulation of the core problem
2. **User Needs**: Who the users are and what they expect
3. **Constraints**: All identified limitations or requirements
4. **Success Criteria**: What "solved" looks like
5. **Next Steps**: Recommendation for specification phase

## Tone & Style
- Be conversational and patient
- Don't rush through questions
- Validate and acknowledge each response
- Ask clarifying questions when answers are ambiguous
- Use examples to illustrate the level of detail you're looking for

## When to Use This Skill
- User has a new idea but hasn't fully articulated it
- Before starting any significant specification or implementation
- When requirements seem unclear or potentially misaligned
- User says "I want to build X" without explaining why or for whom

---

*Inspired by: ["The AI Failure Mode Nobody Warned You About"](https://www.youtube.com/watch?v=T74uZgfu6mU)*
