---
name: worldcrafter-skill-selector
description: Meta-skill for selecting correct WorldCrafter skill. Use when unclear which skill to use, request maps to multiple skills, need to orchestrate skills, user asks for guidance, or ambiguous requests need clarification. Provides decision trees and trigger matching for feature-builder (complete features with forms), database-setup (tables/migrations/RLS), test-generator (add tests), route-creator (simple pages/APIs), auth-guard (authentication/authorization), ai-assistant (AI generation/suggestions/consistency), visualization (maps/timelines/graphs), and chatgpt-setup (MCP integration). Do NOT use when request clearly maps to one skill or trigger phrases clearly indicate specific skill.
---

# WorldCrafter Skill Selector

**Version:** 2.0.0
**Last Updated:** 2025-01-15

This meta-skill helps Claude select the correct WorldCrafter skill based on user requests and orchestrate multiple skills when needed.

## Skill Metadata

**Related Skills:**
- `worldcrafter-feature-builder` - Complete features with forms, validation, and database
- `worldcrafter-database-setup` - Database tables, migrations, and RLS policies
- `worldcrafter-test-generator` - Add tests to existing code
- `worldcrafter-route-creator` - Simple pages and API endpoints
- `worldcrafter-auth-guard` - Authentication and authorization

**Example Use Cases:**
- "I want to add a blog" → Recommends feature-builder (which will call database-setup if needed)
- "Add an about page" → Recommends route-creator
- "Protect the dashboard" → Recommends auth-guard

## Skill Selection Decision Tree

### Primary Decision: What is the user trying to do?

```
User request analysis:
│
├─ Building a COMPLETE FEATURE with forms/validation?
│  → worldcrafter-feature-builder
│  Examples: "Create a blog", "Add comments feature", "Build user profiles"
│  Note: Feature-builder will call database-setup if needed
│
├─ Working with DATABASE ONLY (no UI yet)?
│  → worldcrafter-database-setup
│  Examples: "Create a table for X", "Add RLS policies", "Set up database for..."
│  Note: Use this FIRST before building UI
│
├─ Adding TESTS to existing code?
│  → worldcrafter-test-generator
│  Examples: "Add tests for X", "Improve coverage", "Test the auth flow"
│  Note: Feature-builder includes basic tests, use this for additional coverage
│
├─ Creating SIMPLE PAGES without forms?
│  → worldcrafter-route-creator
│  Examples: "Add an about page", "Create API endpoint", "Add a layout"
│  Note: For pages WITH forms, use feature-builder instead
│
├─ Adding AUTHENTICATION or protecting routes?
│  → worldcrafter-auth-guard
│  Examples: "Protect the dashboard", "Add login", "Require authentication"
│  Note: Can be used during or after feature creation
│
├─ Using AI for GENERATION, SUGGESTIONS, or CONSISTENCY CHECKS?
│  → worldcrafter-ai-assistant
│  Examples: "Generate character with AI", "Suggest relationships", "Check for inconsistencies"
│  Keywords: AI, generate, suggest, consistency, prompts, ideas, brainstorm
│
├─ Creating VISUALIZATIONS (maps, timelines, graphs)?
│  → worldcrafter-visualization
│  Examples: "Upload world map", "Show timeline", "Visualize hierarchy", "Display analytics"
│  Keywords: map, timeline, graph, chart, tree, hierarchy, visualization, analytics
│
└─ Setting up CHATGPT INTEGRATION or MCP server?
   → worldcrafter-chatgpt-setup
   Examples: "Set up ChatGPT", "Create MCP server", "Enable conversational worldbuilding"
   Keywords: ChatGPT, MCP, OAuth, conversational, integration
```

## Trigger Phrase Mapping

### worldcrafter-feature-builder Triggers

**Strong indicators:**
- "Create a [feature]"
- "Build a [feature]"
- "Add a [feature] feature"
- "I want to add [feature] to the app"
- "Implement [feature] with forms/validation"

**Weak indicators (ask for clarification):**
- "Add [X]" - Could be page, feature, or database
- "Create [X]" - Could be page or feature

**Keywords:**
- feature, form, submit, validation, CRUD, create/update/delete

### worldcrafter-database-setup Triggers

**Strong indicators:**
- "Create a table for..."
- "Add a [Model] model"
- "Set up database for..."
- "I need to store [data]"
- "Add RLS policies"
- "Create a migration"

**Keywords:**
- table, model, database, schema, migration, RLS, Prisma

### worldcrafter-test-generator Triggers

**Strong indicators:**
- "Add tests for..."
- "Test the [feature]"
- "Improve coverage"
- "Write tests for..."
- "Generate tests"

**Keywords:**
- test, coverage, spec, E2E, integration test, unit test

### worldcrafter-route-creator Triggers

**Strong indicators:**
- "Create a page for..." (simple, no forms)
- "Add an about/contact/terms page"
- "Create an API endpoint"
- "Add a layout"

**Weak indicators (ask for clarification):**
- "Create a page" - Could be simple page or feature

**Keywords:**
- page, route, API endpoint, layout, static content

### worldcrafter-auth-guard Triggers

**Strong indicators:**
- "Protect the [route]"
- "Add authentication"
- "Require login"
- "Make [X] require auth"
- "Implement login/logout"
- "Add role-based access"

**Keywords:**
- protect, auth, authentication, login, logout, permission, role, RBAC

### worldcrafter-ai-assistant Triggers

**Strong indicators:**
- "Generate [entity] with AI"
- "Suggest relationships for..."
- "Check for inconsistencies in..."
- "Get writing prompts for..."
- "AI-generate [characters/locations/events]"
- "Brainstorm ideas for..."
- "What would make sense for..."
- "Help me expand on..."

**Weak indicators (ask for clarification):**
- "Generate [X]" - Could be AI or manual creation
- "Suggest [X]" - Could be AI-powered or manual

**Keywords:**
- AI, generate, suggest, consistency, inconsistency, prompts, ideas, brainstorm
- creative, expand, develop, what if, possibilities, options

### worldcrafter-visualization Triggers

**Strong indicators:**
- "Upload world map"
- "Show timeline of..."
- "Visualize [hierarchy/graph/tree]"
- "Display analytics for..."
- "Create a [map/timeline/chart/graph]"
- "Plot [events/locations] on..."
- "Show relationship graph for..."
- "Generate visualization of..."

**Weak indicators (ask for clarification):**
- "Show [X]" - Could be visualization or simple display
- "Display [X]" - Could be chart or text

**Keywords:**
- map, timeline, graph, chart, tree, hierarchy, visualization, analytics
- plot, spatial, temporal, network, relationships, connections
- dashboard, metrics, statistics

### worldcrafter-chatgpt-setup Triggers

**Strong indicators:**
- "Set up ChatGPT integration"
- "Create MCP server for..."
- "Enable conversational worldbuilding"
- "Connect to ChatGPT"
- "Add ChatGPT support"
- "Implement MCP protocol"
- "OAuth for ChatGPT"

**Keywords:**
- ChatGPT, MCP, OAuth, conversational, integration, protocol
- chat interface, natural language, dialogue

## Ambiguous Request Handling

### "Add a contact form"

**Analysis:**
- "form" keyword → Likely feature-builder
- But could be interpreted as simple page by some users

**Recommendation:**
→ Use **worldcrafter-feature-builder**
- Forms need validation and Server Actions
- Route-creator is for pages WITHOUT forms

### "Create a blog"

**Analysis:**
- Ambiguous: Could mean feature, database, or pages
- Context: "Create a blog" typically means complete feature

**Recommendation:**
→ Use **worldcrafter-feature-builder**
- Implies complete functionality
- Feature-builder will orchestrate database-setup if needed

### "Add an about page"

**Analysis:**
- "page" keyword → Could be feature-builder or route-creator
- Context: About pages are typically static

**Recommendation:**
→ Use **worldcrafter-route-creator**
- Simple static content
- No forms or complex logic needed

### "Set up user profiles"

**Analysis:**
- Ambiguous: Could be database-only or complete feature

**Recommendation:**
→ Ask user for clarification:
- "Do you want just the database table, or the complete profile editing feature?"
- If database only → worldcrafter-database-setup
- If complete feature → worldcrafter-feature-builder

### "Add authentication"

**Analysis:**
- Clear intent but could apply to new or existing code

**Recommendation:**
→ Ask user for context:
- "Are you adding auth to existing features, or building new auth flows?"
- If protecting existing → worldcrafter-auth-guard
- If building from scratch → Feature-builder can include auth

### "Generate character ideas"

**Analysis:**
- "generate" keyword → Could be AI-assisted or manual creation
- Context: User likely wants AI help for creative ideas

**Recommendation:**
→ Use **worldcrafter-ai-assistant**
- AI excels at creative generation
- Can suggest relationships, traits, backstories
- If user wants to store characters afterward → database-setup

### "Show me my world timeline"

**Analysis:**
- "show" + "timeline" → Clearly visualization
- User wants visual representation

**Recommendation:**
→ Use **worldcrafter-visualization**
- Timeline visualization is core feature
- Can integrate with existing world data
- If timeline data doesn't exist → may need database-setup first

### "Set up conversational interface"

**Analysis:**
- Ambiguous: Could mean chat UI or ChatGPT integration
- "conversational" suggests MCP integration

**Recommendation:**
→ Ask user for clarification:
- "Do you want a chat UI in your app, or ChatGPT/MCP integration?"
- If chat UI → feature-builder (build chat feature)
- If ChatGPT/MCP → chatgpt-setup

## Multi-Skill Orchestration Patterns

### Pattern: Complete Feature from Scratch

**User request:** "Build a blog post system where users can create and edit posts"

**Analysis:**
- Complete feature needed
- Authentication implied ("users can create")
- Database needed for posts

**Orchestration:**
1. worldcrafter-database-setup (create BlogPost model, RLS policies)
2. worldcrafter-feature-builder (create forms, Server Actions, tests)
3. worldcrafter-auth-guard (add auth checks, protect routes)

**Note:** Feature-builder might call database-setup automatically

### Pattern: Simple Page

**User request:** "Create an about us page"

**Analysis:**
- Simple static page
- No database or forms needed

**Orchestration:**
1. worldcrafter-route-creator only

### Pattern: Protect Existing Feature

**User request:** "Protect the dashboard so only logged-in users can access it"

**Analysis:**
- Dashboard already exists
- Adding auth to existing code

**Orchestration:**
1. worldcrafter-auth-guard only

### Pattern: Database-First Development

**User request:** "Set up database tables for storing blog posts, then I'll build the UI later"

**Analysis:**
- User explicitly wants database first
- UI comes later

**Orchestration:**
1. worldcrafter-database-setup now
2. worldcrafter-feature-builder later (when user is ready for UI)

### Pattern: Improve Test Coverage

**User request:** "The blog feature works but coverage is only 60%"

**Analysis:**
- Feature already exists
- Need to add tests

**Orchestration:**
1. worldcrafter-test-generator only

### Pattern: AI-Assisted World Creation

**User request:** "Generate a fantasy kingdom with AI, then let me visualize it on a map"

**Analysis:**
- AI generation needed first
- Visualization follows
- May need database to store generated data

**Orchestration:**
1. worldcrafter-ai-assistant (generate kingdom data)
2. worldcrafter-database-setup (store generated entities if needed)
3. worldcrafter-visualization (display on map)

### Pattern: Analytics Dashboard

**User request:** "Show me analytics about my world with charts and graphs"

**Analysis:**
- User wants visual analytics
- May need to aggregate data from database
- Visualization is primary goal

**Orchestration:**
1. worldcrafter-visualization (create analytics dashboard)
2. Optional: worldcrafter-database-setup if custom analytics tables needed

### Pattern: Conversational Worldbuilding Setup

**User request:** "Set up ChatGPT so I can build my world conversationally"

**Analysis:**
- MCP server integration needed
- OAuth authentication required
- May want AI assistance features afterward

**Orchestration:**
1. worldcrafter-chatgpt-setup (MCP server, OAuth)
2. Optional: worldcrafter-ai-assistant for prompts/consistency checking

### Pattern: Complete World Visualization

**User request:** "I have character data. Generate relationships with AI and show them in a graph"

**Analysis:**
- Existing data in database
- AI to suggest/expand relationships
- Visualization to display

**Orchestration:**
1. worldcrafter-ai-assistant (suggest relationships)
2. worldcrafter-database-setup (store new relationships if needed)
3. worldcrafter-visualization (relationship graph)

### Pattern: Interactive Timeline with AI Suggestions

**User request:** "Show my world timeline and suggest missing historical events"

**Analysis:**
- Visualization for timeline
- AI for gap analysis and suggestions
- May need database updates

**Orchestration:**
1. worldcrafter-visualization (display existing timeline)
2. worldcrafter-ai-assistant (analyze gaps, suggest events)
3. Optional: worldcrafter-database-setup (add suggested events)

## Common Mistakes to Avoid

### Mistake 1: Using Route-Creator for Forms

```
❌ Wrong:
User: "Create a contact form"
Claude: Uses route-creator

✅ Correct:
User: "Create a contact form"
Claude: Uses feature-builder (forms need validation)
```

### Mistake 2: Using Feature-Builder for Static Pages

```
❌ Wrong:
User: "Add an about page"
Claude: Uses feature-builder (over-engineering)

✅ Correct:
User: "Add an about page"
Claude: Uses route-creator (simple page)
```

### Mistake 3: Using Test-Generator After Feature-Builder

```
❌ Wrong:
User: "Build a blog feature"
Claude: Uses feature-builder, then test-generator

✅ Correct:
User: "Build a blog feature"
Claude: Uses feature-builder only (already includes tests)

Only use test-generator if user requests additional coverage
```

### Mistake 4: Not Using Database-Setup First

```
❌ Wrong:
User: "Build a blog feature"
Claude: Uses feature-builder, realizes database is needed, goes back

✅ Correct:
User: "Build a blog feature"
Claude: Uses database-setup first, then feature-builder
```

### Mistake 5: Using AI-Assistant for Manual Creation

```
❌ Wrong:
User: "Create a character named John"
Claude: Uses ai-assistant (user wants manual creation)

✅ Correct:
User: "Create a character named John"
Claude: Uses feature-builder or database-setup (manual input)

User: "Generate character ideas with AI"
Claude: Uses ai-assistant (AI generation)
```

### Mistake 6: Using Visualization for Static Display

```
❌ Wrong:
User: "Show me a list of my characters"
Claude: Uses visualization (over-engineering)

✅ Correct:
User: "Show me a list of my characters"
Claude: Uses route-creator (simple list page)

User: "Show character relationships in a graph"
Claude: Uses visualization (actual visualization needed)
```

### Mistake 7: Using Feature-Builder for MCP Setup

```
❌ Wrong:
User: "Set up ChatGPT integration"
Claude: Uses feature-builder (builds chat UI instead of MCP)

✅ Correct:
User: "Set up ChatGPT integration"
Claude: Uses chatgpt-setup (MCP server configuration)
```

## Clarifying Questions

When user intent is unclear, ask these questions:

**For "Add a [X] page":**
- "Do you need a form on this page, or just static content?"
- If form → feature-builder
- If static → route-creator

**For "Create a [X]":**
- "Do you want the complete feature with forms and validation, or just the database table?"
- If complete → feature-builder
- If database only → database-setup

**For "Set up [X]":**
- "Do you want to set up the database, the UI, or both?"
- Database only → database-setup
- UI only → route-creator or feature-builder
- Both → database-setup then feature-builder

**For "Add authentication":**
- "Are you adding auth to existing features, or building new auth flows?"
- Existing features → auth-guard
- New flows → feature-builder with auth

**For "Generate [X]":**
- "Do you want AI-assisted generation, or manual creation with forms?"
- AI-assisted → ai-assistant
- Manual creation → feature-builder or database-setup

**For "Show [X]":**
- "Do you need a visualization (map/timeline/graph), or a simple list/display?"
- Visualization → visualization
- Simple display → route-creator

**For "Set up ChatGPT" or "conversational":**
- "Do you want ChatGPT/MCP integration, or a chat UI feature in your app?"
- MCP integration → chatgpt-setup
- Chat UI feature → feature-builder

**For "Timeline" or "Map":**
- "Do you need to visualize existing data, or create the timeline/map data first?"
- Visualize existing → visualization
- Create data first → database-setup, then visualization

**For "Suggest" or "Ideas":**
- "Do you want AI suggestions, or just a form to manually add ideas?"
- AI suggestions → ai-assistant
- Manual form → feature-builder

## Reference Files

- `references/skill-decision-matrix.md` - Comprehensive decision matrix for all scenarios
- `references/orchestration-patterns.md` - Detailed multi-skill workflows
- `references/trigger-phrases.md` - Complete list of trigger phrases for each skill

## Success Criteria

Correct skill selection includes:
- ✅ User intent correctly identified
- ✅ Appropriate skill(s) chosen
- ✅ Multiple skills orchestrated in correct order
- ✅ Ambiguities clarified with user
- ✅ Common mistakes avoided
- ✅ Efficient workflow (no redundant skill usage)
