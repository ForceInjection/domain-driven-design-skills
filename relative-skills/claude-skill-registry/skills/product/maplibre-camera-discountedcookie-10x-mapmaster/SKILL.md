---
name: maplibre-camera
description: >-
  Use when implementing map camera animations (flyTo, easeTo, jumpTo), handling
  zoom transitions, or managing bearing/pitch. Load for useMapCamera composable
  patterns, preventing camera feedback loops, promise-based animations, and
  globe visibility filtering. ALWAYS use the composable, never direct map access.
---

# MapLibre Camera

Camera control patterns using the useMapCamera composable.

> **Announce:** "I'm using maplibre-camera to implement camera control correctly."

## The Iron Rule

**NEVER access `map.flyTo()` directly. ALWAYS use `useMapCamera`.**

```typescript
// WRONG: Direct map access
const map = inject(MAP_KEY)
map.flyTo({ center: [lng, lat], zoom: 10 })

// CORRECT: Use the composable
const { flyTo } = useMapCamera()
await flyTo({ center: [lng, lat], zoom: 10 })
```

## useMapCamera Composable

Location: `src/composables/map/useMapCamera.ts`

### What It Provides

```typescript
const {
  // State
  center,        // Ref<{lng, lat}> - current center
  zoom,          // Ref<number> - current zoom
  pitch,         // Ref<number> - current pitch (0-85)
  bearing,       // Ref<number> - current bearing (0-360)
  isAnimating,   // Ref<boolean> - animation in progress
  isLoaded,      // Computed<boolean> - map ready
  
  // Methods (all return Promise<void>)
  flyTo,         // Smooth arc animation
  easeTo,        // Linear interpolation
  jumpTo,        // Instant move
  fitBounds,     // Fit to bounding box
  
  // Lifecycle
  cleanup        // Remove event listeners
} = useMapCamera(options)
```

### Options

```typescript
interface UseMapCameraOptions {
  initialCenter?: [number, number]  // Default: [0, 20]
  initialZoom?: number              // Default: 2
  initialPitch?: number             // Default: 0
  initialBearing?: number           // Default: 0
  syncFromMap?: boolean             // Default: true - sync state from map events
}
```

## Animation Methods

### flyTo - Dramatic Arc Animation

```typescript
await flyTo({
  center: [2.3522, 48.8566],  // Paris
  zoom: 12,
  pitch: 45,
  bearing: 30,
  duration: 3000  // 3 seconds
})
// Promise resolves when animation completes
```

**Use for:** Dramatic camera moves, showing user a new location

### easeTo - Linear Interpolation

```typescript
await easeTo({
  center: [2.3522, 48.8566],
  zoom: 12,
  duration: 1000
})
```

**Use for:** Quick, responsive moves (faster than flyTo)

### jumpTo - Instant Move

```typescript
jumpTo({
  center: [2.3522, 48.8566],
  zoom: 12
})
// No promise - instant
```

**Use for:** Initial positioning, resetting view

### fitBounds - Fit to Bounding Box

```typescript
await fitBounds(
  [[minLng, minLat], [maxLng, maxLat]],
  { padding: 50, maxZoom: 15 }
)
```

**Use for:** Showing all candidates, fitting to region

## Feedback Loop Prevention

The composable prevents infinite loops between state and map:

```typescript
// Inside useMapCamera
let isProgrammaticMove = false

function flyTo(options) {
  isProgrammaticMove = true  // Flag: we initiated this
  map.flyTo(options)
  map.once('moveend', () => {
    isProgrammaticMove = false
  })
}

// Map event listener
map.on('move', () => {
  if (!isProgrammaticMove) {
    // Only sync state if user moved the map
    center.value = map.getCenter()
  }
})
```

**This prevents:** Component → updates state → triggers watcher → calls map method → triggers event → updates state → ...

## Globe Visibility Filtering

For globe projection, filter markers to visible hemisphere:

```typescript
// src/composables/map/useGlobeVisibility.ts
export function isVisibleOnGlobe(
  pointLng: number,
  pointLat: number,
  centerLng: number,
  centerLat: number
): boolean {
  const toRad = (d: number) => d * Math.PI / 180
  const lat1 = toRad(pointLat)
  const lat2 = toRad(centerLat)
  const dLng = toRad(pointLng - centerLng)
  
  // Cosine of angle between points on sphere
  const cosAngle = 
    Math.sin(lat1) * Math.sin(lat2) + 
    Math.cos(lat1) * Math.cos(lat2) * Math.cos(dLng)
  
  // Visible if on front hemisphere (with small buffer)
  return cosAngle > -0.1
}
```

Use with computed to filter candidates:

```typescript
const visibleCandidates = computed(() => 
  candidates.value.filter(c => 
    isVisibleOnGlobe(c.lng, c.lat, center.value.lng, center.value.lat)
  )
)
```

## Cinematic Intro Animation

For custom animations beyond built-in methods:

```typescript
// src/composables/map/useCinematicIntro.ts
export function useCinematicIntro() {
  async function animate(
    map: MapLibreMap,
    target: { lng: number, lat: number },
    options: { duration?: number, signal?: AbortSignal }
  ): Promise<void> {
    return new Promise((resolve) => {
      const startTime = performance.now()
      let rafId: number
      
      function frame(currentTime: number) {
        if (options.signal?.aborted) {
          cancelAnimationFrame(rafId)
          resolve()
          return
        }
        
        const progress = (currentTime - startTime) / (options.duration || 3000)
        const eased = easeOutCubic(Math.min(progress, 1))
        
        // Interpolate camera
        map.jumpTo({
          center: lerp(startCenter, target, eased),
          zoom: lerp(startZoom, targetZoom, eased)
        })
        
        if (progress < 1) {
          rafId = requestAnimationFrame(frame)
        } else {
          resolve()
        }
      }
      
      rafId = requestAnimationFrame(frame)
    })
  }
  
  return { animate }
}
```

## Anti-Patterns

### DON'T: Access Map Directly

```typescript
// WRONG
const map = inject(MAP_KEY)
map.flyTo({ center })

// CORRECT
const { flyTo } = useMapCamera()
await flyTo({ center })
```

### DON'T: Forget to Await Animations

```typescript
// WRONG: May cause race conditions
flyTo({ center: a })
flyTo({ center: b })  // Interrupts first animation!

// CORRECT: Await each animation
await flyTo({ center: a })
await flyTo({ center: b })
```

### DON'T: Check Map Before isLoaded

```typescript
// WRONG: Map may not be ready
onMounted(() => {
  flyTo({ center })  // May fail!
})

// CORRECT: Wait for map
watch(isLoaded, (loaded) => {
  if (loaded) flyTo({ center })
})
```

## References

See `references/camera-examples.md` for more animation patterns.
