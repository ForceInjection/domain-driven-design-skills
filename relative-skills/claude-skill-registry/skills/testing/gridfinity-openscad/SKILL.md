---
name: gridfinity-openscad
description: Interpretive guidance for generating OpenSCAD code for Gridfinity desktop/drawer organizers. Provides pattern selection frameworks, dimensional constraints, and stacking system integration specific to the Gridfinity ecosystem. Use when generating OpenSCAD files for Gridfinity bins, baseplates, or accessories.
---

# Gridfinity OpenSCAD Code Generation

Generates OpenSCAD code for desktop and drawer storage items compatible with Gridfinity (42mm grid, 7mm height units).

## Required Reading Before Generating Code

**Official specifications:**

- **Gridfinity Spec**: https://gridfinity.xyz/specification/ - Official specification (fetch for current details)
- **GitHub Spec**: https://github.com/gridfinity-unofficial/specification - Community-maintained spec

**Pattern references** (read as needed):

- ./common_items/\*.md - Full OpenSCAD modules for each pattern
- home-organization/gridfinity-reference.md - Gridfinity system overview (sibling skill)

## Core Understanding (Critical Architecture)

### What Makes Gridfinity Different From Generic 3D Modeling

**Grid constraint**: All bins align to 42mm × 42mm grid. This affects:

- Bin base dimensions: multiples of 42mm (42, 84, 126, 168mm)
- Actual bin size: 41.5mm per grid unit (0.5mm total tolerance)
- Height units: multiples of 7mm (7, 14, 21, 28mm, etc.)
- Tolerance: 0.25mm per side for proper fit

**Baseplate socket system**: Bins don't sit flat on surface. They:

1. Have base profile that matches Z-shaped socket in baseplate
2. Lock into position but can be reconfigured
3. Require specific base geometry (see ./common_items/basic_bin.md)

**Stacking system**: Bins can stack on top of each other:

- Optional 4.4mm stacking lip at top
- Lip must align with base socket profile
- Height = (N × 7mm) + optional 4.4mm lip

**Critical parameter relationships**:

```openscad
// Core Gridfinity dimensions (NEVER change these)
grid_size = 42;           // Base grid unit
bin_size = 41.5;          // Actual bin dimension (0.5mm tolerance)
height_unit = 7;          // Vertical unit
corner_radius = 3.75;     // Filleted corners
stacking_lip = 4.4;       // Optional lip height

// User parameters
grid_x = 2;               // Grid units wide (2 = 84mm)
grid_y = 3;               // Grid units deep (3 = 126mm)
height_u = 4;             // Height units (4u = 28mm)

// Calculated dimensions
bin_width = bin_size * grid_x;     // 83mm (not 84mm!)
bin_depth = bin_size * grid_y;     // 124.5mm (not 126mm!)
bin_height = height_unit * height_u;  // 28mm
```

**Why this matters**: User requests "2×3×4 bin" but must understand that means 83mm × 124.5mm × 28mm actual size, not 84mm × 126mm × 28mm.

### Cross-System Compatibility (Critical Insight)

**Gridfinity and OpenGrid share 84mm alignment**:

- 2 × Gridfinity (42mm) = 84mm
- 3 × OpenGrid (28mm) = 84mm
- This enables hybrid wall/desktop systems

**Design implication**: When creating combo systems, use 84mm as common denominator for alignment across both standards.

## Pattern Selection Framework (Decision Layer)

### When User Requests Gridfinity Storage

Use this decision tree to select pattern:

| User wants to store                    | Primary pattern                     | Alternative                    | Read module               |
| -------------------------------------- | ----------------------------------- | ------------------------------ | ------------------------- |
| Generic desktop organization           | Basic Bin                           | Divided Bin (if categories)    | basic_bin.md              |
| Sorted small parts (resistors, screws) | Divider Bin                         | Multiple basic bins            | divider_bin.md            |
| Maximum drawer space efficiency        | Basic Bin (exact drawer dimensions) | Lite Bin (vase mode)           | basic_bin.md, lite_bin.md |
| Rapid printing / minimal filament      | Lite Bin                            | Basic Bin (if strength needed) | lite_bin.md               |
| Custom baseplate for drawer/desk       | Baseplate                           | N/A                            | baseplate.md              |

### When Pattern Is Unclear

**Ask these questions:**

1. **Environment**: Desktop (stability matters) or drawer (fit matters)?
2. **Item type**: Similar items (basic bin) or mixed categories (dividers)?
3. **Print time priority**: Need it fast (lite bin) or strong (basic bin)?
4. **Customization**: Standard sizes or specific drawer dimensions?

**Default**: When unclear, use Basic Bin - most versatile, user can refine.

## Code Generation Best Practices

### Parameter Organization

**Always declare these parameters** at top of file:

```openscad
// Grid dimensions (what user specifies)
grid_x = 2;              // Grid units wide (1 unit = 42mm)
grid_y = 3;              // Grid units deep
height_u = 4;            // Height units (1u = 7mm)

// Gridfinity constants (NEVER change)
grid_size = 42;          // Standard grid spacing
bin_size = 41.5;         // Actual bin size (0.5mm tolerance)
height_unit = 7;         // Height increment
corner_radius = 3.75;    // Fillet radius

// Structural parameters (print quality)
wall_thickness = 2.0;    // 1.6-2.4mm typical for bins
base_thickness = 2.0;    // First layer above base profile

// Optional features
include_stacking_lip = true;   // Add 4.4mm lip for stacking
include_magnets = false;        // Add magnet holes (6mm × 2mm)
include_label = false;          // Add label recess
```

**Why this order**: User dimensions first (grid units), then ecosystem constants, then structural parameters, then optional features.

### Base Profile Integration Pattern

**Every bin needs proper base profile**. Standard integration:

```openscad
module gridfinity_base_profile() {
    // Z-shaped profile that locks into baseplate
    // See ./common_items/basic_bin.md for complete module
    // First ~5mm of bin height is dedicated to base
}

union() {
    // Base profile (required)
    gridfinity_base_profile();

    // Bin body above base
    translate([0, 0, 5])  // Start above base profile
        bin_body();

    // Optional stacking lip at top
    if (include_stacking_lip) {
        translate([0, 0, bin_height])
            stacking_lip();
    }
}
```

**Common mistake**: Ignoring base profile and creating flat-bottom bin. Won't lock into baseplate.

### Grid Unit Reasoning

**When user says "I need a bin for X"**:

1. **Estimate grid dimensions** for their items:

   - Small parts (screws, resistors): 1×1 or 2×1 (42mm or 84mm)
   - Tools (pliers, cutters): 2×2 or 3×2 (84mm × 84mm or 126mm × 84mm)
   - Desk supplies (tape, scissors): 2×3 or 3×3 (84mm × 126mm or 126mm × 126mm)

2. **Calculate actual bin dimensions**:

   ```openscad
   actual_width = bin_size * grid_x;   // 41.5mm per unit
   actual_depth = bin_size * grid_y;
   actual_height = height_unit * height_u;
   ```

3. **Calculate usable interior**:

   ```openscad
   interior_width = actual_width - wall_thickness*2;
   interior_depth = actual_depth - wall_thickness*2;
   interior_height = actual_height - base_thickness;  // Minus base profile

   // First height unit loses ~5mm to base profile
   // So 4u (28mm) bin has ~23mm usable height
   ```

4. **Inform user of actual dimensions**:

   - "2×3×4u bin = 83mm × 124.5mm × 28mm exterior"
   - "Usable interior ≈ 79mm × 120.5mm × 23mm (with 2mm walls)"

### Height Unit Considerations

**Critical understanding**: First height unit is partially consumed by base profile.

```openscad
// Height budget for 1u (7mm) bin:
// - ~5mm: Base profile (socket engagement)
// - ~2mm: Usable interior height
// Result: 1u bins are VERY shallow, rarely practical

// Recommended minimum: 3u (21mm)
// - ~5mm: Base profile
// - ~2mm: Base thickness above profile
// - ~14mm: Usable interior
// Result: Enough space for most small items
```

**Guidance**: Suggest minimum 3u for functional bins, unless user specifically needs shallow compartments.

### Pattern Module Integration

**Read the module file, don't reinvent**. Each pattern has complete module in ./common_items/:

```openscad
// DON'T write basic_bin() from scratch
// DO read ./common_items/basic_bin.md and use/adapt the module

// Option 1: Include external file
include <modules/gridfinity_modules.scad>
basic_bin(grid_x=2, grid_y=3, height_u=4);

// Option 2: Paste module directly (user preference)
[paste module from basic_bin.md]
basic_bin(grid_x=2, grid_y=3, height_u=4);
```

**When to adapt vs use as-is**:

- **Use as-is**: Standard bin in standard size
- **Adapt dimensions**: Different grid units or height
- **Enhance**: Add dividers, label recess, magnet holes
- **Hybrid**: Baseplate with custom grid pattern

## Optional Features (When Requested)

**Only add features if**:

1. User explicitly requests (e.g., "with magnets")
2. Use case clearly requires (e.g., metal desktop → magnets helpful)
3. You ask and confirm

**Available features**:

### Magnets (6mm × 2mm)

```openscad
// Four corners of each grid unit
translate([corner_offset, corner_offset, -0.1])
    cylinder(d=6, h=2.1, $fn=30);
```

**Placement**: At corners of each 42mm grid square, 8mm from edges.

### Stacking Lip (4.4mm)

```openscad
// At top of bin, mirrors base profile inverted
translate([0, 0, bin_height])
    stacking_lip();  // See basic_bin.md for module
```

**Critical**: Lip must match base profile geometry for proper stacking.

### Label Recess

```openscad
// Front face, typically 45° overhang (no supports)
translate([bin_width/2, 0, bin_height - 8])
    rotate([45, 0, 0])
        cube([bin_width*0.6, 10, 10], center=true);
```

**Design consideration**: Also serves as finger grip for lifting bin.

### Screw Holes (Alternative to Magnets)

```openscad
// M3 screw holes at corners
translate([corner_offset, corner_offset, -0.1])
    cylinder(d=3.2, h=base_thickness+0.2, $fn=20);
```

**Use case**: Non-magnetic surfaces or extra-strong anchoring.

## Common Pitfalls

### Pitfall #1: Ignoring Tolerance (Using 42mm Instead of 41.5mm)

**Problem**: User requests "2×2 bin", code uses 84mm × 84mm dimensions, bin doesn't fit baseplate socket.

**Why it fails**: Grid spacing is 42mm, but bin size must be 41.5mm to allow 0.5mm tolerance for fit.

**Better approach**:

```openscad
// DON'T:
bin_width = 42 * grid_x;  // Results in too-tight fit

// DO:
bin_width = 41.5 * grid_x;  // Proper tolerance
```

### Pitfall #2: Forgetting Base Profile Height Budget

**Problem**: User wants 1u (7mm) bin for small parts, code generates bin, but interior is < 2mm tall and useless.

**Why it fails**: ~5mm of first height unit is consumed by base socket profile.

**Better approach**:

```openscad
// When user requests 1u bin:
echo("WARNING: 1u bins have only ~2mm usable interior.");
echo("Recommend minimum 3u (21mm) for functional storage.");

// Suggest alternative
height_u = 3;  // Override to practical minimum
```

### Pitfall #3: Flat Bottom (No Socket Profile)

**Problem**: Code creates bin with flat bottom, looks correct in preview, but won't lock into baseplate.

**Why it fails**: Gridfinity requires specific Z-shaped base profile for socket engagement.

**Better approach**:

```openscad
// DON'T: Start with flat cube
cube([bin_width, bin_depth, bin_height]);

// DO: Use proper base module
gridfinity_base_profile();  // Required locking geometry
translate([0, 0, 5])
    bin_walls();  // Bin body above base
```

### Pitfall #4: Incorrect Stacking Lip Geometry

**Problem**: User wants stackable bins, code adds simple rim at top, but bins don't stack properly.

**Why it fails**: Stacking lip must be inverted mirror of base profile for proper engagement.

**Better approach**:

```openscad
// DON'T: Add simple cylinder rim
translate([0, 0, bin_height])
    cylinder(r=40, h=4.4);  // Wrong geometry

// DO: Use proper stacking lip module
translate([0, 0, bin_height])
    stacking_lip();  // Mirrors base profile inverted
```

### Pitfall #5: Hardcoding Instead of Parameterizing

**Problem**: Module has magic numbers scattered throughout instead of grid-based calculations.

**Why it fails**: User can't easily adjust to different sizes; violates Gridfinity modularity principle.

**Better approach**:

```openscad
// DON'T:
cube([83, 124.5, 28]);  // What grid size is this?

// DO:
cube([
    bin_size * grid_x,
    bin_size * grid_y,
    height_unit * height_u
]);
```

## Quality Checklist

**Before delivering OpenSCAD code:**

**Required elements:**

- ✓ Parameters defined clearly (grid_x, grid_y, height_u)
- ✓ Gridfinity constants correct (42mm grid, 41.5mm bin, 7mm height, 3.75mm radius)
- ✓ Proper base profile integrated (not flat bottom)
- ✓ Tolerance applied (41.5mm per unit, not 42mm)
- ✓ Height budget communicated (first ~5mm for base profile)

**Dimensional accuracy:**

- ✓ Bin dimensions use 41.5mm per grid unit (not 42mm)
- ✓ Height uses 7mm per unit
- ✓ Corner radius is 3.75mm
- ✓ Magnet holes are 6mm × 2mm (if included)
- ✓ Stacking lip is 4.4mm (if included)

**Pattern compliance:**

- ✓ Used appropriate pattern from decision framework
- ✓ Read module from ./common_items/ (didn't reinvent from scratch)
- ✓ Optional features only included if requested/clearly needed
- ✓ Base profile geometry matches specification

**Code quality:**

- ✓ Parameterized (no magic numbers)
- ✓ Clear variable names (grid_x not gx)
- ✓ Module structure (reusable components)
- ✓ `$fn` specified for cylinders/curves (e.g., `$fn=40`)
- ✓ Comments explain Gridfinity-specific constraints

**User communication:**

- ✓ Explained pattern choice
- ✓ Stated grid dimensions and actual mm dimensions
- ✓ Communicated usable interior space
- ✓ Warned if height too shallow (< 3u)
- ✓ Noted optional features if applicable to use case

## Module Reference Structure

**Pattern modules** are organized as:

```
./common_items/
├── basic_bin.md           - Standard Gridfinity bin (most common)
├── baseplate.md           - Grid baseplate with sockets
├── divider_bin.md         - Bin with internal compartments
└── lite_bin.md            - Thin-wall vase mode variant

```

**Workflow**:

1. Use decision framework to select pattern
2. Read selected pattern's .md file
3. Adapt grid dimensions to user's needs
4. Calculate actual dimensions (41.5mm per unit)
5. Verify height budget (minimum 3u recommended)
6. Add optional features if requested
7. Validate with checklist

## Cross-System Integration

### Gridfinity + OpenGrid Hybrid Systems

**84mm alignment** enables combining systems:

```openscad
// 2×2 Gridfinity baseplate (84mm × 84mm)
gridfinity_baseplate(grid_x=2, grid_y=2);

// Same width as 3-slot OpenGrid item (3 × 28mm = 84mm)
// Can mount side-by-side on shared 84mm width surface
```

**Use case**: Desktop organization (Gridfinity bins) with wall-mounted tool storage (OpenGrid) sharing common width alignment for visual coherence.

**Design consideration**: When creating hybrid workspace, use 84mm width increments for alignment across both systems.

## Documentation References

**Gridfinity Ecosystem**:

- Gridfinity: 42mm grid system for desktop/drawer organization
- Open standard, MIT license
- Community-driven with extensive ecosystem
- This skill focuses on CODE GENERATION for Gridfinity items

**Related skills**:

- home-organization/SKILL.md - When to use Gridfinity vs other systems (NOT code generation)
- opengrid-openscad/SKILL.md - OpenGrid code generation (wall-mounted items)
- For system selection guidance, defer to home-organization skill
- This skill is only for "generate OpenSCAD code for Gridfinity items"

**Official resources**:

- https://gridfinity.xyz/specification/ - Official specification
- https://github.com/gridfinity-unofficial/specification - Community spec
- https://gridfinitygenerator.com/ - Online generator (reference for patterns)
