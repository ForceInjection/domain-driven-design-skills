---
name: ruby-integration
description: This skill is for writing integrations to the Ruby SDK. Claude acts as the engineer implementing LLM provider or agentic framework integrations. Use when adding support for OpenAI-like providers, Anthropic-like providers, or agent frameworks. Covers TDD workflow, comprehensive testing (streaming/non-streaming/tokens/multimodal), defensive coding, MCP validation, and StandardRB compliance.
---

# Writing Ruby SDK Integrations

**This skill is for writing integrations.** Claude acts as the Braintrust engineer implementing new integrations to the Ruby SDK.

## Reference Integrations

Study existing integrations as examples:
- **OpenAI**: `lib/braintrust/trace/contrib/openai.rb` (tests: `test/braintrust/trace/openai_test.rb`, example: `examples/openai.rb`)
- **Anthropic**: `lib/braintrust/trace/contrib/anthropic.rb` (tests: `test/braintrust/trace/anthropic_test.rb`, example: `examples/anthropic.rb`)

**Important Notes**:
- **Examine the library thoroughly** - Study the library's documentation and source code to identify ALL critical methods that call LLMs/AI services. Plan to trace every method that makes API calls, not just the obvious ones.
- Some integrations (e.g. ruby-llm) support multiple providers (e.g. OpenAI and Anthropic). Test all supported providers.

## Core Pattern: Module Prepending

```ruby
# frozen_string_literal: true

module Braintrust
  module Trace
    module YourProvider
      def self.wrap(client = nil, tracer_provider: nil)
        tracer_provider ||= ::OpenTelemetry.tracer_provider

        # Idempotent wrapping: check if already wrapped
        return client if client && client.instance_variable_get(:@braintrust_wrapped)

        # Support class-level wrapping: wrap() with no args wraps class globally
        if client.nil?
          # Class wrapping: YourProvider.prepend(wrapper)
          # Instance wrapping: client.singleton_class.prepend(wrapper)
        end

        wrapper = Module.new do
          define_method(:your_api_method) do |**params|
            tracer = tracer_provider.tracer("braintrust")

            tracer.in_span("your_provider.operation") do |span|
              # IMPORTANT: Start span FIRST (before metadata extraction) for accurate timing
              # 1. Capture input
              set_json_attr(span, "braintrust.input_json", extract_input(params))

              # 2. Set metadata (provider, model, endpoint, all params)
              set_json_attr(span, "braintrust.metadata", {
                "provider" => "your_provider",
                "endpoint" => "/v1/endpoint",
                "model" => params[:model]
              }.compact)

              # 3. Call original
              response = super(**params)

              # 4. Capture output
              set_json_attr(span, "braintrust.output_json", extract_output(response))

              # 5. Capture metrics (normalized tokens)
              set_json_attr(span, "braintrust.metrics", parse_usage_tokens(response.usage))

              response
            end
          end
        end

        client.your_api.singleton_class.prepend(wrapper)
        client.instance_variable_set(:@braintrust_wrapped, true) if client
        client
      end

      ## Code Organization

      - Break large methods (>50 lines) into focused helpers
      - Separate streaming/non-streaming into distinct handler methods (e.g., `handle_streaming_request`, `handle_non_streaming_request`)
      - Extract metadata/input/output capture into helper methods (e.g., `extract_metadata`, `build_input_messages`, `capture_output`)

      private

      def self.set_json_attr(span, key, value)
        span.set_attribute(key, JSON.generate(value)) if value
      rescue => e
        warn "Failed to serialize #{key}: #{e.message}"
      end

      def self.parse_usage_tokens(usage)
        return {} unless usage
        {
          "prompt_tokens" => usage[:input_tokens] || usage[:prompt_tokens],
          "completion_tokens" => usage[:output_tokens] || usage[:completion_tokens],
          "tokens" => usage[:total_tokens]
        }.compact
      end
    end
  end
end
```

## Streaming Pattern

```ruby
define_method(:stream) do |**params|
  tracer = tracer_provider.tracer("braintrust")
  aggregated_chunks = []

  span = tracer.start_span("your_provider.operation.stream")
  set_json_attr(span, "braintrust.input_json", extract_input(params))
  set_json_attr(span, "braintrust.metadata", extract_metadata(params))

  stream = begin
    super(**params)
  rescue => e
    span.record_exception(e)
    span.status = ::OpenTelemetry::Trace::Status.error("Error: #{e.message}")
    span.finish
    raise
  end

  original_each = stream.method(:each)
  stream.define_singleton_method(:each) do |&block|
    original_each.call do |chunk|
      aggregated_chunks << chunk
      block&.call(chunk)
    end
  rescue => e
    span.record_exception(e)
    span.status = ::OpenTelemetry::Trace::Status.error("Streaming error: #{e.message}")
    raise
  ensure
    # CRITICAL: Always finish span even if stream partially consumed
    unless aggregated_chunks.empty?
      aggregated = aggregate_chunks(aggregated_chunks)
      set_json_attr(span, "braintrust.output_json", aggregated)
      set_json_attr(span, "braintrust.metrics", parse_usage_tokens(aggregated[:usage]))
    end
    span.finish
  end

  stream
end
```

## Examples

Write two examples:
- **Customer example** (`examples/your_provider.rb`): Concise example demonstrating setup and basic usage
- **Internal example** (`examples/internal/your_provider.rb`): Comprehensive example using every library feature

Follow existing example patterns:
- **Nest all API calls under a manual root span** (see `examples/openai.rb`):
  ```ruby
  tracer = OpenTelemetry.tracer_provider.tracer("your-provider-example")
  root_span = nil

  response = tracer.in_span("examples/your_provider.rb") do |span|
    root_span = span
    client.your_api.call(...)  # Automatically traced, nested under root_span
  end
  ```
- Use consistent nomenclature for spans and projects
- Print permalink at end: `Braintrust::Trace.permalink(root_span)`

## Required Components

**Do in this order:**

- [ ] **Appraisals FIRST**: Add to `Appraisals` file (latest + 2 recent + uninstalled), run `bundle exec appraisal generate`
- [ ] **Tests**: `test/braintrust/trace/your_provider_test.rb`
- [ ] **Integration**: `lib/braintrust/trace/contrib/your_provider.rb`
- [ ] **VCR cassettes**: `test/fixtures/vcr_cassettes/your_provider/` (record as you write tests)
- [ ] **Auto-load**: Add to `lib/braintrust/trace.rb` with `begin/rescue LoadError`
- [ ] **Example**: `examples/your_provider.rb`
- [ ] **Example**: `examples/internal/your_provider.rb` (comprehensive internal example)
- [ ] **Env var**: Add to `.env.example` if needed

## Test Coverage (LLM Providers)

1. ✅ Non-streaming requests (basic + attributes + metrics)
2. ✅ Streaming requests (full consumption)
3. ✅ Early stream termination (partial consumption)
4. ✅ Error handling (exception recording)
5. ✅ **All critical features** - Test ALL provider capabilities:
   - Tool/function calling (if supported)
   - Images/vision (if supported)
   - System messages (if supported)
   - Multiple messages/chat history (if supported)
   - Any other provider-specific features
6. ✅ Token usage edge cases (cached, reasoning tokens)
7. ✅ Multiple APIs (if provider has multiple endpoints)
8. ✅ Verify we don't change the behaviour of the integration
9. ✅ **LLM wrapper libraries** - If tracing a library that wraps LLM providers (e.g., ruby_llm→OpenAI), verify traces match the underlying provider exactly (tools format, token format, output structure). Compare side-by-side with `BRAINTRUST_ENABLE_TRACE_CONSOLE_LOG=1`

## Appraisal Configuration (Set up FIRST)

**CRITICAL**: Configure appraisal at the START, before writing tests. Test latest + 2 recent versions + uninstalled.

**Step 1 - Add to `Appraisals` file:**

```ruby
# Appraisals file - ADD THIS FIRST
appraise "your_provider-latest" do
  gem "your_provider", ">= 2.0"
end

appraise "your_provider-1.5" do
  gem "your_provider", "~> 1.5.0"
end

appraise "your_provider-1.0" do
  gem "your_provider", "~> 1.0.0"
end

appraise "your_provider-uninstalled" do
  remove_gem "your_provider"
end
```

**Step 2 - Generate gemfiles:**
```bash
bundle exec appraisal generate
```

**Step 3 - Use appraisal for ALL test runs:**
```bash
bundle exec appraisal rake test   # Run all scenarios (use this in TDD cycle)
```

**Determine versions**: Check release history, focus on API changes, include customer-likely versions.

## Testing Tools & Validation

Use multiple testing approaches to validate your integration:

### 1. Unit Tests (Primary)
- **Location**: `test/braintrust/trace/your_provider_test.rb`
- **Purpose**: Test all code paths, edge cases, and error handling
- **Run**: `bundle exec appraisal rake test`
- **Coverage**: Track with `bundle exec rake coverage` (>90% line, >80% branch)

### 2. Console Log Inspection
- **Purpose**: Quickly verify trace structure during development
- **Usage**:
  ```bash
  BRAINTRUST_ENABLE_TRACE_CONSOLE_LOG=true bundle exec ruby examples/your_provider.rb
  ```
- **Verify**: Check span hierarchy, attributes, and parent/child relationships

### 3. Braintrust MCP Server (Integration Testing)
- **Purpose**: Query and inspect traces in the Braintrust platform
- **Setup**: Should be auto-configured in Docker environment
- **Commands**:
  ```ruby
  # List recent traces
  mcp__braintrust__list_recent_objects(object_type: "project_logs", limit: 10)

  # Inspect specific span
  mcp__braintrust__resolve_object(object_type: "project_logs", object_id: "span_id")

  # BTQL query
  mcp__braintrust__btql_query(query: "SELECT * FROM project_logs WHERE metadata.provider = 'your_provider'")
  ```
- **Verify attributes**: `input`, `output`, `metadata`, `metrics`, `span_attributes.braintrust.parent`, `span_attributes.braintrust.org`

### 4. Examples (Manual Testing)
- **Customer example**: `bundle exec ruby examples/your_provider.rb`
- **Internal example**: `bundle exec ruby examples/internal/your_provider.rb`
- **Purpose**: End-to-end validation of real API calls

### Testing Workflow
1. **TDD cycle**: Write unit test → implement → run `bundle exec appraisal rake test`
2. **Console log**: Use `BRAINTRUST_ENABLE_TRACE_CONSOLE_LOG=true` to debug span structure
3. **MCP validation**: Query traces with Braintrust MCP server
4. **Examples**: Run examples to verify end-to-end behavior

## TDD Workflow (CRITICAL)

**After EVERY major change**: test → lint → fix → commit cycle

1. **Create todo list** at start
2. **Write one failing test**
3. **Implement minimal code** to pass
4. **Run tests with appraisal**: `bundle exec appraisal rake test`
5. **Lint**: `bundle exec rake lint` (fix with `rake lint:fix`)
6. **Verify with MCP** tools
7. **Refactor** if needed
8. **Repeat cycle** for: basic → attributes → streaming → errors → tokens → multimodal

## Defensive Coding

- ✅ Nil checks (`return {} unless usage`)
- ✅ Safe navigation (`params[:model] || "unknown"`)
- ✅ Compact hashes (`.compact`)
- ✅ Error handling (`begin/rescue/ensure`)
- ✅ JSON safety (rescue in `set_json_attr`)
- ✅ Graceful gem loading (`rescue LoadError`)

## StandardRB & CI

Lint after every change (part of TDD cycle):
```bash
bundle exec rake lint          # Check StandardRB
bundle exec rake lint:fix      # Auto-fix
```

Coverage target (check periodically):
```bash
bundle exec rake coverage      # >90% line, >80% branch
```

**CI requirements**: StandardRB + tests on Ruby 3.2/3.3/3.4 + Ubuntu/macOS + all appraisal scenarios

## Token Normalization

Use shared `TokenParser.parse_usage_tokens(usage)` in `lib/braintrust/trace/token_parser.rb` to normalize tokens:
- `prompt_tokens` (input)
- `completion_tokens` (output)
- `tokens` (total, includes cache_creation_tokens)
- `prompt_cached_tokens` (if cached)
- `prompt_cache_creation_tokens` (if cache created)
- `completion_reasoning_tokens` (if reasoning)

## VCR Cassettes

```bash
VCR_MODE=all bundle exec rake test           # Re-record all
VCR_MODE=new_episodes bundle exec rake test  # Record new only
VCR_OFF=true bundle exec rake test           # Skip VCR
```

## Reference Files

- Integrations: `lib/braintrust/trace/contrib/{openai,anthropic}.rb`
- Tests: `test/braintrust/trace/{openai,anthropic}_test.rb`
- Test helpers: `test/test_helper.rb`
- Examples: `examples/{openai,anthropic}.rb`
- Config: `Rakefile`, `Appraisals`, `.github/workflows/ci.yml`
