---
name: update-blog-links-after-publish
description: Update 4 files with published blog article links. Use this after a blog article is published and the user provides the publication URL.
---

# Update Blog Links After Publish

This skill handles the standard task of updating project files after a blog article is published. This corresponds to Step 9 of the phase-development-workflow.

## When to use this skill

Use this skill when:
- A blog article has been published on Hatena Blog
- User provides the publication URL
- Asked to "update blog links after publish"
- At Step 9 of the phase development workflow

## Required Information

Before starting, confirm you have:
1. **Phase number** (e.g., "6b", "7a")
2. **Article title** (e.g., "複雑な形状を描画する")
3. **Publication URL** (e.g., `https://an-embedded-engineer.hateblo.jp/entry/2026/01/03/...`)
4. **Publication date** (e.g., "2026-01-03")
5. **Git tag** (e.g., "v6b.0")

## Files to Update

Update these 4 files in order:

### 1. `plan/blog_phases.md`

**Purpose**: Record published article in project plan

**Action**: Add new row to "公開済み記事" (Published Articles) table

**Format**:
```markdown
| Phase {number} | {title} | {date} | {tag} | {url} |
```

**Example**:
```markdown
| Phase 6b | 複雑な形状を描画する | 2026-01-03 | v6b.0 | https://an-embedded-engineer.hateblo.jp/entry/2026/01/03/... |
```

**Location**: Add to the table under the "公開済み記事" section

### 2. `blog/phase{previous_number}.md`

**Purpose**: Update "Next" link in previous article

**Action**: Replace the "次回" (Next) section at the end of the file

**Before**:
```markdown
**次回**: 第N+1回「{title}」(準備中)
```

**After**:
```markdown
**次回**: [第N+1回「{title}」]({url})
```

**Example**:
```markdown
**次回**: [第7回「複雑な形状を描画する」](https://an-embedded-engineer.hateblo.jp/entry/2026/01/03/...)
```

**Note**: Find the previous phase number by looking at the current phase (e.g., if current is 6b, previous is 6a)

### 3. `blog/phase{current_number}.md`

**Purpose**: Final check of current article

**Action**: Verify and adjust if needed:
- Image paths converted to Hatena format (`[f:id:...]`)
- Previous/next links are correct
- Any minor formatting adjustments

**Usually**: No changes needed if already published

### 4. `blog/phase0_introduction.md`

**Purpose**: Update series index (table of contents)

**Action**: Add new row to published articles table

**Format**:
```markdown
| [第N回 {title}]({url}) | Phase {number} | {date} |
```

**Example**:
```markdown
| [第7回 複雑な形状を描画する](https://an-embedded-engineer.hateblo.jp/entry/2026/01/03/...) | Phase 6b | 2026-01-03 |
```

**Location**: Add to the table in chronological order

## Execution Workflow

### Step 9-1: Create Update Plan

Copilot should:
1. Confirm received information (phase number, title, URL, date, tag)
2. Show specific changes for each of 4 files
3. Provide diff preview for each change

Example output:
```markdown
## Link Update Plan

**Phase**: 6b
**Title**: 複雑な形状を描画する
**URL**: https://an-embedded-engineer.hateblo.jp/entry/2026/01/03/...
**Date**: 2026-01-03
**Tag**: v6b.0

### Changes:

1. plan/blog_phases.md
   - Add: | Phase 6b | 複雑な形状を描画する | 2026-01-03 | v6b.0 | {url} |

2. blog/phase6a.md
   - Update: Next link to Phase 6b

3. blog/phase6b.md
   - Verify: Images and links

4. blog/phase0_introduction.md
   - Add: | [第7回 複雑な形状を描画する]({url}) | Phase 6b | 2026-01-03 |
```

### Step 9-2: Apply Changes

Copilot should:
1. Use `multi_replace_string_in_file` for efficient batch updates
2. Update all 4 files
3. Show confirmation of each change

**Recommended approach**:
```
multi_replace_string_in_file with 3-4 replacements covering:
- plan/blog_phases.md
- blog/phase{previous}.md
- blog/phase0_introduction.md
```

### Step 9-3: User Verification & Commit

User should:
1. Review changes with `git diff`
2. Verify URLs are correct
3. Commit changes

```bash
git add -A
git commit -m "docs: Phase {number} - リンク更新（記事公開）"
git push origin phase{number}/{keyword}
```

## Important Notes

- **Accuracy**: Double-check phase numbers and URLs
- **Git Diff**: Always recommend user verify with `git diff` before committing
- **Formatting**: Maintain consistent table formatting (alignment, spacing)
- **Previous Phase**: Calculate correctly (6b → previous is 6a, 7a → previous is 6b)

## Example Usage

User: "Phase 6b article published. URL: https://an-embedded-engineer.hateblo.jp/entry/2026/01/03/123456"

Copilot should:
1. Extract phase number (6b)
2. Ask for missing info (title, date) if not in context
3. Execute 9-1: Show update plan
4. Execute 9-2: Apply changes to 4 files
5. Execute 9-3: Remind user to verify and commit

## Error Handling

If information is missing:
```
必要な情報が不足しています:
- [ ] Phase番号
- [ ] 記事タイトル
- [x] 公開URL
- [ ] 公開日

以下の情報を提供してください: ...
```

If previous article file not found:
```
前回の記事ファイル blog/phase{prev}.md が見つかりません。
Phase番号が正しいか確認してください。
```
