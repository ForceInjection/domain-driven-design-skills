---
name: compliance-automation
description: Automated compliance checks, continuous monitoring, reporting frameworks for GDPR, HIPAA, SOC2, and CCPA compliance.
triggers:
  - compliance automation
  - automated compliance
  - regulatory compliance
  - compliance monitoring
category: compliance
---

# Compliance Automation Skill

## Overview

Automate compliance checking, monitoring, and reporting for regulatory frameworks including GDPR, HIPAA, SOC2, and CCPA.

## Compliance Frameworks

### GDPR (General Data Protection Regulation)
```python
class GDPRComplianceChecker:
    def check_all_requirements(self, catalog: str) -> dict:
        """Check all GDPR requirements."""
        return {
            "data_inventory": self.check_data_inventory(catalog),
            "legal_basis": self.check_legal_basis(catalog),
            "consent_management": self.check_consent(catalog),
            "right_to_access": self.check_sar_process(),
            "right_to_erasure": self.check_deletion_workflow(),
            "right_to_portability": self.check_export_capability(),
            "data_minimization": self.check_data_minimization(catalog),
            "security_measures": self.check_security(catalog),
            "breach_notification": self.check_breach_process()
        }

    def check_right_to_erasure(self) -> dict:
        """Article 17: Right to erasure."""
        has_deletion_api = self.verify_deletion_api_exists()
        has_lineage = self.verify_lineage_for_cascade()
        response_time_ok = self.verify_30day_sla()

        return {
            "compliant": all([has_deletion_api, has_lineage, response_time_ok]),
            "gaps": self.identify_gaps([has_deletion_api, has_lineage, response_time_ok])
        }
```

### HIPAA (Health Insurance Portability)
```python
class HIPAAComplianceChecker:
    def check_technical_safeguards(self, catalog: str) -> dict:
        """Check HIPAA technical safeguards."""
        return {
            "access_control": self.check_unique_user_id(),
            "audit_controls": self.check_audit_logs(),
            "integrity_controls": self.check_data_integrity(),
            "transmission_security": self.check_encryption_transit(),
            "encryption_at_rest": self.check_encryption_rest(catalog)
        }

    def check_audit_controls(self) -> dict:
        """45 CFR § 164.312(b) - Audit controls."""
        logs_enabled = self.verify_audit_logs_enabled()
        retention_ok = self.verify_log_retention_6years()
        comprehensive = self.verify_phi_access_logged()

        return {
            "compliant": all([logs_enabled, retention_ok, comprehensive]),
            "requirement": "45 CFR § 164.312(b)"
        }
```

### SOC2 (Service Organization Control 2)
```python
class SOC2ComplianceChecker:
    def check_trust_services_criteria(self, catalog: str) -> dict:
        """Check SOC2 trust services criteria."""
        return {
            "security": self.check_security_principle(catalog),
            "availability": self.check_availability_principle(),
            "processing_integrity": self.check_processing_integrity(catalog),
            "confidentiality": self.check_confidentiality(catalog),
            "privacy": self.check_privacy_principle(catalog)
        }
```

## Continuous Monitoring

### Real-time Compliance Monitoring
```python
def continuous_compliance_monitor(interval_minutes: int = 60):
    """Monitor compliance continuously."""
    while True:
        # Check all compliance frameworks
        gdpr_status = GDPRComplianceChecker().check_all_requirements("production")
        hipaa_status = HIPAAComplianceChecker().check_technical_safeguards("production")
        soc2_status = SOC2ComplianceChecker().check_trust_services_criteria("production")

        # Identify violations
        violations = identify_violations([gdpr_status, hipaa_status, soc2_status])

        if violations:
            # Alert and remediate
            send_compliance_alerts(violations)
            auto_remediate_violations(violations)

        # Log compliance status
        log_compliance_status(gdpr_status, hipaa_status, soc2_status)

        # Wait for next check
        time.sleep(interval_minutes * 60)
```

## Automated Remediation

```python
def auto_remediate_compliance_violations(violations: list):
    """Automatically fix compliance violations."""
    for violation in violations:
        if violation["type"] == "unencrypted_pii":
            enable_encryption(violation["table"])
            apply_masking(violation["columns"])

        elif violation["type"] == "excessive_access":
            revoke_excessive_permissions(violation["grants"])

        elif violation["type"] == "missing_audit_logs":
            enable_audit_logging(violation["catalog"])

        elif violation["type"] == "retention_violation":
            execute_retention_policy(violation["table"])

        # Log remediation
        log_remediation(violation)
```

## Compliance Reporting

### Generate Compliance Report
```python
def generate_compliance_report(standard: str, catalog: str) -> dict:
    """Generate comprehensive compliance report."""
    if standard == "gdpr":
        checker = GDPRComplianceChecker()
        results = checker.check_all_requirements(catalog)
    elif standard == "hipaa":
        checker = HIPAAComplianceChecker()
        results = checker.check_technical_safeguards(catalog)

    report = {
        "standard": standard,
        "catalog": catalog,
        "date": datetime.now(),
        "overall_score": calculate_compliance_score(results),
        "compliant_controls": count_compliant(results),
        "non_compliant_controls": count_non_compliant(results),
        "findings": extract_findings(results),
        "remediation_plan": generate_remediation_plan(results)
    }

    return report
```

## Best Practices

1. **Automate Everything**: Manual checks are error-prone
2. **Monitor Continuously**: Real-time compliance monitoring
3. **Alert Proactively**: Notify before violations escalate
4. **Auto-Remediate**: Fix violations automatically where possible
5. **Document Evidence**: Maintain audit trail for regulators
6. **Regular Testing**: Test compliance controls quarterly

## Templates

- **gdpr-checklist.yaml**: GDPR compliance checklist
- **hipaa-controls.yaml**: HIPAA control validation
- **soc2-audit.yaml**: SOC2 audit procedures
- **compliance-monitor.py**: Continuous monitoring script

## Examples

- **gdpr-compliance-check**: Complete GDPR audit
- **hipaa-phi-protection**: PHI protection validation
- **soc2-security-controls**: Security control testing
