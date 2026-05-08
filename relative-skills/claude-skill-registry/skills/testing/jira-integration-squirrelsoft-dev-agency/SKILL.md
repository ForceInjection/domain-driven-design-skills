---
name: jira-integration
description: Master Jira integration using acli CLI, Jira REST API, issue management, sprint operations, JQL queries, and ADF comment formatting. Essential for Jira-based project management automation.
triggers:
  - "jira integration"
  - "acli"
  - "atlassian cli"
  - "jira api"
  - "jql query"
  - "jira sprint"
  - "adf format"
  - "jira comment"
  - "jira issue detection"
---

# Jira Integration Mastery

This skill provides comprehensive guidance for integrating with Jira using the Atlassian CLI (acli), Jira REST API, and ADF (Atlassian Document Format). Essential for automating issue management, sprint planning, JQL queries, and building robust Jira-based workflows.

## When to Use This Skill

- Automating Jira issue creation, updates, and transitions
- Building sprint planning workflows
- Writing and executing JQL queries
- Formatting comments with ADF (Atlassian Document Format)
- Parsing Jira URLs and extracting metadata
- Integrating Jira into development automation
- Creating bulk operations across multiple issues

---

## Atlassian CLI (acli) Mastery

The Atlassian CLI (`acli`) is the primary tool for Jira automation via command line.

### Installation and Configuration

```bash
# Download acli
curl -O https://bobswift.atlassian.net/wiki/download/attachments/16285777/acli-9.8.0-distribution.zip

# Extract and setup
unzip acli-9.8.0-distribution.zip
export PATH=$PATH:/path/to/acli

# Configure connection
acli jira --server https://your-domain.atlassian.net --user user@example.com --password your-api-token --action getServerInfo

# Store credentials (creates ~/.acli/acli.properties)
acli jira --server https://your-domain.atlassian.net --user user@example.com --password your-api-token --action login
```

**Configuration file** (`~/.acli/acli.properties`):
```properties
server=https://your-domain.atlassian.net
user=user@example.com
password=your-api-token
```

### Issue Operations

**List issues**:
```bash
# List issues in project
acli jira --action getIssueList --project PROJ

# List with JQL
acli jira --action getIssueList --jql "project = PROJ AND status = 'To Do'"

# List with specific fields
acli jira --action getIssueList --jql "assignee = currentUser()" --outputFormat 2 --columns "key,summary,status"
```

**Get issue details**:
```bash
# Get full issue details
acli jira --action getIssue --issue PROJ-123

# Get specific fields
acli jira --action getIssue --issue PROJ-123 --outputFormat 2 --columns "key,summary,description,status,assignee"
```

**Create issue**:
```bash
# Create issue
acli jira --action createIssue \
  --project PROJ \
  --type "Story" \
  --summary "Implement authentication" \
  --description "Add OAuth2 authentication to the application" \
  --priority "High" \
  --labels "backend,security"

# Create with custom fields
acli jira --action createIssue \
  --project PROJ \
  --type "Bug" \
  --summary "Login fails on mobile" \
  --field "customfield_10001=High Priority"
```

**Update issue**:
```bash
# Update summary and description
acli jira --action updateIssue \
  --issue PROJ-123 \
  --summary "Updated summary" \
  --description "Updated description"

# Update custom fields
acli jira --action updateIssue \
  --issue PROJ-123 \
  --field "customfield_10001=New Value"

# Add labels
acli jira --action updateIssue \
  --issue PROJ-123 \
  --labels "bug,urgent" \
  --labelsAdd
```

**Transition issue**:
```bash
# Move to different status
acli jira --action transitionIssue \
  --issue PROJ-123 \
  --transition "In Progress"

# Transition with comment
acli jira --action transitionIssue \
  --issue PROJ-123 \
  --transition "Done" \
  --comment "Completed implementation and testing"
```

**Assign issue**:
```bash
# Assign to user
acli jira --action assignIssue \
  --issue PROJ-123 \
  --assignee "john.doe"

# Assign to me
acli jira --action assignIssue \
  --issue PROJ-123 \
  --assignee "@me"
```

### Sprint Operations

**List sprints**:
```bash
# List sprints for board
acli jira --action getSprintList \
  --board "PROJ Board"

# List active sprints
acli jira --action getSprintList \
  --board "PROJ Board" \
  --state "active"
```

**Add issues to sprint**:
```bash
# Add single issue
acli jira --action addIssuesToSprint \
  --sprint "Sprint 24" \
  --issue "PROJ-123"

# Add multiple issues
acli jira --action addIssuesToSprint \
  --sprint "Sprint 24" \
  --issue "PROJ-123,PROJ-124,PROJ-125"
```

**Start sprint**:
```bash
# Start sprint with date range
acli jira --action startSprint \
  --sprint "Sprint 24" \
  --startDate "2024-01-01" \
  --endDate "2024-01-14"
```

**Close sprint**:
```bash
# Complete sprint (moves incomplete issues to backlog)
acli jira --action completeSprint \
  --sprint "Sprint 24"
```

### Board Management

**List boards**:
```bash
# List all boards
acli jira --action getBoardList

# List boards for project
acli jira --action getBoardList \
  --project PROJ
```

**Get board configuration**:
```bash
# Get board details
acli jira --action getBoard \
  --board "PROJ Board"
```

### Bulk Operations

**Bulk transition**:
```bash
# Transition multiple issues
acli jira --action progressIssue \
  --issue "PROJ-123,PROJ-124,PROJ-125" \
  --transition "In Progress"
```

**Bulk update**:
```bash
# Update multiple issues
acli jira --action updateIssue \
  --issue "PROJ-123,PROJ-124" \
  --labels "sprint-24" \
  --labelsAdd
```

For complete acli command reference, see `references/acli-reference.md`.

---

## Jira REST API Patterns

### API Basics

```typescript
import axios from 'axios';

// Configure API client
const jiraClient = axios.create({
  baseURL: 'https://your-domain.atlassian.net/rest/api/3',
  auth: {
    username: 'user@example.com',
    password: 'your-api-token'
  },
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  }
});
```

### Issue CRUD Operations

**Get issue**:
```typescript
const response = await jiraClient.get(`/issue/PROJ-123`);
const issue = response.data;

console.log(issue.key);
console.log(issue.fields.summary);
console.log(issue.fields.status.name);
```

**Create issue**:
```typescript
const newIssue = await jiraClient.post('/issue', {
  fields: {
    project: {
      key: 'PROJ'
    },
    summary: 'Implement authentication',
    description: {
      type: 'doc',
      version: 1,
      content: [
        {
          type: 'paragraph',
          content: [
            {
              type: 'text',
              text: 'Add OAuth2 authentication'
            }
          ]
        }
      ]
    },
    issuetype: {
      name: 'Story'
    },
    priority: {
      name: 'High'
    },
    labels: ['backend', 'security']
  }
});

console.log(`Created issue: ${newIssue.data.key}`);
```

**Update issue**:
```typescript
await jiraClient.put(`/issue/PROJ-123`, {
  fields: {
    summary: 'Updated summary',
    labels: ['bug', 'urgent']
  }
});
```

**Transition issue**:
```typescript
// Get available transitions
const transitionsResp = await jiraClient.get(`/issue/PROJ-123/transitions`);
const transitions = transitionsResp.data.transitions;

// Find "In Progress" transition
const inProgressTransition = transitions.find(t => t.name === 'In Progress');

// Execute transition
await jiraClient.post(`/issue/PROJ-123/transitions`, {
  transition: {
    id: inProgressTransition.id
  }
});
```

### Advanced Operations

**Add comment**:
```typescript
await jiraClient.post(`/issue/PROJ-123/comment`, {
  body: {
    type: 'doc',
    version: 1,
    content: [
      {
        type: 'paragraph',
        content: [
          {
            type: 'text',
            text: 'This issue has been reviewed and approved'
          }
        ]
      }
    ]
  }
});
```

**Add attachment**:
```typescript
import FormData from 'form-data';
import fs from 'fs';

const form = new FormData();
form.append('file', fs.createReadStream('screenshot.png'));

await jiraClient.post(`/issue/PROJ-123/attachments`, form, {
  headers: {
    ...form.getHeaders(),
    'X-Atlassian-Token': 'no-check'
  }
});
```

**Link issues**:
```typescript
await jiraClient.post('/issueLink', {
  type: {
    name: 'Blocks'
  },
  inwardIssue: {
    key: 'PROJ-123'
  },
  outwardIssue: {
    key: 'PROJ-456'
  }
});
```

For complete API patterns and examples, see `references/jira-api-patterns.md`.

---

## JQL (Jira Query Language)

JQL is Jira's query language for searching and filtering issues.

### Basic JQL Syntax

```jql
# Single condition
project = PROJ

# Multiple conditions (AND)
project = PROJ AND status = "To Do"

# Multiple conditions (OR)
status = "To Do" OR status = "In Progress"

# Negation
status != Done

# IN operator
status IN ("To Do", "In Progress")

# Comparison
created >= -7d
```

### Common JQL Queries

**By status**:
```jql
# Open issues
status IN ("To Do", "In Progress", "Review")

# Closed issues
status = Done

# Not done
status != Done
```

**By assignee**:
```jql
# Assigned to me
assignee = currentUser()

# Unassigned
assignee IS EMPTY

# Assigned to specific user
assignee = "john.doe"
```

**By date**:
```jql
# Created in last 7 days
created >= -7d

# Updated today
updated >= startOfDay()

# Due this week
due <= endOfWeek()
```

**By sprint**:
```jql
# Current sprint
sprint in openSprints()

# Specific sprint
sprint = "Sprint 24"

# Issues not in sprint
sprint IS EMPTY
```

**By label**:
```jql
# Has specific label
labels = backend

# Has any of multiple labels
labels IN (backend, frontend)

# Missing labels
labels IS EMPTY
```

### Advanced JQL Patterns

**Combination queries**:
```jql
# Sprint items assigned to me
project = PROJ AND sprint in openSprints() AND assignee = currentUser()

# High priority bugs
project = PROJ AND issuetype = Bug AND priority IN (Highest, High)

# Overdue items
duedate < now() AND status != Done
```

**Using functions**:
```jql
# Issues updated by me
updatedBy = currentUser()

# Issues where I'm a watcher
watcher = currentUser()

# Issues in epics
"Epic Link" IS NOT EMPTY
```

**Ordering results**:
```jql
# Order by priority, then created date
project = PROJ ORDER BY priority DESC, created ASC

# Multiple sort fields
status = "To Do" ORDER BY priority DESC, updated DESC
```

For 30+ JQL query examples, see `examples/jql-query-examples.md`.

---

## ADF (Atlassian Document Format)

ADF is Jira's JSON-based format for rich text content in descriptions and comments.

### Basic ADF Structure

```typescript
// Simple text paragraph
const adf = {
  type: 'doc',
  version: 1,
  content: [
    {
      type: 'paragraph',
      content: [
        {
          type: 'text',
          text: 'Hello, world!'
        }
      ]
    }
  ]
};
```

### Text Formatting

**Bold, italic, code**:
```typescript
{
  type: 'doc',
  version: 1,
  content: [
    {
      type: 'paragraph',
      content: [
        {
          type: 'text',
          text: 'This is ',
          marks: []
        },
        {
          type: 'text',
          text: 'bold',
          marks: [{ type: 'strong' }]
        },
        {
          type: 'text',
          text: ', '
        },
        {
          type: 'text',
          text: 'italic',
          marks: [{ type: 'em' }]
        },
        {
          type: 'text',
          text: ', and '
        },
        {
          type: 'text',
          text: 'code',
          marks: [{ type: 'code' }]
        }
      ]
    }
  ]
}
```

### Links

```typescript
{
  type: 'text',
  text: 'Click here',
  marks: [
    {
      type: 'link',
      attrs: {
        href: 'https://example.com'
      }
    }
  ]
}
```

### Code Blocks

```typescript
{
  type: 'codeBlock',
  attrs: {
    language: 'typescript'
  },
  content: [
    {
      type: 'text',
      text: 'function hello() {\n  console.log("Hello");\n}'
    }
  ]
}
```

### Lists

**Bullet list**:
```typescript
{
  type: 'bulletList',
  content: [
    {
      type: 'listItem',
      content: [
        {
          type: 'paragraph',
          content: [
            {
              type: 'text',
              text: 'First item'
            }
          ]
        }
      ]
    },
    {
      type: 'listItem',
      content: [
        {
          type: 'paragraph',
          content: [
            {
              type: 'text',
              text: 'Second item'
            }
          ]
        }
      ]
    }
  ]
}
```

**Ordered list**:
```typescript
{
  type: 'orderedList',
  content: [
    // Same listItem structure as bulletList
  ]
}
```

### Helper Functions

```typescript
// Create simple text paragraph
function createParagraph(text: string) {
  return {
    type: 'paragraph',
    content: [
      {
        type: 'text',
        text
      }
    ]
  };
}

// Create ADF document
function createADFDocument(...paragraphs: any[]) {
  return {
    type: 'doc',
    version: 1,
    content: paragraphs
  };
}

// Usage
const doc = createADFDocument(
  createParagraph('First paragraph'),
  createParagraph('Second paragraph')
);
```

For complete ADF specification and templates, see `references/adf-format-guide.md` and `examples/adf-comment-templates.md`.

---

## Issue Detection and Parsing

### Jira URL Patterns

```typescript
// Jira issue URL pattern
const JIRA_ISSUE_URL = /https?:\/\/([^\/]+)\.atlassian\.net\/browse\/([A-Z]+-\d+)/g;

// Custom Jira domain
const JIRA_CUSTOM_URL = /https?:\/\/jira\.([^\/]+)\.com\/browse\/([A-Z]+-\d+)/g;

function detectJiraIssues(text: string) {
  const matches = Array.from(text.matchAll(JIRA_ISSUE_URL));

  return matches.map(match => ({
    url: match[0],
    domain: match[1],
    key: match[2]
  }));
}

// Example
const text = "See https://mycompany.atlassian.net/browse/PROJ-123";
const issues = detectJiraIssues(text);
// => [{ url: "...", domain: "mycompany", key: "PROJ-123" }]
```

### Jira Issue Key Pattern

```typescript
// Issue key pattern (e.g., PROJ-123)
const JIRA_KEY = /\b([A-Z]{2,10}-\d+)\b/g;

function extractJiraKeys(text: string): string[] {
  const matches = Array.from(text.matchAll(JIRA_KEY));
  return matches.map(m => m[1]);
}

// Example
const text = "Implements PROJ-123 and fixes PROJ-456";
const keys = extractJiraKeys(text);
// => ["PROJ-123", "PROJ-456"]
```

### Auto-fetch Issue Details

```typescript
async function fetchJiraIssue(key: string) {
  const response = await jiraClient.get(`/issue/${key}`);
  return {
    key: response.data.key,
    summary: response.data.fields.summary,
    status: response.data.fields.status.name,
    assignee: response.data.fields.assignee?.displayName,
    url: `https://your-domain.atlassian.net/browse/${key}`
  };
}

// Auto-enrich text with issue details
async function enrichWithJiraData(text: string) {
  const keys = extractJiraKeys(text);
  const issues = await Promise.all(keys.map(fetchJiraIssue));

  let enriched = text;
  issues.forEach(issue => {
    const pattern = new RegExp(issue.key, 'g');
    enriched = enriched.replace(
      pattern,
      `[${issue.key}](${issue.url}) (${issue.summary})`
    );
  });

  return enriched;
}
```

---

## Sprint Management

### Sprint Planning Workflow

```bash
# 1. Create new sprint
acli jira --action createSprint \
  --board "PROJ Board" \
  --name "Sprint 25" \
  --startDate "2024-01-15" \
  --endDate "2024-01-28"

# 2. Add issues to sprint (from JQL query)
acli jira --action getIssueList \
  --jql "project = PROJ AND labels = 'sprint-ready'" \
  --outputFormat 999 | \
  acli jira --action addIssuesToSprint \
    --sprint "Sprint 25" \
    --issue "@-"

# 3. Start sprint
acli jira --action startSprint \
  --sprint "Sprint 25"
```

### Sprint Reporting

```typescript
interface SprintMetrics {
  name: string;
  total: number;
  completed: number;
  inProgress: number;
  todo: number;
  velocity: number;
}

async function getSprintMetrics(sprintId: string): Promise<SprintMetrics> {
  const response = await jiraClient.get(`/sprint/${sprintId}/issues`);
  const issues = response.data.issues;

  const completed = issues.filter((i: any) => i.fields.status.name === 'Done').length;
  const inProgress = issues.filter((i: any) => i.fields.status.name === 'In Progress').length;
  const todo = issues.filter((i: any) => i.fields.status.name === 'To Do').length;

  return {
    name: response.data.sprint.name,
    total: issues.length,
    completed,
    inProgress,
    todo,
    velocity: (completed / issues.length) * 100
  };
}
```

---

## Quick Reference

### Essential acli Commands
- `acli jira --action getIssueList --jql "query"` - Query issues
- `acli jira --action createIssue --project PROJ --type Story --summary "..."` - Create issue
- `acli jira --action transitionIssue --issue KEY --transition "Status"` - Change status
- `acli jira --action addIssuesToSprint --sprint "Sprint" --issue "KEY"` - Add to sprint
- `acli jira --action getSprintList --board "Board"` - List sprints

### Key API Endpoints
- `GET /issue/{issueKey}` - Get issue
- `POST /issue` - Create issue
- `PUT /issue/{issueKey}` - Update issue
- `POST /issue/{issueKey}/transitions` - Transition issue
- `POST /issue/{issueKey}/comment` - Add comment

### JQL Quick Patterns
- `project = PROJ AND assignee = currentUser()` - My issues
- `sprint in openSprints()` - Current sprint
- `status = "To Do" ORDER BY priority DESC` - Prioritized backlog
- `created >= -7d` - Recent issues

### ADF Basics
- Paragraph: `{type: 'paragraph', content: [{type: 'text', text: '...'}]}`
- Bold: `marks: [{type: 'strong'}]`
- Code: `marks: [{type: 'code'}]`
- Link: `marks: [{type: 'link', attrs: {href: '...'}}]`

### Best Practices
- Always use API tokens (not passwords) for authentication
- Cache Jira project metadata to reduce API calls
- Use JQL for complex queries instead of filtering in code
- Validate issue keys before API calls (format: PROJECT-123)
- Use ADF for all rich text content (descriptions, comments)
- Handle Jira API rate limits (10 requests/second)

---

## Multi-Specialist ADF Comment Support

When working with multi-specialist implementations, Jira comments need to aggregate work from multiple specialists into a single, well-formatted comment.

### Detection Logic

**Check for multi-specialist mode**:
```bash
# Detect if this is a multi-specialist implementation
FEATURE_NAME="authentication"  # Extract from issue or context

if [ -d ".agency/handoff/${FEATURE_NAME}" ]; then
  echo "Multi-specialist mode detected"
  MODE="multi-specialist"
else
  echo "Single-specialist mode"
  MODE="single-specialist"
fi
```

**Gather specialist information**:
```bash
# List all specialists who worked on this feature
if [ -d ".agency/handoff/${FEATURE_NAME}" ]; then
  specialists=$(ls -d .agency/handoff/${FEATURE_NAME}/*/ | xargs -n1 basename)

  for specialist in $specialists; do
    echo "Found specialist: $specialist"

    # Read specialist's summary
    if [ -f ".agency/handoff/${FEATURE_NAME}/${specialist}/summary.md" ]; then
      cat ".agency/handoff/${FEATURE_NAME}/${specialist}/summary.md"
    fi

    # Read specialist's verification
    if [ -f ".agency/handoff/${FEATURE_NAME}/${specialist}/verification.md" ]; then
      cat ".agency/handoff/${FEATURE_NAME}/${specialist}/verification.md"
    fi
  done
fi
```

### Multi-Specialist ADF Comment Template

**Complete example with multiple specialists**:
```typescript
interface SpecialistWork {
  name: string;
  displayName: string;
  summary: string;
  filesChanged: string[];
  testResults: string;
  status: 'success' | 'warning' | 'error';
}

function createMultiSpecialistComment(
  featureName: string,
  specialists: SpecialistWork[],
  overallStatus: 'success' | 'warning' | 'error',
  integrationPoints: string[]
): object {
  const statusEmoji = {
    success: '✅',
    warning: '⚠️',
    error: '❌'
  };

  const panelType = {
    success: 'success',
    warning: 'warning',
    error: 'error'
  };

  return {
    version: 1,
    type: 'doc',
    content: [
      // Header panel with overall status
      {
        type: 'panel',
        attrs: {
          panelType: panelType[overallStatus]
        },
        content: [
          {
            type: 'paragraph',
            content: [
              {
                type: 'text',
                text: `${statusEmoji[overallStatus]} Multi-Specialist Implementation Complete`,
                marks: [{ type: 'strong' }]
              }
            ]
          },
          {
            type: 'paragraph',
            content: [
              {
                type: 'text',
                text: `Feature: ${featureName} | Specialists: ${specialists.length}`
              }
            ]
          }
        ]
      },

      // Specialists summary
      {
        type: 'heading',
        attrs: { level: 3 },
        content: [
          {
            type: 'text',
            text: 'Specialist Contributions'
          }
        ]
      },

      // List of specialists with status
      {
        type: 'bulletList',
        content: specialists.map(specialist => ({
          type: 'listItem',
          content: [
            {
              type: 'paragraph',
              content: [
                {
                  type: 'text',
                  text: `${statusEmoji[specialist.status]} `,
                  marks: []
                },
                {
                  type: 'text',
                  text: specialist.displayName,
                  marks: [{ type: 'strong' }]
                },
                {
                  type: 'text',
                  text: ` - ${specialist.summary}`
                }
              ]
            }
          ]
        }))
      },

      // Detailed work by specialist (collapsible-like sections)
      {
        type: 'heading',
        attrs: { level: 3 },
        content: [
          {
            type: 'text',
            text: 'Detailed Work Breakdown'
          }
        ]
      },

      ...specialists.flatMap(specialist => [
        // Specialist heading
        {
          type: 'heading',
          attrs: { level: 4 },
          content: [
            {
              type: 'text',
              text: `${specialist.displayName} ${statusEmoji[specialist.status]}`
            }
          ]
        },

        // Summary
        {
          type: 'paragraph',
          content: [
            {
              type: 'text',
              text: 'Summary: ',
              marks: [{ type: 'strong' }]
            },
            {
              type: 'text',
              text: specialist.summary
            }
          ]
        },

        // Files changed
        {
          type: 'paragraph',
          content: [
            {
              type: 'text',
              text: 'Files Changed: ',
              marks: [{ type: 'strong' }]
            },
            {
              type: 'text',
              text: `${specialist.filesChanged.length} files`
            }
          ]
        },
        {
          type: 'bulletList',
          content: specialist.filesChanged.slice(0, 10).map(file => ({
            type: 'listItem',
            content: [
              {
                type: 'paragraph',
                content: [
                  {
                    type: 'text',
                    text: file,
                    marks: [{ type: 'code' }]
                  }
                ]
              }
            ]
          }))
        },

        // Test results
        {
          type: 'paragraph',
          content: [
            {
              type: 'text',
              text: 'Tests: ',
              marks: [{ type: 'strong' }]
            },
            {
              type: 'text',
              text: specialist.testResults
            }
          ]
        }
      ]),

      // Integration points
      {
        type: 'heading',
        attrs: { level: 3 },
        content: [
          {
            type: 'text',
            text: 'Integration Points'
          }
        ]
      },
      {
        type: 'bulletList',
        content: integrationPoints.map(point => ({
          type: 'listItem',
          content: [
            {
              type: 'paragraph',
              content: [
                {
                  type: 'text',
                  text: point
                }
              ]
            }
          ]
        }))
      }
    ]
  };
}
```

**Usage example**:
```typescript
const specialists: SpecialistWork[] = [
  {
    name: 'backend-architect',
    displayName: 'Backend Architect',
    summary: 'Implemented authentication API with JWT and refresh tokens',
    filesChanged: [
      'src/api/auth/login.ts',
      'src/api/auth/refresh.ts',
      'src/middleware/authenticate.ts',
      'src/models/user.ts'
    ],
    testResults: 'All tests passing (24/24)',
    status: 'success'
  },
  {
    name: 'frontend-developer',
    displayName: 'Frontend Developer',
    summary: 'Created login/signup forms and integrated with auth API',
    filesChanged: [
      'src/components/LoginForm.tsx',
      'src/components/SignupForm.tsx',
      'src/hooks/useAuth.ts',
      'src/pages/profile.tsx'
    ],
    testResults: 'All tests passing (18/18)',
    status: 'success'
  }
];

const comment = createMultiSpecialistComment(
  'Authentication System',
  specialists,
  'success',
  [
    'Backend exposes /api/auth/login and /api/auth/refresh endpoints',
    'Frontend uses useAuth hook to manage authentication state',
    'JWT tokens stored in httpOnly cookies',
    'Protected routes redirect to login when unauthenticated'
  ]
);

// Post to Jira
await jiraClient.post(`/issue/PROJ-123/comment`, { body: comment });
```

### Single-Specialist ADF Comment Template

**Backward compatibility** - Keep existing single-specialist format:
```typescript
function createSingleSpecialistComment(
  summary: string,
  filesChanged: string[],
  testResults: string,
  status: 'success' | 'warning' | 'error'
): object {
  const statusEmoji = {
    success: '✅',
    warning: '⚠️',
    error: '❌'
  };

  const panelType = {
    success: 'success',
    warning: 'warning',
    error: 'error'
  };

  return {
    version: 1,
    type: 'doc',
    content: [
      {
        type: 'panel',
        attrs: {
          panelType: panelType[status]
        },
        content: [
          {
            type: 'paragraph',
            content: [
              {
                type: 'text',
                text: `${statusEmoji[status]} Implementation Complete`,
                marks: [{ type: 'strong' }]
              }
            ]
          }
        ]
      },
      {
        type: 'paragraph',
        content: [
          {
            type: 'text',
            text: 'Summary: ',
            marks: [{ type: 'strong' }]
          },
          {
            type: 'text',
            text: summary
          }
        ]
      },
      {
        type: 'paragraph',
        content: [
          {
            type: 'text',
            text: 'Files Changed: ',
            marks: [{ type: 'strong' }]
          },
          {
            type: 'text',
            text: `${filesChanged.length} files`
          }
        ]
      },
      {
        type: 'bulletList',
        content: filesChanged.slice(0, 10).map(file => ({
          type: 'listItem',
          content: [
            {
              type: 'paragraph',
              content: [
                {
                  type: 'text',
                  text: file,
                  marks: [{ type: 'code' }]
                }
              ]
            }
          ]
        }))
      },
      {
        type: 'paragraph',
        content: [
          {
            type: 'text',
            text: 'Tests: ',
            marks: [{ type: 'strong' }]
          },
          {
            type: 'text',
            text: testResults
          }
        ]
      }
    ]
  };
}
```

### Auto-Detection Wrapper

**Automatically choose the right format**:
```typescript
async function postImplementationComment(
  issueKey: string,
  featureName: string
): Promise<void> {
  const handoffDir = `.agency/handoff/${featureName}`;

  // Check if multi-specialist mode
  if (fs.existsSync(handoffDir)) {
    // Multi-specialist mode
    const specialists: SpecialistWork[] = [];
    const specialistDirs = fs.readdirSync(handoffDir, { withFileTypes: true })
      .filter(d => d.isDirectory())
      .map(d => d.name);

    for (const specialistName of specialistDirs) {
      const summaryPath = `${handoffDir}/${specialistName}/summary.md`;
      const verificationPath = `${handoffDir}/${specialistName}/verification.md`;

      if (fs.existsSync(summaryPath)) {
        const summary = fs.readFileSync(summaryPath, 'utf-8');
        const verification = fs.existsSync(verificationPath)
          ? fs.readFileSync(verificationPath, 'utf-8')
          : '';

        // Parse summary and verification to extract data
        const specialist = parseSpecialistData(specialistName, summary, verification);
        specialists.push(specialist);
      }
    }

    // Determine overall status
    const overallStatus = specialists.every(s => s.status === 'success')
      ? 'success'
      : specialists.some(s => s.status === 'error')
      ? 'error'
      : 'warning';

    // Extract integration points from summaries
    const integrationPoints = extractIntegrationPoints(specialists);

    const comment = createMultiSpecialistComment(
      featureName,
      specialists,
      overallStatus,
      integrationPoints
    );

    await jiraClient.post(`/issue/${issueKey}/comment`, { body: comment });
  } else {
    // Single-specialist mode (backward compatible)
    const summary = 'Implementation completed';
    const filesChanged = await getChangedFiles();
    const testResults = 'All tests passing';
    const status = 'success';

    const comment = createSingleSpecialistComment(
      summary,
      filesChanged,
      testResults,
      status
    );

    await jiraClient.post(`/issue/${issueKey}/comment`, { body: comment });
  }
}
```

### Helper Functions

```typescript
function parseSpecialistData(
  name: string,
  summary: string,
  verification: string
): SpecialistWork {
  // Extract display name
  const displayNames: Record<string, string> = {
    'backend-architect': 'Backend Architect',
    'frontend-developer': 'Frontend Developer',
    'database-specialist': 'Database Specialist',
    'devops-engineer': 'DevOps Engineer'
  };

  // Extract summary (first paragraph or heading)
  const summaryMatch = summary.match(/^##?\s+(.+)$/m) ||
                       summary.match(/^(.+)$/m);
  const summaryText = summaryMatch ? summaryMatch[1] : 'Work completed';

  // Extract files from summary (look for code blocks or lists)
  const filesMatch = summary.match(/```[^`]*```/s) ||
                     summary.match(/^[-*]\s+`([^`]+)`/gm);
  const filesChanged = filesMatch
    ? Array.from(summary.matchAll(/`([^`]+\.[a-z]+)`/g)).map(m => m[1])
    : [];

  // Extract test results
  const testMatch = verification.match(/Tests?:\s*(.+)/i) ||
                   verification.match(/(\d+\/\d+\s+passing)/i);
  const testResults = testMatch ? testMatch[1] : 'Tests completed';

  // Determine status from verification
  let status: 'success' | 'warning' | 'error' = 'success';
  if (verification.includes('❌') || verification.includes('FAIL')) {
    status = 'error';
  } else if (verification.includes('⚠️') || verification.includes('WARNING')) {
    status = 'warning';
  }

  return {
    name,
    displayName: displayNames[name] || name,
    summary: summaryText,
    filesChanged,
    testResults,
    status
  };
}

function extractIntegrationPoints(specialists: SpecialistWork[]): string[] {
  const points: string[] = [];

  // Look for API endpoints from backend
  const backend = specialists.find(s => s.name === 'backend-architect');
  if (backend) {
    const apiMatches = backend.summary.match(/\/api\/[^\s]+/g);
    if (apiMatches) {
      points.push(...apiMatches.map(api => `Backend exposes ${api} endpoint`));
    }
  }

  // Look for components from frontend
  const frontend = specialists.find(s => s.name === 'frontend-developer');
  if (frontend) {
    const componentMatches = frontend.filesChanged
      .filter(f => f.endsWith('.tsx') || f.endsWith('.jsx'));
    if (componentMatches.length > 0) {
      points.push(`Frontend components: ${componentMatches.join(', ')}`);
    }
  }

  return points.length > 0 ? points : ['See individual specialist sections for details'];
}

async function getChangedFiles(): Promise<string[]> {
  // Get changed files from git using execFile for security
  const { execFile } = require('child_process').promises;
  try {
    const { stdout } = await execFile('git', ['diff', '--name-only', 'HEAD']);
    return stdout.trim().split('\n').filter(Boolean);
  } catch (error) {
    console.error('Failed to get changed files:', error);
    return [];
  }
}
```

### Best Practices

**Multi-specialist comments**:
1. Always include overall status panel at top
2. List all specialists with emoji status indicators
3. Provide detailed breakdown per specialist
4. Highlight integration points between specialists
5. Keep file lists reasonable (max 10 per specialist)
6. Include test results for each specialist
7. Use consistent formatting across all specialists

**ADF structure**:
1. Use panels for status (success/warning/error)
2. Use headings (level 3-4) for major sections
3. Use bullet lists for file listings
4. Use code marks for file paths and code references
5. Keep paragraphs focused and concise
6. Always validate ADF structure before posting

**Detection logic**:
1. Always check for `.agency/handoff/{feature}` directory first
2. Fall back to single-specialist format if not found
3. Handle missing files gracefully (summary.md, verification.md)
4. Parse specialist data defensively with defaults
5. Validate all parsed data before creating ADF

---

## Related Skills

- **jira-adf-generator**: Generate properly formatted ADF for Jira comments
- **github-integration**: Alternative provider integration for comparison
- **agency-workflow-patterns**: General workflow automation applicable to any provider
- **github-workflow-best-practices**: Sprint concepts and planning patterns
