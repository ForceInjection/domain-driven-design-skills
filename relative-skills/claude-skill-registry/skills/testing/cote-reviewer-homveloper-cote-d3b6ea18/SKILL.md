---
name: cote-reviewer
description: When reviewing coding test solutions. This Skill reviews coding test solutions and provides feedback. it adds an evaluation section to the README.md file in the problem-solving folder, including areas for improvement, strengths, and other application ideas based on the provided template. Use this skill when user requests "코테 리뷰", "풀이 리뷰", "리뷰 작성", "리뷰를 작성해줘", "코드 리뷰", or any similar coding test review request.
---

# CoTe Reviewer

## Instructions

# IMPORTANT : '회고' 영역은 사용자가 직접 작성하는 곳입니다.

1. 코딩 테스트 문제 풀이를 제출하면, 코드를 검토합니다.
2. README.md 파일을 참고하여 기본적인 정보를 작성합니다.
   1. 문제명
   2. 문제 링크를 찾을 수 있으면 추가합니다.
   3. 문제 정보에 대한 태그를 추가합니다.
3. 문제 풀이 폴더에 있는 README.md 파일에 분석 내용을 추가합니다.
4. 파일 하단에 새로운 섹션을 추가하여 다음 항목들을 포함하여 평가를 작성합니다:
   - 개선할 점
   - 잘한 점
   - 다른 응용 방안
   - 다른 추천 문제 : 해당 문제와 유사하거나, 학습을 확장할 수 있는 문제를 추천합니다.
   - 종합 평가
5. 알고리즘 문제인 경우, 학습 자료로써 도움이 될 수 있는 개념 및 설명등의 추가 정보를 제공합니다.
  
- 자세한 사용 방법은 '_template/README.md' 파일의 '평가' 섹션을 참고하세요.
- 포함하는 항목들은 예시일뿐 해당 문제와 사용자의 풀이 방식에 따라 조정될 수 있습니다.
- 종합 평가는 별표나 점수 형식이 아닌 서술형으로 작성해주세요. 평가는 칭찬보다는 비판적이고 건설적인 피드백으로 코딩 테스트 학습자가 인사이트를 얻을 수 있도록 도와주세요.
- 피드백은 코딩 테스트 관점에서 작성해주세요.
- [IMPORTANT] 코테 풀이하면서 작성한 주석은 사용자가 문제를 풀면서 고민한 흔적이므로, 피드백 작성시 참고하여 반영해주세요.

## Examples
Show concrete examples of using this Skill.

### Example 1

**Input:**
```markdown
# [문제이름]
- [문제 링크](https://school.programmers.co.kr/learn/courses/30/lessons/49994)

... (rest of the README content) ...

# 평가

## 개선할 점

- 코드에 주석을 추가하여 각 부분의 역할을 명확히 설명하면 가독성이 향상될 것입니다.
- 변수명과 함수명을 더 직관적으로 변경하여 코드의 의도를 쉽게 파악할 수 있도록 하면 좋겠습니다.
- 예외 처리 및 경계 조건에 대한 테스트 케이스를 추가하여 코드의 견고성을 높일 수 있습니다.

## 잘한 점
- set 자료구조를 활용하여 중복 경로를 효과적으로 처리한 점이 매우 좋습니다.
- 함수에서 tuple을 반환하고 언패킹하는 방식을 사용하여 코드의 간결성을 높인 점이 인상적입니다.

# 추가 학습

- 좌표 이동 문제에서 방향 벡터를 활용하는 방법은 매우 유용한 기법입니다. 이를 통해 다양한 경로 탐색 문제에 적용할 수 있습니다.
```
