---
name: bsky
description: Use this when working with BlueSky - fetching threads, reading posts, creating content. Shows you how to use pdsx MCP tools for the task.
---

# BlueSky with pdsx

Use the pdsx MCP tools (`list_records`, `get_record`, `create_record`, etc.) for BlueSky tasks.

## Quick Reference

| Task | Tool | Example |
|------|------|---------|
| get a post | `get_record` | `get_record(uri="at://did:plc:xxx/app.bsky.feed.post/abc123")` |
| list someone's posts | `list_records` | `list_records("app.bsky.feed.post", repo="handle.bsky.social")` |
| get a profile | `get_record` | `get_record(uri="app.bsky.actor.profile/self", repo="handle.bsky.social")` |
| create a post | `create_record` | `create_record("app.bsky.feed.post", {"text": "hello"})` |

## Following Threads

Threads span multiple users. Pattern:

1. **Get the root post** to see its content and who posted it:
   ```python
   get_record(uri="at://did:plc:xxx/app.bsky.feed.post/abc123")
   ```

2. **List the OP's posts** and filter for replies to extract participant DIDs:
   ```python
   list_records("app.bsky.feed.post", repo="did:plc:xxx", _filter="[?reply].reply.parent.uri")
   ```

3. **Extract DIDs** from the URIs (format: `at://DID/collection/rkey`)

4. **Query each participant's posts** for their contributions to the thread:
   ```python
   list_records("app.bsky.feed.post", repo="did:plc:other", _filter="[?reply.root.uri=='at://did:plc:xxx/app.bsky.feed.post/abc123']")
   ```

## Collections

| Collection | Purpose |
|------------|---------|
| `app.bsky.feed.post` | posts |
| `app.bsky.actor.profile` | profile (rkey is always `self`) |
| `app.bsky.feed.like` | likes |
| `app.bsky.feed.repost` | reposts |
| `app.bsky.graph.follow` | follows |

## Post Structure

Posts reference other posts via `reply`:

```json
{
  "text": "reply text",
  "reply": {
    "root": {"uri": "at://did/collection/rkey", "cid": "bafyrei..."},
    "parent": {"uri": "at://did/collection/rkey", "cid": "bafyrei..."}
  }
}
```

- `reply.root` - thread's original post
- `reply.parent` - immediate parent being replied to

## Creating Posts

Simple:
```python
create_record("app.bsky.feed.post", {"text": "hello world"})
```

Reply (requires both uri AND cid from the parent/root posts):
```python
create_record("app.bsky.feed.post", {
    "text": "my reply",
    "reply": {
        "root": {"uri": "at://...", "cid": "..."},
        "parent": {"uri": "at://...", "cid": "..."}
    }
})
```

## Filtering with `_filter`

The `_filter` parameter uses JMESPath:

```python
# just the text from posts
list_records(..., _filter="[*].text")

# reply URIs only
list_records(..., _filter="[?reply].reply.parent.uri")

# posts with specific text
list_records(..., _filter="[?contains(text, 'keyword')]")
```

## Gotchas

1. **strongRef needs uri AND cid** - when creating replies, you need both from the parent post
2. **profile rkey is always `self`** - use `app.bsky.actor.profile/self`
3. **byte indices for facets** - links/mentions use UTF-8 byte positions, not character positions
