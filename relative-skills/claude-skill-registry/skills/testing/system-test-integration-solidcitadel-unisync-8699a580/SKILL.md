---
name: system-test-integration
description: System 테스트 작성 및 실행. pytest 기반, docker-compose.acceptance.yml 필수, 4단계 순서(infra→component→integration→scenarios). 네이밍 test_{대상}_{시나리오}_{예상결과}. poetry run pytest system-tests/ 실행. Fail Fast - 모든 응답 필드/타입/에러 엄격 검증, 예상외 필드/부작용은 실패 처리.
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
---

# System 테스트 작성 및 실행

## 참조 문서
- **필수**: [docs/design/testing-strategy.md](../../../docs/design/testing-strategy.md)
- **SQS**: [docs/design/sqs-architecture.md](../../../docs/design/sqs-architecture.md)

## 전제 조건

**모든 System Tests 실행 전 필수**:
```bash
docker-compose -f docker-compose.acceptance.yml up -d
```

## 폴더 구조 및 4단계

```
system-tests/
├── conftest.py                    # 공통 fixtures + 실행 순서 강제
├── infra/                         # 1단계: 인프라 검증
│   └── test_infrastructure.py
├── component/                     # 2단계: 개별 서비스 API
│   ├── user_service/
│   ├── course_service/
│   └── schedule_service/
├── integration/                   # 3단계: 서비스 간 연동
│   ├── user_to_lambda/
│   ├── lambda_to_course/
│   └── course_to_schedule/
└── scenarios/                     # 4단계: E2E 시나리오
    └── test_full_user_journey.py
```

## 4단계별 가이드

### 1단계: Infra Tests
**목적**: 인프라 정상 동작 확인

**검증 대상**:
- LocalStack (SQS, Lambda, S3)
- MySQL 연결
- 서비스 Health Check
- SQS 큐 존재

**예시**:
```python
def test_localstack_is_healthy():
    """LocalStack이 정상 동작하는지 확인"""
    response = requests.get(f"{LOCALSTACK_URL}/_localstack/health")
    assert response.status_code == 200
```

### 2단계: Component Tests
**목적**: 각 서비스 API 개별 검증

**검증 대상**:
- REST API 정상 응답
- CRUD 동작
- 인증/인가

**예시**:
```python
# system-tests/component/schedule_service/test_schedule_api.py
def test_create_schedule_with_valid_data_returns_201():
    """일정 생성 API가 201을 반환하는지 확인"""
    response = requests.post(
        f"{SCHEDULE_SERVICE_URL}/v1/schedules",
        headers={"X-Cognito-Sub": "test-user"},
        json={
            "title": "Test Schedule",
            "startTime": "2025-01-01T10:00:00",
            "endTime": "2025-01-01T11:00:00",
            "source": "USER",
            "categoryId": 1
        }
    )
    assert response.status_code == 201
```

### 3단계: Integration Tests
**목적**: 서비스 간 1:1 연동 검증

**폴더 네이밍**: `{producer}_to_{consumer}/`

**검증 대상**:
- SQS 메시지 발행 → 수신 → 처리
- API 호출 체인
- 데이터 변환

**예시**:
```python
# system-tests/integration/course_to_schedule/test_assignment_to_schedule.py
def test_assignment_created_event_creates_schedule():
    """Assignment 생성 이벤트가 Schedule을 생성하는지 확인"""
    # Arrange
    assignment_event = {
        "eventType": "ASSIGNMENT_CREATED",
        "canvasAssignmentId": 12345,
        "name": "Homework 1",
        "dueAt": "2025-01-15T23:59:59Z"
    }

    # Act
    sqs_client.send_message(
        QueueUrl=ASSIGNMENT_QUEUE_URL,
        MessageBody=json.dumps(assignment_event)
    )
    time.sleep(10)  # 처리 대기

    # Assert
    response = requests.get(
        f"{SCHEDULE_SERVICE_URL}/v1/schedules",
        headers={"X-Cognito-Sub": "test-user"}
    )
    assert response.status_code == 200
    schedules = response.json()
    assert len(schedules) == 1
    assert schedules[0]["title"] == "Homework 1"
```

### 4단계: Scenario Tests
**목적**: 전체 E2E 사용자 플로우

**핵심 원칙**:
- **DB 직접 조작 금지**: DB fixture (`mysql_connection`, `schedule_db_connection` 등) 사용 금지. 모든 데이터는 API를 통해서만 생성/조회/검증
- **Gateway 엔드포인트만 사용**: 프론트엔드가 실제로 호출할 수 있는 API Gateway를 통한 엔드포인트만 사용 (내부 서비스 직접 호출 금지)
- **실제 사용자 플로우**: 사용자가 UI에서 수행하는 동작과 동일한 순서로 테스트

**검증 대상**:
- 회원가입 → 토큰 등록 → 동기화 → 일정 조회
- 실제 사용자 시나리오 전체

**예시**:
```python
# system-tests/scenarios/test_full_user_journey.py
def test_complete_canvas_sync_flow():
    """
    전체 Canvas 동기화 플로우 검증
    1. 회원가입
    2. Canvas 토큰 등록
    3. 수동 동기화 실행
    4. Course 데이터 확인
    5. Schedule 데이터 확인
    """
    # 1. 회원가입
    user = create_test_user()

    # 2. Canvas 토큰 등록
    register_canvas_token(user, VALID_TOKEN)

    # 3. 수동 동기화
    trigger_manual_sync(user)

    # 4. Course 확인
    courses = get_user_courses(user)
    assert len(courses) > 0

    # 5. Schedule 확인
    schedules = get_user_schedules(user)
    assert len(schedules) > 0
```

## 네이밍 규칙

**형식**: `test_{대상}_{시나리오}_{예상결과}`

```python
# ✅ Good
def test_schedule_api_with_valid_request_returns_201():
    pass

def test_assignment_event_with_duplicate_id_skips_creation():
    pass

# ❌ Bad
def test_1():
    pass

def test_schedule():  # 시나리오/결과 누락
    pass
```

## AAA 패턴 (Arrange-Act-Assert)

```python
def test_assignment_to_schedule_conversion():
    # Arrange (준비)
    assignment_event = create_test_assignment_event()

    # Act (실행)
    sqs_client.send_message(...)
    time.sleep(10)
    response = requests.get(...)

    # Assert (검증)
    assert response.status_code == 200
    assert len(response.json()) == 1
```

## 엄격한 검증 원칙 (Strict Validation)

**핵심**: 예상치 못한 모든 결과는 실패로 처리. 검증 생략 금지.

### ❌ 나쁜 예: 상태 코드만 확인

```python
def test_create_schedule_bad():
    response = requests.post(...)
    # 상태 코드만 확인하고 응답 본문은 검증 안함
    assert response.status_code == 201
```

### ✅ 좋은 예: 모든 필드 및 예상치 못한 필드 검증

```python
def test_create_schedule_with_valid_data_returns_complete_response():
    response = requests.post(
        f"{SCHEDULE_SERVICE_URL}/v1/schedules",
        headers={"X-Cognito-Sub": "test-user-123"},
        json={
            "title": "Test Schedule",
            "startTime": "2025-01-01T10:00:00Z",
            "endTime": "2025-01-01T11:00:00Z",
            "source": "USER",
            "categoryId": 1
        }
    )

    # 1. 상태 코드 검증
    assert response.status_code == 201

    # 2. 응답 본문 존재 검증
    data = response.json()
    assert data is not None

    # 3. 모든 필수 필드 존재 및 타입 검증
    assert "id" in data
    assert isinstance(data["id"], int)
    assert data["id"] > 0

    assert "title" in data
    assert data["title"] == "Test Schedule"

    assert "startTime" in data
    assert data["startTime"] == "2025-01-01T10:00:00Z"

    assert "endTime" in data
    assert data["endTime"] == "2025-01-01T11:00:00Z"

    assert "source" in data
    assert data["source"] == "USER"

    assert "categoryId" in data
    assert data["categoryId"] == 1

    # 4. 예상치 못한 필드 발견 시 실패
    expected_fields = {"id", "title", "startTime", "endTime", "source", "categoryId", "createdAt", "updatedAt"}
    actual_fields = set(data.keys())
    unexpected_fields = actual_fields - expected_fields
    assert len(unexpected_fields) == 0, f"Unexpected fields found: {unexpected_fields}"
```

### ❌ 나쁜 예: 에러 상태만 확인

```python
def test_create_schedule_with_missing_field_bad():
    response = requests.post(..., json={"title": "Test"})
    # 에러만 확인하고 구체적인 에러 메시지는 검증 안함
    assert response.status_code == 400
```

### ✅ 좋은 예: 에러 응답 및 부작용 검증

```python
def test_create_schedule_with_missing_start_time_returns_detailed_error():
    response = requests.post(
        f"{SCHEDULE_SERVICE_URL}/v1/schedules",
        headers={"X-Cognito-Sub": "test-user"},
        json={
            "title": "Test",
            # startTime 누락
            "endTime": "2025-01-01T11:00:00Z",
            "source": "USER",
            "categoryId": 1
        }
    )

    # 1. 에러 상태 코드 검증
    assert response.status_code == 400

    # 2. 에러 응답 형식 검증
    error_data = response.json()
    assert "error" in error_data
    assert "message" in error_data
    assert "field" in error_data

    # 3. 에러 메시지 구체성 검증
    assert error_data["field"] == "startTime"
    assert "required" in error_data["message"].lower() or "missing" in error_data["message"].lower()

    # 4. 예상치 못한 부작용 검증 (DB에 저장되지 않았는지)
    all_schedules = requests.get(
        f"{SCHEDULE_SERVICE_URL}/v1/schedules",
        headers={"X-Cognito-Sub": "test-user"}
    ).json()
    assert len(all_schedules) == 0, "Failed request should not create any data"
```

### 핵심 검증 항목

1. **모든 응답 필드 검증**: 상태 코드 + 본문 모든 필드 + 타입
2. **예상치 못한 필드 감지**: API 계약 외 필드 추가 시 실패
3. **에러 응답 구체성 검증**: 에러 메시지, 필드명, actionable 정보
4. **부작용 검증**: 실패 시 DB 저장/변경 없는지 확인
5. **불변성 검증**: PATCH 요청 시 변경하지 않아야 할 필드 유지 확인

**참고**: 상세한 예제는 [docs/design/testing-strategy.md](../../../docs/design/testing-strategy.md)의 "엄격한 검증 원칙" 섹션 참조

## 실행 명령

**중요**: 모든 pytest 명령어는 `poetry run`을 통해 실행

```bash
# 전체 실행 (순서 보장: infra → component → integration → scenarios)
poetry run pytest system-tests/

# 개별 단계만 실행
poetry run pytest system-tests/infra/
poetry run pytest system-tests/component/
poetry run pytest system-tests/integration/
poetry run pytest system-tests/scenarios/

# 특정 통합 테스트만
poetry run pytest system-tests/integration/course_to_schedule/

# 상세 출력
poetry run pytest system-tests/ -v

# 특정 테스트만
poetry run pytest system-tests/component/schedule_service/test_schedule_api.py::test_create_schedule_with_valid_data_returns_201
```

## 체크리스트

### 작성 전
- [ ] docker-compose.acceptance.yml 실행 확인
- [ ] 테스트 단계 결정 (infra/component/integration/scenarios)
- [ ] 관련 SQS 큐 확인 (integration 테스트 시)

### 작성 중
- [ ] 네이밍: `test_{대상}_{시나리오}_{예상결과}`
- [ ] AAA 패턴 준수
- [ ] 비동기 처리 시 `time.sleep()` 추가
- [ ] **엄격한 검증**: 모든 응답 필드, 타입, 에러 메시지 검증
- [ ] **예상치 못한 필드 감지**: API 계약 외 필드 추가 시 실패
- [ ] **부작용 검증**: 실패 시 DB에 데이터 저장 안되었는지 확인

### 작성 후
- [ ] 실행: `poetry run pytest system-tests/`
- [ ] 모든 테스트 PASS 확인
- [ ] 테스트 순서 강제 확인 (conftest.py)

## 금지사항
- ❌ docker-compose 없이 System Tests 실행
- ❌ `pytest` 직접 실행 (`poetry run pytest` 사용)
- ❌ 테스트 간 데이터 공유
- ❌ 순서 의존적 테스트 (각 테스트는 독립적)
- ❌ **검증 생략**: 상태 코드만 확인하고 응답 본문 무시
- ❌ **에러만 확인**: 에러 타입만 보고 메시지/부작용 무시
- ❌ **상정외 동작 허용**: 예상치 못한 필드를 실패로 처리하지 않음
- ❌ **Scenario Tests에서 DB 직접 조작**: DB fixture 사용 금지, API Gateway를 통한 검증만 허용
- ❌ **Scenario Tests에서 내부 서비스 직접 호출**: 프론트엔드가 접근할 수 없는 엔드포인트 사용 금지

## 트러블슈팅

### 문제: 테스트가 순서대로 실행 안됨
**해결**: `conftest.py`의 `pytest_collection_modifyitems` 확인

### 문제: SQS 메시지 처리 안됨
**해결**:
1. LocalStack 상태 확인: `docker-compose -f docker-compose.acceptance.yml ps`
2. 큐 존재 확인: infra 테스트 실행
3. `time.sleep()` 증가 (10초 → 15초)

### 문제: MySQL 연결 실패
**해결**: 서비스 시작 대기 시간 증가 (docker-compose up 후 60초 대기)