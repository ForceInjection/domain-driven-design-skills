---
name: product-context-template
description: Generic product context template for creating product vision, goals, and constraints skills. Auto-invoke when user requests product skill creation, product context framework, or strategic alignment templates. Do NOT load during actual product work (use project-specific skills instead).
allowed-tools: [Grep]
version: 1.0.0
category: Templates
tags: [template, product-context, vision, strategy]
last-updated: 2025-10-20
---

# Product Context Template

## Purpose
This template guides the creation of product context skills - strategic information about product vision, goals, constraints, and positioning that helps Claude understand the "why" behind technical decisions. Replace all `[PLACEHOLDER]` values with actual product information.

## SKILL.md Frontmatter Template

```yaml
---
name: [product-name]-context
description: Product context for [PRODUCT_NAME] including vision, goals, and constraints when discussing [FEATURE_AREA_1], [FEATURE_AREA_2], or [USE_CASE]. Auto-invoke when user mentions [PRODUCT_NAME], [KEY_FEATURE], or [TARGET_USER_SEGMENT]. Do NOT load for general [DOMAIN] discussions unrelated to [PRODUCT_NAME].
allowed-tools: []
version: 1.0.0
category: Product
tags: [[product-name], [domain], product-context, strategy]
product-version: [VERSION_OR_RELEASE]
last-updated: [YYYY-MM-DD]
---
```

**Description Engineering Guidance**:

✅ **DO** include:
- Product name and key features
- Specific feature areas covered
- Target user segments
- Strategic positioning keywords

❌ **DON'T** use:
- Generic descriptions ("Information about product...")
- No product scope boundaries
- Missing trigger terms users will actually mention

**Example Good Description**:
```
Product context for EasyPay payment processing including merchant onboarding, flexible leasing, and international support when discussing payment flows, compliance requirements, or merchant experience. Auto-invoke when user mentions EasyPay, merchant setup, or leasing options. Do NOT load for general payment discussions outside EasyPay.
```

## Product Context Content Structure

### 1. Product Vision & Mission

**Purpose**: Core purpose and long-term aspiration

#### Product Vision
`[ONE_SENTENCE_VISION_STATEMENT]`

**Example**: "Enable every restaurant to offer flexible payment options that increase customer purchasing power while maintaining financial security."

#### Mission Statement
`[ONE_TO_TWO_SENTENCE_MISSION]`

**Target Outcome**: `[MEASURABLE_GOAL_OR_IMPACT]`
- Example: "Increase average transaction value by >30%"
- Example: "Reduce merchant setup time from weeks to <24 hours"

#### Strategic Positioning
- **Market Position**: `[WHERE_PRODUCT_FITS_IN_MARKET]`
- **Differentiation**: `[WHAT_MAKES_THIS_UNIQUE]`
- **Competitive Advantage**: `[KEY_ADVANTAGE_OVER_ALTERNATIVES]`

### 2. Target Users & Personas

**Purpose**: Who the product serves and their key characteristics

#### Primary Persona: `[PERSONA_NAME]`

**Role**: `[JOB_TITLE_OR_ROLE]`

**Key Characteristics**:
- **Goals**: `[PRIMARY_GOAL_1]`, `[PRIMARY_GOAL_2]`
- **Pain Points**: `[PAIN_POINT_1]`, `[PAIN_POINT_2]`
- **Technical Proficiency**: `[LOW/MEDIUM/HIGH]`
- **Decision Authority**: `[WHAT_THEY_CAN_DECIDE]`

**Success Metrics** (for this persona):
- `[METRIC_1]`: `[TARGET_VALUE]`
- `[METRIC_2]`: `[TARGET_VALUE]`

#### Secondary Persona: `[PERSONA_NAME]`
(Repeat structure for secondary/tertiary personas)

### 3. Product Goals & Success Metrics

**Purpose**: Measurable objectives and KPIs

#### Current Release Goals `[RELEASE_VERSION]`

| Goal | Success Metric | Target | Current | Status |
|------|----------------|--------|---------|--------|
| `[GOAL_1]` | `[METRIC_NAME]` | `[TARGET_VALUE]` | `[CURRENT_VALUE]` | `[ON_TRACK/AT_RISK/ACHIEVED]` |
| `[GOAL_2]` | `[METRIC_NAME]` | `[TARGET_VALUE]` | `[CURRENT_VALUE]` | `[ON_TRACK/AT_RISK/ACHIEVED]` |
| `[GOAL_3]` | `[METRIC_NAME]` | `[TARGET_VALUE]` | `[CURRENT_VALUE]` | `[ON_TRACK/AT_RISK/ACHIEVED]` |

#### Long-Term Strategic Goals (12-24 months)
1. `[STRATEGIC_GOAL_1]`: `[DESCRIPTION_AND_WHY]`
2. `[STRATEGIC_GOAL_2]`: `[DESCRIPTION_AND_WHY]`
3. `[STRATEGIC_GOAL_3]`: `[DESCRIPTION_AND_WHY]`

### 4. Product Constraints & Trade-offs

**Purpose**: Known limitations and strategic trade-off decisions

#### Technical Constraints
- **Performance**: `[CONSTRAINT_DESCRIPTION]`
  - Example: "Must support 10,000 transactions/second"
  - Rationale: `[WHY_THIS_MATTERS]`

- **Scalability**: `[CONSTRAINT_DESCRIPTION]`
  - Example: "Architecture must scale to 100M users without redesign"
  - Rationale: `[WHY_THIS_MATTERS]`

- **Integration**: `[CONSTRAINT_DESCRIPTION]`
  - Example: "Must integrate with legacy POS systems via REST API"
  - Rationale: `[WHY_THIS_MATTERS]`

#### Business Constraints
- **Budget**: `[CONSTRAINT_DESCRIPTION]` (use relative terms, no specific amounts)
- **Timeline**: `[CONSTRAINT_DESCRIPTION]`
- **Resources**: `[CONSTRAINT_DESCRIPTION]`
- **Compliance**: `[REGULATORY_REQUIREMENTS]`

#### Strategic Trade-offs (Decisions Made)
```
Trade-off: [WHAT_WAS_DECIDED]
We chose: [OPTION_A]
Over: [OPTION_B]
Because: [RATIONALE]
Date decided: [YYYY-MM-DD]
Revisit if: [CONDITION_THAT_WOULD_CHANGE_DECISION]
```

### 5. Core Features & Capabilities

**Purpose**: What the product does (high-level, not implementation details)

#### Feature Category: `[CATEGORY_NAME]`

**Features**:
1. **`[FEATURE_NAME]`**
   - **Purpose**: `[WHY_THIS_EXISTS]`
   - **User Value**: `[BENEFIT_TO_USER]`
   - **Status**: `[AVAILABLE/IN_DEVELOPMENT/PLANNED]`
   - **Priority**: `[MUST_HAVE/SHOULD_HAVE/NICE_TO_HAVE]`

2. **`[FEATURE_NAME]`**
   (Repeat structure)

#### Feature Roadmap (High-Level)

| Quarter | Theme | Key Features | Goal |
|---------|-------|--------------|------|
| `[Q1 YYYY]` | `[THEME]` | `[FEATURES]` | `[OBJECTIVE]` |
| `[Q2 YYYY]` | `[THEME]` | `[FEATURES]` | `[OBJECTIVE]` |
| `[Q3 YYYY]` | `[THEME]` | `[FEATURES]` | `[OBJECTIVE]` |

**Note**: Roadmap is directional, subject to change based on customer feedback and market conditions.

### 6. User Experience Principles

**Purpose**: Design philosophy and UX standards

#### Core UX Principles
1. **`[PRINCIPLE_1]`**: `[DESCRIPTION]`
   - Example: "Simplicity over features - every screen should have single clear purpose"
   - Application: `[HOW_THIS_APPLIES_TO_DECISIONS]`

2. **`[PRINCIPLE_2]`**: `[DESCRIPTION]`
   - Example: "Progressive disclosure - show basics first, advanced options on demand"
   - Application: `[HOW_THIS_APPLIES_TO_DECISIONS]`

3. **`[PRINCIPLE_3]`**: `[DESCRIPTION]`
   - Example: "Mobile-first design - optimize for smallest screen, enhance for larger"
   - Application: `[HOW_THIS_APPLIES_TO_DECISIONS]`

#### Accessibility Standards
- **Compliance Level**: `[WCAG_LEVEL]` (e.g., WCAG 2.1 AA)
- **Key Requirements**: `[SPECIFIC_REQUIREMENTS]`
- **Testing Approach**: `[HOW_ACCESSIBILITY_IS_VALIDATED]`

### 7. Integration & Ecosystem

**Purpose**: How product fits in broader ecosystem

#### Key Integrations
| System | Integration Type | Purpose | Status |
|--------|------------------|---------|--------|
| `[SYSTEM_1]` | `[API/WEBHOOK/SDK]` | `[WHY_INTEGRATED]` | `[ACTIVE/PLANNED]` |
| `[SYSTEM_2]` | `[API/WEBHOOK/SDK]` | `[WHY_INTEGRATED]` | `[ACTIVE/PLANNED]` |

#### Ecosystem Position
```
Upstream Dependencies: [SYSTEMS_WE_DEPEND_ON]
Downstream Consumers: [SYSTEMS_THAT_DEPEND_ON_US]
Lateral Partners: [PEER_SYSTEMS_WE_COORDINATE_WITH]
```

### 8. Assumptions & Risks

**Purpose**: Known assumptions and tracked risks

#### Key Assumptions
1. **`[ASSUMPTION_1]`**
   - If wrong, impact: `[WHAT_WOULD_CHANGE]`
   - Validation approach: `[HOW_WE_TEST_THIS]`

2. **`[ASSUMPTION_2]`**
   (Repeat structure)

#### Risk Register

| Risk | Probability | Impact | Mitigation | Owner |
|------|-------------|--------|------------|-------|
| `[RISK_1]` | `[LOW/MEDIUM/HIGH]` | `[LOW/MEDIUM/HIGH]` | `[MITIGATION_STRATEGY]` | `[ROLE_NOT_NAME]` |
| `[RISK_2]` | `[LOW/MEDIUM/HIGH]` | `[LOW/MEDIUM/HIGH]` | `[MITIGATION_STRATEGY]` | `[ROLE_NOT_NAME]` |

## Validation Checklist

Before finalizing product context skill, verify:

**Content Quality**:
- [ ] All `[PLACEHOLDERS]` replaced with actual values
- [ ] Zero PII (no names, emails, phone numbers)
- [ ] Zero business-confidential data (revenue, pricing, specific budgets)
- [ ] Vision and goals are clear and measurable
- [ ] Constraints are documented with rationale

**Strategic Clarity**:
- [ ] Vision statement is one sentence and inspiring
- [ ] Success metrics are specific and measurable
- [ ] Trade-offs are documented with reasoning
- [ ] Assumptions are testable
- [ ] Risks have mitigation strategies

**User Focus**:
- [ ] Primary personas clearly defined
- [ ] User goals and pain points specific
- [ ] UX principles actionable (not generic)
- [ ] Accessibility requirements clear

**Metadata & Tracking**:
- [ ] `product-version` field indicates current release
- [ ] Last updated date is current
- [ ] `allowed-tools: []` set (product context is read-only reference)
- [ ] Category and tags aid discovery

**Security & Scope**:
- [ ] File location matches scope (product context in `.claude/skills/projects/[product-name]/`)
- [ ] No competitive intelligence or confidential strategy exposed
- [ ] Reviewed by product owner

## Usage Examples

**Creating New Product Context Skill**:
```
User: "Create a product context skill for EasyPay"

Claude: [Loads this template skill, uses structure to create EasyPay-specific context]
```

**Feature Development Guidance**:
```
User: "Should we add advanced analytics to the merchant dashboard?"

Claude: [Loads product context skill, checks against vision, user personas, and goals]
Response: "Based on product vision of 'simplicity over features' and primary persona being small restaurant owners with low technical proficiency, advanced analytics might violate UX principle #1. Consider progressive disclosure - basic metrics by default, advanced analytics opt-in."
```

**Do NOT Use This Template For**:
- Actual product work (use project-specific skills instead)
- Technical implementation details (use ground truth for specs)
- Stakeholder information (use stakeholder template)
- Frequently changing tactical plans (product context is strategic)

## Maintenance & Freshness

**Update Triggers**:
- New product vision or strategic pivot
- Major release with significant feature changes
- Quarterly goals update
- New competitive positioning
- Persona evolution based on user research

**Review Cadence**:
- **Vision/Mission**: Annually or on strategic pivot
- **Goals/Metrics**: Quarterly
- **Features/Roadmap**: Monthly
- **Constraints/Risks**: Ongoing as they change

**Version Control**:
- Update `product-version` field with product release version
- Track changes in git with reference to product release notes
- Use semantic versioning for template (1.0.0 → 1.1.0 for additions)

---

**Template Source**: Phase 2 requirements + product management best practices
**Template Version**: 1.0.0
**Last Updated**: 2025-10-20
**Validation**: Ready for Phase 2 implementation
