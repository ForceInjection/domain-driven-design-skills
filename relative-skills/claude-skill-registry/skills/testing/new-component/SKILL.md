---
name: new-component
description: Scaffold a new Angular component with test file following project conventions. Use when creating new components, widgets, or UI elements.
---

# New Component Skill

Generate Angular standalone components following hnews project patterns.

## File Structure

Create two files:

- `src/app/components/{component-name}/{component-name}.component.ts`
- `src/app/components/{component-name}/{component-name}.component.spec.ts`

For shared/reusable widgets, use `src/app/components/shared/{component-name}/`.

## Component Template

```typescript
// SPDX-License-Identifier: MIT
// Copyright (C) 2025 Alysson Souza
import { Component, ChangeDetectionStrategy, input, output } from '@angular/core';

@Component({
  selector: 'app-{component-name}',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [],
  template: `
    <!-- Template here -->
  `,
  styles: [
    `
      @reference '../../../styles.css';

      :host {
        @apply contents;
      }
    `,
  ],
})
export class {ComponentName}Component {
  // Use signal-based inputs/outputs
  readonly someInput = input<string>('');
  readonly someOutput = output<void>();
}
```

## Test Template

```typescript
// SPDX-License-Identifier: MIT
// Copyright (C) 2025 Alysson Souza
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { {ComponentName}Component } from './{component-name}.component';

describe('{ComponentName}Component', () => {
  let component: {ComponentName}Component;
  let fixture: ComponentFixture<{ComponentName}Component>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [{ComponentName}Component],
    }).compileComponents();

    fixture = TestBed.createComponent({ComponentName}Component);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  // Set inputs using fixture.componentRef.setInput('inputName', value)
});
```

## Key Conventions

1. **No `standalone: true`** — It's the default in Angular 20+
2. **Use `ChangeDetectionStrategy.OnPush`** always
3. **Signal-based APIs**: Use `input()`, `output()`, `viewChild()` instead of decorators
4. **Styles reference**: Use `@reference '../../../styles.css';` (adjust path depth)
5. **Tailwind**: Use `@apply` for component styles
6. **Dark mode**: Include `.dark:` variants for colors
7. **Selector prefix**: Always `app-` (kebab-case)
8. **Class suffix**: `{Name}Component`

## After Creation

Run `ng test --include src/app/components/{component-name}/{component-name}.component.spec.ts` to verify.
