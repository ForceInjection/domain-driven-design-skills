---
name: testing-process
description: Expert en stratégie et méthodologie de tests - Pyramide, types de tests, qualité, performance, sécurité, accessibilité
version: 1.0.0
status: active
---

# Testing Process Expert Skill

## Quick Start

```bash
# 1. Navigation rapide vers un agent
testing-process/agents/strategy/pyramide       # Stratégie et pyramide de tests
testing-process/agents/types/unit              # Méthodologie tests unitaires
testing-process/agents/quality/coverage        # Couverture et métriques
testing-process/agents/performance/load        # Tests de charge
testing-process/agents/security/owasp          # Tests sécurité OWASP
testing-process/agents/accessibility/wcag      # Tests accessibilité WCAG

# 2. Exécuter les tests de validation
cd .claude/skills/testing-process && npm test

# 3. Questions fréquentes
"Quelle stratégie de tests adopter ?"      → strategy/pyramide
"Comment mesurer la couverture ?"          → quality/coverage
"Tests de performance pour mon API ?"      → performance/load
"Vérifier la sécurité OWASP ?"            → security/owasp
```

## Position dans l'Architecture

Ce skill est au **NIVEAU 2 : PROCESSUS**. Il définit le QUOI et QUAND tester, pas le COMMENT.

```
┌─────────────────────────────────────────────────────────────────────┐
│  NIVEAU 1 : STRATÉGIE (direction-technique)                         │
│  → POURQUOI : Politique qualité, budgets, exigences                 │
├─────────────────────────────────────────────────────────────────────┤
│  NIVEAU 2 : PROCESSUS                                               │
│  ┌────────────────────────────┐  ┌────────────────────────────┐    │
│  │     web-dev-process        │  │   testing-process ← ICI    │    │
│  │  Phases de développement   │  │  Méthodologie de tests     │    │
│  └────────────────────────────┘  └────────────────────────────┘    │
├─────────────────────────────────────────────────────────────────────┤
│  NIVEAU 3 : IMPLÉMENTATION (skills techniques)                      │
│  → COMMENT : Code de tests spécifique à chaque technologie          │
│  backend-dev/testing, frontend-dev/testing, react/testing, etc.     │
└─────────────────────────────────────────────────────────────────────┘
```

## Philosophie

> Définir QUOI tester et QUAND, pas COMMENT.

Ce skill :
- ✅ Définit la stratégie de tests (pyramide, ratios)
- ✅ Explique les types de tests et leurs cas d'usage
- ✅ Guide sur les métriques de qualité
- ✅ Fournit les méthodologies (TDD, BDD)
- ✅ Définit les critères de qualité

Il ne fait PAS :
- ❌ Le code de test spécifique → `backend-developer/testing`, `frontend-developer/testing`
- ❌ La configuration d'outils → skills techniques
- ❌ Les décisions politiques → `direction-technique/qualite`

## Domaines et Agents (25 agents)

### 1. strategy/ - Stratégie de Tests (5 agents)

Définition de la stratégie globale de tests.

| Agent | Responsabilité |
|-------|----------------|
| `orchestrator` | Coordination stratégie testing |
| `pyramide` | Pyramide de tests, ratios, anti-patterns |
| `tdd-bdd` | Méthodologies TDD, BDD, ATDD |
| `planning` | Planification des tests, priorisation |
| `documentation` | Documentation des tests, rapports |

### 2. types/ - Types de Tests (5 agents)

Méthodologie pour chaque type de test.

| Agent | Responsabilité |
|-------|----------------|
| `orchestrator` | Coordination types de tests |
| `unit` | Tests unitaires - isolation, mocks, AAA |
| `integration` | Tests d'intégration - API, DB, services |
| `e2e` | Tests end-to-end - parcours utilisateur |
| `component` | Tests de composants UI |

### 3. quality/ - Qualité et Métriques (4 agents)

Mesure et amélioration de la qualité.

| Agent | Responsabilité |
|-------|----------------|
| `orchestrator` | Coordination qualité |
| `coverage` | Couverture de code, seuils, reporting |
| `mutation` | Mutation testing, qualité des tests |
| `flaky` | Détection et correction tests instables |

### 4. performance/ - Tests de Performance (4 agents)

Tests de charge et performance.

| Agent | Responsabilité |
|-------|----------------|
| `orchestrator` | Coordination performance |
| `load` | Tests de charge (k6, Artillery) |
| `frontend-perf` | Core Web Vitals, Lighthouse |
| `profiling` | Profiling et analyse |

### 5. security/ - Tests de Sécurité (4 agents)

Tests de sécurité applicative.

| Agent | Responsabilité |
|-------|----------------|
| `orchestrator` | Coordination sécurité |
| `owasp` | OWASP Top 10, vulnérabilités |
| `dependencies` | Audit dépendances, CVE |
| `headers` | Headers HTTP sécurisés |

### 6. accessibility/ - Accessibilité (3 agents)

Tests d'accessibilité.

| Agent | Responsabilité |
|-------|----------------|
| `orchestrator` | Coordination accessibilité |
| `wcag` | Conformité WCAG 2.1/2.2 |
| `audit` | Audits axe-core, Pa11y |

**Total : 25 agents spécialisés**

## Règles de Routage

### Par Type de Question

| Question | Domaine |
|----------|---------|
| Stratégie de tests, pyramide, ratios | `strategy/` |
| Comment structurer mes tests unitaires ? | `types/unit` |
| Tests d'intégration avec DB | `types/integration` |
| Tests end-to-end, parcours | `types/e2e` |
| Couverture de code, métriques | `quality/coverage` |
| Tests de charge, performance | `performance/load` |
| Sécurité OWASP, vulnérabilités | `security/owasp` |
| Accessibilité WCAG | `accessibility/wcag` |

### Par Mots-Clés

| Mots-clés | Agent |
|-----------|-------|
| pyramide, ratio, 70/20/10 | `strategy/pyramide` |
| TDD, BDD, red-green-refactor | `strategy/tdd-bdd` |
| mock, stub, spy, isolation | `types/unit` |
| API test, contract, Pact | `types/integration` |
| Playwright, Cypress, parcours | `types/e2e` |
| coverage, seuil, 80% | `quality/coverage` |
| mutation, Stryker | `quality/mutation` |
| k6, load test, stress | `performance/load` |
| Core Web Vitals, LCP, CLS | `performance/frontend-perf` |
| OWASP, injection, XSS | `security/owasp` |
| npm audit, Snyk, CVE | `security/dependencies` |
| WCAG, aria, screen reader | `accessibility/wcag` |
| axe-core, Pa11y, Lighthouse | `accessibility/audit` |

## Arbre de Décision

```
Requête Testing
│
├─ Concerne la STRATÉGIE globale ?
│  ├─ Pyramide, ratios → strategy/pyramide
│  ├─ TDD, BDD → strategy/tdd-bdd
│  └─ Planification → strategy/planning
│
├─ Concerne un TYPE de test ?
│  ├─ Tests unitaires → types/unit
│  ├─ Tests d'intégration → types/integration
│  ├─ Tests end-to-end → types/e2e
│  └─ Tests de composants → types/component
│
├─ Concerne la QUALITÉ/métriques ?
│  ├─ Couverture → quality/coverage
│  ├─ Mutation testing → quality/mutation
│  └─ Tests flaky → quality/flaky
│
├─ Concerne la PERFORMANCE ?
│  ├─ Tests de charge → performance/load
│  ├─ Core Web Vitals → performance/frontend-perf
│  └─ Profiling → performance/profiling
│
├─ Concerne la SÉCURITÉ ?
│  ├─ OWASP → security/owasp
│  ├─ Dépendances → security/dependencies
│  └─ Headers → security/headers
│
├─ Concerne l'ACCESSIBILITÉ ?
│  ├─ WCAG → accessibility/wcag
│  └─ Audit → accessibility/audit
│
├─ Code de test SPÉCIFIQUE à une techno ?
│  └─ → Déléguer au skill technique
│     ├─ React → react-expert/testing
│     ├─ Next.js → nextjs-expert/testing
│     ├─ Backend → backend-developer/testing
│     └─ WordPress → wordpress-gutenberg-expert/testing
│
└─ Décision stratégique (politique qualité) ?
   └─ → direction-technique/qualite
```

## Interaction avec les Autres Skills

### Flux Entrants

```
direction-technique/qualite ──► testing-process (politique → méthodologie)
web-dev-process ──► testing-process (phase testing → détails)
```

### Flux Sortants (délégation implémentation)

```
testing-process ──► backend-developer/testing (tests backend)
testing-process ──► frontend-developer/testing (tests frontend)
testing-process ──► react-expert/testing (tests React)
testing-process ──► nextjs-expert/testing (tests Next.js)
testing-process ──► wordpress-gutenberg-expert/testing (tests WP)
```

## Points d'Escalade

### Vers direction-technique

| Situation | Raison |
|-----------|--------|
| Définir les seuils de couverture | Politique qualité |
| Choisir les outils de test | Décision stratégique |
| Budget temps pour les tests | Validation managériale |

### Vers l'humain

| Situation | Raison |
|-----------|--------|
| Tests manuels exploratoires | Jugement humain requis |
| Validation fonctionnelle métier | Expertise domaine |
| Décision go/no-go release | Responsabilité |

## Skills Associés

| Skill | Niveau | Relation |
|-------|--------|----------|
| `direction-technique` | STRATÉGIE | Reçoit les politiques qualité |
| `web-dev-process` | PROCESSUS | Pair - phase testing |
| `backend-developer` | IMPLÉMENTATION | Délègue tests backend |
| `frontend-developer` | IMPLÉMENTATION | Délègue tests frontend |
| `react-expert` | IMPLÉMENTATION | Délègue tests React |
| `nextjs-expert` | IMPLÉMENTATION | Délègue tests Next.js |

## Exemples de Routage Pratiques

Cette section clarifie les frontières entre **PROCESSUS** (testing-process) et **IMPLÉMENTATION** (skills techniques).

### Exemple 1 : Tests Unitaires

| Question | Skill | Raison |
|----------|-------|--------|
| "Comment structurer mes tests unitaires ?" | `testing-process/types/unit` | **Méthodologie** : pattern AAA, isolation |
| "Comment mocker un service Node.js ?" | `backend-developer/testing/unit` | **Implémentation** : code Jest spécifique |
| "Comment tester un hook React ?" | `react-expert/testing` | **Implémentation** : RTL, code spécifique |

### Exemple 2 : Pyramide de Tests

| Question | Skill | Raison |
|----------|-------|--------|
| "Quels ratios adopter (70/20/10) ?" | `testing-process/strategy/pyramide` | **Stratégie** : ratios, anti-patterns |
| "Combien de tests E2E pour mon projet ?" | `testing-process/strategy/planning` | **Planification** : allocation |
| "Comment configurer Playwright ?" | `frontend-developer/testing/e2e` | **Implémentation** : config technique |

### Exemple 3 : Tests de Sécurité

| Question | Skill | Raison |
|----------|-------|--------|
| "Quelles vulnérabilités OWASP tester ?" | `testing-process/security/owasp` | **Méthodologie** : checklist OWASP |
| "Comment scanner les dépendances npm ?" | `testing-process/security/dependencies` | **Méthodologie** : processus audit |
| "Script Snyk pour mon CI GitHub Actions" | `devops/cicd/quality-gates` | **Implémentation** : config CI |

### Exemple 4 : Couverture de Code

| Question | Skill | Raison |
|----------|-------|--------|
| "Quel seuil de couverture viser ?" | `testing-process/quality/coverage` | **Méthodologie** : objectifs, métriques |
| "Comment configurer Istanbul/nyc ?" | `backend-developer/testing/coverage` | **Implémentation** : config outil |

### Règle Générale

```
┌─────────────────────────────────────────────────────────────────────┐
│  QUESTION                          │  SKILL                         │
├────────────────────────────────────┼─────────────────────────────────┤
│  "QUOI tester ?"                   │  testing-process               │
│  "POURQUOI tester X ?"             │  testing-process               │
│  "QUAND ajouter des tests ?"       │  testing-process               │
│  "COMBIEN de tests ?"              │  testing-process               │
├────────────────────────────────────┼─────────────────────────────────┤
│  "COMMENT écrire ce test ?"        │  skill technique (impl)        │
│  "COMMENT configurer l'outil ?"    │  skill technique (impl)        │
│  "Code de test pour X ?"           │  skill technique (impl)        │
└────────────────────────────────────┴─────────────────────────────────┘
```

## Changelog

### v1.0.0
- Création initiale avec 6 domaines et 25 agents
- Consolidation de la méthodologie testing
- Position : NIVEAU 2 PROCESSUS
- Couverture : strategy, types, quality, performance, security, accessibility
