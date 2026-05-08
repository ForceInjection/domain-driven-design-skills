---
name: fullstack-security
description: Security and performance - hardening, optimization, auditing
sasmp_version: "1.3.0"
bonded_agent: 07-security-performance
bond_type: PRIMARY_BOND

# Skill Configuration
atomic: true
single_responsibility: security_performance

# Parameter Schema
parameters:
  type: object
  required: [action]
  properties:
    action:
      type: string
      enum: [audit_security, optimize_performance, configure_caching, harden_infrastructure]
      description: The specific security/performance action to perform
    audit_type:
      type: string
      enum: [owasp, pci-dss, soc2, gdpr]
      default: owasp
    target:
      type: string
      enum: [frontend, backend, infrastructure, database]
    severity_threshold:
      type: string
      enum: [critical, high, medium, low]
      default: medium

# Return Schema
returns:
  type: object
  properties:
    success: { type: boolean }
    vulnerabilities: { type: array }
    performance_report: { type: object }
    recommendations: { type: array, items: { type: string } }
    compliance_status: { type: object }

# Retry Configuration
retry:
  max_attempts: 3
  backoff: exponential
  initial_delay_ms: 1000
  jitter: true

# Observability
logging:
  level: INFO
  events: [vulnerability_found, performance_analyzed, hardening_applied]
  metrics: [vulnerability_count, performance_score, compliance_coverage]
---

# Fullstack Security Skill

Atomic skill for security auditing and performance optimization.

## Responsibility

**Single Purpose**: Audit security, optimize performance, and ensure compliance

## Actions

### `audit_security`
Perform security audit against specified standards.

```typescript
// Input
{
  action: "audit_security",
  audit_type: "owasp",
  target: "backend"
}

// Output
{
  success: true,
  vulnerabilities: [
    {
      severity: "high",
      category: "A03:Injection",
      title: "SQL Injection Risk",
      location: "src/routes/users.ts:45",
      remediation: "Use parameterized queries"
    }
  ],
  compliance_status: { owasp_score: 75, passing: 8, failing: 2 },
  recommendations: ["Add input validation", "Implement CSP headers"]
}
```

### `optimize_performance`
Analyze and optimize application performance.

### `configure_caching`
Set up caching strategies.

### `harden_infrastructure`
Apply security hardening to infrastructure.

## Validation Rules

```typescript
function validateParams(params: SkillParams): ValidationResult {
  if (!params.action) {
    return { valid: false, error: "action is required" };
  }

  if (params.action === 'audit_security' && !params.target) {
    return { valid: false, error: "target required for security audit" };
  }

  return { valid: true };
}
```

## Error Handling

| Error Code | Description | Recovery |
|------------|-------------|----------|
| CRITICAL_VULNERABILITY | Critical security issue found | Block deployment, immediate fix |
| PERFORMANCE_REGRESSION | Performance degraded | Rollback or optimize |
| COMPLIANCE_VIOLATION | Compliance requirement not met | Document and remediate |
| SCAN_FAILED | Security scanner failed | Use alternative tool |

## Logging Hooks

```json
{
  "on_invoke": "log.info('fullstack-security invoked', { action, target })",
  "on_vulnerability": "log.warn('Vulnerability found', { severity, category })",
  "on_success": "log.info('Security check completed', { score, recommendations })",
  "on_error": "log.error('Security skill failed', { error })"
}
```

## Unit Test Template

```typescript
import { describe, it, expect } from 'vitest';
import { fullstackSecurity } from './fullstack-security';

describe('fullstack-security skill', () => {
  describe('audit_security', () => {
    it('should detect OWASP Top 10 vulnerabilities', async () => {
      const result = await fullstackSecurity({
        action: 'audit_security',
        audit_type: 'owasp',
        target: 'backend'
      });

      expect(result.success).toBe(true);
      expect(result.compliance_status.owasp_score).toBeDefined();
    });

    it('should provide remediation steps', async () => {
      const result = await fullstackSecurity({
        action: 'audit_security',
        target: 'backend'
      });

      result.vulnerabilities.forEach(v => {
        expect(v.remediation).toBeDefined();
      });
    });
  });

  describe('optimize_performance', () => {
    it('should analyze Core Web Vitals', async () => {
      const result = await fullstackSecurity({
        action: 'optimize_performance',
        target: 'frontend'
      });

      expect(result.success).toBe(true);
      expect(result.performance_report.lcp).toBeDefined();
    });
  });
});
```

## Security Checklist

```typescript
const securityChecklist = {
  authentication: [
    "Strong password policy enforced",
    "MFA available and encouraged",
    "Session timeout configured",
    "Token rotation implemented"
  ],
  authorization: [
    "Role-based access control",
    "Principle of least privilege",
    "Resource-level permissions",
    "Access logging enabled"
  ],
  data_protection: [
    "Encryption at rest",
    "Encryption in transit (TLS 1.3)",
    "PII handling compliant",
    "Backup encryption enabled"
  ]
};
```

## Integration

- **Bonded Agent**: 07-security-performance
- **Upstream Skills**: All development and DevOps skills
- **Downstream Skills**: None (final checkpoint)

## Version History
| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-01 | Initial release |
| 2.0.0 | 2025-01 | Production-grade upgrade with OWASP 2024 |
