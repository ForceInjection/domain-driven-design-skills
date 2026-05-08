---
name: cto-engineering-metrics
description: Expert methodology for defining, tracking, and interpreting engineering performance metrics including DORA, team health, productivity, and executive reporting.
---

# CTO Engineering Metrics Skill

## Purpose

This skill provides a comprehensive framework for measuring engineering organization performance. Use it to define metrics, create dashboards, interpret data, and communicate engineering impact to different stakeholders (executives, board, engineering team).

## When to Use

Trigger this skill when you need to:

- Set up engineering metrics and KPIs for your organization
- Create executive dashboards or board presentations
- Diagnose engineering productivity or quality issues
- Demonstrate engineering value to business stakeholders
- Benchmark your team against industry standards
- Define OKRs and success criteria for engineering
- Track team health and developer satisfaction
- Measure DevOps/platform improvements

## Core Methodology

Follow this systematic approach to engineering metrics:

### Phase 1: Define Purpose and Audience

1. **Identify the Question**

   - What are we trying to understand or improve?
   - What decision will these metrics inform?
   - What behavior do we want to encourage?

2. **Know Your Audience**

   - **Board/Investors**: Business impact, risk, strategic progress
   - **CEO/Executives**: Productivity, velocity, quality, cost efficiency
   - **Engineering Team**: Flow, blockers, technical health, growth
   - **Product Team**: Delivery predictability, feature velocity
   - **Yourself (CTO)**: Holistic health, trends, early warnings

3. **Avoid Metric Traps**
   - Don't measure what's easy, measure what matters
   - Avoid vanity metrics (lines of code, hours worked)
   - Beware Goodhart's Law: "When a measure becomes a target, it ceases to be a good measure"
   - Combine metrics to prevent gaming

### Phase 2: Select Metrics Framework

Choose the appropriate framework for your context:

#### DORA Metrics (DevOps Performance)

The gold standard for measuring DevOps effectiveness:

1. **Deployment Frequency**: How often do you deploy to production?
2. **Lead Time for Changes**: Time from commit to production
3. **Mean Time to Recovery (MTTR)**: Time to restore service after incident
4. **Change Failure Rate**: % of deployments causing failures

Use `references/frameworks/dora-metrics.md` for detailed implementation.

**When to use**: Assessing DevOps maturity, improving deployment pipeline

---

#### SPACE Framework (Developer Productivity)

Holistic view of developer productivity across 5 dimensions:

1. **S**atisfaction: Developer happiness and wellbeing
2. **P**erformance: Code quality and impact
3. **A**ctivity: Volume of work (commits, PRs, reviews)
4. **C**ommunication: Collaboration effectiveness
5. **E**fficiency: Ability to complete work without interruption

Use `references/frameworks/space-framework.md` for implementation.

**When to use**: Understanding developer experience, diagnosing productivity issues

---

#### Business Impact Metrics

Connect engineering to business outcomes:

1. **Feature Velocity**: Business value delivered per sprint
2. **Engineering Cost per Customer**: Cost efficiency
3. **Time to Market**: Speed of delivering customer value
4. **System Reliability**: Uptime, SLA compliance
5. **Engineering ROI**: Return on engineering investment

Use `references/frameworks/business-impact-metrics.md` for details.

**When to use**: Demonstrating value to executives/board, justifying budget

---

#### Team Health Metrics

Measure team sustainability and morale:

1. **Developer Satisfaction Score**: Regular surveys (eNPS)
2. **Retention Rate**: Voluntary turnover
3. **Time to Productivity**: How fast new hires contribute
4. **Burnout Indicators**: On-call load, overtime, vacation usage
5. **Psychological Safety**: Team confidence in taking risks

Use `references/frameworks/team-health-metrics.md` for surveys and benchmarks.

**When to use**: Preventing burnout, improving retention, building culture

---

### Phase 3: Implement Measurement

1. **Identify Data Sources**

   - Version control: GitHub, GitLab, Bitbucket
   - CI/CD: Jenkins, CircleCI, GitHub Actions
   - Issue tracking: Jira, Linear, GitHub Issues
   - Monitoring: Datadog, New Relic, PagerDuty
   - Surveys: Officevibe, Culture Amp, Google Forms

2. **Automate Collection**

   - Use APIs to pull data automatically
   - Build dashboards with real-time updates
   - Set up regular surveys (weekly/monthly)
   - Avoid manual reporting (too time-consuming, error-prone)

3. **Establish Baselines**
   - Measure current state before setting goals
   - Understand natural variation
   - Compare to industry benchmarks
   - Track trends over time, not point-in-time

Use `references/templates/metrics-implementation-plan.md` for step-by-step setup.

---

### Phase 4: Interpret and Act

1. **Look for Patterns**

   - Are metrics improving or declining?
   - Are there correlations? (e.g., deploy frequency ↑, change failure ↓)
   - Are there anomalies? (sudden spikes or drops)
   - Are different teams showing different patterns?

2. **Ask "Why?"**

   - Metrics show _what_ is happening, not _why_
   - Combine quantitative data with qualitative insights
   - Talk to engineers about what they see
   - Look for systemic issues, not individual performance

3. **Define Actions**

   - What specifically will we change?
   - Who owns the improvement?
   - What's the expected impact on metrics?
   - When will we review progress?

4. **Avoid Anti-Patterns**
   - Don't measure individuals, measure systems
   - Don't use metrics for performance reviews
   - Don't set arbitrary improvement targets without context
   - Don't track too many metrics (focus on 5-7 key ones)

Use `references/templates/metrics-interpretation-guide.md` for analysis playbook.

---

### Phase 5: Communicate Effectively

Tailor your message to the audience:

#### For Board/Investors

**Focus**: Risk, strategic progress, competitive positioning

**Key Metrics**:

- System reliability (uptime %)
- Security incidents and response
- Engineering budget vs. plan
- Technical debt trajectory
- Team growth and retention

**Format**: High-level dashboard, traffic-light status, narrative

Use `references/templates/board-dashboard.md`

---

#### For CEO/Executives

**Focus**: Business impact, velocity, quality, efficiency

**Key Metrics**:

- Feature delivery rate
- Engineering cost per revenue
- Time to market
- Quality (bugs, incidents)
- Team productivity trends

**Format**: Executive dashboard with trends and insights

Use `references/templates/executive-dashboard.md`

---

#### For Engineering Team

**Focus**: Flow, improvements, celebrating wins

**Key Metrics**:

- Deployment frequency
- Lead time
- Code review time
- Incident trends
- Team satisfaction

**Format**: Live dashboard, retrospectives, all-hands updates

Use `references/templates/team-dashboard.md`

---

## Key Principles

- **Start Simple**: Begin with 3-5 core metrics, expand later
- **Measure Systems, Not People**: Focus on process improvement
- **Balance is Key**: Combine speed, quality, and sustainability metrics
- **Context Matters**: Benchmarks vary by company stage, industry, team size
- **Act on Insights**: Metrics without action are vanity numbers
- **Iterate**: Refine metrics as your organization evolves

## Bundled Resources

**Frameworks** (`references/frameworks/`):

- `dora-metrics.md` - Complete DORA implementation guide with benchmarks
- `space-framework.md` - Developer productivity measurement
- `business-impact-metrics.md` - Connecting engineering to revenue
- `team-health-metrics.md` - Satisfaction, retention, burnout indicators

**Templates** (`references/templates/`):

- `metrics-implementation-plan.md` - Step-by-step setup guide
- `board-dashboard.md` - Board presentation template
- `executive-dashboard.md` - CEO/executive reporting
- `team-dashboard.md` - Engineering team metrics
- `metrics-interpretation-guide.md` - How to analyze and act on data
- `survey-templates.md` - Developer satisfaction surveys

**Examples** (`references/examples/`):

- Real dashboard examples from startups to enterprises
- Sample board presentations
- Before/after improvement stories
- Benchmark data by company stage

## Usage Patterns

**Example 1**: User says "Set up DORA metrics for my 30-person engineering team"

→ Load `references/frameworks/dora-metrics.md`
→ Identify data sources (e.g., GitHub + CircleCI + PagerDuty)
→ Create implementation plan using template
→ Define baseline benchmarks for team stage
→ Set up dashboard with targets
→ Provide interpretation guide

---

**Example 2**: User says "Create board presentation showing engineering performance"

→ Load `references/templates/board-dashboard.md`
→ Focus on: reliability, security, strategic initiatives, team health
→ Use traffic-light status for clarity
→ Include 1-2 key risks and mitigation plans
→ Keep to 3-5 slides maximum
→ Provide talking points

---

**Example 3**: User says "Our deployment frequency is low, help diagnose why"

→ Look at full DORA metrics: lead time, MTTR, change failure rate
→ Check deployment process: manual steps, review bottlenecks, test duration
→ Survey team for qualitative insights
→ Identify top 3 blockers
→ Create improvement plan with expected metrics impact

---

**Example 4**: User says "Prove that engineering is being productive to the CEO"

→ Load `references/frameworks/business-impact-metrics.md`
→ Calculate: features shipped, customer impact, time to market
→ Show efficiency: cost per feature, productivity trends
→ Demonstrate quality: bug rates, incident trends
→ Connect to business goals: revenue features vs. platform investment
→ Use executive dashboard template

---

## Metrics by Company Stage

### Early Stage Startup (5-15 engineers)

**Focus**: Speed to learn, customer feedback

**Key Metrics** (3-5):

- Deployment frequency (weekly)
- Customer-reported bugs
- Feature delivery vs. plan
- Team satisfaction

**Anti-Pattern**: Over-measuring at this stage. Stay lean.

---

### Growth Stage (15-50 engineers)

**Focus**: Scaling processes, maintaining quality

**Key Metrics** (5-7):

- Full DORA metrics
- Code review time
- Incident rate and MTTR
- Team health scores
- Feature velocity

**Challenge**: Maintaining speed while adding process

---

### Scale Stage (50-200 engineers)

**Focus**: Efficiency, coordination, technical excellence

**Key Metrics** (7-10):

- DORA metrics by team
- Developer productivity (SPACE)
- Cost efficiency metrics
- Cross-team delivery time
- Technical debt ratio
- Retention and satisfaction

**Challenge**: Comparing teams fairly, avoiding metric gaming

---

### Enterprise (200+ engineers)

**Focus**: Strategic alignment, innovation balance, efficiency

**Key Metrics** (10-15):

- All previous metrics, segmented
- Engineering ROI
- Innovation vs. maintenance ratio
- Platform adoption rates
- Organizational health
- Strategic initiative progress

**Challenge**: Not drowning in metrics, maintaining agility

---

## Warning Signs

These metric patterns indicate issues:

| Pattern               | Possible Issue                            | Action                                     |
| --------------------- | ----------------------------------------- | ------------------------------------------ |
| Deploy frequency ↓    | Fear of breaking things, process overhead | Simplify process, improve testing          |
| Lead time ↑           | Bottlenecks, growing complexity           | Find bottlenecks (code review? testing?)   |
| MTTR ↑                | Poor monitoring, unclear ownership        | Improve observability, on-call process     |
| Change failure rate ↑ | Insufficient testing, rushing             | Strengthen testing, review release process |
| Satisfaction ↓        | Burnout, unclear direction, blockers      | Talk to team, address top frustrations     |
| Retention rate ↓      | Culture issues, compensation, growth      | Exit interviews, competitive analysis      |

---

## Writing Style

All outputs should be:

- **Data-driven**: Use specific numbers and benchmarks
- **Actionable**: Connect metrics to concrete improvements
- **Balanced**: Show both strengths and areas for improvement
- **Contextual**: Adjust for company stage and industry
- **Honest**: Don't hide problems, show how you're addressing them

---

**Version**: 1.0.0
**Philosophy**: Measure what matters, act on insights, improve continuously
