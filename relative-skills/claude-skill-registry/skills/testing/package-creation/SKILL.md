---
name: package-creation
description: Post-creation workflow for new packages in dx-toolkit monorepo - implementation, testing, publishing
---

# Package Creation Workflow

Post-creation workflow for new packages in dx-toolkit monorepo. Use these steps after creating a package with the create-package command.

---

## Post-Creation Workflow

After creating a package with the create-package command:

### 1. Implement Package Logic

- Edit `packages/{package-name}/src/main.ts` to export your public API
- Add TSDoc comments to all exports for API documentation
- Create feature modules in `src/` directory
- Add tests in `src/tests/` directory
- Run `bun run check` from package directory to verify code quality

### 2. Register Package Documentation

- Add your package's AGENTS.md reference to root `CLAUDE.md`
- This ensures Claude Code can access package development guidelines
- Format: `@packages/{package-name}/AGENTS.md`

### 3. Create Package-Specific Skill (Optional)

**When to create a package-specific skill:**
- Package introduces framework-specific patterns (e.g., Teams.ai Memory API, Anthropic streaming)
- Package has domain-specific validation/transformation rules unique to its integration
- Patterns are substantial (50+ lines) and will be referenced frequently
- Examples: `mcp-patterns`, `ai-sdk-patterns`, `teams-ai-patterns`

**When NOT to create a skill:**
- Patterns are universal (belong in `code-patterns` skill)
- Package has minimal integration patterns (<50 lines)
- Patterns fit better in package AGENTS.md (very package-specific, not reusable)

**Skill directory structure:**
```
.claude/skills/{package-name}-patterns/
└── SKILL.md
```

**How to create:**

1. Create skill directory and SKILL.md with frontmatter:
```markdown
---
name: {package-name}-patterns
description: {Package} patterns for dx-toolkit - [key patterns summary]
---

# {Package} Patterns

Package-specific patterns for `@youdotcom-oss/{package-name}`. Use these patterns when developing with this package.

---

## Pattern Section 1

[Pattern description with ✅/❌ examples]

**Why this pattern?**
[Explanation]

## Pattern Section 2

[Continue with other patterns]
```

2. Add pattern sections with clear ✅/❌ code examples
3. Explain "Why this pattern?" for each
4. Reference skill from package AGENTS.md: `> **For {package} patterns**, see '.claude/skills/{package-name}-patterns'`
5. Add skill to root AGENTS.md skill list (lines 11-18 in Skill-Based Organization section)

**Best practices:**
- Focus on framework/domain-specific patterns only
- Use clear ✅/❌ code examples with explanations
- Keep under 200 lines (use root skills for universal patterns)
- Test that skill is discoverable and loadable
- Update root AGENTS.md to document the new skill

### 4. Add Performance Monitoring (Optional)

- Only required for packages that wrap You.com APIs directly
- Add measurements to `scripts/performance/measure.ts`
- See the `performance-testing` skill for detailed instructions
- Skip for utility libraries, CLI tools, or packages without API wrappers

### 5. Test Locally

```bash
cd packages/{package-name}
bun test                 # Run tests
bun run check            # Check code quality
bun run build            # Build package (if bundled pattern)
```

### 6. Test Publish Workflow

- Test with prerelease before first stable release
- Go to: `https://github.com/youdotcom-oss/dx-toolkit/actions/workflows/publish-{package-name}.yml`
- Enter version `0.1.0` with next `1` to create `0.1.0-next.1`
- Verify workflow succeeds and package appears on npm

### 7. First Stable Release

- Push package code to main branch
- Trigger publish workflow with version `0.1.0` (no next value)
- Verify package at `https://www.npmjs.com/package/{npm-package-name}`
- Test installation: `bun add {npm-package-name}`

## Best Practices

1. **Test locally first** - Ensure package works before publishing
2. **Use prerelease** - Test publish workflow with next version first
3. **Document with TSDoc** - Add API docs directly in code, not separate API.md
4. **Follow patterns** - Use appropriate skills for implementation
5. **Check quality** - Run `bun run check` before committing
6. **Register docs** - Add AGENTS.md to root CLAUDE.md
7. **Create skills for substantial patterns** - If package introduces 50+ lines of framework-specific patterns, create a skill

## Related Skills

- **code-patterns** - For implementing package logic
- **documentation** - For writing README and thin AGENTS.md
- **performance-testing** - For adding performance monitoring
- **git-workflow** - For commits and releases

## Related Resources

- Create package command: `.claude/commands/create-package.md`
- Root AGENTS.md: Development Workflow section
- Publishing guide: Root AGENTS.md → Publishing
