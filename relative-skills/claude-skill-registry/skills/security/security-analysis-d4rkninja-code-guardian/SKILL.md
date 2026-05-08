---
name: security-analysis
description: Master skill for comprehensive security analysis. Identifies technology stack and delegates to specialized security sub-skills for deep vulnerability assessment.
---

# Security Analysis Framework

## Instructions
You are the entry point for security vulnerability scanning and analysis. Your goal is to **Identify** the technology stack, **Scan** for vulnerabilities, **Assess** real-world risk, and **Remediate** with actionable solutions.

## Core Security Analysis Process

### Phase 1: Discovery \u0026 Reconnaissance
1. **Technology Stack Detection**: Identify languages, frameworks, and dependencies
2. **Attack Surface Mapping**: Enumerate all entry points (APIs, forms, file uploads, etc.)
3. **Dependency Inventory**: List all direct and transitive dependencies
4. **Configuration Review**: Check for security-relevant configurations

### Phase 2: Vulnerability Scanning

#### A. Static Code Analysis
Scan source code for:
- **Injection Vulnerabilities**: SQL, NoSQL, Command, LDAP, XPath, Template injection
- **Broken Authentication**: Weak password policies, session fixation, credential storage
- **Sensitive Data Exposure**: Hardcoded secrets, unencrypted data, logging sensitive info
- **XML External Entities (XXE)**: Unsafe XML parsing
- **Broken Access Control**: Missing authorization checks, IDOR vulnerabilities
- **Security Misconfiguration**: Default credentials, unnecessary features enabled
- **Cross-Site Scripting (XSS)**: Reflected, Stored, DOM-based
- **Insecure Deserialization**: Unsafe object deserialization
- **Using Components with Known Vulnerabilities**: Outdated dependencies
- **Insufficient Logging \u0026 Monitoring**: Missing security event logging

#### B. Dependency Vulnerability Analysis
**IMPORTANT**: Always run native security audit tools FIRST before web search for faster and more accurate results.

For each dependency:
1. **Extract Version Information**: From package manifests (package.json, requirements.txt, pom.xml, etc.)

2. **Run Native Security Audit Tools** (Primary Method):
   - **Node.js/JavaScript**: `npm audit` or `npm audit --json` for detailed output
   - **Python**: `pip-audit` or `safety check` for vulnerability scanning
   - **Java/Maven**: `mvn dependency-check:check` or `mvn versions:display-dependency-updates`
   - **Java/Gradle**: `./gradlew dependencyCheckAnalyze`
   - **.NET**: `dotnet list package --vulnerable` or `dotnet list package --outdated`
   - **PHP/Composer**: `composer audit` for security vulnerabilities
   - **Ruby**: `bundle audit check` for known vulnerabilities
   - **Rust**: `cargo audit` for RustSec advisories
   - **Go**: `go list -m -u all` for updates, or use `govulncheck`
   
3. **Parse Audit Results**: Extract CVE IDs, severity levels, and affected versions from tool output

4. **Web Search for CVEs** (Secondary/Verification Method):
   If native tools are unavailable or for additional verification:
   - National Vulnerability Database (NVD)
   - Snyk Vulnerability DB
   - GitHub Security Advisories
   - npm/PyPI/Maven/NuGet security advisories
   
5. **Check Latest Versions**: Compare against current stable releases

6. **Assess Severity**: Use CVSS scores and exploit availability

7. **Verify Patch Availability**: Check if fixes exist and are stable

#### C. Context-Aware Analysis
For each identified vulnerability:
1. **Code Path Tracing**: Is the vulnerable code actually used?
2. **Import Analysis**: Are vulnerable functions imported?
3. **Call Graph Analysis**: Are vulnerable methods called?
4. **Data Flow Analysis**: Does user input reach vulnerable code?
5. **Environment Context**: Is this a dev-only or production dependency?

### Phase 3: Advanced Vulnerability Discovery (Discovery over Checking)

**Logic**: Move beyond static pattern matching. Actively hunt for vulnerabilities using dynamic analysis, data flow tracing, and fuzzing methodologies.

#### A. Taint Analysis & Data Flow Tracing
*   **Concept**: Trace data from "Sources" (user input, API responses, files) to "Sinks" (DB queries, HTML output, shell commands).
*   **Action**:
    1.  **Identify Sources**: Map all entry points (`req.body`, `argv`, `params`, `headers`).
    2.  **Identify Sinks**: Map dangerous functions (`eval()`, `exec()`, `innerHTML`, `SQL execution`).
    3.  **Trace Flow**: Manually or tool-assist trace if input reaches a sink without a "sanitizer" step.
    4.  **Zero Tolerance**: If ANY user input reaches a sensitive sink without strict validation, flag as **CRITICAL**.

#### B. Fuzzing & Property-Based Testing
*   **Concept**: Bombard functions with massive amounts of random, malformed, or boundary-case data to trigger crashes or unexpected behaviors.
*   **Action**:
    1.  **Generative Fuzzing**: Use tools (like `Atheris` for Python, `Jazzer` for Java) to generate random inputs.
    2.  **Structure-Aware Fuzzing**: Generate inputs that follow valid structures (JSON, XML) but contain malicious payloads.
    3.  **Boundary Testing**: Specifically test empty strings, max integer values, unicode characters, and null bytes.

#### C. Manual Logic Abusability
*   **Concept**: Code may be secure syntactically but insecure logically (e.g., race conditions, price manipulation).
*   **Action**:
    1.  **Race Conditions**: Identify concurrent state updates (db transactions, file writes).
    2.  **Business Logic**: Can you buy an item for $0? Can you access data ID+1?
    3.  **State Manipulation**: Can you skip a step in a multi-step flow?

#### D. Zero Tolerance Data Compromise Check
*   **Mandate**: **Any** potential for data compromise (minor or major) must be flagged.
*   **Checks**:
    1.  **Leakage**: Are PII, secrets, or internal IDs exposed in logs, error messages, or API responses?
    2.  **Integrity**: Can data be modified without authorization?
    3.  **Availability**: Can a payload cause a crash or high resource consumption (DoS)?

### Phase 4: Risk Assessment

#### Severity Classification
```
🔴 CRITICAL (CVSS 9.0-10.0)
- Remote code execution
- Authentication bypass
- SQL injection in production endpoints
- Exposed secrets/credentials

🟠 HIGH (CVSS 7.0-8.9)
- Privilege escalation
- Sensitive data exposure
- XSS in authenticated areas
- Known exploits available

🟡 MEDIUM (CVSS 4.0-6.9)
- CSRF vulnerabilities
- Information disclosure
- Weak cryptography
- Outdated dependencies with patches available

🔵 LOW (CVSS 0.1-3.9)
- Minor information leaks
- Deprecated functions
- Code quality issues with security implications

⚪ INFO (CVSS 0.0)
- Security best practice recommendations
- Hardening opportunities
- Awareness items
```

#### Risk Factors
- **Exploitability**: How easy to exploit? (Automated, Simple, Complex, Theoretical)
- **Impact**: What's at risk? (Data breach, Service disruption, Financial loss)
- **Scope**: What's affected? (Single user, All users, System-wide)
- **Exposure**: Who can exploit? (Internet, Authenticated users, Admins only)

### Phase 5: Remediation Planning

#### Remediation Strategies
1. **Immediate Fixes** (Critical/High)
   - Version upgrades with compatibility verification
   - Code patches with security testing
   - Configuration hardening
   - Temporary mitigations (WAF rules, input validation)

2. **Scheduled Fixes** (Medium)
   - Plan for next sprint/release
   - Coordinate with feature development
   - Comprehensive testing required

3. **Long-term Improvements** (Low/Info)
   - Architectural refactoring
   - Security framework adoption
   - Developer training needs

#### Upgrade Guidance Template
```
📦 Package: [name]
├─ Current Version: [x.y.z]
├─ Vulnerable: YES
├─ CVE: [CVE-YYYY-NNNNN]
├─ Severity: [LEVEL]
├─ Fixed In: [a.b.c]
├─ Latest Stable: [p.q.r]
├─ Breaking Changes: [YES/NO]
├─ Migration Guide: [URL]
└─ Recommendation: Upgrade to [version] - [reason]
```

## Technology-Specific Security Patterns

### Node.js / JavaScript Security
**Focus Areas**: Prototype pollution, RegEx DoS, dependency confusion, npm package hijacking
**Key Checks**:
- `eval()`, `Function()`, `vm.runInContext()` usage
- Unsafe deserialization with `JSON.parse()` on user input
- Command injection via `child_process.exec()`
- Path traversal in file operations
- Weak random number generation (`Math.random()`)
- Missing helmet.js security headers
- CORS misconfiguration
- JWT token vulnerabilities (weak secrets, no expiration)
*Refer to [node_security.md](node_security.md) for detailed patterns.*

### Python Security
**Focus Areas**: Pickle deserialization, SQL injection, SSTI, XML vulnerabilities
**Key Checks**:
- `eval()`, `exec()`, `compile()` with user input
- Unsafe pickle/yaml deserialization
- SQL injection in raw queries
- Server-Side Template Injection (Jinja2, Django templates)
- XML bomb attacks
- Weak cryptography (MD5, SHA1 for passwords)
- Path traversal in `open()` calls
- Command injection via `os.system()`, `subprocess.shell=True`
*Refer to [python_security.md](python_security.md) for detailed patterns.*

### PHP Security
**Focus Areas**: RCE, file inclusion, type juggling, deserialization
**Key Checks**:
- `eval()`, `assert()`, `create_function()` usage
- Local/Remote File Inclusion (LFI/RFI)
- SQL injection (especially with `mysql_*` functions)
- Type juggling vulnerabilities (`==` vs `===`)
- Unsafe deserialization (`unserialize()`)
- Command injection via `exec()`, `shell_exec()`, `system()`
- XXE in `simplexml_load_string()`
- Session fixation vulnerabilities
*Refer to [php_security.md](php_security.md) for detailed patterns.*

### Go Security
**Focus Areas**: SQL injection, command injection, race conditions, unsafe reflection
**Key Checks**:
- SQL injection in database queries without parameterization
- Command injection via `exec.Command()` with user input
- Race conditions in concurrent code
- Unsafe use of `reflect` package
- Path traversal in file operations
- Weak random number generation (`math/rand` vs `crypto/rand`)
- Missing input validation
- Improper error handling exposing sensitive info
*Refer to [go_security.md](go_security.md) for detailed patterns.*

### Java / Kotlin Security
**Focus Areas**: Deserialization, XXE, SSRF, Spring vulnerabilities
**Key Checks**:
- Unsafe deserialization (`ObjectInputStream`)
- XXE in XML parsers
- SQL injection in JDBC queries
- SSRF vulnerabilities
- Spring Expression Language (SpEL) injection
- Insecure random number generation (`Random` vs `SecureRandom`)
- Path traversal in file operations
- Weak cryptography (DES, MD5)
*Refer to [java_security.md](java_security.md) for detailed patterns.*

### .NET / C# Security
**Focus Areas**: Deserialization, SQL injection, XSS, CSRF
**Key Checks**:
- Unsafe deserialization (BinaryFormatter, NetDataContractSerializer)
- SQL injection in Entity Framework raw queries
- XSS in Razor views without encoding
- CSRF token validation
- Weak cryptography (MD5, SHA1)
- Path traversal in File.Open()
- Command injection via Process.Start()
- Missing authentication/authorization attributes
*Refer to [dotnet_security.md](dotnet_security.md) for detailed patterns.*

### Rust Security
**Focus Areas**: Unsafe code blocks, memory safety, dependency vulnerabilities
**Key Checks**:
- Unsafe code blocks without proper justification
- Potential memory leaks in unsafe code
- SQL injection in database queries
- Command injection via `std::process::Command`
- Weak random number generation
- Dependency vulnerabilities (cargo audit)
- Integer overflow in arithmetic operations
- Path traversal in file operations
*Refer to [rust_security.md](rust_security.md) for detailed patterns.*

### React / Frontend Security
**Focus Areas**: XSS, CSRF, sensitive data exposure, dependency vulnerabilities
**Key Checks**:
- XSS via `dangerouslySetInnerHTML`
- Sensitive data in localStorage/sessionStorage
- API keys in frontend code
- Missing CSRF tokens
- Insecure HTTP requests (not using HTTPS)
- Dependency vulnerabilities (npm audit)
- Weak authentication token storage
- Missing Content Security Policy
*Refer to [react_security.md](react_security.md) for detailed patterns.*

### React Native / Mobile Security
**Focus Areas**: Insecure storage, weak crypto, API key exposure, deep linking
**Key Checks**:
- Sensitive data in AsyncStorage without encryption
- Hardcoded API keys and secrets
- Insecure deep linking
- Missing certificate pinning
- Weak cryptography
- Jailbreak/root detection
- Insecure inter-process communication
- Dependency vulnerabilities
*Refer to [react_native_security.md](react_native_security.md) for detailed patterns.*

### Vue.js Security
**Focus Areas**: XSS, template injection, dependency vulnerabilities
**Key Checks**:
- XSS via `v-html` directive
- Template injection vulnerabilities
- Sensitive data exposure in Vuex store
- Missing CSRF protection
- Insecure API communication
- Dependency vulnerabilities
- Weak authentication implementation
*Refer to [vue_security.md](vue_security.md) for detailed patterns.*

### NestJS Security
**Focus Areas**: Injection attacks, authentication bypass, authorization flaws
**Key Checks**:
- SQL/NoSQL injection in TypeORM/Mongoose queries
- Missing authentication guards
- Broken authorization (missing role checks)
- CORS misconfiguration
- Missing rate limiting
- Insecure JWT configuration
- Dependency vulnerabilities
- Missing input validation (class-validator)
*Refer to [nest_security.md](nest_security.md) for detailed patterns.*

### Next.js Security
**Focus Areas**: Server-side vulnerabilities, API route security, SSR/SSG security
**Key Checks**:
- API route authentication/authorization
- Server-side injection vulnerabilities
- Sensitive data in getServerSideProps
- Missing CSRF protection
- Insecure environment variable handling
- XSS in server-rendered content
- Dependency vulnerabilities
*Refer to [next_security.md](next_security.md) for detailed patterns.*

## Web Search Strategy for Vulnerability Intelligence

### Required Searches
For each dependency, perform:
1. **CVE Search**: `"[package-name]" CVE [current-year] [previous-year]`
2. **Security Advisory**: `"[package-name]" security advisory vulnerability`
3. **Version Check**: `"[package-name]" latest stable version`
4. **Known Exploits**: `"[package-name]" exploit proof of concept`
5. **Changelog Review**: `"[package-name]" changelog security fix`

### Trusted Sources
- NVD (nvd.nist.gov)
- Snyk Vulnerability Database
- GitHub Security Advisories
- npm/PyPI/Maven/NuGet security pages
- OWASP resources
- Vendor security bulletins

## Output Format

### Security Report Structure
```markdown
# Security Analysis Report
Generated: [timestamp]
Project: [name]
Scan Scope: [files/dependencies scanned]

## Executive Summary
- Total Vulnerabilities: [count]
- Critical: [count] | High: [count] | Medium: [count] | Low: [count]
- Immediate Action Required: [YES/NO]

## Critical Findings
[List of critical vulnerabilities requiring immediate attention]

## Detailed Analysis

### File-Level Vulnerabilities
[Per-file security issues with code snippets and line numbers]

### Dependency Vulnerabilities
[Per-package analysis with CVE details and upgrade paths]

### Context-Aware Risk Assessment
[Analysis of which vulnerabilities are actually exploitable in this codebase]

## Remediation Roadmap
### Immediate (0-24 hours)
[Critical fixes]

### Short-term (1-7 days)
[High priority fixes]

### Medium-term (1-4 weeks)
[Medium priority improvements]

### Long-term (1-3 months)
[Low priority and architectural improvements]

## Verification Steps
[How to test that fixes work correctly]

## References
[Links to CVE databases, security advisories, documentation]
```

## Best Practices
- Always verify vulnerability information from multiple sources
- Consider the specific context of the application
- Provide clear, actionable remediation steps
- Include code examples for fixes
- Link to official documentation
- Respect responsible disclosure practices
- Focus on practical, implementable solutions

## References
For advanced security patterns and vulnerability signatures, see [security_reference.md](security_reference.md).
