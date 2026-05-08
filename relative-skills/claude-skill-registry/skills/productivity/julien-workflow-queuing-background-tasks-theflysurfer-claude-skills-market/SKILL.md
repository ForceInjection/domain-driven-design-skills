---
name: julien-workflow-queuing-background-tasks
description: Queue long-running tasks (transcoding, API calls, batch processing) to run in background at low priority when user is active, normal priority when idle. Use when scripts take minutes/hours and shouldn't impact PC performance during active use.
triggers:
  # Core concepts
  - queue task
  - background job
  - idle queue
  - low priority task
  - run when idle
  - qm add
  - idle-queue
  - schedule this task
  - planifier cette tâche
  - deferred job
  # Transcoding/conversion scenarios
  - transcode video
  - transcoder vidéo
  - convert video background
  - ffmpeg background
  - ffmpeg en arrière-plan
  - conversion longue
  - long conversion
  - render video
  - faire le rendu
  - render vidéo en tâche de fond
  - encode footage
  - run blender render
  - convert mkv
  # Long-running scripts
  - script takes long
  - script prend du temps
  - long running script
  - slow script
  - script lent
  - batch processing
  - traitement par lot
  - this is taking forever
  - ça prend une éternité
  - queue heavy python script
  # Performance concerns
  - without blocking
  - sans bloquer
  - don't block PC
  - ne pas bloquer le PC
  - keep PC responsive
  - garder le PC réactif
  - run without impact
  - low priority execution
  - don't slow down my machine
  - ne ralentis pas ma machine
  - keep my system responsive
  - resource-intensive task
  - tâche gourmande en ressources
  - heavy computation
  - calcul lourd
  # Background execution intent
  - run in background
  - exécuter en arrière-plan
  - lancer en arrière-plan
  - background execution
  - execute when idle
  - exécuter quand inactif
  - run this when I'm away
  - exécute quand je ne suis pas là
  - process when computer is idle
  - do this asynchronously
  - faisons cela de manière asynchrone
  # Common use cases
  - bulk API calls
  - mass translation
  - batch encode
  - multiple file conversion
  - heavy task
  - tâche lourde
  - compress files when idle
  - traiter photos RAW
  - background ML training
  - train machine learning model
  - batch OCR
  - large file processing
  - traitement de gros fichiers
  - process data overnight
  - large data export
  - exportation volumineuse
  - scrape website background
  - pipeline data nightly
  - run backup background
  - compile in background
  - keep working while this runs
  - continuer à travailler pendant que ça tourne
  - encoder des vidéos
  - encode videos
---

# Idle Queue - Background Task Manager

Queue manager that runs jobs at low priority when user is active, and normal priority when idle (5min inactivity).

## Prerequisites

- Python 3.10+
- Service must be running before adding jobs
- Windows only (uses Windows API for idle detection)

## Quick Start

> **Verified behavior**: When user is active, jobs run at **IDLE priority (4)** - your PC stays responsive.
> After 5 minutes idle, priority increases for faster execution. Only 1 job runs when active.

```bash
# 1. Start the service (keep this terminal open)
qm start --foreground

# 2. In another terminal, add a job
qm add "python my_script.py" --name "My Task"

# 3. Monitor
qm list
qm logs 1
```

## Service Startup

### Manual start
```bash
qm start                   # Background (daemon)
qm start --foreground      # With dashboard at http://127.0.0.1:8742
```

### Auto-start at login (Windows)
```bash
# Create shortcut in startup folder
# Target: pythonw -m idle_queue.cli start
# Or add to Task Scheduler
```

### Check if service is running
```bash
qm status                  # Shows service status
curl http://127.0.0.1:8742/api/status  # API check
```

## When to Use

- Scripts taking > 30 seconds
- Batch processing (transcoding, conversions)
- API-heavy operations (translations, LLM calls)
- Any task that shouldn't block user work

## CLI Commands

All commands via `python -m idle_queue.cli` or `qm` (if installed):

```bash
# Add a job to queue
qm add "python script.py" --name "My Task"
qm add "ffmpeg -i in.mp4 out.webm" --name "Transcode" --cwd "C:/videos"
qm add "node build.js" --force  # Run even when user active

# List jobs
qm list                    # All jobs
qm list --status pending   # Filter by status

# Job details
qm status <id>             # Full job info
qm logs <id>               # View stdout/stderr
qm logs <id> --follow      # Stream logs live

# Job management
qm cancel <id>             # Cancel pending/running job
qm retry <id>              # Retry failed job
qm force <id>              # Force pending job to run now

# Service control
qm start                   # Start as background service
qm start --foreground      # Start with dashboard
qm stop                    # Stop service

# Configuration
qm config show             # Show current config
qm config set workers.max_when_idle 4
```

## REST API

Base URL: `http://127.0.0.1:8742/api/`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/status` | Service status (running, activity_state, job counts) |
| GET | `/jobs` | List all jobs |
| POST | `/jobs` | Create job `{command, name?, cwd?, force?}` |
| GET | `/jobs/{id}` | Job details |
| DELETE | `/jobs/{id}` | Cancel job |
| POST | `/jobs/{id}/retry` | Retry failed job |
| POST | `/jobs/{id}/force` | Force pending job |
| GET | `/jobs/{id}/logs` | Get job logs |
| GET | `/jobs/{id}/logs/stream` | SSE log stream |

## Job Statuses

- `pending` - Waiting in queue
- `running` - Currently executing
- `completed` - Finished successfully (exit_code=0)
- `failed` - Finished with error (exit_code!=0)
- `cancelled` - Manually cancelled

## Usage Patterns

### Queue a Python script
```bash
qm add "python process_data.py --input data.csv" --name "Process CSV"
```

### Queue with working directory
```bash
qm add "npm run build" --name "Build Project" --cwd "C:/projects/myapp"
```

### Force immediate execution
```bash
qm add "python urgent.py" --name "Urgent Task" --force
```

### Check job and get logs
```bash
qm status 42
qm logs 42
```

### API usage from Python
```python
import requests

# Add job
r = requests.post("http://127.0.0.1:8742/api/jobs", json={
    "command": "python long_task.py",
    "name": "Background Task"
})
job_id = r.json()["id"]

# Check status
status = requests.get(f"http://127.0.0.1:8742/api/jobs/{job_id}").json()
print(status["status"])  # pending, running, completed, failed
```

## Important Notes

1. **Service must be running** - Start with `qm start` before adding jobs
2. **Dashboard** available at `http://127.0.0.1:8742/` when service runs
3. **Logs stored** in `%APPDATA%\idle-queue\logs\`
4. **Config file** at `%APPDATA%\idle-queue\config.yaml`
5. **Duplicate detection** - Same command+cwd rejected unless `--force-duplicate`

## Priority Behavior (Verified)

| User State | Max Workers | CPU Priority | I/O Priority |
|------------|-------------|--------------|--------------|
| Active | 1 | IDLE (4) | VERY_LOW |
| Idle (5min) | Unlimited | BELOW_NORMAL | NORMAL |

**Tested**: Process shows Priority: 4 (IDLE_PRIORITY_CLASS) when user is active.

## Troubleshooting

### Special characters in paths (IMPORTANT)

**Problem**: Shell escaping issues with special characters in file paths.

| Character | Issue | CLI workaround |
|-----------|-------|----------------|
| `!` | Escaped to `\!` | Use API or `--cwd` |
| `'` (single quote) | Breaks quoting | Use double quotes, escape with `'\''` |
| `"` (double quote) | Needs escaping | Use `\"` inside double-quoted strings |
| ` ` (space) | Needs quoting | Always quote paths with spaces |
| `&` | Shell interprets as background | Quote the entire command |
| `()` | Shell interprets as subshell | Quote or escape |
| `$` | Variable expansion | Use single quotes or escape `\$` |
| Accents (é, ü) | Encoding issues | Ensure UTF-8, use API |

**Recommended approach by complexity:**

```bash
# SIMPLE - paths without special characters
qm add "ffmpeg -i input.mp4 output.mp4"

# MEDIUM - use --cwd to avoid path issues
qm add "ffmpeg -i input.mp4 output.mp4" --cwd "C:/Movies/My Folder"

# COMPLEX - use API for any special characters
python -c "
import requests
requests.post('http://127.0.0.1:8742/api/jobs', json={
    'command': 'ffmpeg -i \"C:/Movies/What\\'s Up!.mp4\" out.mp4',
    'name': 'Transcode'
})
"
```

**Why API is safest**: The API receives JSON directly without shell parsing, so special characters are preserved exactly as-is.

### Service won't start
```bash
# Check if port is already in use
netstat -ano | findstr 8742

# Kill process using port
taskkill /F /PID <pid>

# Retry
qm start --foreground
```

### Job stuck in "pending"
- Service not running → `qm start`
- User is active + job not forced → wait for idle or `qm force <id>`

### Job fails immediately
```bash
# Check logs for error
qm logs <id>

# Common causes:
# - Command not found → check PATH or use full path
# - Working directory doesn't exist → verify --cwd path
# - Permission denied → run as admin if needed
```

### Can't connect to API/Dashboard
- Service not running → `qm start`
- Wrong port → check `qm config show` for api.port
- Firewall blocking → allow port 8742

### Logs not appearing
- Job hasn't started yet (pending)
- Log directory permissions → check `%APPDATA%\idle-queue\logs\`

## Skill Chaining

### Skills Required Before
- None

### Input Expected
- Long-running command to execute
- Optional: name, working directory, force flag

### Output Produced
- **Format**: Job ID and status
- **Side effects**: Creates job in queue, executes when appropriate
- **Logs**: Stored in %APPDATA%\idle-queue\logs/

### Compatible Skills After
- Any skill that needs to wait for background processing

### Tools Used
- `Bash` (usage: run qm commands)
- `WebFetch` (usage: API calls if needed)

### Usage Example

**Scenario**: User asks to transcode videos

**Command**:
```bash
qm add "ffmpeg -i input.mp4 -c:v libx265 output.mp4" --name "Transcode to H265"
```

**Result**: Job queued, runs at low priority, notifications on completion
