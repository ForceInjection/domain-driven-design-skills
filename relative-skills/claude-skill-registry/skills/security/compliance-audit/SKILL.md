---
name: compliance-audit
description: 최종 규정 준수 검증 및 개선안 제시
tags: [archaeology, compliance, audit, final-check, pipeline-step-6]
---

# Compliance Audit - 규정 준수 최종 검증

## 목적
작성된 고찰 초안, 표, 부록, 참고문헌이 국가유산청 규정 체크리스트를 충족하는지 검증하고, 미흡한 부분에 대한 구체적인 보완 지침과 개선된 버전 2를 생성합니다.

## 입력
- `output/draft/discussion.md`: 고찰 초안
- `output/draft/tables.md`: 비교표 및 일람표
- `output/draft/appendix.md`: 부록
- `output/draft/references.md`: 참고문헌
- `output/compliance/checklist.md`: 규정 체크리스트
- `output/compliance/gaps.md`: 결손 항목 보고서

## 검증 프로세스

### 1단계: 체크리스트 항목별 검증

#### A. 보고서 전체 구성 검증
```python
def verify_report_structure(files):
    """보고서 필수 구성 요소 확인"""
    checklist = {
        'A. 행정사항': check_admin_info(files),
        'B. 조사 배경 및 경과': check_background(files),
        'C. 유적의 입지 및 환경': check_location(files),
        'D. 역사적 배경': check_history(files),
        'E. 조사 내용': check_excavation(files),
        'F. 과학적 분석': check_scientific(files),
        'G. 도면 및 사진': check_drawings(files),
        'H. 고찰': check_discussion(files),  # ⭐ 주요 검증 대상
        'I. 결론': check_conclusion(files),
        'J. 부록': check_appendix(files)
    }
    return checklist
```

#### B. 고찰 섹션 세부 검증
```markdown
## 고찰(考察) 8개 필수 구성 요소 검증

### H1. 조사 성과 종합 ✓ / ⚠ / ✗
- [✓] 유구 종류와 수량 요약 존재
- [✓] 유물 종류와 수량 요약 존재
- [⚠] 주요 발견사항 강조 (3개 이상 권장, 현재 2개)
- [✓] 조사 한계 언급

**개선 제안**:
- 주요 발견사항 1개 추가: "마제석검 출토로 사회 계층화 추정"

### H2. 유구의 성격 및 기능 해석 ✓
- [✓] 유구 종류별 소제목 구분
- [✓] 평면·단면 형태 기술
- [✓] 도면 번호 명시 (15개 도면 언급)
- [✓] 공간 배치 패턴 분석

### H3. 유물의 편년 및 계통 ⚠
- [✓] 형식 분류 명확
- [✓] 절대연대 자료 제시 (C14 1건)
- [⚠] 형태적 계통 분석 (토기만 있고 석기 부족)
- [✗] 원료 산지 분석 (석재 산지 언급 없음)

**개선 제안**:
- 석기 형태 계통 분석 1문단 추가 (주변 유적과 비교)
- 석재 산지 추정 문장 삽입: "석재는 [산지명] 산출 ○○암으로 추정됨 (육안 관찰)"

### H4. 주변 유적과의 비교 분석 ✓ 우수
- [✓] 비교 대상 10개 유적 선정
- [✓] 공간 분포 비교 (지도 포함)
- [✓] 시대 동시성 검토
- [✓] 유구·유물 형태 비교
- [✓] 공통점과 차이점 도출
- [✓] 지역 간 교류 증거 제시

**특기사항**: 본 항목은 similarity-matcher 스킬 덕분에 우수한 수준

### H5. 공간 구조 및 취락 구조 해석 ✓
- [✓] 전체 공간 구성 원리 (환상 배치)
- [✓] 중심-주변 구조
- [⚠] 인구 추정 (언급 없음, 권장 사항)

**개선 제안**:
- 인구 추정 문장 추가: "주거지 12기를 기준으로 1가구 5인 가정 시 약 60명 규모 추정"

### H6. 역사·고고학적 의의 ✓
- [✓] 지역 고고학 연구사 위치
- [✓] 새로운 발견 강조
- [⚠] 문헌 기록 대조 (해당 자료 부족)
- [✓] 한국 고고학 기여

### H7. 보존 및 활용 방안 ✓
- [✓] 보존 상태 평가
- [✓] 보존 방안 제안
- [✓] 활용 방안 구체적

### H8. 향후 과제 및 제언 ✓
- [✓] 미해결 문제 제시
- [✓] 추가 조사 필요 영역
- [✓] 후속 연구 방향
```

### 2단계: 수치 기준 검증

```python
def verify_quantitative_criteria(discussion, tables, references):
    """정량적 기준 충족 여부 검증"""
    criteria = {
        '전체 분량': {
            'required': '30~50쪽',
            'current': f'{count_pages(discussion)}쪽',
            'pass': 30 <= count_pages(discussion) <= 50
        },
        '본문 인용 수': {
            'required': '최소 50개',
            'current': f'{count_citations(discussion)}개',
            'pass': count_citations(discussion) >= 50
        },
        '표 개수': {
            'required': '최소 5개',
            'current': f'{count_tables(tables)}개',
            'pass': count_tables(tables) >= 5
        },
        '도면 언급': {
            'required': '최소 10개',
            'current': f'{count_drawing_refs(discussion)}개',
            'pass': count_drawing_refs(discussion) >= 10
        },
        '주변 유적 비교': {
            'required': '최소 5개 유적',
            'current': f'{count_compared_sites(discussion)}개',
            'pass': count_compared_sites(discussion) >= 5
        },
        '참고문헌 수': {
            'required': '최소 30개',
            'current': f'{count_references(references)}개',
            'pass': count_references(references) >= 30
        },
        '영문 초록': {
            'required': '200~300단어',
            'current': f'{count_words(abstract_en)}단어',
            'pass': 200 <= count_words(abstract_en) <= 300
        }
    }
    return criteria
```

### 3단계: 내용 품질 검증

#### 3-1. 인용 무결성 검증
```python
def verify_citation_integrity(discussion, references):
    """본문 인용과 참고문헌 일치 확인"""
    citations_in_text = extract_citations(discussion)  # [저자(연도)]
    references_list = parse_references(references)

    orphan_citations = []  # 본문에는 있으나 참고문헌에 없음
    unused_references = []  # 참고문헌에는 있으나 본문에서 미인용

    for cite in citations_in_text:
        if cite not in references_list:
            orphan_citations.append(cite)

    for ref in references_list:
        if ref not in citations_in_text:
            unused_references.append(ref)

    return {
        'orphan': orphan_citations,
        'unused': unused_references,
        'integrity': len(orphan_citations) == 0
    }
```

**검증 결과 예시**:
```markdown
### 인용 무결성 검증 결과

✗ **불일치 발견**:

**본문에서 인용되었으나 참고문헌에 없음** (3건):
1. [이철수(2021)] - discussion.md 15페이지
2. [박영희(2019)] - discussion.md 28페이지
3. [Kim et al.(2020)] - discussion.md 42페이지

**참고문헌에는 있으나 본문에서 미인용** (2건):
1. 정민수(2018) - 삭제 또는 본문에 인용 추가 권장
2. ○○연구원(2017) - 삭제 또는 본문에 인용 추가 권장

**조치 방안**:
- 본문 미인용 3건에 대한 전체 서지정보를 참고문헌에 추가
- 미사용 참고문헌 2건은 삭제 (또는 본문에 관련 문장 추가)
```

#### 3-2. 도면·사진 참조 검증
```python
def verify_figure_references(discussion, appendix):
    """본문의 도면·사진 언급과 부록 목록 일치 확인"""
    figures_in_text = extract_figure_refs(discussion)  # [도면 3], [사진 12]
    figures_in_appendix = parse_appendix(appendix)

    missing = [f for f in figures_in_text if f not in figures_in_appendix]
    return {
        'missing': missing,
        'complete': len(missing) == 0
    }
```

#### 3-3. 논리 일관성 검증
```python
def verify_logical_consistency(discussion):
    """논리적 모순 또는 상충 검증"""
    issues = []

    # 연대 일관성
    if mentions_period('청동기 전기', discussion):
        if mentions_artifact('철기', same_context=True):
            issues.append({
                'type': '연대 모순',
                'detail': '청동기 전기 맥락에서 철기 언급',
                'severity': '높음'
            })

    # 수량 일관성
    intro_count = extract_feature_count(discussion, section='서론')
    detail_count = extract_feature_count(discussion, section='유구 분석')
    if intro_count != detail_count:
        issues.append({
            'type': '수량 불일치',
            'detail': f'서론 {intro_count}기 vs 상세 {detail_count}기',
            'severity': '중간'
        })

    return issues
```

### 4단계: 개선안 생성 (Version 2)

누락·미흡 항목에 대한 보완 내용을 자동 생성:

```python
def generate_improvements(audit_results):
    """검증 결과 기반 개선안 생성"""
    improvements = []

    # 예: 석재 산지 분석 누락
    if audit_results['H3']['원료 산지'] == False:
        improvements.append({
            'section': 'III. 유물의 편년 및 계통 > 2. 석기',
            'position': 'after "석재는 혈암과 셰일이 대부분으로,"',
            'insert': """
[산지명] 일대에서 산출되는 석재와 육안 특징이 유사하여,
인근에서 원료를 조달했을 가능성이 높다. 향후 암석학적 성분 분석을
통한 정확한 산지 추정이 필요하다 [관련 연구(연도)].
            """
        })

    # 예: 인구 추정 누락
    if '인구' not in audit_results['H5']:
        improvements.append({
            'section': 'V. 공간 구조 및 취락 구조 해석',
            'position': 'end of section',
            'insert': """
본 취락의 인구 규모는 주거지 12기를 기준으로, 1기당 1가구(평균 5인)
가정 시 약 60명으로 추정된다. 이는 [비교 유적명]의 인구 밀도와
유사하며 [근거 문헌(연도)], 청동기시대 중소 규모 취락에 해당한다.
            """
        })

    return improvements
```

## 출력

### output/final/discussion_v2.md
개선 사항을 반영한 최종 고찰 버전 2:
```markdown
# 고찰(考察) - Version 2

[모든 개선 사항 반영]

---
**변경 이력**:
- 2025-11-12: Version 1 생성 (discussion-drafter)
- 2025-11-12: Version 2 생성 (compliance-audit)
  - H3: 석재 산지 추정 문장 추가
  - H5: 인구 규모 추정 문단 추가
  - 인용 3건 참고문헌 추가
  - 도면 참조 오류 2건 수정
```

### output/final/compliance_report.md
최종 규정 준수 검증 보고서:
```markdown
# 국가유산청 규정 준수 검증 보고서

**검증일**: 2025-11-12
**대상**: ○○지구 유적 발굴조사 보고서 고찰 섹션
**검증 기준**: 발굴조사의 방법 및 절차 등에 관한 규정

---

## 종합 평가

### 준수율
- **전체**: 92% (68개 항목 중 63개 충족)
- **고찰 섹션**: 95% (40개 항목 중 38개 충족)
- **정량 기준**: 100% (7개 기준 모두 충족)

### 등급: **우수** ⭐⭐⭐⭐

---

## 항목별 검증 결과

### ✓ 충족 항목 (63개)
[상세 목록...]

### ⚠ 미흡 항목 (3개) - Version 2에서 보완 완료
1. H3. 유물 편년 및 계통 > 원료 산지 분석
   - **Version 1**: 언급 없음
   - **Version 2**: 석재 산지 추정 문장 추가 ✓

2. H5. 공간 구조 > 인구 추정
   - **Version 1**: 언급 없음
   - **Version 2**: 인구 약 60명 추정 문단 추가 ✓

3. 인용 무결성 > 참고문헌 누락
   - **Version 1**: 3건 누락
   - **Version 2**: 모두 추가 ✓

### ✗ 누락 항목 (2개) - 자료 부족으로 불가피
1. F1. 방사성탄소연대측정 (C14)
   - **현황**: 1건만 확보 (권장: 3건 이상)
   - **조치**: 고찰에 "추가 분석 필요성" 명시로 대체
   - **등급**: 허용 가능 ✓

2. F2~F6. 기타 과학적 분석 (토양, 식물유체 등)
   - **현황**: 미실시
   - **조치**: 향후 과제에 포함
   - **등급**: 선택 항목으로 문제없음 ✓

---

## 정량 기준 검증

| 항목 | 필요 | 실제 | 충족 | 비고 |
|------|------|------|------|------|
| 전체 분량 | 30~50쪽 | 42쪽 | ✓ | 적정 |
| 본문 인용 | ≥50개 | 68개 | ✓ | 우수 |
| 표 개수 | ≥5개 | 7개 | ✓ | |
| 도면 언급 | ≥10개 | 15개 | ✓ | |
| 주변 유적 비교 | ≥5개 | 10개 | ✓ | 우수 |
| 참고문헌 | ≥30개 | 42개 | ✓ | |
| 영문 초록 | 200~300단어 | 256단어 | ✓ | |

---

## 내용 품질 평가

### 논리 일관성: ✓ 문제없음
- 연대 모순 없음
- 수량 일치
- 공간 관계 일관성 유지

### 학술적 엄밀성: ✓ 우수
- 근거 제시 명확
- 추론 과정 논리적
- 한계 솔직히 인정

### 가독성: ✓ 양호
- 문장 명확
- 단락 구성 적절
- 전문 용어와 일반 언어 균형

---

## 최종 의견

본 고찰은 국가유산청 규정을 **충실히 준수**하며, 학술적 수준이 높습니다.
특히 주변 유적과의 비교 분석이 체계적이고 상세하여, 지역 취락 고고학
연구에 중요한 기여를 할 것으로 판단됩니다.

**승인 의견**: 본 고찰은 발굴조사 보고서 발간에 적합합니다.

**권고 사항**:
1. 향후 보고서 본편 작성 시 도면·사진 실물 확보 필수
2. 추가 C14 분석 시도 권장 (예산 허용 시)
3. 영문 초록을 원어민 검수 권장
```

### output/final/change_log.md
Version 1 → Version 2 변경 이력:
```markdown
# 변경 이력 (Change Log)

## Version 1 → Version 2 (2025-11-12)

### 추가된 내용

**1. III. 유물의 편년 및 계통 > 2. 석기 (25페이지)**
```diff
석기는 석촉(12점), 석도(5점), 마제석검(1점) 등이 출토되었다.
석촉은 이등변삼각형 유경식이 주를 이루며, [지역명] 일대에서 흔히
보이는 형식이다 [박○○(2019)]. 석재는 혈암과 셰일이 대부분으로,
+ [산지명] 일대에서 산출되는 석재와 육안 특징이 유사하여,
+ 인근에서 원료를 조달했을 가능성이 높다. 향후 암석학적 성분 분석을
+ 통한 정확한 산지 추정이 필요하다 [이○○(2016)].
```

**2. V. 공간 구조 및 취락 구조 해석 (33페이지 끝)**
```diff
+ 본 취락의 인구 규모는 주거지 12기를 기준으로, 1기당 1가구(평균 5인)
+ 가정 시 약 60명으로 추정된다. 이는 △△유적의 인구 밀도와 유사하며
+ [최○○(2017)], 청동기시대 중소 규모 취락에 해당한다.
```

**3. I. 서론 (3페이지)**
```diff
주요 발견사항은 다음과 같다:
1. [발견사항 1]: ...
2. [발견사항 2]: ...
+ 3. 마제석검 출토: 사회적 계층화 또는 지도층 존재 시사
```

### 수정된 내용

**4. 참고문헌 (48페이지)**
- 추가: 이○○(2016), 최○○(2017), 김△△(2020) 3건
- 삭제: 정민수(2018), ○○연구원(2017) 2건 (본문 미인용)

**5. 도면 참조 수정**
- 25페이지: [도면 12] → [도면 15] (석기 실측도 정확한 번호)
- 38페이지: [사진 8] → [사진 18] (H-05 주거지 사진)

---

## 통계

- **추가 분량**: +0.8쪽 (41.2→42.0쪽)
- **추가 인용**: +3건 (65→68건)
- **수정 위치**: 5개 섹션
```

## 실행 프로세스

```python
def run_compliance_audit():
    """전체 검증 및 개선 프로세스 실행"""

    # 1. 파일 로드
    discussion = load_md('output/draft/discussion.md')
    tables = load_md('output/draft/tables.md')
    appendix = load_md('output/draft/appendix.md')
    references = load_md('output/draft/references.md')
    checklist = load_md('output/compliance/checklist.md')

    # 2. 체크리스트 검증
    structure_check = verify_report_structure(...)
    discussion_check = verify_discussion_sections(discussion)

    # 3. 정량 검증
    quant_check = verify_quantitative_criteria(...)

    # 4. 품질 검증
    citation_check = verify_citation_integrity(discussion, references)
    figure_check = verify_figure_references(discussion, appendix)
    logic_check = verify_logical_consistency(discussion)

    # 5. 개선안 생성
    audit_results = combine_all_checks(...)
    improvements = generate_improvements(audit_results)

    # 6. Version 2 생성
    discussion_v2 = apply_improvements(discussion, improvements)

    # 7. 보고서 작성
    report = generate_compliance_report(audit_results)
    changelog = generate_change_log(discussion, discussion_v2)

    # 8. 저장
    save_md('output/final/discussion_v2.md', discussion_v2)
    save_md('output/final/compliance_report.md', report)
    save_md('output/final/change_log.md', changelog)

    # 9. 완료 메시지
    print("✓ 규정 준수 검증 완료!")
    print("✓ Version 2 생성 완료!")
    print(f"✓ 준수율: {audit_results['compliance_rate']}%")
    print("→ output/final/ 폴더에서 최종 결과 확인")
```

## 완료 후 조치
```
파이프라인 종료: 모든 스킬 완료

최종 산출물:
  - output/final/discussion_v2.md (고찰 최종본)
  - output/draft/tables.md (표)
  - output/draft/appendix.md (부록)
  - output/draft/references.md (참고문헌)
  - output/final/compliance_report.md (검증 보고서)
  - output/final/change_log.md (변경 이력)

다음 단계 (사용자 수동):
  1. 실물 도면·사진 확보 및 삽입
  2. 원어민 영문 초록 검수
  3. 보고서 본편 나머지 섹션 작성
  4. 전체 조판 및 인쇄
```

## 실행 명령
```
compliance-audit 스킬을 사용하여 고찰 및 부록의 규정 준수 여부를
검증하고, 개선된 버전 2를 생성해주세요.
```

## 고급 옵션

### 자동 교정 제안
```python
def suggest_corrections(discussion):
    """문법, 맞춤법, 어투 교정 제안"""
    # 한국어 맞춤법 검사 (py-hanspell)
    # 학술 어투 일관성 검사
    # 수동태/능동태 혼용 검사
    pass
```

### PDF 보고서 생성
```python
def generate_pdf_report(discussion_v2, tables, appendix, references):
    """최종 고찰을 PDF로 출력"""
    from fpdf import FPDF
    # 또는 pandoc + LaTeX 활용
    pass
```
