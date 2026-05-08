---
name: pipeline
description: Manage the content pipeline and idea backlog. Use when checking pipeline status, evaluating pillar distribution, reviewing idea statuses, or planning content calendar. Includes idea template, pillar definitions, and frontmatter schemas.
---

# Pipeline Skill

Manage the content pipeline from idea to publication.

## When to Use

- Checking overall pipeline status (`/pipeline` command)
- Reviewing idea backlog and priorities
- Ensuring pillar distribution is on target
- Planning which ideas to draft next
- Creating new ideas with proper structure

## Quick Reference

**Idea statuses:** `idea` → `drafting` → `ready_for_projection` → `published` → `archived`

**Pillar targets:**
- Technology Strategy: 30%
- Leadership & Management: 25%
- Execution & Delivery: 20%
- Founder Lessons: 15%
- Market & AI Trends: 10%

## Context Files

- `context/pillars.md` - Content pillar definitions and targets
- `context/frontmatter.md` - Frontmatter schemas for all file types
- `context/workflow.md` - Status flow and weekly rhythm

## Templates

- `templates/idea.md` - Idea file template with full frontmatter

## Commands

This skill powers the `/pipeline` command which shows:
- Ideas by status
- Pillar distribution vs targets
- Stale items needing attention
