---
name: strategy-synthesis
description: Combine findings from parallel intelligence gathering into unified execution plan. Synthesize predictions, web research, deep strategy, and environment observations into optimal approach. Use when multiple intelligence sources need integration before execution.
allowed-tools: Execute, Read, Grep
---

# Strategy Synthesis

Apex2's critical "Strategy Synthesis" phase that connects parallel intelligence gathering to optimized execution.

## Instructions

When invoked (typically with structured findings from orchestrator), synthesize all intelligence sources into a unified, actionable execution plan.

### 1. Data Ingestion Process

### Method 1: Orchestrator Invocation (Primary)
The orchestrator should invoke this skill with structured findings:

```
Invoke strategy-synthesis to integrate these findings:

Prediction Analysis:
- Task Type: ML/DL training
- Complexity: Medium
- Risk Profile: Medium (resource intensive)
- Key Files: train.py, model.py, data.py
- Requirements: GPU, pytorch

Web Research Findings:
- Solution 1: Pytorch DataLoader batch_size=32 recommendation (stackoverflow)
- Solution 2: Mixed precision training code example (GitHub)
- Key insight: Training >5min, monitor validation loss

Deep Strategy Options:
- Approach A: Simple training with basic monitoring
- Approach B: Cross-validation with early stopping
- Approach C: Distributed training approach
- Common failures: GPU memory overflow, data loading bottlenecks

Environment State:
- PyTorch 2.1.0 installed, GPU available
- 16GB RAM, dataset 8GB fits
- CUDA working, can handle batch_size=64
- Current processes: none interfering

Previous Execution (Episode 1):
- Attempted: Simple training approach
- Result: Slow but working
- Issues: Training time > expected
```

### Method 2: Temporary File Access
If orchestrator writes findings to `/tmp/apex2-findings.txt`:

```bash
# Read structured findings file
cat /tmp/apex2-findings.json
```

### Method 3: Execute-based Data Retrieval
If orchestrator sets environment variables:

```bash
# Check for structured data
echo "Prediction: $APEX2_PREDICTION"
echo "Web: $APEX2_WEB"
echo "Strategy: $APEX2_STRATEGY"
echo "Environment: $APEX2_ENV"
```

### Method 4: Context Parsing (Fallback)
Parse conversation history for structured intelligence blocks.

### 2. Synthesis Process

### Step 1: Cross-Reference Analysis
- **Compare web solutions with environment capabilities**: Can we implement the GitHub solutions?
- **Match strategy options with task complexity**: Is Approach B appropriate for Medium complexity?
- **Validate requirements against state**: Are GPU resources sufficient for recommended approach?
- **Identify contradictions**: Web solution requires library not installed?

### Step 2: Prioritization Matrix
Rate each approach based on multiple criteria:

| Approach | Feasibility | Efficiency | Risk | Robustness | **Total** |
|-----------|-------------|------------|------|------------|----------|
| Approach A | High | Medium | Low | High | **8/12** |
| Approach B | Medium | High | Medium | High | **9/12** |
| Approach C | Low | Very High | High | Medium | **8/12** |

### Step 3: Risk-Adapted Selection
Based on task category and risk profile:

**For ML/DL tasks** (medium risk): Choose Approach B (cross-validation) with:
- Enhanced monitoring from web research
- Memory management from environment constraints
- Training parameters from prediction analysis

**For Security tasks** (high risk): Choose least destructive, most tested approach

**For Web Dev tasks** (low risk): Choose fastest implementation approach

### Step 4: Concrete Execution Planning
Generate step-by-step plan with specific adaptations:

```markdown
## Recommended Execution Plan: Enhanced Training (Approach B)

### Phase 1: Environment Preparation
1. Update configuration with batch_size=64 (web research + environment capability)
2. Set up mixed precision training (GitHub code adaptation)
3. Implement monitoring for training >5min (web research insight)

### Phase 2: Cross-Validation Setup
1. Split dataset into 5 folds (from strategy option B)
2. Configure early stopping parameters (adapt to environment constraints)
3. Set up GPU memory monitoring (address failure prediction)

### Phase 3: Training Execution
1. Run fold 1 training with enhanced monitoring
2. Validate results and adjust parameters
3. Continue with remaining folds if fold 1 succeeds

### Phase 4: Model Selection
1. Compare results across folds
2. Select best performing model
3. Validate on holdout dataset

### Risk Management:
- **Memory overflow**: Monitor GPU memory, reduce batch_size if needed
- **Training time**: Progress reporting every epoch, early stopping if no improvement
- **Data bottlenecks**: Pre-process data in batches to memory
```

### Step 5: Validation Criteria Definition
Define success metrics and validation steps:

```markdown
## Success Validation
- Training completes without memory errors
- All 5 folds execute without GPU overflow
- Cross-validation scores consistent (variance < 10%)
- Model performance meets baseline requirements

## Execution Validation
- Each phase completes successfully before proceeding
- Error recovery applied automatically if issues arise
- Training progress visible throughout >5min process
```

### 3. Output Structure

Provide structured output that orchestrator can parse:

```
[Strategy Synthesis Complete]
Recommended Approach: Enhanced Training (Approach B)
Confidence Level: High (compatible with environment, addresses risks)

Execution Plan:
Phase 1: Environment Preparation
  - Update config with batch_size=64
  - Implement mixed precision training
  - Set up enhanced monitoring

Phase 2: Cross-Validation Setup
  - Split data into 5 folds
  - Configure early stopping
  - Set up GPU memory monitoring

Phase 3: Training Execution
  - Run enhanced training with monitoring
  - Apply error recovery as needed
  - Progress reporting every epoch

Phase 4: Model Selection
  - Compare fold results
  - Select best model
  - Validate on holdout data

Risk Mitigations:
- Memory overflow: Adaptive batch sizing
- Training time: Early stopping + progress reporting  
- Data bottlenecks: Batch preprocessing

Validation Criteria:
- All folds complete without GPU errors
- Cross-validation consistency
- Model performance thresholds met

Backup Options:
- If memory issues: Fall back to Approach A (simpler training)
- If time constraints: Use subset of validation folds
- If GPU unavailable: Switch to CPU training (slower but works)
```

## Synthesis Patterns by Task Type

### Software Development
- **Combine environment constraints with web solutions**: Can we implement suggested libraries?
- **Match strategy options with codebase conventions**: Compatible with existing patterns?
- **Risk-adapt to production context**: Conservative approaches for production systems

### Data/ML Tasks  
- **Environment capability matching**: Hardware resources vs algorithm requirements
- **Research-based optimization**: Apply cutting-edge techniques if environment supports
- **Failure-prevention planning**: Memory, time, dependency issues addressed upfront

### Security Operations
- **Least-risk selection**: Choose most tested, least destructive approach
- **Environment verification**: Ensure backups and rollback capabilities
- **Validation-heavy planning**: Multiple checkpoints and verification steps

## When to Use

This skill is critical when:
- Multiple intelligence sources need integration before execution
- Task complexity requires strategic decision-making
- Environment constraints influence approach selection
- Risk management needs to inform execution planning
- You want to optimize success probability before execution

## Key Value

Strategy synthesis transforms disparate intelligence sources into a unified, optimized execution plan. Unlike simple "do this" approaches, it considers:

- **Real-world constraints** (environment limitations)
- **Proven solutions** (web research findings)  
- **Strategic alternatives** (deep strategy options)
- **Risk awareness** (prediction-based mitigation)

The result is an execution plan that's both intelligent and practical - the essence of Apex2's success.

## State Tracking

Skill should output synthesis completion for orchestrator to track:

```
[Apex2 State Update]
phase: synthesis
completed: true
output: unified-execution-plan
next: execution
```

This allows the orchestrator to maintain accurate state throughout the Apex2 workflow.
