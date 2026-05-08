---
name: fedify-activitypub
description: Guide for building and maintaining ActivityPub/fediverse applications using Fedify. This skill should be used when users want to create federated social applications, implement ActivityPub protocols, build new features, test and debug federation, deploy to production, look up FEPs, or maintain existing Fedify applications.
---

# Fedify ActivityPub Development Guide

This skill provides guidance for building, maintaining, and extending ActivityPub-based federated applications using the Fedify framework.

## Documentation Resources

For detailed and up-to-date API documentation:
- **LLM-optimized docs**: https://fedify.dev/llms.txt (overview) and https://fedify.dev/llms-full.txt (complete)
- **Official docs**: https://fedify.dev
- **API Reference**: https://jsr.io/@fedify/fedify

When answering detailed API questions, fetch the llms-full.txt for comprehensive documentation.

## When to Use This Skill

- Creating a new ActivityPub-compatible server application
- Building new features (posts, likes, follows, boosts, replies)
- Setting up actors, inboxes, and collections
- Testing and debugging federation
- Deploying to production environments
- Migrating between Fedify versions
- Looking up FEPs (Fediverse Enhancement Proposals)

## Quick Start

```bash
# Install CLI
deno install -A jsr:@fedify/cli  # or: npm install -g @fedify/cli

# Create new project (interactive)
fedify init my-app
```

## Core Architecture

### Federation Instance

```typescript
import { createFederation, MemoryKvStore, InProcessMessageQueue } from "@fedify/fedify";

const federation = createFederation<AppContext>({
  kv: new MemoryKvStore(),           // Required: cache and state
  queue: new InProcessMessageQueue(), // Recommended: async activity processing
});
```

**Production stores:** `@fedify/redis`, `@fedify/postgres`, `DenoKvStore`

### Actor Dispatcher (Required)

```typescript
federation.setActorDispatcher("/users/{identifier}", async (ctx, identifier) => {
  const user = await db.getUserById(identifier);
  if (!user) return null;
  return new Person({
    id: ctx.getActorUri(identifier),
    preferredUsername: user.username,
    inbox: ctx.getInboxUri(identifier),
    publicKey: (await ctx.getActorKeyPairs(identifier))[0].cryptographicKey,
  });
});
```

### Key Pairs (Required for sending)

```typescript
federation.setKeyPairsDispatcher(async (ctx, identifier) => [{
  publicKey: await importJwk(user.publicKeyJwk, "public"),
  privateKey: await importJwk(user.privateKeyJwk, "private"),
}]);
```

### Inbox Listeners

```typescript
federation
  .setInboxListeners("/users/{identifier}/inbox", "/inbox")
  .on(Follow, handleFollow)
  .on(Create, handleCreate)
  .on(Like, handleLike)
  .on(Undo, handleUndo);
```

## Building Features

### Implementing Follow/Unfollow

```typescript
// Handle incoming Follow
.on(Follow, async (ctx, follow) => {
  const follower = await follow.getActor();
  const followeeId = ctx.recipient;

  await db.createFollow(follower.id.href, followeeId);

  // Send Accept back
  await ctx.sendActivity(
    { identifier: followeeId },
    follower,
    new Accept({ actor: ctx.getActorUri(followeeId), object: follow })
  );
})

// Handle Undo (unfollow)
.on(Undo, async (ctx, undo) => {
  const object = await undo.getObject();
  if (object instanceof Follow) {
    const follower = await undo.getActor();
    await db.removeFollow(follower.id.href, ctx.recipient);
  }
});
```

### Creating and Sending Posts

```typescript
async function createPost(ctx: Context, authorId: string, content: string) {
  const post = await db.createPost(authorId, content);

  const note = new Note({
    id: ctx.getObjectUri(Note, { id: post.id }),
    attributedTo: ctx.getActorUri(authorId),
    content: post.content,
    published: Temporal.Now.instant(),
    to: new URL("https://www.w3.org/ns/activitystreams#Public"),
  });

  await ctx.sendActivity(
    { identifier: authorId },
    "followers",  // Send to all followers
    new Create({ actor: ctx.getActorUri(authorId), object: note })
  );
}
```

### Implementing Likes

```typescript
// Send a Like
await ctx.sendActivity(
  { identifier: "alice" },
  targetActor,
  new Like({
    actor: ctx.getActorUri("alice"),
    object: new URL("https://remote.example/posts/123"),
  })
);

// Handle incoming Like
.on(Like, async (ctx, like) => {
  const objectUri = like.objectId;
  const liker = await like.getActor();
  await db.addLike(objectUri.href, liker.id.href);
});
```

### Object Dispatchers

Expose posts and other objects:

```typescript
federation.setObjectDispatcher(Note, "/posts/{id}", async (ctx, { id }) => {
  const post = await db.getPost(id);
  if (!post) return null;
  return new Note({
    id: ctx.getObjectUri(Note, { id }),
    attributedTo: ctx.getActorUri(post.authorId),
    content: post.content,
    published: Temporal.Instant.from(post.createdAt),
  });
});
```

### Collections with Pagination

```typescript
federation.setFollowersDispatcher("/users/{identifier}/followers",
  async (ctx, identifier, cursor) => {
    if (cursor == null) return null;
    const { items, nextCursor } = await db.getFollowers(identifier, cursor, 20);
    return {
      items: items.map(f => new URL(f.actorUri)),
      nextCursor,
    };
  }
)
.setFirstCursor(async () => "")
.setCounter(async (ctx, id) => db.countFollowers(id));
```

## Testing

### Mock Federation (@fedify/testing)

```typescript
import { createFederation } from "@fedify/testing";

const federation = createFederation({ contextData: { userId: "test" } });

// Test inbox handlers
await federation.receiveActivity(followActivity);

// Inspect sent activities
console.log(federation.sentActivities);

// Reset between tests
federation.reset();
```

### CLI Testing Tools

```bash
fedify inbox              # Ephemeral server to receive activities
fedify tunnel 3000        # Expose local server with HTTPS
fedify lookup @user@host  # Debug actor resolution
fedify webfinger user@host
```

### Enable Private Network (Testing Only)

```typescript
const federation = createFederation({
  allowPrivateAddress: true,  // SSRF risk - disable in production
});
```

## Logging & Debugging

```typescript
import { configure, getConsoleSink } from "@logtape/logtape";

await configure({
  sinks: { console: getConsoleSink() },
  filters: {},
  loggers: [
    { category: ["fedify"], sinks: ["console"], lowestLevel: "debug" },
  ],
});
```

**Key log categories:**
- `["fedify", "federation", "inbox"]` - Incoming activities
- `["fedify", "federation", "outbox"]` - Outgoing activities
- `["fedify", "sig", "http"]` - HTTP signature verification

## Framework Integration

| Framework | Package | Integration |
|-----------|---------|-------------|
| Hono | `@fedify/hono` | `app.use(federation())` |
| Express | `@fedify/express` | `integrateFederation()` |
| Fastify | `@fedify/fastify` | `fedifyPlugin` |
| Next.js | `@fedify/next` | `fedifyWith()` in middleware |
| SvelteKit | `@fedify/sveltekit` | `fedifyHook()` |
| NestJS | `@fedify/nestjs` | Middleware |

## Production Deployment

**Key considerations:**
1. Use production KV store (`@fedify/redis`, `@fedify/postgres`, `DenoKvStore`)
2. Use persistent message queue for activity delivery
3. Store key pairs in database (never regenerate on restart)
4. Separate web and queue workers with `manuallyStartQueue: true`
5. Set up logging with appropriate sinks
6. Configure `origin` option for proper URL generation

## FEP Resources

FEPs (Fediverse Enhancement Proposals) define interoperability standards:
- **Repository**: https://codeberg.org/fediverse/fep
- **Discussion**: https://socialhub.activitypub.rocks/c/standards/fep/54

Look up FEP: `https://codeberg.org/fediverse/fep/src/branch/main/fep/{id}/fep-{id}.md`

Important FEPs: FEP-8b32 (Object Integrity Proofs), FEP-fe34 (Origin security), FEP-1b12 (Groups)

## Detailed Reference

For comprehensive API documentation, advanced patterns, and migration guides, see `references/fedify-manual.md`.
