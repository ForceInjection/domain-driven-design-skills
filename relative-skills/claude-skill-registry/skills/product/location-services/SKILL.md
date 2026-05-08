---
name: location-services
description: Location services, GPS tracking, and geolocation features using Expo Location. Use when implementing location-based functionality like finding nearby stations.
---

# Location Services Guidelines

## When to Use
- Requesting location permissions
- Getting user's current position
- Finding nearby subway stations
- Calculating distances between coordinates

## Setup

### Installation
```bash
npx expo install expo-location
```

### Configuration (app.json)
```json
{
  "expo": {
    "ios": {
      "infoPlist": {
        "NSLocationWhenInUseUsageDescription": "LiveMetro needs your location to find nearby subway stations."
      }
    },
    "android": {
      "permissions": ["ACCESS_COARSE_LOCATION", "ACCESS_FINE_LOCATION"]
    }
  }
}
```

## Core Patterns

### Permission Request
```typescript
import * as Location from 'expo-location';

const requestPermission = async (): Promise<boolean> => {
  const { status } = await Location.requestForegroundPermissionsAsync();
  return status === 'granted';
};
```

### Get Current Location
```typescript
const location = await Location.getCurrentPositionAsync({
  accuracy: Location.Accuracy.Balanced,
});
```

### Distance Calculation
```typescript
import { getDistance } from 'geolib';

const distance = getDistance(
  { latitude: 37.4979, longitude: 127.0276 },
  station.coordinates
);
```

### Distance Formatting
```typescript
const formatDistance = (meters: number): string => {
  if (meters < 1000) return `${Math.round(meters)}m`;
  return `${(meters / 1000).toFixed(1)}km`;
};
```

## Accuracy Levels

| Level | Accuracy | Use Case |
|-------|----------|----------|
| `Lowest` | ~3000m | Battery-friendly background |
| `Low` | ~1000m | Rough proximity |
| `Balanced` | ~100m | **Nearby stations (recommended)** |
| `High` | ~10m | Precise location |
| `Highest` | GPS | Maximum precision |

## Error Handling

```typescript
const handleLocationError = (error: unknown): string => {
  if (error instanceof Error) {
    if (error.message.includes('permission')) {
      return 'Location permission is required';
    }
    if (error.message.includes('timeout')) {
      return 'Location request timed out';
    }
  }
  return 'Failed to get location';
};
```

## Best Practices

1. **Request Permission at Right Time**
   ```tsx
   // ❌ Bad: On app launch
   // ✅ Good: When user clicks "Find Nearby"
   const handleFindNearby = async () => {
     const hasPermission = await requestPermission();
     if (hasPermission) { /* proceed */ }
   };
   ```

2. **Handle Permission Denial**
   - Check `canAskAgain` from `getForegroundPermissionsAsync()`
   - If `false`, direct user to Settings with `Linking.openSettings()`

3. **Cache Location**
   - Cache for 60 seconds to reduce GPS usage
   - Return cached on repeated requests

4. **Handle Offline**
   - Return last known location when GPS unavailable

## Important Notes

- Always explain WHY you need location permission
- Use `Accuracy.Balanced` for nearby stations (battery + accuracy)
- Test on both iOS and Android (permission flows differ)
- Clean up background tracking when not needed

## Reference Documentation

For complete implementations, see [references/hooks-examples.md](references/hooks-examples.md):
- useLocation hook
- useNearbyStations hook
- Background location tracking
- Permission states handling
- Testing mocks
