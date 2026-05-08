---
name: generate-feature-spec
description: Generates features_spec.txt files for use with auto-code extension mode. Analyzes existing codebase and creates structured feature specifications based on user requirements.
allowed-tools: Read, Glob, Grep, Bash(find:*), Bash(tree:*), Bash(ls:*), Write, AskUserQuestion
---

# Generate Feature Specification

Create `features_spec.txt` files for use with the `auto-code` package in extension mode. This skill analyzes an existing codebase and generates a structured XML specification of features to implement.

## When to Use

- Before running `auto-code extend ./features_spec.txt`
- When you want precise control over which features to add
- When extending an existing TypeScript/JavaScript project
- When you have specific requirements and don't want agent-generated recommendations

## Output Format

Generate XML with a `<feature>` element for each feature:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<features_spec version="1.0">
  <metadata>
    <project>Project Name</project>
    <generated_date>2026-01-05</generated_date>
    <source>Manual specification</source>
    <base_branch>development</base_branch>
  </metadata>

  <feature id="feature-1">
    <title>Feature Name</title>
    <type>new-feature</type>
    <priority>normal</priority>

    <description>
      Description of what this feature should do.
      Any additional context, requirements, or acceptance criteria.
    </description>

    <affected_files>
      <file path="src/components/Example.tsx">
        <issues>- Add new component logic here</issues>
      </file>
    </affected_files>

    <implementation_steps>
      <step order="1">First implementation step</step>
      <step order="2">Second implementation step</step>
    </implementation_steps>

    <acceptance_criteria>
      <criterion>Feature works as expected</criterion>
    </acceptance_criteria>

    <testing>
      <test type="manual">Verify feature works in browser</test>
    </testing>
  </feature>
</features_spec>
```

## Workflow

### Step 1: Analyze Existing Codebase

First, understand the current project:

```bash
# Check project type and dependencies
cat package.json 2>/dev/null || cat pyproject.toml 2>/dev/null

# Get directory structure
find . -type f -name "*.ts" -o -name "*.tsx" | head -30

# Check for existing app_spec.txt
cat app_spec.txt 2>/dev/null
```

Document:
- Technology stack (React, Next.js, Express, etc.)
- Existing features and components
- Code patterns and conventions
- Database schema if applicable

### Step 2: Gather Requirements

Ask the user what features they want to add:

1. **If app_spec.txt exists**: Reference it and ask which features from the spec should be implemented
2. **If no app_spec.txt**: Ask the user to describe the features they want

Use `AskUserQuestion` to clarify:
- Feature priorities
- Specific requirements or constraints
- Integration points with existing code
- Any technical preferences

### Step 3: Generate features_spec.txt

Create the file with:
- One `<feature>` element per feature
- Clear, actionable descriptions
- Relevant technical context
- Affected files with specific issues/changes needed
- Implementation steps
- Acceptance criteria

### Step 4: Review with User

Present the generated spec and ask if any adjustments are needed before finalizing.

## XML Schema Reference

### Root Element

```xml
<features_spec version="1.0">
```

### Metadata Section

```xml
<metadata>
  <project>Project Name</project>
  <generated_date>YYYY-MM-DD</generated_date>
  <source>Where features came from (Linear, manual, etc.)</source>
  <base_branch>development</base_branch>
</metadata>
```

### Feature Element

| Element | Required | Description |
|---------|----------|-------------|
| `id` | Yes | Unique identifier (e.g., "PROJ-123", "feature-1") |
| `title` | Yes | Human-readable title |
| `type` | Yes | bug-fix, ui-enhancement, improvement, new-feature |
| `priority` | No | low, normal, high, urgent (default: normal) |
| `labels` | No | Comma-separated labels |
| `linear_url` | No | Link to issue tracker |
| `branch` | No | Pre-created branch name |
| `description` | Yes | Detailed description |
| `affected_files` | No | Files to modify with issues |
| `implementation_steps` | No | Ordered steps |
| `acceptance_criteria` | No | What "done" looks like |
| `testing` | No | How to verify the feature |

### Feature Types

- **bug-fix**: Fixing broken functionality
- **ui-enhancement**: Visual/UX improvements
- **improvement**: Enhancing existing features
- **new-feature**: Adding new functionality

## Quality Guidelines

- **Be specific**: Include file paths, line numbers where possible
- **Be realistic**: Each feature should be implementable in 1-3 sessions
- **Be ordered**: Put foundational features first, dependent features after
- **Reference existing code**: Use `<affected_files>` to point to specific locations
- **Include acceptance criteria**: What does "done" look like for each feature?
- **Add testing steps**: How should the agent verify the implementation?

## Example Output

```xml
<?xml version="1.0" encoding="UTF-8"?>
<features_spec version="1.0">
  <metadata>
    <project>My Portal App</project>
    <generated_date>2026-01-05</generated_date>
    <source>Manual specification</source>
    <base_branch>development</base_branch>
  </metadata>

  <feature id="auth-001">
    <title>User Authentication</title>
    <type>new-feature</type>
    <priority>high</priority>

    <description>
      Add login and logout functionality using NextAuth.js.
      Support email/password authentication with secure session handling.
    </description>

    <affected_files>
      <file path="src/pages/api/auth/[...nextauth].ts">
        <issues>- Create NextAuth configuration</issues>
      </file>
      <file path="src/pages/login.tsx">
        <issues>- Create login page matching existing UI style</issues>
      </file>
      <file path="src/middleware.ts">
        <issues>- Add protected route middleware</issues>
      </file>
    </affected_files>

    <implementation_steps>
      <step order="1">Install next-auth and configure providers</step>
      <step order="2">Create login and signup pages</step>
      <step order="3">Add session provider to _app.tsx</step>
      <step order="4">Implement protected route middleware</step>
      <step order="5">Add user context to navigation</step>
    </implementation_steps>

    <acceptance_criteria>
      <criterion>Users can sign up with email/password</criterion>
      <criterion>Users can log in and log out</criterion>
      <criterion>Protected routes redirect to login</criterion>
      <criterion>Session persists across page refreshes</criterion>
    </acceptance_criteria>

    <testing>
      <test type="manual">Complete signup and login flow</test>
      <test type="manual">Verify protected routes redirect</test>
      <test type="manual">Verify logout clears session</test>
    </testing>
  </feature>

  <feature id="dashboard-001">
    <title>Dashboard Analytics Widget</title>
    <type>new-feature</type>
    <priority>normal</priority>

    <description>
      Add a new widget to the dashboard showing user activity metrics.
      Follow existing widget pattern and use recharts for visualization.
    </description>

    <affected_files>
      <file path="src/components/widgets/AnalyticsWidget.tsx">
        <issues>- Create new widget component</issues>
      </file>
      <file path="src/pages/api/analytics.ts">
        <issues>- Create API endpoint for metrics</issues>
      </file>
      <file path="src/pages/dashboard.tsx">
        <issues>- Add widget to dashboard grid</issues>
      </file>
    </affected_files>

    <implementation_steps>
      <step order="1">Create /api/analytics endpoint</step>
      <step order="2">Create AnalyticsWidget following existing pattern</step>
      <step order="3">Add recharts line/bar chart</step>
      <step order="4">Add loading and error states</step>
      <step order="5">Integrate into dashboard</step>
    </implementation_steps>

    <acceptance_criteria>
      <criterion>Widget displays activity metrics</criterion>
      <criterion>Chart renders correctly with data</criterion>
      <criterion>Loading state shows skeleton</criterion>
      <criterion>Error state shows retry button</criterion>
    </acceptance_criteria>

    <testing>
      <test type="manual">View dashboard with analytics widget</test>
      <test type="manual">Verify chart updates with new data</test>
    </testing>
  </feature>

  <feature id="export-001">
    <title>Export to CSV</title>
    <type>improvement</type>
    <priority>low</priority>

    <description>
      Allow users to export their data to CSV format.
      Support filtering before export and handle large datasets with streaming.
    </description>

    <affected_files>
      <file path="src/components/DataTable.tsx">
        <issues>- Add export button to table header</issues>
      </file>
      <file path="src/lib/export.ts">
        <issues>- Create CSV generation utility</issues>
      </file>
    </affected_files>

    <implementation_steps>
      <step order="1">Create CSV generation utility</step>
      <step order="2">Add export button to DataTable component</step>
      <step order="3">Implement streaming for large datasets</step>
      <step order="4">Add progress indicator</step>
    </implementation_steps>

    <acceptance_criteria>
      <criterion>Export button visible in data table</criterion>
      <criterion>CSV file downloads with current filter applied</criterion>
      <criterion>Large exports show progress</criterion>
    </acceptance_criteria>

    <testing>
      <test type="manual">Export small dataset</test>
      <test type="manual">Export with filters applied</test>
      <test type="integration">Test export with 10k+ rows</test>
    </testing>
  </feature>
</features_spec>
```

## Integration with auto-code

After generating `features_spec.txt`, the user can run:

```bash
auto-code extend ./features_spec.txt
```

Or if working from an app spec instead:

```bash
auto-code extend --app-spec ./app_spec.txt
```

The autonomous agent will:
1. Read `features_spec.txt`
2. Create one `feature_list.json` entry per `<feature>` element
3. Implement ONLY the features listed (no additional recommendations)
4. Use the provided context (affected_files, steps, criteria) to guide implementation

## Completion Message

When you finish generating the features_spec.txt file, show the user:

```
Done! I've generated features_spec.txt with [N] features.

The spec is ready to use:

  auto-code extend ./features_spec.txt
```

IMPORTANT: Do NOT use the old command format `autonomous-coding --mode extend --features-spec`. The correct command is `auto-code extend` (the package binary is `auto-code`, not `autonomous-coding`, and it uses subcommands, not `--mode` flags)
