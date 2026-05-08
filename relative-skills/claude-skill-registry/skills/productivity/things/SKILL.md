---
name: Things
description: Interacting with Things 3 task manager for Mac. Use when working with the user's personal todos, tasks, projects, areas, tags, or task lists (inbox, today, upcoming, etc.). Supports creating, reading, updating, and navigating tasks.
allowed-tools: [Bash(osascript:*), Bash(open:*), Read]
---

# Things 3 Task Manager

Interact with Things 3, the user's personal task manager for Mac.

## Quick Start

**Read operations**: Use TypeScript with esbuild to write type-safe JXA code via `scripts/run-jxa.sh`
**Write operations**: Use `things://` URL schemes (`things:///add`, `things:///update`, `things:///json`)
**Auth token**: `security find-generic-password -a "$USER" -s "things-auth-token" -w` (see `@1password.md` for setup)

## Common Commands

**Read today's todos:**
```bash
scripts/run-jxa.sh 'const app = Application("Things3"); const today = app.lists.byId("TMTodayListSource"); JSON.stringify(today.toDos().map(t => ({id: t.id(), name: t.name()})), null, 2);'
```

**Create a todo:**
```bash
open "things:///add?title=Task%20name&when=today&tags=Work"
```

**Update a todo:**
```bash
auth_token=$(security find-generic-password -a "$USER" -s "things-auth-token" -w)
open "things:///update?id=ABC-123&auth-token=$auth_token&append-notes=Additional%20info"
```

**Navigate to today:**
```bash
open "things:///show?id=today"
```

## Built-in List IDs

- `TMInboxListSource` - Inbox
- `TMTodayListSource` - Today
- `TMNextListSource` - Anytime
- `TMCalendarListSource` - Upcoming
- `TMSomedayListSource` - Someday
- `TMLogbookListSource` - Logbook

## When Values

- `today`, `tomorrow`, `evening`
- `anytime`, `someday`
- `yyyy-mm-dd` (specific date)
- Natural language: "in 3 days", "next week"

## Status Values (JXA)

- `open` - Active todo
- `completed` - Completed
- `canceled` - Canceled

## Documentation

Load detailed guides as needed:

- **[setup.md](setup.md)** - TypeScript/JXA development setup, array conversion, running scripts
- **[examples.md](examples.md)** - Comprehensive usage examples for all operations
- **[jxa.md](jxa.md)** - Complete JXA object model and API reference
- **[url-scheme.md](url-scheme.md)** - URL scheme commands and parameters
- **[1password.md](1password.md)** - Auth token setup and keychain configuration
- **[troubleshooting.md](troubleshooting.md)** - Common issues, best practices, repeating task detection

## Essential Tips

- **URL encoding**: Always URL-encode parameters (spaces → `%20`, newlines → `%0a`)
- **Verification**: ALWAYS verify updates succeeded by reading back the todo with JXA
- **Repeating tasks**: Filter by comparing `creationDate` to midnight (see [troubleshooting.md](troubleshooting.md))
- **TypeScript mode**: Use `scripts/run-jxa.sh` for type-safe JXA with autocomplete
