---
name: implementing-spatial-xr
description: Implementing WebXR, VR, and AR features for StickerNest's spatial platform. Use when the user asks about VR mode, AR mode, WebXR integration, immersive sessions, XR controllers, hand tracking, hit testing, plane detection, mesh detection, room mapping, spatial anchors, teleportation, XR accessibility, or spatial rendering. Covers @react-three/xr, useSpatialModeStore, XR adapters, room scanning, and intent-based input.
---

# Implementing Spatial XR for StickerNest

This skill guides you through implementing VR and AR features following StickerNest's spatial platform architecture where **VR and AR are rendering modes, not separate applications**.

## Core Design Principles (DO NOT VIOLATE)

1. **One System, Multiple Modes**: Desktop, VR, and AR share the same widget system, canvas system, scene graph, and interaction model
2. **Mode-Specific Logic in Adapters**: Rendering differences live in adapters, not forked code
3. **Intent-Based Interaction**: All input normalized to semantic intents (select, grab, move, etc.)
4. **Accessibility First**: All features must support reduced motion, keyboard navigation, and flexible input

---

## Technology Stack

### Required Dependencies
```bash
npm install three @react-three/fiber @react-three/xr@latest @react-three/drei
```

### Key Libraries
- **@react-three/xr** (v6+): React bindings for WebXR
- **@react-three/fiber**: React renderer for Three.js
- **@react-three/drei**: Useful helpers and components

---

## StickerNest Spatial Mode Integration

### State Management: useSpatialModeStore

The spatial mode store at `src/state/useSpatialModeStore.ts` manages rendering modes:

```typescript
import { useSpatialModeStore, useActiveSpatialMode, useIsVRMode } from '../state/useSpatialModeStore';

// Access mode state
const spatialMode = useActiveSpatialMode(); // 'desktop' | 'vr' | 'ar'
const isVRMode = useIsVRMode();

// Toggle modes
const toggleVR = useSpatialModeStore((s) => s.toggleVR);
const toggleAR = useSpatialModeStore((s) => s.toggleAR);

// Check capabilities
const capabilities = useSpatialModeStore((s) => s.capabilities);
// { vrSupported: boolean, arSupported: boolean, webXRAvailable: boolean }

// Session state
const sessionState = useSpatialModeStore((s) => s.sessionState);
// 'none' | 'requesting' | 'active' | 'ending' | 'error'

// Accessibility preferences
const reducedMotion = useSpatialModeStore((s) => s.reducedMotion);
```

---

## Setting Up XR with React Three Fiber

### Basic XR Scene Setup

```tsx
import { Canvas } from '@react-three/fiber';
import { XR, createXRStore } from '@react-three/xr';
import { useSpatialModeStore } from '../state/useSpatialModeStore';

// Create store outside component
const xrStore = createXRStore({
  // Input configuration
  controller: { teleportPointer: true },
  hand: { teleportPointer: true },

  // Session features
  frameRate: 'high',
  foveation: 1,
  handTracking: true,

  // AR features (when needed)
  hitTest: true,
  planeDetection: true,
  anchors: true,
});

function SpatialCanvas() {
  const setActiveMode = useSpatialModeStore((s) => s.setActiveMode);
  const setSessionState = useSpatialModeStore((s) => s.setSessionState);

  return (
    <>
      {/* Entry buttons - place in your UI */}
      <button onClick={() => xrStore.enterVR()}>Enter VR</button>
      <button onClick={() => xrStore.enterAR()}>Enter AR</button>

      <Canvas>
        <XR
          store={xrStore}
          onSessionStart={() => {
            setSessionState('active');
            // Detect mode from session
            const mode = xrStore.getState().session?.mode;
            setActiveMode(mode?.includes('ar') ? 'ar' : 'vr');
          }}
          onSessionEnd={() => {
            setSessionState('none');
            setActiveMode('desktop');
          }}
        >
          {/* Your 3D content here */}
          <ambientLight intensity={0.5} />
          <SpatialScene />
        </XR>
      </Canvas>
    </>
  );
}
```

---

## WebXR Session Types

### immersive-vr
Full VR with environment replacement:
```typescript
xrStore.enterVR(); // Requests immersive-vr session
```

### immersive-ar
AR with real-world passthrough:
```typescript
xrStore.enterAR(); // Requests immersive-ar session
```

### inline
Non-immersive, renders in page (useful for previews):
```typescript
// Inline sessions don't require XR hardware
// Content renders directly in the canvas
```

---

## Reference Spaces

Reference spaces define the coordinate system origin:

| Type | Use Case | Y=0 Position |
|------|----------|--------------|
| `viewer` | Head-locked UI, no movement | At eyes |
| `local` | Seated experiences | Near eyes at start |
| `local-floor` | Standing, limited movement | At floor level |
| `bounded-floor` | Room-scale with boundaries | At floor, bounded |
| `unbounded` | Large area, free movement | At floor |

### Configuring Reference Space
```typescript
const xrStore = createXRStore({
  // Default is 'local-floor'
  referenceSpace: 'local-floor',
});
```

---

## XR Origin and Teleportation

### XROrigin Component
The XROrigin represents the user's feet position:

```tsx
import { XROrigin, TeleportTarget } from '@react-three/xr';
import { useState } from 'react';

function TeleportableScene() {
  const [position, setPosition] = useState([0, 0, 0]);

  return (
    <>
      <XROrigin position={position} />

      {/* Floor that user can teleport to */}
      <TeleportTarget onTeleport={(point) => setPosition([point.x, 0, point.z])}>
        <mesh rotation-x={-Math.PI / 2} position={[0, 0, 0]}>
          <planeGeometry args={[10, 10]} />
          <meshStandardMaterial color="#444" />
        </mesh>
      </TeleportTarget>
    </>
  );
}
```

---

## Input Handling: Intent-Based System

Following StickerNest's architecture, normalize all input to semantic intents:

### Core Intents
```typescript
type InteractionIntent =
  | 'select'    // Primary action (click, trigger, pinch)
  | 'focus'     // Hover/gaze target
  | 'grab'      // Start dragging
  | 'move'      // While dragging
  | 'resize'    // Scale gesture
  | 'rotate'    // Rotation gesture
  | 'release';  // End interaction
```

### Using Pointer Events (Unified Input)
```tsx
function InteractiveWidget({ onIntent }) {
  return (
    <mesh
      // These work across mouse, touch, controller, and hand
      onClick={() => onIntent('select')}
      onPointerDown={() => onIntent('grab')}
      onPointerUp={() => onIntent('release')}
      onPointerMove={(e) => onIntent('move', e.point)}
      onPointerEnter={() => onIntent('focus')}
      onPointerLeave={() => onIntent('focus', null)}
    >
      <boxGeometry args={[1, 1, 1]} />
      <meshStandardMaterial color="purple" />
    </mesh>
  );
}
```

### Controller-Specific Events
```tsx
import { useXREvent } from '@react-three/xr';

function ControllerHandler() {
  // Handle squeeze (grip button)
  useXREvent('squeeze', (event) => {
    console.log('Grip pressed on', event.inputSource.handedness);
  });

  // Handle select (trigger)
  useXREvent('select', (event) => {
    console.log('Trigger pressed');
  });

  return null;
}
```

---

## Hand Tracking

Enable and use hand tracking:

```typescript
// In store configuration
const xrStore = createXRStore({
  handTracking: true,
  hand: {
    teleportPointer: true,
    // Hand model options
  },
});
```

### Detecting Hand Tracking State
```tsx
import { useXR } from '@react-three/xr';

function HandAwareComponent() {
  const isHandTracking = useXR((state) => state.isHandTracking);

  if (isHandTracking) {
    // User is using hands, not controllers
  }

  return null;
}
```

---

## AR Features

### Hit Testing (Ray Against Real World)
```tsx
import { useHitTest } from '@react-three/xr';

function ARPlacementIndicator() {
  const ref = useRef();

  useHitTest((hitMatrix) => {
    // hitMatrix is a Matrix4 of the intersection point
    if (ref.current) {
      hitMatrix.decompose(
        ref.current.position,
        ref.current.quaternion,
        ref.current.scale
      );
    }
  });

  return (
    <mesh ref={ref}>
      <ringGeometry args={[0.1, 0.15, 32]} />
      <meshBasicMaterial color="white" />
    </mesh>
  );
}
```

### Plane Detection
```typescript
const xrStore = createXRStore({
  planeDetection: true,
});
```

### Anchors (Persistent Positions)
```typescript
const xrStore = createXRStore({
  anchors: true,
});
```

---

## Room Mapping & Spatial Understanding

StickerNest supports room mapping through WebXR's plane detection and mesh detection APIs. These work across devices that support them (Meta Quest 2/3/Pro, Vision Pro, etc.) while gracefully degrading on unsupported hardware.

### Enabling Room Mapping Features

```typescript
const xrStore = createXRStore({
  // Basic AR features
  hitTest: true,

  // Room mapping features
  planeDetection: true,  // Detect walls, floors, tables
  meshDetection: true,   // Full room mesh (Quest 3+)
  anchors: true,         // Persistent positions

  // Request optional features for compatibility
  optionalFeatures: [
    'plane-detection',
    'mesh-detection',
    'anchors',
    'depth-sensing',
  ],
});
```

### Plane Detection with useXRPlanes

Planes represent detected surfaces (walls, floors, tables, etc.):

```tsx
import { useXRPlanes, XRPlaneModel, XRSpace } from '@react-three/xr';

// Plane types: 'wall' | 'floor' | 'ceiling' | 'table' | 'couch' | 'door' | 'window' | 'other'

function DetectedPlanes() {
  // Get all detected planes
  const allPlanes = useXRPlanes();

  // Or filter by type
  const walls = useXRPlanes('wall');
  const floors = useXRPlanes('floor');
  const tables = useXRPlanes('table');

  return (
    <>
      {/* Render wall planes with semi-transparent material */}
      {walls.map((plane) => (
        <XRSpace key={plane.planeSpace.toString()} space={plane.planeSpace}>
          <XRPlaneModel plane={plane}>
            <meshBasicMaterial
              color="#8b5cf6"
              transparent
              opacity={0.3}
              side={2} // DoubleSide
            />
          </XRPlaneModel>
        </XRSpace>
      ))}

      {/* Render floor planes */}
      {floors.map((plane) => (
        <XRSpace key={plane.planeSpace.toString()} space={plane.planeSpace}>
          <XRPlaneModel plane={plane}>
            <meshBasicMaterial
              color="#22c55e"
              transparent
              opacity={0.2}
            />
          </XRPlaneModel>
        </XRSpace>
      ))}
    </>
  );
}
```

### Mesh Detection with useXRMeshes

Full room meshes provide detailed 3D geometry of the environment (requires Quest 3/3S or similar):

```tsx
import { useXRMeshes, XRMeshModel, XRSpace } from '@react-three/xr';

function RoomMesh() {
  const meshes = useXRMeshes();

  return (
    <>
      {meshes.map((mesh) => (
        <XRSpace key={mesh.meshSpace.toString()} space={mesh.meshSpace}>
          <XRMeshModel mesh={mesh}>
            {/* Wireframe to visualize room structure */}
            <meshBasicMaterial
              color="#ffffff"
              wireframe
              transparent
              opacity={0.1}
            />
          </XRMeshModel>
        </XRSpace>
      ))}
    </>
  );
}
```

### Using Plane Geometry for Custom Rendering

```tsx
import { useXRPlaneGeometry } from '@react-three/xr';

function CustomPlaneRenderer({ plane }) {
  // Get the plane's geometry directly
  const geometry = useXRPlaneGeometry(plane);

  if (!geometry) return null;

  return (
    <mesh geometry={geometry}>
      <meshStandardMaterial
        color="#8b5cf6"
        transparent
        opacity={0.5}
      />
    </mesh>
  );
}
```

### Persistent Anchors (Save Positions Across Sessions)

Anchors let you save world positions that persist when users return:

```tsx
import { useXRAnchor, requestXRAnchor, useXR } from '@react-three/xr';

function PersistentWidget({ savedAnchorId, position }) {
  const { session } = useXR();
  const [anchorId, setAnchorId] = useState(savedAnchorId);

  // Restore anchor from saved ID
  const anchor = useXRAnchor(anchorId);

  // Create new anchor at position
  const createAnchor = async () => {
    if (!session) return;

    const newAnchor = await requestXRAnchor(session, {
      space: 'local-floor',
      position: position,
    });

    if (newAnchor) {
      // Request persistent handle (Meta Quest specific)
      const handle = await newAnchor.requestPersistentHandle?.();
      if (handle) {
        // Save this handle to restore later
        localStorage.setItem('widgetAnchor', handle);
        setAnchorId(handle);
      }
    }
  };

  // Render at anchor position
  if (anchor) {
    return (
      <XRSpace space={anchor.anchorSpace}>
        <mesh>
          <boxGeometry args={[0.2, 0.2, 0.2]} />
          <meshStandardMaterial color="#8b5cf6" />
        </mesh>
      </XRSpace>
    );
  }

  return null;
}
```

### Meta Quest Room Setup Integration

On Meta Quest, users must set up their room boundaries for plane detection to work. Guide users through this:

```tsx
function RoomSetupGuide() {
  const planes = useXRPlanes();
  const hasRoomSetup = planes.length > 0;

  if (!hasRoomSetup) {
    return (
      <group position={[0, 1.5, -1]}>
        <Text fontSize={0.08} color="white" anchorX="center">
          Room setup required for full experience
        </Text>
        <Text fontSize={0.06} color="#9ca3af" position={[0, -0.15, 0]} anchorX="center">
          Go to Settings → Guardian → Room Setup
        </Text>
      </group>
    );
  }

  return null;
}
```

### Device Capability Detection

Check what features are available before using them:

```tsx
function useRoomMappingCapabilities() {
  const [capabilities, setCapabilities] = useState({
    planeDetection: false,
    meshDetection: false,
    anchors: false,
    depthSensing: false,
  });

  useEffect(() => {
    async function check() {
      if (!navigator.xr) return;

      // Check AR support with features
      const supported = await navigator.xr.isSessionSupported('immersive-ar');
      if (!supported) return;

      // These are optional features - check if device reports them
      // Note: Full feature detection often requires starting a session
      setCapabilities({
        planeDetection: true,  // Most AR devices
        meshDetection: true,   // Quest 3/3S, Vision Pro
        anchors: true,         // Most AR devices
        depthSensing: true,    // Quest 3/3S with Depth API
      });
    }

    check();
  }, []);

  return capabilities;
}
```

### Occlusion with Room Mesh

Make virtual objects appear behind real-world surfaces:

```tsx
function OcclusionMesh() {
  const meshes = useXRMeshes();

  return (
    <>
      {meshes.map((mesh) => (
        <XRSpace key={mesh.meshSpace.toString()} space={mesh.meshSpace}>
          <XRMeshModel mesh={mesh}>
            {/* Occlusion material - writes to depth but not color */}
            <meshBasicMaterial
              colorWrite={false}
              depthWrite={true}
            />
          </XRMeshModel>
        </XRSpace>
      ))}
    </>
  );
}

function ARSceneWithOcclusion({ children }) {
  return (
    <group>
      {/* Render occlusion mesh first */}
      <OcclusionMesh />

      {/* Virtual content will be occluded by real surfaces */}
      {children}
    </group>
  );
}
```

### Placing Objects on Detected Surfaces

Combine hit testing with plane detection for accurate placement:

```tsx
function SurfacePlacement({ onPlace }) {
  const tables = useXRPlanes('table');
  const floors = useXRPlanes('floor');
  const [hoveredPlane, setHoveredPlane] = useState(null);

  // Render interactive placement targets on detected surfaces
  return (
    <>
      {[...tables, ...floors].map((plane) => (
        <XRSpace key={plane.planeSpace.toString()} space={plane.planeSpace}>
          <XRPlaneModel
            plane={plane}
            onPointerEnter={() => setHoveredPlane(plane)}
            onPointerLeave={() => setHoveredPlane(null)}
            onClick={(e) => {
              e.stopPropagation();
              onPlace(e.point, plane.orientation);
            }}
          >
            <meshBasicMaterial
              color={hoveredPlane === plane ? '#8b5cf6' : '#ffffff'}
              transparent
              opacity={hoveredPlane === plane ? 0.5 : 0.1}
            />
          </XRPlaneModel>
        </XRSpace>
      ))}
    </>
  );
}
```

---

## Accessibility Requirements

### Motion Sickness Prevention
```tsx
function AccessibleScene() {
  const reducedMotion = useSpatialModeStore((s) => s.reducedMotion);

  return (
    <>
      {/* Reduce peripheral motion for comfort */}
      {reducedMotion && <VignetteEffect />}

      {/* Use teleportation instead of smooth locomotion */}
      <TeleportTarget />

      {/* Maintain stable frame rate */}
      <AdaptivePerformance />
    </>
  );
}
```

### Size and Reach Flexibility
```tsx
function AccessibleWidget({ children }) {
  // Allow scaling beyond "realistic" sizes
  const [scale, setScale] = useState(1);

  return (
    <group scale={scale}>
      {children}
      {/* UI to adjust scale for accessibility */}
    </group>
  );
}
```

### Focus Mode (Bring Content Closer)
```tsx
function FocusMode({ target, enabled }) {
  const { camera } = useThree();

  useEffect(() => {
    if (enabled && target) {
      // Bring content to comfortable viewing distance
      // without requiring user movement
    }
  }, [enabled, target]);

  return null;
}
```

### No Required Locomotion
- All interactions reachable without movement
- Teleportation as optional enhancement
- World can come to user, not just user to world

---

## Rendering Mode Adapter Pattern

Create adapters that consume the same SpatialScene but render differently:

```tsx
// src/adapters/DesktopRenderAdapter.tsx
function DesktopRenderAdapter({ scene }) {
  return (
    <Canvas>
      <PerspectiveCamera />
      <DesktopControls />
      <SpatialSceneRenderer scene={scene} />
    </Canvas>
  );
}

// src/adapters/VRRenderAdapter.tsx
function VRRenderAdapter({ scene }) {
  return (
    <Canvas>
      <XR store={xrStore}>
        <XROrigin />
        <VREnvironment />
        <SpatialSceneRenderer scene={scene} />
      </XR>
    </Canvas>
  );
}

// src/adapters/ARRenderAdapter.tsx
function ARRenderAdapter({ scene }) {
  return (
    <Canvas>
      <XR store={xrStore}>
        <XROrigin />
        {/* No environment - real world is visible */}
        <SpatialSceneRenderer scene={scene} />
        <ARHitTestIndicator />
      </XR>
    </Canvas>
  );
}
```

---

## Environment Provider (VR-Only)

```tsx
import { Environment } from '@react-three/drei';

function VREnvironment() {
  const spatialMode = useActiveSpatialMode();

  // Only show environment in VR, not AR
  if (spatialMode !== 'vr') return null;

  return (
    <Environment
      preset="sunset" // or load 360° panorama
      background
    />
  );
}
```

---

## Detecting XR Capabilities

```tsx
function XRCapabilityCheck() {
  const setCapabilities = useSpatialModeStore((s) => s.setCapabilities);

  useEffect(() => {
    async function checkXR() {
      if (!navigator.xr) {
        setCapabilities({ webXRAvailable: false });
        return;
      }

      const [vrSupported, arSupported] = await Promise.all([
        navigator.xr.isSessionSupported('immersive-vr'),
        navigator.xr.isSessionSupported('immersive-ar'),
      ]);

      setCapabilities({ vrSupported, arSupported, webXRAvailable: true });
    }

    checkXR();
  }, []);

  return null;
}
```

---

## Testing Without Hardware

Use the WebXR Emulator browser extension:
- Chrome: "WebXR API Emulator"
- Firefox: "WebXR API Emulator"

The extension allows simulating headset position, controllers, and hand tracking.

---

## Common Patterns

### Pattern: Mode-Agnostic Widget
```tsx
// Widgets don't know their rendering mode
function StickerWidget({ position, content, onIntent }) {
  return (
    <group position={position}>
      <mesh
        onClick={() => onIntent('select')}
        onPointerDown={() => onIntent('grab')}
        onPointerUp={() => onIntent('release')}
      >
        <planeGeometry args={[1, 1]} />
        <meshBasicMaterial>
          {/* Widget content */}
        </meshBasicMaterial>
      </mesh>
    </group>
  );
}
```

### Pattern: Spatial Transform
```typescript
// All canvas objects use spatial transforms
interface SpatialTransform {
  position: { x: number; y: number; z: number };
  rotation: { x: number; y: number; z: number };
  scale: { x: number; y: number; z: number };
}

// 2D canvases are just z=0 spatial objects
const flatCanvas: SpatialTransform = {
  position: { x: 0, y: 1.5, z: -2 },
  rotation: { x: 0, y: 0, z: 0 },
  scale: { x: 1, y: 1, z: 1 },
};
```

---

## Reference Files

- **Spatial Mode Store**: `src/state/useSpatialModeStore.ts`
- **Creative Toolbar (VR Toggle)**: `src/components/CreativeToolbar.tsx`
- **Entity Types**: `src/types/entities.ts`
- **Tool Store**: `src/state/useToolStore.ts`

---

## Troubleshooting

### Issue: XR session fails to start
**Cause**: Missing HTTPS or unsupported browser
**Fix**:
- Use HTTPS (required for WebXR)
- Check `navigator.xr.isSessionSupported()` first
- Verify browser compatibility (Chrome, Edge, Firefox, Oculus Browser)

### Issue: Controllers not appearing
**Cause**: Controller configuration disabled
**Fix**: Ensure `controller: true` in createXRStore config

### Issue: Hand tracking not working
**Cause**: Device doesn't support or feature not enabled
**Fix**:
- Check device supports hand tracking (Quest, Vision Pro)
- Enable `handTracking: true` in config
- Request `hand-tracking` feature

### Issue: AR passthrough is black
**Cause**: Using immersive-vr instead of immersive-ar
**Fix**: Use `xrStore.enterAR()` for passthrough experiences

---

## Device Compatibility Reference

| Feature | Quest 2 | Quest 3/3S | Quest Pro | Vision Pro | Android AR |
|---------|---------|------------|-----------|------------|------------|
| Passthrough | ✅ (B&W) | ✅ (Color) | ✅ (Color) | ✅ | ✅ |
| Plane Detection | ✅ | ✅ | ✅ | ✅ | ✅ |
| Mesh Detection | ❌ | ✅ | ❌ | ✅ | ❌ |
| Depth API | ❌ | ✅ | ❌ | ✅ | Varies |
| Hand Tracking | ✅ | ✅ | ✅ | ✅ | ❌ |
| Persistent Anchors | ✅ | ✅ | ✅ | ✅ | ❌ |
| Controller Input | ✅ | ✅ | ✅ | ❌ | ❌ |

---

## Troubleshooting Room Mapping

### Issue: No planes detected
**Cause**: User hasn't completed room setup on Meta Quest
**Fix**:
- Guide user to Settings → Guardian → Room Setup
- Check that `planeDetection: true` is in createXRStore config
- Verify session is `immersive-ar` mode

### Issue: Mesh detection returns empty array
**Cause**: Device doesn't support mesh detection or feature not enabled
**Fix**:
- Mesh detection requires Quest 3/3S or Vision Pro
- Ensure `meshDetection: true` in config
- Fall back to plane detection on unsupported devices

### Issue: Anchors don't persist across sessions
**Cause**: Using regular anchors instead of persistent anchors
**Fix**:
- Call `anchor.requestPersistentHandle()` after creating anchor
- Save the returned handle string to localStorage
- Use `session.restorePersistentAnchor(handle)` to restore

### Issue: Virtual objects float through real surfaces
**Cause**: Occlusion not implemented
**Fix**:
- Add OcclusionMesh component that renders room mesh with `colorWrite: false`
- Ensure occlusion mesh renders before virtual content
- Use correct depth testing settings

---

## Spatial Sticker System

StickerNest extends the 2D sticker/widget system into 3D VR/AR space. Spatial stickers work in both 2D canvas mode and 3D immersive modes.

### Core Types (src/types/spatialEntity.ts)

```typescript
import { SpatialSticker, createSpatialSticker, createQRAnchoredSticker } from '../types/spatialEntity';

// SpatialSticker properties
interface SpatialSticker {
  // 2D Properties (canvas mode)
  position2D: { x: number; y: number };
  size2D: { width: number; height: number };
  rotation2D: number;

  // 3D Properties (VR/AR mode)
  transform3D: SpatialTransform;
  anchor: SpatialAnchor;  // QR code, surface, persistent
  billboard3D: boolean;

  // Media (works in both modes)
  mediaType: SpatialMediaType;  // 'image' | '3d-model' | '3d-primitive' | etc.
  model3DConfig?: Model3DConfig;
  primitive3DConfig?: Primitive3DConfig;

  // Interaction (same in both modes)
  clickBehavior: 'launch-widget' | 'toggle-widget' | 'open-url' | 'emit-event' | 'run-pipeline' | 'none';
  linkedWidgetDefId?: string;
}
```

### Anchor Types

Spatial stickers can be anchored to real-world objects or locations:

```typescript
// QR Code Anchor - attach to physical QR codes
const qrSticker = createQRAnchoredSticker('canvas-1', 'Calendar', 'https://myqr.com/calendar');

// Surface Anchor - attach to detected room surfaces
const wallSticker = createSurfaceAnchoredSticker('canvas-1', 'Poster', 'wall');
const tableSticker = createSurfaceAnchoredSticker('canvas-1', 'Display', 'table');

// Persistent Anchor - save position across sessions
const sticker = createSpatialSticker({
  canvasId: 'canvas-1',
  name: 'Widget Launcher',
  anchor: {
    type: 'persistent',
    anchorHandle: savedHandle,
    createdAt: Date.now(),
  },
});
```

### Rendering Spatial Stickers

```tsx
import { SpatialStickerManager } from './components/spatial/stickers';
import { useSpatialStickerStore } from './state/useSpatialStickerStore';

function SpatialScene() {
  const stickers = useSpatialStickerStore((s) => s.getSpatialStickers());
  const detectedQRCodes = useSpatialStickerStore((s) => s.detectedQRCodes);

  return (
    <SpatialStickerManager
      stickers={stickers}
      detectedQRCodes={detectedQRCodesMap}
      onLaunchWidget={(widgetDefId, sticker) => {
        // Launch the linked widget
      }}
      onStickerClick={(sticker) => {
        // Handle sticker selection
      }}
    />
  );
}
```

### QR Code Detection

```tsx
import { useQRCodeDetection } from './components/spatial/qr';

function ARScene() {
  const { detectedCodes, simulateDetection } = useQRCodeDetection({
    enabled: true,
    debug: true,
  });

  // For testing without actual QR codes
  useEffect(() => {
    simulateDetection('https://example.com/calendar', [1, 1.5, -1]);
  }, []);

  return <SpatialScene />;
}
```

### Surface Placement

```tsx
import { SurfacePlacement, useSpatialAnchors } from './components/spatial/anchors';

function PlacementMode() {
  const { snapToSurface } = useSpatialAnchors({ enabled: true });

  const handlePlacement = (surfaceType, position, normal) => {
    // Create sticker at this position
    useSpatialStickerStore.getState().createSurfaceSticker(
      canvasId,
      'New Sticker',
      surfaceType
    );
  };

  return (
    <SurfacePlacement
      active={isPlacing}
      surfaceTypes={['floor', 'wall', 'table']}
      onPlacement={handlePlacement}
    />
  );
}
```

### State Management (useSpatialStickerStore)

```typescript
import { useSpatialStickerStore } from './state/useSpatialStickerStore';

// CRUD operations
const addSticker = useSpatialStickerStore((s) => s.addSpatialSticker);
const updateSticker = useSpatialStickerStore((s) => s.updateSpatialSticker);
const stickers = useSpatialStickerStore((s) => s.getSpatialStickersByCanvas('canvas-1'));

// Factory functions
const store = useSpatialStickerStore.getState();
store.createImageSticker('canvas-1', 'Photo', '/images/photo.png');
store.createModelSticker('canvas-1', 'Trophy', '/models/trophy.glb');
store.createPrimitiveSticker('canvas-1', 'Marker', 'sphere');
store.createQRLinkedSticker('canvas-1', 'Calendar Link', 'https://qr.example.com/cal');

// QR code registration
store.registerQRCode({
  id: 'qr-1',
  userId: 'user-1',
  content: 'https://qr.example.com/calendar',
  label: 'Calendar QR',
  sizeMeters: 0.1,
  attachedStickerIds: [],
  createdAt: Date.now(),
});
```

### Reference Files

- **Spatial Sticker Type**: `src/types/spatialEntity.ts`
- **3D Sticker Renderer**: `src/components/spatial/stickers/SpatialSticker3D.tsx`
- **Anchor System**: `src/components/spatial/stickers/AnchoredSticker.tsx`
- **Sticker Manager**: `src/components/spatial/stickers/SpatialStickerManager.tsx`
- **State Store**: `src/state/useSpatialStickerStore.ts`
- **QR Detection**: `src/components/spatial/qr/useQRCodeDetection.ts`
- **Surface Placement**: `src/components/spatial/anchors/SurfacePlacement.tsx`

---

## Explicit Non-Goals (v1)

Per StickerNest architecture, do NOT implement:
- Object recognition (identifying specific objects like "chair" vs "table")
- Physics simulation (objects bouncing off real surfaces)
- Multiplayer synchronization (shared AR spaces)
- Native-only features (always prefer WebXR standard APIs)

These are future possibilities, not foundations.
