---
name: github-integration
description: Master GitHub integration using gh CLI, GitHub API, issue/PR management, GitHub Actions, sprint planning with Projects, and automated workflows. Essential for GitHub-based development automation.
triggers:
  - "github integration"
  - "gh cli"
  - "github api"
  - "github issue detection"
  - "github projects"
  - "github actions"
  - "github automation"
  - "parse github issue"
  - "github sprint planning"
---

# GitHub Integration Mastery

This skill provides comprehensive guidance for integrating with GitHub using the gh CLI, GitHub REST and GraphQL APIs, and GitHub Actions. Essential for automating issue management, PR workflows, sprint planning with GitHub Projects, and building robust GitHub-based development pipelines.

## When to Use This Skill

- Automating issue creation, updates, and transitions
- Building PR management workflows
- Parsing GitHub URLs and extracting metadata
- Integrating GitHub into development automation
- Sprint planning with GitHub Projects
- Creating GitHub Actions workflows
- Querying GitHub data programmatically

---

## GitHub CLI (gh) Mastery

The `gh` CLI is the primary tool for GitHub automation. It provides intuitive commands for all GitHub operations.

### Installation and Authentication

```bash
# Install gh CLI (macOS)
brew install gh

# Authenticate
gh auth login

# Verify authentication
gh auth status
```

### Issue Operations

**List issues with filters**:
```bash
# List open issues
gh issue list

# List by label
gh issue list --label bug --label high-priority

# List assigned to you
gh issue list --assignee @me

# List in specific state
gh issue list --state closed
```

**View issue details**:
```bash
# View issue 123
gh issue view 123

# View with comments
gh issue view 123 --comments

# View as JSON for programmatic access
gh issue view 123 --json number,title,body,labels,assignees
```

**Create issues**:
```bash
# Interactive creation
gh issue create

# With flags
gh issue create --title "Bug: Login fails" --body "Description here" --label bug

# From template
gh issue create --template bug_report.md
```

**Edit issues**:
```bash
# Add labels
gh issue edit 123 --add-label "in-progress"

# Assign
gh issue edit 123 --add-assignee username

# Set milestone
gh issue edit 123 --milestone "Sprint 24"

# Update title
gh issue edit 123 --title "Updated title"
```

**Close issues**:
```bash
# Close with comment
gh issue close 123 --comment "Fixed in PR #456"
```

### Pull Request Operations

**Create PR**:
```bash
# Interactive creation
gh pr create

# With details
gh pr create --title "feat: Add authentication" --body "Implementation details" --base main

# Draft PR
gh pr create --draft

# Auto-fill from commits
gh pr create --fill
```

**List and view PRs**:
```bash
# List open PRs
gh pr list

# List by author
gh pr list --author @me

# View PR details
gh pr view 456

# View PR diff
gh pr diff 456

# View PR checks
gh pr checks 456
```

**Review PRs**:
```bash
# Approve PR
gh pr review 456 --approve

# Request changes
gh pr review 456 --request-changes --body "Please fix the tests"

# Comment on PR
gh pr comment 456 --body "LGTM!"
```

**Merge PRs**:
```bash
# Merge with squash
gh pr merge 456 --squash

# Merge with rebase
gh pr merge 456 --rebase

# Auto-merge when checks pass
gh pr merge 456 --auto --squash
```

### GitHub Projects Integration

**List projects**:
```bash
# List organization projects
gh project list --owner org-name

# List user projects
gh project list --owner @me
```

**Add items to project**:
```bash
# Add issue to project
gh project item-add PROJECT_ID --owner org-name --url https://github.com/org/repo/issues/123

# Add PR to project
gh project item-add PROJECT_ID --owner org-name --url https://github.com/org/repo/pull/456
```

### Advanced CLI Patterns

**Aliases for common operations**:
```bash
# Create alias in ~/.config/gh/config.yml
gh alias set issues-ready 'issue list --label sprint-ready --json number,title'
gh alias set prs-mine 'pr list --author @me --json number,title,updatedAt'

# Use alias
gh issues-ready
```

**Output formatting**:
```bash
# JSON output for scripting
gh issue list --json number,title,labels

# Template formatting
gh pr list --json number,title --template '{{range .}}{{.number}}: {{.title}}{{"\n"}}{{end}}'
```

For complete shell script examples combining gh commands, see `examples/gh-cli-scripts.md`.

---

## GitHub API Patterns

### REST API Basics

**Authentication**:

```typescript
// Using Octokit
import { Octokit } from '@octokit/rest';

const octokit = new Octokit({
  auth: process.env.GITHUB_TOKEN
});
```

**Rate Limits**:

```typescript
// Check rate limit status
const { data: rateLimit } = await octokit.rateLimit.get();
console.log(`Remaining: ${rateLimit.rate.remaining}/${rateLimit.rate.limit}`);
console.log(`Resets at: ${new Date(rateLimit.rate.reset * 1000)}`);
```

### Common REST API Operations

**Issue Operations**:

```typescript
// Get issue
const { data: issue } = await octokit.issues.get({
  owner: 'org-name',
  repo: 'repo-name',
  issue_number: 123
});

// Create issue
const { data: newIssue } = await octokit.issues.create({
  owner: 'org-name',
  repo: 'repo-name',
  title: 'Bug: Login fails',
  body: 'Description of the issue',
  labels: ['bug', 'high-priority'],
  assignees: ['username']
});

// Update issue
await octokit.issues.update({
  owner: 'org-name',
  repo: 'repo-name',
  issue_number: 123,
  state: 'closed',
  labels: ['bug', 'fixed']
});

// Add comment
await octokit.issues.createComment({
  owner: 'org-name',
  repo: 'repo-name',
  issue_number: 123,
  body: 'This has been fixed in PR #456'
});
```

**PR Operations**:

```typescript
// Get PR
const { data: pr } = await octokit.pulls.get({
  owner: 'org-name',
  repo: 'repo-name',
  pull_number: 456
});

// List PR reviews
const { data: reviews } = await octokit.pulls.listReviews({
  owner: 'org-name',
  repo: 'repo-name',
  pull_number: 456
});

// Merge PR
await octokit.pulls.merge({
  owner: 'org-name',
  repo: 'repo-name',
  pull_number: 456,
  merge_method: 'squash',
  commit_title: 'feat: Add authentication',
  commit_message: 'Closes #123'
});
```

**Repository Operations**:

```typescript
// List repositories
const { data: repos } = await octokit.repos.listForOrg({
  org: 'org-name',
  type: 'all',
  sort: 'updated'
});

// Get repository details
const { data: repo } = await octokit.repos.get({
  owner: 'org-name',
  repo: 'repo-name'
});

// Create webhook
await octokit.repos.createWebhook({
  owner: 'org-name',
  repo: 'repo-name',
  config: {
    url: 'https://example.com/webhook',
    content_type: 'json'
  },
  events: ['issues', 'pull_request']
});
```

### GraphQL API

**When to Use GraphQL**:
- Fetching nested data (issue + comments + reactions)
- Reducing API calls (get multiple resources in one request)
- Custom field selection (only fetch what you need)
- Complex queries across repositories

**Basic GraphQL Query**:

```typescript
import { graphql } from '@octokit/graphql';

const graphqlWithAuth = graphql.defaults({
  headers: {
    authorization: `token ${process.env.GITHUB_TOKEN}`
  }
});

// Fetch issue with comments
const result = await graphqlWithAuth(`
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      issue(number: $number) {
        title
        body
        state
        labels(first: 10) {
          nodes {
            name
          }
        }
        comments(first: 50) {
          nodes {
            author {
              login
            }
            body
            createdAt
          }
        }
      }
    }
  }
`, {
  owner: 'org-name',
  repo: 'repo-name',
  number: 123
});
```

**Pagination with GraphQL**:

```typescript
// Fetch all issues with pagination
const issues = [];
let hasNextPage = true;
let cursor = null;

while (hasNextPage) {
  const result = await graphqlWithAuth(`
    query($owner: String!, $repo: String!, $cursor: String) {
      repository(owner: $owner, name: $repo) {
        issues(first: 100, after: $cursor, states: OPEN) {
          pageInfo {
            hasNextPage
            endCursor
          }
          nodes {
            number
            title
            state
          }
        }
      }
    }
  `, {
    owner: 'org-name',
    repo: 'repo-name',
    cursor
  });

  issues.push(...result.repository.issues.nodes);
  hasNextPage = result.repository.issues.pageInfo.hasNextPage;
  cursor = result.repository.issues.pageInfo.endCursor;
}
```

### API Best Practices

**Error Handling**:

```typescript
// ✅ GOOD: Handle rate limits and errors
async function safeApiCall<T>(apiCall: () => Promise<T>): Promise<T> {
  try {
    return await apiCall();
  } catch (error: any) {
    if (error.status === 403 && error.message.includes('rate limit')) {
      const resetTime = new Date(error.response.headers['x-ratelimit-reset'] * 1000);
      throw new Error(`Rate limit exceeded. Resets at ${resetTime}`);
    }

    if (error.status === 404) {
      throw new Error('Resource not found');
    }

    throw error;
  }
}

// Usage
const issue = await safeApiCall(() =>
  octokit.issues.get({ owner, repo, issue_number: 123 })
);
```

**Caching**:

```typescript
// ✅ GOOD: Cache repository metadata
const repoCache = new Map<string, any>();

async function getRepoWithCache(owner: string, repo: string) {
  const key = `${owner}/${repo}`;

  if (repoCache.has(key)) {
    return repoCache.get(key);
  }

  const { data } = await octokit.repos.get({ owner, repo });
  repoCache.set(key, data);

  return data;
}
```

For complete API usage examples, see `references/github-api-patterns.md`.

---

## Issue and PR Detection

### URL Pattern Detection

**Issue URL Patterns**:

```typescript
// GitHub issue URL patterns
const GITHUB_ISSUE_PATTERNS = [
  /https?:\/\/github\.com\/([^\/]+)\/([^\/]+)\/issues\/(\d+)/,
  /https?:\/\/github\.com\/([^\/]+)\/([^\/]+)\/pull\/(\d+)/,
];

function detectGitHubIssue(text: string): { owner: string; repo: string; number: number } | null {
  for (const pattern of GITHUB_ISSUE_PATTERNS) {
    const match = text.match(pattern);
    if (match) {
      return {
        owner: match[1],
        repo: match[2],
        number: parseInt(match[3], 10)
      };
    }
  }
  return null;
}

// Usage
const issue = detectGitHubIssue('Fix https://github.com/org/repo/issues/123');
// => { owner: 'org', repo: 'repo', number: 123 }
```

**Issue Number References**:

```typescript
// Detect issue references in text
const ISSUE_REF_PATTERN = /#(\d+)/g;

function extractIssueNumbers(text: string): number[] {
  const matches = text.matchAll(ISSUE_REF_PATTERN);
  return Array.from(matches, m => parseInt(m[1], 10));
}

// Usage
const numbers = extractIssueNumbers('Fixes #123 and closes #456');
// => [123, 456]
```

### Auto-linking Strategy

```typescript
// ✅ GOOD: Fetch issue details for auto-linking
async function enrichWithIssueData(text: string, owner: string, repo: string) {
  const numbers = extractIssueNumbers(text);
  const issues = await Promise.all(
    numbers.map(num => octokit.issues.get({ owner, repo, issue_number: num }))
  );

  let enriched = text;
  issues.forEach(({ data }, index) => {
    const num = numbers[index];
    enriched = enriched.replace(
      `#${num}`,
      `[#${num}](https://github.com/${owner}/${repo}/issues/${num}) (${data.title})`
    );
  });

  return enriched;
}
```

### Metadata Extraction

```typescript
// Extract comprehensive issue metadata
interface IssueMetadata {
  url: string;
  owner: string;
  repo: string;
  number: number;
  type: 'issue' | 'pr';
  title?: string;
  state?: string;
  labels?: string[];
}

async function extractIssueMetadata(url: string): Promise<IssueMetadata | null> {
  const detected = detectGitHubIssue(url);
  if (!detected) return null;

  const { owner, repo, number } = detected;
  const type = url.includes('/pull/') ? 'pr' : 'issue';

  try {
    const { data } = type === 'pr'
      ? await octokit.pulls.get({ owner, repo, pull_number: number })
      : await octokit.issues.get({ owner, repo, issue_number: number });

    return {
      url,
      owner,
      repo,
      number,
      type,
      title: data.title,
      state: data.state,
      labels: data.labels?.map((l: any) => l.name) || []
    };
  } catch (error) {
    // Return partial metadata if fetch fails
    return { url, owner, repo, number, type };
  }
}
```

For complete issue detection patterns, see `examples/issue-detection-patterns.md`.

---

## GitHub Actions Integration

### Workflow Triggers

**Common trigger patterns**:

```yaml
# Trigger on push to main
on:
  push:
    branches: [main]

# Trigger on PR events
on:
  pull_request:
    types: [opened, synchronize, reopened]

# Trigger on issue events
on:
  issues:
    types: [opened, labeled]

# Multiple triggers
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:  # Manual trigger
```

### Using gh CLI in Actions

```yaml
name: Auto-label PRs

on:
  pull_request:
    types: [opened]

jobs:
  label:
    runs-on: ubuntu-latest
    steps:
      - name: Label PR based on files changed
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          # Get changed files
          FILES=$(gh pr view ${{ github.event.pull_request.number }} --json files --jq '.files[].path')

          # Add labels based on file patterns
          if echo "$FILES" | grep -q "\.ts$"; then
            gh pr edit ${{ github.event.pull_request.number }} --add-label "typescript"
          fi

          if echo "$FILES" | grep -q "\.test\.ts$"; then
            gh pr edit ${{ github.event.pull_request.number }} --add-label "tests"
          fi
```

### Common Workflow Patterns

**Auto-assign reviewers**:

```yaml
name: Auto-assign reviewers

on:
  pull_request:
    types: [opened]

jobs:
  assign:
    runs-on: ubuntu-latest
    steps:
      - name: Assign team members
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh pr edit ${{ github.event.pull_request.number }} \
            --add-reviewer team-lead \
            --add-reviewer senior-dev
```

**Link PR to issue**:

```yaml
name: Link PR to issue

on:
  pull_request:
    types: [opened]

jobs:
  link:
    runs-on: ubuntu-latest
    steps:
      - name: Extract issue number from PR title
        id: extract
        run: |
          TITLE="${{ github.event.pull_request.title }}"
          ISSUE_NUM=$(echo "$TITLE" | grep -oP '#\K\d+' | head -1)
          echo "issue_number=$ISSUE_NUM" >> $GITHUB_OUTPUT

      - name: Comment on linked issue
        if: steps.extract.outputs.issue_number != ''
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh issue comment ${{ steps.extract.outputs.issue_number }} \
            --body "PR #${{ github.event.pull_request.number }} has been created to address this issue"
```

For complete GitHub Actions integration examples, see `references/github-actions-integration.md`.

---

## Sprint Planning with GitHub Projects

### Project Board Setup

**Create project board**:
```bash
# Using gh CLI (requires gh project extension)
gh project create --owner org-name --title "Sprint 24" --format board

# Or via web UI at https://github.com/orgs/org-name/projects
```

**Configure board columns**:
- Backlog
- Sprint Ready
- In Progress
- In Review
- Done

### Sprint Workflow

**Start sprint**:

1. Create milestone for sprint
```bash
gh api repos/org-name/repo-name/milestones -f title="Sprint 24" -f due_on="2024-01-15T00:00:00Z"
```

2. Label issues as sprint-ready
```bash
gh issue edit 123 --add-label "sprint-ready"
```

3. Assign milestone to selected issues
```bash
gh issue edit 123 --milestone "Sprint 24"
```

**Track progress**:

```bash
# View sprint issues
gh issue list --milestone "Sprint 24" --json number,title,state,assignees

# View by assignee
gh issue list --milestone "Sprint 24" --assignee username
```

**Sprint metrics**:

```typescript
// Calculate sprint velocity
interface SprintMetrics {
  total: number;
  completed: number;
  in_progress: number;
  velocity: number;
}

async function getSprintMetrics(milestone: string): Promise<SprintMetrics> {
  const { data: issues } = await octokit.issues.listForRepo({
    owner: 'org-name',
    repo: 'repo-name',
    milestone,
    state: 'all'
  });

  const completed = issues.filter(i => i.state === 'closed').length;
  const in_progress = issues.filter(i =>
    i.state === 'open' && i.labels.some(l => l.name === 'in-progress')
  ).length;

  return {
    total: issues.length,
    completed,
    in_progress,
    velocity: (completed / issues.length) * 100
  };
}
```

---

## Label and Milestone Management

### Label Strategies

**Standard label set**:
```typescript
const STANDARD_LABELS = [
  { name: 'bug', color: 'd73a4a', description: 'Something isn\'t working' },
  { name: 'feature', color: 'a2eeef', description: 'New feature or request' },
  { name: 'enhancement', color: '84b6eb', description: 'Improvement to existing feature' },
  { name: 'documentation', color: '0075ca', description: 'Documentation updates' },
  { name: 'high-priority', color: 'ff0000', description: 'Urgent issue' },
  { name: 'sprint-ready', color: '00ff00', description: 'Ready for sprint planning' },
  { name: 'in-progress', color: 'fbca04', description: 'Currently being worked on' },
  { name: 'needs-review', color: 'c2e0c6', description: 'Awaiting code review' }
];

// Create labels
for (const label of STANDARD_LABELS) {
  await octokit.issues.createLabel({
    owner: 'org-name',
    repo: 'repo-name',
    ...label
  });
}
```

### Milestone Patterns

**Create milestone with due date**:
```typescript
const { data: milestone } = await octokit.issues.createMilestone({
  owner: 'org-name',
  repo: 'repo-name',
  title: 'Sprint 24',
  description: 'Q1 2024 Sprint 24',
  due_on: '2024-01-15T00:00:00Z',
  state: 'open'
});
```

**Bulk assign to milestone**:
```typescript
const issueNumbers = [123, 124, 125, 126];

await Promise.all(
  issueNumbers.map(number =>
    octokit.issues.update({
      owner: 'org-name',
      repo: 'repo-name',
      issue_number: number,
      milestone: milestone.number
    })
  )
);
```

---

## Multi-Specialist PR Comments

When multiple specialists collaborate on a feature, create comprehensive PR comments that document each specialist's contribution.

### Multi-Specialist Detection

**Check for handoff directory**:
```typescript
import { existsSync, readdirSync } from 'fs';
import { join } from 'path';

interface MultiSpecialistContext {
  isMultiSpecialist: boolean;
  specialists?: string[];
  handoffDir?: string;
  handoffFiles?: string[];
}

function detectMultiSpecialistWork(featureName: string): MultiSpecialistContext {
  const handoffDir = join(process.cwd(), '.agency', 'handoff', featureName);

  if (!existsSync(handoffDir)) {
    return { isMultiSpecialist: false };
  }

  const files = readdirSync(handoffDir);
  const summaryFiles = files.filter(f => f.endsWith('-summary.md'));

  // Extract specialist names from summary files
  const specialists = summaryFiles.map(f => {
    // Remove '-summary.md' and convert to title case
    const name = f.replace('-summary.md', '').replace(/-/g, ' ');
    return name.split(' ').map(w =>
      w.charAt(0).toUpperCase() + w.slice(1)
    ).join(' ');
  });

  return {
    isMultiSpecialist: true,
    specialists,
    handoffDir,
    handoffFiles: summaryFiles
  };
}

// Usage
const context = detectMultiSpecialistWork('user-authentication');
if (context.isMultiSpecialist) {
  console.log(`Multi-specialist work detected: ${context.specialists?.join(', ')}`);
}
```

### Single-Specialist PR Comment Template

**Standard PR comment for single specialist**:
```markdown
## Implementation Summary

**Specialist**: Frontend Developer

### Changes Made
- Implemented user authentication UI
- Added login and registration forms
- Created protected route components
- Integrated with backend auth API

### Files Changed
**Total**: 8 files (+245, -12)

**Key Files**:
- `src/components/auth/LoginForm.tsx` (+89, -0)
- `src/components/auth/RegisterForm.tsx` (+76, -0)
- `src/hooks/useAuth.ts` (+45, -8)
- `src/pages/ProfilePage.tsx` (+35, -4)

### Test Results
✅ All tests passing (18/18)

**Test Coverage**:
- Unit tests: 12 passing
- Integration tests: 6 passing
- E2E tests: Verified manually

### Verification
- [x] Code builds without errors
- [x] All tests passing
- [x] Linting and formatting applied
- [x] No console errors or warnings
- [x] Tested in development environment

**Ready for review** 🚀
```

**TypeScript example for single-specialist comment**:
```typescript
interface FileChange {
  path: string;
  additions: number;
  deletions: number;
}

interface TestResults {
  total: number;
  passing: number;
  failing: number;
  categories?: { name: string; count: number }[];
}

function generateSingleSpecialistComment(
  specialist: string,
  summary: string,
  changes: FileChange[],
  tests: TestResults
): string {
  const totalFiles = changes.length;
  const totalAdditions = changes.reduce((sum, c) => sum + c.additions, 0);
  const totalDeletions = changes.reduce((sum, c) => sum + c.deletions, 0);

  const keyFiles = changes
    .sort((a, b) => (b.additions + b.deletions) - (a.additions + a.deletions))
    .slice(0, 5)
    .map(c => `- \`${c.path}\` (+${c.additions}, -${c.deletions})`)
    .join('\n');

  const testStatus = tests.passing === tests.total ? '✅' : '⚠️';

  return `## Implementation Summary

**Specialist**: ${specialist}

### Changes Made
${summary}

### Files Changed
**Total**: ${totalFiles} files (+${totalAdditions}, -${totalDeletions})

**Key Files**:
${keyFiles}

### Test Results
${testStatus} Tests: ${tests.passing}/${tests.total} passing

${tests.categories?.map(c => `- ${c.name}: ${c.count} passing`).join('\n') || ''}

### Verification
- [x] Code builds without errors
- [x] All tests passing
- [x] Linting and formatting applied
- [x] No console errors or warnings
- [x] Tested in development environment

**Ready for review** 🚀`;
}
```

### Multi-Specialist PR Comment Template

**Comprehensive multi-specialist comment**:
```markdown
## 🚀 Multi-Specialist Implementation

This PR represents collaborative work across multiple specialists for the **User Authentication** feature.

**Specialists Involved**: Backend Architect, Frontend Developer

---

<details>
<summary><b>Backend Architect Summary</b></summary>

### Work Completed
- Implemented REST API authentication endpoints
- Added JWT token generation and validation
- Created database migrations for users table
- Integrated bcrypt password hashing
- Added role-based access control middleware

### Files Changed
**Total**: 12 files (+567, -89)

**Key Changes**:
- `src/api/auth/routes.ts` (+124, -0) - Authentication routes
- `src/api/auth/controller.ts` (+98, -0) - Auth business logic
- `src/middleware/auth.ts` (+76, -12) - JWT validation middleware
- `src/models/User.ts` (+89, -34) - User model with auth fields
- `migrations/002_add_auth_tables.sql` (+67, -0) - Database schema

### Test Results
✅ All tests passing (24/24)
- Unit tests: 16 passing
- Integration tests: 8 passing
- API endpoint coverage: 100%

### Handoff Notes
[View detailed handoff summary](.agency/handoff/user-authentication/backend-architect-summary.md)

**Integration Points**:
- JWT tokens returned in `/api/auth/login` response
- Token validation via `Authorization: Bearer <token>` header
- User roles available in `req.user.role` after auth middleware

</details>

<details>
<summary><b>Frontend Developer Summary</b></summary>

### Work Completed
- Built login and registration form components
- Implemented client-side auth state management
- Created protected route components
- Added token storage and refresh logic
- Integrated with backend auth API

### Files Changed
**Total**: 8 files (+245, -12)

**Key Changes**:
- `src/components/auth/LoginForm.tsx` (+89, -0) - Login UI
- `src/components/auth/RegisterForm.tsx` (+76, -0) - Registration UI
- `src/hooks/useAuth.ts` (+45, -8) - Auth state hook
- `src/context/AuthContext.tsx` (+35, -4) - Global auth context

### Test Results
✅ All tests passing (18/18)
- Component tests: 10 passing
- Hook tests: 4 passing
- Integration tests: 4 passing

### Handoff Notes
[View detailed handoff summary](.agency/handoff/user-authentication/frontend-developer-summary.md)

**Integration Points**:
- Consumes `/api/auth/login` and `/api/auth/register` endpoints
- Stores JWT in localStorage with auto-refresh
- Protected routes redirect to `/login` when unauthenticated

</details>

---

### Overall Status
✅ **All specialists have completed and verified their work**

**Total Changes**: 20 files (+812, -101)
**Total Tests**: 42/42 passing (100%)

**Integration Verified**:
- [x] Backend API fully functional
- [x] Frontend successfully consuming backend
- [x] End-to-end authentication flow working
- [x] Token refresh mechanism operational
- [x] Protected routes enforcing authentication
- [x] All tests passing across both layers

**Ready for review** 🎉
```

**TypeScript example for multi-specialist comment**:
```typescript
interface SpecialistWork {
  name: string;
  summary: string;
  files: FileChange[];
  tests: TestResults;
  handoffFile: string;
  integrationPoints: string[];
}

async function generateMultiSpecialistComment(
  featureName: string,
  specialists: SpecialistWork[]
): Promise<string> {
  const totalFiles = specialists.reduce((sum, s) => sum + s.files.length, 0);
  const totalAdditions = specialists.reduce(
    (sum, s) => sum + s.files.reduce((s2, f) => s2 + f.additions, 0),
    0
  );
  const totalDeletions = specialists.reduce(
    (sum, s) => sum + s.files.reduce((s2, f) => s2 + f.deletions, 0),
    0
  );
  const totalTests = specialists.reduce((sum, s) => sum + s.tests.total, 0);
  const totalPassing = specialists.reduce((sum, s) => sum + s.tests.passing, 0);

  const allTestsPassing = totalTests === totalPassing;
  const statusIcon = allTestsPassing ? '✅' : '⚠️';

  const specialistSections = specialists.map(s => {
    const fileCount = s.files.length;
    const additions = s.files.reduce((sum, f) => sum + f.additions, 0);
    const deletions = s.files.reduce((sum, f) => sum + f.deletions, 0);

    const keyFiles = s.files
      .sort((a, b) => (b.additions + b.deletions) - (a.additions + a.deletions))
      .slice(0, 5)
      .map(f => `- \`${f.path}\` (+${f.additions}, -${f.deletions}) - ${getFileDescription(f.path)}`)
      .join('\n');

    const testStatus = s.tests.passing === s.tests.total ? '✅' : '⚠️';
    const testBreakdown = s.tests.categories
      ?.map(c => `- ${c.name}: ${c.count} passing`)
      .join('\n') || '';

    const integrationPoints = s.integrationPoints
      .map(point => `- ${point}`)
      .join('\n');

    return `<details>
<summary><b>${s.name} Summary</b></summary>

### Work Completed
${s.summary}

### Files Changed
**Total**: ${fileCount} files (+${additions}, -${deletions})

**Key Changes**:
${keyFiles}

### Test Results
${testStatus} All tests passing (${s.tests.passing}/${s.tests.total})
${testBreakdown}

### Handoff Notes
[View detailed handoff summary](${s.handoffFile})

**Integration Points**:
${integrationPoints}

</details>`;
  }).join('\n\n');

  const specialistNames = specialists.map(s => s.name).join(', ');

  return `## 🚀 Multi-Specialist Implementation

This PR represents collaborative work across multiple specialists for the **${formatFeatureName(featureName)}** feature.

**Specialists Involved**: ${specialistNames}

---

${specialistSections}

---

### Overall Status
${statusIcon} **All specialists have completed and verified their work**

**Total Changes**: ${totalFiles} files (+${totalAdditions}, -${totalDeletions})
**Total Tests**: ${totalPassing}/${totalTests} passing (${Math.round(totalPassing / totalTests * 100)}%)

**Integration Verified**:
${generateIntegrationChecklist(specialists)}

**Ready for review** 🎉`;
}

function getFileDescription(filePath: string): string {
  if (filePath.includes('route')) return 'API routes';
  if (filePath.includes('controller')) return 'Business logic';
  if (filePath.includes('model')) return 'Data model';
  if (filePath.includes('component')) return 'UI component';
  if (filePath.includes('hook')) return 'React hook';
  if (filePath.includes('test')) return 'Tests';
  if (filePath.includes('migration')) return 'Database migration';
  return 'Core implementation';
}

function formatFeatureName(name: string): string {
  return name
    .split('-')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ');
}

function generateIntegrationChecklist(specialists: SpecialistWork[]): string {
  const checks = [
    'All specialist work completed and verified',
    'Integration points documented and tested',
    'End-to-end functionality confirmed',
    'All tests passing across all layers',
    'No breaking changes introduced',
    'Documentation updated'
  ];

  return checks.map(check => `- [x] ${check}`).join('\n');
}
```

### Complete PR Comment Workflow

**Detect context and generate appropriate comment**:
```typescript
async function generatePRComment(
  featureName: string,
  prNumber: number
): Promise<string> {
  const context = detectMultiSpecialistWork(featureName);

  if (!context.isMultiSpecialist) {
    // Single specialist workflow
    const specialist = await getCurrentSpecialist();
    const changes = await getFileChanges(prNumber);
    const tests = await getTestResults();
    const summary = await generateWorkSummary(changes);

    return generateSingleSpecialistComment(specialist, summary, changes, tests);
  }

  // Multi-specialist workflow
  const specialists = await Promise.all(
    context.specialists!.map(async (name) => {
      const handoffFile = `.agency/handoff/${featureName}/${name.toLowerCase().replace(/\s+/g, '-')}-summary.md`;
      const summary = await parseHandoffSummary(handoffFile);

      return {
        name,
        summary: summary.workCompleted,
        files: summary.filesChanged,
        tests: summary.testResults,
        handoffFile,
        integrationPoints: summary.integrationPoints
      };
    })
  );

  return generateMultiSpecialistComment(featureName, specialists);
}

async function postPRComment(prNumber: number, body: string): Promise<void> {
  await octokit.issues.createComment({
    owner: 'org-name',
    repo: 'repo-name',
    issue_number: prNumber,
    body
  });
}

// Usage
const comment = await generatePRComment('user-authentication', 456);
await postPRComment(456, comment);
```

### Best Practices for PR Comments

**Multi-Specialist Comments**:
- ✅ Use collapsible `<details>` sections to keep the main view clean
- ✅ List all specialists involved in the header
- ✅ Link to detailed handoff summaries for deep dive
- ✅ Document integration points clearly
- ✅ Include comprehensive test results
- ✅ Show overall status and verification checklist

**Single-Specialist Comments**:
- ✅ Keep format consistent for easy scanning
- ✅ Highlight key files and changes
- ✅ Include test results and coverage
- ✅ Add verification checklist
- ✅ Use clear status indicators (✅, ⚠️, ❌)

**Markdown Formatting**:
- ✅ Use proper heading hierarchy (##, ###)
- ✅ Format code with backticks
- ✅ Use emojis sparingly for status indicators
- ✅ Keep lines under 120 characters for readability
- ✅ Use tables for structured data when appropriate

**Automation**:
- ✅ Auto-detect multi-specialist vs single-specialist context
- ✅ Extract file stats from git diff
- ✅ Parse test results from test runner output
- ✅ Link to relevant handoff documents
- ✅ Include commit SHAs for traceability

---

## Quick Reference

### Essential gh Commands
- `gh issue list --label <label>` - Filter issues by label
- `gh issue view <number> --json <fields>` - Get issue as JSON
- `gh pr create --fill` - Create PR from commits
- `gh pr merge --squash --auto` - Auto-merge when checks pass
- `gh project item-add <id> --url <url>` - Add to project board

### Key API Endpoints
- `GET /repos/{owner}/{repo}/issues` - List issues
- `POST /repos/{owner}/{repo}/issues` - Create issue
- `PATCH /repos/{owner}/{repo}/issues/{number}` - Update issue
- `POST /repos/{owner}/{repo}/issues/{number}/comments` - Add comment
- `GET /repos/{owner}/{repo}/pulls` - List PRs

### URL Patterns
- Issues: `https://github.com/{owner}/{repo}/issues/{number}`
- PRs: `https://github.com/{owner}/{repo}/pull/{number}`
- References: `#{number}` in text

### Best Practices
- Always handle rate limits (5000/hour authenticated)
- Use GraphQL for nested data requirements
- Cache repository metadata to reduce API calls
- Use webhooks for real-time event handling
- Implement exponential backoff for retries

---

## Related Skills

- **github-workflow-best-practices**: Broader GitHub workflow patterns and team collaboration
- **agency-workflow-patterns**: General workflow automation applicable to any provider
- **jira-integration**: Alternative provider integration for comparison
- **testing-strategy**: Integration testing for GitHub Actions workflows
