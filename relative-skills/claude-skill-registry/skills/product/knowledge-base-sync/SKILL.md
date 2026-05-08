---
name: knowledge-base-sync
description: Automatically detect when features change and remind to update the feedback assistant knowledge base. CRITICAL for keeping the AI assistant accurate and preventing user frustration from outdated information.
---

# Knowledge Base Sync Skill

**CRITICAL IMPORTANCE:** The feedback assistant (`/feedback`) only knows what's documented in `src/lib/feedback/knowledge-base.ts`. If you add or change features without updating this file, the AI will give incorrect or incomplete information to users.

---

## When This Skill Activates

This skill monitors for changes that affect user-facing features:

1. **New page routes** - Creating files in `src/app/[feature]/page.tsx`
2. **New API endpoints** - Adding routes in `src/app/api/`
3. **Changed server actions** - Modifying files in `src/lib/actions/`
4. **New capabilities** - Adding features to existing domains
5. **Status changes** - Modifying workflow states or enums

---

## The Knowledge Base Structure

Located at: `src/lib/feedback/knowledge-base.ts`

```typescript
export const FOSSAPP_KNOWLEDGE: KnowledgeBase = {
  appName: 'FOSSAPP',
  appDescription: '...',
  lastUpdated: '2025-12-31',  // ← UPDATE THIS!

  features: {
    featureName: {
      name: 'Feature Display Name',
      description: 'One-sentence summary',
      capabilities: [
        'What users can do',
        'Main features',
      ],
      limitations: [
        'What users cannot do',
        'Known constraints',
      ],
      howTo: {
        'actionName': 'Step-by-step instructions',
      },
      statuses: {
        'statusCode': 'What this status means',
      },
    },
  },

  commonQuestions: {
    'How do I...?': 'Answer with specifics',
  },
}
```

---

## Current Features in Knowledge Base

As of 2025-12-28, these features are documented:

1. **products** - Product search and browsing
2. **projects** - Project management with areas and phases
3. **projectProducts** - Products added to project areas
4. **tiles** - DWG tile generation
5. **symbols** - Symbol generation from screenshots
6. **planner** - Floor plan viewer with symbol placement
7. **playground** - DWG manipulation environment
8. **filters** - Dynamic faceted search

**Total:** 8 features

---

## Update Patterns by Change Type

### Pattern 1: New Feature (New Page)

**Trigger:** Created `src/app/new-feature/page.tsx`

**Action Required:**
```typescript
// Add to features object in knowledge-base.ts
newFeature: {
  name: 'New Feature',
  description: 'What this feature does in one sentence',
  capabilities: [
    'List what users can do',
    'Focus on value, not implementation',
  ],
  limitations: [
    'What they cannot do (if any)',
  ],
  howTo: {
    'commonTask': 'Navigate to... → Click... → Enter...',
  },
},
```

**Example:**
```typescript
// Adding the "Reports" feature
reports: {
  name: 'Reports',
  description: 'Generate PDF reports for projects with product lists and specifications',
  capabilities: [
    'Generate project summary reports',
    'Export product specifications to PDF',
    'Include pricing and availability data',
    'Send reports via email',
  ],
  limitations: [
    'Reports are generated asynchronously (may take 30-60 seconds)',
    'Maximum 1000 products per report',
  ],
  howTo: {
    'generateReport': 'Navigate to Projects → Select project → Reports tab → Click "Generate Report"',
    'emailReport': 'After generation, click "Email" and enter recipient address',
  },
},
```

---

### Pattern 2: New Capability (Modified Server Actions)

**Trigger:** Added new action in `src/lib/actions/projects.ts`

**Action Required:**
```typescript
// Find the relevant feature and ADD to capabilities array
projects: {
  name: 'Projects',
  // ... existing fields
  capabilities: [
    'Existing capability 1',
    'Existing capability 2',
    'NEW: Your new capability',  // ← ADD THIS
  ],
  howTo: {
    // ... existing howTo
    'newAction': 'How to use the new capability',  // ← ADD THIS
  },
},
```

**Example:**
```typescript
// Added project archiving capability
projects: {
  name: 'Projects',
  capabilities: [
    'Create and manage projects with customer association',
    'Organize projects into phases and areas',
    'Archive completed projects',  // ← NEW
  ],
  howTo: {
    // ... existing
    'archiveProject': 'Open project → Click menu (⋮) → Select "Archive"',  // ← NEW
  },
},
```

---

### Pattern 3: New Status/Enum

**Trigger:** Added new status to project workflow

**Action Required:**
```typescript
// Add to statuses object
projects: {
  // ... existing fields
  statuses: {
    'draft': 'Initial project state, still being set up',
    'quotation': 'Project is in quotation phase',
    'approved': 'Project has been approved by client',
    'archived': 'Project is archived and read-only',  // ← NEW
  },
},
```

---

### Pattern 4: Changed Behavior

**Trigger:** Modified how a feature works (e.g., changed from synchronous to async)

**Action Required:**
```typescript
// Update description and/or add limitation
tiles: {
  name: 'Tiles',
  description: 'Generate DWG tiles from product selections with background processing',  // ← UPDATED
  capabilities: [
    'Create tile layouts from product placements',
    'Monitor generation progress in real-time',  // ← UPDATED
  ],
  limitations: [
    'Generation is asynchronous (30-120 seconds)',  // ← ADDED
    'Maximum 20 products per tile',
  ],
},
```

---

## Update Checklist

Before committing feature changes, verify:

- [ ] **Feature exists in knowledge base** (if new page/domain)
- [ ] **Capabilities are current** (new actions added)
- [ ] **Limitations are accurate** (constraints documented)
- [ ] **howTo guides exist** (for main user flows)
- [ ] **Statuses are complete** (all workflow states listed)
- [ ] **lastUpdated date changed** (update the timestamp)
- [ ] **Test the feedback assistant** (ask it about your feature)

---

## Testing the Knowledge Base

After updating, verify the feedback assistant knows about changes:

1. Open the feedback panel (bottom-right chat icon)
2. Ask: "How do I [use the new feature]?"
3. Verify the AI gives accurate information
4. If response is wrong, check knowledge base entry

**Common issues:**
- ❌ AI says "I don't have information about that" → Feature not in knowledge base
- ❌ AI gives outdated steps → howTo needs updating
- ❌ AI doesn't mention new capability → Not added to capabilities array

---

## Common Mistakes

### ❌ Mistake 1: Forgetting to Update
```typescript
// You added a new "Export to Excel" feature
// But forgot to update knowledge-base.ts

User: "Can I export projects to Excel?"
AI: "I don't have information about Excel export capabilities."
// ← USER FRUSTRATED!
```

**Fix:** Always update knowledge base when adding features.

---

### ❌ Mistake 2: Vague Capabilities
```typescript
capabilities: [
  'Manage products',  // ❌ TOO VAGUE
]

// Better:
capabilities: [
  'Search products by keyword, supplier, or ETIM class',
  'Filter products by specifications (IP rating, CCT, power)',
  'View detailed product specifications and datasheets',
  'Add products to project areas with quantities',
]
```

**Fix:** Be specific about what users can actually do.

---

### ❌ Mistake 3: Missing howTo
```typescript
// You added a complex workflow but no instructions

User: "How do I generate a tile?"
AI: "I know tiles exist but I don't have detailed instructions on how to generate them."
// ← USER CONFUSED!
```

**Fix:** Add howTo for any non-obvious workflows.

---

### ❌ Mistake 4: Stale Information
```typescript
// Old entry (no longer accurate)
tiles: {
  capabilities: [
    'Generate tiles synchronously',  // ❌ WRONG NOW
  ],
}

// Feature changed to async but knowledge base wasn't updated
```

**Fix:** Review knowledge base when changing feature behavior.

---

## Quick Reference: When to Update

| Change | Update Required | Example |
|--------|----------------|---------|
| New page route | Add feature object | `/reports` page → add `reports: {...}` |
| New API endpoint | Add to capabilities | `/api/export` → add to `projects.capabilities` |
| New server action | Add to capabilities + howTo | `archiveProject()` → add archive instructions |
| Changed workflow | Update description/limitations | Sync → async, add timing limitation |
| New status | Add to statuses | `archived` → add status definition |
| Removed feature | Remove from knowledge base | Deprecated `/old-feature` → remove entry |
| Bug fix | Usually no update needed | Unless behavior changed significantly |

---

## Example: Full Feature Addition

Let's say you just implemented a "Favorites" feature:

```typescript
// NEW FILE: src/app/favorites/page.tsx
// NEW FILE: src/lib/actions/favorites.ts
// NEW API: src/app/api/favorites/route.ts

// KNOWLEDGE BASE UPDATE REQUIRED:

favorites: {
  name: 'Favorites',
  description: 'Save and organize your favorite products for quick access',
  capabilities: [
    'Mark products as favorites from any product card',
    'View all favorites in one place',
    'Organize favorites into custom lists',
    'Share favorite lists with team members',
    'Add favorites directly to project areas',
  ],
  limitations: [
    'Maximum 500 favorites per user',
    'Shared lists are read-only for recipients',
  ],
  howTo: {
    'addFavorite': 'Click the star icon on any product card',
    'viewFavorites': 'Navigate to Favorites from the main menu',
    'createList': 'Go to Favorites → Click "New List" → Name your list',
    'shareList': 'Open a list → Click share icon → Enter email addresses',
  },
},

// ALSO UPDATE:
commonQuestions: {
  'Can I save products for later?': 'Yes! Use the Favorites feature to bookmark products. Click the star icon on any product card.',
  'How do I organize my favorite products?': 'Create custom lists in the Favorites section. You can organize by project, product type, or any way that makes sense to you.',
},

// DON'T FORGET:
lastUpdated: '2025-12-31',  // ← Update this!
```

---

## Integration with Development Workflow

### During Development
1. **Feature branch created** → Note: will need KB update
2. **Feature implemented** → Draft KB entry
3. **Testing feature** → Test with KB entry in place
4. **Code review** → Reviewer checks KB update

### Before Merge
1. **Update knowledge-base.ts** → Add/modify feature entry
2. **Update lastUpdated date** → Current date
3. **Test feedback assistant** → Ask questions about feature
4. **Document in PR** → "Updated knowledge base for [feature]"

### After Deploy
1. **Monitor feedback** → Check if users ask AI about feature
2. **Refine entries** → Based on actual user questions
3. **Iterate** → Knowledge base is living document

---

## Pro Tips

### Tip 1: Write for Users, Not Developers
```typescript
// ❌ Developer perspective
capabilities: [
  'Execute RPC function for supplier aggregation',
]

// ✅ User perspective
capabilities: [
  'View product counts grouped by supplier',
]
```

---

### Tip 2: Anticipate Questions
Think about what users will ask:
- "How do I...?"
- "Can I...?"
- "What does [status] mean?"
- "Why can't I...?"

Add these to `commonQuestions` or `howTo`.

---

### Tip 3: Use Real Product Names
```typescript
// ❌ Generic
'Search for items in the database'

// ✅ Specific
'Search 56,000+ lighting products from Delta Light, Modular, and other suppliers'
```

---

### Tip 4: Document Limitations Proactively
If you know a feature has constraints, document them:
```typescript
limitations: [
  'Maximum 1000 products per project area',
  'Project names must be unique per customer',
  'Cannot delete areas with products (remove products first)',
]
```

This prevents users from hitting walls and getting frustrated.

---

## Related Documentation

- **Full documentation:** `docs/features/feedback-assistant.md`
- **Agent tool system:** `src/lib/feedback/agent.ts`
- **Knowledge base types:** `src/lib/feedback/knowledge-base.ts`

---

## Summary

**REMEMBER:** The feedback assistant is only as good as its knowledge base. If you add or change features without updating `knowledge-base.ts`, users will get wrong or incomplete information.

**Make it a habit:**
1. Implement feature
2. Update knowledge base
3. Test feedback assistant
4. Commit both together

**Last updated:** 2025-12-31
