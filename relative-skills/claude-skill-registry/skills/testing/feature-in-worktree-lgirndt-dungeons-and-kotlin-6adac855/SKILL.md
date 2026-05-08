---
name: feature-in-worktree
description: Develop features in isolated git worktrees with autonomous testing and iteration. Use when the user asks to develop a feature in a separate worktree, wants isolated feature development, or mentions working without affecting the current directory.
---

# Feature Development in Git Worktree

Develop features autonomously in isolated git worktrees, allowing you to work on new features without disrupting your
current working directory.

## Worktree Location Pattern

All worktrees are created in: `../dungeons-kotlin-worktree/{feature-name}`

Example:

- Feature: `authentication-refactor`
- Worktree path: `../dungeons-kotlin-worktree/authentication-refactor`
- Branch: `feature/authentication-refactor`

## Workflow Instructions

### 1. Create Worktree

```bash
git worktree add ../dungeons-kotlin-worktree/{feature-name} {branch-name}
```

- Use descriptive feature names (e.g., `integration-tests`, `user-auth`, `dice-rolling`)
- Branch names typically follow: `feature/{feature-name}`

### 2. Work in Isolated Environment

Navigate to worktree and work using absolute paths:

- Edit files in `/Users/lars/devel/playground/dungeons-kotlin-worktree/{feature-name}/...`
- Run commands with appropriate working directory context

**Permission Strategy:**
- Request permissions based on the **worktree root directory**: `../dungeons-kotlin-worktree/{feature-name}`
- Do NOT request permissions for subdirectories (e.g., `src/main/kotlin/`, `src/test/kotlin/`)
- This is more efficient - one root-level approval covers all work in the worktree
- Example: Ask for permission to work in `../dungeons-kotlin-worktree/character-validation` not `../dungeons-kotlin-worktree/character-validation/src/main/kotlin/io/dungeons/...`

### 3. Implement Feature

1. Make code changes
2. Write/update tests
3. Follow project conventions from `CLAUDE.md`
4. Consult `doc/unit_tests.md` for testing guidelines
5. Check `doc/decisions.md` for architectural patterns

### 4. Test Iteratively

```bash
cd ../dungeons-kotlin-worktree/{feature-name}
./gradlew clean build
./gradlew test
```

- Run tests after each significant change
- Fix failures iteratively
- Rely on Gradle output and test results for error detection
- Continue until all tests pass

### 5. Commit Changes

```bash
git add .
git commit -m "feat: {description}

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

### 6. Push and Create PR (Optional)

```bash
git push -u origin {branch-name}
gh pr create --title "{title}" --body "..."
```

### 7. Cleanup When Done

```bash
# After merging or abandoning feature
git worktree remove ../dungeons-kotlin-worktree/{feature-name}

# If branch should be deleted too
git branch -d {branch-name}
```

## Benefits

- **Non-disruptive**: Main working directory remains untouched
- **Parallel work**: Multiple worktrees for different features
- **Clean testing**: Isolated environment for each feature
- **Safe experimentation**: Easy to abandon without cleanup
- **Full autonomy**: Complete implementation cycles without interruption

## Important Notes

- Always use absolute paths when working in worktrees
- Each worktree has its own working directory and index
- Worktrees share the same repository and branches
- Don't create worktree for same branch twice
- Clean up worktrees when feature is complete/merged
- **CRITICAL**: Request permissions at worktree root level only (e.g., `../dungeons-kotlin-worktree/{feature-name}`), NOT for subdirectories - this is much more efficient

## Tool Limitations in Worktrees

**CRITICAL: JetBrains MCP tools are NOT available in worktrees** because the worktree project is not open in IntelliJ IDEA.

### Unavailable Tools (DO NOT USE):
- ❌ `mcp__jetbrains__get_file_problems` - Not available
- ❌ `mcp__jetbrains__get_run_configurations` - Not available
- ❌ `mcp__jetbrains__execute_run_configuration` - Not available
- ❌ `mcp__jetbrains__reformat_file` - Not available
- ❌ `mcp__jetbrains__find_files_by_*` - Not available
- ❌ `mcp__jetbrains__search_in_files_*` - Not available
- ❌ `mcp__jetbrains__get_symbol_info` - Not available
- ❌ `mcp__jetbrains__rename_refactoring` - Not available
- ❌ All other `mcp__jetbrains__*` tools

### Available Tools (USE THESE):
- ✅ `Read` - Read files directly
- ✅ `Write` - Create new files
- ✅ `Edit` - Modify existing files
- ✅ `Glob` - Find files by pattern
- ✅ `Grep` - Search file contents
- ✅ `Bash` - Run gradle, git, and other commands
- ✅ `WebSearch` / `WebFetch` - Research documentation

### Error Detection Strategy

Since JetBrains tools are unavailable, rely on:
1. **Gradle output** - Compilation errors and warnings
2. **Test results** - Test failures and stack traces
3. **Manual code review** - Read files to verify correctness
4. **Grep/Glob** - Search for patterns and potential issues

## Example Usage

User: "Implement character creation validation in a worktree"

1. Create: `git worktree add ../dungeons-kotlin-worktree/character-validation feature/character-validation`
2. Implement validation logic with tests
3. Run: `./gradlew test` until passing
4. Commit and push
5. Create PR
6. Cleanup after merge

## Troubleshooting

- **"Branch already checked out"**: Use different branch or remove existing worktree
- **Tests fail in worktree**: Ensure all dependencies are available (check MongoDB, etc.)
- **Path not found**: Verify parent directory `../dungeons-kotlin-worktree/` exists (create if needed)
