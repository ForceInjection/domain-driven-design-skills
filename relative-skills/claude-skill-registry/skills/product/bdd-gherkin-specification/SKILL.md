---
name: bdd-gherkin-specification
description: Create Behavior-Driven Development (BDD) feature files using Gherkin syntax. Write clear, executable specifications that describe system behavior from the user's perspective. Use for requirements documentation, acceptance criteria, and living documentation.
version: 2.0.0
---

# BDD & Gherkin Specification

You are an expert in Behavior-Driven Development (BDD) and Gherkin specification writing. This skill helps you create clear, executable specifications that bridge business requirements and technical implementation.

## What is BDD?

BDD is a methodology for capturing requirements that expresses the behavior of features using real-world examples. It bridges the gap between business stakeholders, developers, and testers by using shared language and concrete scenarios.

## What is Gherkin?

Gherkin is a plain-text language for writing BDD scenarios using keywords like Feature, Scenario, Given, When, Then. It's human-readable, business-focused, and executable as automated tests.

## When to Use This Skill

**USE when:**
- Defining acceptance criteria for user stories
- Creating living documentation
- Bridging communication gaps between technical and non-technical stakeholders
- Specifying complex business rules
- Working in cross-functional teams

**DO NOT USE when:**
- Requirements are purely technical (architecture, refactoring)
- Team is small and co-located with constant communication
- Features are too simple to warrant formal specification

## Quick Start

**Basic Gherkin Structure:**
```gherkin
Feature: User Login

  Scenario: Successful login with valid credentials
    Given the user is on the login page
    When the user enters valid credentials
    Then the user should be redirected to the dashboard
```

## Available Resources

### Core Documentation

- **[gherkin-syntax.md](reference/gherkin-syntax.md)** - Complete Gherkin language reference
  - Basic structure and file naming
  - Given-When-Then detailed explanation
  - All keywords (Feature, Scenario, Background, Scenario Outline, Rule)
  - AND/BUT usage
  - Read when: Writing your first feature file or need keyword reference

- **[best-practices.md](reference/best-practices.md)** - Writing effective scenarios
  - Declarative vs imperative style
  - Keep scenarios focused and independent
  - Consistent language and perspective
  - Clear outcomes and business value
  - Read when: Reviewing or improving scenario quality

- **[examples.md](reference/examples.md)** - Real-world feature file examples
  - Complete feature files across different domains
  - Product search, shopping cart, authentication
  - Background and Scenario Outline usage
  - Side-by-side comparisons (good vs bad)
  - Read when: Need inspiration or want to see patterns in action

### Advanced Topics

- **[anti-patterns.md](reference/anti-patterns.md)** - Common mistakes and how to avoid them
  - Testing implementation vs behavior
  - Overly technical language
  - Dependent scenarios
  - UI-centric vs behavior-centric
  - Read when: Troubleshooting or code review

- **[organization.md](reference/organization.md)** - Structuring large feature file suites
  - Directory structure patterns
  - When to split features
  - Using Rules to group scenarios
  - Team collaboration patterns
  - Read when: Setting up project structure or scaling BDD adoption

- **[quick-reference.md](reference/quick-reference.md)** - Cheat sheet and templates
  - Feature file template to copy
  - Keywords at a glance
  - Common patterns
  - Quick decision tree
  - Read when: Need fast lookup or reminder

## Key Principles

1. **Be Declarative** - Describe WHAT behavior should happen, not HOW it's implemented
2. **Stay Focused** - One scenario = one behavior (5-10 steps max)
3. **Stay Independent** - Scenarios should not depend on each other
4. **Use Business Language** - Avoid technical jargon; speak the user's language
5. **Make it Readable** - Anyone on the team should understand the scenario

## Typical Workflow

1. **Start with Examples** - Read [examples.md](reference/examples.md) to see patterns
2. **Learn Syntax** - Reference [gherkin-syntax.md](reference/gherkin-syntax.md) for keywords
3. **Write Scenarios** - Use [quick-reference.md](reference/quick-reference.md) template
4. **Review Quality** - Check against [best-practices.md](reference/best-practices.md)
5. **Avoid Mistakes** - Scan [anti-patterns.md](reference/anti-patterns.md) during review

## Quick Tips

- Write scenarios BEFORE code (they're specifications, not tests)
- Each scenario should be understandable in isolation
- Use Background for common setup across scenarios
- Use Scenario Outline for testing multiple similar cases
- Use Rule to group related scenarios
- Keep feature files under 20 scenarios (split if larger)

## File Naming Convention

Use lowercase with underscores: `user_authentication.feature`, `shopping_cart_checkout.feature`

## Remember

BDD scenarios are **conversations written down**, not test scripts. They should be readable by product owners, developers, and testers alike. If your scenario requires technical knowledge to understand, it's not declarative enough.

---

**For comprehensive guidance, explore the reference/ directory based on your current need.**
