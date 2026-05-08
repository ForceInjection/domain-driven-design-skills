---
name: hn-title
description: This skill should be used when the user wants to create, analyze, or improve blog titles for Hacker News submissions. Invoke when the user mentions "HN title", "Hacker News title", wants to optimize their post title, or wants to increase their chances of reaching the HN front page.
---

# Hacker News Title Skill

## Overview

This skill helps create compelling, HN-appropriate blog titles that maximize your chances of reaching the front page. It analyzes titles using proven HN best practices, generates alternatives, and provides concrete suggestions for improvement.

## When to Use This Skill

Trigger this skill when the user:
- Asks for help creating an HN title
- Wants to improve an existing blog title for HN submission
- Mentions "Hacker News" or "HN" in context of title creation
- Wants to analyze if their title would perform well on HN
- Asks what makes a good HN title

## HN Title Best Practices

### Core Principles

1. **Be Clear and Direct**
   - State exactly what the article is about
   - Avoid mystery, intrigue, or clickbait
   - Front-load the most interesting part
   - Use concrete nouns over vague concepts

2. **Be Concise**
   - Aim for 8-12 words (50-80 characters)
   - Every word should add information
   - Remove filler words and adjectives
   - Get to the point immediately

3. **Show Technical Depth**
   - Indicate specific technologies, algorithms, or concepts
   - Use technical terminology appropriately
   - Suggest complexity without being obscure
   - Show you've done something non-trivial

4. **Be Authentic**
   - Avoid superlatives (amazing, incredible, revolutionary)
   - Don't oversell or hype
   - Be honest about limitations
   - Match the HN community's skeptical mindset

### What Works on HN

**Strong patterns:**
- Technical deep dives: "How SQLite scales to 4M QPS on a single server"
- Contrarian insights: "Why I rewrote my app in vanilla JavaScript"
- Problem-solving: "Building a distributed task queue with Redis"
- Learning narratives: "What I learned optimizing PostgreSQL for 100TB"
- Show HN projects: "Show HN: I built a compiler in Rust"
- Technical postmortems: "How we debugged a memory leak in production"
- Numbers and specifics: "Reducing Docker image size from 1.2GB to 30MB"
- Year tags for older content: "Understanding Unix pipes (2018)"

**Weak patterns:**
- Clickbait: "You won't believe what happened when..."
- Vague promises: "The secret to writing better code"
- Hype: "The amazing tool that will change everything"
- Overly broad: "Thoughts on programming"
- Listicles: "10 ways to improve your code"
- Personal appeals: "Please check out my project"

### Title Structure Templates

#### Pattern 1: Technical Achievement
Format: `[Action] [Technology/Domain] [Specific Result/Scale]`
- "Implementing ray tracing in 100 lines of C"
- "Building a Redis clone in Rust"
- "Scaling to 1M concurrent WebSocket connections"

#### Pattern 2: Learning/Discovery
Format: `[What I learned/discovered] [doing specific thing]`
- "What I learned building a database from scratch"
- "Lessons from parsing 10TB of JSON"
- "Understanding memory allocation in Go"

#### Pattern 3: Contrarian/Controversial
Format: `Why [controversial opinion about technology]`
- "Why I ditched React for vanilla JavaScript"
- "Why we moved from microservices back to a monolith"
- "Why SQLite is the only database you need"

#### Pattern 4: Problem-Solution
Format: `[Problem] and how we solved it`
- "Our API was too slow, here's how we fixed it"
- "Debugging a race condition in production"
- "How we reduced AWS costs by 90%"

#### Pattern 5: Show HN
Format: `Show HN: [Project name] – [concise description]`
- "Show HN: A terminal-based Git client in Go"
- "Show HN: Self-hosted analytics alternative to Google Analytics"
- "Show HN: I built a visual regex debugger"

#### Pattern 6: Technical Explanation
Format: `[How X works] or [Understanding X]`
- "How Git stores data internally"
- "Understanding TCP congestion control"
- "How modern JavaScript bundlers work"

## Process

### Phase 1: Analyze Context

1. **Understand the Content**
   - Read the blog post or ask the user to describe it
   - Identify the core technical contribution
   - Note specific technologies, numbers, or results
   - Determine the target audience

2. **Identify Key Elements**
   - What problem does this solve?
   - What's technically interesting?
   - What's surprising or counterintuitive?
   - What specific results can be quantified?
   - What technologies are involved?

### Phase 2: Generate Title Candidates

Create 5-8 title variations using different patterns:

1. **Direct approach**: State the main point clearly
2. **Technical depth**: Emphasize specific technologies
3. **Contrarian angle**: Highlight unconventional choices
4. **Results-focused**: Lead with impressive numbers
5. **Learning narrative**: Frame as knowledge sharing
6. **Problem-solution**: Present the challenge and outcome

For each candidate:
- Aim for 8-12 words
- Use specific technical terms
- Include numbers when relevant
- Avoid hype and superlatives
- Front-load the most interesting part

### Phase 3: Evaluate and Rank

Score each title on these criteria (1-5 scale):

**Clarity (weight: 2x)**
- Is it immediately clear what the article is about?
- Would a technical reader understand the topic?

**Specificity (weight: 2x)**
- Does it include specific technologies or numbers?
- Is it concrete rather than abstract?

**Interest (weight: 1.5x)**
- Is there something surprising or non-obvious?
- Would an engineer find this technically interesting?

**Authenticity (weight: 1.5x)**
- Does it avoid hype and clickbait?
- Is it honest about what the article delivers?

**Conciseness (weight: 1x)**
- Is every word necessary?
- Is it under 80 characters?

Calculate weighted scores and rank titles.

### Phase 4: Refine Top Candidates

For the top 2-3 titles:
1. Remove any unnecessary words
2. Replace vague terms with specific ones
3. Move the most interesting part to the front
4. Check character count (aim for 50-80)
5. Read aloud to check flow
6. Verify technical accuracy

### Phase 5: Present Recommendations

Provide:
1. **Top 3 recommended titles** with rationale
2. **Scoring breakdown** for each
3. **Specific improvements** made from original
4. **HN submission tips** for the chosen title
5. **Alternative angles** if the user wants more options

## Red Flags to Avoid

### Immediate Disqualifiers
- Clickbait phrasing ("you won't believe", "this one trick")
- ALL CAPS or excessive punctuation
- Emoji (unless showing emoji-related content)
- Questions in the title (usually)
- "How to" for basic topics
- Superlatives without evidence ("best", "fastest" without numbers)

### Warning Signs
- Starting with "A" or "An" (often removable)
- Using "just" or "simply" (condescending)
- Vague adjectives ("great", "awesome", "interesting")
- Missing technical specifics
- Over 15 words or 100 characters
- Generic industry buzzwords

## Special Cases

### Show HN Posts
- Must start with "Show HN:"
- Include project name and brief description
- Focus on what it does, not why it's great
- Example: "Show HN: Terminal-based Markdown editor in Rust"

### Older Content
- Add (YYYY) to indicate year for content over 2 years old
- Example: "How Dropbox stores billions of files (2018)"
- Helps set expectations and context

### Academic/Research Papers
- Keep the original title if it's clear
- Or: "Paper: [Short title] – [key finding]"
- Example: "Paper: Raft consensus algorithm – easier than Paxos"

### Ask HN Posts
- Start with "Ask HN:"
- Be specific about what you're asking
- Example: "Ask HN: How do you debug production memory leaks?"

## Examples

### Example 1: Original to Optimized

**Original:**
"Amazing new approach to building web applications"

**Analysis:**
- ❌ "Amazing" is hype/clickbait
- ❌ "new approach" is vague
- ❌ No specific technologies mentioned
- ❌ Doesn't convey what the approach is

**Candidates:**
1. "Building web apps without a JavaScript framework"
2. "Why I ditched React and use vanilla JavaScript"
3. "Web components vs React: A performance comparison"
4. "Reducing bundle size from 300KB to 10KB"

**Recommended:** "Building web apps without a JavaScript framework"
- ✅ Clear and specific
- ✅ Slightly contrarian (no framework)
- ✅ Concrete approach
- ✅ No hype, just facts

### Example 2: Technical Deep Dive

**Original:**
"My thoughts on databases"

**Analysis:**
- ❌ Too vague and broad
- ❌ No specific database technology
- ❌ "Thoughts" suggests opinion piece without depth
- ❌ Not clear what the article covers

**Candidates:**
1. "How PostgreSQL uses B-trees for indexing"
2. "Understanding MVCC in PostgreSQL"
3. "Why SQLite is perfect for edge computing"
4. "Building a key-value store in 500 lines of Go"
5. "What I learned implementing a LSM tree"

**Recommended:** "How PostgreSQL uses B-trees for indexing"
- ✅ Specific technology (PostgreSQL, B-trees)
- ✅ Educational/technical depth
- ✅ Clear topic
- ✅ Appeals to database engineers

### Example 3: Project Launch

**Original:**
"Check out my new project - it's really cool!"

**Analysis:**
- ❌ Doesn't say what the project is
- ❌ "really cool" is subjective hype
- ❌ Personal appeal ("check out")
- ❌ No technical details

**Candidates:**
1. "Show HN: Visual debugger for regular expressions"
2. "Show HN: Self-hosted alternative to Google Analytics"
3. "Show HN: I built a terminal file manager in Rust"
4. "Show HN: Static site generator using Deno"

**Recommended:** "Show HN: Visual debugger for regular expressions"
- ✅ Clear what it does
- ✅ Specific problem (regex debugging)
- ✅ Visual = interesting approach
- ✅ Solves a common pain point

### Example 4: Performance Story

**Original:**
"How I made my app faster"

**Analysis:**
- ❌ Too vague ("made faster")
- ❌ No numbers or specifics
- ❌ Doesn't indicate what kind of app
- ❌ No technical details about how

**Candidates:**
1. "Reducing Docker image size from 1.2GB to 30MB"
2. "How we reduced API latency from 500ms to 20ms"
3. "Optimizing PostgreSQL for 100TB datasets"
4. "Scaling to 1M requests/second with Cloudflare Workers"

**Recommended:** "Reducing Docker image size from 1.2GB to 30MB"
- ✅ Specific numbers (40x improvement)
- ✅ Concrete technology (Docker)
- ✅ Practical problem many face
- ✅ Impressive but believable result

## Quick Checklist

Before submitting, verify:
- [ ] Title clearly states what the article is about
- [ ] No clickbait, hype, or superlatives
- [ ] Includes specific technologies or numbers (when relevant)
- [ ] 8-12 words, 50-80 characters
- [ ] Front-loaded with most interesting information
- [ ] Technically accurate
- [ ] Honest about what's inside
- [ ] No unnecessary words or filler
- [ ] Appropriate for HN's technical audience
- [ ] Matches HN title guidelines (no self-promotion in title)

## Using This Skill

When you invoke this skill, I will:

1. Ask you to provide either:
   - Your current title for analysis
   - A description of your blog post content
   - A link to your blog post

2. Analyze your content to identify:
   - Core technical contribution
   - Interesting angles
   - Specific technologies and numbers
   - Target audience appeal

3. Generate 5-8 title candidates using different patterns

4. Score and rank them based on HN best practices

5. Present the top 3 with:
   - Rationale for each
   - Scoring breakdown
   - Why they would work on HN

6. Refine based on your feedback

Let's create a title that gets your technical content the attention it deserves on Hacker News!
