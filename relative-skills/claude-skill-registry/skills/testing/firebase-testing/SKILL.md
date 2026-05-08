---
name: firebase-testing
description: Guide for testing Firebase Admin SDK with Vitest mocks. Use when writing tests that involve Firebase Auth, Firestore, or Firebase App.
---

# Firebase Testing Patterns

This skill provides patterns for mocking Firebase Admin SDK in Vitest tests.

## Mock Helpers Location

Firebase mocks are located in `app/tests/mocks/firebase.ts` and provide:

- `createFirebaseAppMock()` - Mock Firebase App instance
- `createFirebaseAuthMock()` - Mock Firebase Auth with verifyIdToken, getUser
- `createFirestoreMock()` - Mock Firestore with collection, doc, get
- `resetFirebaseMocks()` - Reset all mocks between tests

## Firebase Plugin Test Template

```typescript
import Fastify from "fastify";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import {
  createFirebaseAppMock,
  createFirebaseAuthMock,
  createFirestoreMock,
} from "../../mocks/firebase.js";

const mockApp = createFirebaseAppMock();
const mockAuth = createFirebaseAuthMock();
const mockFirestore = createFirestoreMock();

vi.mock("firebase-admin/app", () => ({
  getApps: vi.fn(() => [mockApp]),
  initializeApp: vi.fn(() => mockApp),
  cert: vi.fn(),
}));

vi.mock("firebase-admin/auth", () => ({
  getAuth: vi.fn(() => mockAuth),
}));

vi.mock("firebase-admin/firestore", () => ({
  getFirestore: vi.fn(() => mockFirestore),
}));

describe("Firebase Plugin", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  afterEach(async () => {
    // Clear module cache so dynamic imports get fresh mocked modules
    vi.resetModules();
  });

  it("should register firebase decorator", async () => {
    const { default: firebasePlugin } = await import(
      "../../../src/plugins/firebase.js"
    );
    const fastify = Fastify();
    await fastify.register(firebasePlugin);
    await fastify.ready();

    expect(fastify.firebase).toBeDefined();
    await fastify.close();
  });
});
```

## Auth Testing Patterns

### Valid Token Authentication

```typescript
it("should authenticate with valid token", async () => {
  const mockDecodedToken = {
    uid: "test-user-123",
    email: "test@example.com",
    email_verified: true,
  };
  mockAuth.verifyIdToken.mockResolvedValue(mockDecodedToken);

  const response = await fastify.inject({
    method: "GET",
    url: "/protected",
    headers: { authorization: "Bearer valid-token" },
  });

  expect(response.statusCode).toBe(200);
  expect(mockAuth.verifyIdToken).toHaveBeenCalledWith("valid-token", false);
});
```

### Invalid Token Handling

```typescript
it("should return 401 for invalid token", async () => {
  mockAuth.verifyIdToken.mockRejectedValue(
    new Error("Firebase ID token has invalid signature"),
  );

  const response = await fastify.inject({
    method: "GET",
    url: "/protected",
    headers: { authorization: "Bearer invalid-token" },
  });

  expect(response.statusCode).toBe(401);
});
```

### Token Revocation

```typescript
it("should return 401 when token is revoked", async () => {
  const revokedError = Object.assign(new Error("Token has been revoked"), {
    code: "auth/id-token-revoked",
  });
  mockAuth.verifyIdToken.mockRejectedValue(revokedError);

  const response = await fastify.inject({
    method: "GET",
    url: "/protected",
    headers: { authorization: "Bearer revoked-token" },
  });

  expect(response.statusCode).toBe(401);
  expect(response.json().message).toContain("Token has been revoked");
});
```

### Missing Authorization Header

```typescript
it("should return 401 when no authorization header", async () => {
  const response = await fastify.inject({
    method: "GET",
    url: "/protected",
  });

  expect(response.statusCode).toBe(401);
});
```

## Firestore Testing Patterns

### Mocking Collection Queries

```typescript
it("should query Firestore collection", async () => {
  const mockDocs = [
    { id: "doc1", data: () => ({ name: "Test 1" }) },
    { id: "doc2", data: () => ({ name: "Test 2" }) },
  ];
  mockFirestore.collection.mockReturnValue({
    get: vi.fn().mockResolvedValue({ docs: mockDocs }),
    limit: vi.fn().mockReturnThis(),
  });

  // Test code that queries Firestore
});
```

### Mocking Document Operations

```typescript
it("should get a document", async () => {
  const mockDoc = {
    exists: true,
    id: "doc-id",
    data: () => ({ field: "value" }),
  };
  mockFirestore.collection.mockReturnValue({
    doc: vi.fn().mockReturnValue({
      get: vi.fn().mockResolvedValue(mockDoc),
    }),
  });

  // Test code that gets a document
});
```

## Key Patterns

1. **Mock before import**: Use `vi.mock()` at module level before importing tested modules
2. **Dynamic imports**: Use `await import()` after mocks are set up to ensure mocks are applied
3. **Reset between tests**:
   - `vi.clearAllMocks()` in beforeEach - clears mock call history
   - `vi.resetModules()` in afterEach - clears module cache so dynamic imports get fresh mocked modules
4. **Realistic data**: Use realistic mock data that matches Firebase structures

## Commands

```bash
cd app
npm run test              # Run all tests
npm run test:coverage     # Run tests with coverage
```

## Boundaries

- Never use real Firebase credentials in tests
- Always mock Firebase Admin SDK modules
- Use the shared mock helpers from `tests/mocks/firebase.ts`
