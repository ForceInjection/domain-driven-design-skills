---
name: fetch-supabase-example
description: Fetch reference implementations from core-supabase repository. Use when (1) implementing Repository layer with Supabase, (2) need RPC function usage patterns, (3) checking correct parameter structures and type assertions, (4) verifying Supabase integration patterns.
tools: [Bash, Read, GitHub CLI]
---

> **🔔 시스템 메시지**: 이 Skill이 호출되면 `[SEMO] Skill: fetch-supabase-example 호출 - {도메인/패턴}` 시스템 메시지를 첫 줄에 출력하세요.

# Fetch Supabase Example Skill

**Purpose**: Retrieve official Supabase integration patterns from core-supabase repository

## When to Use

Agents should invoke this skill when:

- Implementing Repository layer with Supabase
- Need RPC function usage patterns
- Require parameter structure examples
- During v0.4.x CODE phase of implementation

## Quick Start

### Schema Verification (우선순위)

```bash
# 1. Supabase MCP (실시간 스키마) - 우선
mcp__supabase__list_tables()
mcp__supabase__get_table_schema()

# 2. database.types.ts (로컬 타입)
@src/lib/supabase/database.types.ts

# 3. core-supabase (참조 구현)
gh api repos/semicolon-devteam/core-supabase/...
```

### Fetch from core-supabase

```bash
# List available test examples
gh api repos/semicolon-devteam/core-supabase/contents/document/test

# Fetch specific domain example
gh api repos/semicolon-devteam/core-supabase/contents/document/test/posts/createPost.ts \
  --jq '.content' | base64 -d
```

## Usage

```javascript
// Agent invokes this skill
skill: fetchSupabaseExample("posts", "read");

// Returns: RPC function, parameters, type assertion pattern
```

## Critical Rules

1. **Always use RPC functions**: Never write raw SQL in Repository
2. **Follow parameter naming**: Use `p_` prefix for all RPC parameters
3. **Type assertion pattern**: Always `as unknown as Type`
4. **Error handling**: Always check error before using data
5. **Optional parameters**: Use `null as unknown as undefined`

## Available Domains

- `posts` - Post CRUD operations
- `comments` - Comment operations
- `users` - User profile operations
- `activities` - User activity tracking

## Dependencies

- GitHub CLI (`gh`) with authentication
- Access to `semicolon-devteam/core-supabase` repository

## Related Skills

- `implement` - Uses this skill during v0.4.x CODE phase
- `validate-architecture` - Verifies Supabase pattern compliance

## References

For detailed documentation, see:

- [RPC Patterns](references/rpc-patterns.md) - Parameter handling, type assertions, full examples
- [Storage Patterns](references/storage-patterns.md) - Upload/download patterns, bucket configuration
