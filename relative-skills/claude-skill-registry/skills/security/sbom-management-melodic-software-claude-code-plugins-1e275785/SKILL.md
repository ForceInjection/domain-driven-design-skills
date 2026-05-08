---
name: sbom-management
description: Software Bill of Materials management including generation, formats, vulnerability tracking, and supply chain security
allowed-tools: Read, Glob, Grep, Write, Edit, Task
---

# SBOM Management

Comprehensive guidance for Software Bill of Materials creation, maintenance, and supply chain security.

## When to Use This Skill

- Creating SBOMs for software releases
- Responding to customer SBOM requests
- Tracking software components and dependencies
- Implementing supply chain security
- Meeting regulatory requirements (Executive Order 14028, EU CRA)

## SBOM Fundamentals

### What is an SBOM?

A Software Bill of Materials is a formal, machine-readable inventory of software components and dependencies, their relationships, and associated metadata.

```text
Your Application
├── Dependency A (v1.2.3) → Transitive Dep X
├── Dependency B (v2.0.0) → Transitive Dep Y, Z
├── Dependency C (v3.1.0)
└── Direct code components
```

### NTIA Minimum Elements

Required elements per NTIA SBOM guidelines:

| Element | Description | Example |
|---------|-------------|---------|
| **Supplier Name** | Entity that creates/maintains | "Microsoft" |
| **Component Name** | Designation of component | "System.Text.Json" |
| **Version** | Version identifier | "8.0.0" |
| **Other Unique Identifiers** | Additional IDs | PURL, CPE |
| **Dependency Relationship** | Upstream/downstream | "depends-on" |
| **Author of SBOM Data** | Who created SBOM | "Contoso Inc" |
| **Timestamp** | When SBOM created | "2025-01-15T10:30:00Z" |

### SBOM Formats

| Format | Strengths | Use Case |
|--------|-----------|----------|
| **CycloneDX** | Security-focused, VEX support | Vulnerability management |
| **SPDX** | License-focused, ISO standard | License compliance |
| **SWID** | Software identification | Asset management |

## CycloneDX (Recommended)

### Basic Structure

```json
{
  "$schema": "http://cyclonedx.org/schema/bom-1.5.schema.json",
  "bomFormat": "CycloneDX",
  "specVersion": "1.5",
  "version": 1,
  "serialNumber": "urn:uuid:3e671687-395b-41f5-a30f-a58921a69b79",
  "metadata": {
    "timestamp": "2025-01-15T10:30:00Z",
    "tools": [
      {
        "vendor": "CycloneDX",
        "name": "cyclonedx-dotnet",
        "version": "3.0.0"
      }
    ],
    "component": {
      "type": "application",
      "name": "MyApplication",
      "version": "1.0.0"
    }
  },
  "components": [
    {
      "type": "library",
      "bom-ref": "pkg:nuget/Newtonsoft.Json@13.0.3",
      "name": "Newtonsoft.Json",
      "version": "13.0.3",
      "purl": "pkg:nuget/Newtonsoft.Json@13.0.3",
      "licenses": [
        {
          "license": {
            "id": "MIT"
          }
        }
      ],
      "hashes": [
        {
          "alg": "SHA-256",
          "content": "a5c9a4e..."
        }
      ]
    }
  ],
  "dependencies": [
    {
      "ref": "pkg:nuget/MyApplication@1.0.0",
      "dependsOn": [
        "pkg:nuget/Newtonsoft.Json@13.0.3"
      ]
    }
  ]
}
```

### Component Types

```text
application    - Standalone application
framework      - Software framework
library        - Software library
container      - Container image
operating-system
device         - Hardware device
firmware       - Device firmware
file           - Arbitrary file
machine-learning-model
data           - Data assets
```

## .NET SBOM Generation

### Using CycloneDX Tool

```bash
# Install the tool
dotnet tool install --global CycloneDX

# Generate SBOM for solution
dotnet CycloneDX MyApp.sln -o sbom.json -j

# Include dev dependencies
dotnet CycloneDX MyApp.sln -o sbom.json -j --include-dev

# Recursive for all projects
dotnet CycloneDX . -o sbom.json -j -r
```

### Integration with Build

```xml
<!-- Add to Directory.Build.props -->
<PropertyGroup>
  <GenerateSBOM>true</GenerateSBOM>
  <SBOMFormat>CycloneDX</SBOMFormat>
</PropertyGroup>

<!-- MSBuild target -->
<Target Name="GenerateSBOM" AfterTargets="Build" Condition="'$(GenerateSBOM)'=='true'">
  <Exec Command="dotnet CycloneDX $(MSBuildProjectFullPath) -o $(OutputPath)sbom.json -j" />
</Target>
```

### Programmatic Generation

```csharp
using CycloneDX.Models;

public class SbomGenerator
{
    public Bom GenerateSbom(Project project, IEnumerable<PackageReference> packages)
    {
        var bom = new Bom
        {
            Version = 1,
            SerialNumber = $"urn:uuid:{Guid.NewGuid()}",
            Metadata = new Metadata
            {
                Timestamp = DateTime.UtcNow,
                Component = new Component
                {
                    Type = Component.Classification.Application,
                    Name = project.Name,
                    Version = project.Version
                }
            },
            Components = new List<Component>()
        };

        foreach (var pkg in packages)
        {
            bom.Components.Add(new Component
            {
                Type = Component.Classification.Library,
                BomRef = $"pkg:nuget/{pkg.Id}@{pkg.Version}",
                Name = pkg.Id,
                Version = pkg.Version,
                Purl = $"pkg:nuget/{pkg.Id}@{pkg.Version}",
                Licenses = pkg.Licenses?.Select(l => new LicenseChoice
                {
                    License = new License { Id = l }
                }).ToList()
            });
        }

        return bom;
    }
}
```

## Vulnerability Management

### VEX (Vulnerability Exploitability eXchange)

VEX documents state whether vulnerabilities apply to your product:

```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.5",
  "vulnerabilities": [
    {
      "id": "CVE-2023-12345",
      "source": {
        "name": "NVD",
        "url": "https://nvd.nist.gov/vuln/detail/CVE-2023-12345"
      },
      "ratings": [
        {
          "severity": "high",
          "score": 7.5,
          "method": "CVSSv3"
        }
      ],
      "analysis": {
        "state": "not_affected",
        "justification": "code_not_reachable",
        "detail": "Vulnerable code path not used in our implementation"
      },
      "affects": [
        {
          "ref": "pkg:nuget/SomePackage@1.0.0"
        }
      ]
    }
  ]
}
```

### VEX States

| State | Meaning |
|-------|---------|
| `exploitable` | Vulnerability is exploitable |
| `in_triage` | Currently investigating |
| `not_affected` | Not vulnerable |
| `resolved` | Fixed in current version |

### Vulnerability Tracking Service

```csharp
public class VulnerabilityTracker
{
    private readonly IVulnerabilityDatabase _vulnDb;
    private readonly ISbomRepository _sbomRepo;

    public async Task<VulnerabilityReport> ScanSbom(
        string sbomPath,
        CancellationToken ct)
    {
        var sbom = await _sbomRepo.Load(sbomPath, ct);
        var report = new VulnerabilityReport
        {
            SbomSerialNumber = sbom.SerialNumber,
            ScanTimestamp = DateTimeOffset.UtcNow
        };

        foreach (var component in sbom.Components)
        {
            var vulns = await _vulnDb.GetVulnerabilities(
                component.Purl,
                ct);

            foreach (var vuln in vulns)
            {
                report.Vulnerabilities.Add(new VulnerabilityFinding
                {
                    ComponentRef = component.BomRef,
                    ComponentName = component.Name,
                    ComponentVersion = component.Version,
                    CveId = vuln.Id,
                    Severity = vuln.Severity,
                    CvssScore = vuln.CvssScore,
                    Description = vuln.Description,
                    FixedInVersion = vuln.FixedInVersion,
                    VexStatus = DetermineVexStatus(component, vuln)
                });
            }
        }

        return report;
    }

    private VexStatus DetermineVexStatus(Component component, Vulnerability vuln)
    {
        // Check if we have an existing VEX determination
        // Otherwise mark as in_triage
        return VexStatus.InTriage;
    }
}
```

## Supply Chain Security

### SLSA (Supply-chain Levels for Software Artifacts)

| Level | Requirements |
|-------|--------------|
| **SLSA 1** | Build process documented, provenance generated |
| **SLSA 2** | Version control, hosted build service |
| **SLSA 3** | Hardened builds, provenance verified |
| **SLSA 4** | Two-person review, hermetic builds |

### Package Verification

```csharp
public class PackageIntegrityVerifier
{
    public async Task<VerificationResult> VerifyPackage(
        PackageReference package,
        CancellationToken ct)
    {
        var result = new VerificationResult { Package = package };

        // Check package signature
        var signature = await GetPackageSignature(package, ct);
        if (signature != null)
        {
            result.IsSigned = true;
            result.SignatureValid = await VerifySignature(signature, ct);
            result.SignerCertificate = signature.Certificate;
        }

        // Verify hash against known-good sources
        var packageHash = await ComputePackageHash(package, ct);
        var expectedHash = await GetExpectedHash(package, ct);
        result.HashMatch = packageHash == expectedHash;

        // Check for known vulnerabilities
        result.Vulnerabilities = await ScanForVulnerabilities(package, ct);

        // Check package age and maintenance status
        result.LastUpdated = await GetLastUpdateDate(package, ct);
        result.IsDeprecated = await CheckDeprecationStatus(package, ct);

        return result;
    }
}
```

### Dependency Pinning

```xml
<!-- Enable package lock file for reproducible builds -->
<PropertyGroup>
  <RestorePackagesWithLockFile>true</RestorePackagesWithLockFile>
  <RestoreLockedMode Condition="'$(CI)' == 'true'">true</RestoreLockedMode>
</PropertyGroup>
```

## CI/CD Integration

### GitHub Actions SBOM Generation

```yaml
name: Generate SBOM

on:
  release:
    types: [published]

jobs:
  sbom:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '10.0.x'

      - name: Install CycloneDX
        run: dotnet tool install --global CycloneDX

      - name: Generate SBOM
        run: |
          dotnet CycloneDX MySolution.sln \
            -o sbom.json \
            -j \
            --set-version ${{ github.event.release.tag_name }}

      - name: Sign SBOM
        run: |
          # Sign with cosign or similar
          cosign sign-blob --key ${{ secrets.SIGNING_KEY }} sbom.json

      - name: Upload SBOM to Release
        uses: actions/upload-release-asset@v1
        with:
          upload_url: ${{ github.event.release.upload_url }}
          asset_path: ./sbom.json
          asset_name: sbom.json
          asset_content_type: application/json

      - name: Scan for vulnerabilities
        run: |
          grype sbom:sbom.json --fail-on high
```

### SBOM Attestation

```yaml
      - name: Generate SBOM Attestation
        uses: actions/attest-sbom@v1
        with:
          subject-path: './bin/MyApp.dll'
          sbom-path: './sbom.json'
```

## SBOM Distribution

### Where to Publish

| Channel | Format | Audience |
|---------|--------|----------|
| Release assets | JSON/XML | Developers, security teams |
| API endpoint | JSON | Automated systems |
| Documentation | Human-readable | Auditors, customers |
| Container labels | Reference | Container runtime |

### Container Integration

```dockerfile
# Include SBOM in container
LABEL org.opencontainers.image.sbom="sbom.json"
COPY sbom.json /app/sbom.json

# Or generate at build time
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
RUN dotnet tool install --global CycloneDX
RUN dotnet CycloneDX /src/MyApp.csproj -o /app/sbom.json -j
```

## Regulatory Requirements

### Executive Order 14028 (US)

Requirements for software sold to US government:

- SBOM required for all software
- Must include all components
- Machine-readable format (SPDX, CycloneDX)
- VEX for vulnerability status
- Regular updates

### EU Cyber Resilience Act

Upcoming requirements:

- SBOM for all products with digital elements
- Vulnerability handling procedures
- Security updates for product lifetime
- Reporting of actively exploited vulnerabilities

## SBOM Checklist

### Generation

- [ ] All direct dependencies included
- [ ] Transitive dependencies resolved
- [ ] Versions accurately recorded
- [ ] Licenses identified
- [ ] Hashes computed
- [ ] PURLs generated

### Quality

- [ ] NTIA minimum elements present
- [ ] Machine-readable format
- [ ] Valid against schema
- [ ] Accurate dependency graph
- [ ] Matches actual deployed software

### Distribution

- [ ] Included in release artifacts
- [ ] Available via API (if applicable)
- [ ] Signed/attested
- [ ] VEX document available
- [ ] Customer access method documented

## Cross-References

- **License Compliance**: `license-compliance` for license obligations
- **Security**: `security-frameworks` for supply chain security
- **AI Governance**: `ai-governance` for ML model SBOMs

## Resources

- [NTIA SBOM Documents](https://www.ntia.gov/page/software-bill-materials)
- [CycloneDX Specification](https://cyclonedx.org/specification/overview/)
- [SPDX Specification](https://spdx.github.io/spdx-spec/)
- [CISA SBOM Resources](https://www.cisa.gov/sbom)
