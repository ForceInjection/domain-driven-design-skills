---
name: rust-metrics
description: Expose Prometheus metrics with counters, gauges, and histograms. Use for production monitoring and alerting.
---

# Metrics

Prometheus-compatible metrics for production monitoring.

## Setup

```toml
# Cargo.toml
[dependencies]
metrics = "0.22"
metrics-exporter-prometheus = "0.13"
```

## Initialize Prometheus Exporter

```rust
use metrics_exporter_prometheus::PrometheusBuilder;

fn init_metrics() -> Result<()> {
    PrometheusBuilder::new()
        .with_http_listener(([0, 0, 0, 0], 9090))
        .install()?;

    Ok(())
}

// Access metrics at http://localhost:9090/metrics
```

## Counter (Monotonically Increasing)

```rust
use metrics::counter;

// Increment by 1
counter!("videos_processed_total").increment(1);

// With labels
counter!("http_requests_total", "method" => "GET", "status" => "200").increment(1);

// In a function
fn record_request(method: &str, status: u16) {
    counter!(
        "http_requests_total",
        "method" => method.to_string(),
        "status" => status.to_string()
    ).increment(1);
}
```

## Gauge (Can Go Up or Down)

```rust
use metrics::gauge;

// Set absolute value
gauge!("gpu_vram_used_gb").set(8.5);

// Increment/decrement
gauge!("active_connections").increment(1.0);
gauge!("active_connections").decrement(1.0);

// With labels
gauge!("queue_depth", "queue" => "embedding").set(42.0);
```

## Histogram (Distribution of Values)

```rust
use metrics::histogram;

// Record a value
histogram!("request_duration_seconds").record(0.125);

// With labels
histogram!(
    "processing_duration_seconds",
    "model" => "whisper",
    "phase" => "inference"
).record(duration.as_secs_f64());

// Record timing
let start = std::time::Instant::now();
do_work();
histogram!("operation_duration_seconds").record(start.elapsed().as_secs_f64());
```

## Describe Metrics

```rust
use metrics::{describe_counter, describe_gauge, describe_histogram, Unit};

fn describe_metrics() {
    describe_counter!(
        "videos_processed_total",
        Unit::Count,
        "Total number of videos processed"
    );

    describe_gauge!(
        "gpu_vram_used_gb",
        Unit::Gigabytes,
        "Current GPU VRAM usage"
    );

    describe_histogram!(
        "request_duration_seconds",
        Unit::Seconds,
        "Request processing time distribution"
    );
}
```

## Metrics Struct Pattern

```rust
use metrics::{counter, gauge, histogram};

pub struct ProcessorMetrics;

impl ProcessorMetrics {
    pub fn record_video_processed(model: &str) {
        counter!("videos_processed_total", "model" => model.to_string()).increment(1);
    }

    pub fn record_processing_time(model: &str, duration: std::time::Duration) {
        histogram!(
            "processing_duration_seconds",
            "model" => model.to_string()
        ).record(duration.as_secs_f64());
    }

    pub fn set_queue_depth(queue: &str, depth: usize) {
        gauge!("queue_depth", "queue" => queue.to_string()).set(depth as f64);
    }

    pub fn record_error(error_type: &str) {
        counter!("processing_errors_total", "type" => error_type.to_string()).increment(1);
    }
}

// Usage
ProcessorMetrics::record_video_processed("whisper");
ProcessorMetrics::record_processing_time("whisper", elapsed);
```

## Scheduler Metrics Example

```rust
pub struct SchedulerMetrics {
    model_switches: AtomicU64,
    items_processed: DashMap<ModelType, u64>,
    processing_times: DashMap<ModelType, f64>,
}

impl SchedulerMetrics {
    pub fn new() -> Self {
        Self {
            model_switches: AtomicU64::new(0),
            items_processed: DashMap::new(),
            processing_times: DashMap::new(),
        }
    }

    pub fn record_model_switch(&self, from: Option<ModelType>, to: ModelType) {
        self.model_switches.fetch_add(1, Ordering::Relaxed);
        counter!(
            "model_switches_total",
            "to" => format!("{:?}", to)
        ).increment(1);
    }

    pub fn record_batch_processed(&self, model: ModelType, count: u64, duration: Duration) {
        *self.items_processed.entry(model).or_insert(0) += count;

        counter!(
            "items_processed_total",
            "model" => format!("{:?}", model)
        ).increment(count);

        histogram!(
            "batch_processing_seconds",
            "model" => format!("{:?}", model)
        ).record(duration.as_secs_f64());
    }

    pub fn export(&self) -> MetricsSnapshot {
        MetricsSnapshot {
            model_switches: self.model_switches.load(Ordering::Relaxed),
            items_processed: self.items_processed.iter()
                .map(|e| (*e.key(), *e.value()))
                .collect(),
        }
    }
}
```

## HTTP Endpoint Integration

```rust
use axum::{routing::get, Router};
use metrics_exporter_prometheus::{Matcher, PrometheusBuilder, PrometheusHandle};

fn setup_metrics() -> PrometheusHandle {
    PrometheusBuilder::new()
        .set_buckets_for_metric(
            Matcher::Prefix("http_request".to_string()),
            &[0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1.0, 5.0],
        )
        .unwrap()
        .install_recorder()
        .unwrap()
}

async fn metrics_handler(handle: axum::Extension<PrometheusHandle>) -> String {
    handle.render()
}

#[tokio::main]
async fn main() {
    let handle = setup_metrics();

    let app = Router::new()
        .route("/metrics", get(metrics_handler))
        .layer(axum::Extension(handle));

    axum::Server::bind(&"0.0.0.0:8080".parse().unwrap())
        .serve(app.into_make_service())
        .await
        .unwrap();
}
```

## Common Metric Patterns

```rust
// Request duration with status
fn record_request(method: &str, path: &str, status: u16, duration: Duration) {
    let labels = [
        ("method", method.to_string()),
        ("path", path.to_string()),
        ("status", status.to_string()),
    ];

    counter!("http_requests_total", &labels).increment(1);
    histogram!("http_request_duration_seconds", &labels).record(duration.as_secs_f64());
}

// Error rate tracking
fn record_operation(success: bool, operation: &str) {
    let status = if success { "success" } else { "error" };
    counter!(
        "operations_total",
        "operation" => operation.to_string(),
        "status" => status.to_string()
    ).increment(1);
}

// Resource utilization
fn update_resource_metrics(cpu: f64, memory: f64, disk: f64) {
    gauge!("cpu_usage_percent").set(cpu);
    gauge!("memory_usage_percent").set(memory);
    gauge!("disk_usage_percent").set(disk);
}
```

## Guidelines

- Use counters for things that only increase (requests, errors)
- Use gauges for things that go up and down (connections, memory)
- Use histograms for latency and size distributions
- Include relevant labels but avoid high cardinality
- Describe metrics with units and descriptions
- Expose metrics on standard port (9090 or /metrics endpoint)
- Use consistent naming: `<namespace>_<name>_<unit>`

## Examples

See `hercules-local-algo/src/scheduler/metrics.rs` for production metrics.
