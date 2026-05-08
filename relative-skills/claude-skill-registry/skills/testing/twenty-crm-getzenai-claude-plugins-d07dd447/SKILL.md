---
name: twenty-crm
description: Full access to Twenty CRM (People, Companies, Opportunities, Tasks, Notes) using curl and the Twenty REST API directly - no MCP server or additional dependencies required.
---

# Twenty CRM Skill

Access Twenty CRM to manage people, companies, opportunities, tasks, and notes. Supports self-hosted instances with user-provided domain and API key.

## Capabilities

- List, search, create, update, and delete **People**
- List, search, create, update, and delete **Companies**
- List, search, create, update, and delete **Opportunities** (with stages like NEW_LEAD, QUALIFICATION, etc.)
- List, search, create, update, and delete **Tasks** (with statuses TODO, IN_PROGRESS, DONE)
- List, search, create, update, and delete **Notes**
- Link notes and tasks to opportunities, people, or companies
- Discover object schemas and custom fields via metadata API

## Pre-flight Check

Before making API calls, verify the user is authenticated:

```bash
bash $SKILL_PATH/check-auth.sh
```

Returns `USER_AUTHENTICATED` or `USER_NOT_AUTHENTICATED`.

## Scripts Reference

All scripts are located at `$SKILL_PATH/`. Replace `$SKILL_PATH` with the actual skill directory path.

### Metadata (Schema Discovery)

```bash
# List all object types with their fields
bash $SKILL_PATH/metadata/objects.sh [limit]

# Get specific object schema by ID
bash $SKILL_PATH/metadata/object.sh <object_id>
```

### Workspace Members

```bash
# List all workspace members (team users)
bash $SKILL_PATH/workspace-members/list.sh [limit]

# List workspace members with basic info (id, name, email)
bash $SKILL_PATH/workspace-members/me.sh
```

Use workspace member IDs for `ownerV2Id` and `assigneeId` fields.

### People

```bash
# List people (with optional filter, order, limit, depth)
bash $SKILL_PATH/people/list.sh [filter] [order_by] [limit] [depth]
# depth: 0 = basic fields (default), 1 = include relations

# Get person by ID
bash $SKILL_PATH/people/get.sh <person_id>

# Create person
bash $SKILL_PATH/people/create.sh '<json_data>'

# Update person
bash $SKILL_PATH/people/update.sh <person_id> '<json_data>'

# Delete person
bash $SKILL_PATH/people/delete.sh <person_id>
```

**Example - Create person:**

```bash
bash $SKILL_PATH/people/create.sh '{"name":{"firstName":"John","lastName":"Doe"},"emails":{"primaryEmail":"john@example.com"}}'
```

### Companies

```bash
# List companies
bash $SKILL_PATH/companies/list.sh [filter] [order_by] [limit] [depth]

# Get company by ID
bash $SKILL_PATH/companies/get.sh <company_id>

# Create company
bash $SKILL_PATH/companies/create.sh '<json_data>'

# Update company
bash $SKILL_PATH/companies/update.sh <company_id> '<json_data>'

# Delete company
bash $SKILL_PATH/companies/delete.sh <company_id>
```

### Opportunities

```bash
# List opportunities
bash $SKILL_PATH/opportunities/list.sh [filter] [order_by] [limit] [depth]

# Get opportunity by ID
bash $SKILL_PATH/opportunities/get.sh <opportunity_id>

# Create opportunity
bash $SKILL_PATH/opportunities/create.sh '<json_data>'

# Update opportunity
bash $SKILL_PATH/opportunities/update.sh <opportunity_id> '<json_data>'

# Delete opportunity
bash $SKILL_PATH/opportunities/delete.sh <opportunity_id>
```

**Stages** (may vary by instance - use metadata API to discover):

- NEW_LEAD, QUALIFICATION, IN_TEST_PHASE, PROPOSAL_NEGOTIATION
- CUSTOMER, AFTERSALES, DROP_OUT, WANTS_FEATURE

**Example - Find opportunities in NEW_LEAD stage:**

```bash
bash $SKILL_PATH/opportunities/list.sh 'stage[eq]:NEW_LEAD'
```

**Example - Find unowned opportunities:**

```bash
bash $SKILL_PATH/opportunities/list.sh 'ownerV2Id[is]:NULL'
```

### Tasks

```bash
# List tasks
bash $SKILL_PATH/tasks/list.sh [filter] [order_by] [limit] [depth]

# Get task by ID
bash $SKILL_PATH/tasks/get.sh <task_id>

# Create task
bash $SKILL_PATH/tasks/create.sh '<json_data>'

# Update task
bash $SKILL_PATH/tasks/update.sh <task_id> '<json_data>'

# Delete task
bash $SKILL_PATH/tasks/delete.sh <task_id>

# Link task to opportunity/person/company
bash $SKILL_PATH/tasks/link.sh <task_id> <target_type> <target_id>
```

**Statuses:** TODO, IN_PROGRESS, DONE

**Example - Create a follow-up task:**

```bash
bash $SKILL_PATH/tasks/create.sh '{"title":"Follow up call","status":"TODO","dueAt":"2024-12-20T10:00:00Z"}'
```

**Example - Link task to an opportunity:**

```bash
bash $SKILL_PATH/tasks/link.sh <task-id> opportunity <opportunity-id>
```

### Notes

```bash
# List notes
bash $SKILL_PATH/notes/list.sh [filter] [order_by] [limit] [depth]

# Get note by ID
bash $SKILL_PATH/notes/get.sh <note_id>

# Create note
bash $SKILL_PATH/notes/create.sh '<json_data>'

# Update note
bash $SKILL_PATH/notes/update.sh <note_id> '<json_data>'

# Delete note
bash $SKILL_PATH/notes/delete.sh <note_id>

# Link note to opportunity/person/company
bash $SKILL_PATH/notes/link.sh <note_id> <target_type> <target_id>
```

**Example - Create a note and link to opportunity:**

```bash
# Create note
bash $SKILL_PATH/notes/create.sh '{"title":"Meeting notes","bodyV2":{"markdown":"# Key discussion points\n- Budget approved\n- Timeline: Q1 2025"}}'

# Link to opportunity
bash $SKILL_PATH/notes/link.sh <note-id> opportunity <opportunity-id>
```

## Filtering Syntax

All list scripts accept a filter parameter using Twenty's filter syntax:

```
field[comparator]:value
```

**Comparators:**

- `eq` - equals
- `neq` - not equals
- `in` - in array, e.g., `stage[in]:[NEW_LEAD,QUALIFICATION]`
- `gt`, `gte`, `lt`, `lte` - greater/less than
- `like`, `ilike` - pattern matching (ilike is case-insensitive)
- `is` - NULL check, e.g., `ownerV2Id[is]:NULL`

**Advanced operators:**

- `and(...)` - AND conjunction
- `or(...)` - OR conjunction
- `not(...)` - negation

**Examples:**

```bash
# Find people by email domain
bash $SKILL_PATH/people/list.sh 'emails.primaryEmail[ilike]:%@example.com'

# Find opportunities in multiple stages
bash $SKILL_PATH/opportunities/list.sh 'stage[in]:[NEW_LEAD,QUALIFICATION]'

# Find tasks due this week
bash $SKILL_PATH/tasks/list.sh 'dueAt[lte]:2024-12-15' 'dueAt[AscNullsLast]'

# Complex filter with OR
bash $SKILL_PATH/opportunities/list.sh 'or(stage[eq]:NEW_LEAD,ownerV2Id[is]:NULL)'

# Find tasks by status
bash $SKILL_PATH/tasks/list.sh 'status[eq]:TODO'
```

## Ordering

The `order_by` parameter controls result sorting:

```
field[Direction]
```

**Directions:** AscNullsFirst, AscNullsLast, DescNullsFirst, DescNullsLast

**Example:**

```bash
bash $SKILL_PATH/opportunities/list.sh '' 'createdAt[DescNullsLast]' 20
```

## Setup Instructions

1. **Get your API key** from your Twenty instance:
   - Navigate to Settings → API & Webhooks (`/settings/api-webhooks`)
   - Generate a new API key

2. **Create the config file:**

   ```bash
   mkdir -p ~/.config/twenty-crm
   cat > ~/.config/twenty-crm/config.json << 'EOF'
   {
     "base_url": "https://your-twenty-instance.com",
     "api_key": "your-api-key-here"
   }
   EOF
   chmod 600 ~/.config/twenty-crm/config.json
   ```

3. **Verify authentication:**
   ```bash
   bash $SKILL_PATH/check-auth.sh
   ```

## Common Workflows

### Find opportunities and get contact emails

```bash
# 1. List opportunities in NEW_LEAD stage (use depth=1 to include contact info)
bash $SKILL_PATH/opportunities/list.sh 'stage[eq]:NEW_LEAD' '' 50 1

# 2. For a specific opportunity, get the pointOfContact person
bash $SKILL_PATH/people/get.sh <pointOfContactId>
```

### Create opportunity with person

```bash
# 1. Create or find the person
bash $SKILL_PATH/people/create.sh '{"name":{"firstName":"Jane","lastName":"Smith"},"emails":{"primaryEmail":"jane@company.com"}}'

# 2. Create opportunity with pointOfContactId
bash $SKILL_PATH/opportunities/create.sh '{"name":"New Deal","stage":"QUALIFICATION","pointOfContactId":"<person-id-from-step-1>"}'
```

### Add note to an opportunity

```bash
# 1. Create the note
bash $SKILL_PATH/notes/create.sh '{"title":"Call summary","bodyV2":{"markdown":"Discussed pricing options."}}'

# 2. Link note to opportunity
bash $SKILL_PATH/notes/link.sh <note-id> opportunity <opportunity-id>
```

### Create follow-up task for next week

```bash
# 1. Create task with due date
bash $SKILL_PATH/tasks/create.sh '{"title":"Schedule follow-up meeting","status":"TODO","dueAt":"2024-12-20T09:00:00Z"}'

# 2. Link to opportunity
bash $SKILL_PATH/tasks/link.sh <task-id> opportunity <opportunity-id>
```

## Discovering Custom Fields

Field names may vary between Twenty instances. Use the metadata API to discover the actual schema:

```bash
# List all objects to find their IDs
bash $SKILL_PATH/metadata/objects.sh

# Get detailed schema for opportunities (including custom fields)
bash $SKILL_PATH/metadata/object.sh <opportunity-object-id>
```

Look for fields with `type: "RELATION"` to find owner/assignee fields, and `type: "SELECT"` for stage-like fields with options.

## Troubleshooting

**Authentication fails:**

- Verify config file exists at `~/.config/twenty-crm/config.json`
- Check base_url doesn't have trailing slash
- Ensure API key is valid and not expired

**Empty results:**

- Check filter syntax - enum values should NOT be quoted: `stage[eq]:NEW_LEAD` not `stage[eq]:"NEW_LEAD"`
- Use metadata API to verify field names for your instance

**Permission denied:**

- API key may lack required scopes
- Check with your Twenty admin for API permissions
