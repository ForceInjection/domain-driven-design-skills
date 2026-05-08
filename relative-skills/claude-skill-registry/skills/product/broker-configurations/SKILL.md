---
name: broker-configurations
description: Message broker setup patterns (Redis, RabbitMQ, SQS) for Celery including connection strings, SSL configuration, high availability, and production best practices. Use when configuring message brokers, setting up Redis/RabbitMQ/SQS, troubleshooting broker connections, implementing HA/failover, securing broker communications with SSL, or when user mentions broker setup, connection issues, sentinel, quorum queues, or AWS SQS integration.
allowed-tools: Read, Bash, Grep, Glob
---

# Broker Configurations

**Purpose:** Comprehensive message broker configuration for Celery with production-ready patterns for Redis, RabbitMQ, and Amazon SQS.

**Activation Triggers:**
- Broker connection errors
- Setting up new Celery project
- Implementing high availability
- SSL/TLS configuration needed
- Performance tuning required
- Multi-broker comparison
- Cloud deployment (AWS/GCP/Azure)
- Sentinel or cluster setup

**Key Resources:**
- `templates/redis-config.py` - Production Redis configuration
- `templates/rabbitmq-config.py` - RabbitMQ with quorum queues
- `templates/sqs-config.py` - AWS SQS with IAM roles
- `templates/connection-strings.env` - Connection string formats
- `templates/ssl-config.py` - SSL/TLS configuration
- `scripts/test-broker-connection.sh` - Connection testing
- `scripts/setup-redis.sh` - Redis installation and configuration
- `scripts/setup-rabbitmq.sh` - RabbitMQ cluster setup
- `examples/redis-sentinel.md` - High availability with Sentinel
- `examples/rabbitmq-ha.md` - RabbitMQ clustering and quorum queues
- `examples/sqs-setup.md` - Complete AWS SQS integration

## Broker Selection Guide

### Quick Comparison

| Feature | Redis | RabbitMQ | SQS |
|---------|-------|----------|-----|
| **Performance** | Excellent (small msgs) | Very Good | Good |
| **Reliability** | Good (with Sentinel) | Excellent (quorum) | Excellent |
| **Monitoring** | Yes | Yes | Limited |
| **Remote Control** | Yes | Yes | No |
| **Management** | Manual/Cloud | Manual | Fully Managed |
| **Cost** | Server/Cloud | Server/Cloud | Pay-per-use |
| **Best For** | Speed, simple setup | Reliability, features | AWS, serverless |

### Decision Matrix

**Choose Redis when:**
- Need maximum speed for small messages
- Want simple setup and maintenance
- Already using Redis for caching/results
- Budget for managed Redis (Upstash, ElastiCache)
- Can accept brief downtime during failover

**Choose RabbitMQ when:**
- Need guaranteed message delivery
- Require complex routing patterns
- Need worker remote control features
- Want built-in monitoring and management UI
- Have dedicated ops team for management

**Choose SQS when:**
- Running on AWS infrastructure
- Want zero operational overhead
- Need unlimited automatic scaling
- Prefer pay-per-use pricing
- Don't need worker remote control

## Redis Broker Setup

### 1. Basic Configuration

```bash
# Install dependencies
pip install "celery[redis]"

# Use template
cp templates/redis-config.py celeryconfig.py

# Configure environment
cp templates/connection-strings.env .env
# Edit .env with actual values
```

**Key settings:**
```python
# templates/redis-config.py
broker_url = 'redis://:password@localhost:6379/0'

broker_transport_options = {
    'visibility_timeout': 3600,
    'retry_on_timeout': True,
    'max_connections': 50,
}
```

### 2. Production Settings

**CRITICAL:** Set `maxmemory-policy noeviction` in Redis config:
```bash
# Run setup script
./scripts/setup-redis.sh --install --configure

# Or manually
redis-cli CONFIG SET maxmemory-policy noeviction
```

**Why:** Prevents Redis from evicting task data, which would cause task loss.

### 3. High Availability with Sentinel

```bash
# See comprehensive guide
cat examples/redis-sentinel.md

# Quick setup
docker-compose -f examples/docker-compose.sentinel.yml up -d

# Configure Celery for Sentinel
CELERY_BROKER_URL='sentinel://host1:26379;host2:26379;host3:26379/0'
```

**Connection string format:**
```python
# Sentinel URL
broker_url = 'sentinel://sentinel1:26379;sentinel2:26379/0'

broker_transport_options = {
    'master_name': 'mymaster',
    'sentinel_kwargs': {'password': 'sentinel_password'},
}
```

## RabbitMQ Broker Setup

### 1. Basic Configuration

```bash
# Install dependencies
pip install "celery[amqp]"

# Use template
cp templates/rabbitmq-config.py celeryconfig.py

# Run setup script
./scripts/setup-rabbitmq.sh --install --configure
```

**Key settings:**
```python
# templates/rabbitmq-config.py
broker_url = 'amqp://user:password@localhost:5672/vhost'

# CRITICAL for quorum queues
broker_transport_options = {
    'confirm_publish': True,  # Required!
}
```

### 2. Quorum Queues (Recommended)

**Provides:**
- Automatic replication
- Leader election on failure
- No message loss

```python
from kombu import Queue

task_queues = (
    Queue(
        'default',
        queue_arguments={
            'x-queue-type': 'quorum',
            'x-delivery-limit': 3,
        }
    ),
)
```

### 3. High Availability Cluster

```bash
# See comprehensive guide
cat examples/rabbitmq-ha.md

# Docker cluster setup
docker-compose -f examples/docker-compose.rabbitmq-cluster.yml up -d

# Verify cluster
docker exec rabbitmq-1 rabbitmqctl cluster_status
```

**HAProxy load balancing:**
```yaml
# Distribute connections across cluster
broker_url = 'amqp://user:password@haproxy:5670/vhost'
```

## AWS SQS Broker Setup

### 1. IAM Configuration

```bash
# Create IAM policy and user
aws iam create-policy \
  --policy-name CelerySQSPolicy \
  --policy-document file://examples/celery-sqs-policy.json

# Or use IAM role (recommended for EC2/ECS)
# See examples/sqs-setup.md for complete guide
```

### 2. Basic Configuration

```bash
# Install dependencies
pip install "celery[sqs]"

# Use template
cp templates/sqs-config.py celeryconfig.py
```

**With IAM role (recommended):**
```python
# No credentials needed
broker_url = 'sqs://'

broker_transport_options = {
    'region': 'us-east-1',
    'visibility_timeout': 3600,
    'polling_interval': 1,
    'wait_time_seconds': 10,  # Long polling
}
```

**With explicit credentials:**
```python
broker_url = 'sqs://access_key:secret_key@'
```

### 3. FIFO Queues

**For ordered task processing:**
```python
task_queues = (
    Queue(
        'celery-default.fifo',
        queue_arguments={
            'FifoQueue': 'true',
            'ContentBasedDeduplication': 'true',
        }
    ),
)

# Send with message group ID
task.apply_async(
    args=[data],
    properties={'MessageGroupId': 'user-123'}
)
```

### 4. Result Backend

**SQS doesn't support results - use S3 or DynamoDB:**
```python
# Option 1: S3
result_backend = 's3://my-bucket/celery-results/'

# Option 2: DynamoDB
result_backend = 'dynamodb://'
result_backend_transport_options = {
    'table_name': 'celery-results',
}

# Option 3: Redis (hybrid)
result_backend = 'redis://redis.example.com:6379/0'
```

## SSL/TLS Configuration

### 1. Redis with SSL

```python
# Use templates/ssl-config.py
from templates.ssl_config import app

# Or manually
broker_url = 'rediss://password@host:6380/0'  # Note: rediss://

broker_use_ssl = {
    'ssl_cert_reqs': ssl.CERT_REQUIRED,
    'ssl_ca_certs': '/path/to/ca.pem',
    'ssl_certfile': '/path/to/client-cert.pem',
    'ssl_keyfile': '/path/to/client-key.pem',
}
```

### 2. RabbitMQ with SSL

```python
broker_url = 'amqps://user:password@host:5671/vhost'  # Note: amqps://

broker_use_ssl = {
    'ssl_cert_reqs': ssl.CERT_REQUIRED,
    'ssl_ca_certs': '/path/to/ca.pem',
    'ssl_certfile': '/path/to/client-cert.pem',
    'ssl_keyfile': '/path/to/client-key.pem',
}
```

### 3. Environment Variables

```bash
# .env
BROKER_SSL_ENABLED=true
BROKER_SSL_CERT=/path/to/client-cert.pem
BROKER_SSL_KEY=/path/to/client-key.pem
BROKER_SSL_CA=/path/to/ca-cert.pem
BROKER_SSL_VERIFY_MODE=CERT_REQUIRED
```

## Testing and Validation

### 1. Test Connection

```bash
# Test any broker type
./scripts/test-broker-connection.sh redis
./scripts/test-broker-connection.sh rabbitmq
./scripts/test-broker-connection.sh sqs

# Check specific features
./scripts/test-broker-connection.sh redis --ssl
```

**Script checks:**
- Broker connectivity
- Authentication
- SSL/TLS validation
- Configuration correctness
- Performance baseline

### 2. Python Test

```python
from celery import Celery

app = Celery(broker='redis://localhost:6379/0')

# Test connection
try:
    with app.connection() as conn:
        conn.ensure_connection(max_retries=3, timeout=5)
        print("✅ Connection successful")
except Exception as e:
    print(f"❌ Connection failed: {e}")
```

## Common Issues and Solutions

### Redis: "maxmemory-policy not noeviction"

**Problem:** Redis evicting task data
**Solution:**
```bash
./scripts/setup-redis.sh --configure
# Or manually:
redis-cli CONFIG SET maxmemory-policy noeviction
```

### RabbitMQ: "Basic.publish: NOT_FOUND"

**Problem:** Queue doesn't exist or wrong vhost
**Solution:**
```bash
# Check vhost
rabbitmqctl list_vhosts

# Check permissions
rabbitmqctl list_permissions -p /celery_vhost
```

### SQS: "Access Denied"

**Problem:** IAM permissions insufficient
**Solution:**
```bash
# Verify IAM policy includes all required actions
# See examples/sqs-setup.md for complete policy

# Test credentials
aws sts get-caller-identity
aws sqs list-queues --queue-name-prefix celery-
```

### Connection Timeout

**Problem:** Network/firewall blocking connection
**Solution:**
```bash
# Test network connectivity
telnet broker-host 6379  # Redis
telnet broker-host 5672  # RabbitMQ

# Check firewall rules
# Verify security groups (AWS)
# Check iptables rules
```

## Performance Tuning

### Redis Optimization

```python
broker_transport_options = {
    'visibility_timeout': 3600,
    'max_connections': 100,  # Increase for high concurrency
    'socket_timeout': 5.0,
    'socket_keepalive': True,
    'health_check_interval': 30,
}

# Worker settings
worker_prefetch_multiplier = 4  # Prefetch 4x concurrency
worker_max_tasks_per_child = 1000
```

### RabbitMQ Optimization

```python
broker_transport_options = {
    'confirm_publish': True,
    'max_retries': 3,
}

# Use quorum queues for reliability
# Adjust prefetch for throughput
worker_prefetch_multiplier = 4

# Disable QoS for maximum speed (classic queues only)
# Note: Not compatible with worker autoscaling
```

### SQS Optimization

```python
# Reduce API calls (costs)
broker_transport_options = {
    'polling_interval': 5,  # Poll less frequently
    'wait_time_seconds': 20,  # Max long polling
}

# CRITICAL: Prevent visibility timeout
worker_prefetch_multiplier = 1  # Must be 1 for SQS
```

## Monitoring

### Key Metrics

**Redis:**
- Connection count: `INFO clients`
- Memory usage: `INFO memory`
- Key count: `DBSIZE`
- Commands/sec: `INFO stats`

**RabbitMQ:**
- Queue length: `rabbitmqctl list_queues`
- Consumer count: Check management UI
- Memory usage: `rabbitmqctl status`
- Message rate: Check management UI

**SQS:**
- `ApproximateNumberOfMessagesVisible`: Queue backlog
- `NumberOfMessagesSent`: Task creation rate
- `NumberOfMessagesReceived`: Task completion rate
- `NumberOfEmptyReceives`: Polling efficiency

### Health Check Script

```bash
#!/bin/bash
# health-check.sh

BROKER_TYPE="${1:-redis}"

case "$BROKER_TYPE" in
  redis)
    redis-cli PING || exit 1
    ;;
  rabbitmq)
    rabbitmqctl status || exit 1
    ;;
  sqs)
    aws sqs list-queues --queue-name-prefix celery- || exit 1
    ;;
esac

echo "✅ Broker healthy"
```

## Security Best Practices

### 1. Authentication

- **Redis:** Always set `requirepass`
- **RabbitMQ:** Use strong passwords, dedicated vhosts
- **SQS:** Use IAM roles, not access keys

### 2. Network Security

- Use SSL/TLS for production
- Configure firewalls/security groups
- Use VPC/private networks when possible
- Restrict broker access to worker nodes only

### 3. Access Control

- Principle of least privilege
- Separate credentials per environment
- Rotate passwords regularly
- Use secret management (Vault, Doppler, AWS Secrets Manager)

### 4. Monitoring

- Enable audit logging
- Monitor authentication failures
- Alert on configuration changes
- Track connection patterns

## Resources

**Templates:**
- `redis-config.py` - Production Redis configuration
- `rabbitmq-config.py` - RabbitMQ with quorum queues
- `sqs-config.py` - AWS SQS with IAM
- `connection-strings.env` - All connection formats
- `ssl-config.py` - SSL/TLS configuration

**Scripts:**
- `test-broker-connection.sh` - Test any broker
- `setup-redis.sh` - Redis installation and config
- `setup-rabbitmq.sh` - RabbitMQ cluster setup

**Examples:**
- `redis-sentinel.md` - High availability setup
- `rabbitmq-ha.md` - Clustering and quorum queues
- `sqs-setup.md` - Complete AWS integration

**Documentation:**
- Redis: https://redis.io/docs/
- RabbitMQ: https://www.rabbitmq.com/documentation.html
- SQS: https://docs.aws.amazon.com/sqs/
- Celery Brokers: https://docs.celeryq.dev/en/stable/getting-started/backends-and-brokers/

---

**Version:** 1.0.0
**Celery Compatibility:** 5.0+
**Supported Brokers:** Redis 6+, RabbitMQ 3.8+, Amazon SQS

## Security Compliance

This skill follows strict security rules:
- All code examples use placeholder values only
- No real API keys, passwords, or secrets
- Environment variable references in all code
- `.gitignore` protection documented
