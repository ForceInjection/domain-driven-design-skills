---
name: nondominium-holochain-tryorama-testing
description: Specialized skill for testing nondominium Holochain applications with Tryorama, providing comprehensive test patterns, agent simulation workflows, performance testing, and multi-agent scenario testing. Use when writing Tryorama tests, debugging zome interactions, or validating Holochain DNA functionality.
---

# Nondominium Holochain Tryorama Testing

This skill transforms Claude into a specialized Tryorama testing assistant, providing expert guidance for testing Holochain applications with multi-agent scenarios, performance testing, and comprehensive validation workflows.

## When to Use This Skill

**Use this skill when:**

- Writing Tryorama tests for Holochain zomes
- Creating multi-agent test scenarios
- Testing cross-zome interactions and workflows
- Validating ValueFlows economic flows
- Performance testing and load testing
- Debugging Holochain DNA functionality
- Testing capability-based access control
- Validating PPR (Private Permissioned Requests) systems

**Do NOT use for:**

- DNA code development (use the DNA development skill)
- Frontend/UI development (use appropriate web development skills)
- Generic testing outside Holochain context

## Core Testing Architecture

### Test File Organization

Tests are organized by zome and functionality in a 4-layer testing strategy:

```
tests/src/nondominium/
├── person/              # Person zome tests
│   ├── person-foundation.test.ts
│   ├── person-integration.test.ts
│   └── person-scenarios.test.ts
├── resource/            # Resource zome tests
│   ├── resource-foundation.test.ts
│   ├── resource-integration.test.ts
│   └── resource-scenarios.test.ts
├── governance/          # Governance zome tests
│   ├── governance-foundation.test.ts
│   ├── governance-integration.test.ts
│   ├── governance-scenarios.test.ts
│   └── ppr-system/      # PPR system tests
│       ├── ppr-foundation.test.ts
│       ├── ppr-integration.test.ts
│       ├── ppr-scenarios.test.ts
│       ├── ppr-cryptography.test.ts
│       └── ppr-debug.test.ts
└── utils/               # Shared testing utilities
    ├── common.ts
    ├── agents.ts
    └── fixtures.ts
```

### 4-Layer Testing Strategy

1. **Foundation Tests**: Basic zome function calls and connectivity
2. **Integration Tests**: Cross-zome interactions and multi-agent scenarios
3. **Scenario Tests**: Complete user journeys and workflows
4. **Performance Tests**: Load and stress testing for PPR systems

## Testing Workflows

### 1. Test Setup and Agent Management

```typescript
import { CallableCell, AgentPubKey, ActionHash } from "@holochain/client";
import { assert, test, describe } from "vitest";

// Common test setup
describe("Person Zome Tests", () => {
  let alice: AgentPubKey;
  let bob: AgentPubKey;
  let aliceCell: CallableCell;
  let bobCell: CallableCell;

  test("setup agents and cells", async () => {
    const conductor = await Conductor.singleton();

    alice = await generateAgentPubKey();
    bob = await generateAgentPubKey();

    aliceCell = await conductor.createCell({
      app_bundle: APP_BUNDLE,
      agent_key: alice,
    });

    bobCell = await conductor.createCell({
      app_bundle: APP_BUNDLE,
      agent_key: bob,
    });
  });
});
```

### 2. Foundation Test Patterns

**Basic Function Testing**:

```typescript
test("create person entry", async () => {
  const personInput = {
    name: "Alice Smith",
    nickname: "alice",
    bio: "Test user for Person zome",
    user_type: "accountable",
    email: "alice@example.com",
    time_zone: "UTC",
    location: "Test Location",
  };

  const result = await aliceCell.callZome({
    zome_name: "zome_person",
    fn_name: "create_person",
    payload: personInput,
  });

  assert.ok(result.person_hash);
  assert.equal(result.person.name, "Alice Smith");
});
```

**Error Testing**:

```typescript
test("invalid person creation fails", async () => {
  const invalidInput = {
    name: "", // Empty name should fail
    nickname: "test",
    bio: "Invalid person",
    user_type: "invalid_type", // Invalid user type
    email: "not-an-email",
    time_zone: "UTC",
    location: "Test",
  };

  try {
    await aliceCell.callZome({
      zome_name: "zome_person",
      fn_name: "create_person",
      payload: invalidInput,
    });
    assert.fail("Should have thrown an error");
  } catch (error) {
    assert.ok(error.message.includes("Validation failed"));
  }
});
```

### 3. Integration Test Patterns

**Cross-Zome Testing**:

```typescript
test("resource creation with person assignment", async () => {
  // Create person first
  const personResult = await aliceCell.callZome({
    zome_name: "zome_person",
    fn_name: "create_person",
    payload: samplePersonInput(),
  });

  // Create resource linked to person
  const resourceInput = {
    name: "Test Resource",
    resource_spec_hash: generateActionHash(),
    current_state: "available",
    accountable_agent: alice,
  };

  const resourceResult = await aliceCell.callZome({
    zome_name: "zome_resource",
    fn_name: "create_economic_resource",
    payload: resourceInput,
  });

  assert.ok(resourceResult.resource_hash);
  assert.equal(resourceResult.resource.accountable_agent, alice);
});
```

**Multi-Agent Scenarios**:

```typescript
test("multi-agent resource transfer", async () => {
  // Alice creates resource
  const resource = await createResource(aliceCell);

  // Alice transfers to Bob
  const transferInput = {
    resource_hash: resource.resource_hash,
    receiver: bob,
    quantity: 1,
    note: "Transfer test",
  };

  const transferResult = await aliceCell.callZome({
    zome_name: "zome_gouvernance",
    fn_name: "log_economic_event",
    payload: {
      ...transferInput,
      action: "transfer",
      provider: alice,
      receiver: bob,
      resource_inventoried_as: resource.resource_hash,
      generate_pprs: true,
    },
  });

  assert.ok(transferResult.event_hash);

  // Verify Bob can access the resource
  const bobResources = await bobCell.callZome({
    zome_name: "zome_resource",
    fn_name: "get_my_resources",
    payload: {},
  });

  assert.equal(bobResources.length, 1);
});
```

### 4. PPR System Testing

**PPR Issuance Testing**:

```typescript
test("PPR issuance for resource transfer", async () => {
  // Create resource and transfer (from previous test)
  const resource = await createResource(aliceCell);
  await transferResource(aliceCell, bobCell, resource);

  // Check PPRs were generated
  const aliceClaims = await aliceCell.callZome({
    zome_name: "zome_gouvernance",
    fn_name: "get_my_participation_claims",
    payload: { claim_type_filter: "CustodyTransfer" },
  });

  const bobClaims = await bobCell.callZome({
    zome_name: "zome_gouvernance",
    fn_name: "get_my_participation_claims",
    payload: { claim_type_filter: "CustodyAcceptance" },
  });

  assert.equal(aliceClaims.claims.length, 1);
  assert.equal(bobClaims.claims.length, 1);

  // Validate bi-directional receipt structure
  assert(validateBiDirectionalReceipts(aliceClaims.claims.map((c) => c[1])));
});
```

**Performance Testing**:

```typescript
test("PPR system performance benchmarks", async () => {
  const profiler = new PPRTestProfiler();
  profiler.start();

  // Issue multiple PPRs
  const receiptCount = 50;
  for (let i = 0; i < receiptCount; i++) {
    const claim = sampleParticipationClaim("ResourceCreation", {
      notes: `Performance test receipt ${i + 1}`,
    });

    await issueParticipationReceipts(aliceCell, claim);
    profiler.recordReceipt();
  }

  const metrics = profiler.finish();

  // Check performance benchmarks
  assert(
    metrics.executionTime < PPR_PERFORMANCE_BENCHMARKS.BULK_RECEIPT_PROCESSING,
  );
  assert.equal(metrics.receiptCount, receiptCount);
});
```

**Stress Testing**:

```typescript
test("PPR system stress testing", async () => {
  const stressResult = await stressTesterPPRIssuance(
    aliceCell,
    100, // receipt count
    10, // concurrency level
  );

  assert.equal(stressResult.successRate, 1.0);
  assert(stressResult.averageTime < 100); // ms per receipt
  assert.equal(stressResult.errors.length, 0);
});
```

## Advanced Testing Patterns

### 1. Test Fixtures and Data Generation

**Sample Data Generators**:

```typescript
export function samplePersonInput(
  overrides?: Partial<PersonInput>,
): PersonInput {
  return {
    name: "Test User",
    nickname: "testuser",
    bio: "Test user description",
    user_type: "accountable",
    email: "test@example.com",
    time_zone: "UTC",
    location: "Test Location",
    ...overrides,
  };
}

export function sampleParticipationClaim(
  claimType: ParticipationClaimType,
  overrides?: Partial<any>,
): ParticipationReceiptInput {
  return {
    claim_type: claimType,
    counterparty: generateAgentPubKey(),
    fulfills: generateActionHash(),
    fulfilled_by: generateActionHash(),
    performance_metrics: samplePerformanceMetrics(),
    ...overrides,
  };
}
```

**Test Scenario Definitions**:

```typescript
export const PPR_TEST_SCENARIOS: PPRTestScenario[] = [
  {
    name: "Basic Resource Creation",
    description: "Simple resource creation with standard metrics",
    claimType: "ResourceCreation",
    expectedReceiptCount: 2,
    performanceMetrics: {
      quality: 0.8,
      timeliness: 0.8,
      communication: 0.7,
      overall_satisfaction: 0.7,
      reliability: 0.8,
      notes: "Basic resource creation metrics",
    },
    shouldRequireSignature: true,
  },
  // ... more scenarios
];
```

### 2. Multi-Agent Test Scenarios

**Complex Interaction Matrix**:

```typescript
export const MULTI_AGENT_SCENARIOS: MultiAgentScenario[] = [
  {
    agentCount: 3,
    interactionMatrix: [
      ["ResourceContribution", "ServiceProvision"],
      ["ResourceReception", "KnowledgeSharing"],
      ["ServiceReception", "KnowledgeAcquisition"],
    ],
    expectedTotalReceipts: 6, // 3 agents × 2 interactions each
    scenario_description: "Triangle resource/service/knowledge exchange",
  },
  // ... more complex scenarios
];
```

**Multi-Agent Test Execution**:

```typescript
test("multi-agent complex interactions", async () => {
  const agents = await setupAgents(4);
  const scenario = MULTI_AGENT_SCENARIOS[1]; // Complex 4-agent scenario

  // Execute interaction matrix
  for (let i = 0; i < agents.length; i++) {
    const agentCell = agents[i].cell;
    const interactions = scenario.interactionMatrix[i];

    for (const claimType of interactions) {
      const claim = sampleParticipationClaim(claimType);
      await issueParticipationReceipts(agentCell, claim);
    }
  }

  // Verify total receipts
  let totalReceipts = 0;
  for (const agent of agents) {
    const claims = await agent.cell.callZome({
      zome_name: "zome_gouvernance",
      fn_name: "get_my_participation_claims",
      payload: {},
    });
    totalReceipts += claims.total_count;
  }

  assert.equal(totalReceipts, scenario.expectedTotalReceipts);
});
```

### 3. Performance and Load Testing

**Benchmark Testing**:

```typescript
describe("Performance Benchmarks", () => {
  test("PPR issuance performance", async () => {
    const startTime = performance.now();

    // Issue bi-directional PPRs
    const claim = sampleParticipationClaim("CustodyTransfer");
    await issueParticipationReceipts(aliceCell, claim);

    const duration = performance.now() - startTime;
    assert(
      duration < PPR_PERFORMANCE_BENCHMARKS.BI_DIRECTIONAL_RECEIPT_CREATION,
    );
  });

  test("Reputation aggregation performance", async () => {
    // Create multiple claims first
    for (let i = 0; i < 10; i++) {
      const claim = sampleParticipationClaim("ResourceCreation");
      await issueParticipationReceipts(aliceCell, claim);
    }

    const startTime = performance.now();

    const reputation = await aliceCell.callZome({
      zome_name: "zome_gouvernance",
      fn_name: "derive_reputation_summary",
      payload: {
        period_start: Date.now() - 86400000, // 24 hours ago
        period_end: Date.now(),
      },
    });

    const duration = performance.now() - startTime;
    assert(duration < PPR_PERFORMANCE_BENCHMARKS.REPUTATION_AGGREGATION);
    assert.ok(reputation.summary);
  });
});
```

### 4. Cryptographic Testing

**Signature Validation Testing**:

```typescript
test("PPR signature validation", async () => {
  // Create original receipt
  const claim = sampleParticipationClaim("ResourceCreation");
  const originalReceipt = await issueParticipationReceipts(aliceCell, claim);

  // Sign the receipt
  const signInput = {
    data_to_sign: new TextEncoder().encode("test data"),
    counterparty: bob,
  };

  const signatureResult = await aliceCell.callZome({
    zome_name: "zome_gouvernance",
    fn_name: "sign_participation_claim",
    payload: signInput,
  });

  assert.ok(signatureResult.signature);

  // Validate signature chain
  const isValid = validateSignatureChain(
    originalReceipt.provider_claim_hash,
    signatureResult.signed_data_hash,
  );

  assert.isTrue(isValid);
});
```

## Testing Utilities and Helpers

### 1. Validation Functions

```typescript
export function validateBiDirectionalReceipts(
  receiptsRecords: HolochainRecord[],
  expectedCount: number = 2,
): boolean {
  if (receiptsRecords.length !== expectedCount) {
    console.error(
      `Expected ${expectedCount} receipts, got ${receiptsRecords.length}`,
    );
    return false;
  }

  const receipts = decodeRecords(receiptsRecords) as ParticipationReceipt[];
  const claimTypes = receipts.map((r) => r.claim_type);

  // Check for complementary pairs
  const hasContributionReception =
    claimTypes.includes("ResourceContribution") &&
    claimTypes.includes("ResourceReception");
  const hasServiceProvisionReception =
    claimTypes.includes("ServiceProvision") &&
    claimTypes.includes("ServiceReception");

  return hasContributionReception || hasServiceProvisionReception;
}

export function validateReputationDerivation(
  reputation: ReputationSummary,
  expectedMinimumClaims: number = 1,
): boolean {
  return (
    reputation.total_participation_claims >= expectedMinimumClaims &&
    reputation.average_quality_score >= 0 &&
    reputation.average_quality_score <= 5 &&
    reputation.reputation_score >= 0 &&
    reputation.last_activity_timestamp > 0
  );
}
```

### 2. Performance Monitoring

```typescript
export class PPRTestProfiler {
  private startTime: number = 0;
  private metrics: PPRResourceMetrics = {
    memoryUsage: 0,
    executionTime: 0,
    receiptCount: 0,
    signatureCount: 0,
    validationCount: 0,
  };

  start(): void {
    this.startTime = performance.now();
  }

  recordReceipt(): void {
    this.metrics.receiptCount++;
  }

  recordSignature(): void {
    this.metrics.signatureCount++;
  }

  recordValidation(): void {
    this.metrics.validationCount++;
  }

  finish(): PPRResourceMetrics {
    this.metrics.executionTime = performance.now() - this.startTime;
    this.metrics.memoryUsage = (performance as any).memory?.usedJSHeapSize || 0;
    return { ...this.metrics };
  }
}
```

### 3. Stress Testing Framework

```typescript
export async function stressTesterPPRIssuance(
  cell: CallableCell,
  receiptCount: number,
  concurrencyLevel: number = 10,
): Promise<{
  totalTime: number;
  averageTime: number;
  successRate: number;
  errors: any[];
}> {
  const startTime = performance.now();
  const errors: any[] = [];
  let successCount = 0;

  // Create batches for concurrent processing
  const batches = [];
  for (let i = 0; i < receiptCount; i += concurrencyLevel) {
    const batchSize = Math.min(concurrencyLevel, receiptCount - i);
    const batch = Array.from({ length: batchSize }, (_, j) =>
      sampleParticipationClaim("ResourceCreation", {
        notes: `Stress test receipt ${i + j + 1}`,
      }),
    );
    batches.push(batch);
  }

  // Process batches
  for (const batch of batches) {
    const promises = batch.map(async (claim) => {
      try {
        await issueParticipationReceipts(cell, claim);
        successCount++;
      } catch (error) {
        errors.push({ claim, error });
      }
    });

    await Promise.all(promises);
  }

  const totalTime = performance.now() - startTime;
  const averageTime = totalTime / receiptCount;
  const successRate = successCount / receiptCount;

  return { totalTime, averageTime, successRate, errors };
}
```

## Test Configuration

### Test Timeout and Concurrency

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    timeout: 240000, // 4 minutes for complex scenarios
    concurrency: 1, // Single fork for DHT consistency
    globals: true,
    environment: "node",
  },
});
```

### Performance Benchmarks

```typescript
export const PPR_PERFORMANCE_BENCHMARKS = {
  BI_DIRECTIONAL_RECEIPT_CREATION: 1000, // ms
  SIGNATURE_ROUND_TRIP: 200, // ms
  REPUTATION_AGGREGATION: 1500, // ms
  BULK_RECEIPT_PROCESSING: 5000, // ms for 100 receipts
  CROSS_AGENT_VALIDATION: 800, // ms
};
```

## Running Tests

### Test Execution Commands

```bash
# Run all tests
bun run tests

# Run specific test files (use filename pattern, not path)
bun run tests person-foundation
bun run tests ppr-integration
bun run tests resource-scenarios

# Run specific zome tests (use partial file name patterns)
bun run tests person
bun run tests gouvernance
bun run tests ppr
```

### Test Development Tips

1. **Test Isolation**: Use `.only()` on `describe` or `it` blocks to run specific tests during development:

```typescript
describe.only('specific test suite', () => { ... })  // Run only this suite
it.only('specific test', async () => { ... })       // Run only this test
test.only('specific test', async () => { ... })       // Run only this test
```

2. **Rust Debugging**: Use the `warn!` macro in Rust zome functions to log debugging information that will appear in test output:

```rust
warn!("Debug info: variable = {:?}", some_variable);
warn!("Checkpoint reached in function_name");
warn!("Processing entry: {}", entry_hash);
```

The `warn!` macro output is visible in the test console, making it invaluable for debugging complex Holochain interactions and understanding execution flow during test development.

## Best Practices

### DO ✅

- Use structured test data generators for consistent test scenarios
- Implement comprehensive validation helpers for complex data structures
- Test both success and failure cases for all zome functions
- Use performance benchmarks to catch regressions
- Create multi-agent scenarios to test real-world usage
- Implement proper test isolation and cleanup
- Use descriptive test names and scenarios
- Test cross-zome interactions thoroughly
- Validate bi-directional receipt structures for PPR systems
- Use stress testing for performance-critical components

### DON'T ❌

- Create tests without proper validation of results
- Skip testing error cases and edge conditions
- Use hardcoded test data that's hard to maintain
- Create tests that depend on each other's state
- Ignore performance testing for critical paths
- Skip multi-agent testing for collaborative features
- Test without proper timeout handling
- Create tests that don't validate Holochain-specific patterns
- Skip cryptographic validation testing
- Ignore DHT consistency requirements in multi-agent tests

## Resources

### Test Utilities/

Shared testing helpers and utilities:

- `common.ts` - Common test patterns and helpers
- `agents.ts` - Agent management and setup utilities
- `fixtures.ts` - Test data generators and fixtures

### Test Scenarios/

Predefined test scenarios for common workflows:

- `ppr-scenarios.ts` - PPR system test scenarios
- `multi-agent.ts` - Multi-agent interaction patterns
- `performance.ts` - Performance testing utilities

**Note**: This skill is specifically tailored for the nondominium project's Tryorama testing needs and should be used in conjunction with the DNA development skill for comprehensive Holochain application testing.
