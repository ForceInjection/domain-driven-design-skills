---
name: add-keyboard-nav
description: Add keyboard navigation to a feature using CommandRegistryService. Use when implementing keyboard shortcuts, vim-style navigation, or hotkeys for a page or component.
---

# Add Keyboard Navigation Skill

Implement keyboard shortcuts using the hnews command registry pattern.

## Architecture Overview

```
CommandRegistryService     <- Central command registry (string → callback)
        ↑
KeyboardNavigationService  <- Story list navigation (j/k/o/c)
BaseCommentNavigationService <- Comment thread navigation (abstract)
        ↑
SidebarKeyboardNavigationService  <- Sidebar-specific commands
ItemKeyboardNavigationService     <- Item page-specific commands
```

## Step 1: Register Commands

Inject `CommandRegistryService` and register commands in constructor:

```typescript
import { inject } from '@angular/core';
import { CommandRegistryService } from '../services/command-registry.service';

@Injectable({ providedIn: 'root' })
export class MyFeatureNavigationService {
  private commandRegistry = inject(CommandRegistryService);

  constructor() {
    this.registerCommands();
  }

  private registerCommands(): void {
    // Use namespaced command IDs: 'feature.action'
    this.commandRegistry.register('myFeature.next', () => this.selectNext());
    this.commandRegistry.register('myFeature.previous', () => this.selectPrevious());
    this.commandRegistry.register('myFeature.open', () => this.openSelected());
  }

  private selectNext(): void {
    // Implementation
  }
}
```

## Step 2: Handle Keyboard Events

In the component or app-level, listen for keydown and execute commands:

```typescript
@HostListener('document:keydown', ['$event'])
handleKeydown(event: KeyboardEvent): void {
  // Skip if user is typing in an input
  if (this.isTyping(event)) return;

  const keyMap: Record<string, string> = {
    'j': 'myFeature.next',
    'k': 'myFeature.previous',
    'Enter': 'myFeature.open',
  };

  const command = keyMap[event.key];
  if (command) {
    event.preventDefault();
    this.commandRegistry.execute(command);
  }
}

private isTyping(event: KeyboardEvent): boolean {
  const target = event.target as HTMLElement;
  return target.tagName === 'INPUT' ||
         target.tagName === 'TEXTAREA' ||
         target.isContentEditable;
}
```

## Step 3: DOM Attributes for Navigation

Use data attributes to find navigable elements:

```html
<!-- Story list items -->
<article
  [attr.data-story-index]="index"
  [attr.data-story-id]="story.id"
  [class.selected]="isSelected(index)"
></article>
```

```html
<!-- Comment threads use role="treeitem" -->
<div role="treeitem" [attr.data-comment-id]="comment.id"></div>
```

```html
<!-- Load more buttons -->
<button class="load-more-btn" (click)="loadMore()"></button>
```

## Step 4: Selection State with Signals

```typescript
readonly selectedIndex = signal<number | null>(null);
readonly totalItems = signal<number>(0);

isSelected = computed(() => {
  const index = this.selectedIndex();
  return (itemIndex: number) => index === itemIndex;
});

selectNext(): boolean {
  const current = this.selectedIndex();
  const total = this.totalItems();

  if (current === null) {
    this.selectedIndex.set(0);
    return true;
  }

  if (current < total - 1) {
    this.selectedIndex.set(current + 1);
    return true;
  }

  return false;
}
```

## Step 5: Scroll Into View

```typescript
private scrollSelectedIntoView(): void {
  const element = document.querySelector(`[data-item-index="${this.selectedIndex()}"]`);
  element?.scrollIntoView({ behavior: 'smooth', block: 'center' });
}
```

## Command Naming Convention

Use hierarchical naming: `{feature}.{action}`

Examples:

- `story.next`, `story.previous`, `story.open`
- `comment.next`, `comment.previous`, `comment.collapse`
- `sidebar.close`, `sidebar.scrollTop`
- `navigation.previousTab`, `navigation.nextTab`

## For Comment Threads

Extend `BaseCommentNavigationService`:

```typescript
@Injectable()
export class MyCommentNavigationService extends BaseCommentNavigationService {
  protected getCommentElements(): HTMLElement[] {
    return Array.from(document.querySelectorAll('[role="treeitem"]'));
  }

  protected getContainerElement(): HTMLElement | null {
    return document.querySelector('.comments-container');
  }
}
```

## Testing

```typescript
describe('MyFeatureNavigationService', () => {
  let service: MyFeatureNavigationService;
  let commandRegistry: CommandRegistryService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(MyFeatureNavigationService);
    commandRegistry = TestBed.inject(CommandRegistryService);
  });

  it('should register commands', () => {
    expect(commandRegistry.hasCommand('myFeature.next')).toBe(true);
  });
});
```
