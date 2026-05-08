---
name: generate-schema
description: |
   Generate the conclaude-schema.json configuration schema file using src/bin/generate-schema.rs.
   USE WHEN the configuration format changes, new config fields are added, or the schema needs to be updated for release or testing.
---

# Generate Schema

This skill helps you generate the `conclaude-schema.json` file that defines the configuration schema for conclaude. The schema is used for validation and is published as a release asset.

## USE WHEN

**Use this skill when:**

- Adding new configuration fields to conclaude
- Modifying existing configuration structure
- Changing hook definitions or their schema
- Updating configuration validation rules
- Preparing for a new release that includes config changes
- The schema file is out of sync with the code
- Implementing new features that add configuration options

**Do NOT use this skill when:**

- Just reading or viewing the current schema
- Working on features that don't affect configuration
- Making non-configuration code changes

## How It Works

The schema generator (`src/bin/generate-schema.rs`) uses the conclaude library's built-in schema generation capabilities to:

1. Introspect the Rust configuration structs
2. Generate a JSON Schema representation
3. Write it to `conclaude-schema.json` at the workspace root

The generated schema file is then published as a release asset for users to reference.

## Instructions

### Step 1: Make Your Configuration Changes

First, implement your configuration changes in the relevant Rust files (typically `src/config.rs` or related modules).

### Step 2: Generate the Schema

Run the schema generator:

```bash
cargo run --bin generate-schema
```

This will:
- Generate the schema from the current configuration code
- Write it to `conclaude-schema.json` in the workspace root
- Display a success message

### Step 3: Verify the Changes

Check the generated schema file:

```bash
cat conclaude-schema.json
```

Or use a JSON formatter:

```bash
jq . conclaude-schema.json
```

Look for:
- Your new fields appear with correct types
- Descriptions are accurate and helpful
- Required fields are marked appropriately
- Enum values are correct

### Step 4: Commit the Schema

Include the updated schema in your commit:

```bash
git add conclaude-schema.json
git commit -m "Update schema for [your feature]"
```

## Expected Output

When successful, you'll see:

```
[OK] Schema generated successfully: conclaude-schema.json
     The schema file is ready to be published as a release asset.
```

## Common Issues

### Build Errors

If the generator fails to build:
- Ensure your Rust code compiles: `cargo build`
- Check for syntax errors in configuration structs
- Verify all dependencies are available

### Schema Validation Errors

If the generated schema doesn't match expectations:
- Check your derive macros on configuration structs
- Ensure you're using the correct serde attributes
- Review the schema generation code in `src/schema.rs`

### File Permission Errors

If it fails to write the file:
- Ensure you have write permissions in the workspace root
- Check that `conclaude-schema.json` isn't locked by another process

## Related Files

- `src/bin/generate-schema.rs` - The schema generator binary
- `src/schema.rs` - Schema generation implementation
- `src/config.rs` - Main configuration structures
- `conclaude-schema.json` - The output schema file

## Notes

- The schema is automatically generated from code, so manual edits to `conclaude-schema.json` will be overwritten
- Always regenerate the schema after configuration changes
- The schema is version-controlled and should be kept in sync with the code
- The schema file is published as a release asset for external tools and IDEs
