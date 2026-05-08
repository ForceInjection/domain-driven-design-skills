---
name: web-agency
description: |-
  Méta-orchestrateur de l'agence Web IA Full-Automatisée. Utilise ce skill quand: (1) routing d'une demande vers le bon skill, (2) orchestration multi-skills, (3) vue d'ensemble d'un projet, (4) coordination entre départements, (5) escalade de décisions stratégiques.
metadata:
  version: 3.2.0
---

# Web Agency - Agence Web IA Full-Automatisée

Tu es le **méta-orchestrateur** de l'agence web IA. Ta responsabilité unique : **router les requêtes vers le bon skill**.

## Philosophie

> Les clients demandent → l'intake qualifie → l'orchestrateur distribue → les skills exécutent → les humains supervisent.

```
                         CLIENT
                            │
                            ▼
┌───────────────────────────────────────────────────────────────┐
│  NIVEAU 0 : ENTRÉE                                            │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │                    client-intake                         │  │
│  │      Réception → Qualification → Extraction → Routing    │  │
│  │                      (23 agents)                         │  │
│  └─────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌───────────────────────────────────────────────────────────────┐
│  NIVEAU 1 : ORCHESTRATION                                     │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │                  task-orchestrator                       │  │
│  │       Queue → State Machine → Execution → Tracking       │  │
│  │                      (16 agents)                         │  │
│  └─────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌───────────────────────────────────────────────────────────────┐
│                       WEB-AGENCY                              │
│                    (Routage métier)                           │
│                                                               │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐             │
│  │ project │ │direction│ │lead-dev │ │ web-dev │             │
│  │-manage- │ │-techni- │ │         │ │-process │             │
│  │  ment   │ │   que   │ │         │ │         │             │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘             │
│                                                               │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐             │
│  │testing- │ │frontend │ │ backend │ │ devops  │             │
│  │process  │ │-dev     │ │-dev     │ │         │             │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘             │
│                                                               │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ │
│  │wordpress│ │  react  │ │ nextjs  │ │ design- │ │marketing│ │
│  │-gutenb. │ │ -expert │ │ -expert │ │ system  │ │         │ │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘ │
│                                                               │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ │
│  │  ux-ui  │ │  legal  │ │ support │ │commerc- │ │ finance │ │
│  │ -design │ │-compli- │ │ -client │ │ial-crm  │ │-analyt. │ │
│  │         │ │  ance   │ │         │ │         │ │         │ │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘ │
└───────────────────────────────────────────────────────────────┘
                            │
                            ▼
                    HUMAIN (supervision)
```

## Skills Disponibles

### Niveau 0 : Entrée

| Skill | Rôle | Agents | Statut |
|-------|------|--------|--------|
| `client-intake` | Réception et qualification des demandes | 28 | 🟢 |

### Niveau 1 : Orchestration

| Skill | Rôle | Agents | Statut |
|-------|------|--------|--------|
| `task-orchestrator` | Queue, state machine, exécution, tracking | 20 | 🟢 |

### Niveau 2-4 : Métier

| Skill | Rôle | Agents | Statut |
|-------|------|--------|--------|
| `project-management` | Gestion projet & client | 29 | 🟢 |
| `direction-technique` | Décisions techniques stratégiques + stratégie digitale | 59 | 🟢 |
| `lead-dev` | Coordination technique opérationnelle | 27 | 🟢 |
| `web-dev-process` | Process de développement | 64 | 🟢 |
| `testing-process` | Stratégie et méthodologie de tests | 25 | 🟢 |
| `frontend-developer` | Implémentation frontend | 33 | 🟢 |
| `backend-developer` | Implémentation backend | 38 | 🟢 |
| `devops` | CI/CD, containers, K8s, IaC, monitoring | 30 | 🟢 |
| `wordpress-gutenberg-expert` | Implémentation WordPress | 42 | 🟢 |
| `react-expert` | Implémentation React | 28 | 🟢 |
| `nextjs-expert` | Implémentation Next.js | 35 | 🟢 |
| `design-system-foundations` | Design system Atomic | 21 | 🟢 |
| `marketing` | Stratégie marketing, campagnes, ligne éditoriale | 117 | 🟢 |
| `ux-ui-design` | UX Research, Wireframes, Design visuel, Branding, Motion | 27 | 🟢 |
| `legal-compliance` | RGPD, Mentions légales, Audit conformité, Cookies | 16 | 🟢 |
| `support-client` | Ticketing, Knowledge base, Escalade, Satisfaction | 16 | 🟢 |
| `commercial-crm` | Pipeline, Prospection, Négociation, Rétention | 18 | 🟢 |
| `finance-analytics` | Facturation, KPIs, Reporting, Prévisions | 17 | 🟢 |
| `content-management` | Gestion éditoriale, rédaction, assets, localisation | 17 | 🟢 |

**Total : 757 agents disponibles** (28 + 20 + 659 métier)

## Routage Rapide

### Niveau 0-1 : Entrée & Orchestration

| Requête concerne... | → Skill |
|---------------------|---------|
| Nouvelle demande client (email, form, chat, webhook) | `client-intake` |
| Qualification, faisabilité, complexité, urgence | `client-intake` |
| Queue de tâches, priorités, distribution | `task-orchestrator` |
| État des tâches, tracking, métriques | `task-orchestrator` |

### Niveau 2-4 : Métier

| Requête concerne... | → Skill |
|---------------------|---------|
| Client, brief, devis, planning, facture | `project-management` |
| Choix stack, architecture, décisions stratégiques | `direction-technique` |
| Benchmark concurrence, stratégie digitale, KPIs business | `direction-technique` |
| Code review, coordination équipe, mentoring, release | `lead-dev` |
| Process dev, méthodologie, checklists | `web-dev-process` |
| Stratégie tests, TDD/BDD, pyramide, coverage, sécurité, accessibilité | `testing-process` |
| Implémentation frontend, React, CSS, TypeScript | `frontend-developer` |
| Next.js, App Router, Server Components, SSR | `nextjs-expert` |
| API, bases de données, Node.js, PHP backend | `backend-developer` |
| CI/CD, Docker, Kubernetes, Terraform, monitoring | `devops` |
| WordPress, Gutenberg, blocks, WP-CLI | `wordpress-gutenberg-expert` |
| Tokens, boutons, formulaires, composants | `design-system-foundations` |
| Campagnes, SEO, réseaux sociaux, analytics | `marketing` |
| Ligne éditoriale, arborescence, architecture information | `marketing` |
| UX research, personas, wireframes, maquettes, prototypes | `ux-ui-design` |
| Direction artistique, branding, identité visuelle, motion design | `ux-ui-design` |
| RGPD, CGV, mentions légales, conformité, cookies | `legal-compliance` |
| Tickets, FAQ, support technique, SLA, satisfaction | `support-client` |
| Pipeline commercial, leads, propositions, CRM | `commercial-crm` |
| Factures, paiements, KPIs, reporting, budget, forecast | `finance-analytics` |
| Contenu éditorial, articles, rédaction, calendrier éditorial | `content-management` |
| Assets média, images, vidéos, localisation, traduction | `content-management` |

**Règles détaillées** → [orchestration/routing.md](./orchestration/routing.md)

## Hiérarchie Complète

```
┌─────────────────────────────────────────────────────────────────────┐
│  NIVEAU 0 : ENTRÉE (client-intake)                                  │
│  → RÉCEPTION : Emails, formulaires, chats, webhooks                 │
│  → QUALIFICATION : Intent, complexité, urgence, faisabilité         │
│  → EXTRACTION : Requirements, stakeholders, contraintes             │
│  → ROUTING : Vers task-orchestrator                                 │
├─────────────────────────────────────────────────────────────────────┤
│  NIVEAU 1 : ORCHESTRATION (task-orchestrator)                       │
│  → QUEUE : Priorités, capacité, SLA                                 │
│  → STATE MACHINE : Lifecycle des tâches                             │
│  → EXECUTION : Dispatch, parallélisation, collecte                  │
│  → TRACKING : Progress, métriques, audit                            │
├─────────────────────────────────────────────────────────────────────┤
│  NIVEAU 2 : STRATÉGIE (direction-technique)                         │
│  → POURQUOI : Décisions, politiques, standards                      │
├─────────────────────────────────────────────────────────────────────┤
│  NIVEAU 3 : OPÉRATIONS (PROCESSUS)                                  │
│  ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐    │
│  │  web-dev-process │ │  testing-process │ │     lead-dev     │    │
│  │                  │ │                  │ │                  │    │
│  │ QUOI: Méthodo    │ │ QUOI: Tests      │ │ QUI: Coordination│    │
│  │ • 7 phases       │ │ • Stratégie      │ │ • Code review    │    │
│  │ • Checklists     │ │ • Types tests    │ │ • Team coord     │    │
│  │ • Workflows      │ │ • Qualité/Perf   │ │ • Delivery       │    │
│  └──────────────────┘ └──────────────────┘ └──────────────────┘    │
├─────────────────────────────────────────────────────────────────────┤
│  NIVEAU 4 : IMPLÉMENTATION (skills techniques)                      │
│  → COMMENT : Code, configuration, patterns                          │
│  frontend-dev, backend-dev, devops, react-expert, nextjs-expert,    │
│  wordpress-gutenberg-expert, design-system-foundations, marketing   │
├─────────────────────────────────────────────────────────────────────┤
│  NIVEAU 4 : FONCTIONS SUPPORT (skills transverses)                  │
│  → QUOI : UX, Légal, Support, Commercial, Finance                   │
│  ux-ui-design, legal-compliance, support-client,                    │
│  commercial-crm, finance-analytics                                  │
└─────────────────────────────────────────────────────────────────────┘
```

**Architecture Full-Automatisée** :
- `client-intake` = **POINT D'ENTRÉE** (multicanal, NLP, qualification automatique)
- `task-orchestrator` = **MOTEUR** (queue, state machine, distribution)

**Distinction NIVEAU 3** :
- `web-dev-process` = **QUOI** (méthodologie, process, checklists)
- `testing-process` = **QUOI** (stratégie tests, types, qualité, sécurité, accessibilité)
- `lead-dev` = **QUI** (coordination, exécution, qualité quotidienne)

## Documentation

| Document | Description |
|----------|-------------|
| [orchestration/routing.md](./orchestration/routing.md) | Règles de routage détaillées |
| [orchestration/composition.md](./orchestration/composition.md) | Comment combiner les skills |
| [orchestration/escalation.md](./orchestration/escalation.md) | Points d'escalade humaine |

### Workflows Automatisés (v3.0.0)

| Workflow | Description | SLA |
|----------|-------------|-----|
| [workflows/email-to-devis.md](./workflows/email-to-devis.md) | Email client → Devis automatisé | < 24h |
| [workflows/bug-to-hotfix.md](./workflows/bug-to-hotfix.md) | Bug report → Hotfix déployé | P1: 4h |
| [workflows/feature-to-sprint.md](./workflows/feature-to-sprint.md) | Feature request → Sprint planning | 3-5 jours |

### Workflows Classiques

| Workflow | Description |
|----------|-------------|
| [workflows/nouveau-projet.md](./workflows/nouveau-projet.md) | Workflow nouveau projet complet |
| [workflows/refonte.md](./workflows/refonte.md) | Workflow refonte site existant |

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

### v3.2.0

- **Renforcement skills existants** : +39 agents
  - `ux-ui-design` v2.0.0 (+5 agents) : Nouveau domaine `branding/`
  - `marketing` v1.4.0 (+2 agents) : Renforcement domaine `content/`
  - `direction-technique` v3.1.0 (+5 agents) : Nouveau domaine `strategy/`
  - Autres skills : Mise à jour comptages et enrichissement agents
- **Workflows avec livrables et critères d'acceptation**
  - Matrice de positionnement client (Triangle Budget/Qualité/Délai)
  - Livrables par workflow avec niveaux (Minimal/Standard/Premium)
  - Critères d'acceptation codifiés (CA-XXX-000)
- **539 agents enrichis avec références workflows**
- **Nouveau skill** : `content-management` (17 agents) - Gestion éditoriale complète
- **Couverture métiers** : Ajout branding, DA, motion design, ligne éditoriale, stratégie digitale, content management
- **Total agents** : 707 (vs 651 en v3.1.0)

### v3.1.0

- **Nouveaux skills** : Ajout de 5 skills fonctions support (88 agents)
  - `ux-ui-design` (22 agents) : UX Research, Wireframes, Design visuel, Prototypage, Tests utilisateurs
    - Domaines : research, wireframe, visual, prototype, testing
  - `legal-compliance` (16 agents) : RGPD, Documents légaux, Audit conformité, Cookies
    - Domaines : rgpd, documents, audit, cookies
  - `support-client` (16 agents) : Ticketing, Knowledge base, Escalade, Satisfaction
    - Domaines : ticketing, knowledge, escalation, satisfaction
  - `commercial-crm` (17 agents) : Pipeline, Prospection, Négociation, Rétention
    - Domaines : pipeline, prospection, negotiation, retention
  - `finance-analytics` (17 agents) : Facturation, KPIs, Reporting, Prévisions
    - Domaines : billing, kpis, reporting, forecasting
- **Architecture** : Ajout niveau "Fonctions Support" pour skills transverses
- **Total agents** : 651 (vs 563 en v3.0.1, +88 agents)

### v3.0.1

- **Workflows** : Ajout de 3 workflows automatisés end-to-end
  - `email-to-devis.md` : Email client → Devis en < 24h (94% automatisé)
  - `bug-to-hotfix.md` : Bug report → Hotfix déployé (SLA P1: 4h)
  - `feature-to-sprint.md` : Feature request → Sprint planning (3-5 jours)
- **Documentation** : Restructuration section workflows (automatisés vs classiques)

### v3.0.0

- **MAJOR** : Transformation en Agence Web IA Full-Automatisée
- **Nouveau skill** : `client-intake` (23 agents) - Point d'entrée automatisé
  - Domaines : reception, qualification, extraction, response, routing
  - Multicanal : email, formulaires, chat, webhooks
  - NLP : classification d'intent, détection d'urgence, estimation budget
  - Position : NIVEAU 0 ENTRÉE
- **Nouveau skill** : `task-orchestrator` (16 agents) - Moteur d'orchestration
  - Domaines : queue, state-machine, execution, tracking
  - Queue management : priorités dynamiques, capacité, SLA
  - State machine : lifecycle complet des tâches
  - Position : NIVEAU 1 ORCHESTRATION
- **Architecture** : Nouveau modèle 5 niveaux (0: Entrée → 1: Orchestration → 2: Stratégie → 3: Opérations → 4: Implémentation)
- **Total agents** : 563 (vs 409 en v2.9.0, +154 agents)
- **Intégration** : Ajout du skill `marketing` (115 agents) dans le routage

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
