---
name: otel-observability
description: Implement OpenTelemetry-based observability for traces, metrics, and logs. Use for distributed tracing, Prometheus metrics, structured logging, and agent monitoring. Triggers on "OpenTelemetry", "OTEL", "tracing", "metrics", "observability", "Prometheus", "Grafana", "distributed tracing", or when implementing spec/007-observability.md.
---

# OpenTelemetry Observability

## Overview

Implement comprehensive observability using OpenTelemetry for distributed tracing, Prometheus-compatible metrics, and structured logging across all AgentStack components.

## Observability Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                   Observability Stack                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   Applications                           │   │
│  │  API Gateway │ Agents │ Workers │ Control Plane          │   │
│  │  (OTEL SDK instrumentation)                              │   │
│  └─────────────────────────────────────────────────────────┘   │
│                           │                                     │
│                           ▼                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              OTEL Collector                              │   │
│  │  Receives │ Processes │ Exports                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│           │              │              │                       │
│           ▼              ▼              ▼                       │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐               │
│  │   Tempo     │ │ Prometheus  │ │    Loki     │               │
│  │  (Traces)   │ │  (Metrics)  │ │   (Logs)    │               │
│  └─────────────┘ └─────────────┘ └─────────────┘               │
│           └──────────────┴──────────────┘                       │
│                          │                                      │
│                          ▼                                      │
│                   ┌─────────────┐                               │
│                   │   Grafana   │                               │
│                   │ (Dashboards)│                               │
│                   └─────────────┘                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Go OTEL Setup

### Initialize Provider

```go
// internal/pkg/telemetry/provider.go
package telemetry

import (
    "context"
    "time"

    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
    "go.opentelemetry.io/otel/exporters/prometheus"
    "go.opentelemetry.io/otel/propagation"
    "go.opentelemetry.io/otel/sdk/metric"
    "go.opentelemetry.io/otel/sdk/resource"
    "go.opentelemetry.io/otel/sdk/trace"
    semconv "go.opentelemetry.io/otel/semconv/v1.21.0"
)

type Config struct {
    ServiceName    string
    ServiceVersion string
    Environment    string
    OTLPEndpoint   string
}

type Provider struct {
    TracerProvider *trace.TracerProvider
    MeterProvider  *metric.MeterProvider
}

func NewProvider(ctx context.Context, cfg Config) (*Provider, error) {
    // Create resource
    res, err := resource.New(ctx,
        resource.WithAttributes(
            semconv.ServiceNameKey.String(cfg.ServiceName),
            semconv.ServiceVersionKey.String(cfg.ServiceVersion),
            semconv.DeploymentEnvironmentKey.String(cfg.Environment),
        ),
    )
    if err != nil {
        return nil, err
    }

    // Create trace exporter
    traceExporter, err := otlptracegrpc.New(ctx,
        otlptracegrpc.WithEndpoint(cfg.OTLPEndpoint),
        otlptracegrpc.WithInsecure(),
    )
    if err != nil {
        return nil, err
    }

    // Create tracer provider
    tp := trace.NewTracerProvider(
        trace.WithResource(res),
        trace.WithBatcher(traceExporter,
            trace.WithBatchTimeout(5*time.Second),
            trace.WithMaxExportBatchSize(512),
        ),
        trace.WithSampler(trace.ParentBased(trace.TraceIDRatioBased(0.1))),
    )

    // Create Prometheus exporter for metrics
    promExporter, err := prometheus.New()
    if err != nil {
        return nil, err
    }

    // Create meter provider
    mp := metric.NewMeterProvider(
        metric.WithResource(res),
        metric.WithReader(promExporter),
    )

    // Set global providers
    otel.SetTracerProvider(tp)
    otel.SetMeterProvider(mp)
    otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(
        propagation.TraceContext{},
        propagation.Baggage{},
    ))

    return &Provider{
        TracerProvider: tp,
        MeterProvider:  mp,
    }, nil
}

func (p *Provider) Shutdown(ctx context.Context) error {
    if err := p.TracerProvider.Shutdown(ctx); err != nil {
        return err
    }
    return p.MeterProvider.Shutdown(ctx)
}
```

### Initialize in main.go

```go
// cmd/api/main.go
func main() {
    ctx := context.Background()
    
    // Initialize telemetry
    telemetryProvider, err := telemetry.NewProvider(ctx, telemetry.Config{
        ServiceName:    "agentstack-api",
        ServiceVersion: version,
        Environment:    os.Getenv("ENVIRONMENT"),
        OTLPEndpoint:   os.Getenv("OTEL_EXPORTER_OTLP_ENDPOINT"),
    })
    if err != nil {
        log.Fatal(err)
    }
    defer telemetryProvider.Shutdown(ctx)
    
    // ... rest of app initialization
}
```

## Distributed Tracing

### Custom Spans

```go
// internal/domain/agent/service.go
package agent

import (
    "context"
    
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/attribute"
    "go.opentelemetry.io/otel/codes"
    "go.opentelemetry.io/otel/trace"
)

var tracer = otel.Tracer("agentstack/agent")

func (s *Service) Create(ctx context.Context, projectID string, input CreateInput) (*Agent, error) {
    ctx, span := tracer.Start(ctx, "agent.Create",
        trace.WithAttributes(
            attribute.String("project.id", projectID),
            attribute.String("agent.name", input.Name),
            attribute.String("agent.framework", input.Framework),
        ),
    )
    defer span.End()

    // Validate
    if err := s.validate(ctx, input); err != nil {
        span.RecordError(err)
        span.SetStatus(codes.Error, "validation failed")
        return nil, err
    }

    // Create agent
    agent, err := s.repo.Create(ctx, projectID, &Agent{
        Name:      input.Name,
        Framework: input.Framework,
        Config:    input.Config,
    })
    if err != nil {
        span.RecordError(err)
        span.SetStatus(codes.Error, "create failed")
        return nil, err
    }

    span.SetAttributes(attribute.String("agent.id", agent.ID))
    span.SetStatus(codes.Ok, "created")
    
    return agent, nil
}
```

### HTTP Client Tracing

```go
// internal/infrastructure/httpclient/client.go
package httpclient

import (
    "net/http"
    
    "go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
)

func NewTracedClient() *http.Client {
    return &http.Client{
        Transport: otelhttp.NewTransport(http.DefaultTransport),
    }
}
```

### Database Tracing

```go
// Using pgx with OTEL
import "github.com/exaring/otelpgx"

poolConfig.ConnConfig.Tracer = otelpgx.NewTracer()
```

## Metrics

### Define Custom Metrics

```go
// internal/pkg/telemetry/metrics.go
package telemetry

import (
    "go.opentelemetry.io/otel"
    "go.opentelemetry.io/otel/metric"
)

var meter = otel.Meter("agentstack")

var (
    // Request metrics
    RequestsTotal metric.Int64Counter
    RequestDuration metric.Float64Histogram
    
    // Agent metrics
    AgentsActive metric.Int64UpDownCounter
    AgentDeployDuration metric.Float64Histogram
    
    // Chat metrics
    ChatTokensUsed metric.Int64Counter
    ChatLatency metric.Float64Histogram
    
    // LLM metrics
    LLMCallsTotal metric.Int64Counter
    LLMLatency metric.Float64Histogram
    LLMTokensInput metric.Int64Counter
    LLMTokensOutput metric.Int64Counter
)

func InitMetrics() error {
    var err error

    RequestsTotal, err = meter.Int64Counter("http_requests_total",
        metric.WithDescription("Total HTTP requests"),
        metric.WithUnit("{request}"),
    )
    if err != nil {
        return err
    }

    RequestDuration, err = meter.Float64Histogram("http_request_duration_seconds",
        metric.WithDescription("HTTP request duration"),
        metric.WithUnit("s"),
        metric.WithExplicitBucketBoundaries(0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10),
    )
    if err != nil {
        return err
    }

    ChatTokensUsed, err = meter.Int64Counter("chat_tokens_total",
        metric.WithDescription("Total tokens used in chat"),
        metric.WithUnit("{token}"),
    )
    if err != nil {
        return err
    }

    LLMLatency, err = meter.Float64Histogram("llm_call_duration_seconds",
        metric.WithDescription("LLM API call duration"),
        metric.WithUnit("s"),
        metric.WithExplicitBucketBoundaries(0.1, 0.5, 1, 2, 5, 10, 30, 60),
    )
    if err != nil {
        return err
    }

    return nil
}
```

### Record Metrics

```go
// In handler/service
func (h *ChatHandler) Chat(c *fiber.Ctx) error {
    start := time.Now()
    
    // ... process request
    
    duration := time.Since(start).Seconds()
    
    telemetry.RequestsTotal.Add(c.Context(), 1,
        metric.WithAttributes(
            attribute.String("method", "POST"),
            attribute.String("path", "/v1/agents/{id}/chat"),
            attribute.Int("status", c.Response().StatusCode()),
        ),
    )
    
    telemetry.RequestDuration.Record(c.Context(), duration,
        metric.WithAttributes(
            attribute.String("method", "POST"),
            attribute.String("path", "/v1/agents/{id}/chat"),
        ),
    )
    
    telemetry.ChatTokensUsed.Add(c.Context(), int64(usage.TotalTokens),
        metric.WithAttributes(
            attribute.String("agent.id", agentID),
            attribute.String("project.id", projectID),
            attribute.String("model", model),
        ),
    )
    
    return nil
}
```

### Prometheus Endpoint

```go
// internal/api/routes/router.go
import "github.com/prometheus/client_golang/prometheus/promhttp"

func SetupRoutes(app *fiber.App, deps *Dependencies) {
    // Metrics endpoint
    app.Get("/metrics", adaptor.HTTPHandler(promhttp.Handler()))
}
```

## Structured Logging

### Logger Setup

```go
// internal/pkg/logger/logger.go
package logger

import (
    "context"
    
    "go.uber.org/zap"
    "go.uber.org/zap/zapcore"
    "go.opentelemetry.io/otel/trace"
)

var log *zap.Logger

func Init(level string, env string) error {
    var cfg zap.Config
    
    if env == "production" {
        cfg = zap.NewProductionConfig()
    } else {
        cfg = zap.NewDevelopmentConfig()
    }
    
    cfg.EncoderConfig.TimeKey = "timestamp"
    cfg.EncoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
    
    var err error
    log, err = cfg.Build(
        zap.AddCallerSkip(1),
    )
    return err
}

// WithContext adds trace context to log
func WithContext(ctx context.Context) *zap.Logger {
    span := trace.SpanFromContext(ctx)
    if !span.SpanContext().IsValid() {
        return log
    }
    
    return log.With(
        zap.String("trace_id", span.SpanContext().TraceID().String()),
        zap.String("span_id", span.SpanContext().SpanID().String()),
    )
}

func Info(ctx context.Context, msg string, fields ...zap.Field) {
    WithContext(ctx).Info(msg, fields...)
}

func Error(ctx context.Context, msg string, fields ...zap.Field) {
    WithContext(ctx).Error(msg, fields...)
}

func Debug(ctx context.Context, msg string, fields ...zap.Field) {
    WithContext(ctx).Debug(msg, fields...)
}
```

### Usage

```go
func (s *Service) Create(ctx context.Context, input Input) (*Agent, error) {
    logger.Info(ctx, "creating agent",
        zap.String("name", input.Name),
        zap.String("framework", input.Framework),
    )
    
    agent, err := s.repo.Create(ctx, input)
    if err != nil {
        logger.Error(ctx, "failed to create agent",
            zap.Error(err),
            zap.String("name", input.Name),
        )
        return nil, err
    }
    
    logger.Info(ctx, "agent created",
        zap.String("agent_id", agent.ID),
    )
    
    return agent, nil
}
```

## OTEL Collector Configuration

```yaml
# otel-collector-config.yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:
    timeout: 5s
    send_batch_size: 512
  
  memory_limiter:
    check_interval: 1s
    limit_mib: 1000
    spike_limit_mib: 200
  
  attributes:
    actions:
      - key: environment
        value: production
        action: upsert

exporters:
  otlp/tempo:
    endpoint: tempo:4317
    tls:
      insecure: true
  
  prometheus:
    endpoint: 0.0.0.0:8889
    namespace: agentstack
  
  loki:
    endpoint: http://loki:3100/loki/api/v1/push

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [memory_limiter, batch]
      exporters: [otlp/tempo]
    
    metrics:
      receivers: [otlp]
      processors: [memory_limiter, batch]
      exporters: [prometheus]
    
    logs:
      receivers: [otlp]
      processors: [memory_limiter, batch]
      exporters: [loki]
```

## Kubernetes Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: otel-collector
  namespace: observability
spec:
  replicas: 2
  selector:
    matchLabels:
      app: otel-collector
  template:
    spec:
      containers:
        - name: collector
          image: otel/opentelemetry-collector-contrib:0.91.0
          args:
            - --config=/conf/otel-collector-config.yaml
          ports:
            - containerPort: 4317  # OTLP gRPC
            - containerPort: 4318  # OTLP HTTP
            - containerPort: 8889  # Prometheus metrics
          volumeMounts:
            - name: config
              mountPath: /conf
          resources:
            requests:
              cpu: 200m
              memory: 256Mi
            limits:
              cpu: 1000m
              memory: 1Gi
      volumes:
        - name: config
          configMap:
            name: otel-collector-config
```

## Resources

- `references/grafana-dashboards.md` - Pre-built dashboard templates
- `references/alerting-rules.md` - Prometheus alerting rules
- `assets/dashboards/` - Grafana dashboard JSON files
