---
name: e2e-test-scenarios
description: End-to-end testing scenarios for Supabase - complete workflow tests from project creation to AI features, validation scripts, and comprehensive test suites. Use when testing Supabase integrations, validating AI workflows, running E2E tests, verifying production readiness, or when user mentions Supabase testing, E2E tests, integration testing, pgvector testing, auth testing, or test automation.
allowed-tools: Bash, Read, Write, Edit
---

# e2e-test-scenarios

## Instructions

This skill provides comprehensive end-to-end testing capabilities for Supabase applications, covering database operations, authentication flows, AI features (pgvector), realtime subscriptions, and production readiness validation.

### Phase 1: Setup Test Environment

1. Initialize test environment:
   ```bash
   bash scripts/setup-test-env.sh
   ```
   This creates:
   - Test database configuration
   - Environment variables for testing
   - Test data fixtures
   - CI/CD configuration templates

2. Configure test database:
   - Use dedicated test project or local Supabase instance
   - Never run tests against production
   - Set `SUPABASE_TEST_URL` and `SUPABASE_TEST_ANON_KEY`
   - Enable pgTAP extension for database tests

3. Install dependencies:
   ```bash
   npm install --save-dev @supabase/supabase-js jest @types/jest
   # or
   pnpm add -D @supabase/supabase-js vitest
   ```

### Phase 2: Database Workflow Testing

Test complete database operations from schema to queries:

1. Run database E2E tests:
   ```bash
   bash scripts/test-database-workflow.sh
   ```

   This validates:
   - Schema creation and migrations
   - Table relationships and foreign keys
   - RLS policies enforcement
   - Triggers and functions
   - Data integrity constraints

2. Use pgTAP for SQL-level tests:
   ```bash
   # Run all database tests
   supabase test db

   # Run specific test file
   supabase test db --file tests/database/users.test.sql
   ```

3. Test schema migrations:
   ```bash
   # Test migration up/down
   supabase db reset --linked
   supabase db push

   # Verify schema state
   bash scripts/validate-schema.sh
   ```

### Phase 3: Authentication Flow Testing

Test complete auth workflows end-to-end:

1. Run authentication E2E tests:
   ```bash
   bash scripts/test-auth-workflow.sh
   ```

   This validates:
   - Email/password signup and login
   - Magic link authentication
   - OAuth provider flows (Google, GitHub, etc.)
   - Session management and refresh
   - Password reset flows
   - Email verification
   - Multi-factor authentication (MFA)

2. Test RLS with authenticated users:
   ```typescript
   // See templates/auth-tests.ts for complete examples
   test('authenticated users see only their data', async () => {
     const { data, error } = await supabase
       .from('private_notes')
       .select('*');

     expect(data).toHaveLength(userNoteCount);
     expect(data.every(note => note.user_id === userId)).toBe(true);
   });
   ```

3. Test session persistence:
   ```bash
   # Run session validation tests
   npm test -- auth-session.test.ts
   ```

### Phase 4: AI Features Testing (pgvector)

Test vector search and semantic operations:

1. Run AI features E2E tests:
   ```bash
   bash scripts/test-ai-features.sh
   ```

   This validates:
   - pgvector extension is enabled
   - Embedding storage and retrieval
   - Vector similarity search accuracy
   - HNSW/IVFFlat index performance
   - Hybrid search (keyword + semantic)
   - Embedding dimension consistency

2. Test vector search accuracy:
   ```typescript
   // See templates/vector-search-tests.ts
   test('semantic search returns relevant results', async () => {
     const queryEmbedding = await generateEmbedding('machine learning');

     const { data } = await supabase.rpc('match_documents', {
       query_embedding: queryEmbedding
       match_threshold: 0.7
       match_count: 5
     });

     expect(data.length).toBeGreaterThan(0);
     expect(data[0].similarity).toBeGreaterThan(0.7);
   });
   ```

3. Test embedding operations:
   ```bash
   # Validate embedding pipeline
   npm test -- embedding-workflow.test.ts
   ```

4. Performance benchmarking:
   ```bash
   # Run performance tests
   bash scripts/benchmark-vector-search.sh [TABLE_NAME] [VECTOR_DIM]
   ```

### Phase 5: Realtime Features Testing

Test realtime subscriptions and presence:

1. Run realtime E2E tests:
   ```bash
   bash scripts/test-realtime-workflow.sh
   ```

   This validates:
   - Database change subscriptions
   - Broadcast messaging
   - Presence tracking
   - Connection handling
   - Reconnection logic
   - Subscription cleanup

2. Test database change subscriptions:
   ```typescript
   // See templates/realtime-tests.ts
   test('receives real-time updates on insert', async () => {
     const updates = [];

     const subscription = supabase
       .channel('test-channel')
       .on('postgres_changes'
         { event: 'INSERT', schema: 'public', table: 'messages' }
         (payload) => updates.push(payload)
       )
       .subscribe();

     await supabase.from('messages').insert({ content: 'test' });

     await waitFor(() => expect(updates).toHaveLength(1));
   });
   ```

3. Test presence and broadcast:
   ```bash
   # Run presence tests
   npm test -- presence.test.ts
   ```

### Phase 6: Complete Integration Tests

Run full workflow tests simulating real user scenarios:

1. Execute complete E2E test suite:
   ```bash
   bash scripts/run-e2e-tests.sh
   ```

   This runs:
   - User signup → profile creation → data CRUD → logout
   - Document upload → embedding generation → semantic search
   - Chat message → realtime delivery → read receipts
   - Multi-user collaboration scenarios
   - Error handling and recovery

2. Run test scenarios in parallel:
   ```bash
   # Run all test suites
   npm test -- --maxWorkers=4

   # Run specific workflow
   npm test -- workflows/document-rag.test.ts
   ```

3. Generate test reports:
   ```bash
   # Generate coverage report
   npm test -- --coverage

   # Generate HTML report
   npm test -- --coverage --coverageReporters=html
   ```

### Phase 7: CI/CD Integration

Setup automated testing in CI/CD pipelines:

1. Use GitHub Actions template:
   ```bash
   # Copy CI config to your repo
   cp templates/ci-config.yml .github/workflows/supabase-tests.yml
   ```

2. Configure test secrets:
   - Add `SUPABASE_TEST_URL` to GitHub secrets
   - Add `SUPABASE_TEST_ANON_KEY` to GitHub secrets
   - Add `SUPABASE_TEST_SERVICE_ROLE_KEY` for admin tests

3. Run tests on pull requests:
   - Automatic test execution on PR creation
   - Blocking PRs if tests fail
   - Test result reporting in PR comments

### Phase 8: Cleanup and Teardown

Clean up test resources after testing:

1. Run cleanup script:
   ```bash
   bash scripts/cleanup-test-resources.sh
   ```

   This removes:
   - Test users and sessions
   - Test data from tables
   - Temporary test databases
   - Test file uploads

2. Reset test database:
   ```bash
   # Reset to clean state
   supabase db reset --linked

   # Or use migration-based reset
   bash scripts/reset-test-db.sh
   ```

## Test Coverage Areas

### Database Testing
- **Schema Validation**: Table structure, columns, constraints
- **Migration Testing**: Up/down migrations, rollback safety
- **RLS Policies**: Access control, policy enforcement
- **Functions & Triggers**: Database logic, event handlers
- **Performance**: Query optimization, index usage

### Authentication Testing
- **User Flows**: Signup, login, logout, password reset
- **Provider Integration**: OAuth, magic links, phone auth
- **Session Management**: Token refresh, expiration, persistence
- **MFA**: Setup, verification, recovery codes
- **Security**: Rate limiting, brute force protection

### AI Features Testing
- **Vector Operations**: Insert, update, delete embeddings
- **Similarity Search**: Accuracy, relevance, threshold tuning
- **Index Performance**: HNSW vs IVFFlat, query speed
- **Hybrid Search**: Combined keyword and semantic search
- **Dimension Validation**: Embedding size consistency

### Realtime Testing
- **Subscriptions**: Database changes, broadcasts, presence
- **Connection Management**: Connect, disconnect, reconnect
- **Message Delivery**: Ordering, reliability, deduplication
- **Performance**: Latency, throughput, concurrent users
- **Cleanup**: Subscription disposal, memory leaks

### Integration Testing
- **Multi-Component**: Auth + Database + Storage
- **User Journeys**: Complete workflows end-to-end
- **Error Scenarios**: Network failures, invalid data, rate limits
- **Edge Cases**: Concurrent updates, race conditions, timeouts

## Test Data Strategies

### Fixture Management
```typescript
// Load test fixtures
const testData = await loadFixtures('users', 'posts', 'comments');

// Seed database
await seedDatabase(testData);

// Cleanup after tests
afterAll(async () => {
  await cleanupFixtures();
});
```

### Factory Patterns
```typescript
// Create test users with factories
const user = await createTestUser({
  email: 'test@example.com'
  metadata: { role: 'admin' }
});

// Create related data
const posts = await createTestPosts(user.id, 5);
```

### Isolation Strategies
- **Test Database**: Dedicated test project
- **Transaction Rollback**: Rollback after each test
- **Namespace Prefixes**: `test_` prefix for test data
- **Time-based Cleanup**: Delete data older than X hours

## Performance Benchmarks

### Query Performance Targets
- Simple queries: < 50ms
- Vector similarity search: < 100ms
- Hybrid search: < 200ms
- Complex joins: < 300ms

### Realtime Latency Targets
- Message delivery: < 100ms
- Presence updates: < 200ms
- Database changes: < 500ms

### Throughput Targets
- Authenticated requests: 100+ req/s
- Vector searches: 50+ req/s
- Realtime messages: 1000+ msg/s

## Common Test Patterns

### Pattern 1: Auth-Protected Resource Test
```typescript
test('authenticated user CRUD operations', async () => {
  // 1. Sign up user
  const { user } = await supabase.auth.signUp({
    email: 'test@example.com'
    password: 'test123'
  });

  // 2. Create resource
  const { data } = await supabase
    .from('notes')
    .insert({ content: 'test note' })
    .select()
    .single();

  // 3. Verify ownership
  expect(data.user_id).toBe(user.id);

  // 4. Update resource
  await supabase
    .from('notes')
    .update({ content: 'updated' })
    .eq('id', data.id);

  // 5. Delete resource
  await supabase.from('notes').delete().eq('id', data.id);
});
```

### Pattern 2: Vector Search Workflow Test
```typescript
test('document RAG workflow', async () => {
  // 1. Upload document
  const doc = await uploadDocument('test.pdf');

  // 2. Generate embeddings
  const chunks = await chunkDocument(doc);
  const embeddings = await generateEmbeddings(chunks);

  // 3. Store in database
  await supabase.from('document_chunks').insert(
    chunks.map((chunk, i) => ({
      content: chunk
      embedding: embeddings[i]
      document_id: doc.id
    }))
  );

  // 4. Perform semantic search
  const query = 'What is the main topic?';
  const queryEmbedding = await generateEmbedding(query);

  const { data } = await supabase.rpc('match_documents', {
    query_embedding: queryEmbedding
    match_count: 5
  });

  // 5. Verify results
  expect(data.length).toBeGreaterThan(0);
  expect(data[0].similarity).toBeGreaterThan(0.7);
});
```

### Pattern 3: Realtime Collaboration Test
```typescript
test('multi-user realtime chat', async () => {
  // 1. Create two users
  const user1 = await createTestUser();
  const user2 = await createTestUser();

  // 2. Subscribe to messages
  const user1Messages = [];
  const user2Messages = [];

  const sub1 = await subscribeToMessages(user1, user1Messages);
  const sub2 = await subscribeToMessages(user2, user2Messages);

  // 3. User 1 sends message
  await sendMessage(user1, 'Hello from user 1');

  // 4. Verify both users receive it
  await waitFor(() => {
    expect(user1Messages).toHaveLength(1);
    expect(user2Messages).toHaveLength(1);
  });

  // 5. Cleanup subscriptions
  await sub1.unsubscribe();
  await sub2.unsubscribe();
});
```

## Troubleshooting

### Tests Failing Intermittently
- **Race Conditions**: Add proper wait conditions
- **Async Issues**: Ensure all promises are awaited
- **Cleanup**: Verify test isolation and cleanup
- **Timeouts**: Increase timeout for slow operations

### Tests Passing Locally but Failing in CI
- **Environment**: Verify env variables in CI
- **Timing**: CI may be slower, increase timeouts
- **Parallelization**: Check for shared state issues
- **Dependencies**: Ensure all deps are installed

### Slow Test Execution
- **Parallel Tests**: Use `--maxWorkers` flag
- **Test Selection**: Run only changed tests
- **Database Reset**: Use faster cleanup methods
- **Mocking**: Mock external services

### Database Connection Issues
- **Connection Pooling**: Limit concurrent connections
- **Cleanup**: Properly close connections after tests
- **Retries**: Implement connection retry logic
- **Timeouts**: Set appropriate connection timeouts

## Files Reference

**Scripts:**
- `scripts/setup-test-env.sh` - Initialize test environment
- `scripts/run-e2e-tests.sh` - Execute complete test suite
- `scripts/test-database-workflow.sh` - Database E2E tests
- `scripts/test-auth-workflow.sh` - Authentication E2E tests
- `scripts/test-ai-features.sh` - Vector search E2E tests
- `scripts/test-realtime-workflow.sh` - Realtime E2E tests
- `scripts/cleanup-test-resources.sh` - Clean up test data
- `scripts/validate-schema.sh` - Validate database schema
- `scripts/benchmark-vector-search.sh` - Performance benchmarks
- `scripts/reset-test-db.sh` - Reset test database

**Templates:**
- `templates/test-suite-template.ts` - Jest/Vitest boilerplate
- `templates/database-tests.ts` - Database operation tests
- `templates/auth-tests.ts` - Authentication flow tests
- `templates/vector-search-tests.ts` - pgvector tests
- `templates/realtime-tests.ts` - Realtime subscription tests
- `templates/ci-config.yml` - GitHub Actions CI/CD
- `templates/jest.config.js` - Jest configuration
- `templates/vitest.config.ts` - Vitest configuration

**Examples:**
- `examples/complete-test-workflow.md` - Full E2E testing guide
- `examples/ci-cd-integration.md` - CI/CD setup guide
- `examples/test-data-strategies.md` - Test data management
- `examples/performance-benchmarks.md` - Performance testing
- `examples/mocking-strategies.md` - Mocking external services

---

**Plugin**: supabase
**Version**: 1.0.0
**Last Updated**: 2025-10-26
