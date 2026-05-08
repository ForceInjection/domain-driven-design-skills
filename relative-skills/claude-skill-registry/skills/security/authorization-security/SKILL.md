---
name: authorization-security
description: Authorization security standards covering RBAC, ABAC, policy enforcement, OAuth2 scopes, resource-based access control, and NIST 800-53 compliance (AC-3, AC-4, AC-6) for production systems
tags: [security, authorization, rbac, abac, access-control, oauth2, nist-800-53]
category: security
difficulty: intermediate
estimated_time: 45 minutes
prerequisites: [security-practices, authentication-security]
related_skills: [authentication, api-security, secrets-management]
nist_controls: [AC-3, AC-4, AC-6, AC-2, AC-5, AC-16]
---

# Authorization Security

> **Quick Navigation:**
> Level 1: [Quick Start](#level-1-quick-start-800-tokens-5-minutes) (5 min) → Level 2: [Implementation](#level-2-implementation-4500-tokens-30-minutes) (30 min) → Level 3: [Mastery](#level-3-mastery-resources) (Extended)

---

## Level 1: Quick Start (<800 tokens, 5 minutes)

### Core Principles

1. **Least Privilege**: Grant minimum permissions required (NIST AC-6)
2. **Separation of Duties**: No single user controls entire critical process
3. **Defense in Depth**: Multiple authorization checks at different layers
4. **Fail Secure**: Default deny, explicit allow
5. **Audit Everything**: Log all authorization decisions (AU-2)

### RBAC vs ABAC Comparison

| Aspect | RBAC (Role-Based) | ABAC (Attribute-Based) |
|--------|-------------------|------------------------|
| **Model** | Roles → Permissions | Attributes → Policies |
| **Flexibility** | Low (fixed roles) | High (dynamic rules) |
| **Complexity** | Simple to implement | Complex policy engine |
| **Use Case** | Traditional enterprise | Context-aware access |
| **Example** | `admin`, `user`, `guest` | `dept=finance AND time=business_hours` |
| **NIST Control** | AC-3 (Access Enforcement) | AC-3, AC-4, AC-16 |

### Essential Checklist

- [ ] **Least privilege**: Users have minimum required permissions (AC-6)
- [ ] **Separation of duties**: Critical operations require multiple approvals (AC-5)
- [ ] **Role hierarchies**: Roles inherit permissions logically
- [ ] **Policy enforcement**: Authorization checked at API gateway + service level
- [ ] **OAuth2 scopes**: Fine-grained permissions in access tokens
- [ ] **Resource ownership**: Users can only access their own resources
- [ ] **Deny by default**: Unknown requests rejected automatically
- [ ] **Audit logging**: All authorization decisions logged with user/resource/action
- [ ] **Time-based access**: Support for temporary permissions
- [ ] **Policy testing**: Unit tests for all authorization rules

### Quick Example

```python
# @nist ac-3 "Access enforcement"
# @nist ac-6 "Least privilege"

# ❌ NEVER do this (no authorization)
@app.route('/api/documents/<doc_id>')
def get_document(doc_id):
    return Document.query.get(doc_id)

# ✅ Enforce ownership and permissions
@app.route('/api/documents/<doc_id>')
@require_auth
def get_document(doc_id):
    doc = Document.query.get_or_404(doc_id)

    # Check ownership OR read permission
    if doc.owner_id != current_user.id and not current_user.has_permission('documents:read'):
        abort(403, "Insufficient permissions")

    # Audit the access
    audit_log.info(f"User {current_user.id} accessed document {doc_id}")
    return doc.to_dict()
```

### Common Patterns

**Role Hierarchy:**

```
superadmin
  └── admin
       └── manager
            └── user
                 └── guest
```

**Permission Naming:**

- `resource:action` (e.g., `documents:read`, `users:write`)
- `service:resource:action` (e.g., `api:documents:delete`)

**Scope Patterns:**

- `read:profile` - Read own profile
- `read:all_profiles` - Read all profiles (admin)
- `write:documents` - Create/update documents
- `admin:*` - Full administrative access

### Quick Links to Level 2

- [RBAC Implementation](#rbac-implementation)
- [ABAC Implementation](#abac-implementation)
- [Policy Enforcement Points](#policy-enforcement-points)
- [OAuth2 Scopes](#oauth2-scopes-and-claims)
- [NIST Compliance](#nist-800-53-compliance)

---

## Level 2:
>
> **📚 Full Examples**: See [REFERENCE.md](./REFERENCE.md) for complete code samples, detailed configurations, and production-ready implementations.

 Implementation (<4,500 tokens, 30 minutes)

### RBAC Implementation

**Role-Based Access Control** assigns permissions to roles, then roles to users. Ideal for traditional enterprise systems with stable organizational structures.

#### Core Components

1. **Roles**: Named collections of permissions (e.g., `admin`, `editor`, `viewer`)
2. **Permissions**: Specific actions on resources (e.g., `documents:read`, `users:write`)
3. **Users**: Assigned one or more roles
4. **Role Hierarchy**: Roles can inherit from parent roles

#### Database Schema


*See [REFERENCE.md](./REFERENCE.md#example-0) for complete implementation.*


#### Python Implementation

See [templates/policy-enforcement.py](templates/policy-enforcement.py) for complete implementation.


*See [REFERENCE.md](./REFERENCE.md#example-1) for complete implementation.*


#### Role Hierarchy Example


*See [REFERENCE.md](./REFERENCE.md#example-2) for complete implementation.*


See [templates/rbac-policy.yaml](templates/rbac-policy.yaml) for declarative policy definition.

---

### ABAC Implementation

**Attribute-Based Access Control** uses policies that evaluate attributes (user, resource, environment) to make dynamic authorization decisions. Ideal for complex, context-aware access control.

#### Core Components

1. **Attributes**: Properties of users, resources, or environment (e.g., `user.department`, `resource.classification`, `env.time`)
2. **Policies**: Rules written in policy language (XACML, Rego, Cedar)
3. **Policy Decision Point (PDP)**: Evaluates policies
4. **Policy Enforcement Point (PEP)**: Enforces PDP decisions

#### XACML Policy Example

See [templates/abac-policy.json](templates/abac-policy.json) for complete policy.


*See [REFERENCE.md](./REFERENCE.md#example-3) for complete implementation.*


#### Python ABAC Implementation


*See [REFERENCE.md](./REFERENCE.md#example-4) for complete implementation.*


---

### Policy Enforcement Points

**PEP (Policy Enforcement Point)** intercepts requests and enforces authorization decisions from the PDP (Policy Decision Point). Common locations: API gateway, middleware, service mesh.

#### Architecture


*See [REFERENCE.md](./REFERENCE.md#example-5) for complete implementation.*


#### Express Middleware Example

See [templates/middleware.js](templates/middleware.js) for complete implementation.


*See [REFERENCE.md](./REFERENCE.md#example-6) for complete implementation.*


#### Multi-Layer Enforcement

**Defense in Depth**: Enforce at multiple layers.


*See [REFERENCE.md](./REFERENCE.md#example-7) for complete implementation.*


---

### OAuth2 Scopes and Claims

**OAuth2 scopes** provide coarse-grained authorization. **JWT claims** carry fine-grained attributes for ABAC.

#### Scope Design

**Best Practices:**

- Use `resource:action` format (e.g., `documents:read`, `users:write`)
- Separate read/write/admin scopes
- Use `*` sparingly (e.g., `admin:*` for full access)


*See [REFERENCE.md](./REFERENCE.md#example-8) for complete implementation.*


#### Scope Validation Middleware


*See [REFERENCE.md](./REFERENCE.md#example-9) for complete implementation.*


#### Claims-Based Authorization (ABAC with JWT)

Embed user attributes in JWT for distributed ABAC.


*See [REFERENCE.md](./REFERENCE.md#example-10) for complete implementation.*


---

### Testing Authorization

Comprehensive testing ensures authorization logic is correct and secure.

#### Unit Tests


*See [REFERENCE.md](./REFERENCE.md#example-11) for complete implementation.*


#### Integration Tests


*See [REFERENCE.md](./REFERENCE.md#example-12) for complete implementation.*


#### Policy Testing


*See [REFERENCE.md](./REFERENCE.md#example-13) for complete implementation.*


---

### NIST 800-53 Compliance

#### AC-3: Access Enforcement

**Control**: The information system enforces approved authorizations for logical access to information and system resources.

**Implementation:**

- ✅ PEP at API gateway and service layer
- ✅ PDP evaluates policies before granting access
- ✅ Deny by default (fail secure)
- ✅ Authorization decisions logged (audit trail)


*See [REFERENCE.md](./REFERENCE.md#example-14) for complete implementation.*


#### AC-4: Information Flow Enforcement

**Control**: The information system enforces approved authorizations for controlling the flow of information within the system and between interconnected systems.

**Implementation:**

- ✅ ABAC policies control data flow based on classification
- ✅ Network-based restrictions (IP allowlisting)
- ✅ Cross-department access controls


*See [REFERENCE.md](./REFERENCE.md#example-15) for complete implementation.*


#### AC-6: Least Privilege

**Control**: The organization employs the principle of least privilege, allowing only authorized accesses for users necessary to accomplish assigned tasks.

**Implementation:**

- ✅ Users granted minimum required permissions
- ✅ Role hierarchy (users don't automatically get admin)
- ✅ Temporary permissions with expiration
- ✅ Regular permission audits

```python
# @nist ac-6 "Least privilege"
# Users assigned specific roles, not blanket admin access
user.roles = ['documents:read', 'documents:write']  # NOT 'admin:*'
```

#### AC-2: Account Management

**Control**: The organization manages information system accounts including creation, enabling, modification, review, disabling, and removal.

**Implementation:**

- ✅ Role assignment audit trail (granted_by, granted_at)
- ✅ Temporary role expiration (expires_at)
- ✅ Account review process

```sql
-- @nist ac-2 "Account management"
CREATE TABLE user_roles (
    granted_by INTEGER REFERENCES users(id),
    granted_at TIMESTAMP,
    expires_at TIMESTAMP  -- Support temporary access
);
```

#### AC-5: Separation of Duties

**Control**: The organization separates duties of individuals to reduce the risk of malevolent activity without collusion.

**Implementation:**

- ✅ Multi-approval workflows for critical operations
- ✅ No single user has complete control
- ✅ Admin operations require dual authorization


*See [REFERENCE.md](./REFERENCE.md#example-18) for complete implementation.*


#### AC-16: Security Attributes

**Control**: The information system associates and maintains security attributes with information.

**Implementation:**

- ✅ Resource attributes (classification, department, owner)
- ✅ User attributes (clearance_level, department, role)
- ✅ ABAC policies use attributes for decisions


*See [REFERENCE.md](./REFERENCE.md#example-19) for complete implementation.*


#### Compliance Checklist

- [ ] **AC-3**: All resources protected by PEP, default deny enforced
- [ ] **AC-4**: Cross-boundary access controlled by classification/network
- [ ] **AC-6**: Least privilege verified, no unnecessary admin grants
- [ ] **AC-2**: Account management audit trail complete
- [ ] **AC-5**: Separation of duties for critical operations
- [ ] **AC-16**: Security attributes assigned and maintained
- [ ] **AU-2**: All authorization decisions logged with context

See [resources/nist-ac-controls.md](resources/nist-ac-controls.md) for detailed control mappings.

---

## Level 3: Mastery Resources

### Reference Materials

- [NIST SP 800-53 Rev 5 - Access Control Family](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)
- [XACML 3.0 Core Specification](http://docs.oasis-open.org/xacml/3.0/xacml-3.0-core-spec-os-en.html)
- [OAuth 2.0 Security Best Practices](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-security-topics)
- [NIST RBAC Model](https://csrc.nist.gov/projects/role-based-access-control)
- [Cedar Policy Language (AWS)](https://www.cedarpolicy.com/)
- [Open Policy Agent (OPA) Rego](https://www.openpolicyagent.org/docs/latest/policy-language/)

### Templates

- [templates/rbac-policy.yaml](templates/rbac-policy.yaml) - Declarative RBAC policy
- [templates/abac-policy.json](templates/abac-policy.json) - ABAC policy with conditions
- [templates/middleware.js](templates/middleware.js) - Express PEP middleware
- [templates/policy-enforcement.py](templates/policy-enforcement.py) - Python RBAC/ABAC
- [scripts/generate-rbac.sh](scripts/generate-rbac.sh) - Auto-generate RBAC from org chart
- [resources/nist-ac-controls.md](resources/nist-ac-controls.md) - NIST control checklist

### Advanced Topics

- **Policy Languages**: XACML, Rego (OPA), Cedar
- **Distributed Authorization**: Service mesh (Istio), sidecar pattern
- **ReBAC**: Relationship-Based Access Control (Google Zanzibar)
- **Fine-Grained Authorization**: Field-level, row-level security
- **Dynamic Permissions**: Context-aware, time-based, location-based
- **Authorization at Scale**: Caching strategies, policy compilation

### Tools

- **Open Policy Agent (OPA)**: General-purpose policy engine
- **Keycloak**: Identity and access management with RBAC/ABAC
- **Casbin**: Authorization library for multiple languages
- **AWS IAM/Cedar**: Cloud authorization services
- **Oso**: Authorization framework with Polar language

### Practice Exercises

1. Implement RBAC for a multi-tenant SaaS application
2. Design ABAC policy for healthcare system (HIPAA compliance)
3. Build PEP middleware for microservices architecture
4. Create dynamic permission system with temporary grants
5. Implement separation of duties for financial system
6. Audit existing authorization logic for NIST compliance

## Examples

### Basic Usage

```python
// TODO: Add basic example for authorization
// This example demonstrates core functionality
```

### Advanced Usage

```python
// TODO: Add advanced example for authorization
// This example shows production-ready patterns
```

### Integration Example

```python
// TODO: Add integration example showing how authorization
// works with other systems and services
```

See `examples/authorization/` for complete working examples.

## Integration Points

This skill integrates with:

### Upstream Dependencies

- **Tools**: RBAC, ABAC, ACL, Policy engines
- **Prerequisites**: Basic understanding of security concepts

### Downstream Consumers

- **Applications**: Production systems requiring authorization functionality
- **CI/CD Pipelines**: Automated testing and deployment workflows
- **Monitoring Systems**: Observability and logging platforms

### Related Skills

- [Authentication](../../authentication/SKILL.md)
- [Api Security](../../api-security/SKILL.md)

### Common Integration Patterns

1. **Development Workflow**: How this skill fits into daily development
2. **Production Deployment**: Integration with production systems
3. **Monitoring & Alerting**: Observability integration points

## Common Pitfalls

### Pitfall 1: Insufficient Testing

**Problem:** Not testing edge cases and error conditions leads to production bugs

**Solution:** Implement comprehensive test coverage including:

- Happy path scenarios
- Error handling and edge cases
- Integration points with external systems

**Prevention:** Enforce minimum code coverage (80%+) in CI/CD pipeline

### Pitfall 2: Hardcoded Configuration

**Problem:** Hardcoding values makes applications inflexible and environment-dependent

**Solution:** Use environment variables and configuration management:

- Separate config from code
- Use environment-specific configuration files
- Never commit secrets to version control

**Prevention:** Use tools like dotenv, config validators, and secret scanners

### Pitfall 3: Ignoring Security Best Practices

**Problem:** Security vulnerabilities from not following established security patterns

**Solution:** Follow security guidelines:

- Input validation and sanitization
- Proper authentication and authorization
- Encrypted data transmission (TLS/SSL)
- Regular security audits and updates

**Prevention:** Use security linters, SAST tools, and regular dependency updates

**Best Practices:**

- Follow established patterns and conventions for authorization
- Keep dependencies up to date and scan for vulnerabilities
- Write comprehensive documentation and inline comments
- Use linting and formatting tools consistently
- Implement proper error handling and logging
- Regular code reviews and pair programming
- Monitor production metrics and set up alerts

---

**Next Steps**: Review [api-security](../api-security/SKILL.md) for securing APIs, [authentication-security](../authentication/SKILL.md) for auth fundamentals, and [secrets-management](../secrets-management/SKILL.md) for credential handling.
