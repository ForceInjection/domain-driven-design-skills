---
name: create-custom-dagster-component
description: Create a custom Dagster Component with demo mode support, realistic asset structure, and optional custom scaffolder using the dg CLI. Use this skill if there is no Component included in an existing integration or if Dagster does not have the integration.
license: MIT
---

# Create a custom Component

## Overview

This skill automates the creation and validation of a new custom Dagster component using the `dg` CLI tool with uv as a package manager. It incorporates demo mode functionality for creating realistic demonstrations that can run locally without external dependencies. The documentation for creating good components can be found here https://docs.dagster.io/guides/build/components/creating-new-components/creating-and-registering-a-component and here https://github.com/dagster-io/dagster/blob/master/python_modules/libraries/dagster-dbt/dagster_dbt/components/dbt_project/component.py for a complex example of a component.

## What This Skill Does

When invoked, this skill will:

1. ✅ Create a new Dagster Component project using `dg scaffold component ComponentName`
2. ✅ Fills in the component logic in the `build_defs()` function with both real and demo mode implementations
3. ✅ Implement a `demo_mode` boolean flag in the component YAML for toggling between real and local demo implementations
4. ✅ Create 3-5 realistic assets with proper dependencies and technology kinds
5. ✅ Instantiate a component YAML and fill it in using the `dg scaffold defs my_module.components.ComponentName my_component` command
6. ✅ Optionally create a custom scaffolder if requested
7. ✅ Validate that the component loaded correctly using `dg check defs` and `dg list defs` to ensure that the expected component instances are all loaded.
8. ✅ Provide clear next steps for development

## Prerequisites

Before running this skill, ensure:

- `uv` is installed (check with `uv --version`)
- You have a component name in mind (or will use the default)
- You're in a Dagster project directory with the dg CLI available
- You have inspected and understand how to create multi-asset integrations (see this guide: https://docs.dagster.io/integrations/guides/multi-asset-integration)

## Skill Workflow

### Step 1: Get Component Name and Demo Mode Preference

Ask the user for:

1. A component name, or use a sensible default like `MyDagsterComponent`. Validate that:
   - The name starts with a letter
   - Contains only alphanumeric characters, hyphens, or underscores
   - The component doesn't already exist (or ask to overwrite)
2. Whether they want demo mode support (default: yes for demonstration projects)
3. Whether they want to create a custom scaffolder (see Step 5)

### Step 2: Create Component

Use `dg` to create the component

```bash
uv run dg scaffold component <ComponentName>
```

This will:

- Scaffold a new Dagster Component in `defs/components`
- Create a `component_name.py` file

### Step 3: Implement Component Logic with Demo Mode

Fill in the `build_defs()` function in the component file. The component should:

1. **Accept a `demo_mode` parameter** in the component params (default: False)
2. **Create 3-5 realistic assets** based on the chosen technologies
3. **Implement dual logic paths:**
   - Real implementation: connects to actual systems (the body should include connections to real systems)
   - Demo mode: uses local data/mocked behavior for demonstrations
   - Important Configuration in Pydantic + YAML fields: All configuration (a new pipeline or asset) should be configurable in the Component and _not_ hard coded in the Component Python. **Demo mode assets are the exception that _should_ be hard coded.**
   - All Resources should be configured outside of the Component in the `defs/` folder in a `resources.py` file, using `dg scaffold defs dagster.resource resources.py`
   - All Components that invoke a pipeline or API that might trigger multiple assets should allow for an `assets` field in the YAML that describes what assets are used in the underlying component. See https://dagster.io/blog/dsls-to-the-rescue for best practices in how to design a good DSL. Refer to https://github.com/dagster-io/dagster/blob/master/python_modules/libraries/dagster-dbt/dagster_dbt/components/dbt_project/component.py and https://github.com/dagster-io/dagster/blob/master/python_modules/libraries/dagster-fivetran/dagster_fivetran/components/workspace_component/component.py for two reference architectures for good component design with mutli-assets.
4. **Set proper asset metadata:**
   - Use the `kinds` argument to indicate technologies in use
   - Add descriptive names and documentation
   - Establish proper dependencies between assets
5. **Design asset keys for downstream integration** (CRITICAL):
   - Consider what components will consume your assets
   - Choose key structures that minimize downstream configuration
   - See "Design Asset Keys for Integration" section below

Example asset structure:

- Raw data ingestion asset
- Data transformation/cleaning asset
- Business logic/aggregation asset
- ML model or analytics asset (if applicable)
- Output/export asset

### Design Asset Keys for Integration

**CRITICAL:** When creating a custom component, consider **what will consume** your component's assets. The asset keys you generate should align with downstream component expectations to avoid requiring per-asset configuration.

#### Key Principle: Upstream Defines, Downstream Consumes

Your component (upstream) should generate asset keys in a structure that downstream components naturally reference. This eliminates the need for `meta.dagster.asset_key` or complex translation configuration.

#### Common Downstream Consumers

**If dbt will consume your assets:**
- Use pattern: `["<source_name>", "<table_name>"]`
- Example: `["fivetran_raw", "customers"]` or `["api_raw", "users"]`
- This allows dbt sources to reference naturally: `source('fivetran_raw', 'customers')`

**If custom Dagster assets will consume them:**
- Match the key structure those assets expect in their `deps`
- Minimize nesting when possible (prefer 2 levels: `["category", "name"]`)
- Avoid deeply nested keys like `["system", "subsystem", "type", "name"]` unless necessary

**If another integration component will consume them:**
- Check that component's expected input key structure
- Align your keys to match, or provide clear mapping documentation

**If your assets are intermediate and consumed by your own component:**
- Use clear, hierarchical keys that reflect data flow
- Example: `["raw", "table"]` → `["processed", "table"]` → `["enriched", "table"]`

#### Example: Creating an API Ingestion Component

```python
import dagster as dg

class APIIngestionComponent(dg.Component, dg.Model, dg.Resolvable):
    """Ingests data from REST APIs."""

    api_endpoint: str
    tables: list[str]
    demo_mode: bool = False

    def build_defs(self, context: dg.ComponentLoadContext) -> dg.Definitions:
        assets = []

        for table in self.tables:
            # Design key for dbt consumption: ["api_raw", "table_name"]
            # NOT: ["api", "ingestion", "raw", "table_name"]
            @dg.asset(
                key=dg.AssetKey(["api_raw", table]),  # ← Flattened for easy downstream reference
                kinds={"api", "python"},
            )
            def ingest_table(context: dg.AssetExecutionContext):
                if self.demo_mode:
                    context.log.info(f"Demo mode: Mocking API call for {table}")
                    return {"status": "demo", "rows": 100}
                else:
                    # Real API call
                    pass

            assets.append(ingest_table)

        return dg.Definitions(assets=assets)
```

**Result:** dbt can reference these assets naturally:
```yaml
# sources.yml
sources:
  - name: api_raw
    tables:
      - name: customers  # Matches ["api_raw", "customers"]
```

#### Verification

Always verify asset keys align with downstream dependencies:

```bash
# Check asset keys and their dependencies
uv run dg list defs --json | uv run python -c "
import sys, json
assets = json.load(sys.stdin)['assets']
print('\\n'.join([f\"{a['key']}: deps={a.get('deps', [])}\" for a in assets]))
"
```

**What to verify:**
- Downstream assets list your assets in their `deps` array
- No duplicate keys with different structures
- Keys are simple and descriptive (typically 2 levels: `["category", "name"]`)

#### Anti-Patterns to Avoid

❌ **Too deeply nested:** `["company", "team", "project", "environment", "table"]`
- Hard for downstream to reference
- Requires complex mapping

❌ **Inconsistent structure:** Some assets with 2 levels, others with 4
- Confusing for consumers
- Unpredictable references

❌ **Generic names:** `["data", "table1"]`, `["output", "result"]`
- Not clear what system they're from
- Conflicts with other components

✅ **Good patterns:**
- `["source_system", "entity"]`: `["fivetran_raw", "customers"]`
- `["integration", "object"]`: `["salesforce", "accounts"]`
- `["stage", "table"]`: `["staging", "orders"]`

#### Critical: Asset Keys Must Be Identical in Demo and Production Mode

**IMPORTANT:** Asset keys should be **exactly the same** whether `demo_mode` is True or False. Only the asset implementation (the function body) should differ between modes.

**Why this matters:**
- Downstream components reference assets by key
- Dependencies are established based on keys
- If keys differ between modes, dependencies break when switching modes
- Testing in demo mode won't accurately reflect production behavior

**Example - CORRECT approach:**

```python
def build_defs(self, context: dg.ComponentLoadContext) -> dg.Definitions:
    @dg.asset(
        key=dg.AssetKey(["fivetran_raw", "customers"]),  # ← Same key in both modes
        kinds={"fivetran"},
    )
    def customers_sync(context: dg.AssetExecutionContext):
        if self.demo_mode:
            # Demo implementation - mock data
            context.log.info("Demo mode: Creating empty table")
            # ... create mock table
        else:
            # Production implementation - real Fivetran sync
            context.log.info("Production: Syncing from Fivetran")
            # ... call Fivetran API

    return dg.Definitions(assets=[customers_sync])
```

**Example - INCORRECT approach:**

```python
def build_defs(self, context: dg.ComponentLoadContext) -> dg.Definitions:
    if self.demo_mode:
        @dg.asset(
            key=dg.AssetKey(["demo", "customers"]),  # ❌ Different key!
        )
        def demo_customers():
            pass
        return dg.Definitions(assets=[demo_customers])
    else:
        @dg.asset(
            key=dg.AssetKey(["fivetran_raw", "customers"]),  # ❌ Different key!
        )
        def prod_customers():
            pass
        return dg.Definitions(assets=[prod_customers])
```

**Reference Documentation:**

- Cross-reference https://docs.dagster.io/llms.txt for up-to-date titles and descriptions
- Use https://docs.dagster.io/llms-full.txt for full API details
- Check available integrations with:

```bash
uv run dg docs integrations --json
```

## Important: Always Add Kinds to Assets

When creating assets in your component, **ALWAYS add the `kinds` parameter** to properly categorize assets by their technology/integration type. This helps with:
- Filtering and organizing assets in the Dagster UI
- Understanding the technology stack at a glance
- Grouping assets by integration type

**Common integration kinds:**
- `kinds={"fivetran"}` for Fivetran assets
- `kinds={"dbt"}` for dbt assets
- `kinds={"census"}` for Census assets
- `kinds={"sling"}` for Sling assets
- `kinds={"powerbi"}` for PowerBI assets
- `kinds={"looker"}` for Looker assets
- `kinds={"airbyte"}` for Airbyte assets
- `kinds={"python"}` for custom Python processing
- `kinds={"snowflake"}` for Snowflake assets

You can verify kinds are showing correctly by running:
```bash
uv run dg list defs
```
The "Kinds" column should show the integration type for each asset.

**Example Component Structure:**

```python
from dagster import asset, Definitions, AssetExecutionContext
from pydantic import BaseModel

class MyComponentParams(BaseModel):
    demo_mode: bool = False
    # ... other params

class MyComponent(Component):
    params_schema = MyComponentParams

    def build_defs(self, context: ComponentLoadContext) -> Definitions:
        params = self.params

        @asset(
            kinds={"fivetran"},  # ← REQUIRED: Add the integration kind
        )
        def raw_data(context: AssetExecutionContext):
            if params.demo_mode:
                # Demo implementation - local/mocked data
                context.log.info("Running in demo mode with local data")
                pass
            else:
                # Real implementation - connect to actual systems
                context.log.info("Running with real data source")
                pass

        @asset(
            deps=[raw_data],
            kinds={"dbt"},  # ← REQUIRED: Add the integration kind
        )
        def processed_data(context: AssetExecutionContext):
            if params.demo_mode:
                context.log.info("Processing demo data")
                pass
            else:
                context.log.info("Processing real data")
                pass

        # ... more assets

        return Definitions(assets=[raw_data, processed_data, ...])
```

### Step 4: Create Component Instance YAML

Use `dg scaffold defs` to create the component instance:

```bash
uv run dg scaffold defs my_module.components.ComponentName my_component
```

This creates a YAML file that should include the `demo_mode` parameter:

```yaml
type: my_module.components.ComponentName
attributes:
  demo_mode: true  # Set to true for local demos, false for real deployments
  # ... other params
```

### Step 5: Create Custom Scaffolder (Optional)

If the user requested a custom scaffolder in Step 1, follow the directions here:
https://docs.dagster.io/guides/build/components/creating-new-components/component-customization#customizing-scaffolding-behavior

Customize the scaffolder to provide a better developer experience for creating instances of this component.

### Step 6: Validate Setup and Asset Key Alignment

Run these commands to ensure everything works:

```bash
# Check that definitions load without errors
uv run dg check defs

# List all assets to verify they were created
uv run dg list defs
```

Verify that:

- ✅ All expected assets are listed
- ✅ The component instance is properly configured
- ✅ No errors or warnings are shown
- ✅ The `demo_mode` flag toggles between implementations correctly
- ✅ The `demo_mode: false` implementation uses realistic resources and is a production implementation

**CRITICAL: Verify Asset Key Alignment**

Check that asset dependencies are correct by running:

```bash
uv run dg list defs --json | uv run python -c "
import sys, json
data = json.load(sys.stdin)
assets = data.get('assets', [])
print('Asset Dependencies:\n')
for asset in assets:
    key = asset.get('key', 'unknown')
    deps = asset.get('deps', [])
    if deps:
        print(f'{key}')
        for dep in deps:
            print(f'  ← {dep}')
    else:
        print(f'{key} (no dependencies)')
    print()
"
```

**What to verify:**
- ✅ Downstream assets list upstream assets in their `deps` array
- ✅ No missing dependencies
- ✅ Asset keys are simple and descriptive (typically 2 levels: `["category", "name"]`)
- ✅ Asset keys work consistently in both demo mode and production mode

**Key Principle:** Asset keys should be **identical** between demo mode and production mode. Only the asset implementation (the function body) should differ. This ensures:
- Dependencies work the same in both modes
- You can switch between modes without reconfiguring downstream components
- Testing in demo mode accurately reflects production behavior

### Step 7: Test Demo Mode

If demo mode was implemented:

1. Ensure the component YAML has `demo_mode: true`
2. Run `dg check defs` to verify it works locally
3. Document how to switch between demo and real modes

## Success Criteria

The component is complete when:

- ✅ Component scaffolding is created
- ✅ `build_defs()` is implemented with proper asset logic
- ✅ Demo mode flag is working (if applicable)
- ✅ Non demo mode has realistic connections to the database or APIs implemented
- ✅ 3-5 realistic assets are created with proper dependencies
- ✅ Assets have appropriate `kinds` metadata
- ✅ Component YAML instance is created and configured
- ✅ Custom scaffolder is implemented (if requested)
- ✅ `dg check defs` passes without errors
- ✅ `dg list defs` shows all expected assets

## Next Steps

After completion, inform the user:

1. The component has been created and validated
2. Location of the component files
3. How to toggle demo mode (if applicable)
4. How to customize the component further
5. How to create additional instances using the scaffolder