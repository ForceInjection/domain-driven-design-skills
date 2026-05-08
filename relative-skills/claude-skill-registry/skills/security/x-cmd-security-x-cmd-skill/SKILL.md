---
name: x-cmd-security
description: This skill provides comprehensive security assessment and vulnerability management tools through x-cmd CLI, including network reconnaissance with Shodan, vulnerability scanning with OSV, and known exploited vulnerability tracking with KEV. This skill should be used when users need to perform security assessments, vulnerability research, network reconnaissance, or security monitoring from command line interfaces.
---

# x-cmd Security Assessment Tools

## Overview

This skill provides professional security assessment and vulnerability management capabilities through the x-cmd ecosystem. The tools enable security professionals, developers, and system administrators to perform network reconnaissance, vulnerability scanning, and security monitoring directly from the terminal.

## Available Tools

### Shodan Network Intelligence (shodan)
Comprehensive network reconnaissance and internet intelligence gathering.

- **Usage**: `x shodan [subcommand]`
- **Key subcommands**:
  - `host` - Search and analyze host information
  - `scan` - Network scanning and port discovery
  - `dns` - DNS resolution and lookup
  - `alert` - Network monitoring and alerts
  - `cve` - CVE vulnerability checking
  - `geo` - Geolocation-based network testing
- **Examples**:
  - `x shodan scan create 8.8.8.8 1.1.1.1=53/dns-udp,443/https` - Scan specific ports
  - `x shodan dns res google.com facebook.com` - DNS resolution
  - `x shodan cve` - Check specific product vulnerabilities
  - `x shodan geo geoping 8.8.8.8,4.4.4.4` - Multi-location ping tests

### OSV Vulnerability Scanner (osv)
Open Source Vulnerability scanning and dependency analysis.

- **Usage**: `x osv [subcommand]`
- **Key subcommands**:
  - `query` - Query vulnerabilities for specific packages
  - `scanner` - Use osv-scanner for vulnerability detection
  - `sarif` - Generate SARIF vulnerability reports
  - `vuln` - Get detailed vulnerability information
  - `eco` - List supported ecosystems
- **Examples**:
  - `x osv q -p jq -v 1.7.1` - Query vulnerabilities for jq 1.7.1
  - `x osv sarif` - Scan system packages and generate SARIF report
  - `x osv vuln OSV-2020-111` - Get detailed vulnerability info
  - `x osv : git` - Search for git-related vulnerabilities

### KEV Vulnerability Catalog (kev)
Known Exploited Vulnerabilities tracking and management.

- **Usage**: `x kev [subcommand]`
- **Key subcommands**:
  - `ls` - List all known exploited vulnerabilities
  - `top` - List top N vulnerabilities
- **Examples**:
  - `x kev ls` - List all KEV entries
  - `x kev top 100` - List top 100 exploited vulnerabilities

## Security Use Cases

### Network Security Assessment
- Use `x shodan host` to discover exposed services
- Use `x shodan scan` for targeted port scanning
- Use `x shodan alert` for continuous monitoring

### Vulnerability Management
- Use `x osv scanner` for dependency vulnerability scanning
- Use `x osv query` for specific package vulnerability checks
- Use `x kev ls` to track actively exploited vulnerabilities

### Security Research
- Use `x shodan cve` for CVE-based vulnerability research
- Use `x osv vuln` for detailed vulnerability analysis
- Use `x shodan trend` for historical security trend analysis

## Installation and Setup

### Prerequisites
- x-cmd CLI installed
- Internet connection
- Shodan API key (for full shodan functionality)

### Configuration

#### Shodan API Setup
```bash
x shodan init  # Interactive configuration
x shodan --cfg key=<your-shodan-api-key>
```

Get Shodan API key from: https://account.shodan.io/

#### OSV Configuration
OSV typically works without additional configuration for basic queries. For advanced scanning:
```bash
x osv scanner --help  # View scanning options
```

## Security Best Practices

### Responsible Usage
- Only scan networks and systems you own or have explicit permission to test
- Respect rate limits and terms of service for all tools
- Use vulnerability information for defensive security purposes

### Data Protection
- API keys and sensitive configuration stored locally
- Review data retention settings with `cfg` subcommands
- Be mindful of information disclosure in shared environments

### Compliance Considerations
- Ensure usage complies with local laws and regulations
- Obtain proper authorization before security testing
- Document security assessments for audit purposes

## Integration with Other Tools

### Data Processing
- Pipe output to `x jq` for JSON processing
- Use with `@zh` for Chinese translation of security findings
- Export to CSV/JSON for further analysis

### Reporting
- Generate SARIF reports with `x osv sarif`
- Use `x shodan download` for data collection
- Combine with documentation tools for security reports

## Troubleshooting

### Common Issues
- **API key errors**: Verify Shodan API key configuration
- **Rate limiting**: Respect API rate limits and use appropriate intervals
- **Network connectivity**: Check internet connection and proxy settings
- **Permission errors**: Ensure proper authorization for security testing

### Performance Optimization
- Use `--limit` flags to control data volume
- Cache results when appropriate
- Use specific queries rather than broad searches

## Support and Resources

- **Shodan Documentation**: https://help.shodan.io/
- **OSV Project**: https://osv.dev/
- **KEV Catalog**: CISA Known Exploited Vulnerabilities
- **x-cmd Security**: https://x-cmd.com/mod/security

For additional help:
- Use `x [tool] --help` for specific tool documentation
- Visit individual module pages for detailed usage
- Check tool-specific configuration options
