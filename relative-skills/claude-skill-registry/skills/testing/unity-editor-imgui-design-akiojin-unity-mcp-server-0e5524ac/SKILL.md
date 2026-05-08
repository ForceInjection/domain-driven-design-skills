---
name: unity-editor-imgui-design
description: Unity IMGUI (Immediate Mode GUI) for editor tools and custom inspectors. Use for EditorWindow, Custom Inspector, Property Drawer development. NOT for game UI - use unity-game-ugui-design or unity-game-ui-toolkit-design instead.
allowed-tools:
  - mcp__unity-mcp-server__create_class
  - mcp__unity-mcp-server__edit_structured
  - mcp__unity-mcp-server__edit_snippet
  - mcp__unity-mcp-server__read
  - mcp__unity-mcp-server__search
  - mcp__unity-mcp-server__get_symbols
  - mcp__unity-mcp-server__find_symbol
  - mcp__unity-mcp-server__manage_asset_database
  - mcp__unity-mcp-server__execute_menu_item
  - mcp__unity-mcp-server__get_compilation_state
---

# Unity Editor IMGUI Design Skill

> **WARNING**: IMGUI is for **Unity Editor extensions ONLY**.
> For game UI, use `unity-game-ugui-design` or `unity-game-ui-toolkit-design`.

## IMGUI vs Game UI

| Aspect | IMGUI (Editor) | uGUI / UI Toolkit (Game) |
|--------|----------------|--------------------------|
| Purpose | Editor tools, inspectors | In-game UI, HUD |
| Build inclusion | Editor only | Included in builds |
| Rendering | Immediate mode | Retained mode |
| Performance | OK for editor | Optimized for runtime |
| Styling | Limited (GUISkin) | Rich (USS, materials) |

---

## Quick Start

### Create EditorWindow

```javascript
// Create editor window script
mcp__unity-mcp-server__create_class({
  path: "Assets/Editor/MyToolWindow.cs",
  className: "MyToolWindow",
  namespace: "MyProject.Editor",
  baseType: "EditorWindow",
  usings: "UnityEditor"
})

// Add window content
mcp__unity-mcp-server__edit_structured({
  path: "Assets/Editor/MyToolWindow.cs",
  symbolName: "MyToolWindow",
  operation: "insert_after",
  newText: `
    [MenuItem("Tools/My Tool Window")]
    public static void ShowWindow()
    {
        GetWindow<MyToolWindow>("My Tool");
    }

    private void OnGUI()
    {
        GUILayout.Label("My Tool", EditorStyles.boldLabel);

        if (GUILayout.Button("Do Something"))
        {
            Debug.Log("Button clicked!");
        }
    }
`
})
```

### Create Custom Inspector

```javascript
// Create custom inspector script
mcp__unity-mcp-server__create_class({
  path: "Assets/Editor/MyComponentEditor.cs",
  className: "MyComponentEditor",
  namespace: "MyProject.Editor",
  baseType: "Editor",
  usings: "UnityEditor"
})

// Add CustomEditor attribute and OnInspectorGUI
mcp__unity-mcp-server__edit_structured({
  path: "Assets/Editor/MyComponentEditor.cs",
  symbolName: "MyComponentEditor",
  operation: "insert_before",
  newText: "[CustomEditor(typeof(MyComponent))]\n"
})

mcp__unity-mcp-server__edit_structured({
  path: "Assets/Editor/MyComponentEditor.cs",
  symbolName: "MyComponentEditor",
  operation: "insert_after",
  newText: `
    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        EditorGUILayout.PropertyField(serializedObject.FindProperty("myField"));

        if (GUILayout.Button("Custom Button"))
        {
            ((MyComponent)target).DoSomething();
        }

        serializedObject.ApplyModifiedProperties();
    }
`
})
```

---

## Core Concepts

### IMGUI Lifecycle

```
OnGUI() called every frame (or on repaint/input)
    ├── Layout Event: Calculate sizes
    ├── Repaint Event: Draw controls
    └── Input Events: Handle mouse/keyboard
```

### Event Types

```csharp
void OnGUI()
{
    Event e = Event.current;

    switch (e.type)
    {
        case EventType.Layout:
            // Calculate layout
            break;
        case EventType.Repaint:
            // Draw visuals
            break;
        case EventType.MouseDown:
            // Handle click
            break;
        case EventType.KeyDown:
            // Handle keyboard
            break;
    }
}
```

### GUILayout vs EditorGUILayout

| GUILayout | EditorGUILayout |
|-----------|-----------------|
| Works everywhere | Editor only |
| Basic controls | Rich editor controls |
| `GUILayout.Button` | `EditorGUILayout.PropertyField` |
| `GUILayout.TextField` | `EditorGUILayout.ObjectField` |
| `GUILayout.Label` | `EditorGUILayout.HelpBox` |

---

## EditorWindow Patterns

### Basic Window Structure

```csharp
using UnityEngine;
using UnityEditor;

public class MyToolWindow : EditorWindow
{
    // Serialized state (survives recompile)
    [SerializeField] private string searchText = "";
    [SerializeField] private Vector2 scrollPosition;

    // Non-serialized state
    private GUIStyle headerStyle;

    [MenuItem("Tools/My Tool %#t")] // Ctrl+Shift+T
    public static void ShowWindow()
    {
        var window = GetWindow<MyToolWindow>();
        window.titleContent = new GUIContent("My Tool", EditorGUIUtility.IconContent("d_Settings").image);
        window.minSize = new Vector2(300, 200);
        window.Show();
    }

    private void OnEnable()
    {
        // Initialize when window opens
    }

    private void OnDisable()
    {
        // Cleanup when window closes
    }

    private void OnGUI()
    {
        InitStyles();
        DrawToolbar();
        DrawContent();
    }

    private void InitStyles()
    {
        headerStyle ??= new GUIStyle(EditorStyles.boldLabel)
        {
            fontSize = 14,
            alignment = TextAnchor.MiddleCenter
        };
    }

    private void DrawToolbar()
    {
        using (new EditorGUILayout.HorizontalScope(EditorStyles.toolbar))
        {
            if (GUILayout.Button("Refresh", EditorStyles.toolbarButton, GUILayout.Width(60)))
            {
                Refresh();
            }

            GUILayout.FlexibleSpace();

            searchText = EditorGUILayout.TextField(searchText, EditorStyles.toolbarSearchField, GUILayout.Width(200));
        }
    }

    private void DrawContent()
    {
        scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition);
        {
            GUILayout.Label("Content Here", headerStyle);
        }
        EditorGUILayout.EndScrollView();
    }

    private void Refresh()
    {
        Repaint();
    }
}
```

### MCP Implementation

```javascript
// Create the window class
mcp__unity-mcp-server__create_class({
  path: "Assets/Editor/Tools/AssetBrowserWindow.cs",
  className: "AssetBrowserWindow",
  namespace: "MyProject.Editor.Tools",
  baseType: "EditorWindow",
  usings: "UnityEditor,System.Collections.Generic,System.Linq"
})

// Add complete implementation
mcp__unity-mcp-server__edit_structured({
  path: "Assets/Editor/Tools/AssetBrowserWindow.cs",
  symbolName: "AssetBrowserWindow",
  operation: "insert_after",
  newText: `
    [SerializeField] private string searchFilter = "";
    [SerializeField] private Vector2 scrollPos;
    private List<string> assetPaths = new List<string>();

    [MenuItem("Tools/Asset Browser")]
    public static void ShowWindow()
    {
        GetWindow<AssetBrowserWindow>("Asset Browser");
    }

    private void OnEnable()
    {
        RefreshAssets();
    }

    private void OnGUI()
    {
        DrawSearchBar();
        DrawAssetList();
    }

    private void DrawSearchBar()
    {
        using (new EditorGUILayout.HorizontalScope(EditorStyles.toolbar))
        {
            EditorGUI.BeginChangeCheck();
            searchFilter = EditorGUILayout.TextField(searchFilter, EditorStyles.toolbarSearchField);
            if (EditorGUI.EndChangeCheck())
            {
                RefreshAssets();
            }

            if (GUILayout.Button("Refresh", EditorStyles.toolbarButton, GUILayout.Width(60)))
            {
                RefreshAssets();
            }
        }
    }

    private void DrawAssetList()
    {
        scrollPos = EditorGUILayout.BeginScrollView(scrollPos);

        foreach (var path in assetPaths)
        {
            using (new EditorGUILayout.HorizontalScope())
            {
                var icon = AssetDatabase.GetCachedIcon(path);
                GUILayout.Label(icon, GUILayout.Width(20), GUILayout.Height(20));

                if (GUILayout.Button(System.IO.Path.GetFileName(path), EditorStyles.linkLabel))
                {
                    Selection.activeObject = AssetDatabase.LoadAssetAtPath<Object>(path);
                    EditorGUIUtility.PingObject(Selection.activeObject);
                }
            }
        }

        EditorGUILayout.EndScrollView();
    }

    private void RefreshAssets()
    {
        var filter = string.IsNullOrEmpty(searchFilter) ? "t:Object" : searchFilter;
        assetPaths = AssetDatabase.FindAssets(filter)
            .Select(AssetDatabase.GUIDToAssetPath)
            .Take(100)
            .ToList();
        Repaint();
    }
`
})
```

---

## Custom Inspector Patterns

### Basic Inspector

```csharp
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(EnemySpawner))]
public class EnemySpawnerEditor : Editor
{
    private SerializedProperty spawnPrefab;
    private SerializedProperty spawnInterval;
    private SerializedProperty maxEnemies;

    private void OnEnable()
    {
        spawnPrefab = serializedObject.FindProperty("spawnPrefab");
        spawnInterval = serializedObject.FindProperty("spawnInterval");
        maxEnemies = serializedObject.FindProperty("maxEnemies");
    }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        EditorGUILayout.PropertyField(spawnPrefab);

        EditorGUILayout.Space();
        EditorGUILayout.LabelField("Spawn Settings", EditorStyles.boldLabel);

        EditorGUILayout.PropertyField(spawnInterval);
        EditorGUILayout.PropertyField(maxEnemies);

        EditorGUILayout.Space();

        // Custom button
        if (GUILayout.Button("Spawn Test Enemy"))
        {
            var spawner = (EnemySpawner)target;
            spawner.SpawnEnemy();
        }

        serializedObject.ApplyModifiedProperties();
    }
}
```

### MCP Implementation

```javascript
// Create inspector class
mcp__unity-mcp-server__create_class({
  path: "Assets/Editor/Inspectors/WeaponDataEditor.cs",
  className: "WeaponDataEditor",
  namespace: "MyProject.Editor",
  baseType: "Editor",
  usings: "UnityEditor"
})

// Add CustomEditor attribute
mcp__unity-mcp-server__edit_structured({
  path: "Assets/Editor/Inspectors/WeaponDataEditor.cs",
  symbolName: "WeaponDataEditor",
  operation: "insert_before",
  newText: "[CustomEditor(typeof(WeaponData))]\n"
})

// Add inspector implementation
mcp__unity-mcp-server__edit_structured({
  path: "Assets/Editor/Inspectors/WeaponDataEditor.cs",
  symbolName: "WeaponDataEditor",
  operation: "insert_after",
  newText: `
    private SerializedProperty weaponName;
    private SerializedProperty damage;
    private SerializedProperty attackSpeed;
    private SerializedProperty weaponType;

    private bool showStats = true;

    private void OnEnable()
    {
        weaponName = serializedObject.FindProperty("weaponName");
        damage = serializedObject.FindProperty("damage");
        attackSpeed = serializedObject.FindProperty("attackSpeed");
        weaponType = serializedObject.FindProperty("weaponType");
    }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        // Header
        EditorGUILayout.LabelField("Weapon Configuration", EditorStyles.boldLabel);
        EditorGUILayout.Space();

        EditorGUILayout.PropertyField(weaponName);
        EditorGUILayout.PropertyField(weaponType);

        EditorGUILayout.Space();

        // Foldout section
        showStats = EditorGUILayout.Foldout(showStats, "Combat Stats", true);
        if (showStats)
        {
            EditorGUI.indentLevel++;
            EditorGUILayout.PropertyField(damage);
            EditorGUILayout.PropertyField(attackSpeed);

            // Calculated DPS
            float dps = damage.floatValue * attackSpeed.floatValue;
            EditorGUILayout.HelpBox($"DPS: {dps:F1}", MessageType.Info);
            EditorGUI.indentLevel--;
        }

        serializedObject.ApplyModifiedProperties();
    }
`
})
```

### Foldout Groups

```csharp
private bool showAdvanced = false;

public override void OnInspectorGUI()
{
    serializedObject.Update();

    // Basic properties
    EditorGUILayout.PropertyField(serializedObject.FindProperty("basicField"));

    // Foldout group
    showAdvanced = EditorGUILayout.Foldout(showAdvanced, "Advanced Settings", true);
    if (showAdvanced)
    {
        EditorGUI.indentLevel++;
        EditorGUILayout.PropertyField(serializedObject.FindProperty("advancedField1"));
        EditorGUILayout.PropertyField(serializedObject.FindProperty("advancedField2"));
        EditorGUI.indentLevel--;
    }

    serializedObject.ApplyModifiedProperties();
}
```

### Conditional Display

```csharp
public override void OnInspectorGUI()
{
    serializedObject.Update();

    var enableFeature = serializedObject.FindProperty("enableFeature");
    EditorGUILayout.PropertyField(enableFeature);

    // Show only when enabled
    if (enableFeature.boolValue)
    {
        EditorGUI.indentLevel++;
        EditorGUILayout.PropertyField(serializedObject.FindProperty("featureValue"));
        EditorGUILayout.PropertyField(serializedObject.FindProperty("featureMode"));
        EditorGUI.indentLevel--;
    }

    serializedObject.ApplyModifiedProperties();
}
```

---

## Property Drawer Patterns

### Basic Property Drawer

```csharp
using UnityEngine;
using UnityEditor;

[CustomPropertyDrawer(typeof(MinMaxRange))]
public class MinMaxRangeDrawer : PropertyDrawer
{
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        EditorGUI.BeginProperty(position, label, property);

        position = EditorGUI.PrefixLabel(position, label);

        var minProp = property.FindPropertyRelative("min");
        var maxProp = property.FindPropertyRelative("max");

        float min = minProp.floatValue;
        float max = maxProp.floatValue;

        // MinMax slider
        var sliderRect = new Rect(position.x, position.y, position.width - 100, position.height);
        var minRect = new Rect(position.x + position.width - 95, position.y, 45, position.height);
        var maxRect = new Rect(position.x + position.width - 45, position.y, 45, position.height);

        EditorGUI.MinMaxSlider(sliderRect, ref min, ref max, 0f, 100f);
        min = EditorGUI.FloatField(minRect, min);
        max = EditorGUI.FloatField(maxRect, max);

        minProp.floatValue = min;
        maxProp.floatValue = max;

        EditorGUI.EndProperty();
    }
}
```

### MCP Implementation

```javascript
// Create property drawer
mcp__unity-mcp-server__create_class({
  path: "Assets/Editor/PropertyDrawers/ColorRangeDrawer.cs",
  className: "ColorRangeDrawer",
  namespace: "MyProject.Editor",
  baseType: "PropertyDrawer",
  usings: "UnityEditor"
})

// Add attribute and implementation
mcp__unity-mcp-server__edit_structured({
  path: "Assets/Editor/PropertyDrawers/ColorRangeDrawer.cs",
  symbolName: "ColorRangeDrawer",
  operation: "insert_before",
  newText: "[CustomPropertyDrawer(typeof(ColorRange))]\n"
})

mcp__unity-mcp-server__edit_structured({
  path: "Assets/Editor/PropertyDrawers/ColorRangeDrawer.cs",
  symbolName: "ColorRangeDrawer",
  operation: "insert_after",
  newText: `
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        EditorGUI.BeginProperty(position, label, property);

        position = EditorGUI.PrefixLabel(position, label);

        var startColor = property.FindPropertyRelative("startColor");
        var endColor = property.FindPropertyRelative("endColor");

        float halfWidth = position.width / 2 - 2;
        var startRect = new Rect(position.x, position.y, halfWidth, position.height);
        var endRect = new Rect(position.x + halfWidth + 4, position.y, halfWidth, position.height);

        EditorGUI.PropertyField(startRect, startColor, GUIContent.none);
        EditorGUI.PropertyField(endRect, endColor, GUIContent.none);

        EditorGUI.EndProperty();
    }

    public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
    {
        return EditorGUIUtility.singleLineHeight;
    }
`
})
```

### Multi-Line Property Drawer

```csharp
[CustomPropertyDrawer(typeof(DialogLine))]
public class DialogLineDrawer : PropertyDrawer
{
    public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
    {
        // 3 lines + spacing
        return EditorGUIUtility.singleLineHeight * 3 + 4;
    }

    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        EditorGUI.BeginProperty(position, label, property);

        float lineHeight = EditorGUIUtility.singleLineHeight;

        var speakerRect = new Rect(position.x, position.y, position.width, lineHeight);
        var textRect = new Rect(position.x, position.y + lineHeight + 2, position.width, lineHeight * 2);

        EditorGUI.PropertyField(speakerRect, property.FindPropertyRelative("speaker"));
        EditorGUI.PropertyField(textRect, property.FindPropertyRelative("text"));

        EditorGUI.EndProperty();
    }
}
```

---

## Attribute-Based Drawers

### ReadOnly Attribute

```csharp
// Runtime attribute
public class ReadOnlyAttribute : PropertyAttribute { }

// Editor drawer
[CustomPropertyDrawer(typeof(ReadOnlyAttribute))]
public class ReadOnlyDrawer : PropertyDrawer
{
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        GUI.enabled = false;
        EditorGUI.PropertyField(position, property, label);
        GUI.enabled = true;
    }
}
```

### Range with Label Attribute

```csharp
// Runtime attribute
public class LabeledRangeAttribute : PropertyAttribute
{
    public float Min { get; }
    public float Max { get; }
    public string MinLabel { get; }
    public string MaxLabel { get; }

    public LabeledRangeAttribute(float min, float max, string minLabel, string maxLabel)
    {
        Min = min;
        Max = max;
        MinLabel = minLabel;
        MaxLabel = maxLabel;
    }
}

// Editor drawer
[CustomPropertyDrawer(typeof(LabeledRangeAttribute))]
public class LabeledRangeDrawer : PropertyDrawer
{
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        var attr = (LabeledRangeAttribute)attribute;

        EditorGUI.BeginProperty(position, label, property);
        position = EditorGUI.PrefixLabel(position, label);

        // Min label
        var minLabelRect = new Rect(position.x, position.y, 30, position.height);
        GUI.Label(minLabelRect, attr.MinLabel);

        // Slider
        var sliderRect = new Rect(position.x + 35, position.y, position.width - 70, position.height);
        property.floatValue = GUI.HorizontalSlider(sliderRect, property.floatValue, attr.Min, attr.Max);

        // Max label
        var maxLabelRect = new Rect(position.x + position.width - 30, position.y, 30, position.height);
        GUI.Label(maxLabelRect, attr.MaxLabel);

        EditorGUI.EndProperty();
    }
}
```

---

## SceneView GUI (Handles)

### Gizmo Drawing

```csharp
[CustomEditor(typeof(SpawnArea))]
public class SpawnAreaEditor : Editor
{
    private void OnSceneGUI()
    {
        var spawner = (SpawnArea)target;

        // Draw spawn area bounds
        Handles.color = new Color(0, 1, 0, 0.3f);
        Handles.DrawSolidDisc(spawner.transform.position, Vector3.up, spawner.radius);

        // Draw editable radius handle
        Handles.color = Color.green;
        EditorGUI.BeginChangeCheck();
        float newRadius = Handles.RadiusHandle(Quaternion.identity, spawner.transform.position, spawner.radius);
        if (EditorGUI.EndChangeCheck())
        {
            Undo.RecordObject(spawner, "Change Spawn Radius");
            spawner.radius = newRadius;
        }

        // Draw label
        Handles.Label(spawner.transform.position + Vector3.up * 2, $"Spawn Area\nRadius: {spawner.radius:F1}");
    }
}
```

### Position Handle

```csharp
private void OnSceneGUI()
{
    var waypoint = (WaypointPath)target;

    for (int i = 0; i < waypoint.points.Count; i++)
    {
        EditorGUI.BeginChangeCheck();
        Vector3 newPos = Handles.PositionHandle(waypoint.points[i], Quaternion.identity);
        if (EditorGUI.EndChangeCheck())
        {
            Undo.RecordObject(waypoint, "Move Waypoint");
            waypoint.points[i] = newPos;
        }

        // Draw connection lines
        if (i > 0)
        {
            Handles.DrawLine(waypoint.points[i - 1], waypoint.points[i]);
        }

        // Draw index label
        Handles.Label(waypoint.points[i], $"Point {i}");
    }
}
```

---

## Common UI Patterns

### Horizontal Layout

```csharp
using (new EditorGUILayout.HorizontalScope())
{
    GUILayout.Label("Name:", GUILayout.Width(60));
    value = EditorGUILayout.TextField(value);
    if (GUILayout.Button("Clear", GUILayout.Width(50)))
    {
        value = "";
    }
}
```

### Vertical Layout with Box

```csharp
using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
{
    GUILayout.Label("Section Title", EditorStyles.boldLabel);
    EditorGUILayout.PropertyField(prop1);
    EditorGUILayout.PropertyField(prop2);
}
```

### Toolbar

```csharp
private int selectedTab = 0;
private string[] tabs = { "General", "Advanced", "Debug" };

private void OnGUI()
{
    selectedTab = GUILayout.Toolbar(selectedTab, tabs);

    switch (selectedTab)
    {
        case 0: DrawGeneralTab(); break;
        case 1: DrawAdvancedTab(); break;
        case 2: DrawDebugTab(); break;
    }
}
```

### Progress Bar

```csharp
// Simple progress bar
EditorGUI.ProgressBar(rect, progress, $"{progress * 100:F0}%");

// Progress bar in inspector
public override void OnInspectorGUI()
{
    var healthProp = serializedObject.FindProperty("health");
    var maxHealthProp = serializedObject.FindProperty("maxHealth");

    float ratio = healthProp.floatValue / maxHealthProp.floatValue;

    Rect rect = GUILayoutUtility.GetRect(18, 18, "TextField");
    EditorGUI.ProgressBar(rect, ratio, $"Health: {healthProp.floatValue}/{maxHealthProp.floatValue}");
}
```

### Drag and Drop

```csharp
private void OnGUI()
{
    var dropArea = GUILayoutUtility.GetRect(100, 100);
    GUI.Box(dropArea, "Drop Asset Here");

    Event evt = Event.current;

    switch (evt.type)
    {
        case EventType.DragUpdated:
        case EventType.DragPerform:
            if (!dropArea.Contains(evt.mousePosition))
                break;

            DragAndDrop.visualMode = DragAndDropVisualMode.Copy;

            if (evt.type == EventType.DragPerform)
            {
                DragAndDrop.AcceptDrag();

                foreach (var obj in DragAndDrop.objectReferences)
                {
                    Debug.Log($"Dropped: {obj.name}");
                }
            }
            break;
    }
}
```

---

## Undo Support

### Recording Changes

```csharp
// Single object
Undo.RecordObject(target, "Change Value");
myComponent.value = newValue;

// Multiple objects
Undo.RecordObjects(targets, "Change Values");
foreach (var t in targets)
{
    ((MyComponent)t).value = newValue;
}

// Create object with undo
var newObj = new GameObject("New Object");
Undo.RegisterCreatedObjectUndo(newObj, "Create Object");

// Destroy with undo
Undo.DestroyObjectImmediate(obj);
```

### Property Change Callback

```csharp
private void OnEnable()
{
    Undo.undoRedoPerformed += OnUndoRedo;
}

private void OnDisable()
{
    Undo.undoRedoPerformed -= OnUndoRedo;
}

private void OnUndoRedo()
{
    Repaint();
}
```

---

## EditorPrefs (Persistent Settings)

```csharp
public class MyToolWindow : EditorWindow
{
    private const string PREF_KEY = "MyTool_";

    private bool showAdvanced;
    private int selectedMode;

    private void OnEnable()
    {
        // Load settings
        showAdvanced = EditorPrefs.GetBool(PREF_KEY + "ShowAdvanced", false);
        selectedMode = EditorPrefs.GetInt(PREF_KEY + "SelectedMode", 0);
    }

    private void OnDisable()
    {
        // Save settings
        EditorPrefs.SetBool(PREF_KEY + "ShowAdvanced", showAdvanced);
        EditorPrefs.SetInt(PREF_KEY + "SelectedMode", selectedMode);
    }
}
```

---

## Message Types

```csharp
// Help boxes
EditorGUILayout.HelpBox("Info message", MessageType.Info);
EditorGUILayout.HelpBox("Warning message", MessageType.Warning);
EditorGUILayout.HelpBox("Error message", MessageType.Error);
EditorGUILayout.HelpBox("No icon message", MessageType.None);

// Dialog boxes
if (EditorUtility.DisplayDialog("Confirm", "Are you sure?", "Yes", "No"))
{
    // User clicked Yes
}

// Progress dialog
EditorUtility.DisplayProgressBar("Processing", "Please wait...", 0.5f);
// ... do work ...
EditorUtility.ClearProgressBar();
```

---

## Best Practices

### 1. Always Use SerializedProperty

```csharp
// Good - supports undo, multi-edit, prefab overrides
serializedObject.Update();
EditorGUILayout.PropertyField(serializedObject.FindProperty("myField"));
serializedObject.ApplyModifiedProperties();

// Bad - loses undo support
((MyComponent)target).myField = EditorGUILayout.FloatField(((MyComponent)target).myField);
```

### 2. Cache SerializedProperty References

```csharp
private SerializedProperty myProp;

private void OnEnable()
{
    myProp = serializedObject.FindProperty("myField");
}

public override void OnInspectorGUI()
{
    serializedObject.Update();
    EditorGUILayout.PropertyField(myProp); // Use cached reference
    serializedObject.ApplyModifiedProperties();
}
```

### 3. Support Multi-Object Editing

```csharp
[CustomEditor(typeof(MyComponent))]
[CanEditMultipleObjects]  // Enable multi-select editing
public class MyComponentEditor : Editor
{
    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        // This automatically handles multiple selection
        EditorGUILayout.PropertyField(serializedObject.FindProperty("value"));

        // For custom buttons, iterate targets
        if (GUILayout.Button("Reset All"))
        {
            foreach (var t in targets)
            {
                Undo.RecordObject(t, "Reset");
                ((MyComponent)t).Reset();
            }
        }

        serializedObject.ApplyModifiedProperties();
    }
}
```

### 4. Repaint on Changes

```csharp
private void OnGUI()
{
    EditorGUI.BeginChangeCheck();

    // ... draw controls ...

    if (EditorGUI.EndChangeCheck())
    {
        Repaint();  // Force immediate redraw
    }
}
```

---

## Common Mistakes

### 1. Forgetting serializedObject.Update/ApplyModifiedProperties

```csharp
// Wrong - changes won't be saved
public override void OnInspectorGUI()
{
    EditorGUILayout.PropertyField(serializedObject.FindProperty("value"));
}

// Correct
public override void OnInspectorGUI()
{
    serializedObject.Update();
    EditorGUILayout.PropertyField(serializedObject.FindProperty("value"));
    serializedObject.ApplyModifiedProperties();
}
```

### 2. Using IMGUI for Game UI

```csharp
// Wrong - OnGUI is for editor only
public class GameHUD : MonoBehaviour
{
    void OnGUI()
    {
        GUI.Label(new Rect(10, 10, 100, 20), "Health: 100");
    }
}

// Correct - use uGUI or UI Toolkit for game UI
```

### 3. Not Caching GUIStyle

```csharp
// Wrong - creates new style every frame
void OnGUI()
{
    var style = new GUIStyle(EditorStyles.boldLabel);
    style.fontSize = 14;
    GUILayout.Label("Title", style);
}

// Correct - cache and reuse
private GUIStyle titleStyle;

void OnGUI()
{
    titleStyle ??= new GUIStyle(EditorStyles.boldLabel) { fontSize = 14 };
    GUILayout.Label("Title", titleStyle);
}
```

---

## Tool Selection Guide

| Task | Recommended Approach |
|------|---------------------|
| Custom inspector | `[CustomEditor]` + `Editor` class |
| Reusable field UI | `[CustomPropertyDrawer]` + `PropertyDrawer` class |
| Standalone tool | `EditorWindow` subclass |
| Scene visualization | `OnSceneGUI` + `Handles` |
| Menu command | `[MenuItem]` attribute |
| Context menu | `[ContextMenu]` / `[ContextMenuItemAttribute]` |
| Project settings | `SettingsProvider` |

---

## Reference

### Useful Classes

- `EditorGUILayout` - Layout-based editor controls
- `EditorGUI` - Position-based editor controls
- `GUILayout` - Layout-based basic controls
- `GUI` - Position-based basic controls
- `Handles` - Scene view 3D handles
- `EditorStyles` - Built-in editor styles
- `EditorGUIUtility` - Editor utilities
- `AssetDatabase` - Asset operations
- `SerializedObject` / `SerializedProperty` - Serialization access

### MenuItem Shortcuts

```csharp
[MenuItem("Tools/My Tool %#t")]     // Ctrl+Shift+T
[MenuItem("Tools/My Tool %&t")]     // Ctrl+Alt+T
[MenuItem("Tools/My Tool #t")]      // Shift+T
[MenuItem("Tools/My Tool _t")]      // T only
[MenuItem("Tools/My Tool %LEFT")]   // Ctrl+Left Arrow
```
