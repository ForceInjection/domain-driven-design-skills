---
name: release-automation
description: Automate library releases, NuGet package publishing, and API versioning. Use when working with NuGet releases, package versioning, API compatibility checks, library releases, or semantic versioning for shared libraries. Handles package publishing, version management, and breaking change detection.
---

# Release Automation Specialist

## Mission
Automate and streamline releases for the Lidarr.Plugin.Common shared library, ensuring proper NuGet package publishing, API compatibility, and semantic versioning for downstream consumers.

## Expertise Areas

### 1. NuGet Package Management
- Publish to NuGet.org and GitHub Packages
- Handle package versioning (library vs. API versioning)
- Manage package metadata and dependencies
- Implement package signing
- Handle pre-release packages (alpha, beta, rc)

### 2. API Compatibility Management
- Run API compatibility checks (microsoft.dotnet.apicompat.tool)
- Detect breaking changes in public API
- Generate public API surface files
- Validate API changes against previous versions
- Document breaking changes

### 3. Semantic Versioning for Libraries
- MAJOR: Breaking API changes
- MINOR: Backward-compatible features
- PATCH: Backward-compatible bug fixes
- Pre-release: alpha, beta, rc suffixes

### 4. Multi-Package Coordination
- Coordinate releases of Lidarr.Plugin.Abstractions and Lidarr.Plugin.Common
- Ensure version alignment between packages
- Handle dependency version updates
- Manage package references in consuming projects

### 5. Release Validation
- Run full test suite across all TFMs (net6.0, net8.0)
- Validate public API against previous release
- Check documentation is current
- Verify package metadata
- Test package installation

## Current Project Context

### Lidarr.Plugin.Common Infrastructure
- **Current Status**: Enterprise-grade (release.yml exists)
- **Package Type**: NuGet library (.nupkg)
- **Target Frameworks**: net6.0, net8.0 (multi-targeting)
- **Packages**:
  - Lidarr.Plugin.Abstractions (host-owned ABI)
  - Lidarr.Plugin.Common (main library)
- **Publishing**: NuGet.org + GitHub Packages
- **API Validation**: microsoft.dotnet.apicompat.tool
- **Existing Workflows**: release.yml, publish-packages.yml

### Key Files to Maintain
- `.github/workflows/release.yml` - Main release workflow
- `.github/workflows/publish-packages.yml` - GitHub Packages publishing
- `src/Lidarr.Plugin.Common.csproj` - Main library version
- `src/Abstractions/Lidarr.Plugin.Abstractions.csproj` - Abstractions version
- `CHANGELOG.md` - Version history with breaking changes
- `Directory.Build.props` - Shared build properties
- `.config/PublicAPI/*/*.txt` - Public API surface files

## Best Practices

### Library Versioning Strategy
1. **Breaking Changes** (MAJOR bump):
   - Public API changes (renames, removals)
   - Interface changes
   - Behavior changes that break consumers
   - Dependency major version changes

2. **New Features** (MINOR bump):
   - New public APIs
   - New interfaces
   - Optional parameters
   - New dependency features

3. **Bug Fixes** (PATCH bump):
   - Internal fixes
   - Documentation updates
   - Performance improvements (non-breaking)

### Release Process
1. **Pre-release Validation**:
   - All tests pass on all TFMs
   - API compatibility check passes
   - Public API files updated
   - CHANGELOG updated with breaking changes
   - Documentation current
   - Examples updated

2. **Release Execution**:
   - Create version tag
   - Trigger release workflow
   - Build for all TFMs
   - Pack NuGet packages
   - Run API compatibility check
   - Publish to NuGet.org
   - Publish to GitHub Packages
   - Create GitHub release

3. **Post-release**:
   - Update consuming projects (Brainarr, Qobuzarr, Tidalarr)
   - Notify plugin developers
   - Update documentation
   - Monitor package downloads

### Breaking Change Communication
```markdown
## Breaking Changes in v1.2.0

### Removed
- ❌ `IStreamingService.GetTrackAsync()` - Use `GetTrackDetailsAsync()` instead
- ❌ `TokenStorage.Store()` - Use `TokenStorage.StoreAsync()` for async support

### Changed
- 🔄 `IAuthenticationService.AuthenticateAsync()` now returns `AuthResult` instead of `bool`
- 🔄 `CacheOptions.DefaultExpiration` changed from `TimeSpan` to `CacheExpiration` struct

### Migration Guide
See [MIGRATION.md](docs/migration/v1.1-to-v1.2.md) for detailed upgrade instructions.
```

## Commands & Scripts

### Version Update
```bash
# Update version in csproj files
# (No automated script exists - manual update needed)
# Enhancement opportunity: Create version bump script
```

### API Surface Update
```bash
# Generate public API files
dotnet tool restore
dotnet public-api-generator src/Lidarr.Plugin.Common.csproj -o .config/PublicAPI/net6.0/PublicAPI.Shipped.txt
```

### Package Build
```bash
# Pack packages locally
dotnet pack src/Lidarr.Plugin.Abstractions.csproj -c Release -o dist/
dotnet pack src/Lidarr.Plugin.Common.csproj -c Release -o dist/
```

### Package Publish
```bash
# Publish to NuGet.org (requires API key)
dotnet nuget push dist/*.nupkg --source https://api.nuget.org/v3/index.json --api-key $NUGET_API_KEY --skip-duplicate
```

### API Compatibility Check
```bash
# Check against previous version
dotnet tool restore
dotnet apicompat --package Lidarr.Plugin.Common --package-version 1.1.5 --assembly dist/Lidarr.Plugin.Common.dll
```

## Workflow Integration

### GitHub Actions Release Flow
1. **Trigger**: Tag push `v*.*.*` or manual dispatch
2. **Build**: Restore and build for net6.0 + net8.0
3. **Validate**: Public API drift checks for both TFMs
4. **Test**: Run test suite (with timing flake filters on tags)
5. **Pack**: Create NuGet packages with ContinuousIntegrationBuild=true
6. **API Check**: Validate compatibility with previous release
7. **Publish**: Push to NuGet.org (if NUGET_API_KEY present)
8. **Release**: Create GitHub release

### Release Checklist
- [ ] Update version in both csproj files
- [ ] Update PublicAPI.Shipped.txt for breaking changes
- [ ] Update CHANGELOG.md with categorized changes
- [ ] Update documentation for new features
- [ ] Run tests locally: `dotnet test`
- [ ] Check API compatibility: `dotnet apicompat`
- [ ] Commit changes: `git commit -m "chore: release v1.2.0"`
- [ ] Create tag: `git tag -a v1.2.0 -m "Release 1.2.0"`
- [ ] Push tag: `git push origin v1.2.0`
- [ ] Monitor release workflow
- [ ] Verify NuGet.org package published
- [ ] Update consuming projects
- [ ] Announce in plugin developer channels

## Troubleshooting

### API Compatibility Check Fails
**Problem**: New version breaks API contract
**Solution**:
1. Review PublicAPI.Unshipped.txt changes
2. If breaking: Bump MAJOR version
3. If new APIs: Move to PublicAPI.Shipped.txt
4. Document breaking changes in CHANGELOG

### NuGet Publish Fails
**Problem**: Package already exists or API key invalid
**Solution**:
1. Check NuGet.org for existing version
2. Verify NUGET_API_KEY secret is set and valid
3. Use --skip-duplicate flag

### Test Failures on Release
**Problem**: Tests fail during release but pass locally
**Solution**:
1. Check for timing-sensitive tests (flaky tests)
2. Run with same TFM as CI (net8.0)
3. Consider adding test filters for known flakes

### Multi-TFM Build Issues
**Problem**: Build succeeds for net6.0 but fails for net8.0
**Solution**:
1. Check conditional dependencies in csproj
2. Verify framework-specific code paths
3. Test locally with `dotnet build -f net8.0`

## Enhancement Opportunities

### For Lidarr.Plugin.Common
1. **Automated Version Bumping**: Create script to update versions in csproj files
2. **Release Drafter**: Auto-generate release notes from PRs
3. **Package Signing**: Add strong-name signing for assemblies
4. **Symbol Packages**: Publish symbol packages for debugging
5. **Pre-release Channel**: Automated beta packages from develop branch
6. **Compatibility Matrix**: Document which versions work with which Lidarr versions
7. **Migration Tools**: Create CLI tool to help upgrade between major versions

## Related Skills
- `artifact-manager` - Handle package lifecycle
- `api-versioning` - Manage API compatibility
- `code-quality` - Ensure quality before release

## Examples

### Example 1: Release New Version with Breaking Changes
**User**: "Release version 1.3.0 with the new authentication API"
**Action**:
1. Verify breaking changes documented in CHANGELOG.md
2. Update PublicAPI.Shipped.txt
3. Update both csproj versions to 1.3.0
4. Create migration guide in docs/migration/
5. Commit and create tag v1.3.0
6. Monitor release workflow
7. Verify API compatibility check runs (may fail if breaking, but documented)
8. Publish to NuGet.org
9. Create GitHub release with migration notes
10. Update consuming projects

### Example 2: Fix API Compatibility Error
**User**: "The API compatibility check is failing"
**Action**:
1. Review PublicAPI.Unshipped.txt for changes
2. Identify breaking vs. non-breaking changes
3. If breaking: Ensure MAJOR version bump
4. Move new APIs from Unshipped to Shipped
5. Update CHANGELOG.md with breaking change details
6. Re-run release workflow

### Example 3: Publish Pre-release Package
**User**: "Publish a beta package for testing"
**Action**:
1. Update versions to 1.3.0-beta.1
2. Create tag v1.3.0-beta.1
3. Push tag to trigger release
4. Verify package published with beta suffix
5. Test installation in consumer project
6. Document beta features for testers
