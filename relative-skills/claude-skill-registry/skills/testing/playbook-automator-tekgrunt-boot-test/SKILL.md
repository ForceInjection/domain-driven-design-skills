---
name: playbook-automator
description: Use this skill when the user needs help designing, implementing, testing, or troubleshooting automated response playbooks using LimaCharlie's Playbook extension.
---

# LimaCharlie Playbook Automator

This skill helps you design and implement automated response playbooks using LimaCharlie's Playbook extension. Use this when users need assistance creating Python-based automation workflows, integrating with external systems, orchestrating complex responses, or building custom detection logic.

## What are Playbooks?

Playbooks are Python scripts that execute within LimaCharlie's cloud infrastructure to automate security operations tasks. They provide a programmable way to:

- Orchestrate complex multi-step response workflows
- Integrate with external security tools and services
- Implement custom detection and enrichment logic
- Automate investigation procedures
- Perform batch operations across sensors
- Generate custom reports and notifications
- Execute scheduled maintenance tasks

### Key Benefits

1. **Serverless Execution**: Run in LimaCharlie's cloud without managing infrastructure
2. **Full SDK Access**: Complete access to LimaCharlie's Python SDK for all operations
3. **Secure Credential Management**: Store secrets safely in Hive for use in playbooks
4. **Multiple Trigger Methods**: Manual, D&R rule-based, API-triggered, or scheduled execution
5. **Rich Execution Environment**: Pre-installed packages including ML libraries, AI CLI tools, and more
6. **Organization Isolation**: Each organization's playbooks run in dedicated containers

## Quick Start: Your First Playbook

### Basic Playbook Structure

Every playbook requires a single `playbook()` function:

```python
import limacharlie

def playbook(sdk, data):
    """
    Required entry point for all playbooks.

    Args:
        sdk: Pre-authenticated limacharlie.Manager() instance (or None if no credentials)
        data: Dictionary of input parameters passed to the playbook

    Returns:
        Dictionary with optional keys:
            - data: Dictionary to return to caller
            - error: Error message string
            - detection: Dictionary to use as a detection
            - cat: String category for the detection
    """

    # Your automation logic here

    return {
        "data": {"result": "success"}
    }
```

### Simple Example: Sensor Status Check

```python
import limacharlie

def playbook(sdk, data):
    """Check if sensor is online and return status."""

    if not sdk:
        return {"error": "API credentials required"}

    sid = data.get("sid")
    if not sid:
        return {"error": "sid parameter required"}

    try:
        sensor = sdk.sensor(sid)
        info = sensor.getInfo()

        return {
            "data": {
                "hostname": info.get("hostname"),
                "is_online": info.get("is_online"),
                "platform": info.get("plat"),
                "tags": info.get("tags", [])
            }
        }
    except Exception as e:
        return {"error": f"Failed to get sensor info: {str(e)}"}
```

### Storing and Running Your Playbook

Upload to LimaCharlie Hive:

```bash
limacharlie hive set playbook --key my-first-playbook --data playbook.py --data-key python
```

Test interactively from the web interface:

1. Navigate to **Extensions** > **Playbook**
2. Select your playbook
3. Provide test data as JSON: `{"sid": "your-sensor-id"}`
4. Click **Run Playbook**

## Playbook Return Values

The `playbook()` function must return a dictionary with one or more of these optional keys:

### 1. Return Data (`data`)

Return information to the caller:

```python
return {"data": {"sensors": [s.getInfo() for s in sdk.sensors()]}}
```

### 2. Report Errors (`error`)

Report an error condition:

```python
return {"error": "Failed to connect to external API"}
```

### 3. Generate Detection (`detection` + `cat`)

Create a detection report:

```python
return {
    "detection": {
        "title": "Suspicious Activity Detected",
        "content": event_details
    },
    "cat": "suspicious-behavior"
}
```

---

## Working with Timestamps

**IMPORTANT**: When users provide relative time offsets (e.g., "last hour", "past 24 hours", "last week"), you MUST dynamically compute the current epoch timestamp based on the actual current time. Never use hardcoded or placeholder timestamps.

### Computing Current Epoch

```python
import time

# Compute current time dynamically
current_epoch_seconds = int(time.time())
current_epoch_milliseconds = int(time.time() * 1000)
```

**The granularity (seconds vs milliseconds) depends on the specific API or MCP tool**. Always check the tool signature or API documentation to determine which unit to use.

### Common Relative Time Calculations

**Example: "Investigate events from the last hour"**
```python
def playbook(sdk, data):
    end_time = int(time.time())  # Current time
    start_time = end_time - 3600  # 1 hour ago

    # Use with queries or API calls
    return {"data": {"start": start_time, "end": end_time}}
```

**Common offsets (in seconds)**:
- 1 hour = 3600
- 24 hours = 86400
- 7 days = 604800
- 30 days = 2592000

**For millisecond-based APIs, multiply by 1000**.

### Critical Rules

**NEVER**:
- Use hardcoded timestamps
- Use placeholder values like `1234567890`
- Assume a specific current time

**ALWAYS**:
- Compute dynamically using `time.time()`
- Check the API/tool signature for correct granularity
- Verify the time range is valid (start < end)

---

## Triggering Playbooks

### 1. Via D&R Rules (Automated)

Trigger playbooks automatically from detections:

```yaml
detect:
  event: NEW_PROCESS
  op: contains
  path: event/COMMAND_LINE
  value: mimikatz
  case sensitive: false

respond:
  - action: report
    name: Mimikatz Detected
  - action: extension request
    extension name: ext-playbook
    extension action: run_playbook
    extension request:
      name: '{{ "investigate-mimikatz" }}'
      credentials: '{{ "hive://secret/lc-api-key" }}'
      data:
        sid: "{{ .routing.sid }}"
        hostname: "{{ .routing.hostname }}"
        process_id: "{{ .event.PROCESS_ID }}"
        command_line: "{{ .event.COMMAND_LINE }}"
```

**Key Points:**
- Use `extension request` action in D&R rules
- Pass detection context via the `data` parameter
- Reference credentials using `hive://secret/` syntax
- Use Go template syntax to inject event data

### 2. Via Python SDK

Invoke playbooks programmatically:

```python
import limacharlie

lc = limacharlie.Manager()
ext = limacharlie.Extension(lc)

response = ext.request("ext-playbook", "run_playbook", {
    "name": "my-playbook",
    "credentials": "hive://secret/my-api-key",
    "data": {
        "target_host": "server-123",
        "incident_id": "INC-2024-001"
    }
})
```

### 3. Via REST API

Make direct API calls:

```bash
curl -X POST https://api.limacharlie.io/v1/orgs/YOUR_OID/extension \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "ext-playbook",
    "action": "run_playbook",
    "request": {
      "name": "my-playbook",
      "credentials": "hive://secret/my-api-key",
      "data": {"param1": "value1"}
    }
  }'
```

See [REFERENCE.md](./REFERENCE.md) for complete triggering details and advanced options.

## Common Patterns

### Pattern 1: Webhook Notification

```python
import limacharlie
import json
import urllib.request

def playbook(sdk, data):
    """Send detection to external webhook."""

    if not sdk:
        return {"error": "API credentials required"}

    webhook_url = limacharlie.Hive(sdk, "secret").get("webhook-url").data["secret"]

    payload = {
        "timestamp": data.get("timestamp"),
        "hostname": data.get("hostname"),
        "severity": data.get("severity", "medium"),
        "details": data
    }

    try:
        request = urllib.request.Request(
            webhook_url,
            data=json.dumps(payload).encode('utf-8'),
            headers={"Content-Type": "application/json"},
            method="POST"
        )

        with urllib.request.urlopen(request) as response:
            response_body = response.read().decode('utf-8')

        return {"data": {"status": "sent", "response": response_body}}
    except Exception as e:
        return {"error": f"Webhook failed: {str(e)}"}
```

### Pattern 2: Threat Intelligence Enrichment

```python
import limacharlie
import json
import urllib.request

def playbook(sdk, data):
    """Enrich IP address with threat intel."""

    if not sdk or not data.get("ip_address"):
        return {"error": "API credentials and ip_address required"}

    api_key = limacharlie.Hive(sdk, "secret").get("virustotal-api-key").data["secret"]
    url = f"https://www.virustotal.com/api/v3/ip_addresses/{data['ip_address']}"

    request = urllib.request.Request(url, headers={"x-apikey": api_key})
    with urllib.request.urlopen(request) as response:
        vt_data = json.loads(response.read().decode('utf-8'))

    malicious_count = vt_data.get("data", {}).get("attributes", {}).get("last_analysis_stats", {}).get("malicious", 0)

    if malicious_count > 0:
        return {
            "detection": {"ip_address": data["ip_address"], "malicious_votes": malicious_count},
            "cat": "malicious-ip-detected"
        }
    return {"data": {"enriched": True, "malicious": False}}
```

### Pattern 3: Automated Response

```python
import limacharlie

def playbook(sdk, data):
    """Automatically triage and respond to suspicious process."""

    if not sdk or not data.get("sid") or not data.get("process_id"):
        return {"error": "API credentials, sid, and process_id required"}

    sensor = sdk.sensor(data["sid"])
    info = sensor.getInfo()
    actions_taken = []
    is_vip = "vip" in info.get("tags", [])

    # Collect memory dump
    sensor.task(f"mem_map --pid {data['process_id']}", investigationId=f"triage-{data['process_id']}")
    actions_taken.append("memory_mapped")

    # Kill and isolate if VIP
    if is_vip:
        sensor.task(f"deny_tree {data['process_id']}")
        sensor.task("segregate_network")
        actions_taken.extend(["process_killed", "network_isolated"])

    return {
        "detection": {
            "sensor_id": data["sid"],
            "hostname": info.get("hostname"),
            "actions_taken": actions_taken
        },
        "cat": "automated-triage"
    }
```

See [EXAMPLES.md](./EXAMPLES.md) for 15+ complete playbook examples covering all major use cases.

## Secret Management

### Creating Secrets

Via CLI:
```bash
limacharlie hive set secret --key webhook-url --data "https://hooks.example.com/webhook" --data-key secret
```

Via Python SDK:
```python
import limacharlie

lc = limacharlie.Manager()
hive = limacharlie.Hive(lc, "secret")
hive.set("my-secret-name", {"secret": "secret-value-here"})
```

### Using Secrets in Playbooks

```python
def playbook(sdk, data):
    if not sdk:
        return {"error": "API credentials required"}

    # Retrieve secret
    api_key = limacharlie.Hive(sdk, "secret").get("external-api-key").data["secret"]

    # Use in API calls...
```

### Passing Credentials to Playbooks

```yaml
# In D&R rule
- action: extension request
  extension name: ext-playbook
  extension action: run_playbook
  extension request:
    name: '{{ "my-playbook" }}'
    credentials: '{{ "hive://secret/lc-api-key" }}'  # API key for the sdk object
    data:
      webhook_key: '{{ "hive://secret/webhook-url" }}'  # Additional secret
```

## Quick SDK Reference

### Sensor Operations

```python
# List all sensors
for sensor in sdk.sensors():
    info = sensor.getInfo()

# Get specific sensor
sensor = sdk.sensor("sensor-id")

# Task a sensor
sensor.task("history_dump", investigationId="my-investigation")

# Tag a sensor
sensor.tag("compromised", ttl=3600)

# Isolate sensor
sensor.task("segregate_network")
```

### Hive Operations

```python
# Access secrets
secret = limacharlie.Hive(sdk, "secret").get("my-secret").data["secret"]

# Access lookups
lookup = limacharlie.Hive(sdk, "lookup")
domains = lookup.get("malicious-domains").data

# Store data
playbook_hive = limacharlie.Hive(sdk, "playbook")
playbook_hive.set("my-data", {"results": [1, 2, 3]})
```

### Detection Management

```python
# Query detections
detections = sdk.getDetections(limit=100)

for det in detections:
    print(f"{det['detect']['cat']}: {det['routing']['hostname']}")
```

See [REFERENCE.md](./REFERENCE.md) for complete SDK documentation and all available operations.

## Best Practices

1. **Keep Playbooks Focused**: Each playbook should do one thing well
2. **Validate Inputs**: Always check for required parameters
3. **Handle Errors Gracefully**: Return meaningful error messages
4. **Use Secrets**: Never hardcode credentials
5. **Return Structured Data**: Use consistent return formats
6. **Test Thoroughly**: Test with edge cases before production
7. **Document Parameters**: Comment expected inputs and outputs
8. **Use Investigation IDs**: Tag sensor tasks for correlation
9. **Keep Executions Short**: Design for 10-minute maximum execution time
10. **Don't Assume Persistence**: Environment is ephemeral between executions

## Environment and Limitations

### Available Packages

**Python Libraries:**
- `limacharlie` - LimaCharlie SDK/CLI
- `lcextension` - LimaCharlie Extension SDK
- `flask`, `gunicorn` - Web framework
- `scikit-learn` - Machine learning
- `jinja2`, `markdown`, `pillow`, `weasyprint`

**CLI Tools:**
- NodeJS, `claude`, `codex`, `gemini`

### Execution Constraints

- **Execution Time**: Maximum 10 minutes per playbook
- **State**: Environment is ephemeral - no persistent state between executions
- **Packages**: Custom packages require support contact (not available in self-serve)
- **Background Tasks**: Only code in `playbook()` function executes

## Documentation Navigation

This skill documentation is organized for progressive disclosure:

- **[REFERENCE.md](./REFERENCE.md)**: Complete SDK reference, all available operations, advanced patterns, conditional logic, looping, and Infrastructure as Code examples
- **[EXAMPLES.md](./EXAMPLES.md)**: 15+ complete playbook examples including multi-sensor investigation, ticketing integration, SOAR integration, notification services, threat hunting, compliance reporting, and timeline reconstruction
- **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)**: Testing strategies, debugging techniques, common errors, development workflow, and best practices

## Common Use Cases

- **Automated Incident Response**: Execute containment actions based on detections
- **Threat Intelligence Integration**: Enrich detections with external threat data
- **Custom Notifications**: Send alerts to ticketing systems, SOAR platforms, or chat apps
- **Fleet Management**: Perform batch operations across multiple sensors
- **Compliance Automation**: Generate reports and audit logs
- **Scheduled Maintenance**: Periodic security hygiene tasks
- **Investigation Orchestration**: Coordinate multi-step investigation workflows
- **External System Integration**: Connect LimaCharlie with other security tools

## Key Reminders

1. **Always validate inputs**: Check for required parameters and handle missing data
2. **Use secrets for credentials**: Never hardcode sensitive information
3. **Return structured data**: Use consistent return format with `data`, `error`, `detection`, `cat`
4. **Handle offline sensors**: Check sensor status before tasking
5. **Use investigation IDs**: Tag related sensor tasks for correlation
6. **Test before deploying**: Validate playbooks with test data before automation
7. **Use proper error handling**: Catch and report errors meaningfully
8. **Document your playbooks**: Comment expected inputs, outputs, and behavior

---

This skill provides comprehensive guidance for creating powerful automated response playbooks. When helping users, focus on understanding their automation goals and designing playbooks that are reliable, maintainable, and follow security best practices.
