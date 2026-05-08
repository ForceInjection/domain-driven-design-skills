---
name: generate-feature-spec
description: Generates features_spec.txt files for use with auto-code extension mode. Analyzes existing codebase and creates structured feature specifications based on user requirements.
allowed-tools: Read, Glob, Grep, Bash(find:*), Bash(tree:*), Bash(ls:*), Write, AskUserQuestion
---

# Generate Feature Specification

Create `features_spec.txt` files for use with the `auto-code` package in extension mode. This skill analyzes an existing codebase and generates a structured specification of features to implement.

## When to Use

- Before running `auto-code --mode extend --features-spec`
- When you want precise control over which features to add
- When extending an existing TypeScript/JavaScript project
- When you have specific requirements and don't want agent-generated recommendations

## Output Format

Generate markdown with `##` headers for each feature:

```markdown
## Feature Name
Description of what this feature should do.
Any additional context, requirements, or acceptance criteria.

## Another Feature
Description of this feature.
- Sub-requirement 1
- Sub-requirement 2
- Technical considerations

## Third Feature
Brief description with implementation hints.
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
- One `## Section` per feature
- Clear, actionable descriptions
- Relevant technical context
- Acceptance criteria where helpful

### Step 4: Review with User

Present the generated spec and ask if any adjustments are needed before finalizing.

## Quality Guidelines

- **Be specific**: Include enough detail for the agent to implement correctly
- **Be realistic**: Each feature should be implementable in 1-3 sessions
- **Be ordered**: Put foundational features first, dependent features after
- **Reference existing code**: Mention files or patterns to follow when relevant
- **Include acceptance criteria**: What does "done" look like for each feature?

## Example Output

```markdown
## User Authentication
Add login and logout functionality using NextAuth.js.
- Support email/password authentication
- Add protected route middleware
- Create login and signup pages matching existing UI style
- Store session in existing database

## Dashboard Analytics Widget
Add a new widget to the dashboard showing user activity metrics.
- Follow existing widget pattern in src/components/widgets/
- Fetch data from new /api/analytics endpoint
- Include charts using the existing recharts setup
- Add loading and error states

## Export to CSV
Allow users to export their data to CSV format.
- Add export button to data table component
- Support filtering before export
- Handle large datasets with streaming
```

## Integration with auto-code

After generating `features_spec.txt`, the user can run:

```bash
auto-code --spec ./app_spec.txt --mode extend --features-spec ./features_spec.txt
```

The autonomous agent will:
1. Read `features_spec.txt`
2. Create one `feature_list.json` entry per `## Section`
3. Implement ONLY the features listed (no additional recommendations)
