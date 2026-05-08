---
name: restate
description: Restate durable execution for fault-tolerant services and workflows. Triggers on restate, durable, ctx.run, ctx.sleep, awakeable.
triggers: ["restate", "durable", "workflow", "ctx\\.run", "ctx\\.sleep", "awakeable"]
---

<objective>
Build durable, fault-tolerant services using Restate with TypeScript. Restate provides automatic retries, state persistence, and exactly-once execution guarantees.
</objective>

<mcp_first>
**CRITICAL: Use the Restate docs MCP server if available, or OctoCode.**

```
MCPSearch({ query: "restate" })
```

If Restate MCP available:
```typescript
mcp__restate_docs__SearchRestate({
  query: "virtual object state management"
})
```

Otherwise use OctoCode:
```typescript
mcp__octocode__githubSearchCode({
  keywordsToSearch: ["service", "handler", "ctx.run"],
  owner: "restatedev",
  repo: "sdk-typescript",
  path: "packages/restate-sdk/src",
  mainResearchGoal: "Understand Restate SDK",
  researchGoal: "Find service definition patterns",
  reasoning: "Need current API for Restate services"
})
```
</mcp_first>

<quick_start>
**Service definition:**

```typescript
import * as restate from "@restatedev/restate-sdk";

const myService = restate.service({
  name: "MyService",
  handlers: {
    process: async (ctx: restate.Context, input: string): Promise<string> => {
      // Durable step - automatically retried on failure
      const result = await ctx.run("fetch-data", async () => {
        const response = await fetch("https://api.example.com/data");
        return response.json();
      });

      // Durable sleep - survives restarts
      await ctx.sleep(5000);

      return `Processed: ${result}`;
    },
  },
});

// Serve the service
restate.endpoint().bind(myService).listen(9080);
```

**Register with Restate:**

```bash
restate deployments register http://host.docker.internal:9080
```
</quick_start>

<context_methods>
| Method | Purpose | Example |
|--------|---------|---------|
| `ctx.run(name, fn)` | Durable step with retries | `await ctx.run("api-call", () => fetch(...))` |
| `ctx.sleep(ms)` | Durable delay | `await ctx.sleep(60000)` |
| `ctx.awakeable()` | Wait for external signal | `const { id, promise } = ctx.awakeable()` |
| `ctx.serviceClient(svc)` | Call another service | `ctx.serviceClient(other).method(input)` |
| `ctx.objectClient(obj, key)` | Call Virtual Object | `ctx.objectClient(counter, "user-1").increment()` |
</context_methods>

<patterns>
**Virtual Objects (Stateful):**

```typescript
const counter = restate.object({
  name: "Counter",
  handlers: {
    increment: async (ctx: restate.ObjectContext): Promise<number> => {
      const current = (await ctx.get<number>("count")) ?? 0;
      const newCount = current + 1;
      ctx.set("count", newCount);
      return newCount;
    },
  },
});
```

**Workflows (Long-running):**

```typescript
const orderWorkflow = restate.workflow({
  name: "OrderWorkflow",
  handlers: {
    run: async (ctx: restate.WorkflowContext, order: Order): Promise<void> => {
      await ctx.run("validate", () => validateOrder(order));

      // Wait for human approval
      const approval = ctx.awakeable<boolean>();
      await notifyForApproval(approval.id);
      const approved = await approval.promise;

      if (approved) {
        await ctx.run("fulfill", () => fulfillOrder(order));
      }
    },
  },
});
```
</patterns>

<constraints>
**Banned:** Starting Restate server manually (use Docker), blocking without `ctx.run()`

**Required:**
- Wrap all external calls in `ctx.run()` for durability
- Use `ctx.sleep()` for delays (not `setTimeout`)
- Register services with running Restate server
- Handlers must be idempotent
</constraints>

<commands>
```bash
# Health check
curl http://localhost:9170/health

# Register service
restate deployments register http://host.docker.internal:9080

# List services
restate services list

# SQL introspection
restate sql "SELECT * FROM sys_invocation LIMIT 10"
```
</commands>

<success_criteria>
- [ ] MCP docs fetched for current API
- [ ] External calls wrapped in `ctx.run()`
- [ ] Using `ctx.sleep()` not `setTimeout`
- [ ] Service registered with Restate
- [ ] Handlers are idempotent
</success_criteria>
