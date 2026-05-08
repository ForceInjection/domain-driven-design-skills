---
name: flux-prompt-engineer
description: Expert prompt engineering for FLUX.1 image generation. Use when users request AI-generated images, artwork, illustrations, or visual content. Converts any visual request into optimized FLUX.1 prompts using layering, descriptive language, technical parameters, and text integration techniques.
---

# FLUX.1 Prompt Engineer

This skill transforms user requests into three expert-level FLUX.1 prompts, each optimized for the [dev] variant.

## Core Workflow

**For any image generation request:**

1. **Analyze the request** - Identify key visual elements, mood, style, composition
2. **Generate three variants** - Create three distinct code blocks, each containing a complete prompt
3. **Apply advanced techniques** - Use layering, specificity, contrast, and technical parameters from bundled references
4. **Format as code blocks** - Present each prompt in a code block for easy copying

## Prompt Construction Principles

### Be Specific and Descriptive

Use precise language: "vibrant orange and pink sunset" not "nice sunset"

### Use Hierarchical Layering

Organize complex scenes into foreground, middle ground, and background layers

### Leverage Technical Parameters

Include camera settings (Canon EOS R5, 50mm lens, f/2.8, ISO 100) for photorealistic styles

### Create Dynamic Scenes

Use active language: "emerging through swirling mist" not "a misty scene"

### Avoid Anti-patterns

- No Stable Diffusion syntax (e.g., `++`, `(emphasis)`)
- No vague terms without specificity
- No "white background" in [dev] variant (causes fuzzy outputs)
- Keep prompts focused, not overcomplicated

## Output Format

Always provide exactly three code blocks:

```prompt
[Variant 1: Full detailed prompt]
```

```prompt
[Variant 2: Alternative interpretation]
```

```prompt
[Variant 3: Creative variation]
```

## Advanced Techniques

For complex requests, consult these references:

- **Layered compositions**: See `references/layering-hierarchy.md`
- **Contrasts and aesthetics**: See `references/contrasts.md`
- **Text integration**: See `references/text-rendering.md`
- **Technical parameters**: See `references/camera-settings.md`
- **See-through materials**: See `references/materials-textures.md`

## Quick Examples

**User**: "A futuristic city"

**Output**:

```prompt
A sprawling futuristic metropolis at twilight with towering glass skyscrapers featuring holographic advertisements. In the foreground, elevated maglev train tracks with a sleek white train passing through. The middle ground shows interconnected sky bridges between buildings with pedestrians visible as silhouettes. Background features a gradient sky transitioning from deep purple to orange, with distant communication towers topped with blinking lights. Shot on Canon EOS R5 with 24mm wide-angle lens, f/8, capturing sharp architectural details with slight motion blur on the train.
```

```prompt
Aerial view of a neon-lit cyberpunk city at night. Foreground: rain-slicked streets reflecting pink and blue neon signs in puddles. Middle ground: dense clusters of buildings with illuminated windows creating a mosaic pattern. Background: enormous holographic advertisements projected into misty air. Atmosphere: moody and atmospheric with volumetric lighting cutting through the fog. Style: influenced by Blade Runner aesthetics with emphasis on vertical architecture and vibrant color contrasts.
```

```prompt
A futuristic city floating above clouds, with modular buildings connected by transparent tubes. Foreground shows a landing platform with small spacecraft. Middle ground features botanical gardens suspended between structures with lush greenery visible through glass domes. Background displays the curvature of Earth with stars visible above. Lighting: soft golden hour sunlight creating warm reflections on metallic surfaces. Shot with Sony Alpha 7R IV, 50mm lens, f/4, emphasizing clean lines and utopian design philosophy.
```

## Notes

- `FLUX.1 [dev]` uses guidance scale `3.5`, `50` inference steps, `1024x1024` default
- `[dev]` variant excels at text rendering - include specific font descriptions when relevant
- Avoid importing syntax from other AI tools
