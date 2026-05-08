---
name: Temporal Workflow Guidelines
description: |
  Comprehensive guide for developing Temporal.io workflows and activities in the A4C-AppSuite.
  Covers Workflow-First architecture, deterministic workflow design, event-driven activities,
  saga compensation patterns, CQRS integration, and testing strategies for durable workflow
  orchestration in healthcare compliance contexts (HIPAA audit trails).
version: 1.0.0
category: temporal
tags: [temporal, workflows, activities, event-driven, saga, cqrs, orchestration]
---

# Temporal Workflow Guidelines

This skill provides comprehensive guidance for developing Temporal.io workflows and activities following the **Workflow-First** architecture pattern used in A4C-AppSuite.

## Quick Start

### Creating a New Workflow

- [ ] Create workflow file: `temporal/src/workflows/{category}/{name}-workflow.ts`
- [ ] Define `*Params` and `*Result` interfaces
- [ ] Import and proxy activities with retry policies
- [ ] Implement deterministic orchestration logic
- [ ] Add saga compensation for rollback
- [ ] Export workflow function
- [ ] Create tests: `temporal/src/workflows/{category}/__tests__/{name}-workflow.test.ts`
- [ ] Register in worker: `temporal/src/workers/index.ts`

### Creating a New Activity

- [ ] Create activity file: `temporal/src/activities/{category}/{name}.ts`
- [ ] Define `*Params` interface and return type
- [ ] Perform side effect (API call, database operation)
- [ ] Emit domain event to `domain_events` table
- [ ] Return result
- [ ] Create tests: `temporal/src/activities/{category}/__tests__/{name}.test.ts`
- [ ] Export from category index
- [ ] Use in workflows via `proxyActivities`

## Common Imports

```typescript
// Workflows
import { proxyActivities, sleep, uuid4, patched } from '@temporalio/workflow'
import type * as activities from '../../activities/organization'

// Activities
import { Context } from '@temporalio/activity'
import { ApplicationFailure } from '@temporalio/common'
import { createClient } from '@supabase/supabase-js'

// Testing
import { TestWorkflowEnvironment } from '@temporalio/testing'
import { Worker } from '@temporalio/worker'
```

## Topics Overview

### Workflow Patterns
Learn deterministic workflow design, versioning with `patched()`, saga compensation, and durable state management. Workflows orchestrate processes without side effects.

📖 **[resources/workflow-patterns.md](resources/workflow-patterns.md)**

### Activity Best Practices
Master idempotent activity design, retry policies, error handling, and timeout configuration. Activities perform all side effects and integrate with external systems.

📖 **[resources/activity-best-practices.md](resources/activity-best-practices.md)**

### Event Emission
Understand domain event patterns, CQRS integration, event schema design, and PostgreSQL event store usage. Every state change becomes an immutable audit trail.

📖 **[resources/event-emission.md](resources/event-emission.md)**

### Testing Workflows
Explore workflow replay testing, activity mocking, local development setup, and integration testing strategies against the dev Temporal cluster.

📖 **[resources/testing-workflows.md](resources/testing-workflows.md)**

## Navigation Table

| Resource | Focus | Key Concepts |
|----------|-------|--------------|
| [workflow-patterns.md](resources/workflow-patterns.md) | Workflow design | Determinism, versioning, saga, child workflows |
| [activity-best-practices.md](resources/activity-best-practices.md) | Activity implementation | Idempotency, retries, timeouts, error handling |
| [event-emission.md](resources/event-emission.md) | Event-driven architecture | Domain events, CQRS, audit trails, metadata |
| [testing-workflows.md](resources/testing-workflows.md) | Testing strategies | Replay tests, mocks, local setup, debugging |

---

## Core Principles

### 1. Workflow-First Architecture

**Workflows orchestrate, activities execute.**

Workflows define the **what** and **when** of business processes. Activities handle the **how** (side effects).

```typescript
// Workflow orchestrates steps
export async function BootstrapOrganization(params: BootstrapParams) {
  // Step 1: Create organization
  const orgId = await createOrganizationActivity(params)

  // Step 2: Configure DNS
  await configureDNSActivity({ orgId, subdomain: params.subdomain })

  // Step 3: Send invitations
  await sendInvitationsActivity({ orgId, emails: params.invitations })

  return { orgId, subdomain: params.subdomain }
}
```

### 2. Determinism is Non-Negotiable

Workflows must be **deterministic** - same input always produces same execution history.

**Use Temporal APIs for workflow operations:**
```typescript
import { uuid4, sleep } from '@temporalio/workflow'

// ✅ Correct - deterministic
const workflowId = uuid4()
await sleep('5 minutes')

// ❌ Wrong - non-deterministic
const workflowId = Math.random().toString()  // Different each replay!
await new Promise(resolve => setTimeout(resolve, 300000))  // Breaks replay!
```

**No side effects in workflows:**
```typescript
// ❌ Wrong - side effects in workflow
export async function BadWorkflow(params) {
  const response = await fetch('https://api.example.com')  // NO!
  await supabase.from('orgs').insert({ name: params.name })  // NO!
  console.log('Started at', new Date())  // Different on replay!
}

// ✅ Correct - side effects in activities
export async function GoodWorkflow(params) {
  const result = await fetchDataActivity()  // YES!
  await createOrgActivity({ name: params.name })  // YES!
}
```

### 3. Event-Driven Activities

**Every activity that changes state MUST emit a domain event.**

This creates an immutable audit trail for HIPAA compliance and enables CQRS projections.

```typescript
export async function createOrganizationActivity(params: CreateOrgParams) {
  // 1. Perform side effect
  const { data: org, error } = await supabase
    .from('organizations')
    .insert({ name: params.name, subdomain: params.subdomain })
    .select()
    .single()

  if (error) throw new Error(`Failed to create org: ${error.message}`)

  // 2. Emit domain event
  const workflowInfo = Context.current().info
  await supabase.from('domain_events').insert({
    event_type: 'OrganizationCreated',
    aggregate_type: 'Organization',
    aggregate_id: org.id,
    event_data: { name: org.name, subdomain: org.subdomain },
    metadata: {
      workflow_id: workflowInfo.workflowId,
      workflow_run_id: workflowInfo.runId,
      workflow_type: workflowInfo.workflowType
    }
  })

  // 3. Return result
  return org.id
}
```

### 4. Saga Compensation Pattern

Workflows must handle partial failures by rolling back completed steps in reverse order.

```typescript
export async function ProvisionTenantWorkflow(params: ProvisionParams) {
  let orgId: string | undefined
  let dnsConfigured = false

  try {
    // Step 1
    orgId = await createOrganizationActivity(params)

    // Step 2
    await configureDNSActivity({ orgId, subdomain: params.subdomain })
    dnsConfigured = true

    // Step 3
    await provisionDatabaseActivity({ orgId })

    return { orgId, success: true }

  } catch (error) {
    // Compensation: rollback in reverse order
    if (dnsConfigured && orgId) {
      await deleteDNSRecordActivity({ subdomain: params.subdomain })
    }
    if (orgId) {
      await deleteOrganizationActivity({ orgId })
    }
    throw error
  }
}
```

### 5. CQRS with Event Sourcing

Events are the source of truth. Projections (read models) are derived from the event stream.

**Flow:**
1. Activity performs action → Emits event to `domain_events`
2. PostgreSQL trigger processes event → Updates projection table
3. Frontend queries projection → Gets denormalized read model

```typescript
// Activity emits event
await supabase.from('domain_events').insert({
  event_type: 'UserInvitationSent',
  aggregate_type: 'Invitation',
  aggregate_id: invitation.id,
  event_data: { email: invitation.email, role: invitation.role }
})

// Trigger updates projection (PostgreSQL)
// CREATE TRIGGER process_invitation_events
//   AFTER INSERT ON domain_events
//   FOR EACH ROW EXECUTE FUNCTION update_invitation_projection();

// Frontend queries projection
const { data: invitations } = await supabase
  .from('invitations_projection')
  .select('*')
  .eq('org_id', orgId)
```

### 6. Idempotent Activity Design

Activities must be safe to retry without duplicating effects. Check if operation already completed before executing.

See: **[resources/activity-best-practices.md](resources/activity-best-practices.md)** for complete idempotency patterns.

### 7. Configurable Retry Policies

Different activities need different retry strategies. External APIs get aggressive retries, validations fail fast.

See: **[resources/activity-best-practices.md](resources/activity-best-practices.md)** for retry policy patterns.

### 8. Workflow Versioning

Use `patched()` to safely update workflows without breaking in-flight executions.

See: **[resources/workflow-patterns.md](resources/workflow-patterns.md)** for complete versioning guide.

---

## Complete Workflow Template

```typescript
// File: temporal/src/workflows/organization/my-workflow.ts

import { proxyActivities } from '@temporalio/workflow'
import type * as activities from '../../activities/organization'

// Proxy activities with retry policies
const {
  step1Activity,
  step2Activity,
  compensateStep1Activity,
  compensateStep2Activity
} = proxyActivities<typeof activities>({
  startToCloseTimeout: '5 minutes',
  retry: {
    initialInterval: '1s',
    backoffCoefficient: 2,
    maximumInterval: '30s',
    maximumAttempts: 3
  }
})

export interface MyWorkflowParams {
  orgId: string
  config: Record<string, unknown>
}

export interface MyWorkflowResult {
  success: boolean
  resourceId: string
}

export async function MyWorkflow(
  params: MyWorkflowParams
): Promise<MyWorkflowResult> {

  // Track state for compensation
  let step1Completed = false
  let step2Completed = false
  let resourceId: string

  try {
    // Step 1
    resourceId = await step1Activity({ orgId: params.orgId })
    step1Completed = true

    // Step 2
    await step2Activity({ resourceId, config: params.config })
    step2Completed = true

    return { success: true, resourceId }

  } catch (error) {
    // Saga compensation: rollback completed steps in reverse order
    if (step2Completed) {
      await compensateStep2Activity({ resourceId })
    }
    if (step1Completed) {
      await compensateStep1Activity({ resourceId })
    }

    throw error
  }
}
```

## Complete Activity Template

```typescript
// File: temporal/src/activities/organization/my-activity.ts

import { Context } from '@temporalio/activity'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

export interface MyActivityParams {
  orgId: string
  config: Record<string, unknown>
}

export async function myActivity(
  params: MyActivityParams
): Promise<string> {

  // 1. Perform side effect
  const { data: resource, error } = await supabase
    .from('resources')
    .insert({
      org_id: params.orgId,
      config: params.config
    })
    .select()
    .single()

  if (error) {
    throw new Error(`Failed to create resource: ${error.message}`)
  }

  // 2. Emit domain event
  const workflowInfo = Context.current().info

  const { error: eventError } = await supabase
    .from('domain_events')
    .insert({
      event_type: 'ResourceCreated',
      aggregate_type: 'Resource',
      aggregate_id: resource.id,
      event_data: {
        org_id: params.orgId,
        config: params.config
      },
      metadata: {
        workflow_id: workflowInfo.workflowId,
        workflow_run_id: workflowInfo.runId,
        workflow_type: workflowInfo.workflowType,
        activity_id: workflowInfo.activityId
      }
    })

  if (eventError) {
    throw new Error(`Failed to emit event: ${eventError.message}`)
  }

  console.log(`[ACTIVITY] Created resource ${resource.id} for org ${params.orgId}`)

  // 3. Return result
  return resource.id
}
```

---

## Anti-Pattern Example

### What NOT to Do: Side Effects in Workflow

```typescript
// ❌ WRONG - This workflow will break on replay!

export async function BadWorkflow(params) {
  // Non-deterministic - Date.now() changes on each replay
  const timestamp = Date.now()

  // Side effect - API call in workflow
  const response = await fetch('https://api.example.com/data')
  const data = await response.json()

  // Side effect - database write in workflow
  await supabase.from('logs').insert({
    message: 'Workflow started',
    timestamp: new Date().toISOString()  // Different each replay!
  })

  return data
}

// ✅ CORRECT - Deterministic workflow, side effects in activities

export async function GoodWorkflow(params) {
  // Use activity for API call
  const data = await fetchDataActivity()

  // Use activity for database write
  await logWorkflowStartActivity({ workflowId: params.id })

  return data
}
```

**Why this matters:** Temporal replays workflows from event history to reconstruct state after crashes. Non-deterministic code or side effects will produce different results on replay, breaking workflow execution.

---

## Quick Reference

```bash
# Local development
kubectl port-forward -n temporal svc/temporal-frontend 7233:7233
export TEMPORAL_ADDRESS=localhost:7233
npm run dev

# View Temporal Web UI
kubectl port-forward -n temporal svc/temporal-web 8080:8080

# Run tests
npm test
```

See `temporal/CLAUDE.md` for complete environment variables and commands.

---

## When to Use This Skill

Activate this skill when:

- Creating or modifying Temporal workflows
- Implementing activities that emit domain events
- Adding saga compensation logic
- Debugging workflow execution issues
- Writing workflow or activity tests
- Working in `temporal/src/workflows/` or `temporal/src/activities/`
- Implementing event-driven CQRS patterns

This skill complements `temporal/CLAUDE.md` with detailed implementation patterns and examples.
