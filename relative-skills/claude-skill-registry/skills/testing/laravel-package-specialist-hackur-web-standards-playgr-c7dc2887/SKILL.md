---
name: Laravel Package Specialist
description: Laravel and Nova package development, forked package management, VCS path repositories, webpack configuration, and package integration workflows. Triggers include "package", "nova field", "nova tool", "webpack.mix.js", "pcrcard/nova-*", "packages/".
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
---

# Laravel Package Specialist

Expert assistance for Laravel and Nova package development, forked package management, and package integration workflows.

## When to Use

- Creating or modifying Laravel Nova fields
- Developing Nova resources, tools, or lenses
- Managing forked packages (pcrcard/nova-*)
- Building and deploying package assets
- Configuring webpack for Nova packages
- Package versioning and git workflows
- Troubleshooting package integration issues
- Syncing with upstream package forks

## Quick Commands

```bash
# Package management
./scripts/dev.sh pkg:list                    # List all forked packages
./scripts/dev.sh pkg:status                  # Show package status
./scripts/dev.sh pkg:clone [package-name]    # Clone packages
./scripts/dev.sh pkg:update [package-name]   # Update from remote
./scripts/dev.sh pkg:build <package-name>    # Build and reinstall

# Package development workflow
cd packages/<package-name>/
npm install
npm run dev                   # Development build
npm run prod                  # Production build
git add .
git commit -m "feat: description"
git push origin master
composer update pcrcard/<package-name>  # Update main app
```

## PCR Card Package Architecture

### Forked Packages

**1. pcrcard/nova-menus** - Hierarchical menu management
- Path: `packages/nova-menus/`
- Remote: https://github.com/hackur/nova-menus
- Upstream: skylark-team/nova-menus
- Purpose: Database-driven Nova sidebar menus

**2. pcrcard/nova-medialibrary-bounding-box-field** - Media + damage assessment
- Path: `packages/nova-medialibrary-bounding-box-field/`
- Remote: https://github.com/hackur/nova-medialibrary-bounding-box-field
- Upstream: dmitrybubyakin/nova-medialibrary-field
- Purpose: Spatie MediaLibrary management + canvas-based bounding box editor
- Fields: `Medialibrary`, `BoundingBoxField`

### Package Structure

```
packages/
├── nova-menus/
│   ├── src/                # PHP source (Fields, Tools, Resources)
│   ├── resources/          # Vue components, CSS
│   │   └── js/
│   ├── dist/               # Compiled assets (committed)
│   ├── composer.json       # Package metadata
│   ├── package.json        # npm dependencies
│   └── webpack.mix.js      # Laravel Mix configuration
└── nova-medialibrary-bounding-box-field/
    ├── src/
    │   └── Fields/         # Nova field classes
    ├── resources/
    │   └── js/components/  # Vue 3 components
    ├── dist/               # Compiled assets
    ├── docs/               # Package documentation
    ├── composer.json
    ├── package.json
    └── webpack.mix.js
```

### Composer Configuration

```json
{
    "repositories": {
        "nova-menus": {
            "type": "path",
            "url": "packages/nova-menus"
        },
        "nova-medialibrary-field": {
            "type": "path",
            "url": "packages/nova-medialibrary-bounding-box-field"
        }
    },
    "require": {
        "pcrcard/nova-menus": "@dev",
        "pcrcard/nova-medialibrary-bounding-box-field": "@dev"
    }
}
```

## Package Development Patterns

### 1. Creating New Nova Field

**PHP Field Class** (`src/Fields/MyField.php`):
```php
namespace Vendor\Package\Fields;

use Laravel\Nova\Fields\Field;

class MyField extends Field
{
    public $component = 'my-field';

    public function __construct($name, $attribute = null, callable $resolveCallback = null)
    {
        parent::__construct($name, $attribute, $resolveCallback);
    }

    // Custom methods for field configuration
    public function withConfig(array $config): self
    {
        return $this->withMeta(['config' => $config]);
    }
}
```

**Vue Component Registration** (`resources/js/field.js`):
```javascript
import IndexField from './components/IndexField'
import DetailField from './components/DetailField'
import FormField from './components/FormField'

Nova.booting((app, store) => {
  app.component('index-my-field', IndexField)
  app.component('detail-my-field', DetailField)
  app.component('form-my-field', FormField)
})
```

**Component Template** (`resources/js/components/FormField.vue`):
```vue
<template>
  <DefaultField
    :field="field"
    :errors="errors"
    :show-help-text="showHelpText"
  >
    <template #field>
      <div class="my-field-wrapper">
        <!-- Your field UI -->
      </div>
    </template>
  </DefaultField>
</template>

<script>
import { DependentFormField, HandlesValidationErrors } from 'laravel-nova'

export default {
  mixins: [DependentFormField, HandlesValidationErrors],

  props: ['resourceName', 'resourceId', 'field'],

  methods: {
    fill(formData) {
      formData.append(this.field.attribute, this.value || '')
    }
  }
}
</script>
```

### 2. Webpack Configuration (Nova 5.x)

**Standard webpack.mix.js for Nova Packages**:
```javascript
let mix = require('laravel-mix')

mix
  .setPublicPath('dist')
  .js('resources/js/field.js', 'js')
  .vue({ version: 3 })
  .css('resources/css/field.css', 'css')
  .webpackConfig({
    externals: {
      vue: 'Vue',
      'laravel-nova': 'LaravelNova',
      'laravel-nova-ui': 'LaravelNovaUi',
    },
    output: {
      uniqueName: 'vendor/package',
    },
  })
  .version()
```

**Key Points**:
- `setPublicPath('dist')` - Output directory
- `vue({ version: 3 })` - Vue 3 for Nova 5.x
- **Externals** - Don't bundle Vue/Nova (provided by Nova)
- `uniqueName` - Prevents webpack conflicts
- `version()` - Cache busting with mix-manifest.json

### 3. Service Provider Registration

```php
namespace Vendor\Package;

use Laravel\Nova\Nova;
use Laravel\Nova\Events\ServingNova;
use Illuminate\Support\ServiceProvider;

class FieldServiceProvider extends ServiceProvider
{
    public function boot()
    {
        Nova::serving(function (ServingNova $event) {
            Nova::script('my-field', __DIR__.'/../dist/js/field.js');
            Nova::style('my-field', __DIR__.'/../dist/css/field.css');
        });
    }

    public function register()
    {
        //
    }
}
```

**Alternative (Laravel Mix manifest)**:
```php
public function boot()
{
    Nova::serving(function (ServingNova $event) {
        Nova::mix('my-field', __DIR__.'/../dist/mix-manifest.json');
    });
}
```

### 4. Package composer.json

```json
{
    "name": "pcrcard/my-nova-field",
    "description": "My Nova field description",
    "keywords": ["laravel", "nova", "field"],
    "license": "MIT",
    "require": {
        "php": "^8.2",
        "laravel/nova": "^5.0"
    },
    "autoload": {
        "psr-4": {
            "Pcrcard\\MyNovaField\\": "src/"
        }
    },
    "extra": {
        "laravel": {
            "providers": [
                "Pcrcard\\MyNovaField\\FieldServiceProvider"
            ]
        }
    },
    "minimum-stability": "dev",
    "prefer-stable": true
}
```

## Development Workflows

### Package Development Workflow

**Complete workflow for modifying a package**:

```bash
# 1. Navigate to package directory
cd packages/nova-medialibrary-bounding-box-field/

# 2. Make code changes
# Edit src/Fields/BoundingBoxField.php
# Edit resources/js/components/FormField.vue

# 3. Build assets
npm run dev          # Development build (faster)
npm run prod         # Production build (minified)

# 4. Test in main app
cd ../..
composer update pcrcard/nova-medialibrary-bounding-box-field

# 5. Commit to package repo
cd packages/nova-medialibrary-bounding-box-field/
git add .
git commit -m "feat: Add new feature to bounding box editor"
git push origin master

# 6. Update main app (optional)
cd ../..
composer update pcrcard/nova-medialibrary-bounding-box-field
```

### Creating New Forked Package

```bash
# 1. Fork upstream package on GitHub
# 2. Clone into packages/ directory
cd packages/
git clone https://github.com/hackur/new-package.git

# 3. Update composer.json namespace
cd new-package/
# Edit composer.json: Change namespace to "pcrcard/*"

# 4. Add to main app composer.json
cd ../..
# Add repository and require to composer.json

# 5. Install package
composer install

# 6. Update package management script
# Edit scripts/lib/packages.sh - add to get_forked_packages()
```

## Best Practices

### Git Workflow
- ✅ **ALWAYS commit to package repo first, then main app**
- ✅ Use semantic versioning tags (v1.0.0, v2.0.0)
- ✅ Keep package and app commits separate
- ✅ Reference package commits in app commit messages
- ✅ Push to fork remote (origin), not upstream

### Asset Building
- ✅ Build in package directory (not main app)
- ✅ Use `npm run prod` for production builds
- ✅ **COMMIT dist/ files to package repo** (required for Nova)
- ❌ Never commit node_modules/
- ✅ Test builds locally before committing

### Dependencies
- ✅ External packages in externals config (Vue, Nova, etc.)
- ❌ Don't bundle Nova or Vue in package assets
- ✅ Use @dev version constraint for local development
- ✅ Lock upstream versions in package.json

### Symlinks
- ✅ Composer creates symlinks automatically
- ✅ vendor/pcrcard/* → packages/*
- ❌ Don't modify symlinks manually
- ✅ Rebuild symlinks: `composer install`

## Troubleshooting

### Package Changes Not Reflected

**Symptom**: Modified package code doesn't appear in Nova

**Solution**:
```bash
cd packages/<package>/
npm run dev                               # Rebuild assets
cd ../..
composer update pcrcard/<package>         # Update main app
php artisan nova:publish                  # Republish Nova assets
php artisan cache:clear                   # Clear cache
```

### Webpack Errors (Cannot Find Module)

**Symptom**: `Module not found: Error: Can't resolve 'laravel-nova'`

**Solution**: Check externals configuration
```javascript
// webpack.mix.js
.webpackConfig({
    externals: {
        vue: 'Vue',                         // ✅ Must be externalized
        'laravel-nova': 'LaravelNova',     // ✅ Must be externalized
        'laravel-nova-ui': 'LaravelNovaUi', // ✅ Must be externalized
    },
})
```

### Vue Component Not Rendering

**Symptom**: Nova field shows blank or error in console

**Solution**:
1. Check component registration in field.js
2. Verify `$component` property matches registration name
3. Check browser console for errors
4. Verify Vue 3 syntax (Composition API vs Options API)

```javascript
// ✅ CORRECT: Registration matches field $component
Nova.booting((app) => {
  app.component('index-my-field', IndexField)  // matches $component = 'my-field'
})
```

### Symlink Broken

**Symptom**: `vendor/pcrcard/<package>` missing or broken

**Solution**:
```bash
rm -rf vendor/pcrcard/<package>
composer install                  # Recreates symlinks
```

### Asset Build Fails

**Symptom**: `npm run dev` or `npm run prod` fails

**Solution**:
```bash
rm -rf node_modules/
rm package-lock.json
npm install
npm run dev
```

### Package Not Found After Installation

**Symptom**: Composer can't find package

**Solution**: Verify composer.json configuration
```json
{
    "repositories": {
        "my-package": {
            "type": "path",
            "url": "packages/my-package"  // ✅ Correct path
        }
    },
    "require": {
        "pcrcard/my-package": "@dev"      // ✅ Correct constraint
    }
}
```

## Nova 5.x Specific Patterns

### Vue 3 Component Structure

```vue
<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  resourceName: String,
  resourceId: [String, Number],
  field: Object,
})

const value = ref(props.field.value || '')

const fill = (formData) => {
  formData.append(props.field.attribute, value.value)
}

defineExpose({ fill })
</script>
```

### Field Meta Data

```php
// Pass data to Vue component
MyField::make('Name')
    ->withMeta([
        'config' => [
            'option1' => true,
            'option2' => 'value',
        ],
    ]);
```

Access in Vue:
```javascript
// this.field.config (Options API)
// props.field.config (Composition API)
```

### Nova Mixins (Options API)

```javascript
import { DependentFormField, HandlesValidationErrors } from 'laravel-nova'

export default {
  mixins: [DependentFormField, HandlesValidationErrors],
  // ...
}
```

## Documentation References

### Package Documentation
- Package fork integration: `docs/development/PACKAGE-FORK-INTEGRATION-PLAN.md`
- BoundingBox field: `packages/nova-medialibrary-bounding-box-field/README.md`
- Nova menus: `packages/nova-menus/README.md`
- Package scripts: `scripts/lib/packages.sh`

### Related Guides
- Nova Admin Guide: `docs/development/NOVA-ADMIN-GUIDE.md`
- Nova Resource Builder skill: `.claude/skills/nova-resource/SKILL.md`

### External Resources
- Laravel Nova Docs: https://nova.laravel.com/docs/5.0
- Laravel Mix Docs: https://laravel-mix.com/docs/6.0
- Vue 3 Docs: https://vuejs.org/guide/
- Webpack Docs: https://webpack.js.org/

## Common Tasks Checklist

### Creating New Nova Field Package

- [ ] Fork upstream package (if applicable)
- [ ] Clone into `packages/` directory
- [ ] Update `composer.json` with `pcrcard/*` namespace
- [ ] Create PHP field class in `src/Fields/`
- [ ] Create Vue components in `resources/js/components/`
- [ ] Set up component registration in `resources/js/field.js`
- [ ] Configure `webpack.mix.js` with externals
- [ ] Create service provider with Nova::serving()
- [ ] Add package to main `composer.json`
- [ ] Add to `scripts/lib/packages.sh` get_forked_packages()
- [ ] Run `composer install`
- [ ] Build assets: `npm run prod`
- [ ] Commit dist/ files
- [ ] Test in Nova admin

### Modifying Existing Package

- [ ] Navigate to package directory
- [ ] Create feature branch (optional)
- [ ] Make code changes
- [ ] Build assets: `npm run dev`
- [ ] Test in main app
- [ ] Build production assets: `npm run prod`
- [ ] Commit changes (including dist/)
- [ ] Push to remote fork
- [ ] Update main app: `composer update pcrcard/<package>`

### Syncing with Upstream

- [ ] Add upstream remote: `git remote add upstream <url>`
- [ ] Fetch upstream: `git fetch upstream`
- [ ] Review changes: `git log upstream/master`
- [ ] Merge or rebase: `git merge upstream/master`
- [ ] Resolve conflicts
- [ ] Rebuild assets
- [ ] Test thoroughly
- [ ] Commit and push

---

**Last Updated**: October 2025
**Package Count**: 2 (nova-menus, nova-medialibrary-bounding-box-field)
**Nova Version**: 5.x (Vue 3, Laravel Mix 6.x)
