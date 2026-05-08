---
name: frappe-integration-test-generator
description: Generate integration tests for multi-DocType workflows in Frappe. Use when testing end-to-end workflows, state transitions, or complex business processes.
---

# Frappe Integration Test Generator

Generate comprehensive integration tests for multi-DocType workflows and end-to-end business processes in Frappe.

## When to Use This Skill

Claude should invoke this skill when:
- User wants to test complete workflows
- User needs end-to-end scenario testing
- User mentions integration tests or workflow testing
- User wants to test multi-DocType interactions
- User needs to verify business process integrity

## Capabilities

### 1. Workflow Integration Test

**Complete Sales Workflow Test:**
```python
from frappe.tests.utils import FrappeTestCase
import frappe

class TestSalesWorkflow(FrappeTestCase):
    def test_complete_sales_cycle(self):
        """Test end-to-end sales process"""
        # 1. Create Customer
        customer = self._create_test_customer()

        # 2. Create Sales Order
        so = self._create_sales_order(customer.name)
        so.submit()

        # 3. Create Sales Invoice from SO
        si = self._make_sales_invoice_from_order(so.name)
        si.insert()
        si.submit()

        # 4. Create Payment Entry
        pe = self._create_payment_entry(si)
        pe.insert()
        pe.submit()

        # Verify workflow completed
        si.reload()
        self.assertEqual(si.status, 'Paid')
        self.assertEqual(si.outstanding_amount, 0)

    def _create_test_customer(self):
        return frappe.get_doc({
            'doctype': 'Customer',
            'customer_name': '_Test Customer',
            'customer_group': 'Commercial'
        }).insert()

    def _create_sales_order(self, customer):
        return frappe.get_doc({
            'doctype': 'Sales Order',
            'customer': customer,
            'delivery_date': frappe.utils.add_days(frappe.utils.today(), 7),
            'items': [{
                'item_code': '_Test Item',
                'qty': 10,
                'rate': 100
            }]
        })
```

### 2. State Transition Test

**Test Document States:**
```python
class TestInvoiceStates(FrappeTestCase):
    def test_invoice_state_transitions(self):
        """Test all possible state transitions"""
        si = self._get_test_invoice()

        # Draft state
        si.insert()
        self.assertEqual(si.docstatus, 0)
        self.assertEqual(si.status, 'Draft')

        # Submit transition
        si.submit()
        self.assertEqual(si.docstatus, 1)
        self.assertEqual(si.status, 'Submitted')

        # Cannot edit submitted
        si.customer = 'Different Customer'
        with self.assertRaises(frappe.ValidationError):
            si.save()

        # Cancel transition
        si.cancel()
        self.assertEqual(si.docstatus, 2)
        self.assertEqual(si.status, 'Cancelled')
```

## References

**Integration Test Examples:**
- Sales Invoice Tests: https://github.com/frappe/erpnext/blob/develop/erpnext/accounts/doctype/sales_invoice/test_sales_invoice.py
- Stock Entry Tests: https://github.com/frappe/erpnext/blob/develop/erpnext/stock/doctype/stock_entry/test_stock_entry.py
