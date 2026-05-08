---
name: workflows
description: |
  Build Glide workflows with automation, loops, conditions, queries, and background processes.
  Use when creating automations, processing data in bulk, building scheduled tasks, or integrating with external services.
---

# Glide Workflows

Workflows are Glide's automation engine for background processes, data transformations, and integrations. They run server-side without user interaction.

## What Workflows Do

Workflows automate tasks that would otherwise require manual work:
- Send notifications when data changes
- Process data in bulk using loops
- Connect to external APIs and services
- Run scheduled reports or cleanup tasks
- Transform and move data between tables
- Multi-step business processes

## When to Use Workflows

- **Event-driven automation**: "When a new order is created, send email confirmation"
- **Scheduled tasks**: "Every Monday at 9am, generate weekly report"
- **Bulk processing**: "For each pending invoice, calculate total and send reminder"
- **External integrations**: "Sync data from external API to Glide table"
- **Data transformation**: "When spreadsheet is uploaded, parse and distribute to multiple tables"

## Accessing Workflows

In Glide Builder:
1. Click **Workflows** tab in the top navigation
2. Click **"+ New Workflow"** to create
3. Each workflow has:
   - **Name** - descriptive label
   - **Trigger** - what starts the workflow
   - **Steps** - nodes that execute in sequence

## Triggers

Triggers determine when a workflow runs.

### Event Triggers

**Row Added**
- Runs when a new row is created in a table
- Access the new row's data in workflow steps
- Use case: Send welcome email when user signs up

**Row Updated**
- Runs when any column in a row changes
- Can filter to specific column changes
- Use case: Notify manager when order status changes to "Shipped"

**Row Deleted**
- Runs when a row is removed from a table
- Can access the deleted row's data
- Use case: Log deletions for audit trail

**Webhook**
- Runs when external service sends HTTP request to webhook URL
- Receives POST data as workflow input
- Use case: Stripe payment webhook triggers order fulfillment

### Scheduled Triggers

**Schedule**
- Runs on a recurring schedule (hourly, daily, weekly, monthly)
- Set specific time and timezone
- Use case: Every Sunday at midnight, archive completed tasks

**Custom Schedule (Cron)**
- Advanced scheduling using cron expressions
- Full control over timing
- Use case: `0 9 * * 1-5` = 9am weekdays only

### Manual Triggers

**Button Action**
- Triggered by user clicking a button in the app
- Useful for on-demand processing
- Use case: "Generate Report" button runs export workflow

**Form Submission**
- Triggered when form is submitted
- Access form data in workflow
- Use case: After contact form submission, create task and notify team

## Workflow Nodes

Nodes are the building blocks of workflows. They execute sequentially from top to bottom.

### Query Node

Fetch data from Glide tables to use in the workflow.

**Configuration:**
- **Table**: Which table to query
- **Filters**: Optional conditions to narrow results (e.g., Status = "Active")
- **Limit**: Max rows to return (useful for testing)
- **Columns**: Which columns to include (all by default)

**Output:**
Returns an array of row objects: `[{col1: val1, col2: val2}, ...]`

**Common uses:**
- Get all pending orders to process
- Find users matching criteria
- Fetch related data for processing

**Example pattern:**
```
Query Node → Get Orders where Status = "Pending"
  ↓
Loop Node → Process each order
```

### Loop Node

Iterate over an array, running child nodes for each item.

**Configuration:**
- **Array**: The data to loop over (typically from Query Node)
- **Item Name**: Reference name for current item (e.g., "order")
- **Max Iterations**: Safety limit to prevent runaway loops

**How it works:**
- Takes an array as input
- Runs all child nodes once for each array item
- Inside loop, access current item data via item reference
- Child nodes are indented under the loop

**Common uses:**
- Process each row from a Query
- Send email to each user in a list
- Create multiple rows based on template

**Example:**
```
Query → Get pending tasks
  ↓
Loop over tasks (item: "task")
  ├─ Condition → If task.priority = "High"
  │    └─ Send Email → Notify manager
  └─ Update Row → Mark task as "Processed"
```

### Condition Node

Add if/then logic to control workflow execution.

**Configuration:**
- **Condition**: Expression that evaluates to true/false
- **Then steps**: Nodes that run if condition is true
- **Else steps**: Nodes that run if condition is false

**Conditions can check:**
- Field values: `status = "approved"`
- Comparisons: `total > 100`
- Existence: `email is not empty`
- Combinations: `priority = "High" AND dueDate < today`

**Common uses:**
- Skip processing if data doesn't meet criteria
- Branch workflow based on values
- Prevent errors (e.g., only send email if email field isn't empty)
- Implement business rules

**Example:**
```
Condition → If order.total > 1000
  THEN:
    └─ Send Email → Notify VIP sales team
  ELSE:
    └─ Send Email → Notify standard sales team
```

### Set Column Node

Extract or transform data, often used to prepare data for other nodes.

**Configuration:**
- **Input**: The source data (object or array)
- **Column/Field**: Which field to extract
- **Operation**: Extract, Transform, Calculate

**Critical for Query Result Processing:**

When you query a table, you get an array of objects:
```json
[
  {email: "alice@example.com", name: "Alice", status: "Active"},
  {email: "bob@example.com", name: "Bob", status: "Active"}
]
```

To extract just the emails into a simple array:
```
Query Node → Get users where status = "Active"
  ↓
Set Column Node → Extract "email" column
  ↓
Result: ["alice@example.com", "bob@example.com"]
```

**Why this matters:**
- Many nodes expect simple arrays, not arrays of objects
- Email nodes want string array of addresses
- API calls may need specific field formats

**Common pattern: Query → Extract → Loop**
```
Query → Get customers
  ↓
Set Column → Extract customer.email
  ↓
Loop → For each email
    └─ Send Email → email
```

### Create Row Node

Add a new row to a table.

**Configuration:**
- **Table**: Target table
- **Column Values**: Data for each column

**Common uses:**
- Log workflow execution
- Create derived records
- Duplicate rows with modifications

**Example:**
```
Trigger: Order created
  ↓
Create Row → Add row to "Order Logs" table
  - Order ID: {trigger.orderID}
  - Timestamp: {now}
  - Status: "Processed"
```

### Update Row Node

Modify an existing row in a table.

**Configuration:**
- **Table**: Which table
- **Row**: Which row to update (by ID or from loop item)
- **Column Values**: New values to set

**Common uses:**
- Mark records as processed
- Update status after action
- Calculate and store derived values

**Example:**
```
Loop over pending orders (item: "order")
  ├─ API Call → Get shipping cost
  └─ Update Row → order
      - Shipping Cost: {API response}
      - Status: "Quoted"
```

### Delete Row Node

Remove a row from a table.

**Configuration:**
- **Table**: Which table
- **Row**: Which row to delete (by ID or from loop item)

**Common uses:**
- Clean up temporary data
- Archive old records
- Remove duplicates

### Send Email Node

Send email notifications.

**Configuration:**
- **To**: Recipient email(s) - can be array from Set Column
- **Subject**: Email subject line
- **Body**: Email content (plain text or HTML)
- **From**: Optional custom sender name

**Works with arrays:**
```
Set Column → Extract emails from query result
  ↓
Send Email → To: {extracted emails array}
```

**Common uses:**
- Notify users of status changes
- Send bulk announcements
- Alert admins of errors

### API Request Node

Call external web services via HTTP.

**Configuration:**
- **Method**: GET, POST, PUT, DELETE
- **URL**: API endpoint
- **Headers**: Authentication, Content-Type, etc.
- **Body**: Request payload (for POST/PUT)

**Response handling:**
- Store response in variable
- Use response data in subsequent nodes
- Parse JSON responses

**Common uses:**
- Fetch data from external API
- Send data to external system
- Trigger webhooks in other services
- Integration with Stripe, SendGrid, etc.

**Example:**
```
Trigger: Form submitted
  ↓
API Request → POST to Slack webhook
  - URL: https://hooks.slack.com/...
  - Body: {"text": "New form submission from {name}"}
```

### JavaScript Node

Run custom JavaScript code for complex logic.

**Use cases:**
- Advanced data transformation
- Complex calculations
- Custom parsing logic
- Validation rules

**Has access to:**
- Workflow variables
- Input data
- JavaScript standard library

**Example:**
```javascript
// Parse and validate phone number
const phone = input.phoneNumber;
const cleaned = phone.replace(/\D/g, '');
return cleaned.length === 10 ? cleaned : null;
```

### Wait/Delay Node

Pause workflow execution.

**Configuration:**
- **Duration**: How long to wait (seconds, minutes, hours, days)

**Common uses:**
- Rate limiting (wait between API calls)
- Scheduled follow-ups (wait 3 days, then send reminder)
- Throttling bulk operations

**Example:**
```
Loop over 1000 contacts
  ├─ Send Email → contact
  └─ Wait → 1 second (prevent rate limiting)
```

## Advanced Patterns

### Query → Extract Column → Loop Pattern

The most common workflow pattern for bulk processing:

```
Query Node → Get all users where status = "Active"
  Output: [{id: 1, email: "a@x.com", name: "Alice"}, ...]
  ↓
Set Column Node → Extract "email" field
  Output: ["a@x.com", "b@x.com", "c@x.com"]
  ↓
Loop Node → For each email
  Item: "email"
  ↓
  Send Email Node → To: {email}
    Subject: "Weekly Newsletter"
```

**Why extract the column?**
- Query returns full row objects
- Most action nodes (Email, API) need simple values
- Extracting creates a clean array of just the values you need

### Nested Loops for Multi-Level Processing

Process hierarchical data by nesting loops:

```
Query → Get all projects
  ↓
Loop over projects (item: "project")
  ↓
  Query → Get tasks where projectID = {project.id}
    ↓
  Loop over tasks (item: "task")
    ↓
    Condition → If task.status = "Overdue"
      ↓
      Send Email → Notify {task.assignee}
```

### Error Handling with Conditions

Prevent workflow failures by validating data:

```
Trigger: Form submission
  ↓
Condition → If email is not empty
  THEN:
    └─ Send Email → {email}
  ELSE:
    └─ Create Row → Error log
        - Message: "Missing email"
        - Form ID: {form.id}
```

### Batch Processing with Limits

Test with small batches before running on full dataset:

```
Query → Get pending invoices
  - Limit: 10 (for testing)
  ↓
Loop over invoices
  ↓
  API Request → Send to accounting system
  Wait → 500ms
  Update Row → Mark as "Synced"
```

Once tested, remove or increase the limit.

### Conditional Branching by Type

Handle different record types in one workflow:

```
Trigger: Row added to "Notifications" table
  ↓
Condition → If notificationType = "Email"
  THEN:
    └─ Send Email
  ELSE:
    Condition → If notificationType = "SMS"
      THEN:
        └─ API Request → Twilio SMS
      ELSE:
        └─ Create Row → Error log
```

### Data Aggregation

Collect results from loop and store:

```
Query → Get all orders from this month
  ↓
JavaScript Node:
  // Calculate total revenue
  let total = 0;
  for (const order of input.orders) {
    total += order.amount;
  }
  return {total, count: input.orders.length};
  ↓
Update Row → Monthly Stats table
  - Revenue: {total}
  - Order Count: {count}
```

## Testing Workflows

### Test Mode

Before enabling a workflow for production:

1. **Set Row Limits**: Add limit to Query nodes (e.g., 5 rows)
2. **Use Test Data**: Create test rows to trigger workflow
3. **Check Execution Logs**: View workflow runs in history
4. **Verify Output**: Check that data changes are correct

### Execution History

In Workflows tab:
- Click on a workflow to see execution history
- Each run shows:
  - Timestamp
  - Trigger source
  - Status (Success/Failed)
  - Execution time
  - Error messages (if failed)

### Debugging Failed Workflows

If a workflow fails:

1. **Check error message** in execution history
2. **Common issues:**
   - Missing required fields
   - API authentication failed
   - Invalid data format
   - Timeout (workflow took too long)
   - Rate limit exceeded
3. **Add logging**: Use Create Row to log progress
4. **Add conditions**: Validate data before risky operations
5. **Test incrementally**: Enable one node at a time

### Logging Pattern for Debugging

```
Query → Get pending items
  ↓
Create Row → Workflow Log
  - Message: "Found {count} items to process"
  - Timestamp: {now}
  ↓
Loop over items
  ↓
  [Process item]
  ↓
  Create Row → Workflow Log
    - Message: "Processed item {item.id}"
```

## Performance & Limits

### Quota Costs

Workflows consume update quota:
- Each row read: 0.001 updates
- Each row write: 0.01 updates
- API calls: May have their own limits

### Timeouts

- Workflows timeout after 5 minutes
- For long-running tasks, use Wait nodes strategically
- Consider splitting into multiple workflows

### Rate Limiting

When calling external APIs:
- Add Wait nodes between calls
- Batch requests when possible
- Handle rate limit errors gracefully

### Best Practices

1. **Test with limits**: Use Query limits during development
2. **Add conditions**: Validate data before processing
3. **Log progress**: Create audit trail for debugging
4. **Handle errors**: Use conditions to catch edge cases
5. **Batch operations**: Process in chunks if dataset is large
6. **Use indexes**: Filter queries to reduce data scanned
7. **Avoid infinite loops**: Always set max iterations on loops
8. **Monitor quota**: Track update usage in large workflows

## Common Use Cases

### Send Welcome Email on Signup

```
Trigger: Row added to Users table
  ↓
Condition → If user.email is not empty
  THEN:
    Send Email
      - To: {user.email}
      - Subject: "Welcome to {appName}!"
      - Body: "Hi {user.name}, thanks for joining..."
```

### Weekly Digest Email

```
Trigger: Schedule (Every Monday 9am)
  ↓
Query → Get users where emailPreference = "Weekly"
  ↓
Set Column → Extract email
  ↓
Query → Get new content from last 7 days
  ↓
JavaScript → Format content into HTML
  ↓
Send Email
  - To: {user emails array}
  - Subject: "Your Weekly Digest"
  - Body: {formatted HTML}
```

### Sync External Data

```
Trigger: Schedule (Every hour)
  ↓
API Request → GET from external API
  - URL: https://api.example.com/products
  ↓
Loop over API response items
  ↓
  Query → Check if product exists (by externalID)
  ↓
  Condition → If product exists
    THEN:
      Update Row → Update price, stock
    ELSE:
      Create Row → Add new product
```

### Order Fulfillment

```
Trigger: Order status updated to "Paid"
  ↓
Condition → If order.total > 0
  THEN:
    API Request → POST to shipping service
      - Create shipping label
    ↓
    Update Row → order
      - Tracking Number: {API response}
      - Status: "Shipped"
    ↓
    Send Email → order.customerEmail
      - Subject: "Order shipped!"
      - Body: "Track your package: {trackingNumber}"
```

### Data Cleanup

```
Trigger: Schedule (Daily at 2am)
  ↓
Query → Get rows where createdAt < 90 days ago AND status = "Temporary"
  ↓
Loop over old rows
  ↓
  Delete Row → item
  ↓
Create Row → Audit Log
  - Message: "Deleted {count} old temporary records"
  - Timestamp: {now}
```

## Workflows vs. Computed Columns

Know when to use each:

| Feature | Computed Column | Workflow |
|---------|----------------|----------|
| **Timing** | Instant (during app use) | Background (delayed) |
| **Use case** | Calculations, lookups | Automation, notifications |
| **Scope** | Single row | Multiple rows, external systems |
| **Examples** | Total = Price × Qty | Send email when status changes |

**Use computed columns when:**
- Calculation based on current row
- Need instant result in UI
- Simple logic (math, if-then, lookup)

**Use workflows when:**
- Triggering external actions
- Processing multiple rows
- Sending notifications
- Scheduled tasks
- Complex multi-step processes

## Summary

Workflows are powerful for:
- ✅ Event-driven automation
- ✅ Scheduled tasks
- ✅ Bulk data processing
- ✅ External integrations
- ✅ Multi-step business processes

Key patterns:
- **Query → Extract → Loop** for bulk processing
- **Condition nodes** for validation and branching
- **Set Column** to convert query results to arrays
- **Wait nodes** for rate limiting
- **Logging** for debugging

Always test with limits before running on production data.
