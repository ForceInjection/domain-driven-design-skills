---
name: vue-story
description: Create and maintain Histoire stories for Vue 3 components. Use when working with .story.vue files, creating visual contracts, or when user mentions Histoire stories or visual testing.
metadata:
  prerequisites: "Histoire, Vue 3, TypeScript"
  related: "vue-component-development"
---

# Vue Story Development

Create and maintain Histoire stories for Vue 3 components, focusing on visual and behavioral contracts rather than parameter demonstrations.

## Prerequisites

- Histoire for visual stories
- Vue 3 with `<script setup>` syntax
- TypeScript
- Existing Vue component to create stories for

## Story File

Each component can optionally have a `compName.story.vue` file that contains Histoire stories.

**Requirements:**

- Component must have `compName.story.md` documentation file (not just `compName.md`)
- Stories are optional but recommended for visual regression prevention
- Follow the [Story Guide](references/comp-story.md) for best practices

## Core Principle

A Story represents ONE of the following:

1. **Canonical semantic state** - A stable, long-term design commitment
2. **State transition boundary** - Critical boundaries between internal states
3. **Edge case likely to regress** - Scenarios most likely to break
4. **Design-forbidden state** - Invalid states that must not be relied upon

Stories must be **readable without explanatory text**. If a Story needs explanation, it likely belongs in the documentation instead.

## Story Categories

### Canonical (Required)

Stable, long-term design commitments.

```vue
<Story title="Primary Button" :layout="{ type: 'single' }">
  <InkButton text="Save Changes" variant="primary" />
</Story>
```

### State (Recommended)

Critical boundaries between internal states.

```vue
<Story title="Loading State">
  <InkButton text="Saving..." :loading="true" />
</Story>
```

### Edge (Recommended)

Scenarios most likely to break layout or behavior.

```vue
<Story title="Long Text Wrapping">
  <InkButton text="This is a very long button text that should wrap properly" />
</Story>
```

### Invalid (Optional)

States that must not be relied upon.

```vue
<Story title="❌ Both Loading and Disabled (Undefined)">
  <InkButton text="Invalid" :loading="true" :disabled="true" />
</Story>
```

## What Stories Are NOT

❌ **NOT for exhaustive prop combinations**
❌ **NOT a playground or sandbox**
❌ **NOT for replacing documentation**

✅ **YES for semantic state contracts**

## Development Workflow

### Creating Stories for a Component

1. Ensure component has `compName.story.md` (not just `compName.md`)
2. Create `compName.story.vue` in the component folder
3. Import the component
4. Create at least one **canonical** story
5. Add **state** and **edge** stories as needed
6. Verify stories are readable without explanation

### Story Template

```vue
<script setup lang="ts">
import { CompName } from './compName';
</script>

<template>
  <Story
    group="canonical"
    title="Primary State"
    :layout="{ type: 'single', width: '200px' }"
  >
    <CompName prop="value" />
  </Story>

  <Story group="state" title="Loading State">
    <CompName :loading="true" />
  </Story>

  <Story group="edge" title="Edge Case">
    <CompName extreme="scenario" />
  </Story>
</template>
```

## Best Practices

**Story Creation:**

- Focus on semantic states, not prop variations
- Use clear, descriptive titles
- Group related stories with the `group` attribute
- Keep stories simple and self-explanatory

**Layout:**

- Use appropriate Histoire layout options
- Consider container constraints for edge cases
- Test dark mode/theme variations when relevant

**Quality:**

- Stories represent meaningful states
- No exhaustive prop combinations
- All critical states are covered
- Stories are stable over time

## Minimal Checklist

Before committing a `*.story.vue`:

- [ ] At least one **canonical** variant exists
- [ ] At least one **state** or **edge** variant exists
- [ ] No exhaustive prop combinations are present
- [ ] All Story titles communicate semantic intent
- [ ] Stories are readable without needing explanation

## Success Criteria

A well-implemented story file has:

- ✅ Clear category grouping (canonical, state, edge)
- ✅ Semantic, descriptive titles
- ✅ Coverage of critical states and boundaries
- ✅ No exhaustive prop matrices
- ✅ Stories that are self-explanatory
- ✅ Focused on long-term semantic contracts
- ❌ No redundant similar stories
- ❌ No stories that just demonstrate parameters
- ❌ No stories requiring extensive explanation

## Related Skills

- [vue-component-development](../vue-component-development/SKILL.md) - Main Vue component development skill

## References

- [Story Guide](references/comp-story.md) - Comprehensive guide to creating stories
- [Histoire Documentation](https://histoire.dev/)
