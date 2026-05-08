---
name: odoo-model-inspector
description: This skill analyzes Odoo model inheritance chains and fields, showing "who stands on whom" with complete inheritance hierarchy including all fields and methods from all modules. Should be used when understanding model structure, checking available fields before adding new ones, or tracing inheritance dependencies.
---

# Odoo Model Inspector

Analyzes Odoo model inheritance to show complete picture of model structure across all modules.

## When to use

Use this skill when:
- "What fields does sale.order have?" → need to see ALL fields from all inherits
- "Where is field X defined?" → need to trace through inheritance chain
- Working with a model and need to understand its full structure
- Before adding new field → check what already exists
- Understanding module dependencies through models

## What you do

### Step 1: Identify model and context

**From user request:**
- "Show me sale.order structure" → model = `sale.order`, context = current module
- "What fields does product.product have?" → model = `product.product`
- "Analyze res.partner in sale" → model = `res.partner`, context = `sale`

**Context module:**
- If specified: use it
- If not specified: try to infer from current work
- Default: analyze from all available modules

### Step 2: Run inspector script

Execute:
```bash
# Basic usage - JSON only
uv run python .claude/skills/odoo_model_inspector/inspect.py \
  --model sale.order \
  --context-module sale

# With Markdown output for human reading
uv run python .claude/skills/odoo_model_inspector/inspect.py \
  --model sale.order \
  --context-module sale \
  --output-markdown .odoo_inspect/sale_order_structure.md
```

The script will:
- Parse `__manifest__.py` files → get `depends` recursively
- Find base model definition (`_name = 'sale.order'`)
- Find ALL extensions (`_inherit = 'sale.order'`)
- Parse Python AST → extract field names + types
- Build dependency graph → show "who stands on whom"
- Return JSON with complete structure

### Step 3: Parse JSON output

Script returns JSON:
```json
{
  "model": "sale.order",
  "context_module": "sale",
  "base_definition": {
    "module": "sale",
    "file": "addons/sale/models/sale_order.py",
    "line": 15
  },
  "inheritance_chain": [
    {
      "order": 1,
      "module": "sale",
      "is_base": true,
      "fields": {
        "partner_id": "Many2one",
        "amount_total": "Monetary",
        "state": "Selection"
      },
      "fields_count": 23
    },
    {
      "order": 2,
      "module": "stock",
      "is_base": false,
      "depends_on": ["sale"],
      "file": "addons/stock/models/sale_order.py",
      "fields": {
        "picking_ids": "One2many",
        "warehouse_id": "Many2one"
      },
      "fields_count": 5
    }
  ],
  "total_fields": 38,
  "modules_involved": 4
}
```

### Step 4: Present to user

Format the inheritance chain:

```
Model: sale.order (38 fields total)

Inheritance Chain:
  sale (BASE) → 23 fields
    └─> stock → +5 fields

Fields by module:

sale (base):
- partner_id: Many2one
- amount_total: Monetary
- state: Selection
...

stock (extends sale.order):
- picking_ids: One2many
- warehouse_id: Many2one
...
```

## Configuration

**Before first use**, customize `config.py` for your project:

```python
# Project root (auto-detected from script location)
PROJECT_ROOT = Path(__file__).parent.parent.parent.parent

# Addon directories (relative to PROJECT_ROOT)
ADDON_DIRECTORIES = [
    'server/addons',
    'server/odoo/addons',
    'addons_custom',  # Add your custom directories
]

# Output directory for analysis files
OUTPUT_DIRECTORY = '.odoo_inspect'
```

**Default values** work for standard Odoo projects with common structure.

## Important Notes

- **Zero code execution:** Uses AST parsing, never imports/runs code
- **Recursive dependencies:** Follows entire dependency chain
- **Only fields + types + methods:** Structure analysis, not logic
- **Fast:** Parses files directly, no Odoo server needed
- **Complete picture:** Shows ALL modules that touch this model
- **Configurable:** Customize addon paths via `config.py`

## Token Efficiency

**Without skill:**
- Read sale/models/sale_order.py
- Search for "_inherit = 'sale.order'" in all modules
- Open each file manually
- Extract fields by eye
- **Cost: ~5,000 tokens, 5-10 minutes**

**With skill:**
- 1 command
- Get complete JSON
- Format for user
- **Cost: ~300 tokens, 30 seconds** ✅

## Use Cases

### Use Case 1: Adding new field
```
User: "I want to add delivery_date to sale.order"
You:
1. Run inspector on sale.order
2. Check if delivery_date already exists in any module
3. If not - proceed with adding
4. If yes - tell user where it's defined
```

### Use Case 2: Understanding model structure
```
User: "What fields can I use in sale.order?"
You:
1. Run inspector
2. Show ALL available fields from all modules
3. Show which module added which field
```

### Use Case 3: Debugging field errors
```
User: "Error: field 'warehouse_id' doesn't exist on sale.order"
You:
1. Run inspector
2. Check if field exists
3. If yes - show which module adds it (e.g., sale_stock)
4. Check if that module is in depends
```

## Error Handling

If script fails:
- Model not found → check spelling, check if model exists
- No base definition found → might be abstract model
- Circular dependencies → handled automatically with recovery mechanism
- Parse errors → skip problematic file, continue with others

## Example

**User:** "Show me what fields sale.order has"

**You:**
1. Run: `python .claude/skills/odoo_model_inspector/inspect.py --model sale.order`
2. Get JSON with complete inheritance chain
3. Present formatted view showing all fields
4. Show which module adds which fields
5. Done! (~300 tokens)

## Advanced Options

```bash
# Analyze specific module context
--context-module sale

# Output Markdown for documentation
--output-markdown ./docs/models/sale_order.md
```
