---
name: auth-system
description: Auth system (Clerk + Convex + anonymous JWT) guidelines and planned permissions/upgrade behavior.
---

# Overview

Auth system design + implementation notes (Clerk + Convex + anonymous JWT), including planned projects/workspaces/assets privacy model and upgrade migration behavior.

# Auth system (Clerk + Convex + anonymous JWT), and planned permissions model for projects/workspaces/assets.

# High-level goals (product + security)

## Frictionless onboarding

The user must be able to create content without signing in. This means the app must mint and use an anonymous identity early so content can be associated with a stable user record.

## Anonymous is not “secure”

Anonymous identities are not to be treated as safe. Even though the app uses a JWT flow for anonymous users, it is not treated as secure enough for sensitive content:

- Anonymous users should be warned not to store sensitive information.
- “Public write” (edit by link) is intentionally unsafe and must be treated as a capability-style risk (link leak = edit access).

## Upgrade must secure everything by default

When an anonymous user signs up (upgrades to a Clerk account), the default behavior must secure their resources:

- All workspaces/projects/assets become private.
- Only signed-in workspace/project members can access/edit.
- Any anonymous/public access must be re-enabled explicitly by the owner after upgrade.

# Current implementation (how auth works today)

## Provider wiring (frontend)

Auth is coordinated by `ClerkProvider` + `AppAuthProvider` + Convex auth integration.

- Entry point: [main.tsx](../../../packages/app/src/main.tsx)
- Auth provider: [app-auth.tsx](../../../packages/app/src/components/app-auth.tsx)
- Root route gating: [\_\_root.tsx](../../../packages/app/src/routes/__root.tsx)
- Convex client: [app-convex-client.ts](../../../packages/app/src/lib/app-convex-client.ts)

`AppAuthProvider` provides:

- `isAuthenticated`, `isLoaded`, `isAnonymous`, `userId`
- `getToken()` returning either:
  - a Clerk JWT (`template: "convex"`) when signed in, or
  - an anonymous JWT when not signed in

Convex consumes the auth source via `ConvexProviderWithAuth` using `useAuth={AppAuthProvider.useAuth}`.

## Two identity modes

### Clerk (signed-in)

- The frontend requests a Clerk JWT with `template: "convex"`.
- The app expects the JWT to include `external_id`, which is used as the canonical Convex `users` document id.
- If `external_id` is missing, the frontend calls `/api/auth/resolve-user` to create/link the Convex user and then updates Clerk so future tokens include `external_id`.

### Anonymous (not signed in)

- The frontend calls `/api/auth/anonymous` (or refreshes it) to mint/refresh an anonymous JWT.
- The JWT subject is the Convex `users` id.
- The anonymous JWT is stored in `localStorage` and re-used until refreshed/cleared.

Anonymous token caching keys (frontend):

- `app::auth::anonymous_token`
- `app::auth::anonymous_token_user_id`

## HTTP routes and responsibilities (Convex)

HTTP router entry: [http.ts](../../../packages/app/convex/http.ts)

Routes implemented in: [users.ts](../../../packages/app/convex/users.ts)

### `POST /api/auth/anonymous`

- With no body token: creates a new anonymous user record and mints a JWT.
- With `token`: refresh path:
  - extract user id from JWT
  - verify the provided token matches the stored token for that user
  - issue a new JWT and store it on the user record

Anonymous JWT properties:

- `alg: ES256`
- `iss`: `VITE_CONVEX_HTTP_URL` (Convex env var)
- `aud`: `"convex"`
- `sub`: Convex `users` id
- expiry: `"30d"`

### `GET /.well-known/jwks.json`

Exposes public JWK(s) for the anonymous JWT signing key so JWT verifiers can validate anonymous tokens.

### `POST /api/auth/resolve-user`

Purpose: ensure a Clerk identity is linked to a Convex user id, and ensure Clerk `external_id` is set.

- Requires a valid Clerk-authenticated request (`ctx.auth.getUserIdentity()` must exist).
- If `identity.external_id` already exists, returns it.
- Otherwise:
  - calls internal mutation `internal.users.resolve_user` to find/create/link the Convex user
  - calls Clerk API to set `external_id` to the Convex user id

Internal mutation behavior:

- If `anonymousUserToken` is provided:
  - validates token and finds the anonymous user
  - links that user record to the Clerk user (canonicalize anonymous into signed-in)
  - may delete other existing users for the same Clerk id so the anonymous record becomes canonical
- If no `anonymousUserToken`:
  - finds or creates a Convex user record for the Clerk user id

## Root route gating

The root layout waits for both:

- Convex auth to finish loading (`useConvexAuth().isLoading === false`)
- App auth provider to finish loading (`auth.isLoaded === true`)

If Convex is authenticated, the main app is rendered; otherwise an unauthenticated view is shown.

## Assistant UI token generation (Convex action)

File: [auth.ts](../../../packages/app/convex/auth.ts)

The action `generate_assistant_ui_token` uses `ctx.auth.getUserIdentity()` to decide the `userId`/`workspaceId` for Assistant UI Cloud tokens:

- Clerk user: uses `identity.external_id` (must exist)
- Anonymous user: detected by `identity.issuer === VITE_CONVEX_HTTP_URL`, uses `identity.subject`
- No identity: falls back to [shared-auth-constants.ts](../../../packages/app/shared/shared-auth-constants.ts) for `anonymous`

# Planned functionality (not fully implemented yet)

## Projects and workspaces

The app is organized into projects and workspaces so users can organize assets flexibly.

When an anonymous user is created:

- A project and workspace must be created as well.
- Other users (including anonymous, depending on visibility) can be invited into the project/workspace.

## Public vs private semantics

### “Public” is link-only

Public access is implemented by possessing the asset id in a URL (not indexable content, no separate share token).

### Public workspace/project

If the workspace/project is public:

- anonymous collaborators can be invited
- anonymous collaborators can have permissions like any other user id (subject to the permission system)

### Public asset

If an asset is public:

- it can be accessed by anonymous users without an invite
- the owner can choose whether anonymous users can write or only read

Important: “public write” means anyone who knows the asset id can write (shared edit capability).

## Granular permissions system

Permissions are intended to be granular and set per-asset and optionally per-user id (including anonymous user ids).

The owner may:

- allow anonymous users to write on a public asset (edit-by-link)
- allow anonymous users to read only
- grant write permissions to a specific anonymous user id (while keeping others read-only)

## Upgrade behavior (anonymous → signed-in)

When the user upgrades by signing up (Clerk-authenticated, linked to Convex user id):

- The anonymous user record is linked to the Clerk identity (so content is retained).
- The user must not be able to access the same private resources while logged out.
- Default security migration:
  - all workspaces become private
  - all projects become private
  - all assets become private
  - all anonymous write access is removed
  - all anonymous/public access is removed by default

The owner can later re-publicize assets explicitly.

# Implementation constraints (to follow when modifying this system)

When the user requests changes in this area, you must:

# Preserve the canonical user id design

- The canonical app identity is the Convex `users` document id.
- Clerk `external_id` is used as a pointer to that Convex user id in tokens.

# Keep anonymous flows robust

- Anonymous token fetch must be resilient and should not crash the app.
- Token suppliers used by Convex should resolve (not reject) so auth state can transition cleanly.

# Treat “public write” as intentionally unsafe

- Do not accidentally enable public write by default.
- When implementing the upgrade migration, ensure “everything becomes private” is enforced.
