---
name: gns3-lab-automation
description: GNS3 network lab operations including topology management, device configuration via console, and troubleshooting workflows for routers and switches
---

# GNS3 Lab Automation Skill

## Overview

GNS3 (Graphical Network Simulator-3) is a network emulation platform for building complex network topologies. This skill provides knowledge for automating GNS3 lab operations through the MCP server.

## Key Features (Must Know!)

### 🗒️ Project Notes/Memory System
**Problem**: Lab configurations consume conversation context (IPs, credentials, architecture notes)
**Solution**: Store persistent notes in per-project README

**When to use:**
- ✅ Always read notes when starting work on a project
- ✅ Update notes after configuring new devices
- ✅ Document IP schemes, credentials, topology changes
- ✅ Record troubleshooting findings and solutions

**Tools:**
- `get_project_readme()` - Retrieve project documentation
- `update_project_readme(content)` - Save/update documentation (markdown format)

**Resource:** `projects://{id}/readme` (read-only browsing)

**Example Workflow:**
```python
# 1. Always start by reading existing notes
notes = get_project_readme()

# 2. Do your work (configure router, add nodes, etc.)
# ...

# 3. Update notes with new information
update_project_readme("""
# Lab Configuration

## Network Topology
- Router1: 10.1.0.1/24 (GigabitEthernet0/0)
- Router2: 10.1.0.2/24 (GigabitEthernet0/0)

## Credentials
- Username: admin
- Password: cisco123

## Last Updated
2025-10-26: Added Router2, configured OSPF
""")
```

### 📋 Template Usage Notes
**Problem**: Forgetting default credentials, boot times, device-specific setup steps
**Solution**: Templates include built-in usage notes with device info

**What's included:**
- Default credentials (username/password)
- Boot timing estimates ("First boot takes 60 seconds...")
- Persistent storage locations ("/root directory persists")
- Console availability and device-specific quirks

**How to access:**
- **For specific node:** `projects://{id}/nodes/{node_id}/template`
- **For template:** `gns3://templates/{template_id}`

**Example:**
```python
# Get usage notes for a MikroTik node you just created
usage = read_resource("projects://{id}/nodes/{node_id}/template")
# Returns: "The login is admin, with no password by default.
#           On first boot, RouterOS is actually being installed..."
```

**Pro Tip:** Check template usage before configuring new devices to avoid common mistakes!

## Core Concepts

### MCP Resources (v0.13.0 - NEW)

**MCP resources provide browsable state** via standardized URIs, replacing query tools for better IDE integration.

**Resource Benefits:**
- Browsable in MCP-aware tools (inspectors, IDEs)
- Automatic discovery and autocomplete
- Consistent URI scheme (`gns3://` protocol)
- Better performance with resource subscriptions

**Available Resources (v0.29.0 - URI Standardization):**

**Project-Centric Resources:**
- `projects://` - List all GNS3 projects
- `projects://{project_id}` - Get project details by ID
- `projects://{project_id}/readme` - Get project README/notes (v0.23.0)
- `projects://{project_id}/sessions/console/` - Console sessions in project (v0.29.1)
- `projects://{project_id}/sessions/ssh/` - SSH sessions in project (v0.29.1)

**Object-Centric Resources:**
- `nodes://{project_id}/` - List nodes in project (NodeSummary, table mode v0.30.0)
- `nodes://{project_id}/{node_id}` - Get node details (full NodeInfo)
- `nodes://{project_id}/{node_id}/template` - Get template usage notes for node (v0.23.0)
- `links://{project_id}/` - List network links in project (table mode v0.30.0)
- `drawings://{project_id}/` - List drawing objects (table mode v0.30.0)

**Diagram Resources (v0.33.0):**
- `diagrams://{project_id}/topology` - Get topology diagram as SVG (visualize lab layout)

**Template Resources (Static, Not Project-Scoped):**
- `templates://` - List all available templates (table mode v0.30.0)
- `templates://{template_id}` - Get template details with usage notes (v0.23.0)

**Session Resources (Dual Access Patterns v0.29.1):**

*Path-based (project-scoped):*
- `projects://{project_id}/sessions/console/` - Console sessions in project
- `projects://{project_id}/sessions/ssh/` - SSH sessions in project

*Query-parameter-based (filtered):*
- `sessions://console/?project_id={id}` - Console sessions filtered by project
- `sessions://ssh/?project_id={id}` - SSH sessions filtered by project

*Unfiltered (all sessions):*
- `sessions://console/` - All console sessions across all projects (table mode v0.30.0)
- `sessions://console/{node_name}` - Console session for specific node
- `sessions://ssh/` - All SSH sessions across all projects (table mode v0.30.0)
- `sessions://ssh/{node_name}` - SSH session status for node
- `sessions://ssh/{node_name}/history` - SSH command history (table mode v0.30.0)
- `sessions://ssh/{node_name}/buffer` - SSH continuous buffer

**Proxy Resources:**
- `proxies:///status` - Main proxy status (THREE slashes)
- `proxies://` - Proxy registry (host + lab proxies, table mode v0.30.0)
- `proxies://sessions` - All proxy sessions (table mode v0.30.0)
- `proxies://project/{project_id}` - Proxies for specific project
- `proxies://{proxy_id}` - Specific proxy details

**Resource vs Tool Usage:**
- **Resources**: Query state (read-only) - use for browsing, monitoring
- **Tools**: Modify state (actions) - use for changes, commands, configuration

**Example Resource Workflow:**
```
# Browse resources (read-only)
1. List all projects: projects://
2. Pick project ID from list
3. View nodes: nodes://{project_id}/
4. Check topology diagram: diagrams://{project_id}/topology
5. Check SSH sessions: sessions://ssh/?project_id={project_id}
6. Check SSH session for specific node: sessions://ssh/R1

# Use tools to modify (actions)
7. Call ssh_configure() to create SSH session
8. Call ssh_command() to execute commands
9. Call set_node() to change node state
10. Call export_topology_diagram() to save diagram as PNG/SVG
```

**Removed in v0.14.0 (use MCP resources instead):**
- `list_projects()` → Use resource `projects://`
- `list_nodes()` → Use resource `nodes://{project_id}/`
- `get_node_details()` → Use resource `nodes://{project_id}/{node_id}`
- `get_links()` → Use resource `links://{project_id}/`
- `list_templates()` → Use resource `templates://`
- `list_drawings()` → Use resource `drawings://{project_id}/`
- `get_console_status()` → Use resource `sessions://console/{node_name}`
- `ssh_get_status()` → Use resource `sessions://ssh/{node_name}`
- `ssh_get_history()` → Use resource `sessions://ssh/{node_name}/history`
- `ssh_get_command_output()` → Use resource with filtering
- `ssh_read_buffer()` → Use resource `sessions://ssh/{node_name}/buffer`

**Final Architecture (v0.34.0):**
- **27 Action Tools**: Modify state (create, delete, configure, execute commands)
- **21 MCP Resources**: Browse state (projects, nodes, sessions, diagrams, proxies) with table mode
- **5 MCP Prompts**: Guided workflows (ssh_setup, topology_discovery, troubleshooting, lab_setup, node_setup)
- **Clear separation**: Tools change things, Resources view things, Prompts guide workflows
- **Table Mode (v0.30.0)**: All list resources use simple table format for readability

### Projects
- **Projects** are isolated network topologies with their own nodes, links, and configuration
- Projects have status: `opened` or `closed`
- Always ensure a project is opened before working with nodes
- Use `open_project()` to activate a project

### Nodes
- **Nodes** represent network devices (routers, switches, servers, etc.)
- Node types: `qemu` (VMs), `docker` (containers), `ethernet_switch`, `nat`, etc.
- Node status: `started` or `stopped`
- Each node has a unique `node_id` and human-readable `name`

**Node Deletion & Cleanup (v0.34.0):**
- `delete_node(node_name)` removes node from project
- **Automatic SSH session cleanup**: When a node is deleted, all SSH sessions are automatically cleaned up:
  - Disconnects SSH sessions on ALL registered proxies (host proxy + lab proxies)
  - Cleans up internal session mappings
  - Best-effort cleanup - won't block deletion if cleanup fails
- **Why**: Prevents orphaned SSH sessions consuming resources
- **Example**:
  ```python
  delete_node("Router1")
  # Automatically:
  # 1. Deletes node from GNS3
  # 2. Disconnects SSH session if active
  # 3. Cleans up proxy mappings
  # No manual cleanup needed!
  ```

### Choosing Between SSH and Console Tools

**IMPORTANT: Always prefer SSH tools when available!**

**Use SSH Tools For:**
- Production automation workflows
- Configuration management
- Command execution on network devices
- Better reliability with automatic prompt detection
- Structured output and error handling
- Available SSH tools: `ssh_send_command()`, `ssh_send_config_set()`, `ssh_read_buffer()`, `ssh_get_history()`

**Use Console Tools Only For:**
- **Initial device configuration** (enabling SSH, creating users, generating keys)
- **Troubleshooting** when SSH is unavailable or broken
- **Devices without SSH support** (VPCS, simple switches)
- Interactive TUI navigation (vim, menu systems)

**Typical Workflow:**
1. Start with console tools to configure SSH access
2. Establish SSH session with `configure_ssh()`
3. Switch to SSH tools for all automation
4. Return to console only if SSH fails

### Local Execution on SSH Proxy Container (v0.28.0)

**Use node_name="@" to execute commands directly on the SSH proxy container.**

**Why Use Local Execution:**
- Test connectivity before accessing devices (ping, traceroute)
- Run ansible playbooks from /opt/gns3-ssh-proxy mount
- Execute diagnostic tools not available on network devices
- Orchestrate multi-device operations with custom scripts

**Available Tools:**
- **Network diagnostics**: ping, traceroute, ip, ss, netstat
- **DNS queries**: dig, nslookup
- **HTTP client**: curl
- **Automation**: ansible-core, python3, bash
- **Working directory**: /opt/gns3-ssh-proxy (shared with host)

**Key Advantages:**
- No ssh_configure() needed
- Direct access to diagnostic tools
- Ansible playbooks can orchestrate multiple devices
- Mix local and remote commands in ssh_batch()

**Examples:**

```python
# Test connectivity before device access
ssh_command("@", "ping -c 3 10.10.10.1")

# Run ansible playbook (mounted from host)
ssh_command("@", "ansible-playbook /opt/gns3-ssh-proxy/backup.yml -i inventory")

# DNS lookup for lab devices
ssh_command("@", "dig router1.lab.local")

# Bash script (list of commands)
ssh_command("@", [
    "cd /opt/gns3-ssh-proxy",
    "python3 backup_configs.py",
    "ls -la backups/"
])

# Batch operations - test connectivity then configure devices
ssh_batch([
    {"type": "send_command", "node_name": "@", "command": "ping -c 2 10.1.1.1"},
    {"type": "send_command", "node_name": "@", "command": "ping -c 2 10.1.1.2"},
    {"type": "send_command", "node_name": "R1", "command": "show ip int brief"},
    {"type": "send_command", "node_name": "R2", "command": "show ip int brief"}
])
```

**File Sharing with Host:**
1. Place files in `/opt/gns3-ssh-proxy/` on GNS3 host
2. Access same path in container
3. Useful for: ansible playbooks, Python scripts, configuration templates

**Note:** Local execution returns `{success, output, exit_code}` instead of SSH job format.

### Error Responses

**All tools return standardized error responses** (v0.20.0) with machine-readable error codes and actionable guidance.

**Error Response Structure:**
```json
{
  "error": "Human-readable error message",
  "error_code": "MACHINE_READABLE_CODE",
  "details": "Additional error details",
  "suggested_action": "How to fix the error",
  "context": {
    "parameter": "value",
    "debugging_info": "..."
  },
  "server_version": "0.20.0",
  "timestamp": "2025-10-25T14:30:00.000Z"
}
```

**Error Code Categories:**

**Resource Not Found (404-style):**
- `PROJECT_NOT_FOUND` - No project open or project doesn't exist
- `NODE_NOT_FOUND` - Node name not found in project
- `LINK_NOT_FOUND` - Link ID doesn't exist
- `TEMPLATE_NOT_FOUND` - Template name not available
- `DRAWING_NOT_FOUND` - Drawing ID not found
- `SNAPSHOT_NOT_FOUND` - Snapshot name doesn't exist

**Validation Errors (400-style):**
- `INVALID_PARAMETER` - Invalid parameter value
- `MISSING_PARAMETER` - Required parameter not provided
- `PORT_IN_USE` - Port already connected to another node
- `NODE_RUNNING` - Operation requires node to be stopped
- `NODE_STOPPED` - Operation requires node to be running
- `INVALID_ADAPTER` - Adapter name/number not valid for node
- `INVALID_PORT` - Port number exceeds adapter capacity

**Connection Errors (503-style):**
- `GNS3_UNREACHABLE` - Cannot connect to GNS3 server
- `GNS3_API_ERROR` - GNS3 server API error
- `CONSOLE_DISCONNECTED` - Console session lost
- `CONSOLE_CONNECTION_FAILED` - Failed to connect to console
- `SSH_CONNECTION_FAILED` - Failed to establish SSH session
- `SSH_DISCONNECTED` - SSH session lost

**Authentication Errors (401-style):**
- `AUTH_FAILED` - Authentication failed
- `TOKEN_EXPIRED` - JWT token expired
- `INVALID_CREDENTIALS` - Wrong username/password

**Internal Errors (500-style):**
- `INTERNAL_ERROR` - Server internal error
- `TIMEOUT` - Operation timed out
- `OPERATION_FAILED` - Generic operation failure

**Example Error Handling:**
```python
# Attempt to start a node
result = set_node("Router1", action="start")

# Check for errors
if "error" in result:
    error = json.loads(result)
    if error["error_code"] == "NODE_NOT_FOUND":
        # Use suggested_action to fix
        print(error["suggested_action"])  # "Use list_nodes() to see all available nodes"
        # Check available nodes from context
        print(error["context"]["available_nodes"])  # ["Router2", "Router3", "Switch1"]
    elif error["error_code"] == "GNS3_UNREACHABLE":
        # Server connection issue
        print(f"Cannot reach GNS3 at {error['context']['host']}:{error['context']['port']}")
```

**Common Error Scenarios:**

1. **No project open**: Most tools require an open project
   - Error: `PROJECT_NOT_FOUND`
   - Fix: `open_project("ProjectName")`

2. **Node not found**: Typo in node name (case-sensitive)
   - Error: `NODE_NOT_FOUND`
   - Fix: Check available_nodes in error context or use resource `projects://{id}/nodes/`

3. **Port already in use**: Trying to connect already-connected port
   - Error: `PORT_IN_USE`
   - Fix: Disconnect existing link first with `set_connection([{"action": "disconnect", "link_id": "..."}])`

4. **Node must be stopped**: Trying to modify running node properties
   - Error: `NODE_RUNNING`
   - Fix: `set_node("NodeName", action="stop")` then retry

### Tool Annotations (v0.19.0)

**MCP tool annotations** provide metadata to IDE/MCP clients for better UX and safety.

**destructive** (3 tools):
- `delete_node`, `restore_snapshot`, `delete_drawing`
- IDE may show warnings or require confirmation
- These operations delete data or make irreversible changes
- **Always create backups before using destructive tools**

**idempotent** (9 tools):
- `open_project`, `create_project`, `close_project`, `set_node`
- `console_disconnect`, `ssh_configure`, `ssh_disconnect`
- `update_drawing`, `export_topology_diagram`
- Safe to retry - same operation produces same result
- Example: Opening already-opened project is safe

**read_only** (1 tool):
- `console_read`
- Tool only reads data, makes no state changes
- May be cached by MCP clients

**creates_resource** (5 tools):
- `create_project`, `create_node`, `create_snapshot`
- `export_topology_diagram`, `create_drawing`
- Tool creates new resources (in GNS3 or filesystem)

**modifies_topology** (3 tools):
- `set_connection`, `create_node`, `delete_node`
- Tool changes network topology structure
- May require project reload in GNS3 GUI

### Console Access
- Nodes have **console** ports for CLI access
- Console types:
  - `telnet`: CLI access (most routers/switches) - currently supported
  - `vnc`: Graphical access (desktops/servers) - not yet supported
  - `spice+agent`: Enhanced graphical - not yet supported
  - `none`: No console
- **Auto-connect workflow** (v0.2.0):
  1. Just use `console_send(node_name, command)` - automatically connects if needed
  2. Read output with `console_read(node_name)` - returns new output since last read (diff mode, default since v0.9.0)
  3. Or use `console_read(node_name, mode="last_page")` for last ~25 lines
  4. Or use `console_read(node_name, mode="all")` for full buffer
  5. Disconnect with `console_disconnect(node_name)` when done
- Sessions are managed automatically by node name
- Session timeout: 30 minutes of inactivity

**Console State Tracking (v0.34.0):**
- **IMPORTANT**: Must read console BEFORE sending commands
- **Why**: Ensures you understand current terminal state (prompt, login screen, etc.)
- **Enforced**: All send operations (`console_send`, `console_send_and_wait`, `console_keystroke`) check access state
- **Workflow**:
  1. First: `console_read("R1")` - Check terminal state (are you at login? prompt? password?)
  2. Then: `console_send("R1", "command\n")` - Send appropriate command
  3. Read again: `console_read("R1")` - Verify command executed
- **Error**: If you try to send without reading first, you'll get:
  ```
  "Cannot send to console - terminal not accessed yet.
   Use console_read() to check current terminal state first."
  ```
- **Best Practice**: Always read → send → read pattern for reliable automation

### Interactive Console Automation (v0.21.1)

For workflows that need to **wait for specific prompts** before proceeding:

**Tool**: `console_send_and_wait(node_name, command, wait_pattern, timeout, raw)`

**Best Practice Workflow:**
1. **Check the prompt first** - See what you're waiting for:
   ```
   console_send("R1", "\n")  # Wake console
   output = console_read("R1")  # Check output: "Router#"
   ```

2. **Use that pattern** in console_send_and_wait:
   ```
   result = console_send_and_wait(
       "R1",
       "show ip interface brief\n",
       wait_pattern="Router#",  # Wait for this exact prompt
       timeout=10
   )
   ```

3. **Check the result**:
   ```json
   {
       "output": "Interface    IP-Address   ...\nGi0/0        192.168.1.1  ...\nRouter#",
       "pattern_found": true,
       "timeout_occurred": false,
       "wait_time": 0.8
   }
   ```

**Use Cases:**
- **Interactive logins**: Wait for "Login:" prompt
- **Command completion**: Wait for prompt to return before next command
- **Configuration mode**: Wait for "(config)#" before sending configs
- **Reboots**: Wait for boot messages to complete

**Examples:**
```
# Wait for login prompt
console_send_and_wait("R1", "\n", wait_pattern="Login:", timeout=30)

# Wait for enable prompt
console_send_and_wait("R1", "enable\n", wait_pattern="#", timeout=5)

# Configuration mode
console_send_and_wait("R1", "configure terminal\n", wait_pattern="(config)#", timeout=5)

# No pattern - just wait 2 seconds and return output
console_send_and_wait("R1", "save config\n")
```

**Pattern Matching:**
- Supports regex patterns: `"Router[>#]"` matches "Router>" OR "Router#"
- Pattern search is case-sensitive by default
- If `wait_pattern=None`, waits 2 seconds and returns output
- Polls console every 0.5 seconds until pattern found or timeout

**Error Handling:**
- Invalid regex: Returns error with `error_code="INVALID_PARAMETER"`
- Console disconnected: Returns error with `error_code="CONSOLE_DISCONNECTED"`
- Timeout without pattern: Sets `timeout_occurred=true`, still returns accumulated output

**When to Use:**
- ✅ Interactive console workflows (logins, menus, confirmations)
- ✅ Ensuring command completion before next step
- ✅ Boot sequences with specific prompts
- ❌ Simple command execution - use `console_send()` + `console_read()` instead
- ❌ SSH-capable devices - use `ssh_command()` for better reliability

### Batch Console Operations (v0.22.0)

For workflows that need to **execute multiple console operations** efficiently:

**Tool**: `console_batch(operations)` - Execute multiple console operations with two-phase validation

**Two-Phase Execution:**
1. **VALIDATE ALL** operations (check nodes exist, required params present)
2. **EXECUTE ALL** operations (only if all valid, sequential execution)

**Supported Operation Types:**
Each operation in the batch can be any of these types with **full parameter support**:

1. **"send"** - Send data to console
   ```json
   {
       "type": "send",
       "node_name": "R1",
       "data": "show version\n",
       "raw": false  // optional
   }
   ```

2. **"send_and_wait"** - Send command and wait for pattern
   ```json
   {
       "type": "send_and_wait",
       "node_name": "R1",
       "command": "show ip interface brief\n",
       "wait_pattern": "Router#",  // optional
       "timeout": 30,  // optional
       "raw": false  // optional
   }
   ```

3. **"read"** - Read console output
   ```json
   {
       "type": "read",
       "node_name": "R1",
       "mode": "diff",  // optional: diff/last_page/num_pages/all
       "pattern": "error",  // optional grep pattern
       "case_insensitive": true  // optional
   }
   ```

4. **"keystroke"** - Send special keystroke
   ```json
   {
       "type": "keystroke",
       "node_name": "R1",
       "key": "enter"  // up/down/enter/ctrl_c/etc
   }
   ```

**Use Case 1: Multiple Commands on One Node**
```json
console_batch([
    {"type": "send_and_wait", "node_name": "R1", "command": "show version\n", "wait_pattern": "Router#"},
    {"type": "send_and_wait", "node_name": "R1", "command": "show ip route\n", "wait_pattern": "Router#"},
    {"type": "send_and_wait", "node_name": "R1", "command": "show running-config\n", "wait_pattern": "Router#"}
])
```

**Use Case 2: Same Command on Multiple Nodes** (Parallel Analysis)
```json
console_batch([
    {"type": "send_and_wait", "node_name": "R1", "command": "show ip int brief\n", "wait_pattern": "#"},
    {"type": "send_and_wait", "node_name": "R2", "command": "show ip int brief\n", "wait_pattern": "#"},
    {"type": "send_and_wait", "node_name": "R3", "command": "show ip int brief\n", "wait_pattern": "#"}
])
```

**Use Case 3: Mixed Operations** (Interactive Workflow)
```json
console_batch([
    {"type": "send", "node_name": "R1", "data": "\n"},  // Wake console
    {"type": "read", "node_name": "R1", "mode": "last_page"},  // Check prompt
    {"type": "send_and_wait", "node_name": "R1", "command": "show version\n", "wait_pattern": "#"},
    {"type": "keystroke", "node_name": "R1", "key": "ctrl_c"}  // Cancel if needed
])
```

**Return Format:**
```json
{
    "completed": [0, 1, 2],  // Indices of successful operations
    "failed": [3],  // Indices of failed operations
    "results": [
        {
            "operation_index": 0,
            "success": true,
            "operation_type": "send_and_wait",
            "node_name": "R1",
            "result": {
                "output": "...",
                "pattern_found": true,
                "timeout_occurred": false,
                "wait_time": 1.2
            }
        },
        {
            "operation_index": 3,
            "success": false,
            "operation_type": "send_and_wait",
            "node_name": "R4",
            "error": {
                "error": "Node not found: R4",
                "error_code": "NODE_NOT_FOUND",
                "suggested_action": "..."
            }
        }
    ],
    "total_operations": 4,
    "execution_time": 5.3
}
```

**When to Use:**
- ✅ Running same diagnostic command on multiple routers
- ✅ Executing multi-step workflows on one device
- ✅ Gathering data from multiple nodes for comparison/analysis
- ✅ Interactive sequences with validation checks between steps
- ❌ Single operations - use individual tools for simplicity
- ❌ SSH-capable devices - consider SSH batch operations for better reliability

**Advantages:**
- **Validation**: All operations validated before execution (prevents partial failures)
- **Structured Results**: Clear success/failure status per operation
- **Timing**: Execution time tracking for performance analysis
- **Flexibility**: Mix different operation types in one batch
- **Error Isolation**: Failed operations don't stop the batch, all results returned

### Coordinate System and Topology Layout

GNS3 uses a specific coordinate system for positioning elements:

**Node Positioning:**
- Node coordinates (x, y) represent the **top-left corner** of the node icon
- Icon sizes:
  - **PNG images**: 78×78 pixels (custom device icons)
  - **SVG/internal icons**: 58×58 pixels (built-in icons)
- Node center is at `(x + icon_size/2, y + icon_size/2)`
- Example: Node at (100, 100) with PNG icon has center at (139, 139)

**Label Positioning:**
- Node labels are stored as **offsets from node top-left to label box top-left**
- GNS3 API returns: `label: {x: -10, y: -25, text: "Router1", rotation: 0, style: "..."}`
- The offset (x, y) represents: node_top_left → label_box_top_left
- Label box contains text that is **right-aligned and vertically centered** within the box
- Text alignment: `text-anchor: end; dominant-baseline: central`

**Link Connections:**
- Links connect to the **center** of nodes, not the top-left corner
- Connection point: `(node_x + icon_size/2, node_y + icon_size/2)`
- When using `set_connection()`, specify which adapter and port on each node

**Drawing Objects (v0.8.0 - Unified create_drawing):**
- Create drawings with `create_drawing(drawing_type, x, y, ...)` where type is "rectangle", "ellipse", "line", or "text"
- All drawing coordinates (x, y) represent the **top-left corner** of bounding box
- **Rectangle**: `create_drawing("rectangle", x, y, width=W, height=H, fill_color="#fff", border_color="#000")`
- **Ellipse**: `create_drawing("ellipse", x, y, rx=50, ry=30, fill_color="#fff", border_color="#000")`
- **Line**: `create_drawing("line", x, y, x2=100, y2=50, border_color="#000", border_width=2)` - ends at (x+x2, y+y2)
- **Text**: `create_drawing("text", x, y, text="Label", font_size=10, color="#000", font_weight="normal")`
- Z-order: 0 = behind nodes (backgrounds), 1 = in front of nodes (labels)

**Topology Export:**
- Use `export_topology_diagram()` to create SVG/PNG screenshots
- Renders nodes with actual icons, links, drawings, and labels
- All positioning respects the coordinate system above
- Output includes:
  - Visual status indicators on nodes (started=green, stopped=red)
  - Port status indicators on links (active=green circles, shutdown=red circles)
  - Preserved fonts and styling from GNS3

**Layout Best Practices:**
- **Minimum spacing** to avoid overlaps:
  - Horizontal: 150-200px between node icons
  - Vertical: 100-150px between node icons
  - Site rectangles: 250-350px wide, 200-300px tall
  - Padding around elements: 50px minimum
- **Site organization**:
  - Place background rectangles at z=0 (behind nodes)
  - Place site labels at z=1 (in front of rectangles)
  - Position site labels 30px above rectangle top edge
  - Center nodes within site rectangles for clean layout
- **Node positioning**:
  - PNG icons (78×78): Need more spacing than SVG icons (58×58)
  - Account for label width when positioning adjacent nodes
  - Estimated label width: `text_length * font_size * 0.6`
- **Connection planning**:
  - Consider link paths when positioning nodes
  - Avoid crossing links where possible for clarity
  - Star topologies: Central node with radial connections
  - Mesh topologies: Triangular or grid layouts work best

## Common Workflows

### Starting a Lab Environment

```
1. List projects to find your lab
2. Open the target project
3. List nodes to see topology
4. Start nodes in order (usually: core switches → routers → endpoints)
5. Wait ~30-60s for devices to boot
6. Verify status with list_nodes
```

### Configuring a Router via Console

```
1. Ensure node is started (use set_node if needed)
2. Send initial newline to wake console: send_console("Router1", "\n")
3. Read output to see prompt: read_console("Router1")
4. Send configuration commands one at a time
5. Always read output after each command to verify
6. Default behavior (v0.8.0): returns only new output since last read
7. Disconnect when done: disconnect_console("Router1")
```

**Example:**
```
send_console("R1", "\n")
read_console("R1")  # See prompt (diff mode default since v0.9.0)
send_console("R1", "show ip interface brief\n")
read_console("R1")  # See command output (only new lines)
disconnect_console("R1")  # Clean up when done
```

### Using send_and_wait_console for Automation

For automated workflows, `send_and_wait_console()` simplifies command execution by waiting for specific prompts:

```
Workflow:
1. First, identify the prompt pattern
   - Send \n and read output to see what prompt looks like
   - Note the exact prompt: "Router#", "[admin@MikroTik] >", "switch>", etc.

2. Use the prompt pattern in automated commands
   - send_and_wait_console(node, command, wait_pattern=<prompt>)
   - Tool waits until prompt appears, then returns all output

3. No need to manually wait or read - tool handles timing
```

**Example - Automated configuration:**
```
# Step 1: Identify the prompt
send_console("R1", "\n")
output = read_console("R1")  # Output shows "Router#"

# Step 2: Use prompt pattern for automation
result = send_and_wait_console("R1",
    "show ip interface brief\n",
    wait_pattern="Router#",
    timeout=10)
# Returns when "Router#" appears - command is complete

# Step 3: Continue with more commands
result = send_and_wait_console("R1",
    "configure terminal\n",
    wait_pattern="Router\\(config\\)#",  # Prompt changes in config mode
    timeout=10)
```

**When to use send_and_wait_console:**
- Automated scripts where you know the expected prompts
- Long-running commands that need completion confirmation
- Interactive menus where you need to wait for specific text

**When to use send_console + read_console:**
- Interactive troubleshooting where prompts may vary
- Exploring unknown device states
- When you need fine-grained control over timing

### Console Best Practices

- **Always** read console output after sending commands
- **Wait** 1-2 seconds between commands for device processing
- **Send** `\n` (newline) first to wake up console
- **Look for** prompts (>, #) in output to confirm device is ready
- **Default behavior** (v0.9.0): `read_console()` returns only new output since last read (diff mode)
- **Last page mode**: Use `read_console(node, mode="last_page")` for last ~25 lines
- **Full buffer**: Use `read_console(node, mode="all")` for entire console history
- **Before using send_and_wait_console()**: First check what the prompt looks like with `read_console()`
  - Different devices have different prompts: `Router#`, `[admin@MikroTik] >`, `switch>`, etc.
  - Use the exact prompt pattern in `wait_pattern` parameter to ensure command completion
  - Example: Send `\n`, read output to see `Router#`, then use `wait_pattern="Router#"` for commands
  - This prevents missing output or waiting for wrong prompt
- **No need** to manually connect - auto-connects on first send/read
- **Disconnect** when done to free resources (30min timeout otherwise)
- For RouterOS (MikroTik): default user `admin`, empty password
- For Arista vEOS: default user `admin`, no password

### Troubleshooting Connectivity

```
1. Check node status (all started?)
2. Verify console access (can you connect?)
3. Check interfaces: send "show ip interface brief" or equivalent
4. Check routing: send "show ip route"
5. Test ping: send "ping <target_ip>"
6. Read output after each command
```

### Topology Visualization (v0.33.0)

**Viewing Diagrams:**
Use the diagram resource to quickly visualize lab topology:
```
# Get topology as SVG
diagram = read_resource("diagrams://{project_id}/topology")
```

**Exporting Diagrams:**
Use `export_topology_diagram()` tool to save diagrams as files:
```
# Export as both SVG and PNG
export_topology_diagram(
    output_path="/path/to/topology",
    format="both"  # or "svg", "png"
)

# Export with crop region
export_topology_diagram(
    output_path="/path/to/cropped",
    format="png",
    crop_x=100, crop_y=100,
    crop_width=800, crop_height=600
)
```

**Diagram Features:**
- Node positions, status indicators (color-coded by status)
- Network links with connection information
- Drawing objects (labels, shapes, annotations)
- Automatic layout based on node coordinates
- SVG format: scalable, text-based, ideal for AI analysis
- PNG format: rasterized for sharing/presentation

**Use Cases:**
- Document lab topology
- Visual topology review before making changes
- Share lab configuration with team
- Analyze network layout and connectivity patterns

## MCP Prompts - Guided Workflows (v0.17.0)

**MCP prompts** provide step-by-step guidance for complex multi-step operations.

### Available Prompts

**ssh_setup** - Device-Specific SSH Configuration
- Covers 6 device types: Cisco IOS, NX-OS, MikroTik, Juniper, Arista, Linux
- Step-by-step instructions from console configuration to SSH session establishment
- Device-specific commands with parameter placeholders
- Troubleshooting guidance for common SSH issues

Usage:
```
Call the ssh_setup prompt with device_type parameter
Example: ssh_setup(device_type="cisco_ios", node_name="R1")
```

**topology_discovery** - Network Topology Discovery and Visualization
- Guides through using MCP resources to browse projects/nodes/links
- Instructions for `export_topology_diagram` tool usage
- Topology pattern analysis (hub-and-spoke, mesh, tiered, etc.)
- Common topology questions to answer during discovery

Usage:
```
Call the topology_discovery prompt to start guided discovery
The prompt walks through resource browsing and diagram export
```

**troubleshooting** - OSI Model-Based Systematic Troubleshooting
- Layer 1-7 troubleshooting methodology
- Common issues and resolutions for each layer
- Console and SSH troubleshooting workflows
- Performance analysis and log collection

Usage:
```
Call the troubleshooting prompt for systematic diagnosis
Example: troubleshooting(node_name="R1", issue="connectivity")
```

**lab_setup** - Automated Topology Creation (v0.18.0)
- Creates complete topologies with single command
- 6 topology types: star, mesh, linear, ring, OSPF, BGP
- Automatic node positioning using layout algorithms
- IP addressing schemes

Topology types:
- **star**: Hub-and-spoke (parameter: spoke_count)
- **mesh**: Full mesh (parameter: router_count)
- **linear**: Chain topology (parameter: router_count)
- **ring**: Circular topology (parameter: router_count)
- **ospf**: Multi-area OSPF (parameter: area_count, 3 routers per area)
- **bgp**: Multiple AS (parameter: AS_count, 2 routers per AS)

Usage:
```
Call the lab_setup prompt with topology_type and device_count
Example: lab_setup(topology_type="ospf", device_count=3)
```

**node_setup** - Complete Node Setup Workflow (v0.23.0)
- End-to-end workflow for adding new node to lab
- Covers: create, boot, configure IP, document, establish SSH
- Device-specific configuration commands (Cisco IOS, Linux, MikroTik)
- Automatic project README documentation updates
- SSH session verification

Workflow steps:
1. Create node from template at specified coordinates
2. Start node and wait for boot completion (device-specific timing)
3. Configure IP address via console (device-specific commands)
4. Document IP/credentials in project README
5. Establish and verify SSH session for automation

Usage:
```
Call the node_setup prompt to get guided workflow
Example: node_setup(template_name="Cisco IOSv", node_name="R1",
                    x=100, y=100, ip_address="10.1.1.1/24")
```

## SSH Automation (v0.12.0)

SSH automation via Netmiko for advanced device management. Requires SSH proxy container deployed to GNS3 host.

### Prerequisites

SSH must be enabled on device first using console tools:

**Cisco IOS:**
```
send_console('R1', 'configure terminal\n')
send_console('R1', 'username admin privilege 15 secret cisco123\n')
send_console('R1', 'crypto key generate rsa modulus 2048\n')
send_console('R1', 'ip ssh version 2\n')
send_console('R1', 'line vty 0 4\n')
send_console('R1', 'login local\n')
send_console('R1', 'transport input ssh\n')
send_console('R1', 'end\n')
```

**MikroTik RouterOS:**
```
send_console('MT1', '/user add name=admin password=admin123 group=full\n')
send_console('MT1', '/ip service enable ssh\n')
```

### Basic SSH Workflow

**1. Configure SSH Session:**
```
configure_ssh('R1', {
    'device_type': 'cisco_ios',
    'host': '10.10.10.1',
    'username': 'admin',
    'password': 'cisco123'
})
```

**2. Execute Commands:**
```
# Show commands
ssh_send_command('R1', 'show ip interface brief')
ssh_send_command('R1', 'show running-config')

# Configuration commands
ssh_send_config_set('R1', [
    'interface GigabitEthernet0/0',
    'ip address 192.168.1.1 255.255.255.0',
    'no shutdown'
])
```

**3. Review History:**
```
# List recent commands
ssh_get_history('R1', limit=10)

# Search history
ssh_get_history('R1', search='interface')

# Get specific command output
ssh_get_command_output('R1', job_id='...')
```

### Session Management (v0.1.6)

SSH sessions are automatically managed with the following features:

**30-Minute Session TTL:**
- Sessions automatically expire after 30 minutes of inactivity
- Activity timestamp updated on every operation:
  - SSH command execution (`ssh_send_command`, `ssh_send_config_set`)
  - Buffer reads (via resources)
  - Session configuration (reuse of existing session)
- Expired sessions are automatically detected and recreated
- No manual intervention required

**Session Health Checks:**
- Before reusing existing sessions, health checks verify connection is still alive
- Health check methods:
  1. Netmiko `is_alive()` if available (Netmiko 4.0+)
  2. Lightweight empty command test (fallback)
- Stale/closed connections automatically recreated
- Ensures reliable session reuse

**Auto-Recovery from Stale Sessions (THE KEY FEATURE):**

When commands fail with "Socket is closed":
1. Stale session **automatically removed** from session manager
2. Error response includes `error_code="SSH_DISCONNECTED"` and `suggested_action`
3. **Just retry configure_ssh() with same parameters - no force needed!**
4. Fresh session will be created automatically
5. Retry your ssh_command() - it will work

**Recovery Workflow:**
```
# 1. Command fails with "Socket is closed"
result = ssh_send_command('R1', 'show version')
# Returns: error_code="SSH_DISCONNECTED",
#          suggested_action="Session was stale and has been removed. Reconnect..."

# 2. Simply retry configure_ssh() - NO force parameter needed
#    Stale session already cleaned up, new session will be created
configure_ssh('R1', device_dict)

# 3. Retry command - works now
result = ssh_send_command('R1', 'show version')  # ✅ Works
```

**Force Recreation Parameter (rarely needed):**
- Use `force=True` ONLY for: credential changes, manual troubleshooting
- NOT needed for stale session recovery (auto-cleanup handles it)
- Example:
```
# Force recreation to change credentials (uncommon use case)
configure_ssh('R1', device_dict, force=True)
```

**Error Codes (v0.1.6):**
- `SSH_DISCONNECTED` - Session closed (stale connection) → Just retry configure_ssh()
- `TIMEOUT` - Command timed out → Increase read_timeout parameter
- `COMMAND_FAILED` - Generic command failure → Check command syntax

### Adaptive Async for Long Commands

For long-running operations (firmware upgrades, backups):

```
# Start command, return job_id immediately
result = ssh_send_command('R1', 'copy running-config tftp:', wait_timeout=0)
job_id = result['job_id']

# Poll for completion
status = ssh_get_job_status(job_id)
# Returns: {completed, output, execution_time}

# For 15+ minute commands:
ssh_send_command('R1', 'upgrade firmware', read_timeout=900, wait_timeout=0)
```

### Supported Device Types

200+ device types via Netmiko:
- **cisco_ios** - Cisco IOS/IOS-XE
- **cisco_nxos** - Cisco Nexus
- **juniper** - Juniper JunOS
- **arista_eos** - Arista EOS
- **mikrotik_routeros** - MikroTik RouterOS
- **linux** - Linux/Alpine
- See Netmiko documentation for complete list

### SSH Best Practices

- **Enable SSH first** using console tools
- **Use job history** for audit trails and debugging
- **Set wait_timeout=0** for long commands to avoid blocking
- **Poll with ssh_get_job_status()** for async operations
- **Review ssh_get_history()** to verify command execution
- **Clean sessions** with ssh_cleanup_sessions() when changing lab topology
- **Check status** with ssh_get_status() to verify connection before commands

## Device-Specific Commands

### MikroTik RouterOS
- Login prompt: `Login:` → send `admin\n`
- Password: just press enter (empty)
- Prompt: `[admin@MikroTik] >`
- Show interfaces: `/interface print`
- Show IP addresses: `/ip address print`
- Show routes: `/ip route print`

### Arista vEOS
- Login: `admin` (no password)
- Prompt: `switch>`
- Enable mode: `enable` → `switch#`
- Show interfaces: `show interfaces status`
- Show IP: `show ip interface brief`
- Config mode: `configure terminal`

### Cisco IOS (CSR1000v, IOSv)
- Prompt: `Router>` (user mode), `Router#` (privileged)
- Enable: `enable`
- Show interfaces: `show ip interface brief`
- Show routes: `show ip route`
- Config: `configure terminal`

## Error Handling

### Node Won't Start
- Check node details for errors
- Verify compute resources available
- Some nodes (Windows) take 5+ minutes to boot

### Console Not Responding
- Check node is actually started
- Try sending `\n` or `\r\n` to wake console
- Some consoles have startup delay (30-60s after node start)

### Session Timeout
- Console sessions expire after 30 minutes of inactivity
- Always disconnect when done to free resources
- Sessions managed by node_name (no manual tracking needed)

## Multi-Node Operations

When working with multiple nodes:
1. Start nodes using `set_node(node_name, action='start')` or batch operations
2. Console sessions identified by node_name (no manual tracking needed)
3. Configure one device at a time, verify before moving on
4. Read output to get only new lines (diff mode default since v0.8.0) - avoids confusion between devices
5. Disconnect sessions when done: `disconnect_console(node_name)`

**Example - Configure multiple routers:**
```
# Start all routers
set_node("R1", action="start")
set_node("R2", action="start")

# Configure R1
send_console("R1", "\n")
read_console("R1")  # Diff mode default - only new output
send_console("R1", "configure terminal\n")
read_console("R1")  # Only new output since last read
# ... more commands ...
disconnect_console("R1")

# Configure R2 (same pattern)
send_console("R2", "\n")
# ... configure R2 ...
disconnect_console("R2")
```

## Managing Network Connections

### Link Management with set_connection

Use `set_connection(connections)` for batch link operations. Operations execute sequentially (top-to-bottom) with predictable state on failure.

**Connection Format:**
```python
connections = [
    # Disconnect a link
    {"action": "disconnect", "link_id": "abc123"},

    # Connect two nodes (using adapter names - recommended)
    {"action": "connect",
     "node_a": "R1", "adapter_a": "eth0", "port_a": 0,
     "node_b": "R2", "adapter_b": "GigabitEthernet0/0", "port_b": 1},

    # Or using adapter numbers (legacy)
    {"action": "connect",
     "node_a": "R1", "adapter_a": 0, "port_a": 0,
     "node_b": "R2", "adapter_b": 0, "port_b": 1}
]
```

**Adapter Names vs Numbers:**
- **Adapter names** (recommended): Use port names like "eth0", "GigabitEthernet0/0", "Ethernet0"
- **Adapter numbers** (legacy): Use numeric adapter index (0, 1, 2, ...)
- Response always shows **both**: `"adapter_a": 0, "port_a_name": "eth0"`

**Returns:**
```json
{
  "completed": [
    {"index": 0, "action": "disconnect", "link_id": "abc123"},
    {"index": 1, "action": "connect", "link_id": "new-id",
     "node_a": "R1", "node_b": "R2",
     "adapter_a": 0, "port_a": 0, "port_a_name": "eth0",
     "adapter_b": 0, "port_b": 1, "port_b_name": "GigabitEthernet0/0"}
  ],
  "failed": null
}
```

**Best Practices:**
- **Always** call `get_links()` first to check current topology and see port names
- Use **adapter names** for readability (e.g., "eth0" instead of 0)
- Get link IDs from output (in brackets) for disconnection
- Disconnect existing links before connecting to occupied ports
- Operations stop at first failure for predictable state

**Example - Rewire topology:**
```python
# 1. Check current topology
get_links()
# Output shows port names: eth0, GigabitEthernet0/0, etc.

# 2. Disconnect old link and create new one (using port names)
set_connection([
    {"action": "disconnect", "link_id": "abc-123"},
    {"action": "connect",
     "node_a": "R1", "adapter_a": "eth0", "port_a": 0,
     "node_b": "Switch1", "adapter_b": "Ethernet3", "port_b": 3}
])
```

## Node Positioning & Configuration

### Unified Node Control with set_node

Use `set_node(node_name, ...)` for both control and configuration:

**Control Actions:**
- `action="start"` - Start the node
- `action="stop"` - Stop the node
- `action="suspend"` - Suspend node (VM only)
- `action="reload"` - Reload node
- `action="restart"` - Stop, wait (3 retries × 5s), then start

**Configuration Properties:**
- `x`, `y` - Position on canvas
- `z` - Z-order (layer) for overlapping nodes
- `locked` - Lock position (True/False)
- `ports` - Number of ports (ethernet switches only)

**Examples:**
```python
# Start a node
set_node("R1", action="start")

# Restart with retry logic
set_node("R1", action="restart")  # Waits for clean stop

# Move and lock position
set_node("R1", x=100, y=200, locked=True)

# Configure switch ports
set_node("Switch1", ports=16)

# Combined operation
set_node("R1", action="start", x=150, y=300)
```

**Restart Behavior:**
- Stops node and polls status (3 attempts × 5 seconds)
- Waits for confirmed stop before starting
- Returns all retry attempts in result
- Use for nodes that need clean restart

## Snapshot Management (v0.18.0)

Snapshots capture complete project state for version control and rollback.

### Creating Snapshots

Before major changes, create a snapshot for safe rollback:

**Workflow:**
1. Stop all running nodes (optional but recommended for consistency)
2. Create snapshot with descriptive name
3. Make your changes
4. If issues occur, restore to snapshot

**Example:**
```
create_snapshot("Before OSPF Configuration",
                "Working baseline before adding OSPF")
```

**Best Practices:**
- Use descriptive names with dates: "2025-10-26 Working OSPF Config"
- Stop nodes before snapshot for consistent state
- Document what each snapshot represents
- Create snapshots at major milestones

### Restoring Snapshots

Rollback to previous state (⚠️ **DESTRUCTIVE** - all changes since snapshot are lost):

**Restore Process:**
1. Call `restore_snapshot("snapshot_name")`
2. Tool automatically:
   - Stops all running nodes
   - Disconnects all console sessions
   - Restores project to snapshot state
3. All changes since snapshot are permanently lost

**Example:**
```
restore_snapshot("Before OSPF Configuration")
```

**Warning:** Destructive operation - creates backup before testing restore procedure.

### Browsing Snapshots

List available snapshots via resource:
```
projects://{project_id}/snapshots/
```

View snapshot details:
```
projects://{project_id}/snapshots/{snapshot_id}
```

## Project Notes/Memory (v0.23.0)

**Store project-specific context** to avoid consuming conversation context. Agent can maintain persistent notes about IPs, credentials, and architecture.

### Features

- **Per-Project Storage**: Each lab has separate README.txt file
- **Zero Context Cost**: Notes loaded only on explicit tool call
- **Markdown Format**: Human-readable, supports formatting
- **Native GNS3 Storage**: Uses built-in README.txt via API
- **Persistent**: Saved with project, portable

### Tools

**get_project_readme(project_id?)**
- Retrieve project documentation
- Returns markdown content
- Uses current project if ID not specified

**update_project_readme(content, project_id?)**
- Save project documentation
- Markdown format
- Creates README.txt if doesn't exist

### MCP Resource

```
projects://{project_id}/readme
```

Browsable resource for read-only access to project notes.

### Common Use Cases

**IP Addressing Documentation:**
```markdown
# Network Lab

## IP Addressing
- Router1: 10.1.0.1/24 (GigabitEthernet0/0)
- Router2: 10.1.0.2/24 (GigabitEthernet0/0)
- Management VLAN: 192.168.100.0/24

## VLANs
- VLAN 10: Users (10.10.0.0/24)
- VLAN 20: Servers (10.20.0.0/24)
- VLAN 100: Management (192.168.100.0/24)
```

**Credentials & Access:**
```markdown
## Device Credentials
- Router1: admin / vault:router1-pass
- Router2: admin / vault:router2-pass
- Switches: admin / vault:switch-default

## SSH Access
- Router1: ssh://10.1.0.1:22
- Router2: ssh://10.1.0.2:22
```

**Architecture Notes:**
```markdown
## Lab Architecture

### Topology
Router1 ← → Router2 (OSPF backbone)
  |            |
Switch1     Switch2
  |            |
Clients     Servers

### Protocols
- OSPF Area 0: Backbone between routers
- HSRP: VIP 10.1.0.254 (priority R1=110, R2=100)
- STP: Root bridge is Switch1
```

**Configuration Snippets:**
```markdown
## Standard Configs

### OSPF Template
```
router ospf 1
 network 10.0.0.0 0.255.255.255 area 0
 passive-interface default
 no passive-interface GigabitEthernet0/0
```

### HSRP Template
```
interface GigabitEthernet0/1
 standby 1 ip 10.1.0.254
 standby 1 priority 110
 standby 1 preempt
```
```

**Troubleshooting Notes:**
```markdown
## Known Issues

### Router1 High CPU
- **Symptom**: CPU >80% after OSPF config
- **Cause**: Debug logging enabled
- **Fix**: `no debug all`

### Switch1 Port Flapping
- **Symptom**: Port Gi0/1 up/down
- **Cause**: Bad cable in lab
- **Fix**: Use port Gi0/2 instead
```

### Workflow Example

```python
# Agent discovers lab setup
# Get current notes
notes = get_project_readme()

# Agent configures new router, updates notes
update_project_readme("""
# Lab Update 2025-10-26

## New Router Added
- Router3: 10.1.0.3/24
- SSH: admin / vault:router3-pass
- Role: Border router for internet access

## OSPF Updated
- Added Router3 to Area 0
- Redistributing default route from Router3

## Next Steps
- Configure NAT on Router3
- Test internet connectivity from clients
""")
```

## Template Usage Notes (v0.23.0)

**Templates have built-in usage notes** with default credentials, setup instructions, and important information about persistent storage.

### What Template Usage Contains

- **Default Credentials** - Username/password for pre-configured images
  - Example: "Username: ubuntu, Password: ubuntu"
  - Example: "The login is admin, with no password by default"
- **Setup Instructions** - First-boot procedures and installation details
  - Boot timing estimates (e.g., "On first boot, RouterOS is actually being installed...")
  - Console availability notes
- **Persistent Storage Info** - Which directories persist across reboots
  - Example: "The /root directory is persistent."
- **Configuration Guidance** - Device-specific quirks and recommendations

### Accessing Template Usage (Read-Only)

**For a specific template:**
```
Resource: gns3://templates/{template_id}
Returns: Full template details including usage field
```

**For a specific node (most common):**
```
Resource: projects://{project_id}/nodes/{node_id}/template
Returns: Template usage notes for that node
```

**Lazy Loading Pattern:**
- Template list (`projects://{id}/templates/`) excludes usage to keep lightweight
- Usage loaded separately only when needed to avoid context bloat
- Each node has `template_id` linking to its template

### Usage Examples

**Check default credentials before connecting:**
```
1. Get node details: projects://{id}/nodes/{node_id}
2. Note template_id from node
3. Check template usage: gns3://templates/{template_id}
4. See "Username: admin" in usage field
5. Use those credentials with ssh_configure()
```

**Find persistent storage directories:**
```
1. Browse node's template: projects://{id}/nodes/{node_id}/template
2. Look for "persistent" in usage field
3. Note which directories survive reboots
4. Store important data in those locations
```

**Best Practice:** Always check template usage before initial configuration to find default credentials and understand device-specific setup requirements.

## Lab Setup Automation (v0.18.0)

Use `lab_setup` prompt to create complete topologies automatically.

### Creating a Lab

The lab_setup prompt creates:
- Nodes positioned using layout algorithms
- Network links between nodes
- IP addressing schemes
- Complete topology diagrams

### Topology Types

**Star Topology** (Hub-and-Spoke):
```
lab_setup(topology_type="star", device_count=4)
```
- Creates: 1 hub router + 4 spoke routers
- Links: Hub-to-each-spoke
- IP: 10.0.{spoke}.0/24 per link

**Mesh Topology** (Full Mesh):
```
lab_setup(topology_type="mesh", device_count=4)
```
- Creates: 4 routers, all interconnected
- Links: N*(N-1)/2 point-to-point links
- IP: 10.0.{subnet}.0/30 per link

**Linear Topology** (Chain):
```
lab_setup(topology_type="linear", device_count=4)
```
- Creates: 4 routers in series (R1-R2-R3-R4)
- Links: Sequential connections
- IP: 10.0.{link}.0/30

**Ring Topology** (Circular):
```
lab_setup(topology_type="ring", device_count=4)
```
- Creates: 4 routers in a ring
- Links: Each router connects to two neighbors
- Closes the loop for redundancy

**OSPF Topology** (Multi-Area):
```
lab_setup(topology_type="ospf", device_count=3)
```
- Creates: 3 areas with Area 0 backbone
- Nodes: 3 routers per area + ABRs
- IP: 10.{area}.0.{router}/32 loopbacks

**BGP Topology** (Multiple AS):
```
lab_setup(topology_type="bgp", device_count=3)
```
- Creates: 3 autonomous systems
- Nodes: 2 routers per AS (iBGP peering)
- Links: eBGP between adjacent AS
- IP: 10.{AS}.1.0/30 (iBGP), 172.16.{link}.0/30 (eBGP)

### Customizing Labs

**Parameters:**
- `topology_type`: Required topology type (star/mesh/linear/ring/ospf/bgp)
- `device_count`: Number of devices/areas/AS (topology-specific)
- `template_name`: Device template (default: "Alpine Linux")
- `project_name`: Target project (uses current if not specified)

**Example:**
```
lab_setup("ospf", device_count=2,
          template_name="Cisco IOSv",
          project_name="OSPF Lab")
```

## Drawing Tools (v0.19.0 - Hybrid Architecture)

Create visual annotations on topology diagrams using drawing tools.

**Hybrid Pattern:**
- **READ**: Browse drawings via resource `projects://{id}/drawings/`
- **WRITE**: Modify drawings via tools (create_drawing, update_drawing, delete_drawing)

### Available Drawing Types

**Rectangle** - For site boundaries, network segments
```
create_drawing("rectangle", x=100, y=100, width=300, height=200,
               fill_color="#f0f0f0", border_color="#000000", z=0)
```

**Ellipse** - For cloud/WAN representations, circles
```
create_drawing("ellipse", x=200, y=200, rx=50, ry=50,
               fill_color="#ffffff", border_color="#0000ff", z=0)
```

**Line** - For connections, arrows, dividers
```
create_drawing("line", x=100, y=100, x2=200, y2=150,
               color="#ff0000", border_width=3, z=1)
```

**Text** - For labels, site names, annotations
```
create_drawing("text", x=150, y=50, text="Data Center A",
               font_size=14, font_weight="bold", color="#000000", z=1)
```

### Updating Drawings

Modify drawing properties:
```
update_drawing(drawing_id="abc123", x=120, y=80, rotation=45)
```

### Deleting Drawings

Remove drawing (⚠️ **DESTRUCTIVE**):
```
delete_drawing(drawing_id="abc123")
```

### Z-order Layers

- `z=0`: Background shapes (behind nodes)
- `z=1`: Foreground labels and annotations
- Higher z values appear in front

## Automation Tips

- **Always check status** before operations (is node started? is project open?)
- **Read before write** to console (check current state first)
- **Verify each step** before proceeding (don't assume success)
- **Handle errors gracefully** (node might not start immediately)
- **Clean up** console sessions when done
- **Use set_node** for node lifecycle operations (replaces start/stop)
- **Use set_connection** for topology changes (batch operations)

## Example Workflows

See `examples/` folder for:
- `ospf_lab.md` - Setting up OSPF routing between routers
- `bgp_lab.md` - Configuring BGP peering
- Common troubleshooting procedures
