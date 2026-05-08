---
name: dev-swarm-market-research
description: Conduct comprehensive market research and competitive analysis to validate the problem and understand the market landscape. Use when user asks to conduct market research, validate market, analyze competitors, or start Stage 1 after init-ideas.
---

# AI Builder - Market Research

This skill conducts comprehensive market research and competitive analysis to validate the problem defined in init-ideas and understand the market landscape.

## When to Use This Skill

- User asks to conduct "market research"
- User wants to "validate the market" or "analyze competitors"
- User requests to start Stage 1 or the next stage after init-ideas
- User wants to understand market landscape before building

## Prerequisites

This skill requires the **00-init-ideas** stage to be completed first. The market research will build upon the problem statement, target users, and value proposition defined in that stage.

## Your Roles in This Skill

- **Product Manager**: Conduct market research and competitive analysis (5-7 competitors). Create initial product vision and goals. Define key features and prioritization (P0/P1/P2).
- **Data Analyst**: Analyze market size and trends. Research competitor metrics and performance. Identify data requirements for success tracking. Define key metrics to measure.
- **Marketing Manager**: Conduct market opportunity assessment. Identify target audience segments. Estimate customer acquisition costs. Define initial positioning and messaging.

## Role Communication

As an expert in your assigned roles, you must announce your actions before performing them using the following format:

As a {Role} [and {Role}, ...], I will {action description}

This communication pattern ensures transparency and allows for human-in-the-loop oversight at key decision points.
## Instructions

Follow these steps in order:

### Step 0: Verify Prerequisites and Gather Context

1. **Check if `00-init-ideas/` folder exists (mandatory):**
   - If NOT found: Inform user they need to init ideas first, then STOP
   - If found: Read all files to understand.

2. Read and apply rules: `dev-swarm/docs/research-specs-rules.md`

3. **Check if this stage should be skipped:**
   - Check if `01-market-research/SKIP.md` exists
   - **If SKIP.md exists:**
     - Read SKIP.md to understand why this stage was skipped
     - Inform the user: "Stage 1 (market-research) is marked as SKIP because [reason from SKIP.md]"
     - Ask the user: "Would you like to proceed to the next stage (personas)?"
     - **If user says yes:**
       - Exit this skill and inform them to run the next stage skill
     - **If user says no:**
       - Ask if they want to proceed with market research anyway
       - If yes, delete SKIP.md and continue with this skill
       - If no, exit the skill

3. **Check if `01-market-research/` folder exists with README.md:**
   - **If README.md exists (update mode):**
     - Read README.md to understand what was planned
     - Read all existing files in the folder
     - Inform the user: "Market research stage has existing documentation. I will update it based on the latest information from 00-init-ideas."
     - Ask the user: "Should I update the existing market research documentation? (yes/no)"
     - **If user says no:**
       - Ask what they want to do instead
       - Exit if needed
     - **If user says yes:**
       - Proceed to Step 1 in UPDATE MODE (refine existing docs)

   - **If folder doesn't exist or only has .gitkeep (create mode):**
     - Proceed to Step 1 in CREATE MODE (create new docs)

   - **If README.md exists:** Check whether it requires diagrams. If it does,
     follow `dev-swarm/docs/mermaid-diagram-guide.md` and use the
     `dev-swarm-mermaid` skill to render outputs.

4. Proceed to Step 1 with gathered context

### Step 1: Create/Update README.md Based on init-ideas

**CRITICAL: Create/update README.md first, get user approval, then create other docs.**

1. **Analyze information from 00-init-ideas/:**
   - **First, check what files exist** in 00-init-ideas/ (use Glob or Read to list files)
   - **Read ALL existing files** to gather context:
     - Problem statement (understand the problem to research)
     - Target users (understand who has this problem)
     - Value proposition (understand the solution domain)
     - Owner requirements (understand specific requirements)
     - Cost budget (understand budget constraints for this stage)
     - Any other documentation files that exist
   - **Don't assume file names** - read whatever exists in the folder

2. **Create or update 01-market-research/README.md:**
   - List deliverables explicitly in README (typical: market-overview.md, competitor-analysis.md, gap-analysis.md, pricing-research.md, validation-findings.md)
   - **Stage overview and objectives** (based on init-ideas context)
   - **Owners:** Product Manager, Data Analyst, Marketing Manager
   - **Diagrams (if required by project init):**
     - Reference `dev-swarm/docs/mermaid-diagram-guide.md`
     - Include `diagram/` deliverables when needed
   - **Research goal:**
     - What problem domain will be researched (NOT technology)
     - Why this research matters for the project
     - What specific aspects will be investigated
     - What documents will be created as research output
   - **Research scope and constraints:**
     - Budget allocation for this stage (from cost-budget.md)
     - Time/depth trade-offs if applicable
     - What will NOT be researched (technology, frameworks, etc.)
   - **Status:** In Progress (update to "Completed" after research is done)

3. **Present README to user:**
   - Show the research goal and what will be researched
   - Show what documentation files will be created
   - Explain how it aligns with init-ideas
   - Ask: "Does this market research plan look good? Should I proceed with the research?"

4. **Wait for user approval:**
   - **If user says yes:** Proceed to Step 2
   - **If user says no:**
     - Ask what needs to be changed
     - Update README based on feedback
     - Ask for approval again

### Step 2: Identify Research Focus - Core Project Value

**CRITICAL: Focus on WHAT the project does, NOT the technology used to build it.**

Before conducting any research, identify the **core value/purpose** of the project:

1. **Read and analyze the init-ideas documentation:**
   - What problem is being solved?
   - What value proposition is being delivered?
   - What does the end product do for users?

2. **Determine the research focus:**
   - **CORRECT Example:** If building a "Flutter mobile app for food delivery"
     - Research: food delivery market, competitors in food delivery, user needs for ordering food
     - **DO NOT** research: Flutter framework, mobile app development trends

   - **CORRECT Example:** If building a "Python CLI tool for database migrations"
     - Research: database migration solutions, existing migration tools, developer pain points with migrations
     - **DO NOT** research: Python language, CLI frameworks

   - **CORRECT Example:** If building a "React web app for project management"
     - Research: project management software market, PM tool competitors, team collaboration needs
     - **DO NOT** research: React ecosystem, web development trends

3. **The research must be narrow and focused:**
   - Research the **unique idea** the user wants to build
   - Research the **problem domain** and **solution space**
   - Research **competitors solving the same problem**
   - **NOT** the technology stack or frameworks

4. **Present the research focus to user for confirmation:**
   - Clearly state what problem domain will be researched
   - List the key research questions based on init-ideas
   - Explain what will NOT be researched (technology, frameworks, etc.)
   - Ask: "Does this research focus match your expectations? Should I proceed?"

5. **Wait for user approval before starting web searches**

### Step 3: Conduct/Update Market Research Using Web Search

**Only after user confirms the research focus:**

**If files already exist (UPDATE MODE):**
- Update them based on latest context from 00-init-ideas and user feedback
- Improve and refine existing content, add new research findings
- Ensure data is current and relevant to the core project value
- Ensure research focuses on the problem/solution domain, not technology

**If files don't exist (CREATE MODE):**
- Create new files with comprehensive research
- **Only create files as specified in the approved README**
- Focus all research on the core project value identified in Step 2

Use web search capabilities to gather information for each document:

**After completing all research:**
- Update README.md to change **Status** from "In Progress" to "Completed"
- Add a **Research Summary** section with key findings (2-3 paragraphs)
- Add a **Generated Files** section listing all created files with brief descriptions
- The README serves as the summary - detailed results are in the generated files

**IMPORTANT: The guidelines below are EXAMPLES to illustrate typical research content.**
**The actual files you create must match what was specified in the approved README.**
**File names, structure, and content should be tailored to the specific project needs.**

---

**Example: Typical README.md content (if not already created):**
- Stage overview and objectives
- Specify the owners: Product Manager, Data Analyst, Marketing Manager
- Research goal (what problem domain, what documents will be created)
- Research scope and constraints
- Status: In Progress (updated to "Completed" after research)
- Research Summary (added after completion - key findings in 2-3 paragraphs)
- Generated Files (added after completion - list of created files with brief descriptions)

**Example: market-overview.md (typical content):**
- **Focus on the problem/solution domain** (not technology)
- Market size for the specific problem being solved (TAM, SAM, SOM estimates)
- Market trends and growth drivers in the problem domain
- Industry dynamics and forces
- Key market segments in the solution space
- Growth projections
- Data sources and references
- **Example:** For a food delivery app, research the food delivery market, not mobile app market

**Example: competitor-analysis.md (typical content):**
- Identify 5-7 direct and indirect competitors **solving the same problem**
- **CRITICAL:** Competitors should be in the same problem domain, not just using the same tech stack
- **Example:** For a database migration tool, competitors are other migration tools (Flyway, Liquibase), NOT other Python CLI tools
- For each competitor document:
  - Product overview
  - Key features and capabilities
  - Target audience
  - Strengths and weaknesses
  - Market position
  - Pricing model (if available)
  - User reviews and feedback (if available)
- Competitive positioning quadrant (if applicable)
- Competitive summary table

**Example: gap-analysis.md (typical content):**
- Unmet needs in the current market
- Opportunities competitors are missing
- Pain points not adequately addressed
- Features users want but don't have
- Your product's unique opportunity
- How your value proposition fills the gaps

**Example: pricing-research.md (typical content):**
- Competitor pricing models and tiers
- Price ranges in the market
- Value-for-money perception
- Willingness to pay signals from user research
- Pricing strategy recommendations
- Monetization model options

**Example: validation-findings.md (typical content):**
- Evidence the problem is real and significant
- User pain points validated through:
  - Online research (forums, reviews, social media)
  - Market data and reports
  - Industry publications
  - User feedback (if available)
- Problem severity and frequency
- User willingness to adopt solutions
- Market readiness assessment

### Step 4: Research Execution Tips

When conducting research:

1. **ALWAYS start by identifying the core project value:**
   - What problem is being solved?
   - What is the unique idea?
   - What domain/industry does this belong to?

2. **Research the PROBLEM DOMAIN, not the technology:**
   - Focus searches on the problem being solved
   - Search for competitors in the same problem space
   - Avoid researching the tech stack, frameworks, or platforms

3. **Use Web Search Tool** extensively for:
   - Market size data and reports **in the problem domain**
   - Competitor information and reviews **solving the same problem**
   - Industry trends and analysis **in the solution space**
   - User feedback on forums and review sites **about the problem**
   - Pricing information **for similar solutions**

4. **Document Sources**: Include URLs and references for all data

5. **Be Specific**: Use concrete numbers, dates, and examples

6. **Stay Objective**: Present both positive and negative findings

7. **Focus on Recent Data**: Prioritize information from the last 1-2 years

8. **Cross-Reference**: Validate findings across multiple sources

9. **Validate Research Relevance:**
   - After gathering data, ask: "Does this research help understand the problem/solution domain?"
   - If researching technology instead of the problem, STOP and refocus

### Step 5: User Review of Completed Research

1. Inform the user that research is complete and README.md has been updated with summary
2. Ask the user to review the market research documentation in `01-market-research/`
3. Ask if they want to proceed to the next stage (personas and user stories)
4. Make any adjustments based on user feedback

### Step 6: Commit to Git (if user confirms)

1. **If user confirms the research is complete:**
   - Ask if they want to commit to git
2. **If user wants to commit:**
   - Stage all changes in `01-market-research/`
   - Use the dev-swarm-draft-commit-message skill to draft the commit message
   - Commit with the drafted message (should follow conventional commit format)
   - Example: "feat(market-research): complete market research and competitive analysis for [problem domain]"

## Expected Output Structure

**NOTE: This is an EXAMPLE structure. The actual files created should match the approved README.**

```
project-root/
├── 00-init-ideas/
│   └── [existing files]
└── 01-market-research/
    ├── README.md (with owners, research goal, status, summary after completion, and list of generated files)
    └── [Research output files - examples below]
        ├── market-overview.md (if specified)
        ├── competitor-analysis.md (if specified)
        ├── gap-analysis.md (if specified)
        ├── pricing-research.md (if specified)
        └── validation-findings.md (if specified)
```

**The actual files may have different names or structure based on project needs.**

## Key Principles

- **Research the PROBLEM/SOLUTION domain, NOT the technology:**
  - Focus on what the product does for users, not how it's built
  - Research competitors solving the same problem, not using the same tech stack
  - Understand the market for the unique value proposition, not the platform/framework
- **Narrow and focused research:**
  - Identify the core project value before starting research
  - Stay focused on the specific problem domain
  - Avoid generic technology or platform research
- Conduct thorough research using web search
- Analyze 5-7 competitors minimum for comprehensive view (in the same problem domain)
- Validate that the problem is real and significant
- Identify clear market opportunities and gaps
- Document all sources and references
- Stay objective and data-driven
- Focus on actionable insights
- **Respect budget constraints** from 00-init-ideas/cost-budget.md

## Deliverables

By the end of this stage, you should have:
- Comprehensive market overview with size estimates **for the problem domain**
- Detailed competitive analysis of 5-7 competitors **solving the same problem**
- Clear gap analysis showing opportunities **in the solution space**
- Pricing research and monetization insights **from similar solutions**
- Evidence validating the problem is real and worth solving
- **All research focused on the core project value, NOT the technology stack**
