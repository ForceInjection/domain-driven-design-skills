---
name: Creating Service Scaffolds
description: Creates standardized directory structure and boilerplate files for new microservices or feature modules, ensuring compliance with repository standards and development best practices. Use when creating new services, major feature modules, establishing consistent patterns across distributed systems, or when the user mentions scaffolding, boilerplate, or new service creation.
---

# Creating Service Scaffolds

Create standardized directory structure and boilerplate for microservices and feature modules.

## What you should do

1. **Analyze project structure and language** – Examine the repository root for:
   - Language-specific files (`package.json`, `pyproject.toml`, `go.mod`, etc.)
   - Existing service directories or modules to understand naming conventions
   - Configuration files (`.eslintrc`, `pytest.ini`, `docker-compose.yml`)
   - Testing framework and directory structure (`tests/`, `spec/`, `__tests__/`)

2. **Determine service name and location** – Based on the project structure:
   - Use kebab-case for directory names (e.g., `user-service`, `payment-gateway`)
   - Place services in appropriate location (`services/`, `apps/`, `src/services/`)
   - Ensure name doesn't conflict with existing modules

3. **Create standard directory structure** – Generate the following directories:
   - `/src` – Main source code
   - `/tests/unit` – Unit tests
   - `/tests/integration` – Integration tests  
   - `/tests/fixtures` – Test data and mocks
   - `/docs` – Service-specific documentation
   - `/config` – Configuration files (if applicable)

4. **Generate core boilerplate files** – Create language-appropriate files:
   - Main entry point (`index.js`, `main.py`, `main.go`, etc.)
   - Configuration handler (`config.js`, `settings.py`, `config.go`)
   - Error handling utilities (`errors.js`, `exceptions.py`)
   - Basic service interface or API definition

5. **Create testing scaffolding** – Generate test files:
   - Unit test template with framework imports and basic structure
   - Integration test template with service initialization
   - Mock data files in `/tests/fixtures`
   - Test configuration file if needed

6. **Generate service documentation** – Create initial documentation:
   - `README.md` with service overview, setup instructions, and API reference
   - `CHANGELOG.md` for tracking service versions
   - `API.md` or OpenAPI specification (if service exposes APIs)
   - Architecture decision records template in `/docs/adr/`

7. **Create CI/CD configuration** – Generate pipeline files:
   - Service-specific build steps (Docker, build scripts)
   - Test execution configuration
   - Deployment configuration templates
   - Quality gates and code coverage requirements

8. **Setup dependency management** – Initialize dependency files:
   - Language-specific dependency file (`package.json`, `requirements.txt`, `go.mod`)
   - Development dependencies for testing and linting
   - Lock files for reproducible builds

9. **Configure linting and formatting** – Setup code quality tools:
   - Copy or inherit project-wide linting configuration
   - Service-specific linting rules if needed
   - Pre-commit hooks for code quality enforcement
   - Code formatting configuration

10. **Generate service templates** – Create reusable code templates:
    - Controller/handler templates with standard patterns
    - Model/entity templates with validation
    - Service layer templates with error handling
    - Database migration templates (if applicable)

11. **Initialize version control** – Setup service tracking:
    - Add service to main project documentation
    - Update root `README.md` with service reference
    - Create initial git commit for service structure
    - Tag initial service version

12. **Validate and test scaffold** – Verify the generated structure:
    - Run dependency installation
    - Execute initial test suite to ensure framework works
    - Validate linting passes on generated code
    - Check that build process completes successfully
    - Generate scaffold report with next steps and recommendations