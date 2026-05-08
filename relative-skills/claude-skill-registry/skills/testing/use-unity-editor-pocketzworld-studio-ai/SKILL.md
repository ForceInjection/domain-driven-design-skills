---
name: use-unity-editor
description: Read and edit scenes and prefabs as you would in the Unity editor. You can't do anything in the Unity editor without this skill.
---

# Use Highrise Studio's Unity Editor

Highrise Studio is built on Unity, and uses a variant of the Unity editor to edit scenes and prefabs. This guide covers how you can read and edit scenes and prefabs as a user would in the Unity editor.

## Important information

### Reading the scene

Highrise Studio serializes the active scene to a JSON file for easier understanding. You can find the JSON file at `Temp/Highrise/Serializer/active_scene.json`. The JSON file should be up-to-date with the scene's current state.

The JSON file contains the scene's entire Game Object hierarchy. There will be a single top-level object called "SceneRoot", whose children are the root Game Objects in the scene. The JSON file is structured as follows:
```json
{
  "referenceId": "a GUID that uniquely identifies this Game Object within the scene. Not persistent across editor reloads.",
  "objectProperties": {
    "name": "the name of the game object, as it appears in the hierarchy.",
    "activeSelf": "whether the Game Object is enabled.",
    "tag": "the Game Object's tag.",
    "parentGameObject": "the GUID of the parent Game Object, or null if this is a root Game Object.",
    "prefabPath": "the path to the prefab that this Game Object is an instance of, or null if this is not an instance of a prefab."
  },
  "components": [
    {
      "componentType": "the type of the component (e.g., UnityEngine.Transform)",
      "referenceId": "a GUID that uniquely identifies this component within the scene. Not persistent across editor reloads.",
      "componentProperties": {
        "PROPERTY_NAME (e.g., position)": {
          "propertyName": "the name of the property (e.g., position, rotation, scale, etc.), matching the PROPERTY_NAME key.",
          "type": "the type of the property (e.g., UnityEngine.Vector3, String, etc. If the type is an enum, the full name of the enum will be used, followed by a list of the possible values in parentheses.)",
          "value": "the value of the property."
        }
      }
    }
  ],
  "children": [
    {
      // An object of the same format as the root object; may have children of its own nested within it.
    }
  ]
}
```

Here are some important property value formats:
```json
{
  "type": "UnityEngine.Vector2",
  "value": {"x": 1.0, "y": 2.0}
}
{
  "type": "UnityEngine.Vector3",
  "value": {"x": 1.0, "y": 2.0, "z": 3.0}
}
{
  "type": "UnityEngine.Vector4" | "UnityEngine.Quaternion",
  "value": {"x": 1.0, "y": 2.0, "z": 3.0, "w": 4.0}
}
{
  "type": "GameObject" | "a component type (e.g., Transform), when a property refers to a component",
  "value": "the GUID of the referenced Game Object or Component OR if the field refers to a prefab asset, a path to the prefab asset with the prefix 'prefab:' (e.g., 'prefab:Assets/Prefabs/MyPrefab.prefab')."
}
```

### Reading the prefabs

Highrise Studio serializes all prefabs in the Assets directory to JSON files for easier understanding. You can find the JSON files in `Temp/Highrise/Serializer/`, under the name of the prefab file (e.g., `Assets/Prefabs/MyPrefab.prefab.json`). Each JSON file is structured the same as the active scene file, and the prefabs can be edited using the same editing instructions as the scene. You should make edits to the prefabs using the reference IDs in this file; only use the `prefab:PATH` format as the value of a property that refers to a prefab asset.

### Editing the scene or a prefab

**Do not modify the active_scene.json or .prefab.json file directly; this will not do anything.** Instead, you will submit a queue of changes to be applied to the scene in a file you will create called `Temp/Highrise/Serializer/edit.json`. The file consists of an array of objects. Each object is required to have an `editType` key, which will determine how to interpret the change and what other keys to expect in the object. The following are the possible edit types:
- `delete`: Remove a GameObject or Component from the scene. Requires the following key:
  - `referenceIdToDelete`: The GUID of the GameObject or Component to delete.
- `createGameObject`: Add a new GameObject to the scene. Requires the following keys:
  - `referenceIdOfParentGameObject`: The GUID of the parent Game Object to create the new Game Object under.
  - `nameOfGameObjectToCreate`: The name of the new Game Object.
  - `referenceIdOfGameObjectToCreate`: A GUID that *you* generate that will be assigned to the new Game Object.
  - `prefabPathForGameObjectToCreate`: The (optional) path to a prefab. If provided, the new Game Object will be instantiated from the prefab. If not provided, an empty Game Object will be created.
- `addComponent`: Add a new Component to a Game Object. Requires the following keys:
  - `referenceIdOfGameObjectToAddComponent`: The GUID of the Game Object to add the new Component to.
  - `componentTypeToAdd`: The type of the Component to add (e.g., UnityEngine.Transform), chosen from the list of available component types in `Temp/Highrise/Serializer/all_component_types.json`.
  - `referenceIdOfComponentToAdd`: A GUID that *you* generate that will be assigned to the new Component.
- `setProperty`: Set the value of a property on a GameObject or Component. Requires the following keys:
  - `referenceIdOfObjectWithPropertyToSet`: The GUID of the GameObject or Component to set the property on.
  - `nameOfPropertyToSet`: The name of the property to set (e.g., position, tag, etc.). **This should already exist in the JSON file; do not invent a new property.**
  - `newPropertyValue`: The value of the property to set.
- `saveObjectAsPrefab`: Save a Game Object as a prefab file for future use. Requires the following keys:
  - `referenceIdOfObjectToSaveAsPrefab`: The GUID of the GameObject to save as a prefab.
  - `pathToSavePrefabAs`: The path to save the prefab as. This should be a relative path from the project root and should not already exist.

You can enqueue multiple edits in a single file, but create the file and write all edits to it in a single transaction. The edits will be applied in the order they are enqueued.

#### Adding components to Game Objects

When you want to add a component to a Game Object, you will need to know the full name of the type of the component you want to add. You can find the list of available component types in `Temp/Highrise/Serializer/all_component_types.json`. **You do not know this list in advance; you will need to read the file to find it.** `all_component_types.json` is structured as follows:
```json
[
  {
    "fullName": "the full name of the component type (e.g., UnityEngine.Transform)",
    "properties": {
      "PROPERTY_NAME (e.g., position)": {
        "propertyName": "the name of the property (e.g., position, rotation, scale, etc.), matching the PROPERTY_NAME key.",
        "type": "the type of the property (e.g., UnityEngine.Vector3, String, etc. If the type is an enum, the full name of the enum will be used, followed by a list of the possible values in parentheses.)"
      }
    }
  }
]
```

If you want to create a Game Object or Component and then set properties on it, you can do this using multiple edits in a single `edit.json` file. After the `createGameObject` or `addComponent` edit, you can add the `setProperty` edit for the new object using the reference ID you generated for `referenceIdOfGameObjectToCreate` or `referenceIdOfComponentToAdd`.

#### Adding Lua script components to Game Objects

When you have a built-in or project-specific Lua script that you want to add to a Game Object, you will create a component as normal following the steps above. The only point to keep in mind is that the `componentTypeToAdd` key will be the name of the script with the prefix `Highrise.Lua.Generated` (e.g., `Highrise.Lua.Generated.MyScript`). Properties on these components will generally be prefixed with `m_` (e.g., `m_MyProperty`).

If you just created the Lua script, **do not attempt to add it to a Game Object yet,** as the generated code will not exist yet. Ask the user to switch over to the Unity editor first so that the code can be compiled; then, the component can be added to the Game Object.

#### Adding UI components and making them visible

UI components are added by attaching a Lua script component to a Game Object in the scene, like any other component. The UXML and USS will be pulled in automatically at runtime. To make a UI component visible, you must also set the `_uiOutput` property on the component to either "World" (rendering the UI within the world space), "AboveChat" (rendering the UI above the chat), or "Hud" (above everything, like a heads-up display).

## Instructions

Add the following steps to your todo list:
1. Check that `Temp/Highrise/Serializer/active_scene.json` exists. If it does not, follow these steps:
   a. Check whether the user has the required editor scripts in their project. Look in `Assets/Scripts/Editor` for the `Serializer` folder. If it does not exist or is empty, ask the user for permission to symlink that folder from this plugin's `resources/Serializer` folder.
   b. Ensure that the `Assets/Scripts/Editor/Serializer/` folder is in the project's `.gitignore` file, if one exists, so that the symlinks are not committed to the repository.
   c. If the user has the required editor scripts, ask them to turn on JSON serialization in the Unity toolbar, under Highrise > Studio.
2. Use your tools (`jq`, `grep`, etc.) to read the relevant parts of the JSON file. For example, to list the names of the root Game Objects in the scene, you can use the following command: `jq -r '.SceneRoot.children[].properties.name' Temp/Highrise/Serializer/active_scene.json`. Do not make any changes to the JSON file.
3. If needed, create the `Temp/Highrise/Serializer/edit.json` file and write the edits to it.
4. Inform the user that edits have been submitted and will be applied when they interact with their editor.