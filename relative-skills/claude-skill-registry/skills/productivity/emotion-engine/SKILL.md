---
name: emotion-engine
description: Manage emotion detection, LED responses, and mood-based automations for Ezra. Use when working on emotional regulation features, smart home responses, or the Chaos Orb.
allowed-tools: Read, Edit, Grep, Glob
---

# Emotion Engine Skill

## Emotion States
| State | Color | Response |
|-------|-------|----------|
| happy | orange | Energy quests, upbeat |
| calm | blue | Focus quests, peaceful |
| anxious | purple | Comfort, breathing exercises |
| frustrated | red | Break, encouragement |
| withdrawn | purple | Gentle engagement |
| peak | gold | Celebrate, challenge quests |
| distressed | red | Immediate support, alert parent |
| encouraged | green | Positive reinforcement |

## LED Color Mapping
```python
colors = {
    'happy': 'orange',
    'calm': 'blue',
    'anxious': 'purple',
    'frustrated': 'red',
    'withdrawn': 'purple',
    'peak': 'gold',
    'distressed': 'red',
    'encouraged': 'green'
}
```

## Response Rules

### Immediate Responses
1. Emotion change → LED color change (2 second transition)
2. Peak performance → Rainbow celebration + TTS

### Escalation Rules
1. Negative emotion → Support lights + optional TTS
2. Negative 30+ minutes → Alert parent via SMS
3. Distressed → Immediate parent alert

### Context Modifiers
- Morning + negative → Extra encouragement
- Bedtime + negative → Calming protocol (dim orange)
- Home alone + low energy → Gentle engagement
- With parent + frustrated → Let parent handle

## Chaos Orb (Daily Modifier)

Calculates 0.8x to 1.2x multiplier for XP:

```
Base: 1.0 (40%)
Mood Factor: confidence + valence (30%)
Moon Phase: new=0.9, full=1.1 (20%)
Streak Bonus: 0% streak=0.8, 100%=1.2 (10%)
Random Nudge: ±0.05
```

Runs daily at 6 AM via cron.

## Key Files
- ~/repos/phoenix-forge-ecosystem/9_Documentation/emotion_engine_rules.yaml
- ~/repos/phoenix-forge-ecosystem/2_SmartHome/scripts/chaos_orb.py

## Home Assistant Entities
- input_select.ezra_emotion
- input_number.daily_quest_count
- input_number.daily_xp_total
- input_number.current_streak
- light.ezra_room
