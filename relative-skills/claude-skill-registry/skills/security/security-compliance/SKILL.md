---
name: security-compliance
description: Implement comprehensive security for shared library. Use when working with security audits, dependency vulnerabilities, API security, token encryption, or secure coding practices for library consumers. Library security impacts all consuming plugins.
---

# Security & Compliance Guardian

## Mission
Ensure Lidarr.Plugin.Common provides secure foundation for all consuming plugins through comprehensive security practices and secure defaults.

## Current Security Infrastructure
- ✅ **CodeQL Scanning**: Weekly automated scans
- ✅ **Secret Scanning**: GitLeaks active + historical
- ✅ **Dependency Review**: PR-based vulnerability checks
- ✅ **OpenSSF Scorecard**: Weekly security assessment
- ✅ **Token Encryption**: DPAPI/Keychain/SecretService support
- ✅ **Azure Key Vault**: Optional encrypted storage

## Library-Specific Security

### Secure Defaults
- All APIs secure by default
- No insecure opt-in options
- Fail-secure error handling
- Encrypted token storage

### Consumer Impact
- Security issues affect ALL plugins
- Breaking fixes may require major versions
- Clear security migration guides
- Responsible disclosure process

## Expertise Areas

### 1. Secure API Design
- Input validation patterns
- Output sanitization
- Error handling without information leakage
- Cryptographic best practices

### 2. Authentication Security
- OAuth 2.0 + PKCE implementation
- Token storage encryption
- Session management security
- Credential rotation support

### 3. Data Protection
- At-rest encryption (DPAPI, Keychain, Secret Service)
- In-transit security (TLS/HTTPS enforcement)
- Azure Key Vault integration
- Secure cache management

### 4. Supply Chain Security
- Package signing (NuGet)
- Dependency pinning and lock files
- SBOM for library releases
- Transitive dependency monitoring

### 5. Vulnerability Management
- CVE monitoring and response
- Security advisory creation (GitHub)
- Breaking security fixes process
- Backport security patches to old versions

## Enhancement Opportunities
1. **Package Signing**: Sign NuGet packages with certificate
2. **Security Documentation**: Consumer security guide
3. **Threat Model**: Library-specific threat analysis
4. **Fuzzing**: Add fuzz testing for parsers and validators
5. **Penetration Testing**: Regular third-party security audits

## Security Checklist for Library
- [ ] All APIs have input validation
- [ ] Secrets encrypted at rest
- [ ] TLS/HTTPS enforced
- [ ] No default credentials
- [ ] Secure error messages
- [ ] Regular dependency updates
- [ ] Security advisories documented
- [ ] Breaking security fixes have migration guide

## Related Skills
- `api-versioning` - Security through API contracts
- `release-automation` - Secure releases with SBOM

## Examples

### Example 1: Handle Security Vulnerability in Dependency
**User**: "FluentValidation has a critical CVE"
**Action**: Assess impact, update version, test compatibility, create security advisory, release patch for supported versions

### Example 2: Add Token Encryption
**User**: "Implement encrypted token storage"
**Action**: Use DPAPI (Windows), Keychain (macOS), Secret Service (Linux), add Azure Key Vault support, document usage

### Example 3: Security Audit Findings
**User**: "Penetration test found API key in logs"
**Action**: Remove sensitive data from logs, add log scrubbing, update documentation, release hotfix, notify consumers
