---
name: external-refs-skill
description: Skill with external file references for testing detection
---

# External References Skill

This skill contains external references that should be detected.

## Usage

Run the shared script:
```bash
node ../shared/common.js
python ~/scripts/process.py
bash /usr/local/bin/helper.sh
```

Reference files outside the skill:
- Config at ~/config/settings.json
- Data at /tmp/data.json
