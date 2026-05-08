---
name: camera-movements
description: Standardized camera movement vocabulary for Veo 3 video generation. Use when creating video prompts that require specific camera movements, cinematography terminology, or when validating camera movement specifications. Provides authoritative reference for 50+ camera movements (Dolly, Arc, Crane, FPV Drone, Whip Pan, etc.) to ensure consistent, production-ready terminology.
---

# Camera Movements Vocabulary

Authoritative reference for Veo 3 camera movement terminology.

## Quick Reference - Most Common Movements

**Basic Movements:**
- **Dolly In/Out** - Camera moves forward/backward on track
- **Pan Left/Right** - Camera rotates horizontally
- **Tilt Up/Down** - Camera rotates vertically
- **Zoom In/Out** - Lens focal length change

**Advanced Movements:**
- **Arc Left/Right** - Camera moves in curved path around subject
- **Crane Up/Down** - Camera moves vertically on boom arm
- **FPV Drone** - First-person view rapid movement
- **Whip Pan** - Extremely fast horizontal pan with motion blur

**Specialty Movements:**
- **Dutch Angle** - Tilted frame for dramatic effect
- **Snorricam** - Camera mounted to subject's body
- **Bullet Time** - Matrix-style frozen moment with camera rotation

## Usage Guidelines

**One Movement Per Beat:** Each timed beat should have ONE dominant camera movement to avoid conflicts.

**Precision Terminology:** Use exact terms from vocabulary to ensure machine interpretation accuracy.

**Conflict Prevention:**
- ❌ WRONG: "Dolly in while arc left" (conflicting movements)
- ✅ CORRECT: "Dolly in" OR "Arc left" (choose one)

## Complete Movement Catalog

For full list of 50+ movements with technical specifications, see: [references/movement-catalog.md](references/movement-catalog.md)

## When to Read Reference

**Load movement-catalog.md when:**
- User requests specific/rare movement type
- Validating movement terminology
- Exploring movement options for scene
- Cross-referencing movement conflicts

**Stay in SKILL.md when:**
- Using common movements (listed above)
- Quick reference needed
- Basic validation only
