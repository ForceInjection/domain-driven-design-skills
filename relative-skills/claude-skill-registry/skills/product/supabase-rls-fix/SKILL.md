---
name: supabase-rls-fix
description: Fix Supabase RLS issues - handles missing user context, system processes, background jobs, and provides standardized RLS templates
---

# Supabase RLS Fix Skill

## When to Use This Skill

Activate this skill when you encounter:
- "relation does not exist" errors with user/tenant tables
- "Tenant or user not found" errors in background jobs
- System processes failing due to missing user context
- RLS policies blocking scheduled tasks
- Need to add RLS to new tables

## Quick Fixes

### 🚨 Fix 1: Missing user_tenants Table

If you get: `ERROR: relation "user_tenants" does not exist`

**Create compatibility view:**
```sql
-- Run in Supabase SQL Editor
DROP VIEW IF EXISTS user_tenants CASCADE;
CREATE OR REPLACE VIEW user_tenants AS
SELECT * FROM tenant_memberships;

GRANT SELECT ON user_tenants TO authenticated;
GRANT SELECT ON user_tenants TO anon;
```

### 🚨 Fix 2: System Process Failures

If background jobs fail with "Tenant or user not found":

**Update the function to handle system processes:**
```sql
CREATE OR REPLACE FUNCTION get_current_user_tenant_ids()
RETURNS UUID[] AS $$
DECLARE
  current_user_id_str TEXT;
  current_user_uuid UUID;
  tenant_ids UUID[];
BEGIN
  -- Get current user setting (may be null for system processes)
  current_user_id_str := current_setting('app.current_user_id', true);

  -- If no user context (system process/background job), return empty array
  IF current_user_id_str IS NULL OR current_user_id_str = '' THEN
    RETURN ARRAY[]::UUID[];
  END IF;

  -- Try to convert to UUID
  BEGIN
    current_user_uuid := current_user_id_str::UUID;
  EXCEPTION WHEN OTHERS THEN
    RETURN ARRAY[]::UUID[];
  END;

  -- Get user's tenant IDs
  SELECT ARRAY_AGG(tenant_id) INTO tenant_ids
  FROM tenant_memberships
  WHERE user_id = current_user_uuid;

  RETURN COALESCE(tenant_ids, ARRAY[]::UUID[]);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Permanent Solution: Standardized RLS Functions

### Step 1: Create Helper Functions

```sql
-- Helper 1: Detect system processes
CREATE OR REPLACE FUNCTION is_system_process()
RETURNS BOOLEAN AS $$
BEGIN
  -- Check if explicitly marked as system process
  IF current_setting('app.is_system', true) = 'true' THEN
    RETURN true;
  END IF;

  -- Check if no user context (also system process)
  IF current_setting('app.current_user_id', true) IS NULL OR
     current_setting('app.current_user_id', true) = '' THEN
    RETURN true;
  END IF;

  RETURN false;
END;
$$ LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER;

-- Helper 2: Universal access checker
CREATE OR REPLACE FUNCTION can_access_row(
  p_user_id UUID DEFAULT NULL,
  p_tenant_id UUID DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
  v_current_user_id UUID;
  v_current_tenant_id UUID;
BEGIN
  -- System processes always have access
  IF is_system_process() THEN
    RETURN true;
  END IF;

  -- Get current user/tenant from session
  BEGIN
    v_current_user_id := current_setting('app.current_user_id', true)::UUID;
  EXCEPTION WHEN OTHERS THEN
    v_current_user_id := NULL;
  END;

  BEGIN
    v_current_tenant_id := current_setting('app.current_tenant_id', true)::UUID;
  EXCEPTION WHEN OTHERS THEN
    v_current_tenant_id := NULL;
  END;

  -- Check user match
  IF p_user_id IS NOT NULL AND v_current_user_id = p_user_id THEN
    RETURN true;
  END IF;

  -- Check tenant match
  IF p_tenant_id IS NOT NULL AND v_current_tenant_id = p_tenant_id THEN
    RETURN true;
  END IF;

  -- Check if user belongs to tenant
  IF p_tenant_id IS NOT NULL AND v_current_user_id IS NOT NULL THEN
    RETURN EXISTS (
      SELECT 1 FROM tenant_memberships
      WHERE user_id = v_current_user_id
      AND tenant_id = p_tenant_id
      AND status = 'ACTIVE'
    );
  END IF;

  RETURN false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Step 2: RLS Template for New Tables

```sql
-- COPY THIS TEMPLATE FOR EVERY NEW TABLE WITH RLS:

ALTER TABLE your_table_name ENABLE ROW LEVEL SECURITY;

-- SELECT: System processes + users can read
CREATE POLICY "your_table_name_select" ON your_table_name
FOR SELECT USING (
  can_access_row(user_id, tenant_id)
);

-- INSERT: Only users (no system processes)
CREATE POLICY "your_table_name_insert" ON your_table_name
FOR INSERT WITH CHECK (
  NOT is_system_process() AND
  can_access_row(user_id, tenant_id)
);

-- UPDATE: System processes + users
CREATE POLICY "your_table_name_update" ON your_table_name
FOR UPDATE USING (
  can_access_row(user_id, tenant_id)
);

-- DELETE: Only users
CREATE POLICY "your_table_name_delete" ON your_table_name
FOR DELETE USING (
  NOT is_system_process() AND
  can_access_row(user_id, tenant_id)
);
```

## Debugging RLS Issues

### Check Current Context
```sql
-- Am I a system process?
SELECT is_system_process();

-- What's my current user ID?
SELECT current_setting('app.current_user_id', true);

-- What's my current tenant ID?
SELECT current_setting('app.current_tenant_id', true);

-- What tenants do I have access to?
SELECT get_current_user_tenant_ids();
```

### Test Access
```sql
-- Can I access a specific row?
SELECT can_access_row('user-uuid-here'::UUID, 'tenant-uuid-here'::UUID);

-- Which rows can I see in a table?
SELECT * FROM your_table WHERE can_access_row(user_id, tenant_id);
```

### For Background Jobs
```sql
-- Mark as system process before running job
SELECT set_config('app.is_system', 'true', false);

-- Or set specific user context
SELECT set_config('app.current_user_id', 'user-uuid-here', false);
SELECT set_config('app.current_tenant_id', 'tenant-uuid-here', false);
```

## Common Patterns

### Multi-Tenant Table
```sql
-- Table with tenant_id column
CREATE POLICY "table_tenant_policy" ON table_name
FOR ALL USING (
  is_system_process() OR
  tenant_id = ANY(get_current_user_tenant_ids())
);
```

### User-Owned Table
```sql
-- Table with user_id column
CREATE POLICY "table_user_policy" ON table_name
FOR ALL USING (
  is_system_process() OR
  user_id = current_setting('app.current_user_id')::UUID
);
```

### Public Read, Authenticated Write
```sql
-- Anyone can read
CREATE POLICY "table_public_read" ON table_name
FOR SELECT USING (true);

-- Only authenticated users can write
CREATE POLICY "table_auth_write" ON table_name
FOR INSERT WITH CHECK (
  current_setting('app.current_user_id', true) IS NOT NULL
);
```

## Testing Checklist

When adding RLS to a table, test:

- [ ] **With user context**: Normal user operations work
- [ ] **Without context**: System processes can still operate
- [ ] **Wrong context**: Other users/tenants are blocked
- [ ] **Background jobs**: Scheduled tasks complete successfully
- [ ] **Migrations**: Can run without user context

## Quick Apply via Supabase

1. Open SQL Editor: `https://supabase.com/dashboard/project/[PROJECT_ID]/sql/new`
2. Run helper functions first (Step 1)
3. Apply template to your tables (Step 2)
4. Test with debugging queries

## Red Flags to Watch For

- Using `current_setting()` directly in policies → Use helper functions instead
- Policies without system process consideration → Always check `is_system_process()`
- Complex nested conditions → Use `can_access_row()` for clarity
- No tests for background jobs → Test without user context
- RLS on junction tables → Often unnecessary, check parent tables instead

## References

- [Supabase RLS Docs](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL RLS](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- Common error codes:
  - `42P01`: Relation does not exist
  - `42501`: Insufficient privileges
  - `22P02`: Invalid text representation (bad UUID)