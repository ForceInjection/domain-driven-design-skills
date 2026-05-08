---
name: wbs-gantt-management
description: Implement WBS (Work Breakdown Structure) and Gantt chart functionality. Use when working with task scheduling, date range calculations, drag-and-drop timeline interactions, or project planning features.
---

# WBS Gantt Management

WBS(작업분해구조) 및 간트차트 기능 구현 스킬입니다.

## Quick Reference

### 날짜 계산
```typescript
// 두 날짜 사이 일수
const days = differenceInDays(endDate, startDate);

// 날짜 위치 (퍼센트)
const position = ((date - startDate) / (endDate - startDate)) * 100;
```

### 드래그 인터랙션
- **이동**: 전체 바 드래그 → 시작/종료일 동시 변경
- **리사이즈**: 좌/우 핸들 드래그 → 시작 또는 종료일만 변경

## Contents

- [reference.md](reference.md) - 간트차트 날짜 계산 및 렌더링 가이드
- [guide.md](guide.md) - 드래그 앤 드롭 인터랙션 패턴
- [scripts/validate_schedule.py](scripts/validate_schedule.py) - 스케줄 검증 유틸리티

## When to Use

- 간트차트 컴포넌트 개발 시
- 태스크 날짜 범위 계산 시
- 드래그로 태스크 이동/리사이즈 구현 시
- WBS 테이블과 타임라인 동기화 시
