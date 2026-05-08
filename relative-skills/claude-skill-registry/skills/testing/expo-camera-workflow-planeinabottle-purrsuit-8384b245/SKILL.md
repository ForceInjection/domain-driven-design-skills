---
name: expo-camera-workflow
description: Handles camera integration, photo capture, sticker creation, and storage workflows in Expo React Native apps. Use when implementing camera features, photo editing (sticker creation), file system operations, and integration with MST.
---

# Expo Camera Workflow

This skill handles the complete camera integration workflow for Expo React Native apps, including permissions, capture, sticker creation, and file system management.

## When to Use This Skill

Use this skill when you need to:
- Implement camera functionality with permission handling
- Capture photos using `CameraView`
- Implement photo editing or sticker creation logic
- Manage photo storage and file system operations
- Integrate camera features with MST stores

## Camera Workflow Steps

### 1. Permission Management
Always request camera permissions before accessing camera:

```typescript
import { Camera } from 'expo-camera'

export async function requestCameraPermissions(): Promise<boolean> {
  const { status } = await Camera.requestCameraPermissionsAsync()
  return status === 'granted'
}
```

### 2. Camera Setup
Configure `CameraView` with proper settings:

```typescript
import { CameraView } from 'expo-camera'

<CameraView
  ref={cameraRef}
  style={styles.camera}
  facing="back"
  flash="off"
/>
```

### 3. Photo Capture
Capture photos with `takePictureAsync`:

```typescript
const photo = await cameraRef.current?.takePictureAsync({
  quality: 1.0,
})
```

### 4. Photo Editing (Sticker Creation)
Create stickers by drawing paths and using `captureRef`:

```typescript
import { manipulateAsync, SaveFormat } from 'expo-image-manipulator'
import { captureRef } from 'react-native-view-shot'

// 1. Capture drawing view
const uri = await captureRef(viewRef, { format: 'png', quality: 1 })

// 2. Crop to sticker bounding box
const result = await manipulateAsync(
  uri,
  [{ crop: { originX, originY, width, height } }],
  { format: SaveFormat.PNG }
)
```

### 5. File Storage
Store captured images in app's document directory:

```typescript
import * as FileSystem from 'expo-file-system'

const PHOTOS_DIR = `${FileSystem.documentDirectory}purrsuit/photos/`
await FileSystem.copyAsync({ from: photoUri, to: `${PHOTOS_DIR}${filename}` })
```

## Best Practices

1. **Permissions**: Use `requestCameraPermissions` and handle denied states.
2. **Icons**: Use `lucide-react-native` for consistent UI.
3. **Storage**: Always ensure directories exist before saving.
4. **Compression**: Use high quality (1.0) for stickers, slightly lower for originals if needed.

## References

See [CAMERA_PATTERNS.md](references/CAMERA_PATTERNS.md) for actual project implementations.
