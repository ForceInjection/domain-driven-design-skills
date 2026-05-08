---
name: spring-kafka-integration
description: "[Extends backend-developer] Kafka specialist for Spring/Reactor. Use for Kafka producers/consumers, DLT, retry mechanisms, transactional outbox, event sourcing. Covers Spring Kafka 4.x and Reactor Kafka 1.3.x. Invoke alongside backend-developer."
---

# Spring Kafka Integration

> **Extends:** backend-developer
> **Type:** Specialized Skill

## Trigger

Use this skill alongside `backend-developer` when:
- Implementing event-driven architecture
- Setting up Kafka producers/consumers
- Configuring Dead Letter Topics (DLT)
- Implementing transactional outbox pattern
- Reactive Kafka streaming with WebFlux
- Event sourcing or CQRS patterns
- Testing Kafka integrations

## Context

You are a Senior Kafka Integration Specialist with deep expertise in Apache Kafka and Spring Kafka. You design and implement reliable, scalable event-driven systems. You understand both blocking (Spring Kafka) and reactive (Reactor Kafka) approaches and choose appropriately based on the application's needs.

## Expertise

### Versions

| Technology | Version | Notes |
|------------|---------|-------|
| Spring Kafka | 3.x / 4.x | For Spring Boot 3.x / 4.x |
| Reactor Kafka | 1.3.x | For reactive applications |
| Apache Kafka | 3.x / 4.x | KRaft mode (4.x has no ZooKeeper) |

### Blocking Mode: Spring Kafka

#### KafkaTemplate (Producer)

```java
@Component
@RequiredArgsConstructor
@Slf4j
public class EventPublisher {
    private final KafkaTemplate<String, Object> kafkaTemplate;

    public CompletableFuture<SendResult<String, Object>> publish(
            String topic, String key, Object event) {
        return kafkaTemplate.send(topic, key, event)
            .whenComplete((result, ex) -> {
                if (ex == null) {
                    log.info("Published to {} partition {}",
                        topic, result.getRecordMetadata().partition());
                } else {
                    log.error("Failed to publish to {}", topic, ex);
                }
            });
    }
}
```

#### @KafkaListener (Consumer)

```java
@Component
@RequiredArgsConstructor
@Slf4j
public class EventConsumer {

    @KafkaListener(topics = "${app.kafka.topics.events}")
    public void handle(
            @Payload Event event,
            @Header(KafkaHeaders.RECEIVED_PARTITION) int partition,
            Acknowledgment ack) {
        try {
            processEvent(event);
            ack.acknowledge();
        } catch (Exception e) {
            log.error("Processing failed", e);
            throw e; // Triggers retry/DLT
        }
    }
}
```

#### Dead Letter Topic (DLT) Configuration

```java
@Bean
public DefaultErrorHandler errorHandler(KafkaTemplate<String, Object> template) {
    var recoverer = new DeadLetterPublishingRecoverer(template);
    var backOff = new ExponentialBackOffWithMaxRetries(3);
    backOff.setInitialInterval(1000L);
    backOff.setMultiplier(2.0);
    return new DefaultErrorHandler(recoverer, backOff);
}
```

### Reactive Mode: Reactor Kafka

Use Reactor Kafka when:
- Application uses Spring WebFlux
- Using Project Reactor (Mono/Flux)
- Need non-blocking Kafka operations
- High-throughput streaming required

#### KafkaSender (Reactive Producer)

```java
@Configuration
public class ReactiveKafkaConfig {

    @Bean
    public KafkaSender<String, Object> kafkaSender(KafkaProperties properties) {
        Map<String, Object> props = new HashMap<>(properties.buildProducerProperties());
        props.put(ProducerConfig.ACKS_CONFIG, "all");
        props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);

        SenderOptions<String, Object> senderOptions = SenderOptions
            .<String, Object>create(props)
            .maxInFlight(256)  // Backpressure control
            .stopOnError(false);

        return KafkaSender.create(senderOptions);
    }
}

@Service
@RequiredArgsConstructor
@Slf4j
public class ReactiveEventPublisher {
    private final KafkaSender<String, Object> kafkaSender;

    public Mono<SenderResult<Void>> publish(String topic, String key, Object event) {
        SenderRecord<String, Object, Void> record = SenderRecord.create(
            new ProducerRecord<>(topic, key, event), null);

        return kafkaSender.send(Mono.just(record))
            .single()
            .doOnSuccess(r -> log.info("Published to {} offset {}",
                topic, r.recordMetadata().offset()))
            .doOnError(e -> log.error("Failed to publish", e));
    }

    public Flux<SenderResult<String>> publishBatch(String topic, Flux<Event> events) {
        return kafkaSender.send(events.map(event ->
            SenderRecord.create(topic, null, null, event.getId(), event, event.getId())
        ));
    }
}
```

#### KafkaReceiver (Reactive Consumer)

```java
@Configuration
public class ReactiveKafkaReceiverConfig {

    @Bean
    public KafkaReceiver<String, Object> kafkaReceiver(KafkaProperties properties) {
        Map<String, Object> props = new HashMap<>(properties.buildConsumerProperties());

        ReceiverOptions<String, Object> receiverOptions = ReceiverOptions
            .<String, Object>create(props)
            .subscription(List.of("events-topic"))
            .commitInterval(Duration.ofSeconds(5))
            .commitBatchSize(100)
            .maxDeferredCommits(100);  // Out-of-order commits

        return KafkaReceiver.create(receiverOptions);
    }
}

@Service
@RequiredArgsConstructor
@Slf4j
public class ReactiveEventConsumer {
    private final KafkaReceiver<String, Object> kafkaReceiver;

    @PostConstruct
    public void consume() {
        kafkaReceiver.receive()
            .groupBy(r -> r.receiverOffset().topicPartition())  // Per-partition ordering
            .flatMap(partition -> partition
                .publishOn(Schedulers.boundedElastic())
                .flatMap(record -> processRecord(record)
                    .doOnSuccess(v -> record.receiverOffset().acknowledge())
                    .doOnError(e -> log.error("Processing failed", e))
                )
            )
            .retryWhen(Retry.backoff(3, Duration.ofSeconds(1)))
            .subscribe();
    }

    private Mono<Void> processRecord(ReceiverRecord<String, Object> record) {
        return Mono.fromRunnable(() -> {
            log.info("Processing: {}", record.value());
            // Process event
        });
    }
}
```

#### Delivery Semantics

**At-Least-Once** (default):
```java
kafkaReceiver.receive()
    .flatMap(record -> process(record)
        .doOnSuccess(v -> record.receiverOffset().acknowledge()))
    .subscribe();
```

**At-Most-Once**:
```java
kafkaReceiver.receiveAtmostOnce()
    .flatMap(record -> process(record.value()))
    .subscribe();
```

**Exactly-Once** (with transactions):
```java
kafkaReceiver.receiveExactlyOnce(kafkaSender.transactionManager())
    .flatMap(flux -> kafkaSender.send(flux.map(this::transform)))
    .subscribe();
```

#### Backpressure Handling

```java
SenderOptions<String, Object> senderOptions = SenderOptions
    .<String, Object>create(props)
    .maxInFlight(256)  // Limit concurrent requests
    .scheduler(Schedulers.boundedElastic());

// Producer properties
props.put(ProducerConfig.BUFFER_MEMORY_CONFIG, 33554432);  // 32MB
props.put(ProducerConfig.MAX_BLOCK_MS_CONFIG, 5000);
```

### Patterns

#### Transactional Outbox Pattern

```java
@Service
@RequiredArgsConstructor
public class OutboxService {
    private final OutboxRepository outboxRepository;
    private final KafkaTemplate<String, Object> kafkaTemplate;

    @Transactional
    public void saveWithOutbox(Entity entity, Event event) {
        entityRepository.save(entity);
        outboxRepository.save(new OutboxEntry(event));
    }

    @Scheduled(fixedDelay = 1000)
    @Transactional
    public void publishOutbox() {
        outboxRepository.findUnpublished().forEach(entry -> {
            kafkaTemplate.send(entry.getTopic(), entry.getKey(), entry.getPayload())
                .whenComplete((r, e) -> {
                    if (e == null) {
                        entry.markPublished();
                    }
                });
        });
    }
}
```

#### Event Sourcing

```java
@Service
public class EventStore {
    private final KafkaTemplate<String, DomainEvent> kafkaTemplate;

    public void append(String aggregateId, DomainEvent event) {
        kafkaTemplate.send("events-" + event.getAggregateType(), aggregateId, event);
    }
}
```

### Testing

#### EmbeddedKafka

```java
@SpringBootTest
@EmbeddedKafka(partitions = 1, topics = {"test-topic"})
class KafkaIntegrationTest {

    @Autowired
    private KafkaTemplate<String, Object> kafkaTemplate;

    @Autowired
    private EmbeddedKafkaBroker embeddedKafka;

    @Test
    void shouldPublishAndConsume() throws Exception {
        kafkaTemplate.send("test-topic", "key", new TestEvent("data")).get();

        // Assert consumer received the message
    }
}
```

#### Testcontainers

```java
@Testcontainers
@SpringBootTest
class KafkaContainerTest {

    @Container
    static KafkaContainer kafka = new KafkaContainer(
        DockerImageName.parse("confluentinc/cp-kafka:7.5.0"));

    @DynamicPropertySource
    static void kafkaProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.kafka.bootstrap-servers", kafka::getBootstrapServers);
    }

    @Test
    void testWithRealKafka() {
        // Test with real Kafka
    }
}
```

## Parent & Related Skills

| Skill | Relationship |
|-------|--------------|
| **backend-developer** | Parent skill - invoke for Spring Boot patterns |
| **architect** | For event-driven architecture patterns, CQRS design |
| **database-architect** | For event store design, outbox table schema |
| **sre** | For Kafka cluster reliability, consumer lag monitoring |

## Standards

- **Idempotent producers**: Always enable `enable.idempotence=true`
- **Proper retry**: Configure exponential backoff with max retries
- **DLT for all consumers**: Failed messages go to dead letter topic
- **Use Reactor Kafka for WebFlux**: Don't block in reactive applications
- **Document event contracts**: Schema for all events
- **Monitor lag**: Track consumer group lag
- **Partition key strategy**: Choose keys that distribute evenly

## Checklist

### Before Implementing
- [ ] Event schema defined
- [ ] Partition key strategy decided
- [ ] DLT naming convention set
- [ ] Retry policy defined
- [ ] Consumer group naming convention

### Before Deploying
- [ ] Idempotent producer enabled
- [ ] DLT configured
- [ ] Retry with backoff configured
- [ ] Consumer lag monitoring
- [ ] Error handling tested

## Anti-Patterns to Avoid

1. **Fire-and-forget**: Always handle send errors
2. **Unbounded retry**: Use max retries with DLT
3. **Missing consumer group**: Always set group.id
4. **Sync in reactive**: Never block in Reactor Kafka
5. **No backpressure**: Configure maxInFlight
6. **Ignoring offset commits**: Commit after processing
7. **Large messages**: Keep messages small, use references
