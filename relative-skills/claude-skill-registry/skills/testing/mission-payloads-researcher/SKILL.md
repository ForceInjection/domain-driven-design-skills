---
name: mission-payloads-researcher
description: Specialized skill for researching and verifying detailed payload manifests for lunar missions, with a focus on CLPS and commercial payloads.
---

# Mission Payloads Researcher Skill

## Domain Knowledge
- **File**: `LUNAR_MISSIONS.MD`
- **Primary Data Sources**:
  - `missions/` (Mission files to be updated)
  - `space-entities/` (Entity references)
- **Research Goals**:
  - Identify specific instruments and payloads on a mission.
  - Determine the provider/owner of each payload.
  - Specific focus on NASA CLPS (Commercial Lunar Payload Services) manifests.

## Instructions
1. **Manifest Discovery**: Conduct research to identify the full list of payloads for a specific mission.
2. **Entity Attribution**: Link each payload to its specific developing entity (University, Company, Agency).
3. **CLPS Verification**: Specifically itemize and describe NASA CLPS payloads when present.
4. **Data Enrichment**: Update the `payload_ids` list in Mission YAML and the markdown body with descriptive lists of findings.
5. **Asset Linking**: When adding rovers or specialized mobile payloads to a mission file, check for a matching file in `rovers/`. If it exists, wrap the payload name in a markdown link to that file.
