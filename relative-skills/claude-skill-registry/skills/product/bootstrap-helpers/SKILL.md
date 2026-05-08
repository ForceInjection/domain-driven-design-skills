---
name: bootstrap-helpers
description: This skill should be used when the user asks about Bootstrap helpers, Bootstrap clearfix, Bootstrap color and background helpers, Bootstrap colored links, Bootstrap focus ring, Bootstrap icon link, Bootstrap position helpers, Bootstrap ratio helpers, Bootstrap stacks, Bootstrap stretched link, Bootstrap text truncation, Bootstrap vertical rule, Bootstrap visually hidden, or needs help with Bootstrap helper classes.
---

# Bootstrap 5.3 Helpers

Bootstrap provides helper classes for common utility patterns that extend the base utility classes.

## Clearfix

Clear floats within a container:

```html
<div class="clearfix">
  <button class="btn btn-secondary float-start">Left float</button>
  <button class="btn btn-secondary float-end">Right float</button>
</div>
```

## Color & Background

Combined color and background helpers for proper contrast:

```html
<div class="text-bg-primary p-3">Primary with proper contrast</div>
<div class="text-bg-secondary p-3">Secondary</div>
<div class="text-bg-success p-3">Success</div>
<div class="text-bg-danger p-3">Danger</div>
<div class="text-bg-warning p-3">Warning</div>
<div class="text-bg-info p-3">Info</div>
<div class="text-bg-light p-3">Light</div>
<div class="text-bg-dark p-3">Dark</div>
```

These ensure proper text color contrast automatically.

## Colored Links

Link colors with hover states:

```html
<a href="#" class="link-primary">Primary link</a>
<a href="#" class="link-secondary">Secondary link</a>
<a href="#" class="link-success">Success link</a>
<a href="#" class="link-danger">Danger link</a>
<a href="#" class="link-warning">Warning link</a>
<a href="#" class="link-info">Info link</a>
<a href="#" class="link-light">Light link</a>
<a href="#" class="link-dark">Dark link</a>
<a href="#" class="link-body-emphasis">Body emphasis link</a>

<!-- Link with opacity -->
<a href="#" class="link-primary link-opacity-10">10% opacity</a>
<a href="#" class="link-primary link-opacity-25">25% opacity</a>
<a href="#" class="link-primary link-opacity-50">50% opacity</a>
<a href="#" class="link-primary link-opacity-75">75% opacity</a>
<a href="#" class="link-primary link-opacity-100">100% opacity</a>

<!-- Underline utilities (requires base class) -->
<!-- .link-underline or .link-underline-{color} must be applied for opacity classes to work -->
<a href="#" class="link-underline link-underline-opacity-50">Base underline with 50% opacity</a>
<a href="#" class="link-underline-primary link-underline-opacity-25">Primary underline at 25%</a>

<!-- Combining link color with underline opacity (requires .link-underline base) -->
<a href="#" class="link-primary link-underline link-underline-opacity-0">No underline</a>
<a href="#" class="link-primary link-underline link-underline-opacity-10">Light underline</a>

<!-- Underline offset works directly with link colors (no base class needed) -->
<a href="#" class="link-primary link-offset-2">Offset underline</a>
<a href="#" class="link-primary link-offset-3">More offset</a>
```

### Hover Variants

Link utilities include hover variants for dynamic effects:

```html
<!-- Opacity changes on hover -->
<a href="#" class="link-primary link-opacity-50 link-opacity-100-hover">Brightens on hover</a>

<!-- Underline appears on hover -->
<a href="#" class="link-primary link-underline-opacity-0 link-underline-opacity-100-hover">Underline on hover</a>

<!-- Offset changes on hover -->
<a href="#" class="link-primary link-offset-2 link-offset-3-hover">Offset increases on hover</a>

<!-- Combined hover effect -->
<a href="#" class="link-offset-2 link-offset-3-hover link-underline link-underline-opacity-0 link-underline-opacity-75-hover">
  Underline appears on hover
</a>
```

## Focus Ring

Custom focus ring styling:

```html
<!-- Default focus ring -->
<a href="#" class="d-inline-flex focus-ring py-1 px-2 text-decoration-none border rounded-2">
  Custom focus ring
</a>

<!-- Colored focus rings -->
<a href="#" class="d-inline-flex focus-ring focus-ring-primary">Primary</a>
<a href="#" class="d-inline-flex focus-ring focus-ring-secondary">Secondary</a>
<a href="#" class="d-inline-flex focus-ring focus-ring-success">Success</a>
<a href="#" class="d-inline-flex focus-ring focus-ring-danger">Danger</a>

<!-- Custom focus ring via CSS variable -->
<a href="#" class="d-inline-flex focus-ring" style="--bs-focus-ring-color: rgba(118, 169, 250, .5)">
  Custom color
</a>
```

## Icon Link

Style links that include icons:

```html
<a class="icon-link" href="#">
  <svg class="bi" aria-hidden="true"><use xlink:href="#box-seam"></use></svg>
  Icon link
</a>

<a class="icon-link" href="#">
  Icon link
  <svg class="bi" aria-hidden="true"><use xlink:href="#arrow-right"></use></svg>
</a>

<!-- Icon link with hover animation -->
<a class="icon-link icon-link-hover" href="#">
  Icon link
  <svg class="bi" aria-hidden="true"><use xlink:href="#arrow-right"></use></svg>
</a>

<!-- Custom styling -->
<a class="icon-link icon-link-hover" style="--bs-icon-link-transform: translate3d(0, -.125rem, 0);" href="#">
  <svg class="bi" aria-hidden="true"><use xlink:href="#clipboard"></use></svg>
  Icon link
</a>
```

## Position

Position helpers for common patterns:

### Fixed Position

```html
<div class="fixed-top">Fixed to top</div>
<div class="fixed-bottom">Fixed to bottom</div>
```

### Sticky Position

```html
<div class="sticky-top">Sticky top</div>
<div class="sticky-sm-top">Sticky top on sm+</div>
<div class="sticky-md-top">Sticky top on md+</div>
<div class="sticky-lg-top">Sticky top on lg+</div>
<div class="sticky-xl-top">Sticky top on xl+</div>
<div class="sticky-xxl-top">Sticky top on xxl+</div>

<div class="sticky-bottom">Sticky bottom</div>
<div class="sticky-sm-bottom">Sticky bottom on sm+</div>
<div class="sticky-md-bottom">Sticky bottom on md+</div>
<div class="sticky-lg-bottom">Sticky bottom on lg+</div>
<div class="sticky-xl-bottom">Sticky bottom on xl+</div>
<div class="sticky-xxl-bottom">Sticky bottom on xxl+</div>
```

## Ratio

Maintain aspect ratios for embeds and videos:

```html
<!-- 16:9 ratio (default) -->
<div class="ratio ratio-16x9">
  <iframe src="https://www.youtube.com/embed/..." title="YouTube video"></iframe>
</div>

<!-- 21:9 ratio -->
<div class="ratio ratio-21x9">
  <iframe src="..."></iframe>
</div>

<!-- 4:3 ratio -->
<div class="ratio ratio-4x3">
  <iframe src="..."></iframe>
</div>

<!-- 1:1 ratio (square) -->
<div class="ratio ratio-1x1">
  <iframe src="..."></iframe>
</div>

<!-- Custom ratio via CSS variable -->
<div class="ratio" style="--bs-aspect-ratio: 50%;">
  <iframe src="..."></iframe>
</div>
```

## Stacks

Quick flexbox layouts:

### Vertical Stack (vstack)

```html
<div class="vstack gap-3">
  <div class="p-2">First item</div>
  <div class="p-2">Second item</div>
  <div class="p-2">Third item</div>
</div>

<!-- With spacer -->
<div class="vstack gap-2">
  <button class="btn btn-secondary">Top</button>
  <button class="btn btn-secondary mt-auto">Bottom</button>
</div>
```

### Horizontal Stack (hstack)

```html
<div class="hstack gap-3">
  <div class="p-2">First</div>
  <div class="p-2">Second</div>
  <div class="p-2">Third</div>
</div>

<!-- With spacer -->
<div class="hstack gap-3">
  <button class="btn btn-secondary">Left</button>
  <div class="vr"></div>  <!-- Vertical divider -->
  <button class="btn btn-secondary ms-auto">Right</button>
</div>

<!-- Form inline with stacks -->
<div class="hstack gap-3">
  <input class="form-control me-auto" type="text" placeholder="Add your item here...">
  <button type="button" class="btn btn-secondary">Submit</button>
  <div class="vr"></div>
  <button type="button" class="btn btn-outline-danger">Reset</button>
</div>
```

**Browser Support Note:** Gap utilities (`.gap-*`) with flexbox aren't fully supported in Safari versions prior to 14.5. Grid layout is unaffected. For broader browser support, consider using margin utilities instead.

## Stretched Link

Make entire container clickable:

```html
<div class="card" style="width: 18rem;">
  <img src="..." class="card-img-top" alt="...">
  <div class="card-body">
    <h5 class="card-title">Card with stretched link</h5>
    <p class="card-text">Some text that will appear.</p>
    <a href="#" class="stretched-link">Go somewhere</a>
  </div>
</div>

<!-- Works with position: relative parent -->
<div class="row g-0 bg-body-secondary position-relative">
  <div class="col-md-6">
    <img src="..." class="w-100" alt="...">
  </div>
  <div class="col-md-6 p-4">
    <h5>Columns with stretched link</h5>
    <a href="#" class="stretched-link">Go somewhere</a>
  </div>
</div>
```

**Note:** The parent must have `position: relative` (cards have this by default).

**Identifying the containing block:** If the stretched link doesn't work as expected, check for these CSS properties on parent elements which also create containing blocks: `transform`, `perspective`, `filter` (Firefox only), or `will-change` set to `transform` or `perspective`.

## Text Truncation

Truncate long text with ellipsis:

```html
<!-- Block level (requires block display) -->
<div class="text-truncate" style="max-width: 150px;">
  This text is too long and will be truncated with an ellipsis.
</div>

<!-- Inline with d-inline-block -->
<span class="d-inline-block text-truncate" style="max-width: 150px;">
  This text is truncated.
</span>
```

## Vertical Rule

Vertical dividers:

```html
<div class="vr"></div>

<!-- In flexbox -->
<div class="d-flex" style="height: 200px;">
  <div class="vr"></div>
</div>

<!-- In stacks -->
<div class="hstack gap-3">
  <div>Item 1</div>
  <div class="vr"></div>
  <div>Item 2</div>
  <div class="vr"></div>
  <div>Item 3</div>
</div>
```

## Visually Hidden

Hide content visually but keep accessible to screen readers:

```html
<!-- Completely hidden from visual users -->
<h2 class="visually-hidden">Title for screen readers</h2>

<!-- Hidden but focusable (for skip links) -->
<a class="visually-hidden-focusable" href="#main-content">Skip to main content</a>
```

**Use cases:**

- Skip navigation links
- Form labels when visual context is sufficient
- Additional context for icons/images
- Headings for document structure

**Sass mixins** available for custom classes:

```scss
@import "bootstrap/scss/mixins/visually-hidden";

.custom-sr-only {
  @include visually-hidden;
}
```

## Sass Customization

Many helpers support build-time customization via Sass variables:

- **Focus Ring**: `$focus-ring-width`, `$focus-ring-opacity`, `$focus-ring-blur`
- **Icon Link**: `$icon-link-gap`, `$icon-link-icon-size`, `$icon-link-icon-transform`
- **Ratio**: `$aspect-ratios` map for custom aspect ratios

## Additional Resources

### Reference Files

- `references/helpers-reference.md` - Complete helper class reference and Sass customization options

### Example Files

- `examples/accessibility-patterns.html` - Visually hidden, focus ring, skip links, and screen reader utilities
- `examples/link-helpers-patterns.html` - Colored links, icon links, stretched links, and link utilities
- `examples/position-layout-patterns.html` - Fixed and sticky positioning patterns
- `examples/ratio-embed-patterns.html` - Responsive video embeds and aspect ratio utilities
- `examples/stack-patterns.html` - Comprehensive vstack/hstack patterns including gap variations
