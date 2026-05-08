---
name: isaac-patterns
description: NVIDIA Isaac Sim and Isaac ROS integration patterns for Physical AI applications.
---

## Isaac Sim USD Scene Structure

### Asset Organization (Universal Scene Description)
```
/World
├── /Environment
│   ├── /Ground_Plane (physics material: friction 0.8)
│   ├── /Obstacles (procedurally generated for domain randomization)
│   └── /Lighting
│       ├── /DomeLight (HDRI environment map)
│       └── /DistantLight (sun simulation)
├── /Robot
│   ├── /Humanoid (USD reference to robot asset)
│   ├── /Sensors
│   │   ├── /Camera_RGB (1920x1080, 60 FPS)
│   │   ├── /Camera_Depth (640x480, 30 FPS)
│   │   └── /Lidar (360°, 0.1° resolution)
│   └── /ActionGraph (OmniGraph for ROS 2 bridge)
└── /PhysicsScene (gravity: -9.81 m/s², time step: 1/60s)
```

## Isaac ROS VSLAM Pipeline

### Hardware-Accelerated Workflow
```
RealSense D435i → isaac_ros_visual_slam → nav2_map_server → nav2_planner → cmd_vel
                     ↓ (CUDA accelerated)
                  Pose Estimation (30-60 FPS on Jetson Orin)
```

### Key Isaac ROS Nodes
- **visual_slam**: `isaac_ros_visual_slam` (NOT ORB-SLAM2, NOT RTAB-Map)
- **stereo_matching**: `isaac_ros_ess` (Enhanced Semi-Global Matching, GPU-based)
- **object_detection**: `isaac_ros_dnn_inference` (TensorRT optimized)

### Performance Expectations (Jetson Orin Nano)
- VSLAM: 30-60 FPS (vs 5-10 FPS on CPU-based SLAM)
- Object Detection: 30 FPS (YOLOv5 with TensorRT)
- Depth Estimation: 30 FPS (ESS model)

## Isaac Sim Python API Patterns

### Create Scene Programmatically
```python
import omni.isaac.core.utils.stage as stage_utils
from omni.isaac.core.objects import DynamicCuboid

# Add ground plane
stage_utils.add_ground_plane()

# Spawn robot
robot_prim_path = "/World/Robot"
stage_utils.add_reference_to_stage(
    usd_path="omniverse://localhost/NVIDIA/Assets/Isaac/2023.1.1/Unitree/unitree_g1.usd",
    prim_path=robot_prim_path
)

# Add camera sensor
from omni.isaac.sensor import Camera
camera = Camera(prim_path=f"{robot_prim_path}/camera", position=[0, 0, 1.5])
camera.initialize()
```

### Domain Randomization for Sim-to-Real
```python
from omni.isaac.core.utils.stage import randomize_shader_properties

# Randomize material properties every episode
randomize_shader_properties(
    prim_path="/World/Environment",
    parameters=["inputs:roughness", "inputs:metallic"],
    ranges=[(0.1, 0.9), (0.0, 1.0)]
)
```

## RTX VRAM Allocation (Isaac Sim 4.x)
- Base Sim: 4-6 GB
- Robot Asset (Humanoid): 1-2 GB
- Ray Tracing: 3-4 GB
- Physics: 2-3 GB
- **Total**: 10-15 GB → **12GB minimum, 24GB recommended**
