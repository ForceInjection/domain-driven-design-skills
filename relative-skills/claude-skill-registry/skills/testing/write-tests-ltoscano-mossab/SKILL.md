---
name: write-tests
description: Generates comprehensive unit tests and integration tests for code with test coverage analysis and edge cases
license: MIT
compatibility: JavaScript/TypeScript (Jest, Vitest), Python (pytest), Java (JUnit), Go
---

# Write Tests Skill

Questa skill genera test completi e professionali per il codice, includendo unit tests, integration tests, e edge cases.

## Obiettivo

Creare test suite completa che garantisca quality assurance e faciliti refactoring futuro.

## Processo di Test Generation

### 1. Analisi del Codice

Prima di scrivere test, analizza:
- **Funzionalità**: Cosa fa il codice?
- **Dependencies**: Quali dipendenze esterne ha?
- **Side effects**: Il codice ha effetti collaterali?
- **Input/Output**: Quali sono i possibili input e output?
- **Edge cases**: Quali sono i casi limite?

### 2. Tipi di Test da Generare

#### A. Unit Tests
- Test per ogni funzione/metodo pubblico
- Test per comportamenti normali (happy path)
- Test per error cases
- Test per edge cases e boundary conditions
- Mock di dependencies esterne

#### B. Integration Tests
- Test per interazioni tra moduli
- Test per database operations (se applicabile)
- Test per API calls (se applicabile)

#### C. Edge Cases & Boundary Conditions
- Input null/undefined/None
- Empty arrays/strings
- Numeri negativi, zero, infinito
- Stringhe molto lunghe
- Overflow/underflow
- Concurrent access (se applicabile)

### 3. Framework Detection

Identifica il framework di testing appropriato:

**JavaScript/TypeScript**:
- Jest (default per React/Node)
- Vitest (per Vite projects)
- Mocha + Chai

**Python**:
- pytest (preferred)
- unittest

**Java**:
- JUnit 5

**Go**:
- testing package

### 4. Test Structure

Organizza i test seguendo il pattern **AAA** (Arrange-Act-Assert):

```javascript
describe('functionName', () => {
  it('should handle normal case', () => {
    // Arrange: Setup test data
    const input = 'test';

    // Act: Execute function
    const result = functionName(input);

    // Assert: Verify result
    expect(result).toBe('expected');
  });
});
```

### 5. Mocking & Stubbing

Per dependencies esterne, genera mocks appropriati:

```javascript
// Mock external dependencies
jest.mock('./database');
jest.mock('./api-client');

describe('serviceFunction', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should use mocked dependency', async () => {
    // Arrange
    database.query.mockResolvedValue([{ id: 1 }]);

    // Act & Assert
    const result = await serviceFunction();
    expect(database.query).toHaveBeenCalledWith(/* ... */);
  });
});
```

### 6. Test Coverage Goals

Punta a:
- **90%+ code coverage** per business logic
- **100% coverage** per funzioni critiche (payment, auth, security)
- Tutti i branch testati
- Tutti gli error paths testati

## Output Format

Genera i test in questo formato:

```
# Test Suite for [ComponentName]

## Test File: `[filename].test.[ext]`

[Complete test code]

## Coverage Analysis

- Lines covered: X%
- Branches covered: Y%
- Functions covered: Z%

## Test Cases Summary

1. ✅ Normal operations (X tests)
2. ✅ Error handling (Y tests)
3. ✅ Edge cases (Z tests)
4. ✅ Integration scenarios (W tests)

## Running the Tests

\`\`\`bash
[command to run tests]
\`\`\`

## Missing Coverage (if any)

[Areas that might need additional tests]
```

## Best Practices

### 1. Test Names
- Descrittivi e leggibili
- Formato: "should [expected behavior] when [condition]"
- Esempio: `should return null when user is not found`

### 2. Test Data
- Usa fixtures per dati complessi
- Evita magic values, usa named constants
- Crea test data builders per oggetti complessi

### 3. Assertions
- Una assertion principale per test (quando possibile)
- Usa matchers specifici (toEqual, toContain, toThrow, etc.)
- Assert su tutti gli aspetti rilevanti del risultato

### 4. Test Organization
- Raggruppa test correlati con `describe`
- Usa `beforeEach`/`afterEach` per setup/cleanup
- Mantieni test indipendenti (no shared state)

### 5. Performance
- Test veloci (< 100ms per unit test)
- Evita sleep/delays quando possibile
- Usa test parallelization se disponibile

## Esempi

### Esempio 1: Testing Pure Function

```javascript
// src/utils/calculator.js
export function add(a, b) {
  return a + b;
}

// src/utils/calculator.test.js
describe('add', () => {
  it('should add two positive numbers', () => {
    expect(add(2, 3)).toBe(5);
  });

  it('should handle negative numbers', () => {
    expect(add(-1, -1)).toBe(-2);
  });

  it('should handle zero', () => {
    expect(add(0, 5)).toBe(5);
  });

  it('should handle floating point numbers', () => {
    expect(add(0.1, 0.2)).toBeCloseTo(0.3);
  });
});
```

### Esempio 2: Testing Async Function with Mocks

```javascript
// src/services/user-service.test.js
import { getUserById } from './user-service';
import { database } from './database';

jest.mock('./database');

describe('getUserById', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should return user when found', async () => {
    // Arrange
    const mockUser = { id: 1, name: 'John' };
    database.query.mockResolvedValue([mockUser]);

    // Act
    const user = await getUserById(1);

    // Assert
    expect(user).toEqual(mockUser);
    expect(database.query).toHaveBeenCalledWith(
      'SELECT * FROM users WHERE id = ?',
      [1]
    );
  });

  it('should return null when user not found', async () => {
    database.query.mockResolvedValue([]);

    const user = await getUserById(999);

    expect(user).toBeNull();
  });

  it('should throw error when database fails', async () => {
    database.query.mockRejectedValue(new Error('DB Error'));

    await expect(getUserById(1)).rejects.toThrow('DB Error');
  });
});
```

## Tools Raccomandati

- `read_file`: Per leggere il codice sorgente da testare
- `write_file`: Per creare i file di test
- `bash`: Per eseguire i test e verificare coverage
- `grep`: Per trovare test esistenti e pattern
