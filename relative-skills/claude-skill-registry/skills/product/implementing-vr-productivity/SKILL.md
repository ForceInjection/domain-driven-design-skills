---
name: implementing-vr-productivity
description: Implementing VR productivity features with cross-platform input handling. Use when the user asks about VR productivity apps, cross-platform XR input, gaze-and-pinch, controller abstraction, floating panels, curved UI, spatial workspaces, Meta Quest patterns, Vision Pro compatibility, or WebXR performance optimization. Covers unified input handling, spatial UI patterns, and productivity-focused 3D interfaces.
---

# Implementing VR Productivity for StickerNest

This skill guides you through implementing productivity-focused VR features following proven patterns from leading VR productivity apps (Immersed, Virtual Desktop, Horizon Workrooms) while ensuring cross-platform compatibility.

## Research Sources (December 2025)

This skill is based on current research from:
- [Meta Quest Productivity Apps](https://www.meta.com/quest/productivity/)
- [WebXR Hand Input Specification](https://www.w3.org/TR/webxr-hand-input-1/)
- [WebXR Input Sources](https://developer.mozilla.org/en-US/docs/Web/API/WebXR_Device_API/Inputs)
- [Meta WebXR Documentation](https://developers.meta.com/horizon/documentation/web/webxr-hands/)
- [Spatial UI Design Best Practices](https://www.interaction-design.org/literature/article/spatial-ui-design-tips-and-best-practices)
- [visionOS WebXR Support](https://www.roadtovr.com/visionos-2-webxr-support-vision-pro/)

---

## Core Principles for VR Productivity

### 1. Comfort-First Design
Place UI at comfortable distances (0.5-1.5 meters) and below eye level. Users will spend extended time in productivity apps—discomfort kills adoption.

### 2. Cross-Platform Input Abstraction
Never assume controllers OR hands—support both plus gaze+pinch (Vision Pro). Use semantic intents, not device-specific events.

### 3. 2D Content in 3D Spaces
Documents, videos, and most productivity content remain 2D. Display them on floating panels, not forced 3D transformations.

### 4. Minimize Locomotion
All essential interactions should be reachable without movement. Bring content to the user, not the reverse.

---

## Device Compatibility Matrix (2025/2026)

| Feature | Quest 2 | Quest 3/3S | Quest Pro | Vision Pro | Android AR | iOS AR |
|---------|---------|------------|-----------|------------|------------|--------|
| **Input: Controllers** | Yes | Yes | Yes | No | No | No |
| **Input: Hand Tracking** | Yes | Yes | Yes | Yes | No | Limited |
| **Input: Gaze+Pinch** | No | No | No | Yes | No | No |
| **Input: Touch Screen** | No | No | No | No | Yes | Yes |
| **Passthrough Quality** | B&W | Color HD | Color | Seamless | Native | Native |
| **Plane Detection** | Yes | Yes | Yes | Yes | Yes | Yes |
| **Mesh Detection** | No | Yes | No | Yes | No | No |
| **Persistent Anchors** | Yes | Yes | Yes | Yes | No | No |
| **WebXR immersive-ar** | Yes | Yes | Yes | No* | Yes | Yes |

*Vision Pro supports `immersive-vr` only in WebXR as of visionOS 2.

---

## Cross-Platform Input Handling

### The Problem
- Quest uses **controllers** with buttons, triggers, thumbsticks
- Quest also supports **hand tracking** with pinch gestures
- Vision Pro uses **gaze+pinch** (transient-pointer) exclusively
- Mobile AR uses **touch** input
- Each requires different handling code

### The Solution: Unified Input Layer

Create an input abstraction that normalizes all devices to semantic **intents**:

```typescript
// src/xr/input/inputIntents.ts

export type InputIntent =
  | { type: 'select'; point?: Vector3; hand?: 'left' | 'right' }
  | { type: 'grab-start'; point: Vector3; hand?: 'left' | 'right' }
  | { type: 'grab-move'; point: Vector3; delta: Vector3 }
  | { type: 'grab-end' }
  | { type: 'focus'; target: Object3D | null }
  | { type: 'pinch-scale'; scale: number; center: Vector3 }
  | { type: 'teleport'; destination: Vector3 }
  | { type: 'menu-open' }
  | { type: 'menu-close' };

export interface InputState {
  primaryPoint: Vector3 | null;      // Where user is pointing
  primaryDirection: Vector3 | null;  // Direction of pointer ray
  isSelecting: boolean;              // Primary action active
  isGrabbing: boolean;               // Grab/squeeze active
  activeHand: 'left' | 'right' | 'gaze' | null;
}
```

### Implementation: Unified Input Hook

```tsx
// src/xr/input/useUnifiedInput.ts

import { useXR, useXREvent, useXRInputSourceState } from '@react-three/xr';
import { useThree } from '@react-three/fiber';
import { useHandGestures } from '../useHandGestures';

export function useUnifiedInput(
  onIntent: (intent: InputIntent) => void
) {
  const { isHandTracking } = useXR();
  const { gl } = useThree();
  const handGestures = useHandGestures();

  // Track input mode
  const inputMode = useMemo(() => {
    // Vision Pro detection via transient-pointer
    const session = gl.xr.getSession();
    const sources = session?.inputSources || [];
    const hasTransientPointer = Array.from(sources).some(
      (s) => s.targetRayMode === 'transient-pointer'
    );

    if (hasTransientPointer) return 'gaze-pinch';
    if (isHandTracking) return 'hands';
    return 'controllers';
  }, [isHandTracking, gl.xr]);

  // Controller events
  useXREvent('select', (e) => {
    if (inputMode !== 'controllers') return;
    onIntent({
      type: 'select',
      hand: e.inputSource.handedness as 'left' | 'right',
      point: e.intersection?.point,
    });
  });

  useXREvent('squeeze', (e) => {
    if (inputMode !== 'controllers') return;
    onIntent({
      type: 'grab-start',
      hand: e.inputSource.handedness as 'left' | 'right',
      point: e.intersection?.point || new Vector3(),
    });
  });

  useXREvent('squeezeend', () => {
    if (inputMode !== 'controllers') return;
    onIntent({ type: 'grab-end' });
  });

  // Hand tracking events
  useEffect(() => {
    if (inputMode !== 'hands') return;

    // Pinch = select
    if (handGestures.anyPinching) {
      const hand = handGestures.activePinchHand;
      const gesture = hand === 'left' ? handGestures.left : handGestures.right;
      onIntent({
        type: 'select',
        hand,
        point: gesture.pinchPosition,
      });
    }

    // Grab gesture = grab
    if (handGestures.anyGrabbing) {
      const hand = handGestures.activeGrabHand;
      const gesture = hand === 'left' ? handGestures.left : handGestures.right;
      onIntent({
        type: 'grab-start',
        hand,
        point: gesture.palmPosition,
      });
    }
  }, [handGestures, inputMode]);

  // Gaze+pinch (Vision Pro transient-pointer)
  useXREvent('select', (e) => {
    if (e.inputSource.targetRayMode !== 'transient-pointer') return;

    // transient-pointer only reveals position at pinch moment
    onIntent({
      type: 'select',
      hand: 'gaze',
      point: e.intersection?.point,
    });
  });

  return { inputMode };
}
```

### Pattern: Intent-Driven Component

```tsx
function ProductivityPanel({ children, onAction }) {
  const handleIntent = useCallback((intent: InputIntent) => {
    switch (intent.type) {
      case 'select':
        onAction('activate');
        break;
      case 'grab-start':
        onAction('start-move', intent.point);
        break;
      case 'grab-move':
        onAction('move', intent.point);
        break;
      case 'grab-end':
        onAction('end-move');
        break;
    }
  }, [onAction]);

  useUnifiedInput(handleIntent);

  return (
    <group>
      {/* Panel content */}
      {children}
    </group>
  );
}
```

---

## Gesture Recognition Best Practices

### Pinch Gesture (Primary Selection)

Based on WebXR Hand Input specification and Meta's implementation:

```typescript
// Pinch detection with hysteresis to prevent flickering
const PINCH_START_THRESHOLD = 0.02;  // 2cm to start
const PINCH_END_THRESHOLD = 0.04;    // 4cm to end

function detectPinch(
  thumbTip: Vector3,
  indexTip: Vector3,
  wasPinching: boolean
): boolean {
  const distance = thumbTip.distanceTo(indexTip);

  if (wasPinching) {
    // Require larger distance to end (hysteresis)
    return distance < PINCH_END_THRESHOLD;
  } else {
    // Require close distance to start
    return distance < PINCH_START_THRESHOLD;
  }
}
```

### Pinch Position Damping

When pinching, the midpoint between thumb and index moves quickly, causing jitter:

```typescript
// Damp pinch position for stable selection
const PINCH_SMOOTHING = 0.3;

function smoothPinchPosition(
  current: Vector3,
  previous: Vector3 | null
): Vector3 {
  if (!previous) return current;

  return new Vector3().lerpVectors(previous, current, PINCH_SMOOTHING);
}
```

### Grab Gesture (Object Manipulation)

```typescript
// Detect grab: all fingers curled 70%+
const GRAB_CURL_THRESHOLD = 0.7;

function detectGrab(fingerCurls: number[]): boolean {
  // Exclude thumb (index 0), check fingers 1-4
  const fingersCurled = fingerCurls.slice(1).every(
    (curl) => curl >= GRAB_CURL_THRESHOLD
  );
  return fingersCurled;
}
```

### Reserved System Gestures

Palm pinch (pinching with palm facing up) is reserved by Meta Quest for system menu. Never use it for app actions:

```typescript
// Check if gesture is reserved by system
function isSystemGesture(palmDirection: Vector3, isPinching: boolean): boolean {
  // Palm facing up + pinch = system menu on Quest
  const isPalmUp = palmDirection.y > 0.7;
  return isPalmUp && isPinching;
}
```

---

## Spatial UI Patterns for Productivity

### Floating Panels (Primary Content Container)

Based on Immersed and Horizon Workrooms patterns:

```tsx
// src/components/spatial/productivity/FloatingWorkPanel.tsx

interface FloatingWorkPanelProps {
  width?: number;          // meters
  height?: number;         // meters
  curveRadius?: number;    // 0 = flat, positive = curved toward user
  children: React.ReactNode;
}

export function FloatingWorkPanel({
  width = 1.2,
  height = 0.8,
  curveRadius = 2.5,      // Curve to match user's visual arc
  children,
}: FloatingWorkPanelProps) {
  const curveAngle = curveRadius > 0 ? width / curveRadius : 0;

  return (
    <group>
      {/* Panel background */}
      {curveRadius > 0 ? (
        <mesh>
          <cylinderGeometry
            args={[
              curveRadius,
              curveRadius,
              height,
              32,
              1,
              true,
              -curveAngle / 2,
              curveAngle,
            ]}
          />
          <meshStandardMaterial
            color="#1a1a2e"
            transparent
            opacity={0.95}
            side={THREE.BackSide}
          />
        </mesh>
      ) : (
        <mesh>
          <planeGeometry args={[width, height]} />
          <meshStandardMaterial
            color="#1a1a2e"
            transparent
            opacity={0.95}
          />
        </mesh>
      )}

      {/* Content via Html from drei */}
      <Html
        transform
        distanceFactor={1.5}
        position={[0, 0, curveRadius > 0 ? -curveRadius + 0.01 : 0.01]}
        style={{
          width: `${width * 1000}px`,
          height: `${height * 1000}px`,
        }}
      >
        <div className="spatial-panel-content">
          {children}
        </div>
      </Html>
    </group>
  );
}
```

### Optimal Panel Placement

Research-backed positioning for comfort:

```typescript
// Productivity panel placement constants
const PLACEMENT = {
  // Distance from user
  COMFORTABLE_MIN: 0.5,    // meters - never closer
  COMFORTABLE_MAX: 2.0,    // meters - readable limit
  OPTIMAL: 1.0,            // meters - default placement

  // Vertical position (relative to eye height ~1.6m)
  EYE_OFFSET_MIN: -0.3,    // below eye level
  EYE_OFFSET_MAX: 0.1,     // slightly above
  EYE_OFFSET_DEFAULT: -0.1, // slightly below for comfort

  // Horizontal spread for multiple panels
  HORIZONTAL_ANGLE_MAX: 120, // degrees total arc
  PANEL_GAP: 0.05,           // meters between panels
};

function calculatePanelPositions(
  panelCount: number,
  panelWidth: number,
  distance: number = PLACEMENT.OPTIMAL
): Vector3[] {
  const positions: Vector3[] = [];
  const totalWidth = panelCount * panelWidth + (panelCount - 1) * PLACEMENT.PANEL_GAP;
  const startX = -totalWidth / 2 + panelWidth / 2;

  for (let i = 0; i < panelCount; i++) {
    const x = startX + i * (panelWidth + PLACEMENT.PANEL_GAP);
    // Arc panels around user
    const angle = Math.atan2(x, distance);
    positions.push(new Vector3(
      Math.sin(angle) * distance,
      1.6 + PLACEMENT.EYE_OFFSET_DEFAULT,
      -Math.cos(angle) * distance
    ));
  }

  return positions;
}
```

### Orbiter UI (Quick Actions)

Floating action buttons that orbit around main content:

```tsx
function OrbiterActions({
  parentPosition,
  actions,
}: {
  parentPosition: Vector3;
  actions: Array<{ icon: string; onClick: () => void }>;
}) {
  const orbiterRadius = 0.15; // meters from panel edge
  const buttonSize = 0.05;    // meters

  return (
    <group position={parentPosition}>
      {actions.map((action, i) => {
        const angle = (i / actions.length) * Math.PI * 0.5 - Math.PI * 0.25;
        const x = Math.cos(angle) * orbiterRadius;
        const y = Math.sin(angle) * orbiterRadius;

        return (
          <mesh
            key={i}
            position={[x, y, 0.02]}
            onClick={action.onClick}
          >
            <circleGeometry args={[buttonSize, 16]} />
            <meshBasicMaterial color="#4f46e5" />
            {/* Icon via Html or 3D text */}
          </mesh>
        );
      })}
    </group>
  );
}
```

### Wrist Menu (Body-Anchored UI)

Following Meta Quest menu pattern:

```tsx
function WristMenu({ items }: { items: MenuItem[] }) {
  const { left: leftHand } = useHandGestures();

  // Show menu when palm faces user
  const isPalmFacingUser = leftHand.palmDirection.z < -0.5;
  const isMenuGesture = isPalmFacingUser && !leftHand.isPinching;

  if (!leftHand.isTracking || !isMenuGesture) return null;

  return (
    <group
      position={leftHand.wristPosition}
      quaternion={leftHand.palmRotation}
    >
      {/* Offset above wrist */}
      <group position={[0, 0.08, 0]}>
        {items.map((item, i) => (
          <group key={item.id} position={[0, i * 0.04, 0]}>
            <mesh onClick={item.onClick}>
              <planeGeometry args={[0.12, 0.035]} />
              <meshBasicMaterial
                color={item.active ? '#4f46e5' : '#374151'}
              />
            </mesh>
            <Text
              position={[0, 0, 0.001]}
              fontSize={0.015}
              color="white"
              anchorX="center"
            >
              {item.label}
            </Text>
          </group>
        ))}
      </group>
    </group>
  );
}
```

---

## Industry-Standard Widget Manipulation

StickerNest implements comprehensive widget manipulation matching Quest and Vision Pro patterns.

### Widget3DHandles Component

The `Widget3DHandles` component provides industry-standard interaction:

```tsx
import { Widget3DHandles } from '@/components/spatial/xr';

<Widget3DHandles
  width={widgetWidthMeters}
  height={widgetHeightMeters}
  selected={isSelected}
  // Industry-standard features:
  enableHaptics={true}           // XR controller haptic feedback
  enableTwoHanded={true}         // Pinch-to-zoom with both hands
  snapToGrid={true}              // Size snapping for alignment
  gridSize={0.05}                // 5cm grid (adjustable)
  snapAngles={true}              // Rotation snapping
  snapAngleIncrement={15}        // 15°/45°/90° snaps
  lockAspectRatio={false}        // Optional aspect ratio lock
  // Callbacks:
  onResize={(w, h, handle) => updateWidgetSize(w, h)}
  onRotate={(angleDelta) => updateRotation(angleDelta)}
  onDepthChange={(delta) => updateZPosition(delta)}
  onTwoHandedScale={(factor) => handlePinchZoom(factor)}
/>
```

### Handle Types

| Handle | Geometry | Interaction | Use Case |
|--------|----------|-------------|----------|
| **Corner** | Spheres | Drag to resize proportionally | Resize from corners |
| **Edge** | Capsules | Single-axis resize | Width or height only |
| **Rotation** | Torus above widget | Rotate Z-axis | Orient widget |
| **Depth** | Cone pointing forward | Push/pull Z | Bring closer/further |

### Two-Handed Manipulation (Pinch-to-Zoom)

Both hands grip widget → scale by changing hand distance:

```typescript
// Detection: Both controllers squeezing same widget
const bothPressed = leftGripPressed && rightGripPressed;

// Scale factor = current hand distance / initial hand distance
const scaleFactor = currentDistance / initialDistance;

// Haptic feedback scales with intensity
triggerHaptic('both', 0.15 * scaleFactor, 20);
```

### XR Haptic Feedback Intensities

```typescript
const HAPTIC = {
  HOVER: 0.1,        // Light pulse on handle hover
  GRAB: 0.6,         // Medium pulse when grabbing handle
  DRAG: 0.15,        // Subtle feedback during drag
  RELEASE: 0.3,      // Confirmation pulse on release
  SNAP: 0.4,         // Click when snapping to grid/angle
  TWO_HAND_START: 0.8, // Strong pulse starting two-hand mode
};
```

### Snapping Behavior

**Size Snapping:**
```typescript
// Snap to grid when within threshold
const SNAP_THRESHOLD = 0.008; // 8mm
const snappedValue = Math.round(value / gridSize) * gridSize;
if (Math.abs(value - snappedValue) < SNAP_THRESHOLD) {
  triggerHaptic('both', 0.4, 30); // Snap feedback
  return snappedValue;
}
```

**Rotation Snapping (15°/45°/90°):**
```typescript
const ANGLE_SNAP_THRESHOLD = 3; // degrees
const snappedAngle = Math.round(degrees / 15) * 15;
if (Math.abs(degrees - snappedAngle) < ANGLE_SNAP_THRESHOLD) {
  // Visual indicator: angle ticks appear during rotation
  return snappedAngle;
}
```

### Visual Feedback

- **Selection border**: Dashed line turns green when snapped
- **Angle indicators**: 24 tick marks appear during rotation (15° increments)
- **Size display**: Shows dimensions in cm during resize
- **Scale percentage**: Shows two-handed scale factor
- **Aspect lock icon**: 🔒 appears when ratio locked

---

## World-Anchored Content

### Anchoring Panels to Surfaces

For AR productivity, anchor panels to detected surfaces:

```tsx
function AnchoredWorkspace() {
  const walls = useXRPlanes('wall');
  const tables = useXRPlanes('table');
  const [placedPanels, setPlacedPanels] = useState<PlacedPanel[]>([]);

  const handleSurfaceClick = (point: Vector3, plane: XRPlane) => {
    setPlacedPanels((prev) => [
      ...prev,
      {
        id: crypto.randomUUID(),
        position: point,
        normal: getPlaneNormal(plane),
        surfaceType: plane.orientation,
      },
    ]);
  };

  return (
    <>
      {/* Placement targets on walls and tables */}
      {[...walls, ...tables].map((plane) => (
        <XRSpace key={plane.planeSpace.toString()} space={plane.planeSpace}>
          <XRPlaneModel
            plane={plane}
            onClick={(e) => handleSurfaceClick(e.point, plane)}
          >
            <meshBasicMaterial
              color="#4f46e5"
              transparent
              opacity={0.1}
            />
          </XRPlaneModel>
        </XRSpace>
      ))}

      {/* Placed panels */}
      {placedPanels.map((panel) => (
        <AnchoredPanel
          key={panel.id}
          position={panel.position}
          normal={panel.normal}
        />
      ))}
    </>
  );
}
```

---

## Performance Optimization for Productivity Apps

### Target Frame Rates

| Device | Target FPS | Notes |
|--------|------------|-------|
| Quest 2 | 72-90 | 90 preferred for comfort |
| Quest 3 | 90-120 | 120 for smooth text |
| Quest Pro | 90 | Color passthrough impacts |
| Vision Pro | 90 | Variable display |

### HTML Panel Optimization

```tsx
// Reduce Html component rerenders
const MemoizedHtmlPanel = memo(function HtmlPanel({
  content,
}: {
  content: ReactNode;
}) {
  return (
    <Html
      transform
      occlude="blending"
      distanceFactor={1.5}
      zIndexRange={[0, 0]} // Prevent z-fighting
      sprite={false}       // Don't billboard
      prepend              // Render behind 3D
    >
      {content}
    </Html>
  );
}, (prev, next) => {
  // Custom comparison for complex content
  return prev.content === next.content;
});
```

### Draw Call Reduction

```tsx
// Instance repeated elements
function InstancedPanelFrames({ panels }: { panels: Panel[] }) {
  const meshRef = useRef<THREE.InstancedMesh>(null);

  useEffect(() => {
    if (!meshRef.current) return;

    panels.forEach((panel, i) => {
      const matrix = new THREE.Matrix4();
      matrix.compose(
        panel.position,
        panel.quaternion,
        new THREE.Vector3(panel.width, panel.height, 1)
      );
      meshRef.current!.setMatrixAt(i, matrix);
    });

    meshRef.current.instanceMatrix.needsUpdate = true;
  }, [panels]);

  return (
    <instancedMesh ref={meshRef} args={[undefined, undefined, panels.length]}>
      <planeGeometry args={[1, 1]} />
      <meshBasicMaterial color="#1a1a2e" transparent opacity={0.9} />
    </instancedMesh>
  );
}
```

### On-Demand Rendering

For static productivity content:

```tsx
// Only render when content changes
function ProductivityCanvas({ children }) {
  const [needsRender, setNeedsRender] = useState(true);

  return (
    <Canvas
      frameloop={needsRender ? 'always' : 'demand'}
      onCreated={({ invalidate }) => {
        // Invalidate on content changes
        setNeedsRender(false);
      }}
    >
      {children}
    </Canvas>
  );
}
```

### Memory Management

```typescript
// Dispose textures and geometries properly
function useDisposable<T extends { dispose: () => void }>(
  factory: () => T,
  deps: DependencyList
): T {
  const ref = useRef<T>();

  useEffect(() => {
    ref.current?.dispose();
    ref.current = factory();
    return () => ref.current?.dispose();
  }, deps);

  return ref.current!;
}
```

---

## Multi-Monitor Productivity Patterns

Based on Immersed's multi-screen approach:

### Virtual Monitor Layout

```tsx
interface VirtualMonitor {
  id: string;
  position: Vector3;
  rotation: Euler;
  width: number;      // meters
  height: number;     // meters
  resolution: { x: number; y: number };
  curved: boolean;
  curveRadius: number;
}

const MONITOR_PRESETS = {
  single: [
    { position: [0, 1.5, -1.5], width: 1.6, height: 0.9 },
  ],
  dual: [
    { position: [-0.85, 1.5, -1.5], width: 1.6, height: 0.9 },
    { position: [0.85, 1.5, -1.5], width: 1.6, height: 0.9 },
  ],
  ultrawide: [
    {
      position: [0, 1.5, -2],
      width: 3.2,
      height: 0.9,
      curved: true,
      curveRadius: 2.5,
    },
  ],
  cockpit: [
    { position: [0, 1.5, -1.2], width: 1.2, height: 0.7 },       // Center main
    { position: [-1.0, 1.5, -0.8], width: 0.8, height: 0.5 },   // Left secondary
    { position: [1.0, 1.5, -0.8], width: 0.8, height: 0.5 },    // Right secondary
  ],
};
```

### Focus Mode

Bring content closer without moving user:

```tsx
function FocusablePanel({ children, onFocus }) {
  const [isFocused, setIsFocused] = useState(false);
  const groupRef = useRef<THREE.Group>(null);

  const { position, scale } = useSpring({
    position: isFocused ? [0, 1.5, -0.8] : [0, 1.5, -1.5],
    scale: isFocused ? 1.3 : 1,
    config: { tension: 200, friction: 20 },
  });

  return (
    <animated.group
      ref={groupRef}
      position={position as any}
      scale={scale}
      onDoubleClick={() => setIsFocused((f) => !f)}
    >
      {children}
    </animated.group>
  );
}
```

---

## DOM Overlay for 2D UI

For AR/mobile, use WebXR DOM Overlay for native 2D UI:

```tsx
// Request DOM overlay feature
const xrStore = createXRStore({
  domOverlay: {
    root: document.getElementById('xr-overlay')!,
  },
});

// AR UI component
function ARProductivityOverlay() {
  return (
    <div id="xr-overlay" className="xr-dom-overlay">
      {/* Native 2D UI rendered over AR view */}
      <button
        onClick={(e) => {
          // preventDefault suppresses XR select events
          e.preventDefault();
          // Handle UI interaction
        }}
      >
        Add Note
      </button>
    </div>
  );
}
```

---

## Vision Pro Compatibility

### Transient Pointer Handling

Vision Pro uses `transient-pointer` which only reveals gaze position at pinch moment:

```tsx
function VisionProCompatibleScene() {
  useXREvent('select', (e) => {
    if (e.inputSource.targetRayMode === 'transient-pointer') {
      // This is Vision Pro gaze+pinch
      const hitPoint = e.intersection?.point;

      if (hitPoint) {
        // Process selection at gaze point
        handleSelection(hitPoint);
      }
    }
  });

  return <>{/* Scene content */}</>;
}
```

### Feature Detection Pattern

```typescript
function detectInputCapabilities(session: XRSession): InputCapabilities {
  const sources = Array.from(session.inputSources);

  return {
    hasControllers: sources.some((s) => s.targetRayMode === 'tracked-pointer'),
    hasHands: sources.some((s) => s.hand !== null),
    hasGazePinch: sources.some((s) => s.targetRayMode === 'transient-pointer'),
    hasTouch: sources.some((s) => s.targetRayMode === 'screen'),
  };
}
```

---

## Reference: Existing StickerNest Implementation

### Current XR Infrastructure

| Component | Location | Purpose |
|-----------|----------|---------|
| XR Store | `src/components/spatial/xrStore.ts` | XR configuration |
| Hand Gestures | `src/components/spatial/xr/useHandGestures.ts` | Hand tracking |
| Spatial Mode | `src/state/useSpatialModeStore.ts` | Mode state |
| Widget Rendering | `src/components/spatial/SpatialWidgetContainer.tsx` | 3D widgets |
| VR Toolbar | `src/components/spatial/xr/XRToolbar.tsx` | Tool selection |
| Teleportation | `src/components/spatial/VRTeleport.tsx` | Movement |
| AR Hit Test | `src/components/spatial/ARHitTest.tsx` | Surface detection |
| Mobile AR | `src/components/spatial/mobile/useMobileAR.ts` | Device detection |

### Gaps to Address

1. **Unified Input Layer**: No cross-platform input abstraction yet
2. **Vision Pro Compatibility**: Transient-pointer not handled
3. **Multi-Panel Layouts**: No preset workspace arrangements
4. **Performance Monitoring**: No frame rate tracking/adaptation
5. **DOM Overlay**: Not configured for AR productivity UI

---

## Troubleshooting

### Issue: Pinch gesture is jittery
**Cause**: No position damping
**Fix**: Apply smoothing to pinch midpoint (see Gesture Recognition section)

### Issue: Vision Pro select events don't fire
**Cause**: Not handling transient-pointer mode
**Fix**: Check `targetRayMode === 'transient-pointer'` in event handlers

### Issue: Panels hard to read in VR
**Cause**: Placed too far or wrong font size
**Fix**: Keep panels at 0.8-1.2m distance, use minimum 16px (0.012m) font

### Issue: Frame drops in productivity scene
**Cause**: Too many Html components or draw calls
**Fix**: Memoize Html content, use instancing, enable on-demand rendering

### Issue: Input works on Quest but not Vision Pro
**Cause**: Relying on controller-specific events
**Fix**: Use unified input layer with intent-based handling

---

## Next Steps for StickerNest

1. **Create Unified Input Hook**: `src/xr/input/useUnifiedInput.ts`
2. **Add Productivity Panel Component**: `src/components/spatial/productivity/`
3. **Implement Multi-Panel Layouts**: Preset workspace arrangements
4. **Add Performance Monitor**: Track and adapt to frame rate
5. **Test on Vision Pro**: Ensure transient-pointer works

See also: [implementing-spatial-xr](../implementing-spatial-xr/SKILL.md) for core XR setup.
