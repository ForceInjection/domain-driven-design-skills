---
name: skill-tester
description: Test and validate agent skills against the Agent Skills Specification v1.0. Use before deploying skills to ensure spec compliance and catch structural issues.
license: MIT
allowed-tools:
  - Bash
  - Read
---

# Skill Tester

Validate agent skills against the Agent Skills Specification v1.0 with comprehensive testing and reporting.

## When to Use This Skill

Use skill-tester when you need to:

- Validate a new skill before deployment
- Test an existing skill after modifications
- Ensure spec compliance
- Catch structural issues early
- Generate validation reports

## Testing Process

### Phase 1: Initial Checks

#### Locate the Skill

1. Identify the skill directory path
2. Verify the directory exists
3. Confirm SKILL.md file is present (case-sensitive)

### Phase 2: Run Validation

#### Use the Validation Script

Check available options:

```bash
python scripts/test_skill.py --help
```

Run full validation:

```bash
python scripts/test_skill.py /path/to/skill-directory
```

### Phase 3: Interpret Results

#### Validation Report Structure

The validator checks:

✓ **PASSED** - Requirement met

```text
✓ Directory exists: skill-name
✓ SKILL.md file exists
✓ YAML frontmatter is valid
✓ Required field present: 'name'
✓ Required field present: 'description'
✓ Skill name format is valid: 'skill-name'
✓ Directory name matches YAML name: 'skill-name'
✓ Description explains when to use the skill
✓ SKILL.md body has 1234 words (<5,000)
```

⚠ **WARNINGS** - Should be addressed

```text
⚠ Description is 250 chars (recommended ~200)
⚠ SKILL.md body has 5,200 words (recommended <5,000)
⚠ Description should explain WHEN to use the skill
⚠ Possible hardcoded credential detected
```

✗ **FAILED** - Must be fixed

```text
✗ SKILL.md file not found (case-sensitive)
✗ Invalid YAML frontmatter: mapping values are not allowed here
✗ Missing required field in YAML: 'description'
✗ Skill name exceeds 64 characters: 72
✗ Skill name must be hyphen-case: 'Skill_Name'
✗ Directory name 'skill-name' does not match YAML name 'skillname'
✗ Description exceeds 1024 characters (1500 chars)
✗ Referenced file does not exist: scripts/missing.py
```

### Phase 4: Fix Issues

#### Priority 1: Fix All Errors

Errors prevent the skill from working correctly:

- Missing or invalid SKILL.md
- Invalid YAML syntax
- Missing required fields
- Name format violations
- Directory/YAML name mismatches
- Missing referenced files

#### Priority 2: Address Warnings

Warnings indicate quality issues:

- Description too long or vague
- SKILL.md too verbose
- Missing "when to use" guidance
- Potential security issues

### Phase 5: Re-test

After fixes:

```bash
python scripts/test_skill.py /path/to/skill-directory
```

Verify:

- All errors resolved
- Warnings addressed
- Clean validation report

## Validation Checks

### 1. Directory Structure

**Checks**:

- Directory exists and is a directory
- SKILL.md file exists (case-sensitive)

**Common Issues**:

- Using `skill.md` instead of `SKILL.md`
- Missing SKILL.md file
- Incorrect directory path

### 2. YAML Frontmatter

**Checks**:

- YAML syntax is valid
- Starts and ends with `---`
- Required fields present: `name`, `description`
- Field types correct (strings, arrays, objects)

**Common Issues**:

- Missing opening or closing `---`
- Invalid YAML syntax (indentation, special characters)
- Typos in field names
- Missing required fields

### 3. Skill Name

**Checks**:

- Hyphen-case format (lowercase, hyphens only)
- Maximum 64 characters
- Only Unicode alphanumeric and hyphens
- Directory name matches YAML `name` field exactly

**Valid Examples**:

- `code-analyzer`
- `api-doc-generator`
- `test-runner`

**Invalid Examples**:

- `Code_Analyzer` (underscores, capitals)
- `codeAnalyzer` (camelCase)
- `code analyzer` (spaces)

### 4. Description Field

**Checks**:

- String type
- Maximum 1024 characters (API limit)
- Recommended ~200 characters
- Explains WHAT and WHEN

**Good Description**:

```yaml
description: Analyze code complexity using cyclomatic complexity metrics. Use when assessing code maintainability or identifying refactoring candidates.
```

**Poor Description**:

```yaml
description: This skill helps with code.
```

### 5. File References

**Checks**:

- All referenced files exist
- Paths are correct relative to skill root
- Checks markdown links and inline code that reference local files

**Common Issues**:

- Typos in file paths
- Case sensitivity mismatches
- Absolute paths instead of relative
- References to non-existent files

### 6. Content Quality

**Checks**:

- Word count under 5,000 (warning at 5,000+)
- No hardcoded credentials (simple pattern check)
- Description includes "when" indicators

**Security Patterns Checked**:

- `password: "..."`
- `api_key: "..."`
- `secret: "..."`
- `token: "..."`

## Testing Scripts

### test_skill.py

**Purpose**: Main validation script for skill testing

**Usage**:

```bash
python scripts/test_skill.py <skill-directory>
```

**Exit Codes**:

- `0`: All checks passed
- `1`: One or more checks failed

**Output**: Formatted validation report with passed, warnings, and failed checks

### validate_yaml.py

**Purpose**: Validate YAML frontmatter only

**Usage**:

```bash
python scripts/validate_yaml.py <skill-directory>
```

**Checks**:

- YAML syntax
- Required fields
- Field types and constraints

## Examples

### Example 1: Valid Skill

**Skill Structure**:

```text
brand-guidelines/
└── SKILL.md
```

**SKILL.md**:

```yaml
---
name: brand-guidelines
description: Apply brand visual identity guidelines including colors, typography, and spacing. Use when creating branded materials or reviewing designs.
license: MIT
---
# Brand Guidelines

[Content follows...]
```

**Validation Result**:

```text
✓ PASSED (9)
  ✓ Directory exists: brand-guidelines
  ✓ SKILL.md file exists
  ✓ YAML frontmatter is valid
  ✓ Required field present: 'name'
  ✓ Required field present: 'description'
  ✓ Skill name format is valid: 'brand-guidelines'
  ✓ Directory name matches YAML name: 'brand-guidelines'
  ✓ Description explains when to use the skill
  ✓ SKILL.md body has 245 words (<5,000)

RESULT: PASSED - Skill is valid
```

### Example 2: Skill with Errors

**Skill Structure**:

```text
Code_Analyzer/
└── SKILL.md
```

**SKILL.md**:

```yaml
---
name: code-analyzer
description: Analyzes code.
---
# Code Analyzer

Run the analysis script from the scripts directory.
```

**Validation Result**:

```text
✗ FAILED (2)
  ✗ Directory name 'Code_Analyzer' does not match YAML name 'code-analyzer'

⚠ WARNINGS (1)
  ⚠ Description should explain WHEN to use the skill

RESULT: FAILED - Fix errors before using this skill
```

**Fixes Required**:

1. Rename directory to `code-analyzer`
2. Improve description to explain when to use

### Example 3: Skill with Warnings

**SKILL.md**:

```yaml
---
name: data-processor
description: This skill provides comprehensive data processing capabilities including cleaning, transformation, validation, analysis, and reporting across multiple data formats and sources with support for batch and streaming operations.
---
```

**Validation Result**:

```text
✓ PASSED (7)
  [... passed checks ...]

⚠ WARNINGS (2)
  ⚠ Description is 210 chars (recommended ~200)
  ⚠ Description should explain WHEN to use the skill

RESULT: PASSED with warnings - Consider addressing warnings
```

**Improvements**:

```yaml
description: Process, clean, and transform data across multiple formats. Use when preparing datasets for analysis or integrating data from different sources.
```

## Common Pitfalls

### Name Mismatches

❌ **Wrong**:

```text
Directory: data-analyzer
YAML: data_analyzer
```

✓ **Correct**:

```text
Directory: data-analyzer
YAML: data-analyzer
```

### Case Sensitivity

❌ **Wrong**:

```text
skill.md
Skill.md
SKILL.MD
```

✓ **Correct**:

```text
SKILL.md
```

### Vague Descriptions

❌ **Wrong**:

```yaml
description: Helps with testing
```

✓ **Correct**:

```yaml
description: Run Playwright-based web application tests. Use when validating UI functionality or running end-to-end test suites.
```

### Missing File References

❌ **Wrong**:
Reference a script file that doesn't exist in the skill directory.

✓ **Correct**:
Only reference files that are actually bundled with the skill.

## Best Practices

1. **Test Early**: Validate during development, not just before deployment
2. **Fix Errors First**: Address all failures before warnings
3. **Iterate**: Test after each change
4. **Read Reports**: Don't just check pass/fail, read the details
5. **Automate**: Integrate into CI/CD pipelines

## Validation Checklist

Use this before deploying skills:

- [ ] Run `python scripts/test_skill.py /path/to/skill`
- [ ] Zero errors in validation report
- [ ] Warnings addressed or documented
- [ ] All file references valid
- [ ] Description clear and actionable
- [ ] Skill name matches directory
- [ ] YAML frontmatter valid

## Resources

- Validation script: `scripts/test_skill.py`
- YAML validator: `scripts/validate_yaml.py`
- Agent Skills Specification: <https://github.com/anthropics/skills/blob/main/agent_skills_spec.md>
