---
name: security-prompts-threat-modeling
description: Security analysis and threat modeling prompt templates for STRIDE analysis, code review, OWASP compliance, and vulnerability assessment. Use for security planning, pre-deployment reviews, and ongoing threat assessment. Triggers include "STRIDE", "threat model", "security review", "code review", "OWASP", "payment security", "security analysis", "vulnerability assessment".
---

# Threat Modeling Security Templates

## Purpose

This skill provides security analysis and threat modeling prompt templates for proactive security assessment, vulnerability identification, and compliance checking. Use these templates throughout the development lifecycle for continuous security validation.

## Available Templates

### 01: STRIDE Analysis
**File**: `01_stride_analysis.md`
**When to use**: After architecture design, before building features
**Time**: 60 minutes

**Analysis Coverage**:
- Spoofing threats
- Tampering threats
- Repudiation threats
- Information Disclosure
- Denial of Service
- Elevation of Privilege

**Trigger keywords**: "STRIDE", "STRIDE analysis", "threat model", "create threat model", "comprehensive threat analysis", "security architecture review"

**Use case**: Initial project setup, major architecture changes, security audits

**Output**: Complete threat model document (docs/security/THREAT_MODEL.md)

---

### 02: Feature Threats
**File**: `02_feature_threats.md`
**When to use**: Before implementing new features
**Time**: 20 minutes

**Analysis Focus**:
- Feature-specific threats
- Attack vectors
- Mitigation strategies
- Integration risks

**Trigger keywords**: "feature threats", "analyze feature security", "feature threat analysis", "new feature security", "threat analysis for feature"

**Use case**: Pre-implementation security planning for individual features

**Output**: Feature-specific threat assessment

---

### 03: Architecture Impact
**File**: `03_architecture_impact.md`
**When to use**: When making architecture changes
**Time**: 30 minutes

**Analysis Focus**:
- Trust boundary changes
- Data flow modifications
- New attack surfaces
- Control gaps
- Integration risks

**Trigger keywords**: "architecture security", "architecture impact", "security impact analysis", "architecture change security", "evaluate architecture changes"

**Use case**: Database migrations, framework changes, new service integrations

**Output**: Architecture change impact assessment

---

### 04: Code Review
**File**: `04_code_review.md`
**When to use**: Before deployment, after feature completion
**Time**: 45 minutes

**Review Coverage**:
- OWASP Top 10 vulnerabilities
- Input validation gaps
- Authentication/authorization issues
- Data exposure risks
- Error handling problems
- Security control verification

**Trigger keywords**: "security review", "code review", "vulnerability review", "security code review", "review security", "check for vulnerabilities"

**Use case**: Pre-deployment reviews, pull request security checks, periodic audits

**Output**: Vulnerability findings with severity and remediation

---

### 05: Security Tests
**File**: `05_security_tests.md`
**When to use**: Automated security test generation
**Time**: 60 minutes

**Test Coverage**:
- Authentication tests
- Authorization tests
- Input validation tests
- CSRF tests
- Rate limiting tests
- Error handling tests

**Trigger keywords**: "generate security tests", "security test suite", "automated security tests", "create security tests", "test generation"

**Use case**: CI/CD integration, comprehensive test coverage, regression testing

**Output**: Complete security test suite

---

### 06: OWASP Check
**File**: `06_owasp_check.md`
**When to use**: OWASP Top 10 compliance assessment
**Time**: 45 minutes

**Compliance Check**:
- A01: Broken Access Control
- A02: Cryptographic Failures
- A03: Injection
- A04: Insecure Design
- A05: Security Misconfiguration
- A06: Vulnerable Components
- A07: Identification and Authentication Failures
- A08: Software and Data Integrity Failures
- A09: Security Logging and Monitoring Failures
- A10: Server-Side Request Forgery

**Trigger keywords**: "OWASP", "OWASP check", "OWASP compliance", "OWASP Top 10", "check OWASP", "OWASP assessment"

**Use case**: Compliance verification, security audits, baseline assessment

**Output**: OWASP compliance scorecard with gaps and recommendations

---

### 07: Payment Security
**File**: `07_payment_security.md`
**When to use**: Payment security for Clerk Billing + Stripe
**Time**: 60 minutes

**Security Focus**:
- PCI DSS compliance
- Webhook security
- Payment data handling
- Subscription security
- Fraud prevention
- Financial data protection

**Trigger keywords**: "payment security", "Stripe security", "billing security", "Clerk Billing security", "payment security review", "subscription security"

**Use case**: Payment feature implementation, billing system review, PCI compliance

**Output**: Payment security assessment and recommendations

---

### 08: Update Model
**File**: `08_update_model.md`
**When to use**: After adding features or making changes
**Time**: 15 minutes

**Update Process**:
- Identify new threats
- Update existing threats
- Modify attack vectors
- Adjust risk priorities
- Version threat model

**Trigger keywords**: "update threat model", "refresh threat model", "threat model maintenance", "update security model", "revise threat model"

**Use case**: After every feature, post-deployment, regular maintenance

**Output**: Updated threat model with version increment

---

## Usage Pattern

### 1. Identify Analysis Type

**Starting Project**:
→ 01_stride_analysis.md

**New Feature**:
→ 02_feature_threats.md → Implement → 08_update_model.md

**Architecture Change**:
→ 03_architecture_impact.md → Change → 08_update_model.md

**Before Deployment**:
→ 04_code_review.md → 06_owasp_check.md

**Adding Payments**:
→ 07_payment_security.md

**Continuous Testing**:
→ 05_security_tests.md (run in CI/CD)

### 2. Load Template

```markdown
Read: .claude/skills/security/security-prompts/threat-modeling/[number]_[name].md
```

### 3. Customize Context

Replace in template:
- `[Your app description]` with actual description
- `[Key Features]` with feature list
- `[Assets to Protect]` with actual assets
- `[Architecture details]` with specific stack

### 4. Present Analysis

```markdown
I'll conduct a [ANALYSIS_TYPE] using the threat modeling template.

**Analysis will cover**:
- [List from template]

**Estimated time**: [From template]

**Expected output**: [From template]

Let me load the template and customize it for your application...
```

### 5. Document Findings

Save results to:
- `docs/security/THREAT_MODEL.md` (main threat model)
- `docs/security/reviews/YYYY-MM-DD-[type]-review.md` (specific reviews)

## Development Lifecycle Integration

### Project Start (Week 1)
```markdown
Step 1: STRIDE Analysis
→ Use: 01_stride_analysis.md
→ Output: Initial threat model v1.0

Step 2: OWASP Baseline
→ Use: 06_owasp_check.md
→ Output: Baseline security scorecard
```

### Feature Development (Ongoing)
```markdown
Before Feature:
→ Use: 02_feature_threats.md

After Feature:
→ Use: 08_update_model.md
→ Increment threat model version (v1.0 → v1.1)
```

### Pre-Deployment (Weekly/Sprint)
```markdown
Step 1: Code Review
→ Use: 04_code_review.md
→ Fix findings

Step 2: OWASP Check
→ Use: 06_owasp_check.md
→ Verify compliance

Step 3: Security Tests
→ Use: 05_security_tests.md
→ Ensure coverage
```

### Major Changes
```markdown
Architecture Change:
→ Use: 03_architecture_impact.md
→ Assess before implementing

Payment Addition:
→ Use: 07_payment_security.md
→ Verify PCI compliance

Threat Model Update:
→ Use: 08_update_model.md
→ Keep model current
```

## Combining with Implementation Templates

### Complete Feature Workflow

```markdown
1. Threat Analysis (Pre-implementation)
   → threat-modeling/02_feature_threats.md

2. Secure Implementation
   → prompt-engineering/[appropriate_template].md

3. Security Testing
   → prompt-engineering/08_security_testing.md

4. Code Review
   → threat-modeling/04_code_review.md

5. Update Threat Model
   → threat-modeling/08_update_model.md
```

## Agent Usage

### Threat Modeler Agent

When threat-modeler agent runs:
```markdown
"Create comprehensive threat model using STRIDE template from
.claude/skills/security/security-prompts/threat-modeling/01_stride_analysis.md"
```

### Security Scanner Agent

Before scanning:
```markdown
"Review code using template from
.claude/skills/security/security-prompts/threat-modeling/04_code_review.md
to guide vulnerability assessment"
```

### Security Reporter Agent

For compliance:
```markdown
"Generate OWASP compliance report using template from
.claude/skills/security/security-prompts/threat-modeling/06_owasp_check.md"
```

## Output Management

### Threat Model Versioning

**Initial**: `docs/security/THREAT_MODEL.md` (v1.0)

**Updates**: Increment version in file
```markdown
# Threat Model v1.1
**Last Updated**: 2025-10-23
**Changes**: Added payment feature threats
```

### Review Reports

**Location**: `docs/security/reviews/`

**Naming**: `YYYY-MM-DD-[type]-review.md`

**Examples**:
- `2025-10-23-stride-analysis.md`
- `2025-10-23-owasp-check.md`
- `2025-10-23-code-review.md`
- `2025-10-23-payment-security.md`

### Test Results

**Location**: `__tests__/security/`

**Naming**: `[feature]-security.test.ts`

Generated from template 05_security_tests.md

## Integration with Secure Vibe Coding OS

All templates reference:
- **Baseline**: 90/100 OWASP score
- **Architecture**: `@docs/security/SECURITY_ARCHITECTURE.md`
- **Stack**: Next.js, Clerk, Convex, Stripe
- **Controls**: CSRF, rate limiting, validation, error handling, headers

Templates assess threats in context of existing baseline security.

## Best Practices

### Threat Model Maintenance

**After every feature**:
- Use 08_update_model.md
- Increment version
- Document changes
- Commit to Git

**Monthly reviews**:
- Re-run 01_stride_analysis.md
- Update risk priorities
- Add newly discovered threats
- Review existing mitigations

### Code Review Frequency

**Pre-deployment**: Always run 04_code_review.md

**Pull requests**: For security-sensitive changes

**Weekly**: During active development

**Quarterly**: Full security audit

### OWASP Compliance

**Initial**: Run 06_owasp_check.md at project start

**Quarterly**: Re-assess compliance

**After major changes**: Re-check affected categories

**Before audits**: Full compliance verification

## Related Skills

**Parent Skill**:
- **security-prompts** - Main directory with all template categories (engineering, auth, controls, threat-modeling)

**Agents** (use these templates):
- **threat-modeler** (agent) - Automated threat modeling
- **security-scanner** (agent) - Vulnerability scanning
- **security-reporter** (agent) - Report generation

**Note**: For other template categories (implementation, authentication, simple controls), see the parent `security-prompts` skill

## Template Customization

**Every template requires context**:
- Application description
- Key features
- Data handled
- User types
- Architecture stack
- Existing controls

**Never use generic templates** - always customize for specific application context.

## Version History

**v1.0** (2025-10-23): Initial skill creation
- Converted 8 threat modeling templates
- Added trigger keywords
- Integrated with agent workflows
- Added lifecycle guidance

---

**Note**: Threat modeling is proactive security. Use these templates early and often to identify and mitigate threats before they become vulnerabilities.
