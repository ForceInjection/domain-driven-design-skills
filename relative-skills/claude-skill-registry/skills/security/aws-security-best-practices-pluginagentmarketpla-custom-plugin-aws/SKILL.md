---
name: aws-security-best-practices
description: Implement comprehensive AWS security controls and compliance
sasmp_version: "1.3.0"
bonded_agent: 06-aws-security
bond_type: PRIMARY_BOND
---

# AWS Security Best Practices Skill

Implement defense-in-depth security for AWS workloads.

## Quick Reference

| Attribute | Value |
|-----------|-------|
| AWS Services | KMS, WAF, GuardDuty, Security Hub |
| Complexity | Medium-High |
| Est. Time | 30-60 min |
| Prerequisites | Admin access |

## Parameters

### Required
| Parameter | Type | Description | Validation |
|-----------|------|-------------|------------|
| compliance_framework | string | Target framework | SOC2, HIPAA, PCI-DSS, CIS |
| scope | array | Resource types | ["EC2", "S3", "RDS"] |

### Optional
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| enable_guardduty | bool | true | Enable GuardDuty |
| enable_securityhub | bool | true | Enable Security Hub |
| encryption_key_type | string | AWS_MANAGED | AWS_MANAGED or CMK |
| log_retention_days | int | 365 | CloudTrail log retention |

## Security Checklist by Service

### S3 Security
```yaml
mandatory:
  - Block Public Access: enabled (account + bucket level)
  - Default Encryption: SSE-S3 or SSE-KMS
  - Access Logging: enabled
  - Versioning: enabled for critical data

recommended:
  - Object Lock: for compliance
  - MFA Delete: for versioned buckets
  - Lifecycle Rules: auto-delete old versions
```

### EC2 Security
```yaml
mandatory:
  - IMDSv2: required (HttpTokens=required)
  - EBS Encryption: default enabled
  - Security Groups: no 0.0.0.0/0 for SSH/RDP
  - Systems Manager: for patching

recommended:
  - Inspector: vulnerability scanning
  - No public IPs: use bastion or SSM
  - Instance profiles: no access keys on instances
```

### RDS Security
```yaml
mandatory:
  - No Public Access: publicly_accessible=false
  - Encryption at Rest: storage_encrypted=true
  - SSL/TLS: required for connections
  - Security Groups: app-tier only access

recommended:
  - IAM Authentication: enabled
  - Audit Logging: enabled
  - Automated Backups: encrypted
```

## Implementation

### Enable GuardDuty
```bash
# Enable GuardDuty
aws guardduty create-detector \
  --enable \
  --finding-publishing-frequency FIFTEEN_MINUTES \
  --features '[{"Name":"S3_DATA_EVENTS","Status":"ENABLED"},{"Name":"EKS_AUDIT_LOGS","Status":"ENABLED"}]'
```

### Enable Security Hub
```bash
# Enable Security Hub with standards
aws securityhub enable-security-hub \
  --enable-default-standards

# Enable additional standards
aws securityhub batch-enable-standards \
  --standards-subscription-requests '[{"StandardsArn":"arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.4.0"}]'
```

### KMS Key Setup
```bash
# Create CMK with rotation
aws kms create-key \
  --description "RDS encryption key" \
  --key-spec SYMMETRIC_DEFAULT \
  --key-usage ENCRYPT_DECRYPT \
  --tags TagKey=Purpose,TagValue=RDS

# Enable rotation
aws kms enable-key-rotation --key-id $KEY_ID
```

### WAF Rule Example
```bash
# Create WAF rule for SQL injection
aws wafv2 create-rule-group \
  --name SQLiProtection \
  --scope REGIONAL \
  --capacity 100 \
  --rules '[{
    "Name": "SQLiRule",
    "Priority": 1,
    "Statement": {
      "SqliMatchStatement": {
        "FieldToMatch": {"Body": {}},
        "TextTransformations": [{"Priority": 0, "Type": "URL_DECODE"}]
      }
    },
    "Action": {"Block": {}},
    "VisibilityConfig": {
      "SampledRequestsEnabled": true,
      "CloudWatchMetricsEnabled": true,
      "MetricName": "SQLiRule"
    }
  }]'
```

## Compliance Mapping

| Framework | Key AWS Controls |
|-----------|-----------------|
| SOC 2 | CloudTrail, Config, GuardDuty, IAM |
| HIPAA | KMS, CloudWatch, VPC, WAF, Macie |
| PCI-DSS | KMS, WAF, CloudTrail, VPC, Config |
| CIS | Security Hub CIS Benchmark, Config |
| GDPR | KMS, Macie, Data lifecycle policies |

## Troubleshooting

### Common Issues
| Symptom | Cause | Solution |
|---------|-------|----------|
| Access Denied | IAM/resource policy | Check both policies |
| KMS error | Key policy | Verify key grants |
| WAF blocking legit | Rule too strict | Use count mode first |
| GuardDuty finding | Security issue | Investigate finding |

### Debug Checklist
- [ ] CloudTrail enabled in all regions?
- [ ] GuardDuty enabled with all features?
- [ ] Security Hub standards enabled?
- [ ] AWS Config recording?
- [ ] VPC Flow Logs enabled?
- [ ] KMS keys have rotation?

### Security Finding Triage
```
Critical: Immediate action required
├── Unauthorized access detected
├── Data exfiltration attempt
└── Compromised credentials

High: Action within 24 hours
├── Exposed credentials
├── Open security groups
└── Unencrypted data

Medium: Action within 7 days
├── Missing encryption
├── Logging gaps
└── Outdated software
```

## Test Template

```python
def test_s3_security_controls():
    # Arrange
    bucket = "test-bucket"

    # Act - Check Block Public Access
    response = s3.get_public_access_block(Bucket=bucket)
    config = response['PublicAccessBlockConfiguration']

    # Assert
    assert config['BlockPublicAcls'] == True
    assert config['IgnorePublicAcls'] == True
    assert config['BlockPublicPolicy'] == True
    assert config['RestrictPublicBuckets'] == True

    # Act - Check Encryption
    enc_response = s3.get_bucket_encryption(Bucket=bucket)

    # Assert encryption enabled
    assert 'ServerSideEncryptionConfiguration' in enc_response
```

## Assets

- `assets/security-checklist.yaml` - Security audit checklist

## References

- [AWS Security Best Practices](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/)
- [CIS AWS Benchmarks](https://www.cisecurity.org/benchmark/amazon_web_services)
