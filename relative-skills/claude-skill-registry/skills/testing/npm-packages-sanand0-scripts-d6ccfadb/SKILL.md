---
name: npm-packages
description: Conventions for package.json, README.md, coding & testing styles
---

- Name packages as single words ("smartart"), joined words ("saveform") or hyphenated ("bootstrap-llm-provider")
- The main file name is package-name.js
- Use ESM ("type": "module")
- Use JavaScript, not TypeScript
- Encourage type definitions

## package.json

Include these keys:

- name: package-name
- version: semver
- description: 1-line (how it helps developers)
- homepage: typically "https://github.com/sanand0/repo#readme"
- repository: typically { type: "git", url: "https://github.com/sanand0/repo.git" }
- license: "MIT"
- author: typically "Anand S <root.node@gmail.com>"
- type: "module"
- files: [ "LICENSE", "README.md", "dist/" ]
- browser: "dist/package-name.min.js" if meant for browsers
- exports: "dist/package-name.min.js" or `{ ".": { "default": "./dist/package-name.min.js", "types": "./package-name.d.ts" } }`
- bin: only for CLI apps
- scripts: typically includes:
  ```jsonc
  {
    "build": "npx -y esbuild package-name.js --bundle --format esm --minify --outfile=dist/package-name.min.js",
    "lint": "dprint fmt -c https://raw.githubusercontent.com/sanand0/scripts/refs/heads/main/dprint.jsonc && npx -y oxlint --fix",
    "test": "npx -y vitest@3 run --globals",
    "prepublishOnly": "npm run lint && npm run build && npm test"
    // docs, watch, pretest, ...
  }
  ```
- dependencies: only if required
- devDependencies: only if required. Prefer `npx -y` in scripts over devDependencies. Used mainly if tests/utilities need packages, e.g. jsdom, playwright, sharp
- peerDependencies: only if required. E.g. { "bootstrap": "^5.3.7" }
- keywords: [ ... ]

## README.md

Include these H2 headings in order:

- Begin with shields, followed by a 1-line description of the package. Shields include
  ```markdown
  [![npm version](https://img.shields.io/npm/v/package-name.svg)](https://www.npmjs.com/package/package-name)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
  [![bundle size](https://img.shields.io/bundlephobia/minzip/package-name)](https://bundlephobia.com/package/package-name)
  ```
- Installation. Typically:

  ````markdown
  Add this to your script:

  ```js
  import { something } from "package-name";
  ```

  To use via CDN, add this to your HTML file:

  ```html
  <script type="importmap">
  {
    "imports": {
      "package-name": "https://cdn.jsdelivr.net/npm/package-name@1"
    }
  }
  </script>
  ```

  To use locally, install via `npm`:

  ```bash
  npm install package-name
  ```

  ... and add this to your HTML file:

  ```html
  <script type="importmap">
  {
    "imports": {
      "package-name": "./node_modules/package-name/dist/package-name.js"
    }
  }
  </script>
  ```
  ````

- Usage. Provide detailed examples covering all scenarios
  - API. Provide API documentation
- Development. Use this content:

  ```bash
  git clone https://github.com/user/package-name.git
  cd package-name

  npm install
  npm run lint && npm run build && npm test

  npm publish
  git commit . -m"$COMMIT_MSG"; git tag $VERSION; git push --follow-tags
  ```

- Release notes. This is a list of `[x.y.z](https://npmjs.com/package/package-name/v/x.y.y): dd mmm yyyy: Description of the change`
- License. Just mention `[MIT](LICENSE)`

Follow these conventions:

- Code blocks: add language hints (js, html, bash); keep lines ≤ 120 chars
- Examples: minimal, copy-paste-able; inline comments sparingly
- Links: prefer absolute repo URLs for cross-references

## Coding style

- Prefer named exports for utilities; default export for the primary function; avoid classes unless needed
- Use JSDoc for params/returns and typedefs; ship `.d.ts` for public APIs where feasible

## Testing style

- Prefer Vitest with jsdom for browser libraries
- Playwright can be used for end-to-end and screenshot tests
- File naming: `*.test.js` (or `*.spec.ts` for Playwright suites)
- Style: BDD (`describe`, `it`), deterministic tests, small fixtures; mock network when applicable

## .gitignore

```
node_modules/
dist/
```
