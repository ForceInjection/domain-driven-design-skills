---
name: trivy
description: This skill should be used when scanning container images, filesystems, or repositories for vulnerabilities using Trivy. Use for CVE detection, security analysis, vulnerability comparison across image versions, understanding scan output (severity levels, status fields), and batch scanning multiple images.
---

# Trivy Vulnerability Scanner

## Core Commands

### Node.js / Filesystem Scanning

```bash
# Scan current directory for vulnerabilities (package.json/package-lock.json)
trivy fs --scanners vuln .

# Include dev dependencies (devDependencies in package.json)
trivy fs --scanners vuln --include-dev-deps .

# Scan specific package-lock.json file
trivy fs --scanners vuln package-lock.json

# JSON output for CI/CD pipelines
trivy fs --scanners vuln --format json -o results.json .

# Fail on HIGH/CRITICAL only
trivy fs --scanners vuln --severity HIGH,CRITICAL .

# Scan a repository (GitHub URL)
trivy repo --scanners vuln https://github.com/org/repo
```

**Supported Node.js files:**
- `package.json` + `package-lock.json` (npm)
- `yarn.lock` (Yarn)
- `pnpm-lock.yaml` (pnpm)

### Basic Image Scanning

```bash
# Scan with severity filter (recommended)
trivy image --severity HIGH,CRITICAL <image:tag>

# All severities
trivy image <image:tag>

# JSON output for automation
trivy image --format json --output results.json <image:tag>
```

### Common Patterns

```bash
# Compare two versions
trivy image --severity HIGH,CRITICAL image:18.3.2 > v1.txt
trivy image --severity HIGH,CRITICAL image:18.4.0 > v2.txt
diff v1.txt v2.txt

# Batch scan multiple images (use provided script)
scripts/batch_scan.sh alpine:latest nginx:latest postgres:16

# Compare versions (use provided script)
scripts/compare_versions.sh public.ecr.aws/org/image 18.3.2 18.4.0 18.5.0
```

## Output Formats

```bash
# Table (default, human-readable)
trivy image --format table <image:tag>

# JSON (machine-readable)
trivy image --format json <image:tag>

# SARIF (GitHub/GitLab integration)
trivy image --format sarif <image:tag>
```

## Scanner Types

Use `--scanners` to control what Trivy scans:

```bash
# Vulnerability only (faster, recommended)
trivy image --scanners vuln <image:tag>

# Vulnerabilities + secrets
trivy image --scanners vuln,secret <image:tag>

# All scanners (vuln, secret, misconfig, license)
trivy image <image:tag>
```

**Default:** All scanners enabled. Use `--scanners vuln` to disable secret scanning for faster scans.

## Performance Options

```bash
# Skip database update (use cached DB)
trivy image --skip-db-update <image:tag>

# Skip version check notification
trivy image --skip-version-check <image:tag>

# Disable secret scanning (faster)
trivy image --scanners vuln <image:tag>
```

## Understanding Output

For detailed interpretation of Trivy output including status fields, severity levels, and false positives, see [output_interpretation.md](references/output_interpretation.md).

**Quick reference:**
- **Status `fixed`**: Patch available (check Fixed Version column)
- **Status `affected`**: No fix available yet
- **Status `will_not_fix`**: Vendor won't patch
- **False positives**: Status shows `fixed` but CVE still appears (common with Go binaries)

## Common Use Cases

### Compare Vulnerabilities Across Versions

Use the provided script:

```bash
scripts/compare_versions.sh public.ecr.aws/org/image 14.4.1 15.5.4 16.5.9 17.7.10 18.0.0
```

Or manually:

```bash
for version in 14.4.1 15.5.4 16.5.9; do
  trivy image --severity HIGH,CRITICAL image:$version > scan-$version.txt
done
```

### Track Specific CVEs

```bash
# Scan and grep for specific CVE
trivy image <image:tag> | grep CVE-2025-6020

# JSON query for specific CVE
trivy image --format json <image:tag> | \
  jq '.Results[].Vulnerabilities[] | select(.VulnerabilityID == "CVE-2025-6020")'
```

### CI/CD Integration

```bash
# Fail build on HIGH/CRITICAL findings
trivy image --exit-code 1 --severity HIGH,CRITICAL <image:tag>

# Generate SARIF for GitHub
trivy image --format sarif --output trivy-results.sarif <image:tag>
```

## Batch Scanning

For scanning multiple images efficiently:

```bash
# Use provided script (scans in parallel)
scripts/batch_scan.sh image1:tag1 image2:tag2 image3:tag3

# Configure parallelism
TRIVY_MAX_PARALLEL=10 scripts/batch_scan.sh image1 image2 image3

# Custom output directory
TRIVY_OUTPUT_DIR=./scans scripts/batch_scan.sh image1 image2
```

## Filtering and Ignoring

```bash
# Only show vulnerabilities with fixes
trivy image --ignore-unfixed <image:tag>

# Ignore specific CVEs (.trivyignore file)
cat > .trivyignore <<EOF
CVE-2022-36633
CVE-2023-12345
EOF
trivy image <image:tag>
```

## Best Practices

1. **Always filter by severity** for focused analysis: `--severity HIGH,CRITICAL`
2. **Use JSON for automation** to enable scripting and parsing
3. **Disable secret scanning** when not needed: `--scanners vuln`
4. **Skip DB updates** in CI/CD after initial download: `--skip-db-update`
5. **Verify "fixed" status** - Check if installed version >= fixed version (false positives common)
6. **Use provided scripts** for comparing versions or batch scanning
7. **Document ignored CVEs** in .trivyignore with comments explaining why

## Troubleshooting

**Slow scans:**
```bash
trivy image --scanners vuln --skip-db-update <image:tag>
```

**Too many false positives:**
```bash
trivy image --ignore-unfixed <image:tag>
```

**Database update failures:**
```bash
trivy image --download-db-only
```

## References

- [Output Interpretation Guide](references/output_interpretation.md) - Detailed guide for understanding scan results
- [Official Documentation](https://aquasecurity.github.io/trivy/)
- [GitHub Repository](https://github.com/aquasecurity/trivy)
