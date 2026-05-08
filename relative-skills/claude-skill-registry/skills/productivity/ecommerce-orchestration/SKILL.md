---
name: ecommerce-orchestration
description: Manage e-commerce orders and returns using task management and business rules together. Use for order processing, returns, shipping calculations, and discount applications.
---

# E-commerce Orchestration Skill

## Overview

This skill demonstrates **Pattern 2: Multi-MCP Orchestration** by coordinating between two MCP servers:

1. **task-tracker**: Manages order/return tasks and workflows
2. **business-rules**: Provides e-commerce policies (return windows, shipping costs, discounts)

## When This Skill Activates

Claude automatically uses this skill when you mention:

**Return Processing:**
- Processing/handling a return request
- Checking return eligibility or policies
- Customer wants to return an item
- Return evaluation or assessment
- Refund calculations or decisions

**Order Processing:**
- Creating or processing an order
- Applying discounts or loyalty benefits
- Calculating shipping costs
- Order fulfillment
- New customer orders or bulk orders

**Policy Inquiries:**
- Shipping costs for an order
- Return windows or policies
- Discount eligibility
- Restocking fees
- Business rules or policies

## Multi-Server Workflows

### Return Request Workflow

When processing a customer return:

**Orchestration Steps:**
1. **Create return task** (task-tracker: `create_task`)
   - Title: "Return: [Item] - [Price/Details]"
   - Status: "pending"
   - Include item category, purchase date, condition in description
2. **Check return policy** (business-rules: `check_return_policy`)
   - Parameters: category (clothing/electronics/books/food), days_since_purchase, opened (true/false)
3. **Evaluate eligibility** based on policy result
   - If eligible: calculate refund amount (original_price - restocking_fee if applied)
   - If ineligible: note reason (outside return window, condition issues, etc.)
4. **Update task** (task-tracker: `update_task`)
   - Add policy decision to task description
   - Include refund method and amount
   - Status: "in_progress" (ready for fulfillment)
5. **Route to fulfillment** based on eligibility status

**Example**: "Process a return for a laptop purchased 10 days ago"
- Step 1: Creates task "Return: Laptop - Opened - 10 days"
- Step 2: Checks policy: electronics = 14 days, opened = 15% fee
- Step 3: Evaluates: Eligible (within 14-day window), refund = original × 0.85
- Step 4: Updates task: "✓ ELIGIBLE - 15% restocking fee applies"
- Step 5: Ready for fulfillment team to process

### Order Processing Workflow

When creating a new order:

**Orchestration Steps:**
1. **Calculate discounts** (business-rules: `calculate_discount`)
   - Parameters: customer_status (new/existing), loyalty_tier (bronze/silver/gold), num_items
   - Result: discount percentage to apply
2. **Calculate shipping** (business-rules: `calculate_shipping_cost`)
   - Parameters: order_total (after discount), shipping_type (standard/expedited/express)
   - Result: shipping cost for the selected method
3. **Create order task** (task-tracker: `create_task`)
   - Title: "Order fulfillment - [Customer] - $[Total]"
   - Status: "pending"
   - Include itemized breakdown in description
4. **Update task** (task-tracker: `update_task`) with final pricing
   - Subtotal, discount amount, shipping cost, estimated tax, final total
   - Include delivery timeline based on shipping type
5. **Route to fulfillment center** based on order size/priority

**Example**: "Create an order for a new customer buying 12 items totaling $85"
- Step 1: Calculates discounts: 10% new customer + 10% bulk (capped at 25%) = $21.25 discount
- Step 2: Calculates shipping: Free standard (order $63.75 > $50)
- Step 3: Creates task "Order fulfillment - New Customer - $63.75"
- Step 4: Updates task with breakdown: Subtotal $85 - Discount $21.25 - Shipping $0 = Total $63.75 + tax
- Step 5: Routes to fulfillment for processing

### Complex Scenario: Return Evaluation

Scenario: "Evaluate a return for 3 opened books and 1 unopened laptop purchased 20 days ago for $500 each"

**Orchestration Steps:**
1. **Create multi-item return task** (task-tracker: `create_task`)
   - Title: "Return evaluation - 4 items - 20 days"
   - Description: List each item with category, condition, original price
2. **Check each item's policy** (business-rules: `check_return_policy` × 4 calls)
   - Books: category=books, days=20, opened=true
   - Laptop: category=electronics, days=20, opened=false
3. **Aggregate results** for each item
4. **Update task** (task-tracker: `update_task`) with itemized decision
5. **Calculate total refund** and route for processing

**Evaluation Results:**

**Books (3×)**:
- Step 2: books policy = 60-day window, no restocking fee
- Result: ✓ ELIGIBLE (within 60 days), full refund = $100 each × 3 = $300

**Laptop**:
- Step 2: electronics policy = 14-day window, 15% fee if opened
- Result: ✗ OUTSIDE WINDOW (20 days > 14 days), ineligible - cannot process

**Total Return**: $300 only (books eligible, laptop denied)

**Note**: This example shows how the skill evaluates each item independently and provides itemized refund decisions.

## Available Operations

### From task-tracker MCP:
- `create_task` - Create order/return task with metadata
- `update_task` - Update task status, add notes
- `filter_tasks` - Find tasks by priority, status, project
- `list_tasks` - List pending/completed tasks
- `get_task_statistics` - Get completion rates, metrics

### From business-rules MCP:
- `check_return_policy` - Validate return eligibility
- `calculate_shipping_cost` - Get shipping costs by order amount
- `calculate_discount` - Apply customer/order discounts
- `get_all_policies` - View all business rules

## Best Practices

1. **Always check rules first**: Before creating tasks, validate using business-rules to provide accurate information
2. **Embed results in tasks**: Include policy decisions and calculations in task descriptions for auditing
3. **Use specific categories**: Use exact category names (electronics, clothing, books, food) for accurate policies
4. **Consider customer context**: Loyalty tier, purchase history affect discounts and eligibility
5. **Chain operations**: Discount → Shipping → Task creation creates complete order workflows
6. **Document decisions**: When rules block actions, clearly state why in task notes

## Example Prompts

### Return Processing
- "Process a return for clothing purchased 20 days ago, unopened"
- "Evaluate return for opened electronics purchased 5 days ago"
- "Check if customer can return books purchased 45 days ago"

### Order Creation
- "Create an order for a new customer buying 8 items for $65"
- "Create an order for a gold loyalty member buying 3 items for $120"
- "Process an order for 25 bulk items totaling $500 with standard shipping"

### Policy Inquiries
- "What's our shipping cost for a $75 order?"
- "What discounts apply for a silver member buying 12 items?"
- "How long can customers return clothing?"

## Integration Example

```
User: "I need to process a return for a dress. Customer bought it 20 days ago for $45, and it's unworn."

Steps:
1. task-tracker: Create task "Return: Dress - $45 - Unworn"
2. business-rules: check_return_policy("clothing", 20, opened=false)
   → {eligible: true, days_remaining: 10, restocking_fee: 0%, refund_method: "original_payment"}
3. task-tracker: Update task with "✓ ELIGIBLE - Full refund $45 via original payment method"
4. Result: Task ready for fulfillment, customer gets full refund
```

## Token Efficiency Note

This pattern (Pattern 2) uses 2 MCP servers, which increases token usage compared to Pattern 1:
- **Pattern 1** (single server): ~600-1000 tokens
- **Pattern 2** (multi-server): ~1000-1500 tokens

The additional tokens are worth it because:
- Business rules are independently versioned and managed
- Rule changes don't require server restarts
- Clear separation of concerns (tasks vs. policies)
- Demonstrates real-world orchestration patterns

## Implementation Requirements

This skill requires:
- **task-tracker MCP server** - For creating and updating return/order tasks
- **business-rules MCP server** - For checking policies and calculating costs/discounts

When the skill activates, it orchestrates calls to both MCP servers in sequence:
1. Create/query task-tracker to initialize tasks
2. Call business-rules to validate against policies
3. Update task-tracker with results and decisions
4. Route to appropriate fulfillment/processing workflow

Both MCP servers must be registered and running for this skill to function properly.

## See Also

- [PATTERNS_CATALOG.md](../../docs/PATTERNS_CATALOG.md) - Pattern 2 detailed documentation
- [PATTERN_2_IMPLEMENTATION.md](../../docs/PATTERN_2_IMPLEMENTATION.md) - Implementation details
