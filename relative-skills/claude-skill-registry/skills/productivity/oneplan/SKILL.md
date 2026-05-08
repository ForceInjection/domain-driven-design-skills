---
name: oneplan
description: OnePlan is a GitHub-native, context-driven engineering workflow using Milestones (tracks), Issues (spec/plan), and Sub-issues (phases/tasks). Use for complex features/bugfixes that need structured planning, resumable execution, parallel tasks, and team coordination.
metadata:
  author: giulioleone
  version: "1.0"
compatibility: Works with VS Code Agent Skills. Optional GitHub CLI (gh) for local automation.
allowed-tools: Read Write Bash(git:*) Bash(gh:*)
---

# OnePlan (Context-Driven Engineering)

Questa skill implementa l’equivalente del workflow “Conductor” (file-based) ma con **GitHub come backend** e un’identità propria: **OnePlan**.

Idea guida: *Measure twice, ship once.*

## Quick Reference

### Struttura consigliata
- **Track** = GitHub **Milestone**
- **Spec** = Issue con label `oneplan/spec`
- **Plan** = Issue con label `oneplan/plan` (parent)
- **Phase** = Sub-issue del Plan con label `oneplan/phase`
- **Task** = Sub-issue (o sub-issue della Phase) con label `oneplan/task`

Fallback (se le Sub-issues non sono abilitate nel repo):
- **Phase** = Issue normale nella milestone (titolo `[PHASE] ...`) + linkata dal PLAN tramite task list
- **Task** = Issue normale nella milestone (titolo `[TASK] ...`) + linkata dalla PHASE tramite task list

### Stati (label)
- `status/pending`, `status/in-progress`, `status/blocked`, `status/done`

### Regola d’oro
- Prima **SPEC**, poi **PLAN**, poi **IMPLEMENT**.

## Cosa risolve rispetto al file-based
- Persistenza e collaborazione: tutto vive su GitHub.
- Gerarchia e parallelismo: sub-issues + dipendenze.
- Tracciamento: milestone progress, labels, assignees, review.
- Audit trail: commenti e PR collegate.

## Workflow operativo

### 1) Setup (una volta per repo)
Obiettivo: standardizzare convenzioni e ridurre ambiguità.

1. Crea labels OnePlan (vedi `references/LABELS_AND_STATES.md`).
2. Aggiungi issue templates (vedi `references/ISSUE_TEMPLATES.md`).
3. Crea (opzionale) una issue “contesto” sempre aperta:
   - titolo: `[CONTEXT] Project context`
   - label: `oneplan/context`
   - contenuto: product goals, tech stack, workflow.

Output desiderato:
- Labels pronte
- Templates pronte
- Contesto centralizzato e condiviso

### 2) Creare un Track (Milestone)
Obiettivo: un contenitore unico per spec/plan/tasks.

1. Crea milestone: `Track: <nome>`.
2. Crea issue SPEC associata alla milestone:
   - titolo: `[SPEC] <nome>`
   - label: `oneplan/spec`
3. Crea issue PLAN associata alla milestone:
   - titolo: `[PLAN] <nome>`
   - label: `oneplan/plan`

Nota: la SPEC deve essere “approvata” (anche solo via commento “LGTM / approved”) prima di creare task dettagliate.

### 3) Planning (gerarchico + parallelo)
Obiettivo: trasformare SPEC → fasi e task eseguibili.

Regole:
- Le **Phase** sono sequenziali salvo dichiarazione esplicita.
- Le **Task** dentro una phase possono essere parallele.
- Ogni task deve avere:
  - “Definition of Done” verificabile
  - dipendenze esplicite (se esistono)
  - owner/assignee (se in team)

Algoritmo pratico di scomposizione:
1. Estrarre requisiti/AC dalla SPEC.
2. Raggruppare per aree (UI, API, DB, tests, deploy).
3. Definire 3–6 phases:
   - Setup/Scaffold
   - Core implementation
   - Edge cases
   - Testing
   - Docs/Release
4. Per ogni phase, creare 2–6 task piccole, con verifica.

Parallelismo:
- Metti nella stessa phase task indipendenti.
- Usa dipendenze solo dove necessario.

#### Gerarchia senza Sub-issues (task lists)
Se non puoi creare sub-issues, usa le **task list** nel body del PLAN/PHASE:

- [ ] #123 [PHASE] Setup
- [ ] #124 [PHASE] Implementazione

E dentro una PHASE:

- [ ] #130 [TASK] Aggiungere toggle UI
- [ ] #131 [TASK] Persistenza preferenza
- [ ] #132 [TASK] Test e2e

### 4) Implement (resumable)
Obiettivo: eseguire una task per volta, mantenendo stato su GitHub.

Selezione “next task” (deterministica):
1. Se esiste una task `status/in-progress` assegnata a te → continua quella.
2. Altrimenti scegli la più piccola task `status/pending`:
   - nella prima phase non completata
   - non `status/blocked`
   - con dipendenze soddisfatte

Ciclo di esecuzione per task:
1. Metti `status/in-progress`.
2. Esegui la modifica in repo (branch/commit/PR se necessario).
3. Aggiorna la issue task:
   - checklist di verifica spuntata
   - link a PR/commit
4. Metti `status/done` e chiudi la issue task.

### 5) Status / Reporting
Obiettivo: visione rapida a milestone/phase/task.

Heuristics:
- Track progress = (issues chiuse nella milestone) / (issues totali nella milestone)
- Phase progress = (tasks chiuse nella phase) / (tasks totali)

### 6) Post-track Tech Debt pass (consigliato)
Obiettivo: dopo aver consegnato una milestone, ridurre il debito tecnico “fresco”.

Workflow consigliato:
1. Quando una track è completa (0 issue aperte nella milestone), crea una issue di review tech-debt.
2. Esegui la modalità `@techdebt` e trasforma i findings in issue piccole e prioritizzate.

Suggerimenti pratici:
- `@techdebt assess` (panoramica)
- `@techdebt smells`, `@techdebt complexity`, `@techdebt unused` (se pertinente)

Nota: l’estensione può proporre automaticamente la creazione della issue di review quando la milestone è completa.

### 7) Sync opzionale (GitHub ⇄ repo)
Se vuoi “contesto locale” per far lavorare meglio l’agente (e facilitare review), puoi mantenere:
- `.conductor/product.md`
- `.conductor/tech-stack.md`
- `.conductor/workflow.md`

Questi file sono **derivati** dal contesto GitHub (o viceversa). La fonte di verità resta GitHub.

## Convenzioni di naming
- Milestone: `Track: <Titolo umano>`
- Issue type prefix: `[SPEC]`, `[PLAN]`, `[PHASE]`, `[TASK]`
- Slug: kebab-case per file/branch (se usati)

## Dipendenze (come rappresentarle)
Usa un blocco standard nel body:

- Depends on: #123, #124
- Blocks: #200

E quando blocchi una task:
- label `status/blocked`
- commento: motivo + cosa serve per sbloccare

## Integrazione con Agent Planning
Quando serve progettazione “larga”:
1. Usa un agente planner (es. “Plan”) per ricavare la scomposizione.
2. Trascrivi il risultato nel PLAN issue creando phases/tasks come sub-issues.

## Guardrail
- Non creare task “giganti”: target 0.5–2 ore ciascuna.
- Evita dipendenze cicliche.
- Non chiudere una task senza verifica scritta.
- Una sola task `in-progress` per persona.

## Reference
- `references/GITHUB_MAPPING.md`
- `references/LABELS_AND_STATES.md`
- `references/ISSUE_TEMPLATES.md`
- `references/DEPENDENCIES.md`

