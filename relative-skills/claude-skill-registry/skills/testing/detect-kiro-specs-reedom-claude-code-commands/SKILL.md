---
name: detect-kiro-specs
description: Detect Kiro specs with modified files in current branch. Use before PRs, spec-specific tests, or CI filtering.
allowed-tools: Bash(ls:*)
---

# Modified Kiro Specs Detection

IMPORTANT:
Check `.kiro/specs` exists via `ls` before start.
If absent, quit immediately with empty list.


## Usage

```bash
./scripts/main.sh [-b|--branch <branch>]
```

Options:
- `-b`, `--branch`: Base branch (default: repo default)

## Output

Newline-separated spec names, sorted:

```
user-auth
product-listing
```

Empty if no modified specs.

## main.sh Internal Detection Logic

1. List all specs from `.kiro/specs/`
2. Get modified files via `git diff <branch>...HEAD`
3. Match files containing `/<spec-name>/` pattern
4. Return distinct matches sorted alphabetically

## Examples

```bash
# Default branch
./scripts/main.sh

# Specific branch
./scripts/main.sh -b develop

# Count
./scripts/main.sh | wc -l

# CI loop
for spec in $(./scripts/main.sh); do
  run_tests "$spec"
done
```
