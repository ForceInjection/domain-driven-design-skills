---
name: service-architecture-patterns
description: Modular design pattern for external service integrations (CAPTCHA, payment, SMS, file storage, analytics). Use when implementing third-party services, designing service abstractions, or reviewing service architecture. Triggers on /src/services/* files, integration questions, and provider implementations.
---

# Service Architecture Patterns Skill

## Overview

The **Modular Service Design Pattern** provides a structured approach for integrating external services with:

- Feature isolation in dedicated directories
- Generic interfaces supporting multiple providers
- Factory-based instantiation
- Encapsulation of implementation details

**Use this pattern for:** Payment processors, CAPTCHA services, Email providers, SMS services, File storage, Analytics services, and any external API integration.

**Key Benefits:**

- **Extensibility**: Easy to add new providers without changing consumers
- **Testability**: Mock interfaces instead of concrete implementations
- **Maintainability**: Clear separation of concerns and responsibilities
- **Performance**: Reusable service instances via closure/singleton patterns
- **Type Safety**: Full TypeScript support with proper abstractions

## Quick Reference: 7-Step Pattern

### 1. Feature Isolation

Create isolated service modules under `/src/services/[service-name]/`:

```text
src/services/[service-name]/
├── index.ts              # Public API exports only
├── [service].ts          # Generic interface
├── factory.ts            # Factory method
├── config.ts             # General configuration interface
└── [provider]/           # Provider-specific implementation
```

### 2. Interface Abstraction

Define generic interfaces supporting multiple implementations:

```typescript
export interface Captcha {
  validate: (token: string) => Promise<void>
}
```

### 3. Helper Interfaces

Create supporting types for data structures and configurations:

```typescript
export interface Config {
  baseUrl: string
  secret: string
  options: RequestOptions
}
```

### 4. Concrete Implementation

Implement the generic interface with provider-specific logic:

```typescript
export class Recaptcha implements Captcha {
  constructor(private config: Config) {}
  async validate(token: string): Promise<void> { /* ... */ }
}
```

### 5. Factory Pattern

Provide factory method for service creation:

```typescript
export const createCaptchaVerifier = (): Captcha => {
  return new Recaptcha(recaptchaConfig)
}
```

### 6. Encapsulation Strategy

Export only public API via index.ts:

```typescript
export type { Captcha } from './captcha'
export { createCaptchaVerifier } from './factory'
// Implementation details NOT exported
```

### 7. Usage Pattern

Consume services via factory methods and generic interfaces:

```typescript
const captchaVerifier = createCaptchaVerifier() // singleton instance
await captchaVerifier.validate(token)
```

## When to Use This Pattern

Use this pattern when:

- Integrating external third-party services or APIs
- Multiple provider implementations are needed (or planned)
- Testing requires mocking external dependencies
- Service logic should be isolated from business logic
- Provider may change in the future

## Real Examples from Codebase

- **Simple (single provider)**: `/src/services/captcha/` - Google reCAPTCHA
- **Advanced (multiple providers)**: `/src/services/email/` - Ethereal + Resend with registry pattern

## Deep Dive References

- **[Implementation Guide](references/implementation-guide.md)** - Complete 7-step walkthrough with testing strategies
- **[Captcha Example](references/captcha-example.md)** - Simple single-provider reference implementation
- **[Email Example](references/email-example.md)** - Advanced multi-provider with registry and singleton patterns
