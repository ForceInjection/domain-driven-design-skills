---
name: work
description: Manage work items and tasks using the work todo system. Use when creating, updating, listing, or tracking work items with dependencies. (user)
---

# work todo system

Manage work items stored as `Work{}` callback-based lua files in `~/*/*/work/`.

## Data structure

Work items are stored in individual lua files using the `Work{}` callback pattern:

```lua
Work{
  id = "01KBB8VWCGH1CMSNDGNXD54F2J",  -- ULID (time-ordered, globally unique)
  title = "implement feature",
  created = "2025-11-30",              -- YYYY-MM-DD
  completed = "2025-11-30T14:30:00",   -- ISO 8601 timestamp (optional, present when done)
  due = "2025-12-15",                  -- absolute date (YYYY-MM-DD) or relative (-Xd, -Xw)
  description = "optional details",    -- optional
  blocks = {                           -- optional: IDs this item BLOCKS (dependents)
    "01KBB8VWCGH1CMSNDGNXD54F2K"      -- these items cannot start until this completes
  },
  log = {                              -- optional timestamp-message pairs
    ["2025-11-30T10:30:00"] = "started investigation",
    ["2025-11-30T14:15:00"] = "found root cause"
  }
}
```

Each item is stored in `~/*/*/work/{id}.lua`.

### Dependency model: blocks field

**CRITICAL: The `blocks` field lists what this item blocks (what waits on this item).**

The `blocks` field specifies IDs that cannot start until THIS item completes:

- If item Y has `blocks = [Z]`, then Y blocks Z (Z waits for Y)
- Y must complete before Z can start
- Y is a "prerequisite" or "blocker" of Z

**Example hierarchy:**

``` lua
Work{id = "X", title = "code", blocks = ["Y"]}      -- X blocks Y (Y waits for X)
Work{id = "Y", title = "test", blocks = ["Z"]}      -- Y blocks Z (Z waits for Y)
Work{id = "Z", title = "deploy"}                    -- Z has no blocks field
```

Execution order: X → Y → Z

**Common terminology:**

- "Y blocks Z" = Y has `blocks = [Z]` = Z waits for Y to complete
- "Z is blocked by Y" = Y has Z in its blocks field = Z cannot start until Y completes
- "Y is a blocker" = Y has items in its blocks field that wait on it

### Due dates

Due dates can be specified in two ways:

1. **Absolute dates**: `"2025-12-15"` (YYYY-MM-DD format)
2. **Relative dates**: `"-1d"` or `"-4w"` (days or weeks before dependent items)

Relative dates are computed based on the earliest due date among all items that transitively depend on (block on) the current item. For example:

- Item A has `due = "2025-12-15"`
- Item B blocks on A with `due = "-1d"` → resolves to `2025-12-14`
- Item C blocks on B with `due = "-2d"` → resolves to `2025-12-12` (2 days before A's date)

Warnings are shown if:

- A relative due date has no dependent items
- No dependent items have due dates set

Supported units:

- `d` - days
- `w` - weeks (7 days)

## Global flags

All commands support the `--json` flag for machine-readable output:

``` bash
bin/work --json <command> [args...]
```

JSON output format:

- `add`: returns the created item
- `list`: returns array of all items
- `show`: returns the item
- `done`: returns the updated item
- `update`: returns the updated item
- `rm`: returns the removed item
- `blocked`: returns array of blocked items with `unresolved_blocks` field
- `ready`: returns array of ready (unblocked) items
- `log`: returns object with `id`, `timestamp`, and `message`

## Commands

### add

Create new work item:

``` bash
bin/work add "task title"
bin/work add "task title" due=2025-12-15
bin/work add "task title" due=-1d description="details" priority=5
bin/work add "task title" blocks=FK0FHM,21S2FX  # supports 6-char suffix IDs
```

Accepts optional field=value arguments:

- `due=YYYY-MM-DD` or `due=-Xd` - Set due date (absolute or relative)
- `description="text"` - Add description
- `priority=N` - Set priority (numeric)
- `blocks=id1,id2` - Set blocking dependencies (IDs that THIS item will block)

Returns the generated ULID on stdout. Short IDs (both prefixes and suffixes) are supported in the blocks argument.

**IMPORTANT:** When adding an item with blocking relationships:

- The `blocks` parameter in `add` specifies what THIS new item will block
- To make an existing item block the new item, update the existing item's `blocks` field instead
- Example: To create item B that is blocked by existing item A:
  ``` bash
  # Create B first
  id_b=$(bin/work add "task B")
  # Then update A to block B
  bin/work update {id_a} blocks={id_b}
  ```

### list

Show all work items with status:

``` bash
bin/work list
```

Output format:

    ◉ K0FHM: completed task
    ○ W8NAE: pending task
    ○ 4F2K: blocked task (blocks: W8NAE)

Items are sorted by creation time (ULID order). IDs are displayed as the last 6 characters of the ULID (suffix) for better uniqueness, since ULIDs have more entropy at the end.

### tree

Show work items as a dependency tree:

``` bash
bin/work tree
```

Output format:

    ○ FK0FHM +13w  2026 ATR
        ○ 21S2FX  +3d  self-review
            ○ JRV0BB  +3d  request feedback
                ○ W8NAEP  +1d  identify feedbackers
        ○ MCFMG3 +12d  peer feedback

Displays items in dependency hierarchy with indentation, showing:

- Status marker (○ for incomplete, ◉ for completed)
- 6-character suffix ID
- Relative due date if present (e.g., +3d, +13w)
- Task title

Root items (no dependencies) are shown at the top level, with dependent items indented beneath them. Items are sorted by due date (ascending), priority (descending), and creation time (ascending) at each level.

### show

Display detailed information about a work item:

``` bash
bin/work show {id}
bin/work show FK0FHM  # 6-char suffix ID
bin/work show 01KBBAH  # prefix also works
```

Shows: id, title, created date, completed timestamp (if present), due date (with resolution for relative dates), description (if present), blocking dependencies, and log entries.

**Note:** All commands accept short IDs (6+ characters). The system matches both prefixes and suffixes, preferring suffixes since they're displayed in `list` and `tree`. If ambiguous, the command will error and show matching IDs.

### done

Mark work item as complete:

``` bash
bin/work done {id}
```

Sets the completed field to the current timestamp (ISO 8601 format) in the item's lua file.

### update

Modify work item fields:

``` bash
bin/work update {id} field=value...
bin/work update {id} description="new description"
bin/work update {id} blocks=id1,id2,id3  # set what THIS item blocks
bin/work update {id} due=2025-12-15
bin/work update {id} due=-1d
bin/work update {id} priority=5
```

To remove a field, use an empty value:

``` bash
bin/work update {id} field=
bin/work update {id} completed=    # unmark as done
bin/work update {id} description=  # remove description
bin/work update {id} due=          # remove due date
```

Any optional field can be removed by setting it to an empty value.

**IMPORTANT:** When updating blocking relationships:

- `blocks=id1,id2` sets what THIS item blocks (items that wait on THIS item)
- To make item A block item B: update A with `blocks=B` (not the other way around)
- The item specified in the update command is the blocker, values are what it blocks

### rm

Remove work item:

``` bash
bin/work rm {id}
```

Deletes the item's lua file from the work data directory.

### blocked

List items blocked by incomplete dependencies:

``` bash
bin/work blocked
```

Shows only items with `blocks` fields containing IDs without a `completed` timestamp.

### ready

Show next ready (unblocked) items:

``` bash
bin/work ready                # default: 5 items, sorted by schedule
bin/work ready --limit=10     # show up to 10 items
bin/work ready --shuffle      # randomize order (sorts by reversed ID)
bin/work --json ready         # JSON output
```

Returns incomplete items that have no incomplete prerequisites (not waiting on anything). These are the items that can be started immediately.

**Sorting:**

- Default: due date (ascending), priority (descending), created date (ascending)
- `--shuffle`: sorts by reversed ID for pseudo-random order (entropy is at end of ULID)

**Options:**

- `--limit=N`: maximum number of items to show (default: 5)
- `--shuffle`: randomize the order instead of scheduling sort

**Output format:**

    W8NAEP  +1d  send email
    3MCZQM  +3w  code review [p10]
    1MHKK2  +3w  documentation [p10]

Shows: 6-char suffix ID, relative due date (if set), title, and priority (if non-zero).

### log

Append a timestamped message to a work item's log:

``` bash
bin/work log id={id} <message>
```

Automatically generates an ISO 8601 timestamp (YYYY-MM-DDTHH:MM:SS) and appends the message to the item's log field. If the log field doesn't exist, it will be created.

## Library

The work system uses a three-layer architecture:

### lib/work/data.lua - Data layer

Handles storage, validation, and I/O operations:

**Functions:**

- `load_all(dir)` - Load all work items from directory
- `load_file(path, kinds)` - Load lua file with Work{} callbacks
- `save(item, dir)` - Save item with validation and atomic write
- `delete(item)` - Remove item file
- `get(id)` - Retrieve item by full ID
- `get_all()` - Return all items sorted by created date
- `get_by_file(source)` - Get items from specific file
- `validate(item)` - Validate item schema
- `clean(item)` - Remove internal fields (\_meta, \_computed)
- `resolve_id(short_id)` - Resolve short ID to full ID
- `generate_id()` - Generate new ULID
- `write(item, callback_name)` - Serialize item to Work{} format
- `render(data, opts)` - Render data structure to lua format

**Validation:**

- Required fields: `id`, `title`
- Optional fields: `created`, `completed`, `due`, `description`, `priority`, `blocks`, `log`
- Collision detection for duplicate IDs
- Metadata tracking via `_meta.source` and `_meta.kind`
- Atomic writes with signal handling for cleanup

### lib/work/process.lua - Processing layer

Handles business logic, enrichment, and dependencies:

**Functions:**

- `enrich(item)` - Add \_computed fields to item
- `enrich_all(items)` - Enrich array of items
- `resolve_due_date(item)` - Resolve absolute/relative/inferred due dates
- `date_relative_to_today(date_str)` - Format date as "+3w", "-2d"
- `get_blocked_items()` - Items with unresolved blocking dependencies
- `get_ready_items()` - Items with no incomplete prerequisites
- `validate_blocks(item_id, blocks)` - Check for cycles and self-blocking
- `sort_by_schedule(items)` - Sort by due (asc), priority (desc), created (asc)
- `build_tree(items)` - Build dependency tree with roots and children

**Enrichment:**
Items are enriched with `_computed` fields:

- `short_id` - Last 6 chars of ID
- `resolved_due` - Actual date after resolution
- `relative_due` - Human-readable ("+3w", "-2d")
- `is_blocked` - Boolean status
- `unresolved_blocks` - Incomplete dependencies
- `dependent_count` - Items depending on this one

### lib/work/render.lua - Presentation layer

Handles formatting and display:

**Functions:**

- `list(items, opts)` - List format output
- `tree(tree_data, opts)` - Tree format with hierarchy
- `detail(item, opts)` - Detailed item view
- `ready(items, opts)` - Ready items format
- `blocked(items, opts)` - Blocked items format
- `json(data)` - JSON output
- Component functions: `status_mark()`, `short_id()`, `due_display()`, `priority_badge()`, `blocks_info()`

### ULID generation

IDs use ULID (Universally Unique Lexicographically Sortable Identifier):

``` lua
local ulid = require("ulid")
local id = ulid.generate()  -- "01KBB8VWCGH1CMSNDGNXD54F2J"
```

- 26 characters (Crockford Base32)
- Time-ordered: first 10 chars = millisecond timestamp
- Globally unique: last 16 chars = random
- Lexicographically sortable

ULID library location: `~/.local/lib/lua/ulid.lua`

## Workflow patterns

### Basic task tracking

``` bash
bin/work add "implement auth"
bin/work add "write tests"
bin/work add "deploy to staging"
bin/work list
bin/work done {auth-id}
```

### Dependencies

``` bash
# Create items with dependencies
# Note: blocks lists what this item BLOCKS (what waits on this item)
id1=$(bin/work add "research database options" blocks=$id2)  # id1 blocks id2
id2=$(bin/work add "implement database layer" blocks=$id3)   # id2 blocks id3
id3=$(bin/work add "write tests")                            # id3 has no dependents

bin/work blocked  # shows id2 (blocked by id1) and id3 (blocked by id2)
bin/work ready    # shows id1 only (nothing blocks it)

bin/work done $id1
bin/work blocked  # shows id3 (still blocked by id2)
bin/work ready    # shows id2 (id1 is now complete)

bin/work done $id2
bin/work blocked  # now empty
bin/work ready    # shows id3 (all blockers complete)
```

### Adding details

``` bash
bin/work update {id} description="Use PostgreSQL with connection pooling"
bin/work show {id}
```

## Implementation notes

- Work items are stored in `~/*/*/work/` (discovered via glob pattern)
- Library uses three-layer architecture in `~/.local/lib/lua/work/`:
  - `data.lua` - Storage and validation
  - `process.lua` - Business logic and enrichment
  - `render.lua` - Formatting and display
- ULID library is global (`~/.local/lib/lua/ulid.lua`)
- Each work item is a separate file for version control friendliness
- Uses `Work{}` callback pattern for data definition
- Commands follow Load → Process → Render pattern
- Enrichment pattern computes derived fields once, renders many times
