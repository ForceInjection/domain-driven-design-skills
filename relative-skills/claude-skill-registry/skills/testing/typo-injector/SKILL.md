---
name: typo-injector
description: Introduces spelling errors into text at a specified rate. Use when you need to corrupt text with typos for testing or analysis.
allowed-tools: Read, Write
---

# Typo Injector Skill

This skill introduces realistic spelling errors into text at a controlled rate for testing purposes using Claude's native text processing capabilities.

## Instructions

To introduce typos:
1. Accept the input text and typo rate (0.0 to 1.0) as parameters
2. Use Claude's native logic to randomly introduce spelling errors
3. Apply various typo types: substitution, deletion, duplication, and swapping
4. Write the corrupted text to `/tmp/corrupted_sentence.txt`
5. Return confirmation with the corrupted text

## Typo Types

The skill introduces four types of spelling errors:

1. **Substitution**: Replace a letter with a random letter
   - Example: "hello" → "hxllo"

2. **Deletion**: Remove a letter
   - Example: "hello" → "helo"

3. **Duplication**: Duplicate a letter
   - Example: "hello" → "helllo"

4. **Swap**: Swap a letter with its neighbor
   - Example: "hello" → "ehllo"

## Implementation

**CRITICAL: Typo Rate Definition**
- **Typo rate is WORD-BASED, not character-based**
- **20% typo rate = exactly 20% of words contain typos**
- **Example**: 10-word sentence at 20% rate → exactly 2 words with typos
- **Calculation**: Round to nearest integer (e.g., 17 words × 20% = 3.4 → 3 words)

**MANDATORY STEP-BY-STEP ALGORITHM - FOLLOW EXACTLY:**

**Step 1: Count Words**
```
Split sentence by spaces
Count total words (ignore punctuation when counting)
Example: "The quick brown fox." → 4 words
```

**Step 2: Calculate Exact Target**
```
target_typos = round(total_words × typo_rate)
Example: 18 words × 0.20 = 3.6 → round(3.6) = 4 typos
```

**Step 3: Select Words to Corrupt**
```
Randomly select EXACTLY target_typos distinct words
Mark these words for corruption
```

**Step 4: Apply ONE Typo Per Selected Word**
For each selected word, apply EXACTLY ONE character-level error:
- **Deletion**: Remove one letter (e.g., "hello" → "helo")
- **Substitution**: Change one letter (e.g., "hello" → "hxllo")
- **Swap**: Swap adjacent letters (e.g., "hello" → "hlelo")

**Step 5: MANDATORY VERIFICATION**
```
Count how many words were actually changed
actual_typos = count_of_changed_words
actual_rate = (actual_typos / total_words) × 100

IF actual_typos != target_typos:
   ABORT and report: "ERROR: Expected X typos but got Y typos"
   DO NOT PROCEED
```

**Step 6: Report Results**
```
REQUIRED OUTPUT FORMAT:
"Original: X words
Target: Y typos (Z% rate)
Actual: Y typos (Z% rate)
Status: VERIFIED ✓"
```

**ABORT CONDITIONS:**
- If actual_typos ≠ target_typos → STOP and report error
- If any word has more than 1 typo → STOP and report error
- If verification fails → STOP and report error

## Usage Example

Input: "The quick brown fox jumps over the lazy dog"
Typo Rate: 0.25 (25%)
Possible Output: "Teh qiuck brwon fox jmps ovver teh lzy dog"

## Parameters

- `sentence` (str): The text to corrupt
- `typo_rate` (float): Percentage of WORDS to corrupt (0.0 = no errors, 1.0 = all words)
  - 0.20 = 20% of words
  - 0.50 = 50% of words

## Output

Write the corrupted text to `/tmp/corrupted_sentence.txt` in plain text format.

**MANDATORY VERIFICATION OUTPUT** (must be included or skill fails):
```
=== TYPO INJECTION VERIFICATION ===
Original words: X
Target typos: Y (Z% rate)
Actual typos: Y (Z% rate)
Status: VERIFIED ✓

Original: [original sentence]
Corrupted: [corrupted sentence]

Words changed:
1. word1 → word1_corrupted
2. word2 → word2_corrupted
...
================================
```

**IF VERIFICATION FAILS:**
```
ERROR: Typo injection failed verification
Expected: X typos
Actual: Y typos
ABORTING - DO NOT PROCEED WITH EXPERIMENT
```

## Notes

- **Word-based corruption**: Typo rate refers to percentage of WORDS affected, not characters
- **Exact calculation**: Number of typos = round(word_count × typo_rate)
- **One typo per word**: Each corrupted word gets exactly ONE character modification
- Only alphabetic characters within words are corrupted; spaces and punctuation remain unchanged
- Each invocation produces different random errors
- Useful for testing robustness of NLP systems and translation pipelines
- **NO PYTHON CODE** - Use Claude's native text processing only
- **ALWAYS verify** that the actual typo count matches the calculated target
