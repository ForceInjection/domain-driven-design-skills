---
name: deno
description: Deno-specific conventions and patterns.
---

## Conventions

- **Imports**: Explicit extensions (`.ts`), JSR > @std > npm
- **Config**: `deno.json` for imports, tasks, lint, fmt
- **Tools**: `deno fmt/lint/check/test` (not Prettier/ESLint/Vitest)
- **No node_modules**

## Testing

```typescript
Deno.test("behavior description", async (t) => {
  await t.step("specific case", () => {
    // AAA pattern, @std/assert
  });
});
```

## Permissions

Document in JSDoc: `@requires --allow-read`
