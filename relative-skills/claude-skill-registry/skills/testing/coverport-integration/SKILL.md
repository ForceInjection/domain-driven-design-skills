---
name: coverport-integration
description: Integrate coverport into Go repositories with Tekton pipelines to enable e2e test coverage collection and upload to Codecov. Use this skill when users ask to integrate coverport, add e2e coverage tracking, or set up coverage instrumentation for Go projects.
---

# Coverport Integration Skill

This skill automates the integration of coverport into Go repositories for e2e test coverage collection and upload to Codecov.

## What is Coverport?

Coverport is a tool that enables e2e test coverage collection by:
1. Building instrumented container images with Go's `-cover` flag
2. Collecting coverage data from running containers during e2e tests
3. Uploading the coverage data to Codecov with appropriate flags

## When to Use This Skill

Use this skill when the user:
- Asks to integrate coverport into their repository
- Wants to add e2e test coverage tracking
- Needs to set up coverage instrumentation for Go projects
- Mentions integrating coverage collection for Tekton/Konflux pipelines

## Prerequisites

Before using this skill, verify the repository has:
- Go codebase with a Dockerfile
- Tekton pipelines for CI/CD (typically in `.tekton/` directory)
- E2E test pipeline (typically in `integration-tests/pipelines/`)
- GitHub Actions workflows (optional but common)
- Codecov account

## Instructions

### Step 0: Pre-Integration Repository Scan

Before starting, run these checks to understand the repository structure:

1. **Find main.go location:**
   ```bash
   find . -name "main.go" -not -path "*/vendor/*" -not -path "*/test/*"
   ```

2. **Check current Dockerfile build command:**
   ```bash
   grep -A5 "go build" Dockerfile
   ```

3. **List Tekton pipelines:**
   ```bash
   ls .tekton/*.yaml
   ls integration-tests/pipelines/*.yaml 2>/dev/null || echo "No integration-tests/pipelines found"
   ```

4. **Check for existing coverage setup:**
   ```bash
   grep -r "ENABLE_COVERAGE\|instrumented\|coverport" . --exclude-dir=vendor --exclude-dir=.git
   ```

This helps identify potential conflicts or existing coverage infrastructure before making changes.

### Step 1: Analyze the Repository

Analyze the repository structure to understand what needs to be modified:

1. **Find the Dockerfile** - Look for the main Dockerfile
2. **Identify binaries being built** - Check what Go binaries are compiled in the Dockerfile and note if main.go is in root or subdirectory
3. **Find Tekton push pipeline** - Look in `.tekton/` for `*-push.yaml`
4. **Find E2E test pipeline** - Look in `integration-tests/pipelines/` for `*e2e*.yaml`
5. **Find Tekton PR pipeline** - Look in `.tekton/` for `*-pull-request.yaml`
6. **Find GitHub Actions** - Look in `.github/workflows/` for `pr.yaml`, `pr.yml`, `codecov.yaml`, or `codecov.yml`
7. **Check for existing coverage integration** - Search for `ENABLE_COVERAGE`, `instrumented`, `coverport`

### Step 2: Ask Clarifying Questions

Before making changes, ask the user:

1. **Which binaries to instrument?** - If the Dockerfile builds multiple binaries, ask which ones run during e2e tests
2. **Tenant namespace** - Confirm the namespace where their build and integration pipelines run (check `.tekton/*-push.yaml` for the `namespace` field)
3. **Secret name** - Confirm they want to use `coverport-secrets` or specify a different name
4. **OCI storage** - Confirm where coverage data should be stored (the quay.io repository for test artifacts)

### Step 3: Add Coverport as a Go Module Dependency

Add coverport to your Go module dependencies:

```bash
go get github.com/konflux-ci/coverport/instrumentation/go
```

This will:
- Add the coverport package to `go.mod` as a dependency
- Update `go.sum` with the dependency checksums

### Step 4: Create coverage_init.go File

Create a new file `coverage_init.go` in the root of your Go module (same directory as `main.go` or where the `package main` is):

```go
//go:build coverage

package main

// This file is only included when building with -tags=coverage.
// It starts a coverage HTTP server that allows collecting coverage data
// from the running binary during E2E tests.

import _ "github.com/konflux-ci/coverport/instrumentation/go" // starts coverage server via init()
```

**Important**:
- The `//go:build coverage` tag ensures this file is only included when building with `-tags=coverage`
- The blank import triggers the coverage server's init() function
- This file should be at the root of your Go module (where `main.go` is, or where the main package is)

### Step 5: Modify the Dockerfile

Add coverage instrumentation support:

**Add build argument** (near the top after FROM):
```dockerfile
# Build arguments
ARG ENABLE_COVERAGE=false
```

**Modify the build command** to conditionally build with coverage tags:

```dockerfile
# Build with or without coverage instrumentation
RUN if [ "$ENABLE_COVERAGE" = "true" ]; then \
        echo "Building with coverage instrumentation..."; \
        CGO_ENABLED=0 go build -cover -covermode=atomic -tags=coverage -o <binary-name> .; \
    else \
        echo "Building production binary..."; \
        CGO_ENABLED=0 go build -a -o <binary-name> .; \
    fi
```

**Important**:
- Replace `<binary-name>` with the actual binary name
- The `-tags=coverage` flag includes the `coverage_init.go` file
- Build the package (`.`) rather than individual files
- Only instrument binaries that run during e2e tests
- Keep other binaries without instrumentation
- No need to download external files - coverport is now a Go module dependency

### Step 5.5: Validate Dockerfile Changes Locally

**IMPORTANT**: Before proceeding to pipeline changes, validate the Dockerfile modifications work correctly using podman or docker:

```bash
# Build instrumented image
podman build --build-arg ENABLE_COVERAGE=true -t test-instrumented -f Dockerfile .

# Build production image (without coverage)
podman build -t test-production -f Dockerfile .

# Verify both images built successfully
podman images | grep test-
```

**Expected output in instrumented build:**
- "Building with coverage instrumentation..."

**Expected output in production build:**
- "Building production binary..."

**If builds fail:**
- Stop and fix the Dockerfile before proceeding
- See Troubleshooting section for common issues
- Ensure `coverage_init.go` exists in the correct location
- Verify Go module dependencies were downloaded (check `go.mod` and `go.sum`)
- Check that the build tags syntax is correct in `coverage_init.go`

**Why this validation matters:**
- Catches Dockerfile syntax errors immediately
- Verifies coverport Go module integration works
- Confirms both production and instrumented builds succeed
- Prevents wasting CI/CD pipeline time on broken builds
- Validates the conditional build logic works correctly

### Step 6: Update Tekton Push Pipeline

Add a task to build an instrumented image in the push pipeline (e.g., `.tekton/*-push.yaml`):

Find the location after `prefetch-dependencies` task and add:

```yaml
- name: build-instrumented-image
  params:
  - name: IMAGE
    value: $(params.output-image).instrumented
  - name: DOCKERFILE
    value: $(params.dockerfile)
  - name: CONTEXT
    value: $(params.path-context)
  - name: HERMETIC
    value: $(params.hermetic)
  - name: PREFETCH_INPUT
    value: $(params.prefetch-input)
  - name: IMAGE_EXPIRES_AFTER
    value: $(params.image-expires-after)
  - name: COMMIT_SHA
    value: $(tasks.clone-repository.results.commit)
  - name: BUILD_ARGS
    value:
    - $(params.build-args[*])
    - ENABLE_COVERAGE=true
  - name: BUILD_ARGS_FILE
    value: $(params.build-args-file)
  - name: SOURCE_ARTIFACT
    value: $(tasks.prefetch-dependencies.results.SOURCE_ARTIFACT)
  - name: CACHI2_ARTIFACT
    value: $(tasks.prefetch-dependencies.results.CACHI2_ARTIFACT)
  runAfter:
  - prefetch-dependencies
  taskRef:
    params:
    - name: name
      value: buildah-oci-ta
    - name: bundle
      value: quay.io/konflux-ci/tekton-catalog/task-buildah-oci-ta:0.7@sha256:b54509f5f695c0c89de4587a403099a26da5cdc3707037edd4b7cf4342b63edd
    - name: kind
      value: task
    resolver: bundles
  when:
  - input: $(tasks.init.results.build)
    operator: in
    values:
    - "true"
```

**IMPORTANT - Key points**:
- Use `buildah-oci-ta` (NOT `buildah-remote-oci-ta`) - this is a regular local build for amd64 testing clusters
- This should be a single task, NOT a matrix build (no PLATFORM parameter, no IMAGE_APPEND_PLATFORM)
- Image tagged with `.instrumented` suffix
- `HERMETIC: $(params.hermetic)` - uses the same hermetic setting as the main build (now supports hermetic builds!)
- `PREFETCH_INPUT: $(params.prefetch-input)` - uses the same prefetch settings as the main build
- `BUILD_ARGS` includes `ENABLE_COVERAGE=true`
- Do NOT add a `build-instrumented-image-index` task - the instrumented image is single-platform only

### Step 5: Update E2E Test Pipeline

Make three changes to the e2e test pipeline:

**A. Update test-metadata task** from v0.3 to v0.4:
```yaml
- name: test-metadata
  taskRef:
    resolver: git
    params:
      - name: url
        value: https://github.com/konflux-ci/tekton-integration-catalog.git
      - name: revision
        value: main
      - name: pathInRepo
        value: tasks/test-metadata/0.4/test-metadata.yaml
```

**B. Update image references (if applicable):**

**NOTE:** Only modify this if your e2e tests actually **run the containerized application**.

- If your tests **build the manager from source** (e.g., using `make build` or `go run main.go`), you may need to modify the build/run commands to use coverage flags instead, or deploy the instrumented container image
- If your tests **deploy and run containers**, proceed with updating image references

For tests that deploy/run container images, find parameters that reference images and change:
- `container-repo` → `instrumented-container-repo`
- `container-tag` → `instrumented-container-tag`
- `container-image` → `instrumented-container-image`

**Example scenarios:**
- **Scenario 1** (uses container): Tests deploy the app to a cluster using the container image → Update image references
- **Scenario 2** (builds from source): Tests run `make build && ./manager` inside the pipeline → May not need image reference changes, but need to ensure the running process is instrumented
- **Scenario 3** (hybrid): Tests build from source but coverage collection expects instrumented container → Coordinate with user on approach

**C. Add coverage collection task** after e2e tests:
```yaml
- name: collect-and-upload-coverage
  runAfter:
    - <e2e-test-task-name>  # Replace with actual task name
  params:
    - name: instrumented-images
      value: "$(tasks.test-metadata.results.instrumented-container-repo):$(tasks.test-metadata.results.instrumented-container-tag)"
    - name: cluster-access-secret-name
      value: kfg-$(context.pipelineRun.name)  # Adjust if different
    - name: test-name
      value: e2e-tests
    - name: oci-container
      value: "$(params.oci-container-repo):$(context.pipelineRun.name)"
    - name: codecov-flags
      value: e2e-tests
    - name: credentials-secret-name
      value: "coverport-secrets"  # Or user-specified name
  taskRef:
    resolver: git
    params:
      - name: url
        value: https://github.com/konflux-ci/tekton-integration-catalog.git
      - name: revision
        value: main
      - name: pathInRepo
        value: tasks/coverport-coverage/0.1/coverport-coverage.yaml
```

### Step 8: Update Tekton PR Pipeline (Pull Request Pipeline)

Update the PR pipeline (e.g., `.tekton/*-pull-request.yaml`) to build with coverage instrumentation:

**A. Enable hermetic build and prefetch (if not already enabled):**

Add or ensure these parameters exist in the `spec.params` section:
```yaml
  - name: hermetic
    value: "true"
  - name: prefetch-input
    value: '{"type": "gomod", "path": "."}'
```

**B. Add ENABLE_COVERAGE=true to BUILD_ARGS:**

Find the `build-images` task (or equivalent) and add `ENABLE_COVERAGE=true` to its `BUILD_ARGS`:

```yaml
- name: build-images
  # ... other params ...
  params:
  # ... other params ...
  - name: BUILD_ARGS
    value:
    - $(params.build-args[*])
    - ENABLE_COVERAGE=true  # Add this line
  # ... rest of the task ...
```

**Key points**:
- **With the Go module approach, hermetic builds are now supported!**
- Enable `hermetic: "true"` and `prefetch-input` for secure, reproducible builds
- Add `ENABLE_COVERAGE=true` to the regular build task in PR pipeline
- This enables coverage collection for PR builds which can be used for PR-level testing
- No need to create a separate instrumented image task in PR pipeline - just modify the existing build task

### Step 7: Update GitHub Actions

Add codecov flags to distinguish unit tests from e2e tests.

In `.github/workflows/pr.yaml` (or similar), update the codecov upload step:

```yaml
- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v5
  with:
    flags: unit-tests
```

If there's a separate `codecov.yml` workflow, add the same flags there with the token:
```yaml
- name: Codecov
  uses: codecov/codecov-action@v5
  with:
    token: ${{ secrets.CODECOV_TOKEN }}
    flags: unit-tests
```

### Step 8: Document Manual Steps

After making all changes, inform the user they need to create a Kubernetes secret.

**IMPORTANT**: The secret must be created in the namespace where your build and integration pipelines run. This is typically your tenant namespace (e.g., `my-tenant`, not a specific repository namespace like `rhtap-release-2-tenant`). You can identify the correct namespace by checking the `namespace` field in your `.tekton/*-push.yaml` file.

**Option A - Using kubectl:**
```bash
# First, create the dockerconfig JSON file
cat > /tmp/dockerconfig.json <<EOF
{"auths":{"quay.io":{"auth":"<base64-encoded-quay-user:token>","email":""}}}
EOF

# Create the secret with both keys in YOUR tenant namespace
kubectl create secret generic coverport-secrets \
  --from-literal=codecov-token=<your-codecov-token> \
  --from-file=oci-storage-dockerconfigjson=/tmp/dockerconfig.json \
  -n <your-tenant-namespace>

# Clean up
rm /tmp/dockerconfig.json
```

**Option B - Using YAML:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: coverport-secrets
  namespace: <your-tenant-namespace>  # Replace with your tenant namespace
type: Opaque
stringData:
  codecov-token: <your-codecov-token>
  oci-storage-dockerconfigjson: '{"auths":{"quay.io":{"auth":"<base64-encoded-quay-user:token>","email":""}}}'
```

**Required secret keys:**
- `codecov-token` - Your Codecov API token for uploading coverage reports to Codecov
- `oci-storage-dockerconfigjson` - Docker config JSON with Quay.io credentials for pushing coverage test artifacts to an OCI container registry
  - This is used by the `collect-and-upload-coverage` task to store coverage data as OCI artifacts in quay.io
  - The coverage collection process extracts coverage data from instrumented containers and pushes it to the OCI registry before uploading to Codecov
  - The `auth` value should be base64-encoded `username:token`
  - To encode: `echo -n "quay-username:quay-token" | base64`
  - You need push access to the quay.io repository specified in the e2e pipeline's `oci-container-repo` parameter

### Step 9: Post-Integration Validation Checklist

Before committing the changes, verify all modifications are correct:

**Local validation (already completed in Step 5.5):**
- [ ] `podman build` (production) succeeds
- [ ] `podman build --build-arg ENABLE_COVERAGE=true` (instrumented) succeeds
- [ ] Instrumented build logs show "Building with coverage instrumentation..."
- [ ] Production build logs show "Building production binary..."

**Go module setup checklist:**
- [ ] `go.mod` has coverport dependency added
- [ ] `go.sum` has coverport checksums
- [ ] `coverage_init.go` exists at the root of the module with correct build tags

**File modifications checklist:**
- [ ] `Dockerfile` has `ENABLE_COVERAGE` build arg (removed `COVERAGE_SERVER_URL`)
- [ ] `Dockerfile` has conditional build logic with `-tags=coverage` flag
- [ ] `.tekton/*-push.yaml` has `build-instrumented-image` task after `prefetch-dependencies`
- [ ] `.tekton/*-push.yaml` instrumented task uses `buildah-oci-ta` (not `buildah-remote-oci-ta`)
- [ ] `.tekton/*-push.yaml` instrumented task uses `HERMETIC: $(params.hermetic)` and `PREFETCH_INPUT: $(params.prefetch-input)`
- [ ] `.tekton/*-pull-request.yaml` has `hermetic: "true"` and `prefetch-input` enabled
- [ ] `.tekton/*-pull-request.yaml` has `ENABLE_COVERAGE=true` in BUILD_ARGS
- [ ] `integration-tests/pipelines/*e2e*.yaml` uses test-metadata v0.4
- [ ] `integration-tests/pipelines/*e2e*.yaml` has `collect-and-upload-coverage` task
- [ ] `integration-tests/pipelines/*e2e*.yaml` updated image references (if applicable)
- [ ] `.github/workflows/pr.y*ml` has `flags: unit-tests` in codecov action
- [ ] `.github/workflows/codecov.y*ml` has `flags: unit-tests` in codecov action

**Documentation provided to user:**
- [ ] Instructions for creating `coverport-secrets` Kubernetes secret in their tenant namespace
- [ ] Explanation that the namespace should be where their build and integration pipelines run
- [ ] Required secret keys: `codecov-token` and `oci-storage-dockerconfigjson`
- [ ] Explanation of what `oci-storage-dockerconfigjson` is used for (pushing coverage artifacts to quay.io)
- [ ] Instructions for encoding auth credentials
- [ ] Note about needing push access to the quay.io repository

**Summary to provide user:**
List all modified files with brief description of changes:
```
Modified files:
- coverage_init.go: NEW - Coverage initialization with build tags
- go.mod: Added coverport dependency
- go.sum: Added coverport checksums
- Dockerfile: Added coverage instrumentation with build tags
- .tekton/<name>-push.yaml: Added instrumented image build task with hermetic support
- .tekton/<name>-pull-request.yaml: Enabled coverage and hermetic builds for PR builds
- integration-tests/pipelines/<name>-e2e-pipeline.yaml: Added coverage collection
- .github/workflows/pr.yml: Added unit-tests flag
- .github/workflows/codecov.yml: Added unit-tests flag
```

## Validation

After integration is deployed to CI/CD, provide these verification steps to the user:

1. **Check instrumented image build:**
   - Push a commit to main branch
   - Verify the push pipeline creates an image with `.instrumented` tag
   - Check build logs for "Building with coverage instrumentation..." message

2. **Check e2e coverage collection:**
   - Run e2e tests
   - Verify `collect-and-upload-coverage` task executes successfully
   - Check Codecov dashboard for coverage data with `e2e-tests` flag

3. **Check unit test coverage:**
   - Create a PR
   - Verify unit tests upload coverage with `unit-tests` flag
   - Check Codecov shows both unit and e2e coverage

## Troubleshooting

Common issues and solutions:

**Build error: "coverage_init.go not found" or "package not imported"**
- **Cause**: The `coverage_init.go` file is missing or in the wrong location
- **Solution**:
  - Ensure `coverage_init.go` exists at the root of your Go module (same directory as `main.go`)
  - Verify the file has the correct `//go:build coverage` build tag
  - Check that the package declaration matches your main package (`package main`)

**Build error: "cannot find package"**
- **Cause**: Coverport dependency not properly added to Go modules
- **Solution**:
  - Run `go get github.com/konflux-ci/coverport/instrumentation/go`
  - Verify `go.mod` has the coverport dependency
  - Run `go mod tidy` to clean up dependencies

**Instrumented build fails:**
- Verify coverport Go module dependency is in `go.mod` and `go.sum`
- Check that `coverage_init.go` has the correct build tag syntax (`//go:build coverage`, not `// +build coverage`)
- Ensure the Dockerfile build command includes `-tags=coverage`
- Verify hermetic mode is enabled with proper prefetch configuration
- Ensure you're using `buildah-oci-ta` for instrumented builds in push pipeline, not `buildah-remote-oci-ta`
- Verify there's no matrix build or PLATFORM parameter for the instrumented image task

**Hermetic build fails with "cannot download dependencies"**
- **Cause**: Go module dependencies not properly prefetched
- **Solution**:
  - Ensure `hermetic: "true"` is set in the pipeline parameters
  - Verify `prefetch-input` is set correctly: `{"type": "gomod", "path": "."}`
  - Check that the `prefetch-dependencies` task completed successfully
  - Review prefetch task logs for any download errors

**Coverage data not uploaded:**
- Verify `coverport-secrets` exists in your tenant namespace (the namespace where your build and integration pipelines run)
- Check `codecov-token` key exists in the secret
- Check `oci-storage-dockerconfigjson` key exists and is valid (should be a valid Docker config JSON)
- Verify you have push access to the quay.io repository specified in the e2e pipeline's `oci-container-repo` parameter
- Review `collect-and-upload-coverage` task logs for errors related to OCI push or Codecov upload

**Coverage data incomplete:**
- Verify e2e tests are using the instrumented image (check image tag has `.instrumented` suffix)
- Ensure coverage server is properly included in the build (check that `-tags=coverage` is used)
- Check that the correct binaries are instrumented
- Verify `coverage_init.go` exists and has the correct import

**E2E tests pass but no coverage data collected:**
- Verify the e2e tests are actually **running the instrumented binary/container**
- If tests build from source (e.g., `make build`), the build process must include `-cover -tags=coverage` flags
- Check that `GOCOVERDIR` environment variable is set in the running container/process
- Verify the coverage collection task can access the cluster where instrumented app runs
- Review coverage collection task logs for connection or permission errors

**Production build includes coverage code:**
- **Cause**: Missing or incorrect build tags
- **Solution**:
  - Verify `coverage_init.go` has `//go:build coverage` at the top
  - Ensure production builds do NOT include `-tags=coverage`
  - The coverage code should only be included when `ENABLE_COVERAGE=true`

## Best Practices

1. **Validate early and often** - Always run podman/docker builds after Dockerfile changes, before modifying pipelines
2. **Be adaptive** - Repository structures vary, adapt the integration to the specific repository
3. **Ask questions** - If unsure about something, ask the user for clarification
4. **Show diffs** - When modifying files, explain what's changing
5. **Preserve existing logic** - Don't break existing functionality
6. **Handle edge cases** - Check for existing build args, multiple Dockerfiles, etc.
7. **Provide context** - Explain why each change is needed
8. **Use checklists** - Go through the post-integration checklist before completing
9. **Test both paths** - Ensure both production and instrumented builds work

## Reference Implementation

The reference implementation can be found in the `release-service` repository:
- **Initial implementation (wget approach)**: commits `1b2208f..dbf965d`
- **Updated implementation (Go module approach)**: commit `5ed6752` - "fix: use coverport as go module"

Key files modified in the Go module approach:
- `coverage_init.go` - NEW: Coverage initialization file with build tags
- `go.mod` - Added coverport dependency
- `go.sum` - Added coverport checksums
- `Dockerfile` - Updated to use `-tags=coverage` instead of downloading files
- `.tekton/release-service-push.yaml` - Updated to support hermetic builds for instrumented images
- `.tekton/release-service-pull-request.yaml` - Enabled hermetic builds and prefetch
- `integration-tests/pipelines/konflux-e2e-tests-pipeline.yaml` - Updated to use test-metadata v0.4 and added coverage collection
- `.github/workflows/codecov.yml` and `.github/workflows/pr.yml` - Added codecov flags

**Key changes in Go module approach:**
- No more `wget` to download coverage_server.go during build
- Coverport is a proper Go module dependency
- Hermetic builds are now supported
- Cleaner separation using Go build tags

**Note**: The `release-service` repository uses the `rhtap-release-2-tenant` namespace, which is specific to that repository. When implementing coverport for other repositories, use the appropriate tenant namespace where that repository's build and integration pipelines run.

## Examples

### Example 1: Single Binary Repository (main.go in root)

For a repository that builds one binary (`manager`) where main.go is in the root directory:

**Step 1: Add Go module dependency**
```bash
go get github.com/konflux-ci/coverport/instrumentation/go
```

**Step 2: Create coverage_init.go at the root**
```go
//go:build coverage

package main

import _ "github.com/konflux-ci/coverport/instrumentation/go"
```

**Step 3: Update Dockerfile**
```dockerfile
# Before
RUN CGO_ENABLED=0 go build -a -o manager main.go

# After
ARG ENABLE_COVERAGE=false

RUN if [ "$ENABLE_COVERAGE" = "true" ]; then \
        CGO_ENABLED=0 go build -cover -covermode=atomic -tags=coverage -o manager .; \
    else \
        CGO_ENABLED=0 go build -a -o manager .; \
    fi
```

### Example 2: Multiple Binaries

For a repository that builds `manager` and `snapshotgc`, where only `manager` needs coverage:

**Steps 1-2: Same as Example 1** (add Go module, create coverage_init.go)

**Step 3: Update Dockerfile**
```dockerfile
# Before
RUN CGO_ENABLED=0 go build -a -o manager . \
 && CGO_ENABLED=0 go build -a -o snapshotgc ./cmd/snapshotgc

# After
ARG ENABLE_COVERAGE=false

RUN if [ "$ENABLE_COVERAGE" = "true" ]; then \
        CGO_ENABLED=0 go build -cover -covermode=atomic -tags=coverage -o manager .; \
    else \
        CGO_ENABLED=0 go build -a -o manager .; \
    fi \
 && CGO_ENABLED=0 go build -a -o snapshotgc ./cmd/snapshotgc
```

**Note**:
- The `-tags=coverage` flag includes the `coverage_init.go` file
- Package-based build (`.`) is used
- snapshotgc binary is built separately without coverage instrumentation
- No external file downloads needed - coverport is a Go module dependency

## Summary

This skill automates coverport integration by:
1. Running pre-integration repository scan to understand structure
2. Analyzing the repository structure in detail
3. Asking clarifying questions about binaries, secrets, and storage
4. **Adding coverport as a Go module dependency** (NEW: enables hermetic builds!)
5. **Creating coverage_init.go with build tags** (NEW: cleaner approach)
6. Modifying the Dockerfile to support coverage builds with build tags
7. **Validating Dockerfile changes locally with podman/docker builds**
8. Adding instrumented image build to Tekton push pipeline with hermetic support
9. Updating e2e pipeline to use test-metadata v0.4 and instrumented images
10. Adding coverage collection task to e2e pipeline
11. Updating PR pipeline to build with coverage instrumentation and hermetic builds
12. Updating GitHub Actions to add codecov flags
13. Providing comprehensive post-integration validation checklist
14. Providing documentation for manual secret creation

The integration enables automatic e2e test coverage collection and upload to Codecov with proper flag separation from unit tests.

**Key improvements in this version:**
- **Hermetic builds**: Go module approach enables secure, reproducible hermetic builds
- **No external downloads**: Coverage server is a Go module dependency, not downloaded during build
- **Build tags**: Clean separation of coverage code using Go build tags
- **Early validation**: Podman/docker builds catch issues before CI/CD changes
- **Clear checklists**: Pre and post-integration checklists ensure nothing is missed
- **Better guidance**: Clarifies when e2e image references need updating vs source builds
- **Enhanced troubleshooting**: Covers common scenarios including Go module issues
