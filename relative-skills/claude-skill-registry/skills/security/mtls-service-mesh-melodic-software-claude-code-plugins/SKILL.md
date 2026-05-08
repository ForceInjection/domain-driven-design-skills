---
name: mtls-service-mesh
description: Use when implementing service-to-service security, mTLS, or service mesh patterns. Covers mutual TLS, Istio, Linkerd, certificate management, and service mesh security configurations.
allowed-tools: Read, Glob, Grep
---

# mTLS and Service Mesh Security

Comprehensive guide to securing service-to-service communication with mutual TLS and service mesh patterns.

## When to Use This Skill

- Implementing mTLS between services
- Deploying service mesh (Istio, Linkerd)
- Certificate management for services
- Zero trust networking within clusters
- Service identity and authentication
- Encrypting east-west traffic

## Mutual TLS (mTLS) Fundamentals

### TLS vs mTLS

```text
Standard TLS (one-way):
Client ──────────────────► Server
         Client verifies
         server identity

Mutual TLS (two-way):
Client ◄────────────────► Server
         Both verify
         each other

Standard TLS:
- Server presents certificate
- Client validates server
- Client remains anonymous to server

Mutual TLS:
- Server presents certificate
- Client validates server
- Client presents certificate
- Server validates client
- Both identities verified
```

### mTLS Handshake

```text
mTLS Handshake Flow:

1. Client Hello
   └── Client → Server: "Hello, I support these ciphers"

2. Server Hello + Certificate
   └── Server → Client: "Let's use this cipher"
   └── Server → Client: "Here's my certificate"
   └── Server → Client: "Please provide your certificate"

3. Client Certificate
   └── Client → Server: "Here's my certificate"

4. Certificate Verification
   └── Both sides verify:
       - Certificate chain valid
       - Not expired
       - Not revoked
       - Identity matches expected

5. Key Exchange
   └── Derive shared session key

6. Encrypted Communication
   └── All traffic encrypted with session key
```

### Certificate Components

```text
Service Certificate Fields:

Subject:
  CN = my-service
  O = my-organization

Subject Alternative Names (SANs):
  - DNS: my-service.default.svc.cluster.local
  - DNS: my-service.default
  - DNS: my-service
  - URI: spiffe://cluster.local/ns/default/sa/my-service

Issuer: (CA that signed the certificate)
  CN = cluster-ca

Validity:
  Not Before: 2025-01-01
  Not After:  2025-01-08  (short-lived, auto-rotated)

Key Usage:
  - Digital Signature
  - Key Encipherment

Extended Key Usage:
  - TLS Web Server Authentication
  - TLS Web Client Authentication
```

## Service Mesh Architecture

### Components

```text
Service Mesh Architecture:

┌─────────────────────────────────────────────────────┐
│                   Control Plane                      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐   │
│  │   Pilot    │  │   Citadel  │  │   Galley   │   │
│  │ (Config)   │  │   (CA)     │  │ (Validation)│   │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘   │
└────────┼───────────────┼───────────────┼───────────┘
         │               │               │
         └───────────────┼───────────────┘
                         │
         ┌───────────────▼───────────────┐
         │         Data Plane            │
┌────────┼────────────────────────────────┼────────┐
│        │                                │        │
│  ┌─────▼─────┐                  ┌──────▼─────┐  │
│  │  Sidecar  │◄─────mTLS───────►│  Sidecar   │  │
│  │  (Envoy)  │                  │  (Envoy)   │  │
│  └─────┬─────┘                  └─────┬──────┘  │
│        │                              │         │
│  ┌─────▼─────┐                  ┌─────▼─────┐  │
│  │ Service A │                  │ Service B │  │
│  └───────────┘                  └───────────┘  │
└──────────────────────────────────────────────────┘

Control Plane Functions:
- Certificate authority (issue/rotate certs)
- Configuration distribution
- Policy management
- Service discovery

Data Plane Functions:
- mTLS termination
- Traffic encryption
- Policy enforcement
- Telemetry collection
```

### Sidecar Proxy Pattern

```text
Sidecar Injection:

Without Sidecar:
┌───────────────────┐
│      Pod          │
│  ┌─────────────┐  │
│  │   App       │──────► Network
│  └─────────────┘  │
└───────────────────┘

With Sidecar:
┌────────────────────────────────────┐
│              Pod                    │
│  ┌─────────────┐  ┌─────────────┐  │
│  │    App      │  │   Sidecar   │  │
│  │             │──►│  (Envoy)   │──────► mTLS ──►
│  │ localhost   │  │  handles   │  │
│  │  :8080      │  │  security  │  │
│  └─────────────┘  └─────────────┘  │
└────────────────────────────────────┘

Traffic Flow:
1. App sends request to localhost
2. Sidecar intercepts (iptables rules)
3. Sidecar establishes mTLS connection
4. Traffic encrypted to destination sidecar
5. Destination sidecar decrypts
6. Destination sidecar forwards to app
```

## Istio Security

### Istio mTLS Modes

```text
PeerAuthentication Modes:

1. PERMISSIVE (default initially)
   - Accepts both plaintext and mTLS
   - Good for migration

2. STRICT
   - mTLS required for all traffic
   - Rejects plaintext connections

3. DISABLE
   - Disable mTLS (not recommended)

Example Policy:
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: production
spec:
  mtls:
    mode: STRICT
```

### Istio Authorization Policies

```text
Authorization Policy Structure:

apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: orders-policy
  namespace: production
spec:
  selector:
    matchLabels:
      app: orders-service
  action: ALLOW
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/production/sa/frontend"]
    to:
    - operation:
        methods: ["GET", "POST"]
        paths: ["/api/orders/*"]
    when:
    - key: request.headers[x-custom-header]
      values: ["valid-value"]

Policy Logic:
- selector: Which workloads this applies to
- from: Who can make requests (source identity)
- to: What operations are allowed
- when: Additional conditions
```

### Istio Certificate Management

```text
Istio Certificate Flow:

1. Workload starts with sidecar
2. Sidecar requests certificate from Istiod (CA)
3. Istiod verifies service account identity
4. Istiod issues short-lived certificate (24h default)
5. Sidecar stores certificate in memory
6. Certificate auto-rotated before expiry

SPIFFE Identity Format:
spiffe://cluster.local/ns/namespace/sa/service-account

Certificate Properties:
- Short-lived (hours, not years)
- Auto-rotated (no manual intervention)
- Bound to Kubernetes service account
- No private key leaves workload
```

## Linkerd Security

### Linkerd mTLS

```text
Linkerd Automatic mTLS:

Features:
- mTLS enabled by default
- Zero-configuration setup
- Automatic certificate rotation
- No YAML required for basic mTLS

Identity System:
- Uses Kubernetes service accounts
- Certificates issued by Linkerd's identity service
- 24-hour certificate lifetime (default)
- Automatic rotation

Verification:
$ linkerd viz tap deploy/my-service
  Shows mTLS status of connections

$ linkerd check --proxy
  Validates mTLS configuration
```

### Linkerd Server Authorization

```text
Linkerd Authorization:

apiVersion: policy.linkerd.io/v1beta1
kind: Server
metadata:
  name: orders-api
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: orders-service
  port: 8080
  proxyProtocol: HTTP/2

---
apiVersion: policy.linkerd.io/v1beta1
kind: ServerAuthorization
metadata:
  name: orders-authz
  namespace: production
spec:
  server:
    name: orders-api
  client:
    meshTLS:
      serviceAccounts:
      - name: frontend
        namespace: production
```

## Certificate Management

### Certificate Rotation Strategies

```text
Rotation Approaches:

1. Short-Lived Certificates (Recommended)
   - 1-24 hour validity
   - Auto-rotated by mesh
   - No revocation needed (just let expire)
   - Service mesh handles automatically

2. Long-Lived with Revocation
   - Days to months validity
   - Requires revocation infrastructure
   - CRL or OCSP for checking
   - More complex to manage

3. Hybrid
   - Short-lived for service mesh
   - Longer-lived for external connections
   - Different approaches for different contexts

Rotation Timeline:
┌─────────────────────────────────────────────────┐
│  Certificate Lifetime (e.g., 24 hours)         │
│                                                 │
│  ├──────────────────┼────────────────┼────────┤
│  Issue            Rotate          Expire      │
│  t=0              t=12h           t=24h       │
│                   (50% of life)               │
└─────────────────────────────────────────────────┘
```

### Root CA Management

```text
Root CA Hierarchy:

Option 1: Single Root (Simple)
Root CA
└── Workload Certificates

Option 2: Intermediate CAs (Recommended)
Root CA (offline, very long-lived)
├── Cluster CA 1 (intermediate, medium-lived)
│   └── Workload Certs (short-lived)
├── Cluster CA 2
│   └── Workload Certs
└── Cluster CA 3
    └── Workload Certs

Root CA Rotation:
1. Generate new root CA
2. Update trust bundle (include both old and new)
3. Issue new intermediates from new root
4. Workloads accept certs from both roots
5. Remove old root after all certs rotated
```

## Migration to mTLS

### Migration Strategy

```text
Phase 1: Observe (Week 1-2)
- Enable mesh in permissive mode
- Monitor which connections are plaintext
- Identify all service-to-service traffic
- Document dependencies

Phase 2: Test (Week 3-4)
- Enable strict mode in test environment
- Verify all services can communicate
- Test failure scenarios
- Fix any issues

Phase 3: Rollout (Week 5-8)
- Enable strict mode namespace by namespace
- Start with least critical namespaces
- Monitor for connection failures
- Rollback plan ready

Phase 4: Enforce (Week 9+)
- Enable strict mode cluster-wide
- Remove permissive policies
- Document exceptions
- Ongoing monitoring
```

### Common Migration Issues

```text
Issue: External services can't connect
Fix: Use Gateway for external → internal traffic

Issue: Legacy services don't support mTLS
Fix: Use permissive mode for specific services

Issue: Performance degradation
Fix: Tune sidecar resources, connection pools

Issue: Certificate errors
Fix: Check trust bundle, certificate chain

Issue: Non-meshed services can't communicate
Fix: Either add to mesh or use permissive mode
```

## Best Practices

```text
Security Best Practices:

1. Certificate Management
   □ Use short-lived certificates (hours, not years)
   □ Automate rotation completely
   □ Protect root CA (offline if possible)
   □ Monitor certificate expiry

2. Policy Management
   □ Default deny, explicit allow
   □ Use namespace isolation
   □ Regular policy audits
   □ Test policies in staging first

3. Observability
   □ Monitor mTLS success/failure rates
   □ Alert on plaintext connections (in strict mode)
   □ Log authorization decisions
   □ Trace requests across services

4. Operations
   □ Document all exceptions
   □ Regular security reviews
   □ Incident response procedures
   □ Rotation runbooks

5. Performance
   □ Right-size sidecar resources
   □ Connection pooling
   □ Monitor latency overhead
   □ Benchmark with and without mesh
```

## Troubleshooting

```text
Common Issues:

1. "Connection reset" errors
   - Check if both sides have valid certs
   - Verify trust bundle is synchronized
   - Check for certificate expiry

2. "503 Service Unavailable"
   - Destination may not have sidecar
   - Authorization policy blocking request
   - Service not in mesh

3. High latency
   - Sidecar resource constraints
   - Certificate verification overhead
   - Network policy conflicts

4. Intermittent failures
   - Certificate rotation race condition
   - Trust bundle propagation delay
   - Sidecar restart during rotation

Debug Commands (Istio):
$ istioctl analyze
$ istioctl proxy-status
$ istioctl proxy-config secret <pod>

Debug Commands (Linkerd):
$ linkerd check
$ linkerd viz tap <resource>
$ linkerd viz stat <resource>
```

## Related Skills

- `zero-trust-architecture` - Overall security architecture
- `api-security` - Application-level security
- `container-orchestration` - Kubernetes and service mesh
- `distributed-tracing` - Observability in service mesh
