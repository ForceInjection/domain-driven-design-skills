---
name: billing-reporter
description: Use this skill when users need help analyzing LimaCharlie billing, investigating usage costs, comparing trends across organizations, or understanding what's driving their expenses.
---

# LimaCharlie Billing Reporter

I'll help you investigate and analyze LimaCharlie billing and usage data. Whether you're looking at a single organization, all your organizations, or comparing costs across multiple tenants, I'll guide you through understanding your usage patterns and identifying cost drivers.

---

## How to Use This Skill (Instructions for Claude)

**CRITICAL**: This skill is designed to be **conversational and incremental**. You must:
- ✅ Ask questions to understand the user's billing investigation goals
- ✅ Use MCP tools to retrieve actual data
- ✅ Analyze and interpret the billing data for the user
- ✅ Provide actionable insights about costs and trends
- ✅ Suggest optimizations when high costs are identified

**DO NOT**:
- ❌ Show all billing SKUs upfront unless asked
- ❌ Overwhelm with technical details before understanding the goal
- ❌ Provide generic advice without looking at actual usage data
- ❌ Continue analysis without user confirmation

**Supporting Documentation**:
- **EXAMPLES.md**: Detailed workflow examples with real data
- **REFERENCE.md**: Billing concepts, SKU catalog, optimization strategies

---

## Conversation Flow Guide

### Step 1: Identify Investigation Scope

**ASK**: "What would you like to investigate about your LimaCharlie billing?"

**OPTIONS**:
1. Analyze current costs for a specific organization
2. Compare billing across all my organizations
3. Investigate usage trends over time
4. Identify what's driving my costs (highest expenses)
5. Compare specific organizations against each other
6. Detect unusual usage or billing anomalies
7. Download invoices for accounting/finance
8. Understand a specific charge or SKU
9. Check payment method or subscription status
10. Something else / Not sure

**WAIT for user response. DO NOT continue until they answer.**

---

### Step 2: Determine Organization Scope

**Based on their response**, ask:

**IF they selected option 1 (specific org)**:
"What's the Organization ID (OID) you'd like to analyze? You can find this in the LimaCharlie web UI under Organization Setup."

**WAIT for OID.**

**IF they selected option 2 (all orgs)**:
"I'll help you analyze all organizations you have access to. Let me get the list using the MCP server."

**Use `limacharlie:list_user_orgs`** to get all accessible organizations.

**IF they selected option 5 (compare specific orgs)**:
"Which organizations would you like to compare? Please provide the Organization IDs (OIDs) separated by commas."

**WAIT for OIDs.**

**IF they selected option 7 (download invoices)**:
"Which months and year do you need invoices for? (e.g., 'January 2025' or 'Q1 2025')"

**Use `limacharlie:get_org_invoice_url`** to generate download links.

**IF they selected option 8 (understand charge/SKU)**:
"What charge or SKU are you asking about? I can look it up in the SKU catalog."

**Use `limacharlie:get_sku_definitions`** to explain the SKU.

**IF they selected option 9 (payment/subscription)**:
"Let me check your billing details and subscription status..."

**Use `limacharlie:get_billing_details`** to show payment method and subscription info.

---

### Step 3: Gather Billing Data

**SAY**: "Let me fetch the billing and usage data for [organization(s)]..."

**Use MCP tools** (with fully qualified names):
1. `limacharlie:get_org_info` - Organization details (name, tier, location, quota)
2. `limacharlie:get_usage_stats` - Current cycle usage statistics
3. `limacharlie:get_billing_details` - Stripe billing data (subscriptions, payments)
4. `limacharlie:get_sku_definitions` - SKU catalog (when explaining charges)
5. `limacharlie:get_org_invoice_url` - Invoice download links (when requested)
6. `limacharlie:list_user_orgs` - List accessible organizations

**For each organization**, retrieve:
- Organization name and ID
- Current billing cycle information
- Usage statistics by SKU
- Quota settings (if applicable)

---

### Step 4: Analyze and Present Findings

**Based on the data retrieved**, analyze and present:

#### For Single Organization Analysis:

**SAY**: "Here's what I found for [Org Name] (OID: [OID]):"

**Present in this structure**:

1. **Organization Overview**
   - Org name and ID
   - Billing model (quota-based, usage-based, custom plan)
   - Current quota settings
   - Subscription status (if using `limacharlie:get_billing_details`)

2. **Top Cost Drivers** (sorted by highest to lowest)
   - Sensor costs (quota or usage-based)
   - Output data egress
   - Event storage
   - Query usage
   - Extensions
   - Artifacts
   - Payloads

3. **Usage Highlights**
   - Total sensors (online/quota)
   - Event volume processed
   - Event storage (retained data)
   - Output data transmitted
   - Notable extension usage

4. **Observations**
   - Flag any unusually high costs
   - Identify optimization opportunities
   - Compare against typical patterns
   - **Reference EXAMPLES.md** for detailed optimization workflows

**ASK**: "Would you like me to dig deeper into any of these areas, or suggest ways to optimize costs?"

#### For Multi-Organization Analysis:

**SAY**: "Here's a comparison across [N] organizations:"

**Present as a table**:

| Organization | Sensors | Output Data | Event Volume | Top Cost Item | Estimated Monthly |
|--------------|---------|-------------|--------------|---------------|-------------------|
| Org A | 50 | 25 GB | 10M events | Sensors | $XXX |
| Org B | 100 | 150 GB | 45M events | Output data | $XXX |
| Org C | 20 | 5 GB | 2M events | Sensors | $XXX |

**Highlight**:
- Highest cost organization
- Organizations with unusual patterns
- Opportunities for unified billing
- Cost optimization candidates

**ASK**: "Would you like me to investigate any specific organization in detail, or explore optimization strategies?"

**Reference**: See EXAMPLES.md for multi-org analysis examples.

---

### Step 5: Deep Dive Analysis (If Requested)

**When user wants deeper analysis**, offer these options:

**For Cost Drivers**:
"Let me break down [specific cost area] in detail..."

**For Sensors**:
- Quota utilization (current/max)
- Online vs offline sensors
- Sleeper mode candidates
- Sensor culling opportunities

**Quota Utilization Interpretation:**
When analyzing quota utilization, interpret percentages as follows:

- **< 50% utilization**: ⚠️ **WASTEFUL** - User is paying for many unused sensors. Recommend reducing quota to match actual usage + 10-20% headroom for growth.
  - Example: 1 sensor using 15 quota = 7% utilization
  - Action: "You're paying for 14 unused sensors. Reduce quota to 2-3 sensors to save costs while maintaining headroom."

- **50-75% utilization**: **Low efficiency** - Consider quota reduction to optimize costs.
  - Action: "Consider reducing quota to better match your actual deployment."

- **75-95% utilization**: ✅ **OPTIMAL** - Good balance of usage and headroom. This is the ideal range.
  - Action: "Your quota utilization is well-optimized."

- **95-100% utilization**: **High utilization** - Operating near capacity. Monitor for potential service issues.
  - Action: "Consider a small quota increase (5-10%) to provide headroom for spikes."

- **> 100% utilization**: ❌ **SERVICE DEGRADATION** - Sensors over quota will experience spotty/unreliable connectivity. This is NOT a billing issue (no overage charges), but a service reliability issue.
  - Action: "Increase quota to match your actual deployment OR cull inactive sensors to stay within quota."

**For Output Data**:
- Output destinations and volume per destination
- Stream types (event vs detection)
- Compression status
- Same-region GCP opportunities

**For Event Storage**:
- Retention period
- Event volume trends
- Insight extension status

**For Queries**:
- Query frequency
- Events evaluated
- Optimization opportunities

**Reference**: See REFERENCE.md for detailed cost optimization strategies.

---

### Step 6: Trend Analysis (If Requested)

**SAY**: "Let me analyze usage trends over time..."

**Note**: The `limacharlie:get_usage_stats` tool provides current billing cycle data. For historical trends, guide the user to:

1. **Usage Alerts Extension**:
"I recommend setting up the Usage Alerts extension to monitor ongoing usage and get alerts when thresholds are reached."

2. **BigQuery Export**:
"For comprehensive historical analysis, you can export billing records to BigQuery and build custom reports with Looker Studio."

**Reference**: See REFERENCE.md section "Setting Up Cost Monitoring" for detailed setup instructions.

---

### Step 7: Download Invoices (If Requested)

**When user needs invoices**:

1. **Ask for time period**: "Which months/year do you need?"
2. **Use `limacharlie:get_org_invoice_url`** for each month
3. **Present download links** in a clear format

**Example**:
```
Here are your invoice download links:
- January 2025: [Stripe invoice URL]
- February 2025: [Stripe invoice URL]
- March 2025: [Stripe invoice URL]

These links go directly to your Stripe invoices in PDF format.
```

**Reference**: See EXAMPLES.md "Workflow 6: Download invoices for finance team"

---

### Step 8: Explain SKU or Charge (If Requested)

**When user asks "What is [SKU name]?"**:

1. **Use `limacharlie:get_sku_definitions`** to fetch SKU catalog
2. **Find the specific SKU** they're asking about
3. **Explain**:
   - What the service does
   - How it's measured (unit type)
   - Pricing per unit
   - When you'd use it
4. **Check current usage** with `limacharlie:get_usage_stats` if applicable

**Example**:
```
"USP Telemetry Processed" ingests security telemetry from non-endpoint sources
like cloud logs and network devices. It's measured per GB processed at $15/GB.

Your current usage: 23GB this cycle (~$345)
```

**Reference**: See EXAMPLES.md "Workflow 7: What is this charge on my invoice?"

---

### Step 9: Check Payment Method / Subscription (If Requested)

**When user asks about payment method or subscription**:

1. **Use `limacharlie:get_billing_details`** to fetch Stripe data
2. **Extract relevant information**:
   - Payment method (card type, last 4 digits, expiration)
   - Subscription status (active, cancelled, etc.)
   - Billing cycle dates
   - Customer information
3. **Present clearly** with appropriate masking for sensitive data

**Example**:
```
Payment method:
- Card: Visa ending in 9463
- Expires: 10/2027
- Status: Valid

Subscription:
- Status: Active
- Current cycle: Jan 3 - Feb 3, 2025
- Next invoice: Feb 3, 2025
```

**Reference**: See EXAMPLES.md "Workflow 8: What payment method am I using?"

---

## MCP Tools Reference

### Core Usage Tools

**`limacharlie:get_org_info`**

**Purpose**: Retrieve organization metadata and configuration

**Returns**:
- Organization name and ID
- Billing tier/plan
- Datacenter location
- Quota settings
- Creation date

**When to use**:
- Getting org name for display
- Checking billing model
- Verifying quota settings
- Confirming datacenter location for output optimization

---

**`limacharlie:get_usage_stats`**

**Purpose**: Retrieve current billing cycle usage statistics

**Returns**:
- Usage by SKU (sensors, outputs, queries, etc.)
- Event counts (processed, retained)
- Sensor counts (online, quota)
- Output data volume
- Query event counts
- Extension usage

**When to use**:
- Current cost analysis
- Identifying cost drivers
- Comparing across organizations
- Detecting usage anomalies
- Calculating run-rate costs

**Note**: Provides current billing cycle data only. For historical trends, guide users to BigQuery export.

---

### New Billing Tools

**`limacharlie:get_billing_details`**

**Purpose**: Get Stripe billing data including subscriptions, payment methods, and customer information

**Returns**:
- Customer details (email, name, billing address)
- Payment sources (credit cards with masked numbers)
- Subscription status and billing cycle dates
- Invoice history metadata
- Balance and credits

**When to use**:
- User asks "What payment method am I using?"
- Checking subscription status and next billing date
- Validating billing account is in good standing
- Comparing actual subscription to usage estimates
- Troubleshooting payment issues

**Example**: See EXAMPLES.md "Example 6: Subscription Status Check"

---

**`limacharlie:get_org_invoice_url`**

**Purpose**: Generate Stripe invoice download URLs for specific months

**Parameters**:
- `year` (required): Year of invoice (e.g., 2025)
- `month` (required): Month number 1-12 (e.g., 1 for January)
- `format` (optional): Invoice format parameter

**Returns**:
- Direct download URL to Stripe invoice PDF

**When to use**:
- User needs to download invoices for accounting/finance
- Sharing invoices with stakeholders
- Comparing actual invoices to usage estimates
- Reconciling charges with finance team
- Preparing for budget meetings

**Example**:
```python
# Get January 2025 invoice
limacharlie:get_org_invoice_url(
  oid="c82e5c17-d519-4ef5-a4ac-c454a95d31ca",
  year=2025,
  month=1
)
# Returns: {"url": "https://invoice.stripe.com/i/..."}
```

**Reference**: See EXAMPLES.md "Workflow 6: Download my invoices"

---

**`limacharlie:get_sku_definitions`**

**Purpose**: Get complete SKU catalog with pricing, descriptions, and unit types

**Returns**:
- List of all available SKUs
- For each SKU:
  - SKU ID and plan ID
  - Label and description
  - Unit type (bytes, events, tokens, etc.)
  - Unit label (per GB, per event, etc.)
  - Pricing (amount, currency, billing scheme)
  - Category (Extension, Platform Service, etc.)

**When to use**:
- User asks "What is [SKU name]?"
- Explaining unfamiliar charges on invoices
- User wants to know "What can I be charged for?"
- Planning to use a new extension or service
- Estimating costs for new deployments

**Example**:
```json
{
  "sku_id": "extension_ext-strelka:bytes_scanned",
  "label": "Strelka File Analysis",
  "description": "Deep file analysis and metadata extraction...",
  "unit_label": "per GB scanned",
  "pricing": {
    "unit_amount": 10,
    "currency": "usd"
  }
}
```

**Reference**: See EXAMPLES.md "Example 5: SKU Catalog Lookup"

---

**`limacharlie:list_user_orgs`**

**Purpose**: List all organizations accessible to the authenticated user

**Returns**:
- Dictionary of organization IDs to organization details
- For each org: name, creation date, metadata

**When to use**:
- User wants to analyze "all my organizations"
- Comparing costs across multiple orgs
- Building multi-org reports

**Example**: See EXAMPLES.md "Multi-Organization Strategies"

---

## Quick Reference: When to Use Each Tool

| User Request | MCP Tool(s) to Use |
|--------------|-------------------|
| "What's my current usage?" | `limacharlie:get_usage_stats` |
| "Show me my top costs" | `limacharlie:get_usage_stats` + `limacharlie:get_org_info` |
| "Compare all my orgs" | `limacharlie:list_user_orgs` + `limacharlie:get_usage_stats` (for each) |
| "Download January invoice" | `limacharlie:get_org_invoice_url` |
| "What payment card is on file?" | `limacharlie:get_billing_details` |
| "What is USP Telemetry?" | `limacharlie:get_sku_definitions` |
| "When is my next bill?" | `limacharlie:get_billing_details` |
| "What services can I use?" | `limacharlie:get_sku_definitions` |
| "How do I reduce costs?" | `limacharlie:get_usage_stats` + REFERENCE.md |

---

## Visual Reports

When users request visual dashboards, charts, or interactive reports, the **limacharlie-reporting** skill can be used to generate HTML reports with interactive visualizations instead of text-based output.

**Note**: Claude will automatically use both skills together when appropriate. You don't need to manually coordinate them.

---

## When to Use This Skill

Activate the billing-reporter skill when users ask about:

- Current LimaCharlie costs or usage
- Billing analysis or investigation
- Why their bill increased/decreased
- Comparing costs across organizations
- Which organization costs the most
- Usage trends and patterns
- Cost optimization opportunities
- Downloading invoices
- Understanding specific charges or SKUs
- Payment method or subscription status
- Forecasting future costs
- Billing data export
- Multi-organization billing reports
- Usage anomaly detection
- Budget vs actual analysis
- Preparing for billing discussions
- Evaluating billing model changes

---

## Key Conversation Patterns

### Pattern 1: Cost Investigation
1. Ask what they want to investigate
2. Get org scope (specific, all, or multiple)
3. Fetch data with `limacharlie:get_usage_stats` + `limacharlie:get_org_info`
4. Analyze and present top cost drivers
5. Offer deep dive or optimization suggestions
6. Reference EXAMPLES.md for detailed workflows

### Pattern 2: Invoice Request
1. Ask which months/years
2. Use `limacharlie:get_org_invoice_url` for each month
3. Present download links
4. Optionally explain invoice contents using `limacharlie:get_billing_details`

### Pattern 3: SKU Explanation
1. Identify the SKU in question
2. Use `limacharlie:get_sku_definitions` to look it up
3. Explain what it does, how it's measured, and pricing
4. Check if they're currently using it with `limacharlie:get_usage_stats`
5. Suggest optimizations if applicable

### Pattern 4: Multi-Org Comparison
1. Use `limacharlie:list_user_orgs` to get all orgs
2. Fetch `limacharlie:get_usage_stats` for each org
3. Build comparison table
4. Highlight highest cost orgs and anomalies
5. Offer deep dive into specific orgs

---

## Important Notes

**Always fetch actual data**: Don't theorize about costs - use MCP tools to get real usage data.

**Be concise**: Users want insights, not data dumps. Analyze and interpret.

**Progressive disclosure**: Start with high-level overview, then offer deep dives based on interest.

**Use fully qualified tool names**: Always use `limacharlie:tool_name` format to avoid errors.

**Reference supporting docs**: Point to EXAMPLES.md for workflows and REFERENCE.md for detailed concepts.

**Follow the conversational flow**: Ask questions, wait for responses, adapt to user needs.

---

**Remember**: This skill is about helping users understand their costs and make informed decisions. Analyze, interpret, and provide actionable insights - don't just dump raw data.
