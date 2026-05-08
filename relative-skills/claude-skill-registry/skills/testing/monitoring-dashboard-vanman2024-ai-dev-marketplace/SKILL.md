---
name: monitoring-dashboard
description: Training monitoring dashboard setup with TensorBoard and Weights & Biases (WandB) including real-time metrics tracking, experiment comparison, hyperparameter visualization, and integration patterns. Use when setting up training monitoring, tracking experiments, visualizing metrics, comparing model runs, or when user mentions TensorBoard, WandB, training metrics, experiment tracking, or monitoring dashboard.
allowed-tools: Read, Write, Bash, Grep, Glob
---

# Monitoring Dashboard

**Purpose:** Provide complete monitoring dashboard templates and setup scripts for ML training with TensorBoard and Weights & Biases (WandB).

**Activation Triggers:**
- Setting up training monitoring dashboards
- Tracking experiments and metrics in real-time
- Comparing multiple training runs
- Visualizing hyperparameters and results
- Integrating monitoring into existing training pipelines
- Logging custom metrics, images, and model artifacts

**Key Resources:**
- `scripts/setup-tensorboard.sh` - Install and configure TensorBoard
- `scripts/setup-wandb.sh` - Install and configure Weights & Biases
- `scripts/launch-monitoring.sh` - Launch monitoring dashboards
- `templates/tensorboard-config.yaml` - TensorBoard configuration template
- `templates/wandb-config.py` - WandB integration template
- `templates/logging-config.json` - Unified logging configuration
- `examples/tensorboard-integration.md` - Complete TensorBoard integration guide
- `examples/wandb-integration.md` - Complete WandB integration guide

## Quick Start

### 1. Choose Monitoring Solution

**TensorBoard (Local/Open Source):**
- Free, runs locally
- Best for: Single-user development, offline work
- Features: Metrics, histograms, graphs, images, embeddings
- Storage: Local filesystem

**Weights & Biases (Cloud/Collaboration):**
- Free tier available, cloud-hosted
- Best for: Team collaboration, experiment comparison, production
- Features: All TensorBoard features + collaboration, alerts, reports
- Storage: Cloud with unlimited history

**Both (Recommended for Production):**
- Use TensorBoard for local development
- Use WandB for team collaboration and production tracking

### 2. Setup TensorBoard

```bash
# Install and configure TensorBoard
./scripts/setup-tensorboard.sh

# Launch TensorBoard
./scripts/launch-monitoring.sh tensorboard --logdir ./runs
```

**Access:** Open browser to http://localhost:6006

### 3. Setup Weights & Biases

```bash
# Install and configure WandB
./scripts/setup-wandb.sh

# Login with API key
wandb login

# Launch monitoring
./scripts/launch-monitoring.sh wandb
```

**Access:** Dashboard at https://wandb.ai/your-username/your-project

## TensorBoard Integration

### Basic Setup

**Template:** `templates/tensorboard-config.yaml`

```python
from torch.utils.tensorboard import SummaryWriter
import datetime

# Create TensorBoard writer
log_dir = f"runs/experiment_{datetime.datetime.now().strftime('%Y%m%d-%H%M%S')}"
writer = SummaryWriter(log_dir=log_dir)

# Log scalar metrics
writer.add_scalar('Loss/train', train_loss, epoch)
writer.add_scalar('Loss/validation', val_loss, epoch)
writer.add_scalar('Accuracy/train', train_acc, epoch)
writer.add_scalar('Accuracy/validation', val_acc, epoch)

# Log learning rate
writer.add_scalar('Learning_Rate', optimizer.param_groups[0]['lr'], epoch)

# Close writer when done
writer.close()
```

### Advanced Logging

**Histograms (Weight Distributions):**
```python
# Log model weights
for name, param in model.named_parameters():
    writer.add_histogram(f'weights/{name}', param, epoch)
    writer.add_histogram(f'gradients/{name}', param.grad, epoch)
```

**Images:**
```python
# Log sample predictions
writer.add_image('predictions', image_grid, epoch)
writer.add_images('batch_samples', image_batch, epoch)
```

**Text:**
```python
# Log hyperparameters as text
config_text = '\n'.join([f'{k}: {v}' for k, v in config.items()])
writer.add_text('hyperparameters', config_text, 0)
```

**Model Graph:**
```python
# Log model architecture
writer.add_graph(model, input_tensor)
```

**Embeddings (t-SNE, PCA):**
```python
# Visualize embeddings
writer.add_embedding(embeddings, metadata=labels, label_img=images)
```

### Launch TensorBoard

```bash
# Basic launch
tensorboard --logdir runs

# Specify port
tensorboard --logdir runs --port 6007

# Load faster (sample data)
tensorboard --logdir runs --samples_per_plugin scalars=1000

# Enable reload
tensorboard --logdir runs --reload_interval 5
```

## Weights & Biases Integration

### Basic Setup

**Template:** `templates/wandb-config.py`

```python
import wandb

# Initialize WandB run
wandb.init(
    project="my-ml-project",
    name=f"experiment-{datetime.now().strftime('%Y%m%d-%H%M%S')}",
    config={
        "learning_rate": 0.001,
        "epochs": 100,
        "batch_size": 32,
        "model": "resnet50",
        "dataset": "imagenet"
    }
)

# Log metrics
wandb.log({
    "train_loss": train_loss,
    "val_loss": val_loss,
    "train_acc": train_acc,
    "val_acc": val_acc,
    "epoch": epoch
})

# Finish run
wandb.finish()
```

### Advanced Features

**Log Media:**
```python
# Log images
wandb.log({"predictions": [wandb.Image(img, caption=f"Pred: {pred}")]})

# Log tables
table = wandb.Table(columns=["epoch", "loss", "accuracy"], data=data)
wandb.log({"results_table": table})

# Log audio
wandb.log({"audio": wandb.Audio(audio_array, sample_rate=16000)})

# Log videos
wandb.log({"video": wandb.Video(video_path, fps=30)})
```

**Track Model Artifacts:**
```python
# Save model checkpoint
artifact = wandb.Artifact('model-checkpoint', type='model')
artifact.add_file('model.pth')
wandb.log_artifact(artifact)

# Load model from artifact
artifact = wandb.use_artifact('model-checkpoint:latest')
model_path = artifact.download()
```

**Hyperparameter Sweeps:**
```python
# Define sweep configuration
sweep_config = {
    'method': 'bayes',
    'metric': {'name': 'val_loss', 'goal': 'minimize'},
    'parameters': {
        'learning_rate': {'min': 0.0001, 'max': 0.1},
        'batch_size': {'values': [16, 32, 64]},
        'optimizer': {'values': ['adam', 'sgd', 'adamw']}
    }
}

# Initialize sweep
sweep_id = wandb.sweep(sweep_config, project="my-project")

# Run sweep agent
wandb.agent(sweep_id, function=train_model, count=10)
```

**Custom Charts:**
```python
# Create custom plot
data = [[x, y] for (x, y) in zip(x_values, y_values)]
table = wandb.Table(data=data, columns=["x", "y"])
wandb.log({
    "custom_plot": wandb.plot.line(table, "x", "y", title="Custom Plot")
})
```

**Alerts:**
```python
# Alert on metric threshold
if val_loss < 0.1:
    wandb.alert(
        title="Low Validation Loss",
        text=f"Validation loss dropped to {val_loss:.4f}",
        level=wandb.AlertLevel.INFO
    )
```

## Unified Logging Configuration

**Template:** `templates/logging-config.json`

Use this configuration to log to both TensorBoard and WandB simultaneously:

```python
import wandb
from torch.utils.tensorboard import SummaryWriter

class UnifiedLogger:
    def __init__(self, project_name, experiment_name, config):
        # TensorBoard
        self.tb_writer = SummaryWriter(
            log_dir=f"runs/{experiment_name}"
        )

        # WandB
        wandb.init(
            project=project_name,
            name=experiment_name,
            config=config
        )

    def log_metrics(self, metrics_dict, step):
        """Log to both TensorBoard and WandB"""
        # TensorBoard
        for key, value in metrics_dict.items():
            self.tb_writer.add_scalar(key, value, step)

        # WandB
        wandb.log(metrics_dict, step=step)

    def log_images(self, images_dict, step):
        """Log images to both platforms"""
        for key, image in images_dict.items():
            # TensorBoard
            self.tb_writer.add_image(key, image, step)

            # WandB
            wandb.log({key: wandb.Image(image)}, step=step)

    def log_model(self, model, input_sample):
        """Log model architecture"""
        # TensorBoard graph
        self.tb_writer.add_graph(model, input_sample)

        # WandB watches gradients
        wandb.watch(model, log="all", log_freq=100)

    def close(self):
        """Close both loggers"""
        self.tb_writer.close()
        wandb.finish()

# Usage
logger = UnifiedLogger(
    project_name="my-project",
    experiment_name="exp-001",
    config={"lr": 0.001, "batch_size": 32}
)

logger.log_metrics({
    "train_loss": 0.5,
    "val_loss": 0.6
}, step=epoch)

logger.close()
```

## Common Monitoring Patterns

### 1. Training Loop Integration

```python
for epoch in range(num_epochs):
    # Training phase
    model.train()
    train_loss = 0
    for batch_idx, (data, target) in enumerate(train_loader):
        loss = train_step(model, data, target, optimizer)
        train_loss += loss.item()

        # Log batch-level metrics
        global_step = epoch * len(train_loader) + batch_idx
        logger.log_metrics({
            "batch_loss": loss.item(),
            "learning_rate": optimizer.param_groups[0]['lr']
        }, step=global_step)

    # Validation phase
    model.eval()
    val_loss, val_acc = validate(model, val_loader)

    # Log epoch-level metrics
    logger.log_metrics({
        "epoch": epoch,
        "train_loss": train_loss / len(train_loader),
        "val_loss": val_loss,
        "val_acc": val_acc
    }, step=epoch)

    # Log model weights distribution
    for name, param in model.named_parameters():
        logger.tb_writer.add_histogram(f'weights/{name}', param, epoch)
```

### 2. Experiment Comparison

**TensorBoard:**
```bash
# Compare multiple runs
tensorboard --logdir_spec \
  exp1:runs/experiment_1,\
  exp2:runs/experiment_2,\
  exp3:runs/experiment_3
```

**WandB:**
```python
# Automatically compares all runs in project dashboard
# Filter and group runs by tags, config values, or custom fields
```

### 3. Real-Time Monitoring

**TensorBoard:**
```bash
# Auto-reload new data
tensorboard --logdir runs --reload_interval 5
```

**WandB:**
```python
# Real-time by default
# Enable email/slack alerts for key metrics
wandb.alert(
    title="Training Alert",
    text=f"Accuracy reached {acc:.2%}",
    level=wandb.AlertLevel.INFO
)
```

## Best Practices

### 1. Metric Naming Conventions

**Organize by category:**
```python
# Good: Hierarchical naming
"Loss/train"
"Loss/validation"
"Accuracy/train"
"Accuracy/validation"
"Metrics/precision"
"Metrics/recall"

# Bad: Flat naming
"train_loss"
"validation_loss"
"train_accuracy"
```

### 2. Logging Frequency

**Guidelines:**
- Scalars: Every batch or every N batches
- Histograms: Every epoch
- Images: Every epoch or every N epochs
- Model graph: Once at start
- Embeddings: Once per major checkpoint

```python
# Log batch metrics every 10 batches
if batch_idx % 10 == 0:
    logger.log_metrics({"batch_loss": loss}, step)

# Log epoch metrics
if batch_idx == len(train_loader) - 1:
    logger.log_metrics({"epoch_loss": epoch_loss}, epoch)

# Log images every 5 epochs
if epoch % 5 == 0:
    logger.log_images({"samples": sample_images}, epoch)
```

### 3. Disk Space Management

**TensorBoard:**
```bash
# Limit log retention
find runs/ -type d -mtime +30 -exec rm -rf {} +

# Compress old logs
tar -czf archive_$(date +%Y%m%d).tar.gz runs/old_experiments/
rm -rf runs/old_experiments/
```

**WandB:**
```python
# Cloud storage handles retention
# Configure retention in project settings
# Download important runs for local backup
wandb.restore('model.pth', run_path="user/project/run_id")
```

### 4. Security & Privacy

**TensorBoard:**
```bash
# Restrict access to localhost only
tensorboard --logdir runs --host 127.0.0.1

# Or use SSH tunnel for remote access
ssh -L 6006:localhost:6006 user@remote-server
```

**WandB:**
```python
# Use private projects
wandb.init(project="my-project", entity="private-team")

# Disable cloud sync for sensitive data
wandb.init(mode="offline")  # Logs locally only
```

## Troubleshooting

### TensorBoard Issues

**Problem: Dashboard not updating**
```bash
# Force reload
tensorboard --logdir runs --reload_interval 1

# Clear cache
rm -rf /tmp/.tensorboard-info/
```

**Problem: Port already in use**
```bash
# Use different port
tensorboard --logdir runs --port 6007

# Or kill existing process
pkill -f tensorboard
```

### WandB Issues

**Problem: Login fails**
```bash
# Re-login with API key
wandb login --relogin

# Or set via environment
export WANDB_API_KEY=your_api_key
```

**Problem: Slow logging**
```python
# Reduce logging frequency
wandb.init(settings=wandb.Settings(
    _disable_stats=True,  # Disable system metrics
    _disable_meta=True    # Disable metadata
))
```

## Scripts Usage

### Setup TensorBoard

```bash
./scripts/setup-tensorboard.sh

# Verifies:
# - Python environment
# - TensorBoard installation
# - Creates default log directory structure
```

### Setup WandB

```bash
./scripts/setup-wandb.sh

# Verifies:
# - WandB installation
# - API key configuration
# - Creates wandb config file
```

### Launch Monitoring

```bash
# TensorBoard
./scripts/launch-monitoring.sh tensorboard --logdir ./runs --port 6006

# WandB (opens browser to dashboard)
./scripts/launch-monitoring.sh wandb --project my-project

# Both
./scripts/launch-monitoring.sh both --logdir ./runs --project my-project
```

## Resources

**Scripts:**
- `setup-tensorboard.sh` - Install and configure TensorBoard
- `setup-wandb.sh` - Install and configure WandB
- `launch-monitoring.sh` - Launch monitoring dashboards

**Templates:**
- `tensorboard-config.yaml` - TensorBoard setup configuration
- `wandb-config.py` - WandB integration template
- `logging-config.json` - Unified logging configuration

**Examples:**
- `tensorboard-integration.md` - Complete TensorBoard integration
- `wandb-integration.md` - Complete WandB integration with sweeps

---

**Supported Frameworks:** PyTorch, TensorFlow, JAX, Hugging Face Transformers
**Python Version:** 3.8+
**Best Practice:** Use both TensorBoard (local dev) and WandB (team collaboration)
