---
name: vuln-patterns-languages
description: Language-specific vulnerability detection patterns for JavaScript/TypeScript, Python, Go, Java, Ruby, and PHP. Provides regex patterns and grep commands for common security vulnerabilities.
---

# Vulnerability Patterns: Language-Specific

Detection patterns organized by programming language.

## When to Use This Skill

- **Language-targeted scans** - When auditing specific tech stacks
- **Code review** - Finding vulnerabilities in PRs
- **Building auditor agents** - Patterns for domain auditors

## When NOT to Use This Skill

- **Universal patterns** - Use vuln-patterns-core skill
- **Full audits** - Use domain auditor agents
- **Remediation** - Use remediation-* skills

---

## JavaScript/TypeScript Patterns

### Dangerous eval()

**Detection Pattern**:
```regex
# eval with variables
eval\s*\([^)]*[a-zA-Z_]+[^)]*\)

# Function constructor
new\s+Function\s*\([^)]*[a-zA-Z_]+

# setTimeout/setInterval with string
(setTimeout|setInterval)\s*\([^,)]*['"`]
```

**Grep Commands**:
```bash
grep -rn --include="*.{js,ts}" -E "eval\s*\(" .
grep -rn --include="*.{js,ts}" -E "new\s+Function\s*\(" .
grep -rn --include="*.{js,ts}" -E "(setTimeout|setInterval)\s*\(['\"\`]" .
```

**Severity**: Critical
**ASVS**: V1.5.1 - Safe deserialization
**CWE**: CWE-94 (Code Injection)

---

### XSS via DOM Manipulation

**Detection Pattern**:
```regex
# innerHTML assignment
\.innerHTML\s*=(?!\s*['"]<[^>]+>[^<]*</[^>]+>['"])

# document.write
document\.write\s*\(

# insertAdjacentHTML
\.insertAdjacentHTML\s*\(

# React dangerouslySetInnerHTML
dangerouslySetInnerHTML
```

**Grep Commands**:
```bash
grep -rn --include="*.{js,ts,jsx,tsx}" "\.innerHTML\s*=" .
grep -rn --include="*.{js,ts,jsx,tsx}" "document\.write" .
grep -rn --include="*.{js,ts,jsx,tsx}" "dangerouslySetInnerHTML" .
```

**Severity**: High
**ASVS**: V3.3.1 - XSS prevention
**CWE**: CWE-79 (Cross-site Scripting)

---

### Prototype Pollution

**Detection Pattern**:
```regex
# Direct __proto__ access
__proto__

# Object merge without validation
Object\.assign\s*\([^)]*,[^)]*\)
\.\.\.(?!props)[a-zA-Z_]+

# Bracket notation with variable
\[[a-zA-Z_]+\]\s*=
```

**Grep Commands**:
```bash
grep -rn --include="*.{js,ts}" "__proto__" .
grep -rn --include="*.{js,ts}" "constructor\s*\[" .
```

**Severity**: High
**ASVS**: V1.5.1 - Safe deserialization
**CWE**: CWE-1321 (Prototype Pollution)

---

### Insecure Randomness

**Detection Pattern**:
```regex
Math\.random\s*\(\)
```

**Context**: Only flag when used for security purposes (tokens, keys, IDs)

**Grep Commands**:
```bash
grep -rn --include="*.{js,ts}" "Math\.random" .
```

**Severity**: Medium (context-dependent)
**ASVS**: V11.3.1 - CSPRNG for security values
**CWE**: CWE-330 (Insufficient Randomness)

---

### Missing Security Headers (Express)

**Detection Pattern**:
```regex
# Express without helmet
app\s*=\s*express\s*\(\)(?!.*helmet)
```

**Grep Commands**:
```bash
grep -rn --include="*.{js,ts}" "express()" . | grep -v helmet
grep -rn --include="*.{js,ts}" "helmet" .
```

**Severity**: Medium
**ASVS**: V3.4.1 - Security headers
**CWE**: CWE-693 (Protection Mechanism Failure)

---

## Python Patterns

### Unsafe Deserialization

**Detection Pattern**:
```regex
# Pickle with untrusted data
pickle\.(loads?|load)\s*\(

# YAML unsafe load
yaml\.(load|unsafe_load)\s*\([^)]*(?!Loader\s*=\s*yaml\.SafeLoader)

# Marshal load
marshal\.loads?\s*\(
```

**Grep Commands**:
```bash
grep -rn --include="*.py" "pickle\.load" .
grep -rn --include="*.py" "yaml\.load" . | grep -v "SafeLoader\|safe_load"
grep -rn --include="*.py" "marshal\.load" .
```

**Severity**: Critical
**ASVS**: V1.5.1 - Safe deserialization
**CWE**: CWE-502 (Deserialization of Untrusted Data)

---

### Weak Cryptography

**Detection Pattern**:
```regex
# MD5/SHA1 for security
hashlib\.(md5|sha1)\s*\(

# DES/RC4
DES\.|RC4\.|Blowfish\.

# ECB mode
\.MODE_ECB
```

**Grep Commands**:
```bash
grep -rn --include="*.py" "hashlib\.md5\|hashlib\.sha1" .
grep -rn --include="*.py" "MODE_ECB" .
grep -rn --include="*.py" -E "DES\.|RC4\." .
```

**Severity**: High
**ASVS**: V11.5.2 - No MD5/SHA1
**CWE**: CWE-327 (Broken Crypto Algorithm)

---

### Insecure Random

**Detection Pattern**:
```regex
# random module for security
random\.(choice|randint|random|randrange|sample)\s*\(
```

**Context**: Flag when used for tokens, keys, session IDs

**Grep Commands**:
```bash
grep -rn --include="*.py" -E "random\.(choice|randint|random|randrange)" . | grep -i "token\|key\|session\|secret\|password"
```

**Severity**: High
**ASVS**: V11.3.1 - CSPRNG
**CWE**: CWE-338 (Weak PRNG)

---

### Hardcoded Flask Secret Key

**Detection Pattern**:
```regex
SECRET_KEY\s*=\s*['"][^'"]+['"]
app\.secret_key\s*=\s*['"][^'"]+['"]
```

**Grep Commands**:
```bash
grep -rn --include="*.py" "SECRET_KEY\s*=\s*['\"]" .
grep -rn --include="*.py" "secret_key\s*=\s*['\"]" .
```

**Severity**: High
**ASVS**: V13.3.1 - Secrets management
**CWE**: CWE-798 (Hardcoded Credentials)

---

### Debug Mode in Production

**Detection Pattern**:
```regex
DEBUG\s*=\s*True
app\.run\s*\([^)]*debug\s*=\s*True
FLASK_DEBUG\s*=\s*['"]?1
```

**Grep Commands**:
```bash
grep -rn --include="*.py" "DEBUG\s*=\s*True" .
grep -rn --include="*.py" "debug\s*=\s*True" .
```

**Severity**: High
**ASVS**: V13.2.1 - Debug disabled in production
**CWE**: CWE-489 (Active Debug Code)

---

### TLS Verification Disabled

**Detection Pattern**:
```regex
verify\s*=\s*False
REQUESTS_CA_BUNDLE\s*=\s*['"]?$
urllib3\.disable_warnings
```

**Grep Commands**:
```bash
grep -rn --include="*.py" "verify\s*=\s*False" .
grep -rn --include="*.py" "disable_warnings" .
```

**Severity**: High
**ASVS**: V12.3.1 - Certificate validation
**CWE**: CWE-295 (Improper Certificate Validation)

---

## Go Patterns

### SQL Injection

**Detection Pattern**:
```regex
# fmt.Sprintf in queries
fmt\.Sprintf\s*\([^)]*SELECT
db\.(Query|Exec)\s*\([^)]*\+

# String concatenation
"SELECT.*"\s*\+
```

**Grep Commands**:
```bash
grep -rn --include="*.go" -E "fmt\.Sprintf.*SELECT|fmt\.Sprintf.*INSERT" .
grep -rn --include="*.go" -E "db\.(Query|Exec)\s*\(.*\+" .
```

**Severity**: Critical
**ASVS**: V1.2.1 - Parameterized queries
**CWE**: CWE-89 (SQL Injection)

---

### Weak Cryptography

**Detection Pattern**:
```regex
crypto/md5
crypto/sha1
crypto/des
crypto/rc4
```

**Grep Commands**:
```bash
grep -rn --include="*.go" "crypto/md5\|crypto/sha1\|crypto/des\|crypto/rc4" .
```

**Severity**: High
**ASVS**: V11.5.2 - No deprecated algorithms
**CWE**: CWE-327 (Broken Crypto)

---

### Insecure TLS Config

**Detection Pattern**:
```regex
InsecureSkipVerify\s*:\s*true
MinVersion\s*:\s*tls\.VersionSSL
MinVersion\s*:\s*tls\.VersionTLS10
```

**Grep Commands**:
```bash
grep -rn --include="*.go" "InsecureSkipVerify.*true" .
grep -rn --include="*.go" "MinVersion.*SSL\|MinVersion.*TLS10\|MinVersion.*TLS11" .
```

**Severity**: High
**ASVS**: V12.2.1 - TLS 1.2+
**CWE**: CWE-295 (Certificate Validation)

---

## Java Patterns

### SQL Injection

**Detection Pattern**:
```regex
# String concatenation
Statement\s+\w+\s*=.*createStatement
executeQuery\s*\([^?]*\+
"SELECT.*"\s*\+

# PreparedStatement misuse
prepareStatement\s*\([^?]*\+
```

**Grep Commands**:
```bash
grep -rn --include="*.java" "createStatement" .
grep -rn --include="*.java" -E "executeQuery\s*\(.*\+" .
grep -rn --include="*.java" -E "\"SELECT.*\"\s*\+" .
```

**Severity**: Critical
**ASVS**: V1.2.1 - Parameterized queries
**CWE**: CWE-89 (SQL Injection)

---

### Unsafe Deserialization

**Detection Pattern**:
```regex
ObjectInputStream
readObject\s*\(\)
XMLDecoder
XStream(?!.*allowTypes)
```

**Grep Commands**:
```bash
grep -rn --include="*.java" "ObjectInputStream\|readObject()" .
grep -rn --include="*.java" "XMLDecoder" .
```

**Severity**: Critical
**ASVS**: V1.5.1 - Safe deserialization
**CWE**: CWE-502 (Deserialization)

---

### XXE Vulnerability

**Detection Pattern**:
```regex
DocumentBuilderFactory(?!.*setFeature.*FEATURE_SECURE)
SAXParserFactory(?!.*setFeature)
XMLInputFactory(?!.*setProperty.*SUPPORT_DTD)
```

**Grep Commands**:
```bash
grep -rn --include="*.java" "DocumentBuilderFactory\|SAXParserFactory\|XMLInputFactory" .
```

**Severity**: High
**ASVS**: V1.5.1 - XML processing
**CWE**: CWE-611 (XXE)

---

### Weak Cryptography

**Detection Pattern**:
```regex
MessageDigest\.getInstance\s*\(\s*["']MD5
MessageDigest\.getInstance\s*\(\s*["']SHA-?1
Cipher\.getInstance\s*\(\s*["']DES
Cipher\.getInstance\s*\(\s*["'].*ECB
```

**Grep Commands**:
```bash
grep -rn --include="*.java" -E "MessageDigest\.getInstance.*MD5|MessageDigest\.getInstance.*SHA.?1" .
grep -rn --include="*.java" "Cipher\.getInstance.*DES\|Cipher\.getInstance.*ECB" .
```

**Severity**: High
**ASVS**: V11.5.2 - Secure algorithms
**CWE**: CWE-327 (Broken Crypto)

---

## Ruby Patterns

### Command Injection

**Detection Pattern**:
```regex
`[^`]*#{
system\s*\([^)]*#{
exec\s*\([^)]*#{
%x\{[^}]*#{
```

**Grep Commands**:
```bash
grep -rn --include="*.rb" -E "\`.*#\{" .
grep -rn --include="*.rb" -E "system\s*\(.*#\{" .
grep -rn --include="*.rb" "%x{" .
```

**Severity**: Critical
**ASVS**: V1.2.3 - Command injection
**CWE**: CWE-78 (OS Command Injection)

---

### SQL Injection (Rails)

**Detection Pattern**:
```regex
\.where\s*\([^)]*#{
\.find_by_sql\s*\([^)]*#{
\.execute\s*\([^)]*#{
\.order\s*\([^)]*#{
```

**Grep Commands**:
```bash
grep -rn --include="*.rb" -E "\.where\s*\(.*#\{" .
grep -rn --include="*.rb" "find_by_sql" .
```

**Severity**: Critical
**ASVS**: V1.2.1 - Parameterized queries
**CWE**: CWE-89 (SQL Injection)

---

### Mass Assignment

**Detection Pattern**:
```regex
attr_accessible\s*:
params\.permit!
\.update_attributes?\s*\(params
```

**Grep Commands**:
```bash
grep -rn --include="*.rb" "params\.permit!" .
grep -rn --include="*.rb" "update_attributes.*params" .
```

**Severity**: High
**ASVS**: V2.2.1 - Input validation
**CWE**: CWE-915 (Mass Assignment)

---

## PHP Patterns

### SQL Injection

**Detection Pattern**:
```regex
mysql_query\s*\(
mysqli_query\s*\([^,]+,\s*["'][^?]
\$_(?:GET|POST|REQUEST)\s*\[.*\]\s*\.
```

**Grep Commands**:
```bash
grep -rn --include="*.php" "mysql_query\|mysqli_query" .
grep -rn --include="*.php" '\$_(GET|POST|REQUEST).*\.' .
```

**Severity**: Critical
**ASVS**: V1.2.1 - Parameterized queries
**CWE**: CWE-89 (SQL Injection)

---

### Command Injection

**Detection Pattern**:
```regex
(system|exec|shell_exec|passthru|popen|proc_open)\s*\(\s*\$
`\$
```

**Grep Commands**:
```bash
grep -rn --include="*.php" -E "(system|exec|shell_exec|passthru)\s*\(\s*\\\$" .
```

**Severity**: Critical
**ASVS**: V1.2.3 - Command injection
**CWE**: CWE-78 (OS Command Injection)

---

### Unsafe Deserialization

**Detection Pattern**:
```regex
unserialize\s*\(\s*\$
```

**Grep Commands**:
```bash
grep -rn --include="*.php" "unserialize\s*(\s*\$" .
```

**Severity**: Critical
**ASVS**: V1.5.1 - Safe deserialization
**CWE**: CWE-502 (Deserialization)

---

### File Inclusion

**Detection Pattern**:
```regex
(include|require|include_once|require_once)\s*\(\s*\$
```

**Grep Commands**:
```bash
grep -rn --include="*.php" -E "(include|require)(_once)?\s*\(\s*\\\$" .
```

**Severity**: Critical
**ASVS**: V5.3.1 - File security
**CWE**: CWE-98 (File Inclusion)

---

## Quick Reference by Language

| Language | Critical Issues | High Issues |
|----------|-----------------|-------------|
| JS/TS | eval(), XSS | Prototype pollution |
| Python | pickle, yaml.load | MD5/SHA1, random |
| Go | fmt.Sprintf SQL | InsecureSkipVerify |
| Java | ObjectInputStream, SQL | XXE, MD5/SHA1 |
| Ruby | backticks, SQL | Mass assignment |
| PHP | unserialize, include | mysql_query |

## See Also

- `vuln-patterns-core` - Universal patterns
- `remediation-injection` - Injection fixes
- `remediation-crypto` - Crypto fixes
