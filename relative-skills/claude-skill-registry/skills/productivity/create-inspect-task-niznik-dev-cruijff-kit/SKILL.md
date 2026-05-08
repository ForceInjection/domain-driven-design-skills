---
name: create-inspect-task
description: Create custom inspect-ai evaluation tasks through interacted, guided workflow. 
---

# Create Inspect Task

You help users create custom inspect-ai evaluation tasks through an interactive, guided workflow. Create well-documented, reusable evaluation scripts that follow inspect-ai best practices.

## Your Task

Guide the user through designing and implementing a custom inspect-ai evaluation task. Create a complete, runnable task file and comprehensive documentation that explains the design decisions and usage.

## Operating Modes

This skill supports two modes:

### Mode 1: Experiment-Guided (Recommended)
When an `experiment_summary.yaml` file exists (created by `design-experiment` skill), extract configuration to pre-populate:
- Dataset path and format
- Model information
- Evaluation objectives
- System prompts
- Common parameters

**Usage:** Run skill from experiment directory or provide path to experiment_summary.yaml

### Mode 2: Standalone
Create evaluation tasks from scratch without experiment context. User provides all configuration manually.

**Usage:** Run skill when no experiment exists or when creating general-purpose evaluation tasks

## Workflow

### Initial Setup (Both Modes)

1. **Check for experiment context**
   - Look for `experiment_summary.yaml` in current directory
   - If found, ask user: "I found an experiment summary. Would you like me to use it to configure the evaluation task?"
   - If user says yes, proceed with Mode 1
   - If no or not found, proceed with Mode 2

### Mode 1: Experiment-Guided Workflow

1. **Read experiment_summary.yaml** - Extract configuration
2. **Confirm extracted info** - Show user what was found (dataset, models, etc.)
3. **Understand evaluation objective** - What specific aspect to evaluate?
4. **Configure task-specific details** - Solver chain, scorers (guided by experiment context)
5. **Add task parameters** - Make the task flexible and reusable
6. **Generate code** - Create the complete task file with experiment integration
7. **Create documentation** - Write design documentation with experiment context
8. **Create log** - Document all decisions in `create-inspect-task.log`
9. **Provide usage guidance** - Show user how to run the task with their models

### Mode 2: Standalone Workflow

1. **Understand the objective** - What does the user want to evaluate?
2. **Configure dataset** - Guide dataset format selection and loading
3. **Design solver chain** - Build the solver pipeline (prompts, generation, etc.)
4. **Select scorers** - Choose appropriate scoring mechanisms
5. **Add task parameters** - Make the task flexible and reusable
6. **Generate code** - Create the complete task file
7. **Create documentation** - Write design documentation with rationale
8. **Create log** - Document all decisions in `create-inspect-task.log`
9. **Provide usage guidance** - Show user how to run the task

## Extracting Information from experiment_summary.yaml (Mode 1)

When operating in experiment-guided mode, extract the following information from the YAML structure:

### YAML Structure Overview

```yaml
experiment:
  name: string
  type: string
  question: string

data:
  training:
    path: string
    label: string
    format: string
    splits:
      train: int
      validation: int
      test: int

models:
  base:
    - name: string
      path: string

evaluation:
  system_prompt: string
  temperature: float

runs:
  - name: string
    type: string  # "fine-tuned" or "control"
    model: string
```

### Extraction Algorithm

```python
import yaml
from pathlib import Path

def extract_from_experiment_summary(path):
    """Extract configuration from experiment_summary.yaml"""
    with open(path, 'r') as f:
        config = yaml.safe_load(f)

    # Extract dataset configuration
    dataset_path = config['data']['training']['path']
    dataset_format = config['data']['training']['format']
    dataset_splits = config['data']['training']['splits']

    # Extract system prompt from evaluation section
    system_prompt = config['evaluation']['system_prompt']

    # Extract research question
    research_question = config['experiment']['question']
    experiment_type = config['experiment']['type']

    # Extract model information (first base model)
    base_models = config['models']['base']
    model_name = base_models[0]['name'] if base_models else None
    model_path = base_models[0]['path'] if base_models else None

    # Extract run names for documentation examples
    run_names = [run['name'] for run in config['runs']]
    control_runs = [run['name'] for run in config['runs'] if run['type'] == 'control']

    return {
        'dataset_path': dataset_path,
        'dataset_format': dataset_format,
        'dataset_splits': dataset_splits,
        'system_prompt': system_prompt,
        'research_question': research_question,
        'experiment_type': experiment_type,
        'model_name': model_name,
        'model_path': model_path,
        'run_names': run_names,
        'control_runs': control_runs
    }
```

### Key Fields to Extract

**From `experiment` section:**
- `question` → Research question/objective (informs evaluation goal)
- `type` → Experiment type (helps understand what's being compared)

**From `data.training` section:**
- `path` → Dataset path for evaluation
- `format` → Dataset format (json, parquet)
- `splits` → Sample counts (use test split for evaluation)

**From `models.base[]` section:**
- `name` → Model identifier
- `path` → Full path to base model (for usage examples)

**From `evaluation` section:**
- `system_prompt` → Use same prompt for consistency
- `temperature` → Default temperature setting

**From `runs[]` section:**
- `name` → Run identifiers (for documentation)
- `type` → Filter for "control" runs that need evaluation

### Presenting Extracted Information

After extraction, show the user what was found:

```markdown
## Configuration Extracted from Experiment

I found the following configuration in your experiment:

**Dataset:**
- Path: `/scratch/gpfs/.../data/green/capitalization/words_4L_80P_300.json`
- Format: JSON
- Splits: train (240), test (60)

**Models:**
- Llama-3.2-1B-Instruct
- Path: `/scratch/gpfs/.../pretrained-llms/Llama-3.2-1B-Instruct`

**System Prompt:**
```
{extracted_prompt or "(none)"}
```

**Research Question:**
{extracted_question}

I'll use this information to help configure your evaluation task. You can override any of these settings if needed.
```

### Validation

Check extracted information:
- ✓ Dataset path exists (verify with `ls`)
- ✓ Dataset format is supported (.json, .parquet, .jsonl)
- ✓ Model path exists (verify with `ls`)
- ✓ System prompt is properly formatted (string, not list)

If validation fails:
- Warn user but continue
- Ask user to provide correct information
- Log validation failures

## Logging

**IMPORTANT:** Create a detailed log file at `{task_directory}/create-inspect-task.log` that records all questions, answers, and decisions made during task creation.

### Log Format

```
[YYYY-MM-DD HH:MM:SS] ACTION: Description
Details: {specifics}
Result: {outcome}

```

### What to Log

- User's evaluation objective
- Dataset selection and configuration decisions
- Solver chain composition choices
- Scorer selection rationale
- Task parameter decisions
- File creation
- Any validation performed

### Example Log Entries

#### Mode 1: Experiment-Guided

```
[2025-10-24 14:30:00] MODE_SELECTION: Experiment-guided mode
Details: Found experiment_summary.yaml at /scratch/gpfs/MSALGANIK/mjs3/cap_4L_lora_lr_sweep/experiment_summary.yaml
Result: User confirmed to use experiment configuration

[2025-10-24 14:30:05] EXTRACT_CONFIG: Reading experiment_summary.yaml
Details: Parsing YAML structure: experiment, data, models, evaluation sections
Result: Successfully extracted configuration

[2025-10-24 14:30:10] EXTRACTED_DATASET: Dataset configuration
Details: Path: /scratch/gpfs/MSALGANIK/niznik/GitHub/cruijff_kit/data/green/capitalization/words_4L_80P_300.json
Format: JSON, Splits: train (240), test (60)
Result: Verified dataset exists (43KB)

[2025-10-24 14:30:15] EXTRACTED_SYSTEM_PROMPT: System prompt from experiment
Details: Prompt: "" (empty - no system message)
Result: Will use empty system prompt for consistency with training

[2025-10-24 14:30:20] EXTRACTED_RESEARCH_QUESTION: Scientific objective
Details: Compare LoRA ranks and learning rates for capitalization task
Result: Will design evaluation to measure exact match accuracy

[2025-10-24 14:30:25] EVALUATION_OBJECTIVE: User wants to evaluate capitalization accuracy
Details: Exact match (case-sensitive), using experiment dataset
Result: Will use match(location="exact", ignore_case=False) scorer for strict evaluation

[2025-10-24 14:30:30] SOLVER_CONFIG: Designing solver chain
Details: system_message(""), prompt_template("{prompt}"), generate(temp=0.0)
Result: Matches training configuration for consistency
```

#### Mode 2: Standalone

```
[2025-10-24 14:30:00] MODE_SELECTION: Standalone mode
Details: No experiment_summary.md found
Result: User will provide all configuration manually

[2025-10-24 14:30:05] EVALUATION_OBJECTIVE: User wants to evaluate sentiment classification
Details: Binary classification (positive/negative), using custom dataset in JSON format
Result: Will use match() scorer for exact matching, temperature=0.0 for consistency

[2025-10-24 14:30:15] DATASET_CONFIG: Selected JSON dataset format
Details: Dataset path: /scratch/gpfs/MSALGANIK/niznik/data/sentiment_test.json
Field mapping: input="text", target="sentiment"
Result: Will use hf_dataset with json format and custom record_to_sample function
```

## Questions to Ask

### 1. Evaluation Objective

**What do you want to evaluate?**
- Classification task? (sentiment, topic, entity type, etc.)
- Generation quality? (summarization, translation, etc.)
- Factual accuracy? (question answering, fact checking)
- Reasoning ability? (math, logic, chain-of-thought)
- Task-specific capability? (code generation, instruction following)

**What defines a correct answer?**
- Exact match with target?
- Contains specific information?
- Model-graded quality assessment?
- Multiple acceptable answers?

### 2. Dataset Configuration

**What dataset format do you have?**
- JSON file (`.json` or `.jsonl`)
- Parquet files (`.parquet`)
- HuggingFace dataset (specify dataset name)
- CSV file
- Custom format (will need conversion)

**Where is the dataset located?**
- Get full path to dataset
- Verify file exists if possible
- Check file size for sanity

**What are the field names?**
- Input field name (e.g., "question", "text", "prompt")
- Target/answer field name (e.g., "answer", "label", "output")
- Any metadata fields to preserve? (e.g., "category", "difficulty")

**Dataset structure specifics:**
- For JSON: Is it a single JSON file with nested structure or JSONL?
- For JSON with splits: Which field contains the test split?
- For Parquet: Is it a directory of parquet files?
- For HuggingFace: Dataset name and split to use?

**Example questions:**
- "Does your JSON file have a structure like `{'train': [...], 'test': [...]}`?"
- "Is each line a separate JSON object (JSONL format)?"
- "Do you need to load from a specific split like 'test' or 'validation'?"

### 3. Solver Configuration

**System message:**
- Do you want to provide instructions to the model via system message?
- What role should the model play? (e.g., "You are a helpful assistant", "You are an expert classifier")
- Default: empty string (no system message)

**Prompt template:**
- Should we use the input directly or wrap it in a template?
- Do you need chain-of-thought prompting?
- Default: `"{prompt}"` (direct input)

**Generation parameters:**
- **Temperature**:
  - 0.0 for deterministic, consistent answers (recommended for most evals)
  - Higher values (0.7-1.0) for creative tasks
- **Max tokens**: Maximum length of model response (default: model's default)
- **Top-p**: Nucleus sampling parameter (default: 1.0)

**Common solver patterns:**
- Simple generation: `[system_message(""), prompt_template("{prompt}"), generate()]`
- Chain-of-thought: `[chain_of_thought(), generate()]`
- Multiple-choice: `[multiple_choice()]` (don't add separate generate())
- Custom template: `[prompt_template("Answer: {prompt}\n"), generate()]`

### 4. Scorer Selection

**Based on evaluation objective, suggest scorers:**

**For exact matching:**
- `match()` - Target appears at beginning/end; ignores case, whitespace, punctuation
  - Options: `location="begin"/"end"/"any"`, `ignore_case=True/False`
- `exact()` - Precise matching after normalization
- `includes()` - Target appears anywhere in output
  - Options: `ignore_case=True/False`

**For multiple choice:**
- `choice()` - Works with `multiple_choice()` solver
- Returns letter of selected answer (A, B, C, D, etc.)

**For pattern extraction:**
- `pattern()` - Extract answer using regex
  - Requires regex pattern parameter

**For model-graded evaluation:**
- `model_graded_qa()` - Another model assesses answer quality
  - Options: `partial_credit=True/False`, custom `template`
- `model_graded_fact()` - Checks if specific facts appear
- Note: Requires additional model, adds latency and cost

**For numeric/F1 scoring:**
- `f1()` - F1 score for text overlap

**Multiple scorers:**
- Can use a list: `[match(), includes()]` to get multiple scores
- Helpful for comparing scoring methods

### 5. Task Parameters

**Should the task accept parameters for flexibility?**

**Common parameters to expose:**
- `system_prompt` - Allow different system messages
- `temperature` - Enable temperature tuning
- `dataset_path` - Support different datasets
- `grader_model` - For model-graded scoring
- `config_dir` - For integration with fine-tuning runs (like existing `cap_task`)

**Benefits of parameters:**
- Run variations without code changes
- Easier experimentation
- Better reusability

**How to pass parameters:**
```bash
inspect eval task.py -T param_name=value
```

### 6. Model Specification

**How will the model be specified?**

**Option 1: CLI specification (most flexible)**
- User provides model at runtime
- `inspect eval task.py --model hf/local -M model_path=/path/to/model`
- Recommended for most cases

**Option 2: Integration with fine-tuning config**
- Like existing `cap_task` example
- Reads from `setup_finetune.yaml`
- Takes `config_dir` parameter pointing to epoch directory
- Best for evaluating fine-tuned models from experiments

**Option 3: Hard-coded in task**
- Less flexible but simpler
- Can specify model inside task definition
- Better for benchmarking specific models

## Output Files

Create two files:

### 1. Task Script: `{task_name}_task.py`

The complete, runnable inspect-ai task following best practices.

**File naming convention:**
- Descriptive name: `sentiment_classification_task.py`
- Include domain: `math_reasoning_task.py`
- Follow pattern: `{domain}_{type}_task.py`

**Required components:**
```python
from inspect_ai import Task, task
from inspect_ai.dataset import json_dataset, hf_dataset, FieldSpec
from inspect_ai.solver import chain, generate, prompt_template, system_message
from inspect_ai.scorer import match, includes

@task
def my_task(param1: str = "default"):
    """
    Brief description of what this task evaluates.

    Args:
        param1: Description of parameter

    Returns:
        Task: Configured inspect-ai task
    """

    # Dataset loading
    dataset = ...

    # Solver chain
    solver = chain(
        system_message("..."),
        prompt_template("{prompt}"),
        generate({"temperature": 0.0})
    )

    # Return task
    return Task(
        dataset=dataset,
        solver=solver,
        scorer=...
    )
```

**Best practices to follow:**
- Use type hints for parameters
- Include docstring explaining purpose
- Add comments explaining non-obvious choices
- Handle errors gracefully (try/except for file operations)
- Validate required parameters
- Use descriptive variable names

### 2. Design Documentation: `{task_name}_design.md`

Comprehensive documentation of design decisions.

**Required sections:**

```markdown
# {Task Name} Evaluation Task

**Created:** {timestamp}
**Inspect-AI Version:** {version if known}

## Evaluation Objective

{What this task evaluates and why}

## Dataset Configuration

**Format:** {JSON/Parquet/HuggingFace/etc.}
**Location:** `{full_path_to_dataset}`
**Size:** {number of samples if known}

**Field Mapping:**
- Input field: `{field_name}`
- Target field: `{field_name}`
- Metadata fields: `{field_names or "none"}`

**Loading Method:**
{Description of how dataset is loaded}

**Data Structure:**
{Explanation of JSON structure, splits, etc.}

## Solver Chain

**Components:**
1. {Solver 1}: {Purpose}
2. {Solver 2}: {Purpose}
3. ...

**System Message:**
```
{system message text or "none"}
```

**Prompt Template:**
```
{template or "direct input"}
```

**Generation Parameters:**
- Temperature: {value} - {rationale}
- Max tokens: {value or "default"} - {rationale}
- {Other parameters if any}

**Rationale:**
{Why this solver chain was chosen}

## Scorer Configuration

**Primary Scorer:** `{scorer_name}()`

**Options:**
- {option1}: {value} - {reason}
- {option2}: {value} - {reason}

**Additional Scorers:**
{List if multiple scorers used, or "none"}

**Rationale:**
{Why this scorer is appropriate for the task}

## Task Parameters

| Parameter | Type | Default | Purpose |
|-----------|------|---------|---------|
| {param1} | {type} | {default} | {description} |

**Parameter Usage:**
```bash
inspect eval {task_file}.py -T {param}={value}
```

## Model Specification

**Recommended usage:**
```bash
inspect eval {task_file}.py --model hf/local -M model_path=/path/to/model
```

{Any specific notes about model compatibility}

## Example Usage

**Basic evaluation:**
```bash
inspect eval {task_name}_task.py --model hf/local -M model_path=/path/to/model
```

**With parameters:**
```bash
inspect eval {task_name}_task.py --model hf/local -M model_path=/path/to/model -T temperature=0.5
```

**Evaluating fine-tuned model:** {if applicable}
```bash
cd /path/to/experiment/run/epoch_0
inspect eval {task_name}_task.py --model hf/local -M model_path=$PWD -T config_dir=$PWD
```

## Output Files

Inspect-ai will create:
- `logs/{task_name}_{timestamp}.eval` - Evaluation results log
- Console output with accuracy and metrics

## Expected Performance

{If known, describe expected baseline performance or what good performance looks like}

## Notes

{Any additional considerations, limitations, or future improvements}

## References

- Inspect-AI documentation: https://inspect.aisi.org.uk/
- {Any other relevant references}
```

## Code Generation Guidelines

### Dataset Loading Patterns

**JSON with nested splits:**
```python
from inspect_ai.dataset import hf_dataset

def record_to_sample(record):
    return Sample(
        input=record["input"],
        target=record["output"]
    )

dataset = hf_dataset(
    path="json",
    data_files="/path/to/data.json",
    field="test",  # Access the "test" split
    split="train",  # Don't get confused - this refers to top-level split
    sample_fields=record_to_sample
)
```

**JSONL (one JSON object per line):**
```python
from inspect_ai.dataset import json_dataset

def record_to_sample(record):
    return Sample(
        input=record["question"],
        target=record["answer"]
    )

dataset = json_dataset(
    "/path/to/data.jsonl",
    record_to_sample
)
```

**Parquet directory:**
```python
from inspect_ai.dataset import hf_dataset, FieldSpec

dataset = hf_dataset(
    path="parquet",
    data_dir="/path/to/parquet_dir",
    split="test",
    sample_fields=FieldSpec(
        input="question",
        target="answer"
    )
)
```

**HuggingFace dataset:**
```python
from inspect_ai.dataset import hf_dataset, FieldSpec

dataset = hf_dataset(
    path="username/dataset-name",
    split="test",
    sample_fields=FieldSpec(
        input="question",
        target="answer",
        metadata=["category", "difficulty"]  # Preserve metadata
    )
)
```

### Solver Chain Patterns

**Simple generation:**
```python
from inspect_ai.solver import chain, generate, prompt_template, system_message

solver = chain(
    system_message(""),  # Empty if no system message needed
    prompt_template("{prompt}"),  # Direct input
    generate({"temperature": 0.0})
)
```

**With system message and custom template:**
```python
solver = chain(
    system_message("You are an expert classifier. Respond with only the category label."),
    prompt_template("Text: {prompt}\n\nCategory:"),
    generate({"temperature": 0.0, "max_tokens": 50})
)
```

**Chain-of-thought:**
```python
from inspect_ai.solver import chain_of_thought, generate

solver = chain(
    chain_of_thought(),  # Adds "Let's think step by step" prompt
    generate({"temperature": 0.0})
)
```

**Multiple choice:**
```python
from inspect_ai.solver import multiple_choice

solver = multiple_choice()  # Don't add generate() separately
# Or with chain-of-thought:
solver = multiple_choice(cot=True)
```

### Scorer Patterns

**Exact matching (case-insensitive):**
```python
from inspect_ai.scorer import match

scorer = match()  # Default: ignore case, whitespace, punctuation
# Or customize:
scorer = match(location="exact", ignore_case=False)
```

**Substring matching:**
```python
from inspect_ai.scorer import includes

scorer = includes()  # Default: case-sensitive
# Or:
scorer = includes(ignore_case=True)
```

**Multiple scorers:**
```python
scorer = [
    match("exact", ignore_case=False),
    includes(ignore_case=False)
]
# Results will show scores from both
```

**Model-graded:**
```python
from inspect_ai.scorer import model_graded_qa

scorer = model_graded_qa(
    partial_credit=True,  # Allow 0.5 scores
    model="openai/gpt-4o"  # Specify grading model
)
```

## Integration with Fine-Tuning Workflow

### Experiment-Guided Task Creation (Recommended)

When creating tasks for an experiment:

1. **Run from experiment directory:**
   ```bash
   cd /scratch/gpfs/MSALGANIK/mjs3/my_experiment/
   # Invoke create-inspect-task skill
   ```

2. **Skill automatically extracts from experiment_summary.yaml:**
   - Dataset path and format
   - System prompt (ensures eval matches training)
   - Model information
   - Research objectives

3. **Task supports both modes:**
   - **config_dir mode**: Reads from `setup_finetune.yaml` (for fine-tuned models)
   - **dataset_path mode**: Direct dataset path (for base models and flexibility)

### Generated Task Pattern

**For tasks integrated with experiments:**

```python
import yaml
from pathlib import Path

@task
def my_task(
    config_dir: Optional[str] = None,
    dataset_path: Optional[str] = None,
    system_prompt: str = "",
    temperature: float = 0.0,
    split: str = "test"
) -> Task:
    """
    Evaluate model using configuration from fine-tuning setup or direct paths.

    Args:
        config_dir: Path to epoch directory (contains ../setup_finetune.yaml).
                   If provided, reads dataset path and system prompt from config.
        dataset_path: Direct path to dataset JSON file. Used if config_dir not provided.
        system_prompt: System message for the model. Overrides config if both provided.
        temperature: Generation temperature (default: 0.0 for deterministic output).
        split: Which data split to use (default: "test").

    Returns:
        Task: Configured inspect-ai task
    """

    # Determine configuration source
    if config_dir:
        # Mode 1: Read from fine-tuning configuration
        config_path = Path(config_dir).parent / "setup_finetune.yaml"

        with open(config_path, 'r') as f:
            config = yaml.safe_load(f)

        # Extract settings from fine-tuning config
        dataset_path = config['input_dir_base'] + config['dataset_label'] + config['dataset_ext']

        # Use system prompt from config unless overridden
        if not system_prompt:
            system_prompt = config.get('system_prompt', '')

    elif dataset_path:
        # Mode 2: Direct dataset path
        # system_prompt and other params used as provided
        pass
    else:
        raise ValueError("Must provide either config_dir or dataset_path")

    # Load dataset
    dataset = ...  # Load using dataset_path

    return Task(
        dataset=dataset,
        solver=chain(
            system_message(system_prompt),
            prompt_template("{prompt}"),
            generate({"temperature": temperature})
        ),
        scorer=...
    )
```

### Usage Examples

**Evaluating fine-tuned model from experiment:**
```bash
cd /path/to/experiment/run_dir/epoch_0
inspect eval /path/to/my_task.py --model hf/local -M model_path=$PWD -T config_dir=$PWD
```

**Evaluating base model (control run):**
```bash
inspect eval my_task.py \
  --model hf/local \
  -M model_path=/scratch/gpfs/MSALGANIK/pretrained-llms/Llama-3.2-1B-Instruct \
  -T dataset_path=/path/to/dataset.json
```

### Integration with setup_inspect.py (Future)

This task pattern enables integration with the `setup_inspect.py` tool (when implemented):
```bash
python tools/inspect/setup_inspect.py --finetune_epoch_dir /path/to/experiment/run/epoch_0
```

## Validation Before Completion

### Common Validation (Both Modes)

Before finishing, verify:
- ✓ Task file is syntactically correct Python
- ✓ All imports are present
- ✓ Task decorated with `@task`
- ✓ Dataset loading code matches format
- ✓ Solver chain follows inspect-ai patterns
- ✓ Scorer is appropriate for task
- ✓ Design documentation includes all sections
- ✓ Example usage commands are correct
- ✓ Log file documents all decisions

### Mode 1 Specific Validation

Additional checks for experiment-guided mode:
- ✓ experiment_summary.yaml was successfully parsed
- ✓ Extracted dataset path exists and format matches
- ✓ System prompt matches training configuration
- ✓ Task supports both `config_dir` and `dataset_path` parameters
- ✓ Documentation includes experiment context (research question, runs)
- ✓ Usage examples show both fine-tuned and base model evaluation
- ✓ Log includes extraction details and validation results

## Next Steps After Creation

After creating the task, guide user:

1. **Test the task:**
   ```bash
   # Validate syntax
   python -m py_compile {task_file}.py

   # Test with small sample
   inspect eval {task_file}.py --model {model} --limit 5
   ```

2. **Run full evaluation:**
   ```bash
   inspect eval {task_file}.py --model {model}
   ```

3. **View results:**
   ```bash
   inspect view
   # Opens web UI to browse evaluation logs
   ```

4. **Iterate if needed:**
   - Adjust scorer settings
   - Modify prompts
   - Change generation parameters
   - Use `inspect score` to re-score without re-running

## Important Notes

### General Best Practices
- Follow inspect-ai best practices from https://inspect.aisi.org.uk/
- Always include docstrings and comments
- Make tasks parameterized for flexibility
- Create comprehensive documentation for reproducibility
- Use type hints for parameters
- Handle errors gracefully
- Validate dataset paths when possible
- Keep generation temperature at 0.0 for consistency unless user needs creativity
- Prefer simple scorers (match, includes) over model-graded when possible
- Test with small samples first (`--limit 5`)

### Experiment Integration
- **Prefer Mode 1 (experiment-guided)** when working with designed experiments
- Always check for experiment_summary.yaml before starting
- Extract and validate all configuration before proceeding
- **System prompt consistency is critical** - eval must match training
- Generated tasks should work for both fine-tuned and base models
- Include experiment context in documentation (research question, runs)
- Use `config_dir` parameter pattern for experiment integration
- Log all extraction and validation steps for reproducibility

## Error Handling

**If dataset file not found:**
- Warn user but proceed with code generation
- Note in documentation that path should be verified
- Include validation suggestion in next steps

**If unsure about dataset format:**
- Ask for example record
- Offer to help convert to supported format
- Suggest user examine file structure

**If scorer choice unclear:**
- Recommend starting with simple scorers
- Suggest using multiple scorers for comparison
- Note that scorers can be changed later without re-running generation
