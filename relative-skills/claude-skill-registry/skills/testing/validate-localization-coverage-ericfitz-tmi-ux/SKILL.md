---
name: validate_localization_coverage
description: Generate a coverage report for all localization files using the project's check-i18n tool. Use when auditing translation completeness or identifying languages needing attention.
allowed-tools: Bash, Read
---

# Validate Localization Coverage

Generate a comprehensive coverage report for all localization files by running the project's existing `check-i18n` script and parsing its output.

## Inputs

None - this skill uses the project's existing `pnpm run check-i18n` script.

## Output

Return a coverage report object:

```json
{
  "master_file": "src/assets/i18n/en-US.json",
  "total_keys": 450,
  "languages_checked": 15,
  "per_language": {
    "ar-SA": {
      "file_path": "src/assets/i18n/ar-SA.json",
      "missing_keys": ["about.trademarks"],
      "missing_count": 1,
      "coverage_percent": 99.78,
      "extra_keys": []
    },
    "bn-BD": {
      "file_path": "src/assets/i18n/bn-BD.json",
      "missing_keys": [
        "about.trademarks",
        "admin.groups.viewMembersTooltip",
        "admin.webhooks.addDialog.secret"
      ],
      "missing_count": 3,
      "coverage_percent": 99.33,
      "extra_keys": []
    }
  },
  "summary": {
    "average_coverage": 98.5,
    "fully_covered_languages": ["es-ES", "de-DE"],
    "needs_attention": [
      {"language": "th-TH", "coverage_percent": 85.2, "missing_count": 67},
      {"language": "bn-BD", "coverage_percent": 92.1, "missing_count": 36}
    ],
    "total_missing_translations": 245
  }
}
```

## Process

### Step 1: Run check-i18n Script

Execute the project's i18n validation script:

```bash
pnpm run check-i18n
```

This script:
- Compares all language files against `en-US.json`
- Reports missing keys in each language
- Reports extra keys in each language (keys not in master)
- Automatically sorts JSON files
- Creates backups in `/tmp`

### Step 2: Parse Script Output

The script output follows this pattern:

```
=== Comparing src/assets/i18n/en-US.json with src/assets/i18n/ar-SA.json ===

Keys present in src/assets/i18n/en-US.json but missing in src/assets/i18n/ar-SA.json:
about.trademarks

No keys missing in src/assets/i18n/en-US.json
Backup and sorted files saved to /tmp/...

=== Comparing src/assets/i18n/en-US.json with src/assets/i18n/bn-BD.json ===

Keys present in src/assets/i18n/en-US.json but missing in src/assets/i18n/bn-BD.json:
about.trademarks
admin.groups.viewMembersTooltip
admin.webhooks.addDialog.secret
admin.webhooks.addDialog.secretHint
admin.webhooks.addDialog.secretPlaceholder

No keys missing in src/assets/i18n/en-US.json
...
```

**Parsing logic:**

1. **Identify language sections**: Look for pattern `=== Comparing ... with src/assets/i18n/XX-YY.json ===`
2. **Extract language code**: Parse `XX-YY` from the file path (e.g., `ar-SA`, `bn-BD`, `zh-CN`)
3. **Extract missing keys**: Collect lines between "Keys present in en-US.json but missing in..." and the next section marker or "No keys missing"
4. **Detect extra keys**: If output shows keys present in target but missing in en-US.json, collect those
5. **Handle "No keys missing"**: Indicates no extra keys exist in that language file

### Step 3: Count Total Keys in Master

Read `src/assets/i18n/en-US.json` and count total leaf keys (keys with string values, not object containers).

**Counting logic:**
- Recursively traverse the JSON structure
- Count only leaf nodes (string values)
- Nested keys like `about.title` count as 1 key

### Step 4: Calculate Coverage

For each language:

```
coverage_percent = ((total_keys - missing_count) / total_keys) * 100
```

Round to 2 decimal places.

### Step 5: Generate Summary

**Average coverage:**
```
average_coverage = sum(all coverage_percent) / languages_checked
```

**Fully covered languages:**
Languages with `coverage_percent === 100.0` and no extra keys.

**Needs attention:**
Languages with `coverage_percent < 95.0`, sorted by `missing_count` descending.

**Total missing translations:**
```
total_missing = sum(missing_count for all languages)
```

## Output Format Details

### per_language Object

Each language entry contains:

| Field | Type | Description |
|-------|------|-------------|
| `file_path` | string | Full path to the language file |
| `missing_keys` | string[] | List of dot-notation keys missing from this file |
| `missing_count` | number | Count of missing keys |
| `coverage_percent` | number | Percentage of keys present (0-100, 2 decimals) |
| `extra_keys` | string[] | Keys in this file but not in master (potentially obsolete) |

### summary Object

| Field | Type | Description |
|-------|------|-------------|
| `average_coverage` | number | Mean coverage across all languages |
| `fully_covered_languages` | string[] | Language codes with 100% coverage |
| `needs_attention` | object[] | Languages below 95% threshold, sorted by missing_count desc |
| `total_missing_translations` | number | Sum of all missing translations |

### needs_attention Entry

```json
{
  "language": "th-TH",
  "coverage_percent": 85.2,
  "missing_count": 67
}
```

## Example Run

### Command

```bash
pnpm run check-i18n
```

### Sample Output (partial)

```
=== Comparing src/assets/i18n/en-US.json with src/assets/i18n/es-ES.json ===

No keys missing in src/assets/i18n/es-ES.json
No keys missing in src/assets/i18n/en-US.json
Backup and sorted files saved to /tmp/i18n-backup-1234567890

=== Comparing src/assets/i18n/en-US.json with src/assets/i18n/fr-FR.json ===

Keys present in src/assets/i18n/en-US.json but missing in src/assets/i18n/fr-FR.json:
admin.webhooks.addDialog.secret
admin.webhooks.addDialog.secretHint

No keys missing in src/assets/i18n/en-US.json
...
```

### Resulting Report (partial)

```json
{
  "master_file": "src/assets/i18n/en-US.json",
  "total_keys": 450,
  "languages_checked": 15,
  "per_language": {
    "es-ES": {
      "file_path": "src/assets/i18n/es-ES.json",
      "missing_keys": [],
      "missing_count": 0,
      "coverage_percent": 100.0,
      "extra_keys": []
    },
    "fr-FR": {
      "file_path": "src/assets/i18n/fr-FR.json",
      "missing_keys": [
        "admin.webhooks.addDialog.secret",
        "admin.webhooks.addDialog.secretHint"
      ],
      "missing_count": 2,
      "coverage_percent": 99.56,
      "extra_keys": []
    }
  },
  "summary": {
    "average_coverage": 97.8,
    "fully_covered_languages": ["es-ES"],
    "needs_attention": [],
    "total_missing_translations": 32
  }
}
```

## Notes

1. **Script side effects**: The `check-i18n` script automatically sorts JSON files and creates backups in `/tmp`. This is expected behavior.

2. **Threshold configuration**: The 95% threshold for "needs attention" is a default. Adjust based on project requirements.

3. **Extra keys handling**: Extra keys (in target but not in master) may indicate:
   - Obsolete translations that should be removed
   - Keys added by mistake
   - Legitimate locale-specific content (rare)

4. **Key counting accuracy**: Ensure the key counting method matches how the check-i18n script counts keys for consistent percentages.

5. **Language file discovery**: The script automatically discovers all `*.json` files in `src/assets/i18n/` except `en-US.json`.

6. **Error handling**: If the script fails, report the error and any partial results available.
