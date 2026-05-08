---
name: Searching code with Sourcegraph
description: Search code using Sourcegraph CLI. Use when (re)searching codebases, finding implementation examples, analyzing code patterns
---

# Sourcegraph Code Search Skill

This skill enables autonomous code searching across repositories using the Sourcegraph CLI (`src` command).

## When to Invoke This Skill

Use this skill when you need to:

- **Research how features are implemented** across codebases
- **Find examples** of API usage, patterns, or libraries
- **Locate specific code patterns** (functions, classes, imports)
- **Analyze code across repositories** (not just local files)
- **Search commit history** or diffs for changes
- **Find security issues** or credential leaks
- **Understand architecture** by searching for patterns
- **Answer "where is X used?"** questions across projects

**Do NOT use** for local file searches - use Grep/Glob instead.

## Quick Start

### Basic Search Syntax

```bash
src search 'PATTERN'              # Simple text search
src search -json 'PATTERN'        # JSON output for parsing
src search 'repo:REGEX PATTERN'   # Search specific repos
src search 'lang:go PATTERN'      # Search Go files only
```

### Common Search Patterns

**1. Find function/method implementations**
```bash
src search 'lang:go func handleRequest'
src search 'lang:python def authenticate'
```

**2. Search in specific repository**
```bash
src search 'repo:github.com/org/repo$ TODO'
src search 'repo:sourcegraph/sourcegraph auth'
```

**3. Search specific file types**
```bash
src search 'file:\.go$ context.Context'
src search 'file:schema.graphql type User'
```

**4. Search with multiple filters**
```bash
src search 'repo:kubernetes lang:go file:test fmt.Errorf'
src search 'repo:react lang:typescript useState'
```

**5. Search commit diffs/history**
```bash
src search 'type:diff repo:myorg/ password'
src search 'type:commit author:username refactor'
```

**6. Use boolean operators**
```bash
src search 'repo:kubernetes (mutex OR lock) lang:go'
src search 'repo:react useState AND useEffect'
src search 'TODO -file:test'
```

## Workflow

When invoked to search code:

1. **Understand the search goal**
   - What are we looking for?
   - Which repositories/languages?
   - What filters would narrow results?

2. **Construct the query**
   - Start with the search pattern
   - Add filters: `repo:`, `lang:`, `file:`
   - Use operators: `AND`, `OR`, `NOT`, `-`
   - Set pattern type if needed: `patternType:regexp`

3. **Execute the search**
   ```bash
   src search 'your query here'
   # Or for programmatic parsing:
   src search -json 'your query here'
   ```

4. **Parse and analyze results**
   - Extract relevant matches
   - Identify patterns or answers
   - Note repositories/files for further investigation

5. **Refine if needed**
   - Too many results? Add more filters
   - Too few? Broaden the search
   - Wrong results? Adjust pattern or filters

## Key Filters (Quick Reference)

| Filter | Purpose | Example |
|--------|---------|---------|
| `repo:` | Filter by repository | `repo:github.com/org/name` |
| `lang:` | Filter by language | `lang:go`, `lang:python` |
| `file:` | Filter by file path | `file:\.test\.js$` |
| `type:` | Result type | `type:commit`, `type:diff`, `type:symbol` |
| `case:` | Case sensitivity | `case:yes` |
| `-` prefix | Exclude | `-file:test`, `-repo:archived` |

## Pattern Types

- **Literal** (default): Exact text matching
- **Regexp**: Use `patternType:regexp` for regex (RE2 syntax)
- **Structural**: Use `patternType:structural` for syntax-aware matching

## CLI Flags

- `-json`: Output results as JSON (for parsing)
- `-stream`: Stream results as they arrive
- `-display N`: Limit displayed results (with `-stream`)
- `--`: Separate flags from query (for queries starting with `-`)

## Important Notes

### Negation in Queries

Queries starting with negation need `--` separator:
```bash
src search -- '-repo:foo/bar error'
```

### Output Control

- Use `-json` for programmatic parsing
- Default output is formatted for terminal (with colors)
- Set `NO_COLOR=t` to disable colors
- Set `COLOR=t` to force colors when piping

### Search Scope

- Sourcegraph searches across configured repositories
- Default excludes: `fork:no archived:no`
- Include with: `fork:yes` or `archived:yes`

## Examples by Use Case

### Finding Implementation Examples

```bash
# How do people handle authentication in Go?
src search 'lang:go repo:.*auth.* middleware'

# React hooks usage
src search 'lang:typescript repo:facebook/react use.*Hook'
```

### Security Auditing

```bash
# Find hardcoded credentials
src search 'patternType:regexp (password|secret|api_key)\s*=\s*["\'][^"\']+["\']'

# Exposed private keys
src search 'type:diff BEGIN.*PRIVATE KEY'
```

### API Research

```bash
# How is this library used?
src search 'lang:python import requests'

# Find all GraphQL mutations
src search 'file:\.graphql$ type Mutation'
```

### Refactoring Research

```bash
# Find deprecated API usage
src search 'repo:myorg/ oldDeprecatedFunction'

# Find TODO comments in non-test files
src search 'TODO -file:test -file:spec'
```

## Advanced Features

For comprehensive syntax reference, pattern types, and advanced operators, see **reference.md**.

For more practical examples and complex query patterns, see **examples.md**.

## Troubleshooting

**No results?**
- Check repository access/permissions
- Verify repository is indexed by Sourcegraph
- Try broader search terms
- Remove restrictive filters

**Too many results?**
- Add more specific filters
- Use `lang:` to narrow by language
- Use `repo:` with regex for specific repositories
- Combine with `file:` for specific paths

**Syntax errors?**
- Check regex syntax (RE2 format)
- Quote the entire query
- Use `--` before queries starting with `-`
- Verify filter names are correct

## Integration with Other Tools

After finding results with Sourcegraph:
- Use `Read` tool to examine specific files locally
- Use `Grep` for more detailed local searching
- Use `Bash` for git operations on repositories
- Use `WebFetch` to access repository URLs

## Best Practices

1. **Start broad, then narrow**: Begin with simple patterns, add filters incrementally
2. **Use appropriate pattern types**: Literal for exact matches, regexp for patterns
3. **Combine filters effectively**: `repo:` + `lang:` + `file:` for precision
4. **Parse JSON for programmatic analysis**: Use `-json` when processing results
5. **Respect quotas and limits**: Sourcegraph may have rate limits or result limits
6. **Cache insights**: Remember patterns that work for future searches

## Performance Tips

- Specific `repo:` filters are faster than broad searches
- Language filters (`lang:`) significantly narrow scope
- File filters (`file:`) reduce search surface
- Use `count:` to limit results when you just need examples
- Streaming (`-stream`) is better for large result sets

## Reference Files

- **reference.md**: Complete syntax documentation, all filters, operators, pattern types
- **examples.md**: Practical search patterns organized by use case
