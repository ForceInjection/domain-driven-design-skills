---
name: emerging-specialty-skills
description: Master emerging technologies including blockchain, cybersecurity, QA testing, and specialized tech roles. Stay ahead with cutting-edge technologies.
sasmp_version: "1.3.0"
skill_type: atomic
version: "2.0.0"

parameters:
  domain:
    type: string
    enum: [blockchain, security, qa, iot, quantum]
    default: security
  context:
    type: string
    enum: [learning, implementation, audit]
    default: implementation

validation_rules:
  - pattern: "^0x[a-fA-F0-9]{40}$"
    target: ethereum_addresses
    message: Must be valid Ethereum address
  - pattern: "^test_.*$"
    target: test_functions
    message: Test functions must start with test_

retry_config:
  max_attempts: 3
  backoff: exponential
  initial_delay_ms: 1000

logging:
  on_entry: "[Emerging] Starting: {task}"
  on_success: "[Emerging] Completed: {task}"
  on_error: "[Emerging] Failed: {task} - {error}"

dependencies:
  agents:
    - emerging-tech-specialist
---

# Emerging Tech & Specialty Skills

## Blockchain & Smart Contracts

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SecureToken is ReentrancyGuard, Ownable {
    mapping(address => uint256) public balances;
    bool public paused;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Paused(address account);

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    constructor() Ownable(msg.sender) {
        balances[msg.sender] = 1000000 * 10**18;
    }

    // Checks-Effects-Interactions pattern
    function transfer(address to, uint256 amount)
        external
        nonReentrant
        whenNotPaused
    {
        // Checks
        require(to != address(0), "Invalid address");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // Effects
        balances[msg.sender] -= amount;
        balances[to] += amount;

        // Interactions (none in this case, but would go here)
        emit Transfer(msg.sender, to, amount);
    }

    function pause() external onlyOwner {
        paused = true;
        emit Paused(msg.sender);
    }
}
```

```javascript
// Ethers.js v6 - Interact with blockchain
import { ethers } from 'ethers';

async function interactWithContract() {
  const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

  const contract = new ethers.Contract(
    CONTRACT_ADDRESS,
    ABI,
    wallet
  );

  try {
    // Estimate gas first
    const gasEstimate = await contract.transfer.estimateGas(
      recipientAddress,
      amount
    );

    // Send transaction with buffer
    const tx = await contract.transfer(recipientAddress, amount, {
      gasLimit: gasEstimate * 120n / 100n  // 20% buffer
    });

    const receipt = await tx.wait();
    console.log(`TX confirmed: ${receipt.hash}`);
  } catch (error) {
    console.error('Transaction failed:', error.message);
  }
}
```

## Cybersecurity Best Practices

```python
# Security scanning with bandit
# bandit -r src/ -f json -o security-report.json

# Secure password hashing
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError

ph = PasswordHasher(
    time_cost=3,
    memory_cost=65536,
    parallelism=4
)

def hash_password(password: str) -> str:
    """Hash password with Argon2id."""
    return ph.hash(password)

def verify_password(hash: str, password: str) -> bool:
    """Verify password against hash."""
    try:
        ph.verify(hash, password)
        return True
    except VerifyMismatchError:
        return False

# Input validation
import re
from html import escape

def sanitize_input(user_input: str) -> str:
    """Sanitize user input to prevent XSS."""
    # Remove script tags
    cleaned = re.sub(r'<script.*?>.*?</script>', '', user_input, flags=re.DOTALL)
    # Escape HTML entities
    return escape(cleaned)

def validate_email(email: str) -> bool:
    """Validate email format."""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))
```

## QA & Testing Framework

```javascript
// Jest with comprehensive testing patterns
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

describe('Authentication Flow', () => {
  // Setup and teardown
  beforeEach(() => {
    jest.clearAllMocks();
    localStorage.clear();
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  // Happy path
  test('successful login redirects to dashboard', async () => {
    const mockLogin = jest.fn().mockResolvedValue({ token: 'abc123' });

    render(<LoginForm onLogin={mockLogin} />);

    await userEvent.type(screen.getByLabelText(/email/i), 'user@example.com');
    await userEvent.type(screen.getByLabelText(/password/i), 'securepass');
    await userEvent.click(screen.getByRole('button', { name: /login/i }));

    await waitFor(() => {
      expect(mockLogin).toHaveBeenCalledWith({
        email: 'user@example.com',
        password: 'securepass'
      });
    });
  });

  // Error handling
  test('displays error on invalid credentials', async () => {
    const mockLogin = jest.fn().mockRejectedValue(new Error('Invalid credentials'));

    render(<LoginForm onLogin={mockLogin} />);

    await userEvent.type(screen.getByLabelText(/email/i), 'bad@example.com');
    await userEvent.type(screen.getByLabelText(/password/i), 'wrongpass');
    await userEvent.click(screen.getByRole('button', { name: /login/i }));

    await waitFor(() => {
      expect(screen.getByRole('alert')).toHaveTextContent(/invalid credentials/i);
    });
  });

  // Edge cases
  test('prevents submission with empty fields', async () => {
    const mockLogin = jest.fn();

    render(<LoginForm onLogin={mockLogin} />);

    await userEvent.click(screen.getByRole('button', { name: /login/i }));

    expect(mockLogin).not.toHaveBeenCalled();
    expect(screen.getByText(/email is required/i)).toBeInTheDocument();
  });
});
```

```javascript
// Cypress E2E with best practices
describe('E-commerce Checkout', () => {
  beforeEach(() => {
    cy.intercept('GET', '/api/cart', { fixture: 'cart.json' }).as('getCart');
    cy.intercept('POST', '/api/checkout', { fixture: 'order.json' }).as('checkout');

    cy.login('test@example.com', 'password');  // Custom command
    cy.visit('/checkout');
    cy.wait('@getCart');
  });

  it('completes checkout successfully', () => {
    // Fill shipping info
    cy.get('[data-testid="shipping-form"]').within(() => {
      cy.get('input[name="address"]').type('123 Main St');
      cy.get('input[name="city"]').type('New York');
      cy.get('select[name="state"]').select('NY');
      cy.get('input[name="zip"]').type('10001');
    });

    // Fill payment info
    cy.get('[data-testid="payment-form"]').within(() => {
      cy.get('input[name="card"]').type('4242424242424242');
      cy.get('input[name="expiry"]').type('12/25');
      cy.get('input[name="cvv"]').type('123');
    });

    // Submit and verify
    cy.get('[data-testid="submit-order"]').click();
    cy.wait('@checkout');

    cy.url().should('include', '/order-confirmation');
    cy.get('[data-testid="order-number"]').should('exist');
  });
});
```

## Security Testing Checklist

```yaml
# OWASP Top 10 Testing Checklist
security_tests:
  injection:
    - SQL injection in all inputs
    - NoSQL injection
    - Command injection
    - LDAP injection
    status: [ ]

  authentication:
    - Password policy enforcement
    - Account lockout mechanism
    - Session management
    - MFA implementation
    status: [ ]

  sensitive_data:
    - Data encrypted at rest
    - Data encrypted in transit (TLS 1.3)
    - No sensitive data in logs
    - Secure key management
    status: [ ]

  access_control:
    - RBAC implementation
    - Privilege escalation tests
    - IDOR vulnerabilities
    - Path traversal
    status: [ ]

  security_headers:
    - Content-Security-Policy
    - X-Frame-Options
    - X-Content-Type-Options
    - Strict-Transport-Security
    status: [ ]
```

## Test Pyramid

```
        /\
       /  \        E2E Tests (10%)
      /    \       - Full user flows
     /------\      - Browser automation
    /        \
   /          \    Integration Tests (20%)
  /            \   - API contracts
 /--------------\  - Service integration
/                \
/                  \ Unit Tests (70%)
/--------------------\ - Fast, isolated
                       - Mock dependencies
```

## Troubleshooting Guide

| Symptom | Cause | Solution |
|---------|-------|----------|
| Reentrancy exploit | No guard | Use ReentrancyGuard |
| Gas too high | Inefficient code | Optimize loops, storage |
| Test flaky | Async issues | Add proper waits |
| False positive | Scanner too sensitive | Tune rules |

## Key Concepts Checklist

- [ ] Blockchain basics and smart contracts
- [ ] Cryptocurrency fundamentals
- [ ] Security testing and vulnerability assessment
- [ ] Penetration testing basics
- [ ] OWASP Top 10
- [ ] Unit and integration testing
- [ ] Test automation frameworks
- [ ] Performance testing
- [ ] CI/CD testing
- [ ] Kotlin programming
- [ ] Emerging tech trends
- [ ] Career specialization paths

---

**Source**: https://roadmap.sh
**Version**: 2.0.0
**Last Updated**: 2025-01-01
