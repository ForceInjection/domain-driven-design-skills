---
name: iot-security-reviewer
description: Expert IoT security review covering network security, authentication, encryption, secure boot, and attack surface analysis. Use when reviewing device security, implementing authentication, hardening firmware, conducting security audits, or analyzing embedded systems for vulnerabilities. Particularly valuable for ESP32/RP2350 projects, BLE/WiFi devices, MQTT systems, and mobile IoT applications.
---

# IoT Security Reviewer

## Overview

Conduct comprehensive security reviews of IoT devices and embedded systems with focus on confidentiality, integrity, availability, authentication, and authorization. Apply industry best practices, OWASP IoT Top 10 guidelines, and platform-specific hardening techniques for ESP32, RP2350, Android, and MQTT-based systems.

## When to Use This Skill

Trigger this skill for:
- Security audits of IoT firmware and embedded code
- Implementing secure authentication mechanisms (BLE, MQTT, API)
- Reviewing network security configurations (WiFi, TLS, certificates)
- Analyzing secure boot, OTA updates, and firmware integrity
- Hardening production deployments and removing vulnerabilities
- Evaluating data protection (encryption at rest and in transit)
- Conducting threat modeling and attack surface analysis
- Reviewing Argus system components or similar IoT architectures

## Security Review Workflow

### 1. Initial Assessment

**Understand the System:**
- Identify all components (devices, gateways, apps, servers)
- Map communication channels and protocols
- Document trust boundaries and data flows
- Catalog sensitive data and assets

**Quick Security Scan:**
- Check for hardcoded credentials in source code
- Verify TLS/encryption is used for network communication
- Confirm secure boot and flash encryption are enabled
- Review authentication mechanisms
- Identify exposed services and open ports

### 2. Apply Security Checklist

Reference the comprehensive checklist in `references/security_checklist.md` covering:

**Confidentiality** - Data encryption, secure storage, log sanitization
**Integrity** - Firmware signing, secure boot, message authentication
**Availability** - DoS protection, resilience, monitoring
**Authentication** - Device identity, user auth, network auth
**Authorization** - Access control, privilege separation, RBAC
**Network Security** - WiFi, MQTT, protocols, segmentation
**Physical Security** - Debug interfaces, tamper detection
**Compliance** - OWASP IoT Top 10, privacy regulations

Work through each section systematically, checking off items as verified or identifying gaps.

### 3. Vulnerability Analysis

**Review Against OWASP IoT Top 10:**

Load `references/common_vulnerabilities.md` for detailed coverage of:
1. Weak, guessable, or hardcoded passwords
2. Insecure network services
3. Insecure ecosystem interfaces
4. Lack of secure update mechanism
5. Use of insecure or outdated components
6. Insufficient privacy protection
7. Insecure data transfer and storage
8. Lack of device management
9. Insecure default settings
10. Lack of physical hardening

**Additional Vulnerability Classes:**
- Side-channel attacks
- Buffer overflow and memory corruption
- Command injection
- Replay attacks
- Man-in-the-middle attacks
- Denial of service

For each vulnerability category:
- Check if the system is susceptible
- Assess severity and exploitability
- Recommend specific mitigations
- Prioritize fixes based on risk

### 4. Code Review and Implementation Guidance

**Secure Implementation Examples:**

When implementing security features or reviewing code, reference `references/secure_examples.md` for proven patterns:

- **WiFi Security**: NVS storage with encryption, flash encryption configuration
- **MQTT TLS**: Certificate validation, mutual TLS, cipher suite selection
- **BLE Security**: Secure Simple Pairing, bonding, passkey implementation
- **OTA Updates**: Signature verification, secure boot integration, rollback protection
- **API Keys**: Rotation strategies, secure storage, grace period handling

**Code Review Focus Areas:**
- Memory safety (bounds checking, zero after use)
- Cryptographic implementation (use proven libraries)
- Input validation (sanitization, length checks)
- Error handling (secure failure, no info leakage)
- Privilege separation (least privilege principle)

### 5. Architecture-Specific Reviews

**For Argus or Similar Systems:**

Load `references/argus_security.md` for system-specific guidance:

- **Network segmentation**: VLAN configuration, firewall rules
- **Trust model**: Multi-tier authentication and encryption
- **Component security**: T-Embed (ESP32-S3), Presto (RP2350), Android app
- **MQTT broker**: Mosquitto configuration, ACL, TLS setup
- **Threat scenarios**: Specific attack vectors and mitigations
- **Incident response**: Detection, response, recovery procedures

**Apply to Your System:**
- Adapt the trust model to your architecture
- Customize ACL rules for your topic structure
- Implement appropriate certificate pinning
- Configure network segmentation
- Define incident response procedures

### 6. Testing and Validation

**Static Analysis:**
- Run cppcheck or clang-tidy on C/C++ code
- Use SonarQube for multi-language projects
- Scan dependencies with OWASP Dependency-Check

**Dynamic Testing:**
- Test authentication bypass attempts
- Verify certificate validation
- Attempt replay attacks
- Test rate limiting and DoS protection
- Validate input sanitization

**Network Analysis:**
- Capture traffic with Wireshark
- Verify all communication is encrypted
- Check for certificate validation
- Scan for open ports with nmap
- Test for MITM vulnerabilities

**Penetration Testing:**
- Attempt to extract credentials from device
- Test physical security (debug ports, JTAG)
- Try firmware downgrade attacks
- Test BLE pairing security
- Attempt privilege escalation

### 7. Documentation and Reporting

**Security Report Structure:**
1. **Executive Summary**: High-level findings and risk assessment
2. **System Overview**: Components, architecture, data flows
3. **Findings**: Vulnerabilities discovered with severity ratings
4. **Recommendations**: Prioritized remediation steps
5. **Compliance**: OWASP IoT Top 10 coverage, regulatory compliance
6. **Testing Results**: Static analysis, penetration testing outcomes
7. **Action Items**: Specific tasks with assignees and timelines

**Risk Rating:**
- **Critical**: Hardcoded credentials, no encryption, exposed debug ports
- **High**: Weak authentication, missing OTA security, no input validation
- **Medium**: Outdated libraries, verbose logging, weak cipher suites
- **Low**: Missing monitoring, incomplete documentation, minor hardening

## Security Implementation Guidelines

### Quick Wins (Implement First)

1. **Enable Flash Encryption** (ESP32)
   ```c
   #define CONFIG_SECURE_FLASH_ENC_ENABLED 1
   ```

2. **Enable Secure Boot**
   ```c
   #define CONFIG_SECURE_BOOT_V2_ENABLED 1
   ```

3. **Use TLS for All Network Communication**
   - MQTT: Use mqtts:// on port 8883
   - HTTP: Use https:// only
   - Validate certificates, don't skip verification

4. **Store Credentials Securely**
   - Use encrypted NVS on ESP32
   - Android Keystore for mobile apps
   - Never hardcode in source code

5. **Implement API Key Rotation**
   - Generate strong, random keys
   - Rotate every 90 days
   - Support key grace period

### Platform-Specific Hardening

**ESP32/ESP32-S3:**
- Enable flash encryption and secure boot
- Disable JTAG and UART console in production
- Use hardware RNG for key generation
- Implement watchdog timer
- Clear sensitive data from memory after use

**RP2350 (MicroPython):**
- Hash validation for uploaded scripts
- Whitelist allowed modules
- Restrict filesystem access
- Secure BLE bonding storage
- Disable dangerous built-ins in production

**Android:**
- Use Android Keystore for secrets
- Implement certificate pinning
- Enable ProGuard/R8 obfuscation
- Remove debug logs in release builds
- Network security configuration with cleartext disabled

**MQTT Broker:**
- Require TLS on port 8883
- Enforce client authentication
- Implement topic-based ACL
- Use strong cipher suites (TLS 1.2+)
- Monitor failed authentication attempts

### Defense in Depth Strategy

Apply multiple layers of security:

1. **Network Layer**: TLS encryption, certificate validation, network segmentation
2. **Application Layer**: Authentication, authorization, input validation
3. **Device Layer**: Secure boot, flash encryption, physical hardening
4. **Monitoring Layer**: Logging, anomaly detection, alerting
5. **Operational Layer**: Update mechanism, incident response, key rotation

## Using the References

### Quick Reference Guide

- **Conducting a security audit?** → Start with `references/security_checklist.md`
- **Reviewing for specific vulnerabilities?** → Use `references/common_vulnerabilities.md`
- **Implementing secure features?** → Reference `references/secure_examples.md`
- **Reviewing Argus system?** → Load `references/argus_security.md`

### Search Patterns for Large References

If reference files are extensive, use these grep patterns:

```bash
# Find specific vulnerability information
grep -i "hardcoded" references/common_vulnerabilities.md

# Locate implementation examples
grep -B5 -A20 "esp_mqtt_client_config_t" references/secure_examples.md

# Find checklist items
grep "\[ \]" references/security_checklist.md

# Search for Argus-specific guidance
grep -i "t-embed\|presto" references/argus_security.md
```

## Common Security Patterns

### Secure By Default

- Deny by default, allow explicitly
- Fail securely (deny on error)
- Minimum necessary privileges
- Encrypted by default
- Strong authentication required

### Security Anti-Patterns to Avoid

❌ Hardcoded credentials or API keys
❌ Disabled certificate validation ("to make it work")
❌ HTTP instead of HTTPS
❌ Admin/admin default credentials
❌ Debug code left in production
❌ Sensitive data in logs
❌ Unsigned firmware updates
❌ No input validation
❌ Weak encryption (WEP, MD5, SHA1)
❌ Exposed debug ports (JTAG, UART)

### Security Best Practices

✅ Use proven crypto libraries (mbedTLS, OpenSSL)
✅ Validate all inputs (length, type, range)
✅ Use constant-time comparisons for secrets
✅ Zero sensitive data after use
✅ Implement rate limiting
✅ Log security events
✅ Keep dependencies updated
✅ Enable all security features
✅ Regular security audits
✅ Incident response plan

## Tools and Techniques

### Static Analysis
- **cppcheck**: `cppcheck --enable=all src/`
- **clang-tidy**: `clang-tidy src/*.cpp`
- **SonarQube**: Multi-language code quality

### Dependency Scanning
- **OWASP Dependency-Check**: Identify vulnerable libraries
- **npm audit** / **pip-audit**: Language-specific scanners

### Network Analysis
- **Wireshark**: Packet capture and protocol analysis
- **nmap**: Port scanning and service detection

### Penetration Testing
- **Metasploit**: Exploit framework
- **Aircrack-ng**: WiFi security testing
- **Burp Suite**: Web application testing

## Output Format

When completing a security review, provide:

1. **Summary**: Overall security posture (Strong/Moderate/Weak)
2. **Critical Findings**: Issues requiring immediate attention
3. **Compliance Status**: OWASP IoT Top 10 coverage
4. **Recommendations**: Prioritized action items with code examples
5. **Risk Assessment**: Likelihood and impact of identified vulnerabilities
6. **Remediation Timeline**: Suggested timeline for fixes

Use code examples from the references to demonstrate secure implementations for identified issues.

## Continuous Security

Security is not a one-time review but an ongoing process:

- **Regular audits**: Quarterly security reviews
- **Dependency updates**: Monitor and patch vulnerabilities
- **Threat modeling**: Update as architecture evolves
- **Penetration testing**: Annual third-party testing
- **Incident response drills**: Test response procedures
- **Security training**: Keep team updated on best practices

---

This skill provides comprehensive IoT security review capabilities. Load the reference files as needed for detailed checklists, vulnerability information, implementation examples, and system-specific guidance.
