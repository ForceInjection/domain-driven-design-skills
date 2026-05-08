---
name: nuxt-enums
description: TypeScript enum pattern with Castable interface for model integration. Use when creating enums with behavior methods (colors, labels), defining fixed value sets, or integrating enums with the model casting system.
---

# Nuxt Enums

Class-based enums with behavior methods and model casting integration.

## Core Concepts

**[enums.md](references/enums.md)** - Complete enum patterns, behavior methods, UI integration

## Basic Enum

```typescript
// app/enums/PostStatus.ts
import Enum from '#layers/base/app/enums/Enum'
import type { Castable } from '#layers/base/app/types'

export default class PostStatus extends Enum implements Castable {
  // Static enum values
  static readonly Draft = PostStatus.create('draft')
  static readonly PendingReview = PostStatus.create('pending review')
  static readonly Published = PostStatus.create('published')
  static readonly Archived = PostStatus.create('archived')

  // Cast method for model system
  static cast(value: string): PostStatus {
    return PostStatus.coerce(value)
  }

  // Behavior methods
  color(): string {
    switch (this.value) {
      case 'draft': return 'neutral'
      case 'pending review': return 'warning'
      case 'published': return 'success'
      case 'archived': return 'error'
      default: return 'neutral'
    }
  }

  get text(): string {
    return this.value
  }
}
```

## Usage

```typescript
// In models (auto-cast from API string)
status: PostStatus

// Comparisons
post.status.is(PostStatus.Published)

// Get all values
PostStatus.values()

// In templates
<UBadge :color="post.status.color()">{{ post.status.text }}</UBadge>
```
