---
name: portal-component
description: Generate Next.js components for the portal app with proper patterns. Use when creating new pages, components, or features in apps/portal.
---

# Portal Component Generator

Generate Next.js 16 components following portal conventions.

## Page Structure

For a new feature at `/app/feature/page.tsx`:

```
app/feature/
├── page.tsx           # Minimal, renders component
├── loading.tsx        # Uses FeatureSkeleton
└── layout.tsx         # Optional layout wrapper

components/feature/
├── index.ts           # Barrel exports
├── feature-page.tsx   # Main component + skeleton
├── feature-content.tsx # Inner content
└── feature-context.tsx # Optional context/provider
```

## Page Template

```tsx
// app/feature/page.tsx
import { FeaturePage } from "@/components/feature";

interface Props {
  params: Promise<{ id: string }>;
}

export default async function FeatureRoute({ params }: Props) {
  const { id } = await params;
  return <FeaturePage featureId={id} />;
}
```

## Loading Template

```tsx
// app/feature/loading.tsx
import { FeatureSkeleton } from "@/components/feature";

export default function FeatureLoading() {
  return <FeatureSkeleton />;
}
```

## Component Template

```tsx
// components/feature/feature-page.tsx
"use client";

import { Skeleton } from "@/components/ui/skeleton";

interface FeaturePageProps {
  featureId: string;
}

export function FeaturePage({ featureId }: FeaturePageProps) {
  return (
    <div className="space-y-6">
      <FeatureContent featureId={featureId} />
    </div>
  );
}

export function FeatureSkeleton() {
  return (
    <div className="space-y-6">
      <Skeleton className="h-32 w-full" />
      <div className="grid gap-4 md:grid-cols-2">
        <Skeleton className="h-64" />
        <Skeleton className="h-64" />
      </div>
    </div>
  );
}
```

## Barrel Export Template

```ts
// components/feature/index.ts
export { FeaturePage, FeatureSkeleton } from "./feature-page";
export { FeatureContent } from "./feature-content";
```

## Jotai Atom Template

```ts
// atoms/feature/state.ts
"use client";

import { atom } from "jotai";
import { atomWithStorage } from "jotai/utils";

export const featureStateAtom = atom<FeatureState>({
  // initial state
});

// For persisted state
export const featureSettingsAtom = atomWithStorage("feature-settings", {
  // defaults
});
```

## Provider/Context Pattern

For complex features needing data fetching + actions (like nodes, auth):

```tsx
// providers/feature-manager.tsx
"use client";

import { createContext, useContext, useCallback, type ReactNode } from "react";
import { useList, useCreate, useUpdate } from "@refinedev/core";

interface FeatureManagerContextValue {
  // Data
  items: ItemType[];
  isLoading: boolean;

  // Actions
  createItem: (data: CreateData) => Promise<void>;
  updateItem: (id: string, data: UpdateData) => Promise<void>;
  refetch: () => void;
}

const FeatureManagerContext = createContext<FeatureManagerContextValue | null>(
  null,
);

export function FeatureManagerProvider({ children }: { children: ReactNode }) {
  const { result, query } = useList<ItemType>({
    resource: "items",
  });

  const { mutateAsync: createMutation } = useCreate<ItemType>();

  const createItem = useCallback(
    async (data: CreateData) => {
      await createMutation({ resource: "items", values: data });
      query.refetch();
    },
    [createMutation, query],
  );

  return (
    <FeatureManagerContext.Provider
      value={{
        items: result?.data ?? [],
        isLoading: query.isLoading,
        createItem,
        refetch: query.refetch,
      }}
    >
      {children}
    </FeatureManagerContext.Provider>
  );
}

export function useFeatureManager(): FeatureManagerContextValue {
  const context = useContext(FeatureManagerContext);
  if (!context) {
    throw new Error(
      "useFeatureManager must be used within FeatureManagerProvider",
    );
  }

  return context;
}
```

Re-export from `providers/index.ts`:

```ts
export { FeatureManagerProvider, useFeatureManager } from "./feature-manager";
export type { ItemType } from "./feature-manager";
```

## Formatting Utilities

Always use `@/lib/format` for consistent formatting:

```tsx
import {
  formatInt,
  formatRelativeToNow,
  formatPercent,
  formatDurationMs,
} from "@/lib/format";

// Numbers
formatInt(1234567); // "1,234,567"
formatCompact(1234567); // "1.2M"
formatPercent(85.5); // "85.5%"

// Dates
formatRelativeToNow(date); // "2 hours ago"
formatDate(date, "PP"); // "Jan 1, 2024"

// Durations
formatDurationMs(5000); // "5 seconds"
formatDurationSeconds(300); // "5 minutes"
```

## Instructions

1. Ask what the feature/component should do
2. Determine if it needs state (Jotai atoms) or data management (Provider)
3. Generate page, loading, and component files
4. Create barrel exports
5. Add atoms or provider as needed
6. Use formatting utilities for numbers, dates, durations
