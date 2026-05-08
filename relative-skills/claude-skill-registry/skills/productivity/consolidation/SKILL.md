---
name: Consolidation
description: Consolidate atomic memories from MCP-Memory into Obsidian vault knowledge notes. Bridges episodic memory (experiences) with semantic knowledge (curated facts). Structure emerges from links, not naming conventions.
---

# Consolidation

This skill invokes the `consolidation` agent to distil memories into vault knowledge.

## Quick Reference

**Invoke:** `/consolidation [scope]`

**Scopes:**
- Domain tag (e.g., "unison", "scala")
- Time range (e.g., "last week")
- No argument = all unconsolidated memories

## Memory vs Knowledge

| Layer | Type | Content | Update Pattern |
|-------|------|---------|----------------|
| MCP Memory | Episodic | Experiences, observations, atomic facts | Append-only, decay |
| Obsidian Vault | Semantic | Curated knowledge, structured notes | Consolidate, version |

## Memory Tags

| Tag | Meaning |
|-----|---------|
| `consolidated` | Written to vault note — don't reconsider |
| `episodic` | Reviewed, kept as episodic — don't reconsider |

Both tags exclude memories from future consolidation runs.

## Vault vs Skill Distinction

- **Vault** = declarative knowledge (facts, patterns, gotchas) — for reference
- **Skill** = procedural knowledge (how Claude should operate) — instructions

Ask: "Is this about **what** (→ vault) or **how Claude should work** (→ skill)?"

## Agent Behaviour

The consolidation agent:
1. Gathers memories without `consolidated` or `episodic` tags
2. Classifies each memory:
   - **Consolidate** → write to vault, add `consolidated` tag
   - **Keep episodic** → add `episodic` tag (project-specific, transient)
   - **Skip** → already tagged or low-value, no action
3. For consolidations: search vault for existing notes to extend
4. Append observations with hashtag markers
5. Add WikiLinks to related notes
6. Update memory metadata with appropriate tag
7. Return summary report

Runs autonomously without user interaction.

## When to Consolidate

Batch at natural breakpoints:
- End of work session
- Switching projects
- Weekly review
- When memory count feels high (~50+ unconsolidated)

**Don't interrupt flow** — consolidation is reflection time.
