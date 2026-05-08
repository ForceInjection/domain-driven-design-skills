---
name: long-running-harness
description: |
  **UNIVERSAL TRIGGER**: Use when user wants to START/CONTINUE/MANAGE a long-running development project across multiple sessions.

  Common patterns:
  - "start/init/begin new project [description]"
  - "continue/resume working on [project]"
  - "начать/инициализировать проект", "продолжить работу над проектом"
  - "set up harness for [project]", "create project scaffolding"

  Session types supported:

  🚀 **Initialize (first run)**:
  - "init long-running project", "start new multi-session project"
  - "set up project harness", "create progress tracking"
  - "initialize [web-app/api/cli] project", "начать долгий проект"

  🔄 **Continue (subsequent sessions)**:
  - "continue project", "resume work", "продолжить работу"
  - "pick up where I left off", "what's next", "следующая фича"
  - "next feature", "continue implementation"

  📊 **Status & Progress**:
  - "show project progress", "what features are done"
  - "project status", "статус проекта", "что сделано"
  - "remaining features", "what's left to do"

  🔧 **Management**:
  - "mark feature as done", "update progress"
  - "add new feature to list", "reprioritize features"

  Context patterns:
  - "get/show/list project progress"
  - "check project status"
  - "what features in project"
  - "display remaining features"
  - "fetch session history"
  - "retrieve progress log"

  TRIGGERS: long-running, multi-session, project harness, initialize project,
  continue project, resume work, progress tracking, feature list, session handoff,
  incremental development, cross-session, долгий проект, продолжить работу,
  прогресс проекта, следующая сессия, инициализация проекта, get project status,
  show features, list remaining, check progress, display status, fetch history,
  retrieve log, what features done, start harness, begin project, resume session,
  next feature, pick up work, update progress, mark done, end session

  Based on Anthropic's research on effective harnesses for long-running agents.
  Source: https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, TodoWrite
---

# Long-Running Agent Harness

Skill для управления долгосрочными проектами, которые требуют работы через множество сессий Claude. Основан на исследовании Anthropic.

**📚 Источник**: [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) (Anthropic Engineering, Nov 2025)

---

## Проблема, которую решает этот skill

AI-агенты работают в дискретных сессиях без памяти о предыдущей работе. Это приводит к:
- ❌ Попыткам сделать всё за раз (one-shotting)
- ❌ Преждевременному объявлению проекта завершённым
- ❌ Потере контекста между сессиями
- ❌ Багам и недокументированному прогрессу

**Решение**: Два типа агентов + структурированные артефакты для передачи контекста.

---

## Архитектура оркестрации

```
┌─────────────────────────────────────────────────────────────────┐
│                    ORCHESTRATION FLOW                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────┐      FIRST RUN ONLY                      │
│  │ INITIALIZER      │─────────────────────────────┐            │
│  │ AGENT            │                             │            │
│  │                  │  Creates:                   │            │
│  │ (Claude + this   │  • features.json            │            │
│  │  skill in init   │  • progress.md              │            │
│  │  mode)           │  • init.sh                  │            │
│  └──────────────────┘  • Initial git commit       │            │
│           │                                       ▼            │
│           │            ┌─────────────────────────────────┐     │
│           │            │        PROJECT ARTIFACTS        │     │
│           │            │  ┌─────────────────────────┐    │     │
│           │            │  │ .claude/                │    │     │
│           │            │  │ ├── features.json      │    │     │
│           │            │  │ ├── progress.md        │    │     │
│           │            │  │ └── architecture.md    │    │     │
│           │            │  │ scripts/init.sh        │    │     │
│           │            │  └─────────────────────────┘    │     │
│           │            └─────────────────────────────────┘     │
│           │                         ▲         │                │
│           │                         │         │                │
│           │         ┌───────────────┘         │                │
│           ▼         │                         ▼                │
│  ┌──────────────────┐                ┌──────────────────┐      │
│  │ CODING AGENT     │───────────────▶│ CODING AGENT     │      │
│  │ Session 1        │                │ Session 2        │ ...  │
│  │                  │  Reads:        │                  │      │
│  │ (Claude + this   │  • progress.md │                  │      │
│  │  skill in        │  • features.json                  │      │
│  │  continue mode)  │  • git log     │                  │      │
│  │                  │                │                  │      │
│  │ Updates:         │  Updates:      │                  │      │
│  │ • 1 feature      │  • 1 feature   │                  │      │
│  │ • progress.md    │  • progress.md │                  │      │
│  │ • git commit     │  • git commit  │                  │      │
│  └──────────────────┘                └──────────────────┘      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Режимы работы

### 1. `init` — Инициализация нового проекта

**Когда использовать**: Первый запуск, новый проект.

**Входные данные от пользователя**:
| Параметр | Обязательно | Описание |
|----------|-------------|----------|
| Описание проекта | ✅ | Что нужно построить |
| Тип проекта | ✅ | `web-app` \| `api` \| `cli` \| `library` \| `mobile` |
| Стек технологий | ⚪ | React, Python, Rails... (или auto-detect) |
| Приоритеты фич | ⚪ | Какие фичи важнее |

**Генерируемые артефакты**:
```
project/
├── .claude/
│   ├── progress.md          # Лог прогресса между сессиями
│   ├── features.json        # 30-200 фич с статусами
│   └── architecture.md      # Ключевые архитектурные решения
├── scripts/
│   └── init.sh              # Setup окружения + smoke test
└── [initial git commit]
```

### 2. `continue` — Продолжение работы

**Когда использовать**: Каждая последующая сессия.

**Входные данные**: Не требуются (читаем из артефактов).

**Обновляемые артефакты**:
- `progress.md` — добавляется новая запись
- `features.json` — `passes: false → true` для завершённых фич
- Git commit с описательным сообщением

### 3. `status` — Просмотр прогресса

**Когда использовать**: Посмотреть что сделано/осталось.

---

## Формат артефактов

### `.claude/features.json`

```json
{
  "project": "claude-clone",
  "type": "web-app",
  "created_at": "2025-12-02T10:00:00Z",
  "total_features": 47,
  "completed": 12,
  "features": [
    {
      "id": "F001",
      "category": "core",
      "priority": 1,
      "description": "User can send message and receive AI response",
      "verification_steps": [
        "Open app in browser",
        "Type message in input field",
        "Press Enter or click Send",
        "Verify AI response appears within 5 seconds"
      ],
      "passes": false,
      "completed_at": null,
      "session_id": null
    },
    {
      "id": "F002",
      "category": "core",
      "priority": 1,
      "description": "Conversation history persists after page reload",
      "verification_steps": [
        "Send a message",
        "Reload the page",
        "Verify conversation is still visible"
      ],
      "passes": true,
      "completed_at": "2025-12-02T14:30:00Z",
      "session_id": "session-003"
    }
  ]
}
```

**Правила для features.json**:
- ❌ НИКОГДА не удалять фичи
- ❌ НИКОГДА не редактировать description уже существующих фич
- ✅ ТОЛЬКО менять `passes: false → true` после верификации
- ✅ ТОЛЬКО добавлять новые фичи в конец списка

### `.claude/progress.md`

```markdown
# Project Progress Log

## Project: claude-clone
**Type**: web-app
**Stack**: Next.js, TypeScript, Tailwind CSS
**Started**: 2025-12-02

---

## Session 5 | 2025-12-02 14:30 | session-005
**Focus**: Dark mode implementation
**Duration**: ~45 min

### Completed Features
- ✅ F012: Dark mode toggle button
- ✅ F013: Theme persistence in localStorage

### In Progress
- 🔄 F014: System theme detection (80% done, need media query listener)

### Blockers
- None

### Technical Decisions
- Used CSS variables for theming (easier to maintain)
- Chose `prefers-color-scheme` media query over JS detection

### Next Session Should
1. Complete F014 (system theme detection)
2. Start F015 (conversation sidebar)
3. Run full E2E test suite

### Git Commits This Session
- `a3f2b1c` feat: add dark mode toggle component
- `e5d4c3b` feat: persist theme in localStorage
- `f7e8d9a` refactor: extract theme utils

---

## Session 4 | 2025-12-02 12:00 | session-004
...
```

### `scripts/init.sh`

**Назначение**: Setup окружения чтобы агент мог сразу начать работу.

**НЕ путать с**: Запуском dev-сервера. `init.sh` — это подготовка, не запуск.

**Что делает init.sh**:
1. Устанавливает зависимости (bundle/npm/yarn)
2. Настраивает базу данных (migrations, seeds)
3. Копирует .env файлы из примеров
4. Запускает smoke tests для проверки что всё работает
5. Выводит инструкции как запустить сервер

**Примеры для разных стеков**:
- `examples/init-nodejs.sh` — Node.js / JavaScript / TypeScript
- `examples/init-rails.sh` — Ruby on Rails

**Пример структуры** (Ruby on Rails):
```bash
#!/bin/bash
set -e

echo "🔧 Setting up Rails environment..."

# 1. Install dependencies
bundle install
yarn install

# 2. Setup database
rails db:prepare

# 3. Copy env files
[ ! -f .env ] && [ -f .env.example ] && cp .env.example .env

# 4. Smoke tests
rails runner "puts '✅ Rails loads OK'"
rails runner "ActiveRecord::Base.connection; puts '✅ DB connection OK'"

echo "✅ Environment ready!"
echo "To start server: rails server"
```

---

## Инструкция для человека (оператора)

### Как запустить INIT сессию

```
Человек → Claude:
"Инициализируй долгосрочный проект: [описание проекта].
Тип: web-app. Стек: Next.js + TypeScript."

Claude выполнит:
1. Создаст структуру .claude/ с артефактами
2. Сгенерирует 30-200 фич на основе описания
3. Создаст init.sh скрипт
4. Сделает initial git commit
```

### Как запустить CONTINUE сессию

**Вариант 1 — Простой запуск**:
```
Человек → Claude:
"Продолжи работу над проектом"

Claude выполнит startup checklist автоматически.
```

**Вариант 2 — С указанием фокуса**:
```
Человек → Claude:
"Продолжи проект, сфокусируйся на фичах авторизации"
```

**Вариант 3 — Проверка статуса перед работой**:
```
Человек → Claude:
"Покажи статус проекта и что делать дальше"
```

### Когда завершать сессию

Оператор должен завершить сессию когда:
- ⏰ Прошло 30-45 минут активной работы
- ✅ Завершена 1-2 фичи
- 🔄 Claude начинает делать много изменений без коммитов
- ⚠️ Контекст становится длинным (Claude начинает забывать)

**Команда для завершения**:
```
Человек → Claude:
"Заверши сессию. Обнови progress.md, закоммить изменения,
напиши что делать в следующей сессии."
```

---

## Startup Checklist (автоматический)

При каждом `continue` Claude ОБЯЗАН выполнить:

```
┌─────────────────────────────────────────────────────────────┐
│                 SESSION STARTUP CHECKLIST                   │
├─────────────────────────────────────────────────────────────┤
│ 1. ☐ pwd → подтвердить рабочую директорию                  │
│ 2. ☐ git status → проверить чистоту репозитория            │
│ 3. ☐ git log -5 → последние коммиты                        │
│ 4. ☐ cat .claude/progress.md → что было сделано            │
│ 5. ☐ cat .claude/features.json → статус фич                │
│ 6. ☐ ./scripts/init.sh → setup environment + smoke test    │
│ 7. ☐ Выбрать ОДНУ фичу (highest priority, passes=false)    │
│ 8. ☐ Объявить какую фичу будем делать                      │
└─────────────────────────────────────────────────────────────┘
```

## Session End Checklist (автоматический)

Перед завершением сессии Claude ОБЯЗАН:

```
┌─────────────────────────────────────────────────────────────┐
│                  SESSION END CHECKLIST                      │
├─────────────────────────────────────────────────────────────┤
│ 1. ☐ Все изменения закоммичены (git status clean)          │
│ 2. ☐ features.json обновлён (passes=true для готовых)      │
│ 3. ☐ progress.md обновлён (новая запись сессии)            │
│ 4. ☐ Указано что делать в следующей сессии                 │
│ 5. ☐ Нет TODO комментариев в коде                          │
│ 6. ☐ Базовый smoke test проходит                           │
└─────────────────────────────────────────────────────────────┘
```

---

## Failure Modes & Solutions

| Проблема | Как предотвращаем |
|----------|-------------------|
| Claude объявляет проект готовым слишком рано | features.json с полным списком фич |
| Баги и недокументированный прогресс | Обязательный smoke test + progress.md |
| Фичи помечаются готовыми без тестирования | Verification steps в каждой фиче |
| Время тратится на понимание как запустить | init.sh скрипт |
| Потеря контекста между сессиями | progress.md + git log |
| Попытка сделать слишком много за раз | Правило "1 фича за сессию" |

---

## Примеры использования

### Пример 1: Инициализация web-app

```
Человек: "Инициализируй долгосрочный проект: клон Notion с
базовыми функциями - страницы, блоки, drag-and-drop.
Тип: web-app. Стек: Next.js, TypeScript, Prisma, PostgreSQL."

Claude:
1. Создаёт .claude/features.json с ~50 фичами
2. Создаёт .claude/progress.md
3. Создаёт scripts/init.sh
4. git init && git add . && git commit -m "Initial project setup"
5. Выводит summary и рекомендации для первой continue сессии
```

### Пример 2: Continue сессия

```
Человек: "Продолжи работу"

Claude:
1. Выполняет startup checklist
2. Читает progress.md: "Session 3 закончилась на F007"
3. Читает features.json: F008 = "User can create new page"
4. Запускает init.sh, проверяет smoke test
5. Объявляет: "Буду работать над F008: создание новой страницы"
6. Реализует фичу инкрементально
7. Тестирует end-to-end
8. Обновляет features.json: passes=true
9. git commit -m "feat: implement page creation (F008)"
10. Обновляет progress.md
```

### Пример 3: Проверка статуса

```
Человек: "Статус проекта"

Claude:
📊 Project Status: notion-clone
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Completed: 12/47 features (25%)
🔄 In Progress: F013 (block drag-and-drop)
⏭️ Next Priority: F014 (nested pages)

Recent Sessions:
• Session 5: Completed F011, F012 (block types)
• Session 4: Completed F009, F010 (page navigation)

Blockers: None
```

---

## Интеграция с другими инструментами

### Git Workflow
- Каждая фича = отдельный коммит
- Commit message format: `feat: [description] (F###)`
- Используй `git diff` перед коммитом

### Testing
- Для web-app: используй Playwright/Puppeteer для E2E
- Для API: используй curl/httpie для smoke tests
- Для CLI: запускай с тестовыми аргументами

### TodoWrite Integration
При continue сессии создавай todos:
```
- [ ] Complete F### verification
- [ ] Update features.json
- [ ] Update progress.md
- [ ] Git commit
```

---

## Ограничения и известные проблемы

1. **Vision limitations**: Claude может не увидеть browser alerts через Puppeteer
2. **Context pressure**: При очень длинных сессиях качество падает
3. **Scope creep**: Следи чтобы Claude не добавлял фичи сверх списка

---

## Ссылки

- **Источник**: [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- **Quickstart код**: [anthropics/claude-quickstarts/autonomous-coding](https://github.com/anthropics/claude-quickstarts/tree/main/autonomous-coding)
- **Claude 4 Prompting Guide**: [Multi-context window workflows](https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices#multi-context-window-workflows)
