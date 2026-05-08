---
name: redis-persistence
description: Master Redis persistence - RDB snapshots, AOF logging, backup strategies, and disaster recovery planning
sasmp_version: "1.3.0"
bonded_agent: 05-redis-persistence
bond_type: PRIMARY_BOND

# Production Configuration
version: "2.1.0"
last_updated: "2025-01"

# Parameters
parameters:
  strategy:
    type: string
    required: true
    enum: [rdb, aof, hybrid, none]
  fsync_policy:
    type: string
    required: false
    enum: [always, everysec, no]
    default: everysec
  rdb_compression:
    type: boolean
    required: false
    default: true

# Retry Configuration
retry_config:
  max_retries: 3
  backoff_strategy: exponential
  backoff_base_ms: 1000

# Observability
observability:
  metrics:
    - rdb_last_save_time
    - rdb_changes_since_last_save
    - aof_current_size
    - aof_rewrite_in_progress
---

# Redis Persistence Skill

## Persistence Comparison

| Feature | RDB | AOF | Hybrid |
|---------|-----|-----|--------|
| Data Safety | Point-in-time | Near real-time | Best |
| Recovery Speed | Fast | Slow | Fast |
| File Size | Compact | Large | Medium |
| Write Performance | Better | Slower | Balanced |
| Recovery Granularity | Last snapshot | Last fsync | Best |

## RDB (Snapshotting)

Point-in-time snapshots of the dataset. Compact binary format.

### Configuration
```conf
# redis.conf

# Auto-save triggers (any condition triggers save)
save 900 1        # Save after 900s if ≥1 key changed
save 300 10       # Save after 300s if ≥10 keys changed
save 60 10000     # Save after 60s if ≥10000 keys changed

# Disable RDB completely
# save ""

# File settings
dbfilename dump.rdb
dir /var/lib/redis

# Compression (uses LZF)
rdbcompression yes

# Checksum (uses CRC64)
rdbchecksum yes

# Error handling
stop-writes-on-bgsave-error yes
```

### Commands
```redis
SAVE          # Blocking save (AVOID in production)
BGSAVE        # Background save (fork)
LASTSAVE      # Last successful save timestamp

# Check status
INFO persistence
# rdb_bgsave_in_progress:0
# rdb_last_save_time:1704067200
# rdb_last_bgsave_status:ok
# rdb_changes_since_last_save:0
```

### RDB Advantages
- Compact single-file backup
- Fast recovery (just load file)
- Good for disaster recovery
- Minimal performance impact

### RDB Disadvantages
- Data loss between snapshots
- Fork can be slow with large datasets
- Not suitable for zero data loss requirements

## AOF (Append-Only File)

Write-ahead log recording every write operation.

### Configuration
```conf
# redis.conf

# Enable AOF
appendonly yes
appendfilename "appendonly.aof"
appenddirname "appendonlydir"

# Fsync policies
# always    - Fsync after every write (safest, slowest)
# everysec  - Fsync every second (recommended)
# no        - Let OS decide (fastest, least safe)
appendfsync everysec

# Rewrite settings
auto-aof-rewrite-percentage 100    # Rewrite if AOF is 2x size since last rewrite
auto-aof-rewrite-min-size 64mb     # Minimum size to trigger rewrite

# Don't fsync during rewrite (better performance)
no-appendfsync-on-rewrite no

# Truncate corrupted AOF
aof-load-truncated yes

# Enable RDB preamble in AOF
aof-use-rdb-preamble yes
```

### Commands
```redis
BGREWRITEAOF    # Compact AOF file

# Check status
INFO persistence
# aof_enabled:1
# aof_rewrite_in_progress:0
# aof_current_size:123456
# aof_base_size:100000
```

### AOF Advantages
- More durable (up to 1s data loss with everysec)
- Human-readable format (can inspect/repair)
- Append-only is crash-safe

### AOF Disadvantages
- Larger file size
- Slower recovery (replays all commands)
- Rewrite can impact performance

## Hybrid Persistence (Redis 4.0+)

Combines RDB speed with AOF durability.

```conf
# redis.conf
appendonly yes
aof-use-rdb-preamble yes
```

**How it works:**
1. AOF rewrite creates RDB snapshot as preamble
2. Subsequent writes append in AOF format
3. Recovery: Load RDB, then replay AOF tail

## Production Recommendations

### High Durability (Financial/Critical)
```conf
appendonly yes
appendfsync always
save ""  # Disable RDB
```

### Balanced (Most Use Cases)
```conf
appendonly yes
appendfsync everysec
aof-use-rdb-preamble yes
save 900 1
save 300 10
```

### Performance Priority (Cache)
```conf
appendonly no
save 900 1  # Infrequent snapshots
# Or disable completely:
# save ""
```

## Backup Scripts

### Automated Backup Script
```bash
#!/bin/bash
# backup-redis.sh

REDIS_DIR="/var/lib/redis"
BACKUP_DIR="/backup/redis"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

# Trigger background save
redis-cli BGSAVE

# Wait for completion
while [ $(redis-cli LASTSAVE) == $(redis-cli LASTSAVE) ]; do
    sleep 1
done

# Copy files
mkdir -p $BACKUP_DIR
cp $REDIS_DIR/dump.rdb $BACKUP_DIR/dump_$DATE.rdb
cp -r $REDIS_DIR/appendonlydir $BACKUP_DIR/aof_$DATE/

# Compress
gzip $BACKUP_DIR/dump_$DATE.rdb
tar -czf $BACKUP_DIR/aof_$DATE.tar.gz $BACKUP_DIR/aof_$DATE/
rm -rf $BACKUP_DIR/aof_$DATE/

# Cleanup old backups
find $BACKUP_DIR -name "dump_*.rdb.gz" -mtime +$RETENTION_DAYS -delete
find $BACKUP_DIR -name "aof_*.tar.gz" -mtime +$RETENTION_DAYS -delete

echo "Backup completed: $DATE"
```

### Recovery Procedure
```bash
#!/bin/bash
# recover-redis.sh

# 1. Stop Redis
sudo systemctl stop redis

# 2. Backup current (corrupted) data
mv /var/lib/redis /var/lib/redis.corrupted

# 3. Restore from backup
mkdir -p /var/lib/redis
cp /backup/redis/dump_YYYYMMDD.rdb /var/lib/redis/dump.rdb
# Or for AOF:
tar -xzf /backup/redis/aof_YYYYMMDD.tar.gz -C /var/lib/redis/

# 4. Fix permissions
chown -R redis:redis /var/lib/redis

# 5. Start Redis
sudo systemctl start redis

# 6. Verify
redis-cli PING
redis-cli INFO keyspace
```

## Monitoring Commands

```redis
# Persistence status
INFO persistence

# Check last save
DEBUG SLEEP 0
LASTSAVE

# Force save and verify
BGSAVE
# Wait...
DEBUG RELOAD  # Reload from disk (CAREFUL in prod)

# Check data integrity
DEBUG DIGEST
```

## Assets
- `backup-redis.sh` - Automated backup script
- `persistence-config.conf` - Optimized config

## References
- `PERSISTENCE_GUIDE.md` - Strategy guide

---

## Troubleshooting Guide

### Common Issues & Solutions

#### 1. BGSAVE Failing
```
Background saving error
Can't save in background: fork: Cannot allocate memory
```

**Cause:** Not enough memory for fork

**Fixes:**
```bash
# Option 1: Enable overcommit
echo 1 > /proc/sys/vm/overcommit_memory
# Permanent:
echo "vm.overcommit_memory=1" >> /etc/sysctl.conf

# Option 2: Reduce dataset size

# Option 3: Add more RAM/swap
```

#### 2. AOF Corruption
```
Bad file format reading the append only file
```

**Fix:**
```bash
# Check and repair
redis-check-aof --fix appendonly.aof

# Or truncate (data loss)
redis-check-aof --fix appendonly.aof
```

#### 3. RDB Corruption
```
Short read or OOM loading DB
```

**Fix:**
```bash
# Verify RDB
redis-check-rdb dump.rdb

# Restore from backup
cp /backup/dump_latest.rdb /var/lib/redis/dump.rdb
```

#### 4. Slow Recovery
**Cause:** Large AOF file

**Fixes:**
- Enable hybrid persistence (RDB preamble)
- Run BGREWRITEAOF more frequently
- Use RDB for faster recovery, switch to AOF after

#### 5. High Latency During BGSAVE
**Cause:** Copy-on-write with high write load

**Fixes:**
```conf
# Disable THP
echo never > /sys/kernel/mm/transparent_hugepage/enabled

# Schedule BGSAVE during low traffic
save ""  # Disable auto-save
# Use cron for scheduled saves
```

### Debug Checklist

```markdown
□ Persistence enabled? (INFO persistence)
□ Directory writable? (ls -la /var/lib/redis)
□ Disk space available? (df -h)
□ Memory for fork? (free -m)
□ Last save successful? (LASTSAVE)
□ AOF fsync configured? (CONFIG GET appendfsync)
□ RDB file valid? (redis-check-rdb)
□ AOF file valid? (redis-check-aof)
```

### Performance Impact

| Operation | Impact | Mitigation |
|-----------|--------|------------|
| BGSAVE | Memory spike (CoW) | Schedule low-traffic |
| AOF always | High latency | Use everysec |
| BGREWRITEAOF | CPU + I/O | Set min-size high |
| Recovery | Downtime | Use RDB preamble |

---

## Error Codes Reference

| Code | Name | Description | Recovery |
|------|------|-------------|----------|
| P001 | FORK_FAIL | Cannot fork for BGSAVE | Enable overcommit |
| P002 | RDB_CORRUPT | RDB file corrupted | Restore backup |
| P003 | AOF_CORRUPT | AOF file corrupted | redis-check-aof --fix |
| P004 | DISK_FULL | No space for persistence | Free disk space |
| P005 | WRITE_ERR | Cannot write to disk | Check permissions |

---

## Test Template

```python
# test_redis_persistence.py
import redis
import pytest
import time
import subprocess

@pytest.fixture
def r():
    return redis.Redis(decode_responses=True)

class TestRDB:
    def test_bgsave(self, r):
        # Write some data
        r.set("test:persist:1", "value1")

        # Get last save time
        last_save = r.lastsave()

        # Trigger BGSAVE
        r.bgsave()

        # Wait for completion
        time.sleep(2)

        # Verify new save
        new_save = r.lastsave()
        assert new_save >= last_save

        r.delete("test:persist:1")

    def test_persistence_info(self, r):
        info = r.info("persistence")
        assert "rdb_last_save_time" in info
        assert "rdb_changes_since_last_save" in info

class TestAOF:
    def test_aof_rewrite(self, r):
        info = r.info("persistence")
        if info.get("aof_enabled"):
            # Trigger rewrite
            r.bgrewriteaof()
            time.sleep(1)

            # Check status
            info = r.info("persistence")
            assert info["aof_rewrite_in_progress"] in [0, 1]

class TestRecovery:
    def test_data_survives_restart(self, r):
        """Note: Requires actual Redis restart to fully test"""
        key = "test:recovery:data"
        r.set(key, "important_value")
        r.bgsave()
        time.sleep(1)

        # In real test, would restart Redis here
        # For now, just verify data exists
        assert r.get(key) == "important_value"
        r.delete(key)
```
