---
name: raycast-extension-updater
description: Update a Raycast extension to the latest version
---

# Raycast Extension Updater

## Version history
- v1.0.0 (2025-12-13) - Initial release

This skill acts as your tool for updating Raycast extensions to modern versions.

## References

- All files that are needed to update the extension are in the `assets` folder.
- The `assets` folder contains the following files:
  - `eslint.config.js`
  - `tsconfig.json`
- See [reference.md](./reference.md) for more technical information.

## Instructions

### Files
- Inspect the `tsconfig.json` file in the project and compare it to the `tsconfig.json` file in the `assets` folder. Update if necessary. Make sure it is properly formatted.
- Check if the project contains a `.eslintrc` file. If so, delete this and replace it with the `eslint.config.js` file in the `assets` folder.

#### Package.json
- It might be best to first run `npm install`
- The following changes are needed in the `package.json` file:
  - Add `j3lte` to the `contributors` array in the `package.json` file if it is not already present.
  - Update or add the following field: `platforms`, this should be an array that contains `macOS` and `Windows`, depending on whether the extension can be used on either or both platforms. If it appears to only use the internet, you can add both. BE AWARE: `macOS` and `Windows` are case sensitive, use the exact spelling as provided here.
  - Update depencency: `@raycast/api` to the latest version.
  - Update depencency: `@raycast/utils` to the latest version if it is a dependency.
  - Remove any of the following dependencies: `axios`, `cross-fetch`, `node-fetch`, `undici`.
  - Update dev dependency: `@raycast/eslint-config` to the latest version.
  - Update dev dependency: `@types/node` to `22.13.10` if needed.
  - Update dev dependency: `@types/react` to `19.0.10` if needed.
  - Update dev dependency: `eslint`, `prettier` and `typescript` to the latest version.
  - All the latest versions should be using the caret (`^`) operator (and not `latest`)
  - When looking for the latest version of a dependency, use the `npm view {dependency} version` command to find the latest version.

#### CHANGELOG.md
- We need to update the `CHANGELOG.md` file with a new entry. Add the following at the top of the file (below the header):
```markdown
## [Updates] - {PR_MERGE_DATE}

- xxx
```
- Please DO NOT write the `xxx`, the user will write this afterwards himself.

### Refactoring

- Unless the user states otherwise, you should not refactor code. If the user asks you to do light refactoring, please do the following:
  - Using the path aliases mentioned in the `tsconfig.json` file, update the imports to use the aliases.
  - If you encounter utils, these should be in `src/utils/index.ts` and should be imported using the `@/utils` alias.
  - If you encounter types, these should be in `src/types/index.ts` and should be imported using the `@/types` alias.
  - If you encounter hooks, these should be in `src/hooks/*.ts` and should be imported using the `@/hooks/*` alias.
  - If you encounter components, these should be in `src/components/*.ts` and should be imported using the `@/components/*` alias.
  - Please sort the imports alphabetically and by the following order:
    - Internal node modules (e.g. `node:fs`)
    - Raycast modules (e.g. `@raycast/api`)
    - External node modules (e.g. `markdown-it`)
    - Internal types (e.g. `@/types`)
    - Internal utils (e.g. `@/utils/`)
    - Internal hooks (e.g. `@/hooks/*`)
    - Internal components (e.g. `@/components/*`)
    - Everything else
