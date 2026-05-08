---
name: Blender 3D
description: Control Blender for 3D modeling, scene creation, and rendering operations via MCP with PolyHaven, Sketchfab, Hyper3D Rodin, and Hunyuan3D integrations
---

# Blender 3D Skill

This skill enables Claude to interact with Blender for 3D modeling, scene manipulation, material application, and rendering operations through the BlenderMCP addon (ahujasid/blender-mcp - 14k+ stars).

## Features

### Core Capabilities

- **Two-way communication**: Connect Claude AI to Blender through socket server
- **Object manipulation**: Create, modify, and delete 3D objects
- **Material control**: Apply and modify PBR materials and colors
- **Scene inspection**: Get detailed information about the current scene
- **Code execution**: Run arbitrary Python code in Blender
- **Viewport screenshots**: Capture visual feedback from Blender

### Asset Integrations

- **PolyHaven**: Download HDRIs, textures, and 3D models
- **Sketchfab**: Search and import models from the Sketchfab library
- **Hyper3D Rodin**: Generate 3D models from text/images using AI
- **Hunyuan3D**: Alternative AI 3D generation from Tencent

## Prerequisites

- Blender 3.0+ (recommended 4.0+)
- BlenderMCP addon installed and active
- Socket server running on port 9876 (default)

## Docker Installation (Auto-configured)

The addon is automatically installed when building with `Dockerfile.unified`:

- Addon installed to `~/.config/blender/{4.0,4.1,4.2}/scripts/addons/`
- Auto-enabled via startup script
- MCP server available via `uvx blender-mcp`

## Manual Installation

### Method 1: Install via Blender UI

1. Download `addon/blender_mcp_addon.py` from this skill directory
2. Open Blender → Edit → Preferences → Add-ons
3. Click "Install..." and select the addon file
4. Enable "Blender MCP" in the addon list
5. Find the BlenderMCP panel in 3D View sidebar (press N)
6. Click "Start Server" to begin listening on port 9876

### Method 2: Copy to Addons Folder

```bash
# Linux
cp addon/blender_mcp_addon.py ~/.config/blender/4.0/scripts/addons/

# macOS
cp addon/blender_mcp_addon.py ~/Library/Application\ Support/Blender/4.0/scripts/addons/

# Windows
copy addon\blender_mcp_addon.py %APPDATA%\Blender Foundation\Blender\4.0\scripts\addons\
```

### Method 3: Using the installer script

```bash
python3 addon/install-addon.py --blender-version 4.0
```

### Verify Connection

```bash
# Test that Blender is listening
nc -zv localhost 9876

# Or send a test command
echo '{"type":"get_scene_info","params":{}}' | nc localhost 9876
```

## MCP Server Setup

### Via uvx (recommended)

```bash
uvx blender-mcp
```

### Via Python module

```bash
python3 -m blender_mcp.server
```

### Claude Desktop Configuration

Add to `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "blender": {
      "command": "uvx",
      "args": ["blender-mcp"]
    }
  }
}
```

## Connection Details

- **Host**: localhost (configurable via BLENDER_HOST env var)
- **Port**: 9876 (configurable via BLENDER_PORT env var)
- **Protocol**: TCP with JSON messages
- **Timeout**: 180 seconds for long operations

## Tool Functions

### Scene & Object Management

#### `get_scene_info`

Get detailed information about the current Blender scene.

#### `get_object_info`

Get detailed information about a specific object.

- `object_name` (required): Name of the object

#### `execute_code`

Execute arbitrary Python code in Blender.

- `code` (required): Python code to execute
- **Note**: The command is `execute_code`, NOT `execute_blender_code`

#### `get_viewport_screenshot`

Capture a screenshot of the current 3D viewport.

- `max_size` (optional): Maximum size in pixels (default: 800)

### PolyHaven Integration

#### `get_polyhaven_status`

Check if PolyHaven integration is enabled.

#### `get_polyhaven_categories`

Get available asset categories.

- `asset_type`: "hdris" | "textures" | "models" | "all"

#### `search_polyhaven_assets`

Search for PolyHaven assets.

- `asset_type`: Type of assets to search
- `categories`: Optional comma-separated category filter

#### `download_polyhaven_asset`

Download and import a PolyHaven asset.

- `asset_id` (required): Asset identifier
- `asset_type` (required): "hdris" | "textures" | "models"
- `resolution` (optional): "1k" | "2k" | "4k" (default: "1k")
- `file_format` (optional): File format preference

#### `set_texture`

Apply a downloaded texture to an object.

- `object_name` (required): Target object
- `texture_id` (required): PolyHaven texture ID

### Sketchfab Integration

#### `get_sketchfab_status`

Check if Sketchfab integration is enabled.

#### `search_sketchfab_models`

Search Sketchfab for 3D models.

- `query` (required): Search text
- `categories` (optional): Category filter
- `count` (optional): Max results (default: 20)
- `downloadable` (optional): Only downloadable models (default: true)

#### `download_sketchfab_model`

Download and import a Sketchfab model.

- `uid` (required): Sketchfab model UID

### Hyper3D Rodin Integration

#### `get_hyper3d_status`

Check if Hyper3D Rodin is enabled.

#### `generate_hyper3d_model_via_text`

Generate 3D model from text description.

- `text_prompt` (required): Description in English
- `bbox_condition` (optional): [Length, Width, Height] ratio

#### `generate_hyper3d_model_via_images`

Generate 3D model from reference images.

- `input_image_paths` (optional): List of image file paths
- `input_image_urls` (optional): List of image URLs
- `bbox_condition` (optional): Size ratio

#### `poll_rodin_job_status`

Check generation task status.

- `subscription_key`: For MAIN_SITE mode
- `request_id`: For FAL_AI mode

#### `import_generated_asset`

Import completed Hyper3D model.

- `name` (required): Object name in scene
- `task_uuid`: For MAIN_SITE mode
- `request_id`: For FAL_AI mode

### Hunyuan3D Integration

#### `get_hunyuan3d_status`

Check if Hunyuan3D is enabled.

#### `generate_hunyuan3d_model`

Generate 3D model using Hunyuan3D.

- `text_prompt` (optional): Text description
- `input_image_url` (optional): Reference image URL

#### `poll_hunyuan_job_status`

Check Hunyuan3D task status.

- `job_id` (required): Job identifier

#### `import_generated_asset_hunyuan`

Import completed Hunyuan3D model.

- `name` (required): Object name
- `zip_file_url` (required): Generated model URL

## Examples

### Example 1: Create Scene with PolyHaven Assets

```text
Use the Blender skill to:
1. Check PolyHaven status
2. Download an HDRI for environment lighting
3. Download a wood texture
4. Create a cube and apply the wood texture
5. Render the scene
```

### Example 2: Import Sketchfab Model

```text
Search Sketchfab for "vintage car" and import the first downloadable result.
Scale it to fit the scene and position at origin.
```

### Example 3: Generate AI Model with Hyper3D

```text
Generate a 3D model of "a small wooden treasure chest with gold trim"
using Hyper3D Rodin. Import it and add environment lighting.
```

### Example 4: Custom Python Scripting

```python
# Create a grid of cubes with random colors
import bpy
import random

for x in range(-5, 6):
    for y in range(-5, 6):
        bpy.ops.mesh.primitive_cube_add(location=(x*2, y*2, 0))
        obj = bpy.context.active_object
        mat = bpy.data.materials.new(name=f"Mat_{x}_{y}")
        mat.diffuse_color = (random.random(), random.random(), random.random(), 1)
        obj.data.materials.append(mat)
```

## Standalone Server (Headless/Background)

For automated pipelines, use the standalone server instead of the UI addon:

```bash
# Start with VNC display (keeps Blender window open)
DISPLAY=:1 blender --python scripts/standalone_server.py

# Or with direct Python call
python3 -c "
import socket
import json

s = socket.socket()
s.connect(('localhost', 9876))

# Import a GLB mesh
request = json.dumps({
    'type': 'import_model',
    'params': {'filepath': '/path/to/mesh.glb', 'name': 'MyModel'}
})
s.sendall(request.encode())
print(s.recv(4096).decode())
s.close()
"
```

### Standalone Server Commands

| Command                | Description                        |
| ---------------------- | ---------------------------------- |
| `get_scene_info`       | Get scene details and object list  |
| `get_object_info`      | Get specific object properties     |
| `execute_blender_code` | Run arbitrary Python code          |
| `import_model`         | Import GLB/OBJ/FBX/STL/PLY files   |
| `render`               | Render to image file               |
| `orbit_render`         | Render from multiple orbit angles  |
| `set_camera`           | Position camera at location/target |
| `add_hdri`             | Add HDRI environment lighting      |

## Integration with Other Skills

Works well with:

- `comfyui` skill for text-to-3D model generation and validation
- `filesystem` skill for managing output files
- `imagemagick` skill for post-processing renders

### ComfyUI 3D Integration (FLUX2 → SAM3D → Blender)

The Blender skill is the final validation step in the ComfyUI text-to-3D pipeline:

1. **FLUX2 generates** reference image (Phase 1, ~41GB VRAM)
2. **Free GPU memory** via ComfyUI `/free` endpoint
3. **SAM3D reconstructs** mesh.glb from image (Phase 2, ~23GB VRAM)
4. **Blender imports** the mesh via MCP socket
5. **Validation renders** from multiple orbit camera angles
6. **Quality feedback** determines if retry needed with improved prompt

### GPU Memory Management

**Critical**: FLUX2 and SAM3D cannot run concurrently on most GPUs. Use split workflow:

```bash
# After FLUX2 generation, free GPU memory before SAM3D
curl -X POST http://comfyui:8188/free \
  -H "Content-Type: application/json" \
  -d '{"unload_models": true, "free_memory": true}'
```

### Example End-to-End Workflow

```python
import requests
import json
import socket
import time

COMFYUI_URL = "http://192.168.0.51:8188"

# Phase 1: FLUX2 Image Generation
flux2_workflow = {
    "86": {"inputs": {"unet_name": "flux2_dev_fp8mixed.safetensors"}, "class_type": "UNETLoader"},
    # ... rest of FLUX2 workflow
}
response = requests.post(f"{COMFYUI_URL}/prompt", json={"prompt": flux2_workflow})
prompt_id = response.json()["prompt_id"]

# Wait for completion
while True:
    history = requests.get(f"{COMFYUI_URL}/history/{prompt_id}").json()
    if history.get(prompt_id, {}).get("status", {}).get("completed"):
        break
    time.sleep(5)

# Free GPU memory
requests.post(f"{COMFYUI_URL}/free", json={"unload_models": True, "free_memory": True})

# Phase 2: SAM3D Reconstruction
sam3d_workflow = {
    "44": {"inputs": {"model_tag": "hf"}, "class_type": "LoadSAM3DModel"},
    # ... rest of SAM3D workflow
}
response = requests.post(f"{COMFYUI_URL}/prompt", json={"prompt": sam3d_workflow})

# Phase 3: Blender Import and Validation
s = socket.socket()
s.connect(('localhost', 9876))
s.sendall(json.dumps({
    "type": "import_model",
    "params": {"filepath": "/path/to/mesh.glb", "name": "GeneratedModel"}
}).encode())
print(s.recv(4096).decode())

# Orbit render for validation - render to ComfyUI output for visibility
s.sendall(json.dumps({
    "type": "orbit_render",
    "params": {
        "output_dir": "/root/ComfyUI/output/validation",  # ComfyUI output
        "prefix": "blender_validation",
        "angles": [0, 45, 90, 135, 180, 225, 270, 315],
        "elevation": 30,
        "resolution": 512
    }
}).encode())
print(s.recv(4096).decode())
s.close()
```

### Copying Renders to ComfyUI Output

For visibility in the ComfyUI web interface, render directly to the ComfyUI output directory:

```python
# If BlenderMCP is inside Docker with shared volumes:
output_dir = "/root/ComfyUI/output/validation"

# If Blender is on host, copy after rendering:
import shutil
import subprocess

# Copy from local to ComfyUI container
subprocess.run([
    "docker", "cp",
    "/tmp/validation/.",
    "comfyui:/root/ComfyUI/output/validation/"
])
```

Or use docker exec to copy within the container network:

```bash
# Copy renders to ComfyUI output (from host)
docker cp /tmp/validation/. comfyui:/root/ComfyUI/output/validation/

# Or if both are containers in same network:
docker exec comfyui mkdir -p /root/ComfyUI/output/validation
docker cp blender:/tmp/renders/. comfyui:/root/ComfyUI/output/validation/
```

## Performance Notes

- Object creation: < 100ms
- Material application: < 50ms
- Asset downloads: varies by size (seconds to minutes)
- AI generation (Hyper3D/Hunyuan): 30s - 5min depending on complexity
- Render operations: varies by complexity

## Error Handling

The skill handles:

- Blender not running (connection refused)
- Invalid object names (suggests alternatives)
- Script execution errors (returns Python traceback)
- Render failures (provides diagnostic info)
- API rate limits (PolyHaven, Sketchfab)
- AI generation failures (timeout, quota)

## Advanced: Asset Strategy

Recommended priority for creating 3D content:

1. **Specific existing objects**: Sketchfab → PolyHaven
2. **Generic objects/furniture**: PolyHaven → Sketchfab
3. **Custom/unique items**: Hyper3D Rodin → Hunyuan3D
4. **Environment lighting**: PolyHaven HDRIs
5. **Materials/textures**: PolyHaven textures
6. **Fallback**: Python scripting for primitives

## Troubleshooting

### Connection Issues

```bash
# Check if Blender addon server is running
nc -zv localhost 9876

# Restart Blender and enable addon
# Look for BlenderMCP panel in sidebar (press N)
```

### API Key Configuration

For Sketchfab and Hyper3D features, configure API keys in the BlenderMCP addon panel within Blender.

### Display Issues

Ensure VNC is connected for visual feedback:

```bash
# Check VNC status
vncserver -list
```
