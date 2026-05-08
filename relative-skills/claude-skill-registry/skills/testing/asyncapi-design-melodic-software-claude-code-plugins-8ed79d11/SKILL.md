---
name: asyncapi-design
description: Event-driven API specification with AsyncAPI 3.0 for message-based architectures
allowed-tools: Read, Glob, Grep, Write, Edit, mcp__perplexity__search, mcp__context7__resolve-library-id, mcp__context7__query-docs
---

# AsyncAPI Design Skill

## When to Use This Skill

Use this skill when:

- **Asyncapi Design tasks** - Working on event-driven api specification with asyncapi 3.0 for message-based architectures
- **Planning or design** - Need guidance on Asyncapi Design approaches
- **Best practices** - Want to follow established patterns and standards

## Overview

Event-driven API specification using AsyncAPI 3.0 for message-based and streaming architectures.

## MANDATORY: Documentation-First Approach

Before creating AsyncAPI specifications:

1. **Invoke `docs-management` skill** for event-driven patterns
2. **Verify AsyncAPI 3.0 syntax** via MCP servers (context7 for latest spec)
3. **Base all guidance on AsyncAPI 3.0 specification**

## AsyncAPI vs OpenAPI

| Aspect | OpenAPI | AsyncAPI |
|--------|---------|----------|
| Communication | Request/Response | Event-Driven |
| Protocol | HTTP/HTTPS | Kafka, RabbitMQ, MQTT, WebSocket, etc. |
| Initiator | Client requests | Publisher emits |
| Pattern | Synchronous | Asynchronous |
| Use Case | REST APIs | Message queues, streaming, IoT |

## AsyncAPI 3.0 Structure

### Basic Template

```yaml
asyncapi: 3.0.0
info:
  title: Order Events API
  version: 1.0.0
  description: |
    Event-driven API for order lifecycle events.

    ## Overview
    This API publishes events when orders change state, enabling
    downstream systems to react to order lifecycle changes.
  contact:
    name: Events Team
    email: events@example.com
  license:
    name: MIT
    url: https://opensource.org/licenses/MIT

servers:
  production:
    host: kafka.example.com:9092
    protocol: kafka
    description: Production Kafka cluster
    security:
      - $ref: '#/components/securitySchemes/sasl'

  development:
    host: localhost:9092
    protocol: kafka
    description: Local development Kafka

defaultContentType: application/json

channels:
  orderCreated:
    address: orders.created
    messages:
      orderCreatedMessage:
        $ref: '#/components/messages/OrderCreated'
    description: Published when a new order is created

  orderSubmitted:
    address: orders.submitted
    messages:
      orderSubmittedMessage:
        $ref: '#/components/messages/OrderSubmitted'

  orderStatusChanged:
    address: orders.status.changed
    messages:
      orderStatusChangedMessage:
        $ref: '#/components/messages/OrderStatusChanged'

operations:
  publishOrderCreated:
    action: send
    channel:
      $ref: '#/channels/orderCreated'
    summary: Publish order created event
    description: |
      Published when a customer creates a new order.
      Consumers should use this to initialize order tracking.

  consumeOrderCreated:
    action: receive
    channel:
      $ref: '#/channels/orderCreated'
    summary: Consume order created events
    description: Subscribe to receive new order notifications

  publishOrderSubmitted:
    action: send
    channel:
      $ref: '#/channels/orderSubmitted'

  publishOrderStatusChanged:
    action: send
    channel:
      $ref: '#/channels/orderStatusChanged'

components:
  messages:
    OrderCreated:
      name: OrderCreated
      title: Order Created Event
      summary: Event published when an order is created
      contentType: application/json
      headers:
        $ref: '#/components/schemas/EventHeaders'
      payload:
        $ref: '#/components/schemas/OrderCreatedPayload'
      examples:
        - name: basicOrder
          summary: Basic order creation
          headers:
            correlationId: "550e8400-e29b-41d4-a716-446655440000"
            eventType: "OrderCreated"
            eventVersion: "1.0"
            timestamp: "2025-01-15T10:30:00Z"
          payload:
            orderId: "ord-123456"
            customerId: "cust-789"
            items:
              - productId: "prod-001"
                quantity: 2
                unitPrice: 29.99
            createdAt: "2025-01-15T10:30:00Z"

    OrderSubmitted:
      name: OrderSubmitted
      title: Order Submitted Event
      contentType: application/json
      headers:
        $ref: '#/components/schemas/EventHeaders'
      payload:
        $ref: '#/components/schemas/OrderSubmittedPayload'

    OrderStatusChanged:
      name: OrderStatusChanged
      title: Order Status Changed Event
      contentType: application/json
      headers:
        $ref: '#/components/schemas/EventHeaders'
      payload:
        $ref: '#/components/schemas/OrderStatusChangedPayload'

  schemas:
    EventHeaders:
      type: object
      required:
        - correlationId
        - eventType
        - timestamp
      properties:
        correlationId:
          type: string
          format: uuid
          description: Unique identifier for request tracing
        eventType:
          type: string
          description: Type of the event
        eventVersion:
          type: string
          description: Schema version of the event
        timestamp:
          type: string
          format: date-time
          description: When the event occurred

    OrderCreatedPayload:
      type: object
      required:
        - orderId
        - customerId
        - createdAt
      properties:
        orderId:
          type: string
          description: Unique order identifier
        customerId:
          type: string
          description: Customer who created the order
        items:
          type: array
          items:
            $ref: '#/components/schemas/LineItem'
        createdAt:
          type: string
          format: date-time

    OrderSubmittedPayload:
      type: object
      required:
        - orderId
        - customerId
        - total
        - submittedAt
      properties:
        orderId:
          type: string
        customerId:
          type: string
        total:
          $ref: '#/components/schemas/Money'
        submittedAt:
          type: string
          format: date-time

    OrderStatusChangedPayload:
      type: object
      required:
        - orderId
        - previousStatus
        - newStatus
        - changedAt
      properties:
        orderId:
          type: string
        previousStatus:
          $ref: '#/components/schemas/OrderStatus'
        newStatus:
          $ref: '#/components/schemas/OrderStatus'
        reason:
          type: string
          description: Optional reason for status change
        changedAt:
          type: string
          format: date-time

    LineItem:
      type: object
      required:
        - productId
        - quantity
        - unitPrice
      properties:
        productId:
          type: string
        productName:
          type: string
        quantity:
          type: integer
          minimum: 1
        unitPrice:
          type: number
          format: decimal

    Money:
      type: object
      required:
        - amount
        - currency
      properties:
        amount:
          type: number
          format: decimal
        currency:
          type: string
          pattern: '^[A-Z]{3}$'

    OrderStatus:
      type: string
      enum:
        - draft
        - submitted
        - paid
        - shipped
        - delivered
        - cancelled

  securitySchemes:
    sasl:
      type: scramSha256
      description: SASL/SCRAM-SHA-256 authentication

    apiKey:
      type: apiKey
      in: user
      description: API key authentication
```

## Protocol-Specific Patterns

### Kafka

```yaml
servers:
  kafka:
    host: broker1.example.com:9092,broker2.example.com:9092
    protocol: kafka
    protocolVersion: '3.0'
    bindings:
      kafka:
        schemaRegistryUrl: http://schema-registry:8081
        schemaRegistryVendor: confluent

channels:
  orderEvents:
    address: orders.events.v1
    bindings:
      kafka:
        topic: orders.events.v1
        partitions: 12
        replicas: 3
        topicConfiguration:
          cleanup.policy: ['delete']
          retention.ms: 604800000
          segment.bytes: 1073741824

operations:
  publishOrderEvent:
    action: send
    channel:
      $ref: '#/channels/orderEvents'
    bindings:
      kafka:
        groupId:
          type: string
        clientId:
          type: string
        bindingVersion: '0.5.0'
```

### RabbitMQ

```yaml
servers:
  rabbitmq:
    host: rabbitmq.example.com:5672
    protocol: amqp
    protocolVersion: '0.9.1'

channels:
  orderQueue:
    address: order-processing-queue
    bindings:
      amqp:
        is: queue
        queue:
          name: order-processing
          durable: true
          exclusive: false
          autoDelete: false
        exchange:
          name: orders-exchange
          type: topic
          durable: true
        bindingVersion: '0.3.0'
```

### MQTT (IoT)

```yaml
servers:
  mqtt:
    host: mqtt.example.com:1883
    protocol: mqtt
    protocolVersion: '5.0'

channels:
  deviceTelemetry:
    address: devices/{deviceId}/telemetry
    parameters:
      deviceId:
        description: Unique device identifier
        schema:
          type: string
    bindings:
      mqtt:
        qos: 1
        retain: false
        bindingVersion: '0.2.0'
```

### WebSocket

```yaml
servers:
  websocket:
    host: ws.example.com
    protocol: ws
    protocolVersion: '13'

channels:
  orderUpdates:
    address: /orders/updates
    bindings:
      ws:
        method: GET
        headers:
          type: object
          properties:
            Authorization:
              type: string
```

## C# Implementation Patterns

### Event Contracts

```csharp
// Domain Events
public abstract record DomainEvent
{
    public Guid EventId { get; init; } = Guid.NewGuid();
    public DateTimeOffset OccurredAt { get; init; } = DateTimeOffset.UtcNow;
    public string EventType => GetType().Name;
    public string EventVersion { get; init; } = "1.0";
}

public sealed record OrderCreatedEvent(
    Guid OrderId,
    Guid CustomerId,
    IReadOnlyList<LineItemDto> Items,
    DateTimeOffset CreatedAt) : DomainEvent;

public sealed record OrderSubmittedEvent(
    Guid OrderId,
    Guid CustomerId,
    Money Total,
    DateTimeOffset SubmittedAt) : DomainEvent;

public sealed record OrderStatusChangedEvent(
    Guid OrderId,
    OrderStatus PreviousStatus,
    OrderStatus NewStatus,
    string? Reason,
    DateTimeOffset ChangedAt) : DomainEvent;

// Integration Events (for cross-boundary communication)
public abstract record IntegrationEvent
{
    public Guid Id { get; init; } = Guid.NewGuid();
    public Guid CorrelationId { get; init; }
    public DateTimeOffset Timestamp { get; init; } = DateTimeOffset.UtcNow;
    public string Source { get; init; } = "OrderService";
}

public sealed record OrderCreatedIntegrationEvent(
    Guid OrderId,
    Guid CustomerId,
    decimal TotalAmount,
    string Currency) : IntegrationEvent;
```

### MassTransit Publisher

```csharp
using MassTransit;

public sealed class OrderService
{
    private readonly IPublishEndpoint _publishEndpoint;
    private readonly ILogger<OrderService> _logger;

    public OrderService(
        IPublishEndpoint publishEndpoint,
        ILogger<OrderService> logger)
    {
        _publishEndpoint = publishEndpoint;
        _logger = logger;
    }

    public async Task CreateOrderAsync(
        CreateOrderCommand command,
        CancellationToken ct = default)
    {
        // Create order logic...
        var order = Order.Create(command.CustomerId, command.Items);

        // Publish event
        await _publishEndpoint.Publish(
            new OrderCreatedEvent(
                order.Id,
                order.CustomerId,
                order.Items.Select(i => i.ToDto()).ToList(),
                order.CreatedAt),
            ct);

        _logger.LogInformation(
            "Published OrderCreatedEvent for order {OrderId}",
            order.Id);
    }
}

// Consumer
public sealed class OrderCreatedConsumer : IConsumer<OrderCreatedEvent>
{
    private readonly ILogger<OrderCreatedConsumer> _logger;

    public OrderCreatedConsumer(ILogger<OrderCreatedConsumer> logger)
    {
        _logger = logger;
    }

    public async Task Consume(ConsumeContext<OrderCreatedEvent> context)
    {
        var @event = context.Message;

        _logger.LogInformation(
            "Processing OrderCreatedEvent: {OrderId}, Customer: {CustomerId}",
            @event.OrderId,
            @event.CustomerId);

        // Handle the event...
    }
}

// Registration
services.AddMassTransit(x =>
{
    x.AddConsumer<OrderCreatedConsumer>();

    x.UsingRabbitMq((context, cfg) =>
    {
        cfg.Host("rabbitmq://localhost", h =>
        {
            h.Username("guest");
            h.Password("guest");
        });

        cfg.ConfigureEndpoints(context);
    });
});
```

### Kafka with Confluent

```csharp
using Confluent.Kafka;
using System.Text.Json;

public sealed class KafkaOrderPublisher : IAsyncDisposable
{
    private readonly IProducer<string, string> _producer;
    private readonly string _topic;
    private readonly ILogger<KafkaOrderPublisher> _logger;

    public KafkaOrderPublisher(
        IConfiguration config,
        ILogger<KafkaOrderPublisher> logger)
    {
        _logger = logger;
        _topic = config["Kafka:OrdersTopic"] ?? "orders.events.v1";

        var producerConfig = new ProducerConfig
        {
            BootstrapServers = config["Kafka:BootstrapServers"],
            Acks = Acks.All,
            EnableIdempotence = true,
            MessageSendMaxRetries = 3,
            RetryBackoffMs = 1000
        };

        _producer = new ProducerBuilder<string, string>(producerConfig)
            .SetKeySerializer(Serializers.Utf8)
            .SetValueSerializer(Serializers.Utf8)
            .Build();
    }

    public async Task PublishAsync<TEvent>(
        TEvent @event,
        CancellationToken ct = default) where TEvent : DomainEvent
    {
        var key = GetPartitionKey(@event);
        var value = JsonSerializer.Serialize(@event);

        var message = new Message<string, string>
        {
            Key = key,
            Value = value,
            Headers = new Headers
            {
                { "event-type", Encoding.UTF8.GetBytes(@event.EventType) },
                { "event-version", Encoding.UTF8.GetBytes(@event.EventVersion) },
                { "correlation-id", Encoding.UTF8.GetBytes(Guid.NewGuid().ToString()) }
            }
        };

        var result = await _producer.ProduceAsync(_topic, message, ct);

        _logger.LogInformation(
            "Published {EventType} to {Topic}:{Partition}@{Offset}",
            @event.EventType,
            result.Topic,
            result.Partition.Value,
            result.Offset.Value);
    }

    private static string GetPartitionKey<TEvent>(TEvent @event) where TEvent : DomainEvent
    {
        return @event switch
        {
            OrderCreatedEvent e => e.OrderId.ToString(),
            OrderSubmittedEvent e => e.OrderId.ToString(),
            OrderStatusChangedEvent e => e.OrderId.ToString(),
            _ => Guid.NewGuid().ToString()
        };
    }

    public async ValueTask DisposeAsync()
    {
        _producer.Flush(TimeSpan.FromSeconds(10));
        _producer.Dispose();
    }
}
```

## Event Design Patterns

### Event Envelope Pattern

```yaml
components:
  schemas:
    CloudEventEnvelope:
      type: object
      required:
        - specversion
        - type
        - source
        - id
        - time
        - data
      properties:
        specversion:
          type: string
          const: "1.0"
        type:
          type: string
          description: Event type (e.g., com.example.order.created)
        source:
          type: string
          format: uri
          description: Event source URI
        id:
          type: string
          format: uuid
        time:
          type: string
          format: date-time
        datacontenttype:
          type: string
          default: application/json
        dataschema:
          type: string
          format: uri
        subject:
          type: string
          description: Subject of event (e.g., order ID)
        data:
          type: object
          description: Event payload
```

### Event Versioning

```yaml
channels:
  orderEventsV1:
    address: orders.events.v1
    messages:
      orderCreatedV1:
        $ref: '#/components/messages/OrderCreatedV1'

  orderEventsV2:
    address: orders.events.v2
    messages:
      orderCreatedV2:
        $ref: '#/components/messages/OrderCreatedV2'

components:
  messages:
    OrderCreatedV1:
      name: OrderCreatedV1
      schemaFormat: application/vnd.aai.asyncapi+json;version=3.0.0
      payload:
        type: object
        properties:
          orderId:
            type: string
          # V1 schema

    OrderCreatedV2:
      name: OrderCreatedV2
      schemaFormat: application/vnd.aai.asyncapi+json;version=3.0.0
      payload:
        type: object
        properties:
          orderId:
            type: string
            format: uuid
          metadata:
            type: object
          # V2 schema with breaking changes
```

## Best Practices

### Channel Naming

```yaml
# Hierarchy: {domain}.{entity}.{action}.{version}
channels:
  orderCreated:
    address: orders.order.created.v1
  orderItemAdded:
    address: orders.lineitem.added.v1
  paymentProcessed:
    address: payments.payment.processed.v1
```

### Message Design

1. **Self-describing**: Include type and version in headers
2. **Idempotent**: Use event ID for deduplication
3. **Ordered**: Use partition keys for ordering
4. **Backward compatible**: Add fields, don't remove
5. **Complete**: Include all data consumers need (avoid chatty patterns)

### Security Considerations

```yaml
components:
  securitySchemes:
    oauth2:
      type: oauth2
      description: OAuth 2.0 authentication
      flows:
        clientCredentials:
          tokenUrl: https://auth.example.com/oauth/token
          scopes:
            orders:read: Read order events
            orders:write: Publish order events

    mtls:
      type: X509
      description: Mutual TLS authentication
```

## Workflow

When designing AsyncAPI specifications:

1. **Identify events**: What significant occurrences need to be communicated?
2. **Define channels**: What topics/queues will carry these events?
3. **Design messages**: What data does each event contain?
4. **Choose protocol**: Kafka, RabbitMQ, MQTT, etc.?
5. **Add bindings**: Protocol-specific configuration
6. **Document security**: Authentication and authorization
7. **Version strategy**: How will events evolve?
8. **Generate code**: Use AsyncAPI generator for clients/handlers

## MCP Research

For current AsyncAPI patterns and tools:

```text
perplexity: "AsyncAPI 3.0 specification" "event-driven API design patterns"
context7: "asyncapi" (for official documentation)
ref: "AsyncAPI spec examples" "Kafka binding patterns"
```

---

**Last Updated:** 2025-12-26
