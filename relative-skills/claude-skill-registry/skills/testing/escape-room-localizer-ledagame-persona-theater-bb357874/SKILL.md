---
name: escape-room-localizer
description: Adapt escape room games for global markets (English, Korean, Japanese) with cultural considerations, efficient translation workflows, and language-agnostic design strategies. Handles multilingual template creation, cultural adaptation, and localization testing. Use when preparing games for international audiences or implementing multi-language support.
---

# Escape Room Localizer

## Overview

Transform single-language escape rooms into globally-accessible experiences through strategic localization, cultural adaptation, and efficient translation workflows.

## Target Markets

**Primary Markets**:
1. **English** (Global): Largest market, mandatory
2. **Korean** (한국어): Home market, narrative strength
3. **Japanese** (日本語): Adjacent market, escape room culture

**Expansion**: Chinese, Spanish, French (Phase 2)

## Localization Strategies

### Strategy 1: Language Toggle (Single Template)

**Best for**: MVP, testing, low maintenance

**Implementation**:
```
Page Structure:
┌─ 🌐 Select Language
│  ├─ [Toggle] 🇺🇸 English
│  │  └─ [All content in English]
│  ├─ [Toggle] 🇰🇷 한국어
│  │  └─ [한국어로 된 모든 콘텐츠]
│  └─ [Toggle] 🇯🇵 日本語
│     └─ [日本語のコンテンツ]
```

**Pros**:
- ✅ One template to maintain
- ✅ Easy updates (change once)
- ✅ Players can compare languages

**Cons**:
- ❌ Cluttered interface
- ❌ Spoilers visible across languages
- ❌ Larger file size

**Use when**: Quick international launch, frequent updates expected

### Strategy 2: Separate Templates (Multiple Versions)

**Best for**: Production, clean UX, market-specific

**Implementation**:
```
Notion Marketplace:
├─ "Mystery Office EN" ($4.99)
├─ "미스터리 오피스 KR" (₩5,500)
└─ "ミステリーオフィス JP" (¥550)
```

**Pros**:
- ✅ Clean player experience
- ✅ Market-specific pricing
- ✅ Cultural adaptations easier
- ✅ No cross-language spoilers

**Cons**:
- ❌ 3x maintenance work
- ❌ Updates must sync across versions
- ❌ Testing 3 separate templates

**Use when**: Post-MVP, established market, resource available

### Strategy 3: Hybrid (Recommended)

**Best for**: Balance of UX and maintenance

**Implementation**:
```
Act 1 (Free): Toggle method
├─ Players test language preference
└─ Decide before purchasing

Acts 2-5 (Paid): Separate templates
├─ Purchase chosen language only
└─ Clean focused experience
```

**Pros**:
- ✅ Free trial in all languages
- ✅ Paid version is polished
- ✅ Lower barrier to entry

## Content Localization Workflow

Copy this checklist:

```
Localization Progress:
- [ ] Step 1: Audit language dependencies (30 min)
- [ ] Step 2: Categorize content (20 min)
- [ ] Step 3: Translate text content (2-4 hours)
- [ ] Step 4: Adapt cultural elements (1 hour)
- [ ] Step 5: Localize visual assets (30 min)
- [ ] Step 6: Native speaker review (1 hour)
- [ ] Step 7: Localization testing (2 hours)
```

### Step 1: Audit Language Dependencies

Identify all text content:

**Critical (Must Translate)**:
- Story narration
- Character dialogue
- Scene descriptions
- Puzzle instructions
- Hints
- Endings
- Player UI labels

**Optional (Can Keep English)**:
- Database property names (admin view)
- Formula syntax (hidden from player)
- Debug comments

**Never Translate**:
- Answers to visual/math puzzles (universal)
- Proper nouns (character names - keep or localize consistently)

### Step 2: Categorize Content

| Content Type | Translation Difficulty | Cultural Adaptation | Priority |
|--------------|----------------------|---------------------|----------|
| UI Labels | Low | None | High |
| Puzzle Instructions | Low | None | High |
| Story Narration | Medium | High | High |
| Character Names | N/A | Medium | Medium |
| Cultural References | High | High | Medium |
| Hints | Low | Low | High |
| Item Descriptions | Low | Low | High |

### Step 3: Translate Text

**Translation Methods**:

**Option A: Professional Translator**
- Cost: $0.08-0.15 per word
- Quality: ⭐⭐⭐⭐⭐
- Time: 2-5 business days
- Best for: Final production version

**Option B: DeepL + Native Review**
- Cost: Free/Low ($7.49/mo premium)
- Quality: ⭐⭐⭐⭐☆
- Time: 1-2 days
- Best for: MVP, indie developers

**Option C: Community Translation**
- Cost: Free (or revenue share)
- Quality: ⭐⭐⭐☆☆ (varies)
- Time: 1-2 weeks
- Best for: Fan translations, post-launch

**Recommended for Notion Escape Rooms**: Option B

**Workflow**:
```
1. Extract all text to spreadsheet
2. DeepL translate to target languages
3. Native speaker reviews for:
   - Natural phrasing
   - Cultural appropriateness
   - Emotional tone match
4. Implement in Notion template
5. Playtest with native speakers
```

### Step 4: Cultural Adaptation

**What to Adapt**:

**Names**:
```
Original: "Richard Park" (CEO)
English: "Richard Park" (keep)
Korean: "박리차드" or "박준형" (Korean name)
Japanese: "リチャード・パーク" (katakana) or "朴リチャード"
```

**Settings**:
```
Original: "Corporate Office"
English: "Corporate Office"
Korean: "대기업 사무실" (large company office)
Japanese: "コーポレートオフィス" (corporate office)

Cultural touch:
- EN: Coffee machine, cubicles
- KR: 보리차 (barley tea) dispenser, open office
- JP: Vending machines, business cards
```

**Holidays/Dates**:
```
Puzzle: Calendar code

Universal approach:
- Use visual: Circled dates on calendar image
- Avoid culture-specific holidays
- Use numbers only: "1225" instead of "Christmas"

If cultural:
- EN: 12/25 (Christmas)
- KR: 09/15 (Chuseok - adjust date)
- JP: 01/01 (New Year)
```

**Humor/Tone**:
```
Suspenseful narration:

EN: "The door clicks shut behind you."
KR: "문이 찰칵 소리를 내며 닫힌다." (more ominous tone)
JP: "ドアが後ろでカチャリと閉まる。" (suspenseful particle use)

Humor:

EN: "The janitor whistles cheerfully."
KR: "청소부 아저씨가 흥겹게 휘파람을 분다." (familiar informal tone)
JP: "清掃員が楽しそうに口笛を吹いている。" (polite descriptive)
```

**Cultural References**:
```
Original: "Like a detective in a film noir"

EN: Keep as-is (film noir is international term)
KR: "마치 추리 소설 속 탐정처럼" (like detective in mystery novel)
JP: "ハードボイルド探偵のように" (hardboiled detective style)

Adaptation principle: Equivalent cultural touchstone, not literal translation
```

### Step 5: Localize Visual Assets

**Images with Text**:
- Create versions for each language OR
- Use overlays/captions OR
- Remove text (visual only)

**Example**:
```
Puzzle: Photo with note
Original: Sticky note says "Check the red file"

Option A: 3 image versions
- EN: Sticky note "Check the red file"
- KR: 포스트잇 "빨간 파일을 확인하세요"
- JP: 付箋 "赤いファイルをチェック"

Option B: Caption below image
- Image: Photo without text
- Caption (Toggle by language): Instructions in text
```

**Icons/Symbols**:
Generally universal, but verify:
- ✅ Universal: 🔒🔑🚪💡⭐❤️🏠🚗
- ⚠️ Check: 👍👎 (different meanings in some cultures)
- ❌ Avoid: Country flags (except for language selection)

### Step 6: Native Speaker Review

**Checklist for Reviewers**:
```
Language Quality:
- [ ] Natural phrasing (not machine translation stiffness)
- [ ] Appropriate formality level
- [ ] Consistent terminology
- [ ] No grammatical errors
- [ ] Emotional tone matches intent

Cultural Appropriateness:
- [ ] No offensive content
- [ ] References make sense
- [ ] Names sound natural
- [ ] Setting feels authentic

Player Experience:
- [ ] Instructions are clear
- [ ] Hints are helpful
- [ ] Story is engaging
- [ ] Puzzles are solvable
```

**Feedback Template**:
```
Scene: S005 "Server Room"
Original: "The hum of servers fills the air."

KR Translation: "서버의 윙윙거리는 소리가 공기를 채운다."
Review: ⚠️ Too literal. Better: "서버룸은 기계음으로 가득했다."

Issue: Machine translation stiffness
Suggested: More natural Korean phrasing
Priority: Medium
```

### Step 7: Localization Testing

**Test with Native Speakers**:

**Test Protocol**:
```
Tester Profile:
- Native speaker
- Target age group (20-40)
- NOT professional translator (test "normal" user)

Test Tasks:
1. Play through entire game
2. Rate language quality (1-5): ____
3. Mark confusing phrases
4. Note cultural mismatches
5. Suggest improvements

Metrics:
- Completion rate: Should match base language (60-70%)
- Time: Should be within ±10% of base
- Comprehension: Can they solve puzzles?
- Enjoyment: Did story engage them?
```

## Language-Agnostic Design Principles

**70/30 Rule**: 70% language-agnostic content + 30% localized text

**Maximize Visual Communication**:
```
Text-Heavy (Harder to localize):
"The safe requires a 4-digit code. Look at the calendar on the wall. Circle the dates that are holidays in red."

Visual-Heavy (Easier to localize):
[Image: Calendar with red-circled dates]
Instruction: "Enter the dates in order: MM-DD"
```

**Simplify Language**:
```
Complex: "Utilize the implement to facilitate access to the secured compartment."
Simple: "Use the key to open the locked box."

Benefits:
- Easier translation
- Faster comprehension
- Better for non-native speakers even in base language
```

**Use Universal Symbols**:
```
Text: "Go to the kitchen" → Symbol: 🍳 Kitchen
Text: "Find 3 keys" → Symbol: 🔑×3
Text: "Unlock the safe" → Symbol: 🔒→🔓
```

## Pricing Localization

**Strategy**: Regional pricing based on local market

| Market | Price (USD equiv) | Local Currency | Rationale |
|--------|------------------|----------------|-----------|
| EN (Global) | $4.99 | USD $4.99 | Base price |
| KR (Korea) | $4.50 | ₩5,500 | Slightly lower (PPP adjusted) |
| JP (Japan) | $5.50 | ¥600 | Slightly higher (premium market) |

**Bundle Pricing**:
```
EN: Complete Bundle $14.99 (Acts 1-5)
KR: 컴플리트 번들 ₩16,500
JP: コンプリートバンドル ¥1,600
```

## Localization Anti-Patterns

❌ **Direct Translation Without Context**
```
Bad: "Break a leg" → KR: "다리를 부러뜨려" (literal: break your leg - confusing)
Good: "Good luck" → KR: "행운을 빕니다" (natural equivalent)
```

❌ **Ignoring Text Length Differences**
```
Problem:
EN: "Key" (3 chars)
KR: "열쇠" (2 chars) ✅ OK
JP: "キー" (2 chars) ✅ OK
DE: "Schlüssel" (9 chars) ⚠️ May break UI

Solution: Test all languages, adjust UI spacing
```

❌ **Forgetting Sorting/Alphabetization**
```
Problem:
EN: Alphabetical: Apple, Banana, Cherry
KR: 가나다순: 사과, 바나나, 체리 (different order!)

Solution: Use number-based ordering OR language-specific sorting
```

❌ **Cultural Insensitivity**
```
Avoid:
- Religious references (Christmas-only puzzles)
- Political topics
- Stereotypes
- Sensitive historical events

Use instead:
- Universal celebrations (New Year, birthdays)
- Neutral settings
- Diverse representation
- Timeless themes
```

## Maintenance Strategy

**Update Sync Workflow**:
```
When updating any template:
1. Document changes in changelog
2. Update base language (EN or KR)
3. Mark affected sections in other languages
4. Request translation for changes only
5. Test updated sections
6. Deploy all languages simultaneously

Tools:
- Notion Database: "Localization Tracker"
  - Property: Last Updated (Date)
  - Property: Languages Complete (Multi-select)
  - Property: Translation Status (Select)
```

## Resources

### references/
- `cultural-guide.md` - Culture-specific dos and don'ts
- `translation-glossary.md` - Consistent terminology across languages
- `market-research.md` - Escape room cultures by country

### assets/
- `language-templates/` - Pre-formatted language toggles
- `localization-checklist.xlsx` - Translation project management

## Example Application

**User**: "Localize the office mystery for Korean and Japanese markets"

**Output**:
```
Analysis:
- Total text content: ~3,000 words
- Language-agnostic puzzles: 70% (10/15 puzzles)
- Culture-specific content: Office setting (adaptable)

Localization Plan:

Korean Version (미스터리 오피스):
- Character names: 박준형 (CEO), 김미아 (Janitor), 이진 (Security)
- Setting: 대기업 본사 (large company HQ)
- Cultural touches: 보리차 dispenser, 야근 (overtime work) theme
- Pricing: ₩5,500
- Time estimate: 8 hours (DeepL + native review)

Japanese Version (ミステリーオフィス):
- Character names: パク・ジュンヒョン, キム・ミア, イ・ジン
- Setting: コーポレートオフィス
- Cultural touches: Vending machines, 残業 (overtime) theme
- Pricing: ¥600
- Time estimate: 8 hours

Approach: Strategy 3 (Hybrid)
- Act 1: Toggle method (free trial)
- Acts 2-5: Separate templates (purchased)

Visual Assets:
- 3 images contain text → Create EN/KR/JP versions
- 12 images no text → Reuse across all

Next Steps:
1. Create translation spreadsheet
2. DeepL translate (1 hour)
3. Native reviewer feedback (2-3 days)
4. Implement in Notion (3 hours)
5. Localization playtest (4 hours)
```

This approach balances quality, cost, and maintenance for sustainable global market presence.
