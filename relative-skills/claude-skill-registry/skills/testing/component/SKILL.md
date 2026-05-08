---
name: component
description: Crée des composants React pour Motivia. Utilise ce skill quand l'utilisateur demande de créer un composant, un bouton, un formulaire, une carte, ou tout élément UI. Suit les conventions shadcn/ui, Radix UI et les standards Ultracite.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Création de Composants Motivia

## Structure des fichiers

```
components/
├── ui/              # Composants shadcn/ui (primitives)
├── custom/          # Composants custom réutilisables
├── motivation-letter/  # Composants spécifiques aux lettres
├── landing/         # Composants landing page
└── icons/           # Composants icônes
```

## Conventions de code

### Imports (ordre strict)

```typescript
// 1. React et hooks
import { useState, useEffect } from "react";

// 2. Bibliothèques tierces
import { Loader2 } from "lucide-react";
import { cva, type VariantProps } from "class-variance-authority";

// 3. Composants UI internes (@/components/ui)
import { Button } from "@/components/ui/button";

// 4. Utilitaires (@/lib, @/utils)
import { cn } from "@/lib/utils";

// 5. Types
import type { ButtonHTMLAttributes } from "react";
```

### Pattern de composant

```typescript
// Interface avec types explicites
interface MonComposantProps extends HTMLAttributes<HTMLDivElement> {
  isLoading?: boolean;
  variant?: "default" | "secondary";
  children: React.ReactNode;
}

// Export nommé (pas de default export)
export const MonComposant = ({
  isLoading = false,
  variant = "default",
  children,
  className,
  ...props
}: MonComposantProps) => (
  <div className={cn("base-classes", className)} {...props}>
    {children}
  </div>
);
```

### Règles Ultracite

- **Pas de `React.forwardRef`** - React 19 supporte ref comme prop
- **Export nommé** uniquement, pas de `export default`
- **Interface explicite** pour les props
- **Utiliser `cn()`** pour combiner les classes
- **Button doit avoir `type`** explicite (`type="button"` ou `type="submit"`)
- **Pas de `any`** - utiliser `unknown` si nécessaire
- **Pas de `console.log`**

### Accessibilité (a11y)

Obligatoire sur tous les composants:

```typescript
// Boutons avec texte accessible
<button type="button" aria-label="Fermer">
  <X className="size-4" />
</button>

// Images avec alt
<img src={src} alt="Description significative" />

// Formulaires avec labels
<label htmlFor="email">Email</label>
<input id="email" type="email" />

// Interactions clavier
<div
  role="button"
  tabIndex={0}
  onClick={handleClick}
  onKeyDown={(e) => e.key === "Enter" && handleClick()}
>
```

## Variants avec CVA

Pour les composants avec plusieurs variants:

```typescript
import { cva, type VariantProps } from "class-variance-authority";

const cardVariants = cva(
  "rounded-lg border bg-card text-card-foreground shadow-sm",
  {
    variants: {
      variant: {
        default: "border-border",
        outline: "border-2 border-primary",
        ghost: "border-transparent shadow-none",
      },
      size: {
        sm: "p-4",
        default: "p-6",
        lg: "p-8",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
);

interface CardProps
  extends HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof cardVariants> {}

export const Card = ({ variant, size, className, ...props }: CardProps) => (
  <div className={cn(cardVariants({ variant, size }), className)} {...props} />
);
```

## Composants avec état de chargement

```typescript
import { Loader2 } from "lucide-react";

interface LoadingStateProps {
  isLoading: boolean;
  children: React.ReactNode;
}

export const WithLoading = ({ isLoading, children }: LoadingStateProps) => (
  <>
    {isLoading && (
      <Loader2 className="absolute top-1/2 left-1/2 size-4 animate-spin -translate-x-1/2 -translate-y-1/2" />
    )}
    <span className={cn(isLoading && "opacity-0")}>{children}</span>
  </>
);
```

## Checklist avant création

1. [ ] Le composant existe-t-il déjà dans `components/ui` ou `components/custom`?
2. [ ] Est-ce un composant shadcn/ui à ajouter via `npx shadcn@latest add`?
3. [ ] Doit-il être dans `ui/`, `custom/`, ou un dossier spécifique?
4. [ ] A-t-il besoin de variants (CVA)?
5. [ ] L'accessibilité est-elle couverte?
6. [ ] Les types sont-ils explicites?

## Ajout de composants shadcn/ui

Pour ajouter un composant shadcn existant:

```bash
npx shadcn@latest add <component-name>
```

Composants disponibles: accordion, alert, avatar, badge, button, calendar, card, checkbox, dialog, dropdown-menu, form, input, label, popover, select, separator, sheet, skeleton, slider, switch, table, tabs, textarea, toast, tooltip, etc.
