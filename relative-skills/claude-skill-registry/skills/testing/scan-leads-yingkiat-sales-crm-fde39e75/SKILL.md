---
name: scan-leads
description: Find and validate companies for the SME banking pipeline. Supports two modes - validating specific companies mentioned by user, or broad searches for companies matching sector/trigger criteria (e.g., "find logistics companies with expansion").
allowed-tools: WebSearch, Read, Grep, Glob, Write, Edit
---

# Scan Leads Skill

You help the user find and validate companies for their SME banking pipeline.

This skill has TWO modes:
- **Mode A (Specific):** Validate a specific company the user mentions
- **Mode B (Broad):** Search for companies matching criteria

## IMPORTANT: Always Start by Reading User Parameters

**FIRST STEP - Read user parameters:**
```
Read /data/user-parameters.md
Extract:
- Target geography, size, sectors
- Exclusions (MNC, public DBS, holdco)
- Priority scoring criteria
```

## Mode Detection

**Mode A (Specific Company)** - User provides company name:
- "Scan YCH Group"
- "Check out Acme Logistics - heard they won a tender"
- "Validate Supreme Components"

**Mode B (Broad Search)** - User provides criteria:
- "Find 10 logistics companies with expansion triggers"
- "Find manufacturing companies that won tenders"
- "Search for healthcare companies"

---

## MODE A: Specific Company Scan

### Step 1: Research the Company

**Web search pattern:**
```
Search: "[company name] Singapore"
Search: "[company name] official website"
Search: "[company name] LinkedIn"
Search: "[company name] news 2024 2025"
```

**Find:**
- Official website URL
- LinkedIn company page URL
- Basic company info (sector, industry, size indicators)

### Step 2: Validate Existence

**IF no website AND no LinkedIn found:**
- Report: "Could not verify [company] exists. No official website or LinkedIn page found."
- Ask: "Do you have additional information about this company?"
- STOP (don't proceed further)

**IF website OR LinkedIn found:**
- Continue to Step 3

### Step 3: Apply Exclusions (from user-parameters.md)

**Check each exclusion:**

a) **MNC subsidiary check:**
   - Look for patterns in search results:
     - "[Company] subsidiary of [Parent MNC]"
     - Global brand names (FedEx, DHL, UPS, Siemens, ABB, etc.)
     - Website mentions international parent company
   - IF MNC subsidiary → Report: "Found but excluded: MNC subsidiary of [Parent]"
   - STOP

b) **Public DBS mention check:**
   - Search: "[company] DBS bank"
   - Look for: "banking partner DBS", "facility from DBS", "financed by DBS"
   - IF found in press release/credible article → Report: "Found but excluded: Public DBS banker mention"
   - STOP

c) **Holdco/size check:**
   - Look for: "Holdings", "Group" in legal name
   - Check for: listed parent, wide regional operations (>5 countries), >1000 employees
   - IF obviously large (>S$100M likely) → Report: "Found but excluded: Holdco revenue likely >S$100M"
   - IF some signals but unclear → Flag for user review (don't auto-exclude)

**IF passed all exclusions:**
- Continue to Step 4

### Step 4: Extract Triggers

**Search for trigger signals:**
```
Search: "[company] expansion Singapore"
Search: "[company] news 2024 2025"
Search: "[company] tender award"
Search: "[company] hiring LinkedIn"
Search: "[company] acquisition merger"
```

**For each search result, look for these trigger types:**

**1. Expansion triggers:**
- Keywords: "new facility", "new outlet", "new office", "opened", "expanding to", "regional expansion", "JV", "partnership"
- Example: "Opened new 50,000 sqft warehouse in Tuas"

**2. Capex triggers:**
- Keywords: "acquired equipment", "new machinery", "fleet expansion", "invested in", "purchased", "automation"
- Example: "Invested S$5M in automated cold chain equipment"

**3. Contract/order triggers:**
- Keywords: "awarded tender", "won project", "contract with", "partnership", "long-term agreement"
- Example: "Won S$20M tender from NTUC for logistics services"

**4. Hiring triggers:**
- LinkedIn job posts, "hiring", "team growth", "expanding workforce", "recruitment"
- Example: "Hiring 50 warehouse staff for expansion"

**5. M&A triggers:**
- Keywords: "acquired", "merged with", "bought", "acquisition of"
- Example: "Acquired Acme Logistics for S$30M"

**6. Compliance triggers:**
- Keywords: "ISO certification", "regulatory approval", "accreditation", "compliance", "MAS license"
- Example: "Achieved ISO 27001 certification"

**7. Operational complexity triggers:**
- Keywords: "multi-entity", "cross-border", "operations in [N] countries", "regional"
- Example: "Operates across Singapore, Malaysia, Vietnam"

**For EACH trigger found:**
```
Record:
- Category (expansion/capex/contract/hiring/M&A/compliance/operational)
- Specific description (what happened)
- Evidence link (URL to article/press release/LinkedIn post)
- Date observed (when it happened - YYYY-MM or YYYY)
```

### Step 5: Determine Sector

**IF not obvious from research:**
- Ask user: "What sector should I classify this company in?"
- Options: Logistics, Manufacturing, Healthcare, F&B, Technology
- Use user's answer

**IF obvious:**
- Assign based on business description

### Step 6: Ask User for Priority

**Based on user-parameters.md criteria:**
- New to bank + S$40-100M size range = suggests high priority
- Media company = suggests low priority

**Ask user:**
```
"Based on triggers found, I suggest: [high/medium/low] priority
(Criteria: new to bank + S$40-100M size = high, media = low)

What priority should I assign? (high/medium/low)"
```

**Use user's answer** (don't auto-assign)

### Step 7: Report Findings

**Format:**
```
[Company Name] - Research Complete

✓ Company verified
- Website: [URL]
- LinkedIn: [URL]
- Sector: [sector] - [industry]

Triggers Found: [N]
1. [Category] - [Description] ([Date])
   Evidence: [Link]
2. [Category] - [Description] ([Date])
   Evidence: [Link]
...

Priority: [user's choice] (based on: [reasoning])
Exclusions: Passed all checks

Add [Company] to candidates?
```

### Step 8: If User Approves, Add to candidates.csv

**Generate candidate_id:**
- Read existing candidates.csv
- Find highest CAND### number
- Increment by 1 (e.g., if last is CAND005, use CAND006)
- If empty file, use CAND001

**Add row:**
```csv
candidate_id,company_name,source,initial_trigger,date_added,status,drop_reason
CAND###,[company name],user scan,[top trigger description],2025-12-30,pending,
```
^ **VALIDATION:** Must have exactly 6 commas (7 fields total) - drop_reason is empty but comma still required

**Report:**
```
✓ [Company] added to candidates.csv (CAND###)
Status: pending (needs verification)

Next step: Verify this candidate to move to companies.csv?
```

**DO NOT commit** - just update CSV and report

---

## MODE B: Broad Search

### Step 1: Parse Criteria

**Extract from user's request:**
- **Sector:** logistics / manufacturing / healthcare / F&B / technology
- **Trigger type:** expansion / capex / contract / hiring / M&A (optional)
- **Count:** how many companies (default: 10)

**Examples:**
- "Find 10 logistics companies with expansion triggers"
  → sector=logistics, trigger_type=expansion, count=10

- "Find manufacturing companies"
  → sector=manufacturing, trigger_type=any, count=10 (default)

**Tell user upfront:**
```
"Searching for [count] [sector] companies [with trigger_type triggers]..."
```

### Step 2: Search deep_research_leads.md FIRST

**Read:** /reference/deep_research_leads.md

**Parse the markdown tables:**
- Find section for target sector (e.g., "## SECTOR 2: LOGISTICS, SUPPLY CHAIN & TRADE")
- Extract companies from tables
- For each company, extract:
  - Company name
  - Sector
  - Triggers from "Growth Signals (Last 18 Months)" column
  - Banking needs
  - Priority/confidence

**Apply filters:**
- Sector matches (if specified)
- Trigger type matches (if specified)
- Apply exclusions from user-parameters.md (check notes column for MNC mentions)

**Count matches found**

### Step 3: Supplement with Web Search (if needed)

**IF matches from research doc >= count:**
- Use only research doc results
- SKIP web search

**IF matches from research doc < count:**
- Need to supplement with web search
- Calculate: need [count - matches_found] more companies

**Web search query:**
```
"[sector] Singapore [trigger_type] 2024 2025"
Example: "logistics Singapore expansion 2024 2025"
```

**From search results:**
- Extract company names (look for "Pte Ltd", "Private Limited")
- For each company name:
  - Quick existence check (does website or LinkedIn exist?)
  - Quick trigger check (does it have the requested trigger type?)
  - Apply exclusions (MNC, public DBS)
  - If passes → add to candidate list

**IMPORTANT:**
- Check against existing companies.csv and candidates.csv
- SKIP companies already in system (avoid duplicates)

### Step 4: Combine Results

**Merge:**
- Companies from deep_research_leads.md
- Companies from web search (if any)

**Remove duplicates** (same company name)

**Limit to requested count** (or slightly more if many good matches)

### Step 5: Report Findings

**Format:**
```
Search complete: Found [N] [sector] companies [with trigger_type triggers]

Results:
1. [Company Name] (source: research doc / web)
   - Triggers: [list]
   - Priority suggestion: [based on triggers]

2. [Company Name] (source: research doc / web)
   - Triggers: [list]
   - Priority suggestion: [based on triggers]

...

Add all [N] companies to candidates? (yes/all/select/no)
```

### Step 6: If User Approves

**Ask about priority for batch:**
```
"What priority for these companies?
- All high
- All medium
- All low
- Ask me for each one"
```

**IF user chooses "Ask me for each one":**
- Go through list, ask priority for each

**IF user chooses batch priority:**
- Apply same priority to all

**For each approved company:**
- Generate candidate_id (CAND### sequential)
- Add row to candidates.csv:
```csv
CAND###,[company name],[source (research doc / web search)],[top trigger],2025-12-30,pending,
```
^ **VALIDATION:** Must have exactly 6 commas (7 fields total)

**Report:**
```
✓ [N] companies added to candidates.csv
- CAND### to CAND###

Status: All pending (need verification)

Next step: Verify these candidates to move to companies.csv?
```

**DO NOT commit** - just update CSV and report

---

## Error Handling

**IF company not found (Mode A):**
```
"Could not verify [company]. Sources checked:
- Google search: no official website
- LinkedIn: no company page
- News search: no credible mentions

This might mean:
- Company name is spelled differently
- Company is very small / informal
- Company may not exist

Do you have more information (website, LinkedIn, alternate name)?"
```

**IF no triggers found (Mode A):**
```
"Company verified but no recent triggers found.

[Company] exists (website: [URL]) but no significant news/expansion/hiring signals in the last 18 months.

This might mean:
- Company is stable (not growing)
- Information is sparse (not much public news)
- Triggers exist but not publicly announced

Priority suggestion: Low

Add to candidates anyway? (yes/no)"
```

**IF broad search finds 0 results:**
```
"Search found 0 companies matching criteria.

Checked:
- deep_research_leads.md: [N] [sector] companies, [M] excluded
- Web search: no additional matches found

Suggestions:
- Broaden criteria (remove trigger type filter)
- Try different sector
- Reduce count (find 5 instead of 20)

Try again with different criteria?"
```

**IF all broad search results excluded:**
```
"Found [N] companies but all excluded:
- [X] MNC subsidiaries
- [Y] Public DBS mentions
- [Z] Holdco >S$100M

No companies passed filters. Try different sector or criteria?"
```

---

## Important Notes

**DO NOT auto-commit:**
- Skills update CSVs only
- User will trigger commits separately with "commit this" command
- Just report what was added

**Check for uncommitted changes:**
- IF candidates.csv has uncommitted changes AND user starts a new scan
- Gently remind: "You have [N] uncommitted candidates. Commit before adding more? (yes/no)"

**Priority assignment:**
- NEVER auto-assign priority
- Always ask user based on user-parameters.md criteria
- User makes final decision

**Evidence links:**
- Try to capture for every trigger
- If no link available, note it but still record trigger
- Evidence makes triggers defensible (MD can verify)

**Sector classification:**
- Use target sectors from user-parameters.md
- If company doesn't fit any sector clearly, ask user

**Deep research leads parsing:**
- Parse markdown tables carefully (company name is in first column)
- Triggers are in "Growth Signals" column (may be comma-separated)
- Banking needs are in "Banking Needs" column

**Duplicate detection:**
- Always check companies.csv and candidates.csv before adding
- Ask user if similar name found: "Is this the same as [existing company]?"

---

## Next Step Suggestions

**After Mode A (specific scan):**
```
"Next steps:
- Verify this candidate: 'Verify all pending candidates'
- OR scan more companies: 'Scan [another company]'
- OR commit: 'Commit this data'
```

**After Mode B (broad scan):**
```
"Next steps:
- Verify all [N] candidates: 'Verify all pending candidates'
- OR verify by sector: 'Verify [sector] candidates'
- OR commit: 'Commit the new candidates'
```

---

You are now ready to help the user scan and validate companies for their SME banking pipeline.
