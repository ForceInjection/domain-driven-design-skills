---
name: release-guardian
description: Manages VoiceLite releases by ensuring version consistency across all files, coordinating the release workflow, and monitoring deployment. Activates when version numbers are mentioned or release work begins.
---

# Release Guardian

This skill ensures smooth releases by maintaining version consistency and following the proven release workflow.

## When This Skill Activates

- Mentioning version numbers (e.g., "v1.0.97", "bump to 1.0.98")
- Commands like "release", "ship", "deploy", "new version"
- Creating git tags
- Modifying version-containing files

## Version Synchronization Points

### Desktop Application
**File**: `VoiceLite/VoiceLite/VoiceLite.csproj`
```xml
<Version>1.0.97</Version>
<FileVersion>1.0.97.0</FileVersion>
<AssemblyVersion>1.0.97.0</AssemblyVersion>
```

### Installer Script
**File**: `VoiceLite/Installer/VoiceLiteSetup.iss`
```ini
AppVersion=1.0.97
VersionInfoVersion=1.0.97
OutputBaseFilename=VoiceLite-Setup-1.0.97
```

### Web Application
**File**: `voicelite-web/package.json`
```json
"version": "0.1.0"  // Note: Web version independent of desktop
```

### Download Endpoint
**File**: `voicelite-web/app/api/download/route.ts`
```typescript
const CURRENT_VERSION = 'v1.0.97';
const INSTALLER_FILENAME = `VoiceLite-Setup-1.0.97.exe`;
```

### Website Homepage
**Files**:
- `voicelite-web/components/home/hero-section.tsx`
- `voicelite-web/components/home/cta-section.tsx`
```typescript
href="/api/download?version=1.0.97"
```

### Documentation
**File**: `CLAUDE.md`
```markdown
**Current Desktop**: v1.0.97
```

## Release Workflow

### Phase 1: Pre-Release
```bash
# 1. Ensure clean working directory
git status

# 2. Run tests
dotnet test VoiceLite/VoiceLite.Tests/VoiceLite.Tests.csproj

# 3. Update all version locations (see above)

# 4. Build in Release mode
dotnet build VoiceLite/VoiceLite.sln -c Release
```

### Phase 2: Build & Package
```bash
# 5. Publish self-contained
dotnet publish VoiceLite/VoiceLite/VoiceLite.csproj -c Release -r win-x64 --self-contained

# 6. Build installer
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" /Q VoiceLite/Installer/VoiceLiteSetup.iss

# 7. Verify installer size (should be ~100-150MB with model)
```

### Phase 3: Git & Deploy
```bash
# 8. Commit version changes
git add -A
git commit -m "release: v1.0.97"

# 9. Create and push tag (triggers GitHub Actions)
git tag v1.0.97
git push origin master --tags

# 10. Monitor GitHub Actions (~5-7 minutes)
gh run list --workflow release.yml
```

### Phase 4: Post-Release
```bash
# 11. Verify GitHub Release created
gh release view v1.0.97

# 12. Test download from website
curl -I https://voicelite.app/api/download

# 13. Update website if needed
cd voicelite-web && vercel deploy --prod
```

## Version Numbering Convention

**Format**: `MAJOR.MINOR.PATCH`
- **MAJOR** (1.x.x): Breaking changes, major features
- **MINOR** (x.1.x): New features, Pro models, UI changes
- **PATCH** (x.x.1): Bug fixes, performance improvements

**Recent versions**:
- v1.0.96: CRITICAL - Fixed missing model file
- v1.0.95: BROKEN - Model not bundled
- v1.0.94: Fixed logging in Release builds

## Common Issues & Solutions

### Version Mismatch Detected
1. List all files with old version
2. Update systematically (desktop → installer → web)
3. Commit all changes together

### GitHub Actions Failed
```bash
# Check workflow logs
gh run view [run-id] --log

# Common failures:
# - Tag already exists → Delete and recreate
# - Tests failing → Fix before release
# - Upload failed → Retry workflow
```

### Installer Too Small (<50MB)
**CRITICAL**: Model file missing! Check:
- Is `ggml-tiny.bin` in `VoiceLite/whisper/`?
- Is it referenced in `.iss` file?

## GitHub Actions Monitoring

Watch the release workflow in real-time:

```bash
# Watch workflow (blocks until complete ~5-7 min)
gh run watch

# Check latest workflow status
gh run list --workflow release.yml --limit 1

# View logs if failed
gh run view --log

# Expected: "completed" status with green checkmark
```