---
name: sigma-rule-deployer
description: Use this skill when the user needs help deploying, managing, or understanding Sigma rules, Soteria rules, SOC Prime rules, Community rules, or any other managed rulesets in LimaCharlie.
---

# LimaCharlie Managed Ruleset Deployer

This skill helps you deploy and manage Sigma rules and other managed rulesets in LimaCharlie. Use this when users need help with:

- Deploying Sigma rules from SigmaHQ
- Converting Sigma rules to LimaCharlie format
- Managing Soteria EDR, AWS, or M365 rulesets
- Configuring SOC Prime rules
- Using Community Rules
- Understanding managed ruleset pricing and subscriptions
- Tuning and managing false positives
- Updating and versioning rulesets

## What are Managed Rulesets?

Managed rulesets are professionally maintained, pre-built detection rules that can be deployed with one click to a LimaCharlie organization. They provide:

- **Expert-curated detections**: Rules written by security professionals
- **Automatic updates**: Rulesets are updated as new threats emerge
- **Broad coverage**: MITRE ATT&CK framework alignment
- **Reduced maintenance**: No need to write rules from scratch
- **Cost efficiency**: Leverage community and commercial detections
- **Quick deployment**: Enable comprehensive detection in minutes

LimaCharlie supports multiple managed ruleset sources:
1. **Sigma Rules** - Open-source detection rules from SigmaHQ
2. **Soteria Rules** - Managed EDR, AWS, and M365 detection rulesets
3. **SOC Prime Rules** - Community and enterprise detection content
4. **Community Rules** - AI-assisted conversion of third-party rules

## Quick Start by Ruleset Type

### Sigma Rules - Quick Start

**What**: Open-source detection rules automatically converted to LimaCharlie format

**Best for**: Free, customizable coverage with community-maintained rules

**Quick Deploy**:
```bash
# Convert a single Sigma rule
curl -X POST https://sigma.limacharlie.io/convert/rule \
  -H 'content-type: application/x-www-form-urlencoded' \
  --data-urlencode "rule@my-sigma-rule.yaml"

# Convert multiple rules from GitHub directory
curl -X POST https://sigma.limacharlie.io/convert/repo \
  -d "repo=https://github.com/SigmaHQ/sigma/blob/master/rules/windows/process_creation"
```

**Common targets**: `edr` (default for endpoint detection), `artifact` (for log analysis)

See [REFERENCE.md](REFERENCE.md#sigma-conversion-api) for complete API documentation.
See [EXAMPLES.md](EXAMPLES.md#sigma-deployment-scenarios) for deployment examples.

### Soteria EDR Rules - Quick Start

**What**: Professional managed EDR detection ruleset with auto-updates

**Best for**: Comprehensive EDR coverage across Windows, Linux, macOS

**Quick Deploy**:
1. Navigate to **Add-On Marketplace**
2. Search for "Soteria" or select `soteria-rules-edr`
3. Select your organization
4. Click **Subscribe**
5. Configure required events (listed in subscription UI)

**Required events**: `NEW_PROCESS`, `DNS_REQUEST`, `NETWORK_CONNECTIONS`, `FILE_CREATE`, `REGISTRY_WRITE`, and more

**MITRE Coverage**: https://mitre-attack.github.io/attack-navigator/#layerURL=https%3A%2F%2Fstorage.googleapis.com%2Fsoteria-detector-mapping%2F%2Fall.json

See [REFERENCE.md](REFERENCE.md#soteria-edr-details) for complete event list and configuration.
See [EXAMPLES.md](EXAMPLES.md#soteria-edr-deployment) for deployment scenarios.

### Soteria AWS Rules - Quick Start

**What**: Managed AWS threat detection using CloudTrail and GuardDuty

**Best for**: AWS cloud security monitoring

**Quick Deploy**:
1. Configure AWS CloudTrail adapter
2. Configure AWS GuardDuty adapter
3. Navigate to **Add-On Marketplace**
4. Subscribe to `tor` lookup (free)
5. Subscribe to `soteria-rules-aws`

**Prerequisites**: Active AWS CloudTrail and GuardDuty integrations

See [REFERENCE.md](REFERENCE.md#soteria-aws-details) for adapter configuration.
See [EXAMPLES.md](EXAMPLES.md#aws-security-monitoring) for AWS deployment scenarios.

### Soteria M365 Rules - Quick Start

**What**: Managed Microsoft 365 threat detection

**Best for**: M365/Office 365 security monitoring

**Quick Deploy**:
1. Configure Office 365 adapter to collect audit logs
2. Navigate to **Add-On Marketplace**
3. Subscribe to `tor` lookup (free)
4. Subscribe to `soteria-rules-o365`

**Coverage**: Teams, Word, Excel, PowerPoint, Outlook, OneDrive

See [REFERENCE.md](REFERENCE.md#soteria-m365-details) for adapter configuration.
See [EXAMPLES.md](EXAMPLES.md#m365-threat-detection) for M365 scenarios.

### SOC Prime Rules - Quick Start

**What**: Enterprise content platform with continuous updates

**Best for**: Organizations with SOC Prime subscriptions wanting automated content management

**Quick Deploy**:
1. Create content lists in SOC Prime platform
2. Get API key from SOC Prime (requires trial/paid subscription)
3. Enable `socprime` add-on in LimaCharlie
4. Go to **Integrations** page
5. Enter API key and select content lists

**Sync**: Rules sync automatically every 3 hours
**Attribution**: All detections show `socprime` as author

See [REFERENCE.md](REFERENCE.md#soc-prime-configuration) for detailed setup.
See [EXAMPLES.md](EXAMPLES.md#soc-prime-integration) for integration scenarios.

### Community Rules - Quick Start

**What**: AI-powered conversion of third-party rules (Anvilogic, Sigma, Panther, Okta)

**Best for**: Quick deployment of specific detections from various sources

**Quick Deploy**:
1. Navigate to **Automation > Rules**
2. Click **Add Rule**
3. Click **Community Library** (upper right)
4. Search by CVE, keywords, or MITRE ATT&CK tags
5. Click on a rule to view details
6. Click **Load Rule** (AI converts to LimaCharlie format)
7. Review and customize the converted logic
8. Save and deploy

**Sources**: Anvilogic, Sigma, Panther, Okta rules

See [REFERENCE.md](REFERENCE.md#community-rules-sources) for source details.
See [EXAMPLES.md](EXAMPLES.md#community-rule-deployment) for conversion examples.

## Ruleset Comparison

| Ruleset | Cost | Updates | Visibility | Best For |
|---------|------|---------|------------|----------|
| **Sigma** | Free | Manual | Full | Custom rules, open-source coverage |
| **Soteria EDR** | Paid | Auto | None | Comprehensive EDR coverage |
| **Soteria AWS** | Paid | Auto | None | AWS security monitoring |
| **Soteria M365** | Paid | Auto | None | M365/O365 security |
| **SOC Prime** | Paid* | Auto (3h) | Full | Enterprise content management |
| **Community** | Free | Manual | Full | Specific detections, quick starts |

*Requires SOC Prime subscription (separate from LimaCharlie)

For detailed comparison and selection guidance, see [REFERENCE.md](REFERENCE.md#ruleset-selection-guide).

## False Positive Management

False Positive (FP) rules filter detections globally to reduce alert fatigue.

### Quick FP Rule Creation

**From a detection** (fastest method):
1. Navigate to **Detections** page
2. Find a false positive detection
3. Click **Mark False Positive**
4. Review auto-generated rule
5. Save

**From scratch**:
1. Navigate to **Automation > False Positive Rules**
2. Click **New Rule**
3. Define matching logic
4. Optionally set expiry date
5. Save

### Common FP Patterns

```yaml
# Ignore detection by name
op: is
path: cat
value: my-detection-name
```

```yaml
# Ignore specific file
op: ends with
path: detect/event/FILE_PATH
value: legitimate-tool.exe
case sensitive: false
```

```yaml
# Ignore specific host
op: is
path: routing/hostname
value: build-server-01
```

For complete FP rule syntax and advanced examples, see [REFERENCE.md](REFERENCE.md#false-positive-rules).
For FP troubleshooting by ruleset, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md#false-positive-issues).

## Rule Testing

Always test rules before production deployment.

### Quick Test Commands

```bash
# Validate rule syntax
limacharlie replay --validate --rule-content rule.yaml

# Test against recent data (last 7 days)
limacharlie replay --rule-content rule.yaml \
  --entire-org --last-seconds 604800

# Test with trace mode for debugging
limacharlie replay --rule-content rule.yaml \
  --events event.json --trace
```

For complete testing workflows, see [EXAMPLES.md](EXAMPLES.md#testing-workflows).
For test troubleshooting, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md#testing-issues).

## Rule Management

### View Rules

```bash
# List all rules
limacharlie dr list

# Get specific rule
limacharlie dr get --rule-name my-rule
```

### Deploy Rules

```bash
# Add a rule
limacharlie dr add --rule-name my-rule --rule-file rule.yaml

# Remove a rule
limacharlie dr remove --rule-name my-rule

# Export all rules (backup)
limacharlie dr list --format json > rules-backup.json
```

### Organization with Namespaces

Use prefixes to organize rules by source:
- `sigma-windows-process-creation-suspicious-cmd`
- `soteria-edr-windows-lateral-movement`
- `custom-ransomware-indicators`

For version control and IaC approaches, see [REFERENCE.md](REFERENCE.md#rule-versioning).

## Best Practices Summary

### Deployment Strategy

1. **Start with high-fidelity rulesets**
   - Soteria rules for managed coverage
   - SOC Prime for enterprise content

2. **Add broad coverage**
   - Deploy Sigma rules for common threats
   - Use Community Rules for specific techniques

3. **Customize and tune**
   - Create custom rules for org-specific threats
   - Add FP rules to reduce noise

4. **Continuous improvement**
   - Monitor detection quality
   - Refine rules based on feedback
   - Keep rulesets updated

### Performance Tips

- Don't deploy all rules at once
- Focus on high-priority threats first
- Put restrictive conditions first in rules
- Use suppression for noisy rules
- Monitor rule evaluation metrics

### Security Posture

- Update Sigma rules monthly
- Monitor Soteria/SOC Prime updates
- Map rules to MITRE ATT&CK
- Maintain documentation
- Regular effectiveness reviews

For complete best practices, see [REFERENCE.md](REFERENCE.md#best-practices-detailed).

## Common Issues - Quick Reference

### Sigma conversion fails
- Verify Sigma rule syntax
- Try different target (edr/artifact)
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md#sigma-conversion-issues)

### No detections from Soteria
- Verify required events configured
- Check subscription is active
- Wait 24-48 hours for activation
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md#soteria-no-detections)

### SOC Prime rules not syncing
- Verify API key is valid
- Check subscription is not free tier
- Wait for 3-hour sync cycle
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md#soc-prime-sync-issues)

### Community rules fail to convert
- Try again (AI can be inconsistent)
- Use similar rule as template
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md#community-conversion-failures)

### High false positive rate
- Create FP rules from detections
- Exclude test environments
- Tune thresholds
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md#false-positive-rate)

### Rules not matching events
- Use replay with trace mode
- Check event structure
- Verify event type
- See [TROUBLESHOOTING.md](TROUBLESHOOTING.md#rule-matching-issues)

## Navigation

- **[REFERENCE.md](REFERENCE.md)** - Complete API documentation, configuration details, and advanced features
- **[EXAMPLES.md](EXAMPLES.md)** - Deployment scenarios, use cases, and step-by-step guides
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Issue resolution by ruleset type

## Quick Reference Links

### Documentation
- Sigma Converter: https://sigma.limacharlie.io/
- Converted Sigma Rules: https://github.com/refractionPOINT/sigma-limacharlie/tree/rules
- SOC Prime Platform: https://socprime.com/

### MITRE Coverage
- Soteria All Platforms: https://storage.googleapis.com/soteria-detector-mapping//all.json
- Soteria Windows: https://storage.googleapis.com/soteria-detector-mapping//windows.json
- Soteria Linux: https://storage.googleapis.com/soteria-detector-mapping//linux.json
- Soteria macOS: https://storage.googleapis.com/soteria-detector-mapping//mac.json

### Add-on Extensions
- `soteria-rules-edr` - EDR detection ruleset
- `soteria-rules-aws` - AWS detection ruleset
- `soteria-rules-o365` - M365 detection ruleset
- `socprime` - SOC Prime integration
- `tor-ips` - TOR lookup (free)

## Summary

This skill provides guidance for deploying and managing four types of managed rulesets:

1. **Sigma Rules**: Free, customizable open-source rules requiring manual conversion
2. **Soteria Rules**: Professional managed rulesets with auto-updates (EDR, AWS, M365)
3. **SOC Prime Rules**: Enterprise content platform with continuous sync
4. **Community Rules**: AI-assisted conversion from multiple sources

When helping users:
- Understand their environment and needs
- Recommend appropriate rulesets (see comparison table)
- Guide through testing before production
- Help tune for false positives
- Provide troubleshooting assistance
- Encourage Infrastructure as Code for scale

The best approach combines managed rulesets for baseline coverage with custom rules for organization-specific needs.
