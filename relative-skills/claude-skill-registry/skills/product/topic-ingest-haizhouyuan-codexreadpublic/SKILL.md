---
name: topic-ingest
description: 将一条已生成的 digest/research 归档到指定 topic，并更新 topic 的 sources/timeline（M2/M3 辅助能力）。
allowed-tools:
  - workspace
  - shell
  - python
---

# 触发条件

当用户说“把这条 digest 挂到某个 topic”“更新 topic 的 sources/timeline”“把 exports/digests 的内容归档到主题档案”等场景使用本技能。

# 目标

- 输入：一条 digest/research Markdown 文件路径 + `topic_id`
- 输出：
  - 确保文件位于：`archives/topics/<topic_id>/digests/`
  - 更新：`archives/topics/<topic_id>/sources.md`
  - （可选）追加：`archives/topics/<topic_id>/timeline.md`

# 操作步骤（SOP）

1. **确认 topic_id**
   - 必须是稳定 slug（小写+下划线），例如 `space_industry`。

2. **确认输入文件路径**
   - 允许输入文件位于：
     - `archives/topics/<topic_id>/digests/`（已在 topic 内）
     - `exports/digests/`（需要归档进 topic）

3. **必要时复制到 topic**
   - 若文件不在 `archives/topics/<topic_id>/digests/` 下：
     - 将其复制到 `archives/topics/<topic_id>/digests/<same_filename>.md`（避免移动导致历史引用失效）

4. **更新 topic 的 sources（可选 timeline）**
   - 运行：
     - `python3 scripts/topic_ingest_digest.py <topic_id> <digest_path_in_topic>`
     - 若用户要求更新时间线：加 `--timeline`

5. **对用户反馈**
   - 返回：
     - 最终 digest 路径
     - 是否更新了 `sources.md` / `timeline.md`

# 输出格式

- `topic_id`: `<topic_id>`
- `digest_path`: `<path>`
- `sources_updated`: `true|false`
- `timeline_updated`: `true|false`

