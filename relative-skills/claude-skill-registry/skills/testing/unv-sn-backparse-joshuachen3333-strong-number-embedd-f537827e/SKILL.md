---
name: unv-sn-backparse
description: Parses Chinese Union Version (UNV) biblical text with Strong's Numbers into structured semantic groups according to SPECIFICATION_v1.8.md. Includes automatic generic compound detection supporting all types of compounds (מִן, לִפְנֵי, etc.). Use when the user requests parsing UNV+SN verses, batch processing biblical text, or analyzing Strong's number groupings.
allowed-tools: Read, Write, Bash, Grep, Glob
---

# UNV+SN Backparse Skill (Specification v1.8)

This skill parses Chinese Union Version (UNV) biblical text with Strong's Numbers into structured semantic groups according to SPECIFICATION_v1.8.md.

**v1.7 Feature**: Automatic compound preposition detection - resolves 94% of qb_qp_mismatch errors by detecting מִן (04480) compounds directly from qp.php wform field.

**v1.7.2 Enhancement**: Multi-token compound detection - automatically skips 900x prefixes to detect complex compounds like `<04480><09001><06440>` (מִלִּפְנֵי).

**v1.8 Enhancement**: Generic compound detection - supports all types of compound prepositions, not just מִן. Detects לִפְנֵי (`<09001><06440>`) and other 900x-starting compounds by checking both wform and remark fields in qp.php.

## When to Use This Skill

Activate this skill when the user:
- Requests parsing of specific biblical verses (e.g., "parse Genesis 1:1", "parse all verses in Exodus 2")
- Wants to batch process a range of verses
- Needs to analyze Strong's number groupings in UNV text
- Asks about the parsing results or output format
- Requests verification of parsed output

## Core Architecture

The system uses a three-stage pipeline:

1. **Data Retrieval** (`fetch_text.sh`) - Fetches from FHL API endpoints
2. **Parsing** (`parse_verse_v1_8.py` via `run_parser_temp.py`) - Transforms raw data into structured groups
   - v1.7: Automatically detects compound prepositions from qp.php wform
   - v1.8: Generic detection for all compound types
3. **Output Generation** - Saves to `output/{Book}/{Chapter}/{verse}` (text format)

## Parsing Workflow

### Single Verse Parsing

```bash
# Parse a single verse (e.g., Genesis 1:1)
python run_parser_temp.py 1 1

# View output without writing to disk
python run_parser_temp.py --no-write 1 1
```

### Batch Parsing

Follow the Batch_Parsing_SOP.md workflow:

1. **Create Output Directories**
   ```bash
   mkdir -p output/{Book}/{Chapter}/
   ```

2. **Determine Verse Range**
   - If only book is provided, automatically determine starting point
   - For existing book: continue from last processed verse
   - For new book: start from chapter 1, verse 1

3. **Iterate and Process Each Verse**
   ```bash
   for verse in {START..END}; do
       python run_parser_temp.py {chapter} $verse
   done
   ```

4. **Handle Uncertainty**
   - Files with ambiguity are named `{verse}_uncertain`
   - Append `--- UNCERTAINTY NOTES ---` section describing issues

5. **Verification**
   - Check all output files were created
   - Verify no unexpected `_uncertain` files
   - Spot-check sample outputs for correctness

## Output Format (UNV_SN_Output_Format.md)

Each parsed verse contains three sections:

### I. Parsed and Formatted Text Section
Traditional Chinese table format with:
- Individual Strong's numbers: `<NNNN> — [詞性]「[中文意義]」`
- With morphology: `<NNNN>(8xxx) — [詞性]「[中文意義]」 *N`
- Grouped numbers: `<NNNN><MMMM> — [詞性]「[中文意義]」`

### II. Raw UNV+SN Source Text Section
Original `bible_text` with WH/WTH/WAH prefixes preserved

### III. Morphology Notes Section
Detailed grammatical explanations: `*N: [詳細描述]`

## Key Parsing Rules (SPECIFICATION_v1.8.md)

### v1.8 Generic Compound Preposition Detection

All compound prepositions are now detected automatically, not just מִן (04480).

### v1.7.2 Multi-Token Compound Detection

**Automatic Detection from qp.php (v1.7.2 Enhanced)**:
- When `<04480>` (מִן) appears in qb.php but not in qp.php, parser checks the next core token's qp.php record
- **v1.7.2**: Automatically skips intervening 900x prefixes to find the core token
- If core token's `wform` contains "介系詞 מִן +" pattern, all involved tokens are merged into compound preposition
- Supports multi-token compounds like `<04480><09001><06440>` (מִלִּפְנֵי)
- No dictionary file needed - information extracted directly from qp.php wform field

**Output Format**:
```
<04480><05921> — 複合介系詞 מֵעַל「在…上面、在旁邊、關於、敵對、攻擊」
[註]: 介系詞 מִן + 介系詞 עַל
```

**Common Compounds**:
- `<04480><05921>` → מֵעַל "from above" (מִן compound)
- `<04480><08478>` → מִתַּחַת "from under" (מִן compound)
- `<09001><06440>` → לִפְנֵי "before" (v1.8 new: 900x compound)
- `<04480><09001><06440>` → מִלִּפְנֵי "from before" (v1.7.2: multi-token)

**Impact**:
- v1.7: Resolves ~1,097 qb_qp_mismatch errors (94% of מִן-related errors)
- v1.8: Additionally resolves לִפְנֵי and other 900x-starting compounds

### Token Classification

Three distinct token types with non-overlapping ranges:

1. **Core (Strong's)**: `<dddd>` or `{<dddd>}` - Numbers 1-8999 (excluding 8xxx, 09xxx)
2. **Morphology (8xxx)**: `(**8ddd)`, `{8ddd}` - 4-digit codes 8000-8999, verbal stems and tenses
3. **Prefixes (900x)**: `<09ddd>` - **5-digit codes 09000-09999 only**, inseparable particles (ל־, ב־, ה־, etc.)
   - **IMPORTANT**: 4-digit numbers like `<0914>` are NOT prefixes (must be 5 digits starting with 09)

### Normalization (§3.1)

MUST perform before parsing:
1. Remove `WH/WTH/WAH` internal prefixes
2. Convert `<WTH8xxx>` to `(**8xxx)` (morphology codes)
3. Preserve `<09ddd>` as 900x prefixes
4. Recognize `{<dddd>}` as implicit core, `{8xxx}` as implicit morph

### Grouping Rules (§3.3)

**Scan Direction**: Left-to-right, ignoring punctuation/whitespace

1. **Prefix Attachment**: 900x codes enter `prefix_buffer`, skip over `{<...>}` and `{8xxx}`, attach to next core token

2. **Morphology Attachment**: Always left-attach to most recent core group

3. **Brace Preposition Decision Tree** (for `{<PREP>}` where PREP in `["05921","04480","0413","00996"]`):
   - **Exception 1 (Highest Priority)**: If `qp.wform` shows pronoun suffix OR infinitive complement → **left-attach to verb** (`post_brace`)
   - **Exception 2**: `{<0853>}` (object marker אֵת) → **always right-attach to noun** (`pre_brace`)
   - **General Case**: If right-side token (skipping 900x) is noun → **right-attach** (`pre_brace`); else independent group with warning

4. **Construct Linker** (optional v1.2-B): Link construct state nouns to following nouns using `construct_of`

## Configuration Profile (§4.1)

Hardcoded in `parse_verse_v1_7.py`:

```python
PROFILE = {
    "brace_preps": ["05921", "04480", "0413", "00996"],  # עַל, מִן, אֶל, בֵּין
    "object_marker": "0853",                              # אֵת
    "ignored_codes": ["09015"],                           # Paragraph markers

    # v1.7 new configuration
    "detect_compounds_from_qp": True,      # Detect compounds from qp.php wform
    "merge_prep_plus_prep": True,          # Merge prep+prep compounds
    "merge_prep_plus_noun": False,         # Optional: merge prep+noun
}
```

## Data Sources

**FHL API** (bible.fhl.net):
- `qb.php`: UNV text with Strong's numbers (requires Chinese book abbreviations)
- `qp.php`: Parsing/morphology data (requires English book abbreviations)

**Book Mappings**: 66 books with bidirectional lookup (Gen ↔ 創, Matt ↔ 太, etc.)

## Error Handling

### Uncertainty Detection

Mark files as `{verse}_uncertain` when:
- Strong's number from `qb.php` missing in `qp.php`
- Ambiguous brace preposition attachment
- Data inconsistencies between APIs
- Unresolvable grouping decisions

### Warning Types

Add to `warnings[]` array:
- `brace_attach_ambiguous`: Cannot determine preposition attachment
- `dangling_900x`: Prefix without core token
- `morph_without_core`: Orphaned morphology code
- `qb_qp_core_mismatch`: Data mismatch between APIs

### Issue Logging (New Feature)

The parser automatically logs issues to **eight files** in `output/`:

1. **strong_number_from_qb.php_not_found_in_qp.php.txt** (NEW in v1.8.1)
   - Dedicated log for Strong's number mismatches between qb.php and qp.php
   - These are numbers that appear in UNV text but have no corresponding qp.php morphology record
   - Includes KJV cross-reference to help determine if issue is UNV-specific or broader
   - Example: `Strong's number <03212> from qb.php not found in qp.php records. | KJV also uses <03212>`
   - **Important**: This separates the most common issue type (347 entries in Gen+Exod) from other uncertain cases

2. **dangling_prefixes.txt** (NEW in v1.8.1)
   - **Dedicated log for 900x prefix translation artifacts** (74 cases in Gen+Exod)
   - These are FHL data encoding artifacts where Chinese translation adds prepositions not present as independent Strong's numbers in Hebrew
   - **Not parser errors** - correctly identified data quality issues
   - See `dangling_prefixes.md` for comprehensive analysis
   - Example: `[2025-11-25] Gen 3:16 | dangling_p900x | 900x prefix <09002> had no following Strong's number to attach to.`

3. **dangling_brace_preps.txt** (NEW in v1.8.2)
   - **Dedicated log for brace preposition translation artifacts** (12 cases in Gen+Exod)
   - Implicit prepositions `{<0413>}`, `{<05921>}`, `{<04480>}` at syntactic boundaries without suitable attachment points
   - Similar to dangling_prefixes but for brace prepositions
   - **Not parser errors** - FHL data encoding where Chinese translation simplifies original syntax
   - See `dangling_brace_preps.md` for comprehensive analysis
   - Example: `[2025-11-25] Gen 19:5 | dangling_brace_prep | Brace preposition <0413> had no suitable attachment point.`

4. **dangling_object_markers.txt** (NEW in v1.8.3)
   - **Dedicated log for object marker translation artifacts** (19 cases in Gen+Exod)
   - Implicit object markers `{<0853>}` (אֵת) in sentence-final, appositive, or coordinated object structures
   - Hebrew uses explicit את to mark definite direct objects, Chinese omits or fuses into verbs
   - **Not parser errors** - FHL data encoding of translation-source structural differences
   - See `dangling_object_markers.md` for comprehensive analysis
   - Example: `[2025-11-25] Gen 22:12 | dangling_object_marker | Object marker <0853> had no suitable noun to attach to.`

5. **uncertain_or_expandable_issues.txt**
   - Issues that cannot be resolved with confidence (excluding qb_qp_mismatch, dangling_p900x, dangling_brace_prep, and dangling_object_marker)
   - Cases requiring spec expansion or manual review
   - Logged issue types: `brace_attach_ambiguous`, other `dangling_*` types
   - **v1.8.3 changes**: No longer contains `dangling_object_marker` (moved to dedicated file) - now empty or near-empty

6. **compatible_but_notable_issues.txt**
   - Successfully parsed cases worth special attention
   - Edge cases, unusual constructions, multiple valid interpretations
   - Helps identify patterns for quality assurance and future spec refinements

7. **compound_prep_plus_noun.txt** (NEW in v1.7)
   - Prep+noun compounds detected but not merged (per `merge_prep_plus_noun: False` config)
   - FHL data encoding artifacts where qb.php splits מִן but qp.php shows compound
   - These are NOT parsing errors - they reflect intentional design choice
   - Example: `<04480><03605>` = מִכָּל "from all" (מִן + כֹּל)
   - **v1.7.1 fix**: Correctly filters these from `uncertain_or_expandable_issues.txt` to avoid duplicate logging

8. **qp_data_type_errors.txt** (NEW in v1.8.4)
   - **Dedicated log for qp.php data type inconsistencies**
   - Edge cases where qp.php returns unexpected data types (e.g., `sn` field as list instead of string)
   - Parser now handles these gracefully instead of crashing
   - Example: `[2025-11-26] Gen 2:16 | qp_sn_is_list | qp.php 'sn' field is list instead of string: ['01234', '05678']`

**Log Format**: `[timestamp] verse_ref | issue_type | description`

**Example Entries**:
```
[2025-11-25 01:57:42] Gen 3:14 | qb_qp_mismatch | Strong's number <03212> from qb.php not found in qp.php records. | KJV also uses <03212>
[2025-11-24 23:40:07] Gen 2:2 | prep_noun_compound | Prep+noun compound detected: <04480><03605> = מִכָּל (介系詞 מִן + 名詞，單陽附屬形) - not merged per config
[2025-11-25 01:50:43] Gen 3:16 | dangling_p900x | 900x prefix <09002> had no following Strong's number to attach to.
```

## Important User Presentation Rules

**CRITICAL**: When showing parsed verse results to the user:

1. **Present all three sections in order** (Parsed Text → Raw Source → Morphology Notes)
2. **Display sections as-is** with no inserted commentary
3. **After all three sections**, you MAY add English explanations if helpful
4. **DO NOT** insert English translations or bullet points within the sections
5. **DO NOT** add commentary between sections

## Testing Strategy

**Verified Test Cases** (SPECIFICATION_v1.8.md §7):
- Gen 1:2 - Brace preposition right-attach + construct state
- Gen 1:4 - Object marker handling with multiple `{<0853>}`
- Gen 1:5 - FHL profile mapping with inferred vs explicit prefixes
- Gen 3:5 - Verb left-attach exception for infinitive complement
- Gen 4:16 (v1.7.2) - Multi-token compound `<04480><09001><06440>` detection
- Gen 6:11 (v1.8) - לִפְנֵי compound `<09001><06440>` detection

Validate parsed output against expected groupings in spec §7.

## Common Commands

```bash
# Fetch verse data
./fetch_text.sh --engs Gen --chap 1 --sec 1

# Parse single verse
python run_parser_temp.py 1 1

# Batch parse chapter (e.g., Genesis 2, verses 1-25)
mkdir -p output/Gen/2
for verse in {1..25}; do python run_parser_temp.py 2 $verse; done

# Verify outputs
ls -1 output/Gen/2/ | wc -l
ls -1 output/Gen/2/ | grep "_uncertain"

# View sample output
cat output/Gen/2/1

# Check issue logs
tail -20 output/strong_number_from_qb.php_not_found_in_qp.php.txt
tail -20 output/uncertain_or_expandable_issues.txt
tail -20 output/compatible_but_notable_issues.txt
tail -20 output/compound_prep_plus_noun.txt

# Search for specific verse in logs
grep "Gen 3:14" output/strong_number_from_qb.php_not_found_in_qp.php.txt
grep "Gen 3:16" output/uncertain_or_expandable_issues.txt
grep "Gen 1:2" output/compatible_but_notable_issues.txt
grep "Gen 2:2" output/compound_prep_plus_noun.txt

# Count log entries
wc -l output/strong_number_from_qb.php_not_found_in_qp.php.txt
wc -l output/uncertain_or_expandable_issues.txt
wc -l output/compound_prep_plus_noun.txt
```

## Files and Dependencies

**Core Files**:
- `SPECIFICATION_v1.8.md` - Authoritative parsing rules (standalone, includes all previous versions)
- `Batch_Parsing_SOP.md` - Batch processing workflow
- `UNV_SN_Output_Format_Gen_1_1.md` - Output format specification
- `fetch_text.sh` - API wrapper script
- `parse_verse_v1_8.py` - Current parser (outputs text format)
- `run_parser_temp.py` - Batch orchestrator

**Dependencies**: `curl`, `jq`, Python 3

## Step-by-Step Execution Guide

When user requests parsing:

1. **Acknowledge Request**: Confirm book, chapter, verse range
2. **Create TodoList**: Track directory creation, parsing, verification
3. **Create Directories**: `mkdir -p output/{Book}/{Chapter}/`
4. **Execute Parsing**: Run appropriate batch command or single verse
5. **Verify Results**: Check file count, look for `_uncertain` files
6. **Show Samples**: Display 1-2 sample outputs for user review
7. **Report Completion**: Confirm range processed and any issues found

## Example Execution

```
User: "Parse Genesis chapter 3"

1. Create todo list with 4 items
2. mkdir -p output/Gen/3
3. Determine verse count (24 verses in Genesis 3)
4. Run: for verse in {1..24}; do python run_parser_temp.py 3 $verse; done
5. Verify: ls -1 output/Gen/3/ | wc -l (should show 24)
6. Check: ls -1 output/Gen/3/ | grep "_uncertain" (ideally 0)
7. Display: Show sample parsed output from verse 1 and 16
8. Report: "Successfully parsed Genesis 3:1-24 (24 verses, 0 uncertain)"
```

## Notes

- Parser is in **partial implementation** status; full v1.7.2 features may need enhancement
- Always consult SPECIFICATION_v1.7.2.md for authoritative rules
- Output location: `output/{Book}/{Chapter}/{verse}` or `{verse}_uncertain`
- This is a subdirectory of the larger Strong's Number Embedding Project
