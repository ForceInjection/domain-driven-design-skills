---
name: plan-management
description: Multi-layer planning and playbook management. Use when creating playbooks, transitioning phases, or managing plan hierarchy. Triggers on "plan", "playbook", "phase", "roadmap", "milestone" keywords.
---

# Plan Management Skill

Multi-layer planning system for long-running agent sessions.

## Plan Hierarchy Structure

```
roadmap (最上位)
  └── milestones
        └── playbooks (1 task = 1 playbook = 1 branch)
              └── phases
```

## When to Use This Skill

- **New task**: Create playbook before starting work
- **Phase transition**: Update playbook status and state.md
- **Session start**: Read roadmap → playbook → understand context
- **Task completion**: Verify against done_criteria, call critic

## Playbook Creation Flow

```yaml
1. Determine task scope
2. Check existing playbooks in plan/
3. Create playbook using plan/template/playbook-format.md
4. Update state.md:
   - active_playbooks.{layer}: path/to/playbook
   - layer.{layer}.playbook: path/to/playbook
5. Commit playbook
```

## Phase Transition Rules

```yaml
状態遷移:
  pending → designing → implementing → [reviewing] → state_update → done

禁止遷移:
  - pending → implementing (設計スキップ禁止)
  - pending → done (全スキップ禁止)
  - * → done without critic (自己報酬詐欺防止)

Phase 完了条件:
  1. done_criteria の全項目に証拠がある
  2. test_method を実際に実行した
  3. critic が PASS を返した
```

## Four-Tuple Coherence

```yaml
四つ組:
  - focus.current (state.md)
  - layer.state (state.md)
  - playbook (plan/playbook-*.md)
  - branch (git)

整合性ルール:
  - playbook.branch == git current branch
  - focus.current == active playbook's layer
  - layer.state reflects playbook progress
```

## Session Start Checklist

```yaml
必須 Read:
  1. state.md → focus.current 確認
  2. roadmap (if workspace layer)
  3. playbook (if session=task)
  4. project.md (if product layer)

branch 確認:
  - main なら新ブランチ作成
  - playbook.branch と一致するか確認

playbook 確認:
  - null なら /playbook-init 実行
  - 存在するなら Read して in_progress phase 特定
```

## Automatic Triggers

This skill activates when Claude detects:
- "計画を立てて" / "plan" / "playbook"
- "次のフェーズ" / "phase"
- "ロードマップ" / "roadmap" / "milestone"
- Session start with session=task

## Integration with Hooks

```yaml
session-start.sh:
  - Outputs required Read list
  - Warns if playbook=null

check-coherence.sh:
  - Validates four-tuple alignment
  - Blocks commits if misaligned

session-end.sh:
  - Updates session_tracking
  - Reminds about uncommitted changes
```

## Best Practices

1. **One task = One playbook = One branch**
2. **Read before write**: Always read playbook before modifying
3. **Evidence-based completion**: No done without proof
4. **Critic before done**: Always call critic agent
5. **Commit after each phase**: Keep git in sync
