---
name: filament-plugin-scaffold
description: Scaffold Filament plugins with Plugin class, ServiceProvider, Resources, and Pest tests
allowed-tools: Bash(python3:*), Write, Read, Glob
---

# Filament Plugin Scaffold Skill

Creates a complete Filament plugin skeleton (panel or standalone) following Filament's official plugin development guidelines.

## Usage

When the user wants to create a Filament plugin, use the scaffold script:

```bash
python3 ${SKILL_DIR}/scripts/scaffold_filament_plugin.py <vendor/plugin-name> [options]
```

## Options

- `--with-resource <name>` - Include a sample Resource
- `--with-page` - Include a sample custom Page
- `--with-widget` - Include a sample Widget
- `--with-livewire` - Include Livewire component structure
- `--with-pest` - Include PestPHP testing (default: yes)
- `--no-pest` - Exclude PestPHP testing

## Examples

### Basic Filament plugin
```bash
python3 ${SKILL_DIR}/scripts/scaffold_filament_plugin.py mwguerra/filament-blog
```

### Plugin with Resource
```bash
python3 ${SKILL_DIR}/scripts/scaffold_filament_plugin.py mwguerra/filament-blog --with-resource Post
```

### Full-featured plugin
```bash
python3 ${SKILL_DIR}/scripts/scaffold_filament_plugin.py mwguerra/filament-blog --with-resource Post --with-page --with-widget
```

## What Gets Created

### Directory Structure
```
packages/
└── vendor/
    └── filament-plugin-name/
        ├── composer.json
        ├── README.md
        ├── LICENSE
        ├── .gitignore
        ├── phpunit.xml
        ├── config/
        │   └── filament-plugin-name.php
        ├── database/
        │   └── migrations/
        │       └── .gitkeep
        ├── resources/
        │   ├── lang/
        │   │   └── en/
        │   │       └── messages.php
        │   └── views/
        │       └── .gitkeep
        ├── src/
        │   ├── PluginNamePlugin.php
        │   ├── PluginNameServiceProvider.php
        │   ├── Facades/
        │   │   └── PluginName.php
        │   ├── Resources/
        │   │   └── .gitkeep (or generated Resource)
        │   ├── Pages/
        │   │   └── .gitkeep (or generated Page)
        │   ├── Widgets/
        │   │   └── .gitkeep (or generated Widget)
        │   ├── Livewire/
        │   │   └── .gitkeep
        │   └── Commands/
        │       └── .gitkeep
        └── tests/
            ├── Pest.php
            ├── TestCase.php
            ├── Unit/
            │   └── ExampleTest.php
            └── Feature/
                └── .gitkeep
```

### Generated Files

1. **composer.json**
   - Filament ^3.3 (latest)
   - Livewire ^3.6 (latest)
   - Laravel ^11.0|^12.0 support
   - Orchestra Testbench ^10.0 (latest)
   - PestPHP ^3.8 (latest)
   - PSR-4 autoloading
   - Laravel auto-discovery

2. **Plugin Class** (`PluginNamePlugin.php`)
   - Implements `Filament\Contracts\Plugin`
   - Resource, Page, Widget registration
   - Panel configuration hooks

3. **ServiceProvider**
   - View namespace registration
   - Translation loading
   - Migration publishing
   - Config merging

4. **Resource** (if `--with-resource`)
   - Form schema
   - Table configuration
   - Resource pages (List, Create, Edit)

5. **Page** (if `--with-page`)
   - Custom Filament page
   - View and logic

6. **Widget** (if `--with-widget`)
   - Dashboard widget
   - Stats or chart example

7. **Testing Setup**
   - PestPHP configuration
   - Orchestra Testbench
   - Livewire testing utilities

## After Running

1. **Install dependencies**:
   ```bash
   composer update
   ```

2. **Register plugin in Panel Provider**:
   ```php
   use Vendor\PluginName\PluginNamePlugin;
   
   public function panel(Panel $panel): Panel
   {
       return $panel
           ->plugins([
               PluginNamePlugin::make(),
           ]);
   }
   ```

3. **Publish assets** (if needed):
   ```bash
   php artisan vendor:publish --tag=filament-plugin-name-config
   php artisan vendor:publish --tag=filament-plugin-name-migrations
   ```

4. **Run tests**:
   ```bash
   cd packages/vendor/filament-plugin-name
   composer install
   ./vendor/bin/pest
   ```

## Filament Plugin Best Practices

1. **Use the Plugin Contract**: Always implement `Filament\Contracts\Plugin`
2. **Register in boot()**: Register resources/pages/widgets in `boot()` method
3. **Support Panel Configuration**: Allow users to customize via `->plugin()`
4. **Translations**: Use translation keys for all user-facing strings
5. **Views**: Use namespaced views (`filament-plugin-name::view-name`)
6. **Testing**: Test Livewire components with `Livewire::test()`
