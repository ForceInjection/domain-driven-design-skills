---
name: mlops-workflows
description: Comprehensive MLOps workflows for the complete ML lifecycle - experiment tracking, model registry, deployment patterns, monitoring, A/B testing, and production best practices with MLflow
version: 1.0.0
category: Machine Learning Operations
tags:
  - mlops
  - mlflow
  - experiment-tracking
  - model-registry
  - deployment
  - monitoring
  - ml-lifecycle
  - feature-stores
  - ci-cd
  - model-versioning
  - a-b-testing
  - production-ml
prerequisites:
  - Python 3.8+
  - MLflow 2.0+
  - scikit-learn
  - Understanding of ML model training workflows
---

# MLOps Workflows with MLflow

A comprehensive guide to production-grade MLOps workflows covering the complete machine learning lifecycle from experimentation to production deployment and monitoring.

## Table of Contents

1. [MLflow Components Overview](#mlflow-components-overview)
2. [Experiment Tracking](#experiment-tracking)
3. [Model Registry](#model-registry)
4. [Deployment Patterns](#deployment-patterns)
5. [Monitoring and Observability](#monitoring-and-observability)
6. [A/B Testing](#ab-testing)
7. [Feature Stores](#feature-stores)
8. [CI/CD for ML](#cicd-for-ml)
9. [Model Versioning](#model-versioning)
10. [Production Best Practices](#production-best-practices)

## MLflow Components Overview

MLflow consists of four primary components for managing the ML lifecycle:

### 1. MLflow Tracking

Track experiments, parameters, metrics, and artifacts during model development.

```python
import mlflow

# Set tracking URI
mlflow.set_tracking_uri("http://localhost:5000")

# Create or set experiment
mlflow.set_experiment("production-models")

# Start a run
with mlflow.start_run(run_name="baseline-model"):
    # Log parameters
    mlflow.log_param("learning_rate", 0.01)
    mlflow.log_param("batch_size", 32)

    # Log metrics
    mlflow.log_metric("accuracy", 0.95)
    mlflow.log_metric("loss", 0.05)

    # Log artifacts
    mlflow.log_artifact("model_plot.png")
```

### 2. MLflow Projects

Package ML code in a reusable, reproducible format.

```yaml
# MLproject file
name: my-ml-project
conda_env: conda.yaml

entry_points:
  main:
    parameters:
      learning_rate: {type: float, default: 0.01}
      epochs: {type: int, default: 100}
    command: "python train.py --lr {learning_rate} --epochs {epochs}"

  evaluate:
    parameters:
      model_uri: {type: string}
    command: "python evaluate.py --model-uri {model_uri}"
```

### 3. MLflow Models

Package models in a standard format for deployment across platforms.

```python
import mlflow.sklearn
from sklearn.ensemble import RandomForestClassifier

# Train model
model = RandomForestClassifier()
model.fit(X_train, y_train)

# Log model with signature
from mlflow.models import infer_signature
signature = infer_signature(X_train, model.predict(X_train))

mlflow.sklearn.log_model(
    sk_model=model,
    name="random-forest-model",
    signature=signature,
    input_example=X_train[:5],
    registered_model_name="ProductionClassifier"
)
```

### 4. MLflow Registry

Centralized model store for managing model lifecycle and versioning.

```python
from mlflow import MlflowClient

client = MlflowClient()

# Register model
model_uri = f"runs:/{run_id}/model"
registered_model = mlflow.register_model(
    model_uri=model_uri,
    name="CustomerChurnModel"
)

# Set model alias for deployment
client.set_registered_model_alias(
    name="CustomerChurnModel",
    alias="production",
    version=registered_model.version
)
```

## Experiment Tracking

### Basic Experiment Tracking

```python
import mlflow
import mlflow.sklearn
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, r2_score
from sklearn.model_selection import train_test_split

# Configure MLflow
mlflow.set_tracking_uri("http://localhost:5000")
mlflow.set_experiment("house-price-prediction")

# Load and prepare data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)

# Training with MLflow tracking
with mlflow.start_run(run_name="rf-baseline"):
    # Define parameters
    params = {
        "n_estimators": 100,
        "max_depth": 10,
        "min_samples_split": 5,
        "random_state": 42
    }

    # Train model
    model = RandomForestRegressor(**params)
    model.fit(X_train, y_train)

    # Evaluate
    predictions = model.predict(X_test)
    mse = mean_squared_error(y_test, predictions)
    r2 = r2_score(y_test, predictions)

    # Log everything
    mlflow.log_params(params)
    mlflow.log_metrics({
        "mse": mse,
        "r2": r2,
        "rmse": mse ** 0.5
    })

    # Log model
    mlflow.sklearn.log_model(
        sk_model=model,
        name="model",
        registered_model_name="HousePricePredictor"
    )
```

### Autologging

MLflow provides automatic logging for popular frameworks:

```python
import mlflow
from sklearn.ensemble import RandomForestClassifier

# Enable autologging for scikit-learn
mlflow.sklearn.autolog()

# Your training code - everything is logged automatically
with mlflow.start_run():
    model = RandomForestClassifier(n_estimators=100, max_depth=5)
    model.fit(X_train, y_train)
    predictions = model.predict(X_test)
```

### Nested Runs for Hyperparameter Tuning

```python
import mlflow
from sklearn.model_selection import GridSearchCV
from sklearn.ensemble import GradientBoostingClassifier

mlflow.set_experiment("hyperparameter-tuning")

# Parent run for the entire tuning process
with mlflow.start_run(run_name="grid-search-parent"):
    param_grid = {
        'learning_rate': [0.01, 0.1, 0.3],
        'n_estimators': [50, 100, 200],
        'max_depth': [3, 5, 7]
    }

    # Log parent parameters
    mlflow.log_param("tuning_method", "grid_search")
    mlflow.log_param("cv_folds", 5)

    best_score = 0
    best_params = None

    # Nested runs for each parameter combination
    for lr in param_grid['learning_rate']:
        for n_est in param_grid['n_estimators']:
            for depth in param_grid['max_depth']:
                with mlflow.start_run(nested=True, run_name=f"lr{lr}_n{n_est}_d{depth}"):
                    params = {
                        'learning_rate': lr,
                        'n_estimators': n_est,
                        'max_depth': depth
                    }

                    model = GradientBoostingClassifier(**params)
                    model.fit(X_train, y_train)
                    score = model.score(X_test, y_test)

                    mlflow.log_params(params)
                    mlflow.log_metric("accuracy", score)

                    if score > best_score:
                        best_score = score
                        best_params = params

    # Log best results in parent run
    mlflow.log_params({f"best_{k}": v for k, v in best_params.items()})
    mlflow.log_metric("best_accuracy", best_score)
```

### Tracking Multiple Metrics Over Time

```python
import mlflow
import numpy as np

with mlflow.start_run():
    # Log metrics at different steps (epochs)
    for epoch in range(100):
        train_loss = np.random.random() * (1 - epoch/100)
        val_loss = np.random.random() * (1 - epoch/100) + 0.1

        mlflow.log_metric("train_loss", train_loss, step=epoch)
        mlflow.log_metric("val_loss", val_loss, step=epoch)
        mlflow.log_metric("learning_rate", 0.01 * (0.95 ** epoch), step=epoch)
```

### Logging Artifacts

```python
import mlflow
import matplotlib.pyplot as plt
import pandas as pd

with mlflow.start_run():
    # Log plot
    plt.figure(figsize=(10, 6))
    plt.plot(history['loss'], label='Training Loss')
    plt.plot(history['val_loss'], label='Validation Loss')
    plt.legend()
    plt.savefig("loss_curve.png")
    mlflow.log_artifact("loss_curve.png")

    # Log dataframe as CSV
    feature_importance = pd.DataFrame({
        'feature': feature_names,
        'importance': model.feature_importances_
    })
    feature_importance.to_csv("feature_importance.csv", index=False)
    mlflow.log_artifact("feature_importance.csv")

    # Log entire directory
    mlflow.log_artifacts("output_dir/", artifact_path="outputs")
```

## Model Registry

### Registering Models

```python
from mlflow import MlflowClient
import mlflow.sklearn

client = MlflowClient()

# Method 1: Register during model logging
with mlflow.start_run():
    mlflow.sklearn.log_model(
        sk_model=model,
        name="model",
        registered_model_name="CustomerSegmentationModel"
    )

# Method 2: Register an existing model
run_id = "abc123"
model_uri = f"runs:/{run_id}/model"
registered_model = mlflow.register_model(
    model_uri=model_uri,
    name="CustomerSegmentationModel"
)
```

### Model Versioning and Aliases

```python
from mlflow import MlflowClient

client = MlflowClient()

# Create registered model
client.create_registered_model(
    name="FraudDetectionModel",
    description="ML model for detecting fraudulent transactions"
)

# Register version 1
model_uri_v1 = "runs:/run1/model"
mv1 = client.create_model_version(
    name="FraudDetectionModel",
    source=model_uri_v1,
    run_id="run1"
)

# Set aliases for deployment management
client.set_registered_model_alias(
    name="FraudDetectionModel",
    alias="champion",  # Production model
    version="1"
)

client.set_registered_model_alias(
    name="FraudDetectionModel",
    alias="challenger",  # A/B testing model
    version="2"
)

# Load model by alias
champion_model = mlflow.sklearn.load_model("models:/FraudDetectionModel@champion")
challenger_model = mlflow.sklearn.load_model("models:/FraudDetectionModel@challenger")
```

### Model Lifecycle Management

```python
from mlflow import MlflowClient
from mlflow.entities import LoggedModelStatus

client = MlflowClient()

# Initialize model in PENDING state
model = mlflow.initialize_logged_model(
    name="neural_network_classifier",
    model_type="neural_network",
    tags={"architecture": "resnet", "dataset": "imagenet"}
)

try:
    # Training and validation
    train_model()
    validate_model()

    # Log model artifacts
    mlflow.pytorch.log_model(
        pytorch_model=model_instance,
        name="model",
        model_id=model.model_id
    )

    # Mark as ready
    mlflow.finalize_logged_model(model.model_id, LoggedModelStatus.READY)

except Exception as e:
    # Mark as failed
    mlflow.finalize_logged_model(model.model_id, LoggedModelStatus.FAILED)
    raise
```

### Model Metadata and Tags

```python
from mlflow import MlflowClient

client = MlflowClient()

# Set registered model tags
client.set_registered_model_tag(
    name="RecommendationModel",
    key="task",
    value="collaborative_filtering"
)

client.set_registered_model_tag(
    name="RecommendationModel",
    key="business_unit",
    value="ecommerce"
)

# Set model version tags
client.set_model_version_tag(
    name="RecommendationModel",
    version="3",
    key="validation_status",
    value="approved"
)

client.set_model_version_tag(
    name="RecommendationModel",
    version="3",
    key="approval_date",
    value="2024-01-15"
)

# Update model description
client.update_registered_model(
    name="RecommendationModel",
    description="Collaborative filtering model for product recommendations. Trained on user-item interaction data."
)
```

### Searching and Filtering Models

```python
from mlflow import MlflowClient

client = MlflowClient()

# Search registered models
models = client.search_registered_models(
    filter_string="name LIKE 'Production%'",
    max_results=10
)

# Search model versions
versions = client.search_model_versions(
    filter_string="name='CustomerChurnModel' AND tags.validation_status='approved'"
)

# Get specific model version
model_version = client.get_model_version(
    name="CustomerChurnModel",
    version="5"
)

# Get model by alias
champion = client.get_model_version_by_alias(
    name="CustomerChurnModel",
    alias="champion"
)
```

## Deployment Patterns

### Local Model Serving

```python
import mlflow.pyfunc

# Load model
model = mlflow.pyfunc.load_model("models:/CustomerChurnModel@production")

# Make predictions
predictions = model.predict(data)
```

### REST API Deployment

```bash
# Serve model as REST API
mlflow models serve \
    --model-uri models:/CustomerChurnModel@production \
    --host 0.0.0.0 \
    --port 5001 \
    --workers 4
```

```python
# Client code to call the REST API
import requests
import json

url = "http://localhost:5001/invocations"
headers = {"Content-Type": "application/json"}

data = {
    "dataframe_split": {
        "columns": ["feature1", "feature2", "feature3"],
        "data": [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]
    }
}

response = requests.post(url, headers=headers, data=json.dumps(data))
predictions = response.json()
```

### Docker Deployment

```bash
# Build Docker image
mlflow models build-docker \
    --model-uri models:/CustomerChurnModel@production \
    --name customer-churn-model

# Run container
docker run -p 8080:8080 customer-churn-model
```

### AWS SageMaker Deployment

```python
import mlflow.sagemaker

# Deploy to SageMaker
mlflow.sagemaker.deploy(
    app_name="customer-churn-predictor",
    model_uri="models:/CustomerChurnModel@production",
    region_name="us-east-1",
    mode="create",
    execution_role_arn="arn:aws:iam::123456789:role/SageMakerRole",
    instance_type="ml.m5.xlarge",
    instance_count=2
)
```

### Azure ML Deployment

```python
import mlflow.azureml
from azureml.core import Workspace
from azureml.core.webservice import AciWebservice

# Configure workspace
ws = Workspace.from_config()

# Deploy to Azure Container Instance
aci_config = AciWebservice.deploy_configuration(
    cpu_cores=2,
    memory_gb=4,
    tags={"model": "churn-predictor"},
    description="Customer churn prediction model"
)

mlflow.azureml.deploy(
    model_uri="models:/CustomerChurnModel@production",
    workspace=ws,
    deployment_config=aci_config,
    service_name="churn-predictor-service"
)
```

### GCP Vertex AI Deployment

```python
from google.cloud import aiplatform
import mlflow

# Initialize Vertex AI
aiplatform.init(project="my-project", location="us-central1")

# Deploy to Vertex AI
model = mlflow.register_model(
    model_uri="runs:/run-id/model",
    name="CustomerChurnModel"
)

# Create Vertex AI endpoint
endpoint = aiplatform.Endpoint.create(display_name="churn-prediction-endpoint")

# Deploy model
endpoint.deploy(
    model=model,
    deployed_model_display_name="churn-v1",
    machine_type="n1-standard-4",
    min_replica_count=1,
    max_replica_count=5
)
```

### Batch Inference

```python
import mlflow
import pandas as pd

# Load model
model = mlflow.pyfunc.load_model("models:/CustomerChurnModel@production")

# Load batch data
batch_data = pd.read_csv("customer_batch.csv")

# Process in chunks
chunk_size = 1000
predictions = []

for i in range(0, len(batch_data), chunk_size):
    chunk = batch_data[i:i+chunk_size]
    chunk_predictions = model.predict(chunk)
    predictions.extend(chunk_predictions)

# Save results
results = pd.DataFrame({
    'customer_id': batch_data['customer_id'],
    'churn_probability': predictions
})
results.to_csv("churn_predictions.csv", index=False)
```

## Monitoring and Observability

### Model Performance Monitoring

```python
import mlflow
from datetime import datetime
import pandas as pd
from sklearn.metrics import accuracy_score, precision_score, recall_score

class ModelMonitor:
    def __init__(self, model_name, tracking_uri):
        self.model_name = model_name
        mlflow.set_tracking_uri(tracking_uri)
        mlflow.set_experiment(f"{model_name}-monitoring")

    def log_prediction_metrics(self, y_true, y_pred, timestamp=None):
        """Log prediction metrics for monitoring"""
        if timestamp is None:
            timestamp = datetime.now()

        with mlflow.start_run(run_name=f"monitoring-{timestamp}"):
            # Calculate metrics
            metrics = {
                "accuracy": accuracy_score(y_true, y_pred),
                "precision": precision_score(y_true, y_pred, average='weighted'),
                "recall": recall_score(y_true, y_pred, average='weighted')
            }

            # Log metrics
            mlflow.log_metrics(metrics)
            mlflow.log_param("timestamp", timestamp.isoformat())
            mlflow.log_param("num_predictions", len(y_pred))

            # Check for drift
            if metrics["accuracy"] < 0.85:
                mlflow.set_tag("alert", "performance_degradation")

    def log_data_drift(self, reference_data, current_data):
        """Monitor for data drift"""
        with mlflow.start_run(run_name="data-drift-check"):
            # Calculate distribution statistics
            for col in reference_data.columns:
                ref_mean = reference_data[col].mean()
                curr_mean = current_data[col].mean()
                drift_percent = abs((curr_mean - ref_mean) / ref_mean) * 100

                mlflow.log_metric(f"{col}_drift_percent", drift_percent)

                if drift_percent > 20:
                    mlflow.set_tag(f"{col}_drift_alert", "high")

# Usage
monitor = ModelMonitor("CustomerChurnModel", "http://localhost:5000")
monitor.log_prediction_metrics(y_true, y_pred)
```

### Prediction Logging

```python
import mlflow
from datetime import datetime
import json

def log_predictions(model_name, inputs, predictions, metadata=None):
    """Log predictions for auditing and monitoring"""
    mlflow.set_experiment(f"{model_name}-predictions")

    with mlflow.start_run(run_name=f"prediction-{datetime.now().isoformat()}"):
        # Log prediction data
        mlflow.log_param("num_predictions", len(predictions))
        mlflow.log_param("model_name", model_name)

        # Log metadata
        if metadata:
            mlflow.log_params(metadata)

        # Log input/output samples
        sample_data = {
            "inputs": inputs[:5].tolist() if hasattr(inputs, 'tolist') else inputs[:5],
            "predictions": predictions[:5].tolist() if hasattr(predictions, 'tolist') else predictions[:5]
        }

        with open("prediction_sample.json", "w") as f:
            json.dump(sample_data, f)
        mlflow.log_artifact("prediction_sample.json")
```

### Model Explainability Tracking

```python
import mlflow
import shap
import matplotlib.pyplot as plt

def log_model_explanations(model, X_test, feature_names):
    """Log SHAP explanations for model interpretability"""
    with mlflow.start_run():
        # Calculate SHAP values
        explainer = shap.TreeExplainer(model)
        shap_values = explainer.shap_values(X_test)

        # Create summary plot
        plt.figure()
        shap.summary_plot(shap_values, X_test, feature_names=feature_names, show=False)
        plt.savefig("shap_summary.png", bbox_inches='tight')
        mlflow.log_artifact("shap_summary.png")

        # Log feature importance
        feature_importance = dict(zip(feature_names, model.feature_importances_))
        mlflow.log_params({f"importance_{k}": v for k, v in feature_importance.items()})
```

## A/B Testing

### A/B Test Framework

```python
import mlflow
import numpy as np
from datetime import datetime

class ABTestFramework:
    def __init__(self, model_a_uri, model_b_uri, traffic_split=0.5):
        self.model_a = mlflow.pyfunc.load_model(model_a_uri)
        self.model_b = mlflow.pyfunc.load_model(model_b_uri)
        self.traffic_split = traffic_split

        mlflow.set_experiment("ab-testing")

    def predict(self, data, user_id=None):
        """Route traffic between models and log results"""
        # Determine which model to use
        if user_id is None or hash(user_id) % 100 < self.traffic_split * 100:
            model_name = "model_a"
            prediction = self.model_a.predict(data)
        else:
            model_name = "model_b"
            prediction = self.model_b.predict(data)

        # Log the prediction
        with mlflow.start_run(run_name=f"ab-test-{datetime.now().isoformat()}"):
            mlflow.log_param("model_variant", model_name)
            mlflow.log_param("user_id", user_id)
            mlflow.log_metric("prediction", float(prediction[0]))

        return prediction

    def evaluate_test(self, results_a, results_b):
        """Evaluate A/B test results"""
        with mlflow.start_run(run_name="ab-test-evaluation"):
            # Calculate metrics for both variants
            metrics_a = {
                "mean_a": np.mean(results_a),
                "std_a": np.std(results_a),
                "count_a": len(results_a)
            }

            metrics_b = {
                "mean_b": np.mean(results_b),
                "std_b": np.std(results_b),
                "count_b": len(results_b)
            }

            # Statistical test
            from scipy import stats
            t_stat, p_value = stats.ttest_ind(results_a, results_b)

            mlflow.log_metrics({**metrics_a, **metrics_b})
            mlflow.log_metric("t_statistic", t_stat)
            mlflow.log_metric("p_value", p_value)

            # Determine winner
            if p_value < 0.05:
                winner = "model_a" if np.mean(results_a) > np.mean(results_b) else "model_b"
                mlflow.set_tag("winner", winner)
                mlflow.set_tag("significant", "yes")
            else:
                mlflow.set_tag("significant", "no")

# Usage
ab_test = ABTestFramework(
    model_a_uri="models:/CustomerChurnModel@champion",
    model_b_uri="models:/CustomerChurnModel@challenger",
    traffic_split=0.5
)

prediction = ab_test.predict(customer_data, user_id="user123")
```

### Multi-Armed Bandit Testing

```python
import mlflow
import numpy as np
from scipy.stats import beta

class MultiArmedBandit:
    def __init__(self, model_uris):
        self.models = [mlflow.pyfunc.load_model(uri) for uri in model_uris]
        self.successes = [1] * len(model_uris)  # Prior
        self.failures = [1] * len(model_uris)   # Prior

        mlflow.set_experiment("mab-testing")

    def select_model(self):
        """Thompson sampling to select model"""
        samples = [
            np.random.beta(s, f)
            for s, f in zip(self.successes, self.failures)
        ]
        return np.argmax(samples)

    def predict_and_update(self, data, actual_outcome=None):
        """Make prediction and update model performance"""
        model_idx = self.select_model()
        prediction = self.models[model_idx].predict(data)

        with mlflow.start_run(run_name=f"mab-prediction"):
            mlflow.log_param("selected_model", model_idx)
            mlflow.log_metric("prediction", float(prediction[0]))

            # Update based on outcome
            if actual_outcome is not None:
                if actual_outcome == prediction[0]:
                    self.successes[model_idx] += 1
                else:
                    self.failures[model_idx] += 1

                mlflow.log_metric("success_rate",
                    self.successes[model_idx] / (self.successes[model_idx] + self.failures[model_idx]))

        return prediction
```

## Feature Stores

### Feature Store Integration

```python
import mlflow
from datetime import datetime
import pandas as pd

class FeatureStore:
    def __init__(self, storage_path):
        self.storage_path = storage_path
        mlflow.set_experiment("feature-store")

    def create_feature_set(self, name, df, description=None):
        """Create and version a feature set"""
        with mlflow.start_run(run_name=f"feature-set-{name}"):
            # Save features
            feature_path = f"{self.storage_path}/{name}_{datetime.now().isoformat()}.parquet"
            df.to_parquet(feature_path)

            # Log metadata
            mlflow.log_param("feature_set_name", name)
            mlflow.log_param("num_features", len(df.columns))
            mlflow.log_param("num_samples", len(df))
            mlflow.log_param("description", description or "")

            # Log feature statistics
            stats = df.describe().to_dict()
            mlflow.log_dict(stats, "feature_stats.json")

            # Log artifact
            mlflow.log_artifact(feature_path)

            return feature_path

    def get_features(self, run_id):
        """Retrieve feature set by run ID"""
        client = mlflow.MlflowClient()
        run = client.get_run(run_id)
        artifact_uri = run.info.artifact_uri

        # Download and load features
        local_path = mlflow.artifacts.download_artifacts(artifact_uri)
        df = pd.read_parquet(local_path)

        return df

# Usage
store = FeatureStore("s3://my-bucket/features")

# Create features
features = pd.DataFrame({
    'customer_id': range(1000),
    'lifetime_value': np.random.rand(1000) * 1000,
    'avg_purchase': np.random.rand(1000) * 100,
    'days_since_last_purchase': np.random.randint(0, 365, 1000)
})

feature_path = store.create_feature_set(
    name="customer_features",
    df=features,
    description="Customer behavioral features for churn prediction"
)
```

### Feature Engineering Pipeline

```python
import mlflow
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA

def feature_engineering_pipeline(data, run_name="feature-engineering"):
    """Log feature engineering steps"""
    with mlflow.start_run(run_name=run_name):
        # Original features
        mlflow.log_param("original_features", len(data.columns))

        # Scaling
        scaler = StandardScaler()
        scaled_data = scaler.fit_transform(data)
        mlflow.sklearn.log_model(scaler, "scaler")

        # Dimensionality reduction
        pca = PCA(n_components=0.95)
        transformed_data = pca.fit_transform(scaled_data)
        mlflow.sklearn.log_model(pca, "pca")

        mlflow.log_param("final_features", transformed_data.shape[1])
        mlflow.log_metric("variance_explained", pca.explained_variance_ratio_.sum())

        return transformed_data

# Usage
transformed_features = feature_engineering_pipeline(raw_data)
```

## CI/CD for ML

### Training Pipeline

```python
import mlflow
from sklearn.model_selection import cross_val_score
from sklearn.ensemble import RandomForestClassifier

def training_pipeline(data_path, model_params, validation_threshold=0.85):
    """Automated training pipeline with validation gates"""

    mlflow.set_experiment("production-training-pipeline")

    with mlflow.start_run(run_name="pipeline-run"):
        # Load data
        data = pd.read_csv(data_path)
        X = data.drop('target', axis=1)
        y = data['target']

        # Log data version
        mlflow.log_param("data_version", data_path.split('/')[-1])
        mlflow.log_param("data_samples", len(data))

        # Train model
        model = RandomForestClassifier(**model_params)
        model.fit(X, y)

        # Cross-validation
        cv_scores = cross_val_score(model, X, y, cv=5)
        mean_cv_score = cv_scores.mean()

        mlflow.log_params(model_params)
        mlflow.log_metric("cv_score_mean", mean_cv_score)
        mlflow.log_metric("cv_score_std", cv_scores.std())

        # Validation gate
        if mean_cv_score >= validation_threshold:
            # Log model
            mlflow.sklearn.log_model(
                sk_model=model,
                name="model",
                registered_model_name="ProductionModel"
            )
            mlflow.set_tag("status", "passed")
            return True
        else:
            mlflow.set_tag("status", "failed")
            mlflow.set_tag("failure_reason", "below_threshold")
            return False

# Usage in CI/CD
success = training_pipeline(
    data_path="data/training_data_v2.csv",
    model_params={'n_estimators': 100, 'max_depth': 10},
    validation_threshold=0.85
)

if not success:
    raise ValueError("Model did not meet validation criteria")
```

### Model Promotion Pipeline

```python
from mlflow import MlflowClient

def promote_model_to_production(model_name, version, validation_results):
    """Promote model through stages with validation"""

    client = MlflowClient()

    # Validation checks
    required_metrics = ['accuracy', 'precision', 'recall']
    for metric in required_metrics:
        if metric not in validation_results:
            raise ValueError(f"Missing required metric: {metric}")
        if validation_results[metric] < 0.8:
            raise ValueError(f"{metric} below threshold: {validation_results[metric]}")

    # Set tags
    for metric, value in validation_results.items():
        client.set_model_version_tag(
            name=model_name,
            version=version,
            key=f"validation_{metric}",
            value=str(value)
        )

    # Promote to production
    client.set_registered_model_alias(
        name=model_name,
        alias="production",
        version=version
    )

    # Tag with promotion metadata
    client.set_model_version_tag(
        name=model_name,
        version=version,
        key="promoted_at",
        value=datetime.now().isoformat()
    )

    return True

# Usage
validation_results = {
    'accuracy': 0.92,
    'precision': 0.89,
    'recall': 0.91
}

promote_model_to_production(
    model_name="FraudDetectionModel",
    version="5",
    validation_results=validation_results
)
```

### Automated Model Retraining

```python
import mlflow
import schedule
import time

class AutomatedRetrainer:
    def __init__(self, model_name, data_source, schedule_interval="daily"):
        self.model_name = model_name
        self.data_source = data_source
        self.schedule_interval = schedule_interval

        mlflow.set_experiment(f"{model_name}-retraining")

    def retrain(self):
        """Retrain model with latest data"""
        with mlflow.start_run(run_name=f"retrain-{datetime.now().isoformat()}"):
            # Load latest data
            data = self.load_latest_data()

            # Get current production model
            client = MlflowClient()
            current_model = client.get_model_version_by_alias(
                self.model_name, "production"
            )

            # Load and evaluate current model
            current_model_obj = mlflow.sklearn.load_model(
                f"models:/{self.model_name}@production"
            )
            current_score = current_model_obj.score(X_test, y_test)

            mlflow.log_metric("current_production_score", current_score)

            # Train new model
            new_model = self.train_model(data)
            new_score = new_model.score(X_test, y_test)

            mlflow.log_metric("new_model_score", new_score)

            # Compare and promote if better
            if new_score > current_score:
                mlflow.sklearn.log_model(
                    sk_model=new_model,
                    name="model",
                    registered_model_name=self.model_name
                )
                mlflow.set_tag("status", "promoted")
            else:
                mlflow.set_tag("status", "not_promoted")

    def start_scheduled_retraining(self):
        """Start scheduled retraining"""
        if self.schedule_interval == "daily":
            schedule.every().day.at("02:00").do(self.retrain)
        elif self.schedule_interval == "weekly":
            schedule.every().monday.at("02:00").do(self.retrain)

        while True:
            schedule.run_pending()
            time.sleep(3600)

# Usage
retrainer = AutomatedRetrainer(
    model_name="CustomerChurnModel",
    data_source="s3://bucket/data",
    schedule_interval="daily"
)
```

## Production Best Practices

### Model Signatures

```python
from mlflow.models import infer_signature, ModelSignature
from mlflow.types import Schema, ColSpec
import mlflow.sklearn
import numpy as np

# Method 1: Infer signature from data
signature = infer_signature(X_train, model.predict(X_train))

# Method 2: Define explicit signature
input_schema = Schema([
    ColSpec("double", "age"),
    ColSpec("double", "income"),
    ColSpec("string", "customer_segment")
])

output_schema = Schema([ColSpec("double")])

signature = ModelSignature(inputs=input_schema, outputs=output_schema)

# Log model with signature
mlflow.sklearn.log_model(
    sk_model=model,
    name="model",
    signature=signature,
    input_example=X_train[:5]
)
```

### Model Validation Framework

```python
import mlflow
from sklearn.metrics import classification_report
import json

class ModelValidator:
    def __init__(self, thresholds):
        self.thresholds = thresholds

    def validate(self, model, X_test, y_test):
        """Comprehensive model validation"""
        results = {}

        with mlflow.start_run(run_name="model-validation"):
            # Performance metrics
            predictions = model.predict(X_test)
            report = classification_report(y_test, predictions, output_dict=True)

            # Check thresholds
            passed = True
            for metric, threshold in self.thresholds.items():
                value = report['weighted avg'][metric]
                results[metric] = value
                mlflow.log_metric(metric, value)

                if value < threshold:
                    passed = False
                    mlflow.set_tag(f"{metric}_failed", "true")

            # Detailed report
            with open("validation_report.json", "w") as f:
                json.dump(report, f, indent=2)
            mlflow.log_artifact("validation_report.json")

            mlflow.set_tag("validation_passed", str(passed))

            return passed, results

# Usage
validator = ModelValidator(thresholds={
    'precision': 0.85,
    'recall': 0.80,
    'f1-score': 0.82
})

passed, results = validator.validate(model, X_test, y_test)
```

### Error Handling and Logging

```python
import mlflow
import logging
from functools import wraps

def mlflow_error_handler(func):
    """Decorator for MLflow error handling"""
    @wraps(func)
    def wrapper(*args, **kwargs):
        with mlflow.start_run(run_name=f"{func.__name__}"):
            try:
                result = func(*args, **kwargs)
                mlflow.set_tag("status", "success")
                return result

            except Exception as e:
                # Log error
                mlflow.set_tag("status", "failed")
                mlflow.set_tag("error_type", type(e).__name__)
                mlflow.set_tag("error_message", str(e))

                # Log traceback
                import traceback
                tb = traceback.format_exc()
                with open("error_traceback.txt", "w") as f:
                    f.write(tb)
                mlflow.log_artifact("error_traceback.txt")

                logging.error(f"Error in {func.__name__}: {str(e)}")
                raise

    return wrapper

@mlflow_error_handler
def train_model_with_error_handling(data):
    # Training code
    model = RandomForestClassifier()
    model.fit(X, y)
    return model
```

### Model Performance Baseline

```python
import mlflow
from sklearn.dummy import DummyClassifier

def establish_baseline(X_train, y_train, X_test, y_test):
    """Establish baseline model performance"""
    mlflow.set_experiment("baseline-models")

    strategies = ['most_frequent', 'stratified', 'uniform']

    for strategy in strategies:
        with mlflow.start_run(run_name=f"baseline-{strategy}"):
            baseline = DummyClassifier(strategy=strategy)
            baseline.fit(X_train, y_train)
            score = baseline.score(X_test, y_test)

            mlflow.log_param("strategy", strategy)
            mlflow.log_metric("accuracy", score)

            mlflow.sklearn.log_model(
                sk_model=baseline,
                name="baseline_model",
                registered_model_name=f"Baseline-{strategy}"
            )

# Usage
establish_baseline(X_train, y_train, X_test, y_test)
```

## Summary

This comprehensive guide covers production-grade MLOps workflows using MLflow:

1. **Experiment Tracking**: Log parameters, metrics, and artifacts systematically
2. **Model Registry**: Centralized model versioning and lifecycle management
3. **Deployment**: Multiple deployment patterns for various platforms
4. **Monitoring**: Track model performance and data drift in production
5. **A/B Testing**: Compare model variants in production
6. **Feature Stores**: Version and manage feature engineering
7. **CI/CD**: Automated training, validation, and promotion pipelines
8. **Best Practices**: Signatures, validation, error handling, and baselines

These patterns enable teams to build robust, scalable ML systems from experimentation through production deployment and monitoring.
