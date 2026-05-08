---
name: create-backup
description: Creates a Velero backup for specified namespaces or entire cluster with proper configuration and validation.
---

# Create OADP/Velero Backup

This skill helps you create backup resources for OADP/Velero with proper configuration, validation, and best practices.

## When to Use This Skill

- Creating ad-hoc backups of applications
- Backing up before maintenance or upgrades
- Creating backups with specific options (CSI, Kopia/Restic, hooks)
- Generating backup YAML with proper syntax

## What This Skill Does

1. **Analyzes Requirements**: Understands what needs to be backed up
2. **Determines Backup Strategy**: Selects CSI snapshots, Kopia (or legacy Restic), or both
3. **Generates Backup YAML**: Creates properly formatted backup resource
4. **Validates Configuration**: Checks for common issues
5. **Creates Backup**: Applies the backup resource
6. **Monitors Progress**: Watches backup completion
7. **Verifies Success**: Confirms backup completed successfully

## How to Use

### Basic Usage

```
Create a backup of namespace myapp
```

```
Backup all namespaces with label env=production
```

```
Create a full cluster backup
```

### With Specific Options

```
Create a backup of namespace myapp using CSI snapshots
```

```
Backup namespace myapp with Kopia file-level backup
```

```
Create backup with pre and post hooks for mysql database
```

### Advanced

```
Create a backup excluding certain resources like secrets
```

```
Schedule a daily backup at 2 AM for namespace myapp
```

## Examples

### Example 1: Simple Namespace Backup

**User**: "Create a backup of namespace wordpress"

**Skill Actions**:

1. Check namespace exists:
   ```bash
   oc get namespace wordpress
   ```

2. Generate backup YAML:
   ```yaml
   apiVersion: velero.io/v1
   kind: Backup
   metadata:
     name: wordpress-backup-20240315
     namespace: openshift-adp
     labels:
       app: wordpress
   spec:
     includedNamespaces:
       - wordpress
     storageLocation: default
     ttl: 720h0m0s  # 30 days
   ```

3. Apply backup:
   ```bash
   oc apply -f backup.yaml
   ```

4. Monitor:
   ```bash
   watch "oc get backup wordpress-backup-20240315 -n openshift-adp"
   ```

5. Verify:
   ```bash
   velero backup describe wordpress-backup-20240315 --details
   ```

**Output**:
```
✓ Backup created: wordpress-backup-20240315
✓ Backup completed successfully
✓ Total items backed up: 24
✓ Backup size: 156 MB
✓ Storage location: s3://my-bucket/velero/backups/wordpress-backup-20240315
```

### Example 2: Backup with CSI Snapshots

**User**: "Create a backup of namespace myapp with volume snapshots"

**Skill Actions**:

1. Check PVCs in namespace:
   ```bash
   oc get pvc -n myapp
   ```

2. Verify CSI driver and VolumeSnapshotClass:
   ```bash
   oc get volumesnapshotclass
   ```

3. Generate backup with CSI enabled:
   ```yaml
   apiVersion: velero.io/v1
   kind: Backup
   metadata:
     name: myapp-backup-20240315
     namespace: openshift-adp
   spec:
     includedNamespaces:
       - myapp
     storageLocation: default
     snapshotVolumes: true
     defaultVolumesToFsBackup: false
     volumeSnapshotLocations:
       - default
     ttl: 720h0m0s
   ```

4. Monitor VolumeSnapshots:
   ```bash
   watch "oc get volumesnapshots -n myapp"
   ```

**Output**:
```
✓ Backup created: myapp-backup-20240315
✓ Volume snapshots created: 3
  - myapp-data-snapshot-abc123 (Ready)
  - myapp-logs-snapshot-def456 (Ready)
  - myapp-cache-snapshot-ghi789 (Ready)
✓ Backup completed successfully
```

### Example 3: Backup with Kopia (File-Level)

**User**: "Backup namespace database using Kopia file-level backup"

**Skill Actions**:

1. Verify Kopia enabled (OADP 1.4+):
   ```bash
   oc get dpa -n openshift-adp -o jsonpath='{.items[0].spec.configuration.kopia.enable}'
   ```

2. Check Kopia node-agent pods running:
   ```bash
   oc get pods -n openshift-adp -l component=node-agent
   ```

3. Generate backup with Kopia:
   ```yaml
   apiVersion: velero.io/v1
   kind: Backup
   metadata:
     name: database-backup-20240315
     namespace: openshift-adp
     labels:
       backup-type: file-level
   spec:
     includedNamespaces:
       - database
     storageLocation: default
     defaultVolumesToFsBackup: true  # Use Kopia for all volumes
     ttl: 720h0m0s
   ```

4. Monitor Kopia progress:
   ```bash
   # Watch node-agent logs
   oc logs -n openshift-adp -l component=node-agent -f | grep database

   # Check backup status
   oc get backup database-backup-20240315 -n openshift-adp -o jsonpath='{.status.phase}'
   ```

**Note**: For OADP 1.3 and earlier using legacy Restic:
```bash
# Verify Restic enabled (deprecated)
oc get dpa -n openshift-adp -o jsonpath='{.items[0].spec.configuration.restic.enable}'

# Check Restic pods
oc get pods -n openshift-adp -l name=restic
```

### Example 4: Backup with Hooks

**User**: "Create backup of postgres with pre-backup snapshot hook"

**Skill Actions**:

Generate backup with hooks:
```yaml
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: postgres-backup-20240315
  namespace: openshift-adp
spec:
  includedNamespaces:
    - postgres
  storageLocation: default
  hooks:
    resources:
      - name: postgres-backup-hook
        includedNamespaces:
          - postgres
        labelSelector:
          matchLabels:
            app: postgres
        pre:
          - exec:
              container: postgres
              command:
                - /bin/bash
                - -c
                - PGPASSWORD=$POSTGRES_PASSWORD pg_dump -U postgres -d mydb > /tmp/backup.sql
              timeout: 3m
        post:
          - exec:
              container: postgres
              command:
                - /bin/bash
                - -c
                - rm -f /tmp/backup.sql
```

### Example 5: Scheduled Backup

**User**: "Schedule a daily backup of namespace myapp at 2 AM"

**Skill Actions**:

Generate Schedule resource:
```yaml
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: myapp-daily-backup
  namespace: openshift-adp
spec:
  schedule: "0 2 * * *"  # 2 AM every day
  template:
    includedNamespaces:
      - myapp
    storageLocation: default
    snapshotVolumes: true
    ttl: 720h0m0s  # Keep for 30 days
```

### Example 6: Velero Built-in Data Mover Backup (Cross-Region)

**User**: "Create backup using Velero's built-in Data Mover to copy volume data to object storage"

**Note**: Data Mover is now built-in to Velero (not a separate OADP component) and automatically handles volume data movement to object storage for portability across regions and clusters.

**Skill Actions**:

1. Verify Kopia enabled in DPA (required for Data Mover):
   ```bash
   oc get dpa -n openshift-adp -o jsonpath='{.spec.configuration.kopia.enable}'
   ```

2. Create backup with Data Mover annotation:
   ```yaml
   apiVersion: velero.io/v1
   kind: Backup
   metadata:
     name: app-datamover-backup-20240315
     namespace: openshift-adp
     labels:
       velero.io/storage-location: default
   spec:
     includedNamespaces:
       - myapp
     storageLocation: default
     snapshotVolumes: true  # Creates CSI snapshots first
     snapshotMoveData: true  # Enable built-in Data Mover
     ttl: 720h0m0s
   ```

3. Monitor Velero Data Mover progress:
   ```bash
   # Watch Velero's DataUpload CRs (built-in)
   oc get datauploads -A -w

   # Check node-agent pods handling data movement
   oc get pods -n openshift-adp -l component=node-agent

   # View Velero logs for data mover operations
   oc logs -n openshift-adp deployment/velero -f | grep -i "data.*mover\|dataupload"
   ```

**Expected Output:**
- Backup creates VolumeSnapshots first
- Velero's built-in Data Mover creates DataUpload CRs for each PVC
- Volume data moved from snapshots to object storage via Kopia
- Backup completes with both metadata and volume data in BSL
- Data is portable across clusters and regions

### Example 7: Multi-BSL Backup (Specific Storage Location)

**User**: "Create backup to secondary backup storage location"

**Skill Actions**:

1. List available BackupStorageLocations:
   ```bash
   oc get backupstoragelocations -n openshift-adp
   ```

2. Create backup targeting specific BSL:
   ```yaml
   apiVersion: velero.io/v1
   kind: Backup
   metadata:
     name: offsite-backup-20240315
     namespace: openshift-adp
     labels:
       backup-location: secondary
   spec:
     includedNamespaces:
       - critical-app
     storageLocation: secondary-bsl  # Specify non-default BSL
     volumeSnapshotLocations:
       - aws-us-west-2-vsl  # Match VSL to BSL region
     snapshotVolumes: true
     ttl: 2160h0m0s  # 90 days retention
   ```

3. Verify backup in correct location:
   ```bash
   # Check backup BSL
   velero backup describe offsite-backup-20240315 | grep "Storage Location"

   # Verify in object storage
   aws s3 ls s3://secondary-bucket/backups/
   ```

**Use Cases:**
- Geographic redundancy (backup to different region)
- Compliance requirements (specific storage location)
- Cost optimization (different storage tiers)

### Example 8: OpenShift Virtualization VM Backup

**User**: "Create backup of VirtualMachine including disks"

**Skill Actions**:

1. Check VM status:
   ```bash
   # List VMs
   oc get vms -n vm-namespace

   # Check VM details
   virtctl vnc vm-name -n vm-namespace
   ```

2. Create VM backup with DataVolumes:
   ```yaml
   apiVersion: velero.io/v1
   kind: Backup
   metadata:
     name: vm-backup-20240315
     namespace: openshift-adp
   spec:
     includedNamespaces:
       - vm-namespace
     includedResources:
       - virtualmachines.kubevirt.io
       - virtualmachineinstances.kubevirt.io
       - datavolumes.cdi.kubevirt.io
       - persistentvolumeclaims
     storageLocation: default
     snapshotVolumes: true  # Snapshot VM disks
     hooks:
       resources:
         - name: vm-quiesce
           includedResources:
             - virtualmachines.kubevirt.io
           pre:
             - exec:
                 container: compute
                 command:
                   - /bin/bash
                   - -c
                   - virtctl fsfreeze -n vm-namespace vm-name
                 timeout: 2m
           post:
             - exec:
                 container: compute
                 command:
                   - /bin/bash
                   - -c
                   - virtctl fsunfreeze -n vm-namespace vm-name
   ```

3. Verify VM backup:
   ```bash
   velero backup describe vm-backup-20240315 --details

   # Check VolumeSnapshots created
   oc get volumesnapshots -n vm-namespace

   # Verify DataVolumes backed up
   velero backup describe vm-backup-20240315 | grep -i datavolume
   ```

**Success Indicators:**
- VirtualMachine CR backed up
- DataVolumes included
- PVC snapshots created
- VM state preserved

### Example 9: etcd Control Plane Backup Reference

**Note**: etcd backups are typically performed separately from OADP application backups using OpenShift's built-in cluster backup procedures.

**etcd Backup (Manual Process)**:

```bash
# On master node - create etcd snapshot
oc debug node/master-0
chroot /host
/usr/local/bin/cluster-backup.sh /home/core/etcd-backup

# Exit debug session
exit

# Copy backup off node
oc cp <debug-pod>:/home/core/etcd-backup ./etcd-backup-$(date +%Y%m%d)

# Optionally include etcd namespace resources in OADP backup
velero backup create etcd-resources-backup \
  --include-namespaces openshift-etcd \
  --include-resources secrets,configmaps
```

**Integration with OADP:**

While OADP doesn't backup etcd data directly, you can backup etcd-related resources:

```yaml
apiVersion: velero.io/v1
kind: Backup
metadata:
  name: control-plane-resources-backup
  namespace: openshift-adp
spec:
  includedNamespaces:
    - openshift-etcd
    - openshift-kube-apiserver
    - openshift-kube-controller-manager
  includedResources:
    - secrets
    - configmaps
  includeClusterResources: true
  ttl: 720h0m0s
```

**Best Practice**: Combine OADP application backups with separate etcd snapshots for complete disaster recovery capability.

## Backup Decision Tree

```
Do you have PVCs?
├─ Yes
│  ├─ Is CSI driver installed?
│  │  ├─ Yes → Use CSI snapshots (fast, storage-efficient)
│  │  └─ No → Use Kopia file-level backup (works everywhere)
│  └─ Large volumes (>100GB)?
│     ├─ Yes → Prefer CSI snapshots
│     └─ No → Either CSI or Kopia fine
└─ No
   └─ Simple backup (no volume concerns)

Do you need consistency?
├─ Database → Use pre-backup hooks
├─ Stateful app → Quiesce before backup
└─ Stateless → Direct backup OK
```

## Validation Checks

Before creating backup:

- [ ] Namespace exists
- [ ] OADP operator running
- [ ] Velero deployed
- [ ] BackupStorageLocation available
- [ ] For CSI: VolumeSnapshotClass exists
- [ ] For file-level backups: Kopia node-agent (or legacy Restic) daemonset running
- [ ] Sufficient storage space in BSL
- [ ] No existing backup with same name

## Common Options

### Include/Exclude Options

```yaml
# Include specific namespaces
includedNamespaces:
  - app1
  - app2

# Include by label
labelSelector:
  matchLabels:
    backup: "true"

# Exclude resources
excludedResources:
  - secrets
  - events

# Include specific resources only
includedResources:
  - deployments
  - services
  - configmaps
```

### Volume Options

```yaml
# Use CSI snapshots
snapshotVolumes: true
defaultVolumesToFsBackup: false

# Use Kopia file-level backup for all volumes
defaultVolumesToFsBackup: true
snapshotVolumes: false

# Hybrid: CSI by default, Kopia for specific pods
snapshotVolumes: true
defaultVolumesToFsBackup: false
# Add annotation to specific pods for file-level backup:
# backup.velero.io/backup-volumes: volume-name
```

**Note**: For OADP 1.3 and earlier using deprecated Restic, the same configuration options apply.

### Retention

```yaml
# Keep for 30 days
ttl: 720h0m0s

# Keep for 7 days
ttl: 168h0m0s

# Keep for 90 days
ttl: 2160h0m0s
```

## Monitoring Backup

```bash
# Watch status
watch "oc get backup <name> -n openshift-adp"

# View details
velero backup describe <name> --details

# Stream logs
velero backup logs <name> -f

# Check for errors
velero backup describe <name> | grep -i error

# View backed up resources
velero backup describe <name> --details | grep "Resource List" -A 100
```

## Troubleshooting

### Backup Stuck

```bash
# Check Velero logs
oc logs -n openshift-adp deployment/velero -f

# Check for Kopia node-agent issues (OADP 1.4+)
oc get pods -n openshift-adp -l component=node-agent
oc logs -n openshift-adp -l component=node-agent -f

# For legacy Restic (OADP 1.3 and earlier)
oc get pods -n openshift-adp -l name=restic
oc logs -n openshift-adp ds/restic -f

# Check CSI snapshots
oc get volumesnapshots -A
```

### Backup Failed

```bash
# Get error details
velero backup describe <name> --details

# View logs
velero backup logs <name>

# Check BSL
oc get backupstoragelocations -n openshift-adp
```

## Best Practices

1. **Use meaningful names**: Include app name and date
2. **Set appropriate TTL**: Don't keep backups forever
3. **Label backups**: Makes finding and filtering easier
4. **Test restores**: Verify backups can be restored
5. **Use schedules**: Automate regular backups
6. **Monitor completion**: Don't assume backups succeed
7. **Document hooks**: If using hooks, document the process
8. **Version control**: Keep backup YAML in git

## Next Steps After Backup

- Verify backup completed successfully
- Test restore in non-production environment
- Document what was backed up
- Set up monitoring/alerts for scheduled backups
- Plan retention and cleanup strategy
