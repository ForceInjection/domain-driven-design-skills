---
name: security-auditor
description: Performs comprehensive security audits of KrakenD configurations to identify vulnerabilities, authentication gaps, and security best practices violations with Flexible Configuration support
---

# KrakenD Security Auditor

## Purpose
Performs comprehensive security audits of KrakenD configurations using the native `krakend audit` command with intelligent fallback and automatic Flexible Configuration support. Identifies authentication gaps, authorization issues, exposure risks, and security best practices violations with actionable remediation steps.

## When to activate
- User asks to audit security: "check security", "security audit", "is this secure"
- User mentions security concerns: "secure my api", "security issues", "vulnerabilities"
- User wants to review authentication/authorization: "check auth", "review authentication"
- User wants to find security problems: "security scan", "find security issues"
- After completing configuration changes to verify security posture
- Before production deployment (proactively suggest)

## What this skill does

1. **Performs comprehensive security audit** using smart three-tier approach:
   - Native `krakend audit` command (most comprehensive)
   - Docker-based audit (fallback)
   - Basic security checks (last resort: CORS, auth, rate limiting, debug endpoints)

2. **Auto-detects Flexible Configuration** (CE and EE variants) and adjusts audit accordingly

3. **Categorizes issues** by severity: Critical → High → Medium → Low → Info

4. **Provides specific remediation** with:
   - Exact location (JSON path)
   - Step-by-step fix instructions
   - Example configuration snippets
   - Links to relevant documentation

5. **Checks common vulnerabilities**:
   - Missing or weak authentication/authorization
   - Exposed sensitive endpoints
   - Missing rate limiting (DoS protection)
   - Lack of CORS configuration
   - Debug endpoints in production
   - Insecure headers
   - Overly permissive configurations

## Security Categories

Understanding these helps interpret audit results:

- **authentication**: Missing or weak authentication mechanisms
- **authorization**: Authorization bypasses or inadequate access controls
- **exposure**: Exposed sensitive information or debug endpoints
- **dos-protection**: Lack of rate limiting or abuse prevention
- **security-headers**: Missing security-related HTTP headers
- **encryption**: Weak or missing encryption (TLS, JWT signing)
- **injection**: Potential injection vulnerabilities
- **best-practice**: Security best practice violations

## Tools used
- `audit_security` - Comprehensive security audit (smart 3-tier fallback: native → Docker → basic checks)
- `list_features` - Browse available security features and edition requirements
- `get_feature_config_template` - Get configuration templates for security features
- `search_documentation` - Find relevant security documentation
- `validate_config` - Validate configuration structure alongside security checks

## Security Audit Workflow

### Step 1: Prepare Audit
- Read the configuration file
- Detect Flexible Configuration (CE or EE variant)
- Determine required edition (CE or EE)
- Check for LICENSE file if EE features detected

### Step 2: Run Security Audit
Use `audit_security` tool which automatically:
- Selects best audit method (native → Docker → basic)
- Handles FC detection and configuration
- Infers version from `$schema` field
- Categorizes findings by severity
- Generates remediation guidance

### Step 3: Analyze Results
- Group findings by severity (Critical, High, Medium, Low, Info)
- Identify quick wins vs. long-term improvements
- Highlight authentication/authorization gaps first
- Note edition-specific recommendations

### Step 4: Present Report
- Show severity summary upfront
- Detail critical and high severity issues first
- Provide specific remediation steps
- Include configuration examples
- Link to relevant documentation

### Audit Commands

When showing users how to manually audit, provide command based on: (1) Version from `$schema`, (2) Edition (CE/EE by features), (3) FC detection, (4) LICENSE for EE.

**Examples:**
```bash
# CE audit
docker run --rm -v $(pwd):/etc/krakend krakend:VERSION audit -c /etc/krakend/krakend.json

# EE audit (LICENSE file present)
docker run --rm -v $(pwd):/etc/krakend krakend/krakend-ee:VERSION audit -c /etc/krakend/krakend.json
```

**Accuracy:** Native `krakend audit` (most comprehensive) > Docker > Basic checks (limited scope).
**Images:** `krakend:VERSION` (CE), `krakend/krakend-ee:VERSION` (EE).

## Output format

Provide a clear, actionable security report:

```
# KrakenD Security Audit Report

## Summary
🔍 Audit Method: Native KrakenD (most comprehensive)
⚠️ Issues Found: 3 high, 2 medium, 1 low
🎯 Priority: Address high severity issues immediately

## Critical Issues
None found ✓

## High Severity Issues

### 1. Missing Authentication on Sensitive Endpoints
**Severity**: HIGH
**Category**: authentication
**Location**: $.endpoints[2] (POST /api/users)

**Issue**:
Endpoint accepts POST requests without any authentication mechanism. This allows anonymous users to create resources.

**Remediation**:
1. Add JWT validation to the endpoint:
```json
"extra_config": {
  "auth/validator": {
    "alg": "RS256",
    "audience": ["https://api.example.com"],
    "jwk_url": "https://auth.example.com/.well-known/jwks.json"
  }
}
```

**References**:
- https://www.krakend.io/docs/authorization/jwt-validation/
- https://www.krakend.io/docs/enterprise/authentication/api-keys/

---

### 2. Debug Endpoint Enabled
**Severity**: HIGH
**Category**: exposure
**Location**: $.extra_config["debug_endpoint"]

**Issue**:
Debug endpoint is enabled, exposing internal application state and metrics to potential attackers.

**Remediation**:
Remove or disable the debug endpoint in production:
```json
"extra_config": {
  "debug_endpoint": false
}
```
Or remove the entire "debug_endpoint" configuration block.

**References**:
- https://www.krakend.io/docs/service-settings/debug-endpoint/

## Medium Severity Issues

### 3. Missing CORS Configuration
**Severity**: MEDIUM
**Category**: security-headers
**Location**: $.extra_config (root level)

**Issue**:
No CORS configuration found. This may cause browser requests to fail or allow all origins by default.

**Remediation**:
Add CORS configuration with explicit allowed origins:
```json
"extra_config": {
  "security/cors": {
    "allow_origins": ["https://yourdomain.com"],
    "allow_methods": ["GET", "POST", "PUT"],
    "allow_headers": ["Authorization", "Content-Type"],
    "expose_headers": ["Content-Length"],
    "max_age": "12h",
    "allow_credentials": true
  }
}
```

**References**:
- https://www.krakend.io/docs/service-settings/cors/

## Best Practices Recommendations

✓ Circuit breakers configured for backends
✓ Timeouts configured
⚠️ Consider adding request/response logging for security monitoring
⚠️ Consider implementing API key authentication for service-to-service calls
⚠️ Review and minimize backend exposure (principle of least privilege)

## Next Steps

1. **Immediate**: Fix all high severity issues (authentication, debug endpoint)
2. **Short-term**: Address medium severity issues (CORS, rate limiting)
3. **Long-term**: Implement low severity improvements and best practices
4. **Ongoing**: Run security audits regularly, especially after configuration changes
```

## Best Practices

1. **Severity-first** - Always show critical/high severity issues first (these need immediate action)
2. **Be specific and actionable** - Don't just say "insecure", explain what's wrong and exactly how to fix it
3. **Include context** - Show exact location using JSON paths
4. **Provide examples** - Include working configuration snippets for remediation
5. **Link to docs** - Always include relevant KrakenD documentation URLs
6. **Consider edition** - Recommend CE-compatible solutions unless user has EE
7. **Show audit method** - Indicate which validation method was used (affects comprehensiveness)
8. **Balance security with usability** - Don't recommend overly restrictive configs without explanation
9. **Follow up** - Suggest re-running audit after fixes are applied
10. **Context matters** - Development vs. production requires different security levels

## Examples

### Example 1: User asks "Is my API secure?"

**Response:**
"I'll perform a comprehensive security audit of your KrakenD configuration."

[Use `audit_security`]
[Present structured report as shown above]

"I found 3 high severity issues that should be addressed immediately. Would you like me to help you fix these issues?"

### Example 2: Pre-production security check

**Response:**
"I'll audit your configuration for security issues before production deployment."

[Use `audit_security` with production config]
[Present findings]

"Your configuration has 2 critical issues that must be fixed before production:
1. No authentication on admin endpoints
2. Debug mode still enabled

Would you like me to fix these now?"

### Example 3: Post-fix re-audit

**Response:**
"I'll re-run the security audit to verify your authentication changes."

[Use `audit_security` again]
[Compare with previous results if available]

"Great progress! The authentication issue is now resolved. Remaining items:
- 1 high severity: Debug endpoint still enabled
- 2 medium severity: Missing CORS and rate limiting

Shall we address these next?"

### Example 4: Fallback to basic checks

**Response:**
"KrakenD binary and Docker are not available, so I'll perform basic security checks."

[Use `audit_security` which falls back to basic checks]

"I performed basic security checks and found:
- Missing CORS configuration
- No authentication on POST endpoints
- No rate limiting configured
- Debug endpoint enabled

Note: For a comprehensive audit, install KrakenD or Docker to run the full `krakend audit` command. These basic checks cover common issues but may miss advanced security problems."

## When to Run Security Audits

Proactively suggest security audits:
- ✅ Before initial deployment
- ✅ After any configuration changes
- ✅ After adding new endpoints
- ✅ Before major releases
- ✅ After security incidents
- ✅ Periodically (monthly/quarterly)
- ✅ After upgrading KrakenD versions
- ✅ When changing authentication mechanisms

## Integration & Error Handling

### Integration with other skills
- After `config-builder` creates new config → Suggest security audit
- If `config-validator` finds issues → Mention security-specific audit available
- Before production deployment → Strongly recommend security audit
- If user asks about specific security features → Offer to run full audit

### Error handling
- **Config file not found**: Ask user which file to audit
- **Config is invalid JSON**: Run syntax check first via `config-validator`, then report
- **Audit produces no output**: Explain that no issues were found (best case!)
- **KrakenD audit fails**: Tool automatically falls back to Docker, then basic checks
- **Too many issues (>15)**: Group by severity and offer to show details incrementally
- **Mix of CE/EE features**: Note in recommendations which features require EE
