---
name: fullstory-saas
version: v2
description: Industry-specific guide for implementing Fullstory in B2B SaaS applications. Covers feature adoption tracking, onboarding optimization, churn prediction signals, multi-tenant privacy considerations, role-based experiences, and enterprise customer requirements. Includes detailed examples for dashboards, workflows, settings, and collaboration features.
related_skills:
  - fullstory-privacy-controls
  - fullstory-privacy-strategy
  - fullstory-user-properties
  - fullstory-analytics-events
  - fullstory-page-properties
  - fullstory-element-properties
---

# Fullstory for B2B SaaS

> ⚠️ **LEGAL DISCLAIMER**: This guidance is for educational purposes only and does not constitute legal, compliance, or regulatory advice. SaaS applications may be subject to various regulations (GDPR, CCPA, SOC 2, industry-specific requirements) depending on your customers and data processed. Always consult with your legal and compliance teams before implementing any data capture solution. Your organization is responsible for ensuring compliance with all applicable regulations and customer contracts.

## Industry Overview

B2B SaaS applications have unique characteristics for session analytics:

- **Feature adoption focus**: Understanding which features users adopt (or don't)
- **Onboarding optimization**: Critical first-use experience
- **Multi-tenant concerns**: Data separation between customers
- **Enterprise requirements**: SOC 2, single-tenant options, data residency
- **Complex user hierarchies**: Organizations, teams, roles
- **Workflow optimization**: Multi-step processes, collaboration

### Key Goals for SaaS Implementations

1. **Improve onboarding completion** and time-to-value
2. **Understand feature adoption** and usage patterns
3. **Identify friction points** in core workflows
4. **Reduce churn** by identifying at-risk signals
5. **Optimize pricing page** and upgrade flows
6. **Support enterprise customer** requirements

---

## Recommended: Private by Default for Enterprise SaaS

For SaaS applications handling customer data, **Private by Default mode is recommended**:

```
┌─────────────────────────────────────────────────────────────────┐
│  SaaS: Consider Private by Default                               │
│                                                                 │
│  • Multi-tenant = high data sensitivity                         │
│  • Customer data displayed in your UI → mask by default         │
│  • Selectively unmask your UI (buttons, nav, feature names)     │
│  • Contact Fullstory Support to enable                          │
└─────────────────────────────────────────────────────────────────┘
```

| SaaS Type | Private by Default? | Reason |
|-----------|---------------------|--------|
| **CRM/Sales tools** | ⚠️ Recommended | Displays customer contact info |
| **Project management** | ⚠️ Consider | User-generated content |
| **Analytics dashboards** | ⚠️ Consider | Customer business data |
| **Developer tools** | ✅ Highly recommended | Code, credentials, secrets |
| **HR/Payroll** | ✅ Required | Employee PII |
| **Collaboration tools** | ⚠️ Consider | Messages, documents |

> **Reference**: [Fullstory Private by Default](https://help.fullstory.com/hc/en-us/articles/360044349073-Fullstory-Private-by-Default)

---

## SaaS Privacy Considerations

### What Can Typically Be Captured

| Data Type | Capture? | Notes |
|-----------|----------|-------|
| Feature usage | ✅ Yes | Core SaaS analytics |
| User role/permissions | ✅ Yes | For segmentation |
| Account/plan info | ✅ Yes | For segmentation |
| Product interactions | ✅ Yes | Core value |
| Workflow steps | ✅ Yes | Optimization |
| User names | ⚠️ Consider | Mask or use IDs |
| Email addresses | ⚠️ Consider | Hash or mask |
| User-generated content | ⚠️ Consider | Depends on product |
| Customer data in product | ⚠️ Careful | May need exclusion |
| File contents | ❌ Usually not | Customer's IP |
| API keys/tokens | ❌ Never | Security risk |
| Passwords | ❌ Never | Security risk |

### Multi-Tenant Privacy

```
Important: In SaaS, you're capturing data about YOUR users,
but they may be working with THEIR customers' data.

┌─────────────────────────────────────────────────────────────────┐
│  YOUR SaaS Application                                           │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  Customer A's Workspace (their data shown in your UI)       ││
│  │  - Their customer lists                                      ││
│  │  - Their financial data                                      ││
│  │  - Their proprietary content                                 ││
│  │  → May need to exclude/mask depending on product             ││
│  └─────────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  Customer B's Workspace                                      ││
│  │  → Same considerations                                       ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

---

## Implementation Architecture

### Privacy Zones for SaaS

```
┌─────────────────────────────────────────────────────────────────┐
│                    B2B SAAS APPLICATION                          │
├─────────────────────────────────────────────────────────────────┤
│  VISIBLE (fs-unmask)                                             │
│  • Navigation and menus                                          │
│  • Feature names and labels                                      │
│  • Action buttons                                                │
│  • Empty states and onboarding UI                               │
│  • Error messages (generic)                                      │
│  • Settings labels (not values)                                  │
│  • Dashboard structure (not data)                                │
│  • Pricing and plans                                            │
├─────────────────────────────────────────────────────────────────┤
│  MASKED (fs-mask)                                                │
│  • User names                                                   │
│  • Email addresses (consider hash for ID)                       │
│  • Company names (unless your user)                             │
│  • User-generated titles/names                                  │
├─────────────────────────────────────────────────────────────────┤
│  EXCLUDED (fs-exclude)                                           │
│  • Customer's customer data (CRM contacts, etc.)                │
│  • Customer's financial data                                     │
│  • File contents and documents                                  │
│  • API keys and tokens                                          │
│  • Passwords and credentials                                     │
│  • Proprietary/sensitive business data                          │
│  • Healthcare/financial SaaS: customer's regulated data         │
└─────────────────────────────────────────────────────────────────┘
```

### User Identification Pattern

```javascript
// SaaS: Rich identification for product analytics
function onUserLogin(user, organization) {
  FS('setIdentity', {
    uid: user.id,  // Your internal user ID
    displayName: user.firstName  // Just first name
  });
  
  FS('setProperties', {
    type: 'user',
    properties: {
      // User context
      user_role: user.role,  // "admin", "member", "viewer"
      user_created_at: user.createdAt,
      user_title: user.jobTitle,  // If available
      is_account_owner: user.isOwner,
      
      // Organization context (your customer)
      org_id: organization.id,
      org_name: organization.name,  // Usually OK for your customer
      org_industry: organization.industry,
      org_size: getOrgSizeRange(organization.employeeCount),
      org_plan: organization.plan,  // "free", "pro", "enterprise"
      org_created_at: organization.createdAt,
      
      // Feature access
      has_feature_x: organization.features.includes('feature_x'),
      has_feature_y: organization.features.includes('feature_y'),
      
      // Engagement signals
      days_since_signup: daysSince(user.createdAt),
      login_count_30d: user.loginCount30d,
      last_active_feature: user.lastFeature,
      
      // Lifecycle stage
      is_trial: organization.isTrial,
      trial_days_remaining: organization.trialDaysRemaining,
      is_paying: organization.isPaying,
      mrr: organization.mrr,  // Your revenue from this customer
      
      // Onboarding
      onboarding_completed: user.onboardingCompleted,
      onboarding_step: user.onboardingStep,
      
      // Integrations (what they've connected)
      has_slack_integration: organization.integrations.includes('slack'),
      has_salesforce_integration: organization.integrations.includes('salesforce'),
      
      // Joinable keys
      crm_account_id: organization.salesforceAccountId,
      support_org_id: organization.zendeskOrgId
    }
  });
}
```

---

## AI/ML Feature Tracking

Modern SaaS applications increasingly use AI/ML features. Track these carefully:

### What to Track for AI Features

| AI Feature Type | Track | Don't Track |
|-----------------|-------|-------------|
| **AI assistants/copilots** | Feature activated, suggestions accepted/rejected | Actual suggestions or prompts containing user data |
| **Smart recommendations** | Recommendation shown, clicked, dismissed | The recommended content itself (may contain customer data) |
| **Automated workflows** | Automation triggered, completed, failed | Customer data processed by automation |
| **Predictive analytics** | Feature viewed, exported | The predictions themselves |
| **AI-generated content** | Generation requested, accepted, edited | The generated content |

```javascript
// Track AI feature usage without capturing customer data
FS('trackEvent', {
  name: 'ai_feature_interaction',
  properties: {
    feature_name: 'smart_compose',
    interaction_type: 'suggestion_accepted',
    context: 'email_compose',
    suggestion_count: 3,
    accepted_index: 1,
    response_time_ms: 850,
    // NEVER: The actual suggestion text, user prompt, or generated content
  }
});

// Track AI feature adoption over time
FS('trackEvent', {
  name: 'ai_feature_first_use',
  properties: {
    feature_name: 'report_generator',
    days_since_signup: 14,
    user_role: 'analyst',
    trial_or_paid: 'trial',
    // Helps understand AI feature discovery patterns
  }
});
```

### AI Ethics Considerations

| Consideration | Guidance |
|---------------|----------|
| **Bias auditing** | Track AI feature usage across segments to identify disparities |
| **Transparency** | Log when AI made a decision vs user |
| **Opt-out tracking** | Track users who disable AI features |
| **Error rates** | Track AI failures without capturing the data that caused them |

---

## Page-Specific Implementations

### Onboarding Flow

```html
<!-- Onboarding - Critical to capture well -->
<div class="onboarding-flow">
  <!-- Progress indicator - visible -->
  <div class="onboarding-progress fs-unmask">
    <div class="step active">1. Welcome</div>
    <div class="step">2. Team</div>
    <div class="step">3. Integration</div>
    <div class="step">4. First Project</div>
  </div>
  
  <!-- Welcome step - visible -->
  <section class="step-content step-welcome fs-unmask">
    <h1>Welcome to ProductName!</h1>
    <p>Let's get you set up in just a few minutes.</p>
    
    <!-- Role selection - visible (product decision) -->
    <div class="role-selection">
      <h2>What best describes your role?</h2>
      <button data-role="engineer">Engineer</button>
      <button data-role="designer">Designer</button>
      <button data-role="pm">Product Manager</button>
      <button data-role="other">Other</button>
    </div>
  </section>
  
  <!-- Team invite step - mix -->
  <section class="step-content step-team">
    <h1 class="fs-unmask">Invite Your Team</h1>
    <p class="fs-unmask">ProductName works better with your team.</p>
    
    <!-- Email input - mask emails -->
    <div class="invite-form fs-mask">
      <input type="email" placeholder="teammate@company.com" />
      <button>Add</button>
    </div>
    
    <!-- Invited list - mask emails -->
    <div class="invited-list fs-mask">
      <div class="invite">
        <span class="email">john@company.com</span>
        <button>Remove</button>
      </div>
    </div>
    
    <!-- Actions - visible -->
    <div class="step-actions fs-unmask">
      <button>Skip for now</button>
      <button>Continue</button>
    </div>
  </section>
  
  <!-- Integration step - visible (shows what they connect) -->
  <section class="step-content step-integrations fs-unmask">
    <h1>Connect Your Tools</h1>
    <p>Connect the tools you already use.</p>
    
    <div class="integration-options">
      <button class="integration" data-integration="slack">
        <img src="slack-icon.svg" alt="" />
        Connect Slack
      </button>
      <button class="integration" data-integration="github">
        <img src="github-icon.svg" alt="" />
        Connect GitHub
      </button>
      <button class="integration" data-integration="jira">
        <img src="jira-icon.svg" alt="" />
        Connect Jira
      </button>
    </div>
  </section>
</div>
```

```javascript
// Comprehensive onboarding tracking
function trackOnboardingStep(step, data) {
  FS('trackEvent', {
    name: 'onboarding_step_completed',
    properties: {
      step_number: step,
      step_name: data.stepName,
      time_on_step_seconds: data.timeOnStep,
      // Step-specific data
      ...getStepSpecificData(step, data)
    }
  });
}

function getStepSpecificData(step, data) {
  switch(step) {
    case 'welcome':
      return { 
        selected_role: data.role,
        selected_use_case: data.useCase
      };
    case 'team':
      return {
        teammates_invited: data.inviteCount,
        skipped: data.skipped
      };
    case 'integrations':
      return {
        integrations_connected: data.connectedIntegrations,
        skipped: data.skipped
      };
    default:
      return {};
  }
}

// Track onboarding completion
FS('trackEvent', {
  name: 'onboarding_completed',
  properties: {
    total_time_minutes: totalOnboardingTime,
    steps_skipped: skippedSteps,
    teammates_invited: inviteCount,
    integrations_connected: connectedIntegrations,
    first_project_created: hasFirstProject
  }
});

// Track onboarding abandonment
window.addEventListener('beforeunload', () => {
  if (!onboardingCompleted && currentOnboardingStep) {
    FS('trackEvent', {
      name: 'onboarding_abandoned',
      properties: {
        abandoned_at_step: currentOnboardingStep,
        time_in_onboarding_minutes: getOnboardingTime(),
        steps_completed: completedSteps
      }
    });
  }
});
```

### Main Dashboard

```html
<!-- SaaS Dashboard -->
<div class="dashboard">
  <!-- Navigation - visible -->
  <nav class="main-nav fs-unmask">
    <a href="/dashboard">Dashboard</a>
    <a href="/projects">Projects</a>
    <a href="/analytics">Analytics</a>
    <a href="/team">Team</a>
    <a href="/settings">Settings</a>
  </nav>
  
  <!-- Dashboard header - mix -->
  <header class="dashboard-header">
    <h1 class="fs-unmask">Dashboard</h1>
    
    <!-- Workspace selector - mask customer data -->
    <div class="workspace-selector fs-mask">
      <button>Acme Corp ▼</button>
      <div class="workspace-menu">
        <a href="#">Acme Corp</a>
        <a href="#">Widgets Inc</a>
      </div>
    </div>
  </header>
  
  <!-- Metrics cards - depends on product -->
  <div class="metrics-grid fs-unmask">
    <!-- These are YOUR metrics about their usage - usually OK -->
    <div class="metric-card"
         data-fs-element="Metric Card"
         data-fs-properties-schema='{"metric_name":"string","metric_type":"string"}'>
      <h3>Active Users</h3>
      <span class="value">127</span>
      <span class="trend">+12%</span>
    </div>
    
    <div class="metric-card">
      <h3>Projects</h3>
      <span class="value">24</span>
    </div>
    
    <div class="metric-card">
      <h3>API Calls</h3>
      <span class="value">1.2M</span>
    </div>
  </div>
  
  <!-- Activity feed - may contain customer data -->
  <div class="activity-feed">
    <h2 class="fs-unmask">Recent Activity</h2>
    
    <!-- Activity items - mask names, possibly exclude details -->
    <div class="activity-list fs-mask">
      <!-- User names and content may need masking -->
      <div class="activity-item">
        <span class="user">Sarah J.</span>
        <span class="action">created a new project</span>
        <span class="target">"Q4 Marketing Campaign"</span>
        <span class="time">2 hours ago</span>
      </div>
    </div>
  </div>
  
  <!-- Quick actions - visible -->
  <div class="quick-actions fs-unmask">
    <button>New Project</button>
    <button>Invite Team</button>
    <button>View Reports</button>
  </div>
</div>
```

```javascript
// Dashboard page properties
FS('setProperties', {
  type: 'page',
  properties: {
    page_type: 'dashboard',
    
    // Usage metrics (your analytics about them)
    active_users_count: metrics.activeUsers,
    project_count: metrics.projects,
    
    // Feature usage indicators
    has_active_project: metrics.hasActiveProject,
    has_recent_activity: metrics.hasRecentActivity,
    
    // Dashboard customization
    widgets_visible: getVisibleWidgets(),
    date_range_selected: dateRange
  }
});
```

### Feature Usage Tracking (Core SaaS Value)

```html
<!-- Feature Page (e.g., Report Builder) -->
<div class="report-builder">
  <!-- Feature header - visible -->
  <header class="feature-header fs-unmask">
    <h1>Report Builder</h1>
    <div class="actions">
      <button>Save</button>
      <button>Export</button>
      <button>Share</button>
    </div>
  </header>
  
  <!-- Tool palette - visible (what tools they use) -->
  <aside class="tool-palette fs-unmask"
         data-fs-element="Tool Palette">
    <h2>Add Chart</h2>
    <button data-chart="bar">Bar Chart</button>
    <button data-chart="line">Line Chart</button>
    <button data-chart="pie">Pie Chart</button>
    <button data-chart="table">Table</button>
    <button data-chart="metric">Single Metric</button>
  </aside>
  
  <!-- Canvas - may contain customer data -->
  <main class="report-canvas">
    <!-- The actual data in the report may be customer's data -->
    <div class="chart-container fs-mask">
      <!-- Chart showing customer's data -->
    </div>
  </main>
  
  <!-- Configuration panel - mix -->
  <aside class="config-panel">
    <h2 class="fs-unmask">Chart Settings</h2>
    
    <!-- Data source selection - may reveal customer's data structure -->
    <div class="data-source fs-mask">
      <label>Data Source</label>
      <select>
        <option>Sales Pipeline</option>
        <option>Customer Database</option>
      </select>
    </div>
    
    <!-- Chart configuration - visible (product behavior) -->
    <div class="chart-config fs-unmask">
      <label>Chart Type</label>
      <select>
        <option>Bar</option>
        <option>Line</option>
      </select>
    </div>
  </aside>
</div>
```

```javascript
// Feature usage tracking
FS('setProperties', {
  type: 'page',
  properties: {
    page_type: 'report_builder',
    feature_name: 'report_builder',
    
    // Feature state
    report_id: report.id,
    is_new_report: report.isNew,
    chart_count: report.charts.length,
    
    // Feature engagement
    editing_mode: 'visual',  // or "code"
    has_unsaved_changes: report.isDirty
  }
});

// Track feature interactions
function onChartAdded(chartType) {
  FS('trackEvent', {
    name: 'feature_used',
    properties: {
      feature: 'report_builder',
      action: 'chart_added',
      chart_type: chartType,
      total_charts_after: report.charts.length
    }
  });
}

function onReportSaved(report) {
  FS('trackEvent', {
    name: 'feature_used',
    properties: {
      feature: 'report_builder',
      action: 'report_saved',
      chart_count: report.charts.length,
      is_first_report: user.reportCount === 1,
      time_to_create_minutes: report.creationTime
    }
  });
}

// Track feature discovery
function onFeatureFirstUse(featureName) {
  FS('trackEvent', {
    name: 'feature_first_use',
    properties: {
      feature_name: featureName,
      days_since_signup: user.daysSinceSignup,
      discovery_method: getDiscoveryMethod()  // "navigation", "search", "help"
    }
  });
}
```

### Settings and Configuration

```html
<!-- Settings Page -->
<div class="settings-page">
  <!-- Settings nav - visible -->
  <nav class="settings-nav fs-unmask">
    <a href="#profile">Profile</a>
    <a href="#organization">Organization</a>
    <a href="#billing">Billing</a>
    <a href="#integrations">Integrations</a>
    <a href="#security">Security</a>
    <a href="#api">API</a>
  </nav>
  
  <!-- Profile settings - mask PII -->
  <section id="profile" class="settings-section">
    <h2 class="fs-unmask">Profile Settings</h2>
    
    <div class="profile-form fs-mask">
      <div class="form-group">
        <label>Full Name</label>
        <input type="text" value="John Smith" />
      </div>
      <div class="form-group">
        <label>Email</label>
        <input type="email" value="john@acme.com" />
      </div>
      <div class="form-group">
        <label>Job Title</label>
        <input type="text" value="Product Manager" />
      </div>
    </div>
    
    <!-- Action button - visible -->
    <button class="fs-unmask">Save Changes</button>
  </section>
  
  <!-- Organization settings - mix -->
  <section id="organization" class="settings-section">
    <h2 class="fs-unmask">Organization Settings</h2>
    
    <div class="org-form">
      <div class="form-group fs-mask">
        <label>Organization Name</label>
        <input type="text" value="Acme Corporation" />
      </div>
      
      <!-- Plan info - visible (your product data) -->
      <div class="plan-info fs-unmask">
        <label>Current Plan</label>
        <span class="plan-badge">Professional</span>
        <a href="/upgrade">Upgrade</a>
      </div>
    </div>
  </section>
  
  <!-- API settings - EXCLUDE sensitive -->
  <section id="api" class="settings-section">
    <h2 class="fs-unmask">API Access</h2>
    
    <!-- API keys - EXCLUDE -->
    <div class="api-keys fs-exclude">
      <div class="key-row">
        <label>API Key</label>
        <code>sk_live_abc123xyz789...</code>
        <button>Regenerate</button>
      </div>
      <div class="key-row">
        <label>Webhook Secret</label>
        <code>whsec_...</code>
        <button>Regenerate</button>
      </div>
    </div>
    
    <!-- API usage stats - visible -->
    <div class="api-usage fs-unmask">
      <h3>API Usage</h3>
      <p>This month: 45,000 / 100,000 requests</p>
    </div>
  </section>
</div>
```

```javascript
// Settings page tracking
FS('setProperties', {
  type: 'page',
  properties: {
    page_type: 'settings',
    settings_section: currentSection  // "profile", "billing", "api"
  }
});

// Track settings changes
function onSettingsChanged(section, changes) {
  FS('trackEvent', {
    name: 'settings_changed',
    properties: {
      section: section,
      fields_changed: Object.keys(changes),
      // Don't include actual values (could be PII)
    }
  });
}
```

### Billing and Upgrade

```html
<!-- Upgrade / Pricing Page - Important for conversion -->
<div class="pricing-page">
  <!-- Pricing header - visible -->
  <header class="pricing-header fs-unmask">
    <h1>Choose Your Plan</h1>
    <p>Scale as you grow</p>
    
    <!-- Billing toggle - visible -->
    <div class="billing-toggle">
      <button class="active">Monthly</button>
      <button>Annual (Save 20%)</button>
    </div>
  </header>
  
  <!-- Plan cards - visible (your pricing) -->
  <div class="plan-cards fs-unmask"
       data-fs-element="Pricing Card"
       data-fs-properties-schema='{"plan_name":"string","plan_price":"real","billing_cycle":"string"}'>
    <div class="plan-card" data-plan="starter">
      <h2>Starter</h2>
      <p class="price">$29<span>/month</span></p>
      <ul class="features">
        <li>5 team members</li>
        <li>10 projects</li>
        <li>Basic analytics</li>
      </ul>
      <button>Choose Starter</button>
    </div>
    
    <div class="plan-card featured" data-plan="professional">
      <span class="badge">Most Popular</span>
      <h2>Professional</h2>
      <p class="price">$99<span>/month</span></p>
      <ul class="features">
        <li>Unlimited team members</li>
        <li>Unlimited projects</li>
        <li>Advanced analytics</li>
        <li>Priority support</li>
      </ul>
      <button>Choose Professional</button>
    </div>
    
    <div class="plan-card" data-plan="enterprise">
      <h2>Enterprise</h2>
      <p class="price">Custom</p>
      <ul class="features">
        <li>Everything in Professional</li>
        <li>SSO & SAML</li>
        <li>Dedicated support</li>
        <li>Custom contracts</li>
      </ul>
      <button>Contact Sales</button>
    </div>
  </div>
  
  <!-- FAQ - visible -->
  <div class="pricing-faq fs-unmask">
    <h2>Frequently Asked Questions</h2>
    <!-- FAQ items -->
  </div>
</div>
```

```javascript
// Pricing page tracking
FS('setProperties', {
  type: 'page',
  properties: {
    page_type: 'pricing',
    current_plan: organization.plan,
    is_trial: organization.isTrial,
    trial_days_remaining: organization.trialDaysRemaining,
    billing_cycle_viewed: selectedBillingCycle
  }
});

// Track plan interest
function onPlanHover(plan) {
  FS('trackEvent', {
    name: 'pricing_plan_interest',
    properties: {
      plan_name: plan,
      interaction_type: 'hover',
      current_plan: organization.plan
    }
  });
}

function onPlanSelected(plan) {
  FS('trackEvent', {
    name: 'pricing_plan_selected',
    properties: {
      plan_name: plan,
      billing_cycle: selectedBillingCycle,
      current_plan: organization.plan,
      is_upgrade: isPlanUpgrade(organization.plan, plan)
    }
  });
}

// Track upgrade completion
function onUpgradeComplete(upgrade) {
  FS('trackEvent', {
    name: 'subscription_upgraded',
    properties: {
      from_plan: upgrade.previousPlan,
      to_plan: upgrade.newPlan,
      billing_cycle: upgrade.billingCycle,
      mrr_change: upgrade.mrrChange,
      upgrade_trigger: upgrade.trigger  // "trial_end", "feature_limit", "self_serve"
    }
  });
}
```

### Collaboration Features

```html
<!-- Comments / Collaboration - Common in SaaS -->
<div class="collaboration-panel">
  <h3 class="fs-unmask">Comments</h3>
  
  <!-- Comment thread - mask user content -->
  <div class="comment-thread fs-mask">
    <div class="comment">
      <span class="author">Sarah J.</span>
      <span class="time">2h ago</span>
      <p class="content">Can we adjust the timeline for Q4?</p>
      
      <div class="replies">
        <div class="comment reply">
          <span class="author">Mike T.</span>
          <span class="time">1h ago</span>
          <p class="content">Sure, I'll update it now.</p>
        </div>
      </div>
    </div>
  </div>
  
  <!-- Comment input - mask -->
  <div class="comment-input fs-mask">
    <textarea placeholder="Add a comment..."></textarea>
    <button>Post</button>
  </div>
  
  <!-- Comment actions - visible -->
  <div class="comment-actions fs-unmask">
    <button>Resolve All</button>
    <button>Filter</button>
  </div>
</div>
```

```javascript
// Collaboration tracking
FS('trackEvent', {
  name: 'collaboration_action',
  properties: {
    action_type: 'comment_added',
    context: 'project',
    context_id: project.id,
    is_reply: isReply,
    mentions_count: mentionsCount
    // Never: comment content
  }
});
```

---

## Churn Prediction Signals

Track signals that may indicate churn risk:

```javascript
// User engagement signals
FS('setProperties', {
  type: 'user',
  properties: {
    // Activity metrics
    login_frequency: getLoginFrequency(),  // "daily", "weekly", "monthly", "rare"
    days_since_last_login: user.daysSinceLastLogin,
    
    // Feature engagement
    features_used_30d: user.featuresUsed30d.length,
    core_feature_usage: getCoreFeatureUsage(),  // "high", "medium", "low"
    
    // Team engagement
    team_size: organization.teamSize,
    active_team_members: organization.activeMembers,
    
    // Value realization
    projects_created: user.projectCount,
    reports_exported: user.exportCount,
    integrations_active: organization.activeIntegrations.length,
    
    // Support/friction
    support_tickets_30d: organization.ticketCount30d,
    errors_encountered_30d: user.errorCount30d
  }
});

// Track engagement drop signals
function trackEngagementDrop(signal) {
  FS('trackEvent', {
    name: 'engagement_signal',
    properties: {
      signal_type: signal.type,  // "login_frequency_drop", "feature_usage_drop"
      severity: signal.severity,  // "warning", "critical"
      days_since_baseline: signal.daysSince
    }
  });
}
```

---

## Enterprise Considerations

### For Enterprise Customers

```javascript
// Enterprise-specific tracking
if (organization.plan === 'enterprise') {
  FS('setProperties', {
    type: 'user',
    properties: {
      // Enterprise features
      sso_enabled: organization.ssoEnabled,
      scim_enabled: organization.scimEnabled,
      audit_log_enabled: organization.auditLogEnabled,
      
      // Compliance
      data_residency_region: organization.dataRegion,
      
      // Scale metrics
      seat_count: organization.seatCount,
      workspace_count: organization.workspaceCount
    }
  });
}
```

### Respecting Enterprise Privacy Requirements

Some enterprise customers may require special handling:

```javascript
// Check for customer-specific privacy requirements
function initializeFullstory(organization) {
  // Some enterprises may opt out of session replay
  if (organization.settings.disableSessionReplay) {
    // Don't initialize Fullstory at all
    return;
  }
  
  // Some may have stricter masking requirements
  if (organization.settings.strictPrivacyMode) {
    // Additional element exclusions
    document.body.classList.add('fs-mask');
  }
  
  // Initialize with org-specific settings
  FS('setIdentity', {
    uid: user.id,
    consent: organization.settings.analyticsConsent
  });
}
```

---

## Common SaaS Patterns

### Feature Adoption Tracking

```javascript
// Track feature discovery and adoption
const FEATURE_LIST = [
  'report_builder',
  'integrations',
  'team_collaboration',
  'api_access',
  'custom_dashboards',
  'automation'
];

function trackFeatureAdoption(user) {
  const adopted = FEATURE_LIST.filter(f => user.hasUsed(f));
  const notAdopted = FEATURE_LIST.filter(f => !user.hasUsed(f));
  
  FS('setProperties', {
    type: 'user',
    properties: {
      features_adopted_count: adopted.length,
      features_adopted: adopted.join(','),
      features_not_adopted: notAdopted.join(','),
      adoption_rate: adopted.length / FEATURE_LIST.length
    }
  });
}
```

### Organization Size Ranges

```javascript
function getOrgSizeRange(employeeCount) {
  if (employeeCount <= 10) return '1-10';
  if (employeeCount <= 50) return '11-50';
  if (employeeCount <= 200) return '51-200';
  if (employeeCount <= 1000) return '201-1000';
  return '1000+';
}
```

---

## KEY TAKEAWAYS FOR AGENT

When helping SaaS clients with Fullstory:

1. **Feature adoption is core**: Track which features users discover and use
2. **Onboarding is critical**: Comprehensive tracking of first-use experience
3. **Churn signals matter**: Track engagement patterns that predict churn
4. **Multi-tenant privacy**: Customer's customer data may need exclusion
5. **Enterprise requirements**: Be prepared for stricter privacy requirements
6. **API keys/credentials**: Always exclude

### Questions to Ask SaaS Clients

1. "What are your core activation metrics?"
2. "How do you define a 'healthy' user engagement pattern?"
3. "Does your product display your customer's customer data?"
4. "Do you have enterprise customers with special privacy requirements?"
5. "What features are most important to track for conversion?"

### Key Events to Track in SaaS

- Onboarding completion
- Feature first use
- Feature repeated use
- Upgrade/downgrade
- Team member invited
- Integration connected
- Export/share actions
- Settings changes
- Error encounters

---

## REFERENCE LINKS

- **Fullstory for Product Teams**: https://www.fullstory.com/product-analytics/
- **Element Properties**: ../core/fullstory-element-properties/SKILL.md
- **Analytics Events**: ../core/fullstory-analytics-events/SKILL.md
- **User Properties**: ../core/fullstory-user-properties/SKILL.md

---

*This skill document is specific to B2B SaaS implementations. Adjust based on your specific product's data sensitivity requirements.*

