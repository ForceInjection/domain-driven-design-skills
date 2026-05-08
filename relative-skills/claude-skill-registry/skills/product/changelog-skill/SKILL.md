---
name: changelog-skill
description: Use after completing user-visible features, fixes, or behavior changes - NOT for internal docs (CLAUDE.md, DECISIONS.md, _tasks/)
---

# Changelog Update Skill

Updates `CHANGELOG.md` with changes as they happen, not later.

## When to Use

- After completing a new feature
- After fixing a bug
- After changing existing behavior
- Before committing completed work

## When NOT to Use

- Planning documents (`_tasks/` folder)
- Design docs, task plans, brainstorming notes
- Internal documentation (CLAUDE.md, DECISIONS.md updates)
- Tech debt tracking files
- Any documentation that isn't user-visible

**Rule:** Changelog is for user-visible changes only. Planning and internal docs don't belong.

## Changelog Sections (Slovak)

| Section | Slovak | Use For |
|---------|--------|---------|
| Added | `### Pridane` | New features, new capabilities |
| Changed | `### Zmenene` | Modified behavior, updates to existing features |
| Fixed | `### Opravene` | Bug fixes, corrections |
| Removed | `### Odstranene` | Removed features (rare) |

## Workflow

### 1. Read Current Unreleased Section

```bash
head -20 CHANGELOG.md
```

### 2. Add Entry Under Correct Section

Edit `CHANGELOG.md`, adding entry under `## [Unreleased]`:

```markdown
## [Unreleased]

### Pridane
- {New feature description}

### Zmenene
- {Changed behavior description}

### Opravene
- {Bug fix description}
```

### 3. Create Section If Missing

If the needed section doesn't exist under `[Unreleased]`, add it in this order:
1. Pridane (Added)
2. Zmenene (Changed)
3. Opravene (Fixed)
4. Odstranene (Removed)

### 4. Commit With Your Changes

Include changelog update in the same commit as the code change:

```bash
git add CHANGELOG.md src/...
git commit -m "feat: {description}"
```

## Writing Good Entries

**Do:**
- Write in Slovak
- Be concise (one line per change)
- Focus on user-visible impact
- Use consistent terminology

**Don't:**
- Include technical implementation details
- Mention file names or internal refactoring
- Write in English (except technical terms)

## Examples

```markdown
### Pridane
- Export do PDF s prehladom celej knihy jazd
- Moznost vymazat zalohy

### Zmenene
- Predvolene radenie: najnovsie zaznamy hore
- Zlepseny dizajn modalneho okna

### Opravene
- Oprava reaktivity dropdown-u pre vyber roku
- Autocomplete: oprava generovania tras pri uprave jazd
```

## Notes

- Update changelog IMMEDIATELY when completing work
- Each commit can include a changelog update
- Release skill (`/release`) moves [Unreleased] to versioned section
- Write for users, not developers
