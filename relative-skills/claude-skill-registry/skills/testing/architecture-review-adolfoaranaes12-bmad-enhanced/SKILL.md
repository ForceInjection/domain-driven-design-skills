---
name: architecture-review
description: Peer review architecture for quality, risks, and optimization opportunities. Analyzes scalability bottlenecks, security vulnerabilities, performance optimization, technology fit, and provides prioritized recommendations. Use when reviewing proposed architecture documents for quality assurance, risk identification, or architectural decision validation.
acceptance:
  - review_complete: "All architectural dimensions reviewed"
  - risks_identified: "Risks assessed and prioritized"
  - recommendations_provided: "Actionable recommendations with priorities"
  - alternatives_considered: "Alternative approaches evaluated"
inputs:
  architecture_file:
    type: string
    required: true
    description: "Path to architecture document"
  requirements_file:
    type: string
    required: false
    description: "Path to requirements (for comparison)"
  focus_area:
    type: string
    required: false
    description: "security | scalability | performance | cost | maintainability | all"
outputs:
  review_summary:
    type: string
    description: "Overall review summary"
  risks:
    type: array
    description: "Identified risks with severity levels"
  recommendations:
    type: array
    description: "Prioritized improvement recommendations"
  alternatives_evaluated:
    type: number
    description: "Number of alternative approaches considered"
telemetry:
  emit: "skill.architecture-review.completed"
  track:
    - focus_area
    - risks_count
    - critical_risks_count
    - recommendations_count
    - duration_ms
---

# Architecture Review

## Purpose

Conduct peer review of architecture documents to identify risks, bottlenecks, optimization opportunities, and provide expert recommendations. Goes beyond validation to critically analyze architecture quality and suggest improvements.

**Core Principles:**
- **Critical analysis:** Question assumptions, identify weaknesses
- **Risk-focused:** Prioritize risks by severity and likelihood
- **Constructive feedback:** Balance criticism with actionable improvements
- **Context-aware:** Consider business goals, team capabilities, constraints

---

## Prerequisites

- Architecture document exists and is reasonably complete
- Optionally: Requirements document for alignment verification

---

## Workflow

### 1. Load Architecture and Context

**Action:** Read architecture document

Execute:
```bash
python .claude/skills/bmad-commands/scripts/read_file.py \
  --path {architecture_file} \
  --output json
```

**If requirements provided:** Also load for comparison

**Parse architecture to understand:**
- System scale (users, data, traffic)
- Technology choices
- Architectural patterns used
- Deployment strategy
- Team context (size, expertise)

---

### 2. Determine Review Focus

**If focus_area specified:** Prioritize that dimension
**If "all" or unspecified:** Review all dimensions

**Review Dimensions:**
1. **Scalability:** Can it scale with growth?
2. **Security:** Are there vulnerabilities?
3. **Performance:** Optimization opportunities?
4. **Maintainability:** Technical debt risks?
5. **Technology Fit:** Are choices appropriate?
6. **Cost:** Infrastructure/operational costs?
7. **Team Capability:** Can team execute this?

---

### 3. Scalability Review

**Analyze scalability considerations:**

**Check for:**
- ✅ Identified bottlenecks
- ✅ Horizontal scaling strategy
- ✅ Database scaling plan (read replicas, sharding)
- ✅ Stateless design (for scaling)
- ✅ Load balancing approach
- ✅ Cache strategy
- ✅ CDN for static assets

**Common Issues:**
🟠 **Database as bottleneck**
- Single database instance
- No read replicas planned
- No sharding strategy

🟠 **Session state preventing scaling**
- In-memory sessions
- No sticky sessions/Redis

🟠 **No caching strategy**
- Direct database queries
- No CDN for static assets

🟠 **Monolithic architecture at high scale**
- Single deployment unit
- Coupling prevents independent scaling

**Recommendations:**
- Add database read replicas
- Implement Redis for sessions/caching
- Plan microservices extraction for bottlenecks
- Add CDN for static content

**See:** `references/scalability-review-guide.md`

---

### 4. Security Review

**Analyze security posture:**

**Check for:**
- ✅ Authentication mechanism (OAuth, JWT, session)
- ✅ Authorization strategy (RBAC, ABAC)
- ✅ Data encryption (at rest, in transit)
- ✅ Input validation and sanitization
- ✅ SQL injection prevention
- ✅ XSS prevention
- ✅ CSRF protection
- ✅ Rate limiting
- ✅ Security headers
- ✅ Secrets management

**Common Vulnerabilities:**
🔴 **Critical: Missing authentication**
- No auth mechanism documented
- Recommendation: Add JWT or session-based auth

🔴 **Critical: No input validation**
- User inputs not validated
- Risk: SQL injection, XSS
- Recommendation: Add validation layer (Zod, Joi)

🟠 **Medium: Passwords not hashed**
- Plain text storage
- Recommendation: Use bcrypt (cost factor 12)

🟡 **Low: No rate limiting**
- Vulnerable to brute force
- Recommendation: Add rate limiting (5 req/min)

**Recommendations:**
- Implement comprehensive input validation
- Add rate limiting for auth endpoints
- Use bcrypt for password hashing
- Implement CSRF tokens
- Add security headers (helmet.js)

**See:** `references/security-review-guide.md`

---

### 5. Performance Review

**Analyze performance optimization:**

**Check for:**
- ✅ Response time targets (p50, p95, p99)
- ✅ Caching strategy
- ✅ Database query optimization
- ✅ N+1 query prevention
- ✅ Lazy loading / code splitting
- ✅ Asset optimization (images, bundles)
- ✅ CDN usage

**Common Issues:**
🟠 **N+1 query problem**
- ORM queries in loops
- Recommendation: Use joins or batch loading

🟠 **No caching**
- Repeated database queries
- Recommendation: Add Redis caching

🟠 **Large bundle sizes**
- >500KB initial bundle
- Recommendation: Code splitting, lazy loading

🟠 **Unoptimized images**
- Large image files
- Recommendation: Image optimization, WebP format

**Recommendations:**
- Implement Redis caching (5-min TTL)
- Add database query optimization (indexes, joins)
- Enable code splitting (route-based)
- Optimize images (WebP, lazy loading)
- Add CDN for static assets

**See:** `references/performance-review-guide.md`

---

### 6. Maintainability Review

**Analyze long-term maintenance:**

**Check for:**
- ✅ Code organization clear
- ✅ Separation of concerns
- ✅ Testing strategy defined
- ✅ Documentation standards
- ✅ Tech debt management plan
- ✅ Dependency management

**Common Issues:**
🟡 **Poor separation of concerns**
- Business logic in controllers
- Recommendation: Service layer pattern

🟡 **No testing strategy**
- Tests not mentioned
- Recommendation: Add unit + integration tests

🟡 **Tight coupling**
- Components tightly coupled
- Recommendation: Dependency injection, interfaces

🟡 **No deprecation strategy**
- No plan for tech evolution
- Recommendation: Version APIs, plan migrations

**Recommendations:**
- Adopt repository/service pattern
- Define testing strategy (80% coverage)
- Implement dependency injection
- Plan for API versioning

---

### 7. Technology Fit Review

**Evaluate technology choices:**

**For each major technology:**
- ✅ Appropriate for scale?
- ✅ Team has expertise?
- ✅ Community support strong?
- ✅ Long-term viability?
- ✅ Better alternatives exist?

**Common Concerns:**
🟠 **Over-engineering**
- Kubernetes for small app
- Recommendation: Start with simpler hosting (Vercel, Heroku)

🟠 **Under-engineering**
- SQLite for high-traffic app
- Recommendation: Upgrade to PostgreSQL

🟡 **Trend-chasing**
- Latest tech without justification
- Recommendation: Use proven technologies

🟡 **Team mismatch**
- Tech team doesn't know
- Recommendation: Consider team expertise

**Alternative Technologies to Consider:**

**Example 1:** Redux → Zustand
- Simpler API, less boilerplate
- Trade-off: Smaller ecosystem

**Example 2:** Microservices → Modular Monolith
- Simpler deployment, lower ops
- Trade-off: Less independent scaling

**See:** `references/technology-alternatives.md`

---

### 8. Cost Review

**Analyze infrastructure and operational costs:**

**Check for:**
- ✅ Infrastructure cost estimates
- ✅ Scaling cost projections
- ✅ Third-party service costs
- ✅ Cost optimization opportunities

**Common Cost Issues:**
🟠 **Expensive database plan**
- Over-provisioned resources
- Recommendation: Right-size based on actual usage

🟠 **Unused resources**
- Always-on dev environments
- Recommendation: Auto-shutdown non-prod environments

🟠 **Data transfer costs**
- Large data transfers
- Recommendation: Use CDN, optimize payloads

**Cost Optimization Recommendations:**
- Use auto-scaling to match demand
- Leverage reserved instances (if AWS)
- Implement caching to reduce database load
- Optimize data transfer with CDN

---

### 9. Risk Assessment

**Identify and prioritize risks:**

**Risk Categories:**
- **Critical (🔴):** Immediate blockers, security vulnerabilities
- **High (🟠):** Significant impact, likely to occur
- **Medium (🟡):** Moderate impact or likelihood
- **Low (🟢):** Minor impact, unlikely

**Risk Assessment Template:**
```markdown
## Risk: [Risk Title]

**Severity:** Critical | High | Medium | Low
**Likelihood:** High | Medium | Low
**Impact:** [Description of impact]
**Mitigation:** [How to address]
**Effort:** [Time/cost to mitigate]
```

**Example:**
```markdown
## Risk: Database Becomes Bottleneck at Scale

**Severity:** High (🟠)
**Likelihood:** High (projected 50K users in 6 months)
**Impact:** Performance degradation, poor user experience, potential downtime
**Mitigation:**
1. Add database read replicas (3 hours)
2. Implement Redis caching (4 hours)
3. Plan sharding strategy (2 days research)
**Effort:** ~2 person-days
```

---

### 10. Generate Recommendations

**Categorize recommendations by priority:**

**Priority Levels:**
1. **P0 (Critical):** Must address before production
2. **P1 (High):** Address before launch or soon after
3. **P2 (Medium):** Address in next quarter
4. **P3 (Low):** Nice-to-have improvements

**Recommendation Template:**
```markdown
**[P0] Add Input Validation**
- **Issue:** No validation layer, vulnerable to SQL injection/XSS
- **Recommendation:** Implement Zod schemas for all API inputs
- **Impact:** Critical security vulnerability
- **Effort:** 1-2 days
- **Resources:** [Zod documentation link]
```

**Prioritization Criteria:**
- Security issues → P0/P1
- Scalability blockers → P1/P2
- Performance issues → P1/P2
- Maintainability concerns → P2/P3
- Cost optimizations → P2/P3

---

### 11. Evaluate Alternatives

**For each major architectural decision, consider alternatives:**

**Alternative Evaluation Template:**
```markdown
### Alternative: [Option Name]

**Current Choice:** [What's in architecture]
**Alternative:** [Different approach]

**Pros:**
- Benefit 1
- Benefit 2

**Cons:**
- Drawback 1
- Drawback 2

**Recommendation:** Keep current | Switch to alternative | Consider for future

**Rationale:** [Why this recommendation]
```

**Example:**
```markdown
### Alternative: Microservices vs. Modular Monolith

**Current Choice:** Microservices architecture

**Alternative:** Modular Monolith

**Pros:**
- Simpler deployment
- Lower operational overhead
- Faster development initially
- Easier debugging

**Cons:**
- Less independent scaling
- Potential coupling over time
- Harder to extract services later

**Recommendation:** Switch to Modular Monolith for now

**Rationale:** Team is small (3 developers), complexity of microservices outweighs benefits at current scale. Plan to extract microservices when team grows to 10+ developers.
```

---

### 12. Generate Review Report

**Create comprehensive review report:**

```markdown
# Architecture Review Report

**Architecture:** [file path]
**Reviewed by:** Winston (Architect)
**Review Date:** [timestamp]
**Focus:** [focus areas]

---

## Executive Summary

[2-3 paragraphs summarizing overall assessment, major risks, key recommendations]

---

## Strengths

✅ [Strength 1]
✅ [Strength 2]
✅ [Strength 3]

---

## Risks Identified

### Critical Risks (🔴)
1. [Risk title]
   - Impact: [description]
   - Mitigation: [action]

### High Risks (🟠)
2. [Risk title]
   - Impact: [description]
   - Mitigation: [action]

### Medium Risks (🟡)
[Continue...]

---

## Recommendations

### P0 (Critical - Must Address)
1. **Add Input Validation**
   - Issue: Vulnerable to injection attacks
   - Action: Implement Zod schemas
   - Effort: 1-2 days

### P1 (High - Address Soon)
2. **Implement Database Scaling**
   - Issue: Single DB instance won't scale
   - Action: Add read replicas
   - Effort: 3-4 hours

[Continue with P2, P3...]

---

## Alternative Architectures Considered

[List of alternatives evaluated with recommendations]

---

## Detailed Analysis

### Scalability Analysis
[Detailed findings]

### Security Analysis
[Detailed findings]

### Performance Analysis
[Detailed findings]

### Cost Analysis
[Detailed findings]

---

## Action Plan

**Immediate (Next Sprint):**
- [ ] Address P0 recommendations
- [ ] Start P1 recommendations

**Short-term (Next Quarter):**
- [ ] Complete P1 recommendations
- [ ] Start P2 recommendations

**Long-term (6-12 months):**
- [ ] Complete P2 recommendations
- [ ] Consider P3 recommendations

---

## Follow-up

**Re-review recommended after:**
- All P0 and P1 items addressed
- Major architectural changes
- Significant scale increase

---

**Reviewed by:** Winston (BMAD Enhanced Architect)
**Review Tool:** architecture-review skill
```

---

## Common Scenarios

### Scenario 1: Security-Focused Review
**Focus:** Security vulnerabilities and compliance
**Output:** Detailed security findings, OWASP compliance check

### Scenario 2: Scalability-Focused Review
**Focus:** Bottlenecks and scaling strategy
**Output:** Load projections, scaling recommendations

### Scenario 3: Cost-Focused Review
**Focus:** Infrastructure costs and optimization
**Output:** Cost breakdown, optimization recommendations

### Scenario 4: Pre-Launch Review
**Focus:** All dimensions, production readiness
**Output:** Comprehensive review, go/no-go recommendation

---

## Best Practices

1. **Be constructive** - Balance criticism with actionable improvements
2. **Consider context** - Team size, timeline, budget matter
3. **Prioritize ruthlessly** - Not all recommendations are equal
4. **Suggest alternatives** - Don't just criticize, offer options
5. **Think long-term** - Consider maintenance, scaling, evolution
6. **Be pragmatic** - Perfect is the enemy of good
7. **Document thoroughly** - Provide rationale for all recommendations

---

## Reference Files

- `references/scalability-review-guide.md` - Scalability analysis framework
- `references/security-review-guide.md` - Security vulnerability checklist
- `references/performance-review-guide.md` - Performance optimization guide
- `references/technology-alternatives.md` - Alternative technology options

---

## When to Escalate

Escalate to user when:
- Critical security vulnerabilities found
- Architecture fundamentally flawed (requires major rework)
- Cost projections exceed budget significantly
- Team lacks expertise for proposed technologies
- Compliance requirements not met

---

*Part of BMAD Enhanced Quality Suite*
