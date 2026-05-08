---
name: openrouter-config-validator
description: Configuration validation and testing utilities for OpenRouter API. Use when validating API keys, testing model availability, checking routing configuration, troubleshooting connection issues, analyzing usage costs, or when user mentions OpenRouter validation, config testing, API troubleshooting, model availability, or cost analysis.
allowed-tools: Bash, Read, Write, Grep, Glob
---

# OpenRouter Config Validator

Comprehensive validation and testing utilities for OpenRouter API configuration, model availability, routing setup, and cost monitoring.

## What This Skill Provides

1. **API Key Validation**: Format checking and connectivity testing
2. **Model Availability Checking**: Verify requested models are accessible
3. **Routing Configuration Testing**: Validate model routing and fallback chains
4. **Environment Validation**: Check .env file completeness and correctness
5. **Fallback Testing**: Test fallback chain execution and behavior
6. **Provider Status Checking**: Monitor provider availability and health
7. **Usage Analysis**: Track API usage patterns and cost optimization
8. **Troubleshooting**: Comprehensive diagnostic tools for common issues

## Instructions

### Phase 1: Identify Validation Need

Determine what needs validation:
- API key format and connectivity
- Model availability and access
- Routing configuration correctness
- Environment variable completeness
- Fallback chain behavior
- Provider health status
- Usage patterns and costs
- General troubleshooting

### Phase 2: Run Appropriate Validation Script

Execute the relevant validation script from `scripts/` directory:

**API Key Validation:**
```bash
bash scripts/validate-api-key.sh <api-key>
```

**Model Availability Check:**
```bash
bash scripts/check-model-availability.sh <model-id>
```

**Routing Configuration Test:**
```bash
bash scripts/test-routing.sh <config-file>
```

**Environment Validation:**
```bash
bash scripts/validate-env-config.sh <env-file>
```

**Fallback Chain Testing:**
```bash
bash scripts/test-fallback.sh <fallback-config>
```

**Provider Status Check:**
```bash
bash scripts/check-provider-status.sh <provider-name>
```

**Usage Analysis:**
```bash
bash scripts/analyze-usage.sh <date-range>
```

**Comprehensive Troubleshooting:**
```bash
bash scripts/troubleshoot.sh
```

### Phase 3: Load Appropriate Template

Use templates from `templates/` directory for configuration:

**Environment Setup:**
- `templates/.env.template` - Complete configuration template
- `templates/.env.example` - Minimal configuration example

**Monitoring Configuration:**
- `templates/monitoring-config.json` - X-Title and HTTP-Referer setup
- `templates/budget-alerts.json` - Cost alert configuration

**Provider Preferences:**
- `templates/provider-preferences.json` - Provider routing preferences

### Phase 4: Reference Troubleshooting Examples

Check `examples/` directory for common issue resolutions:

- `examples/api-key-troubleshooting.md` - API key issues
- `examples/model-not-found.md` - Model availability problems
- `examples/rate-limiting.md` - Rate limit handling
- `examples/fallback-issues.md` - Fallback chain debugging
- `examples/cost-optimization.md` - Cost reduction strategies
- `examples/provider-errors.md` - Provider-specific errors

### Phase 5: Report Results

Summarize validation results:
- What was tested
- Issues found (if any)
- Recommended fixes
- Next steps

## When Agents Should Use This Skill

**Automatic triggers:**
- Setting up new OpenRouter integration
- Debugging API connection failures
- Validating configuration before deployment
- Troubleshooting model access issues
- Analyzing unexpected API costs
- Testing fallback chain behavior
- Monitoring provider health

**User-requested scenarios:**
- "Validate my OpenRouter configuration"
- "Test if model X is available"
- "Why is my fallback chain not working?"
- "Check my API usage costs"
- "Troubleshoot OpenRouter connection"
- "Verify my routing configuration"

## Validation Capabilities

### API Key Validation
- Format checking (sk-or-v1-* pattern)
- Connectivity testing via /auth/key endpoint
- Permission verification
- Credit balance checking

### Model Availability
- Model ID existence verification
- Provider availability checking
- Access permission validation
- Alternative model suggestions

### Configuration Testing
- .env file completeness
- Required variable presence
- Format validation
- Value sanity checks

### Routing Validation
- Model routing configuration
- Fallback chain structure
- Provider preference validation
- Cost optimization checks

### Usage Analysis
- Request volume tracking
- Cost breakdowns by model
- Provider distribution
- Rate limit monitoring
- Budget alert configuration

## Script Reference

All scripts located in `skills/openrouter-config-validator/scripts/`:

1. `validate-api-key.sh` - API key format and connectivity
2. `check-model-availability.sh` - Model access verification
3. `test-routing.sh` - Routing configuration testing
4. `validate-env-config.sh` - Environment validation
5. `test-fallback.sh` - Fallback chain testing
6. `check-provider-status.sh` - Provider health monitoring
7. `analyze-usage.sh` - Usage pattern analysis
8. `troubleshoot.sh` - Comprehensive diagnostics

## Template Reference

All templates located in `skills/openrouter-config-validator/templates/`:

1. `.env.template` - Complete environment configuration
2. `.env.example` - Minimal configuration example
3. `monitoring-config.json` - Request monitoring setup
4. `budget-alerts.json` - Cost alert configuration
5. `provider-preferences.json` - Provider routing preferences

## Example Reference

All examples located in `skills/openrouter-config-validator/examples/`:

1. `api-key-troubleshooting.md` - Common API key issues
2. `model-not-found.md` - Model availability solutions
3. `rate-limiting.md` - Rate limit handling strategies
4. `fallback-issues.md` - Fallback debugging guide
5. `cost-optimization.md` - Cost reduction techniques
6. `provider-errors.md` - Provider-specific error handling

## Requirements

- bash 4.0+
- curl (for API testing)
- jq (for JSON parsing)
- OpenRouter API key (for live testing)
- Internet connectivity (for API calls)

---

**Skill Location**: plugins/openrouter/skills/openrouter-config-validator/
**Version**: 1.0.0
