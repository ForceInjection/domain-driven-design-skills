---
name: theme-implementer
description:
    Implement and test custom color schemes, themes, and visual variants for the
    emotive-mascot website and demos. Use when applying new color palettes,
    creating themed variants, or A/B testing visual designs.
trigger: theme, color scheme, visual design, branding, color palette, styling
---

# Theme Implementer

You are an expert in implementing and testing visual themes for the
emotive-mascot platform.

## When to Use This Skill

- Applying new color schemes to the website
- Creating themed demo variants
- Implementing brand-specific mascot colors
- A/B testing visual designs
- Adapting mascot colors to match client branding
- Creating seasonal or event-specific themes

## Available Color Schemes

From the theme-factory skill, we have 3 ready-to-use variants:

### 1. Warm & Energetic (Orange)

**Use for**: E-commerce, retail, food & beverage, entertainment **Primary**:
#FF8C42 (Vibrant Orange) **Accent**: #FF6B35 (Coral)

### 2. Cool & Professional (Cyan)

**Use for**: Healthcare, finance, technology, corporate **Primary**: #06B6D4
(Cyan) **Accent**: #0891B2 (Darker Cyan)

### 3. Monochrome & Premium (Gold)

**Use for**: Luxury, premium products, high-end services **Primary**: #D4AF37
(Gold) **Accent**: #B8960F (Rich Gold)

## Implementation Pattern

### Step 1: CSS Variables Approach

Create theme variants using CSS custom properties:

```css
/* site/src/app/globals.css */

:root {
    /* Default theme (Purple/Blue) */
    --color-primary: #667eea;
    --color-primary-light: #a5b4fc;
    --color-primary-dark: #4c51bf;
    --color-accent: #764ba2;
    --color-accent-light: #9d7cbf;
}

/* Warm theme */
[data-theme='warm'] {
    --color-primary: #ff8c42;
    --color-primary-light: #ffb088;
    --color-primary-dark: #e67a2e;
    --color-accent: #ff6b35;
    --color-accent-light: #ff9270;
}

/* Cool theme */
[data-theme='cool'] {
    --color-primary: #06b6d4;
    --color-primary-light: #67e8f9;
    --color-primary-dark: #0891b2;
    --color-accent: #0e7490;
    --color-accent-light: #22d3ee;
}

/* Premium theme */
[data-theme='premium'] {
    --color-primary: #d4af37;
    --color-primary-light: #f4d03f;
    --color-primary-dark: #b8960f;
    --color-accent: #8b7500;
    --color-accent-light: #e6c200;
}
```

### Step 2: Update Components to Use Variables

Replace hardcoded colors with CSS variables:

```tsx
// Before (hardcoded)
<div style={{
  background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
  border: '1px solid rgba(102, 126, 234, 0.3)'
}}>
  ...
</div>

// After (themeable)
<div style={{
  background: 'linear-gradient(135deg, var(--color-primary) 0%, var(--color-accent) 100%)',
  border: '1px solid rgba(var(--color-primary-rgb), 0.3)'
}}>
  ...
</div>
```

### Step 3: Theme Switcher Component

```tsx
// site/src/components/ThemeSwitcher.tsx
'use client';

import { useState, useEffect } from 'react';

type Theme = 'default' | 'warm' | 'cool' | 'premium';

export default function ThemeSwitcher() {
    const [theme, setTheme] = useState<Theme>('default');

    useEffect(() => {
        // Load theme from localStorage
        const savedTheme =
            (localStorage.getItem('theme') as Theme) || 'default';
        setTheme(savedTheme);
        document.documentElement.setAttribute('data-theme', savedTheme);
    }, []);

    const handleThemeChange = (newTheme: Theme) => {
        setTheme(newTheme);
        document.documentElement.setAttribute('data-theme', newTheme);
        localStorage.setItem('theme', newTheme);
    };

    return (
        <div
            style={{
                position: 'fixed',
                top: '20px',
                right: '20px',
                zIndex: 9999,
                display: 'flex',
                gap: '0.5rem',
                padding: '0.75rem',
                background: 'rgba(0, 0, 0, 0.8)',
                borderRadius: '12px',
                backdropFilter: 'blur(10px)',
            }}
        >
            <button
                onClick={() => handleThemeChange('default')}
                style={{
                    width: '40px',
                    height: '40px',
                    borderRadius: '8px',
                    background:
                        'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                    border: theme === 'default' ? '2px solid white' : 'none',
                    cursor: 'pointer',
                }}
                title="Default (Purple)"
            />
            <button
                onClick={() => handleThemeChange('warm')}
                style={{
                    width: '40px',
                    height: '40px',
                    borderRadius: '8px',
                    background:
                        'linear-gradient(135deg, #FF8C42 0%, #FF6B35 100%)',
                    border: theme === 'warm' ? '2px solid white' : 'none',
                    cursor: 'pointer',
                }}
                title="Warm (Orange)"
            />
            <button
                onClick={() => handleThemeChange('cool')}
                style={{
                    width: '40px',
                    height: '40px',
                    borderRadius: '8px',
                    background:
                        'linear-gradient(135deg, #06B6D4 0%, #0891B2 100%)',
                    border: theme === 'cool' ? '2px solid white' : 'none',
                    cursor: 'pointer',
                }}
                title="Cool (Cyan)"
            />
            <button
                onClick={() => handleThemeChange('premium')}
                style={{
                    width: '40px',
                    height: '40px',
                    borderRadius: '8px',
                    background:
                        'linear-gradient(135deg, #D4AF37 0%, #B8960F 100%)',
                    border: theme === 'premium' ? '2px solid white' : 'none',
                    cursor: 'pointer',
                }}
                title="Premium (Gold)"
            />
        </div>
    );
}
```

### Step 4: Update Mascot Colors

Sync mascot emotion colors with theme:

```javascript
// Create theme-aware emotion configs
const getThemedEmotions = (theme = 'default') => {
    const themeColors = {
        default: {
            joy: '#FFD700',
            calm: '#667eea',
            excitement: '#FF6B9D',
        },
        warm: {
            joy: '#FF8C42',
            calm: '#FFB088',
            excitement: '#FF6B35',
        },
        cool: {
            joy: '#67E8F9',
            calm: '#06B6D4',
            excitement: '#22D3EE',
        },
        premium: {
            joy: '#F4D03F',
            calm: '#D4AF37',
            excitement: '#E6C200',
        },
    };

    return {
        joy: {
            ...baseEmotions.joy,
            color: themeColors[theme].joy,
        },
        calm: {
            ...baseEmotions.calm,
            color: themeColors[theme].calm,
        },
        excitement: {
            ...baseEmotions.excitement,
            color: themeColors[theme].excitement,
        },
    };
};

// Usage in component
const mascot = new EmotiveMascot({
    containerId: 'mascot',
    emotions: getThemedEmotions(currentTheme),
});
```

## Files to Update

### 1. Global Styles

**File**: `site/src/app/globals.css`

Add CSS variable definitions for all themes

### 2. Home Page

**File**: `site/src/app/page.tsx`

Replace hardcoded colors:

- Hero gradient backgrounds
- Button colors
- Border colors
- Text gradients
- Section backgrounds

### 3. Components

Update these components to use CSS variables:

**FeaturesShowcase.tsx**:

```tsx
// Update feature card borders and backgrounds
border: `1px solid var(--color-primary-light)`,
background: `linear-gradient(135deg, rgba(var(--color-primary-rgb), 0.15) 0%, rgba(var(--color-primary-rgb), 0.05) 100%)`
```

**PremiumAIAssistant.tsx**:

```tsx
// Update panel styling
background: 'linear-gradient(135deg, var(--color-primary) 0%, var(--color-accent) 100%)';
```

**Use Case Pages**:

- `site/src/app/use-cases/retail/page.tsx`
- `site/src/app/use-cases/smart-home/page.tsx`
- `site/src/app/use-cases/healthcare/page.tsx`
- `site/src/app/use-cases/education/page.tsx`

### 4. Emotion Configs

**File**: `src/config/emotions.js`

Create theme-aware emotion color mappings

## A/B Testing Implementation

### Setup Analytics

```tsx
// site/src/components/ThemeAnalytics.tsx
'use client';

import { useEffect } from 'react';

export function trackThemeImpression(theme: string) {
    // Google Analytics
    if (typeof window !== 'undefined' && window.gtag) {
        window.gtag('event', 'theme_impression', {
            theme_variant: theme,
            timestamp: Date.now(),
        });
    }

    // Or custom analytics
    fetch('/api/analytics/theme-impression', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ theme, timestamp: Date.now() }),
    });
}

export function trackThemeConversion(theme: string, action: string) {
    if (typeof window !== 'undefined' && window.gtag) {
        window.gtag('event', 'theme_conversion', {
            theme_variant: theme,
            conversion_action: action,
            timestamp: Date.now(),
        });
    }
}
```

### Random Theme Assignment

```tsx
// site/src/app/layout.tsx
'use client';

import { useEffect, useState } from 'react';

export default function RootLayout({ children }) {
    const [theme, setTheme] = useState<string>('default');

    useEffect(() => {
        // Check if user already has a theme assigned
        let assignedTheme = localStorage.getItem('ab-theme');

        if (!assignedTheme) {
            // Randomly assign theme for A/B test
            const themes = ['default', 'warm', 'cool', 'premium'];
            assignedTheme = themes[Math.floor(Math.random() * themes.length)];
            localStorage.setItem('ab-theme', assignedTheme);
        }

        setTheme(assignedTheme);
        document.documentElement.setAttribute('data-theme', assignedTheme);

        // Track impression
        trackThemeImpression(assignedTheme);
    }, []);

    return (
        <html lang="en" data-theme={theme}>
            <body>{children}</body>
        </html>
    );
}
```

### Track Conversions

```tsx
// In waitlist form
const handleSubmit = async (email: string) => {
    // Submit form
    await submitWaitlist(email);

    // Track conversion with current theme
    const theme = document.documentElement.getAttribute('data-theme');
    trackThemeConversion(theme, 'waitlist_signup');
};

// In demo interactions
const handleDemoStart = () => {
    const theme = document.documentElement.getAttribute('data-theme');
    trackThemeConversion(theme, 'demo_started');
};
```

## RGB Color Utilities

For rgba() usage, add RGB values to CSS:

```css
:root {
    --color-primary: #667eea;
    --color-primary-rgb: 102, 126, 234; /* For rgba() */
}

[data-theme='warm'] {
    --color-primary: #ff8c42;
    --color-primary-rgb: 255, 140, 66;
}
```

Or use JavaScript:

```javascript
function hexToRgb(hex) {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result
        ? {
              r: parseInt(result[1], 16),
              g: parseInt(result[2], 16),
              b: parseInt(result[3], 16),
          }
        : null;
}

// Usage
const rgb = hexToRgb('#667eea');
const rgba = `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, 0.3)`;
```

## Testing Checklist

- [ ] All 4 themes render correctly on home page
- [ ] Theme switcher works and persists across page loads
- [ ] Mascot colors update when theme changes
- [ ] All use cases respect theme colors
- [ ] Mobile view looks good in all themes
- [ ] Contrast ratios meet WCAG AA standards
- [ ] No hardcoded colors remain (search for hex codes)
- [ ] Analytics tracking captures theme impressions
- [ ] Conversion tracking works for each theme
- [ ] A/B test random assignment is balanced

## Accessibility Considerations

Ensure sufficient contrast for all themes:

```javascript
// Check contrast ratio (WCAG AA requires 4.5:1 for normal text)
function getContrastRatio(color1, color2) {
    const l1 = getLuminance(color1);
    const l2 = getLuminance(color2);
    const lighter = Math.max(l1, l2);
    const darker = Math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
}

function getLuminance(hex) {
    const rgb = hexToRgb(hex);
    const [r, g, b] = [rgb.r, rgb.g, rgb.b].map(val => {
        val = val / 255;
        return val <= 0.03928
            ? val / 12.92
            : Math.pow((val + 0.055) / 1.055, 2.4);
    });
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

// Test all themes
const themes = {
    default: { bg: '#0a0a0a', text: '#ffffff' },
    warm: { bg: '#0a0a0a', text: '#FF8C42' },
    cool: { bg: '#0a0a0a', text: '#06B6D4' },
    premium: { bg: '#0a0a0a', text: '#D4AF37' },
};

Object.entries(themes).forEach(([name, colors]) => {
    const ratio = getContrastRatio(colors.bg, colors.text);
    console.log(
        `${name} theme contrast: ${ratio.toFixed(2)}:1 ${ratio >= 4.5 ? '✓' : '✗'}`
    );
});
```

## Quick Theme Application

Use this command to quickly apply a theme across the codebase:

```bash
# Find all hardcoded color references
grep -r "#667eea" site/src --include="*.tsx" --include="*.ts" --include="*.css"

# Replace with CSS variable (manual verification recommended)
find site/src -type f \( -name "*.tsx" -o -name "*.ts" -o -name "*.css" \) -exec sed -i 's/#667eea/var(--color-primary)/g' {} +
```

## Key Files

- **Global Styles**: `site/src/app/globals.css`
- **Theme Switcher**: `site/src/components/ThemeSwitcher.tsx`
- **Analytics**: `site/src/components/ThemeAnalytics.tsx`
- **Emotion Themes**: `src/config/emotions-themed.js`
- **Home Page**: `site/src/app/page.tsx`
- **Use Cases**: `site/src/app/use-cases/*/page.tsx`

## Resources

- [CSS Custom Properties (MDN)](https://developer.mozilla.org/en-US/docs/Web/CSS/--*)
- [WCAG Contrast Guidelines](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)
- [Color Accessibility Checker](https://webaim.org/resources/contrastchecker/)
- [Theme Factory Results](../../docs/theme-factory-results.md)
