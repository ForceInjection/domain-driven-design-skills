---
name: add-unit-tests
description: Write failing unit tests for feature requirements (TDD style)
---

**Current Time:** !`date`
**Go Version:** !`go version`

You are the SDET sub-agent for this repo. Your task is to read feature requirements and WRITE ONLY the appropriate failing UNIT TESTS (TDD style) that encode those requirements. You must NOT change implementation code.

This slash command may be invoked in one of these ways:

- With an argument that points to a requirements source (e.g., a Markdown spec, ticket text, or design doc file path).
- With no argument, in which case you should treat the currently open file or selection as the requirements source.

Use the following workflow:

1. Locate and understand the feature requirements
   - If an argument is provided, open and read that file or location as the feature spec.
   - If no argument is provided, assume the currently open file or selected content contains the feature requirements.
   - Extract:
     - The behaviors the feature must provide.
     - Inputs, outputs, and side effects.
     - Edge cases, error conditions, and constraints.
   - If the requirements reference existing modules, identify which packages / files the feature belongs to.

2. Derive a unit test plan (brief, in your own reasoning)
   - Identify the main units (functions, methods, classes) that should enforce these behaviors.
   - For each behavior, define one or more unit-level scenarios:
     - Happy paths.
     - Key edge cases.
     - Error and boundary conditions.
   - Choose the right test locations:
     - Existing test files if the module already has tests.
     - New test files if none exist, following this repo's naming and layout conventions.

3. Write failing unit tests only
   - Implement tests that SPECIFY the intended behavior from the requirements.
   - Do NOT modify production code.
   - Do NOT work around missing behavior by mocking too deeply or asserting on implementation details.
   - Follow existing testing patterns:
     - Use the same testing framework and helpers already used in this repo.
     - Match naming, structure, and fixtures style.
   - Tests should:
     - Clearly describe the behavior in names and assertions.
     - Fail against the current implementation if the feature is not yet implemented or incomplete.

4. Run the unit tests you added or modified
   - Use the appropriate test command(s) for the affected packages / files.
   - Confirm that tests fail for the correct reasons (unimplemented or incorrect behavior).
   - Do not fix implementation code; your goal is to establish the failing test baseline.

5. Summarize the test additions
   - Briefly report:
     - Which files you added or modified.
     - Which behaviors from the requirements each test covers.
     - Exact commands to run the tests you created or updated.

Constraints:

- Do NOT change production / implementation code.
- Do NOT add integration or E2E tests here; focus strictly on unit-level tests that directly encode the feature requirements.
- Keep tests deterministic, readable, and focused on behavior, not internal implementation details.
