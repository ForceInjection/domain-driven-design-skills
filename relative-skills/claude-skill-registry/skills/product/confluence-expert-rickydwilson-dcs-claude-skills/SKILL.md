---

# === CORE IDENTITY ===
name: confluence-expert
title: Confluence Expert Skill Package
description: Atlassian Confluence expert for creating and managing spaces, knowledge bases, documentation, planning, product discovery, page layouts, macros, templates, and all Confluence features. Use for documentation strategy, space architecture, content organization, and collaborative knowledge management.
domain: delivery
subdomain: delivery-tools

# === WEBSITE DISPLAY ===
difficulty: intermediate
time-saved: "TODO: Quantify time savings"
frequency: "TODO: Estimate usage frequency"
use-cases:
  - Primary workflow for Confluence Expert
  - Analysis and recommendations for confluence expert tasks
  - Best practices implementation for confluence expert
  - Integration with related skills and workflows

# === RELATIONSHIPS ===
related-agents: []
related-skills: []
related-commands: []
orchestrated-by: []

# === TECHNICAL ===
dependencies:
  scripts: []
  references: []
  assets: []
compatibility:
  python-version: 3.8+
  platforms: [macos, linux, windows]
tech-stack: [Python 3.8+]

# === EXAMPLES ===
examples:
  -
    title: Example Usage
    input: "TODO: Add example input for confluence-expert"
    output: "TODO: Add expected output"

# === ANALYTICS ===
stats:
  downloads: 0
  stars: 0
  rating: 0.0
  reviews: 0

# === VERSIONING ===
version: v1.0.0
author: Claude Skills Team
contributors: []
created: 2025-10-21
updated: 2025-11-23
license: MIT

# === DISCOVERABILITY ===
tags: [architecture, confluence, delivery, expert, product]
featured: false
verified: true
---


# Atlassian Confluence Expert

## Overview

This skill provides comprehensive Confluence expertise for creating and managing documentation spaces, knowledge bases, team collaboration areas, and strategic documentation architecture. It includes advanced macro usage, template creation, content governance frameworks, and integration patterns with Jira and other Atlassian tools through the Atlassian MCP server.

Target users include documentation specialists, knowledge managers, team leads, project managers, technical writers, and Scrum Masters who need to structure and maintain high-quality documentation in Confluence. This skill is essential for teams implementing documentation strategies, creating self-service knowledge bases, or establishing collaborative workspaces for agile teams.

**Core Value:** Reduce documentation creation time by 50% through templates and macros, improve content findability by 40% through proper space architecture, and increase team documentation adoption by 60% through best practices and governance frameworks.

## Core Capabilities

- **Space Architecture & Design** - Create hierarchical space structures with optimal taxonomy, navigation, permission schemes for teams, projects, and knowledge bases
- **Content Creation & Templates** - Build reusable page templates with macros, structured layouts, and dynamic content for consistent documentation across teams
- **Macro Mastery** - Leverage advanced Confluence macros (Jira charts, task lists, status indicators, content includes, dynamic queries) for rich, interactive documentation
- **Documentation Governance** - Implement content lifecycle management, review cycles, archiving strategies, and quality standards for sustainable documentation ecosystems
- **Atlassian MCP Integration** - Direct Confluence operations via MCP server for automated page creation, space management, content synchronization, and Jira integration

## Quick Start

### Common Confluence Operations

This skill provides Confluence expertise through knowledge frameworks, templates, and macros. Actual Confluence operations are performed through the Atlassian MCP server configured in Claude Code settings.

### Access Documentation Resources

- **Macro reference:** See Essential Macros section for commonly used Confluence macros with examples
- **Template library:** See Templates Library section for ready-to-use page templates (meeting notes, project overviews, decision logs, retrospectives)
- **Best practices:** See Best Practices section for writing style, organization, maintenance, and content governance standards
- **Space architecture:** See Page Architecture section for recommended space structures and hierarchies

### Key Workflows to Start With

1. **Create Team Documentation Space** - Set up a complete team space with structure and templates (45 minutes)
2. **Set Up Sprint Ceremony Documentation** - Implement sprint planning, standup, review, and retrospective templates (1 hour)
3. **Create Executive Reporting Page** - Build live dashboard with Jira integration for stakeholder visibility (1.5 hours)

## Key Workflows

### 1. Create Team Documentation Space

**Time:** 45 minutes

**Steps:**
1. **Determine space type and structure** - Identify if this is a Team, Project, or Knowledge Base space based on documentation goals
   - Team spaces: Ongoing team operations and meetings
   - Project spaces: Single-project centered docs
   - Knowledge Base: Cross-team reference materials
2. **Create space with naming convention** - Create space in Confluence using clear, consistent naming (e.g., "TEAM-Engineering" or "PROJ-ProductLaunch")
   - Set description, category, and initial permissions
   - Enable space shortcuts for key pages
3. **Set up initial page structure** - Create space homepage and primary navigation pages
   ```
   Space Home (Overview & Getting Started)
   ├── Team Information (Members, Roles, Communication)
   ├── Processes & Workflows (How we work)
   ├── Meeting Notes (Archive of ceremonies)
   └── Resources & References (External links)
   ```
4. **Configure space permissions** - Set View, Edit, Create, Delete, and Admin access for appropriate groups
5. **Create templates for consistency** - Add space templates for recurring page types (meeting notes, project overviews, retrospectives)

**Expected Output:** A fully operational team documentation space with clear structure, functional templates, and appropriate access controls ready for team population.

See [Page Architecture](#page-architecture) section for detailed space structure patterns and best practices.

### 2. Set Up Sprint Ceremony Documentation

**Time:** 1 hour

**Steps:**
1. **Create Sprint Planning template** - Use template pattern from Templates Library section with agenda, attendees, and decisions
   - Include acceptance criteria review section
   - Add story point estimation placeholder
   - Link to sprint backlog in Jira
2. **Create Daily Standup capture page** - Simple daily page for status tracking
   - Format: What we completed | What's next | Blockers
   - Use task list macro to track impediments
   - Link to sprint board
3. **Create Sprint Retrospective template** - What went well, what didn't, action items
   - Use info/warning macros for positive/negative callouts
   - Link to previous retrospectives for trend analysis
   - Assign owners to improvement actions
4. **Create Sprint Review template** - Stakeholder-facing ceremony documentation
   - Demo checklist for completed stories
   - Feedback capture section
   - Decisions and next steps
5. **Link all templates to Jira sprint** - Connect Confluence pages to Jira sprint epic using Jira embed macros

**Expected Output:** Complete sprint ceremony documentation system with linked templates, ready for team to use in upcoming sprint cycle. Ceremonies will have consistent structure and documented artifacts.

See [Confluence MCP Integration](#atlassian-mcp-integration) for linking pages to Jira issues.

### 3. Create Executive Reporting Page

**Time:** 1.5 hours

**Steps:**
1. **Design report layout** - Create page structure for executive visibility
   - Executive summary at top (status, key metrics, risks)
   - Detailed sections for each project/team
   - Timeline and upcoming milestones
2. **Add project status panels** - Create one panel per active project using Panel macro
   ```
   {panel:title=Project Name|borderColor=#0052CC}
   Status: {status:colour=Green|title=On Track}
   Owner: @pm-name
   Key Metrics: Velocity trend, delivery rate
   {panel}
   ```
3. **Embed Jira reports** - Use Jira Chart and Filter Results macros
   - Sprint velocity chart
   - Issue breakdown by status
   - Overdue items query
4. **Document key risks and decisions** - Create risk register and decision log sections
   - Link to detailed risk register page
   - Recent important decisions with rationale
5. **Set up automated content updates** - Configure "Recently Updated" and "Content by Label" macros to pull relevant data

**Expected Output:** Live executive dashboard page in Confluence that provides stakeholder visibility into project health, metrics, and decisions. Dashboard updates automatically as team creates content and updates Jira.

### 4. Implement Documentation Governance Process

**Time:** 2 hours (setup) + ongoing maintenance

**Steps:**
1. **Define documentation standards** - Create style guide and quality checklist
   - Writing style: active voice, scannable content
   - Naming conventions for pages and spaces
   - Metadata requirements (owner, last updated, review date)
   - See Content Quality Checklist in Best Practices section
2. **Create content review schedule** - Establish review cycles by content type
   - Critical docs: Monthly review
   - Standard docs: Quarterly review
   - Archive docs: Annual retention review
3. **Set up labeling system** - Create labels for organization and filtering
   - Status labels: outdated, reviewed, needs-update
   - Team labels: backend, frontend, product
   - Type labels: how-to, reference, decision, meeting-notes
4. **Create archiving workflow** - Move outdated content to Archive space with date labels
   - Maintain archive for 2 years
   - Link archived docs to replacements
   - Keep audit trail of changes
5. **Schedule quarterly documentation audit** - Review orphaned pages, broken links, content gaps
   - Use Confluence analytics to find unused pages
   - Identify pages without owners
   - Consolidate duplicate content

**Expected Output:** Established documentation governance system with clear standards, review schedule, and archiving process. Team has framework for maintaining documentation quality over time.

See Content Governance section for archiving strategy and quality checklist.

## Python Tools

This skill does not include Python automation tools. Confluence operations are performed directly through the Atlassian MCP server, which provides native integration for:

- Creating and managing spaces
- Creating, updating, and deleting pages
- Applying templates and macros
- Managing page hierarchies
- Configuring permissions
- Searching content
- Extracting documentation for analysis

See the Atlassian MCP Integration section below for detailed integration patterns and capabilities.

## Reference Documentation

The following sections provide comprehensive frameworks, templates, and best practices for Confluence expertise:

## Core Competencies

**Space Architecture**
- Design and create space hierarchies
- Organize knowledge by teams, projects, or topics
- Implement documentation taxonomies
- Configure space permissions and visibility

**Content Creation**
- Create structured pages with layouts
- Use macros for dynamic content
- Build templates for consistency
- Implement version control and change tracking

**Collaboration & Governance**
- Facilitate team documentation practices
- Implement review and approval workflows
- Manage content lifecycle
- Establish documentation standards

**Integration & Automation**
- Link Confluence with Jira
- Embed dynamic Jira reports
- Configure page watchers and notifications
- Set up content automation

## Workflows

### Space Creation
1. Determine space type (Team, Project, Knowledge Base, Personal)
2. Create space with clear name and description
3. Set space homepage with overview
4. Configure space permissions:
   - View, Edit, Create, Delete
   - Admin privileges
5. Create initial page tree structure
6. Add space shortcuts for navigation
7. **HANDOFF TO**: Teams for content population

### Page Architecture
**Best Practices**:
- Use page hierarchy (parent-child relationships)
- Maximum 3 levels deep for navigation
- Consistent naming conventions
- Date-stamp meeting notes

**Recommended Structure**:
```
Space Home
├── Overview & Getting Started
├── Team Information
│   ├── Team Members & Roles
│   ├── Communication Channels
│   └── Working Agreements
├── Projects
│   ├── Project A
│   │   ├── Overview
│   │   ├── Requirements
│   │   └── Meeting Notes
│   └── Project B
├── Processes & Workflows
├── Meeting Notes (Archive)
└── Resources & References
```

### Template Creation
1. Identify repeatable content pattern
2. Create page with structure and placeholders
3. Add instructions in placeholders
4. Format with appropriate macros
5. Save as template
6. Share with space or make global
7. **USE**: References for advanced template patterns

### Documentation Strategy
1. **Assess** current documentation state
2. **Define** documentation goals and audience
3. **Organize** content taxonomy and structure
4. **Create** templates and guidelines
5. **Migrate** existing documentation
6. **Train** teams on best practices
7. **Monitor** usage and adoption
8. **REPORT TO**: Senior PM on documentation health

### Knowledge Base Management
**Article Types**:
- How-to guides
- Troubleshooting docs
- FAQs
- Reference documentation
- Process documentation

**Quality Standards**:
- Clear title and description
- Structured with headings
- Updated date visible
- Owner identified
- Reviewed quarterly

## Essential Macros

### Content Macros
**Info, Note, Warning, Tip**:
```
{info}
Important information here
{info}
```

**Expand**:
```
{expand:title=Click to expand}
Hidden content here
{expand}
```

**Table of Contents**:
```
{toc:maxLevel=3}
```

**Excerpt & Excerpt Include**:
```
{excerpt}
Reusable content
{excerpt}

{excerpt-include:Page Name}
```

### Dynamic Content
**Jira Issues**:
```
{jira:JQL=project = PROJ AND status = "In Progress"}
```

**Jira Chart**:
```
{jirachart:type=pie|jql=project = PROJ|statType=statuses}
```

**Recently Updated**:
```
{recently-updated:spaces=@all|max=10}
```

**Content by Label**:
```
{contentbylabel:label=meeting-notes|maxResults=20}
```

### Collaboration Macros
**Status**:
```
{status:colour=Green|title=Approved}
```

**Task List**:
```
{tasks}
- [ ] Task 1
- [x] Task 2 completed
{tasks}
```

**User Mention**:
```
@username
```

**Date**:
```
{date:format=dd MMM yyyy}
```

## Page Layouts & Formatting

**Two-Column Layout**:
```
{section}
{column:width=50%}
Left content
{column}
{column:width=50%}
Right content
{column}
{section}
```

**Panel**:
```
{panel:title=Panel Title|borderColor=#ccc}
Panel content
{panel}
```

**Code Block**:
```
{code:javascript}
const example = "code here";
{code}
```

## Templates Library

### Meeting Notes Template
```
**Date**: {date}
**Attendees**: @user1, @user2
**Facilitator**: @facilitator

## Agenda
1. Topic 1
2. Topic 2

## Discussion
- Key point 1
- Key point 2

## Decisions
{info}Decision 1{info}

## Action Items
{tasks}
- [ ] Action item 1 (@owner, due date)
- [ ] Action item 2 (@owner, due date)
{tasks}

## Next Steps
- Next meeting date
```

### Project Overview Template
```
{panel:title=Project Quick Facts}
**Status**: {status:colour=Green|title=Active}
**Owner**: @owner
**Start Date**: DD/MM/YYYY
**End Date**: DD/MM/YYYY
**Budget**: $XXX,XXX
{panel}

## Executive Summary
Brief project description

## Objectives
1. Objective 1
2. Objective 2

## Key Stakeholders
| Name | Role | Responsibility |
|------|------|----------------|
| @user | PM | Overall delivery |

## Milestones
{jira:project=PROJ AND type=Epic}

## Risks & Issues
| Risk | Impact | Mitigation |
|------|--------|-----------|
| Risk 1 | High | Action plan |

## Resources
- [Design Docs](#)
- [Technical Specs](#)
```

### Decision Log Template
```
**Decision ID**: PROJ-DEC-001
**Date**: {date}
**Status**: {status:colour=Green|title=Approved}
**Decision Maker**: @decisionmaker

## Context
Background and problem statement

## Options Considered
1. Option A
   - Pros:
   - Cons:
2. Option B
   - Pros:
   - Cons:

## Decision
Chosen option and rationale

## Consequences
Expected outcomes and impacts

## Next Steps
- [ ] Action 1
- [ ] Action 2
```

### Sprint Retrospective Template
```
**Sprint**: Sprint XX
**Date**: {date}
**Team**: Team Name

## What Went Well
{info}
- Positive item 1
- Positive item 2
{info}

## What Didn't Go Well
{warning}
- Challenge 1
- Challenge 2
{warning}

## Action Items
{tasks}
- [ ] Improvement 1 (@owner)
- [ ] Improvement 2 (@owner)
{tasks}

## Metrics
**Velocity**: XX points
**Completed Stories**: X/X
**Bugs Found**: X
```

## Space Permissions

### Permission Levels
- **View**: Read-only access
- **Edit**: Modify existing pages
- **Create**: Add new pages
- **Delete**: Remove pages
- **Admin**: Full space control

### Permission Schemes
**Public Space**:
- All users: View
- Team members: Edit, Create
- Space admins: Admin

**Team Space**:
- Team members: View, Edit, Create
- Team leads: Admin
- Others: No access

**Project Space**:
- Stakeholders: View
- Project team: Edit, Create
- PM: Admin

## Content Governance

**Review Cycles**:
- Critical docs: Monthly
- Standard docs: Quarterly
- Archive docs: Annually

**Archiving Strategy**:
- Move outdated content to Archive space
- Label with "archived" and date
- Maintain for 2 years, then delete
- Keep audit trail

**Content Quality Checklist**:
- [ ] Clear, descriptive title
- [ ] Owner/author identified
- [ ] Last updated date visible
- [ ] Appropriate labels applied
- [ ] Links functional
- [ ] Formatting consistent
- [ ] No sensitive data exposed

## Decision Framework

**When to Escalate to Atlassian Admin**:
- Need org-wide template
- Require cross-space permissions
- Blueprint configuration
- Global automation rules
- Space export/import

**When to Collaborate with Jira Expert**:
- Embed Jira queries and charts
- Link pages to Jira issues
- Create Jira-based reports
- Sync documentation with tickets

**When to Support Scrum Master**:
- Sprint documentation templates
- Retrospective pages
- Team working agreements
- Process documentation

**When to Support Senior PM**:
- Executive report pages
- Portfolio documentation
- Stakeholder communication
- Strategic planning docs

## Handoff Protocols

**FROM Senior PM**:
- Documentation requirements
- Space structure needs
- Template requirements
- Knowledge management strategy

**TO Senior PM**:
- Documentation coverage reports
- Content usage analytics
- Knowledge gaps identified
- Template adoption metrics

**FROM Scrum Master**:
- Sprint ceremony templates
- Team documentation needs
- Meeting notes structure
- Retrospective format

**TO Scrum Master**:
- Configured templates
- Space for team docs
- Training on best practices
- Documentation guidelines

**WITH Jira Expert**:
- Jira-Confluence linking
- Embedded Jira reports
- Issue-to-page connections
- Cross-tool workflow

## Best Practices

**Writing Style**:
- Use active voice
- Write scannable content (headings, bullets, short paragraphs)
- Include visuals and diagrams
- Provide examples
- Keep language simple and clear

**Organization**:
- Consistent naming conventions
- Meaningful labels
- Logical page hierarchy
- Related pages linked
- Clear navigation

**Maintenance**:
- Regular content audits
- Remove duplication
- Update outdated information
- Archive obsolete content
- Monitor page analytics

## Analytics & Metrics

**Usage Metrics**:
- Page views per space
- Most visited pages
- Search queries
- Contributor activity
- Orphaned pages

**Health Indicators**:
- Pages without recent updates
- Pages without owners
- Duplicate content
- Broken links
- Empty spaces

## Atlassian MCP Integration

**Primary Tool**: Confluence MCP Server

**Key Operations**:
- Create and manage spaces
- Create, update, and delete pages
- Apply templates and macros
- Manage page hierarchies
- Configure permissions
- Search content
- Extract documentation for analysis

**Integration Points**:
- Create documentation for Senior PM projects
- Support Scrum Master with ceremony templates
- Link to Jira issues for Jira Expert
- Provide templates for Template Creator
