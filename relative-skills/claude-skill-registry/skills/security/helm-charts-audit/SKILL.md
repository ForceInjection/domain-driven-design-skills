---
name: helm-charts-audit
description: Audits Helm charts for anti-patterns, security issues, and best practice violations. Use when asked to audit, review, or check Helm chart quality. Generates a comprehensive report under reports/YYYY-MM-DD/helm-charts-audit.md. (project)
---

# Purpose

Enforce Helm chart quality and security standards across the `helm-charts/` directory through automated checks.

**What it checks (13 checks):**
1. Image Tags (no latest, mutable tags) - HIGH
2. Security Context (runAsNonRoot, no privileged) - HIGH
3. Resource Limits (requests, limits, memory) - HIGH
4. RBAC Wildcards (no * permissions) - HIGH
5. Health Probes (liveness, readiness) - HIGH
6. Helm Lint (official helm validation) - HIGH
7. Chart Metadata (apiVersion, version, maintainers) - MEDIUM
8. Chart Structure (README, NOTES.txt, _helpers.tpl) - MEDIUM
9. Dependencies (pinned versions, Chart.lock) - MEDIUM
10. Deprecated APIs (no v1beta1, use stable APIs) - MEDIUM
11. Argo Rollouts (strategy, analysis, steps) - MEDIUM
12. Ingress TLS (certificates, annotations) - MEDIUM
13. GPU Resources (nvidia.com/gpu, tolerations) - LOW

# Running Checks

**Full audit (all checks):**
```bash
node .claude/skills/helm-charts-audit/scripts/run_all_checks.mjs
```

**Generate report (all checks + markdown report):**
```bash
node .claude/skills/helm-charts-audit/scripts/generate_report.mjs
```
Report saved to: `reports/YYYY-MM-DD/helm-charts-audit.md`

**Individual checks:**
```bash
node .claude/skills/helm-charts-audit/scripts/check_image_tags.mjs
node .claude/skills/helm-charts-audit/scripts/check_security_context.mjs
node .claude/skills/helm-charts-audit/scripts/check_resource_limits.mjs
node .claude/skills/helm-charts-audit/scripts/check_rbac_wildcards.mjs
node .claude/skills/helm-charts-audit/scripts/check_health_probes.mjs
node .claude/skills/helm-charts-audit/scripts/check_helm_lint.mjs
node .claude/skills/helm-charts-audit/scripts/check_chart_metadata.mjs
node .claude/skills/helm-charts-audit/scripts/check_chart_structure.mjs
node .claude/skills/helm-charts-audit/scripts/check_dependencies.mjs
node .claude/skills/helm-charts-audit/scripts/check_deprecated_apis.mjs
node .claude/skills/helm-charts-audit/scripts/check_argo_rollouts.mjs
node .claude/skills/helm-charts-audit/scripts/check_ingress_tls.mjs
node .claude/skills/helm-charts-audit/scripts/check_gpu_resources.mjs
```

# Quality Rules

## 1. Image Tags (HIGH)

**RULE**: Never use mutable tags. `latest` tag = unpredictable deployments + rollback failures.

**Violations**:
- `image: nginx:latest` - mutable, changes without notice
- `image: nginx` - defaults to :latest
- `tag: ""` - empty tag in values.yaml
- `tag: head`, `tag: canary`, `tag: dev` - mutable branch tags

**Fix**: Use immutable tags like `v1.2.3`, SHA digests `sha256:abc123`, or SemVer `1.21.0`.

---

## 2. Security Context (HIGH)

**RULE**: Containers must run with minimal privileges. Privileged containers = cluster takeover risk.

**Violations**:
- `privileged: true` - full host access, container escape trivial
- `runAsNonRoot: false` - runs as root user UID 0
- `runAsUser: 0` - explicitly root
- `allowPrivilegeEscalation: true` - can gain more privileges
- `hostNetwork: true` - shares host network namespace
- `hostPID: true` - can see/kill host processes
- `hostIPC: true` - can access host shared memory
- `readOnlyRootFilesystem: false` - malware can write anywhere
- `capabilities.add: [SYS_ADMIN]` - near-root level access
- `capabilities.add: [ALL]` - equivalent to privileged

**Fix**: Add proper securityContext with `runAsNonRoot: true`, `allowPrivilegeEscalation: false`, `readOnlyRootFilesystem: true`, `capabilities.drop: [ALL]`.

---

## 3. Resource Limits (HIGH)

**RULE**: All containers must have resource requests and limits. No limits = node OOM + noisy neighbor issues.

**Violations**:
- `resources: {}` - empty resources block
- Missing `requests.cpu` - scheduler can't make decisions
- Missing `requests.memory` - OOM killer may terminate unexpectedly
- Missing `limits.memory` - container can consume all node memory
- `requests > limits` - invalid configuration

**Fix**: Define `resources.requests.cpu`, `resources.requests.memory`, `resources.limits.memory`. Note: CPU limits often intentionally omitted for better performance.

---

## 4. RBAC Wildcards (HIGH)

**RULE**: Follow least-privilege principle. Wildcard permissions = privilege escalation path.

**Violations**:
- `verbs: ["*"]` - grants all actions
- `resources: ["*"]` - access to all resource types
- `apiGroups: ["*"]` - access across all API groups
- `roleRef.name: cluster-admin` - full cluster access
- `verbs: [impersonate]` - can act as other users
- `verbs: [escalate, bind]` - can grant additional privileges
- Access to `secrets` resource - can read all secrets

**Fix**: Use explicit verbs like `[get, list, watch]`, explicit resources like `[pods, services]`, avoid cluster-admin bindings.

---

## 5. Health Probes (HIGH)

**RULE**: All workloads must have health probes. No probes = stuck containers not restarted + traffic to unready pods.

**Violations**:
- Deployment without `livenessProbe` - stuck containers won't restart
- Deployment without `readinessProbe` - traffic sent to unready pods
- `initialDelaySeconds: 0` - probes start immediately, false failures
- `timeoutSeconds: 1` - too short, may cause false failures
- `successThreshold > 1` on livenessProbe - should always be 1
- `failureThreshold > 10` - delays detecting actual failures

**Fix**: Add livenessProbe and readinessProbe with reasonable `initialDelaySeconds` (10-30s), `periodSeconds` (10s), `timeoutSeconds` (5s).

---

## 6. Helm Lint (HIGH)

**RULE**: Charts must pass official helm lint validation. Lint failures = deployment failures.

**Violations**:
- Template syntax errors
- Missing required fields in Chart.yaml
- Invalid YAML structure
- Broken template references

**Fix**: Run `helm lint <chart-path>` and fix reported issues.

---

## 7. Chart Metadata (MEDIUM)

**RULE**: Chart.yaml must have complete metadata. Missing metadata = maintenance nightmare.

**Violations**:
- `apiVersion: v1` - Helm 2 format, upgrade to v2
- Missing or invalid `version` - must be SemVer
- Missing `appVersion` - hard to track what's deployed
- Missing `description` - unclear what chart does
- Missing `maintainers` - no ownership
- `name` doesn't match directory name - confusing

**Fix**: Use `apiVersion: v2`, SemVer version, add description and maintainers with email.

---

## 8. Chart Structure (MEDIUM)

**RULE**: Follow standard Helm chart structure. Non-standard = user confusion + missing features.

**Violations**:
- Missing `README.md` - no documentation
- Missing `templates/NOTES.txt` - no post-install instructions
- Missing `templates/_helpers.tpl` - no template helpers
- Missing `.helmignore` - unnecessary files in package
- Missing `values.schema.json` - no values validation
- Empty `templates/` directory

**Fix**: Create missing files following Helm chart best practices.

---

## 9. Dependencies (MEDIUM)

**RULE**: Pin dependency versions. Floating versions = non-reproducible builds.

**Violations**:
- No `version` on dependency - unpinned
- `version: "*"` or `version: "^1.0"` - floating version
- Missing `Chart.lock` - dependency versions not locked
- `repository: file://` - local reference, breaks when published
- `repository: http://` - insecure, use HTTPS
- Deprecated repository URLs (charts.helm.sh/stable)

**Fix**: Pin exact versions, run `helm dependency update` to generate Chart.lock.

---

## 10. Deprecated APIs (MEDIUM)

**RULE**: Use stable Kubernetes APIs. Deprecated APIs = upgrade failures.

**Violations**:
- `extensions/v1beta1` - removed in K8s 1.22
- `apps/v1beta1`, `apps/v1beta2` - removed in K8s 1.16
- `networking.k8s.io/v1beta1` Ingress - removed in K8s 1.22
- `batch/v1beta1` CronJob - removed in K8s 1.25
- `policy/v1beta1` PodSecurityPolicy - removed in K8s 1.25

**Fix**: Update to stable APIs: `apps/v1`, `networking.k8s.io/v1`, `batch/v1`. Run `kubectl convert` if needed.

---

## 11. Argo Rollouts (MEDIUM)

**RULE**: Rollouts must have valid strategy configuration. Invalid config = failed deployments.

**Violations**:
- Rollout without `strategy` - no deployment strategy
- Canary without `steps` - no gradual rollout
- Canary without `analysis` - no automated validation
- BlueGreen without `activeService` - no active service defined
- BlueGreen without `previewService` - can't preview before promotion
- Missing `revisionHistoryLimit` - old ReplicaSets accumulate
- Missing `progressDeadlineSeconds` - stuck rollouts don't timeout

**Fix**: Configure proper canary steps with analysis, or blueGreen with activeService/previewService.

---

## 12. Ingress TLS (MEDIUM)

**RULE**: Ingress must have TLS configuration. No TLS = unencrypted traffic.

**Violations**:
- Ingress with hosts but no TLS - traffic unencrypted
- TLS without `secretName` - certificate source unclear
- No `ingressClassName` - may use wrong controller
- Missing cert-manager annotations - no automated certificates
- Deprecated `kubernetes.io/ingress.class` annotation
- No SSL redirect annotation - HTTP doesn't redirect to HTTPS

**Fix**: Add TLS section with secretName, use `cert-manager.io/cluster-issuer` annotation for automated certs.

---

## 13. GPU Resources (LOW)

**RULE**: GPU workloads need proper configuration. Missing config = scheduling failures.

**Violations**:
- GPU limits without matching requests - should be equal
- No GPU toleration - won't schedule on GPU nodes
- No GPU nodeSelector/affinity - relies only on resource availability
- No runtimeClassName - may need nvidia runtime

**Fix**: Set `nvidia.com/gpu` in both requests and limits (equal values), add GPU tolerations and nodeSelector.

---

# Detection Philosophy

This skill uses **VALUE-BASED detection**:
- Detects issues by actual values and patterns, not by variable/field names
- Future-proof: new charts with issues are automatically detected
- No need to update scripts when new charts are added

# Parsing Strategy

- **Chart.yaml, values.yaml**: YAML content parsed via regex patterns
- **templates/*.yaml**: Regex-based parsing (Go template syntax breaks YAML parsers)
- **Multi-document YAML**: Handles `---` separators

# Safety

- Read-only operation (except report generation)
- No Helm releases modified
- No cluster changes
