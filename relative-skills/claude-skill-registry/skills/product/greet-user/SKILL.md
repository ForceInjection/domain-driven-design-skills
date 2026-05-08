---
name: greet_user
description: 템플릿을 사용하여 사용자에게 맞춤형 인사를 건넵니다.
parameters:
  - name: user_name
    type: string
    description: 인사할 사용자의 이름
    required: true
runtime: python
entrypoint: scripts/hello.py
allowed-tools: Read, Grep, Glob
---

## 스킬 설명

이 스킬은 `user_name`을 인자로 받아 `scripts/hello.py`를 실행합니다.
스크립트는 `templates/template.txt`의 `{{name}}` 부분을 `user_name`으로 교체하여 출력합니다.