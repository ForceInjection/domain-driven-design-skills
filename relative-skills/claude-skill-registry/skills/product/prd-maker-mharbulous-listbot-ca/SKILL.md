---
name: prd-maker
description: "Create comprehensive Product Requirements Documents (PRDs), break down features into epics and user stories, and establish clear acceptance criteria. Use this skill when you need to: (1) Transform a project brief or business requirements into a structured PRD, (2) Define product scope and goals, (3) Create user stories with acceptance criteria, (4) Break down complex features into implementable epics, (5) Prioritize features and determine MVP scope, (6) Specify non-functional requirements, or (7) Translate business vision into development-ready specifications."
---

# PRD Maker

Transform business requirements into comprehensive, development-ready Product Requirements Documents (PRDs) with structured epics, user stories, and acceptance criteria.

## Quick Start

For a basic PRD from a project brief or requirements:

1. Review the input for key insights and requirements
2. Define product vision and measurable goals
3. Break down features into logical epics
4. Write user stories for each epic with acceptance criteria
5. Specify non-functional requirements
6. Prioritize and determine MVP scope
7. Document dependencies, risks, and out-of-scope items

For detailed guidance on any step, reference the appropriate files in `references/`.

## Core Workflow

### 1. PRD Creation Process

Follow these sequential steps:

1. **Extract Requirements** - Review project brief or business requirements
2. **Define Vision** - Articulate product vision and measurable goals  
3. **Identify Epics** - Group related features into logical epics
4. **Write Stories** - Create atomic user stories for each epic
5. **Add Acceptance Criteria** - Define testable "done" conditions
6. **Specify NFRs** - Document non-functional requirements
7. **Prioritize Scope** - Determine MVP vs future phases
8. **Validate** - Check completeness and consistency

### 2. Writing User Stories

Use the standard format:

**As a** [user type]  
**I want to** [action]  
**So that** [benefit]

**Acceptance Criteria:**
- [ ] [Testable criterion 1]
- [ ] [Testable criterion 2]
- [ ] [Testable criterion 3]

**Best Practices:**
- Keep stories atomic and independently testable
- Each story should deliver incremental value
- Acceptance criteria must be testable and specific
- Include priority level (High/Medium/Low)
- Note any dependencies on other stories
- Write from user perspective, not system perspective
- Focus on value/benefit in "so that" clause
- Avoid technical implementation details in story description

For detailed story patterns by feature type (authentication, CRUD, search, payments, etc.), see `references/story-patterns.md`.

### 3. Epic Structure

Group related stories into epics that represent complete features or capabilities:

```markdown
## Epic: [Name]
**Priority:** [Must-have/Should-have/Nice-to-have]
**Business Value:** [High/Medium/Low]

### User Stories
[Individual stories with acceptance criteria]

### Technical Considerations
[Notes for technical architect]

### UX Considerations  
[Notes for UX designer]
```

Each epic should:
- Represent a complete, independently valuable capability
- Contain 3-10 user stories typically
- Have clear business value
- Be prioritized for release planning

For complete epic examples by domain (authentication, notifications, analytics, etc.), see `references/epic-examples.md`.

### 4. Scope Prioritization

Use this decision framework to determine what goes in MVP:

| Feature | User Value | Technical Complexity | MVP Status |
|---------|------------|---------------------|------------|
| Feature | High/Med/Low | High/Med/Low | Must/Should/Future |

**Criteria:**
- **Must-have (MVP):** Core value proposition; users cannot use the product without it
- **Should-have:** Important functionality but product works without it
- **Nice-to-have (Future):** Enhancement that can wait for later phases

**Guidelines:**
- MVP should form a complete, usable product (not just Phase 1)
- Don't overload MVP - keep it minimal but viable
- Consider technical dependencies when prioritizing
- Factor in technical risk for high-complexity items

### 5. Non-Functional Requirements

Always address these categories for production-ready specifications:

- **Performance:** Response times, throughput, concurrent users, page load times
- **Security:** Authentication mechanisms, authorization model, data protection
- **Scalability:** Growth expectations, load handling, database scaling
- **Reliability:** Uptime targets, error rates, recovery procedures
- **Accessibility:** WCAG compliance level, keyboard navigation, screen reader support
- **Maintainability:** Code standards, documentation requirements, testing expectations

For a detailed NFR checklist with specific examples, see `references/nfr-checklist.md`.

## Output Format

### PRD Structure

Use this standard structure (full template available in `assets/prd-template.md`):

1. **Product Vision & Goals** - The "why" and measurable objectives
2. **Target Users** - User personas and their needs
3. **Feature Overview** - High-level summary of capabilities
4. **Epic Breakdown** - Detailed epics with user stories and acceptance criteria
5. **Non-Functional Requirements** - Performance, security, scalability, etc.
6. **User Experience Requirements** - Key user flows and design principles
7. **Success Metrics** - How to measure product success (KPIs)
8. **Release Planning** - MVP and future phases
9. **Assumptions & Dependencies** - What we're assuming and what we need
10. **Constraints & Risks** - Limitations and potential issues with mitigations
11. **Out of Scope** - What's explicitly NOT included

## Common Patterns

### Example: Authentication Epic

```markdown
## Epic: User Authentication
**Priority:** Must-have
**Business Value:** High

### User Stories

#### Story: User Registration
**As a** new user  
**I want to** create an account with email and password  
**So that** I can access personalized features

**Acceptance Criteria:**
- [ ] User can enter email and password on registration form
- [ ] Email validation prevents invalid formats
- [ ] Email uniqueness is enforced (error if already exists)
- [ ] Password must meet security requirements (8+ chars, uppercase, lowercase, number, special char)
- [ ] User receives confirmation email upon successful registration
- [ ] Account is created in database with proper default values
- [ ] Error messages are clear and actionable
- [ ] Success message confirms registration

**Priority:** High  
**Dependencies:** None  
**Estimated Complexity:** Medium

#### Story: User Login
**As a** registered user  
**I want to** log into my account with email and password  
**So that** I can access my personalized data

**Acceptance Criteria:**
- [ ] User can enter email and password on login form
- [ ] Valid credentials grant access and redirect to dashboard
- [ ] Invalid credentials show clear error message
- [ ] Account lockout after 5 failed attempts
- [ ] Session token expires after 24 hours of inactivity
- [ ] "Remember me" option extends session to 30 days
- [ ] Error messages don't reveal whether email exists

**Priority:** High  
**Dependencies:** User Registration must be complete  
**Estimated Complexity:** Medium
```

For more epic examples covering different domains, see `references/epic-examples.md`.

## Validation Checklist

Before finalizing a PRD, verify completeness:

- [ ] Product vision is clearly stated and compelling
- [ ] Measurable goals defined with specific targets
- [ ] All epics have complete user stories
- [ ] All stories have testable acceptance criteria
- [ ] MVP scope is clearly defined and justified
- [ ] Non-functional requirements specified for all categories
- [ ] Dependencies identified and documented
- [ ] Risks documented with mitigation strategies
- [ ] Success metrics defined with measurement methods
- [ ] Out-of-scope items explicitly listed
- [ ] Target users/personas clearly described
- [ ] Release phases planned with timeline estimates

## Reference Files

Load these files when you need detailed guidance on specific aspects:

- **`references/prd-template.md`** - Complete PRD template with all sections and guidance
- **`references/story-patterns.md`** - Story patterns for different feature types (auth, CRUD, search, payments, notifications)
- **`references/epic-examples.md`** - Example epic breakdowns by domain
- **`references/acceptance-criteria-guide.md`** - Writing clear, testable acceptance criteria
- **`references/nfr-checklist.md`** - Comprehensive non-functional requirements with examples

## Asset Templates

Ready-to-use templates for quick starts:

- **`assets/prd-template.md`** - Clean PRD template to copy and customize
- **`assets/story-template.md`** - User story template with proper format
- **`assets/epic-template.md`** - Epic breakdown template

## Best Practices Summary

### Epic Organization
- Each epic represents a complete, independently valuable capability
- Group 3-10 related stories per epic
- Consider technical dependencies when ordering epics
- Include both technical and UX considerations

### Story Quality
- Stories should be independently testable and deliverable
- Avoid stories that are too large (split into smaller stories)
- Avoid stories that are too small (combine related micro-stories)
- Include edge cases and error scenarios in acceptance criteria
- Consider the complete user journey, not just happy path

### Acceptance Criteria
- Must be testable and objective (no subjective criteria like "looks good")
- Cover happy path, edge cases, and error conditions
- Should be verifiable by QA without developer interpretation
- Include specific values and thresholds where applicable
- Format as checkboxes for easy validation

### Priority Assignment
- Base priority on user value AND technical dependencies
- Must-have features should form a complete, usable product
- Be ruthless about keeping MVP minimal
- Consider technical risk when prioritizing uncertain features

### Stakeholder Alignment
- Validate product vision with stakeholders before writing stories
- Review epic prioritization with business and technical leads
- Ensure NFRs align with infrastructure capabilities
- Get sign-off on MVP scope before development begins

## Integration Points

**Input Sources:**
- Project brief from Business Analyst
- User research and personas
- Business requirements from stakeholders
- Competitive analysis
- Technical constraints from architects

**Output Consumers:**
- Technical Architect (uses PRD for system design)
- UX Designer (uses PRD for interface design)
- Scrum Master (uses PRD to create detailed story files)
- Development Team (uses PRD for understanding)
- Stakeholders (uses PRD for approval and tracking)

**Handoff Criteria:**
- PRD must be complete per validation checklist
- MVP scope must be clearly defined and approved
- All epics and stories must be prioritized
- Non-functional requirements must be specific and measurable
- Dependencies and risks must be documented
