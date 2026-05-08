---
name: Drizzle Schema Generation
description: Generates Drizzle ORM schema files for users, sessions, tokens, OAuth accounts, and audit logs. Syncs schema to Neon Postgres.
---

# Drizzle Schema Generation

## Instructions

1. Generate Drizzle ORM schema files:
   - Create users table with email, name, provider IDs, timestamps
   - Create sessions table with token, expiration, user association
   - Create accounts table for OAuth providers (if needed)
   - Create verification tokens table for email verification
   - Create audit logs table for security tracking

2. Follow Drizzle ORM best practices:
   - Use proper TypeScript types
   - Include appropriate indexes
   - Add foreign key relationships
   - Use proper naming conventions
   - Include proper constraints

3. Ensure Neon Postgres compatibility:
   - Use PostgreSQL-specific features where appropriate
   - Follow Neon's connection and performance guidelines
   - Include proper migration patterns
   - Consider Neon's branching capabilities

4. Generate both SQL and TypeScript definitions:
   - Create proper Drizzle table definitions
   - Include type-safe schema exports
   - Add proper relationship definitions
   - Include migration scripts

5. Follow Context7 MCP documentation:
   - Retrieve latest Drizzle ORM documentation
   - Follow Neon Postgres best practices
   - Ensure security compliance

## Examples

Input: "Generate schema for users with email, name, provider IDs"
Output: Creates Drizzle schema with:
```typescript
export const users = pgTable('users', {
  id: varchar('id', { length: 255 }).primaryKey().notNull(),
  email: varchar('email', { length: 255 }).notNull().unique(),
  name: varchar('name', { length: 255 }),
  providerId: varchar('provider_id', { length: 255 }),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull()
})
```