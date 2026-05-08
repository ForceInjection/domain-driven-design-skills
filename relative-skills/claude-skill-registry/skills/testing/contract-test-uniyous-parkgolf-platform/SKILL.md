---
name: contract-test
description: Park Golf Platform 계약 테스트 가이드. Pact를 사용한 Consumer-Driven Contract Testing, OpenAPI 스펙 검증, NATS 메시지 스키마 검증 방법 안내. "계약테스트", "contract", "pact", "스키마 검증" 관련 질문 시 사용합니다.
---

# Contract Testing Guide

## 개요

Contract Testing은 서비스 간 통신 계약을 검증하여 독립적인 배포를 가능하게 합니다.

### 테스트 유형

| 유형 | 설명 | 도구 |
|------|------|------|
| **Consumer-Driven** | Consumer가 기대하는 API 계약 정의 | Pact |
| **Provider Verification** | Provider가 계약 충족 검증 | Pact |
| **OpenAPI Validation** | Swagger 스펙 준수 검증 | Prism, Dredd |
| **NATS Schema** | 메시지 스키마 검증 | JSON Schema |

---

## 1. Pact 기반 Contract Testing

### 1.1 설치

```bash
# 각 서비스에 설치
npm install --save-dev @pact-foundation/pact
```

### 1.2 Consumer 테스트 (user-api → auth-service)

```typescript
// services/user-api/test/contract/auth-consumer.pact.ts
import { Pact } from '@pact-foundation/pact';
import path from 'path';
import axios from 'axios';

describe('Auth Service Consumer Contract', () => {
  const provider = new Pact({
    consumer: 'user-api',
    provider: 'auth-service',
    port: 1234,
    log: path.resolve(process.cwd(), 'logs', 'pact.log'),
    dir: path.resolve(process.cwd(), 'pacts'),
    logLevel: 'info',
  });

  beforeAll(() => provider.setup());
  afterAll(() => provider.finalize());
  afterEach(() => provider.verify());

  describe('POST /auth/login', () => {
    it('should return tokens on valid credentials', async () => {
      // Arrange
      const expectedResponse = {
        accessToken: 'jwt-access-token',
        refreshToken: 'jwt-refresh-token',
        user: {
          id: '123',
          email: 'test@example.com',
          name: '테스트 사용자',
        },
      };

      await provider.addInteraction({
        state: 'user exists',
        uponReceiving: 'a login request with valid credentials',
        withRequest: {
          method: 'POST',
          path: '/auth/login',
          headers: { 'Content-Type': 'application/json' },
          body: {
            email: 'test@example.com',
            password: 'Test1234!@',
          },
        },
        willRespondWith: {
          status: 200,
          headers: { 'Content-Type': 'application/json' },
          body: expectedResponse,
        },
      });

      // Act
      const response = await axios.post(`http://localhost:1234/auth/login`, {
        email: 'test@example.com',
        password: 'Test1234!@',
      });

      // Assert
      expect(response.status).toBe(200);
      expect(response.data.accessToken).toBeDefined();
    });

    it('should return 401 on invalid credentials', async () => {
      await provider.addInteraction({
        state: 'user exists',
        uponReceiving: 'a login request with invalid password',
        withRequest: {
          method: 'POST',
          path: '/auth/login',
          headers: { 'Content-Type': 'application/json' },
          body: {
            email: 'test@example.com',
            password: 'wrongpassword',
          },
        },
        willRespondWith: {
          status: 401,
          body: {
            message: 'Invalid credentials',
          },
        },
      });

      try {
        await axios.post(`http://localhost:1234/auth/login`, {
          email: 'test@example.com',
          password: 'wrongpassword',
        });
      } catch (error: any) {
        expect(error.response.status).toBe(401);
      }
    });
  });
});
```

### 1.3 Provider 검증 (auth-service)

```typescript
// services/auth-service/test/contract/auth-provider.pact.ts
import { Verifier } from '@pact-foundation/pact';
import path from 'path';

describe('Auth Service Provider Contract', () => {
  it('should validate the expectations of user-api', async () => {
    const opts = {
      provider: 'auth-service',
      providerBaseUrl: 'http://localhost:3001',
      pactUrls: [
        path.resolve(__dirname, '../../pacts/user-api-auth-service.json'),
      ],
      // 또는 Pact Broker 사용
      // pactBrokerUrl: 'https://pact-broker.example.com',
      // pactBrokerToken: process.env.PACT_BROKER_TOKEN,
      stateHandlers: {
        'user exists': async () => {
          // 테스트 사용자 생성
          console.log('Setting up: user exists');
        },
      },
    };

    await new Verifier(opts).verifyProvider();
  });
});
```

---

## 2. NATS 메시지 계약 테스트

### 2.1 JSON Schema 정의

```typescript
// shared/schemas/nats-messages.ts
export const schemas = {
  'auth.login': {
    request: {
      type: 'object',
      properties: {
        email: { type: 'string', format: 'email' },
        password: { type: 'string', minLength: 8 },
      },
      required: ['email', 'password'],
    },
    response: {
      type: 'object',
      properties: {
        accessToken: { type: 'string' },
        refreshToken: { type: 'string' },
        user: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            email: { type: 'string' },
            name: { type: 'string' },
          },
          required: ['id', 'email'],
        },
      },
      required: ['accessToken', 'refreshToken', 'user'],
    },
  },

  'auth.validate': {
    request: {
      type: 'object',
      properties: {
        token: { type: 'string' },
      },
      required: ['token'],
    },
    response: {
      type: 'object',
      properties: {
        valid: { type: 'boolean' },
        userId: { type: 'string' },
        email: { type: 'string' },
      },
      required: ['valid'],
    },
  },

  'courses.list': {
    request: {
      type: 'object',
      properties: {
        page: { type: 'integer', minimum: 1 },
        limit: { type: 'integer', minimum: 1, maximum: 100 },
        search: { type: 'string' },
      },
    },
    response: {
      type: 'object',
      properties: {
        data: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              id: { type: 'string' },
              name: { type: 'string' },
              address: { type: 'string' },
              holes: { type: 'integer' },
            },
            required: ['id', 'name'],
          },
        },
        total: { type: 'integer' },
        page: { type: 'integer' },
        limit: { type: 'integer' },
      },
      required: ['data', 'total'],
    },
  },

  'bookings.create': {
    request: {
      type: 'object',
      properties: {
        userId: { type: 'string' },
        courseId: { type: 'string' },
        date: { type: 'string', format: 'date' },
        timeSlot: { type: 'string', pattern: '^[0-2][0-9]:[0-5][0-9]$' },
        players: { type: 'integer', minimum: 1, maximum: 4 },
      },
      required: ['userId', 'courseId', 'date', 'timeSlot', 'players'],
    },
    response: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        status: { type: 'string', enum: ['pending', 'confirmed', 'cancelled'] },
        bookingNumber: { type: 'string' },
      },
      required: ['id', 'status'],
    },
  },
};
```

### 2.2 NATS Contract Validator

```typescript
// shared/utils/nats-contract-validator.ts
import Ajv from 'ajv';
import addFormats from 'ajv-formats';
import { schemas } from '../schemas/nats-messages';

const ajv = new Ajv({ allErrors: true });
addFormats(ajv);

export class NatsContractValidator {
  private validators: Map<string, { request: any; response: any }> = new Map();

  constructor() {
    Object.entries(schemas).forEach(([pattern, schema]) => {
      this.validators.set(pattern, {
        request: ajv.compile(schema.request),
        response: ajv.compile(schema.response),
      });
    });
  }

  validateRequest(pattern: string, data: any): { valid: boolean; errors?: any[] } {
    const validator = this.validators.get(pattern);
    if (!validator) {
      return { valid: false, errors: [{ message: `Unknown pattern: ${pattern}` }] };
    }

    const valid = validator.request(data);
    return { valid, errors: validator.request.errors || undefined };
  }

  validateResponse(pattern: string, data: any): { valid: boolean; errors?: any[] } {
    const validator = this.validators.get(pattern);
    if (!validator) {
      return { valid: false, errors: [{ message: `Unknown pattern: ${pattern}` }] };
    }

    const valid = validator.response(data);
    return { valid, errors: validator.response.errors || undefined };
  }
}
```

### 2.3 NATS Contract 테스트

```typescript
// test/contract/nats-contract.test.ts
import { connect, StringCodec } from 'nats';
import { NatsContractValidator } from '../../shared/utils/nats-contract-validator';

describe('NATS Message Contracts', () => {
  let nc: any;
  let validator: NatsContractValidator;
  const sc = StringCodec();

  beforeAll(async () => {
    nc = await connect({ servers: 'nats://localhost:4222' });
    validator = new NatsContractValidator();
  });

  afterAll(async () => {
    await nc.close();
  });

  describe('auth.validate', () => {
    it('should validate request schema', () => {
      const request = { token: 'valid-jwt-token' };
      const result = validator.validateRequest('auth.validate', request);
      expect(result.valid).toBe(true);
    });

    it('should reject invalid request', () => {
      const request = { invalidField: 'value' };
      const result = validator.validateRequest('auth.validate', request);
      expect(result.valid).toBe(false);
    });

    it('should validate response schema', () => {
      const response = { valid: true, userId: '123', email: 'test@example.com' };
      const result = validator.validateResponse('auth.validate', response);
      expect(result.valid).toBe(true);
    });
  });

  describe('courses.list', () => {
    it('should return data matching contract', async () => {
      const request = { page: 1, limit: 10 };

      // Validate request
      expect(validator.validateRequest('courses.list', request).valid).toBe(true);

      // Make actual NATS request
      const response = await nc.request(
        'courses.list',
        sc.encode(JSON.stringify(request)),
        { timeout: 5000 }
      );
      const data = JSON.parse(sc.decode(response.data));

      // Validate response
      const validation = validator.validateResponse('courses.list', data);
      expect(validation.valid).toBe(true);
      if (!validation.valid) {
        console.error('Contract violation:', validation.errors);
      }
    });
  });
});
```

---

## 3. OpenAPI Spec Validation

### 3.1 Prism으로 Mock Server 실행

```bash
# Prism 설치
npm install -g @stoplight/prism-cli

# OpenAPI 스펙 기반 Mock 서버 실행
prism mock services/user-api/openapi.yaml --port 4010

# Validation 모드로 실행
prism proxy services/user-api/openapi.yaml http://localhost:3092 --errors
```

### 3.2 Dredd로 API 테스트

```bash
# Dredd 설치
npm install -g dredd

# OpenAPI 스펙 기반 테스트
dredd services/user-api/openapi.yaml http://localhost:3092
```

### 3.3 Swagger 스펙에서 테스트 자동 생성

```typescript
// test/contract/openapi-validation.test.ts
import SwaggerParser from '@apidevtools/swagger-parser';
import axios from 'axios';

describe('OpenAPI Contract Validation', () => {
  let spec: any;

  beforeAll(async () => {
    spec = await SwaggerParser.validate('services/user-api/openapi.yaml');
  });

  it('should validate all endpoints exist', async () => {
    const paths = Object.keys(spec.paths);

    for (const path of paths) {
      const methods = Object.keys(spec.paths[path]);
      for (const method of methods) {
        if (['get', 'post', 'put', 'delete', 'patch'].includes(method)) {
          console.log(`Validating: ${method.toUpperCase()} ${path}`);
          // 각 엔드포인트 검증 로직
        }
      }
    }
  });
});
```

---

## 4. CI/CD 통합

### GitHub Actions Workflow

```yaml
# .github/workflows/contract-test.yml
name: Contract Tests

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [develop]

jobs:
  pact-consumer:
    name: Pact Consumer Tests
    runs-on: ubuntu-latest
    strategy:
      matrix:
        service: [user-api, admin-api]
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci
        working-directory: services/${{ matrix.service }}

      - name: Run Pact Consumer Tests
        run: npm run test:contract:consumer
        working-directory: services/${{ matrix.service }}

      - name: Upload Pact files
        uses: actions/upload-artifact@v4
        with:
          name: pacts-${{ matrix.service }}
          path: services/${{ matrix.service }}/pacts/

  pact-provider:
    name: Pact Provider Verification
    needs: pact-consumer
    runs-on: ubuntu-latest
    strategy:
      matrix:
        service: [auth-service, course-service, booking-service]
    steps:
      - uses: actions/checkout@v4

      - name: Download Pact files
        uses: actions/download-artifact@v4
        with:
          path: pacts

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci
        working-directory: services/${{ matrix.service }}

      - name: Start service
        run: |
          npm run start:test &
          sleep 10
        working-directory: services/${{ matrix.service }}

      - name: Verify Provider
        run: npm run test:contract:provider
        working-directory: services/${{ matrix.service }}

  nats-schema:
    name: NATS Schema Validation
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci
        working-directory: test

      - name: Run NATS Contract Tests
        run: npm run test:nats-contract
        working-directory: test
```

---

## 5. Package.json 설정

```json
// services/user-api/package.json
{
  "scripts": {
    "test:contract": "npm run test:contract:consumer && npm run test:contract:provider",
    "test:contract:consumer": "jest --config jest.contract.config.js --testPathPattern=consumer",
    "test:contract:provider": "jest --config jest.contract.config.js --testPathPattern=provider"
  },
  "devDependencies": {
    "@pact-foundation/pact": "^12.0.0",
    "ajv": "^8.12.0",
    "ajv-formats": "^2.1.1"
  }
}
```

```javascript
// jest.contract.config.js
module.exports = {
  testEnvironment: 'node',
  testMatch: ['**/test/contract/**/*.pact.ts'],
  transform: {
    '^.+\\.tsx?$': 'ts-jest',
  },
  testTimeout: 30000,
};
```

---

## 6. 테스트 실행 체크리스트

### Pact Contract Testing
- [ ] Consumer 테스트 작성 및 Pact 파일 생성
- [ ] Provider 테스트로 계약 검증
- [ ] CI/CD 파이프라인에 통합

### NATS Schema Validation
- [ ] 메시지 스키마 정의 (JSON Schema)
- [ ] Request/Response 검증 테스트
- [ ] 실제 NATS 통신 검증

### OpenAPI Validation
- [ ] OpenAPI 스펙 업데이트
- [ ] Prism/Dredd로 API 검증
- [ ] 스펙과 실제 API 동기화 확인

---

## 7. Best Practices

1. **Consumer First**: Consumer가 먼저 계약을 정의하고 Provider가 충족
2. **스키마 버전 관리**: 메시지 스키마에 버전 포함
3. **Backward Compatibility**: 기존 계약을 깨지 않도록 주의
4. **Pact Broker 활용**: 중앙화된 계약 관리
5. **CI/CD 필수 통합**: PR 머지 전 계약 검증 필수

