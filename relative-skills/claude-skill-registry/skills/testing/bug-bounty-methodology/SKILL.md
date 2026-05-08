---
name: bug-bounty-methodology
description: Target-agnostic bug bounty hunting methodology with parallel recon, systematic testing workflows, and vulnerability-specific exploitation guidance
contributor: buttercupck
---

# Bug Bounty Methodology Skill

## Overview

This skill provides a complete, target-agnostic bug bounty hunting methodology inspired by industry experts like Hadx and Daniel Miessler. It emphasizes systematic reconnaissance, parallel execution for efficiency, and vulnerability-specific testing workflows that apply to any web application target.

## Core Philosophy

**Three-Phase Approach:**
1. **Intelligence Gathering** (Passive Recon) - No direct target interaction
2. **Active Enumeration** - Verification and endpoint discovery
3. **Targeted Exploitation** - Vulnerability-specific testing based on findings

**Key Principles:**
- Target-agnostic workflows that apply universally
- Parallel agent execution for 5-7 hour tasks completed in ~1 hour wall time
- Systematic documentation of all findings
- Prioritization based on bug bounty program criteria
- Reproducible steps with exact commands

## Skill Invocation Patterns

When the user requests bug bounty work, route to appropriate workflow based on intent:

### Starting New Target Reconnaissance
**User says:** "Start bug bounty recon on [target]" or "Begin reconnaissance for [target]"

**Action:**
1. Read `targets/{target}.md` for scope and context
2. Identify required recon phases (passive, active, js-analysis, mobile)
3. Propose spawning parallel agents for each phase
4. Upon user approval, spawn agents via Task() tool
5. Each agent executes appropriate workflow and outputs to target directory
6. Synthesize findings into prioritized attack roadmap

### Continuing Existing Work
**User says:** "Continue testing [target]" or "Resume [target] work"

**Action:**
1. Read latest findings from `LEARNING/targets/{target}/`
2. Review attack roadmap or previous session notes
3. Identify next priority testing phase
4. Route to appropriate testing workflow

### Specific Vulnerability Testing
**User says:** "Test GraphQL on [target]" or "Check for IDOR in [target] API"

**Action:**
1. Load appropriate testing workflow (`test-graphql.md`, `test-rest-api.md`, etc.)
2. Read target context and discovered endpoints
3. Guide through systematic testing checklist
4. Document findings in target-specific location

### New Target Setup
**User says:** "Add new target [name]" or "Set up [target] for bug bounty"

**Action:**
1. Create new target file from `targets/template.md`
2. Guide user through scope definition
3. Help capture authentication details
4. Document program-specific criteria (payout ranges, exclusions)

## Workflow Routing Logic

### Reconnaissance Phase
- **Passive Recon** → `workflows/recon-passive.md`
  - Subdomain enumeration (crt.sh, subfinder, amass)
  - Technology fingerprinting (Wappalyzer, whatweb)
  - Source code intelligence (GitHub, JavaScript analysis)
  - Mobile app static analysis

- **Active Recon** → `workflows/recon-active.md`
  - Subdomain verification (httpx, dnsx)
  - Web application mapping (gospider, Burp Suite)
  - API endpoint discovery (fuzzing, JavaScript extraction)
  - GraphQL detection and introspection

- **JavaScript Analysis** → `workflows/analyze-javascript.md`
  - Bundle extraction and beautification
  - Endpoint discovery from JS
  - Secret scanning (API keys, tokens)
  - Client-side logic analysis

- **Mobile Analysis** → `workflows/analyze-mobile.md`
  - APK/IPA decompilation
  - String extraction and analysis
  - Hardcoded endpoint discovery
  - Mobile-specific API differences

### Testing Phase

Route based on discovered technology stack and vulnerability category:

- **GraphQL endpoints** → `workflows/test-graphql.md`
- **XSS (Cross-Site Scripting)** → `workflows/test-xss.md`
- **REST APIs** → `workflows/test-api.md`
- **Authentication systems** → `workflows/test-authentication.md`
- **Payment/business logic** → `workflows/test-business-logic.md`
- **File uploads** → `workflows/test-file-upload.md`

### Reporting Phase
- **Bug report creation** → `workflows/report-findings.md`

## Parallel Execution Model

For reconnaissance phases (2-3 hours passive + 3-4 hours active = 5-7 hours linear):

**Spawn 4 Parallel Agents:**

```typescript
// Agent 1: Passive Reconnaissance
Task({
  subagent_type: "general-purpose",
  description: "Passive recon for target",
  prompt: `Execute passive reconnaissance workflow for ${target}.

  Read and follow: .claude/skills/bug-bounty-methodology/workflows/recon-passive.md
  Target context: LEARNING/targets/${target}/${target}.md
  Output findings to: LEARNING/targets/${target}/recon/passive-results.md

  Document all discovered subdomains, technologies, and intelligence.`
})

// Agent 2: Active Enumeration (starts after passive completes or runs in parallel)
Task({
  subagent_type: "general-purpose",
  description: "Active recon for target",
  prompt: `Execute active reconnaissance workflow for ${target}.

  Read and follow: .claude/skills/bug-bounty-methodology/workflows/recon-active.md
  Target context: LEARNING/targets/${target}/${target}.md
  Output findings to: LEARNING/targets/${target}/recon/active-results.md

  Verify subdomains, map application, discover API endpoints.`
})

// Agent 3: JavaScript Analysis
Task({
  subagent_type: "general-purpose",
  description: "JavaScript analysis for target",
  prompt: `Execute JavaScript analysis workflow for ${target}.

  Read and follow: .claude/skills/bug-bounty-methodology/workflows/analyze-javascript.md
  Target context: LEARNING/targets/${target}/${target}.md
  Output findings to: LEARNING/targets/${target}/analysis/js-findings.md

  Extract and analyze all JavaScript bundles for endpoints and secrets.`
})

// Agent 4: Mobile App Analysis (if applicable)
Task({
  subagent_type: "general-purpose",
  description: "Mobile analysis for target",
  prompt: `Execute mobile app analysis workflow for ${target}.

  Read and follow: .claude/skills/bug-bounty-methodology/workflows/analyze-mobile.md
  Target context: LEARNING/targets/${target}/${target}.md
  Output findings to: LEARNING/targets/${target}/analysis/mobile-findings.md

  Analyze iOS and Android apps for endpoints and vulnerabilities.`
})
```

**Wall-clock time:** ~45-75 minutes (vs. 5-7 hours sequential)

## Synthesis and Roadmap Generation

After parallel agents complete:

1. **Read all output files** from target directory
2. **Cross-reference findings** between passive, active, JS, and mobile analysis
3. **Identify technology stack** (GraphQL vs REST, auth mechanisms, frameworks)
4. **Map discovered endpoints** to vulnerability categories
5. **Prioritize testing targets** based on:
   - Program payout ranges (Critical > High > Medium)
   - Likelihood of finding (IDOR in APIs = high likelihood)
   - Complexity vs. ROI (quick wins first)
6. **Generate attack roadmap** with specific testing checklists
7. **Output to:** `LEARNING/targets/{target}/ATTACK-ROADMAP.md`

## Target-Specific Intelligence

Each target has a profile in `targets/{target}.md` containing:

- **Program Details:** URL, platform (HackerOne, Bugcrowd), response times
- **Scope:** In-scope assets, out-of-scope exclusions
- **Testing Requirements:** Required headers (X-Bug-Bounty), account setup
- **Known Technology Stack:** From previous recon or public knowledge
- **Priority Attack Surfaces:** Based on program payouts and policy
- **Testing Accounts:** Credentials for authenticated testing
- **Previous Findings:** What's already been reported (avoid duplicates)

## Tools Integration

Reference `tools/reference.md` for quick command syntax:
- **Subdomain enumeration:** subfinder, amass, assetfinder
- **Verification:** httpx, dnsx, subjack
- **Web fuzzing:** ffuf (see ffuf skill for advanced usage)
- **Crawling:** gospider, Burp Suite
- **Mobile analysis:** apktool, class-dump, Frida
- **Secret scanning:** truffleHog, gitleaks

## Output Structure

All findings documented in vault under `LEARNING/targets/{target}/`:

```
LEARNING/targets/{target}/
├── {target}.md (target intelligence profile)
├── recon/
│   ├── passive-results.md
│   ├── active-results.md
│   └── subdomains.txt
├── analysis/
│   ├── js-findings.md
│   ├── mobile-findings.md
│   └── tech-stack.md
├── testing/
│   ├── graphql-tests.md
│   ├── idor-tests.md
│   └── auth-tests.md
├── findings/
│   └── [vulnerability-reports]/
└── ATTACK-ROADMAP.md (prioritized testing plan)
```

## Context Management

For long reconnaissance sessions:
1. Spawn parallel agents (as described above)
2. Agents work independently and document findings
3. Main agent synthesizes results
4. If synthesis requires heavy context, use `/clear` + read output files approach
5. Never try to hold 5-7 hours of recon in single context window

## Success Metrics

**Reconnaissance complete when:**
- ✅ 50+ subdomains enumerated (if applicable)
- ✅ Complete technology stack documented
- ✅ 100+ API endpoints discovered
- ✅ Attack surface mapped by vulnerability type
- ✅ Top 10 high-value targets identified
- ✅ Prioritized testing roadmap created

**Testing complete when:**
- ✅ All Critical/High priority targets tested
- ✅ At least one valid finding OR comprehensive testing documented
- ✅ Findings properly reported to bug bounty program

## Workflow Files Reference

- `workflows/recon-passive.md` - Passive reconnaissance methodology
- `workflows/recon-active.md` - Active enumeration methodology
- `workflows/analyze-javascript.md` - JavaScript analysis workflow
- `workflows/analyze-mobile.md` - Mobile app analysis workflow
- `workflows/test-graphql.md` - GraphQL vulnerability testing
- `workflows/test-xss.md` - Cross-site scripting testing
- `workflows/test-api.md` - REST API security testing (IDOR, authorization)
- `workflows/test-authentication.md` - Auth/authz bypass testing
- `workflows/test-business-logic.md` - Payment and logic flaw testing
- `workflows/test-file-upload.md` - Upload vulnerability testing
- `workflows/report-findings.md` - Bug bounty report writing

## Usage Examples

**Example 1: Start new target**
```
User: "Start bug bounty recon on DoorDash"

Chavvo loads bug-bounty-methodology skill
→ Reads targets/doordash.md
→ Proposes spawning 4 parallel recon agents
→ User approves
→ Agents execute workflows simultaneously
→ Synthesis generates ATTACK-ROADMAP.md
→ User reviews and chooses next phase
```

**Example 2: Specific testing**
```
User: "Test HubSpot GraphQL endpoint for IDOR"

Chavvo loads bug-bounty-methodology skill
→ Reads targets/hubspot.md
→ Loads workflows/test-graphql.md
→ Reads discovered GraphQL endpoints from recon
→ Guides through IDOR testing checklist
→ Documents findings in testing/graphql-tests.md
```

**Example 3: Resume work**
```
User: "Continue DoorDash testing"

Chavvo loads bug-bounty-methodology skill
→ Reads LEARNING/targets/doordash/ATTACK-ROADMAP.md
→ Reviews latest testing/ files
→ Identifies next priority item
→ Proposes specific testing workflow
```

---

**When invoked, always:**
1. Understand user's intent (new recon, continue testing, specific vuln test)
2. Read appropriate target context
3. Route to correct workflow(s)
4. Propose parallel execution for heavy recon tasks
5. Document everything in target-specific structure
6. Maintain target-agnostic methodology across all targets
