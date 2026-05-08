---
name: remediation-crypto
description: Security fix patterns for cryptographic vulnerabilities (weak algorithms, insecure randomness, TLS issues). Provides language-specific secure implementations.
---

# Remediation: Cryptographic Vulnerabilities

Actionable fix patterns for cryptography-related security vulnerabilities.

## When to Use This Skill

- **Fixing weak cryptography** - After finding MD5/SHA1/DES usage
- **Fixing insecure randomness** - After finding Math.random()/random module usage
- **Fixing TLS issues** - After finding disabled certificate verification
- **Code review feedback** - Provide remediation guidance with examples

## When NOT to Use This Skill

- **Detecting vulnerabilities** - Use vulnerability-patterns skill
- **Fixing injection issues** - Use remediation-injection skill
- **Fixing auth issues** - Use remediation-auth skill
- **Fixing config issues** - Use remediation-config skill

---

## Weak Cryptography (CWE-327)

### Problem
Using deprecated algorithms (MD5, SHA1, DES) or insecure modes (ECB) compromises data protection.

### Python

**Don't**:
```python
# VULNERABLE: MD5/SHA1 for security purposes
import hashlib
password_hash = hashlib.md5(password.encode()).hexdigest()

# VULNERABLE: DES encryption
from Crypto.Cipher import DES
cipher = DES.new(key, DES.MODE_ECB)
```

**Do**:
```python
# SECURE: bcrypt for password hashing
import bcrypt
hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt())

# SECURE: argon2 (preferred)
from argon2 import PasswordHasher
ph = PasswordHasher()
hashed = ph.hash(password)

# SECURE: SHA-256+ for data integrity
import hashlib
file_hash = hashlib.sha256(data).hexdigest()

# SECURE: AES-GCM for encryption
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
key = AESGCM.generate_key(bit_length=256)
aesgcm = AESGCM(key)
nonce = os.urandom(12)
ciphertext = aesgcm.encrypt(nonce, plaintext, associated_data)
```

### JavaScript/Node.js

**Don't**:
```javascript
// VULNERABLE: MD5/SHA1
const crypto = require('crypto');
const hash = crypto.createHash('md5').update(data).digest('hex');

// VULNERABLE: Weak password hashing
const hash = crypto.createHash('sha256').update(password).digest('hex');
```

**Do**:
```javascript
// SECURE: bcrypt for passwords
const bcrypt = require('bcrypt');
const hash = await bcrypt.hash(password, 12);

// SECURE: argon2 (preferred)
const argon2 = require('argon2');
const hash = await argon2.hash(password);

// SECURE: SHA-256 for data integrity
const crypto = require('crypto');
const hash = crypto.createHash('sha256').update(data).digest('hex');

// SECURE: AES-GCM for encryption
const algorithm = 'aes-256-gcm';
const key = crypto.randomBytes(32);
const iv = crypto.randomBytes(16);
const cipher = crypto.createCipheriv(algorithm, key, iv);
```

### Java

**Don't**:
```java
// VULNERABLE: MD5/SHA1
MessageDigest md = MessageDigest.getInstance("MD5");
byte[] hash = md.digest(data);

// VULNERABLE: DES/ECB
Cipher cipher = Cipher.getInstance("DES/ECB/PKCS5Padding");
```

**Do**:
```java
// SECURE: BCrypt for passwords
import org.mindrot.jbcrypt.BCrypt;
String hash = BCrypt.hashpw(password, BCrypt.gensalt(12));

// SECURE: SHA-256 for integrity
MessageDigest md = MessageDigest.getInstance("SHA-256");
byte[] hash = md.digest(data);

// SECURE: AES-GCM for encryption
Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
SecretKeySpec keySpec = new SecretKeySpec(key, "AES");
GCMParameterSpec gcmSpec = new GCMParameterSpec(128, iv);
cipher.init(Cipher.ENCRYPT_MODE, keySpec, gcmSpec);
```

### Go

**Don't**:
```go
// VULNERABLE: MD5/SHA1
import "crypto/md5"
hash := md5.Sum(data)
```

**Do**:
```go
// SECURE: bcrypt for passwords
import "golang.org/x/crypto/bcrypt"
hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)

// SECURE: SHA-256 for integrity
import "crypto/sha256"
hash := sha256.Sum256(data)

// SECURE: AES-GCM for encryption
import "crypto/aes"
import "crypto/cipher"
block, _ := aes.NewCipher(key)
gcm, _ := cipher.NewGCM(block)
ciphertext := gcm.Seal(nil, nonce, plaintext, nil)
```

**ASVS**: V11.4.1, V11.5.1, V11.5.2
**References**: [OWASP Cryptographic Storage](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html)

---

## Insecure Randomness (CWE-330)

### Problem
Using predictable random number generators for security-sensitive values allows attackers to predict tokens.

### Python

**Don't**:
```python
# VULNERABLE: random module for security
import random
token = ''.join(random.choices('abcdef0123456789', k=32))
session_id = random.randint(0, 999999)
```

**Do**:
```python
# SECURE: secrets module
import secrets
token = secrets.token_urlsafe(32)
api_key = secrets.token_hex(32)
otp = ''.join(secrets.choice('0123456789') for _ in range(6))

# SECURE: os.urandom for raw bytes
import os
random_bytes = os.urandom(32)
```

### JavaScript/Node.js

**Don't**:
```javascript
// VULNERABLE: Math.random()
const token = Math.random().toString(36).substring(2);
const sessionId = Math.floor(Math.random() * 1000000);
```

**Do**:
```javascript
// SECURE: crypto.randomBytes (Node.js)
const crypto = require('crypto');
const token = crypto.randomBytes(32).toString('hex');
const sessionId = crypto.randomUUID();

// SECURE: Web Crypto API (Browser)
const buffer = new Uint8Array(32);
crypto.getRandomValues(buffer);
const token = Array.from(buffer, b => b.toString(16).padStart(2, '0')).join('');
```

### Java

**Don't**:
```java
// VULNERABLE: java.util.Random
Random rand = new Random();
int token = rand.nextInt();
```

**Do**:
```java
// SECURE: SecureRandom
SecureRandom random = new SecureRandom();
byte[] bytes = new byte[32];
random.nextBytes(bytes);

// SECURE: Generate random string
String token = new BigInteger(256, random).toString(16);
```

### Go

**Don't**:
```go
// VULNERABLE: math/rand
import "math/rand"
token := rand.Intn(1000000)
```

**Do**:
```go
// SECURE: crypto/rand
import "crypto/rand"
import "encoding/hex"

bytes := make([]byte, 32)
rand.Read(bytes)
token := hex.EncodeToString(bytes)
```

**ASVS**: V11.3.1
**References**: [OWASP Secure Random](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html#secure-random-number-generation)

---

## TLS Certificate Validation (CWE-295)

### Problem
Disabling TLS certificate validation allows man-in-the-middle attacks.

### Python

**Don't**:
```python
# VULNERABLE: Disabled verification
import requests
response = requests.get(url, verify=False)

# VULNERABLE: Environment variable
os.environ['REQUESTS_CA_BUNDLE'] = ''
```

**Do**:
```python
# SECURE: Default verification (enabled)
import requests
response = requests.get(url)  # verify=True by default

# SECURE: Custom CA bundle
response = requests.get(url, verify='/path/to/ca-bundle.crt')

# SECURE: Certificate pinning
import ssl
import socket

def verify_certificate(host, expected_fingerprint):
    context = ssl.create_default_context()
    with socket.create_connection((host, 443)) as sock:
        with context.wrap_socket(sock, server_hostname=host) as ssock:
            cert = ssock.getpeercert(binary_form=True)
            fingerprint = hashlib.sha256(cert).hexdigest()
            if fingerprint != expected_fingerprint:
                raise ssl.SSLError("Certificate fingerprint mismatch")
```

### JavaScript/Node.js

**Don't**:
```javascript
// VULNERABLE: Disabled verification
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

// VULNERABLE: rejectUnauthorized false
const https = require('https');
https.get(url, { rejectUnauthorized: false });
```

**Do**:
```javascript
// SECURE: Default verification
const https = require('https');
https.get(url);  // Verification enabled by default

// SECURE: Custom CA
const fs = require('fs');
const https = require('https');

const agent = new https.Agent({
  ca: fs.readFileSync('/path/to/ca.crt')
});
https.get(url, { agent });
```

### Go

**Don't**:
```go
// VULNERABLE: Skip verification
client := &http.Client{
    Transport: &http.Transport{
        TLSClientConfig: &tls.Config{
            InsecureSkipVerify: true,
        },
    },
}
```

**Do**:
```go
// SECURE: Default client (verification enabled)
client := &http.Client{}
resp, err := client.Get(url)

// SECURE: Custom CA pool
caCert, _ := ioutil.ReadFile("/path/to/ca.crt")
caCertPool := x509.NewCertPool()
caCertPool.AppendCertsFromPEM(caCert)

client := &http.Client{
    Transport: &http.Transport{
        TLSClientConfig: &tls.Config{
            RootCAs: caCertPool,
        },
    },
}
```

**ASVS**: V12.3.1
**References**: [OWASP TLS Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Transport_Layer_Security_Cheat_Sheet.html)

---

## Quick Reference

| Vulnerability | Fix Pattern | Key Libraries |
|---------------|-------------|---------------|
| Weak hashing | bcrypt, argon2 | bcrypt, argon2 |
| Weak encryption | AES-GCM | cryptography, crypto |
| Insecure randomness | CSPRNG | secrets, crypto.randomBytes |
| TLS disabled | Enable verification | Default settings |

## See Also

- `remediation-injection` - Injection fixes
- `remediation-auth` - Authentication/authorization fixes
- `remediation-config` - Configuration fixes
- `vulnerability-patterns` - Detection patterns
