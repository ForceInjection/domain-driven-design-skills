---
name: multi-site-theming
description: Use when implementing per-site themes, white-labeling, or brand override systems. Covers tenant-specific branding, theme inheritance, CSS variable hierarchies, and dynamic theme switching for multi-site CMS architectures.
allowed-tools: Read, Glob, Grep, Task, Skill
---

# Multi-Site Theming

Guidance for implementing per-site themes, white-labeling, and brand customization in multi-site CMS architectures.

## When to Use This Skill

- Implementing per-tenant or per-site branding
- Designing theme inheritance hierarchies
- Building white-label customization systems
- Configuring dynamic theme switching
- Managing brand overrides at runtime

## Theme Architecture

### Theme Hierarchy

```text
┌─────────────────────────────────────────────────────────────────┐
│                      THEME HIERARCHY                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                    BASE THEME                            │   │
│   │  (Default colors, typography, spacing, components)       │   │
│   └─────────────────────────────────────────────────────────┘   │
│                              │                                   │
│                              ▼                                   │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                   BRAND THEME                            │   │
│   │  (Corporate colors, fonts, logo, brand identity)         │   │
│   └─────────────────────────────────────────────────────────┘   │
│                              │                                   │
│                              ▼                                   │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                   SITE THEME                             │   │
│   │  (Site-specific overrides, micro-branding)               │   │
│   └─────────────────────────────────────────────────────────┘   │
│                              │                                   │
│                              ▼                                   │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                   USER PREFERENCES                       │   │
│   │  (Dark/light mode, accessibility, contrast)              │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Theme Model

### Core Theme Entity

```csharp
public class Theme
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public ThemeType Type { get; set; }

    // Inheritance
    public Guid? ParentThemeId { get; set; }
    public Theme? ParentTheme { get; set; }

    // Scope
    public Guid? TenantId { get; set; }  // Null = global/base
    public Guid? SiteId { get; set; }    // Null = tenant-wide

    // Tokens
    public ThemeTokens Tokens { get; set; } = new();

    // Assets
    public ThemeAssets Assets { get; set; } = new();

    // Metadata
    public bool IsDefault { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedUtc { get; set; }
    public DateTime? ModifiedUtc { get; set; }
}

public enum ThemeType
{
    Base,       // Foundation theme
    Brand,      // Tenant/brand level
    Site,       // Individual site
    Variant     // Light/dark variants
}

public class ThemeTokens
{
    // Colors
    public ColorTokens Colors { get; set; } = new();

    // Typography
    public TypographyTokens Typography { get; set; } = new();

    // Spacing
    public SpacingTokens Spacing { get; set; } = new();

    // Borders & Shadows
    public BorderTokens Borders { get; set; } = new();
    public ShadowTokens Shadows { get; set; } = new();

    // Component-specific overrides
    public Dictionary<string, Dictionary<string, string>> Components { get; set; } = new();
}

public class ColorTokens
{
    // Brand colors
    public string Primary { get; set; } = "#3B82F6";
    public string Secondary { get; set; } = "#6366F1";
    public string Accent { get; set; } = "#F59E0B";

    // Semantic colors
    public string Success { get; set; } = "#10B981";
    public string Warning { get; set; } = "#F59E0B";
    public string Error { get; set; } = "#EF4444";
    public string Info { get; set; } = "#3B82F6";

    // Surface colors
    public string Background { get; set; } = "#FFFFFF";
    public string Surface { get; set; } = "#F9FAFB";
    public string Border { get; set; } = "#E5E7EB";

    // Text colors
    public string TextPrimary { get; set; } = "#111827";
    public string TextSecondary { get; set; } = "#6B7280";
    public string TextMuted { get; set; } = "#9CA3AF";
}

public class ThemeAssets
{
    public string? LogoUrl { get; set; }
    public string? LogoDarkUrl { get; set; }
    public string? FaviconUrl { get; set; }
    public string? BackgroundImageUrl { get; set; }
    public List<string> FontUrls { get; set; } = new();
    public string? CustomCss { get; set; }
}
```

## Theme Resolution

### Cascading Theme Service

```csharp
public class ThemeResolver
{
    public async Task<ResolvedTheme> ResolveAsync(ThemeContext context)
    {
        var themes = new List<Theme>();

        // 1. Load base theme
        var baseTheme = await _repository.GetBaseThemeAsync();
        if (baseTheme != null) themes.Add(baseTheme);

        // 2. Load tenant/brand theme
        if (context.TenantId.HasValue)
        {
            var tenantTheme = await _repository.GetTenantThemeAsync(context.TenantId.Value);
            if (tenantTheme != null) themes.Add(tenantTheme);
        }

        // 3. Load site theme
        if (context.SiteId.HasValue)
        {
            var siteTheme = await _repository.GetSiteThemeAsync(context.SiteId.Value);
            if (siteTheme != null) themes.Add(siteTheme);
        }

        // 4. Apply user preferences (dark mode, contrast)
        if (context.UserPreferences != null)
        {
            var variantTheme = await ResolveVariantAsync(themes.Last(), context.UserPreferences);
            if (variantTheme != null) themes.Add(variantTheme);
        }

        // Merge themes in order
        return MergeThemes(themes);
    }

    private ResolvedTheme MergeThemes(IEnumerable<Theme> themes)
    {
        var resolved = new ResolvedTheme();

        foreach (var theme in themes)
        {
            // Later themes override earlier ones
            MergeTokens(resolved.Tokens, theme.Tokens);
            MergeAssets(resolved.Assets, theme.Assets);
        }

        return resolved;
    }
}

public class ThemeContext
{
    public Guid? TenantId { get; set; }
    public Guid? SiteId { get; set; }
    public UserPreferences? UserPreferences { get; set; }
}

public class UserPreferences
{
    public ColorScheme ColorScheme { get; set; } = ColorScheme.System;
    public bool HighContrast { get; set; }
    public bool ReducedMotion { get; set; }
}

public enum ColorScheme
{
    Light,
    Dark,
    System
}
```

## CSS Variable Generation

### Variable Generator

```csharp
public class CssVariableGenerator
{
    public string GenerateCssVariables(ResolvedTheme theme)
    {
        var sb = new StringBuilder();

        sb.AppendLine(":root {");

        // Colors
        GenerateColorVariables(sb, theme.Tokens.Colors);

        // Typography
        GenerateTypographyVariables(sb, theme.Tokens.Typography);

        // Spacing
        GenerateSpacingVariables(sb, theme.Tokens.Spacing);

        // Borders & Shadows
        GenerateBorderVariables(sb, theme.Tokens.Borders);
        GenerateShadowVariables(sb, theme.Tokens.Shadows);

        sb.AppendLine("}");

        // Dark mode variant
        if (theme.DarkVariant != null)
        {
            sb.AppendLine();
            sb.AppendLine("@media (prefers-color-scheme: dark) {");
            sb.AppendLine("  :root {");
            GenerateColorVariables(sb, theme.DarkVariant.Colors, "    ");
            sb.AppendLine("  }");
            sb.AppendLine("}");

            // Manual dark mode class
            sb.AppendLine();
            sb.AppendLine("[data-theme=\"dark\"] {");
            GenerateColorVariables(sb, theme.DarkVariant.Colors, "  ");
            sb.AppendLine("}");
        }

        return sb.ToString();
    }

    private void GenerateColorVariables(
        StringBuilder sb,
        ColorTokens colors,
        string indent = "  ")
    {
        sb.AppendLine($"{indent}/* Brand Colors */");
        sb.AppendLine($"{indent}--color-primary: {colors.Primary};");
        sb.AppendLine($"{indent}--color-secondary: {colors.Secondary};");
        sb.AppendLine($"{indent}--color-accent: {colors.Accent};");
        sb.AppendLine();
        sb.AppendLine($"{indent}/* Semantic Colors */");
        sb.AppendLine($"{indent}--color-success: {colors.Success};");
        sb.AppendLine($"{indent}--color-warning: {colors.Warning};");
        sb.AppendLine($"{indent}--color-error: {colors.Error};");
        sb.AppendLine($"{indent}--color-info: {colors.Info};");
        sb.AppendLine();
        sb.AppendLine($"{indent}/* Surface Colors */");
        sb.AppendLine($"{indent}--color-background: {colors.Background};");
        sb.AppendLine($"{indent}--color-surface: {colors.Surface};");
        sb.AppendLine($"{indent}--color-border: {colors.Border};");
        sb.AppendLine();
        sb.AppendLine($"{indent}/* Text Colors */");
        sb.AppendLine($"{indent}--color-text-primary: {colors.TextPrimary};");
        sb.AppendLine($"{indent}--color-text-secondary: {colors.TextSecondary};");
        sb.AppendLine($"{indent}--color-text-muted: {colors.TextMuted};");
    }
}
```

### Generated CSS Output

```css
:root {
  /* Brand Colors */
  --color-primary: #3B82F6;
  --color-secondary: #6366F1;
  --color-accent: #F59E0B;

  /* Semantic Colors */
  --color-success: #10B981;
  --color-warning: #F59E0B;
  --color-error: #EF4444;
  --color-info: #3B82F6;

  /* Surface Colors */
  --color-background: #FFFFFF;
  --color-surface: #F9FAFB;
  --color-border: #E5E7EB;

  /* Text Colors */
  --color-text-primary: #111827;
  --color-text-secondary: #6B7280;
  --color-text-muted: #9CA3AF;

  /* Typography */
  --font-family-base: 'Inter', system-ui, sans-serif;
  --font-family-heading: 'Inter', system-ui, sans-serif;
  --font-size-xs: 0.75rem;
  --font-size-sm: 0.875rem;
  --font-size-base: 1rem;
  --font-size-lg: 1.125rem;
  --font-size-xl: 1.25rem;

  /* Spacing */
  --spacing-1: 0.25rem;
  --spacing-2: 0.5rem;
  --spacing-3: 0.75rem;
  --spacing-4: 1rem;
  --spacing-6: 1.5rem;
  --spacing-8: 2rem;
}

@media (prefers-color-scheme: dark) {
  :root {
    --color-background: #111827;
    --color-surface: #1F2937;
    --color-border: #374151;
    --color-text-primary: #F9FAFB;
    --color-text-secondary: #D1D5DB;
    --color-text-muted: #9CA3AF;
  }
}

[data-theme="dark"] {
  --color-background: #111827;
  --color-surface: #1F2937;
  --color-border: #374151;
  --color-text-primary: #F9FAFB;
  --color-text-secondary: #D1D5DB;
  --color-text-muted: #9CA3AF;
}
```

## Theme API

### REST Endpoints

```text
GET    /api/themes                    # List all themes
GET    /api/themes/{id}               # Get theme by ID
POST   /api/themes                    # Create theme
PUT    /api/themes/{id}               # Update theme
DELETE /api/themes/{id}               # Delete theme

GET    /api/themes/resolve            # Resolve current theme (by context)
GET    /api/themes/{id}/css           # Get generated CSS
GET    /api/themes/{id}/variables     # Get CSS variables JSON
POST   /api/themes/{id}/preview       # Preview theme changes
```

### Theme Delivery Endpoint

```csharp
[Route("api/themes")]
public class ThemeController : ControllerBase
{
    [HttpGet("resolve/css")]
    [ResponseCache(Duration = 3600, VaryByHeader = "X-Tenant-Id,X-Site-Id")]
    public async Task<IActionResult> GetResolvedCss(
        [FromHeader(Name = "X-Tenant-Id")] Guid? tenantId,
        [FromHeader(Name = "X-Site-Id")] Guid? siteId)
    {
        var context = new ThemeContext
        {
            TenantId = tenantId,
            SiteId = siteId
        };

        var theme = await _resolver.ResolveAsync(context);
        var css = _generator.GenerateCssVariables(theme);

        return Content(css, "text/css");
    }

    [HttpGet("{id}/variables")]
    public async Task<ActionResult<ThemeTokens>> GetVariables(Guid id)
    {
        var theme = await _repository.GetByIdAsync(id);
        if (theme == null) return NotFound();

        return Ok(theme.Tokens);
    }
}
```

## White-Label Configuration

### Tenant Branding Settings

```csharp
public class TenantBrandingSettings
{
    // Identity
    public string CompanyName { get; set; } = string.Empty;
    public string ProductName { get; set; } = string.Empty;

    // Visual Identity
    public Guid? ThemeId { get; set; }
    public string? CustomDomain { get; set; }

    // Logos
    public string? LogoUrl { get; set; }
    public string? LogoDarkUrl { get; set; }
    public string? FaviconUrl { get; set; }
    public string? AppIconUrl { get; set; }

    // Contact
    public string? SupportEmail { get; set; }
    public string? SupportUrl { get; set; }

    // Legal
    public string? TermsUrl { get; set; }
    public string? PrivacyUrl { get; set; }

    // Feature Flags
    public bool ShowPoweredBy { get; set; } = true;
    public bool CustomEmailTemplates { get; set; }
}
```

## Frontend Integration

### Blazor Theme Provider

```csharp
@inject IThemeService ThemeService

<CascadingValue Value="@CurrentTheme">
    @ChildContent
</CascadingValue>

@code {
    [Parameter]
    public RenderFragment? ChildContent { get; set; }

    private ResolvedTheme? CurrentTheme { get; set; }

    protected override async Task OnInitializedAsync()
    {
        CurrentTheme = await ThemeService.GetCurrentThemeAsync();
    }
}
```

### JavaScript Theme Switching

```javascript
// Theme switcher
const ThemeSwitcher = {
    setTheme(theme) {
        document.documentElement.setAttribute('data-theme', theme);
        localStorage.setItem('theme', theme);
    },

    getTheme() {
        return localStorage.getItem('theme') ||
               (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
    },

    init() {
        this.setTheme(this.getTheme());

        // Listen for system changes
        window.matchMedia('(prefers-color-scheme: dark)')
            .addEventListener('change', e => {
                if (!localStorage.getItem('theme')) {
                    this.setTheme(e.matches ? 'dark' : 'light');
                }
            });
    }
};
```

## Related Skills

- `design-token-management` - Token schemas and Style Dictionary
- `headless-api-design` - Theme API delivery
- `content-type-modeling` - Theme as content type
