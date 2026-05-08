---
name: Testing N8n Testing
description: Test n8n nodes using Jest, nock for HTTP mocking, and local testing workflows with npm link. Use this skill when writing test files in __tests__ folders, mocking HTTP requests with nock, creating mock IExecuteFunctions contexts, testing helper functions, setting up golden file tests, running the linter before publishing, or locally testing nodes in the n8n UI. Apply when organizing test files, mocking external APIs, validating node execution output, or following the pre-publish checklist.
---

## When to use this skill:

- When creating test files in __tests__/ folders
- When writing Jest test suites for n8n nodes
- When mocking HTTP requests with nock (beforeAll, afterEach, afterAll patterns)
- When testing helper functions for data formatting
- When creating mock IExecuteFunctions for node execution tests
- When verifying node output against expected results
- When testing API error handling (401, 404, 429 responses)
- When setting up golden file tests for complex output
- When linking nodes locally for manual testing (npm link)
- When using n8n dev mode with hot reload
- When running npm run lint before publishing
- When following the pre-publish checklist (tests pass, build succeeds, manual testing)
- When testing credentials save and validation in n8n UI

# Testing N8n Testing

This Skill provides Claude Code with specific guidance on how to adhere to coding standards as they relate to how it should handle testing n8n testing.

## Instructions

For details, refer to the information provided in this file:
[testing n8n testing](../../../agent-os/standards/testing/n8n-testing.md)
