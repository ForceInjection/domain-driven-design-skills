---
name: deployment-runbook
description: Deployment procedures, health checks, and rollback strategies. Use this skill when deploying applications, performing health checks, managing releases, or handling deployment failures. Provides systematic deployment workflows, verification scripts, and troubleshooting guides. Complements the devops-automation agent.
---

# Deployment Runbook

## Overview

This skill provides deployment procedures, automated health checks, and rollback strategies to ensure safe, reliable deployments. Use it to standardize deployment workflows and reduce deployment-related incidents.

## When to Use This Skill

- Planning production deployments
- Executing staged rollouts (canary, blue-green)
- Performing post-deployment health checks
- Rolling back failed deployments
- Troubleshooting deployment issues
- Establishing deployment best practices
- Complementing the **devops-automation agent** for deployments

## Pre-Deployment Checklist

Before any production deployment:

- [ ] **Code Review**: All changes reviewed and approved
- [ ] **Tests Pass**: CI/CD pipeline green
  - Unit tests: ✓
  - Integration tests: ✓
  - E2E tests: ✓
- [ ] **Database Migrations**: Tested in staging
  - Backward compatible
  - Rollback script prepared
- [ ] **Configuration**: Environment variables verified
  - Secrets rotated if needed
  - Feature flags configured
- [ ] **Monitoring**: Dashboards and alerts ready
  - Error tracking enabled
  - Performance monitoring active
  - Log aggregation configured
- [ ] **Communication**: Stakeholders notified
  - Deployment window announced
  - On-call engineer assigned
  - Rollback plan documented
- [ ] **Backups**: Recent backup verified
  - Database backed up < 1 hour ago
  - Backup restoration tested
- [ ] **Capacity**: Resources scaled appropriately
  - Auto-scaling configured
  - Rate limits reviewed
  - CDN cache warmed

## Deployment Strategies

### 1. Blue-Green Deployment

**Best for**: Zero-downtime deployments, easy rollbacks

**Process:**
1. Deploy to inactive (green) environment
2. Run health checks on green
3. Switch traffic from blue to green
4. Monitor for issues
5. Keep blue as instant rollback option

**Commands:**
```bash
# Deploy to green environment
./deploy.sh --env green

# Run health checks
python3 scripts/health_check.py --env green

# Switch traffic (gradual)
./switch_traffic.sh --from blue --to green --percentage 10
./switch_traffic.sh --from blue --to green --percentage 50
./switch_traffic.sh --from blue --to green --percentage 100

# If issues: instant rollback
./switch_traffic.sh --from green --to blue --percentage 100
```

### 2. Canary Deployment

**Best for**: Risk-averse deployments, gradual rollouts

**Process:**
1. Deploy to small subset of servers (5-10%)
2. Monitor metrics closely
3. Gradually increase percentage
4. Roll back if metrics degrade

**Monitoring During Canary:**
- Error rate < baseline + 1%
- Response time < baseline + 10%
- Success rate > 99.9%

### 3. Rolling Deployment

**Best for**: Standard updates, resource-constrained environments

**Process:**
1. Take one instance out of load balancer
2. Deploy new version
3. Run health checks
4. Add back to load balancer
5. Repeat for remaining instances

## Deployment Workflow

### Phase 1: Pre-Deployment (T-30 minutes)

```bash
# 1. Verify staging environment
./verify_staging.sh

# 2. Create deployment tag
git tag -a v1.2.3 -m "Release 1.2.3"
git push origin v1.2.3

# 3. Trigger production build
./build_production.sh --tag v1.2.3

# 4. Backup database
./backup_db.sh --environment production

# 5. Notify team
./notify_slack.sh "🚀 Starting deployment v1.2.3 in 30 minutes"
```

### Phase 2: Deployment (T-0)

```bash
# 1. Enable maintenance mode (if needed)
./maintenance_mode.sh --enable

# 2. Run database migrations
./run_migrations.sh --environment production

# 3. Deploy application
./deploy.sh --environment production --version v1.2.3

# 4. Disable maintenance mode
./maintenance_mode.sh --disable
```

### Phase 3: Post-Deployment Health Checks

```bash
# Run comprehensive health checks
python3 scripts/health_check.py --environment production

# Expected output:
# ✓ API health endpoint responding
# ✓ Database connectivity OK
# ✓ Cache layer accessible
# ✓ External services reachable
# ✓ Error rate within threshold
# ✓ Response time within SLA
```

### Phase 4: Monitoring (T+30 minutes)

Monitor these metrics:

**Application Metrics:**
- Error rate: < 0.1%
- Response time (p95): < 200ms
- Request throughput: within expected range
- Success rate: > 99.9%

**Infrastructure Metrics:**
- CPU utilization: < 70%
- Memory usage: < 80%
- Disk I/O: normal patterns
- Network latency: < 50ms

**Business Metrics:**
- Conversion rate: no significant drop
- User signups: within expected range
- Transaction volume: normal patterns

## Rollback Procedures

### When to Rollback

Rollback immediately if:
- Error rate > 1%
- Critical functionality broken
- Data corruption detected
- Security vulnerability introduced
- Performance degradation > 50%

### Rollback Methods

#### Method 1: Traffic Switch (Fastest)

```bash
# Blue-green: instant rollback
./switch_traffic.sh --from green --to blue --percentage 100

# Verification
python3 scripts/health_check.py --environment production
```

#### Method 2: Version Revert

```bash
# Deploy previous version
./deploy.sh --environment production --version v1.2.2

# Run health checks
python3 scripts/health_check.py --environment production
```

#### Method 3: Database Rollback

```bash
# If migrations were applied
./rollback_migration.sh --environment production --steps 1

# Restore from backup (last resort)
./restore_db.sh --backup latest --environment production
```

### Post-Rollback

1. **Verify system health**
   ```bash
   python3 scripts/health_check.py --environment production
   ```

2. **Notify stakeholders**
   ```bash
   ./notify_slack.sh "⚠️ Deployment v1.2.3 rolled back. System stable on v1.2.2"
   ```

3. **Create postmortem**
   - What went wrong?
   - Why didn't we catch it?
   - How do we prevent recurrence?

## Health Check Script

Use the included health check script:

```bash
# Run all checks
python3 scripts/health_check.py --env production

# Run specific check
python3 scripts/health_check.py --env production --check api

# Verbose output
python3 scripts/health_check.py --env production --verbose
```

See `scripts/health_check.py` for implementation.

## Troubleshooting Guide

### Issue: Deployment Hangs

**Symptoms:**
- Deployment script doesn't complete
- Services not starting

**Diagnosis:**
```bash
# Check service logs
kubectl logs -f deployment/app-name

# Check events
kubectl get events --sort-by='.lastTimestamp'
```

**Resolution:**
- Increase timeout values
- Check resource constraints
- Verify image pull secrets

### Issue: High Error Rate Post-Deployment

**Symptoms:**
- Error rate spike
- 500 errors in logs

**Diagnosis:**
```bash
# Check application logs
tail -f /var/log/app/error.log

# Check error distribution
grep "ERROR" /var/log/app/* | awk '{print $NF}' | sort | uniq -c | sort -nr
```

**Resolution:**
- Check configuration changes
- Verify environment variables
- Review recent code changes
- Consider immediate rollback

### Issue: Database Connection Failures

**Symptoms:**
- "Connection refused" errors
- Timeout errors

**Diagnosis:**
```bash
# Test database connectivity
python3 scripts/test_db_connection.py

# Check connection pool
psql -h db-host -U user -c "SELECT * FROM pg_stat_activity;"
```

**Resolution:**
- Verify connection strings
- Check firewall rules
- Increase connection pool size
- Verify credentials

## Communication Templates

### Pre-Deployment Announcement

```
🚀 **Production Deployment Scheduled**

**Version**: v1.2.3
**Time**: 2024-01-15 14:00 UTC (30 minutes)
**Duration**: ~15 minutes
**Impact**: No expected downtime

**Changes**:
- Feature: New user dashboard
- Fix: Payment processing bug
- Performance: API response time improvements

**Rollback Plan**: Blue-green switch (instant)
**On-Call**: @engineer-name
```

### Deployment Success

```
✅ **Deployment Complete**

**Version**: v1.2.3
**Status**: Successful
**Duration**: 12 minutes

**Health Checks**: All passing ✓
**Metrics**: Within normal range
**Next Check**: T+30 minutes

Monitoring dashboard: [link]
```

### Deployment Rollback

```
⚠️ **Deployment Rolled Back**

**Version**: v1.2.3 → v1.2.2 (rollback)
**Reason**: Elevated error rate (2.1%)
**Status**: System stable on v1.2.2

**Action Items**:
- [ ] Root cause analysis
- [ ] Fix identified issue
- [ ] Re-test in staging
- [ ] Schedule re-deployment

Incident report: [link]
```

## Resources

### scripts/
- **health_check.py**: Comprehensive deployment health checks
- **test_db_connection.py**: Database connectivity verification

### references/
- **deployment-checklist.md**: Detailed pre/post deployment checklist
- **monitoring-guide.md**: Metrics to monitor during deployments

## Best Practices

1. **Always deploy during low-traffic windows**
2. **Never deploy on Fridays** (unless critical hotfix)
3. **Keep deployments small** (< 200 lines changed)
4. **Monitor for 30+ minutes** post-deployment
5. **Document every rollback** with postmortem
6. **Test rollback procedure** in staging first
7. **Use feature flags** for risky changes
8. **Automate health checks** (don't rely on manual verification)

## Quick Reference

**Emergency Rollback:**
```bash
./switch_traffic.sh --from green --to blue --percentage 100
```

**Health Check:**
```bash
python3 scripts/health_check.py --env production
```

**View Logs:**
```bash
kubectl logs -f deployment/app-name --tail=100
```

**Check Metrics:**
```bash
curl https://metrics.example.com/api/health
```
