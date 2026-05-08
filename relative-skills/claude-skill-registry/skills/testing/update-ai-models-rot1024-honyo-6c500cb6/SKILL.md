---
name: update-ai-models
description: Search the web for the latest AI models from Anthropic, OpenAI, and Google, then update src/models.ts with new model IDs. Use when user asks to update or add AI models.
---

# Update AI Models

Search for the latest AI models and update the model list in this project.

## Instructions

1. **Search for latest models** from each provider:
   - Anthropic Claude models (claude-opus, claude-sonnet, claude-haiku)
   - OpenAI models (GPT series, o-series reasoning models)
   - Google Gemini models

2. **Get exact model IDs** from official documentation:
   - Anthropic: https://docs.anthropic.com/en/docs/about-claude/models/overview
   - OpenAI: https://platform.openai.com/docs/models
   - Google: https://ai.google.dev/gemini-api/docs/models

3. **Update src/models.ts**:
   - Add new models with correct `model` ID strings
   - Keep `claude-4.5-sonnet` as the first entry (default model)
   - Order models by recency within each provider section
   - Remove deprecated models

4. **Run verification**:
   ```bash
   npm run typecheck
   npm run build
   npm test
   ```

## Model Entry Format

```typescript
'model-key': {
  provider: 'anthropic' | 'openai' | 'google',
  name: 'Display Name',
  model: 'exact-api-model-id',
},
```

## Examples

**Anthropic Claude:**
```typescript
'claude-4.5-sonnet': {
  provider: 'anthropic',
  name: 'Claude 4.5 Sonnet',
  model: 'claude-sonnet-4-5-20250929',
},
```

**OpenAI:**
```typescript
'gpt-5': {
  provider: 'openai',
  name: 'GPT-5',
  model: 'gpt-5',
},
'o3': {
  provider: 'openai',
  name: 'o3',
  model: 'o3',
},
```

**Google Gemini:**
```typescript
'gemini-2.5-pro': {
  provider: 'google',
  name: 'Gemini 2.5 Pro',
  model: 'gemini-2.5-pro',
},
```

## Notes

- Default model should be cost-effective (Sonnet tier, not Opus)
- Update tests in `src/models.test.ts` if DEFAULT_AI_MODEL changes
- Include sources in your response after updating
