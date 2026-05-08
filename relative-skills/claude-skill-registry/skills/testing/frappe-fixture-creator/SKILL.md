---
name: frappe-fixture-creator
description: Generate fixture files for Frappe test data and master data. Use when creating test fixtures, setup data, or master data for new sites.
---

# Frappe Fixture Creator

Generate fixture JSON files for test data, master data, and initial site configuration in Frappe applications.

## When to Use This Skill

Claude should invoke this skill when:
- User wants to create test fixtures
- User needs master data setup
- User mentions fixtures, test data, or setup data
- User wants repeatable site setup
- User needs demo or sample data

## Capabilities

### 1. Test Fixture Generation

**Item Fixtures:**
```json
[
  {
    "doctype": "Item",
    "item_code": "_Test Item",
    "item_name": "Test Item",
    "item_group": "Products",
    "stock_uom": "Nos",
    "is_stock_item": 1,
    "is_purchase_item": 1,
    "is_sales_item": 1,
    "opening_stock": 100,
    "valuation_rate": 100,
    "standard_rate": 150
  },
  {
    "doctype": "Item",
    "item_code": "_Test Service Item",
    "item_name": "Test Service",
    "item_group": "Services",
    "stock_uom": "Nos",
    "is_stock_item": 0,
    "is_sales_item": 1,
    "standard_rate": 500
  }
]
```

### 2. Hierarchical Fixtures

**Customer Group Tree:**
```json
[
  {
    "doctype": "Customer Group",
    "customer_group_name": "All Customer Groups",
    "is_group": 1
  },
  {
    "doctype": "Customer Group",
    "customer_group_name": "Commercial",
    "parent_customer_group": "All Customer Groups",
    "is_group": 0
  },
  {
    "doctype": "Customer Group",
    "customer_group_name": "Individual",
    "parent_customer_group": "All Customer Groups",
    "is_group": 0
  }
]
```

### 3. Import Fixture

**Load Fixture in App:**
```python
# In app setup
def before_install():
    """Install fixtures before site setup"""
    from frappe.core.page.data_import_tool.data_import_tool import import_doc

    import_doc('my_app/fixtures/item_groups.json')
    import_doc('my_app/fixtures/territories.json')
```

## References

**Frappe Fixture Patterns:**
- Install Fixtures: https://github.com/frappe/frappe/blob/develop/frappe/core/page/data_import_tool/data_import_tool.py
- ERPNext Fixtures: https://github.com/frappe/erpnext/tree/develop/erpnext/setup/fixtures
