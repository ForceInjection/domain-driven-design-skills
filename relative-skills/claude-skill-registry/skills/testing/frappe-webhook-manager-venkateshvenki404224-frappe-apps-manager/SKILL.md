---
name: frappe-webhook-manager
description: Create webhook handlers for Frappe integrations. Use when implementing webhooks, event-driven integrations, or external system notifications.
---

# Frappe Webhook Manager

Generate secure webhook receivers and senders for Frappe integrations with external systems.

## When to Use This Skill

Claude should invoke this skill when:
- User wants to receive webhooks from external services
- User needs to send webhooks to external systems
- User mentions webhook, event-driven integration, or external notifications
- User wants to integrate payment gateways, APIs, or third-party services
- User needs to handle real-time events from external systems

## Capabilities

### 1. Webhook Receiver

**Secure Webhook Endpoint:**
```python
import frappe
import hmac
import hashlib

@frappe.whitelist(allow_guest=True)
def webhook_receiver():
    """Receive webhook from external service"""
    # Get signature
    signature = frappe.get_request_header('X-Webhook-Signature')

    # Verify signature
    secret = frappe.conf.get('webhook_secret')
    expected = hmac.new(
        secret.encode(),
        frappe.request.data,
        hashlib.sha256
    ).hexdigest()

    if not hmac.compare_digest(signature, expected):
        frappe.throw(_('Invalid signature'), frappe.AuthenticationError)

    # Parse payload
    payload = frappe.parse_json(frappe.request.data)

    # Process webhook
    event = payload.get('event')
    if event == 'payment.success':
        handle_payment_success(payload)
    elif event == 'customer.updated':
        handle_customer_update(payload)

    return {'status': 'success'}
```

### 2. Outgoing Webhook

**Send Webhook on Document Event:**
```python
class SalesInvoice(Document):
    def on_submit(self):
        # Send webhook on submission
        send_webhook('invoice.submitted', self.as_dict())

def send_webhook(event, data):
    """Send webhook to external system"""
    webhook_url = frappe.conf.get('external_webhook_url')

    payload = {
        'event': event,
        'data': data,
        'timestamp': frappe.utils.now()
    }

    # Enqueue for async processing
    frappe.enqueue(
        '_send_webhook',
        webhook_url=webhook_url,
        payload=payload,
        queue='short'
    )

def _send_webhook(webhook_url, payload):
    """Send webhook with retry logic"""
    import requests

    for attempt in range(3):
        try:
            response = requests.post(
                webhook_url,
                json=payload,
                headers={'Content-Type': 'application/json'},
                timeout=10
            )

            if response.status_code == 200:
                return True
        except Exception as e:
            if attempt == 2:
                frappe.log_error(frappe.get_traceback(),
                    f"Webhook Failed: {webhook_url}")

    return False
```

## References

**Frappe Webhook Implementation:**
- Webhook DocType: https://github.com/frappe/frappe/tree/develop/frappe/integrations/doctype/webhook
- Integration Request: https://github.com/frappe/frappe/tree/develop/frappe/integrations/doctype/integration_request
