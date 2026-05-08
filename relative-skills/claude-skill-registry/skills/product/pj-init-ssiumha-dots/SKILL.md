---
name: pj-init
description: 멀티레포 워크스페이스(~/pj/xxx/)의 CLAUDE.md를 초기화합니다. 여러 독립 저장소가 하나의 프로젝트로 관리되는 구조에서 사용하세요. (user)
---

# PJ Init

멀티레포 워크스페이스용 CLAUDE.md 초기화 스킬입니다.

**대상 구조**: `~/pj/{project}/` 아래 여러 독립 git 저장소 (모노레포 아님)

**문서화**: `living-docs` 스킬과 연동 (`~/docs/pj--{project}/`)

## Instructions

### 워크플로우 1: 새 워크스페이스 초기화

사용자가 "CLAUDE.md 초기화", "pj 설정" 요청 시:

#### 1. 현재 위치 확인

```bash
pwd
ls -la
```

**확인 사항**:
- `~/pj/{project}/` 패턴인지
- 하위 폴더들이 git 저장소인지

#### 2. 저장소 탐색

```bash
# 각 하위 폴더의 git remote 확인
for dir in */; do
  echo "=== $dir ==="
  git -C "$dir" remote -v 2>/dev/null | head -1
done
```

**수집 정보**:
- 저장소 목록
- GitHub organization/repo 이름
- 저장소별 역할 (backend, frontend 등)

#### 3. 저장소별 상세 정보 수집

각 저장소의 README, package.json/pyproject.toml 확인:

**수집 정보**:
- 기술 스택 (NestJS, React, FastAPI 등)
- 패키지 매니저 (pnpm, npm, uv 등)
- 주요 명령어 (dev, build, test)
- 서비스 포트

#### 4. 사용자와 대화

필수 질문:
- "프로젝트 설명을 간단히 알려주세요"
- "저장소 간 연동 관계가 있나요? (예: API → Frontend codegen)"
- "특별한 작업 규칙이 있나요?"

#### 5. CLAUDE.md 생성

`templates/workspace.md` 기반으로 생성

#### 6. living-docs 연동

`living-docs` 스킬을 사용하여 문서 폴더 초기화:
- 경로: `~/docs/pj--{project}/`
- `living-docs` 스킬의 폴더 구조 규칙 따름

### 워크플로우 2: 기존 워크스페이스 업데이트

사용자가 "CLAUDE.md 업데이트", "저장소 추가됨" 요청 시:

1. 현재 CLAUDE.md 읽기
2. 저장소 변경 감지
3. 변경 사항 반영 (새 저장소 추가, 제거된 저장소 삭제)
4. 사용자 확인 후 저장

## CLAUDE.md 구성 요소

### 필수 섹션

1. **프로젝트 개요** - 한 줄 설명
2. **저장소 구조** - 테이블 (저장소, 설명, GitHub)
3. **저장소별 상세** - 기술 스택, 포트, 명령어
4. **작업 규칙** - 브랜치 정책, Git 규칙
5. **문서화** - living-docs 연동 (`~/docs/pj--{project}/`)

### 선택 섹션

- **저장소 간 연동** - API → Frontend codegen 등

## 작업 규칙 기본값

```markdown
## 작업 규칙

- **main 브랜치에 직접 커밋 금지** - 반드시 feature 브랜치에서 작업 후 PR로 병합
- 각 저장소는 독립적인 브랜치와 PR로 관리
- 커밋 전 린트/테스트 통과 필수

### 브랜치 상태 감지

- `origin/<branch>` 존재 여부로 push 상태 판단

### Git 명령 실행

- mise 환경이 필요한 저장소에서는 `mise exec -- git commit` 형식으로 실행
```

## 중요 원칙

1. **저장소 자동 탐색**: git remote로 저장소 정보 자동 수집
2. **사용자 확인**: 주요 결정은 사용자에게 확인
3. **living-docs 연동**: 문서 관리는 `living-docs` 스킬에 위임
4. **간결함 유지**: 필수 정보만, 상세 내용은 각 저장소 README 참조

## Examples

### 예시 1: 새 워크스페이스 초기화

User: "이 폴더에 CLAUDE.md 초기화해줘"
Assistant:
1. 현재 위치 확인 (`~/pj/myapp/`)
2. 저장소 탐색 (myapp-api, myapp-web 발견)
3. 각 저장소 정보 수집
4. 사용자와 대화 (설명, 연동 관계)
5. CLAUDE.md 생성
6. `living-docs` 스킬로 문서 폴더 초기화 제안

## Technical Details

템플릿은 `templates/workspace.md` 참조
