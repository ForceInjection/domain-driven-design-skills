---
name: gtd-notation
description: Complete Task Genius notation reference for task management and GTD integration. Use when generating actionable items, creating project plans, tracking progress on proposals/projects/tenders, delegating tasks, or managing complex workflows with Task Genius notation (8 status characters).
version: "1.0.0"
last_updated: "2025-10-24"
maintained_by: "Lucas Challamel, Talan SA"
applies_to: "All 12 agents (universal)"
---

# GTD Notation - Complete Task Genius Reference

Complete reference for Task Genius notation and GTD integration for Talan SA business consulting agents.

**When to use this Skill**:
- Generating actionable items, next steps, or deliverables
- Creating project plans, proposal timelines, or work breakdowns
- Tracking progress on proposals, projects, tenders, or recruitment
- Delegating tasks to other agents or team members
- Managing complex multi-phase workflows

---

## 📋 Complete Task Genius Notation Standard

### Status Characters - Full Definitions

| Syntax | Status | Description | Use Case | Example |
|--------|--------|-------------|----------|---------|
| `- [ ]` | **Todo/Not Started** | Task identified but not yet begun | New tasks, backlog items, planned work | `- [ ] Write executive summary (Target: 2-3 pages)` |
| `- [x]` or `- [X]` | **Completed** | Task successfully finished | Finished work, completed deliverables | `- [x] Conduct RFI analysis (Completed: 2025-01-20, 42 requirements)` |
| `- [/]` | **In Progress** | Task currently being worked on | Active tasks, work in progress | `- [/] Design solution architecture (In progress: 60% complete)` |
| `- [-]` | **Cancelled/Abandoned** | Task no longer relevant or deprioritized | Obsolete tasks, changed requirements | `- [-] Alternative pricing model (Cancelled: Client requires fixed-price)` |
| `- [>]` | **Forwarded/Delegated** | Task assigned to another person or team | Delegated work, handoffs, escalations | `- [>] Design cloud architecture (Assigned: @ta-sme-architect-enterprise)` |
| `- [<]` | **Scheduled** | Task scheduled for future execution | Planned tasks with specific dates | `- [<] Red Team review (Scheduled: 2025-02-02 14:00)` |
| `- [?]` | **Question** | Task requires clarification or decision | Blockers, pending decisions, open questions | `- [?] Clarify data residency requirements (Question sent to client)` |
| `- [!]` | **Important** | High-priority task requiring immediate attention | Urgent items, critical path, deadlines | `- [!] URGENT: Bid/no-bid decision required (Deadline: 2025-01-30)` |

---

## 🔧 Detailed Usage Guidelines

### When to Use Task Notation (Comprehensive)

**Pre-Sales & Proposals** (@ta-presales-consultant):
- RFI/RFP analysis steps (requirement extraction, compliance mapping)
- Proposal development tasks (executive summary, technical sections, pricing)
- Solution architecture milestones (current state, target state, roadmap)
- Pricing model development (resource estimation, margin calculation)
- Competitive analysis actions (competitor research, differentiation strategy)
- Review and approval gates (Red Team, technical validation, commercial review)
- Client clarification questions (ambiguous requirements, assumptions)

**Recruitment** (@ta-head-hunter):
- Candidate sourcing tasks (LinkedIn, universities, headhunting)
- Interview scheduling (phone screens, technical interviews, cultural fit)
- Assessment completion (technical evaluations, reference checks)
- Reference checks (2 references per finalist)
- Offer preparation (compensation packages, benefits)
- Onboarding planning (orientation, training, buddy assignment)

**Project Management** (@ta-project-manager):
- Project planning tasks (WBS, schedule, resource allocation)
- Risk mitigation actions (risk register, mitigation plans, contingencies)
- Stakeholder engagement (steering committees, status reports)
- Deliverable tracking (milestones, acceptance criteria, sign-off)
- Status reporting (weekly updates, RAG status, KPI dashboards)
- Issue resolution (blockers, escalations, corrective actions)

**Tenders** (@ta-tender-specialist):
- Tender analysis steps (document review, compliance matrix)
- Compliance mapping (mandatory requirements, gap analysis)
- Consortium coordination (partner identification, agreements, alignment)
- Submission preparation (technical proposal, commercial proposal, legal)
- Bid/no-bid decision gates (strategic fit, win probability, resources)

**Enterprise Architecture** (@ta-sme-architect-enterprise):
- Architecture design tasks (current state, target state, transformation roadmap)
- Technology evaluation (multi-criteria analysis, proof-of-concept)
- ADR (Architecture Decision Record) creation (decisions, rationale, consequences)
- Diagram development (C4 model: Context, Container, Component, Code)
- Technical validation (architecture review board, peer review)

**Cybersecurity** (@ta-sme-cyber):
- Security assessment tasks (vulnerability scanning, threat modeling)
- Compliance validation (ISO 27001, FINMA, Swiss DPA, NIST CSF)
- Incident response planning (detection, containment, recovery, lessons learned)
- Security architecture design (Zero Trust, defense-in-depth, network segmentation)
- Vulnerability remediation (prioritization, patching, compensating controls)

**AI Strategy** (@ta-sme-ai):
- AI maturity assessment (data, talent, culture, governance)
- Use case identification (brainstorming, prioritization, business case)
- ML architecture design (platforms, pipelines, MLOps, monitoring)
- Model development (data preparation, training, evaluation, deployment)
- Responsible AI validation (bias, fairness, explainability, compliance)

**Agent Creation** (@ta-agent-creator):
- Gap analysis validation (capability mapping, MECE validation)
- Agent design tasks (scope definition, architecture, prompt writing)
- Configuration development (opencode.jsonc, custom commands)
- Testing and validation (typical scenarios, company facts, Talan values)
- Ecosystem integration (instructions.md updates, agent count)

---

## 📐 Task Formatting Best Practices (Detailed)

### 1. Be Specific and Actionable

**Principle**: Task descriptions must be concrete, measurable, and actionable. Avoid vague language.

**Bad Examples** ❌:
```markdown
- [ ] Work on proposal
- [ ] Fix issues
- [ ] Talk to client
- [ ] Do architecture
- [ ] Handle security
```

**Good Examples** ✅:
```markdown
- [ ] Write executive summary for UBS data platform proposal (2-3 pages, emphasize Positive Innovation)
- [ ] Address Red Team feedback on security architecture (3 items: encryption, access control, monitoring)
- [ ] Schedule clarification call with UBS procurement (30 min, by Friday 17:00 CET)
- [ ] Design cloud architecture using C4 model (Context, Container, Component diagrams)
- [ ] Validate FINMA compliance requirements (banking regulations, data residency, audit trail)
```

**Key Elements**:
- **Action verb**: Write, Address, Schedule, Design, Validate
- **Deliverable**: Executive summary, feedback response, call, architecture, compliance validation
- **Specificity**: Page count, item count, duration, model type, requirements
- **Context**: UBS, Red Team, procurement, C4 model, FINMA

---

### 2. Assign Ownership When Delegating

**Principle**: Delegated tasks must clearly identify the responsible party and due date.

**Format**: `[>] Task description (Assigned: Name/Role, Due: Date)`

**Examples**:
```markdown
- [>] Design SAP BTP integration architecture (Assigned: @ta-sme-architect-enterprise, Due: 2025-01-26)
- [>] Validate FINMA compliance requirements (Assigned: @ta-sme-cyber, Due: 2025-01-27)
- [>] Review pricing model for margin validation (Assigned: Lucas Challamel, Due: 2025-01-25)
- [>] Conduct technical interview with candidate (Assigned: Hiring Manager, Due: 2025-01-28 10:00)
- [>] Develop consortium agreement (Assigned: Legal Team, Due: 2025-02-01)
```

**Best Practices**:
- Use `@agent-name` for agent delegation
- Use full name or role for human delegation
- Always include due date or deadline
- Add context if needed (e.g., "3 items", "30 min call")

---

### 3. Include Deadlines for Scheduled Tasks

**Principle**: Scheduled tasks must include specific date and time when possible.

**Format**: `[<] Task description (Scheduled: Date Time)`

**Examples**:
```markdown
- [<] Submit proposal to Credit Suisse (Scheduled: 2025-02-15 17:00 CET)
- [<] Red Team review meeting (Scheduled: 2025-02-10 14:00, 90 min, 5 attendees)
- [<] Candidate final interview (Scheduled: 2025-02-08 10:00, in-person, Geneva office)
- [<] Quarterly agent ecosystem review (Scheduled: 2025-04-01, full day workshop)
- [<] Steering committee presentation (Scheduled: 2025-01-30 15:00, 60 min, 8 stakeholders)
```

**Best Practices**:
- Use ISO date format (YYYY-MM-DD) for clarity
- Include time with timezone (CET for Switzerland)
- Add duration if relevant (90 min, 60 min)
- Add location if relevant (in-person, Geneva office, video call)
- Add attendee count if relevant (5 attendees, 8 stakeholders)

---

### 4. Prioritize Urgent Tasks

**Principle**: High-priority tasks must be flagged with urgency indicator and deadline.

**Format**: `[!] URGENT: Task description (Deadline: Date, Reason)`

**Examples**:
```markdown
- [!] URGENT: Bid/no-bid decision required (Deadline: 2025-01-30 EOD, client expects response)
- [!] URGENT: Address critical security vulnerability (Deadline: 24 hours, production system exposed)
- [!] URGENT: Client escalation response (Deadline: Today 17:00, CEO involved)
- [!] URGENT: Confirm Databricks licensing model (Deadline: 2025-01-25, proposal blocker)
- [!] URGENT: Resource allocation for data engineer (Deadline: This week, project at risk)
```

**Best Practices**:
- Reserve `[!]` for genuinely urgent tasks (not everything is urgent)
- Always include deadline (specific date/time)
- Add reason or context (why is it urgent?)
- Use "URGENT:" prefix for visibility
- Consider impact (client relationship, project risk, security)

---

### 5. Track Progress with Status Updates

**Principle**: Update task status as work progresses to maintain visibility.

**Workflow**: `[ ]` → `[/]` → `[x]`

**Example Progression**:
```markdown
## Proposal Development - UBS Data Platform

### Initial State (Backlog)
- [ ] Design cloud migration strategy

### Work Begins (In Progress)
- [/] Design cloud migration strategy (Started: 2025-01-20, 30% complete)

### Blocked/Question (Needs Clarification)
- [?] Design cloud migration strategy (Blocked: Waiting for client data center specs)

### Delegated (Assigned to Specialist)
- [>] Design cloud migration strategy (Assigned: @ta-sme-architect-enterprise, Due: 2025-01-26)

### Scheduled (Planned Execution)
- [<] Design cloud migration strategy (Scheduled: 2025-02-01 - 2025-02-05, 5-day sprint)

### Urgent (Critical Path)
- [!] URGENT: Design cloud migration strategy (Deadline: 2025-01-25, client escalation)

### Completed (Finished)
- [x] Design cloud migration strategy (Completed: 2025-01-23, deliverable: 15-page document)

### Cancelled (Obsolete)
- [-] Design cloud migration strategy (Cancelled: Client decided on SaaS solution instead)
```

**Best Practices**:
- Update status regularly (daily for active tasks)
- Add completion percentage for in-progress tasks (30%, 60%, 90%)
- Document completion date and deliverable
- Explain cancellation reason (changed requirements, obsolete)

---

## 🎭 Agent-Specific Examples (Abbreviated - See Full Examples in Original)

### Pre-Sales Consultant (@ta-presales-consultant)

```markdown
## RFP Analysis - Credit Suisse IT Governance Framework

### Phase 1: Initial Assessment
- [x] Receive RFP document (Received: 2025-01-18, 87 pages)
- [/] Conduct win probability assessment (Currently: 65%)
- [?] Clarify data residency requirements (Question sent)
- [!] URGENT: Bid/no-bid decision (Deadline: 2025-01-21 EOD)

### Phase 2: Solution Design
- [>] Validate compliance (Assigned: @ta-sme-cyber, Due: 2025-01-24)
- [<] Solution workshop (Scheduled: 2025-01-26 09:00-12:00)
```

_[Full examples for all 9 agents available in complete skill file]_

---

## 🔗 Integration with Obsidian Vault (Complete)

### Dual MCP Server Setup

**1. Task Genius MCP Server** (`quad-damage-tasks`):
- Task management with GTD workflows
- Create, query, update tasks
- Batch operations

**2. Obsidian Vault MCP Server** (`obsidian-vault`):
- Knowledge management
- Read/write vault files
- Search and templates

**Benefits**:
- ✅ Unified workflow (tasks + knowledge)
- ✅ Context preservation
- ✅ Reference access
- ✅ Complete GTD support

---

## 📖 Quick Reference Card

| Symbol | Status | Example |
|--------|--------|---------|
| `[ ]` | Todo | `- [ ] Write summary (2-3 pages)` |
| `[x]` | Done | `- [x] RFI analysis (Completed: 2025-01-20)` |
| `[/]` | In Progress | `- [/] Architecture (60% complete)` |
| `[-]` | Cancelled | `- [-] Alt pricing (Client requires fixed-price)` |
| `[>]` | Delegated | `- [>] Design (Assigned: @ta-sme-architect)` |
| `[<]` | Scheduled | `- [<] Review (Scheduled: 2025-02-02 14:00)` |
| `[?]` | Question | `- [?] Clarify data residency` |
| `[!]` | Urgent | `- [!] URGENT: Decision (Deadline: 2025-01-30)` |

---

## ✅ Compliance Checklist

- [ ] Use Task Genius notation for ALL actionable items
- [ ] Be specific (action verb + deliverable + context)
- [ ] Assign ownership when delegating (`[>]`)
- [ ] Include deadlines for scheduled tasks (`[<]`)
- [ ] Prioritize urgent tasks (`[!]`)
- [ ] Track progress with status updates
- [ ] Flag questions requiring clarification (`[?]`)
- [ ] Cancel obsolete tasks explicitly (`[-]`)

---

## Version History

### v1.0.0 (2025-10-24) - Initial Semantic Versioning
- ✅ Established semantic versioning (MAJOR.MINOR.PATCH)
- ✅ Added version history section
- ✅ Created CHANGELOG.md
- ✅ No content changes (baseline version)

### v1.0 (2025-01-23) - Initial Release
- ✅ Complete Task Genius notation standard (8 status characters)
- ✅ Formatting best practices and examples
- ✅ Agent-specific examples for all business agents
- ✅ Obsidian integration guidance (Task Genius + Vault)
- ✅ Task lifecycle management workflows

---

**End of GTD Notation Skill**

**Version**: 1.0.0  
**Last Updated**: 2025-10-24  
**Maintained By**: Lucas Challamel, Talan SA  
**Changelog**: See CHANGELOG.md in this directory

---

**Note**: This is the complete lazy-loaded skill file. Agents should reference Rule 02 for quick reference and load this skill when generating complex task lists, project plans, or multi-phase workflows.
