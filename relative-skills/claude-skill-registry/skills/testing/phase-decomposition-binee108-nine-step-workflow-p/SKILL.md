---
name: phase-decomposition
description: Breaks features into 3-8 manageable phases with clear deliverables and success criteria. Use when planning feature implementation to create testable, independently committable work units.
---

# Phase Decomposition

## Instructions

### Create 3-8 phases

Each phase:
- Has clear deliverable
- Takes 30min - 2 hours
- Is independently testable
- Has clear success criteria

### Decomposition process

1. Identify core components
2. Order by dependency
3. Split into phases
4. Define success criteria for each

## Example

<!-- CUSTOMIZE: Replace with {{PROJECT_NAME}} domain examples -->

**Feature:** "Add {{entity}} validation"

```markdown
Phase 1: Schema (30min)
- Deliverable: ValidationSchema class
- Test: Schema creation works

Phase 2: {{Field1}} Validation (45min)
- Deliverable: validate_{{field1}}() method
- Test: Rejects invalid {{field1}} values

Phase 3: {{Field2}} Validation (45min)
- Deliverable: validate_{{field2}}() method
- Test: Rejects invalid {{field2}} values

Phase 4: Integration (1hr)
- Deliverable: {{Entity}}Validator service
- Test: Full validation workflow
```

## Domain-Specific Examples

### E-commerce: Payment Processing
```markdown
Feature: "Implement payment processing"

Phase 1: Payment Gateway Integration (1.5hr)
- Deliverable: PaymentGateway client wrapper
- Test: Can connect to gateway API

Phase 2: Transaction Creation (1hr)
- Deliverable: createTransaction() method
- Test: Creates transaction record

Phase 3: Payment Verification (1.5hr)
- Deliverable: verifyPayment() method
- Test: Validates payment status from gateway

Phase 4: Webhook Handler (1hr)
- Deliverable: Payment webhook endpoint
- Test: Processes payment status updates

Phase 5: Refund Logic (1.5hr)
- Deliverable: processRefund() method
- Test: Refunds work correctly
```

### SaaS: User Authentication
```markdown
Feature: "Add user authentication"

Phase 1: User Model & Database (45min)
- Deliverable: User table schema
- Test: Can create/read users

Phase 2: Password Hashing (30min)
- Deliverable: hashPassword() and verifyPassword()
- Test: Passwords hashed securely

Phase 3: Login Endpoint (1hr)
- Deliverable: POST /auth/login
- Test: Returns JWT on valid credentials

Phase 4: Token Validation (1hr)
- Deliverable: Authentication middleware
- Test: Rejects invalid/expired tokens

Phase 5: Logout & Token Revocation (45min)
- Deliverable: POST /auth/logout
- Test: Invalidates tokens properly
```

### Data Platform: ETL Pipeline
```markdown
Feature: "Build data extraction pipeline"

Phase 1: Data Source Connector (1.5hr)
- Deliverable: SourceConnector class
- Test: Can fetch raw data

Phase 2: Data Parser (1hr)
- Deliverable: parseData() method
- Test: Converts raw data to structured format

Phase 3: Data Validation (1.5hr)
- Deliverable: validateData() method
- Test: Rejects malformed data

Phase 4: Data Transformation (2hr)
- Deliverable: transformData() method
- Test: Applies business logic correctly

Phase 5: Data Storage (1hr)
- Deliverable: saveData() method
- Test: Persists to database

Phase 6: Error Handling & Retry (1hr)
- Deliverable: Retry mechanism
- Test: Recovers from transient failures
```

### IoT: Device Management
```markdown
Feature: "Implement device registration"

Phase 1: Device Model (45min)
- Deliverable: Device table schema
- Test: Can create device records

Phase 2: Registration Endpoint (1hr)
- Deliverable: POST /devices/register
- Test: Creates device with unique ID

Phase 3: Device Authentication (1.5hr)
- Deliverable: Device token generation
- Test: Devices can authenticate

Phase 4: Device Status Tracking (1hr)
- Deliverable: updateStatus() method
- Test: Tracks online/offline status

Phase 5: Device Configuration (1hr)
- Deliverable: Device config API
- Test: Can update device settings
```

### CRM: Contact Management
```markdown
Feature: "Add contact import"

Phase 1: File Upload Handler (1hr)
- Deliverable: POST /contacts/import
- Test: Accepts CSV/Excel files

Phase 2: File Parser (1hr)
- Deliverable: parseContactFile() method
- Test: Extracts contact data

Phase 3: Contact Validation (1.5hr)
- Deliverable: validateContact() method
- Test: Validates email, phone, required fields

Phase 4: Duplicate Detection (1.5hr)
- Deliverable: findDuplicates() method
- Test: Identifies existing contacts

Phase 5: Bulk Insert (1hr)
- Deliverable: bulkCreateContacts() method
- Test: Efficiently inserts contacts

Phase 6: Import Report (45min)
- Deliverable: Import summary response
- Test: Reports success/failure counts
```

## Anti-Patterns to Avoid

### ❌ Too Large (Unmanageable)
```markdown
Phase 1: Build entire authentication system (8hr)
- Too big, can't test incrementally
- High risk of delays
```

### ❌ Too Small (Excessive Overhead)
```markdown
Phase 1: Define constant (5min)
Phase 2: Write validation if-statement (5min)
Phase 3: Add error message (5min)
- 15 phases for simple feature
- Workflow overhead too high
```

### ❌ Wrong Dependencies
```markdown
Phase 1: Frontend UI
Phase 2: Backend API ← Depends on Phase 1
- Wrong order! Backend should come first
```

### ✅ Correct Example
```markdown
Phase 1: Backend API (1hr)
- Can test independently

Phase 2: Frontend UI (1.5hr)
- Consumes Phase 1 API
- Dependency order correct
```

## Checklist

Before finalizing phases:
- [ ] Each phase 30min - 2hr?
- [ ] Total 3-8 phases?
- [ ] Dependencies ordered correctly?
- [ ] Each phase independently testable?
- [ ] Clear deliverable for each?
- [ ] Success criteria defined?

---

**For detailed patterns, see [reference.md](reference.md)**
**For more examples, see [examples.md](examples.md)**
