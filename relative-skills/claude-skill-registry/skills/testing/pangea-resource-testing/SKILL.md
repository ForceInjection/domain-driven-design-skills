---
name: pangea-resource-testing
description: Creates and tests Pangea Ruby function resources with synthesis testing. Use when creating new resources, writing synthesis tests, generating test coverage for Terraform DSL resources, or filling test gaps for AWS/Cloudflare/Hetzner resources.
---

# Pangea Resource Testing

Creates Ruby function resources and comprehensive synthesis tests for the Pangea infrastructure tool.

## When to Use This Skill

- Creating new resource types (AWS, Cloudflare, Hetzner)
- Writing synthesis tests for existing resources
- Filling test coverage gaps
- Generating synthesis specs that validate Terraform JSON output

## Resource File Structure

Each resource lives in `lib/pangea/resources/<resource_name>/` with two files:

### resource.rb Pattern

```ruby
# frozen_string_literal: true
# Copyright 2025 The Pangea Authors
# [Apache 2.0 License header]

require 'pangea/resources/base'
require 'pangea/resources/reference'
require 'pangea/resources/<resource_name>/types'
require 'pangea/resource_registry'

module Pangea
  module Resources
    module AWS  # or Cloudflare, Hetzner
      def <resource_name>(name, attributes = {})
        # 1. Validate with dry-struct
        attrs = Types::Types::<ResourceName>Attributes.new(attributes)

        # 2. Generate terraform resource block
        resource(:<resource_name>, name) do
          # Map attributes to terraform properties
          attribute_name attrs.attribute_name
          optional_attr attrs.optional_attr if attrs.optional_attr

          # Nested blocks
          if attrs.nested_block
            nested_block do
              # nested properties
            end
          end

          # Tags pattern
          if attrs.tags&.any?
            tags do
              attrs.tags.each { |k, v| public_send(k, v) }
            end
          end
        end

        # 3. Return ResourceReference with outputs
        ResourceReference.new(
          type: '<resource_name>',
          name: name,
          resource_attributes: attrs.to_h,
          outputs: {
            id: "${<resource_name>.#{name}.id}",
            arn: "${<resource_name>.#{name}.arn}",
            # ... other outputs
          }
        )
      end
    end
  end
end

# Auto-register module
Pangea::ResourceRegistry.register(:aws, Pangea::Resources::AWS)
```

### types.rb Pattern

```ruby
# frozen_string_literal: true
# Copyright 2025 The Pangea Authors
# [Apache 2.0 License header]

require 'dry-struct'
require 'pangea/resources/types'

module Pangea
  module Resources
    module AWS
      module Types
        class <ResourceName>Attributes < Dry::Struct
          transform_keys(&:to_sym)

          # Required attributes
          attribute :required_attr, Resources::Types::String

          # Optional attributes with defaults
          attribute :optional_attr?, Resources::Types::String.optional.default(nil)
          attribute :with_default, Resources::Types::Bool.default(false)

          # Computed properties
          def computed_property
            # derived from attributes
          end
        end
      end
    end
  end
end
```

## Synthesis Test Pattern

Each test lives in `spec/resources/<resource_name>/synthesis_spec.rb`:

```ruby
# frozen_string_literal: true
# Copyright 2025 The Pangea Authors
# [Apache 2.0 License header]

require 'spec_helper'
require 'terraform-synthesizer'
require 'pangea/resources/<resource_name>/resource'

RSpec.describe '<resource_name> synthesis' do
  let(:synthesizer) { TerraformSynthesizer.new }

  describe 'terraform synthesis' do
    it 'synthesizes basic resource' do
      synthesizer.instance_eval do
        extend Pangea::Resources::AWS  # or Cloudflare, Hetzner
        <resource_name>(:example, {
          required_attr: 'value'
        })
      end

      result = synthesizer.synthesis
      resource = result[:resource][:<resource_name>][:example]

      expect(resource[:required_attr]).to eq('value')
    end

    it 'synthesizes with optional attributes' do
      synthesizer.instance_eval do
        extend Pangea::Resources::AWS
        <resource_name>(:with_optional, {
          required_attr: 'value',
          optional_attr: 'optional_value'
        })
      end

      result = synthesizer.synthesis
      resource = result[:resource][:<resource_name>][:with_optional]

      expect(resource[:optional_attr]).to eq('optional_value')
    end

    it 'applies default values correctly' do
      synthesizer.instance_eval do
        extend Pangea::Resources::AWS
        <resource_name>(:defaults, { required_attr: 'value' })
      end

      result = synthesizer.synthesis
      resource = result[:resource][:<resource_name>][:defaults]

      expect(resource[:with_default]).to eq(false)  # or expected default
    end

    it 'synthesizes with tags' do
      synthesizer.instance_eval do
        extend Pangea::Resources::AWS
        <resource_name>(:tagged, {
          required_attr: 'value',
          tags: { Name: 'test', Environment: 'dev' }
        })
      end

      result = synthesizer.synthesis
      resource = result[:resource][:<resource_name>][:tagged]

      expect(resource[:tags][:Name]).to eq('test')
    end
  end

  describe 'resource references' do
    it 'provides correct terraform interpolation strings' do
      ref = synthesizer.instance_eval do
        extend Pangea::Resources::AWS
        <resource_name>(:test, { required_attr: 'value' })
      end

      expect(ref.id).to eq('${<resource_name>.test.id}')
      expect(ref.outputs[:arn]).to eq('${<resource_name>.test.arn}')
    end
  end
end
```

## Test Validation Checklist

Each synthesis test should validate:

1. **Basic synthesis** - Required attributes produce valid Terraform JSON
2. **Optional attributes** - Optional fields are included when provided
3. **Default values** - Defaults are applied correctly
4. **Tags support** - Tags block renders properly (if applicable)
5. **Nested blocks** - Complex nested structures synthesize correctly
6. **Resource references** - Interpolation strings are correct

## Provider-Specific Patterns

### AWS Resources
- Module: `Pangea::Resources::AWS`
- Registry: `Pangea::ResourceRegistry.register(:aws, ...)`
- Common outputs: `id`, `arn`, resource-specific attributes

### Cloudflare Resources
- Module: `Pangea::Resources::Cloudflare`
- Registry: `Pangea::ResourceRegistry.register_module(...)`
- Common: `zone_id`, `account_id` (32-char hex)

### Hetzner Resources
- Module: `Pangea::Resources::Hetzner`
- Common: `id`, `name`, `location`, `labels`

## File Size Guidelines

Per CLAUDE.md:
- Keep files under 200 lines
- Split complex resources into focused files

## Running Tests

```bash
# Run specific synthesis test
nix run .#synthesizer-tests

# Or via bundler
bundle exec rspec spec/resources/<resource_name>/synthesis_spec.rb

# Update synthesizer-tests.yaml to include new tests
```

## Adding to Test Configuration

After creating tests, add to `synthesizer-tests.yaml`:

```yaml
enabled_tests:
  - <resource_name>/synthesis_spec.rb
```
