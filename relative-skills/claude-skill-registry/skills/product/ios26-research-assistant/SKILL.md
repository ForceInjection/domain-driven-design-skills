---
name: ios26-research-assistant
description: Compensates for Claude's January 2025 knowledge cutoff by actively searching Apple's official iOS 26 documentation before making claims about iOS 26 APIs, frameworks, or features. This skill should be used when about to make statements about iOS 26 features, suggesting iOS 26-specific APIs, implementing iOS 26 functionality, or answering questions about iOS 26 capabilities. The skill provides multi-tier search workflows using Apple RAG, Sosumi, and web search tools with proper verification tagging.
---

# iOS 26 Research Assistant

## Purpose

Compensate for Claude's January 2025 knowledge cutoff by actively searching Apple's official iOS 26 documentation before making claims about iOS 26 APIs, frameworks, or features.

**Core Principle:** Never state iOS 26 facts without verification. Always search official Apple documentation first.

## When to Use This Skill

### Auto-Activate (Mandatory)

**Trigger automatically when:**
- About to make statements like "iOS 26 has...", "In iOS 26...", "iOS 26 supports..."
- Suggesting iOS 26-specific APIs (`.glassEffect()`, `GlassEffectContainer`, etc.)
- Implementing iOS 26 features
- Answering "Does iOS 26 support X?" questions
- Explaining iOS 26 breaking changes or new patterns
- Referencing WWDC 2025 sessions

### Manual Invocation

**User explicitly requests:**
- "Research iOS 26 [feature]"
- "Verify iOS 26 [API]"
- "What's new in iOS 26?"
- "Find iOS 26 documentation for X"
- "Check Apple docs for Y"
- "Is this correct for iOS 26?"

### DO NOT Use

**Skip this skill for:**
- General Swift 6 language features (unless iOS 26-specific)
- Cross-platform Swift code not tied to iOS APIs
- Historical iOS versions (iOS 25 and earlier)
- Third-party frameworks or libraries
- General programming concepts

## Available MCP Tools

### Tier 1: Apple RAG (Primary)

**Tool:** `mcp__apple-rag-mcp__search`

**Usage:**
```
mcp__apple-rag-mcp__search(
    query: "iOS 26 Liquid Glass glassEffect API parameters",
    result_count: 5
)
```

**Returns:**
- Actual documentation snippets with code examples
- API signatures and parameters
- WWDC session transcripts
- Related documentation URLs

**Best For:**
- API syntax and parameters
- Code examples
- Official explanations
- Quick verification

**Example Query Patterns:**
- "iOS 26 glassEffect API SwiftUI 2025"
- "SwiftData iOS 26 actor patterns"
- "AVAudioEngine iOS 26 changes"
- "NavigationStack iOS 26 improvements"

### Tier 2: Sosumi Search (Secondary)

**Tool:** `mcp__sosumi__searchAppleDocumentation`

**Usage:**
```
mcp__sosumi__searchAppleDocumentation(
    query: "iOS 26 glassEffect"
)
```

**Returns:**
- Documentation URLs and paths
- Title and descriptions
- Breadcrumbs for navigation
- Related documentation links

**Best For:**
- Finding specific documentation pages
- Discovering release notes
- Locating WWDC sessions
- Navigation and exploration

### Tier 3: Fetch Complete Documentation (Depth)

**Tool:** `mcp__apple-rag-mcp__fetch` or `mcp__sosumi__fetchAppleDocumentation`

**Usage:**
```
mcp__apple-rag-mcp__fetch(
    url: "https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views"
)
```

**Returns:**
- Complete cleaned article content
- Full API documentation
- Extended code examples
- Comprehensive explanations

**Best For:**
- Deep understanding of complex topics
- Full tutorial content
- Complete API reference
- Detailed implementation guides

### Tier 4: Web Search (Fallback)

**Tool:** `mcp__brave-search__brave_web_search`

**Usage:**
```
mcp__brave-search__brave_web_search(
    query: "iOS 26 migration guide site:developer.apple.com 2025",
    count: 5
)
```

**Returns:**
- Web search results from Apple and community
- Blog posts and articles
- Stack Overflow discussions
- Beta release notes

**Best For:**
- Community discussions
- Beta-specific issues
- Migration guides
- Troubleshooting

## Verification Workflow

### Pre-Response Checklist

Before responding with iOS 26 information:

1. **Detect iOS 26 Claim** - Scan my intended response for iOS 26 references
2. **Extract Key Terms** - Identify API names, framework names, or features
3. **Execute Multi-Tier Search** - Start with Tier 1, escalate as needed
4. **Tag Results** - Apply appropriate verification tag
5. **Cite Sources** - Include documentation URLs
6. **Respond** - Provide verified answer with tags and citations

### Multi-Tier Search Strategy

```
┌─────────────────────────────────────────┐
│ Step 1: Apple RAG Search (Tier 1)      │
│ Tool: mcp__apple-rag-mcp__search        │
│ Timeout: 10 seconds                     │
└─────────────┬───────────────────────────┘
              │
              ├─── Found? ──> Tag [Verified-Apple-iOS26] + Cite URL
              │
              └─── Not Found? ──> Continue to Tier 2
                                   │
┌─────────────────────────────────┴───────┐
│ Step 2: Sosumi Search (Tier 2)         │
│ Tool: mcp__sosumi__searchAppleDocumentation │
│ Timeout: 10 seconds                     │
└─────────────┬───────────────────────────┘
              │
              ├─── Found URLs? ──> Fetch with Tier 3
              │                     │
              │                     └─> Tag [Verified-Apple-iOS26] + Cite
              │
              └─── Not Found? ──> Continue to Tier 4
                                   │
┌─────────────────────────────────┴───────┐
│ Step 3: Web Search (Tier 4)            │
│ Tool: mcp__brave-search__brave_web_search │
│ Timeout: 10 seconds                     │
└─────────────┬───────────────────────────┘
              │
              ├─── Found on Apple.com? ──> Tag [Verified-Apple-iOS26]
              │
              ├─── Found elsewhere? ──> Tag [External-Source] + Caveat
              │
              └─── Not Found? ──> Tag [Searched-Not-Found]
```

### Verification Tags

Use these tags to indicate verification status:

**[Verified-Apple-iOS26]**
- Found in official Apple documentation
- Include source URL
- High confidence

**[Verified-WWDC25]**
- Found in WWDC 2025 session content
- Include session number and timestamp
- High confidence

**[Searched-Not-Found]**
- Searched Apple docs but not found
- Feature may not exist or documentation pending
- Explicitly state this to user

**[Inference-Only]**
- Based on pre-January 2025 knowledge
- Could not verify with current documentation
- Low confidence - state assumptions clearly

**[External-Source]**
- Found in community resources, not Apple docs
- Include source but note it's unofficial
- Medium confidence

### Citation Format

Always include source URLs when providing verified information:

**Example:**
```markdown
According to Apple's iOS 26 documentation [Verified-Apple-iOS26], the
`.glassEffect()` modifier accepts a `Glass` parameter that can be customized
with `.tint()` and `.interactive()` modifiers.

Source: https://developer.apple.com/documentation/swiftui/view/glasseffect

Example from docs:
```swift
Text("Hello, World!")
    .glassEffect(.regular.tint(.orange).interactive())
```
```

## Priority Topics for Fonic HiFi Project

### Critical APIs to Verify

1. **Liquid Glass Design System**
   - `.glassEffect(_:in:)` parameters and variants
   - `GlassEffectContainer` usage and spacing
   - `Glass.regular`, `Glass.clear` variants
   - `.tint()` and `.interactive()` modifiers
   - `glassEffectID` for morphing transitions

2. **SwiftUI iOS 26 Improvements**
   - NavigationStack enhancements
   - Sheet presentation improvements
   - Animation and transition changes
   - View morphing capabilities
   - Layout system updates

3. **SwiftData iOS 26**
   - `@ModelActor` patterns and changes
   - Actor isolation improvements
   - Query performance enhancements
   - Relationship handling updates
   - Migration patterns

4. **AVAudioEngine iOS 26**
   - API changes or deprecations
   - Concurrency improvements
   - Performance optimizations
   - New audio features

5. **Swift 6.2 + iOS 26 Concurrency**
   - MainActor improvements
   - Actor isolation enhancements
   - Sendable conformance updates
   - Structured concurrency patterns

6. **iOS 26 Design Guidelines**
   - Human Interface Guidelines updates
   - Color system changes
   - Spacing and typography
   - Accessibility requirements

### WWDC 2025 Sessions to Reference

**Core Sessions:**
- **Session 323:** "Build a SwiftUI app with the new design"
- **Session 102:** Platform State of the Union
- **Session 256:** "Learn what's new in SwiftUI"
- **Session 317:** "Meet SwiftUI spatial layout"

**Search for Additional Sessions:**
```
Query: "WWDC25 [topic] iOS 26"
Example: "WWDC25 SwiftData iOS 26"
```

## Example Workflows

### Example 1: Verify Liquid Glass API

**User asks:** "How do I use Liquid Glass in iOS 26?"

**Workflow:**
```
1. Detect iOS 26 claim needed
2. Search: mcp__apple-rag-mcp__search("iOS 26 Liquid Glass glassEffect API")
3. Results found with code examples
4. Tag as [Verified-Apple-iOS26]
5. Cite: developer.apple.com/documentation/swiftui/view/glasseffect
6. Provide verified answer with examples from docs
```

**Response:**
```
According to Apple's iOS 26 documentation [Verified-Apple-iOS26], you use
the `.glassEffect()` modifier to apply Liquid Glass effects:

Basic usage:
```swift
Text("Hello, World!")
    .font(.title)
    .padding()
    .glassEffect()
```

With tinting and interactivity:
```swift
Text("Hello, World!")
    .glassEffect(.regular.tint(.orange).interactive())
```

Source: https://developer.apple.com/documentation/swiftui/view/glasseffect
```

### Example 2: Check SwiftData Changes

**User asks:** "Are there SwiftData improvements in iOS 26?"

**Workflow:**
```
1. Detect iOS 26 claim needed
2. Search: mcp__apple-rag-mcp__search("SwiftData iOS 26 new features 2025")
3. Check: mcp__sosumi__searchAppleDocumentation("iOS 26 release notes SwiftData")
4. If found: Tag [Verified-Apple-iOS26] + cite
5. If not found: Tag [Searched-Not-Found] + acknowledge
```

### Example 3: Feature Not Found

**User asks:** "Does iOS 26 have built-in AI voice synthesis?"

**Workflow:**
```
1. Search all tiers for "iOS 26 AI voice synthesis"
2. No results in Apple docs
3. Tag as [Searched-Not-Found]
4. State clearly: "I searched Apple's iOS 26 documentation but could not
   find information about built-in AI voice synthesis. This feature may
   not exist, or documentation may not be available yet."
```

## Integration with Project Workflows

### Pre-Code Verification

Before suggesting iOS 26 code:
1. Search for API documentation
2. Verify syntax and parameters
3. Include verified code examples from docs
4. Tag all iOS 26-specific code

### During Implementation

When implementing iOS 26 features:
1. Reference official documentation
2. Link to WWDC sessions
3. Note any beta limitations
4. Verify iOS 26.0+ availability

### Code Review

When reviewing iOS 26 code:
1. Verify APIs used are documented
2. Check for deprecated patterns
3. Confirm iOS 26-only usage (no fallbacks)
4. Validate against Apple guidelines

## Performance Considerations

### Search Timeouts

- Tier 1 (Apple RAG): 10 seconds max
- Tier 2 (Sosumi): 10 seconds max
- Tier 3 (Fetch): 15 seconds max
- Tier 4 (Web Search): 10 seconds max

**Total maximum search time:** ~45 seconds for full multi-tier search

### Optimization Strategies

1. **Cache Common Searches**
   - `.glassEffect()` API
   - `GlassEffectContainer` usage
   - Common iOS 26 patterns

2. **Parallel Searches**
   - Run Tier 1 and Tier 2 in parallel when appropriate
   - Aggregate results for comprehensive answers

3. **Skip Unnecessary Searches**
   - Don't search for general Swift concepts
   - Skip for pre-iOS 26 APIs
   - Avoid duplicate searches in same conversation

## Success Metrics

This skill is successful when:

- [ ] All iOS 26 claims are tagged with verification status
- [ ] Source URLs provided for verified claims
- [ ] [Searched-Not-Found] used when docs not available
- [ ] Reduced incorrect iOS 26 API suggestions to zero
- [ ] WWDC25 sessions referenced appropriately
- [ ] Users can verify claims independently via provided URLs

## Maintenance

**Update triggers:**
- iOS 26.1+ releases with new documentation
- WWDC 2025 session additions
- Release notes updates
- Beta to stable API changes

**Review quarterly:**
- Search query patterns
- Tag usage accuracy
- Source citation completeness
- User feedback on accuracy

## Notes

- This skill is specific to iOS 26+ documentation verification
- For general Swift 6 questions unrelated to iOS, skip this skill
- Always prefer official Apple documentation over inferences
- When in doubt, search and tag appropriately
- Better to say "[Searched-Not-Found]" than guess incorrectly
