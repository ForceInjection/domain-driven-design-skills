---
name: maplibre-offline-map-manager
description: Manages offline-capable mapping with tile caching, location services, and MapLibre integration. Use when implementing map features, GPS tracking, offline map regions, or custom map styles in Purrsuit Mobile App.
---

# MapLibre Offline Map Manager

This skill handles MapLibre integration, offline tile management, and location services following the patterns established in the Purrsuit Mobile App.

## When to Use This Skill

Use this skill when you need to:
- Implement interactive maps using MapLibre
- Handle GPS location tracking and permissions
- Manage offline map regions (download, delete, list)
- Switch between custom map styles (Liberty, Bright, Positron, Dark)
- Perform geocoding or reverse geocoding
- Fit map bounds to a collection of coordinates

## Map Components

### MapView with Camera
```tsx
import { MapView, Camera, PointAnnotation } from "@maplibre/maplibre-react-native"
import { MAP_STYLES } from "@/services/offlineMapManager"

<MapView
  ref={mapRef}
  style={StyleSheet.absoluteFillObject}
  mapStyle={MAP_STYLES[mapStyle].url}
>
  <Camera
    ref={cameraRef}
    longitude={longitude}
    latitude={latitude}
    zoom={12}
  />
</MapView>
```

### Point Annotations (Markers)
```tsx
<PointAnnotation
  id={encounter.id}
  coordinate={[lng, lat]}
  onSelected={() => handleMarkerPress(encounter.id)}
>
  <View style={styles.marker}>
    <Text>{emoji}</Text>
  </View>
</PointAnnotation>
```

## Offline Management

### Downloading a Region
```typescript
import { offlineMapManager } from "@/services/offlineMapManager"

await offlineMapManager.downloadRegion({
  name: "Downtown SF",
  bounds: [[-122.45, 37.8], [-122.4, 37.75]],
  minZoom: 10,
  maxZoom: 16
}, (status) => {
  console.log(`Download progress: ${status.percentage}%`)
})
```

## Location Services

### Getting Current Location
```typescript
import { getCurrentLocation, requestLocationPermissions } from "@/services/location"

const permission = await requestLocationPermissions()
if (permission.granted) {
  const coords = await getCurrentLocation()
  // { latitude, longitude, accuracy }
}
```

### Reverse Geocoding
```typescript
import { reverseGeocodeAsync, formatAddress } from "@/services/location"

const address = await reverseGeocodeAsync(lat, lng)
const displayString = formatAddress(address)
```

## Advanced Patterns

### Fitting Multiple Markers
```typescript
const bounds = [minLng, minLat, maxLng, maxLat] // [W, S, E, N]
cameraRef.current?.fitBounds(bounds, {
  padding: { top: 50, right: 50, bottom: 50, left: 50 },
  duration: 1000,
})
```

### Coordinate Conversion
```typescript
import { toMapLibreCoords, fromMapLibreCoords } from "@/services/offlineMapManager"

const mapLibreCoord = toMapLibreCoords({ latitude, longitude }) // [lng, lat]
const nativeCoord = fromMapLibreCoords([lng, lat]) // { latitude, longitude }
```

## References

See [MAP_PATTERNS.md](references/MAP_PATTERNS.md) for detailed implementation examples.

See [OFFLINE_STRATEGIES.md](references/OFFLINE_STRATEGIES.md) for tile caching and database management.
