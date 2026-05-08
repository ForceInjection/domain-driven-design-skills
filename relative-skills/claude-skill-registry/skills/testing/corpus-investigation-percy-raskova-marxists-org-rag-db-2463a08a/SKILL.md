---
name: corpus-investigation
description: Systematically investigate large corpus sections (100GB+) using stratified sampling, pattern recognition, and computational verification. Produces comprehensive section analyses with metadata schemas, chunking strategies, and RAG integration recommendations. Use when analyzing large datasets, investigating archive structures, studying corpus organization, conducting investigation and study tasks, or documenting dataset characteristics for RAG pipeline design.
allowed-tools: Read, Grep, Glob, Bash, Write
---

# Corpus Investigation Skill

**Purpose**: Enable systematic, reproducible, token-efficient investigation of large corpus sections to inform RAG architecture design.

**Methodology**: Based on the proven investigation framework used to analyze the 121GB Marxists Internet Archive, achieving 95% token reduction through computational verification and stratified sampling.

---

## When to Use This Skill

Activate this skill when the user requests:

- "investigate corpus section"
- "analyze archive structure"
- "study dataset organization"
- "document corpus characteristics"
- "investigation and study" (Maoist reference to systematic research)
- Analysis of large file collections (>1GB)
- Metadata schema extraction from document sets
- Chunking strategy recommendations for RAG
- Dataset preparation for knowledge base ingestion

---

## Core Investigation Framework

Follow this **5-phase methodology** for all corpus investigations:

### Phase 1: Reconnaissance (10% of effort)

**Goal**: Understand section scope without deep reading

**Tasks**:

1. **Read the index page** for the section (if exists)
2. **Run directory structure analysis**:
   ```bash
   cd /path/to/section

   # Get directory tree with sizes (3 levels deep)
   find . -type d -maxdepth 3 | head -50
   du -h --max-depth=2 | sort -h | tail -20

   # Count files by type
   find . -type f -name "*.html" | wc -l
   find . -type f -name "*.htm" | wc -l
   find . -type f -name "*.pdf" | wc -l

   # Get size distribution by subdirectory
   du -sh */ 2>/dev/null | sort -h
   ```

3. **Identify subsections** and document hierarchy
4. **Calculate total size** and file counts

**Output**: Section overview with statistics in markdown format

---

### Phase 2: Stratified Sampling (40% of effort)

**Goal**: Sample representative files across key dimensions

**Stratification Dimensions**:

1. **Size-based**: Large (>1GB), medium (100MB-1GB), small (<100MB) subsections
2. **Temporal**: Early, mid, late periods (if time-based organization)
3. **Type-based**: HTML vs PDF, different file naming patterns
4. **Depth-based**: Index pages, category pages, content pages

**Sampling Strategy**:

```bash
# Sample large subsections (>1GB) - prioritize
# Read 10-15 files from largest sections

# Sample medium subsections (100MB-1GB)
# Read 5-10 files from mid-size sections

# Sample small subsections (<100MB)
# Read 3-5 files total from small sections

# Sample different time periods (if applicable)
# Find files with year patterns
find /path/to/section -name "*19[0-9][0-9]*" -o -name "*20[0-9][0-9]*" | head -20

# Sample different file depths
find /path/to/section -name "index.htm*" | head -5  # Index pages
find /path/to/section -type f -name "*.htm*" | shuf | head -10  # Random content
```

**Target Sample Size**: 15-25 files total across all dimensions

**For each sampled file**:
- Extract structure (headings, meta tags, first paragraph)
- Do NOT read full content unless necessary
- Document patterns observed

**Token Optimization**: Extract structure only, not full content

```python
# When reading HTML, extract structure not content:
# - DOCTYPE and charset
# - All meta tags (name and content)
# - All heading tags (h1-h6)
# - CSS classes used
# - First paragraph only
# - Link patterns (internal, external, anchors)
# - Total word count estimate
```

---

### Phase 3: Pattern Verification (30% of effort)

**Goal**: Verify that patterns observed in samples hold across entire section

**Use computational tools (grep/find), NOT exhaustive reading**

**Verification Commands**:

```bash
# 1. Meta tag consistency
grep -r '<meta name="author"' /path/to/section | wc -l
grep -r '<meta name="description"' /path/to/section | wc -l
grep -roh '<meta name="[^"]*"' /path/to/section | sed 's/<meta name="\([^"]*\)".*/\1/' | sort | uniq -c | sort -rn

# 2. CSS class usage patterns
grep -roh 'class="[^"]*"' /path/to/section | sort | uniq -c | sort -rn | head -30

# 3. Link patterns
grep -roh 'href="[^"]*"' /path/to/section | head -100
grep -roh 'href="#[^"]*"' /path/to/section | sort | uniq -c | sort -rn | head -20

# 4. File naming conventions
find /path/to/section -type f -name "*.htm*" | sed 's/.*\///' | sort | uniq -c | sort -rn | head -30

# 5. Year/date patterns in filenames
find /path/to/section -name "*.htm*" -o -name "*.pdf" | grep -oE '(19|20)[0-9]{2}' | sort | uniq -c

# 6. DOCTYPE declarations
grep -roh '<!DOCTYPE[^>]*>' /path/to/section | sort | uniq -c

# 7. Character encoding
grep -roh 'charset=[^"]*' /path/to/section | sort | uniq -c | sort -rn
```

**Document Confidence Levels**:
- 100% = Universal pattern (all files)
- 90-99% = Standard pattern (rare exceptions)
- 75-89% = Common pattern (notable exceptions)
- 50-74% = Frequent pattern (not standard)
- <50% = Occasional pattern

---

### Phase 4: Edge Case Analysis (10% of effort)

**Goal**: Identify exceptions and unusual patterns

**Sample These Outliers**:

```bash
# 1. Largest files (top 5)
find /path/to/section -type f -name "*.htm*" -o -name "*.pdf" | xargs ls -lh | sort -k5 -hr | head -5

# 2. Smallest files (bottom 5)
find /path/to/section -type f -name "*.htm*" -o -name "*.pdf" | xargs ls -lh | sort -k5 -h | head -5

# 3. Files with unusual names (no standard patterns)
find /path/to/section -type f -name "*.htm*" | grep -v 'index\|chapter\|ch[0-9]\|[0-9]\{4\}'

# 4. Deepest nested files
find /path/to/section -type f -name "*.htm*" | awk '{print gsub(/\//,"/"), $0}' | sort -rn | head -10

# 5. Files without meta tags (if meta tags expected)
for file in $(find /path/to/section -name "*.htm*" | head -100); do
  grep -q '<meta name' "$file" || echo "$file"
done
```

**Read 3-5 edge case files** to understand why they differ

---

### Phase 5: Synthesis (10% of effort)

**Goal**: Compile findings into actionable specification

**Produce a Section Analysis Document** following this structure:

```markdown
# {Section Name} Analysis

**Section Path**: /absolute/path/to/section/
**Total Size**: {X}GB
**File Count**: {N} HTML, {M} PDFs
**Investigation Date**: YYYY-MM-DD

---

## 1. Executive Summary

[2-3 paragraph overview: purpose, size, key findings]

## 2. Directory Structure

[Hierarchical organization with sizes]

## 3. File Type Analysis

### HTML Files
- Count: {N}
- Naming conventions: [patterns]
- Size range: {min} - {max}

### PDF Files
- Count: {M}
- OCR quality: [assessed from samples]
- Purpose: [scanned books/periodicals/etc]

## 4. HTML Structure Patterns

### DOCTYPE and Encoding
[Common declarations]

### Meta Tag Schema
| Meta Tag | Occurrence % | Example |
|----------|--------------|---------|
| author   | 95%          | "Marx"  |
| ...      | ...          | ...     |

### Semantic CSS Classes
[Classes with semantic meaning]

## 5. Metadata Extraction Schema

[Define 5-layer metadata schema]

**Layer 1: File System**
- section, subsection, author (from path)
- year, chapter (from filename)

**Layer 2: HTML Meta Tags**
- title, author, description, keywords

**Layer 3: Breadcrumb Navigation**
- breadcrumb trail, category path

**Layer 4: Semantic CSS Classes**
- curator context, provenance, annotations

**Layer 5: Content-Derived**
- word_count, has_footnotes, has_images, reading_time

**Example Metadata Record**:
```json
{
  "section": "...",
  "author": "...",
  "title": "...",
  "year": 1867,
  "word_count": 8500,
  ...
}
```

## 6. Linking Architecture

- Internal link patterns
- Cross-section references
- Anchor/footnote system
- Link topology (hierarchical/cross-reference/citation)

## 7. Unique Characteristics

[What makes this section different?]

## 8. Chunking Recommendations

### Recommended Chunk Boundary
[Paragraph / Section / Article / Entry]

### Rationale
[Why this boundary is optimal for RAG]

### Chunk Size Estimates
[Expected token counts]

### Hierarchical Context Preservation
[How to preserve work → chapter → section hierarchy]

## 9. RAG Integration Strategy

- Processing pipeline steps
- Metadata enrichment approach
- Indexing strategy (vector DB collections, filters)
- Expected query patterns
- Cross-section integration

## 10. Edge Cases and Exceptions

- Unusual files
- Missing metadata
- Broken links
- Encoding issues

## 11. Processing Risks and Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| ... | ... | ... | ... |

## 12. Sample Files Analyzed

[List all files read during investigation]

1. /path/to/file1.htm - Index page, navigation structure
2. /path/to/file2.htm - Typical content, has footnotes
...

## 13. Pattern Verification Commands

[Document exact bash commands used]

```bash
# Example verification commands
grep -r '<meta name="author"' /path | wc -l
```

## 14. Recommendations

- Priority: HIGH / MEDIUM / LOW for RAG inclusion
- Processing complexity: SIMPLE / MODERATE / COMPLEX
- Special requirements: OCR / translation / cleanup needed
- Integration dependencies: [other sections required first]

## 15. Open Questions

1. [Question requiring user decision]
2. [Question needing further investigation]
```

---

## Token Efficiency Tactics

**CRITICAL**: Use these tactics to achieve 95% token reduction

### 1. Computational Tools Over Reading

**DON'T**: Read 100 files to find patterns (500k tokens)
**DO**: Use grep to extract patterns + read 5 samples (25k tokens)

### 2. Strategic Sampling Over Exhaustive Coverage

**DON'T**: Read every author's archive (1M+ tokens)
**DO**: Read 3 authors (large/medium/small) + verify with find (50k tokens)

### 3. Extract Structure, Not Content

**DON'T**: Read entire documents
**DO**: Extract headings, meta tags, first paragraph only

**Implementation**:
- Read only `<head>` section for meta tags
- Extract only `<h1>-<h6>` tags for structure
- Read only first `<p>` for content sample
- Count links/images, don't read them

### 4. Aggregate Statistics Over Individual Analysis

**DON'T**: Describe each file individually
**DO**: Compute aggregate statistics and describe patterns

**Example**:
```
Instead of:
  "file1.htm has 3 meta tags"
  "file2.htm has 3 meta tags"
  "file3.htm has 2 meta tags"

Write:
  "95% of files have 3 meta tags (author, description, classification)"
  "5% are missing description tag"
```

### 5. Reference Examples, Don't Reproduce

**DON'T**: Include full HTML of 10 example files (50k tokens)
**DO**: Include 1-2 representative examples + reference paths (5k tokens)

### 6. Use Shell Commands for Verification

**Always prefer**:
- `grep -r` for pattern extraction
- `find` for file discovery
- `wc -l` for counting
- `sort | uniq -c` for frequency analysis
- `du -sh` for size calculations

**Over**:
- Reading files individually
- Manual counting
- Exhaustive sampling

---

## Metadata Extraction Protocol

**Extract metadata in 5 layers** for comprehensive documentation:

### Layer 1: File System Metadata

Extract from file paths using regex:

```python
# Example patterns to extract:
# - Section from /path/{section}/...
# - Author from /archive/{author}/...
# - Year from .../{year}/... or filename
# - Work slug from path structure
# - Chapter from ch##.htm filenames
```

### Layer 2: HTML Meta Tags

Parse `<meta>` tags in `<head>`:

```bash
# Extract all meta tag names
grep -roh '<meta name="[^"]*"' /path | sed 's/<meta name="\([^"]*\)".*/\1/' | sort | uniq -c

# Extract specific meta tag
grep -roh '<meta name="author" content="[^"]*"' /path | head -20
```

### Layer 3: Breadcrumb Navigation

Extract breadcrumb trails (usually `<p class="breadcrumb">` or similar):

```bash
# Find breadcrumb patterns
grep -r 'class="breadcrumb"' /path | head -10
grep -r 'class="path"' /path | head -10
grep -r '<nav' /path | head -10
```

### Layer 4: Semantic CSS Classes

Identify CSS classes with semantic meaning:

```bash
# Extract all CSS classes
grep -roh 'class="[^"]*"' /path | sed 's/class="\([^"]*\)".*/\1/' | tr ' ' '\n' | sort | uniq -c | sort -rn | head -30

# Common semantic classes to look for:
# - "context" (curator annotations)
# - "information" (provenance)
# - "quoteb" (block quotes)
# - "fst" (first paragraph)
# - "title" (work titles)
```

### Layer 5: Content-Derived Metadata

Calculate from document content:

- Word count (approximate: wc -w)
- Has footnotes (check for anchor links: href="#")
- Has images (check for <img> tags)
- Reading time (word_count / 250 words per minute)

---

## Sample Selection Algorithm

Use this strategy to select representative samples:

```markdown
For a section with N total files:

1. ALWAYS read top-level index.htm (if exists)

2. Identify subsections by size:
   - Large (>1GB): Sample 10-15 files
   - Medium (100MB-1GB): Sample 5-10 files
   - Small (<100MB): Sample 3-5 files total

3. Within each subsection, stratify by:
   - File type (HTML vs PDF)
   - Depth (index vs category vs content pages)
   - Time period (if applicable)

4. Use random sampling within strata:
   find /path -name "*.htm*" | shuf | head -10

5. Include edge cases:
   - Largest file
   - Smallest file
   - Unusual naming pattern
   - Deepest nested file

Target: 15-25 files total for sections <10GB
Target: 25-40 files total for sections >10GB
```

---

## Verification Without Exhaustive Reading

**Principle**: Trust but verify

After identifying a pattern from samples, verify it holds using computational tools.

### Confidence Level Calculation

```bash
# Pattern: "All files have author meta tag"

# Count total files
total=$(find /path -name "*.htm*" | wc -l)

# Count files with pattern
with_pattern=$(grep -rl '<meta name="author"' /path | wc -l)

# Calculate percentage
echo "Coverage: $with_pattern / $total = $(( 100 * with_pattern / total ))%"
```

### Statistical Sampling for Very Large Sections

For sections >10GB:

```bash
# Get random sample of 1000 files
find /path -name "*.htm*" | shuf -n 1000 > sample_files.txt

# Check pattern in sample
while read file; do
  grep -q '<meta name="author"' "$file" && echo "1" || echo "0"
done < sample_files.txt | awk '{sum+=$1; count++} END {print "Coverage: " sum/count*100 "%"}'
```

---

## Quality Assurance Checklist

Before completing investigation, verify:

### Completeness
- [ ] Directory structure fully documented with sizes
- [ ] File counts accurate (HTML, PDF, other)
- [ ] Meta tag schema extracted (all fields identified)
- [ ] CSS class inventory complete
- [ ] Link patterns documented
- [ ] Unique characteristics identified
- [ ] Chunking strategy defined with rationale
- [ ] RAG integration approach proposed
- [ ] Edge cases documented
- [ ] Sample files listed with notes
- [ ] Verification commands included
- [ ] Confidence levels specified for patterns
- [ ] Open questions documented

### Reproducibility
- [ ] Sampling strategy documented
- [ ] Bash commands included (exact commands)
- [ ] File paths specified (actual paths, not placeholders)
- [ ] Investigation date included
- [ ] Corpus version/snapshot documented

### Token Efficiency
- [ ] Used grep/find instead of reading where applicable
- [ ] Sampled strategically (not exhaustively)
- [ ] Aggregated statistics (not individual descriptions)
- [ ] Referenced examples (not reproduced unnecessarily)
- [ ] Extracted structure only (not full content)

### Actionability
- [ ] Metadata schema is code-ready
- [ ] Chunking strategy is specific (not vague)
- [ ] Processing pipeline defined step-by-step
- [ ] Risks identified with mitigations
- [ ] Priority level assigned (HIGH/MEDIUM/LOW)

---

## Common Bash Commands Reference

### File Discovery

```bash
# Find all HTML files
find /path -type f -name "*.htm*"

# Find all PDFs
find /path -type f -name "*.pdf"

# Find files modified in last 30 days
find /path -type f -mtime -30

# Find files larger than 1MB
find /path -type f -size +1M

# Find files by depth
find /path -maxdepth 2 -type f
```

### Pattern Extraction

```bash
# Extract meta tag names
grep -roh '<meta name="[^"]*"' /path | sed 's/<meta name="\([^"]*\)".*/\1/' | sort | uniq -c | sort -rn

# Extract CSS classes
grep -roh 'class="[^"]*"' /path | sort | uniq -c | sort -rn

# Extract link patterns
grep -roh 'href="[^"]*"' /path | head -100

# Extract year patterns
find /path -name "*.htm*" | grep -oE '(19|20)[0-9]{2}' | sort | uniq -c

# Extract DOCTYPE
grep -roh '<!DOCTYPE[^>]*>' /path | sort | uniq -c
```

### Statistics

```bash
# Count files by extension
find /path -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn

# Size distribution by directory
du -sh /path/*/ | sort -h

# Average file size
find /path -type f -name "*.htm*" | xargs ls -l | awk '{sum+=$5; count++} END {print sum/count/1024 " KB average"}'

# Word count distribution
find /path -name "*.htm*" | head -100 | xargs wc -w | sort -n
```

### Sampling

```bash
# Random sample of 10 files
find /path -name "*.htm*" | shuf | head -10

# Stratified sample (first, middle, last)
files=$(find /path -name "*.htm*" | sort)
total=$(echo "$files" | wc -l)
echo "$files" | sed -n "1p; $(($total/2))p; ${total}p"

# Sample by size (smallest, median, largest)
find /path -name "*.htm*" | xargs ls -lh | sort -k5 -h | awk 'NR==1 || NR==total/2 || NR==total'
```

---

## Investigation Tips

### Do's

1. **Start with reconnaissance** - Understand scope before sampling
2. **Use stratified sampling** - Cover all dimensions (size, time, type, depth)
3. **Verify patterns computationally** - grep/find are your friends
4. **Document confidence levels** - Specify % of files matching patterns
5. **Extract structure, not content** - Save tokens
6. **Reference file paths** - Use actual paths, enable reproduction
7. **Include bash commands** - Document what you ran
8. **Identify edge cases** - Sample outliers explicitly
9. **Be specific in recommendations** - "Chunk by paragraph" not "chunk appropriately"
10. **Ask clarifying questions** - If scope is unclear, ask user

### Don'ts

1. **Don't read exhaustively** - Sample strategically instead
2. **Don't include full HTML** - Extract structure only
3. **Don't describe individual files** - Aggregate statistics instead
4. **Don't make assumptions** - Verify patterns with grep/find
5. **Don't skip edge cases** - Outliers reveal important variations
6. **Don't use vague language** - Be specific and actionable
7. **Don't forget verification** - Every pattern needs confidence level
8. **Don't ignore errors** - Document broken files, encoding issues
9. **Don't reinvent chunking** - Use proven strategies from methodology
10. **Don't exceed token budget** - If approaching limit, increase aggregation

---

## Example Investigation Workflow

Here's a concrete example workflow:

```markdown
USER: "Investigate the /data/archive/philosophy section"

AGENT RESPONSE:

I'll systematically investigate the philosophy section using the 5-phase methodology.

## Phase 1: Reconnaissance

[Run directory structure commands]
[Document size, file counts, hierarchy]

Section overview:
- Size: 2.3GB
- Files: 1,847 HTML, 234 PDFs
- Structure: Organized by author (45 authors)
- Time span: 1840-1950 (from filenames)

## Phase 2: Stratified Sampling

[Select 20 representative files across:]
- Large authors: Hegel (400MB), Kant (300MB), Marx (250MB)
- Medium authors: Nietzsche (150MB), Spinoza (120MB)
- Small authors: Feuerbach (40MB), Stirner (30MB)

[For each sample, extract structure:]
- Meta tags: author, title, classification
- Headings: h1 (title), h2 (chapters), h3 (sections)
- CSS classes: "title", "quoteb", "context"
- First paragraph: [sample text]
- Links: Internal chapter links, footnote anchors

## Phase 3: Pattern Verification

[Run verification commands:]

```bash
# Meta tag coverage
grep -r '<meta name="author"' /data/archive/philosophy | wc -l
# Result: 1,823 / 1,847 files = 99% coverage

# CSS class distribution
grep -roh 'class="[^"]*"' /data/archive/philosophy | sort | uniq -c | sort -rn
# Result: "quoteb" (8,234), "title" (1,847), "context" (892)
```

Confidence levels:
- Author meta tag: 99% (universal)
- Title meta tag: 95% (standard)
- Classification meta tag: 78% (common)

## Phase 4: Edge Cases

[Sample outliers:]
- Largest file: hegel-phenomenology.htm (2.3MB, 450k words)
- Smallest file: stirner-intro.htm (3KB, 200 words)
- Missing meta tags: 24 files without author tag (early scans)
- Encoding issues: 12 files with mojibake (German umlauts)

## Phase 5: Synthesis

[Write complete section analysis document following template]

**Chunking Recommendation**: Section-level chunks (h3 boundaries)
- Rationale: Philosophical arguments span multiple paragraphs
- Average chunk: 800-1200 words, 1000-1500 tokens
- Preserve hierarchy: author → work → chapter → section

**RAG Integration Strategy**:
- Collection: "philosophy"
- Metadata filters: author, work_title, year, classification
- Expected queries: "What did Kant say about...", "Compare Hegel and Marx on..."

**Priority**: HIGH (core theoretical content)
**Processing Complexity**: MODERATE (encoding issues for German texts)

**Open Questions**:
1. Should German texts be translated or kept in original?
2. Include secondary literature or only primary sources?
```

---

## Reference Materials

**Full Methodology Specification**:
See `/home/user/projects/marxist-rag/docs/corpus-analysis/00-investigation-methodology-spec.md`

**Example Section Analysis**:
See `/home/user/projects/marxist-rag/docs/corpus-analysis/01-archive-section-analysis.md`

**Corpus Overview**:
See `/home/user/projects/marxist-rag/docs/corpus-analysis/00-corpus-overview.md`

---

## Success Criteria

A successful corpus investigation produces:

1. **Complete section analysis document** following the template
2. **Metadata extraction schema** ready for implementation
3. **Chunking strategy** with clear rationale
4. **RAG integration approach** with concrete steps
5. **Confidence levels** for all identified patterns
6. **Verification commands** enabling reproduction
7. **Edge case documentation** with handling recommendations
8. **Open questions** for user decision

**Token Budget**: 15,000-30,000 tokens per section investigation
**Time Estimate**: 30-60 minutes for AI agent
**Output Size**: 5,000-10,000 token specification document

---

## Investigation Principles Summary

1. **Sample strategically, verify computationally**
2. **Extract structure, not content**
3. **Document patterns, not instances**
4. **Specify confidence levels**
5. **Produce actionable specifications**

**Remember**: The goal is not to read every file, but to understand the corpus structure well enough to design an optimal RAG processing pipeline.

Use computational tools (grep, find, wc, sort, uniq) to verify patterns across thousands of files without reading them individually. This achieves 95% token reduction while maintaining investigative rigor.

---

## Notes

- This methodology was proven on the 121GB Marxists Internet Archive investigation
- Investigations following this framework are reproducible by other AI agents
- Token efficiency tactics are critical for large-scale corpus analysis
- Stratified sampling ensures representative coverage without exhaustive reading
- Computational verification provides confidence without manual checking
- Structured output enables direct implementation of RAG pipelines

**For questions or methodology improvements, see the reference documentation in `/home/user/projects/marxist-rag/docs/corpus-analysis/`**
