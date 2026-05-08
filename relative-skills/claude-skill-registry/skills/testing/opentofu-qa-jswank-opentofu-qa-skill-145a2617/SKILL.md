---
name: opentofu-qa
description: Quality assurance and testing toolkit for OpenTofu/Terraform infrastructure as code. Use this skill when reviewing, testing, or validating OpenTofu/Terraform configurations. This skill runs automated QA checks (tofu fmt, tofu validate, tflint, trivy) and validates code against client-specific conventions and best practices. Ideal for code review, pre-commit validation, and ensuring IaC quality standards.
---

# OpenTofu QA

## Overview

Perform comprehensive quality assurance and testing on OpenTofu/Terraform infrastructure as code. This skill automates the execution of multiple QA tools and validates code against both general best practices and client-specific conventions.

**Use this skill when:**
- Reviewing OpenTofu/Terraform code for quality issues
- Validating IaC before committing or merging
- Checking for security vulnerabilities in infrastructure code
- Ensuring code adheres to organizational conventions
- Generating QA reports for infrastructure changes

## QA Workflow

Follow this workflow when performing QA on OpenTofu/Terraform code:

### 1. Understand the Target

Identify what needs to be reviewed:
- Single module or entire infrastructure repository
- Specific files or recursive directory scan
- Environment-specific configurations (dev, staging, prod)

### 2. Run Automated QA Checks

Execute the QA runner script to perform automated checks:

```bash
python scripts/qa_runner.py [target_directory]
```

The QA runner performs these checks in sequence:

**Formatting Check (tofu fmt)**
- Validates consistent code formatting
- Identifies files that need reformatting
- Non-destructive by default (check mode)

**Configuration Validation (tofu validate)**
- Validates configuration syntax and structure
- Checks resource attribute validity
- Verifies provider configuration
- Note: Runs `tofu init -backend=false` automatically

**Linting (tflint)**
- Enforces coding standards and conventions
- Detects potential errors and anti-patterns
- Checks for deprecated syntax
- Validates naming conventions
- Note: Requires tflint to be installed

**Security Scanning (trivy)**
- Scans for security misconfigurations
- Identifies compliance violations
- Detects hardcoded secrets
- Checks for insecure resource configurations
- Note: Requires trivy to be installed

### 3. Review Convention Compliance

After automated checks, manually review code against client-specific conventions documented in `references/conventions.md`. Focus on:

**Module Structure (highest priority)**
- Verify standard file layout (main.tf, variables.tf, outputs.tf, versions.tf)
- Check file organization and logical grouping
- Validate module size and scope appropriateness
- Ensure proper module composition

**Naming Conventions**
- Resource names follow format: `{resource_type}_{descriptive_name}`
- Variable names follow format: `{purpose}_{qualifier}`
- Output names follow format: `{resource}_{attribute}`
- Module directory names use hyphens with provider prefix
- Required tags/labels are present on all taggable resources

**State Management**
- Remote backend configured for non-dev environments
- State file organization follows project standards
- Workspace usage aligns with guidelines
- State locking enabled where required

Read `references/conventions.md` to understand client-specific requirements. This file should be customized per client/organization.

### 4. Review Best Practices

Validate code against general OpenTofu/Terraform best practices documented in `references/best_practices.md`. Key areas:

**Code Organization**
- Modules used appropriately for reusability
- Resources have single, well-defined purposes
- Locals used for repeated logic

**Security**
- No hardcoded secrets
- Encryption enabled by default
- Least privilege IAM policies
- Restrictive network security rules

**Resource Management**
- Data sources used for existing resources
- count/for_each used appropriately
- Lifecycle rules applied strategically

**Quality**
- Variables have proper types and descriptions
- Validation blocks used where appropriate
- Code properly commented for complex logic
- Dependencies explicit or properly inferred

Read `references/best_practices.md` for detailed guidance on each area.

### 5. Generate QA Report

The QA runner automatically generates a markdown report (`qa_report.md`) containing:
- Summary of all checks performed
- Pass/fail status for each check
- Detailed issues and their locations
- Timestamp and target information

Use this report to:
- Document QA findings in pull requests
- Track remediation progress
- Inform subsequent Claude Code sessions for fixes
- Provide feedback to infrastructure developers

## Tool Installation

The QA runner requires these tools to be installed:

**OpenTofu** (required)
```bash
# Installation instructions at: https://opentofu.org/docs/intro/install/
```

**tflint** (recommended)
```bash
# Installation instructions at: https://github.com/terraform-linters/tflint
```

**trivy** (recommended)
```bash
# Installation instructions at: https://github.com/aquasecurity/trivy
```

If a tool is not installed, the QA runner will skip that check and note it in the report.

## Configuration Files

### TFLint Configuration

A default tflint configuration is provided in `assets/tflint.hcl`. To use it:

1. Copy to project root:
```bash
cp assets/tflint.hcl /path/to/project/.tflint.hcl
```

2. Customize for specific cloud provider by uncommenting relevant plugin sections
3. Adjust rule configurations as needed

The default configuration includes:
- Snake case naming conventions
- Documentation requirements for variables/outputs
- Type constraints for variables
- Module source pinning
- Provider version requirements

## Customizing Conventions

The `references/conventions.md` file is a template that must be customized per client/organization. To customize:

1. Review the template structure
2. Update naming convention examples to match organizational standards
3. Specify required tags/labels
4. Document state management approach
5. Add any client-specific requirements

Key areas to customize (in priority order):
1. **Module Structure**: Directory layout, file organization, module size guidelines
2. **Naming Conventions**: Resources, variables, outputs, modules, tags
3. **State Management**: Backend configuration, state organization, workspace usage

## Integration with Claude Code Sessions

This skill is designed to inform subsequent Claude Code sessions. After running QA:

1. Generate the markdown QA report
2. Share the report with a new Claude Code session focused on remediation
3. Reference specific issues by file and line number
4. Use convention documents as context for fixes

Example workflow:
```
Session 1 (QA): Run opentofu-qa skill → Generate qa_report.md
Session 2 (Fix): Read qa_report.md → Fix issues following conventions.md
Session 3 (Verify): Run opentofu-qa skill → Confirm all issues resolved
```

## Manual Review Checklist

After automated checks, manually verify:

- [ ] Module structure follows conventions
- [ ] All resources have required tags
- [ ] Naming conventions followed throughout
- [ ] Documentation complete (README, variable descriptions, output descriptions)
- [ ] State management configured appropriately
- [ ] Provider versions pinned
- [ ] Security best practices followed
- [ ] No obvious performance issues
- [ ] Complex logic properly commented

## Limitations

**What this skill does:**
- Automate execution of QA tools
- Validate against documented conventions
- Generate comprehensive reports
- Guide manual review process

**What this skill does not do:**
- Fix issues automatically (use separate remediation session)
- Make architectural decisions
- Determine if infrastructure meets business requirements
- Test actual infrastructure deployment
- Validate cloud-specific resource configurations beyond what tools detect

## Resources

### scripts/qa_runner.py
Automated test runner that executes all QA checks and generates a markdown report. Can be run independently or as part of CI/CD pipeline.

### references/conventions.md
Client-specific conventions template covering module structure, naming standards, and state management. Must be customized per organization.

### references/best_practices.md
General OpenTofu/Terraform best practices covering code organization, security, resource management, and common anti-patterns.

### assets/tflint.hcl
Default tflint configuration with sensible rules for naming conventions, documentation requirements, and code quality standards.
