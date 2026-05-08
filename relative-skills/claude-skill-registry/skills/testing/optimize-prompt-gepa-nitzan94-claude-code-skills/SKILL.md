---
name: optimize-prompt-gepa
description: Optimizes prompts using full GEPA methodology (Genetic-Pareto Evolution). Use when user wants to improve a prompt's accuracy on test cases, mentions "optimize prompt", "improve prompt", or has examples of desired input/output pairs. Implements Pareto frontier selection, trace-based reflection, and crossover mutations.
---

<objective>
GEPA (Genetic-Pareto Evolution for AI) optimizes prompts through:
1. **Pareto frontier** - Maintain pool of prompts that excel on different test cases
2. **Trace-based reflection** - Analyze full reasoning chains, not just outputs
3. **Crossover mutations** - Merge insights from multiple successful prompts
4. **Diversity pressure** - Prevent premature convergence

You (Claude) are the optimizer. You run prompts, capture traces, reflect on failures, and evolve improvements.
</objective>

<quick_start>
User provides:
1. A seed prompt to optimize
2. Test cases (input + expected output pairs)

You run the full GEPA loop and return the optimized prompt.

Example:
```
Seed: "Extract action items"
Test case:
  Input: "Meeting notes: John will prepare the report by Friday. Sarah to review."
  Expected: "- John: Prepare report (Due: Friday)\n- Sarah: Review (Due: unspecified)"

After GEPA optimization:
"Extract action items from text. Think step by step:
1. Identify each person mentioned
2. Find what they committed to do
3. Extract any deadline mentioned

Format each item as:
- [Person]: [Task] (Due: [deadline or 'unspecified'])

Rules:
- Skip items without clear ownership
- If deadline is vague (e.g., 'soon', 'later'), mark as 'unspecified'
- One line per action item"
```
</quick_start>

<intake>
To optimize a prompt, I need:

1. **Seed prompt** - What prompt do you want to optimize?
2. **Test cases** - Examples of input and expected output
   - Minimum: 1 example (I'll generate more synthetically)
   - Recommended: 5-10 examples for robust optimization

Optional:
- Target score (default: 90%)
- Max iterations (default: 10)
- Diversity weight (default: 0.3) - How much to favor diverse solutions

Please provide your prompt and test cases.
</intake>

<data_structures>
```
# Prompt Candidate
Candidate = {
  id: string,
  prompt: string,
  scores: {test_case_id: float},  # Score per test case
  avg_score: float,
  parent_ids: [string],  # For tracking lineage
  mutation_type: "reflection" | "crossover" | "seed"
}

# Pareto Frontier
ParetoFrontier = [Candidate]  # Candidates not dominated by any other

# Test Case with Trace
EvaluatedCase = {
  input: string,
  expected: string,
  actual: string,
  trace: string,  # Full reasoning chain
  score: float,
  feedback: string
}
```
</data_structures>

<process>
<step name="1_parse_input">
Parse user's input to extract:
- `seed_prompt`: The prompt to optimize
- `test_cases`: Array of {id, input, expected} pairs
- `target_score`: Default 0.9 (90%)
- `max_iterations`: Default 10
- `diversity_weight`: Default 0.3

Assign unique IDs to test cases (tc_1, tc_2, etc.)
</step>

<step name="2_synthetic_generation">
If fewer than 5 test cases, generate synthetic examples:

```
Given these examples:
{for each test_case: input -> expected}

Generate 5 more examples that:
- Follow the EXACT same output format
- Cover edge cases:
  * Empty/null inputs
  * Multiple items
  * Missing information
  * Ambiguous cases
- Use different names, numbers, contexts

Return as JSON array: [{"input": "...", "expected": "..."}, ...]
```

Add generated examples to test_cases with IDs.
</step>

<step name="3_baseline_evaluation">
Create seed candidate and evaluate with TRACES:

```
seed_candidate = {
  id: "c_0",
  prompt: seed_prompt,
  scores: {},
  parent_ids: [],
  mutation_type: "seed"
}
```

For each test_case:
  1. Run with trace capture:
     ```
     {seed_prompt}
     
     Input: {test_case.input}
     
     Think through this step by step, then provide your final answer.
     
     ## Reasoning:
     [Your step-by-step thinking]
     
     ## Answer:
     [Your final output]
     ```
  
  2. Parse trace (reasoning) and answer separately
  3. Score answer against expected (0-10)
  4. Store: seed_candidate.scores[test_case.id] = score/10

Calculate avg_score = mean(all scores)

Initialize:
- `pareto_frontier = [seed_candidate]`
- `all_candidates = [seed_candidate]`
- `best_avg_score = avg_score`

Report: "Baseline score: {avg_score:.0%}"
</step>

<step name="4_gepa_loop">
FOR iteration 1 to max_iterations:

  **4a. Pareto Selection**
  Select parent candidate using tournament selection with diversity bonus:
  
  ```
  For 3 random candidates from pareto_frontier:
    Calculate selection_score = avg_score + diversity_weight * uniqueness
    (uniqueness = how different this candidate's strengths are from others)
  
  Select candidate with highest selection_score
  ```
  
  selected_parent = winner

  **4b. Mini-batch Evaluation**
  Select mini-batch of 3 test cases, prioritizing:
  - Cases where selected_parent scored lowest (exploitation)
  - 1 random case (exploration)

  Run selected_parent.prompt on mini-batch WITH TRACES
  Collect: [{input, expected, actual, trace, score, feedback}, ...]

  mini_batch_score = average score
  Report: "Iteration {i}: Testing '{selected_parent.id}' on mini-batch: {mini_batch_score:.0%}"

  **4c. Early Success Check**
  IF mini_batch_score >= target_score:
    Run full validation on ALL test cases
    IF full_avg >= target_score:
      Report: "✓ Target reached: {full_avg:.0%}"
      GOTO step 5 (output)

  **4d. Trace-Based Reflection**
  Collect failures (score < 0.8) with their TRACES:

  ```
  ## Reflection Task
  
  Current prompt:
  {selected_parent.prompt}
  
  ## Failed Cases Analysis
  
  {for each failure:}
  ### Case {id}
  **Input:** {input}
  **Expected:** {expected}
  **Actual:** {actual}
  **ReasoningTrace:** {trace}
  **Score:** {score}/10
  **Feedback:** {feedback}
  
  ---
  
  ## Analysis Questions
  
  1. **Trace Analysis**: Where in the reasoning did the model go wrong?
     - Did it misunderstand the task?
     - Did it miss information in the input?
     - Did it apply wrong formatting?
  
  2. **Pattern Recognition**: What patterns do you see across failures?
     - Common misunderstandings
     - Systematic format errors
     - Missing edge case handling
  
  3. **Root Cause**: What's the SINGLE most impactful fix?
  
  4. **Specific Rules**: List 3-5 explicit rules to add to the prompt.
  
  Provide your analysis:
  ```


  Save reflection_analysis

  **4e. Generate Mutations**
  Create 2 new candidates:

  **Mutation 1: Reflection-based**
  ```
  Current prompt:
  {selected_parent.prompt}
  
  Analysis of failures:
  {reflection_analysis}
  
  Create an improved prompt that:
  - Addresses ALL identified issues
  - Includes explicit rules from analysis
  - Adds step-by-step reasoning instructions if helpful
  - Specifies exact output format with examples
  
  Write ONLY the new prompt (no explanation):
  ```

  **Mutation 2: Crossover (if pareto_frontier has 2+ candidates)**
  ```
  You have two successful prompts with different strengths:
  
  Prompt A (excels on: {cases where A > B}):
  {candidate_a.prompt}
  
  Prompt B (excels on: {cases where B > A}):
  {candidate_b.prompt}
  
  Create a NEW prompt that combines the best elements of both.
  Merge their rules, keep the most specific instructions from each.
  
  Write ONLY the merged prompt:
  ```

  Create new candidates:
  - mutation_1 = {id: "c_{n}", prompt: reflection_result, parent_ids: [selected_parent.id], mutation_type: "reflection"}
  - mutation_2 = {id: "c_{n+1}", prompt: crossover_result, parent_ids: [a.id, b.id], mutation_type: "crossover"}

  **4f. Full Evaluation of New Candidates**
  For each new candidate:
    Run on ALL test cases with traces
    Calculate scores per test case and avg_score

  **4g. Update Pareto Frontier**
  For each new candidate:
    Add to all_candidates
    
    Check Pareto dominance:
    - Candidate A dominates B if A scores >= B on ALL test cases AND > on at least one
    
    Update pareto_frontier:
    - Add new candidate if not dominated by any existing
    - Remove any existing candidates now dominated by new one

  **4h. Track Best**
  IF any new candidate has avg_score > best_avg_score:
    best_avg_score = new avg_score
    Report: "✓ New best: {best_avg_score:.0%} (candidate {id})"
  ELSE:
    Report: "No improvement. Pareto frontier size: {len(pareto_frontier)}"

  **4i. Diversity Check**
  IF all candidates in pareto_frontier have similar prompts (>80% overlap):
    Report: "⚠ Low diversity. Injecting random mutation."
    Create random_mutation with aggressive changes
    Add to next iteration's candidates

END FOR
</step>

<step name="5_output_results">
Select best_candidate = candidate with highest avg_score from pareto_frontier

Present final results:

```
## GEPA Optimization Results

### Performance
| Metric | Value |
|--------|-------|
| Baseline Score | {seed_candidate.avg_score:.0%} |
| Final Score | {best_candidate.avg_score:.0%} |
| Improvement | +{improvement:.0%} |
| Iterations | {iterations_run} |
| Candidates Evaluated | {len(all_candidates)} |
| Pareto Frontier Size | {len(pareto_frontier)} |

### Original Prompt
```
{seed_prompt}
```

### Optimized Prompt
```
{best_candidate.prompt}
```

### Per-Case Performance
| Test Case | Before | After | Δ |
|-----------|--------|-------|---|
{for each test_case:}
| {id} | {seed_scores[id]:.0%} | {best_scores[id]:.0%} | {delta} |

### Key Discoveries
{Summarize main patterns found during reflection:}
1. {discovery_1}
2. {discovery_2}
3. {discovery_3}

### Alternative Prompts (Pareto Frontier)
{If pareto_frontier has multiple candidates with different strengths:}
- **{candidate.id}**: Best for {cases where it excels} ({avg:.0%} avg)
```
</step>
</process>

<scoring_guide>
## Scoring Outputs (0-10)

| Score | Criteria |
|-------|----------|
| 10 | Perfect match: correct content AND exact format |
| 9 | Correct content, trivial format difference (whitespace, punctuation) |
| 7-8 | Correct content, minor format difference (ordering, capitalization) |
| 5-6 | Mostly correct content, wrong format structure |
| 3-4 | Partial content, significant omissions |
| 1-2 | Minimal correct content |
| 0 | Completely wrong or empty |

## Feedback Template
```
Score: X/10
✓ Correct: [what's right]
✗ Wrong: [what's wrong]
→ Fix: [specific instruction that would fix it]
```

Be STRICT about format matching. Format errors indicate missing instructions in the prompt.
</scoring_guide>

<trace_analysis_guide>
## How to Analyze Reasoning Traces

When examining a trace, look for:

1. **Task Understanding**
   - Did the model correctly interpret what to do?
   - Did it miss any requirements?

2. **Information Extraction**
   - Did it find all relevant info in the input?
   - Did it hallucinate information not present?

3. **Logic Errors**
   - Where did the reasoning go wrong?
   - What assumption was incorrect?

4. **Format Application**
   - Did it know the expected format?
   - Did it apply it correctly?

## Red Flags in Traces
- "I assume..." → Missing explicit instruction
- "I'm not sure if..." → Ambiguous requirement
- Skipping steps → Need more structured guidance
- Wrong interpretation → Need examples in prompt
</trace_analysis_guide>

<pareto_frontier_guide>
## Pareto Dominance

Candidate A dominates Candidate B if:
- A.scores[tc] >= B.scores[tc] for ALL test cases
- A.scores[tc] > B.scores[tc] for AT LEAST ONE test case

## Why Pareto Matters

Different prompts may excel on different cases:
- Prompt A: Great at edge cases, weak on simple cases
- Prompt B: Great at simple cases, weak on edge cases

Both belong in the Pareto frontier. Crossover can combine their strengths.

## Frontier Maintenance
- Max size: 5 candidates (prevent explosion)
- If over limit, keep most diverse set using k-medoids
</pareto_frontier_guide>

<edge_cases>
**Only 1 test case**: Generate 5+ synthetic examples covering edge cases before starting.

**Perfect baseline (100%)**: Report success, no optimization needed. Suggest additional edge cases to test robustness.

**No improvement after 5 iterations**: 
- Increase diversity_weight to 0.5
- Try aggressive mutations (rewrite from scratch based on learnings)
- Check if test cases have conflicting requirements

**Pareto frontier explodes (>5 candidates)**:
- Keep only the 5 most diverse candidates
- Prioritize candidates with unique strengths

**Crossover produces worse results**:
- Reduce crossover frequency
- Focus on reflection-based mutations

**Oscillating scores (up/down/up)**:
- Indicates conflicting requirements in test cases
- Review test cases for consistency
- Consider splitting into sub-tasks
</edge_cases>

<success_criteria>
Optimization completes when:
1. ✓ Full dataset score >= target_score (default 90%), OR
2. ✓ Max iterations reached, OR
3. ✓ No improvement for 3 consecutive iterations (early stopping)

Always return:
1. Best prompt from Pareto frontier
2. Score improvement trajectory
3. Key discoveries from trace analysis
4. Alternative prompts if Pareto frontier has multiple strong candidates
</success_criteria>

<example_session>
## Example: Action Item Extraction

**User Input:**
```
Seed prompt: "Extract action items from meeting notes"

Test cases:
1. Input: "John will send the report by Friday"
   Expected: "- John: Send report (Due: Friday)"

2. Input: "We should discuss the budget sometime"
   Expected: ""

3. Input: "Sarah and Mike to review the proposal by EOD"
   Expected: "- Sarah: Review proposal (Due: EOD)\n- Mike: Review proposal (Due: EOD)"
```

**GEPA Execution:**

Iteration 1: Baseline 40%
- tc_1: 8/10 (format slightly off)
- tc_2: 0/10 (returned items when should be empty)
- tc_3: 4/10 (missed second person)

Reflection: "Model doesn't know to skip vague items or split multiple people"

Mutation 1 (reflection): Added rules for ownership and multiple people

Iteration 2: 70%
- tc_2 now correct (empty)
- tc_3 still failing (format)

Crossover with seed: Merged format examples

Iteration 3: 90% ✓ Target reached

**Final Optimized Prompt:**
```
Extract action items from meeting notes.

Step-by-step:
1. Find each person with a specific commitment
2. Identify their task and any deadline
3. Format as: "- [Person]: [Task] (Due: [deadline])"

Rules:
- SKIP vague items without clear ownership ("we should...", "someone needs to...")
- If multiple people share a task, create separate lines for each
- If no deadline mentioned, use "Due: unspecified"
- If NO valid action items exist, return empty string

Example:
Input: "John and Mary will review docs by Monday. We should improve process."
Output:
- John: Review docs (Due: Monday)
- Mary: Review docs (Due: Monday)
```
</example_session>