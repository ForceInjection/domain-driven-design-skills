---
name: edge-functions
description: >-
  Use when working with Deno edge functions, LLM integration, or embedding
  generation. Load for Deno.serve patterns, Zod request validation, OpenRouter
  LLM calls, and error handling. Covers function structure, CORS, and the
  call-llm/generate-embedding patterns.
---

# Edge Functions

Deno edge function patterns for external integrations.

> **Announce:** "I'm using edge-functions to implement edge function correctly."

## Function Structure

Standard edge function pattern:

```typescript
// supabase/functions/my-function/index.ts
import { createClient } from '@supabase/supabase-js'
import { MyRequestSchema } from '../types/schemas.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (request: Request) => {
  // Handle CORS preflight
  if (request.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Validate method
    if (request.method !== 'POST') {
      return new Response(
        JSON.stringify({ error: 'Method not allowed' }),
        { status: 405, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Parse and validate request
    const body = await request.json()
    const validated = MyRequestSchema.parse(body)

    // Get auth header for Supabase client
    const authHeader = request.headers.get('Authorization')
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader ?? '' } } }
    )

    // Process request
    const result = await processRequest(validated, supabase)

    return new Response(
      JSON.stringify(result),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ 
        error: error instanceof Error ? error.message : 'Unknown error' 
      }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
```

## Request Validation with Zod

```typescript
// supabase/functions/types/schemas.ts
import { z } from 'zod'

export const GenerateEmbeddingRequest = z.object({
  text: z.string().min(1).max(10000),
  inputType: z.enum(['query', 'passage']).default('query')
})
export type GenerateEmbeddingRequestType = z.infer<typeof GenerateEmbeddingRequest>

export const CallLLMRequest = z.object({
  prompt: z.string().min(1),
  systemPrompt: z.string().optional(),
  model: z.string().default('gpt-4o-mini'),
  temperature: z.number().min(0).max(2).default(0.7),
  maxTokens: z.number().optional(),
  jsonSchema: z.record(z.any()).optional()
})
export type CallLLMRequestType = z.infer<typeof CallLLMRequest>
```

## LLM Calling Pattern

```typescript
// supabase/functions/call-llm/index.ts
import OpenAI from 'openai'

const openai = new OpenAI({
  baseURL: 'https://openrouter.ai/api/v1',
  apiKey: Deno.env.get('OPENROUTER_API_KEY')
})

async function callLLM(request: CallLLMRequestType): Promise<string> {
  const messages: OpenAI.ChatCompletionMessageParam[] = []
  
  if (request.systemPrompt) {
    messages.push({ role: 'system', content: request.systemPrompt })
  }
  messages.push({ role: 'user', content: request.prompt })

  const completion = await openai.chat.completions.create({
    model: request.model,
    messages,
    temperature: request.temperature,
    max_tokens: request.maxTokens,
    response_format: request.jsonSchema 
      ? { type: 'json_schema', json_schema: { name: 'response', schema: request.jsonSchema } }
      : undefined
  })

  return completion.choices[0]?.message?.content ?? ''
}
```

## Embedding Generation Pattern

```typescript
// supabase/functions/generate-embedding/index.ts
async function generateEmbedding(
  text: string, 
  inputType: 'query' | 'passage'
): Promise<number[]> {
  const response = await fetch(
    'https://api-inference.huggingface.co/models/thenlper/gte-small',
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${Deno.env.get('HUGGINGFACE_API_KEY')}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        inputs: text,
        options: { wait_for_model: true }
      })
    }
  )

  if (!response.ok) {
    throw new Error(`Embedding API error: ${response.status}`)
  }

  const embedding = await response.json()
  
  // Validate dimensions
  if (!Array.isArray(embedding) || embedding.length !== 384) {
    throw new Error(`Invalid embedding dimensions: ${embedding?.length}`)
  }

  return embedding
}
```

## Database Callback Pattern

Edge functions can call back to database:

```typescript
// After processing, update database
async function notifyDatabase(supabase: SupabaseClient, result: any) {
  const { error } = await supabase.rpc('process_llm_result', {
    p_result: result
  })
  if (error) throw error
}
```

## Function Whitelist Security

Only allow specific database functions to be called:

```typescript
const ALLOWED_FUNCTIONS = ['update_place_traits', 'process_embedding'] as const
type AllowedFunction = typeof ALLOWED_FUNCTIONS[number]

function validateFunctionName(name: string): name is AllowedFunction {
  return ALLOWED_FUNCTIONS.includes(name as AllowedFunction)
}

// In handler
if (!validateFunctionName(request.function_name)) {
  return new Response(
    JSON.stringify({ error: 'Function not allowed' }),
    { status: 403, headers: corsHeaders }
  )
}
```

## Environment Variables

Required env vars (set in Supabase dashboard):

```
SUPABASE_URL          # Automatic
SUPABASE_ANON_KEY     # Automatic
OPENROUTER_API_KEY    # For LLM calls
HUGGINGFACE_API_KEY   # For embeddings
```

## Anti-Patterns

### DON'T: Check API Key at Module Level

```typescript
// WRONG: Crashes at cold start
const apiKey = Deno.env.get('API_KEY')!  // Throws if missing

// CORRECT: Check inside handler
Deno.serve(async (req) => {
  const apiKey = Deno.env.get('API_KEY')
  if (!apiKey) {
    return new Response(JSON.stringify({ error: 'API key not configured' }), { status: 500 })
  }
})
```

### DON'T: Forget CORS

```typescript
// WRONG: No CORS headers
return new Response(JSON.stringify(result))

// CORRECT: Always include CORS headers
return new Response(JSON.stringify(result), { 
  headers: { ...corsHeaders, 'Content-Type': 'application/json' }
})
```

### DON'T: Expose Internal Errors

```typescript
// WRONG: Leaks internal details
return new Response(JSON.stringify({ error: error.stack }))

// CORRECT: Generic error message
return new Response(JSON.stringify({ 
  error: error instanceof Error ? error.message : 'Internal error'
}))
```

## Testing Locally

```bash
# Start Supabase with edge functions
supabase start

# Test function
curl -X POST http://localhost:54321/functions/v1/my-function \
  -H "Authorization: Bearer $ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"text": "test"}'
```

## References

See `references/function-examples.md` for more patterns.
