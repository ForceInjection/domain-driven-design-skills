---
name: claude-code-service
description: Run Claude Code as a background service, web server, or API endpoint instead of CLI. Enable always-on Claude assistance, web UI access, API integrations, scheduled tasks, and automated workflows. Transform Claude Code from command-line tool to persistent service infrastructure.
---

# Claude Code as a Service

Transform Claude Code from a command-line tool into a persistent background service with web UI, API access, and automated workflows.

## Service Modes

### 1. Background Service (Daemon)
- Runs continuously in background
- Responds to system events
- Handles scheduled tasks
- Always-available Claude assistance

### 2. Web Server
- Browser-based UI
- Chat interface accessible at http://localhost:8080
- File upload/download
- Multi-session support

### 3. API Endpoint
- RESTful HTTP API
- Integration with other tools
- Programmatic access
- Webhook support

### 4. IDE Integration
- VS Code extension
- JetBrains plugin
- Sublime Text integration
- Direct editor access

## Quick Start

### Web Server Mode

**Start web server:**
```bash
# Basic web server
claude-code serve --port 8080

# With authentication
claude-code serve --port 8080 --auth

# With SSL
claude-code serve --port 8443 --ssl-cert cert.pem --ssl-key key.pem
```

**Access:** Open browser to `http://localhost:8080`

### Background Service Mode

**Start as daemon:**
```bash
# Run in background
claude-code daemon start

# Check status
claude-code daemon status

# Stop
claude-code daemon stop
```

## Installation as System Service

### Windows Service

**Install:**
```bash
# Using NSSM (Non-Sucking Service Manager)
# Download from: https://nssm.cc/

# Install service
nssm install ClaudeCode "C:\Python\python.exe" "C:\path\to\claude-code\serve.py"

# Configure
nssm set ClaudeCode AppDirectory "C:\path\to\claude-code"
nssm set ClaudeCode DisplayName "Claude Code Service"
nssm set ClaudeCode Description "Claude AI Assistant Service"

# Start service
nssm start ClaudeCode
```

**Or use PowerShell:**
```powershell
# Create service
New-Service -Name "ClaudeCode" `
  -BinaryPathName "C:\Python\python.exe C:\path\to\claude-code\serve.py" `
  -DisplayName "Claude Code Service" `
  -Description "Claude AI Assistant Service" `
  -StartupType Automatic

# Start service
Start-Service ClaudeCode
```

**Script-based installer:**
```bash
# Run installer
python scripts/install_windows_service.py

# Configure in config file
# Start from Services.msc
```

### macOS LaunchAgent

**Create LaunchAgent:**
```bash
# Run installer
python scripts/install_macos_service.py

# Or manually create plist
cat > ~/Library/LaunchAgents/com.anthropic.claudecode.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.anthropic.claudecode</string>
  
  <key>ProgramArguments</key>
  <array>
    <string>/usr/local/bin/python3</string>
    <string>/path/to/claude-code/serve.py</string>
    <string>--port</string>
    <string>8080</string>
  </array>
  
  <key>RunAtLoad</key>
  <true/>
  
  <key>KeepAlive</key>
  <true/>
  
  <key>StandardOutPath</key>
  <string>/tmp/claudecode.log</string>
  
  <key>StandardErrorPath</key>
  <string>/tmp/claudecode.error.log</string>
</dict>
</plist>
EOF

# Load service
launchctl load ~/Library/LaunchAgents/com.anthropic.claudecode.plist

# Check status
launchctl list | grep claudecode
```

**Start/Stop:**
```bash
# Start
launchctl start com.anthropic.claudecode

# Stop
launchctl stop com.anthropic.claudecode

# Unload
launchctl unload ~/Library/LaunchAgents/com.anthropic.claudecode.plist
```

### Linux Systemd Service

**Create systemd service:**
```bash
# Run installer
python scripts/install_linux_service.py

# Or manually create service file
cat > ~/.config/systemd/user/claude-code.service << 'EOF'
[Unit]
Description=Claude Code Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /path/to/claude-code/serve.py --port 8080
Restart=always
RestartSec=10

Environment="PATH=/usr/bin:/usr/local/bin"
WorkingDirectory=/path/to/claude-code

StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
EOF

# Reload systemd
systemctl --user daemon-reload

# Enable service (start on boot)
systemctl --user enable claude-code

# Start service
systemctl --user start claude-code

# Check status
systemctl --user status claude-code
```

**Manage service:**
```bash
# Start
systemctl --user start claude-code

# Stop
systemctl --user stop claude-code

# Restart
systemctl --user restart claude-code

# View logs
journalctl --user -u claude-code -f

# Disable
systemctl --user disable claude-code
```

## Web Server Implementation

### Basic Flask Server

**serve.py:**
```python
#!/usr/bin/env python3
"""
Claude Code Web Server
"""
from flask import Flask, render_template, request, jsonify, session
from flask_cors import CORS
import os
import sys

app = Flask(__name__)
app.secret_key = os.urandom(24)
CORS(app)

# Import Claude Code
from claude_code import ClaudeCode

claude = ClaudeCode()

@app.route('/')
def index():
    """Main chat interface"""
    return render_template('index.html')

@app.route('/api/chat', methods=['POST'])
def chat():
    """Chat endpoint"""
    data = request.json
    message = data.get('message', '')
    
    # Get response from Claude
    response = claude.chat(message)
    
    return jsonify({
        'response': response,
        'status': 'success'
    })

@app.route('/api/file/upload', methods=['POST'])
def upload_file():
    """File upload endpoint"""
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    file = request.files['file']
    # Process file
    result = claude.process_file(file)
    
    return jsonify(result)

@app.route('/api/status')
def status():
    """Health check"""
    return jsonify({
        'status': 'running',
        'version': '1.0.0'
    })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False)
```

### Web UI (HTML/JavaScript)

**templates/index.html:**
```html
<!DOCTYPE html>
<html>
<head>
    <title>Claude Code</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            margin: 0;
            padding: 0;
            background: #f5f5f5;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
        }
        .chat-box {
            background: white;
            border-radius: 8px;
            padding: 20px;
            min-height: 400px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .message {
            margin-bottom: 16px;
            padding: 12px;
            border-radius: 6px;
        }
        .message.user {
            background: #007bff;
            color: white;
            margin-left: 20%;
        }
        .message.claude {
            background: #f0f0f0;
            margin-right: 20%;
        }
        .input-container {
            display: flex;
            gap: 10px;
        }
        input[type="text"] {
            flex: 1;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
        }
        button {
            padding: 12px 24px;
            background: #007bff;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
        }
        button:hover {
            background: #0056b3;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Claude Code</h1>
        <div class="chat-box" id="chat-box"></div>
        <div class="input-container">
            <input type="text" id="message-input" placeholder="Ask Claude anything...">
            <button onclick="sendMessage()">Send</button>
        </div>
    </div>

    <script>
        async function sendMessage() {
            const input = document.getElementById('message-input');
            const message = input.value.trim();
            if (!message) return;

            // Add user message to chat
            addMessage(message, 'user');
            input.value = '';

            try {
                // Send to API
                const response = await fetch('/api/chat', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({ message })
                });

                const data = await response.json();
                
                // Add Claude's response
                addMessage(data.response, 'claude');
            } catch (error) {
                addMessage('Error: ' + error.message, 'claude');
            }
        }

        function addMessage(text, sender) {
            const chatBox = document.getElementById('chat-box');
            const messageDiv = document.createElement('div');
            messageDiv.className = `message ${sender}`;
            messageDiv.textContent = text;
            chatBox.appendChild(messageDiv);
            chatBox.scrollTop = chatBox.scrollHeight;
        }

        // Send on Enter key
        document.getElementById('message-input').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') sendMessage();
        });
    </script>
</body>
</html>
```

## API Endpoint Mode

### RESTful API

**API server with full REST endpoints:**
```python
#!/usr/bin/env python3
"""
Claude Code REST API
"""
from fastapi import FastAPI, File, UploadFile, HTTPException
from pydantic import BaseModel
import uvicorn

app = FastAPI(title="Claude Code API", version="1.0.0")

class ChatRequest(BaseModel):
    message: str
    context: str = None

class ChatResponse(BaseModel):
    response: str
    tokens_used: int

@app.post("/api/v1/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """Chat with Claude"""
    # Process message
    response = claude.chat(request.message, context=request.context)
    
    return ChatResponse(
        response=response,
        tokens_used=len(response) // 4  # Approximate
    )

@app.post("/api/v1/file/analyze")
async def analyze_file(file: UploadFile = File(...)):
    """Analyze uploaded file"""
    contents = await file.read()
    analysis = claude.analyze_file(contents, file.filename)
    
    return {"analysis": analysis}

@app.post("/api/v1/code/review")
async def review_code(code: str, language: str):
    """Code review"""
    review = claude.review_code(code, language)
    return {"review": review}

@app.get("/api/v1/health")
async def health_check():
    """Health check"""
    return {"status": "healthy", "version": "1.0.0"}

if __name__ == '__main__':
    uvicorn.run(app, host="0.0.0.0", port=8080)
```

**API Usage:**
```bash
# Chat
curl -X POST http://localhost:8080/api/v1/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello Claude"}'

# Upload file
curl -X POST http://localhost:8080/api/v1/file/analyze \
  -F "file=@document.pdf"

# Code review
curl -X POST http://localhost:8080/api/v1/code/review \
  -H "Content-Type: application/json" \
  -d '{"code": "def hello():\n    print(\"hi\")", "language": "python"}'
```

## Configuration

**config.yaml:**
```yaml
server:
  mode: "web"  # "web", "api", "daemon"
  host: "0.0.0.0"
  port: 8080
  ssl:
    enabled: false
    cert: "cert.pem"
    key: "key.pem"

authentication:
  enabled: true
  type: "basic"  # "basic", "token", "oauth"
  users:
    - username: "admin"
      password: "hashed_password"

claude:
  api_key: "${ANTHROPIC_API_KEY}"
  model: "claude-sonnet-4-20250514"
  max_tokens: 4096

logging:
  level: "INFO"
  file: "/var/log/claude-code/service.log"
  rotation: "daily"
  max_size: "100MB"

storage:
  sessions: "/var/lib/claude-code/sessions"
  uploads: "/var/lib/claude-code/uploads"
  
security:
  cors_origins: ["http://localhost:3000"]
  max_upload_size: "10MB"
  rate_limit:
    enabled: true
    requests_per_minute: 60
```

## Security

### Authentication

**Basic authentication:**
```python
from functools import wraps
from flask import request, Response

def check_auth(username, password):
    """Verify credentials"""
    return username == 'admin' and password == 'secret'

def authenticate():
    """Send 401 response"""
    return Response(
        'Authentication required', 401,
        {'WWW-Authenticate': 'Basic realm="Login Required"'}
    )

def requires_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth = request.authorization
        if not auth or not check_auth(auth.username, auth.password):
            return authenticate()
        return f(*args, **kwargs)
    return decorated

@app.route('/api/chat', methods=['POST'])
@requires_auth
def chat():
    # Protected endpoint
    pass
```

**Token-based authentication:**
```python
from functools import wraps
from flask import request, jsonify

API_TOKENS = {
    'token123': 'user1',
    'token456': 'user2'
}

def require_token(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization', '').replace('Bearer ', '')
        if token not in API_TOKENS:
            return jsonify({'error': 'Invalid token'}), 401
        return f(*args, **kwargs)
    return decorated

@app.route('/api/chat', methods=['POST'])
@require_token
def chat():
    # Protected with token
    pass
```

### SSL/TLS

**Run with HTTPS:**
```bash
# Generate self-signed certificate
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes

# Run with SSL
python serve.py --ssl-cert cert.pem --ssl-key key.pem
```

**In Flask:**
```python
if __name__ == '__main__':
    app.run(
        host='0.0.0.0',
        port=8443,
        ssl_context=('cert.pem', 'key.pem')
    )
```

### Rate Limiting

```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["60 per minute"]
)

@app.route('/api/chat', methods=['POST'])
@limiter.limit("10 per minute")
def chat():
    # Rate limited endpoint
    pass
```

## Automated Workflows

### Scheduled Tasks

**Using APScheduler:**
```python
from apscheduler.schedulers.background import BackgroundScheduler
import atexit

scheduler = BackgroundScheduler()

@scheduler.scheduled_job('cron', hour=9)
def morning_summary():
    """Daily morning summary"""
    summary = claude.generate_summary(period='yesterday')
    send_email(summary)

@scheduler.scheduled_job('interval', minutes=30)
def check_emails():
    """Check for urgent emails"""
    urgent = check_urgent_emails()
    if urgent:
        notify(urgent)

scheduler.start()
atexit.register(lambda: scheduler.shutdown())
```

### Webhook Integration

**Receive webhooks:**
```python
@app.route('/webhook/github', methods=['POST'])
def github_webhook():
    """Handle GitHub webhook"""
    payload = request.json
    
    if payload['action'] == 'opened':
        # New PR opened
        pr = payload['pull_request']
        review = claude.review_pr(pr)
        post_github_comment(pr['number'], review)
    
    return jsonify({'status': 'processed'})

@app.route('/webhook/slack', methods=['POST'])
def slack_webhook():
    """Handle Slack command"""
    command = request.form['text']
    response = claude.chat(command)
    
    return jsonify({
        'response_type': 'in_channel',
        'text': response
    })
```

## Monitoring and Logging

### Logging Setup

```python
import logging
from logging.handlers import RotatingFileHandler

# Configure logging
handler = RotatingFileHandler(
    'claude-code.log',
    maxBytes=10*1024*1024,  # 10MB
    backupCount=5
)
handler.setFormatter(logging.Formatter(
    '%(asctime)s %(levelname)s: %(message)s'
))

app.logger.addHandler(handler)
app.logger.setLevel(logging.INFO)
```

### Health Monitoring

```python
@app.route('/health')
def health():
    """Health check endpoint"""
    checks = {
        'database': check_database(),
        'api': check_claude_api(),
        'disk': check_disk_space(),
        'memory': check_memory()
    }
    
    all_healthy = all(checks.values())
    status_code = 200 if all_healthy else 503
    
    return jsonify({
        'status': 'healthy' if all_healthy else 'unhealthy',
        'checks': checks
    }), status_code
```

### Metrics

**Prometheus metrics:**
```python
from prometheus_client import Counter, Histogram, generate_latest

REQUEST_COUNT = Counter('requests_total', 'Total requests')
REQUEST_LATENCY = Histogram('request_latency_seconds', 'Request latency')

@app.before_request
def before_request():
    request.start_time = time.time()

@app.after_request
def after_request(response):
    REQUEST_COUNT.inc()
    REQUEST_LATENCY.observe(time.time() - request.start_time)
    return response

@app.route('/metrics')
def metrics():
    return generate_latest()
```

## Docker Deployment

**Dockerfile:**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Expose port
EXPOSE 8080

# Run service
CMD ["python", "serve.py", "--port", "8080"]
```

**docker-compose.yml:**
```yaml
version: '3.8'

services:
  claude-code:
    build: .
    ports:
      - "8080:8080"
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
    volumes:
      - ./data:/app/data
    restart: unless-stopped
```

**Run:**
```bash
# Build
docker-compose build

# Start
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

## IDE Integration Examples

### VS Code Extension

**package.json:**
```json
{
  "name": "claude-code-extension",
  "version": "1.0.0",
  "engines": {
    "vscode": "^1.70.0"
  },
  "activationEvents": ["*"],
  "main": "./extension.js",
  "contributes": {
    "commands": [
      {
        "command": "claudecode.askClaude",
        "title": "Ask Claude"
      }
    ]
  }
}
```

### Sublime Text Plugin

**claude_code.py:**
```python
import sublime
import sublime_plugin
import requests

class AskClaudeCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        # Get selected text
        selection = self.view.substr(self.view.sel()[0])
        
        # Send to Claude Code service
        response = requests.post(
            'http://localhost:8080/api/chat',
            json={'message': selection}
        )
        
        # Insert response
        result = response.json()['response']
        self.view.insert(edit, self.view.sel()[0].end(), '\n\n' + result)
```

## Scripts Reference

**Installation:**
- `install_windows_service.py` - Windows service installer
- `install_macos_service.py` - macOS LaunchAgent installer
- `install_linux_service.py` - Linux systemd installer

**Server:**
- `serve.py` - Web server
- `api_server.py` - API endpoint server
- `daemon.py` - Background daemon

**Management:**
- `start_service.py` - Start service
- `stop_service.py` - Stop service
- `status.py` - Check status
- `configure.py` - Interactive configuration

## Best Practices

1. **Security first** - Always use authentication for public-facing services
2. **Monitor resources** - Track memory and CPU usage
3. **Implement logging** - Debug issues effectively
4. **Rate limiting** - Prevent abuse
5. **Error handling** - Graceful failure recovery
6. **Auto-restart** - Use service managers for reliability
7. **Backup configuration** - Save settings regularly
8. **Update regularly** - Keep dependencies current

## Troubleshooting

**Service won't start**
```bash
# Check logs
# Linux: journalctl --user -u claude-code
# macOS: tail -f /tmp/claudecode.error.log
# Windows: Event Viewer

# Verify Python path
which python3

# Test manually
python3 serve.py --port 8080
```

**Port already in use**
```bash
# Find process
# Linux/macOS: lsof -i :8080
# Windows: netstat -ano | findstr :8080

# Kill process or use different port
python serve.py --port 8081
```

**Permission denied**
```
# Linux/macOS: May need sudo for ports < 1024
# Or use port > 1024 (recommended)

# Windows: Run as Administrator
```

## Reference Documentation

- [reference/service-architecture.md](reference/service-architecture.md) - Architecture overview
- [reference/api-specification.md](reference/api-specification.md) - Complete API docs
- [reference/deployment-guide.md](reference/deployment-guide.md) - Production deployment
- [reference/security-guide.md](reference/security-guide.md) - Security best practices
- [reference/integration-guide.md](reference/integration-guide.md) - IDE and tool integration
