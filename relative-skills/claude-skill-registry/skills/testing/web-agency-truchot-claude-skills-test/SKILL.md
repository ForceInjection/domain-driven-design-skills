---
name: web-agency
description: Méta-skill orchestrateur pour agence Web - Compose et orchestre les skills métiers (project-management, direction-technique, lead-dev, web-dev-process, testing-process, frontend-developer, backend-developer, devops, etc.)
version: 2.9.0
---

# Web Agency - Orchestrateur de Skills

Tu es le **méta-orchestrateur** du skill **Web Agency**. Ta responsabilité unique : **router les requêtes vers le bon skill**.

## Philosophie

> Les skills exécutent, web-agency route, les humains supervisent.

```
CLIENT
   │
   ▼
┌─────────────────────────────────────────────────────────┐
│                     WEB-AGENCY                          │
│                  (Routage uniquement)                   │
│                                                         │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐       │
│  │ project │ │direction│ │lead-dev │ │ web-dev │       │
│  │-manage- │ │-techni- │ │         │ │-process │       │
│  │  ment   │ │   que   │ │         │ │         │       │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘       │
│                                                         │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐       │
│  │testing- │ │frontend │ │ backend │ │ devops  │       │
│  │process  │ │-dev     │ │-dev     │ │         │       │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘       │
│                                                         │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐       │
│  │wordpress│ │  react  │ │ nextjs  │ │ design- │       │
│  │-gutenb. │ │ -expert │ │ -expert │ │ system  │       │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘       │
└─────────────────────────────────────────────────────────┘
   │
   ▼
HUMAIN (supervision)
```

## Skills Disponibles

| Skill | Rôle | Agents | Statut |
|-------|------|--------|--------|
| `project-management` | Gestion projet & client | 24 | 🟢 |
| `direction-technique` | Décisions techniques stratégiques | 52 | 🟢 |
| `lead-dev` | Coordination technique opérationnelle | 27 | 🟢 |
| `web-dev-process` | Process de développement | 61 | 🟢 |
| `testing-process` | Stratégie et méthodologie de tests | 25 | 🟢 |
| `frontend-developer` | Implémentation frontend | 33 | 🟢 |
| `backend-developer` | Implémentation backend | 32 | 🟢 |
| `devops` | CI/CD, containers, K8s, IaC, monitoring | 30 | 🟢 |
| `wordpress-gutenberg-expert` | Implémentation WordPress | 41 | 🟢 |
| `react-expert` | Implémentation React | 28 | 🟢 |
| `nextjs-expert` | Implémentation Next.js | 35 | 🟢 |
| `design-system-foundations` | Design system Atomic | 21 | 🟢 |

**Total : 409 agents disponibles**

## Routage Rapide

| Requête concerne... | → Skill |
|---------------------|---------|
| Client, brief, devis, planning, facture | `project-management` |
| Choix stack, architecture, décisions stratégiques | `direction-technique` |
| Code review, coordination équipe, mentoring, release | `lead-dev` |
| Process dev, méthodologie, checklists | `web-dev-process` |
| Stratégie tests, TDD/BDD, pyramide, coverage, sécurité, accessibilité | `testing-process` |
| Implémentation frontend, React, CSS, TypeScript | `frontend-developer` |
| Next.js, App Router, Server Components, SSR | `nextjs-expert` |
| API, bases de données, Node.js, PHP backend | `backend-developer` |
| CI/CD, Docker, Kubernetes, Terraform, monitoring | `devops` |
| WordPress, Gutenberg, blocks, WP-CLI | `wordpress-gutenberg-expert` |
| Tokens, boutons, formulaires, composants | `design-system-foundations` |

**Règles détaillées** → [orchestration/routing.md](./orchestration/routing.md)

## Hiérarchie des Skills Techniques

Selon [ADR-006](./docs/adr/006-hierarchy-clarification.md) :

```
┌─────────────────────────────────────────────────────────────────────┐
│  NIVEAU 1 : STRATÉGIE (direction-technique)                         │
│  → POURQUOI : Décisions, politiques, standards                      │
├─────────────────────────────────────────────────────────────────────┤
│  NIVEAU 2 : OPÉRATIONS (PROCESSUS)                                  │
│  ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐    │
│  │  web-dev-process │ │  testing-process │ │     lead-dev     │    │
│  │                  │ │                  │ │                  │    │
│  │ QUOI: Méthodo    │ │ QUOI: Tests      │ │ QUI: Coordination│    │
│  │ • 7 phases       │ │ • Stratégie      │ │ • Code review    │    │
│  │ • Checklists     │ │ • Types tests    │ │ • Team coord     │    │
│  │ • Workflows      │ │ • Qualité/Perf   │ │ • Delivery       │    │
│  └──────────────────┘ └──────────────────┘ └──────────────────┘    │
├─────────────────────────────────────────────────────────────────────┤
│  NIVEAU 3 : IMPLÉMENTATION (skills techniques)                      │
│  → COMMENT : Code, configuration, patterns                          │
│  frontend-dev, backend-dev, devops, react-expert, nextjs-expert,    │
│  wordpress-gutenberg-expert, design-system-foundations              │
└─────────────────────────────────────────────────────────────────────┘
```

**Distinction NIVEAU 2** :
- `web-dev-process` = **QUOI** (méthodologie, process, checklists)
- `testing-process` = **QUOI** (stratégie tests, types, qualité, sécurité, accessibilité)
- `lead-dev` = **QUI** (coordination, exécution, qualité quotidienne)

## Documentation

| Document | Description |
|----------|-------------|
| [orchestration/routing.md](./orchestration/routing.md) | Règles de routage détaillées |
| [orchestration/composition.md](./orchestration/composition.md) | Comment combiner les skills |
| [orchestration/escalation.md](./orchestration/escalation.md) | Points d'escalade humaine |
| [workflows/nouveau-projet.md](./workflows/nouveau-projet.md) | Workflow nouveau projet |
| [workflows/refonte.md](./workflows/refonte.md) | Workflow refonte |

## ADRs

| ADR | Titre |
|-----|-------|
| [001](./docs/adr/001-single-responsibility-agents.md) | Single Responsibility Agents |
| [002](./docs/adr/002-hierarchical-orchestrators.md) | Orchestrateurs Hiérarchiques |
| [003](./docs/adr/003-markdown-agent-format.md) | Format Markdown |
| [004](./docs/adr/004-human-supervision.md) | Supervision Humaine |
| [005](./docs/adr/005-skill-responsibility-boundaries.md) | Frontières entre Skills |
| [006](./docs/adr/006-hierarchy-clarification.md) | Clarification Hiérarchie lead-dev/web-dev-process |
| [007](./docs/adr/007-skill-extraction-pattern.md) | Pattern d'Extraction de Skills |

## Changelog

### v2.9.0

- **Nettoyage** : Suppression des 4 skills vides non implémentés
  - `strategy/`, `design/`, `content/`, `marketing/` supprimés
  - Retrait de la note de routage obsolète
- **Nettoyage** : Suppression du doublon `backend-developer/agents/devops/`
  - Le domaine DevOps est maintenant exclusivement dans le skill `devops` autonome
- **Documentation** : Ajout de ADR-007 (Pattern d'Extraction de Skills)
- **Documentation** : Ajout du graphe de dépendances (`orchestration/dependency-graph.md`)
- **Documentation** : Mise à jour de `orchestration/composition.md` v2.0.0

### v2.8.0

- **Nouveau skill** : Ajout de `testing-process` (25 agents) comme skill autonome
  - Consolidation des 34 agents testing dispersés dans 6 skills
  - Domaines : strategy, types, quality, performance, security, accessibility
  - Position : NIVEAU 2 PROCESSUS (peer de web-dev-process et lead-dev)
  - Distinction claire : PROCESS (quoi/quand tester) vs IMPLEMENTATION (comment coder les tests)
- **Total agents** : 409 (vs 384 en v2.7.0)

### v2.7.0

- **Nouveau skill** : Ajout de `devops` (30 agents) comme skill autonome
  - CI/CD, containers, Kubernetes, Infrastructure as Code, monitoring, deployment
  - Extraction depuis backend-developer/devops
  - Position : NIVEAU 3 IMPLÉMENTATION
- **backend-developer** : v1.1.0 - Domaine DevOps redirigé vers skill `devops`
- **Total agents** : 384 (vs 360 en v2.6.0)

### v2.6.0

- **Clarification hiérarchie** : lead-dev et web-dev-process sont au même niveau (NIVEAU 2: OPÉRATIONS)
- **Distinction claire** : web-dev-process = QUOI (process), lead-dev = QUI (coordination)
- **ADR-006** : Documentation de la décision d'architecture

### v2.5.0

- **Clarification** : Skills planifiés (strategy, design, content, marketing) clairement marqués comme non disponibles
- **Amélioration** : Matrice de désambiguïsation ajoutée dans `orchestration/routing.md`
- **Amélioration** : Règles de priorité RACI pour les mots-clés ambigus
- **Documentation** : Règle de décision en 4 étapes pour le routage

### v2.4.0

- **Nouveau** : Ajout du skill `nextjs-expert` (35 agents)
  - Implémentation Next.js 14+ avec App Router
  - Domaines : app-router, server-components, data, rendering, optimization, deployment, testing
  - Position : NIVEAU 3 COMMENT (implémentation)
- **Total agents** : 360 (vs 325 en v2.3.0)

### v2.3.0

- **Nouveau** : Ajout du skill `lead-dev` (27 agents)
  - Coordination technique opérationnelle
  - Domaines : code-review, team-coordination, technical-decisions, mentoring, delivery
  - Position : entre direction-technique (stratégique) et développeurs (implémentation)
- **Mise à jour** : Hiérarchie des skills avec niveau COORDINATION
- **Total agents** : 325 (vs 199 en v2.2.0)

### v2.2.0

> **📖 [Guide de Migration](./docs/analysis/MIGRATION.md)** - Consultez ce guide avant de mettre à jour

- **Breaking** : Intègre `direction-technique` v3.0.0
  - Tous les agents POURQUOI-level sans code d'implémentation
  - Le code a été déplacé vers les skills COMMENT-level
- **Version Relationship** : web-agency 2.x → direction-technique 3.x (voir ADR-005)

### v2.1.0
- **Refactoring SRP** : Séparation routage/composition/escalade
- Création dossier `orchestration/` avec agents spécialisés
- Création dossier `workflows/` avec scénarios
- Allègement du SKILL.md (responsabilité unique : routage)
- Ajout ADR-005 (frontières entre skills)

### v2.0.1
- Renommage `technical` → `direction-technique`

### v2.0.0
- Refactoring en méta-orchestrateur
- Skills métiers extraits en skills autonomes

### v1.0.0
- Création initiale
