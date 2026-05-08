---
name: debug-mode
description: Hypothesis-driven debugging with hybrid dual-track parallel execution (Opus 4.5 + GPT 5.2). Spawns two independent chains of subagents where each reviews and improves upon its own previous work, then synthesizes findings from both tracks. Use when debugging hard-to-reproduce bugs, CI/E2E test failures, flaky tests, or when standard fixes have failed.
---

<debug_mode_skill>
  <persona>Deep Debugger / Senior Engineer</persona>
  <primary_goal>Fix bugs through runtime evidence using parallel AI perspectives</primary_goal>

  <overview>
    Debug Mode uses hybrid dual-track parallel debugging with Opus 4.5 and GPT 5.2:

    ```
    Main Agent (minimal - coordinates orchestrators)
        |
        ├── Task() -> Track 0 Orchestrator (Opus, synchronous)
        │       ├── debug-mode context run (GPT 5.2 medium)
        │       └── Task(model="opus") -> Repro Assessment
        |
        ├── [After Track 0 completes]
        |   |
        |   ├── Task(background) -> Track A Orchestrator (Opus)
        |   │   └── A1 (Opus) -> A2 (Opus/resume) -> A3 (Opus/resume) -> A4 (GPT/verify)
        |   │
        |   └── Task(background) -> Track B Orchestrator (Opus)
        |       └── B1 (GPT) -> B2 (Opus) -> B3 (GPT) -> B4 (Opus/verify)
        |
        ├── [After Track A/B complete]
        |   |
        |   └── Task() -> Judge Subagent (Opus, synchronous)
        |           └── Compares tracks, picks winner, outputs verdict
        |
        └── Apply winner fix, cleanup
    ```

    - Track 0: Orchestrator runs Context Builder (GPT) then Repro Assessment (Opus)
    - Track A: Opus chain with resume (Opus -> Opus -> Opus -> GPT), saves tokens
    - Track B: True alternation (GPT -> Opus -> GPT -> Opus)
    - Judge: Opus compares both tracks, picks winner (or COMPLEMENTARY if both needed)
    - All Claude models = Opus 4.5, all OpenAI models = GPT 5.2
    - Each iteration: Hypothesize -> Instrument -> Reproduce -> Analyze
    - Early exit: A2/A3 or B2/B3 can verify and signal READY_FOR_FIX to skip remaining iterations
    - Each track works in its own git worktree (no conflicts)
  </overview>

  <prerequisites>
    <requirement>First time setup: cd ~/.claude/skills/debug-mode && bun install</requirement>
    <requirement>Add to PATH: ln -s ~/.claude/skills/debug-mode/bin/debug-mode ~/agent-tools/bin/</requirement>
    <requirement>Requires: bun, tmux, codex CLI (for Track B)</requirement>
  </prerequisites>

  <cli_commands>
    The debug-mode CLI provides utilities for managing debug sessions:

    debug-mode init <project>                       Initialize worktrees and progress docs
    debug-mode cleanup <project>                    Complete cleanup of all artifacts
    debug-mode context run <prompt> <project>       Launch context builder (GPT 5.2 medium)
    debug-mode context poll                         Check context builder status
    debug-mode context read                         Output context.md contents
    debug-mode codex run <track> <n> <file>         Run Codex iteration N for a track
    debug-mode codex poll <track>                   Check Codex session status for a track
    debug-mode status <track>                       Check progress doc for signals
    debug-mode diff <track>                         Show changes in a track's worktree
    debug-mode apply <track> <project>              Apply a track's fix to the project

    Tracks: track-a, track-b
  </cli_commands>

  <critical_rule>
    NEVER attempt to fix the bug immediately. You MUST follow the dual-track
    debugging workflow. Speculative fixes without runtime evidence are prohibited.
    Wait for both tracks to complete before synthesizing findings.
  </critical_rule>

  <workflow>
    <phase name="1. INITIALIZE" agent="main">
      Use the CLI to create worktrees and progress docs:

      ```bash
      debug-mode init /path/to/project
      ```

      This creates:
      - Worktrees: /tmp/debug-track-a, /tmp/debug-track-b
      - Progress docs: /tmp/debug-track-a-progress.md, /tmp/debug-track-b-progress.md

      Update the progress docs with the actual bug description.
      Each track works in its own worktree - no conflicts possible.
    </phase>

    <phase name="2. TRACK 0 (Context + Repro)" agent="main">
      Spawn Track 0 Orchestrator to gather context and establish reproduction.
      This runs synchronously - main agent waits for completion.

      ```
      Task(
        subagent_type="general-purpose",
        model="opus",
        prompt="{track_0_orchestrator_prompt}",
        run_in_background=false  # Wait for completion
      )
      ```

      Track 0 Orchestrator performs:
      1. Context Builder (GPT 5.2 medium via Codex) - gathers relevant files
      2. Repro Assessment (Opus sub-subagent) - establishes reproduction strategy

      Outputs:
      - /tmp/debug-context.md with relevant code and analysis
      - REPRO_MODE in both progress docs (AUTO/SEMI_AUTO/MANUAL)
      - debug-repro.{js|py|sh} in both worktrees (if AUTO mode)

      See <track_0_orchestrator_prompt> for the prompt this orchestrator receives.
    </phase>

    <phase name="3. SPAWN PARALLEL DEBUG TRACKS" agent="main">
      Launch BOTH debug tracks as background subagents. Each subagent manages
      its own iteration loop independently. Main agent waits for both to complete.

      Track A Orchestrator (Opus, manages Opus/GPT iterations):
      ```
      Task(
        subagent_type="general-purpose",
        model="opus",
        prompt="{track_a_orchestrator_prompt}",
        run_in_background=true
      )
      ```

      Track B Orchestrator (Opus, manages GPT/Opus iterations):
      ```
      Task(
        subagent_type="general-purpose",
        model="opus",
        prompt="{track_b_orchestrator_prompt}",
        run_in_background=true
      )
      ```

      Both tracks start with context and repro strategy from Track 0.
      They focus purely on debugging: hypothesize, instrument, reproduce, analyze.

      See <track_orchestrator_prompts> for the prompts each orchestrator receives.
    </phase>

    <phase name="4. WAIT FOR COMPLETION" agent="main">
      Main agent waits for both background subagents to complete.
      Each subagent handles its own iteration loop internally.

      ```
      # Wait for both tracks (can check periodically or block)
      track_a_result = TaskOutput(task_id=track_a_id, block=true)
      track_b_result = TaskOutput(task_id=track_b_id, block=true)
      ```

      The subagents will:
      - Run up to 4 debug iterations each (repro already done by Track 0)
      - Spawn fresh sub-subagents for "fresh eyes" review (Track A)
      - Spawn fresh codex exec calls (Track B)
      - Update their progress docs after each iteration
      - Terminate when "READY FOR FIX" or "EARLY EXIT" is reached, or max iterations

      Main agent can optionally poll with block=false to show progress to user.
    </phase>

    <phase name="5. JUDGE" agent="main">
      Spawn Judge subagent to compare tracks and pick winner.

      ```
      Task(
        subagent_type="general-purpose",
        model="opus",
        prompt="{judge_subagent_prompt}",
        run_in_background=false  # Wait for verdict
      )
      ```

      The Judge will:
      1. Read context file: /tmp/debug-context.md
      2. Read both progress docs
      3. Compare fixes: `debug-mode diff track-a` and `debug-mode diff track-b`
      4. Evaluate: evidence quality, fix simplicity, verification confidence
      5. Output verdict: WINNER: track-a | WINNER: track-b | COMPLEMENTARY

      See <judge_subagent_prompt> for the prompt this subagent receives.
    </phase>

    <phase name="6. APPLY" agent="main">
      Apply the winning fix based on Judge verdict:

      ```bash
      debug-mode apply <winning-track> /path/to/project
      ```

      If COMPLEMENTARY, apply both fixes in sequence (track-a first, then track-b).
      Ask user to verify fix works in their environment.
    </phase>

    <phase name="7. CLEANUP" agent="main">
      After user confirms fix works:

      1. Apply the fix to main worktree (if developed in a track worktree):
         ```bash
         git diff /tmp/debug-track-{a|b}/path/to/file path/to/file
         ```

      2. Run the cleanup command:
         ```bash
         debug-mode cleanup /path/to/project
         ```

         This will:
         - Kill tmux session
         - Remove worktrees and branches
         - Delete all temp files
         - List remaining [DEBUG_AGENT] lines for manual removal

      3. Manually remove any [DEBUG_AGENT] lines listed in the output.

      This phase is MANDATORY. Never leave debug artifacts behind.
    </phase>
  </workflow>

  <meta_prompt_template>
    Use this template for subagents 1-3 in either track (NOT for subagent 4 - see verification_subagent_prompt).
    These subagents iterate toward a fix: hypothesize, instrument, reproduce, analyze.

    ```
    ## Debug Track {A|B} - Subagent {N}

    ### Bug Description
    {original_bug_description}

    ### Context
    Read the context file for relevant files and code snippets:
    Path: /tmp/debug-context.md

    ### Your Worktree (IMPORTANT)
    Path: {/tmp/debug-track-a or /tmp/debug-track-b}

    You are working in an ISOLATED git worktree. All file edits and commands
    should be executed in YOUR worktree. The other track has its own worktree.
    This prevents conflicts between tracks.

    ### Progress Document
    Path: {/tmp/debug-track-a-progress.md or /tmp/debug-track-b-progress.md}

    FIRST: Read the progress document to understand:
    - REPRO_MODE and REPRO_COMMAND from Track 0
    - Previous fix attempts and their results
    LAST: Update the progress document with your findings before completing.

    ### Your Task
    You are Subagent {N}. You are a DIFFERENT MODEL than the previous subagent.
    Your job is to review their work with "fresh eyes" and iterate toward a fix.

    ### Behavior Constraints (GPT 5.2)
    - Implement EXACTLY what is needed to fix the bug - nothing more
    - Do NOT refactor unrelated code or add "improvements"
    - Do NOT add extra error handling, logging, or features beyond the fix
    - Keep fixes minimal: prefer 2-3 line changes over large refactors
    - Use PARALLEL tool calls when reading multiple files
    - Progress updates: 1-2 sentences at major steps only

    Follow this flow: HYPOTHESIZE -> INSTRUMENT -> REPRODUCE -> ANALYZE

    1. READ CONTEXT AND PROGRESS DOC
       - Read /tmp/debug-context.md for relevant files
       - Track 0's REPRO_MODE and REPRO_COMMAND
       - Previous fix attempts and their results
       - What's been confirmed/disproved

    2. HYPOTHESIZE
       Based on the bug description and context, generate 2-3 hypotheses about the root cause.
       If this is not the first iteration, review previous hypotheses and their status.

    3. FRESH EYES REVIEW (Critical Step)
       Read the previous subagent's code changes and analysis with fresh eyes.
       Look carefully for:
       - Obvious bugs or errors in their fix
       - Flawed assumptions or reasoning
       - Edge cases they missed
       - Off-by-one errors, null checks, race conditions
       - Whether their fix actually addresses the root cause
       - Anything that looks wrong, confusing, or suspicious

       You are a different model - use that to your advantage. Question everything.
       Don't assume the previous fix is correct just because it was attempted.

    4. ANALYZE current state
       - If previous fix works AND passes your review -> consider SKIP_TO_VERIFY
       - If previous fix has issues -> understand why, plan correction
       - If no fix yet -> identify root cause from logs/code

    5. INSTRUMENT (if needed)
       - Add [DEBUG_AGENT] logging to understand failures
       - JavaScript/TypeScript: console.log('[DEBUG_AGENT] ...')
       - Python: print('[DEBUG_AGENT] ...')
       - Skip if you have enough information to attempt fix

    6. PROPOSE FIX
       - State which hypothesis you're testing
       - Describe the fix you will make
       - Explain why this should work

    7. ATTEMPT FIX
       - Make the code change in your worktree
       - Keep fixes minimal and targeted (prefer 2-3 line fixes)
       - Do NOT remove [DEBUG_AGENT] logging

    8. REPRODUCE AND VERIFY
       - Run REPRO_COMMAND - does the bug still occur?
       - Run tests if available - do they pass?
       - Document the results

    9. UPDATE PROGRESS DOC
       ```markdown
       ## Iteration {N}

       ### Fresh Eyes Findings
       {issues found in previous work, or "N/A - first iteration"}
       - Bugs/errors spotted: {list or "None"}
       - Flawed assumptions: {list or "None"}
       - Edge cases missed: {list or "None"}

       ### Root Cause Analysis
       {current understanding of the bug}

       ### Fix Attempted
       File: {path}
       Change: {description of code change}
       Rationale: {why this fixes the root cause}

       ### Verification Results
       REPRO_RESULT: PASS | FAIL
       TESTS_RESULT: PASS | FAIL | N/A

       ### Signal
       One of:
       - SKIP_TO_VERIFY: Fix works, passed fresh eyes review, ready for verification
       - CONTINUE: Fix failed, has issues, or incomplete
       - NEEDS_MORE_INFO: Need more instrumentation before fixing

       ### Notes for Next Subagent
       {what to focus on if CONTINUE}
       ```

    ## SKIP_TO_VERIFY Criteria
    Signal SKIP_TO_VERIFY if ALL of the following are true:
    1. Fresh eyes review found no issues with the fix
    2. REPRO_RESULT is PASS (bug no longer reproduces)
    3. TESTS_RESULT is PASS or N/A (no regressions)
    4. The fix is minimal and clearly addresses root cause
    5. You questioned the fix critically and it holds up

    DO NOT remove [DEBUG_AGENT] logging - main agent handles cleanup.
    ```
  </meta_prompt_template>

  <context_builder_prompt>
    Use this prompt for the Context Builder (GPT 5.2 medium) - the first step in Track 0.
    It searches the codebase to identify relevant files, then bundles them with repomix.

    ```
    ## Track 0 Step 1: Context Builder

    Your task is to identify all relevant files for debugging this bug, then bundle
    them into a context file using repomix.

    You are running with GPT 5.2 medium reasoning.

    ### Behavior Constraints
    - Use PARALLEL tool calls when searching (grep multiple patterns simultaneously)
    - Be CONCISE - no narration of routine operations
    - Output only what's needed: file list, repomix command, brief analysis
    - Do NOT expand scope beyond finding relevant files

    ### QUICK REFERENCE: repomix Usage

    Bundle files into /tmp/debug-context.md using these patterns:

    ```bash
    # Single files (comma-separated)
    npx repomix --include "src/auth.ts,src/utils/token.ts" --output /tmp/debug-context.md

    # Glob patterns
    npx repomix --include "src/auth/**/*.ts" --output /tmp/debug-context.md

    # Multiple globs
    npx repomix --include "src/auth/**/*.ts,tests/auth*.ts" --output /tmp/debug-context.md

    # With exclusions
    npx repomix --include "src/**/*.ts" --exclude "**/*.test.ts,**/node_modules/**" --output /tmp/debug-context.md
    ```

    Output MUST go to: /tmp/debug-context.md

    ### Bug Description
    {bug_description}

    ### Project Root
    {project_root}

    ### Phase 1: SEARCH - Identify Relevant Files

    Use search tools to find files relevant to this bug:

    1. Grep for error messages, function names, keywords from bug description
    2. Glob to find related files by pattern (e.g., `**/*auth*.ts`)
    3. Read files briefly to confirm relevance

    Target files:
    - Files likely to contain the bug
    - Files that interact with the buggy code
    - Test files related to the affected functionality
    - Config files that might influence behavior
    - Entry points and call chains

    Build a list of relevant file paths as you search.

    ### Phase 2: BUNDLE - Package with repomix

    Once you have identified the relevant files, bundle them:

    ```bash
    npx repomix \
      --include "src/auth.ts,src/utils/token.ts,tests/auth.test.ts" \
      --output /tmp/debug-context.md
    ```

    Tips:
    - Use comma-separated paths in --include
    - Can use globs: --include "src/auth/**/*.ts,tests/auth*.ts"
    - repomix will include full file contents with line numbers

    ### Phase 3: APPEND - Add Analysis Summary

    After repomix generates the bundle, append your analysis:

    ```bash
    cat >> /tmp/debug-context.md << 'EOF'

    ---

    ## Debug Analysis Summary

    ### Bug Description
    {bug_description}

    ### Reproduction Hints
    - Entry point: {how the bug is triggered}
    - Dependencies: {external services, databases, etc.}
    - Test commands: {existing test commands that might help}

    ### Investigation Areas
    1. {file:lines - what to look for and why}
    2. {file:lines - what to look for and why}
    3. {file:lines - what to look for and why}

    EOF
    ```

    IMPORTANT: The subsequent subagents will rely on this context file.
    Be thorough in Phase 1 - missing a relevant file means the debug
    iterations won't have visibility into that code.
    ```
  </context_builder_prompt>

  <repro_subagent_prompt>
    Use this prompt for Track 0 Step 2 - the repro assessment subagent that
    establishes reproduction strategy for BOTH Track A and Track B.

    ```
    ## Track 0 Step 2: Repro Assessment Subagent

    Your SOLE task is to establish a reproduction strategy for this bug.
    Do NOT add instrumentation. Do NOT attempt to fix. Just establish repro.

    This repro strategy will be used by BOTH Track A (Claude) and Track B (GPT 5.2).

    ### Context
    FIRST: Read the context file generated by the Context Builder:
    Path: /tmp/debug-context.md

    This contains relevant files, code snippets, and observations about the bug.

    ### Worktrees
    - Track A: /tmp/debug-track-a
    - Track B: /tmp/debug-track-b

    ### Progress Docs
    - Track A: /tmp/debug-track-a-progress.md
    - Track B: /tmp/debug-track-b-progress.md

    ### Bug Description
    {bug_description}

    ### Steps

    1. READ the context file (/tmp/debug-context.md) for:
       - Relevant files and code snippets
       - Observations about entry points and dependencies
       - Suggested test commands

    2. ASSESS reproducibility - determine which mode applies:
       - CLI-reproducible: Can be triggered via command (npm test, curl, script)
       - UI-dependent: Requires browser interaction (use chrome-devtools-testing)
       - Manual-only: Requires specific user actions or timing

    3. DECIDE and ACT based on assessment:

       If CLI-reproducible:
       - Write a minimal `debug-repro.{js|py|sh}` script
       - The script should trigger the bug and exit non-zero on failure
       - Copy the script to BOTH worktrees:
         * /tmp/debug-track-a/debug-repro.{ext}
         * /tmp/debug-track-b/debug-repro.{ext}
       - Verify it fails by running it
       - Set REPRO_MODE: AUTO

       If UI-dependent but automatable:
       - Note that chrome-devtools-testing skill should be used
       - Document the browser actions needed
       - Set REPRO_MODE: SEMI_AUTO

       If manual-only (requires human interaction, timing, specific state):
       - Document what the user needs to do to trigger the bug
       - Set REPRO_MODE: MANUAL
       - This is a valid outcome - not all bugs can be auto-reproduced

    4. UPDATE BOTH progress docs with your assessment:

       ## Track 0 - Repro Assessment

       REPRO_MODE: AUTO | SEMI_AUTO | MANUAL
       REPRO_SCRIPT: debug-repro.{ext} | null
       REPRO_COMMAND: {command to run} | "User triggers manually"
       REPRO_RATIONALE: {why this mode was chosen}

       ### Assessment Notes
       {any relevant observations about the bug's reproducibility}

    IMPORTANT: Your job is ONLY to establish repro. Do not:
    - Add [DEBUG_AGENT] instrumentation
    - Attempt to diagnose the root cause
    - Propose fixes

    Both Track A and Track B will use your repro strategy for their debug iterations.
    ```
  </repro_subagent_prompt>

  <track_0_orchestrator_prompt>
    Use this prompt for the Track 0 Orchestrator - runs synchronously before Track A/B.
    It coordinates Context Builder (GPT 5.2) and Repro Assessment (Opus sub-subagent).

    ```
    ## Track 0 Orchestrator

    You are the Track 0 Orchestrator. Your job is to:
    1. Run the Context Builder (GPT 5.2 medium via Codex)
    2. Spawn the Repro Assessment sub-subagent (Opus)

    ### Bug Description
    {bug_description}

    ### Project Root
    {project_root}

    ### Worktrees
    - Track A: /tmp/debug-track-a
    - Track B: /tmp/debug-track-b

    ### Progress Docs
    - Track A: /tmp/debug-track-a-progress.md
    - Track B: /tmp/debug-track-b-progress.md

    ### Step 1: Context Builder (GPT 5.2 medium)

    Write the context builder prompt to /tmp/debug-context-prompt.md, then launch:

    ```bash
    debug-mode context run /tmp/debug-context-prompt.md {project_root}
    ```

    Poll until complete:
    ```bash
    debug-mode context poll
    ```

    The Context Builder will:
    - Search the codebase for relevant files
    - Bundle them with repomix into /tmp/debug-context.md
    - Add analysis summary for subsequent subagents

    See <context_builder_prompt> for the prompt to write.

    ### Step 2: Repro Assessment (Opus sub-subagent)

    After Context Builder completes, spawn the Repro Assessment:

    ```
    Task(
      subagent_type="general-purpose",
      model="opus",
      prompt="{repro_subagent_prompt}",
      run_in_background=false
    )
    ```

    The Repro Assessment will:
    - Read the context file
    - Determine REPRO_MODE (AUTO/SEMI_AUTO/MANUAL)
    - Write repro scripts to both worktrees (if AUTO)
    - Update both progress docs

    See <repro_subagent_prompt> for the prompt this sub-subagent receives.

    ### Completion

    When both steps complete, summarize:
    - Context file location: /tmp/debug-context.md
    - REPRO_MODE determined
    - REPRO_COMMAND (if AUTO)
    - Any issues encountered

    Track A and Track B orchestrators will use this context and repro strategy.
    ```
  </track_0_orchestrator_prompt>

  <verification_subagent_prompt>
    Use this prompt for Subagent 4 (final verification) in either track.
    This subagent does NOT propose new fixes - it only verifies the existing fix.

    ```
    ## Debug Track {A|B} - Subagent 4 (Final Verification)

    ### Your Role
    You are the FINAL VERIFICATION subagent. Your job is to rigorously verify
    that the fix from previous subagents is correct and complete.

    DO NOT propose or attempt new fixes. Only verify.

    ### Your Worktree
    Path: {/tmp/debug-track-a or /tmp/debug-track-b}

    ### Progress Document
    Path: {/tmp/debug-track-a-progress.md or /tmp/debug-track-b-progress.md}

    ### Verification Steps

    1. READ PROGRESS DOC
       - Understand the fix that was applied
       - Review the root cause analysis
       - Note the REPRO_COMMAND from Track 0

    2. FRESH EYES CODE REVIEW (Critical Step)
       Read the fix code with completely fresh eyes. Look carefully for:
       - Obvious bugs, errors, or typos in the fix
       - Off-by-one errors, null pointer issues, race conditions
       - Edge cases that could still trigger the bug
       - Whether the fix actually addresses the root cause
       - Any side effects or regressions the fix might introduce
       - Anything that looks wrong, confusing, or suspicious

       Be skeptical. Don't assume the fix is correct. Question everything.

    3. RUN REPRODUCTION
       - Execute REPRO_COMMAND
       - Confirm the bug no longer occurs
       - Document the output

    4. RUN TEST SUITE (if available)
       - Run existing tests
       - Confirm no regressions
       - Document results

    5. CHECK EDGE CASES
       - Test boundary conditions related to the fix
       - Test null/empty/error cases if relevant
       - Document any failures

    6. UPDATE PROGRESS DOC
       ```markdown
       ## Iteration 4 - Final Verification

       ### Fix Reviewed
       {summary of the fix from previous iterations}

       ### Fresh Eyes Code Review
       - Bugs/errors spotted: {list or "None"}
       - Edge cases missed: {list or "None"}
       - Potential regressions: {list or "None"}

       ### Verification Results
       REPRO_RESULT: PASS | FAIL
       TESTS_RESULT: PASS | FAIL | N/A
       EDGE_CASES: PASS | FAIL | N/A

       ### Signal
       One of:
       - READY_FOR_FIX: Fresh eyes review passed, all tests passed, fix is correct
       - NEEDS_MORE_WORK: {specific issues that need addressing}
       ```

    If verification fails, clearly document WHAT failed and WHY so the main
    agent can decide whether to continue iterating or synthesize findings.
    ```
  </verification_subagent_prompt>

  <judge_subagent_prompt>
    Use this prompt for the Judge subagent that compares Track A and Track B.

    ```
    ## Judge Subagent

    You are the Judge for debug mode. Both Track A and Track B have completed
    their debugging iterations. Your job is to compare them and pick the winner.

    ### Context Files to Read

    1. Codebase context (from Context Builder):
       ```bash
       cat /tmp/debug-context.md
       ```

    2. Meta prompts used for iterations:
       ```bash
       cat /tmp/debug-track-a-prompt.md
       cat /tmp/debug-track-b-prompt.md
       ```

    3. Progress documents (iteration results):
       ```bash
       cat /tmp/debug-track-a-progress.md
       cat /tmp/debug-track-b-progress.md
       ```

    4. Code changes in each track:
       ```bash
       debug-mode diff track-a
       debug-mode diff track-b
       ```

    ### Evaluation Criteria

    Score each track on:
    1. **Evidence Quality** (1-5): Is the fix backed by runtime evidence/logs?
    2. **Fix Simplicity** (1-5): Minimal changes? No unnecessary refactoring?
    3. **Verification Confidence** (1-5): Did reproduction pass? Tests pass?
    4. **Root Cause Accuracy** (1-5): Does the fix address the actual root cause?

    ### Output Format

    ```
    ## Track A Evaluation
    - Evidence Quality: X/5 - {reasoning}
    - Fix Simplicity: X/5 - {reasoning}
    - Verification Confidence: X/5 - {reasoning}
    - Root Cause Accuracy: X/5 - {reasoning}
    - Total: XX/20

    ## Track B Evaluation
    - Evidence Quality: X/5 - {reasoning}
    - Fix Simplicity: X/5 - {reasoning}
    - Verification Confidence: X/5 - {reasoning}
    - Root Cause Accuracy: X/5 - {reasoning}
    - Total: XX/20

    ## Verdict
    WINNER: track-a | track-b | COMPLEMENTARY

    ## Reasoning
    {Why this track won, or why both are needed if COMPLEMENTARY}
    ```

    COMPLEMENTARY means both fixes address different aspects of the bug and
    should be applied together. Only use this if truly necessary.
    ```
  </judge_subagent_prompt>

  <track_orchestrator_prompts>
    These prompts are given to the background subagents that manage each track.
    Note: Track 0 has already run - context and reproduction strategy are established.

    ## Track A Orchestrator (Opus background, chained with resume)

    You are the Track A orchestrator for debug mode. Your job is to manage:
    - A1 (Opus 4.5): Fix iteration via Task(model="opus") - NEW
    - A2 (Opus 4.5): Fix iteration via Task(resume) - RESUME from A1
    - A3 (Opus 4.5): Fix iteration via Task(resume) - RESUME from A2
    - A4 (GPT 5.2): Final verification via Codex

    Pattern: Opus -> Opus (resume) -> Opus (resume) -> GPT
    Token optimization: A1-A3 share context via resume, GPT provides fresh eyes for verification.

    Worktree: /tmp/debug-track-a
    Progress Doc: /tmp/debug-track-a-progress.md
    Context File: /tmp/debug-context.md

    IMPORTANT: Read the context file and progress doc FIRST to see:
    - Relevant files and code snippets from Context Builder
    - REPRO_MODE and REPRO_COMMAND from Track 0

    Each iteration follows: Hypothesize -> Instrument -> Reproduce -> Analyze

    Your Task:

    ITERATION 1 (Opus 4.5 - Fix Attempt):
    1. Spawn sub-subagent using Task(subagent_type="general-purpose", model="opus")
       with the prompt from meta_prompt_template
    2. Wait for it to complete - SAVE THE AGENT ID
    3. Read progress doc, check for signal

    ITERATION 2 (Opus 4.5 - Fix + Verify, RESUME from A1):
    1. Resume using Task(resume=<agent_id>, prompt="Continue debugging iteration 2.
       Read the progress doc for your previous findings. Iterate on the fix, then
       VERIFY if it works. If verified, signal READY_FOR_FIX.")
    2. Wait for it to complete - SAVE THE AGENT ID
    3. Read progress doc, check for signal:
       - READY_FOR_FIX: Track complete, exit early
       - CONTINUE/NEEDS_MORE_INFO: Proceed to iteration 3

    ITERATION 3 (Opus 4.5 - Fix + Verify, RESUME from A2):
    1. Resume using Task(resume=<agent_id>, prompt="Continue debugging iteration 3.
       Read the progress doc for your previous findings. Iterate on the fix, then
       VERIFY if it works. If verified, signal READY_FOR_FIX.")
    2. Wait for it to complete
    3. Read progress doc, check for signal:
       - READY_FOR_FIX: Track complete, exit early
       - CONTINUE/NEEDS_MORE_INFO: Proceed to iteration 4

    ITERATION 4 (GPT 5.2 - Final Verification, only if A2/A3 didn't verify):
    1. Write the prompt (from verification_subagent_prompt) to /tmp/debug-track-a-prompt.md
    2. Launch codex: debug-mode codex run track-a 4 /tmp/debug-track-a-prompt.md
    3. Poll until complete: debug-mode codex poll track-a
    4. Read progress doc for final signal

    When complete, summarize: fix applied, verification results, confidence level.

    ## Track B Orchestrator (Opus background, alternating pattern)

    You are the Track B orchestrator for debug mode. Your job is to manage:
    - B1 (GPT 5.2): Fix iteration via Codex
    - B2 (Opus 4.5): Fix iteration via Task(model="opus")
    - B3 (GPT 5.2): Fix iteration via Codex
    - B4 (Opus 4.5): Final verification via Task(model="opus")

    Pattern: GPT -> Opus -> GPT -> Opus (2x Opus, 2x GPT - true alternation)

    Worktree: /tmp/debug-track-b
    Progress Doc: /tmp/debug-track-b-progress.md
    Context File: /tmp/debug-context.md

    IMPORTANT: Read the context file and progress doc FIRST to see:
    - Relevant files and code snippets from Context Builder
    - REPRO_MODE and REPRO_COMMAND from Track 0

    Each iteration follows: Hypothesize -> Instrument -> Reproduce -> Analyze

    Your Task:

    ITERATION 1 (GPT 5.2 - Fix Attempt):
    1. Write the prompt (from meta_prompt_template) to /tmp/debug-track-b-prompt.md
    2. Launch codex: debug-mode codex run track-b 1 /tmp/debug-track-b-prompt.md
    3. Poll until complete: debug-mode codex poll track-b
    4. If FAILED, note error and continue
    5. Read progress doc, check for signal

    ITERATION 2 (Opus 4.5 - Fix + Verify):
    1. Spawn sub-subagent using Task(subagent_type="general-purpose", model="opus")
       with prompt: meta_prompt_template + "After fixing, VERIFY if it works.
       If verified, signal READY_FOR_FIX."
    2. Wait for it to complete
    3. Read progress doc, check for signal:
       - READY_FOR_FIX: Track complete, exit early
       - CONTINUE/NEEDS_MORE_INFO: Proceed to iteration 3

    ITERATION 3 (GPT 5.2 - Fix + Verify):
    1. Write the prompt (meta_prompt_template + verify instruction) to /tmp/debug-track-b-prompt.md
    2. Launch codex: debug-mode codex run track-b 3 /tmp/debug-track-b-prompt.md
    3. Poll until complete: debug-mode codex poll track-b
    4. Read progress doc, check for signal:
       - READY_FOR_FIX: Track complete, exit early
       - CONTINUE/NEEDS_MORE_INFO: Proceed to iteration 4

    ITERATION 4 (Opus 4.5 - Final Verification, only if B2/B3 didn't verify):
    1. Spawn sub-subagent using Task(subagent_type="general-purpose", model="opus")
       with the prompt from verification_subagent_prompt
    2. Wait for it to complete
    3. Read progress doc for final signal

    When complete, summarize: fix applied, verification results, confidence level.
  </track_orchestrator_prompts>

  <when_to_use>
    <trigger>User describes a bug that's hard to reproduce</trigger>
    <trigger>Standard fix attempts have failed</trigger>
    <trigger>Bug involves timing, race conditions, or state issues</trigger>
    <trigger>User says "I don't understand why this is happening"</trigger>
    <trigger>User explicitly activates with /debug command</trigger>
    <trigger>Bug behavior is inconsistent or intermittent</trigger>
    <trigger>CI/E2E test failures (Playwright, Cypress, Selenium, Puppeteer)</trigger>
    <trigger>Flaky tests that pass/fail intermittently</trigger>
    <trigger>Test timeouts or hanging tests</trigger>
  </when_to_use>

  <tool_integration>
    For browser/E2E bugs, subagents can use chrome-devtools-testing skill:
    - getConsoleMessages() captures [DEBUG_AGENT] logs from browser
    - getNetworkRequests() for API debugging
    - Screenshots for visual state verification
  </tool_integration>

  <iteration_expectations>
    Debug mode runs: Track 0 (repro) + Track A (up to 4) + Track B (up to 4)

    Model alternation per track:
    ```
    Track A: Claude (A1) → GPT (A2) → Claude (A3) → Claude (A4/verify)
    Track B: GPT (B1) → Claude (B2) → GPT (B3) → GPT (B4/verify)
    ```

    Flow with SKIP_TO_VERIFY:
    ```
    A1 (Claude) → A2 (GPT) approves → SKIP → A4 (Claude/verify)
                       OR
    A1 (Claude) → A2 (GPT) → A3 (Claude) → A4 (Claude/verify)
    ```

    Why alternate models:
    - "Fresh eyes" = different MODEL, not just different instance
    - GPT might catch what Claude missed (and vice versa)
    - Each track gets both perspectives, not just one

    Typical runs:
    - Simple bug: A1 fixes it, A2 (GPT) signals SKIP_TO_VERIFY, A4 confirms = 3 iterations
    - Complex bug: A1-A3 alternate models iterating, A4 verifies = 4 iterations
    - Very complex: Both tracks complete, main agent synthesizes best fix

    Each subagent reviews previous fix attempts and can modify/refine/revert.
    Do NOT give up after first failed fix. Iterate until verification passes.
  </iteration_expectations>

  <anti_patterns>
    <avoid name="Speculative fixes">
      WRONG: "Based on reading the code, I think the issue is X. Let me fix it."
      RIGHT: "Let me spawn both debug tracks to gather runtime evidence."
    </avoid>

    <avoid name="Single-track debugging">
      WRONG: "I'll just use Claude to debug this."
      RIGHT: "I'll run both Claude and GPT tracks for diverse perspectives."
    </avoid>

    <avoid name="Ignoring progress docs">
      WRONG: Each subagent starts fresh without reading previous work.
      RIGHT: Each subagent reads progress doc first, then builds upon it.
    </avoid>

    <avoid name="Abandoning cleanup">
      WRONG: "The bug is fixed. We're done."
      RIGHT: "Now I'll remove all [DEBUG_AGENT] logs and delete progress docs."
    </avoid>

    <avoid name="Premature early exit">
      WRONG: "Previous subagent found something, looks fine, EARLY EXIT."
      RIGHT: "Previous subagent found something. Let me verify by re-running reproduction
              and checking for edge cases before deciding if early exit is warranted."

      Early exit requires ALL 5 criteria to be met. When in doubt, continue investigating.
    </avoid>
  </anti_patterns>

  <example_session>
    User: "The form submission sometimes fails silently. No error, just nothing happens."

    Phase 1 - HYPOTHESIZE (main agent):
    1. Event handler not attached correctly on some renders
    2. Async validation failing silently
    3. Network request failing without error handling
    4. Race condition between form state and submit
    5. Browser extension interference
    6. CORS issue on certain requests

    Phase 2 - INITIALIZE (main agent):
    - Run: debug-mode init /path/to/project
    - Update progress docs with bug description and hypotheses

    Phase 3 - SPAWN TRACKS (main agent):
    - Track A: Task(subagent_type="general-purpose", prompt=track_a_orchestrator, run_in_background=true)
    - Track B: Task(subagent_type="general-purpose", prompt=track_b_orchestrator, run_in_background=true)

    Phase 4 - WAIT (main agent):
    - Both orchestrator subagents run independently in background
    - Track A orchestrator spawns: A1 -> A2 -> A3 (sub-subagents)
    - Track B orchestrator runs: codex B1 -> B2 (via tmux)
    - Main agent waits with TaskOutput(block=true) for both

    Phase 5 - SYNTHESIZE (main agent):
    - Track A concluded: Hypothesis 2 CONFIRMED (validation)
    - Track B concluded: Hypothesis 2 CONFIRMED (validation) + Hypothesis 4 partial
    - Both tracks agree: async validation is the root cause

    Phase 6 - FIX (main agent):
    Apply fix to main worktree: proper error state for validation failures (3 lines)

    Phase 7 - CLEANUP (main agent):
    - Run: debug-mode cleanup /path/to/project
    - Manually remove [DEBUG_AGENT] lines listed in output
  </example_session>
</debug_mode_skill>
