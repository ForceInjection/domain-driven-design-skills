---
name: kan
description: Manage kanban boards using the Kan CLI. Use when working with tasks, cards, boards, columns, or project tracking via the kan command.
---

# Kan CLI

[Kan](https://github.com/amterp/kan) is a file-based kanban board CLI. All data lives in `.kan/` as plain files.

## Getting Help

Every command supports `--help` for detailed usage:

```bash
kan --help
kan add --help
kan list --help
```

## Adding Cards

```bash
kan add "Fix login bug"                        # Add card, prompted for details
kan add "Fix login bug" -c "In Progress"       # Add to specific column
kan add "Fix login bug" -l bug -l urgent       # Add with labels
kan add "Refactor auth" "Clean up the auth module" -c Todo   # Title + description
kan add "Subtask" -p 12                        # Add as child of card 12
```

## Listing Cards

```bash
kan list                     # List all cards
kan list -c "In Progress"    # Filter by column
kan list -b myboard          # Filter by board
```

## Showing Card Details

```bash
kan show 12       # Show card by ID
kan show fix      # Show card by alias or partial match
```

## Editing Cards

```bash
kan edit 12       # Edit card interactively
```

## Tips

- Use `-I` / `--non-interactive` to skip prompts (useful for scripting)
- Cards are identified by flexible IDs (numeric ID, alias, or partial match)
