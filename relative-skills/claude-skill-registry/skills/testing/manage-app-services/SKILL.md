---
name: manage-app-services
description: Create or update service functions in this repo, especially store-related services in `src/stores/*.service.ts` and task registrations in `src/setup/services.ts`. Use when adding new service functions, changing service behavior or params, or wiring services to DOM tasks.
---

# Manage App Services

Follow these steps to add or update service functions and their wiring.

## 1) Create or update the service file

Place service functions in `src/stores/<name>.service.ts` and keep them focused on side effects or store updates.

If requested, call the service when the atom is connected extending the atom with `withConnectHook`

Example:

```ts
import { moviesAtom } from './movies'
import { withConnectHook } from '@reatom/core'

export async function loadMovies(): Promise<void> {
  const response = await fetch('/api/movies')
  const movies = (await response.json()) as Movie[]
  moviesAtom.set(movies)
}

// optionally extend the atom to load movies on connect
moviesAtom.extend(withConnectHook(loadMovies))
```

## 2) Wire the service to DOM tasks

Typically, the service is triggered by DOM tasks, register it in `src/setup/services.ts` via `registerTaskHandler`.

Example:

```ts
import { registerTaskHandler } from '../helpers/domTask'
import { deleteMovie } from '../stores/movies.service'

registerTaskHandler('delete-movie', deleteMovie)
```

Ensure the task is defined in `src/setup/tasks.ts` with the correct params/returns.

## 3) Update call sites

Search for all usages and update parameters or return handling to match the service signature.

Use:

- `rg -n "registerTaskHandler\\(|\\.service\\.ts|loadMovies|deleteMovie" src`

## 4) Keep types strict and explicit

Prefer typed params and explicit return types for service functions, and avoid unused locals/params.

## 5) Call the service from components using events (tasks)

Dispatch tasks from components via `dispatchTask`.
Never call service functions directly from components.
