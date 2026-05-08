# UX and Product Specialist

## Skill Overview
This skill provides expert guidance on user experience (UX) design, product strategy, user research, and interface optimization. Use this skill when designing new features, improving existing workflows, or making product decisions.

## When to Use This Skill

### Primary Use Cases
1. **Feature Design** - Planning new features or user flows
2. **UX Audits** - Reviewing existing interfaces for usability issues
3. **User Research** - Analyzing user feedback, pain points, and behavior
4. **Product Strategy** - Making decisions about feature prioritization
5. **Conversion Optimization** - Improving conversion funnels and CTAs
6. **Accessibility** - Ensuring inclusive design practices
7. **Onboarding Flows** - Designing first-time user experiences
8. **Error States** - Creating helpful, user-friendly error messages

### Trigger Phrases
- "How should we design..."
- "What's the best UX for..."
- "Is this user-friendly?"
- "How can we improve conversion..."
- "What do users need..."
- "How should this flow work..."
- "What's the user journey..."

## Core Principles

### 1. User-Centered Design
- **Users First**: Always prioritize user needs over technical convenience
- **Mental Models**: Design interfaces that match user expectations
- **Cognitive Load**: Minimize thinking required to complete tasks
- **Progressive Disclosure**: Show information when needed, not all at once

### 2. Clarity Over Cleverness
- **Clear Language**: Use plain, direct language (no jargon)
- **Visible Actions**: Make buttons and CTAs obvious
- **Immediate Feedback**: Confirm actions with clear responses
- **Error Prevention**: Design to prevent mistakes before they happen

### 3. Consistency & Patterns
- **Design System**: Follow established patterns (glassmorphism, OKLCH colors)
- **Predictability**: Similar actions should work the same way
- **Visual Hierarchy**: Guide attention with size, color, spacing
- **Familiar Patterns**: Use standard UI conventions (don't reinvent)

### 4. Performance & Perception
- **Perceived Speed**: Use loading states, optimistic updates, skeleton screens
- **Real Speed**: Optimize actual performance (lazy loading, caching)
- **Progress Indicators**: Show progress for long operations
- **Instant Feedback**: Acknowledge user actions immediately

## ⚠️ CRITICAL: Fundamental Design Basics (ALWAYS CHECK FIRST)

### Color Contrast & Readability (NON-NEGOTIABLE)
```
RULE 1: Text Must Be Readable
✓ Light text on dark background (e.g., text-teal-300 on bg-black/40)
✓ Dark text on light background (e.g., text-gray-900 on bg-white)
❌ NEVER: Colored text on same-colored background (e.g., text-teal-700 on bg-teal-50)

RULE 2: Background Should Support Text Color
✓ Teal text → Use neutral/dark background (black, gray)
✓ Dark text → Use light/white background
❌ NEVER: Teal text on teal background (poor contrast)

RULE 3: Minimum Contrast Ratio
✓ Normal text: 4.5:1 contrast ratio minimum
✓ Large text (18pt+): 3:1 contrast ratio minimum
✓ Use tools: WebAIM Contrast Checker

Example:
✅ GOOD: text-teal-300 (light teal) on bg-black/40 (dark neutral)
❌ BAD: text-teal-700 (dark teal) on bg-teal-50 (light teal)
```

### Visual Hierarchy & Sizing (NON-NEGOTIABLE)
```
RULE 4: Important Elements Must Be BIGGER
✓ Primary actions: Larger buttons, more padding
✓ Selected states: Bigger than unselected (scale up)
✓ Key information: Larger text, bold weight
❌ NEVER: Same size for selected and unselected states

RULE 5: Use Size to Show Importance
✓ Selected format icon: w-10 h-10 (40px)
✓ Unselected format icon: w-8 h-8 (32px)
✓ Selected text: text-base font-semibold
✓ Unselected text: text-sm

RULE 6: Icons Must Be Professional & Scalable
✓ Use Lucide React icons (SVG, scalable)
✓ Minimum interactive size: 44×44px (mobile)
❌ NEVER: Emoji icons for professional interfaces (not scalable)

Example:
✅ GOOD: Selected button scales to 105%, icon w-10, text-base
❌ BAD: All buttons same size regardless of selection state
```

### Alert & Notification Design (NON-NEGOTIABLE)
```
RULE 7: Alerts Must Stand Out
✓ Dark background for light text (visibility)
✓ Sufficient padding and spacing
✓ Border to define boundaries
✓ Icon + text combination
❌ NEVER: Light alert on light background (invisible)

RULE 8: Alert Background Must Be Neutral
✓ Info alerts: Dark neutral (bg-black/40, bg-gray-900/50)
✓ Success alerts: Dark green background (bg-green-950/40)
✓ Error alerts: Dark red background (bg-red-950/40)
✓ Warning alerts: Dark yellow background (bg-yellow-950/40)
❌ NEVER: Colored text on same-colored background

Example - Excel Warning:
✅ GOOD:
  - Background: bg-black/40 (dark neutral)
  - Text: text-teal-300 (light teal pops on dark)
  - Border: border-teal-500/30 (subtle frame)

❌ BAD:
  - Background: bg-teal-50 (light teal)
  - Text: text-teal-700 (dark teal on light teal = poor contrast)
```

### Semantic Color Usage (NON-NEGOTIABLE)
```
RULE 9: Colors Must Have Meaning
✓ Teal/Primary: Brand, actions, links
✓ Green: Success, completion, positive
✓ Red: Errors, warnings, destructive actions
✓ Gray/Neutral: Backgrounds, disabled states
❌ NEVER: Random color choices without meaning

RULE 10: Background vs Foreground Color Logic
✓ If text is colored → Background should be neutral
✓ If background is colored → Text should be neutral/white
✓ Brand colors (teal) for accents, not backgrounds
❌ NEVER: Both text AND background in brand color

Color Pairing Matrix:
| Text Color      | Background Color | Contrast | Use Case |
|----------------|------------------|----------|----------|
| text-teal-300  | bg-black/40      | ✅ High  | Alerts   |
| text-teal-700  | bg-white         | ✅ High  | Buttons  |
| text-teal-700  | bg-teal-50       | ❌ Low   | AVOID    |
| text-white     | bg-teal-600      | ✅ High  | Buttons  |
```

### Pre-Design Checklist (RUN BEFORE EVERY DESIGN)
```
Before proposing ANY design change, verify:

☑️ 1. CONTRAST CHECK
   - Is text readable against background?
   - Run contrast ratio test (4.5:1 minimum)
   - Light text on dark? Dark text on light?

☑️ 2. SIZE CHECK
   - Are selected states BIGGER than unselected?
   - Are icons properly sized (minimum 32×32px)?
   - Is text size appropriate for hierarchy?

☑️ 3. COLOR LOGIC CHECK
   - If text is colored, is background neutral?
   - If background is colored, is text neutral?
   - Do colors have semantic meaning?

☑️ 4. VISIBILITY CHECK
   - Will alerts/notifications stand out?
   - Are important elements visually prominent?
   - Does visual hierarchy guide the eye?

☑️ 5. PROFESSIONAL STANDARDS
   - Using professional icons (not emojis)?
   - Following design system patterns?
   - Accessible (WCAG AA compliance)?

IF ANY CHECK FAILS → REDESIGN BEFORE PROPOSING
```

### Common Mistakes to NEVER Make Again
```
❌ MISTAKE 1: Same-Color Text and Background
Example: text-teal-700 on bg-teal-50
Fix: Use neutral background (bg-black/40) for colored text

❌ MISTAKE 2: Light Alert on Light Background
Example: bg-teal-50/50 alert on white page
Fix: Use dark background (bg-black/40) for visibility

❌ MISTAKE 3: Same Size for Selected/Unselected
Example: All buttons w-8 h-8 regardless of state
Fix: Selected bigger (w-10 h-10), unselected smaller (w-8 h-8)

❌ MISTAKE 4: Emoji Icons in Professional UI
Example: Using 📊📝📈 instead of Lucide icons
Fix: Use Presentation, FileText, FileSpreadsheet icons

❌ MISTAKE 5: No Visual Hierarchy
Example: Everything same size and color
Fix: Use size, weight, color to create hierarchy
```

### Automatic Design Review Questions
```
When user requests UI changes, ALWAYS ask yourself:

1. "Will the text be readable?" (Contrast check)
2. "Does the selected state pop out?" (Size check)
3. "Is the background appropriate for text color?" (Logic check)
4. "Will this be visible on the page?" (Visibility check)
5. "Is this accessible?" (A11y check)

If answer to ANY question is "No" or "Maybe":
→ REDESIGN before proposing
→ Explain WHY the design needs adjustment
→ Reference these fundamental rules
```

## UX Design Process

### Step 1: Understand the Problem
```
Questions to Ask:
- What user problem are we solving?
- What's the user's goal?
- What pain points exist in the current flow?
- What are users trying to accomplish?
- What context are they in when using this?
```

### Step 2: Map the User Journey
```
Journey Mapping:
1. Entry Point: How do users arrive?
2. Discovery: How do they learn what to do?
3. Action: What steps do they take?
4. Feedback: What confirms success/failure?
5. Outcome: What value did they receive?
6. Next Steps: Where do they go from here?
```

### Step 3: Design Solutions
```
Design Considerations:
- Information Architecture: How is content organized?
- Visual Design: What does it look like?
- Interaction Design: How does it behave?
- Copy/Microcopy: What does it say?
- Edge Cases: What happens when things go wrong?
```

### Step 4: Validate & Iterate
```
Validation Checklist:
✓ Can a first-time user complete the task?
✓ Is every action's outcome clear?
✓ Are error messages helpful and actionable?
✓ Does it work on mobile and desktop?
✓ Is it accessible (keyboard nav, screen readers)?
✓ Does it match our design system?
```

## PDFLab-Specific Guidelines

### Design System
- **Glassmorphism**: Use `.glass-strong` and `.glass-subtle` classes
- **Colors**: OKLCH color space (primary: oklch(0.72 0.15 250))
- **Typography**: Clear hierarchy, readable font sizes
- **Spacing**: Consistent padding/margins using Tailwind scale

### Key User Flows

#### 1. Conversion Flow
```
Goal: Convert PDF quickly with minimal friction

Optimal Flow:
1. Upload PDF (drag-drop or click)
   - Show file name, size, preview
2. Select format (PPTX, DOCX, XLSX, PNG)
   - Visual icons, clear labels
3. Start conversion (single clear CTA)
   - "Convert to PPTX" (specific, action-oriented)
4. Show progress (real-time updates)
   - Percentage, estimated time
5. Download result (automatic or manual)
   - Clear "Download" button, file info

UX Principles Applied:
- Minimal steps (3 clicks max)
- Clear visual feedback at each stage
- Error prevention (file validation upfront)
- Progress transparency (no black box)
```

#### 2. Pricing to Payment Flow
```
Goal: Convert free users to paid subscribers

Optimal Flow:
1. Show value (clear plan comparison)
   - Feature differences highlighted
   - Social proof (testimonials/badges)
2. Plan selection (obvious CTAs)
   - "Choose Pro" - action-oriented
3. Payment (minimal friction)
   - Pre-filled email for logged-in users
   - Clear total amount in USD
4. Confirmation (immediate value)
   - Success message + next steps
   - Redirect to dashboard/conversion

UX Principles Applied:
- Value before price (show benefits)
- Reduce decision fatigue (recommend a plan)
- Trust indicators (secure payment badges)
- Immediate gratification (instant access)
```

#### 3. Dashboard Experience
```
Goal: Help users track usage and manage account

Key Elements:
- Usage Overview (conversions used/limit)
  - Visual progress bars
  - Clear upgrade path if near limit
- Recent Conversions (history)
  - Sortable, searchable table
  - Quick re-download actions
- Account Management (plan, billing)
  - Current plan with benefits listed
  - Easy upgrade/downgrade options

UX Principles Applied:
- Scannable information (cards, not walls of text)
- Actionable insights (show next steps)
- Status visibility (quota, subscription status)
```

### Error Messaging Best Practices

#### Bad Error Messages
```
❌ "Error: 500"
❌ "Invalid input"
❌ "Something went wrong"
❌ "File too large"
```

#### Good Error Messages
```
✅ "File size exceeds 10MB limit"
   → Specific problem identified
   → Shows current limit
   → Action: "Upgrade to Pro for 100MB files"

✅ "PDF conversion failed: File is password-protected"
   → Clear reason for failure
   → Action: "Remove password and try again"

✅ "Conversion quota exceeded (3/3 used this month)"
   → Shows exact usage
   → Action: "Upgrade to Starter for 100 conversions/month"
```

**Error Message Formula**:
```
[What happened] + [Why it happened] + [How to fix it]
```

### Conversion Rate Optimization (CRO)

#### High-Impact CRO Tactics
1. **Clear Value Proposition**
   - Above the fold: "Convert PDFs to PowerPoint, Word, Excel in seconds"
   - Specific, measurable benefit

2. **Trust Indicators**
   - Social proof: "10,000+ conversions completed"
   - Security badges: "Secure SSL encryption"
   - Privacy: "Files deleted after 24 hours"

3. **Reduced Friction**
   - Guest conversion allowed (capture email later)
   - Single-click conversions (minimal form fields)
   - Auto-save progress (resume interrupted conversions)

4. **Strategic CTAs**
   - Primary action: High contrast, large, action-oriented
   - "Convert to PPTX Now" vs "Submit"
   - Secondary actions: Lower contrast

5. **Urgency & Scarcity** (when appropriate)
   - "2/3 conversions used this month" → Encourages upgrade
   - "50% off Pro - ends today" → Limited time offers

#### A/B Testing Priorities
```
Test Priority:
1. Primary CTA text ("Convert Now" vs "Start Conversion")
2. Pricing page plan order (Free-Starter-Pro vs Pro-Starter-Free)
3. Upload UI (drag-drop only vs drag+button)
4. Results page (auto-download vs manual download)
5. Navigation placement (top vs sidebar)
```

### Accessibility Checklist

```
✓ Keyboard Navigation
  - Tab through all interactive elements
  - Enter/Space activate buttons
  - Escape closes modals

✓ Screen Reader Support
  - Semantic HTML (button, nav, main, article)
  - ARIA labels for icon-only buttons
  - Alt text for images

✓ Visual Accessibility
  - Contrast ratio ≥ 4.5:1 (text)
  - Focus indicators visible
  - No color-only information

✓ Motion & Animation
  - Respect prefers-reduced-motion
  - No auto-playing videos
  - Pausable animations

✓ Error Handling
  - Error messages near inputs
  - ARIA live regions for dynamic errors
  - Clear error recovery paths
```

## Product Decision Framework

### Feature Prioritization (RICE Score)
```
Reach: How many users affected? (1-10)
Impact: How much value per user? (0.25-3)
Confidence: How sure are we? (50%-100%)
Effort: How many person-weeks? (1-20)

Score = (Reach × Impact × Confidence) / Effort

Example:
Feature: PDF Compression
- Reach: 8 (most users need it)
- Impact: 2 (moderate value)
- Confidence: 80% (proven feature)
- Effort: 3 weeks

Score = (8 × 2 × 0.8) / 3 = 4.27
```

### Build vs. Buy vs. Defer
```
Build If:
- Core differentiator (unique value prop)
- Simple implementation (< 1 week)
- Long-term competitive advantage

Buy/Integrate If:
- Commodity feature (table stakes)
- Complex implementation (> 4 weeks)
- Mature third-party solution exists

Defer If:
- Low user demand (< 10% requests)
- High effort, low impact
- Workaround exists
```

## Mobile-First Design Considerations

### Mobile UX Patterns
```
Touch Targets:
- Minimum 44×44px (iOS) / 48×48dp (Android)
- Spacing between taps ≥ 8px

Thumb Zones:
- Primary actions: Bottom third (easy reach)
- Secondary: Top (requires stretch)
- Navigation: Bottom tabs or top fixed

File Upload (Mobile):
- Camera capture option (take photo of document)
- Cloud storage integration (Drive, Dropbox)
- Recent files quick access
```

### Responsive Breakpoints
```
Mobile: < 640px
Tablet: 640px - 1024px
Desktop: > 1024px

Key Adaptations:
- Stack cards vertically on mobile
- Hamburger menu < 768px
- Single-column forms on mobile
- Hide secondary info on small screens
```

## Workflow: Conducting a UX Audit

### Step-by-Step UX Audit Process
```
1. Define Scope
   - What page/flow are we auditing?
   - What user goal are we optimizing for?

2. Heuristic Evaluation
   - Check against 10 usability heuristics:
     1. Visibility of system status
     2. Match system to real world
     3. User control and freedom
     4. Consistency and standards
     5. Error prevention
     6. Recognition vs recall
     7. Flexibility and efficiency
     8. Aesthetic and minimalist design
     9. Help users with errors
     10. Help and documentation

3. Task Analysis
   - Can a user complete the task?
   - How many steps? (fewer = better)
   - Where do they get stuck?

4. Accessibility Check
   - Run through checklist above
   - Test with screen reader
   - Test keyboard-only navigation

5. Report Findings
   - List issues (severity: critical/high/medium/low)
   - Suggest fixes with mockups/examples
   - Prioritize by impact/effort
```

## Common UX Anti-Patterns to Avoid

```
❌ Mystery Meat Navigation
- Icons without labels (unclear meaning)
→ Fix: Add text labels or tooltips

❌ Premature Confirmation
- "Are you sure?" for every action
→ Fix: Use undo instead of confirm

❌ Pagination Overload
- 50 items per page with 100 pages
→ Fix: Infinite scroll or search/filter

❌ Fake Urgency
- "Only 2 spots left!" (always shows 2)
→ Fix: Be honest, build real trust

❌ Hidden Costs
- Price shown at end (after email/signup)
→ Fix: Show total upfront

❌ Disabled Buttons Without Explanation
- Grayed-out submit (no reason given)
→ Fix: Show validation errors inline

❌ Auto-Playing Media
- Video/audio starts automatically
→ Fix: User-initiated playback only
```

## Microcopy Guidelines

### Button Text
```
Action-Oriented (Good):
✓ "Convert to PPTX"
✓ "Download My File"
✓ "Upgrade to Pro"
✓ "Start Free Trial"

Generic (Avoid):
❌ "Submit"
❌ "OK"
❌ "Click Here"
❌ "Continue"
```

### Empty States
```
Helpful (Good):
✓ "No conversions yet. Upload your first PDF to get started!"
  [Upload PDF Button]

Unhelpful (Avoid):
❌ "No data"
❌ "0 results"
```

### Success Messages
```
Specific & Next-Step (Good):
✓ "PDF converted successfully! Your PPTX file is ready."
  [Download Now Button]

Vague (Avoid):
❌ "Success"
❌ "Done"
```

## UX Metrics to Track

```
Conversion Funnel:
- Landing page → Upload (bounce rate)
- Upload → Format selection (drop-off)
- Format → Convert (abandon rate)
- Convert → Download (completion rate)

Engagement:
- Time to first conversion (onboarding efficiency)
- Conversions per user (product stickiness)
- Return rate (7-day, 30-day)

Satisfaction:
- NPS (Net Promoter Score)
- CSAT (Customer Satisfaction)
- Support ticket volume (fewer = better UX)

Performance:
- Page load time (< 3s goal)
- Time to interactive (< 5s goal)
- Conversion processing time
```

## Resources & Tools

### UX Research Tools
- **Hotjar**: Heatmaps, session recordings
- **UserTesting**: Moderated user tests
- **Google Analytics**: Behavior flow, bounce rates
- **Maze**: Rapid prototype testing

### Design Tools
- **Figma**: UI design, prototyping
- **Tailwind CSS**: Utility-first styling (used in PDFLab)
- **Shadcn UI**: Component library (used in PDFLab)

### Accessibility Testing
- **WAVE**: Browser extension for a11y
- **axe DevTools**: Automated accessibility testing
- **VoiceOver/NVDA**: Screen reader testing

## Example: UX Audit Template

```markdown
# UX Audit: [Feature/Page Name]

## Scope
- **Page**: [URL or component]
- **User Goal**: [What are users trying to do?]
- **Date**: [Audit date]

## Findings

### Critical Issues (Fix Immediately)
1. **[Issue Title]**
   - Problem: [Description]
   - Impact: [How it affects users]
   - Fix: [Recommended solution]
   - Priority: Critical

### High Priority (Fix This Sprint)
[Same format as above]

### Medium Priority (Fix Next Sprint)
[Same format as above]

### Low Priority (Backlog)
[Same format as above]

## Recommendations Summary
1. [Top recommendation]
2. [Second recommendation]
3. [Third recommendation]

## Next Steps
- [ ] Implement critical fixes
- [ ] Design mockups for high-priority items
- [ ] Re-audit after changes
```

## Skill Activation

### How to Invoke This Skill
```
Example Prompts:
- "Use the UX Product Specialist skill to review the pricing page"
- "Apply UX best practices to design the batch conversion feature"
- "Conduct a UX audit on the dashboard using the specialist skill"
- "What's the optimal user flow for PDF compression? Use UX skill"
```

### Skill Outputs
When this skill is active, expect:
- User journey maps
- UX audit reports with prioritized issues
- Wireframe/flow recommendations
- Microcopy suggestions
- A/B test hypotheses
- Accessibility checklists
- Product decision frameworks (RICE scoring)

---

## Skill Metadata
- **Version**: 1.0.0
- **Created**: 2025-11-09
- **Category**: Product & UX
- **Dependencies**: None
- **Related Skills**: design-system-architect.SKILL.md

**Usage**: Invoke this skill when making product decisions, designing features, or improving user experience. Combine with design-system-architect skill for implementation details.
