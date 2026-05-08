---
name: git-workflow-policy
description: Git workflow policies including commit rules and worktree cleanup sequence. Use when managing git operations, commits, or merges.
---

# Git Workflow Policy

## Instructions

### Core policies

1. Never commit without explicit user approval
2. Phase commits at Step 9 only
3. No direct commits to main
4. Worktree → merge pattern
5. 4-step cleanup in order (plan → services → worktree → branch)

### Commit policy

**Before committing:**
- Present changes with rationale
- Show affected code/logs
- Get explicit user approval
- Focus minimal scope

### Worktree 4-step cleanup

**CRITICAL ORDER:**

```bash
1. rm .plan/{{feature_name}}_plan.md
2. cd .worktree/{{feature-name}} && {{cleanup_command}}
3. git worktree remove .worktree/{{feature-name}}
4. git branch -d feature/{{feature-name}}
```

**Why:** Plan first (project cleanup) → Services (prevent orphans) → Worktree (directory) → Branch (git)

<!-- CUSTOMIZE: Replace {{cleanup_command}} with project-specific commands -->
**Note:** `{{cleanup_command}}` = project-specific cleanup

**Common Cleanup Commands by Stack:**

**Python/Flask/Django:**
```bash
# Stop services
pkill -f "python.*{{app_name}}"
# Or docker-based:
docker-compose down
# Clean artifacts
rm -rf __pycache__ *.pyc .pytest_cache
```

**Node.js/Express:**
```bash
# Stop services
pm2 stop {{app_name}}
# Or kill process:
pkill -f "node.*{{app_name}}"
# Clean artifacts
rm -rf node_modules/.cache dist build
```

**Go:**
```bash
# Stop services
pkill -f "{{binary_name}}"
# Clean artifacts
rm -rf {{binary_name}} *.test
```

**Java/Spring:**
```bash
# Stop services
pkill -f "java.*{{app_name}}"
# Clean artifacts
./gradlew clean  # or: mvn clean
```

**Docker-based (Any stack):**
```bash
# Stop and remove containers
docker-compose -f docker-compose.{{env}}.yml down
docker rm -f {{container_name}}
# Clean volumes (optional)
docker volume prune -f
```

## Example

```bash
# ❌ Wrong
git worktree remove .worktree/feature-x  # Services orphaned!

# ✅ Correct
rm .plan/feature-x_plan.md
cd .worktree/feature-x && {{project_cleanup_command}}
git worktree remove .worktree/feature-x
git branch -d feature/feature-x
```

## Workflow

```
Code complete
    ↓
Present to user
    ↓
User approves
    ↓
Commit at Step 9
    ↓
All phases done
    ↓
Merge to main
    ↓
4-step cleanup
```

---

**For detailed policies, see [reference.md](reference.md)**
**For more examples, see [examples.md](examples.md)**
