---
name: tpm-report
description: Generate beautiful PDF status reports from tpm-mcp project data. Creates executive-ready project status reports with progress bars, milestones, and blockers. Requires Playwright MCP for PDF generation.
---

# Skill: TPM Report Generation

Generate professional, shareable PDF reports from your tpm-mcp project tracking data.

## Purpose

Transform your roadmap data into polished status reports suitable for:
- Stakeholder updates
- Sprint reviews
- Executive summaries
- Team standups
- External sharing

## Routing Logic

**Generate Report** → `workflows/generate-pdf.md`
- "Generate a project status report"
- "Create a PDF report of the roadmap"
- "I need a status report to share externally"
- ":TPM: generate report"
- "Make a pretty report of our progress"
- "Export roadmap as PDF"

**Customize Report** → `workflows/generate-pdf.md` (with customization)
- "Generate a report for just the backend project"
- "Create a report without the backlog items"
- "Make a report showing only completed work"

## Prerequisites

This skill requires:
1. **tpm-mcp** - The project tracking MCP server (provides `roadmap_view`)
2. **Playwright MCP** - For HTML to PDF conversion (provides `browser_navigate`, PDF generation)

If Playwright is not available, the workflow will generate HTML that can be manually converted.

## Workflows

- `workflows/generate-pdf.md` - Complete workflow for generating PDF reports

## Context

- `context/html-template.md` - The HTML/CSS template structure for reports
- `context/overview.md` - Report design principles and customization options
