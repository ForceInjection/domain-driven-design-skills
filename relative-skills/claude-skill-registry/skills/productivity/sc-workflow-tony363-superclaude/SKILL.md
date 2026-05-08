---
name: sc-workflow
description: Generate structured implementation workflows from PRDs and feature requirements. Use when planning implementations, decomposing features, or coordinating multi-domain development.
---

# Implementation Workflow Generator Skill

Transform PRDs and requirements into structured implementation plans.

## Quick Start

```bash
# PRD-based workflow
/sc:workflow feature-spec.md --strategy systematic --depth deep

# Feature workflow
/sc:workflow "user auth system" --strategy agile --parallel

# Enterprise planning
/sc:workflow enterprise-prd.md --strategy enterprise --validate
```

## Behavioral Flow

1. **Analyze** - Parse PRD and feature specifications
2. **Plan** - Generate workflow structure with dependencies
3. **Coordinate** - Activate personas for domain expertise
4. **Execute** - Create step-by-step workflows
5. **Validate** - Apply quality gates and completeness checks

## Flags

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--strategy` | string | systematic | systematic, agile, enterprise |
| `--depth` | string | normal | shallow, normal, deep |
| `--parallel` | bool | false | Enable parallel task generation |
| `--validate` | bool | false | Include quality gates |

## Personas Activated

- **architect** - System design and technical planning
- **analyzer** - Requirements analysis
- **frontend** - UI/UX implementation planning
- **backend** - API and data layer planning
- **security** - Security requirements integration
- **devops** - Infrastructure and deployment planning
- **project-manager** - Timeline and resource coordination

## MCP Integration

- **PAL MCP** - Consensus for high-risk decisions
- **Rube MCP** - Backlog updates and notifications

## Evidence Requirements

This skill does NOT require hard evidence. Deliverables are:
- Structured workflow documentation
- Task dependency maps
- Implementation phases

## Workflow Strategies

### Systematic (`--strategy systematic`)
- Comprehensive task decomposition
- Full dependency mapping
- Documentation-heavy approach

### Agile (`--strategy agile`)
- Sprint-oriented planning
- User story focused
- Iterative milestones

### Enterprise (`--strategy enterprise`)
- Compliance integration
- Stakeholder alignment
- Risk assessment included

## Workflow Components

### Task Decomposition
- Feature breakdown into implementable units
- Clear acceptance criteria
- Effort estimation

### Dependency Mapping
- Task prerequisites
- Blocking relationships
- Parallel execution opportunities

### Quality Gates
- Testing requirements
- Review checkpoints
- Deployment criteria

## Examples

### PRD Analysis
```
/sc:workflow docs/PRD/feature.md --strategy systematic --depth deep
# Full PRD parsing with comprehensive workflow
# Multi-persona coordination for complete plan
```

### Feature Implementation
```
/sc:workflow "payment integration" --strategy agile --parallel
# Sprint-ready task breakdown
# Parallel frontend/backend tracks
```

### Enterprise Planning
```
/sc:workflow enterprise-spec.md --strategy enterprise --validate
# Compliance-aware workflow
# Security and devops integration
```

### Quick Planning
```
/sc:workflow "add search feature" --depth shallow
# Rapid task list generation
# High-level milestone planning
```

## Output Structure

Workflows include:
1. **Overview** - Feature summary and scope
2. **Phases** - Implementation stages
3. **Tasks** - Detailed work items
4. **Dependencies** - Task relationships
5. **Milestones** - Key checkpoints
6. **Risks** - Identified concerns

## Tool Coordination

- **Read/Write** - PRD analysis and documentation
- **TodoWrite** - Progress tracking
- **Task** - Parallel workflow generation
- **WebSearch** - Technology research
