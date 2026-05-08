---
name: audio-effect
description: Create standard SuperCollider audio effects for Bice-Box (delays, reverbs, filters, distortions). Provides templates, ControlSpecs, common patterns, and MCP workflow for safely creating/updating effects.
---

# Audio Effect Development

Create standard SuperCollider audio effects for Bice-Box (delays, reverbs, filters, distortions, etc.).

## Critical Rules

### ⚠️ FILENAME/DEFNAME MATCHING IS CRITICAL ⚠️
- **defName MUST EXACTLY match filename** (character for character!)
  - ✅ CORRECT: `reverb.sc` → `var defName = \reverb;`
  - ✅ CORRECT: `ping_pong_delay.sc` → `var defName = \ping_pong_delay;`
  - ❌ WRONG: `happy-synth.sc` → `var defName = \happy_synth;` (hyphen vs underscore!)
  - ❌ WRONG: `my_effect.sc` → `var defName = \my-effect;` (underscore vs hyphen!)
- **If faders don't appear in UI, check filename vs defName first!**

### Other Critical Rules
- **All variables in ONE block** after parameters - NO `var` declarations anywhere else
- **Use specs defaults**: `\param.kr(specs[\param].default)`
- **Mono-first**: Process in mono, output `[processed, processed]`
- **Analysis out**: Always mono signal to `analysis_out_bus`
- **Maximum 12 faders** fit on screen - design parameters accordingly

## Effect Template

```supercollider
// shader: oscilloscope
(
    var defName = \effect_name;  // ← MUST match filename exactly!
    var specs = (
        param1: ControlSpec(0.1, 10.0, 'exp', 0, 1.0, "x"),
        mix: ControlSpec(0.0, 1.0, 'lin', 0, 0.5, "%")
    );

    var def = SynthDef(defName, {
        // Standard parameters
        var out = \out.kr(0);
        var in_bus = \in_bus.kr(0);
        var analysis_out_bus = \analysis_out_bus.kr;
        var param1 = \param1.kr(specs[\param1].default);
        var mix = \mix.kr(specs[\mix].default);

        // ALL variables declared here!
        var sig, dry, processed, mono_for_analysis;

        // Processing
        sig = In.ar(in_bus);  // Mono input
        dry = sig;
        processed = sig * param1;  // Your effect here
        processed = XFade2.ar(dry, processed, mix * 2 - 1);

        // Outputs
        mono_for_analysis = processed;
        Out.ar(analysis_out_bus, mono_for_analysis);
        Out.ar(out, [processed, processed]);
    });
    def.add;
    "Effect SynthDef 'effect_name' added".postln;

    ~setupEffect.value(defName, specs);
)
```

## Feedback Effects Pattern

For delays, reverbs, and other feedback-based effects:

```supercollider
// Get feedback from previous iteration
var fbNode = LocalIn.ar(1);
// Create delay with input + feedback
var delayed = DelayC.ar(sig + fbNode, maxDelayTime, delayTime);
// Send feedback back (with feedback amount control)
LocalOut.ar(delayed * feedback);
```

## Common ControlSpecs

```supercollider
// Linear 0-1 parameters (mix, level, etc.)
mix: ControlSpec(0.0, 1.0, 'lin', 0, 0.5, "%")

// Exponential frequency parameters
freq: ControlSpec(20, 2000, 'exp', 0, 440, "Hz")

// Gain/amplitude parameters
gain: ControlSpec(0.1, 5.0, 'exp', 0, 1.0, "x")

// Time-based parameters
delay: ControlSpec(0.001, 2.0, 'exp', 0, 0.1, "s")
```

## Visualizer Comments

Add a visualizer comment as the first line to auto-load a visualizer when the effect loads:

- **For GLSL shaders:** `// shader: shader_name` (loads from `shaders/` directory)
- **For p5.js sketches:** `// p5: sketch_name` (loads from `visual/` directory)

Examples:
- `// shader: oscilloscope` → loads `shaders/oscilloscope.glsl`
- `// shader: palpatine` → loads `shaders/palpatine_image.glsl` (multi-pass)
- `// p5: tuner` → loads `visual/tuner.js`

**Note:** Visualizer names must be unique across both directories.

## MCP Workflow

**Recommended workflow for creating/updating effects:**

1. **Test syntax** - Use `test_supercollider_code` to validate during development
   ```
   mcp__bice-box__test_supercollider_code(scCode: "your code here")
   ```

2. **Create/update** - Use `create_or_update_audio_effect` to safely save
   ```
   mcp__bice-box__create_or_update_audio_effect(
       effectName: "my_effect",
       scCode: "your code here",
       makeActive: true  // optional, loads effect immediately
   )
   ```

3. **Activate** - Switch to your effect
   ```
   mcp__bice-box__set_current_effect(effectName: "my_effect")
   ```

4. **Tweak parameters** - Adjust live values for testing
   ```
   mcp__bice-box__set_effect_parameters(params: {
       param1: 2.5,
       mix: 0.7
   })
   ```
   Note: This only affects live session values. To change defaults, edit the `.sc` file.

5. **Debug errors** - If compilation fails, check logs
   ```
   mcp__bice-box__read_logs(lines: 100, filter: "ERROR")
   ```

## Common Patterns

### Distortion/Saturation
```supercollider
processed = (sig * drive).tanh;  // Soft clipping
processed = sig.distort;  // Hard distortion
processed = sig.softclip;  // Soft clipping
```

### Filtering
```supercollider
processed = LPF.ar(sig, cutoff);  // Low-pass
processed = HPF.ar(sig, cutoff);  // High-pass
processed = RLPF.ar(sig, cutoff, rq);  // Resonant low-pass
processed = MoogFF.ar(sig, cutoff, resonance);  // Moog-style filter
```

### Delay/Echo
```supercollider
processed = DelayC.ar(sig, maxDelay, delayTime);  // Clean delay
processed = CombC.ar(sig, maxDelay, delayTime, decayTime);  // Comb filter
```

### Modulation
```supercollider
var lfo = SinOsc.kr(rate);  // LFO for modulation
processed = sig * (1 + (depth * lfo));  // Amplitude modulation
```

## Tips
- Start with simple effects and add complexity gradually
- Test with live audio input frequently
- Use sensible parameter ranges (exponential for frequency/time, linear for mix)
- Keep CPU usage in mind - avoid excessive nesting
- Use meaningful parameter names for better UI readability
