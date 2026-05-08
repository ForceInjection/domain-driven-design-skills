---
name: factory-status
description: Get comprehensive factory status - research progress, drill status, inventory, production overview. Use when checking progress or deciding what to do next.
allowed-tools: Bash, Read
---

# Factory Status Check

Use this skill to get an overview of your factory state.

## Quick Status

```bash
pnpm --prefix /Users/golergka/Projects/factorio-agent factory:status
```

This shows: tech count, current research %, working drills.

## Detailed Status Query

```lua
-- Get comprehensive status
local status = {}

-- Research
local research = force.current_research
status.research = research and research.name or "none"
status.research_progress = research and string.format("%.0f%%", force.research_progress * 100) or "N/A"
status.techs_researched = 0
for _, t in pairs(force.technologies) do
    if t.researched then status.techs_researched = status.techs_researched + 1 end
end

-- Buildings
local drills = surface.find_entities_filtered{force=force, name='burner-mining-drill'}
status.total_drills = #drills
status.working_drills = 0
for _, d in ipairs(drills) do
    if d.status == 1 then status.working_drills = status.working_drills + 1 end
end

local furnaces = surface.find_entities_filtered{force=force, name='stone-furnace'}
status.furnaces = #furnaces

-- Inventory highlights
status.coal = player.get_item_count('coal')
status.iron_plates = player.get_item_count('iron-plate')
status.copper_plates = player.get_item_count('copper-plate')
status.iron_ore = player.get_item_count('iron-ore')

rcon.print(serpent.line(status))
```

## Key Metrics to Watch

1. **Working drills**: Should be close to total drills
2. **Coal inventory**: If low, prioritize coal mining
3. **Research progress**: Keep research running
4. **Iron/copper plates**: Base resources for crafting
