---
name: opengrid-openscad
description: Interpretive guidance for generating OpenSCAD code for OpenGrid/MultiConnect wall-mounted organizers. Provides pattern selection frameworks, mounting system integration, and dimensional constraints specific to this ecosystem. Use when generating OpenSCAD files for OpenGrid items.
---

# OpenGrid OpenSCAD Code Generation

Generates OpenSCAD code for wall-mounted storage items compatible with OpenGrid boards (28mm grid) and MultiConnect mounting system.

## Required Reading Before Generating Code

**Official specifications:**

- **OpenGrid Spec**: 28mm grid spacing standard
- **MultiConnect Mounting**: Slotted backplate system using `multiconnectBack()` module (see ./common_items/backplate_mount.md)

**Pattern references** (read as needed):

- ./common_items/\*.md - Full OpenSCAD modules for each pattern
- ./enhancements.md - Optional feature modules

## Core Understanding (Critical Architecture)

### What Makes OpenGrid Different From Generic 3D Modeling

**Grid constraint**: All items must align to 28mm grid. This affects:

- Mounting backplate width (multiples of 28mm via `distanceBetweenSlots=28`)
- Horizontal dimensions should consider grid alignment for aesthetic consistency
- Vertical dimensions are unconstrained

**MultiConnect mounting system**: Items don't attach directly to wall. They:

1. Have slotted backplate created by `multiconnectBack(width, height, 28)`
2. Slide onto MultiConnect connectors mounted to OpenGrid board
3. Can be repositioned without tools

**Critical parameter relationships**:

```openscad
// These are interdependent:
backWidth = internal_width + wall_thickness*2;  // Total object width
slotCount = floor(backWidth/28);                // Number of connectors
actual_slots = max(1, slotCount);               // Minimum 1 slot
```

**Why this matters**: User requests "50mm wide bin" but code must account for walls, ensure at least one mounting slot, and ideally align to grid aesthetically.

## Pattern Selection Framework (Decision Layer)

### When User Requests Storage

Use this decision tree to select pattern:

| User wants to store               | Primary pattern        | Alternative                               | Read module                                      |
| --------------------------------- | ---------------------- | ----------------------------------------- | ------------------------------------------------ |
| Small hardware (screws, bits)     | Basic Bin              | Shallow Tray (if flat)                    | basic_bin.md                                     |
| Writing tools (pens, markers)     | Vertical Holder        | Angled Storage Row (if visibility needed) | vertical_holder.md, angled_storage_row.md        |
| Hand tools (screwdrivers, pliers) | Tool Holder with Hooks | Angled Storage Row                        | tool_holder_with_hooks.md, angled_storage_row.md |
| Bottles, spray cans               | Round Item Holder      | Advanced Bin (if accessibility needed)    | round_item_holder.md, advanced_bin.md            |
| Mixed items in sections           | Divided Bin            | Multiple basic bins                       | divided_bin.md                                   |
| Light shelving needs              | Shelf Bracket          | N/A                                       | shelf_bracket.md                                 |
| Easy-access items (cables, tape)  | Open Basket            | Multi-Access Holder                       | open_basket.md, multi_access_holder.md           |
| Keys, lightweight hangables       | Hook Array             | Curved Hook (for smooth finish)           | hook_array.md, curved_hook.md                    |
| Phone/charger/electronics         | Multi-Access Holder    | Advanced Bin                              | multi_access_holder.md, advanced_bin.md          |
| Items needing angled visibility   | Angled Storage Row     | Basic Bin                                 | angled_storage_row.md                            |
| Professional-quality bins         | Advanced Bin           | Basic Bin                                 | advanced_bin.md                                  |

### When Pattern Is Unclear

**Ask these questions:**

1. **Access pattern**: Top access (bin), side access (basket), or hanging (hooks)?
2. **Item orientation**: Vertical storage or horizontal?
3. **Item count**: Single type or mixed organization?
4. **Visibility**: Need to see contents from front?
5. **Quality level**: Quick prototype (basic patterns) or production quality (advanced patterns with BOSL2)?

**Default**: When unclear, use Basic Bin - most versatile, user can refine.

## Tolerance Tuning (Printer Calibration)

QuackWorks patterns provide calibration parameters for perfect fit across different printers:

| Parameter                | Range        | Default | Purpose                            |
| ------------------------ | ------------ | ------- | ---------------------------------- |
| slotTolerance            | 0.925-1.075  | 1.00    | Scale slot width (tight/loose fit) |
| dimpleScale              | 0.5-1.5      | 1.0     | Scale dimple size (snap strength)  |
| slotDepthMicroadjustment | -0.5 to +0.5 | 0       | Fine-tune slot depth               |

**Calibration Process:**

1. Print test piece with default values (`slotTolerance=1.00`)
2. If slots too loose (item slides off): decrease by 0.01-0.02
3. If slots too tight (hard to mount): increase by 0.01-0.02
4. Adjust `dimpleScale` for snap strength (v1) or triangle lock (v2)
5. Use `slotDepthMicroadjustment` for final fine-tuning

**When to tune:**

- New printer or filament type
- Temperature changes affecting dimensional accuracy
- Switching between PLA/PETG/ABS
- First print on a new OpenGrid system

## On-Ramp System

On-ramps are conical guides that ease mounting of heavy or tall items onto MultiConnect slots:

| Parameter             | Default | Purpose                                           |
| --------------------- | ------- | ------------------------------------------------- |
| onRampEnabled         | true    | Add guide cones to slots                          |
| On_Ramp_Every_X_Slots | 2       | Frequency (1=every slot, 2=every 2nd slot)        |
| onRampHalfOffset      | false   | Stagger ramps between grid points for better grip |

**When to enable:**

- Large/heavy items needing positioning help
- Tall items that are hard to align while lifting
- Items mounted high on wall (harder to see slots)

**When to disable:**

- Small, lightweight items
- Frequently repositioned items (ramps add friction)
- Minimal profile needed (ramps add material)

**Visual:**

```text
Without ramps:     With ramps:
    ║                  ║▲
    ║                  ║ ▲
────╫────         ────╫──▲────
    ║                  ║   ▲
```

Ramps guide item onto slots, especially helpful when you can't see the back of the item.

## Mounting Options Beyond Basic MultiConnect

QuackWorks supports multiple mounting systems. Choose based on your wall setup:

| Option          | Back Thickness | Grid    | Use Case                           |
| --------------- | -------------- | ------- | ---------------------------------- |
| Multiconnect V1 | 6.5mm          | 25/28mm | Standard, dimple-based hold        |
| Multiconnect V2 | 6.5mm          | 25/28mm | Triangle snap, stronger hold       |
| Multipoint      | 4.8mm          | 25mm    | Thinner profile, Multiboard system |
| GOEWS           | 7mm            | Custom  | Alternative slot design            |
| Command Strip   | N/A            | N/A     | Adhesive mount, rental-friendly    |

### Multiconnect V2 vs V1

**V2 advantages:**

- Triangle cutouts in slots create mechanical lock
- Stronger hold for heavier items
- More positive "snap" feedback when mounted

**V2 parameter:**

```openscad
multiConnectVersion = "v2";  // or "v1"
slotQuickRelease = false;    // Set true to disable triangle locks
```

**When to use V2:**

- Heavy items (>500g)
- Items that vibrate or move (power tools, fans)
- Production designs (better user experience)

**When to use V1:**

- Existing V1 connector infrastructure
- Frequently repositioned items (easier release)
- Prototyping (simpler geometry)

## Code Generation Best Practices

### Parameter Organization

**Always declare these parameters** at top of file:

```openscad
// User-facing dimensions (what they care about)
internal_width = 80;    // Interior space for items
internal_depth = 60;
internal_height = 60;

// Structural parameters (print quality)
wall_thickness = 2.5;   // 2.5-3mm for PETG/PLA
base_thickness = 2.5;

// Mounting parameters (OpenGrid specific)
distanceBetweenSlots = 28;  // ALWAYS 28 for OpenGrid
```

**Why this order**: User dimensions first (what they specified), then structural (printer constraints), then ecosystem constants.

### Mounting Integration Pattern

**Every item needs mounting**. Standard integration:

```openscad
union() {
    // Your item (bin, holder, etc.)
    basic_bin();  // or other pattern

    // MultiConnect backplate
    translate([0, 0, 0])
        multiconnectBack(
            backWidth = internal_width + wall_thickness*2,
            backHeight = internal_height + 20,  // Extend above for strength
            distanceBetweenSlots = 28           // Always 28
        );
}
```

**Common mistake**: Forgetting to extend backplate above item for structural strength. Backplate should be ~20mm taller than internal_height.

### Dimensional Reasoning

**When user says "I need a bin for X"**:

1. **Estimate internal dimensions** for their items:

   - Small screws/bits: 50×40×40mm internal
   - Markers/pens vertical: 15mm diameter × 70mm deep
   - Screwdrivers horizontal: 60mm hook length
   - Spray cans: 80×80×120mm internal

2. **Calculate total dimensions**:

   ```openscad
   total_width = internal_width + wall_thickness*2;
   total_depth = internal_depth + wall_thickness;
   total_height = internal_height;  // No top wall on bins
   ```

3. **Check grid alignment** (optional but aesthetic):

   - Is total_width close to 28mm multiple? (28, 56, 84, 112mm)
   - If yes, mention to user as "this will align nicely to grid"
   - If no, not critical - mounting still works

### Pattern Module Integration

**Read the module file, don't reinvent**. Each pattern has complete module in ./common_items/:

```openscad
// DON'T write basic_bin() from scratch
// DO read ./common_items/basic_bin.md and use/adapt the module

include <path/to/modules.scad>  // If organized
// OR paste module directly (user preference)

basic_bin();  // Call the module
```

**When to adapt vs use as-is**:

- **Use as-is**: Pattern matches user need exactly
- **Adapt dimensions**: User needs different size (pass parameters)
- **Enhance**: User wants label recess, drainage, etc. (use ./enhancements.md)
- **Hybrid**: Combine patterns (divided_bin calls basic_bin)

## BOSL2 Integration (Advanced Patterns)

QuackWorks uses BOSL2 library heavily for advanced geometry. Key patterns:

### rect_tube() for bins (vs manual cube subtraction)

**Instead of manual operations:**

```openscad
// Old way (basic_bin.md)
difference() {
    cube([width, depth, height]);
    translate([wall, wall, base])
        cube([width-wall*2, depth-wall, height]);
}
```

**Use BOSL2:**

```openscad
include <BOSL2/std.scad>

rect_tube(
    size = [width, depth],
    h = height,
    wall = 2,
    chamfer = [5, 0, 0, 0],    // Front, back, left, right
    ichamfer = [2, 0, 0, 0]    // Interior chamfers
)
```

**Benefits**: Cleaner code, automatic chamfering, consistent wall thickness, better performance.

### hull() for curved supports

Creates smooth transitions between shapes:

```openscad
hull() {
    // Item rim (curved holder)
    cylinder(d=30, h=10);

    // Back anchor (mounting plate)
    translate([0, -20, 0])
        cube([30, 5, 10]);
}
```

Generates smooth curve connecting rim to backplate.

### offset3d() for edge rounding

**Instead of manual chamfers:**

```openscad
offset3d(r = 0.5)  // Rounds ALL edges by 0.5mm
    cube([100, 50, 60]);
```

Used in `multi_access_holder.md` for professional finish.

### When to use BOSL2 patterns

**Use BOSL2 (advanced_bin, multi_access_holder, curved_hook) when:**

- User requests production-quality design
- Need professional finish (chamfers, rounded edges)
- Complex geometry (curved hooks, angled bins)
- BOSL2 already installed in environment

**Use basic patterns (basic_bin, vertical_holder) when:**

- Quick prototyping
- User unfamiliar with BOSL2
- Simple geometry sufficient
- Minimal dependencies preferred

**Installing BOSL2:**

```openscad
// Add to top of file:
include <BOSL2/std.scad>
```

User must have BOSL2 library installed. Provide link: <https://github.com/BelfrySCAD/BOSL2>

## Enhancement Integration (When Requested)

**Only add enhancements if**:

1. User explicitly requests (e.g., "with drainage holes")
2. Use case clearly requires (e.g., spray bottle storage → drainage likely helpful)
3. You ask and confirm

**Available enhancements** (see ./enhancements.md for modules):

- **Label recess**: Angled cutout on front for labels (no support needed)
- **Drainage holes**: Grid of holes in floor for wet items
- **Rounded corners**: Hull-based smoothing for cleaning ease
- **Finger scoop**: Cylindrical cutout in front wall for access

**Integration pattern**:

```openscad
difference() {
    basic_bin();           // Base pattern

    // Enhancement as subtraction
    translate([...])
        label_recess(width=40, height=10);
}
```

## Common Pitfalls

### Pitfall #1: Insufficient Mounting Slots

**Problem**: User requests 40mm wide bin, code generates backWidth=45mm (40 + 2.5×2), results in floor(45/28)=1 slot. Bin is wider than one grid space but only has one connector - looks odd and may be unstable.

**Why it fails**: Didn't consider aesthetic/structural mismatch between item width and mounting points.

**Better approach**:

```openscad
// Either: Adjust dimensions to align to grid
internal_width = 51;  // 51 + 5 = 56mm = 2 grid spaces = 2 slots

// Or: Accept 1 slot but mention to user
echo("Note: 45mm width uses 1 mounting slot. For 2 slots, increase width to ~51mm");
```

### Pitfall #2: Forgetting Clearances

**Problem**: User wants vertical holder for 12mm pens, code uses `cylinder(d=12)`, pens don't fit.

**Why it fails**: No clearance for print tolerance and item variation.

**Better approach**:

```openscad
item_diameter = 12;
clearance = 1;  // 0.5mm per side
cylinder(d = item_diameter + clearance, $fn=40);
```

### Pitfall #3: Hardcoding Instead of Parameterizing

**Problem**: Module has magic numbers scattered throughout instead of calculated values.

**Why it fails**: User can't easily adjust; values get out of sync.

**Better approach**:

```openscad
// DON'T:
cube([82.5, 62.5, 60]);  // What are these numbers?

// DO:
cube([
    internal_width + wall_thickness*2,
    internal_depth + wall_thickness,
    internal_height
]);
```

### Pitfall #4: Overcomplicating Simple Requests

**Problem**: User wants basic bin, code generates elaborate parametric system with 15 parameters.

**Why it fails**: User just wanted a bin. Over-engineering delays delivery.

**Better approach**: Start simple, add complexity only when requested:

```openscad
// First iteration: Basic bin with hardcoded dimensions
internal_width = 80;
// ...

// Later if user wants variants: Parameterize
module customizable_bin(width=80, depth=60, height=60) { ... }
```

### Pitfall #5: Wrong Pattern for Use Case

**Problem**: User wants angled storage for screwdrivers, code generates basic vertical_holder.

**Why it fails**: Missed opportunity to suggest better pattern (angled_storage_row provides visibility).

**Better approach**: Use decision framework, suggest alternatives:

```text
"I'll create an angled_storage_row for your screwdrivers - this tilts them 30° for better visibility.
If you prefer vertical storage (more compact), I can use vertical_holder instead."
```

## Quality Checklist

**Before delivering OpenSCAD code:**

**Required elements:**

- ✓ Parameters clearly defined (internal dimensions, wall thickness, mounting parameters)
- ✓ MultiConnect backplate integrated via `multiconnectBack()`
- ✓ `distanceBetweenSlots = 28` (never other value for OpenGrid)
- ✓ Clearances added where items fit into holes/slots
- ✓ Comments explain key calculations (slot count, dimensions)

**Pattern compliance:**

- ✓ Used appropriate pattern from decision framework
- ✓ Read module from ./common_items/ (didn't reinvent from scratch)
- ✓ Enhancements only included if requested/clearly needed
- ✓ BOSL2 patterns used when appropriate (production quality, complex geometry)

**Dimensional sanity:**

- ✓ Internal dimensions match user's items
- ✓ Total width accounts for walls: `internal + wall_thickness*2`
- ✓ Backplate height extends ~20mm above item for strength
- ✓ At least 1 mounting slot: `floor(backWidth/28) >= 1`

**Code quality:**

- ✓ Parameterized (no magic numbers)
- ✓ Clear variable names (internal_width not iw)
- ✓ Module structure (reusable components)
- ✓ `$fn` specified for cylinders/curves (e.g., `$fn=40`)

**User communication:**

- ✓ Explained pattern choice
- ✓ Stated assumed dimensions if user was vague
- ✓ Noted grid alignment if relevant
- ✓ Mentioned enhancements if applicable to use case
- ✓ Suggested QuackWorks advanced features if production quality needed

## Module Reference Structure

**Pattern modules** are organized as:

```text
./common_items/
├── backplate_mount.md            - multiconnectBack() module (ALWAYS needed)
├── basic_bin.md                  - Open-top bin (most common)
├── advanced_bin.md               - BOSL2 bin with angled front, chamfers
├── vertical_holder.md            - Cylindrical holes for pens/bits/etc.
├── angled_storage_row.md         - Tilted multi-item storage for visibility
├── round_item_holder.md          - Single round/rectangular item with rim
├── tool_holder_with_hooks.md     - Horizontal cantilever hooks
├── curved_hook.md                - BOSL2 curved hook with rounded edges
├── divided_bin.md                - Bin with internal dividers
├── shallow_tray.md               - Low-profile bin variant
├── shelf_bracket.md              - Triangular shelf support
├── open_basket.md                - Bin without front wall
├── multi_access_holder.md        - BOSL2 box with customizable cutouts
├── angled_storage.md             - Forward-tilting bin (deprecated, use angled_storage_row)
└── hook_array.md                 - Simple hook row

./enhancements.md                 - Optional features (labels, drainage, etc.)
```

**Workflow**:

1. Use decision framework to select pattern
2. Read selected pattern's .md file
3. Adapt dimensions to user's needs
4. Integrate multiconnectBack() mounting
5. Add enhancements if requested
6. Validate with checklist

## Documentation References

**OpenGrid Ecosystem**:

- OpenGrid: 28mm grid system for wall organization
- MultiConnect: Slotted mounting system (tool-free repositioning)
- This skill focuses on CODE GENERATION for these systems

**QuackWorks Repository (Advanced Patterns)**:

- **GitHub**: <https://github.com/AndyLevesque/QuackWorks>
- **VerticalMountingSeries**: Advanced bins, hooks, holders with BOSL2
- **Modules**: Core generators (multiconnectGenerator, snapConnector)
- **License**: CC BY-NC-SA 4.0

**When generating advanced patterns**, fetch current QuackWorks code for latest parameters and features. Patterns evolve with community contributions.

**Key QuackWorks files referenced**:

- `MultiConnectRoundSingleHolder.scad` → round_item_holder.md
- `MultiConnectRoundRow.scad` → angled_storage_row.md
- `MultiConnectRoundHook.scad` → curved_hook.md
- `MulticonnectBin.scad` → advanced_bin.md
- `VerticalItemHolder.scad` → multi_access_holder.md

**Related skills**:

- home-organization/SKILL.md - When to use OpenGrid vs other systems (NOT code generation)
- For system selection guidance, defer to that skill
- This skill is only for "generate OpenSCAD code for OpenGrid items"
