---
name: building-gitlab-ci-components
description: Use when creating reusable GitLab CI/CD configurations, building component catalog entries, or packaging pipeline templates for sharing - provides systematic guide following GitLab documentation to avoid missing required files, directory structure, input specifications, or testing/publishing configuration
---

# Building GitLab CI Components

## Overview

GitLab CI components are reusable pipeline configuration units that can be versioned, shared, and discovered through the CI/CD Catalog. This skill guides you through creating complete, correct components following GitLab's official structure.

**Core principle:** Follow the GitLab documentation systematically. Components have specific requirements for directory structure, files, inputs, and CI/CD configuration that must be met for valid components.

## When to Use

Use this skill when:
- Creating a new reusable CI/CD component
- Packaging existing pipeline configuration for sharing
- Publishing components to the GitLab CI/CD Catalog
- Setting up a component project structure

## Critical Requirements Checklist

These are commonly missed - verify each one:

- [ ] **Directory structure**: `templates/` directory with components as `.yml` files or subdirectories with `template.yml`
- [ ] **Required files**: README.md, LICENSE.md, .gitlab-ci.yml present
- [ ] **Testing configuration**: .gitlab-ci.yml includes jobs to test component behavior
- [ ] **Publishing configuration**: .gitlab-ci.yml includes release job for catalog publishing
- [ ] **Input specification**: `spec:inputs` syntax correct with proper types and validation
- [ ] **Input usage**: Inputs referenced as `$[[ inputs.field-name ]]` in template
- [ ] **YAML separator**: `---` separator present between spec and job definitions
- [ ] **No hardcoded values**: Use `$CI_SERVER_FQDN` and inputs instead of hardcoded domains/values

## Directory Structure

### Single Component Project

```
my-component/
├── templates/
│   └── my-component.yml      # Component definition
├── README.md                  # Documentation with usage examples
├── LICENSE.md                 # Required license file
└── .gitlab-ci.yml            # Testing and publishing
```

### Multi-Component Project

```
my-components/
├── templates/
│   ├── component-one.yml                    # Simple single-file component
│   ├── component-two/                       # Multi-file component
│   │   ├── template.yml                     # Main template
│   │   └── supporting-script.sh             # Supporting files
│   └── component-three.yml
├── README.md                                 # Covers all components
├── LICENSE.md
└── .gitlab-ci.yml
```

**Limits:**
- Maximum 100 components per project (GitLab 18.5+)
- Earlier versions: 30 components maximum

## Component Template Structure

### Basic Template with Inputs

```yaml
spec:
  inputs:
    stage:
      type: string
      default: test
      description: "Pipeline stage for the job"

    dockerfile_path:
      type: string
      default: Dockerfile
      description: "Path to Dockerfile"

    image_name:
      type: string
      description: "Docker image name (required)"

    image_tag:
      type: string
      default: latest
      description: "Docker image tag"
---
build-docker-image:
  stage: $[[ inputs.stage ]]
  image: docker:latest
  script:
    - docker build -f $[[ inputs.dockerfile_path ]] -t $[[ inputs.image_name ]]:$[[ inputs.image_tag ]] .
```

**Key syntax:**
- `spec:inputs:` defines configurable parameters
- `---` separator required between spec and jobs
- `$[[ inputs.field-name ]]` for referencing inputs
- Inputs without `default` are required

### Input Specification

**Input attributes:**
- `type`: Data type (string, number, boolean, array)
- `default`: Default value (makes input optional)
- `description`: Documents the input purpose

**Validation options:**
- `type`: Enforces data type
- `regex`: Pattern validation (e.g., `^v\d+\.\d+(\.\d+)?$`)
- `options`: Restricts to allowed values (e.g., `['dev', 'staging', 'prod']`)

**Empty spec handling:**
```yaml
# If no inputs needed, use empty spec (not blank)
spec: {}
---
```

**Complete input specification reference:** https://docs.gitlab.com/ci/inputs/

## .gitlab-ci.yml for Testing

```yaml
# Test the component works correctly
test-component:
  stage: test
  trigger:
    include:
      - component: $CI_SERVER_FQDN/$CI_PROJECT_PATH/my-component@$CI_COMMIT_SHA
        inputs:
          image_name: test-image
          image_tag: test-tag
```

## .gitlab-ci.yml for Publishing

```yaml
# Publish to catalog when a tag is created
release:
  stage: deploy
  image: registry.gitlab.com/gitlab-org/release-cli:latest
  rules:
    - if: $CI_COMMIT_TAG =~ /^\d+\.\d+\.\d+$/  # Semantic version tags only
  script:
    - echo "Releasing version $CI_COMMIT_TAG"
  release:
    tag_name: $CI_COMMIT_TAG
    description: "Release $CI_COMMIT_TAG"
```

**Versioning requirements:**
- Use semantic versioning: `1.0.0`, `2.3.4`, etc.
- Tag precedence: commit SHA > tag > branch
- Partial versions supported: `1.2` matches latest `1.2.*`
- Use `~latest` for absolute latest version (not recommended for production)

## README.md Requirements

```markdown
# Component Name

Brief description of what the component does.

## Components

### component-name

Description of component functionality.

#### Inputs

| Input | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| stage | string | test | No | Pipeline stage |
| image_name | string | - | Yes | Docker image name |

#### Usage

\`\`\`yaml
include:
  - component: $CI_SERVER_FQDN/my-org/my-components/component-name@1.0.0
    inputs:
      image_name: myapp
      image_tag: v1.2.3
\`\`\`

## Contributing

Guidelines for contributing to this component.
```

**Required sections:**
- Component summary and capabilities
- Input documentation (use table format)
- Usage examples with `$CI_SERVER_FQDN` (never hardcode domain)
- For multi-component projects: table of contents and sections per component

## Best Practices

### Avoid Hardcoding

```yaml
# ❌ BAD: Hardcoded values
script:
  - curl https://gitlab.example.com/api/v4/projects

# ✅ GOOD: Use built-in variables
script:
  - curl $CI_API_V4_URL/projects
```

Use predefined variables instead of hardcoded values:
- `$CI_SERVER_FQDN` for domain names
- `$CI_API_V4_URL` for API references
- Inputs for user-configurable values

**All predefined variables:** https://docs.gitlab.com/ee/ci/variables/predefined_variables.html

### Avoid Global Keywords

```yaml
# ❌ BAD: Global default affects all jobs
default:
  image: alpine:latest

# ✅ GOOD: Define reusable config with extends
.base-config:
  image: alpine:latest

my-job:
  extends: .base-config
```

Global keywords like `default:` affect the entire pipeline, not just your component.

## Component Usage Format

```yaml
include:
  - component: <FQDN>/<project-path>/<component-name>@<version>
    inputs:
      field: value
```

**Example:**
```yaml
include:
  - component: $CI_SERVER_FQDN/my-org/security/secret-detection@1.0.0
    inputs:
      stage: security-scan
      fail_on_detection: true
```

## Common Mistakes

| Mistake | Consequence | Fix |
|---------|-------------|-----|
| Missing `templates/` directory | Component not recognized | Create `templates/` at project root |
| Blank `spec:inputs` | JSON schema validation error | Use `spec: {}` if no inputs needed |
| Missing `---` separator | YAML parsing error | Add `---` between spec and jobs |
| Wrong input reference syntax | Variable not interpolated | Use `$[[ inputs.name ]]` not `${inputs.name}` |
| No .gitlab-ci.yml testing | Component breaks without detection | Add test jobs that use the component |
| No .gitlab-ci.yml release job | Manual publishing required | Add automated release on version tags |
| Hardcoded domains | Component not portable | Use `$CI_SERVER_FQDN` and variables |
| Missing required inputs | Pipeline error for users | Either add `default` or document as required |

## Quick Start Workflow

1. **Create directory structure**
   ```bash
   mkdir -p my-component/templates
   touch my-component/README.md
   touch my-component/LICENSE.md
   touch my-component/.gitlab-ci.yml
   ```

2. **Create component template**
   - Create `templates/my-component.yml`
   - Add `spec:inputs` with validation
   - Add `---` separator
   - Define jobs using `$[[ inputs.field ]]` syntax

3. **Document in README**
   - Usage examples with `$CI_SERVER_FQDN`
   - Input table with types and descriptions
   - Contribution guidelines

4. **Configure testing**
   - Add test job to `.gitlab-ci.yml`
   - Test component with various input combinations

5. **Configure publishing**
   - Add release job triggered by semantic version tags
   - Test with a pre-release tag first

6. **Verify checklist**
   - Run through Critical Requirements Checklist above
   - Ensure no hardcoded values
   - Confirm all inputs documented

## Reference Documentation

For complete details, see:
- [GitLab CI Components Documentation](https://docs.gitlab.com/ci/components/)
- [Input Specification Reference](https://docs.gitlab.com/ci/inputs/)
- [Predefined Variables Reference](https://docs.gitlab.com/ee/ci/variables/predefined_variables.html)
- [CI/CD Catalog](https://docs.gitlab.com/ci/components/catalog.html)
