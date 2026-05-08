---
name: justfile-security-patterns
description: Level 2 patterns - vulns, lic, sbom, doctor (security, compliance, environment health)
---

# Security Patterns (Level 2)

Add when deploying. Security scanning, license compliance, SBOM generation, environment validation.

## Commands

### vulns

Vulnerability scanning. CRITICAL only, quick feedback.

```just
# Check for security vulnerabilities
vulns:
    <scan for vulnerabilities, fail on CRITICAL, fixable only>
```

**Using Grype:**
```just
vulns:
    grype .venv --fail-on critical --only-fixed
```

**Multi-tier scanning:**
```just
# Quick scan (CRITICAL only)
vulns:
    grype .venv --fail-on critical --only-fixed

# Detailed scan (MEDIUM and above)
vulns-detailed:
    grype .venv --fail-on medium --scope all-layers -o table

# CI scan (HIGH+, JSON output)
vulns-ci:
    grype .venv --fail-on high --only-fixed -o json --file grype-report.json
```

### lic

License compliance. Production dependencies only, strict checking.

```just
# Analyze licenses (flag GPL, etc.)
lic:
    <check production deps only, fail on GPL/LGPL/AGPL>
```

**Python (isolated venv):**
```just
lic:
    #!/usr/bin/env bash
    set -e
    [ ! -d .venv-lic ] && uv venv .venv-lic
    source .venv-lic/bin/activate
    uv pip install -e . --quiet
    uv pip install pip-licenses --quiet
    pip-licenses --fail-on="GPL;LGPL;AGPL" --partial-match --format=plain
    deactivate
```

**JavaScript:**
```just
lic:
    #!/usr/bin/env bash
    OUTPUT=$(pnpm exec licensee --osi 2>&1 || true)
    if echo "$OUTPUT" | grep -qiE "GPL|LGPL|AGPL"; then
        echo "❌ GPL/LGPL/AGPL found"
        exit 1
    fi
    echo "✅ License check passed"
```

**Dev dependencies allowed:**
```just
lic-dev:
    uv run pip-licenses --fail-on="GPL;LGPL;AGPL" --partial-match \
      --ignore-packages pytest ruff chardet
```

### sbom

Software Bill of Materials. CycloneDX format.

```just
# Generate software bill of materials
sbom:
    <generate SBOM in CycloneDX format>
```

**Using Syft:**
```just
sbom:
    syft dir:. -o cyclonedx-json > sbom.json
```

**Polyglot:**
```just
sbom:
    syft dir:./api -o cyclonedx-json > sbom-api.json
    syft dir:./web -o cyclonedx-json > sbom-web.json
```

**Scan SBOM:**
```just
security-scan: sbom
    grype sbom:./sbom.json --fail-on critical --only-fixed
```

### doctor

Environment health check. Required tools, versions, services.

```just
# Check development environment health
doctor:
    <validate required tools installed, show versions>
```

**Basic:**
```just
doctor:
    @echo "Checking environment..."
    @which just >/dev/null && echo "✅ just" || echo "❌ just"
    @which python3 >/dev/null && echo "✅ python3" || echo "❌ python3"
    @which uv >/dev/null && echo "✅ uv" || echo "❌ uv"
```

**With versions:**
```just
doctor:
    #!/usr/bin/env bash
    echo "Required tools:"
    which just >/dev/null && echo "✅ just $(just --version)" || echo "❌ just"
    which python3 >/dev/null && echo "✅ python3 $(python3 --version)" || echo "❌ python3"
    which node >/dev/null && echo "✅ node $(node --version)" || echo "❌ node"
    echo ""
    echo "Optional tools:"
    which grype >/dev/null && echo "✅ grype" || echo "⚠️  grype (security scanning)"
    which syft >/dev/null && echo "✅ syft" || echo "⚠️  syft (SBOM generation)"
```

## Configuration Files

**.grype.yaml:**
```yaml
only-fixed: true
fail-on-severity: critical
ignore:
  - vulnerability: CVE-2025-12345
    fix-state: wont-fix
    reason: "Build tool only, not distributed"
output: table
```

## When to Add Level 2

Add when:
- Deploying to production
- Security requirements exist
- Compliance needs (SOC2, etc.)
- Handling sensitive data

Skip when:
- Internal tools only
- Prototype/demo
- No deployment plans

## Pattern: Production License Checking

Problem: Dev dependencies can use GPL. Production dependencies cannot.

Solution: Isolated environment for production-only check.

**Python:**
1. Create `.venv-lic` with production deps only
2. Install project without `[dev]` extras
3. Check licenses strictly (no exceptions)
4. Clean rebuild: `rm -rf .venv-lic`

**JavaScript:**
Licensee separates dev/prod automatically.

## Pattern: Multi-Tier Scanning

Three scan levels:

1. **vulns** (dev feedback): CRITICAL, fixable, fast
2. **vulns-detailed** (weekly review): MEDIUM+, all layers
3. **vulns-ci** (CI pipeline): HIGH+, JSON output

Developers get fast feedback. Security team gets comprehensive reports.

## Pattern: Environment Validation

Check before first run:
- Required tools installed
- Versions meet minimum
- Optional tools available
- Services running (docker ps)

Prevents "command not found" confusion.
