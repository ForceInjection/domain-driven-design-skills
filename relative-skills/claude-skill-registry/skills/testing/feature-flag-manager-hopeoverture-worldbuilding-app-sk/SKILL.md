---
name: feature-flag-manager
description: Adds feature flag support using LaunchDarkly or JSON-based configuration to toggle features in UI components and Server Actions. This skill should be used when implementing feature flags, feature toggles, progressive rollouts, A/B testing, or gating functionality behind configuration. Use for feature flags, feature toggles, LaunchDarkly integration, progressive rollout, canary releases, or conditional features.
---

# Feature Flag Manager

Implement comprehensive feature flag management for controlled feature rollouts and A/B testing in worldbuilding applications.

## Overview

To add feature flag capabilities:

1. Choose between LaunchDarkly (cloud service) or JSON-based (local) implementation
2. Set up feature flag provider with configuration
3. Create feature flag components and hooks
4. Gate UI components and Server Actions behind flags
5. Implement user targeting and progressive rollouts

## Implementation Options

### LaunchDarkly Integration

To integrate LaunchDarkly:

1. Install LaunchDarkly SDK: `npm install launchdarkly-react-client-sdk`
2. Configure provider in app root with client-side ID
3. Create hooks for flag evaluation
4. Wrap components with feature flag checks
5. Configure flags in LaunchDarkly dashboard

Use `scripts/setup_launchdarkly.py` to scaffold LaunchDarkly configuration.

### JSON-Based Feature Flags

To implement local JSON-based flags:

1. Create `config/feature-flags.json` with flag definitions
2. Build feature flag provider context
3. Create hooks to read flags from context
4. Implement environment-specific overrides
5. Support runtime flag updates

Use `scripts/setup_json_flags.py` to generate JSON flag structure.

Consult `references/feature-flag-patterns.md` for implementation patterns and best practices.

## Feature Flag Provider Setup

### LaunchDarkly Provider

To set up LaunchDarkly in Next.js:

```typescript
// app/providers.tsx
import { LDProvider } from 'launchdarkly-react-client-sdk';

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <LDProvider
      clientSideID={process.env.NEXT_PUBLIC_LD_CLIENT_ID}
      user={{
        key: 'user-id',
        email: 'user@example.com',
      }}
    >
      {children}
    </LDProvider>
  );
}
```

### JSON Provider

To create custom JSON provider:

```typescript
// lib/feature-flags/provider.tsx
import { createContext, useContext } from 'react';
import flags from '@/config/feature-flags.json';

const FeatureFlagContext = createContext(flags);

export function FeatureFlagProvider({ children }: { children: React.ReactNode }) {
  return (
    <FeatureFlagContext.Provider value={flags}>
      {children}
    </FeatureFlagContext.Provider>
  );
}

export function useFeatureFlags() {
  return useContext(FeatureFlagContext);
}
```

Reference `assets/feature-flag-provider.tsx` for complete provider implementation.

## Using Feature Flags

### Component Gating

To gate UI components behind flags:

```typescript
import { useFeatureFlag } from '@/lib/feature-flags';

export function NewFeatureComponent() {
  const isEnabled = useFeatureFlag('new-timeline-view');

  if (!isEnabled) {
    return null;
  }

  return <div>New Timeline View</div>;
}
```

### Conditional Rendering

To show different variants based on flags:

```typescript
export function EntityList() {
  const useNewLayout = useFeatureFlag('entity-list-redesign');

  return useNewLayout ? <NewEntityList /> : <LegacyEntityList />;
}
```

### Server Action Gating

To gate Server Actions:

```typescript
// app/actions/entity-actions.ts
'use server';

import { getFeatureFlag } from '@/lib/feature-flags/server';

export async function createEntity(data: EntityData) {
  const allowBulkCreate = await getFeatureFlag('bulk-entity-creation');

  if (allowBulkCreate && data.items?.length > 1) {
    return bulkCreateEntities(data.items);
  }

  return createSingleEntity(data);
}
```

Reference `assets/server-actions-with-flags.ts` for server-side flag patterns.

## Flag Configuration

### Flag Structure

Define flags with metadata:

```json
{
  "flags": {
    "new-timeline-view": {
      "enabled": true,
      "description": "Enable new timeline visualization",
      "rolloutPercentage": 100,
      "allowedUsers": [],
      "environments": {
        "development": true,
        "staging": true,
        "production": false
      }
    }
  }
}
```

### Flag Types

Support different flag types:

- **Boolean**: Simple on/off toggle
- **Percentage**: Gradual rollout (0-100%)
- **User Targeting**: Specific users or groups
- **Multivariate**: Multiple variations (A/B/C testing)

Consult `references/flag-types.md` for detailed flag type specifications.

## Progressive Rollout

To implement gradual feature rollouts:

1. **Initial Release**: Enable for 5% of users
2. **Monitor Metrics**: Track performance and errors
3. **Increase Rollout**: Gradually increase to 25%, 50%, 100%
4. **Full Release**: Enable for all users
5. **Remove Flag**: Clean up flag code after stable release

Use `scripts/rollout_manager.py` to automate rollout percentage updates.

## User Targeting

To target specific user segments:

### By User ID

```typescript
const flags = evaluateFlags(userId, flagConfig);
```

### By User Properties

```typescript
const flags = evaluateFlags({
  userId: 'user-123',
  email: 'user@example.com',
  role: 'admin',
  tier: 'premium',
});
```

### By Custom Rules

```typescript
const flags = evaluateFlags(user, {
  rules: [
    { property: 'role', operator: 'equals', value: 'admin' },
    { property: 'tier', operator: 'in', values: ['premium', 'enterprise'] },
  ],
});
```

## Environment-Specific Flags

To configure flags per environment:

```json
{
  "flags": {
    "debug-mode": {
      "development": true,
      "staging": true,
      "production": false
    },
    "experimental-features": {
      "development": true,
      "staging": false,
      "production": false
    }
  }
}
```

Load environment-specific configuration at build time or runtime.

## A/B Testing

To implement A/B tests:

```typescript
export function EntityDetailPage() {
  const variant = useFeatureFlagVariant('entity-detail-layout', {
    control: 'grid',
    variantA: 'list',
    variantB: 'cards',
  });

  return variant === 'list' ? (
    <EntityListView />
  ) : variant === 'cards' ? (
    <EntityCardView />
  ) : (
    <EntityGridView />
  );
}
```

Track variant exposure for analytics:

```typescript
useEffect(() => {
  trackExposure('entity-detail-layout', variant);
}, [variant]);
```

## Flag Lifecycle Management

### Creating New Flags

To add a new feature flag:

1. Define flag in configuration with metadata
2. Set initial state (usually disabled)
3. Implement flag checks in code
4. Deploy with flag disabled
5. Enable flag via dashboard or config update

### Removing Old Flags

To clean up completed feature flags:

1. Ensure flag is at 100% rollout
2. Verify no incidents for 2+ weeks
3. Remove flag checks from code
4. Make flagged code permanent
5. Remove flag from configuration
6. Deploy cleanup changes

Use `scripts/find_flag_usage.py` to locate all usages of a flag before removal.

## Testing with Feature Flags

### Local Development

To override flags in development:

```typescript
// .env.local
NEXT_PUBLIC_FEATURE_FLAGS_OVERRIDE='{"new-timeline-view":true}'
```

### Testing Specific Variants

To test flag variations:

```typescript
// test/setup.ts
import { mockFeatureFlags } from '@/lib/feature-flags/testing';

beforeEach(() => {
  mockFeatureFlags({
    'new-timeline-view': true,
    'bulk-entity-creation': false,
  });
});
```

Reference `assets/testing-utils.ts` for testing utilities.

## Monitoring and Analytics

To track feature flag impact:

1. **Exposure Tracking**: Log when flags are evaluated
2. **Performance Metrics**: Monitor performance per variant
3. **Error Rates**: Track errors by flag state
4. **User Engagement**: Measure feature usage
5. **Conversion Metrics**: Track business metrics per variant

Integrate with analytics platform:

```typescript
import { analytics } from '@/lib/analytics';

export function useFeatureFlagWithTracking(flagName: string) {
  const isEnabled = useFeatureFlag(flagName);

  useEffect(() => {
    analytics.track('feature_flag_exposure', {
      flag: flagName,
      enabled: isEnabled,
    });
  }, [flagName, isEnabled]);

  return isEnabled;
}
```

## LaunchDarkly-Specific Features

To leverage LaunchDarkly capabilities:

- **Targeting Rules**: Create complex targeting rules in dashboard
- **Flag Triggers**: Automate flag changes based on metrics
- **Scheduled Rollouts**: Plan feature releases in advance
- **Flag Dependencies**: Define flag prerequisites
- **Audit Logs**: Track all flag changes
- **Team Workflows**: Require approvals for production changes

Consult LaunchDarkly documentation for advanced features.

## Best Practices

1. **Short-Lived Flags**: Remove flags after rollout completes
2. **Clear Naming**: Use descriptive, consistent flag names
3. **Documentation**: Document flag purpose and timeline
4. **Default Values**: Provide safe defaults for missing flags
5. **Testing**: Test both enabled and disabled states
6. **Monitoring**: Track flag performance and errors
7. **Cleanup**: Regularly audit and remove unused flags

## Troubleshooting

Common issues:

- **Flag Not Updating**: Check cache settings and invalidation
- **Inconsistent State**: Verify flag evaluation consistency
- **Performance Impact**: Minimize flag evaluation overhead
- **Testing Challenges**: Use proper mocking in tests
- **Configuration Conflicts**: Ensure environment-specific overrides work correctly
