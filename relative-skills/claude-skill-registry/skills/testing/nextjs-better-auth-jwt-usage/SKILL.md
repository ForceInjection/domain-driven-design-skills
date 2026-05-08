---
name: nextjs-better-auth-jwt-usage
description: >
  Standard patterns for using Better Auth in Next.js 16+ App Router
  projects, including server and client integration, JWT plugin usage,
  and attaching tokens to backend API calls in a reusable way.
---

# Next.js Better Auth + JWT Usage Skill

## When to use this Skill

Use this Skill whenever you are:

- Setting up or modifying authentication in a Next.js 16+ App Router
  project that uses **Better Auth**.
- Integrating the Better Auth **JWT plugin** to issue tokens for a
  separate backend (e.g. FastAPI) to verify.
- Building login, signup, logout flows and protecting routes in the
  frontend.
- Attaching auth headers (e.g. `Authorization: Bearer <token>`) to
  frontend → backend API calls.

This Skill must be generic enough to work for any Next.js + Better Auth
project, not just a single repository.

## Core goals

- Use Better Auth as the primary auth mechanism in Next.js.
- Use the Better Auth **JWT plugin** (or equivalent feature) when a
  separate backend needs to verify users using a shared secret or JWKS.
- Keep auth logic centralized and reusable:
  - Single server-side auth instance.
  - Single client-side wrapper for auth methods.
  - Single place where JWT tokens are retrieved/attached to API calls.
- Protect routes and layouts in a predictable way using standard
  Next.js mechanisms (middleware, server actions, layouts).

## Architecture assumptions

- Frontend: Next.js 16+ App Router.
- Auth provider: Better Auth running in the same Next.js app or as a
  dedicated auth server reachable via HTTP.
- Sessions: Better Auth manages sessions (cookies) by default.
- Tokens: Better Auth JWT plugin is used to issue tokens that other
  services (e.g. FastAPI backend) can verify.

Do not assume a specific database or UI library. The patterns must focus
on auth, not styling or persistence.

## Core components and files

The typical structure for Better Auth in Next.js includes:

- **Auth config / server instance** (e.g. `lib/auth.ts`):
  - Creates the Better Auth instance with secret, database config, and
    plugins (including JWT).
  - Provides server-side helpers to get the current session/user.

- **Auth route handler** (e.g. `app/api/auth/[...all]/route.ts`):
  - Mounts the Better Auth handler on a Next.js API route.
  - Handles all auth-related HTTP requests (login, signup, logout, etc.).

- **Client-side helpers** (e.g. `lib/auth-client.ts`):
  - Expose thin, typed wrappers for login, signup, logout, etc.
  - Use Better Auth client utilities to call the auth API route.

- **JWT retrieval**:
  - Use the Better Auth JWT plugin endpoints or helpers to obtain a JWT
    token that encodes user identity.
  - Store the token in a secure place suitable for the usage pattern
    (e.g. HTTP-only cookie or server-side retrieval when calling
    another backend).

- **Route protection**:
  - Use middleware, layouts, or server actions to check whether a user
    is authenticated before rendering protected pages.
  - Redirect unauthenticated users to the login page or a public route.

## Better Auth integration rules

- Create a single auth configuration module (e.g. `lib/auth.ts`) that:

  - Calls `createAuth(...)` from Better Auth with:
    - A strong secret from environment variables (e.g. `BETTER_AUTH_SECRET`).
    - Database connection details.
    - Session strategy (e.g. cookie, JWT) as needed.
  - Registers the JWT plugin if tokens are required for external
    services.

- Mount the auth handler in an API route such as:

  - `app/api/auth/[...all]/route.ts` using Better Auth’s Next.js
    handler utilities.

- Do not duplicate auth configuration in multiple files.

## JWT usage with Better Auth

- Enable the JWT plugin in the Better Auth configuration when a
  separate backend (e.g. FastAPI) needs to verify users.

- Use the plugin-provided endpoints or helpers to:
  - Request a JWT for the currently authenticated user.
  - Optionally provide a JWKS endpoint or shared secret for backend
    verification.

- Keep JWT-specific logic in a dedicated module (e.g. `lib/auth-jwt.ts`):

  - Functions to fetch or derive the JWT from the current session.
  - Helpers to pass the JWT to backend API clients.

- Never hard-code JWT secrets in source files; always read them from
  environment variables.

## Attaching JWT to backend API calls

- Combine this Skill with the API client patterns Skill:

  - The API client should accept a function like `getAuthToken` that
    retrieves the JWT from a trusted source (session, cookies, Better
    Auth helper).

- Rules for attaching the token:

  - Use the `Authorization` header with `Bearer <token>` format unless
    the backend explicitly requires something else.
  - Attach the token in one central place (e.g. inside `createApiClient`
    configuration), not in every component.

- The backend (e.g. FastAPI) is responsible for verifying the token
  using the same secret or JWKS that Better Auth uses.

## Route protection and session access (frontend)

- For **protected routes**:

  - Use Next.js middleware or route-specific layouts to:
    - Check whether the user is authenticated using Better Auth’s
      session helpers.
    - Redirect unauthenticated users to the login page.

- For **server components / server actions**:

  - Use Better Auth’s server-side helpers to access the current session
    and user.
  - Avoid exposing raw tokens to client components when not necessary.

- For **client components**:

  - Provide hooks or context that expose:
    - Auth state (logged in / logged out).
    - Basic user info (id, email, name).
    - Actions (login, logout, signup).

## Environment variables and secrets

- Always read the Better Auth secret and URLs from environment
  variables, for example:

  - `BETTER_AUTH_SECRET`
  - `BETTER_AUTH_URL` or equivalent base URL for the auth handler.

- Never log secrets or tokens.
- Document required environment variables in the project README, not in
  the Skill.

## Things to avoid

- Mixing multiple unrelated auth systems in the same project without a
  clear separation.
- Hard-coding JWT secrets, tokens, or auth URLs in components.
- Manually building login/signup flows that bypass Better Auth when the
  library is already configured.
- Attaching tokens directly in dozens of components instead of using
  a central API client configuration.

## References inside the repo

When present, this Skill should align with these conventions:

- `@/lib/auth.ts` – Better Auth server-side configuration.
- `@/lib/auth-client.ts` – Client-side helpers for login/signup/logout.
- `@/lib/auth-jwt.ts` – Helpers to obtain JWT tokens from Better Auth.
- `@/lib/api.ts` – Shared API client that attaches the JWT token.
- `app/api/auth/[...all]/route.ts` – Auth route that mounts Better Auth.

If any of these files are missing, propose creating them following
Better Auth’s official Next.js integration guides and the patterns
described above, instead of inventing a completely new auth flow.
