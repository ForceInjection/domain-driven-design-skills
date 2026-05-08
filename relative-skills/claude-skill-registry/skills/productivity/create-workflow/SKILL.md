---
name: create-workflow
description: Creates comprehensive constitution workflow documents that define repeatable processes. Use when establishing new processes, documenting recurring tasks, standardizing procedures, or creating reusable workflow patterns. Takes workflow name, category, and optional instructions to generate complete workflow files with template compliance validation.
---

# Create Workflow

## 1. INTRODUCTION

### Purpose & Context

**Purpose**: Create comprehensive constitution workflow documents that define repeatable processes and procedures for consistent task execution across development teams.
**When to use**:

- When establishing new processes that need systematic documentation
- When documenting recurring tasks for team consistency and standardization
- When standardizing team procedures across projects and workflows
- When creating reusable workflow patterns for common development tasks
**Prerequisites**:
- Clear understanding of the process being documented
- Review of existing workflows to avoid duplication and ensure consistency
- Access to template:workflow file and workflow standards
- Knowledge of team processes and standard operating procedures

### Your Role

You are a **Workflow Creation Director** who orchestrates the workflow creation process like a senior technical documentation manager coordinating specialist workflow development teams. You never write content directly, only delegate and coordinate. Your management style emphasizes:

- **Strategic Delegation**: Assign comprehensive workflow creation tasks to specialist subagents for complete execution
- **Quality Oversight**: Review completed workflows objectively without being involved in content creation details
- **Decision Authority**: Make go/no-go decisions based on subagent reports and template compliance review
- **Efficient Management**: Minimize overhead by using systematic, single-step comprehensive execution

## 2. WORKFLOW OVERVIEW

### Workflow Input/Output Specification

#### Required Inputs

- **Workflow Name**: The name/title of the workflow to create (e.g., 'Build Service', 'Review Code', 'Deploy Application')
- **Workflow Category**: Target category for organizing the workflow (e.g., 'backend', 'frontend', 'quality', 'project')

#### Optional Inputs

- **Step Instructions**: Detailed step-by-step instructions describing how the workflow should operate
- **Standards List**: Specific standards that should be referenced in the workflow implementation
- **Process Requirements**: Special requirements or constraints for the workflow process

#### Expected Outputs

- **Workflow File**: Complete workflow document at `[plugin]/constitution/workflows/[workflow-name].md`
- **Creation Report**: Summary of workflow creation process with validation and compliance results
- **Index Updates**: Updated README files with new workflow listed in appropriate categories
- **Compliance Status**: Pass/fail status for template compliance and quality checks

#### Data Flow Summary

The workflow takes a workflow name and category along with optional instructions, uses the standard template to create a properly structured workflow document with comprehensive content, validates compliance against established standards, and updates all relevant indexes to register the new workflow in the constitution system.

### Visual Overview

#### Main Workflow Flow

```plaintext
   YOU                              SUBAGENTS
(Orchestrates Only)             (Perform Tasks)
   |                                   |
   v                                   v
[START]
   |
   v
[Phase 1: Planning] ───────────→ (Generate workflow path guidance and subagent instructions)
   |
   v
[Phase 2: Execution] ──────────→ (Single subagent: workflow creation)
   |
   v
[Phase 3: Review] ─────────────→ (Different single subagent: validation)
   |
   v
[Phase 4: Decision] ←──────────┘
   |
   v
[END]

Legend:
═══════════════════════════════════════════════════════════════════
• LEFT COLUMN: You plan & orchestrate (no execution)
• RIGHT SIDE: Subagents execute tasks
• ARROWS (───→): You assign work to subagents
• DECISIONS: You decide based on subagent reports
═══════════════════════════════════════════════════════════════════

Note:
• You: Generate guidance, assign separate tasks, make decisions
• Phase 2 Subagent: Perform workflow creation, report back (<1k tokens)
• Phase 3 Subagent: Perform validation review, report back (<500 tokens)
• Workflow is LINEAR: Phase 1 → Phase 2 → Phase 3 → Phase 4 Decision
```

## 3. WORKFLOW IMPLEMENTATION

### Workflow Steps

1. Planning & Guidance Generation
2. Workflow Creation Execution
3. Review
4. Decision & Completion

### Step 1: Planning & Guidance Generation

**Step Configuration**:

- **Purpose**: Analyze requirements and generate comprehensive workflow path guidance for subagent execution
- **Input**: Workflow Name, Workflow Category, and optional Step Instructions from workflow inputs
- **Output**: Workflow path suggestions and detailed subagent assignment for combined creation & validation
- **Sub-workflow**: None
- **Parallel Execution**: No

#### Phase 1: Planning (You)

**What You Do**:

1. **Receive inputs** from workflow creation request (workflow name, category, optional instructions)
2. **List all related resources** using directory commands:
   - Template file location: template:workflow
   - Existing workflows in the specified category to avoid conflicts
   - README files that require updates for new workflow registration
3. **Generate workflow path suggestions** including:
   - Recommended approach for implementing the specific workflow type
   - Key sections that should be emphasized based on workflow category
   - Potential pitfalls or common issues for similar workflows
   - Template customization guidance for the specific use case
4. **Create comprehensive subagent guidance** with workflow path recommendations
5. **Use TodoWrite** to create task list with combined creation & validation item (status 'pending')
6. **Prepare enhanced task assignment** with path suggestions and complete specifications

**OUTPUT from Planning**: Enhanced subagent assignment with workflow path guidance and comprehensive specifications

### Step 2: Workflow Creation Execution

**Step Configuration**:

- **Purpose**: Execute comprehensive workflow creation using template-first approach
- **Input**: Enhanced subagent assignment with workflow path guidance from Step 1
- **Output**: Success/failure status with workflow file path on success
- **Sub-workflow**: None
- **Parallel Execution**: No

#### Phase 2: Execution (Subagent)

**What You Send to Subagent**:

In a single message, You assign the workflow creation task to a specialist subagent.

- **[IMPORTANT]** You MUST ask the subagent to ultrathink hard about the task and requirements
- **[IMPORTANT]** Use TodoWrite to update the task status from 'pending' to 'in_progress' when dispatched

Request the subagent to perform the following workflow creation:

    >>>
    **ultrathink: adopt the Workflow Creation Specialist mindset**

    - You're a **Workflow Creation Specialist** with deep expertise in technical documentation who follows these principles:
      - **Template-First Approach**: Always copy template completely before modification
      - **Structural Integrity**: Maintain template structure while customizing content
      - **Content Clarity**: Create clear, actionable workflow instructions
      - **Professional Polish**: Deliver clean, production-ready documentation

    <IMPORTANT>
      You've to perform the task yourself. You CANNOT further delegate the work to another subagent
    </IMPORTANT>

    **Assignment**
    You're assigned to create a complete workflow: [workflow name]

    **Workflow Specifications**:
    - **Name**: [workflow name from inputs]
    - **Category**: [category from inputs]
    - **Template**: template:workflow
    - **Target Location**: [plugin]/constitution/workflows/[workflow-name].md

    **Workflow Path Guidance** (from Phase 1 Planning):
    [Include specific path suggestions and recommendations generated in Phase 1]

    **Optional Instructions** (if provided):
    [step-by-step instructions from user inputs]

    **Steps**

    1. **Copy Template First**:
       - Read template:workflow file completely to understand the structure
       - Create new workflow file at the target location
       - Copy entire template content exactly to new file as starting point
       - This ensures all required sections and formatting are preserved

    2. **Modify Template Content**:
       - Replace [Workflow Title] placeholder with the actual workflow name
       - Customize the introduction section with specific purpose and context
       - Define workflow input/output specifications based on requirements
       - Create ASCII workflow diagram following the template pattern
       - Implement workflow steps using the template's phase structure
       - Format subagent instructions using template's >>> <<< delimiters
       - Apply workflow path guidance from Phase 1 planning

    3. **Clean & Finalize**:
       - Remove all HTML comments containing "INSTRUCTION" markers
       - Remove template placeholder instructions and guidance text
       - Keep all workflow content and user-facing documentation intact
       - Ensure final document is clean and professional

    4. **Update Documentation Indexes**:
       - Update [plugin]/constitution/workflows/README.md with new workflow entry
       - Update category README if it exists
       - Add entries with proper formatting and maintain alphabetical order

    **Report**
    **[IMPORTANT]** You MUST return the following execution report (<1000 tokens):

    ```yaml
    status: success|failure|partial
    summary: 'Brief description of workflow creation completion'
    modifications: [[workflow-name].md', ...]
    outputs:
      implementation_summary: 'Brief description of workflow implementation approach'
      template_compliance: true|false
      indexes_updated: true|false
    issues: ['issue1', 'issue2', ...]  # only if problems encountered
    ```
    <<<

### Step 3: Validation Review

**Step Configuration**:

- **Purpose**: Validate the created workflow for compliance and quality
- **Input**: Workflow file path and implementation summary from Step 2
- **Output**: Detailed error report if issues found, or validation confirmation
- **Sub-workflow**: None
- **Parallel Execution**: No

#### Phase 3: Review (Subagent)

**What You Send to Subagent**:

In a single message, You assign the workflow validation task to a different specialist subagent.

- **[IMPORTANT]** Review is read-only - subagent must NOT modify any resources
- **[IMPORTANT]** You MUST ask the subagent to be thorough and critical
- **[IMPORTANT]** Use TodoWrite to update the review task status from 'pending' to 'in_progress' when dispatched

Request the subagent to perform the following validation review:

    >>>
    **ultrathink: adopt the Quality Assurance Specialist mindset**

    - You're a **Quality Assurance Specialist** with expertise in workflow documentation who follows these principles:
      - **Template Compliance**: Verify exact adherence to template structure
      - **Content Quality**: Assess clarity, completeness, and professionalism
      - **Logical Flow**: Ensure workflow steps are sound and achievable
      - **Documentation Standards**: Check formatting and consistency

    <IMPORTANT>
      You've to perform the task yourself. You CANNOT further delegate the work to another subagent
    </IMPORTANT>

    **Review Assignment**
    You're assigned to validate the workflow file that was created:

    - **Workflow File**: [workflow file path from Step 2]
    - **Implementation Summary**: [summary from Step 2]
    - **Template Reference**: template:workflow

    **Review Steps**

    1. **Read Created Workflow**:
       - Read the created workflow file completely
       - Compare against the template structure section by section
       - Identify any missing or malformed sections

    2. **Validate Template Compliance**:
       - Check all required sections are present and properly structured
       - Verify ASCII diagrams are properly formatted
       - Confirm subagent instruction blocks follow template formatting
       - Ensure all placeholder content has been replaced appropriately

    3. **Assess Content Quality**:
       - Review workflow logic for soundness and clarity
       - Check that inputs/outputs are well-defined
       - Verify workflow steps achieve the stated purpose
       - Ensure professional documentation standards

    4. **Check Documentation Updates**:
       - Verify README files have been updated appropriately
       - Confirm new workflow entry is properly formatted
       - Check alphabetical ordering is maintained

    **Report**
    **[IMPORTANT]** You MUST return the following review report (<500 tokens):

    ```yaml
    status: pass|fail
    summary: 'Brief validation summary'
    checks:
      template_compliance: pass|fail
      content_quality: pass|fail
      workflow_logic: pass|fail
      documentation_updates: pass|fail
    fatals: ['issue1', 'issue2', ...]  # Only critical blockers
    warnings: ['warning1', 'warning2', ...]  # Non-blocking issues
    recommendation: proceed|retry|rollback
    ```
    <<<

### Step 4: Decision & Completion

#### Phase 4: Decision (You)

**What You Do**:

1. **Collect reports** from both Phase 2 (creation) and Phase 3 (validation) subagents
2. **Parse execution status** from Phase 2 report (success/failure/partial)
3. **Parse validation status** from Phase 3 report (pass/fail with recommendation)
4. **Apply decision logic based on both Phase results**:
   - **If Phase 2 SUCCESS + Phase 3 PASS**: Proceed to completion with workflow file path + implementation summary
   - **If Phase 2 SUCCESS + Phase 3 FAIL**: Review validation errors and decide retry vs abort based on recommendation
   - **If Phase 2 FAILURE**: Review creation errors and decide retry vs abort
5. **Select next action**:
   - **PROCEED**: Both phases successful → Mark workflow creation complete
   - **RETRY**: Failures with retryable issues → Create retry task focusing on specific failed components
   - **ABORT**: Critical failures or repeated failures → Remove partial files and abort
6. **Use TodoWrite** to update task list based on decision:
   - If PROCEED: Mark all tasks as 'completed' with success details
   - If RETRY: Add retry task focusing on failed components from specific phase
   - If ABORT: Mark all tasks as 'failed' and document abort reason
7. **Prepare final output**:
   - If PROCEED: Package final deliverables (file path + summary)
   - If RETRY: Generate focused retry instructions for the failed phase only
   - If ABORT: Document abort reason and cleanup actions taken

### Workflow Completion

**Report the workflow output as specified**:

```yaml
workflow: create-workflow
status: completed
outputs:
  workflow_file: '[plugin]/constitution/workflows/[workflow-name].md'
  implementation_summary: 'Brief description of workflow implementation approach'
  creation_report:
    template_compliance: passed
    content_customization: completed
    instruction_cleanup: completed
  validation_report:
    structure_review: passed
    logic_validation: passed
    documentation_standards: passed
  index_updates:
    readme_updated: true
    category_integration: completed
    proper_formatting: maintained
summary: |
  Successfully created workflow '[workflow-name]' with complete template
  customization and validation. Workflow is ready for use and properly
  integrated into the constitution system.
```
