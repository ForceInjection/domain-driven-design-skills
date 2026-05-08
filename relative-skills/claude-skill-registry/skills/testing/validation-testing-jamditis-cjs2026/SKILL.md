---
name: validation-testing
description: Pre-deployment validation, content verification, and testing strategies for CJS2026 given the current lack of automated tests
---

# Validation & Testing

## When to Activate

Use this skill when the agent needs to:
- Validate changes before deployment
- Verify content generation succeeded
- Check for common failure patterns
- Understand why deployments fail
- Add validation to the pipeline

## Current Testing Status

**Critical context**: CJS2026 has NO automated tests. Playwright is installed but unused.

This creates validation requirements:
1. Manual verification of critical paths
2. Content file validation before deploy
3. Build output verification
4. Runtime error monitoring via admin panel

## Pre-Deployment Validation Checklist

### 1. Content File Validation

```bash
# Run content generation
npm run generate-all

# Verify files updated
ls -la src/content/

# Expected: Recent timestamps on all three files
# siteContent.js
# scheduleData.js
# organizationsData.js
```

### 2. Content Integrity Checks

```javascript
// siteContent.js must have:
timeline.length === 10  // 2017-2026
stats.length === 4      // summits, cities, attendees, mission
sections.details        // Homepage hero content
sections.footer         // Footer content
sections.expect         // What to expect section
```

### 3. Build Verification

```bash
npm run build

# Verify output
ls dist/
# Must contain: index.html, assets/

# Check for errors in build output
# Should NOT see: "error", "warning: missing"
```

### 4. Environment Verification

Required environment variables:
- `VITE_FIREBASE_API_KEY`
- `VITE_FIREBASE_AUTH_DOMAIN`
- `VITE_FIREBASE_PROJECT_ID`
- `VITE_FIREBASE_STORAGE_BUCKET`
- `VITE_FIREBASE_MESSAGING_SENDER_ID`
- `VITE_FIREBASE_APP_ID`

For content generation:
- `AIRTABLE_API_KEY`

## Common Failure Patterns

### Pattern 1: Empty Content Arrays

**Symptom**: Site shows missing content, blank sections
**Cause**: Airtable API failed or returned empty
**Check**: `timeline.length` and `stats.length` in siteContent.js
**Fix**: Re-run `npm run generate-content` with valid API key

### Pattern 2: Build Succeeds with Bad Content

**Symptom**: Deploy completes but site is broken
**Cause**: Content validation missing from pipeline
**Check**: Review generated content files before deploy
**Fix**: Add content validation step to deploy workflow

### Pattern 3: Firebase Function Errors

**Symptom**: Admin actions fail, webhooks don't process
**Cause**: Missing secrets, timeout, or code errors
**Check**: Admin panel → Errors tab
**Fix**: Check Cloud Function logs, verify secrets set

### Pattern 4: Auth Issues

**Symptom**: Users can't sign in or profile not saving
**Cause**: Missing Firestore document, rules mismatch
**Check**: Firestore Console → users collection
**Fix**: Ensure `ensureUserDocumentExists()` called before updates

## Manual Testing Checklist

### Critical Paths

- [ ] New user can sign in with Google
- [ ] Magic link auth works (check email, complete sign-in)
- [ ] Profile wizard appears for new users
- [ ] Profile saves correctly to Firestore
- [ ] Schedule page loads with sessions (if populated)
- [ ] Bookmark saves and count increments
- [ ] Admin panel accessible to admins

### Content Verification

- [ ] Homepage hero text matches Airtable
- [ ] Timeline shows 10 years
- [ ] Stats cards display correct numbers
- [ ] Sponsors appear if any in Airtable

## Adding Validation

### To Deploy Workflow

```yaml
# In .github/workflows/deploy.yml, after npm run generate-all:
- name: Validate content
  run: |
    node -e "
      const {timeline, stats} = require('./src/content/siteContent.js');
      if (timeline.length !== 10) process.exit(1);
      if (stats.length !== 4) process.exit(1);
      console.log('Content validation passed');
    "
```

### To Package.json

```json
{
  "scripts": {
    "validate": "node scripts/validate-content.cjs",
    "predeploy": "npm run validate && npm run build"
  }
}
```

## Integration Points

- **cms-content-pipeline** - For understanding content generation
- **firebase-patterns** - For runtime error monitoring

## Guidelines

1. Always run `npm run generate-all` before deployment
2. Check admin panel Errors tab after major deploys
3. Verify environment variables are set in CI/CD
4. Test auth flow after any AuthContext changes
5. Validate content file sizes (empty = something broke)
