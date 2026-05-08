---
name: risk-assessor
description: Perform comprehensive risk assessments on OSCAL systems including threat modeling, vulnerability analysis, risk scoring, and POA&M generation. Use this skill to evaluate security posture and prioritize remediation efforts.
---

# Risk Assessor Skill

Perform comprehensive risk assessments based on OSCAL data, including threat identification, vulnerability analysis, risk scoring, and remediation recommendations.

## When to Use This Skill

Use this skill when you need to:
- Assess overall security risk posture
- Identify and score individual risks
- Generate risk-based POA&M items
- Prioritize remediation efforts
- Perform threat modeling
- Analyze vulnerability impact

---

## ⛔ Authoritative Data Requirement

Risk assessment requires **user-provided documents** — not training knowledge.

### What You MUST Have
| Data Type | Source | Why Required |
|-----------|--------|-------------|
| Control baseline | User's profile/catalog | Defines what controls are required |
| SSP or control inventory | User-provided | Shows what's implemented |
| Vulnerability data | User's scan results | Actual findings, not assumed |
| Asset information | User-provided | System boundaries and data types |

### What You Can Provide (Methodology)
- Risk calculation formulas (Likelihood × Impact)
- Scoring frameworks (the process)
- Report templates and formats
- General threat categories (STRIDE, etc.)
- Prioritization methodologies

### What You CANNOT Provide
- Specific control requirements (must come from catalog)
- Baseline comparisons without the baseline document
- Gap analysis without both baseline AND SSP
- Vulnerability details without scan data

### If Missing Required Data
```
I cannot assess risks without:
• Your SSP or control implementation inventory
• The baseline profile your system must meet (e.g., FedRAMP Moderate)
• [For gap analysis] Both documents to compare

Please provide these documents. I will not guess at control
requirements or make assumptions about your implementation status.
```

---

## Risk Levels

| Level | Score Range | Description | Response Time |
|-------|-------------|-------------|---------------|
| Very Low | 0-10 | Minimal risk | Monitor |
| Low | 11-30 | Minor risk | 90 days |
| Moderate | 31-60 | Significant risk | 60 days |
| High | 61-80 | Serious risk | 30 days |
| Very High | 81-100 | Critical risk | Immediate |

## Risk Calculation

Risk = Likelihood × Impact

### Likelihood Factors
- Threat source capability
- Attack complexity
- Existing controls
- Historical incidents
- Exposure level

### Impact Factors
- Confidentiality impact
- Integrity impact
- Availability impact
- Financial impact
- Regulatory impact

## Threat Sources

| Source | Category | Examples |
|--------|----------|----------|
| Adversarial | External attackers | Nation states, criminals, hacktivists |
| Accidental | Human error | Misconfigurations, mistakes |
| Structural | System failures | Hardware, software, dependencies |
| Environmental | External events | Natural disasters, power loss |

## Risk Assessment Process

### Step 1: Inventory Assets
Identify system components and data:
- System boundaries
- Data types and sensitivity
- Critical functions
- Dependencies

### Step 2: Identify Threats
For each asset, identify potential threats:
- Who might attack?
- What methods would they use?
- What's their motivation?

### Step 3: Identify Vulnerabilities
Analyze weaknesses:
- Missing or weak controls
- Configuration issues
- Known CVEs
- Process gaps

### Step 4: Assess Current Controls
Review implemented controls:
- Are controls in place?
- Are they operating effectively?
- What gaps exist?

### Step 5: Calculate Risk Scores
For each threat-vulnerability pair:
1. Estimate likelihood (1-10)
2. Estimate impact (1-10)
3. Calculate: Risk = Likelihood × Impact
4. Determine risk level

### Step 6: Prioritize Risks
Rank risks by:
1. Risk score (highest first)
2. Ease of exploitation
3. Asset criticality
4. Regulatory requirements

### Step 7: Generate Recommendations
For each risk:
- Identify mitigation options
- Estimate effort and cost
- Recommend actions
- Set target dates

## Control Gap Analysis

### Baseline Comparison
Compare implemented controls against baseline:
- Required controls (from profile)
- Implemented controls (from SSP)
- Gap = Required - Implemented

### Effectiveness Assessment
For implemented controls:
- Fully effective
- Partially effective
- Not effective
- Not assessed

## Risk Report Format

```
RISK ASSESSMENT REPORT
======================
System: [System Name]
Assessment Date: [Date]
Assessor: [Name/AI]

EXECUTIVE SUMMARY
-----------------
Overall Risk Level: [LEVEL]
Critical Risks: X
High Risks: Y
Moderate Risks: Z

TOP RISKS
---------
1. [RISK-001] Unauthorized Access via Weak Authentication
   Likelihood: High (8/10)
   Impact: High (9/10)
   Risk Score: 72 (HIGH)
   Affected Controls: IA-2, IA-5
   Recommendation: Implement MFA within 30 days

2. [RISK-002] Data Exposure from Misconfigured Storage
   Likelihood: Moderate (6/10)
   Impact: Very High (10/10)
   Risk Score: 60 (MODERATE)
   Affected Controls: SC-28, AC-3
   Recommendation: Enable encryption, restrict access

CONTROL GAPS
------------
Missing Controls: 5
- CM-6: Configuration settings not documented
- SI-4: No automated monitoring
...

POA&M ITEMS
-----------
1. Implement multi-factor authentication
   Milestone: Complete by [date]
   Resources: IAM team, 40 hours
   
2. Configure storage encryption
   Milestone: Complete by [date]
   Resources: Cloud team, 20 hours
```

## POAM Generation

For each identified risk, generate POA&M item:

```yaml
poam_item:
  id: POAM-2024-001
  title: Implement Multi-Factor Authentication
  description: Address IA-2 weakness in user authentication
  risk_level: HIGH
  weakness: Lack of MFA exposes accounts to credential theft
  remediation: Deploy MFA for all privileged accounts
  milestone: 2024-03-01
  resources:
    - IAM Administrator
    - 40 hours effort
  dependencies:
    - Identity provider upgrade
  status: planned
```

## Example Usage

When asked "Assess the security risks in this SSP":

1. Parse the SSP document
2. Extract system characteristics
3. List implemented controls
4. Identify control gaps vs baseline
5. For each gap, assess risk
6. Calculate risk scores
7. Rank by severity
8. Generate remediation recommendations
9. Produce POA&M items for high risks
