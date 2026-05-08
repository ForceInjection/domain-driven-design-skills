---
name: atlas-full
description: Full 9-phase workflow for complex features, epics, and security-critical changes (2-4 hours)
---

# Atlas Full Workflow

## When to Use This Skill

**Perfect for (complex tasks, ~5% of work):**
- Major features (6+ files affected)
- New modules or services
- Security-critical changes
- Cross-platform features requiring coordination
- Epic-level work requiring formal requirements
- Architectural changes affecting multiple systems
- Features requiring comprehensive testing strategy

**Time estimate**: 2-4 hours

**Success criteria**:
- 100% of acceptance criteria met
- Zero defects in production first week
- Complete documentation and evidence
- Full test coverage for critical paths
- Security audit passed (if applicable)
- Cross-platform validation complete

## The 9 Phases

```
Phase 1: Research              → Deep exploration, feasibility analysis
Phase 2: Story Creation        → Formal requirements, acceptance criteria
Phase 3: Planning              → Technical design, architecture
Phase 4: Adversarial Review    → Security audit, edge case analysis
Phase 5: Implementation        → Parallel coding, incremental builds
Phase 6: Testing               → Comprehensive validation, all platforms
Phase 7: Validation            → Acceptance criteria verification
Phase 8: Clean-up              → Documentation, artifacts, debt log
Phase 9: Deployment            → Full quality gates, staged rollout
```

---

## Phase 1: Research

**Goal**: Deep understanding of requirements, feasibility, and technical landscape.

**Time allocation**: 20-30 minutes

### Steps:

1. **Define the problem space**
   - What problem are we solving?
   - Who are the users?
   - What are the business requirements?
   - What are the technical constraints?

2. **Explore current implementation**
   ```bash
   # Find all related code
   grep -r "related_feature" src/

   # Find similar patterns
   find src/ -name "*similar*"

   # Check git history for similar features
   git log --grep="similar feature" --oneline
   ```

3. **Research dependencies and integrations**
   - What external services/APIs are involved?
   - What internal modules will be affected?
   - What platform-specific considerations exist?
   - What are the data flow implications?

4. **Identify risks and constraints**
   - Technical risks (performance, compatibility, security)
   - Timeline constraints
   - Resource constraints
   - Platform limitations

5. **Evaluate alternatives**
   - What are different approaches to solve this?
   - What are the trade-offs?
   - What's the recommended approach?

### Research Checklist:

**Problem Understanding:**
- [ ] Clear problem statement
- [ ] User stories identified
- [ ] Success metrics defined
- [ ] Constraints documented

**Technical Research:**
- [ ] Current implementation mapped
- [ ] Similar patterns found
- [ ] Dependencies identified
- [ ] Platform considerations noted

**Risk Analysis:**
- [ ] Technical risks listed
- [ ] Security implications assessed
- [ ] Performance implications considered
- [ ] Migration/rollback strategy outlined

**Feasibility:**
- [ ] Technically feasible
- [ ] Timeline realistic
- [ ] Resources available
- [ ] No blockers identified

### StackMap-Specific Research:

**For data/state changes:**
- Which stores affected? (`useAppStore`, `useUserStore`, `useSettingsStore`, `useLibraryStore`)
- Field naming strategy? (Activities: `text`/`icon`, Users: `name`/`icon`)
- Sync implications? (Conflict resolution, encryption, field migration)
- Data migration needed? (Existing user data compatibility)

**For UI/UX changes:**
- Platform-specific files needed? (`.native.js`, `.web.js`, `.ios.js`, `.android.js`)
- Platform gotchas? (Check CLAUDE.md: Android FlexWrap, iOS AsyncStorage, Web layouts)
- Design rules followed? (No gray text, high contrast, Typography component)
- Accessibility requirements? (Screen readers, color contrast, font sizes)

**For cross-platform features:**
- Native module integration? (iOS, Android)
- Platform-specific APIs? (Camera, location, notifications)
- Testing strategy per platform?
- Performance considerations per platform?

**For security-critical changes:**
- Authentication/authorization affected?
- Data encryption implications?
- API security requirements?
- Vulnerability assessment needed?

### Research Output Template:

```markdown
## Research Findings: [Feature Name]

### Problem Statement:
[Clear description of what we're solving]

### Users Affected:
- [User type 1]: [how they benefit]
- [User type 2]: [how they benefit]

### Technical Approach:
[High-level approach, alternatives considered]

### Files to Create/Modify:
- /path/to/new/file.js - [purpose]
- /path/to/existing/file.js - [what changes]
- /path/to/test/file.test.js - [test coverage]

### Dependencies:
- External: [external packages, APIs]
- Internal: [internal modules, services]

### Platform Considerations:
- **iOS**: [specific notes]
- **Android**: [specific notes]
- **Web**: [specific notes]

### Data/Store Impact:
- Store(s): [which stores]
- Fields: [new/modified fields]
- Migration: [data migration strategy]
- Sync: [sync implications]

### Risks:
1. [Risk 1] - Mitigation: [strategy]
2. [Risk 2] - Mitigation: [strategy]

### Success Metrics:
- [Metric 1]: [target]
- [Metric 2]: [target]

### Timeline Estimate:
- Research: [time]
- Implementation: [time]
- Testing: [time]
- Total: [time]
```

### Example Research Output:

```markdown
## Research Findings: Photo Attachments for Activities

### Problem Statement:
Users want to attach photos to their activities to provide visual context
and make activity tracking more engaging and memorable.

### Users Affected:
- All users: Can attach photos to activities
- Premium users: Can attach unlimited photos (free: max 3 per activity)

### Technical Approach:
1. Use expo-image-picker for photo selection
2. Store photos in Firebase Storage
3. Store photo URLs in activity.photos array
4. Implement thumbnail generation for performance
5. Lazy load photos in activity cards

Alternatives considered:
- Store base64 in sync data: Rejected (too large, slow sync)
- Use device storage only: Rejected (not cross-device)

### Files to Create/Modify:
- /src/services/photoService.js - Upload, delete, thumbnail generation
- /src/components/ActivityCard.js - Display thumbnail
- /src/components/PhotoAttachment.js - Photo picker UI (NEW)
- /src/components/PhotoGallery.js - Full screen photo viewer (NEW)
- /src/stores/useAppStore.js - Add photos array to activity schema
- /src/services/sync/syncService.js - Sync photo URLs (not files)
- /tests/services/photoService.test.js - Test upload/delete (NEW)

### Dependencies:
- External: expo-image-picker, firebase-storage
- Internal: useAppStore, syncService, dataNormalizer

### Platform Considerations:
- **iOS**: Requires camera/photo library permissions in Info.plist
- **Android**: Requires camera/storage permissions in AndroidManifest.xml
- **Web**: Use file input, no native picker

### Data/Store Impact:
- Store: useAppStore (activities)
- New field: activity.photos (array of { url, thumbnailUrl, timestamp })
- Migration: Add empty photos array to existing activities
- Sync: Only sync URLs, not photo files (files stored in Firebase)

### Risks:
1. Storage costs - Mitigation: Thumbnail compression, size limits
2. Photo permissions denial - Mitigation: Clear UI messaging, fallback
3. Upload failures on poor network - Mitigation: Retry logic, offline queue
4. Photo deletion not synced - Mitigation: Include deleted photo URLs in sync

### Success Metrics:
- 80%+ of active users attach at least one photo in first week
- Average upload time < 3 seconds
- Photo display time < 200ms (thumbnail)
- Zero storage-related crashes

### Timeline Estimate:
- Research: 30 min ✅
- Story Creation: 15 min
- Planning: 30 min
- Implementation: 90 min
- Testing: 45 min
- Total: 3.5 hours
```

---

## Phase 2: Story Creation

**Goal**: Create formal user stories with acceptance criteria and success metrics.

**Time allocation**: 15-20 minutes

### Steps:

1. **Write user stories**
   - Use standard format: "As a [user], I want [goal], so that [benefit]"
   - Break down complex features into multiple stories
   - Prioritize stories (must-have, should-have, nice-to-have)

2. **Define acceptance criteria**
   - Specific, measurable, testable criteria
   - Cover happy path and edge cases
   - Include performance requirements
   - Include platform-specific criteria

3. **Set success metrics**
   - How will we measure success?
   - What are the targets?
   - How will we collect data?

4. **Create testing scenarios**
   - Manual testing checklist
   - Automated test requirements
   - Cross-platform testing plan

### Story Template:

Use the template in `resources/story-template.md` for consistent formatting.

```markdown
# User Story: [Feature Name]

## Story
As a [user type]
I want [goal]
So that [benefit]

## Acceptance Criteria

### Must Have:
1. [ ] [Specific, testable criterion 1]
2. [ ] [Specific, testable criterion 2]
3. [ ] [Specific, testable criterion 3]

### Should Have:
1. [ ] [Nice-to-have criterion 1]
2. [ ] [Nice-to-have criterion 2]

### Platform-Specific:
- **iOS**: [ ] [iOS-specific requirement]
- **Android**: [ ] [Android-specific requirement]
- **Web**: [ ] [Web-specific requirement]

## Success Metrics
- [Metric 1]: [Target value]
- [Metric 2]: [Target value]

## Testing Scenarios

### Happy Path:
1. [Step 1]
2. [Step 2]
3. Expected: [Result]

### Edge Cases:
1. **Empty state**: [Expected behavior]
2. **Error state**: [Expected behavior]
3. **Offline**: [Expected behavior]

## Dependencies
- [Dependency 1]
- [Dependency 2]

## Risks
- [Risk 1]: [Mitigation]
- [Risk 2]: [Mitigation]
```

### Example Story:

```markdown
# User Story: Photo Attachments for Activities

## Story
As an active user
I want to attach photos to my activities
So that I can add visual context and make my activity log more engaging

## Acceptance Criteria

### Must Have:
1. [ ] User can select photo from device gallery
2. [ ] User can take new photo with camera
3. [ ] User can attach up to 3 photos per activity (free tier)
4. [ ] Photos display as thumbnails in activity card
5. [ ] Tapping thumbnail opens full-screen photo viewer
6. [ ] User can delete attached photos
7. [ ] Photos sync across devices (URLs only, not files)
8. [ ] Upload shows progress indicator
9. [ ] Failed uploads show error message with retry option
10. [ ] Photos compressed/thumbnailed for performance

### Should Have:
1. [ ] User can reorder photos (drag and drop)
2. [ ] Photos include timestamp/location metadata
3. [ ] Swipe gesture to navigate between photos in viewer
4. [ ] Share photo to social media

### Platform-Specific:
- **iOS**: [ ] Request camera/photo library permissions
- **iOS**: [ ] Handle permission denial gracefully
- **Android**: [ ] Request camera/storage permissions
- **Android**: [ ] Handle permission denial gracefully
- **Web**: [ ] Use file input (no native picker)
- **Web**: [ ] Support drag-and-drop photo upload

## Success Metrics
- **Adoption**: 80%+ of active users attach at least one photo in first week
- **Performance**: Average upload time < 3 seconds
- **Performance**: Photo thumbnail display < 200ms
- **Reliability**: 99%+ upload success rate
- **Quality**: Zero storage-related crashes

## Testing Scenarios

### Happy Path:
1. User taps "Add Photo" button
2. User selects photo from gallery
3. Photo uploads with progress indicator
4. Thumbnail displays in activity card
5. Tapping thumbnail opens full-screen viewer
Expected: Photo displays correctly, all interactions smooth

### Edge Cases:

**Slow network**:
- Upload shows progress
- User can cancel upload
- Retry available on failure

**Permissions denied**:
- Clear message explaining why permission needed
- Link to settings to enable permission
- Graceful fallback (no crash)

**Large photo file**:
- Automatic compression before upload
- Warning if file too large (>10MB)
- Thumbnail generated for display

**Offline mode**:
- Photo queued for upload when online
- Indicator showing "pending upload"
- Retry automatically when connection restored

**Storage full (device)**:
- Error message shown
- Prompt user to free space
- Don't crash app

**Storage quota exceeded (Firebase)**:
- Error message shown
- Prompt to upgrade or delete old photos
- Graceful degradation

## Dependencies
- expo-image-picker (photo selection)
- firebase-storage (cloud storage)
- react-native-fast-image (thumbnail caching)

## Risks
- **Storage costs**: Mitigate with compression, size limits, cleanup policy
- **Permission denial**: Mitigate with clear messaging, graceful fallback
- **Upload failures**: Mitigate with retry logic, offline queue
- **Performance on old devices**: Mitigate with lazy loading, thumbnail optimization
```

### Story Validation Checklist:

- [ ] User story follows "As a...I want...So that" format
- [ ] Acceptance criteria are specific and testable
- [ ] Edge cases covered
- [ ] Platform-specific requirements included
- [ ] Success metrics defined with targets
- [ ] Testing scenarios documented
- [ ] Dependencies identified
- [ ] Risks documented with mitigation

---

## Phase 3: Planning

**Goal**: Create detailed technical design and implementation plan.

**Time allocation**: 20-30 minutes

### Steps:

1. **Architecture design**
   - How will components interact?
   - What's the data flow?
   - Where does state live?
   - How does it integrate with existing systems?

2. **File-by-file implementation plan**
   - What files to create?
   - What files to modify?
   - What changes in each file?
   - What order to implement?

3. **Data schema design**
   - What new fields/structures?
   - How to migrate existing data?
   - How does sync handle it?
   - What validations needed?

4. **Testing strategy**
   - Unit tests for each module
   - Integration tests for workflows
   - Platform-specific tests
   - Performance tests

5. **Rollout strategy**
   - Phased rollout plan (QUAL → STAGE → BETA → PROD)
   - Feature flags needed?
   - Rollback plan
   - Monitoring strategy

### Planning Template:

```markdown
## Implementation Plan: [Feature Name]

### Architecture

#### Component Structure:
```
[Draw component hierarchy or describe]
```

#### Data Flow:
```
User Action → Component → Service → Store → UI Update
[Detailed flow diagram or description]
```

#### State Management:
- **Store**: [which store(s)]
- **State shape**: [schema]
- **Update methods**: [new methods needed]

### File-by-File Plan

#### New Files:
1. **/src/services/newService.js**
   - Purpose: [what it does]
   - Functions:
     - `function1()`: [description]
     - `function2()`: [description]
   - Dependencies: [what it imports]

2. **/src/components/NewComponent.js**
   - Purpose: [what it does]
   - Props: [prop schema]
   - State: [local state]
   - Platform: [shared/native/web]

#### Modified Files:
1. **/src/stores/useAppStore.js**
   - Add: [new state fields]
   - Modify: [existing functions]
   - Migration: [how to handle existing data]

2. **/src/components/ExistingComponent.js**
   - Add: [new feature integration]
   - Modify: [existing behavior]

#### Test Files:
1. **/tests/services/newService.test.js**
   - Test coverage:
     - [ ] Unit tests for all functions
     - [ ] Edge cases
     - [ ] Error handling

### Data Schema

#### New Fields:
```javascript
activity: {
  // ... existing fields
  newField: {
    type: [type],
    required: [boolean],
    default: [default value],
    validation: [validation rules]
  }
}
```

#### Migration Strategy:
```javascript
// How to handle existing data
const migrateOldData = (activity) => {
  return {
    ...activity,
    newField: activity.legacyField || defaultValue
  }
}
```

### Testing Strategy

#### Unit Tests:
- [ ] `newService.function1()` - happy path
- [ ] `newService.function1()` - error cases
- [ ] `newService.function2()` - edge cases

#### Integration Tests:
- [ ] Full workflow: [user action → result]
- [ ] Error recovery
- [ ] Offline/online transitions

#### Platform Tests:
- [ ] iOS: [specific tests]
- [ ] Android: [specific tests]
- [ ] Web: [specific tests]

#### Performance Tests:
- [ ] Load time < [threshold]
- [ ] Memory usage < [threshold]
- [ ] No memory leaks

### Implementation Order

**Iteration 1: Core functionality**
1. Create newService.js with basic functions
2. Add tests for newService
3. Add state to store
4. Test store integration

**Iteration 2: UI integration**
1. Create NewComponent
2. Integrate with existing UI
3. Add platform-specific variations
4. Test on all platforms

**Iteration 3: Edge cases**
1. Add error handling
2. Add offline support
3. Add loading states
4. Test all edge cases

**Iteration 4: Polish**
1. Performance optimization
2. Accessibility improvements
3. Documentation
4. Final testing

### Rollout Strategy

**QUAL** (development testing):
- Deploy with feature flag (enabled for testing)
- Test all platforms
- Validate performance
- Fix any issues

**STAGE** (internal validation):
- Deploy to stage environment
- Internal team testing
- Gather feedback
- Refine based on feedback

**BETA** (closed beta):
- Deploy to beta users (feature flag 50%)
- Monitor usage metrics
- Monitor error rates
- Collect user feedback

**PROD** (full release):
- Gradual rollout: 10% → 50% → 100%
- Monitor success metrics
- Monitor error rates
- Rollback plan ready

### Rollback Plan

If critical issues arise:
1. Disable feature flag (immediate)
2. Or: Revert to previous deployment (< 15 minutes)
3. Notify users if data affected
4. Fix issues in QUAL/STAGE
5. Re-test before re-enabling

### Monitoring

**Metrics to track**:
- Success rate (uploads, actions)
- Error rate
- Performance (load time, memory)
- User adoption
- User engagement

**Alerts**:
- Error rate > 5%
- Performance degradation > 20%
- Crash rate increase

### StackMap-Specific Planning

**Field Naming**:
- Writing: Use `text`, `icon` (canonical)
- Reading: Use `text || name || title`, `icon || emoji` (with fallbacks)
- Add to dataNormalizer.js if migration needed

**Store Updates**:
- Identify which store: [useUserStore, useSettingsStore, etc.]
- Use store-specific methods: `useUserStore.getState().setUsers()`
- Never use `useAppStore.setState()` directly

**Platform Considerations**:
- **Android**: FlexWrap cards use 48% widths
- **iOS**: AsyncStorage debounced, NetInfo disabled
- **Web**: 3-column layout uses 31%/48%/100% widths
- Use Typography component (not direct fontWeight)

**Sync Strategy**:
- What data needs to sync?
- Conflict resolution strategy
- Encryption needed?
- Field migration for existing synced data

**Design Rules**:
- No gray text (use #000 only)
- High contrast required
- Typography component for fonts
- Accessibility: screen reader support, touch targets
```

### Example Plan:

*(See resources/plan-example.md for full example)*

### Planning Validation Checklist:

- [ ] Architecture clearly defined
- [ ] File-by-file plan complete
- [ ] Implementation order logical
- [ ] Testing strategy comprehensive
- [ ] Rollout strategy defined
- [ ] Rollback plan ready
- [ ] Monitoring plan in place
- [ ] StackMap conventions addressed
- [ ] Platform-specific considerations documented
- [ ] Data migration strategy clear

---

## Phase 4: Adversarial Review

**Goal**: Security audit, edge case analysis, and critical evaluation.

**Time allocation**: 15-20 minutes

### Steps:

1. **Security audit**
   - Use checklist in `resources/adversarial-checklist.md`
   - Identify vulnerabilities
   - Assess attack vectors
   - Validate data encryption
   - Check authentication/authorization

2. **Edge case analysis**
   - What can go wrong?
   - What assumptions might break?
   - What happens under load?
   - What if external dependencies fail?

3. **Performance analysis**
   - Memory usage implications
   - Network bandwidth usage
   - Battery impact (mobile)
   - Startup time impact

4. **Cross-platform compatibility**
   - iOS-specific issues?
   - Android-specific issues?
   - Web-specific issues?
   - Version compatibility?

5. **Maintainability review**
   - Code complexity reasonable?
   - Test coverage sufficient?
   - Documentation clear?
   - Technical debt acceptable?

### Adversarial Review Checklist:

Use the comprehensive checklist in `resources/adversarial-checklist.md`.

**Security** (if applicable):
- [ ] User data encrypted at rest
- [ ] User data encrypted in transit
- [ ] Authentication required where needed
- [ ] Authorization checked for all actions
- [ ] Input validation/sanitization
- [ ] No secrets in code
- [ ] API keys secured
- [ ] No XSS vulnerabilities
- [ ] No SQL injection vulnerabilities

**Edge Cases**:
- [ ] Empty states handled
- [ ] Null/undefined handled
- [ ] Network failures handled
- [ ] Offline mode supported
- [ ] Race conditions prevented
- [ ] Concurrent access handled
- [ ] Large datasets handled
- [ ] Old app versions compatible

**Performance**:
- [ ] Load time acceptable (< 3s)
- [ ] Memory usage reasonable
- [ ] No memory leaks
- [ ] Network bandwidth optimized
- [ ] Battery impact minimal (mobile)
- [ ] Startup time not impacted
- [ ] 60fps maintained (animations)

**Cross-Platform**:
- [ ] iOS testing complete
- [ ] Android testing complete
- [ ] Web testing complete
- [ ] Platform-specific gotchas addressed
- [ ] No platform-specific APIs in shared code
- [ ] Consistent UX across platforms

**Maintainability**:
- [ ] Code complexity reasonable (no 500-line functions)
- [ ] Adequate comments for complex logic
- [ ] Test coverage > 80% for critical paths
- [ ] Documentation complete
- [ ] No copy-paste duplication
- [ ] Follows project patterns

**StackMap-Specific**:
- [ ] Store-specific update methods used
- [ ] Field naming conventions followed
- [ ] Fallbacks included for legacy fields
- [ ] Typography component used (not direct fontWeight)
- [ ] No gray text (only #000)
- [ ] Platform gotchas addressed (CLAUDE.md)

### Adversarial Questions:

Ask yourself tough questions:

1. **"What's the worst that could happen?"**
   - User loses data?
   - App crashes?
   - Security breach?
   - How do we prevent it?

2. **"What if this becomes popular?"**
   - Can it scale?
   - Storage costs?
   - Performance under load?

3. **"What if external service fails?"**
   - Firebase down?
   - Network offline?
   - API timeout?
   - Graceful degradation?

4. **"What if user does unexpected thing?"**
   - Spams button?
   - Enters invalid data?
   - Uses old app version?
   - Switches platforms?

5. **"What will break in 6 months?"**
   - Technical debt?
   - Deprecated APIs?
   - Maintenance burden?
   - Future compatibility?

### Red Flags:

**Stop and reconsider if:**
- 🚩 Security concerns unaddressed
- 🚩 Performance implications unclear
- 🚩 Rollback plan not feasible
- 🚩 Testing strategy inadequate
- 🚩 Technical debt too high
- 🚩 Cross-platform issues unresolved
- 🚩 Edge cases not handled

### Adversarial Review Output:

```markdown
## Adversarial Review: [Feature Name]

### Security Assessment: ✅ PASS / ⚠️ CONCERNS / ❌ FAIL
[Details of security review]

**Concerns found**:
1. [Concern 1] - Mitigation: [plan]
2. [Concern 2] - Mitigation: [plan]

### Edge Case Analysis: ✅ COVERED / ⚠️ PARTIAL / ❌ GAPS
[Details of edge case analysis]

**Edge cases to address**:
1. [Case 1] - Plan: [how to handle]
2. [Case 2] - Plan: [how to handle]

### Performance Assessment: ✅ GOOD / ⚠️ ACCEPTABLE / ❌ CONCERNING
[Details of performance analysis]

**Optimizations needed**:
1. [Optimization 1]
2. [Optimization 2]

### Cross-Platform Compatibility: ✅ READY / ⚠️ NEEDS WORK / ❌ BLOCKED
[Details of cross-platform review]

**Platform issues to address**:
- iOS: [issues]
- Android: [issues]
- Web: [issues]

### Maintainability: ✅ GOOD / ⚠️ ACCEPTABLE / ❌ HIGH DEBT
[Details of maintainability review]

**Debt to address**:
1. [Debt item 1]
2. [Debt item 2]

### Overall Verdict: ✅ PROCEED / ⚠️ PROCEED WITH CAUTION / ❌ REVISE PLAN

**Blocking issues** (must fix before proceeding):
1. [Issue 1]
2. [Issue 2]

**Non-blocking issues** (address during implementation):
1. [Issue 1]
2. [Issue 2]
```

### Example Review Output:

```markdown
## Adversarial Review: Photo Attachments

### Security Assessment: ✅ PASS

**Reviewed**:
- Photos stored in Firebase Storage (secure, access-controlled)
- Photo URLs in sync data (encrypted with NaCl)
- No direct file access from unauthorized users
- Permissions properly requested on mobile

**Concerns found**: None blocking

### Edge Case Analysis: ⚠️ PARTIAL

**Edge cases covered**:
- Offline upload queue ✅
- Permission denial handling ✅
- Large file compression ✅
- Upload failure retry ✅

**Edge cases to address**:
1. User deletes photo while uploading - Plan: Cancel upload, remove from queue
2. Firebase storage quota exceeded - Plan: Show error, prompt upgrade or cleanup
3. Photo corruption during upload - Plan: Validate file before upload, retry on corruption

### Performance Assessment: ⚠️ ACCEPTABLE

**Measurements**:
- Upload time: ~2.5s for 5MB photo ✅
- Thumbnail display: ~150ms ✅
- Memory usage: +15MB per photo in gallery (concern for many photos)

**Optimizations needed**:
1. Implement photo lazy loading (only load visible photos)
2. Add memory cache with size limit (max 10 photos in memory)
3. Thumbnail pre-caching on scroll

### Cross-Platform Compatibility: ✅ READY

**Platform testing**:
- iOS: Permissions, photo picker work ✅
- Android: Permissions, photo picker work ✅
- Web: File input works ✅

**Platform-specific considerations addressed**:
- iOS Info.plist permissions ✅
- Android manifest permissions ✅
- Web drag-and-drop ✅

### Maintainability: ✅ GOOD

**Code quality**:
- photoService.js well-structured (~200 lines)
- Clear separation of concerns
- Adequate comments
- Test coverage planned at 85%

**Technical debt**: Minimal, acceptable

### Overall Verdict: ⚠️ PROCEED WITH CAUTION

**Blocking issues**: None

**Non-blocking issues** (address during implementation):
1. Memory optimization for photo gallery (lazy loading)
2. Handle storage quota exceeded gracefully
3. Handle photo deletion during upload

**Recommendation**: Proceed to implementation. Address non-blocking issues in Phase 5.
```

---

## Phase 5: Implementation

**Goal**: Build the feature incrementally with parallel work where possible.

**Time allocation**: 60-90 minutes

### Steps:

1. **Set up implementation tracking**
   - Break plan into tasks
   - Identify parallel vs sequential tasks
   - Track progress

2. **Implement in iterations**
   - **Iteration 1**: Core functionality (basic feature works)
   - **Iteration 2**: UI integration (feature accessible to users)
   - **Iteration 3**: Edge cases (all scenarios handled)
   - **Iteration 4**: Polish (performance, UX refinements)

3. **Follow coding standards**
   - StackMap conventions (store methods, field naming, Typography)
   - Code comments for complex logic
   - No debugging logs or wrap in `__DEV__`
   - Consistent formatting

4. **Incremental validation**
   - Test after each iteration
   - Fix issues before moving to next iteration
   - Run type checking periodically

### Implementation Strategy:

**Parallel Work** (can be done simultaneously):
- Service layer implementation
- Component development
- Test writing
- Documentation updates

**Sequential Work** (must be done in order):
1. Core service functions
2. Store integration
3. Component integration
4. Platform-specific implementations
5. Final polish

### Implementation Checklist:

**Before starting:**
- [ ] Plan reviewed and approved
- [ ] Adversarial review passed
- [ ] Development environment ready
- [ ] All dependencies installed

**During implementation:**
- [ ] Follow file-by-file plan from Phase 3
- [ ] Write tests alongside code
- [ ] Use store-specific methods (not `setState`)
- [ ] Use canonical field names (`text`, `icon`)
- [ ] Include fallbacks for legacy fields
- [ ] Use Typography component (not direct fontWeight)
- [ ] Remove debug logs or wrap in `__DEV__`
- [ ] Add comments for non-obvious logic
- [ ] Run `npm run typecheck` periodically

**After each iteration:**
- [ ] Iteration functionality works
- [ ] Tests pass for iteration
- [ ] Type checking passes
- [ ] Code reviewed by self
- [ ] Ready for next iteration

### Iteration Breakdown:

**Iteration 1: Core Functionality (20-30 min)**
Goal: Basic feature works in isolation

- Implement service layer
- Add store state and methods
- Write unit tests
- Verify core logic works

**Iteration 2: UI Integration (20-30 min)**
Goal: Feature accessible to users

- Create/modify UI components
- Integrate with store
- Add loading/error states
- Test user interactions

**Iteration 3: Edge Cases (15-20 min)**
Goal: All scenarios handled gracefully

- Implement error handling
- Add offline support
- Handle empty/null states
- Add retry logic
- Test all edge cases

**Iteration 4: Polish (10-15 min)**
Goal: Performance, UX, accessibility

- Performance optimizations
- Accessibility improvements
- Animation refinements
- Final testing
- Code cleanup

### StackMap Implementation Rules:

**Store Updates (CRITICAL)**:
```javascript
// ❌ WRONG: Direct setState
useAppStore.setState({ users: newUsers })

// ✅ CORRECT: Store-specific method
useUserStore.getState().setUsers(newUsers)

// ✅ CORRECT: Store-specific method for settings
useSettingsStore.getState().updateSettings({ theme: 'dark' })

// ✅ CORRECT: Store-specific method for library
useLibraryStore.getState().setLibrary(newLibrary)
```

**Field Naming (CRITICAL)**:
```javascript
// ❌ WRONG: Legacy field names
activity.name = "Running"
activity.emoji = "🏃"

// ✅ CORRECT: Canonical field names
activity.text = "Running"
activity.icon = "🏃"

// ✅ CORRECT: Reading with fallbacks
const text = activity.text || activity.name || activity.title
const icon = activity.icon || activity.emoji
```

**Typography (Platform Compatibility)**:
```javascript
// ❌ WRONG: Direct fontWeight on Android
<Text style={{ fontWeight: 'bold' }}>Hello</Text>

// ✅ CORRECT: Use Typography component
<Typography fontWeight="bold">Hello</Typography>
```

**Design Rules**:
```javascript
// ❌ WRONG: Gray text (accessibility)
<Text style={{ color: '#666666' }}>Text</Text>

// ✅ CORRECT: Black text
<Text style={{ color: '#000000' }}>Text</Text>
```

**Platform-Specific Files**:
```bash
# Shared code (iOS + Android + Web)
Component.js

# Mobile only (iOS + Android)
Component.native.js

# Web only
Component.web.js

# iOS only (rare)
Component.ios.js

# Android only (rare)
Component.android.js
```

### Code Quality Standards:

**Function length**: < 50 lines (split if longer)
**File length**: < 500 lines (split into modules if longer)
**Cyclomatic complexity**: < 10 (refactor if higher)
**Comments**: For non-obvious logic, not obvious code
**Variable names**: Descriptive, not abbreviated (unless common: `id`, `url`)
**No magic numbers**: Use named constants

### Example Implementation Progress:

```markdown
## Implementation Progress: Photo Attachments

### Iteration 1: Core Functionality ✅ COMPLETE (25 min)
- ✅ Created /src/services/photoService.js
  - uploadPhoto(uri, activityId)
  - deletePhoto(url, activityId)
  - generateThumbnail(uri)
- ✅ Added tests to /tests/services/photoService.test.js
- ✅ Added activity.photos to store schema
- ✅ Type checking passes

### Iteration 2: UI Integration ⏳ IN PROGRESS (15/30 min)
- ✅ Created /src/components/PhotoAttachment.js
- ✅ Created /src/components/PhotoGallery.js
- ✅ Updated /src/components/ActivityCard.js to show thumbnails
- 🔄 Integrating with ActivityEditModal
- ⏳ Adding loading/error states

### Iteration 3: Edge Cases ⏳ PENDING
- Handle upload cancellation
- Handle storage quota exceeded
- Offline queue implementation
- Permission denial flow

### Iteration 4: Polish ⏳ PENDING
- Memory optimization (lazy loading)
- Thumbnail pre-caching
- Animation polish
- Accessibility improvements

### Issues Found:
1. ⚠️ Upload progress not showing - Fixed: Added progress callback
2. ⚠️ Large photos cause memory spike - TODO: Implement compression earlier
```

### Validation During Implementation:

Run these commands periodically:

```bash
# Type checking (fast, run often)
npm run typecheck

# Linting (fast)
npm run lint

# Tests (slower, run after each iteration)
npm test

# Build (slowest, run before committing)
npm run build:web  # Web build
# iOS/Android builds tested in Phase 6
```

---

## Phase 6: Testing

**Goal**: Comprehensive validation across all platforms and scenarios.

**Time allocation**: 30-45 minutes

### Steps:

1. **Automated testing**
   ```bash
   # Unit tests
   npm test

   # Type checking
   npm run typecheck

   # Linting
   npm run lint

   # Build validation
   npm run build:web
   ```

2. **Manual testing - Happy path**
   - Test primary user flow on each platform
   - Verify all acceptance criteria met
   - Check performance (load times, animations)

3. **Manual testing - Edge cases**
   - Test all edge cases from Phase 2
   - Test error scenarios
   - Test offline behavior
   - Test with poor network

4. **Cross-platform testing**
   - iOS (simulator + real device)
   - Android (emulator + real device)
   - Web (desktop + mobile browsers)
   - Test platform-specific features

5. **Regression testing**
   - Verify existing features still work
   - Check for unintended side effects
   - Test related features

### Testing Checklist:

**Automated Tests**:
- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Type checking passes
- [ ] Linting passes (or only warnings)
- [ ] Build succeeds (web, iOS, Android)
- [ ] Test coverage > 80% for new code

**Manual Testing - Happy Path**:
- [ ] Primary user flow works on iOS
- [ ] Primary user flow works on Android
- [ ] Primary user flow works on Web
- [ ] All acceptance criteria met
- [ ] Performance acceptable (< 3s load, 60fps)
- [ ] No console errors

**Manual Testing - Edge Cases**:
- [ ] Empty states display correctly
- [ ] Error messages clear and helpful
- [ ] Loading states show appropriately
- [ ] Offline mode works
- [ ] Poor network handled gracefully
- [ ] Large data sets handled
- [ ] Rapid user actions handled (no crashes)

**Platform-Specific Testing**:
- [ ] iOS: Permissions work
- [ ] iOS: Native features work (camera, etc.)
- [ ] iOS: UI matches iOS patterns
- [ ] Android: Permissions work
- [ ] Android: Native features work
- [ ] Android: UI matches Material Design
- [ ] Web: Responsive design works
- [ ] Web: Desktop browser tested
- [ ] Web: Mobile browser tested

**Regression Testing**:
- [ ] Existing features unaffected
- [ ] No performance degradation
- [ ] No new console errors
- [ ] Sync still works
- [ ] Navigation still works
- [ ] Data integrity maintained

**StackMap-Specific Testing**:
- [ ] Store updates work correctly
- [ ] Field naming correct (text/icon)
- [ ] Typography renders correctly (all platforms)
- [ ] No gray text (only #000)
- [ ] Sync works with new data structure
- [ ] Migration works for existing data

### Testing Scenarios:

Use scenarios from Phase 2 story. Example:

```markdown
### Test Scenario 1: Upload Photo (Happy Path)

**Steps**:
1. Open activity in edit mode
2. Tap "Add Photo" button
3. Select photo from gallery
4. Wait for upload

**Expected**:
- Photo picker opens ✅
- Progress indicator shows ✅
- Thumbnail displays after upload ✅
- Activity updates immediately ✅

**Platforms Tested**:
- iOS Simulator ✅
- Android Emulator ✅
- Web Desktop ✅

**Result**: ✅ PASS

---

### Test Scenario 2: Upload Photo (Offline)

**Steps**:
1. Turn on airplane mode
2. Open activity in edit mode
3. Tap "Add Photo" button
4. Select photo from gallery
5. Turn off airplane mode

**Expected**:
- Photo queued for upload ⚠️
- "Pending upload" indicator shows ⚠️
- Auto-uploads when online ❌ (Not working)
- Notification on success ⏳ (Not tested)

**Platforms Tested**:
- iOS Simulator ⚠️

**Result**: ❌ FAIL - Offline queue not working

**Fix**: Implemented offline queue in photoService.js, retested ✅ PASS
```

### Performance Testing:

**Metrics to measure**:
- Load time (initial + subsequent)
- Memory usage (baseline + after feature use)
- Network usage (bandwidth, request count)
- Battery drain (mobile only)
- Animation frame rate (should be 60fps)
- App startup time (shouldn't increase)

**Tools**:
- React DevTools (component render times)
- Chrome DevTools (network, performance)
- Xcode Instruments (iOS performance)
- Android Profiler (Android performance)

**Acceptable thresholds** (StackMap-specific):
- Page load: < 3 seconds
- API response: < 1 second
- Animation: 60fps (no drops below 50fps)
- Memory: < 200MB total app usage
- Startup: < 5 seconds (cold start)

### Testing Output:

```markdown
## Testing Report: Photo Attachments

### Automated Tests: ✅ PASS
- Unit tests: 42/42 passed
- Integration tests: 8/8 passed
- Type checking: Pass
- Linting: Pass (3 warnings, non-blocking)
- Build: Success (web, iOS, Android)
- Coverage: 87% (target: 80%)

### Manual Testing - Happy Path: ✅ PASS
All acceptance criteria met across all platforms.

**iOS**: ✅ All features work
**Android**: ✅ All features work
**Web**: ✅ All features work

### Manual Testing - Edge Cases: ⚠️ PARTIAL PASS

**Passed** (8/10):
- Empty states ✅
- Error messages ✅
- Loading states ✅
- Poor network ✅
- Large files ✅
- Rapid actions ✅
- Permissions denied ✅
- Old data migration ✅

**Failed** (2/10):
- Offline upload queue ❌ → Fixed, retested ✅
- Storage quota exceeded ❌ → Fixed, retested ✅

### Platform-Specific Testing: ✅ PASS
- iOS: Permissions, camera, UI ✅
- Android: Permissions, camera, UI ✅
- Web: Responsive, desktop, mobile ✅

### Regression Testing: ✅ PASS
- All existing features work ✅
- No performance degradation ✅
- Sync works correctly ✅
- No new errors ✅

### Performance Testing: ✅ PASS
- Upload time: 2.3s avg (target: < 3s) ✅
- Thumbnail display: 140ms avg (target: < 200ms) ✅
- Memory usage: +12MB (acceptable) ✅
- No memory leaks ✅
- 60fps maintained ✅

### Issues Found & Fixed:
1. ❌ Offline queue not working → Fixed in photoService.js
2. ❌ Storage quota not handled → Added error handling
3. ⚠️ Memory spike with many photos → Added lazy loading

### Overall: ✅ READY FOR VALIDATION

All critical issues resolved. Ready for Phase 7 validation.
```

---

## Phase 7: Validation

**Goal**: Verify all acceptance criteria met and feature ready for deployment.

**Time allocation**: 15-20 minutes

### Steps:

1. **Acceptance criteria review**
   - Go through story from Phase 2
   - Check each criterion systematically
   - Provide evidence for each

2. **Success metrics validation**
   - Can we measure the metrics?
   - Are targets realistic?
   - Is tracking implemented?

3. **Documentation review**
   - User-facing documentation complete?
   - Developer documentation complete?
   - API documentation (if applicable)?

4. **Stakeholder review** (if applicable)
   - Demo the feature
   - Gather feedback
   - Address concerns

### Validation Checklist:

**Acceptance Criteria**:
- [ ] All "Must Have" criteria met (100%)
- [ ] Evidence provided for each criterion
- [ ] All "Should Have" criteria met (or deferred)
- [ ] All platform-specific criteria met

**Success Metrics**:
- [ ] Metrics measurable
- [ ] Tracking implemented
- [ ] Targets realistic
- [ ] Baseline established (if applicable)

**Documentation**:
- [ ] User guide updated (if user-facing)
- [ ] Developer docs updated (if API changes)
- [ ] CLAUDE.md updated (if conventions change)
- [ ] README updated (if workflow changes)

**Quality Gates**:
- [ ] All tests pass
- [ ] Type checking passes
- [ ] Build succeeds
- [ ] No critical bugs
- [ ] Performance acceptable
- [ ] Security review passed (if applicable)

**Stakeholder Approval** (if applicable):
- [ ] Feature demoed
- [ ] Feedback gathered
- [ ] Concerns addressed
- [ ] Sign-off received

### Validation Output:

```markdown
## Validation Report: Photo Attachments

### Acceptance Criteria Validation

#### Must Have (10/10) ✅ 100%

1. ✅ User can select photo from gallery
   - Evidence: Tested on iOS, Android, Web
   - Screenshot: [link to screenshot]

2. ✅ User can take new photo with camera
   - Evidence: Tested on iOS, Android (Web: not applicable)
   - Screenshot: [link]

3. ✅ Up to 3 photos per activity (free tier)
   - Evidence: Tested, 4th photo shows upgrade prompt
   - Screenshot: [link]

4. ✅ Thumbnails in activity card
   - Evidence: Thumbnails display, tap opens viewer
   - Screenshot: [link]

5. ✅ Full-screen photo viewer
   - Evidence: Swipe navigation works
   - Screenshot: [link]

6. ✅ Delete photos
   - Evidence: Delete confirmation, photo removed
   - Screenshot: [link]

7. ✅ Photos sync across devices
   - Evidence: Tested iOS → Android sync
   - Screenshot: [link]

8. ✅ Upload progress indicator
   - Evidence: Progress bar shows 0-100%
   - Screenshot: [link]

9. ✅ Failed upload error + retry
   - Evidence: Error message, retry button works
   - Screenshot: [link]

10. ✅ Photos compressed/thumbnailed
    - Evidence: 5MB photo → 500KB upload, 50KB thumbnail
    - Screenshot: [link]

#### Should Have (2/4) ⚠️ 50% (deferred)

1. ❌ Reorder photos (drag & drop) - DEFERRED to v2
2. ❌ Timestamp/location metadata - DEFERRED to v2
3. ✅ Swipe navigation in viewer - IMPLEMENTED
4. ✅ Share to social media - IMPLEMENTED

**Deferred items**: Added to backlog as separate stories

#### Platform-Specific (6/6) ✅ 100%

- iOS: ✅ Camera/photo permissions
- iOS: ✅ Permission denial handled
- Android: ✅ Camera/storage permissions
- Android: ✅ Permission denial handled
- Web: ✅ File input works
- Web: ✅ Drag-and-drop works

### Success Metrics Validation ✅

**Metrics implemented**:
- ✅ Photo upload tracking (Firebase Analytics)
- ✅ Usage analytics (photos per user)
- ✅ Performance monitoring (upload time)
- ✅ Error tracking (upload failures)

**Targets**:
- Adoption: 80%+ attach photo in week 1 (trackable ✅)
- Performance: Upload < 3s (measured: 2.3s avg ✅)
- Display: Thumbnail < 200ms (measured: 140ms avg ✅)
- Reliability: 99%+ success rate (trackable ✅)
- Quality: Zero storage crashes (monitored ✅)

### Documentation Review ✅

**Updated**:
- ✅ User guide: Added "Attaching Photos" section
- ✅ Developer docs: Documented photoService API
- ✅ CLAUDE.md: Added photo attachment patterns
- ✅ README: No changes needed

### Quality Gates ✅

- ✅ All tests pass (50/50)
- ✅ Type checking passes
- ✅ Build succeeds (web, iOS, Android)
- ✅ No critical bugs
- ✅ Performance meets targets
- ✅ Security review passed

### Stakeholder Review ✅

**Demo given to**: Product team, beta users (3)

**Feedback**:
- 👍 "Love the thumbnail display"
- 👍 "Upload is fast"
- 💡 Suggestion: Add photo captions (backlog item created)
- 💡 Suggestion: Support video (future consideration)

**Sign-off**: ✅ Approved for QUAL deployment

### Overall: ✅ READY FOR DEPLOYMENT

All acceptance criteria met. Success metrics implemented. Documentation complete.
Stakeholder approved. Ready for Phase 8 (Clean-up) and Phase 9 (Deployment).
```

### Validation Meeting (if applicable):

**Agenda**:
1. Demo feature (5-10 min)
2. Review acceptance criteria (5 min)
3. Discuss success metrics (3 min)
4. Gather feedback (5 min)
5. Address concerns (5 min)
6. Get sign-off (2 min)

**Attendees**:
- Product owner
- Tech lead
- QA (if applicable)
- Designer (if UI changes)
- Stakeholders (if needed)

---

## Phase 8: Clean-up

**Goal**: Documentation, artifacts, technical debt log, code cleanup.

**Time allocation**: 15-20 minutes

### Steps:

1. **Code cleanup**
   - Remove all debug logs
   - Remove commented-out code
   - Remove unused imports
   - Fix linting warnings
   - Format code consistently

2. **Documentation updates**
   - Update code comments
   - Update README (if applicable)
   - Update CLAUDE.md (if conventions change)
   - Update API docs (if APIs added)

3. **Technical debt log**
   - Document any shortcuts taken
   - Document future improvements
   - Document known limitations
   - Document maintenance tasks

4. **Create artifacts**
   - Screenshots for documentation
   - Architecture diagrams (if complex)
   - Performance benchmarks
   - Migration guides (if needed)

5. **Knowledge transfer**
   - Team documentation
   - Handoff notes (if needed)
   - Troubleshooting guide

### Clean-up Checklist:

**Code Cleanup**:
- [ ] All console.log removed (or wrapped in `__DEV__`)
- [ ] All commented code removed
- [ ] All unused imports removed
- [ ] All TODOs addressed or logged
- [ ] Linting warnings fixed (or justified)
- [ ] Code formatted consistently

**Documentation**:
- [ ] Code comments updated
- [ ] README updated (if applicable)
- [ ] CLAUDE.md updated (if conventions added)
- [ ] API docs updated (if APIs changed)
- [ ] User guide updated (if user-facing)
- [ ] Developer guide updated (if architecture changed)

**Technical Debt Log**:
- [ ] Shortcuts documented
- [ ] Future improvements listed
- [ ] Known limitations documented
- [ ] Maintenance tasks identified
- [ ] Refactoring opportunities noted

**Artifacts**:
- [ ] Screenshots captured
- [ ] Diagrams created (if needed)
- [ ] Performance benchmarks documented
- [ ] Migration guides written (if needed)

**Knowledge Transfer**:
- [ ] Team documentation complete
- [ ] Handoff notes written (if needed)
- [ ] Troubleshooting guide created
- [ ] Common issues documented

### Technical Debt Template:

```markdown
## Technical Debt: [Feature Name]

### Shortcuts Taken:
1. **[Shortcut 1]**
   - Why: [reason]
   - Impact: [low/medium/high]
   - Recommended fix: [description]
   - Estimated effort: [time]

2. **[Shortcut 2]**
   - Why: [reason]
   - Impact: [low/medium/high]
   - Recommended fix: [description]
   - Estimated effort: [time]

### Future Improvements:
1. **[Improvement 1]**
   - Benefit: [description]
   - Effort: [time]
   - Priority: [low/medium/high]

2. **[Improvement 2]**
   - Benefit: [description]
   - Effort: [time]
   - Priority: [low/medium/high]

### Known Limitations:
1. **[Limitation 1]**
   - Description: [details]
   - Workaround: [if any]
   - Fix planned: [yes/no]

2. **[Limitation 2]**
   - Description: [details]
   - Workaround: [if any]
   - Fix planned: [yes/no]

### Maintenance Tasks:
1. **[Task 1]**
   - Frequency: [daily/weekly/monthly]
   - Procedure: [description]

2. **[Task 2]**
   - Frequency: [daily/weekly/monthly]
   - Procedure: [description]

### Refactoring Opportunities:
1. **[Opportunity 1]**
   - Current: [current state]
   - Proposed: [better approach]
   - Benefit: [why refactor]
   - Effort: [time]
```

### Example Technical Debt Log:

```markdown
## Technical Debt: Photo Attachments

### Shortcuts Taken:

1. **Lazy loading not fully optimized**
   - Why: Time constraint, works acceptably
   - Impact: Medium (memory usage could be better)
   - Recommended fix: Implement virtualized list for photo gallery
   - Estimated effort: 4 hours

2. **No video support**
   - Why: Out of scope for v1
   - Impact: Low (future feature request)
   - Recommended fix: Extend photoService to support video
   - Estimated effort: 8 hours

### Future Improvements:

1. **Photo captions**
   - Benefit: Users can add context to photos
   - Effort: 2 hours
   - Priority: Medium

2. **Photo editing (crop, rotate)**
   - Benefit: Users can edit before upload
   - Effort: 8 hours
   - Priority: Low

3. **Cloud storage cost optimization**
   - Benefit: Reduce Firebase Storage costs
   - Effort: 4 hours (implement cleanup policy)
   - Priority: High (if costs exceed budget)

### Known Limitations:

1. **Max 3 photos on free tier**
   - Description: Free users limited to 3 photos per activity
   - Workaround: Upgrade to premium
   - Fix planned: No (intentional limitation)

2. **Photo compression may reduce quality**
   - Description: Large photos compressed to 1080p max
   - Workaround: None (necessary for performance)
   - Fix planned: No (acceptable trade-off)

3. **No photo sync during upload**
   - Description: Photos only sync after upload completes
   - Workaround: Wait for upload before switching devices
   - Fix planned: Yes (future: sync pending uploads)

### Maintenance Tasks:

1. **Monitor storage costs**
   - Frequency: Weekly
   - Procedure: Check Firebase Storage usage in console

2. **Clean up orphaned photos**
   - Frequency: Monthly
   - Procedure: Run cleanup script to remove photos not linked to activities

### Refactoring Opportunities:

1. **Extract photo compression logic**
   - Current: Compression in photoService.js (mixed concerns)
   - Proposed: Create imageUtils.js with compression utilities
   - Benefit: Reusable across app (profile photos, etc.)
   - Effort: 2 hours

2. **Unified media service**
   - Current: photoService handles only photos
   - Proposed: mediaService handles photos, videos, audio
   - Benefit: Easier to add video support later
   - Effort: 4 hours
```

### Documentation Example:

```markdown
## Photo Attachments - Developer Guide

### Overview
The photo attachment feature allows users to attach up to 3 photos per activity.
Photos are stored in Firebase Storage and synced across devices via URLs.

### Architecture

#### Components:
- **PhotoAttachment.js**: Photo picker UI
- **PhotoGallery.js**: Full-screen photo viewer
- **ActivityCard.js**: Displays photo thumbnails

#### Services:
- **photoService.js**: Upload, delete, thumbnail generation
- **Firebase Storage**: Cloud photo storage

#### Data Structure:
```javascript
activity: {
  // ... other fields
  photos: [
    {
      url: "https://...",           // Full-size photo URL
      thumbnailUrl: "https://...",  // Thumbnail URL (optimized)
      timestamp: 1234567890,        // Upload timestamp
      size: 1024000                 // File size in bytes
    }
  ]
}
```

### API Reference

#### photoService.uploadPhoto(uri, activityId)
Uploads photo to Firebase Storage and generates thumbnail.

**Parameters**:
- `uri` (string): Local file URI
- `activityId` (string): Activity to attach photo to

**Returns**: Promise<{ url, thumbnailUrl, timestamp, size }>

**Example**:
```javascript
import photoService from './services/photoService'

const result = await photoService.uploadPhoto(
  'file:///path/to/photo.jpg',
  'activity_123'
)
// { url: "https://...", thumbnailUrl: "https://...", ... }
```

#### photoService.deletePhoto(url, activityId)
Deletes photo from Firebase Storage and removes from activity.

**Parameters**:
- `url` (string): Full-size photo URL
- `activityId` (string): Activity ID

**Returns**: Promise<void>

### Testing

Run tests:
```bash
npm test -- photoService
```

### Troubleshooting

**Photo upload fails**:
- Check Firebase Storage rules allow authenticated uploads
- Verify network connectivity
- Check file size < 10MB

**Thumbnail not displaying**:
- Check thumbnail URL is valid
- Verify Firebase Storage CORS configured
- Check network connectivity

**Permission denied**:
- iOS: Check Info.plist has NSPhotoLibraryUsageDescription
- Android: Check AndroidManifest.xml has READ_EXTERNAL_STORAGE
```

---

## Phase 9: Deployment

**Goal**: Deploy via quality gates with staged rollout.

**Time allocation**: 15-20 minutes per tier

### Steps:

1. **Pre-deployment validation**
   ```bash
   # Run full quality gates
   ./atlas-skills/atlas-full/scripts/quality-gates.sh
   ```

2. **Update PENDING_CHANGES.md**
   ```markdown
   ## Title: Photo Attachments for Activities

   ### Changes Made:
   - Added photo attachment feature (up to 3 per activity)
   - Implemented photo picker (camera + gallery)
   - Added full-screen photo viewer with swipe navigation
   - Integrated Firebase Storage for cloud photos
   - Added photo sync across devices (URLs only)
   - Implemented thumbnail generation for performance
   - Added offline upload queue
   - Comprehensive testing across all platforms

   ### Testing:
   - All acceptance criteria met (10/10 must-have)
   - Tested on iOS, Android, Web
   - Performance: Upload 2.3s, Display 140ms
   - Test coverage: 87%

   ### Documentation:
   - Updated user guide
   - Added developer docs for photoService API
   - Added troubleshooting guide
   ```

3. **Deploy to QUAL** (development testing)
   ```bash
   ./scripts/deploy.sh qual --all
   ```
   - Test thoroughly on QUAL
   - Verify all functionality works
   - Check logs for errors
   - Monitor performance

4. **Deploy to STAGE** (internal validation)
   ```bash
   ./scripts/deploy.sh stage --all
   ```
   - Internal team testing
   - Gather feedback
   - Verify no issues

5. **Deploy to BETA** (closed beta testing)
   ```bash
   ./scripts/deploy.sh beta --all
   ```
   - Monitor closely
   - Track success metrics
   - Gather user feedback
   - Fix critical issues if any

6. **Deploy to PROD** (production release)
   ```bash
   ./scripts/deploy.sh prod --all
   ```
   - Gradual rollout (feature flag: 10% → 50% → 100%)
   - Monitor error rates
   - Monitor success metrics
   - Celebrate! 🎉

### Deployment Checklist:

**Pre-Deployment**:
- [ ] Quality gates script passes
- [ ] PENDING_CHANGES.md updated
- [ ] All tests pass (100%)
- [ ] Type checking passes
- [ ] Build succeeds (all platforms)
- [ ] No critical bugs
- [ ] Documentation complete
- [ ] Rollback plan ready

**QUAL Deployment**:
- [ ] Deployed successfully
- [ ] Tested on QUAL environment
- [ ] All functionality works
- [ ] No errors in logs
- [ ] Performance acceptable

**STAGE Deployment**:
- [ ] Deployed successfully
- [ ] Internal team tested
- [ ] Feedback gathered
- [ ] Issues resolved (if any)

**BETA Deployment**:
- [ ] Deployed successfully
- [ ] Beta users notified
- [ ] Monitoring active
- [ ] Success metrics tracked
- [ ] User feedback gathered
- [ ] Issues resolved (if any)

**PROD Deployment**:
- [ ] Deployed successfully
- [ ] Feature flag enabled (gradual)
- [ ] Monitoring active
- [ ] Error rates normal
- [ ] Success metrics tracked
- [ ] No rollback needed

### Monitoring During Rollout:

**Metrics to watch**:
- Error rate (should stay < 1%)
- Crash rate (should not increase)
- Success metrics (adoption, usage)
- Performance metrics (load time, memory)
- User feedback (reviews, support tickets)

**Alert thresholds**:
- 🔴 Error rate > 5% → Rollback immediately
- 🟡 Error rate 1-5% → Investigate, pause rollout
- 🟢 Error rate < 1% → Continue rollout

**Rollback triggers**:
- Critical bug discovered
- Error rate > 5%
- Crash rate increase > 2x
- Data integrity issues
- Security vulnerability

### Deployment Output:

```markdown
## Deployment Report: Photo Attachments

### QUAL Deployment ✅ (Day 1, 2pm)
- Deployed: v2025.01.20-photo-attachments
- Tested: All functionality works
- Performance: Upload 2.3s, Display 140ms
- Issues: None
- Status: ✅ Ready for STAGE

### STAGE Deployment ✅ (Day 2, 10am)
- Deployed: v2025.01.21-photo-attachments
- Internal testing: 5 team members
- Feedback:
  - 👍 "Upload is fast"
  - 💡 "Add photo captions" (backlog item created)
- Issues: None
- Status: ✅ Ready for BETA

### BETA Deployment ✅ (Day 3, 2pm)
- Deployed: v2025.01.22-photo-attachments
- Beta users: 50 active users
- Monitoring (24 hours):
  - Adoption: 38/50 (76%) attached at least one photo
  - Upload success: 98.5% (147/149 uploads)
  - Error rate: 0.3% (very low)
  - Performance: Upload 2.4s avg, Display 135ms avg
- User feedback:
  - 👍 "Love the photo feature!"
  - 👍 "Works great on Android"
  - 🐛 1 user reported slow upload on 3G (acceptable)
- Issues: None critical
- Status: ✅ Ready for PROD

### PROD Deployment ✅ (Day 5, 10am)

**Phase 1: 10% rollout** (Day 5, 10am)
- Users: ~100 users
- Monitoring (4 hours):
  - Adoption: 72% (good)
  - Error rate: 0.4% (normal)
  - Performance: Normal
- Status: ✅ Proceed to 50%

**Phase 2: 50% rollout** (Day 5, 2pm)
- Users: ~500 users
- Monitoring (8 hours):
  - Adoption: 78% (excellent)
  - Error rate: 0.6% (normal)
  - Performance: Normal
  - Firebase Storage usage: +15GB (acceptable)
- Status: ✅ Proceed to 100%

**Phase 3: 100% rollout** (Day 6, 10am)
- Users: All users (~1,000)
- Monitoring (24 hours):
  - Adoption: 81% (🎯 exceeded target of 80%)
  - Error rate: 0.5% (normal)
  - Performance: Upload 2.5s avg, Display 142ms avg
  - Firebase Storage costs: $3.20/day (within budget)
- Status: ✅ COMPLETE

### Week 1 Success Metrics: ✅ ALL TARGETS MET

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Adoption | 80%+ attach photo in week 1 | 81% | ✅ |
| Performance | Upload < 3s | 2.5s avg | ✅ |
| Performance | Display < 200ms | 142ms avg | ✅ |
| Reliability | 99%+ success rate | 99.5% | ✅ |
| Quality | Zero storage crashes | 0 crashes | ✅ |

### Post-Launch Monitoring (Day 7)

**Usage stats**:
- Total photos uploaded: 4,234
- Avg photos per user: 4.2
- Most active time: 6-9pm (evenings)

**Performance stats**:
- Upload time P50: 2.1s
- Upload time P95: 4.8s (acceptable)
- Display time P50: 120ms
- Display time P95: 310ms (acceptable)

**Cost analysis**:
- Storage cost: $22.40/week (within budget)
- Bandwidth cost: $5.30/week (acceptable)

**Issues found**:
- 2 users reported confusion about 3-photo limit → Clarified in UI (hotfix)
- 1 edge case: Photo upload during app backgrounding → Fixed in v2025.01.23

### Overall: 🎉 SUCCESS

Photo attachment feature launched successfully. All success metrics exceeded
targets. User feedback overwhelmingly positive. No critical issues. Feature
considered stable and complete.

**Next steps**:
- Monitor storage costs weekly
- Address "photo captions" feature request (backlog)
- Consider video support in Q2 (future)
```

---

## Success Indicators

### You've succeeded when:
- ✅ 100% of acceptance criteria met
- ✅ Zero critical defects in first week
- ✅ All success metrics targets met or exceeded
- ✅ Complete documentation and evidence
- ✅ Full test coverage for critical paths
- ✅ Security audit passed (if applicable)
- ✅ Cross-platform validation complete
- ✅ Smooth deployment (no rollbacks)
- ✅ Positive user feedback
- ✅ Technical debt documented

### You should have downgraded to Standard if:
- ⚠️ Scope reduced to < 6 files
- ⚠️ Formal requirements not needed
- ⚠️ Simpler than initially estimated

---

## Escalation Rules

### When to escalate from Standard to Full:
- Scope expanded to 6+ files
- Security concerns emerged
- Formal requirements needed
- Cross-platform complexity high
- Stakeholder sign-off required

### When to consider breaking into multiple Full workflows:
- Epic too large (> 4 hours estimated)
- Multiple independent features
- Phased rollout over weeks/months

---

## Common Pitfalls

### ❌ Don't Do This:

1. **Skip research phase** ("I know what to build")
   - Problem: Misunderstand requirements, miss edge cases
   - Solution: Always complete Phase 1 research

2. **Skip story creation** ("Requirements are clear")
   - Problem: No measurable acceptance criteria, scope creep
   - Solution: Write formal stories with testable criteria

3. **Skip adversarial review** ("Nothing can go wrong")
   - Problem: Security issues, edge cases missed, performance problems
   - Solution: Be paranoid, think like an attacker

4. **Implement everything at once** ("I'll test after it's all done")
   - Problem: Hard to debug, hard to test, integration issues
   - Solution: Implement iteratively, test after each iteration

5. **Skip documentation** ("Code is self-documenting")
   - Problem: Future developers struggle, knowledge lost
   - Solution: Document while fresh in mind

6. **Deploy to production immediately** ("It works on my machine")
   - Problem: Production issues, user impact
   - Solution: Use staged rollout (QUAL → STAGE → BETA → PROD)

7. **Ignore technical debt** ("We'll fix it later")
   - Problem: Debt accumulates, maintenance burden increases
   - Solution: Document debt, plan to address

### ✅ Do This Instead:

1. **Complete all 9 phases** (don't skip, they're fast for their value)
2. **Write specific, testable acceptance criteria**
3. **Think adversarially** (security, edge cases, performance)
4. **Implement iteratively** (test often, fail fast)
5. **Document thoroughly** (while context fresh)
6. **Use staged rollout** (QUAL → STAGE → BETA → PROD)
7. **Log technical debt** (make it visible, plan to address)
8. **Celebrate success** (you built something complex!) 🎉

---

## Integration with Agent Skills

The Full workflow can leverage specialized agent skills:

- **atlas-agent-product-manager**: Story creation (Phase 2), validation (Phase 7)
- **atlas-agent-developer**: Implementation (Phase 5), testing (Phase 6)
- **atlas-agent-peer-reviewer**: Adversarial review (Phase 4), validation (Phase 7)
- **atlas-agent-security**: Security audit (Phase 4)
- **atlas-agent-devops**: Deployment (Phase 9), monitoring

**Parallel agent work example**:
```
Phase 5: Implementation
├─ Agent: Developer → Implement service layer
├─ Agent: Developer → Implement UI components
└─ Agent: Peer-Reviewer → Write comprehensive tests

(All three work in parallel, then sync at end of phase)
```

---

## Resources

- **Story template**: See `resources/story-template.md`
- **Adversarial checklist**: See `resources/adversarial-checklist.md`
- **Quality gates script**: See `scripts/quality-gates.sh`
- **StackMap conventions**: See project `/CLAUDE.md`
- **Platform gotchas**: See `/docs/platform/`
- **Store architecture**: See `/docs/STORE_ARCHITECTURE.md`
- **Field conventions**: See `/docs/features/field-conventions.md`
- **Deployment guide**: See `/docs/deployment/README.md`

---

## Example: Complete Full Workflow

### Task: "Implement photo attachments for activities"

*(See detailed example throughout Phase 1-9 sections above)*

**Summary**:
- **Phase 1**: Researched photo storage options, dependencies, risks (30 min)
- **Phase 2**: Created user story with 10 acceptance criteria (15 min)
- **Phase 3**: Designed architecture, file plan, rollout strategy (25 min)
- **Phase 4**: Security audit, edge case analysis, performance review (20 min)
- **Phase 5**: Implemented in 4 iterations, tested each (85 min)
- **Phase 6**: Comprehensive testing, all platforms, all scenarios (40 min)
- **Phase 7**: Validated all acceptance criteria, stakeholder demo (15 min)
- **Phase 8**: Cleaned code, documented, logged technical debt (20 min)
- **Phase 9**: Deployed QUAL → STAGE → BETA → PROD (3 days, ~60 min total)

**Total time**: ~3.5 hours + 3-day staged rollout
**Outcome**: ✅ All success metrics exceeded, zero critical defects, positive feedback

---

## Quick Reference

### Full Workflow Commands:

```bash
# Phase 1: Research
grep -r "feature" src/
git log --grep="similar" --oneline

# Phase 5: Implementation
npm run typecheck  # Run often
npm test          # After each iteration

# Phase 6: Testing
npm test
npm run typecheck
npm run lint
npm run build:web

# Phase 8: Quality Gates
./atlas-skills/atlas-full/scripts/quality-gates.sh

# Phase 9: Deployment
./scripts/deploy.sh qual --all
./scripts/deploy.sh stage --all
./scripts/deploy.sh beta --all
./scripts/deploy.sh prod --all
```

### Time Allocation:

| Phase | Time | Cumulative |
|-------|------|------------|
| 1. Research | 20-30 min | 0:30 |
| 2. Story Creation | 15-20 min | 0:50 |
| 3. Planning | 20-30 min | 1:20 |
| 4. Adversarial Review | 15-20 min | 1:40 |
| 5. Implementation | 60-90 min | 3:10 |
| 6. Testing | 30-45 min | 3:55 |
| 7. Validation | 15-20 min | 4:15 |
| 8. Clean-up | 15-20 min | 4:35 |
| 9. Deployment | 15-20 min per tier | varies |
| **Total** | **2-4 hours** + staged rollout |

### Decision Matrix:

| Characteristic | Use Full ✅ | Use Standard ❌ |
|----------------|------------|-----------------|
| Files affected | 6+ files | 2-5 files |
| Formal requirements | Yes | No |
| Security critical | Yes | No |
| Cross-platform coordination | Yes | Simple |
| Stakeholder sign-off | Required | Not required |
| Epic-level work | Yes | Task-level |
| Comprehensive testing | Required | Standard tests OK |
| Documentation | Extensive | Standard |

---

## Summary

The Full workflow is for **complex, critical features** that require:
- Formal requirements and acceptance criteria
- Security audits and adversarial thinking
- Comprehensive testing across all scenarios
- Complete documentation and knowledge transfer
- Staged rollout with monitoring

**Use Full workflow when**:
- Building new modules/services
- Security is critical
- Cross-platform coordination needed
- Stakeholder sign-off required
- Epic-level features (6+ files)

**Don't use Full workflow when**:
- Simple bug fixes (use Standard)
- Style tweaks (use Iterative)
- Trivial changes (use Quick)

When in doubt, **start with Standard** and escalate to Full if complexity emerges.

---

**Remember**: The Full workflow ensures **100% acceptance, zero defects, and complete evidence**. It's rigorous because the stakes are high. Take the time to do it right. 🚀
