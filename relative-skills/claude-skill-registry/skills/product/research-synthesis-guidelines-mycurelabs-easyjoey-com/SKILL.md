---
name: research-synthesis-guidelines
description: Research documentation and evidence synthesis framework for MYCURE healthcare products using HIGH/MEDIUM/LOW confidence grading, triangulation methodology, and rigorous citation standards. Auto-activates for research documentation, evidence grading, healthcare systems analysis, user research synthesis, market analysis, competitive research. Includes Philippine healthcare context (LGU health systems, FHISIS, PhilHealth).
---

# Research Synthesis Guidelines

Systematic framework for documenting, synthesizing, and grading research evidence for MYCURE healthcare products with emphasis on Philippine healthcare context.

## When This Skill Activates

- Documenting user research findings
- Synthesizing market analysis or competitive research
- Grading evidence quality and confidence levels
- Writing research reports or insights documents
- Analyzing Philippine healthcare systems (LGU, FHISIS, PhilHealth)
- Conducting stakeholder interviews or field studies
- Evaluating healthcare workflows and pain points

---

## Core Principles

### 1. Evidence-Based Decision Making

**All product decisions must be grounded in research.**

**Why:**
- Healthcare products impact patient care
- Assumptions can lead to dangerous design flaws
- Philippine healthcare context has unique requirements
- Stakeholder buy-in requires credible evidence

### 2. Transparent Confidence Grading

**Every finding must be labeled with confidence level.**

**Why:**
- Not all evidence is equal quality
- Teams need to know which findings to trust
- HIGH confidence findings drive major decisions
- LOW confidence findings require further investigation

### 3. Triangulation for Validation

**Multiple sources strengthen findings.**

**Why:**
- Single sources can be biased or incomplete
- Triangulation reduces error
- Philippine healthcare varies by region (urban vs. rural)
- Cross-validation ensures accuracy

---

## Confidence Grading Framework

### HIGH Confidence

**Definition:** Finding is well-supported by multiple high-quality sources with consistent evidence.

**Requirements (need ALL of these):**
- ✅ **3+ independent sources** confirming the finding
- ✅ **Primary research** included (interviews, observations, surveys)
- ✅ **Recent data** (within 2 years for healthcare)
- ✅ **Philippine-specific** evidence (not extrapolated from other countries)
- ✅ **Consistent** across all sources (no major contradictions)

**Example:**
```markdown
## Finding: Manual registration takes 12-15 minutes per patient [HIGH CONFIDENCE]

**Evidence:**
1. **Direct observation** - Observed 15 patient registrations at 3 Manila clinics,
   average time 14.2 minutes (June 2024)
2. **Stakeholder interviews** - 8 clinic administrators reported 12-15 minute average
   registration time (May-June 2024)
3. **DOH data** - Department of Health study cited 13.5 minute average for
   Metro Manila clinics (2023)

**Triangulation:** Primary observation + stakeholder reports + government data = HIGH
```

---

### MEDIUM Confidence

**Definition:** Finding has some support but gaps in evidence quality, recency, or triangulation.

**Characteristics (one or more):**
- ⚠️ **1-2 sources** (not fully triangulated)
- ⚠️ **Secondary research only** (no primary data collected)
- ⚠️ **Dated evidence** (2-5 years old)
- ⚠️ **Extrapolated** from similar contexts (other SE Asian countries)
- ⚠️ **Minor inconsistencies** between sources

**Example:**
```markdown
## Finding: LGU health workers prefer mobile apps over desktop [MEDIUM CONFIDENCE]

**Evidence:**
1. **Industry report** - 2022 Southeast Asia digital health survey showed 68%
   preference for mobile in rural health settings (regional, not PH-specific)
2. **Anecdotal** - 2 RHU staff mentioned preferring mobile during informal
   conversations (small sample)

**Gaps:** No Philippine-specific data, small sample size, older regional data

**Recommendation:** Conduct targeted survey of Philippine LGU health workers before
making mobile-first decision
```

---

### LOW Confidence

**Definition:** Finding is speculative, unsupported, or based on weak evidence. Requires further investigation.

**Characteristics (one or more):**
- ❌ **Single source** or anecdotal only
- ❌ **No primary research**
- ❌ **Outdated** (5+ years old)
- ❌ **Not Philippine-specific** (US/EU data extrapolated)
- ❌ **Contradictory** evidence exists
- ❌ **Assumption** not validated

**Example:**
```markdown
## Finding: Clinics willing to pay ₱50,000/month for MYCURE [LOW CONFIDENCE]

**Evidence:**
1. **Assumption** - Based on perceived value, not actual willingness-to-pay data
2. **No validation** - Have not asked clinics about pricing

**Status:** HYPOTHESIS ONLY - Requires pricing research before proceeding

**Next steps:** Conduct pricing sensitivity survey with 20+ target clinics
```

---

## Triangulation Methodology

**Triangulation = Using multiple data sources or methods to validate findings.**

### Types of Triangulation

#### 1. Data Triangulation (Most Common)

**Combine different data sources:**

**Sources:**
- **Primary research:** Interviews, observations, surveys you conduct
- **Secondary research:** Published studies, reports, government data
- **Internal data:** Usage analytics, support tickets, sales feedback

**Example:**
```markdown
Finding: Inventory mismanagement costs clinics 15-20% of medication budget

**Data triangulation:**
1. **Primary:** Interviewed 10 clinic administrators, 8 reported 15-25% loss
2. **Secondary:** DOH 2023 report cited 18% average medication wastage
3. **Internal:** MYCURE pilot clinic reduced waste from 22% to 5% with inventory tracking

**Result:** HIGH confidence - three independent data types align
```

#### 2. Method Triangulation

**Use different research methods:**

**Methods:**
- **Interviews** (qualitative depth)
- **Surveys** (quantitative breadth)
- **Observation** (behavioral truth)
- **Analytics** (usage patterns)

**Example:**
```markdown
Finding: Receptionists skip validation fields to save time

**Method triangulation:**
1. **Interview:** Receptionists admitted skipping non-required fields "to move faster"
2. **Observation:** Watched 5 receptionists skip 70% of optional fields
3. **Analytics:** Form completion data shows optional fields filled <30% of the time

**Result:** HIGH confidence - stated behavior matches observed and measured behavior
```

#### 3. Philippine Healthcare Context Triangulation

**Validate across different Philippine healthcare settings:**

**Settings:**
- **Private clinics** (urban, well-resourced)
- **LGU health centers** (rural, limited resources)
- **Government hospitals** (public sector)
- **RHUs/BHSs** (barangay-level primary care)

**Example:**
```markdown
Finding: Internet connectivity is unreliable for healthcare IT systems

**Context triangulation:**
1. **Urban private clinics:** Reliable fiber connection, 99% uptime
2. **RHUs (rural):** 2G/3G only, frequent outages, <50% reliability
3. **LGU city health offices:** DSL or fiber, 80-90% reliability

**Result:** MEDIUM-HIGH confidence - varies by setting, MYCURE must work offline
```

---

## Citation Standards

### Why Citations Matter

**Credibility:**
- Allows verification of claims
- Shows rigor and thoroughness
- Enables future researchers to build on work
- Required for stakeholder trust

### Citation Format

**Use this structure:**

```markdown
## Finding Title [CONFIDENCE LEVEL]

**Summary:** [1-2 sentence finding statement]

**Evidence:**

1. **[Source Type]** - [Name/Organization], "[Title or Description]",
   [Date], [Specific data point or quote]

2. **[Source Type]** - [Name/Organization], "[Title or Description]",
   [Date], [Specific data point or quote]

3. **[Source Type]** - [Name/Organization], "[Title or Description]",
   [Date], [Specific data point or quote]

**Triangulation assessment:** [How sources validate each other]

**Limitations:** [Any gaps, biases, or caveats]

**Implications:** [What this means for product/design decisions]
```

### Source Types

**Interviews:**
```markdown
**Interview** - Dr. Maria Santos (General Practitioner, Manila Clinic),
"Patient registration currently takes 15 minutes on average",
June 15, 2024, Stakeholder interview
```

**Observations:**
```markdown
**Direct observation** - Field study at 3 Metro Manila clinics,
14.2 minute average registration time (n=15 patients),
June 10-12, 2024, User research
```

**Documents:**
```markdown
**Government report** - Department of Health Philippines,
"Philippine Health Facility Survey 2023", Published March 2023,
Page 42: "Average patient wait time 45 minutes in public health centers"
```

**Surveys:**
```markdown
**Survey** - MYCURE target market survey (n=50 clinic administrators),
"73% report using paper-based records as primary system",
Conducted May 2024
```

**Analytics:**
```markdown
**Usage data** - MYCURE pilot program analytics (n=5 clinics, 6 months),
"Registration time reduced from 15min to 5min average",
Jan-June 2024
```

**Websites:**
```markdown
**Online source** - PhilHealth official website,
"PhilHealth Claims Processing Guidelines",
Accessed June 20, 2024,
URL: https://www.philhealth.gov.ph/claims/
```

---

## Research Report Template

```markdown
---
title: "[Research Topic]"
research_type: User Research | Market Analysis | Competitive Analysis | Field Study
date_conducted: 2024-06-15
researchers: [Names]
status: draft | final
confidentiality: internal
---

# [Research Topic]

## Executive Summary

[3-5 bullet points of key findings with confidence levels]

- Finding 1 [HIGH CONFIDENCE]
- Finding 2 [MEDIUM CONFIDENCE]
- Finding 3 [HIGH CONFIDENCE]

---

## Research Methodology

**Type:** [User interviews | Surveys | Field observations | Document analysis]

**Sample:**
- Size: [Number of participants/sources]
- Description: [Who/what was studied]
- Selection: [How sample was chosen]

**Dates:** [When research conducted]

**Location:** [Where research took place]

**Limitations:**
- [Limitation 1]
- [Limitation 2]

---

## Findings

### Finding 1: [Title] [HIGH CONFIDENCE]

**Summary:** [1-2 sentence description]

**Evidence:**

1. **[Source type]** - [Citation]
2. **[Source type]** - [Citation]
3. **[Source type]** - [Citation]

**Triangulation:** [How sources validate finding]

**Implications:** [What this means for MYCURE]

---

### Finding 2: [Title] [MEDIUM CONFIDENCE]

[Same structure...]

---

## Recommendations

### Immediate Actions (HIGH Confidence Findings)

1. **Recommendation 1** - Based on Finding 1
   - Action: [Specific next step]
   - Owner: [Who should do it]
   - Timeline: [When]

### Further Investigation Needed (LOW/MEDIUM Confidence)

1. **Research Gap 1** - Finding 3 needs validation
   - Method: [How to validate]
   - Timeline: [When to conduct]

---

## Appendices

### Appendix A: Interview Guide
[Interview questions used]

### Appendix B: Raw Data
[Survey results, observation notes, etc.]

### Appendix C: Sources
[Full bibliography of secondary sources]
```

---

## Philippine Healthcare Context

### Key Systems to Understand

**FHISIS (Field Health Service Information System):**
- DOH reporting system for LGU health centers
- Monthly reporting requirements
- Specific data formats and fields
- Research implications: MYCURE must support FHISIS export

**PhilHealth:**
- National health insurance
- Claims processing requirements
- Accreditation standards
- Research implications: Integration needs for billing

**LGU Health Structure:**
- Provincial Health Office (PHO)
- City/Municipal Health Office (CHO/MHO)
- Rural Health Units (RHUs)
- Barangay Health Stations (BHS)
- Research implications: Varying resource levels, connectivity, literacy

### Research Considerations

**Urban vs. Rural:**
- Infrastructure varies dramatically
- Internet connectivity: Urban 90%+ vs. Rural 30-50%
- Staff technical literacy: Urban high vs. Rural mixed
- Don't extrapolate urban findings to rural contexts

**Public vs. Private:**
- Resource levels differ significantly
- Public: Government budget constraints, high volume
- Private: Better resources, lower volume
- Research both sectors separately

**Regional Variations:**
- Metro Manila ≠ Provinces ≠ BARMM
- Language: English/Filipino in NCR, regional languages in provinces
- Validate findings across multiple regions

---

## Quality Checklist

Before finalizing research:

- [ ] **All findings graded** (HIGH/MEDIUM/LOW)
- [ ] **HIGH confidence = 3+ sources** triangulated
- [ ] **Citations complete** with dates and specifics
- [ ] **Philippine-specific** data (not extrapolated)
- [ ] **Recent evidence** (within 2 years preferred)
- [ ] **Methodology documented** (reproducible)
- [ ] **Limitations acknowledged** (no overclaiming)
- [ ] **Recommendations actionable** (tied to findings)
- [ ] **Executive summary** for stakeholders
- [ ] **Raw data preserved** in appendices

---

## Common Pitfalls

### ❌ Don't Do This

**Treating all evidence equally:**
```
Finding: Clinics want mobile-first design

Evidence: Read blog post about mobile trends

Confidence: HIGH ← WRONG
```

**Extrapolating without validation:**
```
Finding: Philippine clinics will behave like US clinics

Evidence: US healthcare IT study

Confidence: MEDIUM ← WRONG (should be LOW)
```

**Ignoring contradictory evidence:**
```
Finding: All clinics prefer cloud-based

Evidence: 5 clinics said yes
[Ignored: 3 clinics said no due to connectivity]

Confidence: HIGH ← WRONG (cherry-picking)
```

### ✅ Do This

**Grade honestly:**
```
Finding: Clinics may prefer mobile-first design

Evidence: General mobile trends blog post (not healthcare-specific)

Confidence: LOW

Next step: Conduct targeted survey of Philippine clinics
```

**Validate locally:**
```
Finding: Philippine LGU health workers face connectivity challenges

Evidence:
1. Interview: 10 RHU staff in Bulacan reported frequent outages
2. Observation: Visited 5 RHUs, saw 3G-only connectivity
3. DOH report: 2023 study cited 40% of rural health centers lack reliable internet

Confidence: HIGH (triangulated, Philippine-specific, recent)
```

---

## Summary

**Research synthesis framework:**
1. **Grade every finding:** HIGH/MEDIUM/LOW confidence
2. **Triangulate:** 3+ sources for HIGH confidence
3. **Cite rigorously:** Enable verification
4. **Context matters:** Philippine healthcare is unique
5. **Be honest:** Acknowledge limitations and gaps

**Confidence requirements:**
- **HIGH:** 3+ sources, primary research, recent, PH-specific, consistent
- **MEDIUM:** 1-2 sources, some gaps in quality/recency
- **LOW:** Single source, outdated, assumptions, contradictory

**Use research to drive decisions:**
- HIGH confidence → Act with confidence
- MEDIUM confidence → Proceed with caution, validate further
- LOW confidence → Do NOT base major decisions, research more

**Remember:** In healthcare, bad research leads to bad products. Bad products harm patients. Grade honestly, cite thoroughly, validate rigorously.
