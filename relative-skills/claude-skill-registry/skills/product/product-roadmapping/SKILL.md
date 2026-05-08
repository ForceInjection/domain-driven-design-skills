---
name: product-roadmapping
description: Master product roadmapping with strategic planning, OKRs, feature prioritization, timeline management, and stakeholder alignment for successful product delivery.
---

# Product Roadmapping

Create strategic product roadmaps that align teams, communicate vision, and guide product development toward measurable business outcomes.

## When to Use This Skill

- Planning product direction and strategy
- Aligning stakeholders on priorities
- Communicating product vision
- Setting quarterly or annual goals
- Release planning and scheduling
- Balancing strategic initiatives
- Managing stakeholder expectations
- Tracking progress toward objectives

## Core Concepts

### 1. Roadmap Types

**Now-Next-Later Roadmap:**
- **Now**: Current quarter, committed features
- **Next**: Next quarter, high confidence
- **Later**: Future quarters, exploratory

**Theme-Based Roadmap:**
- Group features by strategic themes
- Less date-specific, more outcome-focused
- Examples: Performance, User Experience, Growth

**Release-Based Roadmap:**
- Organized by version releases
- Clear milestones and dates
- Examples: v1.0, v1.5, v2.0

### 2. OKR Framework

**Structure:**
```
Objective: What we want to achieve (qualitative)
├── Key Result 1: How we measure success (quantitative)
├── Key Result 2: How we measure success (quantitative)
└── Key Result 3: How we measure success (quantitative)
```

**Example:**
```
Objective: Become the leading project management tool for remote teams

Key Results:
- Increase MAU from 100K to 250K
- Achieve NPS score of 50+
- Reduce churn rate from 5% to 3%
```

### 3. Roadmap Components

- **Vision**: Long-term product direction
- **Strategy**: How to achieve the vision
- **Goals**: Specific objectives (OKRs)
- **Themes**: Strategic areas of focus
- **Features/Epics**: Major capabilities
- **Timeline**: When initiatives are planned
- **Metrics**: Success measures

## Practical Patterns

### Pattern 1: Now-Next-Later Roadmap

```markdown
## Product Roadmap - Q1 2024

### NOW (Q1 2024) - In Development
**Theme: User Experience & Onboarding**
- ✅ Redesigned onboarding flow (95% complete)
- 🔄 In-app tutorials and tooltips (60% complete)
- 📋 Mobile app improvements (30% complete)
- 📋 Performance optimization (planning)

**Success Metrics:**
- New user activation: 40% → 60%
- Time to first value: 10min → 5min

### NEXT (Q2 2024) - High Confidence
**Theme: Collaboration & Teamwork**
- Real-time collaboration features
- Team workspace management
- Comments and mentions
- Notification system

**Success Metrics:**
- Teams created: +200%
- Daily active teams: 1000+

### LATER (Q3-Q4 2024) - Exploring
**Theme: Advanced Analytics**
- Custom reporting dashboard
- Data export capabilities
- API for integrations
- Advanced search and filters

**Success Metrics:**
- TBD based on customer feedback
```

### Pattern 2: OKR-Based Roadmap

```markdown
## 2024 Product OKRs

### Q1 OKR: Improve User Retention

**Objective:** Reduce churn and increase user engagement

**Key Results:**
- KR1: Reduce monthly churn from 5% to 3%
- KR2: Increase DAU/MAU ratio from 30% to 40%
- KR3: Achieve 70% user activation within 7 days

**Initiatives:**
| Initiative | Owner | Status | Impact on KRs |
|-----------|-------|--------|---------------|
| Onboarding redesign | Sarah | ✅ Done | KR3: +15% |
| Email retention campaign | Mike | 🔄 In Progress | KR1: -1% |
| In-app engagement prompts | Lisa | 📋 Planned | KR2: +5% |

---

### Q2 OKR: Drive Revenue Growth

**Objective:** Increase revenue through upgrades and expansions

**Key Results:**
- KR1: Increase conversion to paid: 2% → 4%
- KR2: Increase ARPU: $50 → $65
- KR3: Achieve 20% quarterly revenue growth

**Initiatives:**
- Feature-gated premium capabilities
- Team pricing tier
- Enterprise sales program
```

### Pattern 3: Timeline Roadmap (Gantt-Style)

```
## Q1-Q2 2024 Release Plan

Jan | Feb | Mar | Apr | May | Jun
----|-----|-----|-----|-----|-----
███ Mobile v2.0           ███
    └── UI Redesign
        └── Performance
            ███ Analytics Dashboard███
                ███ API v2      ███
                    ███ Integrations ███

Milestones:
📍 Jan 15: Mobile v2.0 Beta
📍 Feb 28: Mobile v2.0 GA
📍 Mar 31: Analytics Dashboard Beta
📍 May 15: API v2 Launch
📍 Jun 30: Integrations Marketplace
```

### Pattern 4: Feature Roadmap with Prioritization

```markdown
## Feature Roadmap - Prioritized

### Critical (P0) - Q1
| Feature | Business Value | Effort | Status |
|---------|---------------|--------|--------|
| SSO/SAML Auth | High (Enterprise) | 13 pts | ✅ Done |
| Mobile offline mode | High (Retention) | 21 pts | 🔄 In Prog |
| Data export | High (Compliance) | 8 pts | 📋 Planned |

### High Priority (P1) - Q2
| Feature | Business Value | Effort | Status |
|---------|---------------|--------|--------|
| Advanced permissions | Med (Enterprise) | 13 pts | 📋 Planned |
| Custom branding | Med (Upgrade) | 8 pts | 📋 Planned |
| Audit logs | Med (Compliance) | 5 pts | 📋 Planned |

### Medium Priority (P2) - Q3+
- Slack integration
- Zapier connectivity
- Webhooks API
- Custom fields
```

### Pattern 5: Strategic Theme Roadmap

```markdown
## 2024 Strategic Themes

### Theme 1: Enterprise Ready (40% capacity)
**Goal:** Make product enterprise-grade
- SSO and SAML authentication
- Advanced security features
- Compliance certifications (SOC 2, GDPR)
- Audit logs and monitoring
- SLA guarantees

**Success:** 50+ enterprise customers, $2M ARR

### Theme 2: Performance & Scale (30% capacity)
**Goal:** Support 10x user growth
- Database optimization
- Caching layer
- CDN integration
- Load testing
- Auto-scaling infrastructure

**Success:** 99.9% uptime, <100ms response time

### Theme 3: User Experience (20% capacity)
**Goal:** Best-in-class UX
- Onboarding redesign
- Mobile app improvements
- Accessibility (WCAG 2.1)
- Internationalization

**Success:** NPS 50+, 60% activation rate

### Theme 4: Platform & Integrations (10% capacity)
**Goal:** Ecosystem expansion
- Public API v2
- Webhooks
- OAuth integration
- Partner marketplace

**Success:** 20+ integrations, 1000+ API users
```

## Best Practices

### Roadmap Creation
1. **Start with strategy** - Align with business goals
2. **Focus on outcomes** - Not just features
3. **Stay flexible** - Avoid rigid commitments far out
4. **Theme-based** - Group by strategic objectives
5. **Time horizons** - Now/Next/Later over exact dates
6. **Measurable goals** - Use OKRs or KPIs
7. **Stakeholder input** - Include customer feedback
8. **Regular updates** - Review quarterly

### Communication
1. **Audience-specific** - Different views for different stakeholders
2. **Visual clarity** - Easy to understand at a glance
3. **Context provided** - Why, not just what
4. **Realistic commitments** - Under-promise, over-deliver
5. **Transparent trade-offs** - Explain prioritization decisions
6. **Regular updates** - Keep stakeholders informed
7. **Two-way dialogue** - Gather feedback
8. **Version control** - Track changes over time

### Prioritization
1. **Value vs. Effort** - ROI-driven decisions
2. **Strategic alignment** - Support company OKRs
3. **Customer impact** - Data-driven insights
4. **Technical dependencies** - Sequence appropriately
5. **Resource capacity** - Realistic about team bandwidth
6. **Risk assessment** - Technical and market risks
7. **Competitive pressure** - Market awareness
8. **Regulatory requirements** - Compliance needs

## Tools and Templates

### Roadmap Template
```markdown
## [Product Name] Roadmap - [Year/Quarter]

**Vision:** [1-2 sentence product vision]

**Strategic Goals:**
1. [Goal 1]
2. [Goal 2]
3. [Goal 3]

### Q1 [Quarter Name]
**Theme:** [Strategic theme]
**Objective:** [What we want to achieve]

**Key Initiatives:**
- [ ] Initiative 1 (Priority: High, Effort: 13pts)
- [ ] Initiative 2 (Priority: High, Effort: 8pts)
- [ ] Initiative 3 (Priority: Med, Effort: 5pts)

**Success Metrics:**
- Metric 1: Target
- Metric 2: Target

### Q2 [Quarter Name]
[Similar structure]

### Future Considerations
- Research area 1
- Exploratory initiative 2
- Potential partnership 3
```

### OKR Template
```markdown
## [Quarter] OKRs

**Objective:** [Aspirational goal]

**Key Results:**
1. [Measurable outcome] - Current: X, Target: Y
   - Initiative A (Owner: Name)
   - Initiative B (Owner: Name)

2. [Measurable outcome] - Current: X, Target: Y
   - Initiative C (Owner: Name)

3. [Measurable outcome] - Current: X, Target: Y
   - Initiative D (Owner: Name)

**Dependencies:** [List any dependencies]
**Risks:** [Key risks to achievement]
```

## Resources

- **Product Roadmaps Relaunched**: C. Todd Lombardo
- **Inspired**: Marty Cagan on product management
- **OKR Guide**: Google's OKR playbook
- **ProductPlan**: Roadmap software and templates
- **Aha! Roadmaps**: Strategic planning tools
- **Roman Pichler**: Product roadmap templates
