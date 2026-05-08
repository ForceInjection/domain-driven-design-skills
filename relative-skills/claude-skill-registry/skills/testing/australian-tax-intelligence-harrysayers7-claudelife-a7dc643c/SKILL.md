---
name: Australian Tax Intelligence
description: Provides tax knowledge and deduction validation for Harry's multi-entity Australian business ecosystem (MOKAI PTY LTD, MOK HOUSE PTY LTD, SAFIA Unit Trust, HS Family Trust, Harrison Robert Sayers sole trader). Integrates with Graphiti MCP for entity relationship memory and Serena MCP for calculation patterns. Automatically validates tax deductions, monitors GST thresholds, optimizes trust distributions, and tracks APRA/SAFIA royalty income. Triggers when discussing deductions, tax brackets, GST registration, trust distributions, business expenses, UpBank transactions, or Australian tax optimization. Uses lazy-loading knowledge architecture for token efficiency.
---

# Australian Tax Intelligence

Tax knowledge system for Harry's multi-entity business with automatic knowledge building via Graphiti (facts) and Serena (patterns).

## When to Use This Skill

Automatically activate when user mentions:
- **Tax concepts**: deduction, write-off, tax bracket, franking credits, BAS
- **GST**: threshold, registration, turnover, compliance
- **Entities**: MOKAI, MOK HOUSE, SAFIA, Family Trust, sole trader
- **Income**: APRA royalties, salary, dividend, distributions
- **Assets**: Tesla, home office, musical instruments
- **Questions**: "Is X deductible?", "What's my tax on Y?", "Should I register for GST?"

## Knowledge Architecture (Three-Layer System)

### Layer 1: Entity Facts & Relationships → Graphiti MCP

**What Graphiti stores**:
- Entity ownership (Harry owns MOK HOUSE → transferring to HS Family Trust)
- Asset details (Tesla loan $90,254 @ 4.23%, balloon $41,676.82 Dec 2026)
- Deduction rules (Gym: NEVER deductible, Instruments: YES deductible)
- Financial events (SAFIA show $60K on [date], Invoice overdue since [date])
- Income thresholds (Harry target <$45K for 19% bracket)

**Query pattern**:
```javascript
mcp__graphiti__search_memory_facts({
  query: "[entity/asset/income] tax deductible rules ownership"
})
```

### Layer 2: Calculation Methods & Patterns → Serena MCP

**What Serena stores**:
- Deduction calculation methods (Logbook vs cents/km for vehicles)
- Database schema (Supabase column names, table relationships)
- File locations (Financial reports → 01-areas/finance/analysis/)
- Workflow patterns (Cash flow: 3-month rolling average for APRA)
- Tax strategies (Distribute to Wife first to minimize 32.5% bracket)

**Query pattern**:
```javascript
mcp__serena__read_memory({
  memory_file_name: "harry_tax_deduction_patterns"
})
```

### Layer 3: Tax Law & Rates → Skill Reference Files

**What skill provides**:
- Australian tax rates (FY2025-26 brackets)
- GST rules (threshold $75K, registration timing)
- Company/trust tax rates (25% base rate entity, 45% accumulation)
- General deduction principles (Section 8-1 ITAA 1997)

**Load pattern**: Reference files on-demand only

---

## Core Workflows

### Workflow 1: Deduction Validation

**User asks**: "Is [expense] tax deductible?"

**Steps**:
1. **Check Graphiti first** (instant answer if rule exists):
   ```javascript
   mcp__graphiti__search_memory_facts({
     query: "[expense] tax deductible Harry business"
   })
   ```

2. **If no rule in Graphiti**, apply general tax principles:
   - Section 8-1: Incurred in gaining/producing assessable income?
   - Nexus to income-producing activity?
   - Not capital, private, or domestic?

3. **Validate against known patterns** (from Serena if complex calculation):
   ```javascript
   mcp__serena__read_memory({
     memory_file_name: "harry_tax_deduction_patterns"
   })
   ```

4. **Provide answer with reasoning**:
   ```markdown
   ✅/❌ [Expense] is/is not tax deductible

   **Reasoning**: [Why based on tax law + Harry's situation]
   **Category**: [Expense type]
   **Apportionment**: [If partial, show %]
   **Evidence required**: [Receipt, logbook, etc.]
   ```

5. **Store new rule** (automatic):
   ```javascript
   // Store in Graphiti for instant future lookup
   mcp__graphiti__add_memory({
     name: "Deduction Rule Discovery",
     episode_body: "[Expense] is [deductible/not deductible] because [reason]",
     source: "message",
     group_id: "harry-financial-entities"
   })
   ```

6. **Suggest pattern** (if recurring expense type):
   ```markdown
   💡 **Pattern detected**: This expense type appears regularly.

   Should I store the calculation method in Serena?
   - Pattern: "[Expense category] → [Deduction method]"
   - Future benefit: Instant validation without re-analysis

   [Store pattern] [Skip]
   ```

See: `workflows/deduction-validation.md` for detailed workflow

---

### Workflow 2: GST Threshold Monitoring

**User mentions**: entity name, turnover, GST registration

**Steps**:
1. **Query Graphiti for current status**:
   ```javascript
   mcp__graphiti__search_memory_facts({
     query: "[entity] GST registered turnover threshold FY2025-26"
   })
   ```

2. **Calculate threshold percentage**:
   ```bash
   python scripts/validate_gst_threshold.py [current_turnover]
   ```

   Returns:
   ```json
   {
     "current_turnover": 52000,
     "threshold": 75000,
     "percentage": 69.3,
     "should_alert": false,
     "recommendation": null
   }
   ```

3. **If >70% threshold**:
   ```markdown
   ⚠️ **GST Threshold Alert**

   **Entity**: [Name]
   **Progress**: 69.3% of $75,000 threshold
   **Current turnover**: $52,000 (FY2025-26)

   **Recommendations**:
   - Monitor monthly turnover closely
   - Project annual turnover based on current rate
   - Register for GST if projection indicates threshold breach
   - Prepare for GST obligations (pricing, invoicing, BAS)
   ```

4. **Store status in Graphiti**:
   ```javascript
   mcp__graphiti__add_memory({
     name: "GST Threshold Update",
     episode_body: "[Entity] turnover $52K (69.3% of threshold) as at [date]",
     source: "message",
     group_id: "harry-financial-entities"
   })
   ```

See: `workflows/gst-threshold-check.md` for monitoring schedule

---

### Workflow 3: Trust Distribution Optimization

**User asks**: "Optimize trust distributions" or "What's best tax structure?"

**Steps**:
1. **Query Graphiti for income data**:
   ```javascript
   mcp__graphiti__search_memory_facts({
     query: "Harry Wife income FY2025-26 salary APRA SAFIA"
   })
   ```

2. **Query Serena for distribution strategy**:
   ```javascript
   mcp__serena__read_memory({
     memory_file_name: "harry_tax_deduction_patterns"
   })
   ```

3. **Calculate tax scenarios**:
   ```bash
   python scripts/optimize_trust_distribution.py \
     --harry-income 35000 \
     --wife-income 48000 \
     --trust-income 40000
   ```

4. **Present optimization**:
   ```markdown
   ## Trust Distribution Analysis

   ### Current Structure (No Trust Distribution)
   - Harry: $35K APRA + $0 MOK HOUSE = $35K → Tax: $3,420
   - Wife: $48K employment → Tax: $7,020
   - **Total family tax**: $10,440

   ### Optimized (With Trust Distribution)
   - Harry: $35K APRA + $10K trust = $45K → Tax: $5,520
   - Wife: $48K employment + $0 trust = $48K → Tax: $7,020
   - Trust distributes: $40K (Wife $30K, Harry $10K)
   - **Total family tax**: $12,540

   ### Analysis
   ⚠️ Trust distribution increases tax by $2,100 in this scenario

   **Reason**: Both already in 19% bracket, trust income pushes toward 32.5%
   **Better strategy**: Retain income in company, pay when beneficial
   ```

5. **Store strategy in Serena** (if user confirms):
   ```javascript
   mcp__serena__write_memory({
     memory_name: "harry_tax_deduction_patterns",
     content: "## Trust Distribution Strategy\n\n..." // Append pattern
   })
   ```

See: `workflows/trust-optimization.md` for calculation method

---

## Knowledge Capture Rules

### Automatic Storage (No User Confirmation)

**Store in Graphiti when detecting**:

| Trigger Pattern | Example | Storage |
|----------------|---------|---------|
| Asset detail + date | "Tesla balloon payment $41,676 due Dec 14, 2026" | `mcp__graphiti__add_memory()` |
| Deduction rule | "Gym membership NEVER deductible" | Fact: Gym → not_deductible (reason: personal) |
| Income threshold | "Harry targets <$45K for 19% bracket" | Fact: Harry → income_target → $45K |
| Entity status change | "MOK HOUSE registered for GST on [date]" | Fact: MOK HOUSE → gst_registered → true |
| Financial event | "SAFIA show paid $60K on [date]" | Fact: SAFIA → income_event → $60K |
| Ownership change | "MOK HOUSE transferred to Trust [date]" | Relationship: MOK HOUSE → owned_by → Trust |

**Storage pattern**:
```javascript
mcp__graphiti__add_memory({
  name: "[Fact Category]",
  episode_body: "[Detailed fact with context]",
  source: "message",
  group_id: "harry-financial-entities"
})
```

**Silent feedback**:
```markdown
🔗 **Stored**: [Brief fact description]
```

---

### Suggested Storage (Ask User First)

**Suggest Serena when detecting**:

| Trigger Pattern | Example | Suggestion |
|----------------|---------|------------|
| Method preference | "Use logbook for Tesla, not cents/km" | Store calculation method |
| Workflow improvement | "Always check Apple charges monthly" | Store review pattern |
| Strategy decision | "Distribute to Wife first (lower bracket)" | Store tax strategy |
| Calculation approach | "APRA: 6-month rolling average ±30%" | Store forecasting method |

**Suggestion format**:
```markdown
💡 **Pattern Detected**

Should I store this in Serena for future efficiency?

**Pattern**: "[Description]"
**Benefit**: [Why this helps future analysis]
**Applies to**: [Future scenarios]

[Yes - Store pattern] [No - Just this time] [Customize]
```

**If user confirms "Yes"**:
```javascript
mcp__serena__write_memory({
  memory_name: "harry_tax_deduction_patterns",
  content: `
## [Pattern Category]

### [Specific Pattern]
- **Method**: [How to do it]
- **Reason**: [Why this method]
- **Benefit**: [Quantified advantage]
- **Added**: ${date}
  `
})
```

---

## Smart Query Routing

Based on question type, route to appropriate knowledge source:

### Quick Fact Lookup → Graphiti First
```
User: "When is my Tesla balloon payment due?"
→ Query Graphiti for Tesla → balloon_payment → date
→ Instant answer: "December 14, 2026 ($41,676.82)"
```

### Calculation Method → Serena First
```
User: "How should I calculate vehicle deductions?"
→ Query Serena for "vehicle deduction method"
→ Returns: "Logbook method for Tesla (better than cents/km)"
```

### Tax Law Question → Reference Files
```
User: "What's the tax-free threshold?"
→ Load reference/tax-rates-fy2025.md
→ Returns: "$18,200 (FY2025-26)"
```

### Complex Analysis → All Three Layers
```
User: "Should I register for GST?"
→ Graphiti: Current turnover for entity
→ Serena: GST calculation pattern
→ Reference: GST threshold rules
→ Combine: Comprehensive recommendation
```

---

## Reference File Loading (On-Demand Only)

**Never load all references upfront**. Load specific file when needed:

### Tax Rates
```
User mentions: "tax bracket", "marginal rate", "company tax"
→ Load: reference/tax-rates-fy2025.md
```

### Deduction Rules
```
User asks: "Is [specific expense] deductible?"
→ Check Graphiti first
→ If not found, load: reference/deduction-rules.md (general principles)
```

### Entity Details
```
User mentions: "ABN", "GST registration", "entity structure"
→ Load: reference/entity-structure.md
```

### GST Compliance
```
User asks: "When should I register?", "BAS requirements"
→ Load: reference/gst-compliance.md
```

**Loading pattern**:
```markdown
*Loading tax rate reference for FY2025-26...*

[Reference content used to answer question]

*Reference stored in skill context for this conversation*
```

---

## Entity Context (Stored in Graphiti)

**Core entities to query from Graphiti**:

1. **MOK HOUSE PTY LTD** (ABN: 38690628212)
   - Query: `"MOK HOUSE PTY LTD ownership GST structure"`
   - Expected facts: Owner, GST status, turnover, transfer status

2. **MOKAI PTY LTD**
   - Query: `"MOKAI PTY LTD operational status GST Indigenous"`
   - Expected facts: Not yet operational, Supply Nation certified

3. **Harrison Robert Sayers - Sole Trader** (ABN: 89 184 087 850)
   - Query: `"Harrison sole trader APRA SAFIA income GST"`
   - Expected facts: Income sources, GST status, turnover

4. **SAFIA Unit Trust**
   - Query: `"SAFIA Unit Trust Harry member GST royalties"`
   - Expected facts: Band membership, GST registered, income split

5. **HS Family Trust**
   - Query: `"HS Family Trust beneficiaries distributions structure"`
   - Expected facts: Trustees, beneficiaries, distribution strategy

6. **Tesla Model 3**
   - Query: `"Tesla Model 3 loan balloon business use deduction"`
   - Expected facts: Loan terms, business use %, deduction method

**If Graphiti returns no data**: Use fallback from reference/entity-structure.md

---

## Australian Tax Rates (FY2025-26)

**Quick reference (keep in skill for instant access)**:

### Individual Tax Brackets
- $0 - $18,200: 0% (tax-free threshold)
- $18,201 - $45,000: 19% ⭐ **Target for Harry/Wife**
- $45,001 - $135,000: 32.5%
- $135,001 - $190,000: 37%
- $190,001+: 45%

### Company Tax
- Base rate entity (<$50M turnover, <80% passive): 25%
- Otherwise: 30%

### Trust Tax
- Distributed to beneficiaries: Beneficiary's marginal rate
- Accumulated (not distributed): 45% ⚠️ **Avoid this**

### GST
- Threshold: $75,000 annual turnover
- Rate: 10%
- Alert threshold: 70% ($52,500) for monitoring

### Superannuation Guarantee
- Rate: 12% (from 1 July 2025)
- Payment: Quarterly (28 days after quarter end)

**For detailed rates**: See reference/tax-rates-fy2025.md

---

## Error Handling & Data Gaps

### Graphiti Returns No Data
```markdown
⚠️ No stored information found for [entity/asset]

Using general tax principles...

💡 After this analysis, I'll store the details for instant future lookup.
```

### Serena Has No Pattern
```markdown
No established calculation pattern for [scenario]

Applying standard approach...

💡 Should I store this method for future efficiency?
```

### Ambiguous Deduction
```markdown
⚠️ **Gray Area Detected**

[Expense] deductibility depends on specific circumstances:
- ✅ Deductible IF: [Condition]
- ❌ Not deductible IF: [Condition]

**Your situation**: [Analysis based on Graphiti facts]
**Recommendation**: [Conservative or aggressive approach]

⚠️ **Specialist review recommended** for [reason]
```

---

## Output Templates

### Deduction Validation Response
```markdown
[✅/❌/⚠️] **[Expense]** is [fully/partially/not] tax deductible

**Reasoning**: [Tax law principle + Harry's specific situation]
**Category**: [Expense classification]
**Apportionment**: [Percentage if partial, e.g., "50% business use"]
**Evidence required**: [Receipt, logbook, invoice, contract]
**Timing**: [When to claim: immediate, depreciation, prepaid rules]

**Example calculation**:
- Expense: $[amount]
- Deductible portion: $[amount × %]
- Tax benefit: $[deductible × marginal_rate] saved

🔗 Stored in knowledge graph for future reference
```

### GST Alert Response
```markdown
⚠️ **GST Threshold Alert**

**Entity**: [Name]
**Current turnover** (FY2025-26): $[amount]
**Threshold progress**: [X]% of $75,000
**Projected breach date**: [Estimate based on current rate]

### Recommendations
1. ⏰ **Monitor monthly**: Track invoices to project annual total
2. 📋 **Prepare for registration** (if projection >$75K):
   - Update pricing (include GST or absorb 10%)
   - Set up GST-compliant invoicing
   - Prepare for quarterly BAS
3. 💡 **Consider voluntary registration** if:
   - Clients expect GST invoices (government contracts)
   - Want to claim input tax credits immediately

**Next review**: [Date for next threshold check]
```

### Tax Optimization Response
```markdown
## Tax Optimization Analysis

### Current Structure
[Breakdown of current income and tax by entity/beneficiary]
**Total family tax**: $[amount]

### Optimized Structure
[Proposed distribution strategy]
**Total family tax**: $[amount]

### Benefit
💰 **Annual tax saving**: $[difference]
📊 **Effective rate reduction**: [X]% → [Y]%

### Implementation Steps
1. [Step with timeline]
2. [Step with timeline]
3. [Step with timeline]

⚠️ **Specialist review required**: [If Div 7A, CGT, or complex structures involved]
```

---

## Specialist Review Flags

**Always flag for registered tax agent when**:

| Scenario | Flag Reason |
|----------|-------------|
| Trust distributions | Complex beneficiary tax implications |
| Div 7A loans | Legal compliance required |
| CGT events | Capital gains calculation complexity |
| FBT application | Fringe benefits tax rules |
| International income | Tax treaty implications |
| Business structure change | Entity restructure consequences |
| Large deductions (>$10K) | ATO audit risk management |

**Flag format**:
```markdown
⚠️ **Registered Tax Agent Review Required**

**Issue**: [What triggers the flag]
**Complexity**: [Why specialist needed]
**Risk**: [Potential consequences if wrong]
**Timing**: [When review should occur]

This analysis provides directional guidance only.
```

---

## Integration with /accountant Command

**The `/accountant` slash command uses this skill**:

```markdown
# /accountant command workflow

1. **Load tax intelligence** (this skill activates automatically)
2. **Query Supabase** for real-time financial data
3. **Analyze** using skill's tax knowledge + Graphiti facts + Serena patterns
4. **Generate report** with recommendations
5. **Save** to vault (01-areas/finance/analysis/)

This skill provides the tax intelligence layer.
The command provides the workflow orchestration.
```

**Division of labor**:
- **Skill**: Tax knowledge, deduction validation, entity facts
- **Command**: Database queries, report generation, file saving

---

## Best Practices

1. **Always query Graphiti first** for established facts
2. **Load Serena patterns** for calculation methods
3. **Reference files last** for tax law/rates
4. **Store new learnings automatically** (Graphiti facts)
5. **Suggest patterns** when recurring (Serena methods)
6. **Flag specialist review** for complex scenarios
7. **Quantify in AUD** every recommendation
8. **Keep evidence requirements** clear
9. **Update turnover regularly** for GST monitoring
10. **Review tax strategy** quarterly

---

## Limitations & Disclaimers

> **This skill provides preparatory tax guidance only.**
>
> - Not formal accounting or tax advice
> - Based on general principles and Harry's known situation
> - May not account for all circumstances or recent law changes
> - Always engage registered tax agent (TPB) for final decisions
> - Always engage CPA/CA for financial structure advice

**Skill purpose**: Enable informed discussion with tax professionals, not replace them.

---

## Related Resources

- Command: `/accountant` (uses this skill for tax intelligence)
- Graphiti group: `harry-financial-entities`
- Serena memory: `harry_tax_deduction_patterns`
- Supabase project: `gshsshaodoyttdxippwx` (SAYERS DATA)
- Reference: Australian Taxation Office (ato.gov.au)

---

**Skill ready. Knowledge graph building automatically.**
