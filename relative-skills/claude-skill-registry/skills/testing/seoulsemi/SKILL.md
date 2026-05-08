---
name: seoulsemi
description: Seoul Semiconductor LED MPN encoding patterns, series identification, package extraction, and color decoding. Use when working with Seoul Semi LEDs or SeoulSemiHandler.
---

# Seoul Semiconductor Manufacturer Skill

## Overview

Seoul Semiconductor is a South Korean LED manufacturer producing a wide range of LED products for lighting, automotive, and specialty applications. The company is known for innovative LED technologies including:

- **Acrich** - AC-driven LED modules (no external driver needed)
- **SunLike** - Human-centric lighting LEDs with natural spectrum
- **Z-Power** - High-power LEDs for general illumination
- **WICOP** - Wafer-Level Integrated Chip on PCB (no wire bonding)
- **MJT** - Multi-Junction Technology for high-voltage LEDs
- **UV/IR LEDs** - Specialty LEDs for sterilization, sensing

---

## MPN Structure

Seoul Semiconductor MPNs vary by product family, but follow these general patterns:

### Z-Power Series (High-Power LEDs)
```
Z5-M0-W0-00
│  │  │  │
│  │  │  └── Options/variant
│  │  └── W0 = White color code
│  └── M0 = Power variant (M0, M1, M2)
└── Z5 = Z-Power family, generation 5
```

### Acrich Series (AC-Driven LED Modules)
```
SMJHA-3V1W1P0S0
│     │ │ │ │ │
│     │ │ │ │ └── Options
│     │ │ │ └── P0 = Power factor
│     │ │ └── W1 = Wattage
│     │ └── V1 = Voltage variant
│     └── 3 = Series number
└── SMJHA = Acrich module prefix
```

### SunLike Series (Human-Centric LEDs)
```
SPHWHTL3D50YE3KPH
│   │   │ │ │ │ │
│   │   │ │ │ │ └── Options (PH=tape/reel)
│   │   │ │ │ └── KP = Package variant
│   │   │ │ └── E3 = Efficiency bin
│   │   │ └── Y = Color bin
│   │   └── 50 = CCT (5000K)
│   └── HTL3D = Series variant
└── SPH = SunLike prefix
```

### Standard White LEDs (STW/STN Series)
```
STW9Q14C-W9
│  │    │ │
│  │    │ └── W9 = Color temperature bin
│  │    └── C = Variant
│  └── 9Q14 = Series identifier
└── STW = Standard White prefix (STN = Neutral)
```

### UV LEDs (CUD Series)
```
CUD6GF1B
│  │││ │
│  │││ └── B = Bin/variant
│  ││└── 1 = Generation
│  │└── F = Package
│  └── 6G = Power/wavelength class
└── CUD = UV LED prefix
```

---

## Product Family Prefixes

| Prefix | Product Family | Description |
|--------|---------------|-------------|
| Z5, Z4 | Z-Power | High-power LEDs for general lighting |
| SMJHA | Acrich | AC-driven LED modules |
| SPH | SunLike | Human-centric spectrum LEDs |
| STW | Standard White | General purpose white LEDs |
| STN | Standard Neutral | Neutral white LEDs |
| CUD | UV LED | Ultraviolet LEDs (UVA, UVB, UVC) |
| SFH | Infrared | IR LEDs and emitters |
| W | WICOP | Wafer-level chip-scale package |
| MJT | MJT | Multi-Junction Technology |
| P4, P7 | P-Series | High-power LEDs |
| X | X-Series | Premium high-power LEDs |
| N | N-Series | Niche/specialty LEDs |

---

## Package Codes

### Standard SMD Packages

| Code | Package Size | Description |
|------|--------------|-------------|
| 2835 | 2.8 x 3.5mm | Mid-power SMD |
| 3014 | 3.0 x 1.4mm | Compact SMD |
| 3030 | 3.0 x 3.0mm | Mid-power SMD |
| 3528 | 3.5 x 2.8mm | Standard SMD |
| 3535 | 3.5 x 3.5mm | High-power SMD |
| 5050 | 5.0 x 5.0mm | High-power/RGB |
| 5630 | 5.6 x 3.0mm | High-power SMD |

### Technology-Specific Packages

| Return Value | Description | Series |
|--------------|-------------|--------|
| Ceramic | Ceramic substrate high-power | Z5-M0, Z5-M1, Z5-M2 |
| High-Power | Generic high-power package | Z-Power, P4, P7, X-series |
| Module | Complete LED module | Acrich (SMJHA) |
| CSP | Chip Scale Package | WICOP |
| MJT | Multi-Junction Package | MJT series |
| UV | UV LED package | CUD series |
| IR | Infrared LED package | SFH series |
| SMD | Generic surface mount | STW, STN, SunLike |

---

## Color Codes

### Color Code Extraction

Seoul Semi uses various conventions for color in MPNs:

| Code | Color | Examples |
|------|-------|----------|
| W, WH, WHT | White | `-W0`, `-W-`, `WHT` |
| CW | Cool White | `-CW`, `CW-` |
| WW | Warm White | `-WW`, `WW-` |
| NW | Neutral White | `-NW`, `NW-` |
| R, RD | Red | `-R0`, `RED` |
| G, GR | Green | `-G0`, `GRN` |
| B, BL | Blue | `-B0`, `BLU` |
| Y, YL | Yellow | `-Y0`, `YEL` |
| A, AM | Amber | `-A0`, `AMB` |
| UV | Ultraviolet | `CUD` prefix, `UV` in MPN |
| IR | Infrared | `SFH` prefix |

---

## Series Extraction Rules

The handler extracts series based on the product family:

| Pattern | Series Format | Example |
|---------|---------------|---------|
| Z-Power | `Z5-M0`, `Z5-M1`, `Z5` | `Z5-M0-W0-00` -> `Z5-M0` |
| Acrich | `Acrich` (constant) | `SMJHA3V1W1P0S0` -> `Acrich` |
| SunLike | `SunLike` (constant) | `SPHWHTL3D50YE3KPH` -> `SunLike` |
| UV LED | `CUD6`, `CUD8`, `CUD` | `CUD6GF1B` -> `CUD6` |
| IR LED | `SFH4`, `SFH5`, `SFH` | `SFH4550` -> `SFH4` |
| WICOP | `WICOP` (constant) | `W123456` -> `WICOP` |
| MJT | `MJT` (constant) | `MJT123` -> `MJT` |
| STW/STN | Series code | `STW9Q14C-W9` -> `STW9Q14C` |
| N-Series | `N` + digits | `N20` -> `N20` |
| P-Series | `P4` or `P7` | `P4ABC` -> `P4` |
| X-Series | `X` + digits | `X123` -> `X123` |

---

## Supported Component Types

The handler supports:

| ComponentType | Description |
|---------------|-------------|
| `LED` | Primary type for all LED products |
| `IC` | Secondary registration for pattern matching |

**Note**: All patterns are registered under both `LED` and `IC` types to ensure proper pattern matching in the registry.

---

## Handler Implementation Notes

### Package Code Extraction Priority

The handler checks patterns in a specific order to avoid false positives:

```java
// 1. Check technology-specific patterns FIRST (before embedded size codes)
if (Z_POWER_PATTERN.matches()) return "Ceramic" or "High-Power";
if (ACRICH_PATTERN.matches()) return "Module";
if (WICOP_PATTERN.matches()) return "CSP";
if (MJT_PATTERN.matches()) return "MJT";
if (UV_LED_PATTERN.matches()) return "UV";
if (IR_LED_PATTERN.matches()) return "IR";
if (P_SERIES_PATTERN.matches()) return "High-Power";
if (X_SERIES_PATTERN.matches()) return "High-Power";

// 2. Then check for embedded package sizes in SunLike/STW
if (SUNLIKE_PATTERN.matches() || STW_STN_PATTERN.matches()) {
    // Extract 4-digit size code like "3030", "5050"
    return PACKAGE_CODES.getOrDefault(size, "SMD");
}

// 3. Fallback: check for ANY embedded size code
for (sizeCode : ["3030", "3535", "5050", ...]) {
    if (mpn.contains(sizeCode)) return sizeCode;
}
```

### Color Code Extraction Priority

Color extraction checks specific patterns before generic ones:

```java
// 1. UV/IR first (based on prefix)
if (mpn.startsWith("CUD") || mpn.contains("UV")) return "UV";
if (mpn.startsWith("SFH") || mpn.contains("IR")) return "IR";

// 2. White variants BEFORE generic white
if (contains("-CW") || contains("CW-")) return "CW";  // Cool White
if (contains("-WW") || contains("WW-")) return "WW";  // Warm White
if (contains("-NW") || contains("NW-")) return "NW";  // Neutral White

// 3. Generic white LAST
if (contains("-W0") || contains("-W-") || contains("WHT")) return "W";
```

### Replacement Detection

Two MPNs are considered official replacements if:
1. Same series
2. Same color (or at least one unknown)
3. Same package (or at least one unknown)

---

## Example MPN Decoding

### Z-Power LED
```
Z5-M0-W0-00
├── Series: Z5-M0
├── Package: Ceramic (Z5-M0 variant)
├── Color: W (White)
└── Technology: High-Power LED
```

### Acrich AC Module
```
SMJHA-3V1W1P0S0
├── Series: Acrich
├── Package: Module
├── Color: (not specified in MPN)
└── Technology: AC-Driven
```

### SunLike LED
```
SPHWHTL3D50YE3KPH
├── Series: SunLike
├── Package: SMD (default for SunLike)
├── Color: (encoded in spec fields)
└── Technology: SunLike (Human-Centric)
```

### Standard White LED
```
STW9Q14C-W9
├── Series: STW9Q14C
├── Package: SMD (default)
├── Color: W (White, bin 9)
└── Technology: Standard White
```

### UV LED
```
CUD6GF1B
├── Series: CUD6
├── Package: UV
├── Color: UV (Ultraviolet)
└── Technology: UV LED
```

### Infrared LED
```
SFH4550
├── Series: SFH4
├── Package: IR
├── Color: IR (Infrared)
└── Technology: Infrared LED
```

---

## Related Files

- Handler: `manufacturers/SeoulSemiHandler.java`
- Component types: `ComponentType.LED`, `ComponentType.IC`
- Similarity: `/similarity-led` skill for LED comparison logic

---

## Learnings & Edge Cases

- **Hyphen variations**: Some MPNs have optional hyphens (e.g., `SMJHA3V1W1P0S0` vs `SMJHA-3V1W1P0S0`). Patterns must handle both.
- **Z-Power variants**: Z5-M0, Z5-M1, Z5-M2 are distinct power grades in the same family. M0 is typically lower power.
- **SunLike spectrum**: SunLike LEDs are designed to match natural sunlight spectrum for human-centric lighting.
- **WICOP technology**: No wire bonding or phosphor layer on LED chip - leads to smaller form factor and better thermal performance.
- **Acrich modules**: Self-contained AC LED modules that can run directly from mains voltage without external drivers.
- **CUD UV series**: Numbers after CUD (6, 8) typically indicate wavelength range (e.g., CUD6 = UVC ~275nm).
- **Color code ordering**: When extracting colors, check specific variants (CW, WW, NW) before generic white (W) to avoid false matches.
- **Package embedded in MPN**: SunLike and STW series may have 4-digit package codes embedded (e.g., 3030, 5050). Extract with regex.
- **IC registration**: Patterns are also registered under `ComponentType.IC` to ensure proper pattern matching in the handler factory.

<!-- Add new learnings above this line -->
