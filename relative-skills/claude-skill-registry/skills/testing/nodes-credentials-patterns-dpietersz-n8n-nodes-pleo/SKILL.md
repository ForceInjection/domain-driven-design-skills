---
name: Nodes Credentials Patterns
description: Implement n8n credential types including API key, OAuth2, and header-based authentication patterns. Use this skill when creating *.credentials.ts files, implementing ICredentialType interfaces, configuring OAuth2 flows, setting up credential testing, injecting authentication headers, or following credential security best practices. Apply when building any n8n node that requires API authentication, token management, or secure credential handling.
---

## When to use this skill:

- When creating new credential files (*.credentials.ts)
- When implementing ICredentialType interfaces
- When setting up API key authentication
- When configuring OAuth2 credential flows
- When implementing header-based authentication with the authenticate property
- When adding credential testing with ICredentialTestRequest
- When using getCredentials() in node execute methods
- When handling production vs sandbox environments
- When implementing token refresh logic for OAuth2
- When following security best practices (never log credentials, use password typeOptions)
- When declaring credentials in node description
- When testing credential validation in n8n UI

# Nodes Credentials Patterns

This Skill provides Claude Code with specific guidance on how to adhere to coding standards as they relate to how it should handle nodes credentials patterns.

## Instructions

For details, refer to the information provided in this file:
[nodes credentials patterns](../../../agent-os/standards/nodes/credentials-patterns.md)
