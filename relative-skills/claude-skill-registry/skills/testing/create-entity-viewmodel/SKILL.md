---
name: Create Entity ViewModel
description: Create a new entity ViewModel with property ViewModels following {{sharedLib}} MVVM patterns. Use when adding new data models, creating entity wrappers, or scaffolding ViewModels for entities. Handles property VM creation, label converters, base class selection, and test generation.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# Create Entity ViewModel

This skill scaffolds a complete entity ViewModel following {{sharedLib}} framework patterns.

## When to Use

- Creating a new entity ViewModel for a data model
- Wrapping an existing model with UI logic
- Adding property ViewModels for entity properties
- Setting up label converters for enum types

## Prerequisites

- Data model must exist in `/model/*.model/src/` and be generated
- Run `npm run generate-model` if model was just created
- Entity should be defined with proper property types (ValueProperty, CommandedProperty, etc.)

## Process

### Step 1: Understand the Data Model

Read the source model to understand:
- Property types (ValueProperty, CommandedProperty, RangedCommandedProperty)
- Enum types that need label converters
- Geographic properties (lat/lon/alt)
- Parent class (Entity, GeoEntity, Platform, etc.)

**Reference**: [ENTITY_ARCHITECTURE.md](../../ai-guide/_ARCHITECTURE/ENTITY_ARCHITECTURE.md)

### Step 2: Choose the Right Base Class

Determine appropriate base class:
- **EntityViewModel** - Standard entities (settings, configs)
- **GeoEntityBaseVM** - Entities with location data (platforms, vehicles)
- **GeoPointBaseVM** - Simple geographic points (waypoints, markers)
- **Custom abstract base** - Multiple related entities share functionality

**Reference**: [ENTITY_ARCHITECTURE.md - Best Practices](../../ai-guide/_ARCHITECTURE/ENTITY_ARCHITECTURE.md#best-practices-for-creating-entity-viewmodels)

### Step 3: Create Property ViewModels

For each property on the model, create appropriate property VM:

**Property Type Mapping**:
- `ValueProperty<string>` → `StringViewModel`
- `CommandedProperty<string>` → `CommandedStringViewModel`
- `ValueProperty<number>` → `NumberViewModel`
- `RangedCommandedProperty<number>` → `RangedCommandedNumberViewModel`
- `CommandedProperty<boolean>` → `CommandedBooleanViewModel`
- `CommandedProperty<EnumType>` → `CommandedEnumViewModel<EnumType>`
- `ValueProperty<string[]>` → `ArrayViewModel<string>`
- `CommandedProperty<string[]>` → `CommandedArrayViewModel<string>`

**CRITICAL Patterns**:
- Use `CommandedArrayViewModel`, NOT `ArrayViewModel` for commanded arrays
- Use `RangedCommandedNumberViewModel` for numbers with min/max, NOT `CommandedNumberViewModel`
- Always add type hints for labelConverter: `(value: number | null | undefined) => string`
- Return `'---'` for null/undefined values in labelConverter

**@computed Decorator Usage**:

Use `@computed` when getter:
- Includes configuration (labelConverter, defaultValue, etc.) - prevents re-running configure
- Derives/computes values from observables
- Filters or transforms data

```typescript
// ✅ With configuration - use @computed
@computed
get modeVM(): ICommandedVM<ModeType, IEnumFormatOptions<ModeType>> {
    const vm = this.createPropertyVM('mode', CommandedEnumViewModel<ModeType>);
    vm.configure({
        labelConverter: ModeTypeLabel,
        defaultValue: ModeType.DEFAULT
    });
    return vm;
}

// ✅ Simple forwarding - @computed optional (micro-optimization)
get nameVM(): IPropertyVM<string, IStringFormatOptions> {
    return this.createPropertyVM('name', CommandedStringViewModel);
}

// ✅ Derived values - @computed required
@computed
get activeItems(): EntityViewModel[] {
    return this.items.filter(item => item.isActive);
}
```

**Reference**: [ENTITY_ARCHITECTURE.md - Property ViewModel Patterns](../../ai-guide/_ARCHITECTURE/ENTITY_ARCHITECTURE.md#3-property-viewmodel-patterns)

### Step 4: Create Label Converters for Enums

For each enum type, create a label converter in `adapters/types.ts`:

```typescript
export const YourEnumTypeLabel: Record<YourEnumType, string> = {
    [YourEnumType.VALUE1]: 'Display Label 1',
    [YourEnumType.VALUE2]: 'Display Label 2',
};
```

**Reference**: [ENTITY_ARCHITECTURE.md - Label Converter Creation](../../ai-guide/_ARCHITECTURE/ENTITY_ARCHITECTURE.md#5-label-converter-creation)

### Step 5: Implement Required Methods

All entity ViewModels must implement:
- `getEntityClassName()` - Returns `ModelClass.class`
- `getEntityCtr()` - Returns the model constructor

**Reference**: [COOKBOOK_PATTERNS_ENHANCED.md - Complete Entity ViewModel](../../ai-guide/_DAILY/COOKBOOK_PATTERNS_ENHANCED.md#complete-entity-viewmodel)

**Standard Import Pattern**:
```typescript
// Framework interfaces and types
import { IEntityConstructor, IFrameworkServices, IPropertyVM, ICommandedVM, IEnumFormatOptions, IStringFormatOptions, INumberFormatOptions } from '@{{company}}/framework-api';

// Entity ViewModel base and property VMs (from {{sharedLib}}-core)
import { EntityViewModel, CommandedStringViewModel, CommandedEnumViewModel, RangedCommandedNumberViewModel, CommandedArrayViewModel } from '@{{company}}/{{sharedLib}}-core';

// MobX decorators
import { computed, makeObservable } from 'mobx';

// Model and types
import { MyEntity } from '@{{company}}/your-model-package';
import { MyEnumType } from '@{{company}}/your-model-package';

// Label converters (from adapters)
import { MyEnumTypeLabel } from '../adapters/types';
```

### Step 6: Add MobX Support

**CRITICAL**: Call `makeObservable(this)` in constructor!

```typescript
constructor(services: IFrameworkServices) {
    super(services);
    makeObservable(this);  // REQUIRED for reactivity
}
```

**Reference**: [MOBX_ESSENTIALS.md - Constructor Pattern](../../ai-guide/_DAILY/MOBX_ESSENTIALS.md#constructor-pattern)

### Step 7: Update Barrel Exports

Add to `{lib}.core/src/index.ts`:
```typescript
export * from './lib/viewModels/yourEntityViewModel';
```

Add label converters to `{lib}.core/src/lib/adapters/index.ts`:
```typescript
export * from './types';
```

### Step 8: Create Tests

Generate unit tests following patterns:
- Mock IFrameworkServices
- Test property VM creation
- Test getEntityClassName/getEntityCtr
- Test label converters

**Reference**: [TESTING_GUIDE.md](../../ai-guide/_DAILY/TESTING_GUIDE.md)

## Common Pitfalls to Avoid

**Reference**: [COMMON_PITFALLS.md](../../ai-guide/_DAILY/COMMON_PITFALLS.md)

1. ❌ Don't use `BaseEntityViewModel` - Use `EntityViewModel` from {{sharedLib}}-core
2. ❌ Don't use `ArrayViewModel` for commanded arrays - Use `CommandedArrayViewModel`
3. ❌ Don't forget `makeObservable(this)` in constructor
4. ❌ Don't use `CommandedNumberViewModel` for constrained numbers - Use `RangedCommandedNumberViewModel`
5. ❌ Don't hardcode labels - Create label converters in adapters
6. ❌ Don't forget type hints on labelConverter functions
7. ❌ Don't return 'N/A' for null - Use `'---'`
8. ❌ Don't forget `@computed` on property VMs with configuration or derived values

## Complete Template

**Reference**: [COOKBOOK_PATTERNS_ENHANCED.md - Complete Entity ViewModel](../../ai-guide/_DAILY/COOKBOOK_PATTERNS_ENHANCED.md#complete-entity-viewmodel)

## File Locations

- Entity ViewModels: `{lib}.core/src/lib/viewModels/`
- Label Converters: `{lib}.core/src/lib/adapters/types.ts`
- Tests: `{lib}.core/src/lib/viewModels/__tests__/`

## Verification Steps

After creation:
1. Run `./tools/build-helpers/count-client-errors.sh` - Should be 0
2. Run `npm test` - New tests should pass
3. Verify exports in index.ts
4. Check label converters work in UI components

## Ask User If Unclear

- Which library to create the VM in ({{projectName}}.core, alpha.core, etc.)
- Whether this is a geographic entity (needs GeoEntityBaseVM)
- Default values for enum properties
- Whether to create abstract base class (if multiple similar entities)