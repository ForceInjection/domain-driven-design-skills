---
name: terraform-audit
description: Audits Terraform code for anti-patterns, security issues, and best practice violations. Use when asked to audit, review, or check terraform code quality. Generates a comprehensive report under reports/YYYY-MM-DD/terraform-audit.md. (project)
---

# Purpose

Enforce Terraform code quality and security standards across the `terraform/` directory through automated checks.

**What it checks (9 checks):**
1. Hardcoded secrets (passwords, API keys, AWS keys, GitHub PATs) - HIGH
2. Security issues (RBAC wildcards, open security groups, encryption, public access) - HIGH
3. Missing version constraints (providers, modules, git refs) - HIGH
4. Resource lifecycle (prevent_destroy, Helm timeouts, deletion protection) - HIGH
5. Deprecated syntax (old interpolation, list(), map(), count vs for_each) - HIGH
6. Module structure (README, required files, backend) - MEDIUM
7. Dependency issues (excessive depends_on, circular deps) - MEDIUM
8. Missing descriptions (variables, outputs) - LOW
9. Naming conventions (snake_case enforcement) - LOW

# Running Checks

**Full audit (all checks):**
```bash
node .claude/skills/terraform-audit/scripts/run_all_checks.mjs
```

**Generate report (all checks + markdown report):**
```bash
node .claude/skills/terraform-audit/scripts/generate_report.mjs
```
Report saved to: `reports/YYYY-MM-DD/terraform-audit.md`

**Individual checks:**
```bash
node .claude/skills/terraform-audit/scripts/check_hardcoded_secrets.mjs
node .claude/skills/terraform-audit/scripts/check_security_issues.mjs
node .claude/skills/terraform-audit/scripts/check_missing_versions.mjs
node .claude/skills/terraform-audit/scripts/check_resource_lifecycle.mjs
node .claude/skills/terraform-audit/scripts/check_deprecated_syntax.mjs
node .claude/skills/terraform-audit/scripts/check_module_structure.mjs
node .claude/skills/terraform-audit/scripts/check_dependency_issues.mjs
node .claude/skills/terraform-audit/scripts/check_missing_descriptions.mjs
node .claude/skills/terraform-audit/scripts/check_naming_conventions.mjs
```

# Quality Rules

## 1. Hardcoded Secrets (HIGH)

**RULE**: Never hardcode sensitive values. Exposed secrets = compromised infrastructure.

**Violations**:
- `password = "mysecretpassword"`
- `api_key = "sk-1234567890"`
- `access_key = "AKIA..."`
- `github_token = "ghp_..."`
- Any `_pat`, `_token`, `_secret`, `_key` with literal value

**Fix**: Use `var.password`, `random_password.db.result`, or secrets manager.

---

## 2. Security Issues (HIGH)

**RULE**: Follow least-privilege principle. Over-permissive = security breach waiting to happen.

**Violations**:
- `"Action": "*"` or `"Resource": "*"` in IAM policies
- `verbs = ["*"]`, `resources = ["*"]`, `api_groups = ["*"]` in K8s RBAC
- `cidr_blocks = ["0.0.0.0/0"]` - open to internet
- `encrypted = false` - unencrypted data at rest
- `publicly_accessible = true` - database exposed
- `privileged = true` - container running as root
- `skip_final_snapshot = true` - data loss on delete
- `deletion_protection = false` - accidental deletion risk

**Fix**: Use specific permissions, restrict CIDR blocks, enable encryption, protect resources.

---

## 3. Missing Version Constraints (HIGH)

**RULE**: Pin versions for reproducibility. Unpinned = CI/CD failures + breaking changes in production.

**Violations**:
- Provider without version in `required_providers`
- Module from registry without `version`
- GitHub/Git module without `?ref=` or `?tag=`
- Missing `required_version` for Terraform itself

**Fix**: Add `version = "~> 2.0"` to providers and modules.

---

## 4. Resource Lifecycle (HIGH)

**RULE**: Protect critical resources. No protection = data loss + downtime.

**Violations**:
- Database/storage without `lifecycle { prevent_destroy = true }`
- Helm release without `timeout` (infinite hang possible)
- RDS/database without `deletion_protection = true`
- RDS with `skip_final_snapshot = true`
- EKS/GKE cluster without lifecycle protection

**Fix**: Add lifecycle blocks and deletion protection to critical resources.

---

## 5. Deprecated Syntax (HIGH)

**RULE**: Use modern Terraform syntax. Deprecated syntax = upgrade blockers + state corruption risk.

**Violations**:
- `"${var.name}"` instead of `var.name` (unnecessary interpolation)
- `list("a", "b")` instead of `["a", "b"]` (deprecated function)
- `map("key", "value")` instead of `{ key = "value" }` (deprecated function)
- `count = length(var.x)` instead of `for_each` (index-based state = corruption risk)
- `element(list, count.index)` instead of `list[count.index]`
- `terraform.workspace` usage (anti-pattern)

**Fix**: Update to modern HCL syntax before Terraform upgrades.

---

## 6. Module Structure (MEDIUM)

**RULE**: Follow standard module structure for maintainability.

**Required files**:
- `variables.tf`, `outputs.tf`, `versions.tf`, `README.md`

**Violations**:
- Missing required files
- Root module without backend configuration
- Too many .tf files (>10) - split into modules

**Fix**: Add missing files, configure backend, refactor large modules.

---

## 7. Dependency Issues (MEDIUM)

**RULE**: Use implicit dependencies. Explicit depends_on = maintenance nightmare.

**Violations**:
- >5 `depends_on` in one file (over-reliance)
- `depends_on` with data sources (usually unnecessary)
- `null_resource` provisioner without `depends_on` or `triggers`

**Fix**: Use resource references for implicit dependencies.

---

## 8. Missing Descriptions (LOW)

**RULE**: Document all variables and outputs for usability.

**Violations**:
- `variable "name" { type = string }` (no description)
- `output "id" { value = ... }` (no description)

**Fix**: Add `description = "..."` to all variables and outputs.

---

## 9. Naming Conventions (LOW)

**RULE**: Use snake_case everywhere for consistency.

**Violations**:
- camelCase: `myResourceName`
- kebab-case: `my-resource-name`

**Fix**: Rename to `my_resource_name`.

---

# Safety

- Read-only operation (except report generation)
- No Terraform state modifications
- No infrastructure changes
