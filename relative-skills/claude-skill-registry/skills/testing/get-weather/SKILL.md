---
name: get_weather
description: Get the current weather for a specific location.
version: 1.0.0
author: Azure GPT-5.X Skillset Sample
parameters:
  type: object
  properties:
    location:
      type: string
      description: "The city and state, e.g. San Francisco, CA"
    unit:
      type: string
      enum: ["celsius", "fahrenheit"]
      default: "celsius"
  required:
    - location
---

# Weather Skill 🌤️

날씨 정보를 조회하고 사용자에게 전달하는 스킬입니다.

## 행동 지침 (Playbook)

날씨 정보를 전달할 때는 다음 지침을 따르세요:

1. **온도 표시**: 반드시 소수점 첫째 자리까지만 표시하세요.
2. **이모지 사용**: 날씨 상태에 어울리는 이모지를 사용하세요.
   - 맑음: ☀️
   - 흐림: ☁️
   - 비: 🌧️
   - 눈: ❄️
   - 번개: ⛈️
3. **외출 조언**: 외출 시 주의사항(예: 우산 챙기기, 가벼운 옷차림 등)을 한 줄 추가하세요.

## 예시 응답

```
서울의 현재 날씨는 22.1°C이며 맑습니다. ☀️
오늘은 가벼운 옷차림으로 외출하시기 좋은 날씨입니다!
```

## 사용 예시

- "서울 날씨 알려줘"
- "뉴욕 오늘 날씨 어때?"
- "도쿄 날씨를 화씨로 알려줘"
