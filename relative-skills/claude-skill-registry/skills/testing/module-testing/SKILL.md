---
name: module-testing
description: Automated validation suite for VCV Rack modules
allowed-tools:
  - Read
  - Bash
  - Task # For deep-research on failures
preconditions:
  - Module must exist
  - Module status must NOT be 💡 (must have implementation)
---

# module-testing Skill

**Purpose:** Validate VCV Rack modules through build verification, configuration validation, and manual testing protocols.

## Workflow Overview

This skill provides validation modes for VCV Rack modules:

1. **Build Verification** (~1 min) - Quick build check
2. **Configuration Validation** (~2 min) - plugin.json and SVG panel validation
3. **Manual Testing Protocol** (~30-60 min) - Guided testing checklist (polyphony, CV, sample rates)

**Note:** VCV Rack has no equivalent to pluginval. Manual testing is the primary validation method.

## Phase 1: Detect Module and Mode Selection

**Input:** User invokes `/test [ModuleName]` or asks to test a module

**Steps:**

1. Parse module name from user input
2. Verify module exists in `MODULES.md`
3. Check module status - must NOT be 💡 (must have implementation)

**If mode not specified, present decision menu:**

```
How would you like to test [ModuleName]?

1. Build verification (~1 min)
   → Quick check that module compiles successfully
   → Requires: Source code, Makefile, RACK_DIR set

2. Configuration validation (~2 min)
   → Validate plugin.json format and SVG panel dimensions
   → Check: Slug format, version format, panel dimensions
   → Requires: plugin.json, SVG panel file

3. Manual testing protocol (~30-60 min) ⭐ RECOMMENDED
   → Guided checklist for real-world testing
   → Tests: Polyphony, CV modulation, sample rates, sonic quality
   → Requires: VCV Rack installed

4. Skip testing (NOT RECOMMENDED)
   → Proceed to installation without validation

Choose (1-4): _
```

**Recommendation logic:**

- For new modules: Suggest option 1 first, then 2, then 3
- Before final release: Always suggest option 2 + 3
- For improvements: Suggest option 3 (manual testing)

**Parse shorthand commands:**

- `/test [ModuleName] build` → Jump to Mode 1
- `/test [ModuleName] config` → Jump to Mode 2
- `/test [ModuleName] manual` → Jump to Mode 3

## Phase 2: Execute Test Mode

### Mode 1: Build Verification

**Purpose:** Quickly verify that module compiles without errors

**Prerequisites check:**

```bash
# Check RACK_DIR environment variable
if [[ -z "$RACK_DIR" ]]; then
  echo "RACK_DIR not set - run /setup first"
  exit 1
fi

# Check for Makefile
test -f "modules/$MODULE_NAME/Makefile"

# Check for main source file
test -f "modules/$MODULE_NAME/src/$MODULE_NAME.cpp"
```

**If missing:** Inform user that build verification requires proper VCV Rack environment and suggest `/setup`.

**Build module:**

```bash
cd modules/$MODULE_NAME
make clean
make -j$(nproc) 2>&1 | tee build.log
BUILD_EXIT_CODE=${PIPESTATUS[0]}
```

**Parse build output:**

- Extract errors/warnings
- Check for successful completion
- Identify missing dependencies

**Report format:**

**Build succeeds:**

```
✅ Build PASSED

Module: [ModuleName]
Platform: [mac-arm64 | mac-x64 | linux-x64 | win-x64]
Output: dist/[ModuleName]-[version]-[platform].vcvplugin

Build time: [duration]
Compiler warnings: [count]

Module ready for testing in VCV Rack.
```

**Build fails:**

```
❌ Build FAILED

Compilation errors detected:

[Error 1]
File: src/[ModuleName].cpp:42
Error: 'inputs' was not declared in this scope

[Error 2]
File: src/[ModuleName].cpp:87
Error: no matching function for call to 'setVoltage'

What would you like to do?
1. Investigate failures (detailed analysis)
2. Show full build output (complete logs)
3. Continue anyway (NOT RECOMMENDED - module won't load)
4. I'll fix manually
5. Other

Choose (1-5): _
```

**After results, offer next steps (see Phase 3)**

### Mode 2: Configuration Validation

**Purpose:** Validate plugin.json format and SVG panel specifications

**Load configuration:**

```bash
# Read plugin.json
cat "modules/$MODULE_NAME/plugin.json"
```

**Validation checks:**

**1. plugin.json Structure:**

```json
{
  "slug": "ModuleName",
  "name": "Module Display Name",
  "version": "1.0.0",
  "license": "GPL-3.0-or-later",
  "brand": "Brand Name",
  "author": "Author Name",
  "authorEmail": "email@example.com",
  "authorUrl": "https://example.com",
  "pluginUrl": "https://example.com/ModuleName",
  "manualUrl": "https://example.com/ModuleName/manual",
  "sourceUrl": "https://github.com/username/ModuleName",
  "donateUrl": "",
  "changelogUrl": "",
  "modules": [
    {
      "slug": "ModuleName",
      "name": "Module Display Name",
      "description": "Description",
      "tags": ["Category1", "Category2"]
    }
  ]
}
```

**Validate:**

- `slug` matches module name (alphanumeric + hyphens only)
- `version` follows semver format (X.Y.Z)
- `modules` array contains at least one entry
- Module slug in `modules` array matches top-level `slug`
- `tags` are valid VCV Rack categories

**2. SVG Panel Validation:**

```bash
# Find SVG panel file
SVG_FILE="modules/$MODULE_NAME/res/$MODULE_NAME.svg"
test -f "$SVG_FILE"
```

**Validate SVG dimensions:**

```xml
<!-- SVG must have correct dimensions for module HP -->
<!-- Formula: width = HP × 5.08mm -->
<!-- Height must be 128.5mm -->

<svg width="30.48mm" height="128.5mm" viewBox="0 0 30.48 128.5">
  <!-- 6 HP module -->
</svg>
```

**Validation rules:**

- Width = HP × 5.08mm (e.g., 6 HP = 30.48mm)
- Height = 128.5mm (Eurorack standard)
- viewBox matches width and height
- Contains "component" layer for printing

**Report format:**

**All validations pass:**

```
✅ Configuration VALID

plugin.json:
- Slug: [slug] ✓
- Version: [version] ✓
- Module count: [count] ✓
- Valid tags: [tags] ✓

SVG Panel (res/[ModuleName].svg):
- Width: [HP] HP ([width]mm) ✓
- Height: 128.5mm ✓
- viewBox: correct ✓
- Component layer: present ✓

Configuration ready for VCV Rack Library submission.
```

**Some validations fail:**

```
❌ Configuration INVALID

plugin.json issues:
✗ Slug contains invalid characters (use alphanumeric + hyphens only)
✗ Version "1.0" doesn't follow semver (must be X.Y.Z)
✓ Module count: 1
✗ Invalid tag: "Distortion" (not a valid VCV category)

SVG Panel issues:
✗ Width is 31mm but should be 30.48mm for 6 HP
✓ Height: 128.5mm
✗ viewBox doesn't match dimensions

What would you like to do?
1. Show me the plugin.json file
2. Show me the SVG panel file
3. Auto-fix common issues (recommended)
4. I'll fix manually
5. Other

Choose (1-5): _
```

**After results, offer next steps (see Phase 3)**

### Mode 3: Manual Testing Protocol

**Purpose:** Comprehensive real-world testing in VCV Rack

**Load module configuration:**

```bash
# Read plugin.json to extract module info
cat "modules/$MODULE_NAME/plugin.json"
```

**Generate customized checklist:**

1. Read module info from plugin.json
2. Extract inputs, outputs, parameters, lights
3. Generate specific test cases for each component
4. Display complete checklist to user

**Checklist structure:**

```markdown
# Manual Testing Protocol: [ModuleName]

## Test Environment
- VCV Rack version: [version]
- Platform: [mac/linux/windows]
- Plugin location: ~/Documents/Rack2/plugins-[platform]-[arch]/

## Setup
- [ ] Launch VCV Rack
- [ ] Verify module appears in library browser
- [ ] Add module to patch
- [ ] Module loads without errors
- [ ] Panel displays correctly

## Parameter Testing

### [Parameter 1: Frequency]
- [ ] Knob responds smoothly to mouse drag
- [ ] Right-click menu shows correct range (min: [min], max: [max])
- [ ] Default value is correct: [default]
- [ ] CV input modulates parameter correctly
- [ ] Tooltip displays current value

[Repeat for each parameter]

## Input/Output Testing

### [Input 1: CV_IN]
- [ ] Input accepts cable connection
- [ ] Polyphony: Test with mono cable (1 channel)
- [ ] Polyphony: Test with poly cable (4, 8, 16 channels)
- [ ] Voltage range: Test with -10V to +10V signals
- [ ] No audio bleed when disconnected

### [Output 1: AUDIO_OUT]
- [ ] Output produces signal when expected
- [ ] Polyphony: Output channel count matches input
- [ ] Voltage range: Output stays within -10V to +10V
- [ ] No DC offset (use Scope module to check)
- [ ] No clipping at normal levels

[Repeat for each input/output]

## Sample Rate Testing
- [ ] 44.1 kHz: Module processes correctly
- [ ] 48 kHz: Module processes correctly
- [ ] 96 kHz: Module processes correctly
- [ ] 192 kHz: Module processes correctly (if supported)
- [ ] Sample rate changes don't cause clicks/pops

## Polyphony Testing
- [ ] 1 channel: Mono operation works correctly
- [ ] 4 channels: Polyphonic operation stable
- [ ] 8 channels: All channels process independently
- [ ] 16 channels: Maximum polyphony stable
- [ ] Channel count changes smoothly (no glitches)

## CV Modulation Testing

### [Parameter: Frequency]
- [ ] Slow LFO (0.1 Hz): Smooth modulation
- [ ] Audio rate (440 Hz): Clean FM response
- [ ] Polyphonic CV: Each channel modulates independently
- [ ] CV attenuverter: Positive and negative modulation
- [ ] No zipper noise during modulation

[Repeat for each CV-controllable parameter]

## State Management
- [ ] Save patch: Module state saves correctly
- [ ] Load patch: Module state restores correctly
- [ ] Parameter values persist after save/load
- [ ] Cable connections restore correctly
- [ ] Initialize command resets to defaults

## Edge Cases
- [ ] Disconnected inputs: No crashes or unexpected behavior
- [ ] Extreme parameter values: No instability at min/max
- [ ] Feedback loops: Module handles audio feedback gracefully
- [ ] Rapid parameter changes: No clicks or instability
- [ ] Multiple instances: 10+ modules can coexist without issues

## Performance Testing
- [ ] CPU meter: Module uses reasonable CPU (<5% for basic modules)
- [ ] Memory: No memory leaks during extended use
- [ ] Real-time: Module processes in real-time at all sample rates
- [ ] Stability: No crashes during 10-minute stress test

## Sonic Quality
- [ ] Output sounds clean (no unexpected artifacts)
- [ ] Frequency response: Full bandwidth (20 Hz - 20 kHz)
- [ ] Dynamic range: Good signal-to-noise ratio
- [ ] Aliasing: No audible aliasing at high frequencies
- [ ] Transient response: Clean attack/decay characteristics

## Cross-Platform Testing (Optional)
- [ ] macOS (arm64): Module loads and works
- [ ] macOS (x64): Module loads and works
- [ ] Linux (x64): Module loads and works
- [ ] Windows (x64): Module loads and works

## Final Verification
- [ ] All critical tests passed
- [ ] No crashes or errors during testing
- [ ] Module performs as expected
- [ ] Ready for release

## Issues Found
[List any issues discovered during testing]

1. [Issue description]
   - Severity: [Critical/High/Medium/Low]
   - Steps to reproduce: [Steps]
   - Expected behavior: [Description]
   - Actual behavior: [Description]

## Notes
[Additional observations or comments]
```

**User confirms checklist completion, then offer next steps (see Phase 3)**

## Phase 3: Post-Test Decision Menu

**After Mode 1 (build verification) passes:**

```
✓ Build verification passed

What's next?
1. Validate configuration (plugin.json + SVG) (recommended)
2. Run manual testing protocol
3. Install module (/install-module)
4. Review build warnings
5. Other

Choose (1-5): _
```

**After Mode 2 (configuration validation) passes:**

```
✓ Configuration validation passed

What's next?
1. Run manual testing protocol (recommended)
2. Install module to VCV Rack
3. Review configuration files
4. Continue to next stage (if in workflow)
5. Other

Choose (1-5): _
```

**After Mode 3 (manual testing) complete:**

```
✓ Manual testing complete

What's next?
1. Install module (/install-module) → Ready for production use
2. Mark module as release-ready (update MODULES.md status)
3. Report issues found (if any)
4. Run additional build verification
5. Other

Choose (1-5): _
```

## Phase 4: Failure Investigation (Option 1)

**When user chooses "Investigate failures":**

**For each failed test:**

1. Read detailed explanation from troubleshooting knowledge base
2. Provide specific fix recommendations
3. Offer to show relevant code sections
4. If available, launch `Task` agent with `deep-research` to find root cause

**Example investigation output:**

```
Investigating build failure: "'inputs' was not declared in this scope"...

Root cause: Missing VCV Rack API includes or incorrect namespace

The module is trying to access 'inputs' but hasn't properly inherited from rack::Module.

Fix:
1. Open src/[ModuleName].cpp
2. Verify struct declaration inherits from rack::Module:
   struct ModuleName : Module {
       // Your code here
   }

3. Ensure you're accessing inputs correctly:
   inputs[INPUT_ID].getVoltage()

4. Check that you've declared input enums:
   enum InputIds {
       INPUT_ID,
       INPUTS_LEN
   };

This ensures proper VCV Rack Module API usage.

Would you like me to:
1. Show the current module structure
2. Launch deep-research agent to scan codebase
3. I'll fix it myself
4. Other

Choose (1-4): _
```

## Phase 5: Log Test Results

**Save detailed logs for every test run:**

**Location:** `logs/[ModuleName]/test_[timestamp].log`

**Log format:**

```
================================================================================
Test Report: [ModuleName]
================================================================================
Date: 2025-11-12 14:32:17
Mode: [Mode 1 / Mode 2 / Mode 3]
Module: [ModuleName] v1.0.0
Platform: [mac-arm64 | mac-x64 | linux-x64 | win-x64]

[Mode-specific details]

Test Results:
[Pass/fail summary]

Total time: [duration]

Conclusion: [Module ready / Failures detected]
================================================================================

[Full output below]
...
```

**Update state files:**

- `.continue-here.md` → Mark testing complete, update next step
- `MODULES.md` → Update test status (last tested date, results)

## Success Criteria

Testing is successful when:

- ✅ Tests run without crashes (even if some fail, process completes)
- ✅ All tests pass OR failures are documented with clear explanations
- ✅ User understands what failed and why (no mystery errors)
- ✅ Logs saved for future reference (`logs/[ModuleName]/`)
- ✅ User knows next step (install, fix issues, continue workflow)
- ✅ Test results stored in MODULES.md (test date, pass/fail, mode used)

**NOT required for success:**

- 100% pass rate (failures are learning opportunities)
- Fixing all issues immediately (user can defer fixes)
- Running all 3 test modes (one mode is sufficient for validation)

## Integration Points

**Invoked by:**

- `/test [ModuleName]` command
- `/test [ModuleName] build` → Direct to mode 1
- `/test [ModuleName] config` → Direct to mode 2
- `/test [ModuleName] manual` → Direct to mode 3
- `module-workflow` skill → After Stages 4, 5, 6
- `module-improve` skill → After implementing changes
- Natural language: "Test [ModuleName]", "Run validation on [ModuleName]"

**Invokes:**

- `deep-research` skill → When user chooses "Investigate failures"

**Creates:**

- Test logs in `logs/[ModuleName]/test_[timestamp].log`
- Build artifacts in `modules/[ModuleName]/dist/`

**Updates:**

- `.continue-here.md` → Testing checkpoint
- `MODULES.md` → Test status

**Blocks:**

- Installation (`/install-module`) → Recommends testing first if not done recently

## VCV Rack-Specific Testing Considerations

### Polyphony Testing

VCV Rack supports up to 16 polyphonic channels per cable. Testing must verify:

- **Channel count detection**: Module adapts to incoming cable channel count
- **Independent processing**: Each channel processes independently
- **Channel count changes**: Smooth transitions when channel count changes
- **Maximum polyphony**: Stable operation at 16 channels

### Sample Rate Testing

VCV Rack supports multiple sample rates. Testing must verify:

- **Standard rates**: 44.1 kHz, 48 kHz work correctly
- **High rates**: 96 kHz, 192 kHz work correctly (if supported)
- **Sample rate changes**: No clicks/pops when sample rate changes
- **Performance scaling**: CPU usage scales appropriately with sample rate

### CV Voltage Standards

VCV Rack uses -10V to +10V voltage range. Testing must verify:

- **Pitch CV**: 1V/oct standard (C4 = 0V)
- **Gate/trigger**: 0V = low, 10V = high (or 5V for some modules)
- **Audio signals**: -5V to +5V typical, -10V to +10V maximum
- **Modulation CV**: -10V to +10V full range

### Module Width Testing

VCV Rack modules use HP (Horizontal Pitch) units:

- **1 HP = 5.08mm** (Eurorack standard)
- **SVG panel width must match plugin.json HP declaration**
- **Common widths**: 3 HP, 6 HP, 8 HP, 12 HP, 16 HP, 24 HP

### Performance Testing

VCV Rack modules must run in real-time:

- **CPU usage**: Target <5% per instance for simple modules
- **Sample time**: Target <0.1ms per sample for basic modules
- **Memory allocation**: No allocations in process() method
- **Thread safety**: process() must be thread-safe

## Reference Documentation

- **Testing specifications:** `references/test-specifications.md` - Detailed test implementations
- **Manual testing guide:** `references/manual-testing-guide.md` - VCV Rack testing methodology
- **Troubleshooting:** `references/troubleshooting.md` - Common issues and fixes
- **VCV Rack API:** VCV Rack documentation for API reference

## Template Assets

- **Manual testing checklist:** `assets/manual-testing-checklist.md` - VCV Rack testing template
