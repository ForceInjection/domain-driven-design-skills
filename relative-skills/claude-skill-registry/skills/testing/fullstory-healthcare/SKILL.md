---
name: fullstory-healthcare
version: v2
description: Industry-specific guide for implementing Fullstory in healthcare applications while maintaining HIPAA compliance. Covers PHI protection, patient portal UX, telehealth flows, appointment scheduling, and EHR integrations. Emphasizes that most healthcare data requires exclusion, not just masking, with detailed examples for compliant implementations.
related_skills:
  - fullstory-privacy-controls
  - fullstory-privacy-strategy
  - fullstory-user-consent
  - fullstory-identify-users
  - fullstory-capture-control
---

# Fullstory for Healthcare

> ⚠️ **LEGAL DISCLAIMER**: This guidance is for educational purposes only and does not constitute legal, compliance, or regulatory advice. Healthcare regulations (HIPAA, HITECH, state privacy laws) are complex, jurisdiction-specific, and subject to change. Always consult with your legal, compliance, privacy officer, and security teams before implementing any data capture solution. Your organization is responsible for ensuring compliance with all applicable regulations.

## Industry Overview

Healthcare has the most stringent requirements for session analytics due to:

- **HIPAA compliance**: Protected Health Information (PHI) requires strict handling
- **Patient trust**: Breach of medical data is particularly harmful
- **Regulated entities**: Covered entities and business associates have legal obligations
- **BAA requirement**: Business Associate Agreement required with Fullstory

### Critical Understanding

> **In healthcare, the default should be EXCLUDE, not mask or unmask.**
> 
> Even seemingly innocuous data can become PHI when combined with other information. Err on the side of caution.

### Highly Recommended: Private by Default Mode

For healthcare applications, **Fullstory's Private by Default mode is essential**:

```
┌─────────────────────────────────────────────────────────────────┐
│  HEALTHCARE: Enable Private by Default                           │
│                                                                 │
│  • All text masked by default - no accidental PHI capture       │
│  • Selectively unmask ONLY navigation and generic UI            │
│  • Combined with fs-exclude for regulated areas                 │
│  • Contact Fullstory Support to enable                          │
└─────────────────────────────────────────────────────────────────┘
```

> **Reference**: [Fullstory Private by Default](https://help.fullstory.com/hc/en-us/articles/360044349073-Fullstory-Private-by-Default)

### Key Goals for Healthcare Implementations

1. **Improve patient portal UX** without capturing PHI
2. **Optimize appointment scheduling** flows
3. **Reduce friction** in telehealth experiences
4. **Understand navigation patterns** for health content
5. **Never compromise** patient privacy

---

## HIPAA Framework

### What Constitutes PHI?

PHI (Protected Health Information) includes any health information that can be linked to an individual:

| PHI Category | Examples | Fullstory Handling |
|--------------|----------|-------------------|
| **Names** | Patient, provider, family | fs-exclude (not mask!) |
| **Geographic data** | Address, city, ZIP | fs-exclude |
| **Dates** | DOB, admission, discharge, appointment | fs-exclude |
| **Contact info** | Phone, fax, email | fs-exclude |
| **Identifiers** | SSN, MRN, insurance ID | fs-exclude |
| **Health conditions** | Diagnoses, symptoms | fs-exclude |
| **Treatments** | Medications, procedures | fs-exclude |
| **Providers** | Doctor names, specialties | fs-exclude |
| **Test results** | Lab values, imaging | fs-exclude |
| **Images** | Photos, scans, ID documents | fs-exclude |
| **Biometrics** | Height, weight, vitals | fs-exclude |
| **Insurance** | Plan, member ID, claims | fs-exclude |

### HIPAA De-Identification Standards

HIPAA provides two methods for de-identification. Understanding these helps clarify what Fullstory can/cannot capture:

| Method | Approach | Fullstory Implication |
|--------|----------|----------------------|
| **Safe Harbor** | Remove 18 specific identifiers | Cannot rely on this—FS captures too much visual data |
| **Expert Determination** | Statistical/scientific analysis | Requires formal expert certification; impractical for session replay |

**Key Point**: Neither de-identification method is practical for session replay. This is why **exclusion (not just masking)** is required for healthcare.

```
The 18 Safe Harbor Identifiers (all require EXCLUSION):
├── Names
├── Geographic data (smaller than state)
├── Dates (except year) - birth, admission, discharge, death
├── Phone numbers
├── Fax numbers
├── Email addresses
├── Social Security numbers
├── Medical record numbers
├── Health plan beneficiary numbers
├── Account numbers
├── Certificate/license numbers
├── Vehicle identifiers
├── Device identifiers
├── Web URLs
├── IP addresses
├── Biometric identifiers
├── Full-face photographs
└── Any other unique identifying characteristic
```

### HIPAA Minimum Necessary Standard

Only capture what is absolutely necessary for UX analysis:

```
┌─────────────────────────────────────────────────────────────────┐
│  WHAT YOU CAN CAPTURE (Limited)                                  │
├─────────────────────────────────────────────────────────────────┤
│  ✓ Navigation patterns (which pages visited)                     │
│  ✓ Error occurrences (not error details)                         │
│  ✓ Form completion rates (not form contents)                     │
│  ✓ Button clicks (which buttons, not data submitted)             │
│  ✓ Page load times                                              │
│  ✓ Device/browser information                                   │
│  ✓ Session duration (generic)                                   │
├─────────────────────────────────────────────────────────────────┤
│  WHAT YOU CANNOT CAPTURE                                         │
├─────────────────────────────────────────────────────────────────┤
│  ✗ Any patient information                                       │
│  ✗ Any provider information                                      │
│  ✗ Any health/medical content                                   │
│  ✗ Appointment details                                          │
│  ✗ Insurance information                                         │
│  ✗ Messages between patient and provider                         │
│  ✗ Test results, diagnoses, medications                          │
│  ✗ Images of any kind (could show PHI)                          │
└─────────────────────────────────────────────────────────────────┘
```

---

## Implementation Architecture

### Privacy Zones for Healthcare

```
┌─────────────────────────────────────────────────────────────────┐
│                    HEALTHCARE APPLICATION                        │
├─────────────────────────────────────────────────────────────────┤
│  LIMITED VISIBLE (fs-unmask) - Be very careful                   │
│  • Main navigation menu                                          │
│  • Generic page titles ("My Appointments" not appointment list)  │
│  • Action buttons (text only, not data)                         │
│  • Generic UI elements                                          │
│  • Public health information pages                               │
├─────────────────────────────────────────────────────────────────┤
│  NEVER USE MASK IN HEALTHCARE                                    │
│  • Masking is NOT sufficient for HIPAA                           │
│  • Even masked text structure could reveal PHI                   │
│  • Example: Masked 3-word name = still identifiable              │
├─────────────────────────────────────────────────────────────────┤
│  MUST EXCLUDE (fs-exclude) - Default for healthcare              │
│  • ALL patient information                                       │
│  • ALL provider information                                      │
│  • ALL appointment details                                       │
│  • ALL medical content                                          │
│  • ALL messaging                                                 │
│  • ALL forms with health data                                    │
│  • ALL test results                                             │
│  • ALL images                                                    │
│  • ALL search queries (could contain symptoms)                   │
└─────────────────────────────────────────────────────────────────┘
```

### Recommended Approach: Default Exclude

```javascript
// Healthcare: Consider using Private by Default mode
// Then selectively unmask ONLY navigation elements

// If not using Private by Default, add fs-exclude to almost everything
```

### User Identification Pattern

```javascript
// Healthcare: Use session-only identification
// DO NOT link sessions to patient identity

// Option 1: Don't identify at all (safest)
// Just use anonymous Fullstory sessions

// Option 2: Session-only identifier
FS('setIdentity', {
  uid: generateSessionId()  // Random per session, no linking
});

// Option 3: Hashed, non-reversible ID (consult legal first)
// Only if you have explicit patient consent
FS('setIdentity', {
  uid: sha256(patient.mrn + salt)  // Irreversible hash
});

// MINIMAL properties - no PHI
FS('setProperties', {
  type: 'user',
  properties: {
    // Only non-PHI operational data
    portal_type: 'patient',  // or "provider", "admin"
    access_method: 'direct',  // or "sso", "mobile_app"
    
    // NOTHING about the patient:
    // No demographics, no conditions, no providers, no appointments
  }
});
```

---

## Page-Specific Implementations

### Public Health Information Pages

```html
<!-- Public Health Content - Can be mostly visible -->
<div class="health-info-page">
  <!-- Navigation - visible -->
  <nav class="main-nav fs-unmask">
    <a href="/">Home</a>
    <a href="/conditions">Health Conditions</a>
    <a href="/services">Our Services</a>
    <a href="/portal">Patient Portal</a>
  </nav>
  
  <!-- Generic content about conditions - visible (it's public info) -->
  <article class="health-article fs-unmask">
    <h1>Understanding Diabetes</h1>
    <p>Diabetes is a chronic condition that affects how your body...</p>
    <!-- Public health education content -->
  </article>
  
  <!-- Search - EXCLUDE (queries could contain symptoms) -->
  <div class="search-box fs-exclude">
    <input type="text" placeholder="Search symptoms or conditions" />
    <button>Search</button>
  </div>
  
  <!-- Call-to-actions - visible -->
  <div class="ctas fs-unmask">
    <a href="/portal/login">Access Patient Portal</a>
    <a href="/appointments">Schedule Appointment</a>
  </div>
</div>
```

### Patient Portal Login

```html
<!-- Patient Portal Login -->
<div class="portal-login">
  <!-- Logo and title - visible -->
  <header class="fs-unmask">
    <img src="hospital-logo.svg" alt="Hospital Name" />
    <h1>Patient Portal</h1>
  </header>
  
  <!-- Login form - EXCLUDE everything -->
  <form class="login-form fs-exclude">
    <!-- Username could be MRN, email, or name -->
    <div class="form-group">
      <label>Username or Medical Record Number</label>
      <input type="text" name="username" />
    </div>
    
    <!-- Password -->
    <div class="form-group">
      <label>Password</label>
      <input type="password" name="password" />
    </div>
    
    <!-- Date of birth (verification) -->
    <div class="form-group">
      <label>Date of Birth</label>
      <input type="date" name="dob" />
    </div>
  </form>
  
  <!-- Action buttons - visible for funnel -->
  <div class="form-actions fs-unmask">
    <button type="submit">Sign In</button>
    <a href="/forgot-password">Forgot Password?</a>
    <a href="/register">New Patient? Register Here</a>
  </div>
</div>
```

```javascript
// Login tracking - NO PHI
FS('trackEvent', {
  name: 'portal_login_attempted',
  properties: {
    portal_type: 'patient',
    login_method: 'username'  // or "sso", "biometric"
    // NEVER: username, MRN, DOB
  }
});

FS('trackEvent', {
  name: 'portal_login_result',
  properties: {
    success: true,
    mfa_required: true
    // NEVER: failure reason (could reveal patient exists)
  }
});
```

### Patient Dashboard

```html
<!-- Patient Dashboard - Almost all excluded -->
<div class="patient-dashboard">
  <!-- Main nav - visible (generic labels only) -->
  <nav class="dashboard-nav fs-unmask">
    <a href="/portal/appointments">My Appointments</a>
    <a href="/portal/messages">Messages</a>
    <a href="/portal/records">Health Records</a>
    <a href="/portal/medications">Medications</a>
    <a href="/portal/billing">Billing</a>
  </nav>
  
  <!-- Welcome banner - EXCLUDE (contains name) -->
  <div class="welcome-banner fs-exclude">
    <h1>Welcome, John Smith</h1>
    <p>Last login: December 1, 2024</p>
  </div>
  
  <!-- Upcoming appointments - EXCLUDE entirely -->
  <section class="appointments-summary fs-exclude">
    <h2>Upcoming Appointments</h2>
    <!-- Contains: dates, provider names, appointment types = ALL PHI -->
    <div class="appointment-card">
      <p class="date">Dec 15, 2024 at 2:00 PM</p>
      <p class="provider">Dr. Sarah Johnson</p>
      <p class="type">Annual Physical</p>
      <p class="location">Main Campus, Room 302</p>
    </div>
  </section>
  
  <!-- Recent messages - EXCLUDE entirely -->
  <section class="messages-summary fs-exclude">
    <h2>Messages</h2>
    <!-- Contains provider names, message subjects = PHI -->
    <div class="message-preview">
      <p class="from">From: Dr. Johnson</p>
      <p class="subject">Re: Test Results</p>
    </div>
  </section>
  
  <!-- Medications - EXCLUDE entirely -->
  <section class="medications-summary fs-exclude">
    <h2>Current Medications</h2>
    <!-- Medications are PHI -->
    <ul>
      <li>Metformin 500mg - 2x daily</li>
      <li>Lisinopril 10mg - 1x daily</li>
    </ul>
  </section>
  
  <!-- Quick actions - visible (just buttons) -->
  <div class="quick-actions fs-unmask">
    <button>Request Appointment</button>
    <button>Message Provider</button>
    <button>Request Refill</button>
    <button>Pay Bill</button>
  </div>
</div>
```

```javascript
// Dashboard tracking - generic only
FS('setProperties', {
  type: 'page',
  properties: {
    page_type: 'patient_dashboard',
    // Only counts, no details
    has_upcoming_appointments: true,  // Boolean only
    has_unread_messages: true,
    // NEVER: appointment count, message count, medication count
    // (could indicate health status)
  }
});
```

### Appointment Scheduling

```html
<!-- Appointment Scheduling - Highly sensitive -->
<div class="appointment-scheduling">
  <h1 class="fs-unmask">Schedule an Appointment</h1>
  
  <!-- Progress steps - visible -->
  <div class="progress-steps fs-unmask">
    <span class="active">1. Service</span>
    <span>2. Provider</span>
    <span>3. Time</span>
    <span>4. Confirm</span>
  </div>
  
  <!-- Service selection - EXCLUDE (reveals health need) -->
  <section class="service-selection fs-exclude">
    <h2>Select Service Type</h2>
    <!-- Service types reveal why patient needs care = PHI context -->
    <div class="services">
      <button>Annual Physical</button>
      <button>Sick Visit</button>
      <button>Mental Health</button>  <!-- Especially sensitive -->
      <button>Follow-up</button>
      <button>Specialist Referral</button>
    </div>
  </section>
  
  <!-- Provider selection - EXCLUDE -->
  <section class="provider-selection fs-exclude">
    <h2>Select Provider</h2>
    <!-- Provider + patient = linkable PHI -->
    <div class="providers">
      <div class="provider-card">
        <img src="provider-photo.jpg" alt="" />
        <h3>Dr. Sarah Johnson, MD</h3>
        <p>Internal Medicine</p>
        <p>Accepting new patients</p>
      </div>
    </div>
  </section>
  
  <!-- Time selection - EXCLUDE -->
  <section class="time-selection fs-exclude">
    <h2>Select Date and Time</h2>
    <div class="calendar">
      <!-- Calendar showing available slots -->
    </div>
    <div class="time-slots">
      <button>9:00 AM</button>
      <button>10:30 AM</button>
      <button>2:00 PM</button>
    </div>
  </section>
  
  <!-- Reason for visit - ABSOLUTELY EXCLUDE -->
  <section class="visit-reason fs-exclude">
    <h2>Reason for Visit</h2>
    <textarea 
      name="reason" 
      placeholder="Please describe your symptoms or reason for visit"
    ></textarea>
  </section>
  
  <!-- Action buttons - visible -->
  <div class="form-actions fs-unmask">
    <button>Back</button>
    <button>Continue</button>
  </div>
</div>
```

```javascript
// Appointment scheduling - track funnel, not details
function trackSchedulingStep(step) {
  FS('trackEvent', {
    name: 'appointment_scheduling_step',
    properties: {
      step_number: step,
      step_name: getStepName(step),  // "service", "provider", "time", "confirm"
      // NEVER: service type, provider name, appointment time
    }
  });
}

FS('trackEvent', {
  name: 'appointment_scheduled',
  properties: {
    scheduling_method: 'online',  // or "phone", "in_person"
    steps_completed: 4,
    // NEVER: appointment details
  }
});
```

### Telehealth / Virtual Visit

```html
<!-- Telehealth Waiting Room -->
<div class="telehealth-waiting">
  <!-- Status - visible (generic) -->
  <div class="wait-status fs-unmask">
    <h1>Virtual Visit Waiting Room</h1>
    <p>Your provider will be with you shortly.</p>
  </div>
  
  <!-- Device check - visible -->
  <div class="device-check fs-unmask">
    <h2>Check Your Setup</h2>
    <div class="check-item">
      <span class="status">✓</span>
      <span>Camera</span>
    </div>
    <div class="check-item">
      <span class="status">✓</span>
      <span>Microphone</span>
    </div>
    <div class="check-item">
      <span class="status">✓</span>
      <span>Speaker</span>
    </div>
  </div>
  
  <!-- Appointment info - EXCLUDE -->
  <div class="appointment-info fs-exclude">
    <!-- Contains provider name, visit type = PHI -->
    <p>Appointment with Dr. Johnson</p>
    <p>Mental Health Follow-up</p>
  </div>
  
  <!-- Actions - visible -->
  <div class="actions fs-unmask">
    <button>Test Audio</button>
    <button>Test Video</button>
    <button>Cancel Visit</button>
  </div>
</div>

<!-- Telehealth Video Session - EXCLUDE ENTIRELY -->
<div class="telehealth-session fs-exclude">
  <!-- NEVER capture video sessions
       - Contains patient image/video
       - Contains provider image/video  
       - Contains medical discussion
       - Contains screen sharing of records
  -->
  <div class="video-container">
    <video id="provider-video"></video>
    <video id="patient-video"></video>
  </div>
  
  <div class="session-controls">
    <button>Mute</button>
    <button>Camera Off</button>
    <button>Share Screen</button>
    <button>End Visit</button>
  </div>
  
  <div class="chat-panel">
    <!-- Chat during visit = PHI -->
  </div>
</div>
```

```javascript
// Telehealth tracking - technical only
FS('trackEvent', {
  name: 'telehealth_session_started',
  properties: {
    connection_type: 'video',  // or "audio_only"
    device_type: getDeviceType(),
    browser: getBrowserName(),
    // Technical quality metrics
    initial_video_quality: 'hd',
    // NEVER: provider name, visit type, session content
  }
});

// Technical issues only
FS('trackEvent', {
  name: 'telehealth_technical_issue',
  properties: {
    issue_type: 'connection_lost',  // or "audio_failed", "video_failed"
    duration_before_issue_seconds: 120,
    // NEVER: what was being discussed
  }
});
```

### Health Records / Test Results

```html
<!-- Health Records - EXCLUDE ENTIRELY -->
<div class="health-records">
  <h1 class="fs-unmask">Health Records</h1>
  
  <!-- Navigation tabs - visible (generic labels) -->
  <nav class="records-nav fs-unmask">
    <a href="#results">Test Results</a>
    <a href="#visits">Visit Summaries</a>
    <a href="#immunizations">Immunizations</a>
    <a href="#allergies">Allergies</a>
  </nav>
  
  <!-- ALL record content - EXCLUDE -->
  <div class="records-content fs-exclude">
    <!-- Test results = PHI -->
    <section id="results">
      <h2>Recent Test Results</h2>
      <div class="result">
        <h3>Complete Blood Count</h3>
        <p>Date: Nov 15, 2024</p>
        <p>Ordered by: Dr. Johnson</p>
        <table class="lab-values">
          <tr><td>WBC</td><td>7.5</td><td>Normal</td></tr>
          <tr><td>RBC</td><td>4.8</td><td>Normal</td></tr>
          <tr><td>Hemoglobin</td><td>14.2</td><td>Normal</td></tr>
        </table>
      </div>
    </section>
    
    <!-- Visit summaries = PHI -->
    <section id="visits">
      <h2>Visit Summaries</h2>
      <div class="visit">
        <p>Nov 10, 2024 - Dr. Johnson</p>
        <p>Diagnosis: Type 2 Diabetes</p>
        <p>Treatment Plan: Diet modification, Metformin 500mg</p>
      </div>
    </section>
    
    <!-- Immunizations = PHI -->
    <section id="immunizations">
      <h2>Immunization Record</h2>
      <ul>
        <li>COVID-19 Booster - Oct 2024</li>
        <li>Flu Shot - Sep 2024</li>
      </ul>
    </section>
    
    <!-- Allergies = PHI -->
    <section id="allergies">
      <h2>Allergies</h2>
      <ul>
        <li>Penicillin - Severe</li>
        <li>Shellfish - Moderate</li>
      </ul>
    </section>
  </div>
</div>
```

### Patient Messaging

```html
<!-- Patient-Provider Messaging - EXCLUDE ENTIRELY -->
<div class="messaging">
  <h1 class="fs-unmask">Messages</h1>
  
  <!-- Message list - EXCLUDE -->
  <div class="message-list fs-exclude">
    <!-- Message metadata and content = PHI -->
    <div class="message-thread">
      <div class="thread-header">
        <span class="from">Dr. Sarah Johnson</span>
        <span class="subject">Re: Blood Test Results</span>
        <span class="date">Dec 1, 2024</span>
      </div>
      <div class="thread-preview">
        Your recent blood work shows...
      </div>
    </div>
  </div>
  
  <!-- Compose message - EXCLUDE -->
  <div class="compose-message fs-exclude">
    <select name="recipient">
      <option>Dr. Johnson</option>
      <option>Nurse Williams</option>
    </select>
    <input type="text" name="subject" placeholder="Subject" />
    <textarea name="body" placeholder="Type your message"></textarea>
    <button type="submit">Send</button>
  </div>
  
  <!-- Action buttons - visible -->
  <div class="message-actions fs-unmask">
    <button>New Message</button>
    <button>Mark All Read</button>
  </div>
</div>
```

### Billing (Healthcare-Specific)

```html
<!-- Healthcare Billing - Contains PHI -->
<div class="billing-page">
  <h1 class="fs-unmask">Billing</h1>
  
  <!-- Balance overview - EXCLUDE (tied to services received) -->
  <div class="balance-overview fs-exclude">
    <p>Current Balance: $250.00</p>
    <p>Insurance Pending: $500.00</p>
  </div>
  
  <!-- Statement list - EXCLUDE (shows services = PHI) -->
  <div class="statements fs-exclude">
    <div class="statement">
      <p>Nov 15, 2024</p>
      <p>Service: Laboratory Services</p>  <!-- Reveals health data -->
      <p>Provider: Dr. Johnson</p>
      <p>Amount: $150.00</p>
      <p>Insurance: Pending</p>
    </div>
  </div>
  
  <!-- Payment form - mix of concerns -->
  <div class="payment-form">
    <h2 class="fs-unmask">Make a Payment</h2>
    
    <!-- Amount - could reveal service cost = PHI context -->
    <div class="amount-field fs-exclude">
      <label>Payment Amount</label>
      <input type="number" name="amount" />
    </div>
    
    <!-- Card details - EXCLUDE (PCI + general privacy) -->
    <div class="card-details fs-exclude">
      <input type="text" name="cardNumber" />
      <input type="text" name="expiry" />
      <input type="text" name="cvv" />
    </div>
    
    <!-- Submit - visible -->
    <button class="fs-unmask" type="submit">Pay Now</button>
  </div>
</div>
```

---

## What About Provider-Side Applications?

For EHR systems and provider-facing applications:

```javascript
// Provider applications should use VERY limited Fullstory
// Consider: Do you even need session replay?

// If you do use Fullstory on provider side:
// 1. Never capture patient data displayed on screen
// 2. Only track navigation and technical issues
// 3. Consider using it only for non-patient screens (admin, scheduling UI)

FS('setProperties', {
  type: 'page',
  properties: {
    page_type: 'ehr_dashboard',
    // Only track application name, not patient context
    ehr_module: 'scheduling',  // or "charting", "orders"
    // NEVER: patient MRN, patient name, visit type
  }
});
```

---

## Consent Considerations in Healthcare

```javascript
// Healthcare consent is complex - consult your compliance team

// Option 1: Don't use Fullstory on authenticated patient pages
// Safest option - use only on public pages

// Option 2: Get explicit consent
function initializeFullstoryWithConsent() {
  // Check if patient has consented to analytics
  if (patient.hasConsentedToAnalytics) {
    FS('setIdentity', {
      uid: sha256(patient.id),
      consent: true
    });
  } else {
    // Don't capture this session
    FS('shutdown');
  }
}

// Option 3: Capture no identifying data at all
// Anonymous sessions only, no linking
```

---

## BAA and Compliance Checklist

### Before Going Live

- [ ] **BAA signed** with Fullstory
- [ ] **Privacy by Default** mode enabled
- [ ] **All PHI screens excluded**
- [ ] **No patient identifiers** in user properties
- [ ] **No health data** in events
- [ ] **Images excluded** (could contain PHI)
- [ ] **Search excluded** (queries could contain symptoms)
- [ ] **Messages excluded** entirely
- [ ] **Test results excluded** entirely
- [ ] **Appointment details excluded**
- [ ] **Provider names excluded** (when with patient context)
- [ ] **Billing details excluded** (reveal services received)
- [ ] **Legal/compliance review** completed
- [ ] **Security team review** completed

---

## KEY TAKEAWAYS FOR AGENT

When helping healthcare clients with Fullstory:

1. **Default to exclusion**: In healthcare, fs-exclude is the default, not fs-unmask
2. **Masking is NOT sufficient**: Even masked text can reveal PHI through structure
3. **Everything is potentially PHI**: When in doubt, exclude it
4. **BAA is required**: Don't implement until legal has BAA in place
5. **Consider anonymous sessions**: May not need user identification at all
6. **Public vs. authenticated**: Very different rules apply
7. **Provider applications**: May not be appropriate for Fullstory at all

### What You CAN Track (Limited)

- Page navigation (not what's on the page)
- Button clicks (not the data submitted)
- Form completion rates (not form content)
- Error occurrence (not error details)
- Technical issues (connection, loading)
- Generic UI interactions

### What You CANNOT Track

- Any patient information
- Any health condition information
- Any provider information (in patient context)
- Appointment details
- Test results
- Messages
- Medications
- Insurance information
- Billing details
- Images of any kind

### Questions to Ask Healthcare Clients

1. "Do you have a BAA with Fullstory?"
2. "Is Fullstory in your HIPAA security assessment?"
3. "Are you using Private by Default mode?"
4. "Have you audited session replays for PHI exposure?"
5. "Is your implementation scoped to only non-PHI screens?"

### Red Flags

- Using fs-mask instead of fs-exclude for PHI
- Tracking appointment types or services
- Including provider names in events
- Capturing search queries
- Not having a BAA in place
- Using Fullstory on EHR screens

---

## REFERENCE LINKS

- **HIPAA Overview**: https://www.hhs.gov/hipaa/
- **Fullstory HIPAA Compliance**: https://www.fullstory.com/legal/hipaa/
- **Privacy Controls**: ../core/fullstory-privacy-controls/SKILL.md
- **Privacy Strategy**: ../meta/fullstory-privacy-strategy/SKILL.md
- **User Consent**: ../core/fullstory-user-consent/SKILL.md

---

*This skill document is specific to healthcare implementations. Always consult your HIPAA compliance officer and legal counsel before implementing Fullstory in a healthcare context. This guide does not constitute legal advice.*

