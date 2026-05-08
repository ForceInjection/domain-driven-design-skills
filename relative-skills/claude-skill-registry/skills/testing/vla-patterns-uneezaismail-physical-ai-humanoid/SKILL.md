---
name: vla-patterns
description: Vision-Language-Action model integration patterns for cognitive robotics with ROS 2.
---

## VLA Architecture

### Voice-to-Action Pipeline
```
Microphone → Whisper (STT) → LLM (Planner) → ROS 2 Action Client → Robot Execution
     ↓              ↓                ↓                    ↓
  Audio Stream   Text Command    Action Sequence    Joint Commands
```

## LLM Prompt Template for Robot Planning

### System Prompt (Cognitive Planner)
```python
SYSTEM_PROMPT = """
You are a robot control planner. Given a natural language command, generate a sequence of ROS 2 actions.

Available Actions:
- navigate_to(x: float, y: float, theta: float) - Move to pose (x, y, theta in radians)
- grasp_object(object_id: str) - Pick up identified object
- release_object() - Drop held object
- rotate_base(angle: float) - Rotate in place (radians)
- speak(text: str) - Text-to-speech output

Object Database: {object_list}

Output Format (JSON only):
{{
  "plan": [
    {{"action": "navigate_to", "params": {{"x": 1.0, "y": 2.0, "theta": 0.0}}}},
    {{"action": "grasp_object", "params": {{"object_id": "cup_01"}}}}
  ]
}}

Rules:
1. Navigate before grasping (robot must be close)
2. Check if object exists in database
3. Handle failures (if grasp fails, retry once then report)
"""
```

### User Command Examples
```
"Pick up the red cup" →
  [navigate_to(cup_pose), grasp_object("cup_red_01")]

"Clean the room" →
  [navigate_to(trash_01), grasp_object("trash_01"), navigate_to(bin), release_object(), ...]
```

## Multi-Modal Fusion (Vision + Language)

### Object Detection + Deictic Reference
```python
# User says: "Pick up that cup" (while pointing)
# System must fuse:
# 1. Vision: YOLO detects 3 cups at [(x1,y1), (x2,y2), (x3,y3)]
# 2. Gesture: Hand pointing direction vector [dx, dy]
# 3. Language: "that cup" (deictic reference)

# Fusion Logic:
def resolve_deictic_reference(detected_objects, pointing_vector, utterance):
    # Find object closest to pointing ray
    candidates = [obj for obj in detected_objects if obj.label == "cup"]
    target = min(candidates, key=lambda obj: angle_between(pointing_vector, obj.position))
    return target.id
```

## ROS 2 Integration Pattern

### VLA Node Structure
```python
class VLANode(Node):
    def __init__(self):
        super().__init__('vla_node')

        # Subscribers
        self.audio_sub = self.create_subscription(Audio, '/audio', self.audio_callback, 10)
        self.camera_sub = self.create_subscription(Image, '/camera/rgb', self.vision_callback, 10)

        # Action Clients
        self.nav_client = ActionClient(self, NavigateToPose, 'navigate_to_pose')
        self.grasp_client = ActionClient(self, Grasp, 'grasp_object')

        # LLM API
        self.llm_api = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

    def audio_callback(self, msg: Audio):
        # Whisper STT
        text = whisper.transcribe(msg.data)
        self.get_logger().info(f"Heard: {text}")

        # LLM Planning
        plan = self.llm_plan(text)

        # Execute plan
        for action in plan:
            self.execute_action(action)
```

## Error Handling and Replanning
```python
def execute_with_retry(action, max_retries=2):
    for attempt in range(max_retries):
        result = execute_action(action)
        if result.success:
            return result
        else:
            # Replan with feedback
            feedback = f"Action {action} failed: {result.error}"
            new_plan = llm_replan(original_command, feedback)
            action = new_plan[0]
    return "FAILED_AFTER_RETRIES"
```
