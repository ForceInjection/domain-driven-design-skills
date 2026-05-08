---
name: lunar-rovers-expert
description: Specialized skill for analyzing lunar rover technical specifications and mobility systems within the LORS framework.
---

# Lunar Rovers Expert Skill

## Domain Knowledge
- **Directory**: `rovers/` (contains individual `*.MD` files for each rover)
- **Metadata Format**: YAML frontmatter: `id`, `name`, `developer`, `class`, `status`, `physical`, `power`, `comms`, `mobility`.
- **Interface Context**: Distinguish between **Hosted/Stowed** (on lander) and **Deployed/Mobile** states.

## Instructions
1. **Connectivity Interface Mapping**: Catalog technical specifications for the wireless link to the lander/ground station:
    - **Standards**: Wi-Fi (802.11n/ac), 4G/LTE (3GPP), or Direct-to-Earth (S-Band/X-Band).
    - **Baud Rates & Latency**: Collect data on telemetry vs. high-resolution image downlink rates.
2. **Mobility & Navigation Performance**: Track clearing (ground clearance), speed (cm/s), range, and autonomy levels (manual vs. waypoint vs. swarm).
3. **Egress & Physical Integration**:
    - **Deployment Mech**: Ramps, hoists, cube-sat style deployers, or "drop-offs".
    - **Physical Envelope**: Stowed dimensions vs. deployed configuration.
4. **Phase-Specific Service Analysis**:
    - **Transit/Stowed**: Wired heartbeat and power charging via lander bus.
    - **Deployment Trigger**: Wireless handshake timing and mechanical separation events.
    - **Surface Operations**: Thermal survival, power generation, and duty cycles.
5. **Source Attribution**: Prioritize official developer specs and mission press kits. Always link the `developer` to its entry in `SPACE_ENTITIES.MD`.

