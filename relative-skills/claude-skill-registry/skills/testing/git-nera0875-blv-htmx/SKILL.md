---
name: git
description: Git workflow expert for user projects. Auto-commit features, semantic messages, GitHub integration. Auto-activates on keywords "commit", "push", "git", "github", "version control" or when feature/bugfix completed.
allowed-tools: Bash, Read, Write
---

# Git Workflow Skill

> **Expert Git pour projets user**
>
> Inspiré de : Conventional Commits, GitHub Flow, Semantic Versioning

---

## Scope & Activation

**Chargé par:** EXECUTOR agent (après feature complétée)

**Auto-activé si keywords:**
- `commit`, `push`, `pull`, `git`, `github`
- `version control`, `save changes`, `deploy`
- Feature complétée (auto par executor)
- Bugfix résolu (auto par executor)

**Actions gérées:**
- Commits automatiques (après features)
- Messages sémantiques (conventional commits)
- Push GitHub
- Branches management
- Tag releases

---

## Workflow Auto Commit (OBLIGATOIRE après feature)

### Phase 1: Détection Feature Complétée

**Quand EXECUTOR termine feature:**

```
EXECUTOR:
1. Crée composants/routes
2. Tests passent (TESTER validé)
3. Feature opérationnelle

→ Invoque skill("git") automatiquement
```

**Trigger auto:**
- Feature backend complétée
- Feature frontend complétée
- Bugfix appliqué
- Refactor terminé

---

### Phase 2: Status Check

**AVANT commit, toujours vérifier état:**

```bash
# Check si git repo existe
if [ ! -d .git ]; then
  git init
  echo "✅ Git repo initialisé"
fi

# Check fichiers modifiés
git status --short

# Check si changements à commit
if [ -z "$(git status --porcelain)" ]; then
  echo "✅ Aucun changement à commit"
  exit 0
fi
```

---

### Phase 3: Auto Commit (Conventional Commits)

**Format message (STRICT):**

```
<type>(<scope>): <description>

[body optionnel]

[footer optionnel]
```

**Types autorisés:**
- `feat` - Nouvelle feature
- `fix` - Bugfix
- `refactor` - Refactoring code (pas feature, pas bug)
- `docs` - Documentation uniquement
- `style` - Formatting (pas logic)
- `test` - Ajout/modification tests
- `chore` - Maintenance (deps, configs)
- `perf` - Performance improvement

**Scope (optionnel):**
- `api` - Backend API
- `ui` - Frontend UI
- `db` - Database
- `auth` - Authentication
- `dashboard` - Dashboard feature
- etc (selon projet)

**Exemples:**

```bash
# Feature backend
git commit -m "feat(api): add task CRUD endpoints

- POST /api/tasks (create)
- GET /api/tasks (list)
- PUT /api/tasks/:id (update)
- DELETE /api/tasks/:id (delete)

Prisma schema: Task model with status/priority"

# Feature frontend
git commit -m "feat(dashboard): add kanban board

- KanbanBoard component (dnd-kit)
- TaskCard component
- Column component (To Do, In Progress, Done)
- Drag & drop functionality"

# Bugfix
git commit -m "fix(auth): resolve session timeout issue

- Extend session duration to 24h
- Add auto-refresh token mechanism"

# Refactor
git commit -m "refactor(ui): simplify Button component API

- Remove unused props
- Improve TypeScript types
- Better composition pattern"
```

---

### Phase 4: Workflow Commit Auto

**EXECUTOR appelle automatiquement:**

```bash
# 1. Stage tous les fichiers
git add .

# 2. Commit avec message sémantique
git commit -m "$(cat <<'EOF'
feat(dashboard): add stats cards

- StatsCard component (shadcn Card)
- Display tasks count by status
- Responsive grid layout

Generated with Claude Code
EOF
)"

# 3. Confirmation
echo "✓ Committed: feat(dashboard): add stats cards"
```

**Footer standard (toujours inclure):**
```
Generated with Claude Code
```

---

## Workflow Branches

### Main Branch (par défaut)

**Workflow simple (petits projets):**

```
main
  ↓
  commit feat(x)
  ↓
  commit fix(y)
  ↓
  commit feat(z)
```

**Principe:** Commits directs sur main, déploiement continu.

---

### Feature Branches (projets moyens/grands)

**Workflow GitHub Flow:**

```bash
# 1. Créer branch feature
git checkout -b feature/kanban-board

# 2. Commits sur branch
git commit -m "feat(kanban): add board layout"
git commit -m "feat(kanban): add drag & drop"

# 3. Push branch
git push -u origin feature/kanban-board

# 4. Merge dans main (après PR validée)
git checkout main
git merge feature/kanban-board
git push origin main

# 5. Delete branch
git branch -d feature/kanban-board
git push origin --delete feature/kanban-board
```

**Quand utiliser feature branches:**
- Projet en équipe (>1 dev)
- Feature complexe (>5 commits)
- Review process nécessaire
- User demande explicitement

**Par défaut:** Commits directs sur main (solo dev, prototyping rapide).

---

## Push GitHub

### Auto Push (si user demande)

**User:**
> "Push sur GitHub"

**Executor (skill git):**

```bash
# 1. Vérifier remote configuré
if ! git remote get-url origin >/dev/null 2>&1; then
  echo "❌ Remote 'origin' pas configuré"
  echo "Run: git remote add origin https://github.com/user/repo.git"
  exit 1
fi

# 2. Push branch actuelle
BRANCH=$(git branch --show-current)
git push -u origin "$BRANCH"

echo "✓ Pushed to origin/$BRANCH"
```

---

### First Push (nouveau repo)

**User:**
> "Crée repo GitHub et push"

**Executor (skill git):**

```bash
# 1. Check si gh CLI installé
if ! command -v gh &>/dev/null; then
  echo "❌ GitHub CLI pas installé"
  echo "Install: https://cli.github.com/"
  exit 1
fi

# 2. Créer repo GitHub
gh repo create mon-dashboard --public --source=. --remote=origin

# 3. Push
git push -u origin main

echo "✓ Repo créé et pushed: https://github.com/user/mon-dashboard"
```

**Fallback (si pas gh CLI):**

```bash
echo "Créer repo manuellement:"
echo "1. https://github.com/new"
echo "2. Nom: mon-dashboard"
echo "3. Public/Private: [choix user]"
echo "4. NE PAS initialiser README/gitignore"
echo ""
echo "Puis run:"
echo "git remote add origin https://github.com/user/mon-dashboard.git"
echo "git push -u origin main"
```

---

## .gitignore (Auto Setup)

**TOUJOURS créer .gitignore si absent:**

**Next.js project:**

```gitignore
# dependencies
/node_modules
/.pnp
.pnp.js

# testing
/coverage

# next.js
/.next/
/out/

# production
/build

# misc
.DS_Store
*.pem

# debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# local env files
.env*.local
.env

# vercel
.vercel

# typescript
*.tsbuildinfo
next-env.d.ts

# prisma
/prisma/migrations/*_migration/
!/prisma/migrations/migration_lock.toml

# Builder
.build/
```

**Python/FastAPI project:**

```gitignore
# Byte-compiled
__pycache__/
*.py[cod]
*$py.class

# Virtual env
venv/
env/
ENV/

# Database
*.db
*.sqlite3

# Env
.env
.env.local

# IDE
.vscode/
.idea/

# Logs
*.log
```

---

## Tags & Releases

### Semantic Versioning

**Format:** `vMAJOR.MINOR.PATCH`

- **MAJOR** - Breaking changes
- **MINOR** - New features (backward compatible)
- **PATCH** - Bugfixes

**Exemples:**
- `v1.0.0` - Initial release
- `v1.1.0` - Add kanban feature
- `v1.1.1` - Fix drag & drop bug
- `v2.0.0` - Refactor architecture (breaking)

---

### Créer Release

**User:**
> "Crée release v1.0.0"

**Executor (skill git):**

```bash
# 1. Tag version
git tag -a v1.0.0 -m "Release v1.0.0

Features:
- Dashboard avec stats
- Kanban board (drag & drop)
- Pomodoro timer
- Dark mode support

Built with Builder System"

# 2. Push tag
git push origin v1.0.0

# 3. Créer GitHub release (si gh CLI)
if command -v gh &>/dev/null; then
  gh release create v1.0.0 \
    --title "v1.0.0 - Initial Release" \
    --notes "$(cat <<'EOF'
## 🎉 Initial Release

### Features
- ✅ Dashboard avec stats
- ✅ Kanban board (drag & drop)
- ✅ Pomodoro timer
- ✅ Dark mode support

### Tech Stack
- Next.js 16 + React 19
- shadcn/ui + Tailwind v4
- Prisma + PostgreSQL

Built with [Builder System](https://github.com/pilotedev/BUILDER)
EOF
)"
fi

echo "✓ Release v1.0.0 créée"
```

---

## Hooks Git (Pre-commit)

### Setup Husky (optionnel)

**Si user demande quality checks:**

```bash
# Install husky
npm install --save-dev husky
npx husky init

# Pre-commit hook
cat > .husky/pre-commit <<'EOF'
#!/bin/sh
npm run lint
npm run type-check
EOF

chmod +x .husky/pre-commit
```

**Hooks standards:**
- `pre-commit` - Lint + Type check
- `pre-push` - Tests
- `commit-msg` - Validate commit message format

---

## Best Practices

### Commit Frequency

**✅ DO:**
- Commit après chaque feature complétée
- Commit après bugfix résolu
- Commit quand tests passent
- Commits atomiques (1 feature = 1 commit)

**❌ DON'T:**
- Commit work-in-progress (WIP) sur main
- Commits massifs (>500 lines changed)
- Messages vagues ("update", "fix", "changes")
- Commit code non testé

---

### Message Quality

**✅ GOOD:**
```
feat(api): add user authentication

- JWT token generation
- Password hashing (bcrypt)
- Login/logout endpoints
- Middleware auth validation

Closes #12
```

**❌ BAD:**
```
update stuff
```

**❌ BAD:**
```
feat: lots of changes
```

---

### Git History

**Garder historique propre:**

```bash
# Amend dernier commit (si typo message)
git commit --amend -m "fix(typo): correct commit message"

# Rebase interactif (squash commits)
git rebase -i HEAD~3

# Reset dernier commit (garder changes)
git reset --soft HEAD~1
```

**⚠️ ATTENTION:** Jamais rebase/amend commits déjà pushed sur main partagé.

---

## Workflow Complet Exemple

**User demande:**
> "Dashboard TickTick avec kanban + pomodoro"

**EXECUTOR + skill git:**

```
1. EXECUTOR crée projet
   ↓
2. git init (auto)
   ↓
3. Crée .gitignore (auto)
   ↓
4. EXECUTOR termine backend
   ↓
5. git add . && git commit -m "feat(api): add task API"
   ↓
6. EXECUTOR termine frontend kanban
   ↓
7. git add . && git commit -m "feat(kanban): add board"
   ↓
8. EXECUTOR termine pomodoro
   ↓
9. git add . && git commit -m "feat(pomodoro): add timer"
   ↓
10. User: "Push GitHub"
    ↓
11. git push -u origin main
```

**Résultat GitHub:**

```
* feat(pomodoro): add timer
* feat(kanban): add board
* feat(api): add task API
* chore: initial commit
```

---

## Conventions Non-Negotiables

1. **Conventional Commits** (format strict)
2. **Commit après chaque feature** (auto par executor)
3. **Messages descriptifs** (pas "update", "fix")
4. **Footer "Generated with Claude Code"** (toujours)
5. **Tests passent avant commit** (TESTER validé)
6. **.gitignore créé** (avant premier commit)
7. **Semantic Versioning** (releases)
8. **Main branch stable** (commits = features complètes)

---

**Inspiré de:**
- Conventional Commits (conventional commits.org)
- GitHub Flow (guides.github.com/introduction/flow/)
- Semantic Versioning (semver.org)
- Angular Commit Guidelines (github.com/angular/angular)

---

**Version**: 1.0.0
**Last updated**: 2025-11-11
**Maintained by**: EXECUTOR agent
