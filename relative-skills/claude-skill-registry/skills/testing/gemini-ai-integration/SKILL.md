---
name: gemini-ai-integration
description: Integrate Google Gemini API for AI-powered QA checklist generation and structured output. Use when working with Gemini API calls, generating QA checklists from design specs, parsing AI responses, or implementing structured output with JSON schema.
---

# Gemini AI Integration

Google Gemini API를 활용한 AI 기반 QA 체크리스트 생성 및 구조화된 출력 처리 스킬입니다.

## Quick Reference

### API 설정
```typescript
import { GoogleGenAI, Type } from '@google/genai';

const ai = new GoogleGenAI({
  apiKey: process.env.NEXT_PUBLIC_GEMINI_API_KEY
});
```

### 권장 모델
- `gemini-2.0-flash` - 빠른 응답, 일반 작업
- `gemini-2.5-pro` - 복잡한 추론, 높은 정확도

## Contents

- [reference.md](reference.md) - Gemini 구조화 출력 베스트 프랙티스
- [guide.md](guide.md) - QA 체크리스트 생성 프롬프트 가이드
- [scripts/generate_checklist.py](scripts/generate_checklist.py) - 체크리스트 생성 스크립트
- [scripts/validate_response.py](scripts/validate_response.py) - 응답 검증 유틸리티

## When to Use

- Gemini API로 구조화된 출력 생성 시
- 디자인 스펙에서 QA 체크리스트 자동 생성 시
- AI 응답 파싱 및 검증 로직 작성 시
- 프롬프트 엔지니어링 및 스키마 설계 시
