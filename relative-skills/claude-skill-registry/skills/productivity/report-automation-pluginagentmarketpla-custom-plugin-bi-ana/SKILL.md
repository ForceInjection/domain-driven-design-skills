---
name: report-automation
description: Master enterprise reporting automation including scheduling, distribution, templates, governance, and monitoring
sasmp_version: "1.3.0"
bonded_agent: 07-reporting
bond_type: PRIMARY_BOND
parameters:
  task:
    type: string
    required: true
    enum: [scheduling, distribution, template_design, governance, monitoring]
  platform:
    type: string
    enum: [powerbi_service, tableau_server, ssrs, custom]
    default: powerbi_service
  frequency:
    type: string
    enum: [realtime, hourly, daily, weekly, monthly]
    default: daily
retry_config:
  max_retries: 3
  backoff_ms: [1000, 5000, 15000]
---

# Report Automation Skill

Master enterprise report automation including scheduling, distribution management, template design, governance, and operational monitoring.

## Quick Start (5 minutes)

```yaml
# Basic automated report setup
report:
  name: "Daily Sales Summary"
  schedule: "0 7 * * 1-5"  # Weekdays at 7 AM
  recipients:
    - sales-team@company.com
  format: pdf
  data_refresh: before_send
```

## Core Concepts

### Report Lifecycle

```
┌──────────────────────────────────────────────────────────────┐
│                    REPORT LIFECYCLE                          │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  1. SCHEDULE        Cron expression triggers                 │
│        ↓                                                     │
│  2. DATA REFRESH    Update underlying data                   │
│        ↓                                                     │
│  3. RENDER          Generate report output                   │
│        ↓                                                     │
│  4. VALIDATE        Check for errors/empty data              │
│        ↓                                                     │
│  5. DISTRIBUTE      Send to recipients                       │
│        ↓                                                     │
│  6. ARCHIVE         Store for compliance/history             │
│        ↓                                                     │
│  7. MONITOR         Track delivery & engagement              │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### Scheduling Patterns

```
CRON EXPRESSION FORMAT
┌───────────── minute (0-59)
│ ┌───────────── hour (0-23)
│ │ ┌───────────── day of month (1-31)
│ │ │ ┌───────────── month (1-12)
│ │ │ │ ┌───────────── day of week (0-6, 0=Sunday)
│ │ │ │ │
* * * * *

EXAMPLES:
0 7 * * 1-5     → Weekdays at 7:00 AM
0 8 * * 1       → Every Monday at 8:00 AM
0 9 1 * *       → First of every month at 9:00 AM
30 6 * * *      → Every day at 6:30 AM
0 */4 * * *     → Every 4 hours
```

### Distribution Methods

```
┌────────────────────────────────────────────────────────────┐
│                   DISTRIBUTION CHANNELS                     │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  EMAIL                                                     │
│  • Attachment (PDF, Excel, PowerPoint)                     │
│  • Inline HTML body                                        │
│  • Link to portal                                          │
│                                                            │
│  FILE DROP                                                 │
│  • SharePoint/Teams                                        │
│  • Network share                                           │
│  • Cloud storage (S3, Azure Blob, GCS)                     │
│                                                            │
│  API/WEBHOOK                                               │
│  • Push to external system                                 │
│  • Trigger downstream process                              │
│  • Slack/Teams notification                                │
│                                                            │
│  PORTAL                                                    │
│  • Self-service access                                     │
│  • Interactive exploration                                 │
│  • Subscription management                                 │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

## Code Examples

### Schedule Configuration (YAML)
```yaml
schedules:
  daily_sales:
    name: "Daily Sales Report"
    cron: "0 7 * * 1-5"
    timezone: "America/New_York"
    enabled: true

    data_refresh:
      type: "incremental"
      timeout_minutes: 30
      retry_on_failure: true

    render:
      format: "pdf"
      template: "executive_summary"
      page_size: "letter"
      orientation: "landscape"

    distribution:
      method: "email"
      recipients:
        static:
          - "sales-leadership@company.com"
        dynamic:
          query: "SELECT email FROM users WHERE role = 'regional_manager'"

      email:
        subject: "Daily Sales Report - {{date}}"
        body_template: "templates/email/daily_sales.html"
        from: "reports@company.com"

    validation:
      rules:
        - type: "row_count"
          minimum: 1
          action: "skip_and_notify"
        - type: "data_freshness"
          max_age_hours: 24
          action: "warn"

    archive:
      enabled: true
      destination: "s3://reports-archive/sales/"
      retention_days: 365

    monitoring:
      alert_on_failure: true
      alert_recipients: ["ops-team@company.com"]
      sla_minutes: 60
```

### Email Template (HTML)
```html
<!DOCTYPE html>
<html>
<head>
  <style>
    .kpi-card {
      display: inline-block;
      padding: 20px;
      margin: 10px;
      background: #f8f9fa;
      border-radius: 8px;
      text-align: center;
    }
    .kpi-value {
      font-size: 32px;
      font-weight: bold;
      color: #2563eb;
    }
    .kpi-label {
      font-size: 14px;
      color: #6b7280;
    }
    .trend-up { color: #22c55e; }
    .trend-down { color: #ef4444; }
  </style>
</head>
<body>
  <h1>Daily Sales Report - {{date}}</h1>

  <div class="kpi-section">
    <div class="kpi-card">
      <div class="kpi-value">{{revenue | currency}}</div>
      <div class="kpi-label">Revenue</div>
      <div class="{{revenue_trend_class}}">{{revenue_trend}}%</div>
    </div>

    <div class="kpi-card">
      <div class="kpi-value">{{orders | number}}</div>
      <div class="kpi-label">Orders</div>
      <div class="{{orders_trend_class}}">{{orders_trend}}%</div>
    </div>

    <div class="kpi-card">
      <div class="kpi-value">{{aov | currency}}</div>
      <div class="kpi-label">Avg Order Value</div>
      <div class="{{aov_trend_class}}">{{aov_trend}}%</div>
    </div>
  </div>

  <h2>Highlights</h2>
  <ul>
    {{#each highlights}}
    <li>{{this}}</li>
    {{/each}}
  </ul>

  <p>
    <a href="{{dashboard_url}}">View Full Dashboard</a>
  </p>

  <footer>
    <p style="color: #9ca3af; font-size: 12px;">
      This report was automatically generated on {{generated_at}}.
      {{#if confidential}}CONFIDENTIAL - Internal Use Only{{/if}}
    </p>
  </footer>
</body>
</html>
```

### Distribution Script (Python)
```python
from datetime import datetime
from typing import List, Dict
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email.mime.text import MIMEText
from email import encoders

class ReportDistributor:
    def __init__(self, config: Dict):
        self.config = config
        self.smtp_server = config['smtp_server']
        self.smtp_port = config['smtp_port']

    def send_report(
        self,
        recipients: List[str],
        subject: str,
        body_html: str,
        attachments: List[str] = None
    ) -> Dict:
        """Send report via email with attachments."""
        results = {"sent": [], "failed": []}

        msg = MIMEMultipart()
        msg['Subject'] = subject
        msg['From'] = self.config['from_address']

        # Add HTML body
        msg.attach(MIMEText(body_html, 'html'))

        # Add attachments
        if attachments:
            for filepath in attachments:
                with open(filepath, 'rb') as f:
                    part = MIMEBase('application', 'octet-stream')
                    part.set_payload(f.read())
                    encoders.encode_base64(part)
                    part.add_header(
                        'Content-Disposition',
                        f'attachment; filename="{filepath.split("/")[-1]}"'
                    )
                    msg.attach(part)

        # Send to each recipient
        with smtplib.SMTP(self.smtp_server, self.smtp_port) as server:
            server.starttls()
            server.login(self.config['username'], self.config['password'])

            for recipient in recipients:
                try:
                    msg['To'] = recipient
                    server.send_message(msg)
                    results["sent"].append(recipient)
                except Exception as e:
                    results["failed"].append({
                        "recipient": recipient,
                        "error": str(e)
                    })

        return results
```

### Monitoring Dashboard Query
```sql
-- Report delivery metrics
WITH delivery_stats AS (
    SELECT
        report_name,
        DATE_TRUNC('day', scheduled_time) AS date,
        COUNT(*) AS total_runs,
        SUM(CASE WHEN status = 'SUCCESS' THEN 1 ELSE 0 END) AS successful,
        SUM(CASE WHEN status = 'FAILED' THEN 1 ELSE 0 END) AS failed,
        AVG(duration_seconds) AS avg_duration,
        MAX(duration_seconds) AS max_duration
    FROM report_execution_log
    WHERE scheduled_time >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY report_name, DATE_TRUNC('day', scheduled_time)
)
SELECT
    report_name,
    date,
    total_runs,
    successful,
    failed,
    ROUND(successful::DECIMAL / NULLIF(total_runs, 0) * 100, 2) AS success_rate,
    ROUND(avg_duration, 1) AS avg_duration_sec,
    max_duration AS max_duration_sec
FROM delivery_stats
ORDER BY date DESC, report_name;
```

## Best Practices

### Schedule Design
```yaml
guidelines:
  - Consider timezone of recipients
  - Avoid peak hours for data refresh
  - Stagger reports to avoid resource contention
  - Build in buffer time before meetings
  - Use business day calendars for business reports

example_timing:
  executive_reports:
    timing: "7:00 AM local time"
    reason: "Before morning standup"

  operational_reports:
    timing: "6:00 AM local time"
    reason: "Before shift starts"

  financial_reports:
    timing: "After month-end close + 2 days"
    reason: "Data completeness"
```

### Governance Framework
```yaml
data_classification:
  public:
    distribution: "unrestricted"
    watermark: false
    encryption: false

  internal:
    distribution: "employees_only"
    watermark: true
    encryption: "in_transit"

  confidential:
    distribution: "named_recipients"
    watermark: true
    encryption: "at_rest_and_transit"
    drm: true
    audit_required: true

  restricted:
    distribution: "approval_required"
    watermark: true
    encryption: "at_rest_and_transit"
    drm: true
    audit_required: true
    no_download: true

retention_policy:
  operational: "90 days"
  analytical: "2 years"
  regulatory: "7 years"
  legal_hold: "indefinite"
```

### Error Handling Strategy
```python
class ReportErrorHandler:
    def handle_error(self, error: Exception, context: dict) -> dict:
        error_type = type(error).__name__

        strategies = {
            'DataRefreshTimeout': {
                'action': 'retry',
                'max_retries': 3,
                'backoff': 'exponential',
                'notify': 'ops_team'
            },
            'NoDataAvailable': {
                'action': 'skip',
                'notify': 'report_owner',
                'message': 'Report skipped - no data for period'
            },
            'RecipientInvalid': {
                'action': 'skip_recipient',
                'notify': 'admin',
                'continue': True
            },
            'RenderFailure': {
                'action': 'retry_then_escalate',
                'max_retries': 2,
                'notify': 'dev_team'
            }
        }

        return strategies.get(error_type, {
            'action': 'escalate',
            'notify': 'on_call'
        })
```

## Common Patterns

### Dynamic Recipient List
```sql
-- Query to generate recipient list based on data
SELECT DISTINCT
    u.email,
    u.first_name,
    u.region,
    'regional_manager' AS role
FROM users u
INNER JOIN sales_data s ON u.region = s.region
WHERE u.role = 'regional_manager'
  AND u.is_active = 1
  AND s.report_date = CURRENT_DATE - 1
  AND s.sales_amount > 0;
```

### Parameterized Reports
```yaml
report_template:
  name: "Regional Sales Report"
  parameters:
    - name: region
      type: string
      source: "dynamic"
      query: "SELECT DISTINCT region FROM dim_region WHERE is_active = 1"

    - name: date_range
      type: date_range
      default: "last_month"

    - name: include_forecast
      type: boolean
      default: false

  personalization:
    - Filter data by recipient's region
    - Include recipient's name in greeting
    - Highlight recipient's team performance
```

### Burst Report Pattern
```python
# Send personalized version to each recipient
def burst_report(report_template, recipients, data):
    for recipient in recipients:
        # Filter data for this recipient
        filtered_data = filter_data_for_recipient(data, recipient)

        # Generate personalized report
        report = render_report(
            template=report_template,
            data=filtered_data,
            recipient=recipient
        )

        # Send individual report
        send_report(
            to=recipient.email,
            report=report,
            subject=f"Your {report_template.name} - {recipient.region}"
        )
```

## Retry Logic

```typescript
const executeWithRetry = async (
  operation: () => Promise<any>,
  config: RetryConfig
) => {
  const { maxRetries, backoffMs, retryableErrors } = config;

  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await operation();
    } catch (error) {
      const isRetryable = retryableErrors.includes(error.code);
      const hasRetriesLeft = attempt < maxRetries;

      if (!isRetryable || !hasRetriesLeft) {
        throw error;
      }

      console.log(`Attempt ${attempt + 1} failed, retrying in ${backoffMs[attempt]}ms`);
      await sleep(backoffMs[attempt]);
    }
  }
};

// Usage
await executeWithRetry(
  () => sendReport(report),
  {
    maxRetries: 3,
    backoffMs: [1000, 5000, 15000],
    retryableErrors: ['SMTP_TIMEOUT', 'RATE_LIMITED', 'TEMPORARY_FAILURE']
  }
);
```

## Logging Hooks

```typescript
const reportHooks = {
  onScheduleTrigger: (reportName: string) => {
    console.log(`[REPORT] Triggered: ${reportName}`);
    metrics.increment('reports.triggered', { report: reportName });
  },

  onDataRefresh: (reportName: string, duration: number) => {
    console.log(`[REPORT] Data refreshed for ${reportName} in ${duration}s`);
    metrics.histogram('reports.refresh_duration', duration);
  },

  onDeliverySuccess: (reportName: string, recipient: string) => {
    console.log(`[REPORT] Delivered ${reportName} to ${recipient}`);
    metrics.increment('reports.delivered');
  },

  onDeliveryFailure: (reportName: string, error: Error) => {
    console.error(`[REPORT] Failed: ${reportName} - ${error.message}`);
    metrics.increment('reports.failed');
    alerting.notify('report_failure', { report: reportName, error });
  }
};
```

## Unit Test Template

```typescript
describe('Report Automation Skill', () => {
  describe('Scheduling', () => {
    it('should parse cron expression correctly', () => {
      const schedule = parseCron('0 7 * * 1-5');
      expect(schedule.nextRun().getHours()).toBe(7);
      expect([1, 2, 3, 4, 5]).toContain(schedule.nextRun().getDay());
    });
  });

  describe('Distribution', () => {
    it('should send to all valid recipients', async () => {
      const result = await distributor.send({
        recipients: ['valid@example.com'],
        report: mockReport
      });
      expect(result.sent).toHaveLength(1);
      expect(result.failed).toHaveLength(0);
    });

    it('should handle invalid recipients gracefully', async () => {
      const result = await distributor.send({
        recipients: ['invalid@', 'valid@example.com'],
        report: mockReport
      });
      expect(result.sent).toHaveLength(1);
      expect(result.failed).toHaveLength(1);
    });
  });

  describe('Validation', () => {
    it('should skip empty reports when configured', async () => {
      const result = await validator.validate({
        report: emptyReport,
        rules: [{ type: 'row_count', minimum: 1, action: 'skip' }]
      });
      expect(result.shouldSend).toBe(false);
    });
  });
});
```

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Report not sent | Schedule misconfigured | Verify cron and timezone |
| Empty report | Data not refreshed | Check refresh dependencies |
| Slow delivery | Large attachment | Compress or send link |
| Recipient not receiving | Email filtering | Whitelist sender domain |
| Stale data | Refresh timeout | Increase timeout, optimize query |

## Resources

- **Power BI Service**: Subscription and scheduling docs
- **Tableau Server**: Schedule and subscription management
- **AWS SES/SNS**: Email and notification services
- **Cron Guru**: Cron expression validator

## Version History
| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-01 | Initial release |
| 2.0.0 | 2025-01 | Production-grade with governance |
