---
name: living-docs
description: 프로젝트 지식과 할 일(TODO/todo)을 관리합니다. 문서 작성/업데이트, TODO 생성/완료, 의사결정 기록, 작업 현황 파악 시 사용하세요. (user)
---

# Living Docs

프로젝트의 지식과 실행 계획을 통합 관리하는 문서 시스템입니다.

## Instructions

### 프로젝트 자동 인식

**모든 워크플로우 시작 전에 프로젝트를 자동으로 확인합니다:**

1. **현재 경로에서 프로젝트명 추출**
   - `~/repos/{project}/...` 패턴에서 `{project}` 추출
   - 프로젝트명 정제: `_slot숫자` 제거, 끝 숫자 제거
   - 없으면 사용자에게 질문

2. **문서 디렉토리 확인 및 생성**
   - `~/docs/{project}/` 확인
   - 없으면 생성 제안: `mkdir -p ~/docs/{project}/{knowledge,decisions,todos}`

3. **사용자 확인**: "{project} 프로젝트 맞나요?"

### 문서 위치 및 파일명 규칙

모든 문서는 `~/docs/{project}/` 아래 저장 (knowledge/, decisions/, todos/, requirements/)

**파일명**: kebab-case, 2-4단어, Self-descriptive

상세 규칙: `REFERENCE.md` 참조

### 워크플로우 1: 지식 문서 업데이트

사용자가 "X 문서 업데이트" 요청 시:

**0. 프로젝트 확인 (위 "프로젝트 자동 인식" 절차에 따라 자동 수행)**

1. **문서 확인**
   ```bash
   Read ~/docs/{project}/knowledge/{category}/{topic}.md
   ```

2. **업데이트 유형 판단**
   사용자 요청과 변경 내용을 보고 둘 중 하나 선택:

   **경로 A: 간단한 수정** (오타, 내용 추가, 포맷 정리 등)
   - "어떤 내용을 업데이트할까요?" 물어보기
   - 내용 수정
   - `updated:` 필드만 갱신 (오늘 날짜)
   - 히스토리 생략 가능
   - 변경 사항 요약 후 완료

   **경로 B: 중요한 변경** (정책 변경, 아키텍처 수정, 설정 값 변경 등)
   - "어떤 내용을 업데이트할까요?"
   - "변경 이유를 알려주세요"
   - "영향받는 부분이나 관련 문서가 있나요?"
   - 필요시 추가 정보 요청
   - `updated:` 필드 갱신
   - "## 현재 상태" 섹션 업데이트
   - "## 히스토리" 섹션 최상단에 엔트리 추가:
     ```markdown
     ### YYYY-MM-DD: [변경 제목]
     **변경 내용:**
     - [구체적 변경사항]

     **이유:**
     - [변경 이유]

     **영향:**
     - 관련 문서: [[doc-id]]
     - 관련 TODO: [[todo-id]]

     ---
     ```
   - 관련 문서에 역참조 추가 제안
   - 필요시 TODO 생성 제안

3. **확인**
   - 변경 사항을 사용자에게 요약
   - 추가 업데이트 필요 여부 확인

4. **Git 커밋**
   ```bash
   cd ~/docs/{project} && git add knowledge/{category}/{topic}.md && git commit -m "docs(knowledge): update {category}/{topic} - {변경 요약}"
   ```

5. **자동 건강도 체크** (워크플로우 10)
   - 문서 크기 확인 (300+ 줄 시 분할 제안)
   - 중복 가능성 확인 (태그 80%+ 중복 시 병합 제안)
   - 이슈 발견 시 즉시 알림 및 리팩토링 제안

### 워크플로우 2: 의사결정 기록

사용자가 "X 결정 기록해줘" 요청 시:

1. **템플릿 사용**
   `templates/decision.md`를 기반으로 새 문서 생성

2. **사용자와 대화**
   - "어떤 결정을 했나요?"
   - "이유는 무엇인가요?"
   - "어떤 대안을 고려했나요?"
   - "어떤 영향이 있나요?"

3. **문서 생성**
   ```bash
   Write ~/docs/{project}/decisions/{slug}.md
   ```

   Frontmatter:
   - `id`: dec-{slug}
   - `decided`: 오늘 날짜
   - `impacts`: 영향받는 문서 ID 배열 (사용자에게 확인)

4. **관련 문서 업데이트**
   - 영향받는 문서들의 `references:` 에 이 결정 추가
   - 필요시 TODO 생성 제안

5. **Git 커밋**
   ```bash
   cd ~/docs/{project} && git add decisions/{slug}.md && git commit -m "docs(decision): add {slug}"
   ```

6. **자동 건강도 체크** (워크플로우 10)
   - 유사 결정 문서 중복 확인
   - 이슈 발견 시 알림

### 워크플로우 3: TODO 생성 및 관리

사용자가 "X 작업 TODO 만들어줘" 요청 시:

#### 1. 작업 분석 (복수 작업 감지)

사용자 요청에서 복수 작업 패턴 확인:
- 쉼표 분리: "A, B, C 구현"
- 접속사: "A와 B 작업", "A, B, 그리고 C"
- 나열: "1. A 2. B 3. C"
- 명시적 복수: "5개 리소스", "여러 컴포넌트"

#### 2. 분할 제안 (복수 감지 시)

사용자에게 확인:
```
다음 작업들을 각각 별도 TODO로 만들까요?
- {작업1-slug}.md
- {작업2-slug}.md
- {작업3-slug}.md

[1] 네, 각각 분할 (권장)
[2] 아니요, 하나로 통합
```

**Slug 생성 원칙 (Self-Descriptive)**:

1. **동사 구체화**: fix → correct/add/refactor/resolve
2. **명사 구체화**: types → nullable-field-types, auth → jwt-auth
3. **길이 허용**: 4-6 단어 OK (명확성 > 간결성)

**예시**:
- ❌ admin-api-fix-openapi-types
- ✅ admin-api-correct-openapi-nullable-field-types

- ❌ update-user-service
- ✅ add-email-verification-to-user-registration

**체크**: 파일명만 봐도 작업 내용 파악 가능한가?

#### 3. 작업 간 관계 확인 ([1] 선택 시)

"작업 간 순서가 있나요?"
- [1] 순차 (A → B → C): `depends-on` 체인 설정
- [2] 병렬 (동시 진행): 공통 태그만 추가

#### 4. 각 TODO 정보 수집

각 작업마다:
- "작업 내용을 설명해주세요"
- "완료 조건은 무엇인가요?"
- "관련 문서나 결정이 있나요?"
- "마감일이 있나요?"

#### 5. 문서 생성

**단일 작업** 또는 **[2] 선택 시**:
```bash
Write ~/docs/{project}/todos/{slug}.md
```

**복수 작업 분할** ([1] 선택 시):
```bash
# 병렬 작업
Write ~/docs/{project}/todos/{작업1-slug}.md  # depends-on: []
Write ~/docs/{project}/todos/{작업2-slug}.md  # depends-on: []
Write ~/docs/{project}/todos/{작업3-slug}.md  # depends-on: []

# 순차 작업
Write ~/docs/{project}/todos/{작업1-slug}.md  # depends-on: []
Write ~/docs/{project}/todos/{작업2-slug}.md  # depends-on: [todo-{작업1-slug}]
Write ~/docs/{project}/todos/{작업3-slug}.md  # depends-on: [todo-{작업2-slug}]
```

모든 TODO에 공통 태그 추가 (그룹 식별용)

#### 6. 관련 문서 링크

관련 지식/결정 문서에 역참조 추가

#### 7. Git 커밋

```bash
# 단일 TODO
cd ~/docs/{project} && git add todos/{slug}.md && git commit -m "docs(todo): add {slug}"

# 복수 TODO
cd ~/docs/{project} && git add todos/{작업*}.md && git commit -m "docs(todo): add {작업명} tasks ({count}개)"
```

#### 8. 자동 건강도 체크 (워크플로우 10)

- 중복 TODO 확인
- 이슈 발견 시 알림

### 워크플로우 4: 현황 파악

사용자가 "뭐 해야해?", "TODO 목록", "이번 주 할 일" 요청 시:

1. **Active TODO 파일 검색 (completed 제외)**
   ```bash
   Glob ~/docs/{project}/todos/*.md
   ```
   **주의**: `todos/*.md` 패턴은 `todos/completed/` 하위 파일은 제외

2. **각 파일 분석**
   - Read로 frontmatter만 빠르게 확인
   - `status:` 필드 확인 (pending, in-progress)

3. **필터링 및 정렬**
   - "이번 주" 요청 시: 이번 주 월요일~일요일 범위 deadline만
   - deadline이 가까운 순
   - priority 높은 것 우선

4. **사용자에게 리포트**
   ```
   현재 진행 중: 3개
   - [todo-002] {작업명} (마감: MM/DD, 우선순위: 높음)

   대기 중: 5개
   - [todo-007] {작업명} (마감: MM/DD)

   완료 (이번 달): 12개
   → todos/completed/YYYY-MM/ 참조
   ```

### 워크플로우 5: 지식 탐색 (Wiki 스타일)

사용자가 "X 관련 정보", "X 문서 찾아줘", "이 문서와 관련된 문서는?" 요청 시:

**핵심 원칙**: Read 최소화, Grep으로 후보 좁히기

1. **구조 파악**: lsd --tree로 전체 구조 확인
2. **인덱스 탐색**: Grep으로 키워드/태그/ID 검색
3. **검색 전략 선택**:
   - 키워드 검색
   - 연결 탐색 (Forward Links/Backlinks)
   - 태그 기반 탐색
   - 상태 기반 필터링
4. **상세 분석**: 필요한 문서만 Read
5. **종합 리포트**: 관련 문서/TODO/의사결정 제공

**상세 패턴**: `resources/knowledge-search-patterns.md` 참조

### 워크플로우 6: 새 문서 생성

사용자가 "X 문서 만들어줘" 요청 시:

1. **문서 유형 확인**
   - 지식 문서? → `templates/knowledge.md`
   - 의사결정? → `templates/decision.md`
   - TODO? → `templates/todo.md`

2. **사용자와 대화**
   - 카테고리 확인 (architecture, security 등)
   - 초기 내용 수집

3. **템플릿 기반 생성**
   적절한 위치에 파일 생성

4. **Git 커밋**
   ```bash
   cd ~/docs/{project} && git add {문서경로} && git commit -m "docs({유형}): add {slug}"
   ```

5. **자동 건강도 체크** (워크플로우 10)
   - 문서 크기 및 중복 확인
   - 이슈 발견 시 즉시 알림

### 워크플로우 7: 문서 병합 (중복 방지)

문서 생성/업데이트 후 유사 문서 확인:

1. **유사 문서 탐색**: 같은 카테고리, 키워드, 태그로 검색
2. **유사도 판단**: 태그 50%+ 겹침 → 병합 고려
3. **사용자 제안**: 병합 옵션 제시 (기존 문서 통합 / 새 문서 생성)
4. **병합 실행**:
   - 기존 문서 통합 또는 새 문서 생성
   - 히스토리 기록 (간결성 원칙: 3-5줄)
   - 참조 업데이트 (Grep으로 검색)
   - Git 커밋

### 워크플로우 8: Git 관리

모든 문서 변경 사항은 Git으로 추적합니다:
- 글로벌 규칙: `~/dots/prompts/rules/commit.md` 준수
- Living Docs 커밋 포맷: `REFERENCE.md` 참조
- 프로젝트 문서 디렉토리 생성 시 자동으로 Git 초기화 (저장소 없는 경우)

### 워크플로우 9: TODO 상태 관리 및 완료 처리

#### A. 상태 변경

사용자가 "X 작업 시작", "X 작업 진행 중", "X 작업 완료" 요청 시:

1. **TODO 파일 확인 및 상태 업데이트**
   - pending → in-progress: `status: in-progress` 설정
   - in-progress → done: `status: done` + `completed: YYYY-MM-DD` 설정

2. **히스토리 추가** (간결성 원칙 준수: 3-5줄)

#### B. 완료 후 처리

TODO가 `status: done`이 되면 **completed/ 디렉토리로 이동** (기본 동작):

**1단계: Completed로 이동 (필수)**

```bash
# 완료 월별 디렉토리 생성 (없는 경우)
mkdir -p ~/docs/{project}/todos/completed/YYYY-MM

# TODO 파일 이동
mv ~/docs/{project}/todos/{slug}.md \
   ~/docs/{project}/todos/completed/YYYY-MM/{slug}.md
```

완료 메시지: "✅ TODO [[todo-{slug}]] 완료 → `todos/completed/YYYY-MM/`로 이동"

**2단계: 추가 처리 (선택)**

사용자에게 선택지 제안:

**옵션 1: 이대로 보관 (기본, 빠름)**
- completed/에 보관하여 작업 히스토리 유지
- 나중에 회고, 참고 자료로 활용

**옵션 2: Knowledge로도 통합 (재사용 가치 있는 경우)**
1. Category 결정 (architecture, security, operations 등)
2. 관련 문서 찾기 (Grep, Glob로 검색)
3. 통합 가치 판단 (체크리스트)
4. 문서 업데이트 또는 신규 생성
5. completed/에는 그대로 유지 (삭제 안 함)

**상세 절차**: `resources/todo-completion-guide.md` 참조

**옵션 3: 삭제 (정말 불필요한 경우)**
- completed/에서도 제거
- Git 히스토리에만 남음

사용자 확인: "[1] 이대로 보관 (기본) / [2] Knowledge로도 통합 / [3] 삭제"

### 워크플로우 10: 문서 건강도 자동 체크

**실행 시점**:
- 워크플로우 1, 2, 3, 6 완료 후 자동 실행
- 사용자가 "찾기 힘들어", "중복", "문서 정리" 언급 시

**자동 체크 항목**:
- 문서 크기: 300+ 줄 → 분할 제안
- 중복 가능성: 태그 80%+ 중복 → 병합 제안
- 참조 건강도: 끊어진 링크, 고아 문서

**상세 로직**: `resources/health-check.md` 참조

### 워크플로우 11: Completed TODO 아카이브 (선택)

**실행 시점**: "오래된 TODO 정리", "completed 정리" 요청 시

**대상**: 6개월 이상 경과한 completed TODO

**옵션**:
1. 유지 (활발한 프로젝트)
2. Git 압축 후 삭제 (완료된 프로젝트)
3. 아카이브 디렉토리로 이동 (장기 프로젝트)

**상세 절차**: `resources/completed-archive-policy.md` 참조

### 워크플로우 12: 요구사항 문서 작성

사용자가 "X 요구사항 작성", "requirement 추가" 요청 시:

**0. 프로젝트 확인 (위 "프로젝트 자동 인식" 절차에 따라 자동 수행)**

1. **템플릿 사용**
   `templates/requirements.md`를 기반으로 새 문서 생성

2. **EARS 패턴 결정**
   사용자와 대화하여 적절한 패턴 선택:
   - "이 요구사항은 조건이 있나요? (상태/이벤트/기능)"
   - "항상 적용되는 요구사항인가요?"
   - "오류/예외 상황 처리인가요?"

   **패턴 선택 가이드**: `resources/ears-guide.md` 참조

3. **요구사항 정보 수집**
   - "어떤 시스템/컴포넌트에 대한 요구사항인가요?"
   - "시스템이 어떻게 동작해야 하나요?"
   - "수용 기준은 무엇인가요?"
   - "관련 결정이나 문서가 있나요?"

4. **EARS 문장 작성**
   선택한 패턴에 따라 요구사항 문장 구성:
   - Ubiquitous: "The {system} shall {response}."
   - State-Driven: "While {precondition}, the {system} shall {response}."
   - Event-Driven: "When {trigger}, the {system} shall {response}."
   - Optional Feature: "Where {feature}, the {system} shall {response}."
   - Unwanted Behavior: "If {condition}, then the {system} shall {response}."

5. **문서 생성**
   ```bash
   Write ~/docs/{project}/requirements/{category}/{slug}.md
   ```

   Frontmatter:
   - `id`: req-{category}-{slug}
   - `ears-pattern`: 선택한 패턴
   - `system`: 대상 시스템명
   - `status`: draft
   - `category`: functional | non-functional | constraint | interface

6. **관련 문서 링크**
   - 관련 결정/지식 문서에 역참조 추가 제안
   - 관련 요구사항이 있으면 depends-on 설정

7. **Git 커밋**
   ```bash
   cd ~/docs/{project} && git add requirements/{category}/{slug}.md && git commit -m "docs(requirement): add {category}/{slug}"
   ```

8. **자동 건강도 체크** (워크플로우 10)
   - 유사 요구사항 중복 확인
   - 충돌하는 요구사항 경고

### 워크플로우 13: 요구사항 상태 변경

사용자가 "X 요구사항 승인", "X 요구사항 구현 완료" 요청 시:

1. **요구사항 파일 확인 및 상태 업데이트**
   - draft → proposed: 검토 요청
   - proposed → approved: 승인
   - approved → implemented: 구현 완료
   - 모든 상태 → deprecated: 폐기

2. **히스토리 추가** (간결성 원칙: 3-5줄)

3. **연동 작업**
   - approved → implemented: 관련 `verified-by` TODO/테스트 상태 확인
   - deprecated: 영향받는 문서에 알림

4. **Git 커밋**
   ```bash
   cd ~/docs/{project} && git add requirements/{category}/{slug}.md && git commit -m "docs(requirement): update {slug} status to {status}"
   ```

### 워크플로우 14: 요구사항 검색 및 분석

사용자가 "요구사항 현황", "시스템별 요구사항", "미구현 요구사항" 요청 시:

1. **검색 기준 확인**
   - 시스템별: `system:` 필드로 필터링
   - 상태별: `status:` 필드로 필터링
   - 카테고리별: 디렉토리 또는 `category:` 필드
   - EARS 패턴별: `ears-pattern:` 필드

2. **Grep으로 필터링**
   ```bash
   # 상태별
   Grep "status: approved" ~/docs/{project}/requirements/**/*.md

   # 시스템별
   Grep "system: auth-service" ~/docs/{project}/requirements/**/*.md
   ```

3. **리포트 제공**
   ```
   요구사항 현황 ({project})

   상태별:
   - draft: 3개
   - proposed: 2개
   - approved: 5개 (구현 대기)
   - implemented: 12개
   - deprecated: 1개

   시스템별:
   - auth-service: 8개
   - payment-service: 6개

   우선순위별:
   - critical: 2개 (approved)
   - high: 4개
   ```

## 중요 원칙

1. **사용자 중심**: 항상 사용자에게 확인하고 대화하며 진행
2. **명확한 커뮤니케이션**: 변경 전 요약, 변경 후 확인
3. **일관성**: 모든 문서는 템플릿 구조 유지
4. **추적 가능성**: 히스토리와 참조를 통한 변경 추적
5. **단순함**: 복잡한 스크립트 대신 Claude의 판단 활용
6. **자동 건강도 관리**: 문서 작성 중 자동으로 정리 필요성 판단
7. **간결성**: 각 섹션은 핵심만 간결하게 작성 (상세: `resources/writing-guidelines.md`)

## Examples

### 지식 문서 업데이트
User: "{topic} 문서 업데이트" → 워크플로우 1 → 사용자 대화 → 히스토리 추가 (3-5줄) → Git 커밋

### TODO 현황 파악
User: "이번 주 할 일" → 워크플로우 4 → Glob + Read → 우선순위/마감일 정렬 → 리포트 제공

### 의사결정 기록
User: "{주제} 결정 기록" → 워크플로우 2 → 템플릿 기반 생성 → 사용자 대화 (이유, 대안, 영향) → 관련 문서 링크 → Git 커밋

### TODO 생성 (복수 분할)
User: "User, Post, Comment 리소스 구현해줘" → 워크플로우 3 → 복수 감지 → 분할 제안 → resource-user.md, resource-post.md, resource-comment.md 생성 → 공통 태그 추가

### TODO 완료 및 처리
User: "{task} 완료" → 워크플로우 9 → completed/로 이동 (필수) → 추가 처리 선택 ([1] 보관 / [2] Knowledge 통합 / [3] 삭제)

### 요구사항 작성
User: "로그인 요구사항 작성" → 워크플로우 12 → EARS 패턴 선택 → 사용자 대화 (시스템, 동작, 수용기준) → 문서 생성 → Git 커밋

### 요구사항 승인
User: "req-auth-login 승인" → 워크플로우 13 → status: approved → 히스토리 추가 → Git 커밋 → "구현 TODO 생성할까요?" 제안

## CLI Scripts

Living Docs는 자동화 스크립트를 제공합니다.

### 스크립트 위치

```
scripts/
├── living-docs           # 메인 CLI 진입점
├── todo-list.sh          # TODO 목록 조회
├── todo-archive.sh       # 완료된 TODO 아카이브
├── health-check.sh       # 문서 건강도 체크
└── lib/
    ├── frontmatter.sh    # YAML 파싱 라이브러리
    └── utils.sh          # 공통 유틸리티
```

### 사용법

```bash
# 현황 요약
living-docs

# TODO 목록 조회
living-docs list
living-docs list -s pending
living-docs list --priority urgent

# 완료된 TODO 아카이브
living-docs archive              # dry-run (미리보기)
living-docs archive --execute    # 실제 실행

# 문서 건강도 체크
living-docs health
living-docs health --quick       # 빠른 체크
living-docs health --full        # 전체 체크
```

### Proactive Triggers

다음 키워드 감지 시 스크립트 실행을 제안합니다:

| 키워드 | 스크립트 | 설명 |
|--------|----------|------|
| "TODO 목록", "할 일", "뭐 해야" | `living-docs list` | TODO 목록 조회 |
| "정리", "아카이브", "completed 정리" | `living-docs archive` | 완료된 TODO 정리 |
| "건강도", "문서 상태", "중복 확인" | `living-docs health` | 문서 건강도 체크 |

### 의존성

- `yq`: YAML frontmatter 파싱
- `rg` (ripgrep): 빠른 파일 검색
- `jq`: JSON 처리 (선택)

## Technical Details

상세한 템플릿 구조와 frontmatter 형식은 `REFERENCE.md`를 참조하세요.
