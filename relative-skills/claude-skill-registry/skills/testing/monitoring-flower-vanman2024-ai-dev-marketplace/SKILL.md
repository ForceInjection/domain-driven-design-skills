---
name: monitoring-flower
description: Flower monitoring setup and configuration for Celery including real-time monitoring, authentication, custom dashboards, and Prometheus metrics integration. Use when setting up Celery monitoring, configuring Flower web UI, implementing authentication, creating custom dashboards, integrating with Prometheus, or when user mentions Flower, Celery monitoring, task monitoring, worker monitoring, or real-time metrics.
allowed-tools: Bash, Read, Write, Edit
---

# Flower Monitoring Skill

This skill provides comprehensive templates and configurations for setting up Flower, the real-time monitoring tool for Celery. Includes authentication, custom dashboards, Prometheus metrics integration, and production deployment patterns.

## Overview

Flower is a web-based monitoring and administration tool for Celery that provides:

1. **Real-time Monitoring** - Worker status, task progress, event tracking
2. **Task Management** - View, revoke, and retry tasks
3. **Authentication** - Basic auth, OAuth, and custom authentication
4. **Metrics Export** - Prometheus integration for external monitoring
5. **Custom Dashboards** - Tailored views for specific workflows

This skill covers production-ready Flower deployments with security and scalability.

## Available Scripts

### 1. Start Flower Server

**Script**: `scripts/start-flower.sh <broker-url> <port>`

**Purpose**: Starts Flower monitoring server with proper configuration

**Parameters**:
- `broker-url` - Redis/RabbitMQ broker URL (default: redis://localhost:6379/0)
- `port` - Port to run Flower on (default: 5555)

**Usage**:
```bash
# Start with default settings
./scripts/start-flower.sh

# Start with custom Redis broker
./scripts/start-flower.sh redis://redis:6379/0 5555

# Start with RabbitMQ
./scripts/start-flower.sh amqp://guest:guest@localhost:5672// 5555

# Start with authentication
FLOWER_BASIC_AUTH="user:password" ./scripts/start-flower.sh
```

**Environment Variables**:
- `FLOWER_BASIC_AUTH` - Basic auth credentials (user:password)
- `FLOWER_OAUTH2_REDIRECT_URI` - OAuth2 redirect URI
- `FLOWER_MAX_TASKS` - Maximum tasks to keep in memory (default: 10000)

**Output**: Flower web UI available at http://localhost:5555

### 2. Install Flower as Systemd Service

**Script**: `scripts/flower-systemd.service`

**Purpose**: Systemd service file for production Flower deployment

**Usage**:
```bash
# Copy service file
sudo cp scripts/flower-systemd.service /etc/systemd/system/flower.service

# Edit service file with your paths
sudo nano /etc/systemd/system/flower.service

# Reload systemd
sudo systemctl daemon-reload

# Enable and start service
sudo systemctl enable flower
sudo systemctl start flower

# Check status
sudo systemctl status flower
```

**Configuration Points**:
- `WorkingDirectory` - Your project directory
- `User` - User to run service as
- `Environment` - Broker URL and authentication
- `ExecStart` - Flower command with options

### 3. Test Flower Configuration

**Script**: `scripts/test-flower.sh <flower-url>`

**Purpose**: Validates Flower setup and connectivity

**Checks**:
- Flower web UI accessible
- Worker nodes visible
- Task history available
- Metrics endpoint working
- Authentication configured
- No security warnings

**Usage**:
```bash
# Test local Flower instance
./scripts/test-flower.sh http://localhost:5555

# Test with authentication
./scripts/test-flower.sh http://user:password@localhost:5555

# Test production instance
./scripts/test-flower.sh https://flower.example.com
```

**Exit Codes**:
- `0` - All checks passed
- `1` - Flower not accessible
- `2` - No workers detected
- `3` - Authentication issues

## Available Templates

### 1. Flower Configuration

**Template**: `templates/flower-config.py`

**Purpose**: Complete Flower configuration file with all options

**Features**:
- Broker and backend URLs
- Port and address binding
- Task retention settings
- URL prefix for reverse proxy
- Database persistence
- Max workers and tasks

**Usage**:
```python
# Save as flowerconfig.py in your project
# Flower will auto-detect this file

# Or specify explicitly:
celery -A myapp flower --conf=flowerconfig.py
```

**Key Configuration Options**:
- `broker_api` - Broker management API URL
- `persistent` - Enable database persistence
- `db` - SQLite database path
- `max_tasks` - Task history limit
- `url_prefix` - Prefix for reverse proxy

### 2. Flower Authentication

**Template**: `templates/flower-auth.py`

**Purpose**: Authentication configurations including basic auth and OAuth

**Authentication Methods**:

**Basic Authentication**:
```python
# Username/password protection
flower --basic_auth=user1:password1,user2:password2
```

**OAuth2 (Google)**:
```python
# Google OAuth integration
flower \
  --auth=".*@example\.com" \
  --oauth2_key=your_google_client_id_here \
  --oauth2_secret=your_google_client_secret_here \
  --oauth2_redirect_uri=http://localhost:5555/login
```

**Custom Authentication**:
```python
# Implement custom auth provider
from flower.views.auth import Auth

class CustomAuth(Auth):
    def authenticate(self, username, password):
        # Your authentication logic
        return username in allowed_users
```

**Security Notes**:
- Never hardcode credentials in config files
- Use environment variables for secrets
- Enable HTTPS in production
- Implement rate limiting
- Use OAuth for team access

### 3. Prometheus Metrics

**Template**: `templates/prometheus-metrics.py`

**Purpose**: Export Celery metrics to Prometheus

**Metrics Exposed**:
- `celery_tasks_total` - Total tasks by state
- `celery_workers_online` - Active worker count
- `celery_task_runtime_seconds` - Task execution time
- `celery_queue_length` - Queue depth by queue name

**Usage**:
```python
# Run metrics exporter alongside Flower
python templates/prometheus-metrics.py

# Metrics available at http://localhost:8000/metrics
```

**Prometheus Scrape Config**:
```yaml
scrape_configs:
  - job_name: 'celery'
    static_configs:
      - targets: ['localhost:8000']
```

**Grafana Integration**:
- Import Celery dashboard template
- Connect to Prometheus data source
- Visualize task rates, queue depths, worker health

### 4. Custom Dashboard

**Template**: `templates/custom-dashboard.py`

**Purpose**: Create custom Flower views for specific workflows

**Custom Views**:
- Task filtering by type
- Worker grouping by role
- Custom metrics display
- Workflow-specific dashboards

**Implementation**:
```python
from flower.views import BaseHandler

class CustomDashboard(BaseHandler):
    def get(self):
        # Your custom dashboard logic
        self.render("custom_dashboard.html", data=data)
```

**Template Variables**:
- `workers` - Active worker list
- `tasks` - Recent task history
- `queues` - Queue statistics
- `custom_metrics` - Your computed metrics

## Available Examples

### 1. Complete Flower Setup

**Example**: `examples/flower-setup.md`

**Covers**:
- Initial Flower installation
- Configuration file setup
- Authentication implementation
- Systemd service creation
- Reverse proxy configuration (Nginx)
- SSL/TLS setup
- Monitoring integration

**Step-by-Step Guide**:
1. Install Flower: `pip install flower`
2. Create configuration file
3. Configure authentication
4. Test locally
5. Deploy as systemd service
6. Configure reverse proxy
7. Enable SSL
8. Connect monitoring tools

**Production Checklist**:
- [ ] Authentication enabled
- [ ] HTTPS configured
- [ ] Database persistence enabled
- [ ] Task retention limits set
- [ ] Resource limits configured
- [ ] Monitoring integrated
- [ ] Backup strategy defined

### 2. Prometheus Integration

**Example**: `examples/prometheus-integration.md`

**Covers**:
- Metrics exporter setup
- Prometheus configuration
- Grafana dashboard creation
- Alerting rules
- Performance optimization

**Metrics Collection**:
```python
# Key metrics to monitor
- Task success/failure rates
- Average task duration
- Queue depths
- Worker availability
- Task retries
- Error rates by task type
```

**Alert Examples**:
- High task failure rate
- Queue depth exceeding threshold
- Worker offline detection
- Slow task execution
- Memory usage alerts

### 3. Custom Dashboards

**Example**: `examples/custom-dashboards.md`

**Covers**:
- Creating custom views
- Template customization
- Adding custom metrics
- Filtering and grouping
- Real-time updates

**Use Cases**:
- ML training job monitoring
- ETL pipeline tracking
- Report generation status
- Video processing workflows
- Multi-tenant task views

**Custom View Features**:
- Task filtering by tags
- Worker grouping by zone
- Custom time ranges
- Export capabilities
- Email notifications

## Security Compliance

**CRITICAL:** This skill follows strict security rules:

❌ **NEVER hardcode:**
- Basic auth credentials
- OAuth client secrets
- API keys
- Database passwords
- Broker credentials

✅ **ALWAYS:**
- Use environment variables for secrets
- Generate `.env.example` with placeholders
- Add `.env*` to `.gitignore`
- Use HTTPS in production
- Implement authentication
- Enable rate limiting
- Document credential requirements

**Placeholder format:**
```bash
# .env.example
FLOWER_BASIC_AUTH=username_your_password_here
FLOWER_OAUTH2_KEY=your_google_client_id_here
FLOWER_OAUTH2_SECRET=your_google_client_secret_here
CELERY_BROKER_URL=redis_your_password_here@localhost:6379/0
```

## Progressive Disclosure

This skill provides immediate setup guidance with references to detailed documentation:

- **Quick Start**: Use `start-flower.sh` for immediate local setup
- **Production**: Reference `flower-setup.md` for complete deployment guide
- **Metrics**: Use `prometheus-metrics.py` for monitoring integration
- **Custom Views**: Reference `custom-dashboards.md` for advanced customization

Load additional files only when specific customization is needed.

## Common Workflows

### 1. Local Development Setup

```bash
# Install Flower
pip install flower

# Start with basic auth
FLOWER_BASIC_AUTH="dev:dev_password_here" \
  ./scripts/start-flower.sh redis://localhost:6379/0 5555

# Access at http://localhost:5555
```

### 2. Production Deployment

```bash
# 1. Configure authentication
cp templates/flower-auth.py flowerconfig.py
# Edit with environment-specific settings

# 2. Install systemd service
sudo cp scripts/flower-systemd.service /etc/systemd/system/flower.service
sudo systemctl enable flower
sudo systemctl start flower

# 3. Configure Nginx reverse proxy
# 4. Enable SSL with Let's Encrypt
# 5. Test connectivity
./scripts/test-flower.sh https://flower.example.com
```

### 3. Metrics Integration

```bash
# 1. Start Prometheus metrics exporter
python templates/prometheus-metrics.py &

# 2. Configure Prometheus scraping
# 3. Import Grafana dashboard
# 4. Set up alerting rules
```

## Troubleshooting

### Flower Won't Start

**Check**:
- Broker URL is correct and accessible
- Port is not already in use
- Virtual environment is activated
- Celery workers are running

**Debug**:
```bash
# Test broker connectivity
celery -A myapp inspect ping

# Check port availability
lsof -i :5555

# Run with verbose logging
celery -A myapp flower --logging=debug
```

### Workers Not Visible

**Check**:
- Workers are running and connected to same broker
- Flower is monitoring correct broker
- No firewall blocking connections
- Worker events are enabled

**Fix**:
```bash
# Enable events on workers
celery -A myapp control enable_events

# Verify broker URL matches
echo $CELERY_BROKER_URL
```

### Authentication Issues

**Check**:
- Credentials are properly formatted
- OAuth redirect URI is correct
- No typos in username/password
- Environment variables are set

**Debug**:
```bash
# Test basic auth
curl -u username:password http://localhost:5555

# Check OAuth configuration
curl http://localhost:5555/login
```

## Dependencies

**Required**:
- `flower>=2.0.0` - Flower monitoring tool
- `celery>=5.3.0` - Celery task queue
- `redis>=4.5.0` or `kombu>=5.3.0` - Broker client

**Optional**:
- `prometheus-client>=0.16.0` - For Prometheus metrics
- `tornado>=6.0` - For async support
- `SQLAlchemy>=2.0.0` - For persistent storage

**Installation**:
```bash
# Basic installation
pip install flower

# With Prometheus metrics
pip install flower prometheus-client

# With persistent storage
pip install flower sqlalchemy
```

## Best Practices

1. **Authentication**: Always enable authentication in production
2. **Task Retention**: Set `max_tasks` to prevent memory issues
3. **Database Persistence**: Use SQLite/PostgreSQL for task history
4. **Reverse Proxy**: Run behind Nginx/Caddy for SSL and rate limiting
5. **Monitoring**: Export metrics to Prometheus/Grafana
6. **Resource Limits**: Configure systemd limits for production
7. **Backup**: Regularly backup Flower database if using persistence

## Additional Resources

- **Flower Documentation**: https://flower.readthedocs.io/
- **Celery Monitoring Guide**: https://docs.celeryq.dev/en/stable/userguide/monitoring.html
- **Prometheus Integration**: https://prometheus.io/docs/instrumenting/exporters/
- **Production Deployment**: Reference `examples/flower-setup.md`
