---
name: meta-workflow
description: |
  Meta 환경 기본 워크플로우. semo-system/ 수정 → 버저닝 → 배포 → 로컬 동기화 체인 자동 실행.
  Use when (1) [Meta] 프리픽스 요청, (2) semo-system/ 수정 완료 후, (3) Meta 패키지 설치 환경.
tools: [Bash, Read, Write, Edit, Glob, Grep]
model: inherit
triggers:
  - "[Meta]"
  - "[meta]"
  - "메타 작업"
  - "SEMO 수정"
  - "semo-system 수정"
---

> **시스템 메시지**: 이 Skill이 호출되면
> `[SEMO] - [META] Skill: meta-workflow 호출 - {작업 요약}` 시스템 메시지를 첫 줄에 출력

# meta-workflow Skill

**Purpose**: Meta 환경에서 semo-system/ 수정 작업의 End-to-End 워크플로우 관리

## 기본 활성화

> **Meta 패키지 설치 시 이 스킬이 기본 동작으로 실행됩니다.**

별도의 `[Meta]` 프리픽스 없이도, Meta 환경에서 semo-system/ 수정이 감지되면 자동으로 버저닝 → 배포 → 로컬 동기화 체인이 실행됩니다.

### 트리거 조건

| 조건 | 동작 |
|------|------|
| **Meta 패키지 설치 + semo-system/ 수정** | **자동으로 meta-workflow 체인 실행** |
| `[Meta]` 프리픽스 | 명시적 Meta 작업 요청 |
| 작업 완료 감지 (파일 변경) | 자동 버저닝 → 배포 → 동기화 |

## NON-NEGOTIABLE Rules

1. **Meta 환경 필수**: `semo-system/meta/` 존재 확인
2. **버저닝 필수**: 작업 완료 후 `skill:version-manager` 자동 호출
3. **로컬 동기화 필수**: git push 후 심볼릭 링크 재생성
4. **Slack 알림 필수**: 배포 완료 후 `skill:notify-slack` 호출

## Workflow

```
[요청 수신]
    ↓
Phase 1: 환경 검증
    - meta 패키지 설치 확인
    - GitHub 인증 확인 (gh auth status)
    - 현재 브랜치 확인 (main 권장)
    ↓
Phase 2: 작업 수행
    - semo-system/ 내 파일 수정
    - 기존 스킬 활용 (skill-creator, write-code 등)
    ↓
Phase 3: 버저닝 & 배포
    - 변경된 패키지 VERSION 범프
    - CHANGELOG 생성
    - git commit & push
    - Slack 알림
    ↓
Phase 4: 로컬 동기화
    - 심볼릭 링크 재생성
    - .claude/CLAUDE.md 재생성 (필요 시)
```

---

## 🔴 모노레포 구조 (NON-NEGOTIABLE)

> **SEMO는 모노레포 구조입니다. 반드시 올바른 경로에서 작업하세요.**

### 디렉토리 구조

```text
/path/to/project/              # 사용자 프로젝트 (git repo 아님)
├── .claude/                   # Claude 설정 (심링크)
├── semo-system/               # 로컬 심링크 타겟
│   └── ... (심링크)
│
└── semo/                      # ← 실제 모노레포 (semicolon-devteam/semo)
    ├── .git/                  # git 레포지토리
    ├── packages/
    │   ├── cli/               # @team-semicolon/semo-cli
    │   └── mcp-server/        # @team-semicolon/semo-mcp
    └── semo-system/           # ← 실제 SEMO 패키지 소스
        ├── semo-core/
        ├── semo-skills/
        ├── semo-hooks/
        └── meta/
```

### 모노레포 감지

```bash
# 모노레포 경로 찾기
MONOREPO_PATH=""
if [ -d "semo/.git" ]; then
  MONOREPO_PATH="semo"
elif [ -d "../semo/.git" ]; then
  MONOREPO_PATH="../semo"
fi

if [ -z "$MONOREPO_PATH" ]; then
  echo "❌ 모노레포를 찾을 수 없습니다"
  exit 1
fi
echo "✅ 모노레포 경로: $MONOREPO_PATH"
```

### 작업 위치 규칙

| 작업 유형 | 경로 | 설명 |
|----------|------|------|
| 스킬/에이전트 수정 | semo/semo-system/ | 모노레포 내 실제 소스 |
| CLI 수정 | semo/packages/cli/ | npm 패키지 |
| git 커밋/푸시 | semo/ | 모노레포 루트 |
| 로컬 심링크 | ./semo-system/ | 사용자 프로젝트 |

---

## Phase 1: 환경 검증

### 모노레포 확인

```bash
# 모노레포 경로 및 원격 확인
cd semo 2>/dev/null || cd ../semo 2>/dev/null
git remote -v | grep "semicolon-devteam/semo"
```

### Meta 환경 확인

```bash
# Meta 패키지 설치 확인 (모노레포 내)
if [ -d "semo-system/meta" ]; then
  echo "✅ Meta 환경 확인됨"
else
  echo "❌ Meta 패키지가 설치되어 있지 않습니다"
  exit 1
fi
```

### GitHub 인증 확인

```bash
gh auth status
```

### 브랜치 확인

```bash
git branch --show-current
# main 브랜치가 아닌 경우 경고 표시
```

---

## Phase 2: 작업 수행

사용자 요청에 따라 semo-system/ 내 파일을 수정합니다.

### 동작 범위

- `semo-system/semo-core/` - 에이전트, 커맨드, 원칙
- `semo-system/semo-skills/` - 통합 스킬
- `semo-system/meta/` - 메타 스킬/에이전트
- `semo-system/semo-remote/` - 원격 통합
- `semo-system/semo-hooks/` - 훅 시스템

### 활용 가능한 스킬

| 스킬 | 용도 |
|------|------|
| `skill-creator` | 새 스킬 생성 |
| `agent-manager` | 에이전트 관리 |
| `command-manager` | 커맨드 관리 |

---

## Phase 3: 버저닝 & 배포

### 변경 패키지 감지

```bash
# git diff로 변경된 패키지 감지
git diff --name-only HEAD | grep "semo-system/" | cut -d'/' -f2 | sort -u
```

### VERSION 범프 규칙

| 변경 유형 | 버전 범프 |
|----------|----------|
| Breaking Change | MAJOR (x.0.0) |
| 새 기능 추가 | MINOR (0.x.0) |
| 버그 수정, 문서 | PATCH (0.0.x) |

### 버저닝 체인

```text
1. VERSION 파일 범프
2. CHANGELOG/{version}.md 생성
3. git add & commit
4. git push origin main
5. skill:notify-slack 호출
```

### Slack 알림 형식

```text
🚀 SEMO 배포 완료

패키지: {package_name}
버전: {old_version} → {new_version}
변경: {change_summary}
```

---

## Phase 4: 로컬 동기화

> git push 완료 후 **항상 자동 실행**

### 동기화 대상

```bash
# 심볼릭 링크 재생성
.claude/skills/* → semo-system/semo-skills/*
.claude/agents/* → semo-system/semo-core/agents/*

# Meta 포함 (설치된 경우)
.claude/skills/* → semo-system/meta/skills/*
.claude/agents/* → semo-system/meta/agents/*
```

### 동기화 명령

```bash
# 기존 심볼릭 링크 정리 및 재생성
# (semo-cli의 createStandardSymlinks 로직 활용)

# 1. 기존 스킬 심볼릭 링크 정리
find .claude/skills -type l -delete

# 2. semo-skills 재링크
for skill in semo-system/semo-skills/*/; do
  skill_name=$(basename "$skill")
  ln -sf "../../semo-system/semo-skills/$skill_name" ".claude/skills/$skill_name"
done

# 3. meta 스킬 재링크 (있는 경우)
if [ -d "semo-system/meta/skills" ]; then
  for skill in semo-system/meta/skills/*/; do
    skill_name=$(basename "$skill")
    ln -sf "../../semo-system/meta/skills/$skill_name" ".claude/skills/$skill_name"
  done
fi

# 4. CLAUDE.md 재생성 (스킬 목록 업데이트)
# → semo-cli regenerateClaudeMd 호출 또는 수동 업데이트
```

### 동기화 완료 메시지

```markdown
[SEMO] - [META] Skill: meta-workflow 완료

✅ 버저닝: {package} {old} → {new}
✅ 원격 배포: git push 완료
✅ Slack 알림: 전송 완료
✅ 로컬 동기화: 심볼릭 링크 재생성 완료
```

---

## Related Skills

- `version-manager` - 버저닝 자동화
- `notify-slack` - Slack 알림
- `skill-creator` - 스킬 생성
- `package-validator` - 패키지 검증
- `package-sync` - 패키지 동기화

## References

- [Workflow Phases](references/workflow-phases.md)
- [Version Manager Skill](../../semo-skills/version-manager/SKILL.md)
- [Notify Slack Skill](../../semo-skills/notify-slack/SKILL.md)
