---
name: Project Planning for Photo Map MVP
description: Break down, design, and structure features into implementable tasks for Photo Map MVP. Use when planning new features, creating user stories, defining API endpoints, structuring implementation phases, organizing project tasks, or designing feature breakdowns.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# Project Planning - Photo Map MVP

## Project Context

Photo Map MVP to full-stack aplikacja do zarządzania zdjęciami z geolokalizacją.

**Stack:** Angular 18 (standalone), Spring Boot 3, Java 17, PostgreSQL 15
**Deployment:** Mikrus VPS (limited resources, no background jobs)
**Timeline:** 10 dni (6 faz implementacji)

**Core Features:**
1. Authentication (JWT-based login/registration)
2. Photo Management (Upload z EXIF, thumbnails, CRUD)
3. Gallery View (Responsive grid, rating, filtering)
4. Map View (Leaflet.js, GPS markers, clustering)
5. Admin Panel (User management)

**Key Constraints (Mikrus VPS):**
- ❌ No background jobs (Celery, Sidekiq) → synchronous processing
- ❌ No resource-intensive operations (ML, heavy processing)
- ✅ In-memory cache (60s TTL) - no Redis
- ✅ Synchronous thumbnail generation

**Więcej szczegółów:** `references/mvp-scope-boundaries.md`

---

## When to Use This Skill

Użyj tego skilla gdy:
- Planujesz dodanie nowej funkcji do Photo Map MVP
- Weryfikujesz pomysł pod kątem MVP scope
- Oceniasz złożoność implementacji
- Rozbijasz funkcję na małe zadania (chunks)
- Identyfikujesz ryzyka nowej funkcji

**NIE używaj gdy:**
- Szukasz szczegółów technicznych (API specs → `.ai/api-plan.md`)
- Szukasz database schema (→ `.ai/db-plan.md`)
- Szukasz frontend architecture (→ `.ai/ui-plan.md`)

---

## Feature Verification Process

Proces weryfikacji nowego pomysłu (5 kroków):

### Krok 1: MVP Scope Check

**Pytanie:** Czy funkcja pasuje do MVP?

**Sprawdzenie:**
1. Czy funkcja wymieniona w `.ai/prd.md` Core Features? → ✅ GO
2. Czy funkcja w "Out of Scope" liście? → ❌ STOP
3. Czy funkcja rozwiązuje core problem? → ✅ GO / ❌ STOP

**Decision:**
- ✅ **In Scope** → Kontynuuj do Kroku 2
- ⚠️ **Maybe** → Szukaj simplified version, consulta z użytkownikiem
- ❌ **Out of Scope** → Odrzuć lub consulta (jeśli strong business case)

**Szczegóły:** `references/mvp-scope-boundaries.md`

---

### Krok 2: Tech Stack Compatibility

**Pytanie:** Czy funkcja zgodna z tech stack i constraints?

**Sprawdzenie:**
1. Sprawdź `.ai/tech-stack.md` - czy używamy odpowiednich technologii?
2. Mikrus VPS constraints:
   - Czy wymaga background jobs? → ❌ (use Spring Integration workaround)
   - Czy resource-intensive? → ⚠️ (carefully)
   - Czy wymaga nowych bibliotek? → Lista i oceń

**Decision:**
- ✅ **Compatible** → Kontynuuj do Kroku 3
- ⚠️ **Needs Workaround** → Zaplanuj alternatywne podejście
- ❌ **Incompatible** → Odrzuć lub zmień approach

---

### Krok 3: Complexity Assessment

**Pytanie:** Jaka jest złożoność funkcji?

**Ocena złożoności** (sprawdź tabelę w sekcji "Complexity Levels" poniżej):
- **Database changes?** (ADD COLUMN / CREATE TABLE / None)
- **API endpoints?** (0 / 1-2 / 3+)
- **Frontend + Backend?** (Yes / No)
- **Async processing?** (Yes / No)

**Decision:**
- **Simple:** 1-2 chunks (1-2h) → Szybkie wykonanie
- **Medium:** 3-5 chunks (3-6h) → Checkpoints co 3 chunks
- **Complex:** 6+ chunks (6-12h) → Multiple checkpoints

**Szczegóły:** `references/complexity-assessment.md`

---

### Krok 4: Implementation Planning

**Pytanie:** Jak rozbić funkcję na małe chunks?

**Pattern:** 3 małe zadania (30-60 min każde) → Checkpoint

**Dla każdego chunk:**
1. **Implement** - napisać kod (1 endpoint/component/method)
2. **Test** - zweryfikować (curl/browser)
3. **Commit** - zapisać (Conventional Commits)

**Po 3 chunks → CHECKPOINT:**
- Pokazać użytkownikowi działającą funkcję
- Zebrać feedback
- Kontynuować lub adjust

**Przykłady:**
- Simple feature: `examples/simple-feature-example.md`
- Medium feature: `examples/good-feature-breakdown.md`
- Complex feature: `examples/complex-feature-example.md`

---

### Krok 5: Risk Identification

**Pytanie:** Co może pójść nie tak?

**Common Risks:**
- **Performance:** Slow queries, large files, timeouts
- **Security:** User scoping violations, validation gaps, SQL injection
- **Race conditions:** Concurrent updates, database locks
- **Error handling:** Edge cases, corrupt files, network failures
- **Migration:** Rollback strategy, data loss

**Dla każdego risk:**
1. Zidentyfikuj impact (High / Medium / Low)
2. Zaplanuj mitigation strategy
3. Dokumentuj w feature proposal

**Template:** `templates/feature-proposal-template.md`

---

## Complexity Levels

| Level | Timeline | DB Changes | Endpoints | Example |
|-------|----------|------------|-----------|---------|
| **Simple** | 1-2 chunks<br/>(1-2h) | ADD COLUMN (nullable)<br/>or None | 0 (modify existing)<br/>or None | Add photo description field |
| **Medium** | 3-5 chunks<br/>(3-6h) | ADD COLUMN + INDEX<br/>or simple changes | 1-2 new endpoints | Rating system (1-5 stars) |
| **Complex** | 6+ chunks<br/>(6-12h) | CREATE TABLE<br/>+ relations | 3+ new endpoints | Batch upload async (Spring Integration) |

### Complexity Decision Tree

```
Q1: Database changes?
  - None/ADD COLUMN (nullable) → likely Simple
  - ADD COLUMN + INDEX → likely Medium
  - CREATE TABLE + relations → likely Complex

Q2: New endpoints?
  - 0 (modify existing) → likely Simple
  - 1-2 → likely Medium
  - 3+ → likely Complex

Q3: Async processing needed?
  - No → Simple/Medium
  - Yes → Complex (Spring Integration required)

Q4: External dependencies?
  - None → Simple/Medium
  - New libraries → likely Complex
```

**Szczegóły i przykłady:** `references/complexity-assessment.md`

---

## Quick Reference Tables

### Tabela 1: Kiedy Czytać References?

| Pytanie | Reference File |
|---------|----------------|
| Czy pomysł pasuje do MVP? | `mvp-scope-boundaries.md` |
| Jak ocenić złożoność? | `complexity-assessment.md` |
| Jak przeprowadzić weryfikację? | `verification-checklist.md` |
| Jak wygląda proces planowania PRD? | `prd-planning-process.md` |
| Jakie są fazy implementacji? | `implementation-phases.md` |

---

### Tabela 2: Kiedy Używać Examples?

| Scenario | Example File |
|----------|--------------|
| Pomysł odrzucony (out of scope) | `feature-verification-example.md` |
| Dobry breakdown funkcji (Medium) | `good-feature-breakdown.md` |
| Over-engineered funkcja (BAD) | `bad-feature-example.md` |
| Prosta funkcja (Simple) | `simple-feature-example.md` |
| Złożona funkcja (Complex) | `complex-feature-example.md` |

---

### Tabela 3: Kiedy Używać Templates?

| Zadanie | Template File |
|---------|---------------|
| Weryfikacja nowego pomysłu | `feature-proposal-template.md` |
| Plan implementacji | `implementation-plan-template.md` |
| Napisanie user story | `user-story-template.md` |
| Specyfikacja API endpoint | `api-endpoint-spec-template.md` |
| Sesja planistyczna PRD | `prd-planning-session-template.md` |
| Podsumowanie sesji PRD | `prd-summary-template.md` |
| Analiza tech stacku | `tech-stack-analysis-template.md` |

---

## Related Documentation

### Core Context (.ai/)
Główne dokumenty implementacyjne:
- `.ai/prd.md` - MVP requirements (user stories, acceptance criteria)
- `.ai/tech-stack.md` - Technology specs (stack, constraints, versions)
- `.ai/db-plan.md` - Database schema (tables, relations, indexes)
- `.ai/api-plan.md` - REST API specification (endpoints, DTOs, errors)
- `.ai/ui-plan.md` - Frontend architecture (components, services, routing)

### Decision Context (.decisions/)
Rationale dla decyzji (optional read):
- `.decisions/prd-context.md` - Business context + future vision
- `.decisions/tech-decisions.md` - Technology decisions rationale

### Project Status
- `PROGRESS_TRACKER.md` - Current implementation status (6 phases, current task)

### Skill Resources
- `references/` - Szczegółowa dokumentacja (7 plików)
- `examples/` - Konkretne przykłady z Photo Map MVP (5 plików)
- `templates/` - Gotowe szablony do użycia (7 plików)
