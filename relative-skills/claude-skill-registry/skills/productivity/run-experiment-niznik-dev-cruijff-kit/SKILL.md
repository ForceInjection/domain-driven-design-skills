---
name: run-experiment
description: Execute the complete experimental workflow - model optimization followed by evaluation - for all runs in a scaffolded experiment. Use after scaffold-experiment to submit jobs to SLURM.  
---

## Your Task

Orchestrate experiment execution by reading tool specifications from experiment_summary.yaml and calling the appropriate tool modules **sequentially**:

1. Read experiment_summary.yaml to identify tools being used
2. Execute model optimization (fine-tuning) for all runs
3. Wait for optimization to complete (REQUIRED)
4. Execute model evaluation for all runs

This ensures the entire experiment runs from training through evaluation with proper dependency management.

## Prerequisites

- experiment_summary.yaml exists (from design-experiment skill)
- Scaffolding complete (from scaffold-experiment skill)
- SLURM cluster access

## Workflow

### High-Level Steps

1. **Locate experiment** - Find experiment directory (current dir or ask user)
2. **Verify scaffolding** - Ensure configs exist for optimization and evaluation
3. **Read tool specifications** - Parse experiment_summary.yaml "tools" section
4. **Execute optimization** - Call optimizer module (torchtune)
5. **Execute evaluation** - Call evaluator module (inspect) - **MUST wait for optimization**
6. **Create orchestration log** - Document process in `run-experiment.log`
7. **Report combined summary** - Show complete status

### Tool Modules

**Optimizer modules:** See [optimizers/](optimizers/) for tool-specific execution logic
- Currently supported: torchtune (fine-tuning)
- Future: DSPy (prompt optimization), custom trainers

**Evaluator modules:** See [evaluators/](evaluators/) for tool-specific execution logic
- Currently supported: inspect-ai
- Future: custom evaluation frameworks

### Detailed Workflows

For step-by-step execution details:
- **Torchtune execution:** [workflows/torchtune.md](workflows/torchtune.md)
- **Inspect execution:** [workflows/inspect.md](workflows/inspect.md)

## Reading Tool Specifications

Parse experiment_summary.yaml "tools" section to identify frameworks:

**Expected format:**
```yaml
tools:
  preparation: "torchtune"
  evaluation: "inspect-ai"
```

**Tool to module mapping:**
- `torchtune` → [optimizers/torchtune/](optimizers/torchtune/)
- `inspect-ai` → [evaluators/inspect/](evaluators/inspect/)

**If tools section missing:** Assume torchtune + inspect-ai (backward compatibility)

## Sequential Execution

**CRITICAL:** Evaluation MUST wait for optimization to complete.

**Why?** Evaluation jobs need optimized model checkpoints.

**Implementation:**
1. Execute optimizer module (torchtune fine-tuning)
2. Monitor until ALL optimization jobs complete
3. Only then execute evaluator module (inspect evaluation)
4. Monitor until ALL evaluation jobs complete
5. Report combined results

## Logging

Create orchestration log at `{experiment_dir}/run-experiment.log`:

**Log format:**
```
[YYYY-MM-DD HH:MM:SS] ACTION: Description
Details: {specifics}
Result: {outcome}
```

**What to log:**
- Experiment discovery and validation
- Scaffolding verification
- Tool module invocations (timestamps, results, durations)
- Completion status (successes/failures)
- Errors or warnings
- Final combined summary
- Paths to results and module logs

## Expected Outputs

After successful execution:

**Logs created:**
- `run-experiment.log` - Orchestration log
- Optimizer module logs (e.g., detailed fine-tuning execution)
- Evaluator module logs (e.g., detailed evaluation execution)

**Status updated:**
- Run tracking logs updated with job IDs, timestamps, states
- All execution details recorded in module logs

**Artifacts created:**
- Model checkpoints from optimization
- Evaluation logs from evaluation

**Logging:** All actions logged to `{experiment_dir}/run-{torchtune|inspect}.log` (see `logging.md`)

---

## Error Handling

**If experiment_summary.yaml not found:**
- Suggest running design-experiment skill first
- Do not proceed

**If scaffolding incomplete:**
- Report which parts missing
- Suggest running scaffold-experiment skill
- Can proceed with optimization only if just evaluation configs missing

**If optimization fails:**
- Log failure details
- Do NOT proceed to evaluation (missing model checkpoints)
- Report failure and stop

**If evaluation fails:**
- Log failure details
- Optimization results still valid
- Report partial success

**If user cancels:**
- SLURM jobs continue running independently
- Can resume monitoring by re-running skill

## Validation Checklist

Before reporting success, verify:
- ✓ experiment_summary.yaml found and read
- ✓ Scaffolding verified
- ✓ Optimizer module executed and completed
- ✓ Evaluator module executed and completed
- ✓ Model checkpoints exist
- ✓ Evaluation logs exist
- ✓ Orchestration log created
- ✓ All module logs exist

## Output Summary

Provide comprehensive summary after completion:

```markdown
## Run Experiment Complete

Experiment: `{experiment_dir}`

### Optimization Results

✓ {N}/{M} runs completed successfully
Duration: {duration}

**Completed runs:** [list with times]
**Failed runs:** [list with errors]
**Model checkpoints:** {paths}

### Evaluation Results

✓ {N}/{M} evaluations completed successfully
Duration: {duration}

**Completed evaluations:** [list with times]
**Failed evaluations:** [list with errors]
**Evaluation logs:** {paths}

### Total Time

Complete workflow: {total_duration}
- Optimization: {opt_duration}
- Evaluation: {eval_duration}

### Next Steps

1. View results: `inspect view --port=$(get_free_port)`
2. Export data: `inspect log export ...`
3. Analyze results (see experiment_summary.yaml for configuration)
```

## Important Notes

**Orchestration principles:**
- This skill orchestrates rather than implements
- Each tool module maintains its own detailed log
- Sequential execution is mandatory (evaluation requires optimization complete)
- Partial success is acceptable (some runs succeed, others fail)
- Tool modules can be executed independently if needed

**Relationship to other skills:**
- **Before:** design-experiment, scaffold-experiment
- **After:** analyze-experiment (planned)
- **Standalone:** Individual tool modules can run independently

**Resumability:**
- Re-running run-experiment is safe
- Tool modules check for completed jobs
- Won't re-submit successful jobs
