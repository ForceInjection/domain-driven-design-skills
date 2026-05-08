---
name: tool-ecosystem-manager
description: Manages and improves the Bible study tool creation ecosystem. Use this skill when you need to change tool creation processes, reorganize tool directories, propagate learnings across tools, or analyze common issues. This is a meta-skill for improving the tool-experimenter and tool creation workflow itself.
---

# Tool Ecosystem Manager

## Overview

This skill manages the **meta-level** of Bible study tool creation - improving the processes, guidelines, and structures that create the tools themselves. While `tool-experimenter` improves individual tools, this skill improves the entire tool creation ecosystem.

## When to Use This Skill

Use this skill when:
- User wants to reorganize tool directories or change the tool structure
- User wants to add new quality checks or validation rules to all tools
- User wants to propagate learnings from one tool to others
- User wants to analyze common issues across multiple tools
- User wants to update the TEMPLATE, REVIEW-GUIDELINES, or other foundational documents
- User wants to verify consistency across all tools
- User wants to improve the tool-experimenter skill itself

Do NOT use this skill for:
- Creating or improving a single Bible study tool (use `tool-experimenter` instead)
- Running a tool to generate data (use `bible-researcher` instead)

## Key Governing Documents

These documents control how tools are created and must be understood deeply:

### Core Process Documents
- **@.claude/skills/tool-experimenter/SKILL.md** - The skill that creates/improves individual tools
- **@bible-study-tools/TEMPLATE.md** - Template for all tool README.md files
- **@REVIEW-GUIDELINES.md** - Universal validation framework for all outputs
- **@SCHEMA.md** - YAML structure standards for all data files
- **@STANDARDIZATION.md** - Naming conventions for books, versions, languages, citations
- **@CLAUDE.md** - Project overview and core principles

### Tool-Specific Documents (per tool)
- **bible-study-tools/{tool-name}/README.md** - Tool-specific instructions
- **bible-study-tools/{tool-name}/LEARNINGS.md** - Accumulated knowledge from experiments
- **bible-study-tools/{tool-name}/experiments/** - Experimental data and revisions

## Workflow Overview

### Phase 1: Understand Request
1. Determine if this is:
   - **Process Change** (Case 1): Reorganizing, adding validation, changing structure
   - **Problem Analysis** (Case 2): Analyzing issues, propagating learnings
2. Create a git branch using gitflow syntax

### Phase 2A: Handle Process Changes (Case 1)

This is for structural changes to how tools are organized or created.

#### Step 1: Analyze Current State
1. Read all relevant governing documents
2. Identify all tools that will be affected
3. Map out dependencies and relationships
4. Create a detailed change plan

#### Step 2: Update Governing Documents
Update documents in this order:
1. **REVIEW-GUIDELINES.md** - If adding new validation criteria
2. **SCHEMA.md** - If changing data structure
3. **TEMPLATE.md** - If changing tool README template
4. **tool-experimenter/SKILL.md** - If changing the tool creation workflow

#### Step 3: Update Existing Tools
For each affected tool:
1. Update `README.md` to match new template/guidelines
2. Update `LEARNINGS.md` to reflect new standards
3. Move files if directory structure changed (when moving files git commit only the file changes so git will preserve the history)
4. Ensure all examples still work

#### Step 4: Test Changes
1. Select 2-3 representative tools
2. Call `bible-researcher` subagent for each tool on test verses
3. Verify outputs follow new guidelines
4. Iterate if needed

#### Step 5: Document Changes
1. Update version history in modified documents
2. Create a summary of what changed and why
3. Commit changes with clear message

### Phase 2B: Analyze Problems and Propagate Learnings (Case 2)

This is for identifying common issues and spreading solutions.

#### Step 1: Gather Intelligence
1. Read all `LEARNINGS.md` files from all tools
2. Read sample YAML outputs from each tool's experiments and output dir
3. Identify patterns:
   - Common problems mentioned in multiple LEARNINGS
   - Common solutions that worked well
   - Issues visible in YAML outputs (schema violations, missing citations, etc.)

#### Step 2: Categorize Issues
Organize findings by:
- **Universal issues** - Affect all tools (→ update REVIEW-GUIDELINES or TEMPLATE)
- **Category-specific** - Affect similar tools (→ document in relevant tool READMEs)
- **Tool-specific** - Already documented in that tool's LEARNINGS
- **Resolved issues** - Mark as solved in LEARNINGS so they're not worked on again

#### Step 3: Propagate Solutions
For each identified issue:

**If Universal:**
1. Update REVIEW-GUIDELINES.md with new validation check
2. Update TEMPLATE.md with guidance to prevent issue
3. Add to tool-experimenter Phase 3 evaluation criteria

**If Category-specific:**
1. Identify all tools in that category
2. Add to each tool's README in "Common Challenges and Solutions" section
3. Update LEARNINGS.md noting the solution was applied

**If Already Solved in One Tool:**
1. Extract the solution from that tool's LEARNINGS
2. Check if other tools have the same problem
3. Apply solution and update their LEARNINGS

#### Step 4: Update LEARNINGS Files
For each tool's LEARNINGS.md:
- Mark solved problems with `[SOLVED - YYYY-MM-DD]` prefix
- Add cross-references to solutions used in other tools
- Remove duplicate issues that are now documented centrally

#### Step 5: Analyze YAML Outputs
For output quality analysis:
1. Read sample YAML files from experiments
2. Check against SCHEMA.md standards
3. Verify REVIEW-GUIDELINES compliance
4. Identify patterns:
   - Missing citations
   - Schema violations
   - Fabricated data indicators
   - Incomplete word coverage
   - Generic statements

Document findings in:
- Tool-specific LEARNINGS.md for unique issues
- REVIEW-GUIDELINES.md for universal patterns

## Common Use Cases

### Use Case 1: Reorganize Tools by Type

**Example:** "Break bible-study-tools directory into subdirectories words/commentary/topics"

**Workflow:**
1. Analyze current tool types:
   ```bash
   ls -la bible-study-tools/
   ```

2. Categorize each tool:
   - words: original-language-words, test-word-meanings
   - commentary: (none yet)
   - topics: (none yet)
   - clusters: grouping-semantic-clusters

3. Create new directory structure:
   ```bash
   mkdir -p bible-study-tools/words
   mkdir -p bible-study-tools/commentary
   mkdir -p bible-study-tools/topics
   mkdir -p bible-study-tools/clusters
   ```

4. Move tools:
   ```bash
   git mv bible-study-tools/original-language-words bible-study-tools/words/
   git mv bible-study-tools/test-word-meanings bible-study-tools/words/
   git mv bible-study-tools/grouping-semantic-clusters bible-study-tools/clusters/
   ```
   Be sure to commit after you finish moving as git follows the history better when moves are isolated from any other edits.

5. Update references in:
   - tool-experimenter/SKILL.md (file paths)
   - TEMPLATE.md (if it references paths)
   - Each tool's README.md (relative paths to TEMPLATE, GUIDELINES, etc.)

6. Test with bible-researcher on 2 tools (one from each category)

7. Document change in CLAUDE.md and commit

### Use Case 2: Add Fair Use Verification to All Tools

**Example:** "Add process to verify fair use policy compliance"

**Workflow:**
1. Read plan/policy/fair-use.md to understand requirements

2. Update REVIEW-GUIDELINES.md:
   - Add fair use check to Level 1 CRITICAL validation
   - Define what constitutes compliance
   - Add examples of violations

3. Update TEMPLATE.md:
   - Add fair use section to "Research Methodology"
   - Include citation format that ensures fair use
   - Add to verification checklist

4. Update tool-experimenter/SKILL.md:
   - Add fair use verification to Phase 3 evaluation

5. For each existing tool:
   - Update README.md with fair use guidance
   - Review existing experiments for compliance
   - Update LEARNINGS.md if violations found

6. Test by running bible-researcher on 3 tools:
   - One word study tool
   - One semantic cluster tool
   - One future commentary tool

7. Verify outputs include:
   - Source-language text as primary
   - Convergence grouping for translations
   - Comparative analysis for divergence
   - No programmatic reconstruction possible

8. Document findings and commit

### Use Case 3: Propagate "Helpful Websites" Learning

**Example:** "Tool A found BibleHub concordance very useful, apply to similar tools"

**Workflow:**
1. Read tool A's LEARNINGS.md to understand what made it useful

2. Identify similar tools that would benefit:
   - Check each tool's "Purpose" in README
   - Match tools doing similar research

3. For each similar tool:
   - Read current README to see if they use this source
   - If not, add to "Required Sources" in Phase 1
   - Update LEARNINGS.md noting this was added from tool A

4. Update TEMPLATE.md:
   - Add to suggested sources section
   - Include guidance on when to use it

5. Test on each tool edited by calling bible-researcher
   - Verify the source adds value
   - Check quality of extracted data

6. Document cross-learning in each tool's LEARNINGS

### Use Case 4: Identify and Fix Common Schema Violations

**Example:** "Analyze YAML outputs for pattern errors"

**Workflow:**
1. Collect sample YAML files from all tools:
   ```bash
   find bible -name "*.yaml" -type f
   ```

2. For each file, check:
   - Verse reference format (BOOK.chapter.verse with zero-padding)
   - Inline citations present
   - No standalone translation fields
   - No `sources:` arrays in patterns
   - Word positions sequential
   - All required fields present

3. Categorize violations by frequency and tool

4. For common violations:
   - Update SCHEMA.md with clearer examples
   - Update REVIEW-GUIDELINES.md with detection patterns
   - Add to TEMPLATE.md as warnings

5. For tool-specific violations:
   - Update that tool's README with examples
   - Add to LEARNINGS.md with solution
   - Mark as `[ISSUE FOUND - YYYY-MM-DD]` for tracking

6. Re-run problematic tools:
   - Use updated README
   - Generate new YAML
   - Verify violation is fixed
   - Mark as `[SOLVED - YYYY-MM-DD]` in LEARNINGS

## Decision Framework

### When to Update Which Document

**Update REVIEW-GUIDELINES.md when:**
- Issue affects output quality universally
- New validation criterion needed
- Persona perspective missing
- Hallucination pattern discovered

**Update SCHEMA.md when:**
- Data structure needs clarification
- New field types emerging
- Inconsistent naming across tools
- Citation format issues

**Update TEMPLATE.md when:**
- Tool creation process improved
- Section organization better understood
- Examples more helpful
- Common tool patterns identified

**Update tool-experimenter/SKILL.md when:**
- Experiment workflow improved
- New phase needed
- Evaluation criteria changed
- Parallelization strategy refined

**Update individual tool README when:**
- Tool-specific process learned
- Stellar example discovered
- Source found helpful for that tool
- Schema refinement for that tool type

## Quality Checks

After any ecosystem change, verify:

### Document Consistency
- [ ] All file paths in SKILL files are correct
- [ ] Cross-references between documents are valid
- [ ] Examples match current schema
- [ ] Version numbers updated

### Tool Integrity
- [ ] All tools still in correct directories
- [ ] READMEs reference correct relative paths
- [ ] No broken links in documentation
- [ ] Git history preserved

### Validation Pipeline
- [ ] REVIEW-GUIDELINES comprehensive
- [ ] SCHEMA examples accurate
- [ ] TEMPLATE reflects best practices
- [ ] tool-experimenter workflow coherent

### Test Coverage
- [ ] At least 2 tools tested per change
- [ ] Diverse tool types represented
- [ ] Edge cases considered
- [ ] Outputs validate against guidelines

## Git Workflow

When making ecosystem changes:

1. **Branch Naming:**
   - Process changes: `feat/process-{description}`
   - Guidelines updates: `docs/guidelines-{description}`
   - Directory restructure: `refactor/structure-{description}`

2. **Commit Strategy:**
   - Group related changes into a single commit (one commit per logical task, not per file)
   - Write clear commit messages: `docs: update REVIEW-GUIDELINES with fair use check`
   - Reference issue/discussion if applicable

3. **Testing Before Commit:**
   - Run bible-researcher on test cases
   - Verify outputs match expectations
   - Check for regressions

4. **Pull Request:**
   - Summarize what changed and why
   - List all affected tools
   - Include test results
   - Link to relevant discussions

## Monitoring and Maintenance


## Output Format

After completing an ecosystem management task, provide:

### Summary
- What was requested
- What was changed
- Why it was changed
- Impact scope (how many tools affected)

### Changes Made
- List of documents updated
- List of tools modified
- List of directories restructured
- Commit messages used

### Testing Results
- Which tools were tested
- Test verses used
- Validation results
- Any issues discovered

### Next Steps
- Follow-up tasks needed
- Tools that need attention
- Documentation to update
- Monitoring to establish

## Examples of Ecosystem Changes

### Example 1: Added Copyright Compliance

**Request:** Add fair use verification to all tools

**Changes:**
- Updated REVIEW-GUIDELINES.md Level 1 with copyright check
- Updated TEMPLATE.md with fair use methodology section
- Updated 3 existing tool READMEs
- Added to tool-experimenter Phase 3 evaluation

**Testing:**
- Tested on original-language-words: ✅ PASS
- Tested on grouping-semantic-clusters: ✅ PASS
- No violations found in existing outputs

**Result:** All future tools will verify copyright compliance

---

### Example 2: Reorganized by Tool Type

**Request:** Organize tools into words/commentary/topics subdirectories

**Changes:**
- Created new directory structure
- Moved 4 tools to appropriate categories
- Updated all relative paths in tool READMEs
- Updated tool-experimenter references

**Testing:**
- Verified bible-researcher can still find tools
- Tested path resolution: ✅ PASS
- Git history preserved: ✅ PASS

**Result:** Tool discovery now organized by type

---

### Example 3: Propagated BibleHub Learning

**Request:** All word tools should use BibleHub concordance (learned from tool A)

**Changes:**
- Added BibleHub to TEMPLATE suggested sources
- Updated 2 word study tool READMEs
- Cross-referenced in LEARNINGS.md files

**Testing:**
- Re-ran original-language-words with BibleHub
- Concordance data quality improved: ✅
- No performance degradation: ✅

**Result:** Word tools now consistently use BibleHub

---

## Skill Limitations

This skill does NOT:
- Create new Bible study tools (use `tool-experimenter`)
- Generate Bible data (use `bible-researcher`)
- Review individual tool outputs (that's in tool-experimenter Phase 3)
- Make theological judgments (stays meta-level)

This skill DOES:
- Improve the tool creation process
- Maintain documentation consistency
- Propagate learnings across tools
- Reorganize tool structure
- Analyze patterns across tools
- Update validation frameworks

---

**Version:** 1.0.0
**Created:** 2025-10-29
**Last Updated:** 2025-10-29
**Maintained By:** Context-Grounded Bible Project
