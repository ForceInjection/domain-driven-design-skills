---
name: security-guidance
description: Comprehensive security best practices, vulnerability scanning, and security guidance for development workflows with automated security checks and compliance monitoring.
license: MIT
---

# Security Guidance & Scanning

## Overview

Complete security toolkit providing best practices, automated vulnerability scanning, security guidance, and compliance monitoring for development workflows and production systems.

## Quick Start

### Installation
```bash
npm install -g @security-guidance/cli
# or
npx @security-guidance/cli init
```

### Initial Security Scan
```bash
# Quick security assessment
security-guidance scan

# Comprehensive scan
security-guidance scan --comprehensive --report=html
```

## Security Scanning

### Code Security Analysis
```bash
# Scan source code for vulnerabilities
security-guidance scan code --path=./src --language=javascript

# Scan with specific rules
security-guidance scan code --rules=owasp-top-ten,cwe-89

# Include dependency scanning
security-guidance scan code --include-deps --severity=high,critical
```

**Code Scan Results**
```json
{
  "scanId": "scan_2024_01_15_14_30",
  "timestamp": "2024-01-15T14:30:00Z",
  "summary": {
    "totalIssues": 23,
    "critical": 2,
    "high": 5,
    "medium": 10,
    "low": 6
  },
  "issues": [
    {
      "id": "vuln_001",
      "severity": "critical",
      "type": "sql-injection",
      "file": "src/database.js",
      "line": 45,
      "description": "Potential SQL injection vulnerability",
      "recommendation": "Use parameterized queries or ORM"
    }
  ]
}
```

### Dependency Vulnerability Scanning
```bash
# Scan package dependencies
security-guidance scan dependencies --format=npm

# Scan with custom registry
security-guidance scan dependencies --registry=private-registry

# Continuous monitoring
security-guidance monitor dependencies --interval=daily
```

**Dependency Report**
```javascript
// Generate dependency security report
const { DependencyScanner } = require('@security-guidance/scanner');

const scanner = new DependencyScanner();
const report = await scanner.scan('./package.json');

console.log(`
Vulnerabilities Found: ${report.vulnerabilities.length}
Critical: ${report.criticalCount}
High: ${report.highCount}

Recommendations:
${report.recommendations.join('\n')}
`);
```

### Infrastructure Security
```bash
# Scan cloud infrastructure
security-guidance scan infrastructure --provider=aws --region=us-east-1

# Scan Kubernetes cluster
security-guidance scan k8s --cluster=production

# Docker security scan
security-guidance scan docker --image=myapp:latest
```

**Infrastructure Security Check**
```yaml
# security-config.yaml
infrastructure:
  aws:
    s3:
      - check: "public-read-prohibited"
        severity: "high"
      - check: "encryption-enabled"
        severity: "medium"
    ec2:
      - check: "security-groups-configured"
        severity: "critical"
      - check: "iam-roles-assigned"
        severity: "medium"
  
  kubernetes:
    rbac:
      - check: "no-cluster-admin-binding"
        severity: "critical"
    pods:
      - check: "no-privileged-containers"
        severity: "high"
      - check: "read-only-filesystem"
        severity: "medium"
```

## Security Best Practices

### Secure Coding Guidelines

**Input Validation**
```javascript
const { SecurityUtils } = require('@security-guidance/utils');

// Validate user input
function validateUserInput(input) {
  return SecurityUtils.validate(input, {
    type: 'string',
    maxLength: 1000,
    allowedChars: 'a-zA-Z0-9 .,!?-',
    sanitize: true,
    escape: true
  });
}

// SQL injection prevention
const query = 'SELECT * FROM users WHERE email = ?';
const result = await db.query(query, [validatedEmail]);
```

**Authentication & Authorization**
```javascript
const { AuthManager } = require('@security-guidance/auth');

const auth = new AuthManager({
  jwtSecret: process.env.JWT_SECRET,
  bcryptRounds: 12,
  sessionTimeout: 3600000, // 1 hour
  maxLoginAttempts: 5,
  lockoutDuration: 900000 // 15 minutes
});

// Secure login
async function login(username, password) {
  const user = await auth.authenticate(username, password);
  if (user) {
    const token = auth.generateToken(user, { expiresIn: '1h' });
    return { success: true, token };
  }
  return { success: false, error: 'Invalid credentials' };
}
```

**Data Encryption**
```javascript
const { Encryption } = require('@security-guidance/crypto');

const encryption = new Encryption({
  algorithm: 'aes-256-gcm',
  keyDerivation: 'pbkdf2',
  iterations: 100000
});

// Encrypt sensitive data
async function encryptSensitiveData(data) {
  const encrypted = await encryption.encrypt(data, process.env.ENCRYPTION_KEY);
  return encrypted;
}

// Decrypt sensitive data
async function decryptSensitiveData(encryptedData) {
  const decrypted = await encryption.decrypt(encryptedData, process.env.ENCRYPTION_KEY);
  return decrypted;
}
```

### API Security

**Rate Limiting**
```javascript
const { RateLimiter } = require('@security-guidance/api');

const rateLimiter = new RateLimiter({
  windowMs: 15 * 60 * 1000, // 15 minutes
  maxRequests: 100,
  skipSuccessfulRequests: false,
  skipFailedRequests: false
});

// Apply to API endpoints
app.use('/api/', rateLimiter.middleware());
```

**CORS Configuration**
```javascript
const cors = require('cors');

const corsOptions = {
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['https://example.com'],
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  maxAge: 86400 // 24 hours
};

app.use(cors(corsOptions));
```

**Input Sanitization**
```javascript
const { Sanitizer } = require('@security-guidance/sanitizer');

const sanitizer = new Sanitizer();

// Sanitize HTML input
function sanitizeHtml(input) {
  return sanitizer.html(input, {
    allowedTags: ['b', 'i', 'em', 'strong', 'p', 'br'],
    allowedAttributes: {},
    disallowedTagsMode: 'discard'
  });
}

// Sanitize SQL input
function sanitizeSql(input) {
  return sanitizer.sql(input, {
    escapeQuotes: true,
    removeComments: true,
    validateIdentifiers: true
  });
}
```

## Compliance Monitoring

### GDPR Compliance
```bash
# GDPR compliance check
security-guidance compliance gdpr --audit

# Data privacy assessment
security-guidance privacy assess --region=eu

# Generate GDPR documentation
security-guidance compliance gdpr --docs --output=./docs/gdpr
```

**GDPR Implementation**
```javascript
const { GDPRCompliance } = require('@security-guidance/compliance');

const gdpr = new GDPRCompliance({
  dataController: 'Your Company',
  dataProtectionOfficer: 'dpo@company.com',
  retentionPeriod: 365, // days
  consentRequired: true
});

// Handle data subject requests
async function handleDataSubjectRequest(requestType, userId) {
  switch (requestType) {
    case 'access':
      return await gdpr.getUserData(userId);
    case 'deletion':
      return await gdpr.deleteUserData(userId);
    case 'rectification':
      return await gdpr.rectifyUserData(userId, updatedData);
    default:
      throw new Error('Invalid request type');
  }
}
```

### SOC 2 Compliance
```bash
# SOC 2 compliance assessment
security-guidance compliance soc2 --type=type2 --audit

# Security controls validation
security-guidance controls validate --framework=soc2

# Generate SOC 2 reports
security-guidance compliance soc2 --report --format=pdf
```

**SOC 2 Controls**
```javascript
const { SOC2Controls } = require('@security-guidance/compliance');

const soc2 = new SOC2Controls({
  trustServices: ['security', 'availability', 'confidentiality'],
  criteria: 'common-criteria-2017'
});

// Implement security controls
const controls = {
  accessControl: {
    implemented: true,
    evidence: ['access-logs', 'user-permissions'],
    lastReviewed: '2024-01-15'
  },
  encryption: {
    implemented: true,
    evidence: ['encryption-keys', 'cipher-suites'],
    lastReviewed: '2024-01-10'
  },
  incidentResponse: {
    implemented: true,
    evidence: ['incident-logs', 'response-procedures'],
    lastReviewed: '2024-01-12'
  }
};

await soc2.validateControls(controls);
```

## Security Testing

### Penetration Testing
```bash
# Automated penetration testing
security-guidance pentest --target=https://api.example.com

# Custom penetration test
security-guidance pentest --config=pentest.config.js

# Generate pentest report
security-guidance pentest --report --format=html
```

**Penetration Test Configuration**
```javascript
// pentest.config.js
module.exports = {
  target: 'https://api.example.com',
  tests: [
    'sql-injection',
    'xss',
    'csrf',
    'authentication-bypass',
    'authorization-issues',
    'rate-limiting-bypass'
  ],
  
  authentication: {
    type: 'bearer',
    token: process.env.API_TOKEN
  },
  
  options: {
    maxRequestsPerSecond: 10,
    timeout: 30000,
    followRedirects: true
  },
  
  reporting: {
    format: ['html', 'json'],
    includeEvidence: true,
    severity: ['medium', 'high', 'critical']
  }
};
```

### Security Unit Testing
```javascript
const { SecurityTests } = require('@security-guidance/testing');

describe('Security Tests', () => {
  let securityTests;
  
  beforeEach(() => {
    securityTests = new SecurityTests();
  });

  test('should prevent SQL injection', async () => {
    const maliciousInput = "'; DROP TABLE users; --";
    const result = await securityTests.testSqlInjection(maliciousInput);
    expect(result.vulnerable).toBe(false);
  });

  test('should prevent XSS attacks', async () => {
    const xssPayload = '<script>alert("xss")</script>';
    const result = await securityTests.testXSS(xssPayload);
    expect(result.vulnerable).toBe(false);
  });

  test('should enforce rate limiting', async () => {
    const requests = Array(101).fill().map(() => 
      securityTests.makeRequest('/api/endpoint')
    );
    
    const results = await Promise.all(requests);
    const rejectedRequests = results.filter(r => r.status === 429);
    expect(rejectedRequests.length).toBeGreaterThan(0);
  });
});
```

## Security Monitoring

### Real-time Monitoring
```bash
# Start security monitoring
security-guidance monitor --real-time

# Monitor specific services
security-guidance monitor --services=api,database,auth

# Set up alerts
security-guidance monitor --alert-webhook=https://hooks.slack.com/...
```

**Monitoring Configuration**
```javascript
// monitoring.config.js
module.exports = {
  services: [
    {
      name: 'api',
      endpoint: 'https://api.example.com/health',
      checks: ['response-time', 'status-code', 'ssl-certificate'],
      interval: 60000 // 1 minute
    },
    {
      name: 'database',
      connection: process.env.DATABASE_URL,
      checks: ['connection-pool', 'query-performance', 'access-logs'],
      interval: 300000 // 5 minutes
    }
  ],
  
  alerts: {
    channels: [
      {
        type: 'slack',
        webhook: process.env.SLACK_WEBHOOK,
        severity: ['high', 'critical']
      },
      {
        type: 'email',
        recipients: ['security@company.com'],
        severity: ['critical']
      }
    ]
  },
  
  thresholds: {
    responseTime: 5000, // 5 seconds
    errorRate: 0.05, // 5%
    failedLogins: 10 // per minute
  }
};
```

### Log Analysis
```bash
# Analyze security logs
security-guidance logs analyze --source=./logs --pattern=security-events

# Detect anomalies
security-guidance logs anomaly-detect --baseline=30-days

# Generate security report
security-guidance logs report --period=weekly --format=pdf
```

**Log Analysis Script**
```javascript
const { LogAnalyzer } = require('@security-guidance/logs');

const analyzer = new LogAnalyzer({
  patterns: {
    failedLogin: /failed.*login/i,
    sqlInjection: /union.*select|drop.*table/i,
    xss: /<script|javascript:/i,
    suspiciousActivity: /brute.*force|dictionary.*attack/i
  },
  
  thresholds: {
    failedLoginsPerMinute: 5,
    suspiciousPatternsPerHour: 10
  }
});

// Analyze logs
async function analyzeSecurityLogs(logFile) {
  const analysis = await analyzer.analyze(logFile);
  
  if (analysis.alerts.length > 0) {
    await sendSecurityAlert(analysis.alerts);
  }
  
  return analysis;
}
```

## Security Configuration

### Security Headers
```javascript
const helmet = require('helmet');

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"]
    }
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  },
  noSniff: true,
  frameguard: { action: 'deny' },
  xssFilter: true
}));
```

### Environment Security
```bash
# Secure environment setup
security-guidance env secure --production

# Environment variables validation
security-guidance env validate --required=API_KEY,DB_URL

# Generate secure secrets
security-guidance secrets generate --type=jwt --length=256
```

**Secure Environment Configuration**
```javascript
// security.config.js
module.exports = {
  environment: {
    required: [
      'API_KEY',
      'DATABASE_URL',
      'JWT_SECRET',
      'ENCRYPTION_KEY'
    ],
    
    validation: {
      JWT_SECRET: {
        minLength: 32,
        pattern: /^[A-Za-z0-9+/]+={0,2}$/
      },
      API_KEY: {
        minLength: 20,
        pattern: /^[a-f0-9]{32}$/
      }
    }
  },
  
  secrets: {
    rotation: {
      interval: '90d',
      notification: ['security@company.com']
    },
    
    storage: {
      provider: 'aws-secrets-manager',
      region: 'us-east-1'
    }
  }
};
```

## Incident Response

### Incident Management
```bash
# Report security incident
security-guidance incident report --type=data-breach --severity=high

# View incident status
security-guidance incident status --id=inc-2024-001

# Generate incident report
security-guidance incident report --id=inc-2024-001 --format=pdf
```

**Incident Response Workflow**
```javascript
const { IncidentManager } = require('@security-guidance/incident');

const incidentManager = new IncidentManager({
  escalationPolicy: {
    level1: { timeout: 300, notify: ['oncall@company.com'] },
    level2: { timeout: 900, notify: ['security@company.com', 'cto@company.com'] },
    level3: { timeout: 1800, notify: ['executives@company.com'] }
  },
  
  communication: {
    slack: { webhook: process.env.SLACK_WEBHOOK },
    email: { smtp: process.env.SMTP_CONFIG },
    sms: { provider: 'twilio', apiKey: process.env.TWILIO_KEY }
  }
});

// Handle security incident
async function handleSecurityIncident(incident) {
  const response = await incidentManager.create({
    type: incident.type,
    severity: incident.severity,
    description: incident.description,
    affectedSystems: incident.systems,
    reporter: incident.reporter
  });
  
  // Start automated response
  await incidentManager.automatedResponse(response.id);
  
  return response;
}
```

## Security Training

### Security Awareness
```bash
# Generate security training materials
security-guidance training generate --topic=phishing --format=interactive

# Conduct security quiz
security-guidance training quiz --topic=social-engineering

# Track training progress
security-guidance training progress --team=engineering
```

**Training Content Generator**
```javascript
const { TrainingGenerator } = require('@security-guidance/training');

const generator = new TrainingGenerator();

// Generate phishing awareness training
const phishingTraining = await generator.generate({
  topic: 'phishing',
  format: 'interactive',
  difficulty: 'intermediate',
  duration: 30 // minutes
});

// Generate security quiz
const quiz = await generator.quiz({
  topics: ['password-security', 'social-engineering', 'data-protection'],
  questionsPerTopic: 5,
  difficulty: 'mixed'
});
```

## Integration

### CI/CD Integration
```yaml
# .github/workflows/security.yml
name: Security Scan

on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Run Security Scan
        run: |
          npx @security-guidance/cli scan \
            --comprehensive \
            --format=github \
            --output=security-report.json
      
      - name: Upload Security Report
        uses: actions/upload-artifact@v2
        with:
          name: security-report
          path: security-report.json
```

### IDE Integration
```bash
# VS Code extension
code --install-extension security-guidance.vscode

# IntelliJ plugin
# Install from marketplace: Security Guidance

# Vim/Neovim plugin
git clone https://github.com/security-guidance/vim-plugin ~/.vim/pack/security/start/
```

## API Reference

### Core Classes

**SecurityScanner**
```javascript
const { SecurityScanner } = require('@security-guidance/core');

const scanner = new SecurityScanner({
  rules: ['owasp-top-ten', 'custom-rules'],
  severity: ['medium', 'high', 'critical']
});

const results = await scanner.scan('./src');
```

**VulnerabilityDatabase**
```javascript
const { VulnDB } = require('@security-guidance/database');

const vulnDB = new VulnDB({
  sources: ['cve', 'npm-advisories', 'github-advisories'],
  updateInterval: 3600000 // 1 hour
});

const vulnerabilities = await vulnDB.lookup('express', '4.17.0');
```

**ComplianceChecker**
```javascript
const { ComplianceChecker } = require('@security-guidance/compliance');

const checker = new ComplianceChecker({
  frameworks: ['gdpr', 'soc2', 'pci-dss'],
  jurisdiction: 'eu'
});

const compliance = await checker.check('./app');
```

## Contributing

1. Fork the repository
2. Create security feature branch
3. Follow secure coding practices
4. Add security tests
5. Submit pull request with security review

## License

MIT License - see LICENSE file for details.