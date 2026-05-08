---
name: requirements-writing
description: Write clear, testable requirements using User Stories and Gherkin scenarios. Capture functional and non-functional requirements with proper acceptance criteria. Use when defining new features or documenting system behavior.
---

# Requirements Writing Skill

You are assisting with writing clear, testable requirements that drive development and testing.

## Core Principles

### Requirements Should Be
- **Clear**: Unambiguous and understandable
- **Testable**: Can be verified through testing
- **Complete**: All necessary information included
- **Consistent**: No contradictions
- **Traceable**: Linked to business needs
- **Feasible**: Technically and economically possible

## Primary Format: User Stories + Gherkin

### User Stories (High-Level Features)

**Format**:
```
As a [role]
I want [feature/capability]
So that [benefit/value]
```

**Good Examples**:
```
As an applicant
I want to see my calculated competence points
So that I understand my admission chances

As an admission officer
I want to apply quota rules automatically
So that I can process applications efficiently and fairly
```

**Bad Examples**:
```
As a user, I want a button                    # Too vague
As a developer, I want to use React           # Technical, not user-focused
The system should calculate points            # Not user-story format
```

### Acceptance Criteria (Detailed Requirements)

For each user story, define acceptance criteria using Gherkin scenarios.

**Gherkin Format**:
```gherkin
Feature: [Feature name and brief description]
  [Optional: Longer description explaining business value]

  Scenario: [Specific situation to test]
    Given [initial context/preconditions]
    And [additional context]
    When [action/event occurs]
    Then [expected outcome]
    And [additional expectations]
```

### Complete Example for Admission System

```gherkin
Feature: Minimum Grade Requirement Evaluation
  As an admission system
  I need to evaluate if students meet minimum grade requirements
  So that only qualified applicants are admitted to programs

  Scenario: Student meets minimum grade requirement
    Given a student has Math grade 5
    And the program requires minimum Math grade 4
    When evaluating the admission rule
    Then the student should pass the grade requirement
    And the evaluation reason should be "Meets minimum grade"

  Scenario: Student fails minimum grade requirement
    Given a student has Math grade 3
    And the program requires minimum Math grade 4
    When evaluating the admission rule
    Then the student should fail the grade requirement
    And the evaluation reason should be "Below minimum grade of 4"

  Scenario: Student missing required subject
    Given a student has no Math grade
    And the program requires minimum Math grade 4
    When evaluating the admission rule
    Then the student should fail the grade requirement
    And the evaluation reason should be "Missing required subject: Math"

  Scenario: Exact boundary case
    Given a student has Math grade 4
    And the program requires minimum Math grade 4
    When evaluating the admission rule
    Then the student should pass the grade requirement
```

## Gherkin Best Practices

### 1. Use Domain Language
Use terms from the ubiquitous language (DDD):
```gherkin
# GOOD
Given a student has completed videregående education
When calculating competence points

# BAD
Given the user has a high school diploma
When doing the calculation
```

### 2. One Scenario, One Behavior
```gherkin
# GOOD - Tests one thing
Scenario: Quota full prevents admission
  Given a quota has capacity 100
  And 100 students are already admitted
  When admitting a new student
  Then admission should be rejected

# BAD - Tests multiple things
Scenario: Quota and grade checks
  Given a quota is full
  And student has low grades
  When admitting student
  Then both checks fail
```

### 3. Use Background for Common Setup
```gherkin
Feature: Quota Assignment

  Background:
    Given a program "Computer Science" exists
    And the program has the following quotas:
      | Quota Name          | Capacity |
      | Ordinary            | 100      |
      | Special Competence  | 20       |

  Scenario: First-time applicant assigned to ordinary quota
    Given a student is a first-time applicant
    When assigning quota
    Then the student should be assigned to "Ordinary" quota
```

### 4. Use Scenario Outlines for Multiple Cases
```gherkin
Scenario Outline: Grade to competence points conversion
  Given a student has a grade of <grade>
  When calculating competence points
  Then the points should be <points>

  Examples:
    | grade | points |
    | 6     | 24     |
    | 5     | 20     |
    | 4     | 16     |
    | 3     | 12     |
    | 2     | 8      |
    | 1     | 4      |
```

## Requirements Categories

### 1. Functional Requirements
What the system must do.

**User Story**:
```
As an admission officer
I want to rank all applicants by their competence points
So that I can select the top candidates for admission
```

**Gherkin Scenario**:
```gherkin
Scenario: Applicants ranked by competence points
  Given the following applicants:
    | Name    | Points |
    | Alice   | 55     |
    | Bob     | 48     |
    | Charlie | 52     |
  When ranking applicants
  Then the ranking should be:
    | Rank | Name    |
    | 1    | Alice   |
    | 2    | Charlie |
    | 3    | Bob     |
```

### 2. Non-Functional Requirements
How the system should behave.

**Categories**:
- Performance (response time, throughput)
- Security (authentication, authorization)
- Reliability (uptime, error handling)
- Usability (accessibility, UX)
- Maintainability (code quality, documentation)

**Format**:
```
The system shall [requirement]
Measured by [metric]
```

**Examples**:
```
The system shall evaluate admission rules within 2 seconds
Measured by: Response time for rule evaluation API

The system shall handle 1000 concurrent users
Measured by: Load testing with 1000 simulated users

The system shall maintain 99.9% uptime
Measured by: Monthly uptime percentage
```

### 3. Business Rules
Constraints and policies from the domain.

```gherkin
Feature: Quota Priority Rules
  Business Rule: Students with special competence qualifications
  have priority over ordinary applicants when quotas overlap.

  Scenario: Special competence takes priority
    Given a student qualifies for both ordinary and special quotas
    And special competence quota has available spots
    When assigning quota
    Then the student must be assigned to special competence quota
```

## Requirements Organization

### Directory Structure
```
requirements/
├── user-stories/
│   ├── applicant-stories.md
│   ├── officer-stories.md
│   └── administrator-stories.md
├── features/
│   ├── admission-evaluation.feature
│   ├── quota-management.feature
│   ├── competence-calculation.feature
│   └── reporting.feature
├── business-rules/
│   ├── norwegian-admission-rules.md
│   └── quota-policies.md
└── non-functional/
    ├── performance-requirements.md
    └── security-requirements.md
```

## Requirement Quality Checklist

Use the **INVEST** criteria for user stories:
- [ ] **Independent**: Can be developed independently
- [ ] **Negotiable**: Details can be discussed
- [ ] **Valuable**: Delivers value to users
- [ ] **Estimable**: Can estimate effort
- [ ] **Small**: Can be completed in one iteration
- [ ] **Testable**: Can verify when done

For Gherkin scenarios:
- [ ] Uses domain language
- [ ] Tests one specific behavior
- [ ] Has clear Given-When-Then structure
- [ ] Includes edge cases and error conditions
- [ ] Is executable (can be automated with pytest-bdd)

## Example Mapping (Discovery Technique)

Before writing requirements, use Example Mapping to explore:

```
Rule: Students must have minimum grade 4 in Math

Examples:
  ✓ Math grade 5 → Passes
  ✓ Math grade 4 → Passes (boundary)
  ✗ Math grade 3 → Fails
  ✗ No Math grade → Fails

Questions:
  ? What if student took Math abroad (different grading)?
  ? What if Math was taken before 2020 (old system)?
  ? Does "Math" include both Math S1+S2?
```

Then write Gherkin scenarios for each example + questions.

## Integration with TDD

Requirements drive test development:

1. **Write User Story**: Define what's needed
2. **Write Gherkin Scenarios**: Define acceptance criteria
3. **Generate Test Cases**: Convert scenarios to pytest tests
4. **Implement TDD**: Red-Green-Refactor cycle

**Traceability**:
```
User Story → Gherkin Scenario → pytest Test → Implementation
```

## Norwegian Admission System Examples

### Example 1: Competence Points Calculation
```
User Story:
As an applicant
I want my competence points calculated automatically
So that I know my competitive score for admission

Acceptance Criteria:
```

```gherkin
Feature: Competence Points Calculation
  Points are calculated based on Norwegian upper secondary grades
  using the formula: grade × 4 points per grade

  Scenario: Calculate points for complete grade set
    Given a student has the following grades:
      | Subject    | Grade |
      | Math       | 5     |
      | Norwegian  | 4     |
      | English    | 6     |
    When calculating total competence points
    Then the total should be 60 points
    And the breakdown should be:
      | Subject    | Points |
      | Math       | 20     |
      | Norwegian  | 16     |
      | English    | 24     |
```

### Example 2: Quota Management
```
User Story:
As an admission officer
I want quotas to prevent over-admission
So that program capacity is not exceeded

Acceptance Criteria:
```

```gherkin
Feature: Quota Capacity Enforcement

  Scenario: Prevent admission when quota is full
    Given an "Engineering" quota with capacity 100
    And 100 students are already admitted
    When attempting to admit another student
    Then the admission should be rejected
    And the rejection reason should be "Quota capacity reached"

  Scenario: Allow admission when quota has space
    Given an "Engineering" quota with capacity 100
    And 95 students are already admitted
    When attempting to admit another student
    Then the admission should be accepted
    And the quota filled count should be 96
```

## Response Format

When writing requirements:
1. Start with a user story to capture WHO, WHAT, WHY
2. Add Gherkin scenarios for detailed acceptance criteria
3. Include happy path, edge cases, and error conditions
4. Use domain language consistently
5. Ensure scenarios are testable and executable
6. Link requirements to business rules
7. Consider non-functional requirements

## Tools for Requirements Management

- **BDD Tools**: pytest-bdd, behave (Python)
- **Documentation**: Markdown, Gherkin .feature files
- **Collaboration**: Example Mapping sessions
- **Traceability**: Link stories → scenarios → tests → code
