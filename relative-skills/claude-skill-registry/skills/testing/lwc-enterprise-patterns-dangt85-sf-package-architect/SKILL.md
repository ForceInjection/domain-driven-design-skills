---
name: LWC Enterprise Patterns
description: This skill should be used when the user asks to "create lwc component", "lightning web component", "component architecture", "lwc state management", "lwc testing", "jest test", or mentions container/presentational patterns, pub-sub, or LWC best practices.
version: 0.1.0
---

# LWC Enterprise Patterns

## Overview

Lightning Web Components (LWC) enterprise patterns provide architectural guidance for building scalable, maintainable component libraries for Salesforce managed packages. This skill covers proven patterns for component architecture, state management, event communication, and testing strategies that enable teams to deliver high-quality, reusable components.

Apply these patterns when building component libraries that require consistency, testability, and long-term maintainability across large development teams.

## Component Architecture Patterns

### Container/Presentational Pattern

Separate business logic from presentation by using container components to manage state and data operations while presentational components focus solely on rendering UI.

**Container Components:**
- Fetch data from Salesforce (wire adapters, imperative Apex)
- Manage component state
- Handle business logic and transformations
- Coordinate child component interactions
- Pass data and callbacks to presentational components

**Presentational Components:**
- Receive data via `@api` properties
- Emit events for user interactions
- No direct Salesforce data access
- Stateless where possible
- Highly reusable across contexts

**When to Use:**
- Complex components with significant business logic
- Components requiring data from multiple sources
- Reusable UI elements used across different contexts
- Components requiring comprehensive testing

**Benefits:**
- Clear separation of concerns
- Easier unit testing (presentational components mock-free)
- Reusability of presentational components
- Simplified maintenance

**Example Structure:**
```
accountDashboard/              // Container
  accountDashboard.js          // Handles @wire getAccount, state
  accountDashboard.html        // Minimal template
  accountDashboard.css
  __tests__/

accountCard/                   // Presentational
  accountCard.js               // @api account, dispatches events
  accountCard.html             // Rich UI template
  accountCard.css
  __tests__/
```

See `examples/containerComponent/` and `examples/presentationalComponent/` for complete implementations.

### Compound Components

Build components that work together as a coordinated system while maintaining flexibility and composability.

**Pattern:**
- Parent component provides context via properties
- Child components share implicit communication via parent
- Children can be used independently or within parent
- Flexible composition for different use cases

**Implementation Approaches:**

**1. Property Pass-Through:**
Parent component receives configuration and passes it to children.

**2. Event Coordination:**
Parent listens to child events and coordinates responses across siblings.

**3. Context Sharing:**
Use CSS custom properties or data attributes for shared styling context.

**When to Use:**
- Related components that work better together
- Configurable component groups
- Components requiring coordinated state changes
- Building design system primitives

**Example Use Case:**
```
// Compound components for a filterable list
<c-list-container filters={filters}>
  <c-list-header></c-list-header>
  <c-list-filter-bar onfilterchange={handleFilter}></c-list-filter-bar>
  <c-list-items items={filteredItems}></c-list-items>
  <c-list-footer count={itemCount}></c-list-footer>
</c-list-container>
```

### Base Components

Create abstract base components that encapsulate common functionality and extend them for specific use cases.

**Pattern:**
- Create a base component with shared logic
- Extend using composition (slots) not inheritance
- Use mixins for cross-cutting concerns
- Implement consistent interfaces via `@api` properties

**Common Base Components:**
- Data table bases with sorting, filtering
- Form field bases with validation
- Modal/dialog bases with accessibility
- Card layout bases with standardized structure

**Best Practices:**
- Keep base components focused on single responsibility
- Document extension points clearly
- Provide default implementations that can be overridden
- Use slots for flexible content injection

## State Management Patterns

### Local State (Component State)

Use component properties decorated with `@track` for local, encapsulated state.

**When to Use:**
- State only relevant to single component
- Temporary UI state (expanded/collapsed, selected tab)
- Form input values before submission

**Best Practices:**
- Minimize tracked properties for performance
- Use primitive types when possible
- Avoid deep object tracking
- Initialize state in constructor or property declaration

### Shared State (Parent-Child)

Pass state down through properties and emit events upward for state changes.

**Pattern:**
- Parent owns state
- Children receive state via `@api` properties
- Children dispatch CustomEvents for changes
- Parent updates state and re-renders children

**When to Use:**
- Related components in parent-child hierarchy
- State needs to be synchronized across siblings
- Parent orchestrates child interactions

**Best Practices:**
- Use immutable update patterns
- Keep event payloads simple
- Name events consistently (e.g., `itemselected`, `filterchanged`)
- Document event contracts clearly

### Pub-Sub Pattern

Implement publish-subscribe for communication across unrelated components using Lightning Message Service or custom pub-sub.

**Lightning Message Service (LMS):**
- Platform-native pub-sub mechanism
- Works across LWC, Aura, Visualforce
- Scoped to page or application
- Requires message channel definition

**When to Use:**
- Cross-component communication without direct relationship
- Broadcasting changes to multiple subscribers
- Decoupled architecture requirements
- Communication across different page regions

**Custom Pub-Sub Implementation:**
- Use for simple, non-critical scenarios
- Implement using JavaScript module
- Manage subscriptions and cleanup
- Consider memory leak prevention

**Best Practices:**
- Unsubscribe in `disconnectedCallback()`
- Use specific message channels for different concerns
- Keep message payloads minimal
- Document message contracts

See `references/state-management.md` for implementation examples.

### Service Components

Create JavaScript modules that act as shared services for data access, caching, and business logic.

**Pattern:**
- Export singleton service module
- Encapsulate Apex calls and caching
- Provide consistent API for data operations
- Manage in-flight request deduplication

**When to Use:**
- Shared data access across components
- Implementing client-side caching
- Centralizing business logic
- Managing complex asynchronous workflows

**Implementation:**
```javascript
// dataService.js
import getRecords from '@salesforce/apex/Controller.getRecords';

const cache = new Map();
let inFlightRequests = new Map();

export async function fetchRecords(params) {
  const cacheKey = JSON.stringify(params);

  if (cache.has(cacheKey)) {
    return cache.get(cacheKey);
  }

  if (inFlightRequests.has(cacheKey)) {
    return inFlightRequests.get(cacheKey);
  }

  const promise = getRecords(params);
  inFlightRequests.set(cacheKey, promise);

  try {
    const result = await promise;
    cache.set(cacheKey, result);
    return result;
  } finally {
    inFlightRequests.delete(cacheKey);
  }
}
```

## Event Communication Patterns

### Custom Events

Dispatch CustomEvents for component-to-component communication with proper bubbling and composition.

**Event Design Principles:**
- Use lowercase, hyphenated event names
- Include relevant data in `detail` object
- Set `bubbles: true` for events crossing shadow boundaries
- Set `composed: true` for events crossing component boundaries

**Implementation:**
```javascript
// Dispatching
this.dispatchEvent(new CustomEvent('itemselected', {
  detail: { itemId: this.selectedId },
  bubbles: true,
  composed: true
}));

// Handling in parent
<c-child-component onitemselected={handleItemSelected}></c-child-component>
```

**Best Practices:**
- Keep event names semantic and descriptive
- Document event contracts in component JSDoc
- Include only necessary data in `detail`
- Use consistent event naming conventions across library

### Event Delegation

Handle events at parent level for performance when dealing with many child elements.

**Pattern:**
- Attach event listener to parent container
- Use `event.target` to identify specific child
- Reduce number of event listeners
- Improve performance with large lists

**When to Use:**
- Rendering lists with many interactive items
- Dynamic content with unknown number of children
- Performance-critical scenarios

### Message Service Integration

Integrate Lightning Message Service for cross-namespace and cross-framework communication.

**Setup:**
1. Create message channel in metadata
2. Import message channel in component
3. Subscribe/publish messages
4. Clean up subscription

**Implementation:**
```javascript
import { LightningElement, wire } from 'lwc';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import RECORD_SELECTED from '@salesforce/messageChannel/RecordSelected__c';

export default class Publisher extends LightningElement {
  @wire(MessageContext)
  messageContext;

  handleSelect(event) {
    const message = { recordId: event.detail.id };
    publish(this.messageContext, RECORD_SELECTED, message);
  }
}
```

## Testing Patterns

### Unit Testing with Jest

Write comprehensive Jest tests for LWC components following enterprise testing patterns.

**Test Structure:**
```javascript
import { createElement } from 'lwc';
import ComponentName from 'c/componentName';

describe('c-component-name', () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it('should render correctly with valid data', () => {
    // Arrange
    const element = createElement('c-component-name', {
      is: ComponentName
    });

    // Act
    document.body.appendChild(element);

    // Assert
    expect(element.shadowRoot.querySelector('.className')).not.toBeNull();
  });
});
```

### Testing Patterns by Component Type

**Container Components:**
- Mock Apex calls using `@salesforce/apex` mocks
- Test data transformation logic
- Verify correct data passed to children
- Test error handling scenarios
- Verify loading states

**Presentational Components:**
- Test rendering with various prop combinations
- Verify event dispatching with correct payloads
- Test conditional rendering
- Validate accessibility attributes
- Test user interactions

**Example - Testing Events:**
```javascript
it('should dispatch event when button clicked', () => {
  const element = createElement('c-component', { is: Component });
  const handler = jest.fn();
  element.addEventListener('itemselected', handler);

  document.body.appendChild(element);

  const button = element.shadowRoot.querySelector('button');
  button.click();

  expect(handler).toHaveBeenCalledTimes(1);
  expect(handler.mock.calls[0][0].detail).toEqual({ itemId: '123' });
});
```

### Mocking Strategies

**Apex Methods:**
```javascript
import getAccounts from '@salesforce/apex/AccountController.getAccounts';

jest.mock(
  '@salesforce/apex/AccountController.getAccounts',
  () => ({ default: jest.fn() }),
  { virtual: true }
);

// In test
getAccounts.mockResolvedValue([{ Id: '001', Name: 'Test' }]);
```

**Wire Adapters:**
```javascript
import { getRecord } from 'lightning/uiRecordApi';

jest.mock('lightning/uiRecordApi', () => ({
  getRecord: jest.fn()
}), { virtual: true });

// In test
import { emit } from '@salesforce/sfdx-lwc-jest';

emit('getRecord', { data: mockRecord });
```

**User Permissions:**
```javascript
import hasPermission from '@salesforce/userPermission/CustomPermission';

jest.mock('@salesforce/userPermission/CustomPermission', () => ({
  default: true
}), { virtual: true });
```

See `references/testing-patterns.md` for comprehensive testing examples.

## Accessibility Best Practices

### ARIA and Semantic HTML

Use semantic HTML elements and ARIA attributes for screen reader support.

**Key Practices:**
- Use `<button>` for clickable actions, not `<div>`
- Add `aria-label` for icon-only buttons
- Use `role` attributes when semantic HTML insufficient
- Implement `aria-live` regions for dynamic content
- Use `aria-describedby` for form field help text

**Example:**
```html
<button
  aria-label="Close dialog"
  onclick={handleClose}>
  <lightning-icon icon-name="utility:close"></lightning-icon>
</button>

<div role="status" aria-live="polite" aria-atomic="true">
  {statusMessage}
</div>
```

### Keyboard Navigation

Ensure all interactive elements are keyboard accessible.

**Requirements:**
- All interactive elements reachable via Tab
- Visual focus indicators present
- Logical tab order maintained
- Enter/Space activate buttons
- Escape closes dialogs/dropdowns
- Arrow keys for radio groups/lists

**Implementation:**
```javascript
handleKeyDown(event) {
  if (event.key === 'Escape') {
    this.closeDialog();
  } else if (event.key === 'Enter' || event.key === ' ') {
    event.preventDefault();
    this.handleSelection();
  }
}
```

### Focus Management

Manage focus explicitly for modals, dynamic content, and navigation.

**Patterns:**
- Trap focus within modals
- Return focus to trigger element after modal closes
- Move focus to new content after navigation
- Announce dynamic content changes to screen readers

## Performance Optimization

### Rendering Optimization

**Use `if:true` and `if:false` Sparingly:**
Prefer CSS `display: none` for frequently toggled elements to avoid re-rendering.

**Avoid Unnecessary Re-renders:**
- Use primitive properties when possible
- Implement property change detection
- Leverage immutable data patterns
- Use `@track` judiciously

**Lazy Loading:**
```javascript
// Dynamic import for large components
async loadEditor() {
  const { default: Editor } = await import('c/richTextEditor');
  // Use dynamically loaded component
}
```

### Data Loading Optimization

**Wire Service Best Practices:**
- Use wire adapters for automatic caching
- Implement refresh strategies
- Handle loading and error states
- Use `getRecordNotifyChange` for cache invalidation

**Imperative Apex:**
- Use for user-initiated actions
- Implement client-side caching
- Debounce frequent calls
- Show loading indicators

**Example - Debouncing:**
```javascript
@api
handleSearch(event) {
  clearTimeout(this.searchTimeout);
  const searchTerm = event.target.value;

  this.searchTimeout = setTimeout(() => {
    this.performSearch(searchTerm);
  }, 300);
}
```

### Memory Management

**Prevent Memory Leaks:**
- Clear timeouts/intervals in `disconnectedCallback()`
- Unsubscribe from message channels
- Remove event listeners
- Clear large data structures

**Example:**
```javascript
disconnectedCallback() {
  if (this.subscription) {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  clearTimeout(this.searchTimeout);
  clearInterval(this.refreshInterval);
}
```

## Component Composition

### Slot-Based Composition

Use slots for flexible content injection and component composition.

**Default Slot:**
```html
<!-- parent component -->
<div class="container">
  <slot></slot>
</div>
```

**Named Slots:**
```html
<!-- parent component -->
<div class="card">
  <header>
    <slot name="header"></slot>
  </header>
  <div class="body">
    <slot></slot>
  </div>
  <footer>
    <slot name="footer"></slot>
  </footer>
</div>

<!-- usage -->
<c-card>
  <h1 slot="header">Title</h1>
  <p>Content</p>
  <div slot="footer">Actions</div>
</c-card>
```

### Component Interfaces

Define clear component APIs using `@api` properties with validation.

**Best Practices:**
- Document all `@api` properties with JSDoc
- Validate property values in setters
- Provide sensible defaults
- Use getters for computed properties
- Keep interfaces minimal and focused

**Example:**
```javascript
/**
 * @typedef {Object} Item
 * @property {string} id - Unique identifier
 * @property {string} name - Display name
 * @property {boolean} [selected] - Selection state
 */

export default class ItemList extends LightningElement {
  /**
   * List of items to display
   * @type {Item[]}
   */
  @api items = [];

  /**
   * Maximum number of items to display
   * @type {number}
   */
  @api
  get maxItems() {
    return this._maxItems;
  }
  set maxItems(value) {
    this._maxItems = value > 0 ? value : 10;
  }
  _maxItems = 10;
}
```

## Error Handling

### User-Facing Errors

Display clear, actionable error messages using Lightning Design System patterns.

**Implementation:**
```javascript
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

handleError(error) {
  const evt = new ShowToastEvent({
    title: 'Error loading data',
    message: this.getErrorMessage(error),
    variant: 'error',
    mode: 'sticky'
  });
  this.dispatchEvent(evt);
}

getErrorMessage(error) {
  if (Array.isArray(error.body)) {
    return error.body.map(e => e.message).join(', ');
  } else if (error.body?.message) {
    return error.body.message;
  }
  return 'An unexpected error occurred';
}
```

### Defensive Programming

Implement null checks and default values to prevent runtime errors.

**Patterns:**
- Use optional chaining: `record?.Name`
- Provide default values: `items ?? []`
- Validate before accessing: `if (data && data.length > 0)`
- Guard against undefined in templates: `{item.name || 'N/A'}`

## Additional Resources

### Reference Files

- **`references/testing-patterns.md`** - Comprehensive Jest testing examples, mocking strategies, coverage patterns
- **`references/state-management.md`** - State management implementation patterns, pub-sub examples, LMS integration

### Example Components

- **`examples/containerComponent/`** - Complete container component with data fetching, state management, error handling
- **`examples/presentationalComponent/`** - Presentational component with events, slots, accessibility

### External Resources

- [LWC Developer Guide](https://developer.salesforce.com/docs/component-library/documentation/en/lwc)
- [Lightning Design System](https://www.lightningdesignsystem.com/)
- [LWC Recipes](https://github.com/trailheadapps/lwc-recipes)
- [SFDX LWC Jest Testing](https://github.com/salesforce/sfdx-lwc-jest)

## Quick Reference

### Pattern Selection Guide

| Pattern | Use When | Benefits |
|---------|----------|----------|
| Container/Presentational | Complex components with business logic | Testability, reusability, separation of concerns |
| Compound Components | Related components work together | Flexibility, coordinated behavior, composition |
| Pub-Sub | Unrelated components need communication | Decoupling, scalability, event broadcasting |
| Service Components | Shared data access needed | Caching, consistency, centralized logic |
| Event Delegation | Many interactive child elements | Performance, fewer listeners, scalability |

### Testing Checklist

- [ ] Unit tests for all public methods
- [ ] Event dispatch and handling tested
- [ ] Apex method mocking implemented
- [ ] Error scenarios covered
- [ ] Accessibility attributes verified
- [ ] User interactions tested
- [ ] Edge cases handled
- [ ] Coverage >80% for components

### Accessibility Checklist

- [ ] Semantic HTML elements used
- [ ] ARIA labels for icon-only buttons
- [ ] Keyboard navigation implemented
- [ ] Focus management for modals
- [ ] Color contrast meets WCAG AA
- [ ] Screen reader tested
- [ ] Tab order logical
- [ ] Dynamic content announced

Apply these enterprise patterns to build maintainable, scalable LWC component libraries for Salesforce managed packages.
