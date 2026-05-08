---
name: unityaiforge
description: AI-powered Unity development toolkit with Model Context Protocol integration
license: MIT
---

# Unity-AI-Forge - AI-Powered Unity Development

**Forge Unity games through AI collaboration. Model Context Protocol integration with GameKit framework.**

You are now working with Unity-AI-Forge, a powerful system that lets you create, modify, and manage Unity projects directly from this conversation through intelligent AI collaboration.

## Prerequisites

Before using these tools, ensure:
1. Unity Editor is open
2. MCP Bridge is started (Tools > MCP Assistant > Start Bridge)
3. Connection status shows "Connected"

## Core Capabilities

### 🎮 Scene Management
- **Quick setup**: Instantly create 3D, 2D, UI, or VR scenes with proper configuration
- **Scene operations**: Create, load, save, delete, and list scenes
- **Context inspection**: Get real-time scene hierarchy and GameObject information

### 🎨 GameObject Operations
- **Templates**: Create common GameObjects (Cube, Sphere, Player, Enemy, etc.) with one command
- **CRUD operations**: Create, rename, move, duplicate, delete GameObjects
- **Batch operations**: Find and modify multiple GameObjects using patterns
- **Hierarchy builder**: Build complex nested structures declaratively

### 🧩 Component Management
- **Add/Remove/Update**: Manage components on any GameObject
- **Property setting**: Set component properties including asset references
- **UnityEvent listeners**: Configure UI event handlers (Button.onClick, etc.)
- **Batch operations**: Add/remove/update components on multiple GameObjects

### 🖼️ UI Creation (UGUI)
- **Templates**: Create complete UI elements (Button, Panel, ScrollView, Dropdown, etc.)
- **Layout management**: Add and configure layout groups (Vertical, Horizontal, Grid)
- **Anchor presets**: Position UI elements correctly on Canvas

### 📦 Asset & Script Management
- **Asset operations**: Rename, duplicate, delete, inspect assets and update importer settings
- **Script template generation**: Generate MonoBehaviour and ScriptableObject templates with proper Unity structure
- **Prefab workflow**: Create, instantiate, update, apply/revert prefab overrides
- **Design patterns**: Generate production-ready implementations of common design patterns (Singleton, ObjectPool, StateMachine, Observer, Command, Factory, ServiceLocator)

### 🎯 Advanced Features
- **Project settings**: Read/write Unity project settings (player, quality, time, physics, audio, editor)
- **Render pipeline**: Inspect and configure render pipeline settings (Built-in, URP, HDRP)
- **Tags & Layers**: Manage project tags and layers, set on GameObjects
- **Constants**: Convert between Unity constants and numeric values (enums, colors, layers)

## 🎮 GameKit Framework

**Unity-AI-Forge includes the GameKit framework - a high-level game development system with MCP integration.**

GameKit provides:
- **GameKitActor**: Player/NPC controllers with input abstraction
- **GameKitManager**: Centralized game systems (resources, states, turns)
- **GameKitUICommand**: Bridge UI buttons to game logic
- **GameKitMachinations**: Economic systems with flows/converters/triggers
- **GameKitSceneFlow**: State machine-based scene transitions
- **GameKitInteraction**: Trigger-based game events

**📚 See [SKILL_GAMEKIT.md](SKILL_GAMEKIT.md) for complete GameKit documentation with examples.**

### Quick GameKit Examples

```python
# Create a player actor
gamekitActor({
    "operation": "create",
    "actorId": "Player",
    "controlMode": "directController",
    "behaviorProfile": "3dCharacterController"
})

# Create a resource manager for RPG
gamekitManager({
    "operation": "create",
    "managerId": "PlayerStats",
    "managerType": "resourcepool",
    "initialResources": {
        "health": 100,
        "mana": 50,
        "gold": 0
    }
})

# Create UI buttons that control resources
gamekitUICommand({
    "operation": "createCommandPanel",
    "panelId": "ShopUI",
    "canvasPath": "Canvas",
    "targetType": "manager",
    "targetManagerId": "PlayerStats",
    "commands": [
        {
            "name": "buyPotion",
            "label": "HP Potion (50g)",
            "commandType": "consumeResource",
            "commandParameter": "gold",
            "resourceAmount": 50
        }
    ]
})
```

---

## Quick Start Commands

### Scene Setup
```python
# Set up a 3D game scene (Camera + Light)
unity_scene_quickSetup({"setupType": "3D"})

# Set up a UI scene (Canvas + EventSystem)
unity_scene_quickSetup({"setupType": "UI"})

# Set up a 2D scene
unity_scene_quickSetup({"setupType": "2D"})
```

### GameObject Creation
```python
# Create from template (fastest way)
unity_gameobject_createFromTemplate({
    "template": "Sphere",  # Cube, Sphere, Player, Enemy, etc.
    "name": "Ball",
    "position": {"x": 0, "y": 5, "z": 0},
    "scale": {"x": 0.5, "y": 0.5, "z": 0.5}
})

# Create hierarchical menu system
unity_menu_hierarchyCreate({
    "menuName": "MainMenu",
    "menuStructure": {
        "Play": "Start Game",
        "Settings": {
            "text": "Game Settings",
            "submenus": {
                "Graphics": "Graphics Options",
                "Audio": "Audio Settings"
            }
        },
        "Quit": "Exit Game"
    },
    "generateStateMachine": True,
    "stateMachineScriptPath": "Assets/Scripts/MenuManager.cs"
})
```

### UI Creation
```python
# Create button with one command
unity_ugui_createFromTemplate({
    "template": "Button",
    "text": "Start Game",
    "width": 200,
    "height": 50,
    "anchorPreset": "middle-center"
})

# Create complete menu with navigation
unity_menu_hierarchyCreate({
    "menuName": "GameMenu",
    "menuStructure": {
        "NewGame": "New Game",
        "LoadGame": "Load Game",
        "Options": {
            "text": "Options",
            "submenus": {
                "Display": "Display Settings",
                "Sound": "Sound Settings",
                "Controls": "Control Settings"
            }
        },
        "Exit": "Exit Game"
    },
    "generateStateMachine": True,
    "stateMachineScriptPath": "Assets/Scripts/GameMenuManager.cs",
    "buttonWidth": 250,
    "buttonHeight": 60,
    "navigationMode": "both"
})
```

### Component Management
```python
# Add component
unity_component_crud({
    "operation": "add",
    "gameObjectPath": "Player",
    "componentType": "UnityEngine.Rigidbody"
})

# Update component properties
unity_component_crud({
    "operation": "update",
    "gameObjectPath": "Player",
    "componentType": "UnityEngine.Transform",
    "propertyChanges": {
        "position": {"x": 0, "y": 1, "z": 0},
        "rotation": {"x": 0, "y": 45, "z": 0}
    }
})

# Fast inspection (existence check only)
unity_component_crud({
    "operation": "inspect",
    "gameObjectPath": "Player",
    "componentType": "UnityEngine.CharacterController",
    "includeProperties": False  # 10x faster!
})
```

### Scene Inspection
```python
# Get scene overview (returns one level of hierarchy for performance)
unity_scene_crud({
    "operation": "inspect",
    "includeHierarchy": True,
    "includeComponents": False,  # Skip components for speed
    "filter": "Player*"  # Optional: filter by pattern
})

# For deeper exploration, inspect specific GameObject
unity_gameobject_crud({
    "operation": "inspect",
    "gameObjectPath": "Player/Weapon",
    "includeComponents": True
})
```

### Script Template Generation
```python
# Generate MonoBehaviour template
unity_script_template_generate({
    "templateType": "MonoBehaviour",
    "className": "PlayerController",
    "scriptPath": "Assets/Scripts/PlayerController.cs",
    "namespace": "MyGame.Player"
})

# Generate ScriptableObject template
unity_script_template_generate({
    "templateType": "ScriptableObject",
    "className": "GameConfig",
    "scriptPath": "Assets/ScriptableObjects/GameConfig.cs"
})

# Modify generated template using asset_crud
unity_asset_crud({
    "operation": "update",
    "assetPath": "Assets/Scripts/PlayerController.cs",
    "content": "using UnityEngine;\n\nnamespace MyGame.Player\n{\n    public class PlayerController : MonoBehaviour\n    {\n        public float speed = 5f;\n        \n        void Update()\n        {\n            // Movement code\n        }\n    }\n}"
})
```

### Design Pattern Generation
```python
# Generate Singleton pattern
unity_designPattern_generate({
    "patternType": "singleton",
    "className": "GameManager",
    "scriptPath": "Assets/Scripts/GameManager.cs",
    "options": {
        "persistent": True,
        "threadSafe": True,
        "monoBehaviour": True
    }
})

# Generate ObjectPool pattern
unity_designPattern_generate({
    "patternType": "objectpool",
    "className": "BulletPool",
    "scriptPath": "Assets/Scripts/BulletPool.cs",
    "options": {
        "pooledType": "Bullet",
        "defaultCapacity": "100",
        "maxSize": "500"
    }
})

# Generate StateMachine pattern
unity_designPattern_generate({
    "patternType": "statemachine",
    "className": "PlayerStateMachine",
    "scriptPath": "Assets/Scripts/PlayerStateMachine.cs",
    "namespace": "MyGame.Player"
})

# Available patterns: singleton, objectpool, statemachine, observer, command, factory, servicelocator
```

## Best Practices

### DO ✅
1. **Use templates** - 10x faster than manual creation
   ```python
   unity_ugui_createFromTemplate({"template": "Button"})  # Not manual GameObject + components
   ```

2. **Check context first** - Understand current state before changes
   ```python
   unity_context_inspect({"includeHierarchy": True, "includeComponents": False})
   ```

3. **Use menu creation** - Create complete menu systems with navigation
   ```python
   unity_menu_hierarchyCreate({"menuName": "MainMenu", "menuStructure": {...}})  # Not manual UI creation
   ```

4. **Use script templates** - Generate standard Unity script structures quickly
   ```python
   unity_script_template_generate({"templateType": "MonoBehaviour", "className": "Player", "scriptPath": "Assets/Scripts/Player.cs"})
   ```

5. **Optimize inspections** - Use `includeProperties=false` and `propertyFilter`
   ```python
   unity_component_crud({
       "operation": "inspect",
       "gameObjectPath": "Player",
       "componentType": "UnityEngine.Transform",
       "propertyFilter": ["position", "rotation"]  # Only specific properties
   })
   ```

6. **Limit batch operations** - Use `maxResults` to prevent timeouts
   ```python
   unity_component_crud({
       "operation": "addMultiple",
       "pattern": "Enemy*",
       "componentType": "UnityEngine.Rigidbody",
       "maxResults": 1000  # Safe limit
   })
   ```

### DON'T ❌
1. **Don't create UI manually** - Use templates instead
2. **Don't edit .meta files** - Unity manages these automatically
3. **Don't use asset tool for scripts** - Use script batch manager
4. **Don't skip context inspection** - Know what exists before modifying
5. **Don't use unlimited batch operations** - Always set `maxResults`

## Component Type Reference

### Common Unity Components
- Transform: `UnityEngine.Transform`
- Rigidbody: `UnityEngine.Rigidbody`
- Colliders: `UnityEngine.BoxCollider`, `UnityEngine.SphereCollider`, `UnityEngine.CapsuleCollider`
- Renderer: `UnityEngine.MeshRenderer`, `UnityEngine.SpriteRenderer`
- Camera: `UnityEngine.Camera`
- Light: `UnityEngine.Light`
- Audio: `UnityEngine.AudioSource`, `UnityEngine.AudioListener`

### UI Components (UGUI)
- Canvas: `UnityEngine.Canvas`, `UnityEngine.UI.CanvasScaler`, `UnityEngine.UI.GraphicRaycaster`
- Controls: `UnityEngine.UI.Button`, `UnityEngine.UI.Toggle`, `UnityEngine.UI.Slider`, `UnityEngine.UI.InputField`
- Display: `UnityEngine.UI.Text`, `UnityEngine.UI.Image`, `UnityEngine.UI.RawImage`
- Layout: `UnityEngine.UI.VerticalLayoutGroup`, `UnityEngine.UI.HorizontalLayoutGroup`, `UnityEngine.UI.GridLayoutGroup`

## Performance Tips

### Fast Operations
```python
# ⚡ Ultra-fast: Check existence only (0.1s)
unity_component_crud({
    "operation": "inspect",
    "gameObjectPath": "Player",
    "componentType": "UnityEngine.Rigidbody",
    "includeProperties": False
})

# ⚡ Fast: Get specific properties (0.3s)
unity_component_crud({
    "operation": "inspect",
    "gameObjectPath": "Player",
    "componentType": "UnityEngine.Transform",
    "propertyFilter": ["position"]
})
```

### Batch Operations with Safety
```python
# Test small first
test = unity_component_crud({
    "operation": "addMultiple",
    "pattern": "Enemy*",
    "componentType": "UnityEngine.Rigidbody",
    "maxResults": 10,  # Test with 10 first
    "stopOnError": False
})

# If successful, scale up
if test["errorCount"] == 0:
    unity_component_crud({...,"maxResults": 1000})
```

## Common Workflows

### Create a Main Menu
```python
# 1. Setup UI scene
unity_scene_quickSetup({"setupType": "UI"})

# 2. Create complete menu system with navigation
unity_menu_hierarchyCreate({
    "menuName": "MainMenu",
    "menuStructure": {
        "Play": "Start Game",
        "Settings": {
            "text": "Settings",
            "submenus": {
                "Graphics": "Graphics Settings",
                "Audio": "Audio Settings",
                "Controls": "Control Settings"
            }
        },
        "Credits": "View Credits",
        "Quit": "Exit Game"
    },
    "generateStateMachine": True,
    "stateMachineScriptPath": "Assets/Scripts/MainMenuManager.cs",
    "buttonWidth": 300,
    "buttonHeight": 60,
    "spacing": 15
})
```

### Create a Game Level
```python
# 1. Setup 3D scene
unity_scene_quickSetup({"setupType": "3D"})

# 2. Create player
unity_gameobject_createFromTemplate({
    "template": "Player",
    "position": {"x": 0, "y": 1, "z": 0}
})

# 3. Create ground
unity_gameobject_createFromTemplate({
    "template": "Plane",
    "name": "Ground",
    "scale": {"x": 10, "y": 1, "z": 10}
})

# 4. Create obstacles
for i in range(5):
    unity_gameobject_createFromTemplate({
        "template": "Cube",
        "name": f"Obstacle{i}",
        "position": {"x": i*2, "y": 0.5, "z": 0}
    })
```

## Troubleshooting

### Unity Bridge Not Connected
**Solution**: Open Unity → Tools → MCP Assistant → Start Bridge

### GameObject Not Found
**Solution**: Use `unity_context_inspect()` to see what exists

### Component Type Not Found
**Solution**: Use fully qualified names (e.g., `UnityEngine.UI.Button`, not just `Button`)

### Operation Timeout
**Solution**:
- Use `includeProperties=false` for faster operations
- Set `maxResults` limit for batch operations
- Check Unity isn't compiling scripts

## Complete Tool Reference

**📚 For detailed documentation of all 28 tools, see [TOOLS_REFERENCE.md](docs/TOOLS_REFERENCE.md)**

The tools are organized into 10 categories:

| Category | Tools | Description |
|----------|-------|-------------|
| **Core Tools** | 4 | Connection, context, menu creation, compilation |
| **Scene Management** | 2 | Scene CRUD, quick setup templates |
| **GameObject Operations** | 3 | GameObject CRUD, templates, tag/layer management |
| **Component Management** | 1 | Component CRUD with batch operations |
| **Asset Management** | 2 | Asset operations, C# script batch management |
| **Design Patterns** | 1 | Generate production-ready design pattern implementations |
| **UI (UGUI) Tools** | 6 | UI templates, layouts, RectTransform, overlap detection |
| **Prefab Management** | 1 | Prefab workflow (create, instantiate, apply/revert) |
| **Advanced Features** | 7 | Settings, pipeline, input system, tilemap, navmesh, constants |
| **Utility Tools** | 1 | Compilation waiting |

**Total: 28 Tools**

---

## Quick Tool Reference

### Scene Management
- `unity_scene_quickSetup` - Quick scene setup (3D/2D/UI/VR)
- `unity_scene_crud` - Create, load, save, delete scenes, manage build settings
- `unity_context_inspect` - Get scene hierarchy and state

### GameObject Operations
- `unity_gameobject_createFromTemplate` - Create from templates
- `unity_gameobject_crud` - Full GameObject CRUD operations
- `unity_menu_hierarchyCreate` - Create hierarchical menu systems with navigation

### Component Management
- `unity_component_crud` - Add, update, remove, inspect components

### UI Creation
- `unity_ugui_createFromTemplate` - Create UI elements from templates
- `unity_ugui_layoutManage` - Manage layout components

### Asset & Script Management
- `unity_asset_crud` - Asset file operations (including C# scripts)
- `unity_script_template_generate` - Generate MonoBehaviour/ScriptableObject templates

### Design Patterns
- `unity_designPattern_generate` - Generate design pattern implementations (Singleton, ObjectPool, StateMachine, Observer, Command, Factory, ServiceLocator)

### Advanced Features
- `unity_prefab_crud` - Prefab workflow operations
- `unity_projectSettings_crud` - Project settings management (player, quality, time, physics, audio, editor)
- `unity_renderPipeline_manage` - Render pipeline configuration (Built-in, URP, HDRP)
- `unity_tagLayer_manage` - Tag and layer management
- `unity_constant_convert` - Convert between Unity constants and values (enums, colors, layers)
- `unity_template_manage` - Customize GameObjects and convert to prefabs

### UGUI Tools
- `unity_ugui_manage` - Unified UGUI management (RectTransform operations)
- `unity_ugui_rectAdjust` - Adjust RectTransform size
- `unity_ugui_anchorManage` - Manage RectTransform anchors
- `unity_ugui_detectOverlaps` - Detect overlapping UI elements

### Utility
- `unity_ping` - Test connection and get Unity version
- `unity_await_compilation` - Wait for Unity compilation to complete (includes console logs in results)

## Tips for Success

1. **Always check context before major operations** - Know what you're working with
2. **Use templates whenever possible** - They're optimized and reliable
3. **Batch similar operations** - More efficient than individual commands
4. **Set appropriate timeouts** - Some operations need more time (script compilation)
5. **Use property filters** - Get only the data you need
6. **Test with small limits first** - Before scaling up batch operations
7. **Follow Unity naming conventions** - Use full component type names

---

## Additional Documentation

### GameKit Framework
**📚 [SKILL_GAMEKIT.md](SKILL_GAMEKIT.md)** - Complete guide to GameKit framework:
- GameKitActor (player/NPC controllers)
- GameKitManager (resource/state/turn management)  
- GameKitUICommand (UI → game logic bridge)
- GameKitMachinations (economic systems)
- GameKitSceneFlow (scene transitions)
- GameKitInteraction (trigger systems)
- **Includes complete game examples** (RPG, Tower Defense, Turn-Based Strategy)

### MCP Tools Reference
**📚 [TOOLS_REFERENCE.md](docs/TOOLS_REFERENCE.md)** - Detailed documentation of all 28+ MCP tools

---

**You now have complete control over Unity Editor. Build amazing projects!** 🚀
