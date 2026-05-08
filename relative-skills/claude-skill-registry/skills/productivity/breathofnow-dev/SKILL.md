---
name: breathofnow-dev
description: Master skill for Breath of Now development. Provides comprehensive project context, architecture guidelines, and development workflows. Auto-invoked for all development tasks in the project.
---

# Breath of Now Development Skill

Este é o skill master para desenvolvimento do ecossistema Breath of Now - uma plataforma privacy-first e offline-first de micro-apps para vida consciente.

## Visão Geral

**Breath of Now** é um ecossistema de micro-apps sob **M21 Global, Lda**.

### Filosofia Core
- **Offline First**: Browser é a fonte de verdade - funciona 100% sem internet
- **Privacy First**: Dados nunca saem do dispositivo sem consentimento
- **Conscious Minimalism**: Apps simples e focadas
- **Data Sovereignty**: Utilizadores são donos dos dados
- **Acessibilidade**: Preços regionais, múltiplos idiomas

### Apps no Ecossistema

| App | Estado | Descrição |
|-----|--------|-----------|
| ExpenseFlow | ✅ Live | Gestão de despesas |
| FitLog | ✅ Live | Registo de treinos |
| InvestTrack | 🧪 Beta | Tracking de investimentos |
| RecipeBox | 🔜 Em breve | Gestão de receitas |
| LabelScan | 🔜 Em breve | Scanner de etiquetas |

## Tech Stack

| Camada | Tecnologia |
|--------|------------|
| Framework | Next.js 14 (App Router) |
| Linguagem | TypeScript (strict mode) |
| Styling | Tailwind CSS |
| State | Zustand (apenas UI) |
| Local DB | Dexie.js (IndexedDB) |
| Backend | Supabase (auth + sync opcional) |
| i18n | next-intl |
| PWA | next-pwa (Workbox) |
| Hosting | Vercel |

## Estrutura de Pastas

```
breathofnow/
├── .claude/                     # Documentação Claude Code
│   ├── skills/                  # Skills para Claude
│   ├── commands/                # Comandos slash
│   ├── PROJECT.md               # Visão geral
│   ├── RULES.md                 # Regras de código
│   └── supabase-schema.md       # Schema da BD
├── messages/                    # Ficheiros de tradução (4 idiomas)
├── src/
│   ├── app/[locale]/            # Páginas localizadas
│   ├── components/
│   │   ├── ui/                  # Design system
│   │   ├── shell/               # App shell unificado
│   │   └── layout/              # Header, Footer
│   ├── lib/
│   │   ├── storage/             # NEW: Storage API unificada
│   │   ├── subscription/        # NEW: Gestão de tiers
│   │   ├── db/                  # Dexie database
│   │   ├── supabase/            # Clientes Supabase
│   │   └── sync/                # Sync engine
│   ├── hooks/                   # Custom hooks (incl. useSubscription)
│   ├── stores/                  # Zustand stores
│   └── types/                   # TypeScript types
└── docs/
    └── ARCHITECTURE.md          # Arquitetura detalhada
```

## Princípios de Desenvolvimento

### Princípio 1: Usar Storage API (NEW)

```typescript
// ✅ CORRECTO: Usar Storage API
import { storage, NAMESPACES } from '@/lib/storage';
const expenses = await storage.getAll(NAMESPACES.EXPENSES);

// ❌ ERRADO: Acesso direto ao Dexie
import { db } from '@/lib/db';
const expenses = await db.expenseTransactions.toArray();
```

### Princípio 2: Usar Hooks de Subscription (NEW)

```typescript
// ✅ CORRECTO: Usar hook
import { useSubscription } from '@/hooks';
const { tier, isPro, checkAppAccess } = useSubscription();

// ❌ ERRADO: Verificação manual
const isPro = user?.tier === 'pro';
```

### Princípio 3: Zero Texto Hardcoded

```typescript
// ✅ CORRECTO
const t = useTranslations('namespace');
<h1>{t('title')}</h1>

// ❌ ERRADO
<h1>Welcome</h1>
```

### Princípio 4: TypeScript Strict Mode

```typescript
// ✅ CORRECTO: Tipos de @/types
import type { AppId, User } from '@/types';

// ❌ ERRADO: any types
const handleClick = (data: any) => { ... }
```

## Sistema de Tiers (Simplificado v4)

| | Free | Pro |
|---|---|---|
| **Preço** | €0 | €4.99/mês |
| **Apps** | 2 apps | Todas |
| **Storage local** | ✅ | ✅ |
| **Cloud sync** | ❌ | ✅ |
| **Ads** | Sim | Não |

## Design System

### Cores
- **Primary**: `#5a7d5a` (Warm Sage Green)
- **Secondary**: `#b19373` (Warm Sand)
- **Accent**: `#df7459` (Soft Terracotta)

### Fontes
- **Títulos**: Fraunces (`font-display`)
- **Corpo**: Source Sans 3 (`font-body`)
- **Mono**: JetBrains Mono (`font-mono`)

### Componentes UI
Em `@/components/ui/`:
- Button, Input, Card, Badge, PriceSlider

## APIs Disponíveis

### Storage API

```typescript
import { storage, NAMESPACES } from '@/lib/storage';

storage.get(namespace, key)      // Obter item
storage.set(namespace, key, val) // Guardar item
storage.delete(namespace, key)   // Apagar item
storage.getAll(namespace)        // Obter todos
storage.query(namespace, filter) // Query com filtro
storage.clear(namespace)         // Limpar namespace
```

### Subscription Hook

```typescript
import { useSubscription } from '@/hooks';

const {
  tier,           // 'free' | 'pro'
  isPro,          // boolean
  canSync,        // boolean
  showAds,        // boolean
  selectedApps,   // AppId[]
  checkAppAccess, // (appId) => boolean
} = useSubscription();
```

## Idiomas Suportados

| Código | Idioma | Prioridade |
|--------|--------|------------|
| en | English | Primary |
| pt | Português | Alta |
| es | Español | Média |
| fr | Français | Média |

## Comandos Rápidos

```bash
npm run dev       # Desenvolvimento
npx tsc --noEmit  # Type check
npm run lint      # Lint
npm run build     # Build
```

## Ficheiros Críticos

- `.claude/PROJECT.md` - Visão geral detalhada
- `.claude/RULES.md` - Regras de código (incluindo Storage API)
- `docs/ARCHITECTURE.md` - Arquitetura v4
- `.claude/supabase-schema.md` - Schema da BD

## Domínio

- **Website**: www.breathofnow.site
- **App**: app.breathofnow.site

---

Lembra-te: Cada feature deve alinhar com a missão de **ajudar pessoas a viver mais conscientemente** enquanto **respeita a sua privacidade**.
