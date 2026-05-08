---
name: config-hive-manager
description: Use this skill when the user needs help managing configuration storage in the Config Hive including secrets, D&R rules, YARA rules, lookups, and cloud sensors.
---

# LimaCharlie Config Hive Manager

This skill helps you manage configuration storage in the LimaCharlie Config Hive. Use this when users need help storing, retrieving, organizing, or managing configuration data across different hive types.

## What is the Config Hive?

The Config Hive is LimaCharlie's centralized configuration storage system that allows you to store and reference various types of configuration data across your Organization. It provides:

- Centralized storage for secrets, rules, lookups, and other configurations
- Access control and permission management
- Reference capabilities through Authentication Resource Locators (ARLs)
- Version control and metadata tracking
- Infrastructure-as-Code integration
- Encrypted storage for sensitive data

The Config Hive decouples configuration from usage, enabling better security practices and easier management across multiple Organizations.

## Quick Start: Store and Use a Secret

The most common Config Hive use case is storing secrets securely:

```bash
# 1. Store a secret
echo "my-api-key-value" | limacharlie hive set secret --key my-api-key --data - --data-key secret

# 2. Reference it in configurations using ARLs
hive://secret/my-api-key
```

Use this ARL in adapters, outputs, or extensions:

```yaml
outputs:
  my-output:
    stream: syslog
    dest_host: syslog.example.com
    secret_key: hive://secret/my-api-key
```

## Hive Types Overview

The Config Hive supports multiple specialized storage types:

| Hive Type | Purpose | Common Usage |
|-----------|---------|--------------|
| `secret` | Encrypted credentials and keys | API keys, database credentials, tokens |
| `dr-general` | Detection & Response rules | Custom D&R rules you create |
| `dr-managed` | Managed D&R rules | Third-party curated rules (e.g., Soteria) |
| `yara` | YARA rules | Malware detection, file scanning |
| `lookup` | Lookup tables | Threat intel feeds, allow/block lists |
| `cloudsensor` | Cloud sensor configs | Webhooks, virtual sensors |
| `extension_config` | Extension configurations | Extension-specific settings |

For detailed information on each hive type, see [REFERENCE.md](REFERENCE.md#hive-types).

## Authentication Resource Locators (ARLs)

ARLs are the mechanism for referencing Config Hive data and external resources.

### Hive ARL Format

Reference data stored in the Config Hive:

```
hive://HIVE_TYPE/KEY_NAME
```

**Examples:**
```
hive://secret/my-api-key
hive://yara/malware-detection
hive://lookup/threat-intel
hive://dr-general/suspicious-process
```

### External Resource ARLs

Reference external resources with optional authentication:

```
[methodName,methodDest,authType,authData]
```

**Common Examples:**

```
[https,my.website.com/data]
[https,api.example.com/feed,bearer,hive://secret/api-token]
[gcs,bucket-name/path,gaia,base64(SERVICE_KEY_JSON)]
[github,username/repo/path/file.json]
```

For complete ARL syntax and authentication methods, see [REFERENCE.md](REFERENCE.md#authentication-resource-locators-arls).

## Common Operations

### 1. List Records in a Hive

```bash
limacharlie hive list HIVE_TYPE
```

Examples:
```bash
limacharlie hive list secret
limacharlie hive list dr-general
limacharlie hive list lookup
```

### 2. Get a Specific Record

```bash
limacharlie hive get HIVE_TYPE --key KEY_NAME
```

Example:
```bash
limacharlie hive get secret --key my-api-key
```

### 3. Create or Update a Record

```bash
limacharlie hive set HIVE_TYPE --key KEY_NAME --data FILE_PATH
```

Examples:
```bash
# From file
limacharlie hive set secret --key my-secret --data secret.txt --data-key secret

# From stdin
echo "value" | limacharlie hive set secret --key my-secret --data - --data-key secret
```

### 4. Delete a Record

```bash
limacharlie hive remove HIVE_TYPE --key KEY_NAME
```

Example:
```bash
limacharlie hive remove secret --key old-api-key
```

### 5. Get Metadata Only

```bash
limacharlie hive get_mtd HIVE_TYPE --key KEY_NAME
```

This retrieves only the metadata without exposing the actual data content.

For complete CLI reference, see [REFERENCE.md](REFERENCE.md#cli-command-reference).

## Working with Secrets

### Store a Secret

```bash
# From file
echo "secret-value" > secret.txt
limacharlie hive set secret --key my-secret --data secret.txt --data-key secret

# From stdin
echo "secret-value" | limacharlie hive set secret --key my-secret --data - --data-key secret
```

### Use a Secret

Reference secrets using ARLs:

```yaml
adapters:
  my-adapter:
    type: s3
    credentials: hive://secret/aws-credentials

outputs:
  my-output:
    stream: syslog
    secret_key: hive://secret/syslog-token

extensions:
  ext-virustotal:
    api_key: hive://secret/virustotal-key
```

### Security Best Practices

1. **Never hardcode secrets** - Always use `hive://secret/` references
2. **Use descriptive names** - Name secrets clearly (e.g., `aws-s3-readonly-key`)
3. **Implement least privilege** - Grant only necessary permissions
4. **Rotate regularly** - Update secrets periodically
5. **Separate by environment** - Use different secrets for dev/staging/prod

For more examples, see [EXAMPLES.md](EXAMPLES.md#secrets-management).

## Working with Lookups

Lookups are used for threat intelligence feeds, allow lists, and custom reference data.

### Create a Lookup

```bash
# JSON format
cat <<EOF | limacharlie hive set lookup --key threat-domains --data -
{
  "lookup_data": {
    "evil.com": {"threat_level": "high"},
    "phishing.net": {"threat_level": "medium"}
  }
}
EOF
```

### Use in D&R Rules

```yaml
detect:
  event: DNS_REQUEST
  op: lookup
  path: event/DOMAIN_NAME
  resource: hive://lookup/threat-domains
respond:
  - action: report
    name: "Malicious domain accessed"
```

For more lookup examples and formats, see [EXAMPLES.md](EXAMPLES.md#lookup-management).

## Working with D&R Rules

### Store a Rule

```bash
limacharlie hive set dr-general --key rule-name --data rule.yaml
```

### Via Infrastructure as Code

```yaml
hives:
  dr-general:
    suspicious-process:
      data:
        detect:
          event: NEW_PROCESS
          op: contains
          path: event/FILE_PATH
          value: suspicious
        respond:
          - action: report
            name: Suspicious Process
      usr_mtd:
        enabled: true
        tags:
          - malware-detection
```

For more D&R rule examples, see [EXAMPLES.md](EXAMPLES.md#dr-rule-storage).

## Working with YARA Rules

### Store YARA Rules

```bash
limacharlie hive set yara --key malware-rules --data rules.yara --data-key rule
```

### Use in Commands

```bash
# Scan with hive-stored rule
yara_scan hive://yara/malware-rules --pid 1234
```

### Use in D&R Rules

```yaml
respond:
  - action: task
    command: yara_scan hive://yara/malware-rules --pid "{{ .event.PROCESS_ID }}"
```

For more YARA examples, see [EXAMPLES.md](EXAMPLES.md#yara-rule-management).

## Access Control

### Permission Model

Hive permissions follow a granular model:

- `.get` - Retrieve configuration data
- `.set` - Create or update configuration
- `.del` - Delete configuration
- `.get.mtd` - Get metadata only
- `.set.mtd` - Update metadata only
- `.list` - List available keys

**Examples:**
```
secret.get          # Read secrets
secret.set          # Write secrets
dr.list             # List D&R rules
lookup.get.mtd      # Get lookup metadata only
```

### User Metadata

All hive records support metadata for management:

```yaml
usr_mtd:
  enabled: true              # Enable/disable the record
  expiry: 0                  # Unix timestamp (0 = never expires)
  tags:                      # Categorization tags
    - production
    - threat-intel
  comment: "Description"     # Human-readable description
```

For complete permission details, see [REFERENCE.md](REFERENCE.md#access-control).

## Infrastructure as Code Integration

### Basic IaC Structure

```yaml
version: 3
hives:
  secret:
    my-secret:
      data:
        secret: "value"
      usr_mtd:
        enabled: true
        tags:
          - production

  dr-general:
    my-rule:
      data:
        detect:
          event: NEW_PROCESS
        respond:
          - action: report
      usr_mtd:
        enabled: true
```

### IaC Operations

```bash
# Fetch current configuration
limacharlie infra fetch > config.yaml

# Push configuration (additive merge)
limacharlie infra push -f config.yaml

# Dry run (validate without applying)
limacharlie infra push -f config.yaml --dry-run

# Force push (exact copy, destructive)
limacharlie infra push -f config.yaml --force
```

For complete IaC examples and multi-org management, see [EXAMPLES.md](EXAMPLES.md#infrastructure-as-code).

## Best Practices

### Naming Conventions

1. **Use kebab-case** - `my-secret-name` not `mySecretName`
2. **Be descriptive** - `aws-s3-readonly-credentials` not `aws-key`
3. **Include environment** - `prod-api-key`, `dev-api-key`
4. **Namespace by function** - `threat-intel-virustotal`, `threat-intel-otx`

### Organization

1. **Tag everything** - Use tags for categorization and filtering
2. **Add comments** - Document purpose and usage in metadata
3. **Use consistent structure** - Follow same patterns across hives
4. **Enable/disable** - Use flags instead of deletion for testing

### Security

1. **Never commit secrets** - Never put actual secrets in IaC files
2. **Use hive references** - Always use `hive://secret/` ARLs
3. **Rotate credentials** - Regular rotation schedule
4. **Least privilege** - Grant minimum necessary permissions
5. **Monitor usage** - Track secret and config access

### Testing

1. **Test in dev first** - Never deploy untested configs to production
2. **Use dry runs** - Always use `--dry-run` flag first
3. **Validate rules** - Use replay service for D&R rules
4. **Verify ARLs** - Ensure all ARLs resolve correctly

## Navigation

### Detailed Documentation

- **[REFERENCE.md](REFERENCE.md)** - Complete hive types, ARL syntax, CLI commands, API details
- **[EXAMPLES.md](EXAMPLES.md)** - Common usage patterns with complete examples
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Common issues and solutions

### Quick Reference

```bash
# List hive records
limacharlie hive list HIVE_TYPE

# Get a record
limacharlie hive get HIVE_TYPE --key KEY

# Set a record
limacharlie hive set HIVE_TYPE --key KEY --data FILE

# Remove a record
limacharlie hive remove HIVE_TYPE --key KEY

# Get metadata only
limacharlie hive get_mtd HIVE_TYPE --key KEY
```

### Common Hive Types

```bash
secret          # Encrypted secrets
dr-general      # D&R rules
yara            # YARA rules
lookup          # Lookup tables
cloudsensor     # Cloud sensors
extension_config # Extension configs
```

### ARL Format

```
hive://HIVE_TYPE/KEY_NAME
```

### Web UI Locations

- **Secrets**: Organization Settings > Secrets Manager
- **D&R Rules**: Automation > D&R Rules
- **Lookups**: Automation > Lookups
- **Cloud Sensors**: Sensors > Cloud Sensors
- **Infrastructure as Code**: Organization Settings > Infrastructure as Code

## Key Reminders

1. Always use `hive://TYPE/KEY` format for references
2. Never hardcode secrets - use `hive://secret/` ARLs
3. Tag and comment all hive records for organization
4. Use Infrastructure as Code for version control
5. Test configurations before production deployment
6. Use appropriate permissions for least privilege
7. Store YARA rules with `--data-key rule`
8. Store secrets with `--data-key secret`
9. Use dry-run before pushing IaC changes
10. Enable/disable instead of delete for testing

## Getting Help

When helping users with Config Hive:

1. **Identify the use case** - Secrets, rules, lookups, etc.
2. **Check documentation** - Refer to REFERENCE.md for technical details
3. **Review examples** - Check EXAMPLES.md for similar patterns
4. **Troubleshoot issues** - See TROUBLESHOOTING.md for common problems
5. **Encourage security** - Always promote best practices
6. **Test first** - Recommend dry-run and dev testing

This skill provides comprehensive guidance for managing the Config Hive. Always encourage proper security practices and testing before production deployment.
