---
name: dbt-projects-snowflake-setup
description:
  Step-by-step setup guide for dbt Projects on Snowflake including prerequisites, external access
  integration, Git API integration, event table configuration, and automated scheduling. Use this
  skill when setting up dbt Projects on Snowflake for the first time or troubleshooting setup
  issues.
---

# dbt Projects on Snowflake Setup

Complete step-by-step guide for setting up dbt Projects on Snowflake from beginning to end.

## When to Use This Skill

Activate this skill when users ask about:

- Setting up dbt Projects on Snowflake for the first time
- Configuring external access integrations for dbt packages
- Setting up Git API integrations (GitHub, GitLab, Azure DevOps)
- Creating workspaces in Snowsight
- Configuring event table monitoring for dbt Projects
- Scheduling automated dbt runs with Snowflake Tasks
- Troubleshooting dbt Projects setup issues

## Prerequisites

**1. Snowflake Account**

- Account with ACCOUNTADMIN permissions for initial setup
- Personal database enabled (default for new accounts)

**2. Git Repository**

- GitHub, GitLab, or Azure DevOps repository
- Personal Access Token (PAT) for authentication

---

## Setup Steps

### Step 1: Enable Personal Database

```sql
ALTER ACCOUNT SET ENABLE_PERSONAL_DATABASE = TRUE;
```

---

### Step 2: Create External Access Integration

For `dbt deps` to work, allow external access to dbt packages:

```sql
-- Create NETWORK RULE
CREATE OR REPLACE NETWORK RULE dbt_network_rule
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = (
    'hub.getdbt.com',
    'codeload.github.com'
  );

-- Create EXTERNAL ACCESS INTEGRATION
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION dbt_ext_access
  ALLOWED_NETWORK_RULES = (dbt_network_rule)
  ENABLED = TRUE;
```

**Purpose:** Allows dbt to download packages from hub.getdbt.com and GitHub during `dbt deps`
execution.

---

### Step 3: Create Git API Integration

Choose the appropriate integration for your Git provider:

#### GitHub:

```sql
CREATE OR REPLACE API INTEGRATION git_api_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = (
    'https://github.com/',
    'https://github.com/organization/'
  );
```

#### GitLab:

```sql
CREATE OR REPLACE API INTEGRATION git_api_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = (
    'https://gitlab.com/'
  );
```

#### Azure DevOps:

```sql
CREATE OR REPLACE API INTEGRATION git_api_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = (
    'https://dev.azure.com/'
  );
```

**Purpose:** Allows Snowflake to connect to your Git repository for workspace creation and project
deployment.

---

### Step 4: Create Workspace in Snowsight

1. Navigate to Projects → My Workspace
2. Click My Workspace → Create Workspace → From Git repository
3. Enter:
   - Repository URL
   - API integration name (`git_api_integration`)
   - Authentication (PAT or OAuth)

**Note:** Workspace creation is only available through the Snowsight UI. The Snowflake CLI does not
have commands for creating workspaces.

---

### Step 5: Configure profiles.yml

In your workspace, configure `profiles.yml`:

```yaml
my_dbt_project:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: "" # Uses current account context
      user: "" # Uses current user context
      warehouse: MY_WAREHOUSE
      database: MY_DATABASE
      schema: MY_SCHEMA
      role: MY_ROLE
```

**Important Notes:**

- Leave `account` and `user` empty - Snowflake provides these automatically
- Specify your warehouse, database, schema, and role
- For multiple environments, add additional outputs (staging, prod)

---

### Step 6: Deploy as DBT PROJECT Object

**UI Method:**

- Use the Deploy button in workspace

**CLI Method:**

```bash
snow dbt deploy my_project --source .
```

**Verify Deployment:**

```sql
SHOW DBT PROJECTS IN DATABASE MY_DATABASE;
```

---

## Event Table Monitoring Configuration (Optional but Recommended)

Monitor dbt Projects execution using event tables that capture telemetry data (logs, traces,
metrics) via the [OpenTelemetry data model](https://opentelemetry.io/).

### Critical Pattern: Database-Level Configuration

**Always set event tables at the DATABASE level** (not schema, not account-wide):

```sql
-- Step 1: Create event table (can be in different database)
CREATE EVENT TABLE IF NOT EXISTS MY_LOGGING_DATABASE.MY_LOGGING_SCHEMA.EVENT_LOG;

-- Step 2: Set event table where dbt Projects are deployed at DATABASE level
ALTER DATABASE MY_DBT_PROJECT_DATABASE
  SET EVENT_TABLE = MY_LOGGING_DATABASE.MY_LOGGING_SCHEMA.EVENT_LOG;

-- Step 3: Configure logging levels for the schema where dbt Project is deployed
ALTER SCHEMA MY_DBT_PROJECT_DATABASE.MY_DBT_PROJECT_SCHEMA SET LOG_LEVEL = 'INFO';
ALTER SCHEMA MY_DBT_PROJECT_DATABASE.MY_DBT_PROJECT_SCHEMA SET TRACE_LEVEL = 'ALWAYS';
ALTER SCHEMA MY_DBT_PROJECT_DATABASE.MY_DBT_PROJECT_SCHEMA SET METRIC_LEVEL = 'ALL';
```

### Why DATABASE Level?

✅ **DO:**

- Set at DATABASE level for project-level isolation
- Captures all dbt Project executions in that database
- Avoids account-wide noise
- Provides clear project boundaries

❌ **DON'T:**

- Set at account level (too much noise from all databases)
- Set at schema level (misses cross-schema operations)

### Verify Event Capture

After configuration, verify events are being captured:

```sql
-- Check recent events
SELECT
    TIMESTAMP,
    RESOURCE_ATTRIBUTES['snow.executable.name']::VARCHAR AS project_name,
    RECORD_TYPE,
    RECORD['severity_text']::VARCHAR AS severity,
    VALUE::VARCHAR AS message
FROM MY_LOGGING_DATABASE.MY_LOGGING_SCHEMA.EVENT_LOG
WHERE RESOURCE_ATTRIBUTES['snow.executable.type']::VARCHAR = 'DBT_PROJECT'
  AND TIMESTAMP >= DATEADD(hour, -1, CURRENT_TIMESTAMP())
ORDER BY TIMESTAMP DESC
LIMIT 10;
```

**For complete monitoring guide**, see the **`dbt-projects-on-snowflake` skill** for:

- Ready-to-use monitoring SQL scripts
- Best practices for event table management
- Performance metrics queries
- Alerting strategies
- Troubleshooting guide

---

## Scheduling Automated Runs (Optional)

Create a Snowflake task to run dbt on a schedule:

```sql
CREATE OR REPLACE TASK my_dbt_daily_task
  WAREHOUSE = 'MY_WAREHOUSE'
  SCHEDULE = 'USING CRON 0 6 * * * UTC'  -- Daily at 6 AM UTC
AS
  EXECUTE DBT PROJECT MY_DATABASE.MY_SCHEMA.MY_DBT_PROJECT
    args='build';

-- Enable the task
ALTER TASK my_dbt_daily_task RESUME;
```

### Customization Options:

| Parameter               | Purpose                      | Example                               |
| ----------------------- | ---------------------------- | ------------------------------------- |
| Task name               | Identifies the scheduled job | `my_dbt_daily_task`                   |
| Warehouse               | Compute resources            | `MY_WAREHOUSE`                        |
| Schedule                | CRON expression              | `0 6 * * * UTC` (daily 6 AM)          |
| Database/Schema/Project | Target dbt project           | `MY_DB.MY_SCHEMA.MY_PROJECT`          |
| Args                    | dbt command arguments        | `'build'`, `'run --select tag:daily'` |

### Common Schedules:

```sql
-- Hourly
SCHEDULE = 'USING CRON 0 * * * * UTC'

-- Daily at 2 AM
SCHEDULE = 'USING CRON 0 2 * * * UTC'

-- Every 15 minutes
SCHEDULE = '15 MINUTE'

-- Weekly on Monday at 8 AM
SCHEDULE = 'USING CRON 0 8 * * 1 UTC'
```

### Monitor Task Execution:

```sql
-- View task history
SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
  SCHEDULED_TIME_RANGE_START => DATEADD('day', -7, CURRENT_TIMESTAMP()),
  TASK_NAME => 'MY_DBT_DAILY_TASK'
))
ORDER BY SCHEDULED_TIME DESC;
```

---

## Troubleshooting

### SSH/Network Issues

**Problem:** Can't download dbt packages or connect to Git

**Solutions:**

1. Verify external access integration exists:

   ```sql
   SHOW EXTERNAL ACCESS INTEGRATIONS;
   ```

2. Check network rules include required hosts:

   ```sql
   DESCRIBE EXTERNAL ACCESS INTEGRATION dbt_ext_access;
   ```

3. Ensure required hosts are in VALUE_LIST:
   - `hub.getdbt.com` (for dbt packages)
   - `codeload.github.com` (for GitHub packages)

### Authentication Failures

**Problem:** Git authentication fails in workspace creation

**Solutions:**

1. Verify PAT has correct scopes:

   - GitHub: `repo` scope
   - GitLab: `read_repository` scope
   - Azure DevOps: `Code (Read)` permission

2. Check API integration is created:

   ```sql
   SHOW API INTEGRATIONS;
   ```

3. Verify API allowed prefixes match your repository URL

### Package Installation Issues

**Problem:** `dbt deps` fails in workspace

**Solutions:**

1. Run `dbt deps` manually in workspace before deployment
2. Ensure external access integration is enabled:
   ```sql
   ALTER EXTERNAL ACCESS INTEGRATION dbt_ext_access SET ENABLED = TRUE;
   ```
3. Check package versions are compatible with dbt version in Snowflake

### Event Table Not Capturing Data

**Problem:** No events appearing in event table

**Solutions:**

1. Verify event table is set at DATABASE level:

   ```sql
   SHOW PARAMETERS LIKE 'EVENT_TABLE' IN DATABASE MY_DATABASE;
   ```

2. Check logging levels are set for schema:

   ```sql
   SHOW PARAMETERS LIKE '%_LEVEL' IN SCHEMA MY_DATABASE.MY_SCHEMA;
   ```

3. Ensure dbt Project has executed at least once after configuration

4. Query with correct filter:
   ```sql
   WHERE RESOURCE_ATTRIBUTES['snow.executable.type']::VARCHAR = 'DBT_PROJECT'
   ```

### Workspace Creation Fails

**Problem:** Can't create workspace from Git repository

**Solutions:**

1. Verify personal database is enabled:

   ```sql
   SHOW PARAMETERS LIKE 'ENABLE_PERSONAL_DATABASE' IN ACCOUNT;
   ```

2. Check you have required role (ACCOUNTADMIN or sufficient grants)

3. Ensure Git repository URL is correct and accessible

4. Verify Git API integration exists and has correct allowed prefixes:

   ```sql
   SHOW API INTEGRATIONS;
   DESCRIBE API INTEGRATION git_api_integration;
   ```

5. Check PAT/OAuth token has correct permissions for the repository

---

## Best Practices

### Security

✅ **DO:**

- Use key pair authentication for production deployments
- Rotate PATs regularly
- Use minimal scopes on PATs
- Set up separate integrations for dev/prod
- Use role-based access control

❌ **DON'T:**

- Share PATs between team members
- Use ACCOUNTADMIN for routine operations
- Grant excessive permissions to API integrations
- Hardcode credentials in profiles.yml

### Organization

✅ **DO:**

- Use consistent naming conventions (e.g., `{env}_dbt_project`)
- Organize projects by database
- Document integration configurations
- Set up event tables from the start
- Use separate warehouses for dev/prod

❌ **DON'T:**

- Mix development and production in same database
- Skip event table configuration
- Use default warehouse for all environments
- Deploy without testing in workspace first

### Monitoring

✅ **DO:**

- Configure event tables at database level
- Set appropriate log/trace/metric levels
- Query event tables regularly to verify capture
- Set up alerts for failures
- Archive old event data periodically

❌ **DON'T:**

- Set event tables at account level (too noisy)
- Ignore event table configuration
- Set all levels to DEBUG (storage bloat)
- Keep event data indefinitely

---

## Quick Setup Checklist

- [ ] ✅ Enable personal database
- [ ] ✅ Create external access integration (for dbt deps)
- [ ] ✅ Create Git API integration
- [ ] ✅ Create workspace from Git repository
- [ ] ✅ Configure profiles.yml
- [ ] ✅ Test in workspace
- [ ] ✅ Deploy as DBT PROJECT object
- [ ] ✅ Configure event table (recommended)
- [ ] ✅ Verify deployment with `SHOW DBT PROJECTS`
- [ ] ✅ Test execution with `EXECUTE DBT PROJECT`
- [ ] ✅ Set up scheduled tasks (if needed)
- [ ] ✅ Configure monitoring queries

---

## Related Skills

- `dbt-projects-on-snowflake` skill - Complete monitoring, execution, and management guide
- `dbt-core` skill - dbt-core setup and profiles.yml configuration
- `snowflake-connections` skill - Snowflake authentication and connection configuration
- `snowflake-cli` skill - Snowflake CLI commands and operations

---

**Goal:** Transform AI agents into experts at setting up dbt Projects on Snowflake from scratch with
proper integrations, monitoring, and automation configured from day one.
