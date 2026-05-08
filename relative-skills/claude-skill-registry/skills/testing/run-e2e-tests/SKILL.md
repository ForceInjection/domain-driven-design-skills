---
name: run-e2e-tests
description: Executes end-to-end tests for OADP projects with proper environment setup, test selection, and result analysis.
---

# Run OADP E2E Tests

This skill helps you run end-to-end tests for OADP projects with proper configuration, environment setup, and result analysis.

## When to Use This Skill

- Running full E2E test suite before releases
- Testing specific backup/restore scenarios
- Validating changes across multiple providers
- Debugging failing E2E tests
- Running tests in CI/CD pipelines

## What This Skill Does

1. **Environment Setup**: Configures test environment (cluster, storage, credentials)
2. **Test Selection**: Identifies which tests to run
3. **Execution**: Runs tests with proper configuration
4. **Monitoring**: Tracks test progress
5. **Analysis**: Analyzes failures and provides diagnostics
6. **Cleanup**: Ensures test resources cleaned up

## How to Use

### Basic Usage

```
Run all E2E tests
```

```
Run E2E tests for AWS provider
```

```
Run backup and restore E2E tests
```

### Specific Test Scenarios

```
Run CSI snapshot E2E tests
```

```
Run Restic backup E2E tests
```

```
Test cross-namespace restore
```

### Debugging

```
Run failed E2E tests from last run
```

```
Run E2E tests with debug logging
```

## E2E Test Structure

### OADP Operator E2E Tests

Located in: `oadp-operator/tests/e2e/`

```
tests/e2e/
├── e2e_suite_test.go          # Test suite setup
├── backup_restore_test.go      # Basic backup/restore
├── csi_test.go                 # CSI snapshot tests
├── restic_test.go              # Restic backup tests
├── must_gather_test.go         # must-gather tests
├── lib/                        # Test utilities
│   ├── apps.go                 # Test applications
│   ├── backup.go               # Backup helpers
│   ├── restore.go              # Restore helpers
│   └── velero.go               # Velero client
└── sample-applications/        # Test apps
    ├── mysql/
    ├── postgres/
    └── todolist/
```

### Velero E2E Tests

Located in: `velero/test/e2e/`

```
test/e2e/
├── e2e_suite_test.go
├── basic/
│   ├── backup.go
│   └── restore.go
├── migration/
├── upgrade/
└── util/
```

## Running Tests

### 1. Environment Setup

```bash
# Export required variables
export CLOUD_PROVIDER=aws  # or gcp, azure
export BUCKET_NAME=oadp-e2e-test-bucket
export REGION=us-east-1
export CREDENTIALS_FILE=/path/to/credentials

# For AWS
export AWS_ACCESS_KEY_ID=<key>
export AWS_SECRET_ACCESS_KEY=<secret>

# For OpenShift
export KUBECONFIG=/path/to/kubeconfig
```

### 2. Run All Tests

```bash
# OADP Operator E2E
cd oadp-operator
make test-e2e

# Or with Ginkgo directly
ginkgo -v -trace -progress tests/e2e/
```

### 3. Run Specific Provider

```bash
# AWS tests
make test-e2e CLOUD_PROVIDER=aws

# GCP tests
make test-e2e CLOUD_PROVIDER=gcp

# Azure tests
make test-e2e CLOUD_PROVIDER=azure
```

### 4. Run Specific Test Suite

```bash
# Run only backup/restore tests
ginkgo -v -focus="Backup and Restore" tests/e2e/

# Run only CSI tests
ginkgo -v -focus="CSI" tests/e2e/

# Run only Restic tests
ginkgo -v -focus="Restic" tests/e2e/
```

### 5. Run Specific Test

```bash
# Run single test by name
ginkgo -v -focus="Should backup and restore a simple application" tests/e2e/

# Run multiple specific tests
ginkgo -v -focus="Should backup.*PVC" tests/e2e/
```

### 6. Skip Tests

```bash
# Skip slow tests
ginkgo -v -skip="slow" tests/e2e/

# Skip specific provider
ginkgo -v -skip="Azure" tests/e2e/
```

## Test Configuration

### Environment Variables

```bash
# Required
CLOUD_PROVIDER=aws|gcp|azure
BUCKET_NAME=<backup-bucket>
REGION=<cloud-region>
KUBECONFIG=<path-to-kubeconfig>

# Optional
VELERO_NAMESPACE=openshift-adp  # Default namespace
VELERO_IMAGE=<custom-image>      # Override Velero image
BSL_CONFIG=<bsl-config-file>     # Custom BSL config
TEST_TIMEOUT=2h                  # Test timeout
ARTIFACTS_DIR=/tmp/e2e-artifacts # Artifact storage
DEBUG=true                       # Debug logging
KEEP_CLUSTER=true                # Don't cleanup after tests
```

### Test Configuration File

Create `e2e-config.yaml`:

```yaml
cloudProvider: aws
backupStorageLocation:
  bucket: oadp-e2e-test-bucket
  region: us-east-1
  credentialsFile: /path/to/credentials

volumeSnapshotLocation:
  region: us-east-1

testApplications:
  - mysql
  - postgres
  - todolist

testScenarios:
  - basic-backup-restore
  - csi-snapshot
  - restic-backup
  - scheduled-backup
  - cross-namespace-restore

timeout: 120m
parallelism: 1
```

## Test Examples

### Running Basic Test Suite

```bash
#!/bin/bash
set -e

echo "Setting up E2E test environment..."

# Configure environment
export CLOUD_PROVIDER=aws
export BUCKET_NAME=oadp-e2e-$(date +%s)
export REGION=us-east-1
export KUBECONFIG=~/.kube/config

# Create test bucket
aws s3 mb s3://$BUCKET_NAME --region $REGION

# Install OADP operator
echo "Installing OADP operator..."
oc create namespace openshift-adp
oc apply -f hack/install-operator.yaml

# Wait for operator ready
echo "Waiting for operator..."
oc wait --for=condition=ready pod \
  -l app.kubernetes.io/name=oadp-operator \
  -n openshift-adp --timeout=5m

# Create DPA
cat <<EOF | oc apply -f -
apiVersion: oadp.openshift.io/v1alpha1
kind: DataProtectionApplication
metadata:
  name: dpa-e2e
  namespace: openshift-adp
spec:
  configuration:
    velero:
      defaultPlugins:
        - aws
        - openshift
    restic:
      enable: true
  backupLocations:
    - name: default
      velero:
        provider: aws
        default: true
        objectStorage:
          bucket: $BUCKET_NAME
          prefix: velero
        config:
          region: $REGION
        credential:
          name: cloud-credentials
          key: cloud
EOF

# Wait for Velero ready
echo "Waiting for Velero..."
oc wait --for=condition=ready pod \
  -l app.kubernetes.io/name=velero \
  -n openshift-adp --timeout=5m

# Run tests
echo "Running E2E tests..."
ginkgo -v -progress -trace \
  -timeout=2h \
  -output-dir=/tmp/e2e-results \
  tests/e2e/

# Cleanup (if tests passed)
if [ $? -eq 0 ]; then
  echo "Cleaning up..."
  aws s3 rb s3://$BUCKET_NAME --force
  oc delete namespace openshift-adp
fi
```

### Running Specific Scenario

```bash
# Test MySQL backup and restore
export TEST_APP=mysql
export TEST_SCENARIO=backup-restore

ginkgo -v -focus="MySQL.*backup.*restore" tests/e2e/

# Or use test helper
./tests/e2e/run-scenario.sh mysql backup-restore
```

### Running with Different Configurations

```bash
# Test with CSI snapshots
export ENABLE_CSI=true
export ENABLE_RESTIC=false
ginkgo -v -focus="CSI" tests/e2e/

# Test with Restic only
export ENABLE_CSI=false
export ENABLE_RESTIC=true
ginkgo -v -focus="Restic" tests/e2e/

# Test with both
export ENABLE_CSI=true
export ENABLE_RESTIC=true
ginkgo -v tests/e2e/
```

## Analyzing Results

### Test Output

Ginkgo provides:
- Real-time progress
- Detailed failure messages
- Timing information
- Test artifacts

```bash
# View results summary
cat /tmp/e2e-results/junit_01.xml

# View detailed logs
cat /tmp/e2e-results/ginkgo-*.log

# Search for failures
grep -r "FAIL" /tmp/e2e-results/
```

### Common Failure Patterns

#### Timeout Failures

```
Timed out after 300.000s.
Expected backup to complete
```

**Actions:**
- Check Velero logs
- Verify BSL connectivity
- Increase timeout if large backup

#### Resource Not Found

```
Error: namespaces "test-ns" not found
```

**Actions:**
- Check test cleanup from previous run
- Verify test setup phase completed
- Check test namespace generation

#### Permission Denied

```
Error: failed to create backup: admission webhook denied
```

**Actions:**
- Check RBAC configurations
- Verify service account permissions
- Check admission webhooks

### Debugging Failed Tests

```bash
# Run with debug output
DEBUG=true ginkgo -v -trace tests/e2e/

# Run single failing test
ginkgo -v -focus="<exact test name>" tests/e2e/

# Keep cluster for investigation
KEEP_CLUSTER=true ginkgo -v tests/e2e/

# Collect must-gather after failure
oc adm must-gather \
  --image=quay.io/konveyor/oadp-must-gather:latest \
  --dest-dir=/tmp/must-gather
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: E2E Tests

on:
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM

jobs:
  e2e-aws:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup test environment
        run: |
          ./hack/setup-e2e-env.sh

      - name: Run E2E tests
        env:
          CLOUD_PROVIDER: aws
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        run: |
          make test-e2e

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: e2e-test-results
          path: /tmp/e2e-results/

      - name: Cleanup
        if: always()
        run: |
          ./hack/cleanup-e2e-env.sh
```

## Best Practices

1. **Isolate test resources**: Use unique namespaces and bucket prefixes
2. **Always cleanup**: Even on failure, attempt cleanup
3. **Use timeouts**: Set reasonable timeouts for each test
4. **Parallel execution**: Run independent tests in parallel
5. **Collect diagnostics**: Save logs and must-gather on failures
6. **Test realistic scenarios**: Mirror production use cases
7. **Version compatibility**: Test against multiple K8s versions
8. **Cross-provider testing**: Test on AWS, GCP, Azure
9. **Monitor flaky tests**: Track and fix intermittent failures
10. **Document failures**: Keep record of known issues

## Troubleshooting

### Tests Not Starting

```bash
# Check cluster connectivity
oc cluster-info

# Verify operator installed
oc get csv -n openshift-adp

# Check test prerequisites
./tests/e2e/check-prerequisites.sh
```

### Tests Hanging

```bash
# Check for stuck resources
oc get backup,restore -A
oc get volumesnapshots -A

# Check pod status
oc get pods -n openshift-adp
oc get pods --all-namespaces | grep -v Running
```

### Cleanup Issues

```bash
# Force cleanup
oc delete namespace <test-namespace> --grace-period=0 --force

# Clean up backups
velero backup delete --all --confirm

# Clean up BSL
aws s3 rm s3://$BUCKET_NAME --recursive
```

## Next Steps

- Review test coverage and add missing scenarios
- Automate E2E tests in CI pipeline
- Set up nightly E2E test runs
- Monitor and fix flaky tests
- Add performance benchmarks
