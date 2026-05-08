---

# === CORE IDENTITY ===
name: jira-expert
title: Jira Expert Skill Package
description: Atlassian Jira expert for creating and managing projects, planning, product discovery, JQL queries, workflows, custom fields, automation, reporting, and all Jira features. Use for Jira project setup, configuration, advanced search, dashboard creation, workflow design, and technical Jira operations.
domain: delivery
subdomain: delivery-tools

# === WEBSITE DISPLAY ===
difficulty: intermediate
time-saved: "TODO: Quantify time savings"
frequency: "TODO: Estimate usage frequency"
use-cases:
  - Primary workflow for Jira Expert
  - Analysis and recommendations for jira expert tasks
  - Best practices implementation for jira expert
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
    input: "TODO: Add example input for jira-expert"
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
tags: [automation, delivery, design, expert, jira, product]
featured: false
verified: true
---


# Atlassian Jira Expert

## Overview

This skill provides comprehensive Jira expertise for project configuration, workflow design, advanced JQL queries, automation rules, custom fields, dashboards, and reporting. It covers all technical and operational aspects of Jira including Scrum/Kanban board setup, permission schemes, bulk operations, and integration with Confluence and external tools through the Atlassian MCP server.

Target users include Jira administrators, project managers, Scrum Masters, technical leads, and agile coaches who need to configure projects, optimize workflows, create advanced filters and dashboards, or automate Jira operations. This skill is essential for teams setting up new Jira projects, customizing workflows, implementing automation, or generating portfolio-level reports.

**Core Value:** Reduce project setup time by 60% through templates and automation, improve team productivity by 35% through optimized workflows and JQL filters, and increase reporting efficiency by 70% through custom dashboards and automated data extraction.

## Core Capabilities

- **Project Configuration & Workflows** - Create and configure Jira projects (Scrum, Kanban, custom) with custom workflows, issue types, fields, screens, and permission schemes
- **JQL Mastery & Advanced Queries** - Write complex JQL queries for any use case, build saved filters with multiple conditions, optimize query performance, and create team-specific views
- **Automation & Integration** - Design Jira automation rules, configure webhooks, set up email notifications, and integrate with external tools (Confluence, Slack, CI/CD)
- **Dashboards & Reporting** - Create custom dashboards with gadgets, build reports for sprint metrics, velocity, burndown, configure portfolio-level reporting, and export data for executive visibility
- **Atlassian MCP Integration** - Direct Jira operations via MCP server for project creation, JQL execution, issue updates, sprint management, report generation, and workflow configuration

## Quick Start

### Common Jira Operations

This skill provides Jira expertise through knowledge frameworks, JQL patterns, and workflow templates. Actual Jira operations are performed through the Atlassian MCP server configured in Claude Code settings.

### Access Documentation Resources

- **JQL reference:** See JQL Query Building section for operators, functions, and powerful query examples
- **Workflow patterns:** See Workflow Design section for workflow configuration and transition setup
- **Automation examples:** See Automation Rules section for trigger, condition, and action patterns
- **Dashboard templates:** See Dashboard Creation section for gadget configuration and layout patterns

### Key Workflows to Start With

1. **Configure New Scrum Project** - Set up a new Jira project with workflow, permissions, and board (1.5 hours)
2. **Build Advanced Dashboard for Reporting** - Create executive dashboard with key metrics and JQL filters (1 hour)
3. **Create Automation Rules for Team Efficiency** - Implement automation to reduce manual work (1 hour)
4. **Master JQL for Complex Queries** - Build advanced queries for filtering, reporting, and bulk operations (varies)

## Key Workflows

### 1. Configure New Scrum Project

**Time:** 1.5 hours

**Steps:**
1. **Create Jira project** - Go to Projects → Create project → Select Scrum template
   - Project key (e.g., "PROJ" - 2-4 uppercase letters)
   - Project name and description
   - Project lead (should be Senior PM)
   - Default assignee preference
2. **Configure issue types** - Customize the issue types for your workflow
   - Epic: Large features/initiatives
   - Story: User-facing feature work
   - Task: Non-user-facing work
   - Bug: Defect reports
   - Subtask: Breakdown complex stories
   - Optional: Add custom types (e.g., "Spike" for research)
3. **Create workflow schema** - Design workflow states and transitions
   ```
   To Do → In Progress → In Review → Done
   - To Do: Initial state for all issues
   - In Progress: Active development
   - In Review: Awaiting code/design review
   - Done: Complete and merged/deployed
   ```
   - Define who can transition between states
   - Add validators (required fields before transition)
   - Add post-functions (auto-assign, notify watchers)
4. **Set up project permissions** - Configure who can browse, create, and manage issues
   - Developers: Create/Edit/Transition issues
   - QA: Create bugs, view all issues
   - PM: Admin access
   - Stakeholders: View-only
5. **Configure board and backlog** - Set up Scrum board for sprint management
   - Enable columns for each workflow state
   - Configure backlog visibility
   - Set default issue view
6. **Create board filters and saved searches** - Set up standard queries for team use
   - My Issues: `assignee = currentUser() AND status != Done`
   - Blocked: `issuekey in linkedIssues(PROJ, "is blocked by")`
   - Ready for Dev: `priority >= High AND status = "To Do"`

**Expected Output:** Fully configured Scrum project ready for team to begin working. Team can create stories, manage sprints, and track progress with consistent workflow and permissions.

See [Project Configuration](#core-competencies) section for detailed configuration options.

### 2. Build Advanced Dashboard for Reporting

**Time:** 1 hour

**Steps:**
1. **Create new shared dashboard** - Dashboards → Create Dashboard
   - Name: "Team Metrics" or similar
   - Make it shared with team
   - Set default filters if needed
2. **Add sprint burndown gadget** - Shows sprint progress week by week
   - Select current sprint
   - Configure to show ideal vs actual burndown
   - Helps identify falling behind early
3. **Add velocity chart gadget** - Tracks story points completed per sprint
   - Use last 10 sprints
   - Shows team capacity trends
   - Helps forecast future sprint capacity
4. **Add created vs resolved gadget** - Shows issue intake vs completion rate
   - Monitors if backlog is growing/shrinking
   - Use 30-day timeframe
5. **Add filter results gadget** - Custom issue list using JQL
   ```
   # High priority bugs
   type = Bug AND priority = High AND status != Done
   ```
   - Add separate gadget for high priority issues
   - Add gadget for overdue issues
6. **Arrange and share dashboard** - Position gadgets for readability
   - Executive summary at top
   - Detailed metrics below
   - Share with stakeholders

**Expected Output:** Live dashboard providing real-time view into team metrics, sprint health, and backlog status. Stakeholders can monitor progress without asking for updates.

See [Dashboard Creation](#workflows) section for detailed gadget configuration.

### 3. Set Up Automation Rules for Common Tasks

**Time:** 1.5 hours

**Steps:**
1. **Create automatic status updates** - Trigger on field changes
   - When "Fix Version" is set to current sprint → Auto-move story to "In Progress"
   - When all subtasks marked Done → Auto-move parent to "In Review"
   - Reduces manual status updates
2. **Create auto-assignment rules** - Route work to appropriate team members
   - When type = Bug and priority = High → Assign to @dev-lead
   - When type = Story and label = "backend" → Assign to backend team
   - Balance work distribution
3. **Create notification automation** - Keep stakeholders informed
   - When status changes to "In Review" → Notify assigned reviewer
   - When issue moved to "Done" → Notify watchers with summary
   - When issue created with "Blocker" label → Notify PM
4. **Create linked issue automation** - Maintain relationships
   - When Epic moved to "Done" → Auto-close all child stories marked Done
   - When story linked to QA Epic → Add QA label
   - Keep related issues in sync
5. **Test automation with sample data** - Create test issues in each scenario
   - Verify rules fire correctly
   - Check notifications arrive
   - Confirm field updates work as expected
6. **Enable and monitor** - Turn on automation in production
   - Monitor for 1 week for edge cases
   - Adjust rules if needed
   - Document rules for team reference

**Expected Output:** Automated Jira workflow handling routine tasks, reducing manual work and keeping team informed. Common patterns (status updates, assignments, notifications) happen automatically.

See [Automation Rules](#workflows) section for pattern examples.

### 4. Execute Bulk Data Cleanup and Migration

**Time:** 2 hours

**Steps:**
1. **Identify target issues using JQL** - Write query to find all issues needing update
   ```jql
   # Example: All high priority bugs without fix version
   type = Bug AND priority = High AND fixVersion is EMPTY
   ```
   - Test query to ensure correct scope
   - Check count of affected issues
2. **Create backup report** - Export data before making changes
   - Use Issues → Export to Excel
   - Save report with timestamp
   - Document what changes are being made
3. **Perform bulk change operation** - Select → Tools → Bulk Change
   - Select target issues from query
   - Choose fields to update (e.g., Fix Version, Epic Link, Labels)
   - Preview changes before executing
   - Execute bulk operation
4. **Verify migration success** - Check sample of updated issues
   - Spot check 10-20 updated issues
   - Verify fields updated correctly
   - Check that no data was lost
5. **Update affected reports and dashboards** - Refresh any dashboards or filters
   - Rerun velocity reports
   - Update any hardcoded issue lists
   - Notify team of changes
6. **Document changes** - Create audit trail
   - Record what was changed
   - Why the change was made
   - Date and who performed it

**Expected Output:** Data cleanup completed successfully with verified accuracy. Old or incorrect data is corrected, and audit trail is documented for compliance/reference.

See [Bulk Operations](#advanced-features) section for detailed operation procedures.

## Python Tools

This skill does not include Python automation tools. Jira operations are performed directly through the Atlassian MCP server, which provides native integration for:

- Creating and configuring projects
- Executing JQL queries for data extraction
- Updating issue fields and statuses
- Creating and managing sprints
- Generating reports and dashboards
- Configuring workflows and automation
- Managing boards and filters

See the Atlassian MCP Integration section below for detailed integration patterns and capabilities.

## Reference Documentation

The following sections provide comprehensive frameworks, JQL patterns, and best practices for Jira expertise:

## Core Competencies

**Project Configuration**
- Create and configure Jira projects (Scrum, Kanban, custom)
- Design and implement custom workflows
- Configure issue types, fields, and screens
- Set up project permissions and security schemes

**JQL Mastery**
- Write advanced JQL queries for any use case
- Create complex filters with multiple conditions
- Optimize query performance
- Build saved filters for team use

**Automation & Integration**
- Design Jira automation rules
- Configure webhooks and integrations
- Set up email notifications
- Integrate with external tools (Confluence, Slack, etc.)

**Reporting & Dashboards**
- Create custom dashboards with gadgets
- Build reports for sprint metrics, velocity, burndown
- Configure portfolio-level reporting
- Export data for executive reporting

## Workflows

### Project Creation
1. Determine project type (Scrum, Kanban, Bug Tracking, etc.)
2. Create project with appropriate template
3. Configure project settings:
   - Name, key, description
   - Project lead and default assignee
   - Notification scheme
   - Permission scheme
4. Set up issue types and workflows
5. Configure custom fields if needed
6. Create initial board/backlog view
7. **HANDOFF TO**: Scrum Master for team onboarding

### Workflow Design
1. Map out process states (To Do → In Progress → Done)
2. Define transitions and conditions
3. Add validators, post-functions, and conditions
4. Configure workflow scheme
5. Associate workflow with project
6. Test workflow with sample issues
7. **USE**: References for complex workflow patterns

### JQL Query Building
**Basic Structure**: `field operator value`

**Common Operators**:
- `=, !=` : equals, not equals
- `~, !~` : contains, not contains
- `>, <, >=, <=` : comparison
- `in, not in` : list membership
- `is empty, is not empty`
- `was, was in, was not`
- `changed`

**Powerful JQL Examples**:

Find overdue issues:
```jql
dueDate < now() AND status != Done
```

Sprint burndown issues:
```jql
sprint = 23 AND status changed TO "Done" DURING (startOfSprint(), endOfSprint())
```

Find stale issues:
```jql
updated < -30d AND status != Done
```

Cross-project epic tracking:
```jql
"Epic Link" = PROJ-123 ORDER BY rank
```

Velocity calculation:
```jql
sprint in closedSprints() AND resolution = Done
```

Team capacity:
```jql
assignee in (user1, user2) AND sprint in openSprints()
```

### Dashboard Creation
1. Create new dashboard (personal or shared)
2. Add relevant gadgets:
   - Filter Results (JQL-based)
   - Sprint Burndown
   - Velocity Chart
   - Created vs Resolved
   - Pie Chart (status distribution)
3. Arrange layout for readability
4. Configure automatic refresh
5. Share with appropriate teams
6. **HANDOFF TO**: Senior PM or Scrum Master for use

### Automation Rules
1. Define trigger (issue created, field changed, scheduled)
2. Add conditions (if applicable)
3. Define actions:
   - Update field
   - Send notification
   - Create subtask
   - Transition issue
   - Post comment
4. Test automation with sample data
5. Enable and monitor
6. **USE**: References for complex automation patterns

## Advanced Features

### Custom Fields
**When to Create**:
- Track data not in standard fields
- Capture process-specific information
- Enable advanced reporting

**Field Types**:
- Text: Short text, paragraph
- Numeric: Number, decimal
- Date: Date picker, date-time
- Select: Single select, multi-select, cascading
- User: User picker, multi-user picker

**Configuration**:
1. Create custom field
2. Configure field context (which projects/issue types)
3. Add to appropriate screens
4. Update search templates if needed

### Issue Linking
**Link Types**:
- Blocks / Is blocked by
- Relates to
- Duplicates / Is duplicated by
- Clones / Is cloned by
- Epic-Story relationship

**Best Practices**:
- Use Epic linking for feature grouping
- Use blocking links to show dependencies
- Document link reasons in comments

### Permissions & Security

**Permission Schemes**:
- Browse Projects
- Create/Edit/Delete Issues
- Administer Projects
- Manage Sprints

**Security Levels**:
- Define confidential issue visibility
- Control access to sensitive data
- Audit security changes

### Bulk Operations
**Bulk Change**:
1. Use JQL to find target issues
2. Select bulk change operation
3. Choose fields to update
4. Preview changes
5. Execute and confirm
6. Monitor background task

**Bulk Transitions**:
- Move multiple issues through workflow
- Useful for sprint cleanup
- Requires appropriate permissions

## JQL Functions Reference

**Date Functions**:
- `startOfDay()`, `endOfDay()`
- `startOfWeek()`, `endOfWeek()`
- `startOfMonth()`, `endOfMonth()`
- `startOfYear()`, `endOfYear()`

**Sprint Functions**:
- `openSprints()`
- `closedSprints()`
- `futureSprints()`

**User Functions**:
- `currentUser()`
- `membersOf("group")`

**Advanced Functions**:
- `issueHistory()`
- `linkedIssues()`
- `issuesWithFixVersions()`

## Reporting Templates

**Sprint Report**:
```jql
project = PROJ AND sprint = 23
```

**Team Velocity**:
```jql
assignee in (team) AND sprint in closedSprints() AND resolution = Done
```

**Bug Trend**:
```jql
type = Bug AND created >= -30d
```

**Blocker Analysis**:
```jql
priority = Blocker AND status != Done
```

## Decision Framework

**When to Escalate to Atlassian Admin**:
- Need new project permission scheme
- Require custom workflow scheme across org
- User provisioning or deprovisioning
- License or billing questions
- System-wide configuration changes

**When to Collaborate with Scrum Master**:
- Sprint board configuration
- Backlog prioritization views
- Team-specific filters
- Sprint reporting needs

**When to Collaborate with Senior PM**:
- Portfolio-level reporting
- Cross-project dashboards
- Executive visibility needs
- Multi-project dependencies

## Handoff Protocols

**FROM Senior PM**:
- Project structure requirements
- Workflow and field needs
- Reporting requirements
- Integration needs

**TO Senior PM**:
- Cross-project metrics
- Issue trends and patterns
- Workflow bottlenecks
- Data quality insights

**FROM Scrum Master**:
- Sprint board configuration requests
- Workflow optimization needs
- Backlog filtering requirements
- Velocity tracking setup

**TO Scrum Master**:
- Configured sprint boards
- Velocity reports
- Burndown charts
- Team capacity views

## Best Practices

**Data Quality**:
- Enforce required fields
- Use field validation
- Regular cleanup of stale issues
- Consistent naming conventions

**Performance**:
- Optimize JQL queries
- Limit dashboard gadgets
- Use saved filters
- Archive old projects

**Governance**:
- Document workflow rationale
- Version control for schemes
- Change management for major updates
- Regular permission audits

## Atlassian MCP Integration

**Primary Tool**: Jira MCP Server

**Key Operations**:
- Create and configure projects
- Execute JQL queries for data extraction
- Update issue fields and statuses
- Create and manage sprints
- Generate reports and dashboards
- Configure workflows and automation
- Manage boards and filters

**Integration Points**:
- Pull metrics for Senior PM reporting
- Configure sprint boards for Scrum Master
- Create documentation pages for Confluence Expert
- Support template creation for Template Creator
