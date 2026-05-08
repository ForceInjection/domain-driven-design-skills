---
name: lunar-landers-expert
description: Specialized skill for analyzing lunar lander interface specifications and payload capacity within the LORS framework.
---

# Lunar Landers Expert Skill

## Domain Knowledge
- **Directory**: `landers/` (contains individual `*.MD` files for each lander)
- **Metadata Format**: YAML frontmatter at the top of each file with fields: `id`, `name`, `provider`, `class`, `status`, `physical` (capacity), `power`, `comms`.
- **Unit Standards**: **Metric System Only**. Convert all imperial units (lbf, lbs, inches) to SI/Metric (N, kg, m, km, kPa, °C) during extraction.
- **Common Bus Logic**: Many providers (e.g., Astrobotic) use a "Common Spacecraft Bus." Specifications valid for one lander in a family (e.g., Peregrine) are often inherited by larger variants (e.g., Griffin) unless specified otherwise. **Note: Specific subsystems (Propulsion mix, Antenna gain, Power generation) are often upgraded for larger variants.**
- **Primary Source**: **Payload User's Guide (PUG)** is the gold standard for technical ground-truth.

## Instructions
1. **Exhaustive Interface Mapping**:
    - **Wired Connection**: Document physical connector standards (e.g., MIL-DTL-38999 Series III / Glenair SuperNine), pinout variants (e.g., Regular vs Small SEC), and supported protocols (RS-422/SLIP/UDP, SpaceWire).
    - **Wireless Connection**: Map 802.11n/Wi-fi details, especially for deployed rovers.
    - **Timing Services**: Note "Time at the Tone" or NTP-equivalent UTC synchronization.

2. **Environmental & Structural Load Analysis**:
    - **Mechanical Loads**: Extract Random Vibration (Grms), Shock (G peak), and Acoustic (dB/Freq) qualification levels. Note duration (e.g., 2 mins/axis).
    - **Atmospheric/Pressure**: Document pressure drop rates (kPa/s) and humidity limits (Pre-launch).
    - **Radiation**: Differentiate between near-Earth (Van Allen) and interplanetary dosage (rad/day).
    - **EMI/EMC**: Cite specific standards (e.g., MIL-STD-461G) and test categories (CE102, RE102, etc.).

3. **Phase-Specific Service Modes**:
    - Build matrices for **Power** (Nominal/Peak/Release in W/kg) and **Data** (Heartbeat/Nominal/Release in bps or kbps/kg).
    - Identify duty cycles (e.g., 8-hour AOS/LOS cycles) and service durations (e.g., 60s release window).

4. **Landing & Deployment Logic**:
    - **Geographic Precision**: Catalog landing accuracy (m), effective slope limits (degrees), and rock hazard tolerances (m).
    - **Solar Logic**: Distinguish between Top-mounted (equatorial/mid-lat) and Side-mounted (polar) configurations.
    - **Deployment (Egress)**: Document Safe/Arm/Fire logic, separation velocities (e.g., 0.04 m/s in orbit), and verification methods (visual/telemetry).

5. **Mission Trajectory & Orbits**:
    - Detail specific parking/deployment orbits (LO1/LO2/LO3) with altitudes (km) and durations (hours).
    - Map the descent profile from coasting to terminal nadir (m).

6. **Service Economics**:
    - Standard pricing per kg (Orbit/Surface/Rover).
    - Auxiliary services (e.g., DHL MoonBox) and small payload (<1kg) surcharges.

7. **Avionics & Software Architecture**:
    - **Computing**: Extract flight processor types (e.g., LEON3 FT 32-bit), and identify if a separate **Payload Computer** (e.g., FPGA-based) manages customer interfaces.
    - **Telemetry Path**: Document how data is handled (e.g., "Transparent VPN Tunneling" vs. "Command Processing"). Note support for end-to-end encryption.
    - **Power Rail**: Capture the standard voltage (e.g., 28 Vdc) and whether it is regulated or unregulated.

8. **Integration & Documentation Suite**:
    - **Milestones**: Catalog the full mission review sequence in "L-Minus Months":
        - **PDR/CDR**: Design phase reviews.
        - **PAR**: Payload Acceptance Review (L-9).
        - **SIR/TRR/ORR**: Readiness reviews for integration, testing, and operations.
    - **Required Documents**: Check for the full standard suite:
        - **PSA/SOW**: Overarching contract and scope.
        - **IDD/ICD**: Interface standards and payload-specific controls.
        - **PIP/POP**: Integration schedules and handling procedures.

9. **Mechanical Mounting & Mass Accounting**:
    - **Adapter Plates**: Note if adapter plates are required and if their mass counts against the payload allocation.
    - **Physical Interfaces**: Capture bolt patterns (e.g., M5 / 75mm) and grounding requirements (e.g., VPC bonding).

10. **Planetary Protection & Cleanliness**:
    - **Outgassing**: Capture TML (%) and CVCM (%) limits (e.g., NASA standard 1.0%/0.1%).
    - **Ground Purging**: Note if N2 or other purging is supported during integration/pre-launch.
    - **Cleanroom**: Document the ISO classification (e.g., ISO Class 8).

11. **Ground Segment & Operations**:
    - **Mission Control**: Identify the central control hub (e.g., AMCC).
    - **Customer Access**: Document how customers interface (e.g., Remote VPN vs On-site PMCC).
    - **Staffing**: Note any requirements for on-site personnel during the mission.

12. **Landing Site Constraints**:
    - **Solar Timing**: Look for "Hours after sunrise" landing constraints (critical for thermal/battery).
    - **Hazard Limits**: Catalog specific rock height (m) and slope (°) limits.

13. **Source & Entity Context**:
    - Cite PUG versions. Link `provider` to `SPACE_ENTITIES.MD`.

