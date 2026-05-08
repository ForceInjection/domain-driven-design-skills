---
name: prd-generator
description: Transform product requirements, ideas, or concepts into professional development resources. Use when users request help with product planning, PRD creation, work breakdown, or converting ideas into structured development plans. Triggers include phrases like "create a PRD", "break down this feature", "plan this product", "write requirements", "work breakdown structure", or providing product ideas that need to be formalized into development artifacts.
---

# PRD Generator

Transform product ideas, requirements, or concepts into two comprehensive development resources: a Product Requirements Document (PRD) and a Work Breakdown Structure (WBS).

## Workflow

Follow these steps when generating product development resources:

1. **Understand the product concept**: Gather information about the product idea, requirements, or concept through conversation
2. **Read reference materials**: Load the relevant reference files to understand structure and patterns
3. **Generate the PRD**: Create a comprehensive markdown PRD following industry standards
4. **Generate the work breakdown**: Create a hierarchical WBS with Epic → Features → User Stories
5. **Deliver markdown files**: Save both documents to `product-docs/`
6. **Offer Atlassian integration** (optional): Ask if the user wants to create items in Jira via MCP

## Step 1: Understanding the Product

Engage with the user to clarify:
- What problem does this product solve?
- Who are the target users?
- What are the key features or capabilities?
- Are there any constraints (timeline, budget, technical)?
- What does success look like?
- Are there existing designs, mockups, or documentation?

For ambiguous or incomplete concepts, ask targeted questions to fill gaps. Don't make assumptions about critical requirements.

## Step 2: Read Reference Materials

Before generating documents, read the relevant reference files:

**For PRD structure and content**:
Read `references/prd_structure.md` to understand the standard sections and format for professional PRDs.

**For work breakdown patterns**:
Read `references/work_breakdown.md` to understand how to decompose work into Epic → Feature → User Story hierarchy with appropriate sizing.

**For Atlassian MCP integration** (if user requests it):
Read `references/atlassian_mcp.md` to understand how to create issues in Jira.

## Step 3: Generate the PRD

Create a comprehensive PRD markdown file that includes:

### Required Sections

1. **Executive Summary**: Brief overview with product name, problem, solution, and key metrics
2. **Background and Strategic Fit**: Why this matters and how it aligns with objectives
3. **Goals and Success Metrics**: Clear objectives and measurable KPIs
4. **User Personas**: Primary and secondary users with needs and behaviors
5. **User Stories and Use Cases**: High-level user stories with acceptance criteria
6. **Requirements and Features**: Both functional and non-functional requirements
7. **Technical Considerations**: Architecture, integrations, and tech stack notes
8. **Testing Strategy**: Approach for unit, integration, E2E, and UAT
9. **Deployment and Operations**: Deployment strategy, monitoring, and rollback plans
10. **Assumptions and Dependencies**: Known constraints and external dependencies
11. **Out of Scope**: Explicitly excluded features
12. **Open Questions and Risks**: Unresolved items and risk mitigation
13. **Timeline and Milestones**: Key dates and phases

### PRD Quality Standards

- Be concise but complete (aim for 5-15 pages)
- Use clear headers and formatting for scannability
- Include visual placeholders for diagrams and mockups
- Focus on "why" not just "what"
- Make it actionable for engineering teams
- Use specific, measurable success criteria

Save the PRD to: `product-docs/prd.md`

## Step 4: Generate the Work Breakdown

Create a hierarchical work breakdown in markdown format with three levels:

### Epic Level

Start with 1-3 epics that represent major bodies of work aligned with the PRD goals. Each epic should:
- Have a clear, action-oriented title
- Include a brief description from the PRD context
- Span multiple sprints (4-12 weeks of work)
- Contain 3-8 features

### Feature Level

Break each epic into distinct features. Each feature should:
- Represent a complete, deliverable capability
- Have a specific title describing the functionality
- Take 1-3 sprints to complete
- Contain 3-10 user stories

### User Story Level

Break each feature into user stories following these guidelines:
- Use the format: "As a [user], I want to [action] so that [benefit]"
- Size as **approximately one day of development effort**
- Assign sizing: **S (2-4 hours)**, **M (4-8 hours)**, **L (1-2 days)**, or **Unknown**
- Include acceptance criteria
- Tag with relevant categories (Frontend, Backend, Integration, Testing, DevOps, Documentation)

### Comprehensive Coverage

Ensure the breakdown includes stories for:
- Frontend UI/UX implementation
- Backend API and business logic
- Database schema and migrations
- Third-party integrations
- Unit, integration, and E2E testing
- Infrastructure and deployment
- Monitoring and observability
- Documentation
- Security considerations

### Markdown Format Example

```markdown
# Work Breakdown Structure

## Epic 1: [Epic Title]

Brief epic description

### Feature 1.1: [Feature Title]

Feature description

#### User Stories

- **[Story Title]** (Size: M, Tags: Backend, API)
  - As a [user], I want to [action] so that [benefit]
  - Acceptance Criteria:
    - Criterion 1
    - Criterion 2
  - Technical Notes: Implementation details

- **[Story Title]** (Size: S, Tags: Testing)
  - Story description...
```

Save the work breakdown to: `product-docs/work_breakdown.md`

## Step 5: Deliver Outputs

After generating both documents:
1. Save PRD to `product-docs/prd.md`
2. Save work breakdown to `product-docs/work_breakdown.md`
3. Provide download links to both files
4. Offer a brief summary of what was created

## Step 6: Atlassian MCP Integration (Optional)

If the user wants to create these items in Jira:

1. Ask: "Would you like me to create these items in Jira using the Atlassian MCP?"
2. If yes, read `references/atlassian_mcp.md` for detailed integration instructions
3. Create Epic, Features (as Stories), and User Stories (as Sub-tasks) in Jira
4. Provide a summary with Jira issue keys and links

If MCP is unavailable, inform the user and ensure markdown files are formatted for easy manual import.

## Quality Checklist

Before delivering outputs, verify:
- [ ] PRD includes all required sections with substantive content
- [ ] Work breakdown covers frontend, backend, testing, deployment, and documentation
- [ ] User stories are sized appropriately (~1 day of effort)
- [ ] Acceptance criteria are specific and testable
- [ ] Technical considerations are addressed
- [ ] Both files are saved to `product-docs/`
- [ ] Download links are provided to the user

## Tips for Best Results

- **For vague requirements**: Ask clarifying questions before generating documents
- **For complex products**: Consider breaking into phases or MVPs
- **For technical products**: Ensure non-functional requirements are well-defined
- **For user-facing products**: Emphasize user personas and user experience
- **For integrations**: Detail API requirements and data flows
- **For legacy replacements**: Include migration and transition planning
