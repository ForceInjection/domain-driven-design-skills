---
name: get-last-frame
description: Extract the last frame of an MP4 file into an image using OpenCV. Use when the user needs the final frame of a generated video saved as a still image.
dependencies:
  - python>=3.11
  - opencv-python (optional)
  - ffmpeg (cli tool)
---

# Get Last Frame

Extract the final decoded frame from an `.mp4` video and save it to an image path.

### Run

```bash
.venv/Scripts/python .claude/skills/get_last_frame/scripts/get_last_frame.py "video.mp4" "last_frame.png"
```

### Example

```bash
.venv/Scripts/python .claude/skills/get_last_frame/scripts/get_last_frame.py "./out/video.mp4" "./out/last_frame.png"
```
