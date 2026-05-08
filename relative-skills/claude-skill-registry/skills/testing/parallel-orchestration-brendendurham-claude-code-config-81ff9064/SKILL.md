---
name: parallel-orchestration
description: This skill should be used when the user asks to "run multiple agents", "parallel review", "comprehensive analysis", "full review", "multi-agent workflow", or needs to coordinate multiple specialized agents working simultaneously. Provides patterns for launching agents in parallel and synthesizing results.
---

# Parallel Agent Orchestration

## Overview

This skill provides patterns for orchestrating multiple specialized agents to work in parallel on complex tasks. Use this for comprehensive code reviews, research-and-implement workflows, and multi-project coordination.

## Core Orchestration Patterns

### Pattern 1: Parallel Review (Fan-Out/Fan-In)

Launch multiple review agents simultaneously, then consolidate findings.

**Use for:** Comprehensive code review, pre-PR checks, security audits

**Workflow:**
1. Identify review dimensions needed
2. Launch agents in parallel (use Task tool multiple times in single message)
3. Wait for all agents to complete
4. Synthesize and deduplicate findings
5. Prioritize and present results

**Example:**
```
Launch in parallel:
- security-reviewer: "Review authentication changes for vulnerabilities"
- performance-optimizer: "Analyze database query performance"
- code-reviewer: "Review code quality and conventions"
- silent-failure-hunter: "Check error handling completeness"

Then synthesize findings into prioritized action items.
```

### Pattern 2: Research & Implement (Sequential Phases)

Explore codebase, design architecture, implement, then review.

**Use for:** New feature development, major refactoring

**Workflow:**

Phase 1 - Exploration (parallel):
- code-explorer: "Analyze similar features"
- code-explorer: "Map relevant architecture"
- code-explorer: "Find patterns to follow"

Phase 2 - Design (parallel):
- code-architect: "Design minimal approach"
- code-architect: "Design clean architecture approach"

Phase 3 - Implementation:
- Implement chosen approach

Phase 4 - Review (parallel):
- security-reviewer, performance-optimizer, test-engineer

### Pattern 3: Multi-Project Coordination

Work across multiple projects or repositories simultaneously.

**Use for:** Monorepo changes, cross-project refactoring

**Workflow:**
1. Identify all affected projects
2. Launch exploration agents per project (parallel)
3. Identify cross-cutting concerns
4. Plan coordinated changes
5. Implement with consistency checks

### Pattern 4: Continuous Quality Pipeline

Automated quality gates throughout development.

**Use for:** Maintaining code quality during implementation

**Workflow:**
1. After each significant change, launch self-reviewer
2. On security-sensitive code, auto-trigger security-reviewer
3. Before completion, run orchestrator for full review
4. Record learnings for future sessions

## Agent Selection Guide

| Concern | Agent | When to Use |
|---------|-------|-------------|
| Security | security-reviewer | Auth code, user input, credentials |
| Performance | performance-optimizer | Queries, loops, data processing |
| Testing | test-engineer | New features, bug fixes |
| Documentation | documentation-writer | APIs, complex logic |
| Quality | code-reviewer (plugin) | All code changes |
| Architecture | code-architect (plugin) | Design decisions |
| Exploration | code-explorer (plugin) | Understanding code |
| Error handling | silent-failure-hunter (plugin) | Critical paths |

## Synthesis Best Practices

1. **Deduplicate:** Multiple agents may find same issue
2. **Prioritize:** Critical > High > Medium > Low
3. **Resolve conflicts:** When agents disagree, note both perspectives
4. **Aggregate metrics:** Combine severity ratings
5. **Executive summary:** Provide high-level overview first

## Example Orchestration Prompts

**Comprehensive Review:**
"Launch security-reviewer, performance-optimizer, code-reviewer, and silent-failure-hunter in parallel to review unstaged changes. Synthesize findings prioritized by severity."

**Research & Implement:**
"First launch 3 code-explorer agents to analyze [feature area], then launch 2 code-architect agents to design approaches, present options for my approval, then implement and review."

**Quick Security Check:**
"Launch security-reviewer focused on the authentication module changes."

**Full Pre-PR Review:**
"Use orchestrator to coordinate a comprehensive review before I create the PR."
