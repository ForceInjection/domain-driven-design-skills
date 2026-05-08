---
name: lunar-missions-expert
description: Specialized skill for tracking lunar mission timelines, manifests, and mission status within the LORS framework.
---

# Lunar Missions Expert Skill

## Domain Knowledge
- **File**: `LUNAR_MISSIONS.MD` (Index)
- **Primary Data Sources**:
  - `missions/` (individual mission files with YAML metadata)
  - `rovers/` (rover details)
  - `landers/` (lander details)
- **Metadata Format**: YAML blocks with fields: `mission_id`, `lander_id`, `payload_ids`, `launch_date`, `status`, `target_site`.

## Instructions
1. **Manifest Data Collection**: Create detailed mappings of payload IDs to lander IDs and mission IDs, capturing all items delivered to the surface.
2. **Timeline Data Tracking**: Maintain an accurate log of launch dates, target landing sites, and actual landing coordinates.
3. **Outcome Documentation**: Collect and document mission success metrics and status transitions.
4. **Source Attribution**: Link entries to official mission reports, NASA CLPS updates, or provider press releases to verify status change and manifest items.
5. **Cross-Referential Integrity**: Always verify if `lander_id` or `payload_ids` have corresponding files in `landers/` or `rovers/`. If so, ensure the Markdown body contains relative links (e.g., `[Lander Name](../landers/FILE.MD)`) to those files.
