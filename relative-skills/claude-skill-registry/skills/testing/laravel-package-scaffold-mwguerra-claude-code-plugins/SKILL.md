---
name: laravel-package-scaffold
description: Scaffold Laravel packages with ServiceProvider, Facade, Config, and test setup
allowed-tools: Bash(python3:*), Write, Read, Glob
---

# Laravel Package Scaffold Skill

Creates a complete Laravel package skeleton with proper structure and all necessary files.

## Usage

When the user wants to create a Laravel package, use the scaffold script:

```bash
python3 ${SKILL_DIR}/scripts/scaffold_laravel_package.py <vendor/package-name> [--with-pest] [--with-facade] [--with-config] [--with-command]
```

## Examples

### Basic package
```bash
python3 ${SKILL_DIR}/scripts/scaffold_laravel_package.py mwguerra/my-package
```

### Package with testing
```bash
python3 ${SKILL_DIR}/scripts/scaffold_laravel_package.py mwguerra/my-package --with-pest
```

### Full-featured package
```bash
python3 ${SKILL_DIR}/scripts/scaffold_laravel_package.py mwguerra/my-package --with-pest --with-facade --with-config --with-command
```

## What Gets Created

### Directory Structure
```
packages/
└── vendor/
    └── package-name/
        ├── composer.json
        ├── README.md
        ├── LICENSE
        ├── .gitignore
        ├── config/
        │   └── package-name.php
        ├── src/
        │   ├── PackageNameServiceProvider.php
        │   ├── PackageName.php (main class)
        │   ├── Facades/
        │   │   └── PackageName.php
        │   └── Commands/
        │       └── InstallCommand.php
        └── tests/ (if --with-pest)
            ├── Pest.php
            ├── TestCase.php
            └── Unit/
                └── ExampleTest.php
```

### Generated Files

1. **composer.json**
   - PSR-4 autoloading for `src/` and `tests/`
   - Laravel auto-discovery configuration
   - PHP ^8.2 requirement
   - Laravel ^11.0|^12.0 support (latest)
   - Orchestra Testbench ^10.0 (latest)
   - PestPHP ^3.8 (latest)

2. **ServiceProvider**
   - Config merging and publishing
   - Command registration
   - View/translation loading (prepared)

3. **Facade** (optional)
   - Accessor for the main service class

4. **Config** (optional)
   - Default configuration file
   - Publishable via artisan

5. **Commands** (optional)
   - Install command for post-install setup

6. **Tests** (optional)
   - PestPHP setup with Orchestra Testbench
   - Example test verifying environment

### Project Integration

The script automatically updates the project's `composer.json`:
- Adds path repository pointing to `packages/vendor/package-name`
- Adds package to `require` block as `@dev`
- Enables symlink for development

## After Running

1. **Install dependencies**:
   ```bash
   composer update
   ```

2. **Verify installation**:
   ```bash
   php artisan package-name:install
   ```

3. **Publish config** (if applicable):
   ```bash
   php artisan vendor:publish --tag=package-name-config
   ```

4. **Run tests** (if testing was added):
   ```bash
   cd packages/vendor/package-name
   composer install
   ./vendor/bin/pest
   ```

## Naming Conventions

- Package name: `kebab-case` (e.g., `my-awesome-package`)
- PHP namespace: `PascalCase` (e.g., `MyAwesomePackage`)
- Config key: `kebab-case` (e.g., `my-awesome-package`)
- Commands: `kebab-case:action` (e.g., `my-awesome-package:install`)

## Laravel package integration notes

- Configure **package discovery** via `composer.json` `extra.laravel.providers` (and optional `aliases`).
- In the ServiceProvider:
  - `register()`: `mergeConfigFrom()` and container bindings.
  - `boot()`: `publishes()` / `publishesMigrations()` plus `loadRoutesFrom()`, `loadViewsFrom()`, `loadTranslationsFrom()`.
  - Tag publish groups (`package-config`, `package-migrations`, `package-views`, `public`).
  - Optionally contribute to `about`, and hook into `optimize` / `reload`.
