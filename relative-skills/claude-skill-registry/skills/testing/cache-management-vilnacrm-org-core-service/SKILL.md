---
name: cache-management
description: Implement production-grade caching with cache keys/TTLs/consistency classes per query, SWR (stale-while-revalidate), explicit invalidation, and comprehensive testing for stale reads and cache warmup. Use when adding caching to queries, implementing cache invalidation, or ensuring cache consistency and performance.
---

# Cache Management Skill

## Context (Input)

Use this skill when:

- Adding caching to repositories or expensive queries
- Implementing cache invalidation via domain events
- Defining cache keys, TTLs, and consistency requirements
- Implementing stale-while-revalidate (SWR) pattern
- Testing cache behavior (stale reads, cold start, invalidation)
- Reducing database load with caching

## Task (Function)

Implement production-ready caching with proper key design, TTL management, event-driven invalidation, and comprehensive testing.

**Success Criteria**:

- Cache policy declared for each query (key, TTL, consistency class)
- Decorator pattern with `CachedXxxRepository` wrapping `MongoXxxRepository`
- Event-driven invalidation via domain event subscribers
- Best-effort invalidation (try/catch, never fail business operations)
- Comprehensive unit tests for all cache paths
- Cache observability (hit/miss/error logging)
- `make ci` outputs "✅ CI checks successfully passed!"

---

## ⚠️ CRITICAL CACHE POLICY

```text
╔═══════════════════════════════════════════════════════════════╗
║  ALWAYS use Decorator Pattern for caching (wrap repositories) ║
║  ALWAYS use CacheKeyBuilder service (prevent key drift)       ║
║  ALWAYS invalidate via Domain Events (decouple from business) ║
║  ALWAYS use TagAwareCacheInterface for cache tags             ║
║  ALWAYS wrap cache ops in try/catch (best-effort, no failures)║
║                                                               ║
║  ❌ FORBIDDEN: Caching in repository, implicit invalidation   ║
║  ✅ REQUIRED:  Decorator pattern, event-driven invalidation   ║
╚═══════════════════════════════════════════════════════════════╝
```

**Non-negotiable requirements**:

- Use Decorator Pattern: `CachedXxxRepository` wraps `MongoXxxRepository`
- Use centralized `CacheKeyBuilder` service (in `Shared/Infrastructure/Cache`)
- Invalidate via Domain Event Subscribers (one subscriber per event)
- Wrap ALL cache operations in try/catch (never fail business operations)
- Use `TagAwareCacheInterface` (not `CacheInterface`) for tag support
- Configure test cache pools with `tags: true` in `config/packages/test/cache.yaml`
- Log cache operations for observability

## File Locations (This Codebase)

| Component                | Location                                                                                       |
| ------------------------ | ---------------------------------------------------------------------------------------------- |
| CacheKeyBuilder          | `src/Shared/Infrastructure/Cache/CacheKeyBuilder.php`                                          |
| CachedCustomerRepository | `src/Core/Customer/Infrastructure/Repository/CachedCustomerRepository.php`                     |
| Created Invalidation Sub | `src/Core/Customer/Application/EventSubscriber/CustomerCreatedCacheInvalidationSubscriber.php` |
| Updated Invalidation Sub | `src/Core/Customer/Application/EventSubscriber/CustomerUpdatedCacheInvalidationSubscriber.php` |
| Deleted Invalidation Sub | `src/Core/Customer/Application/EventSubscriber/CustomerDeletedCacheInvalidationSubscriber.php` |
| Cache Pool Config        | `config/packages/cache.yaml`                                                                   |
| Test Cache Config        | `config/packages/test/cache.yaml`                                                              |
| Services Config          | `config/services.yaml`                                                                         |
| Repository Unit Tests    | `tests/Unit/Customer/Infrastructure/Repository/CachedCustomerRepositoryTest.php`               |
| Subscriber Unit Tests    | `tests/Unit/Customer/Application/EventSubscriber/*CacheInvalidation*Test.php`                  |

---

## TL;DR - Cache Management Checklist

**Before Implementing Cache:**

- [ ] Identified slow query worth caching (use query-performance-analysis)
- [ ] Cache policy declared (key pattern, TTL, consistency class)
- [ ] Cache tags defined for invalidation strategy
- [ ] Domain events defined for cache invalidation triggers

**Architecture Setup:**

- [ ] Created `CachedXxxRepository` decorator class
- [ ] Created `CacheKeyBuilder` service (or extended existing one)
- [ ] Created cache invalidation event subscribers (one per event)
- [ ] Configured services.yaml with explicit cache pool injection

**During Implementation:**

- [ ] Decorator wraps inner repository (not extends)
- [ ] CacheKeyBuilder used for all cache keys (prevents drift)
- [ ] Cache operations wrapped in try/catch (best-effort)
- [ ] Event subscribers use same CacheKeyBuilder for tags
- [ ] Logging added for cache hits/misses/errors
- [ ] Repository uses `TagAwareCacheInterface` (required for tags)

**Testing:**

- [ ] Test cache pool configured with `tags: true`
- [ ] Unit tests for cache invalidation subscribers
- [ ] Integration tests for stale reads after writes
- [ ] Test: Cache error fallback to database works

**Before Merge:**

- [ ] All cache tests pass
- [ ] Cache observability verified (logs present)
- [ ] CI checks pass (`make ci`)
- [ ] No cache-related stale data issues

---

## Quick Start: Cache in 7 Steps

### Step 1: Declare Cache Policy

**Before writing code, declare the complete policy:**

```php
/**
 * Cache Policy for Customer By ID Query
 *
 * Key Pattern: customer.{id}
 * TTL: 600s (10 minutes)
 * Consistency: Stale-While-Revalidate
 * Invalidation: Via domain events (CustomerCreated/Updated/Deleted)
 * Tags: [customer, customer.{id}]
 * Notes: Read-heavy operation, tolerates brief staleness
 */
```

### Step 2: Create CacheKeyBuilder Service

**Location**: `src/Shared/Infrastructure/Cache/CacheKeyBuilder.php`

```php
final readonly class CacheKeyBuilder
{
    public function build(string $namespace, string ...$parts): string
    {
        return $namespace . '.' . implode('.', $parts);
    }

    public function buildCustomerKey(string $customerId): string
    {
        return $this->build('customer', $customerId);
    }

    public function buildCustomerEmailKey(string $email): string
    {
        return $this->build('customer', 'email', $this->hashEmail($email));
    }

    /**
     * Build cache key for collections (filters normalized + hashed)
     * @param array<string, string|int|float|bool|array|null> $filters
     */
    public function buildCustomerCollectionKey(array $filters): string
    {
        ksort($filters);  // Normalize key order
        return $this->build(
            'customer',
            'collection',
            hash('sha256', json_encode($filters, \JSON_THROW_ON_ERROR))
        );
    }

    /**
     * Hash email consistently (lowercase + SHA256)
     * - Lowercase normalization (email case-insensitive)
     * - SHA256 hashing (fixed length, prevents key length issues)
     */
    public function hashEmail(string $email): string
    {
        return hash('sha256', strtolower($email));
    }
}
```

### Step 3: Create Cached Repository Decorator

**Location**: `src/Core/{Entity}/Infrastructure/Repository/Cached{Entity}Repository.php`

```php
/**
 * Cached Customer Repository Decorator
 *
 * Responsibilities:
 * - Read-through caching with Stale-While-Revalidate (SWR)
 * - Cache key management via CacheKeyBuilder
 * - Graceful fallback to database on cache errors
 * - Delegates ALL persistence operations to inner repository
 *
 * Cache Invalidation:
 * - Handled by *CacheInvalidationSubscriber classes via domain events
 * - This class only reads from cache, never invalidates (except delete)
 */
final class CachedCustomerRepository implements CustomerRepositoryInterface
{
    public function __construct(
        private CustomerRepositoryInterface $inner,  // Wraps MongoCustomerRepository
        private TagAwareCacheInterface $cache,
        private CacheKeyBuilder $cacheKeyBuilder,
        private LoggerInterface $logger
    ) {}

    /**
     * Proxy all other method calls to inner repository
     * Required for API Platform's collection provider compatibility
     * @param array<int, mixed> $arguments
     */
    public function __call(string $method, array $arguments): mixed
    {
        return $this->inner->{$method}(...$arguments);
    }

    public function find(mixed $id, int $lockMode = 0, ?int $lockVersion = null): ?Customer
    {
        $cacheKey = $this->cacheKeyBuilder->buildCustomerKey((string) $id);

        try {
            return $this->cache->get(
                $cacheKey,
                fn (ItemInterface $item) => $this->loadCustomerFromDb($id, $lockMode, $lockVersion, $cacheKey, $item),
                beta: 1.0  // Enable Stale-While-Revalidate
            );
        } catch (\Throwable $e) {
            $this->logCacheError($cacheKey, $e);
            return $this->inner->find($id, $lockMode, $lockVersion);  // Graceful fallback
        }
    }

    public function findByEmail(string $email): ?Customer
    {
        $cacheKey = $this->cacheKeyBuilder->buildCustomerEmailKey($email);

        try {
            return $this->cache->get(
                $cacheKey,
                fn (ItemInterface $item) => $this->loadCustomerByEmail($email, $cacheKey, $item)
            );
        } catch (\Throwable $e) {
            $this->logCacheError($cacheKey, $e);
            return $this->inner->findByEmail($email);
        }
    }

    public function save(Customer $customer): void
    {
        $this->inner->save($customer);
        // NO cache invalidation here - handled by domain event subscribers
    }

    public function delete(Customer $customer): void
    {
        // Delete is special: invalidate BEFORE deletion (best-effort)
        try {
            $this->cache->invalidateTags([
                "customer.{$customer->getUlid()}",
                "customer.email.{$this->cacheKeyBuilder->hashEmail($customer->getEmail())}",
                'customer.collection',
            ]);
            $this->logger->info('Cache invalidated before customer deletion', [
                'customer_id' => $customer->getUlid(),
                'operation' => 'cache.invalidation',
                'reason' => 'customer_deleted',
            ]);
        } catch (\Throwable $e) {
            $this->logger->error('Cache invalidation failed during deletion - proceeding anyway', [
                'customer_id' => $customer->getUlid(),
                'error' => $e->getMessage(),
                'operation' => 'cache.invalidation.error',
            ]);
        }
        $this->inner->delete($customer);
    }

    private function loadCustomerFromDb(mixed $id, int $lockMode, ?int $lockVersion, string $cacheKey, ItemInterface $item): ?Customer
    {
        $item->expiresAfter(600);  // 10 minutes TTL
        $item->tag(['customer', "customer.{$id}"]);

        $this->logger->info('Cache miss - loading customer from database', [
            'cache_key' => $cacheKey,
            'customer_id' => $id,
            'operation' => 'cache.miss',
        ]);

        return $this->inner->find($id, $lockMode, $lockVersion);
    }

    private function loadCustomerByEmail(string $email, string $cacheKey, ItemInterface $item): ?Customer
    {
        $item->expiresAfter(300);  // 5 minutes TTL
        $emailHash = $this->cacheKeyBuilder->hashEmail($email);
        $item->tag(['customer', 'customer.email', "customer.email.{$emailHash}"]);

        $this->logger->info('Cache miss - loading customer by email', [
            'cache_key' => $cacheKey,
            'operation' => 'cache.miss',
        ]);

        return $this->inner->findByEmail($email);
    }

    private function logCacheError(string $cacheKey, \Throwable $e): void
    {
        $this->logger->error('Cache error - falling back to database', [
            'cache_key' => $cacheKey,
            'error' => $e->getMessage(),
            'operation' => 'cache.error',
        ]);
    }
}
```

### Step 4: Create Event Subscribers for Invalidation

**Location**: `src/Core/{Entity}/Application/EventSubscriber/{Event}CacheInvalidationSubscriber.php`

**IMPORTANT**: Create ONE subscriber per event (CustomerCreated, CustomerUpdated, CustomerDeleted).

```php
/**
 * Customer Updated Event Cache Invalidation Subscriber
 * Handles email change edge case (both old and new email caches)
 */
final readonly class CustomerUpdatedCacheInvalidationSubscriber implements DomainEventSubscriberInterface
{
    public function __construct(
        private TagAwareCacheInterface $cache,
        private CacheKeyBuilder $cacheKeyBuilder,
        private LoggerInterface $logger
    ) {}

    public function __invoke(CustomerUpdatedEvent $event): void
    {
        // Best-effort: don't fail business operation if cache is down
        try {
            $tagsToInvalidate = $this->buildTagsToInvalidate($event);
            $this->cache->invalidateTags($tagsToInvalidate);
            $this->logSuccess($event);
        } catch (\Throwable $e) {
            $this->logError($event, $e);
        }
    }

    /** @return array<class-string> */
    public function subscribedTo(): array
    {
        return [CustomerUpdatedEvent::class];
    }

    /** @return array<string> */
    private function buildTagsToInvalidate(CustomerUpdatedEvent $event): array
    {
        $tags = [
            'customer.' . $event->customerId(),
            'customer.email.' . $this->cacheKeyBuilder->hashEmail($event->currentEmail()),
            'customer.collection',
        ];

        // CRITICAL: If email changed, invalidate previous email cache too!
        if ($event->emailChanged() && $event->previousEmail() !== null) {
            $tags[] = 'customer.email.' . $this->cacheKeyBuilder->hashEmail($event->previousEmail());
        }

        return $tags;
    }

    private function logSuccess(CustomerUpdatedEvent $event): void
    {
        $this->logger->info('Cache invalidated after customer update', [
            'customer_id' => $event->customerId(),
            'email_changed' => $event->emailChanged(),
            'event_id' => $event->eventId(),
            'operation' => 'cache.invalidation',
            'reason' => 'customer_updated',
        ]);
    }

    private function logError(CustomerUpdatedEvent $event, \Throwable $e): void
    {
        $this->logger->error('Cache invalidation failed after customer update', [
            'customer_id' => $event->customerId(),
            'event_id' => $event->eventId(),
            'error' => $e->getMessage(),
            'operation' => 'cache.invalidation.error',
        ]);
    }
}
```

**Simpler subscriber for Created/Deleted events:**

```php
final readonly class CustomerCreatedCacheInvalidationSubscriber implements DomainEventSubscriberInterface
{
    public function __construct(
        private TagAwareCacheInterface $cache,
        private CacheKeyBuilder $cacheKeyBuilder,
        private LoggerInterface $logger
    ) {}

    public function __invoke(CustomerCreatedEvent $event): void
    {
        try {
            $this->cache->invalidateTags([
                'customer.' . $event->customerId(),
                'customer.email.' . $this->cacheKeyBuilder->hashEmail($event->customerEmail()),
                'customer.collection',
            ]);
            $this->logger->info('Cache invalidated after customer creation', [
                'customer_id' => $event->customerId(),
                'event_id' => $event->eventId(),
                'operation' => 'cache.invalidation',
                'reason' => 'customer_created',
            ]);
        } catch (\Throwable $e) {
            $this->logger->error('Cache invalidation failed after customer creation', [
                'customer_id' => $event->customerId(),
                'event_id' => $event->eventId(),
                'error' => $e->getMessage(),
                'operation' => 'cache.invalidation.error',
            ]);
        }
    }

    /** @return array<class-string> */
    public function subscribedTo(): array
    {
        return [CustomerCreatedEvent::class];
    }
}
```

### Step 5: Configure services.yaml

**Location**: `config/services.yaml`

```yaml
services:
  # Base repository - used by API Platform for collections
  App\Core\Customer\Infrastructure\Repository\MongoCustomerRepository:
    public: true

  # Cached repository - wraps base repository with caching
  App\Core\Customer\Infrastructure\Repository\CachedCustomerRepository:
    arguments:
      $inner: '@App\Core\Customer\Infrastructure\Repository\MongoCustomerRepository'
      $cache: '@cache.customer'

  # Alias interface to cached repository for dependency injection
  App\Core\Customer\Domain\Repository\CustomerRepositoryInterface:
    alias: App\Core\Customer\Infrastructure\Repository\CachedCustomerRepository
    public: true

  # Cache invalidation event subscribers - explicitly inject cache.customer
  App\Core\Customer\Application\EventSubscriber\CustomerCreatedCacheInvalidationSubscriber:
    arguments:
      $cache: '@cache.customer'

  App\Core\Customer\Application\EventSubscriber\CustomerUpdatedCacheInvalidationSubscriber:
    arguments:
      $cache: '@cache.customer'

  App\Core\Customer\Application\EventSubscriber\CustomerDeletedCacheInvalidationSubscriber:
    arguments:
      $cache: '@cache.customer'

  # CacheKeyBuilder - auto-registered via App\ namespace
```

**CRITICAL**: Always explicitly inject the named cache pool (`@cache.customer`) instead of relying on autowiring.

### Step 6: Configure Cache Pools

**Production** - `config/packages/cache.yaml`:

```yaml
framework:
  cache:
    app: cache.adapter.redis
    default_redis_provider: '%env(resolve:REDIS_URL)%'

    pools:
      app:
        adapter: cache.adapter.redis
        default_lifetime: 86400 # 24 hours
        provider: '%env(resolve:REDIS_URL)%'
      cache.customer:
        adapter: cache.adapter.redis
        default_lifetime: 600 # 10 minutes
        provider: '%env(resolve:REDIS_URL)%'
        tags: true # REQUIRED for TagAwareCacheInterface
```

**Test** - `config/packages/test/cache.yaml`:

```yaml
framework:
  cache:
    app: cache.adapter.array
    default_redis_provider: null
    pools:
      app:
        adapter: cache.adapter.array
        provider: null
      cache.customer:
        adapter: cache.adapter.array
        provider: null
        tags: true # CRITICAL: Must have tags: true for TagAwareCacheInterface!
```

**CRITICAL**: Test cache pools MUST have `tags: true` for `$cache->invalidateTags()` to work!

### Step 7: Verify with CI

```bash
make ci
```

---

## The Three Pillars of Cache Management

### 1. Cache Policies (Keys, TTLs, Consistency)

**What**: Declare cache configuration before implementation

**Key Elements**:

- Cache key pattern (namespace + identifier)
- TTL (based on data freshness requirements)
- Consistency class (Strong, Eventual, SWR)
- Cache tags (for invalidation)

**Example Policy Decision Matrix**:

| Data Type       | TTL      | Consistency | Invalidation      |
| --------------- | -------- | ----------- | ----------------- |
| User profile    | 5-10 min | SWR         | On update/delete  |
| Product catalog | 1 hour   | SWR         | On product change |
| Configuration   | 1 day    | Strong      | Manual/deployment |
| Search results  | 1 min    | Eventual    | Time-based only   |

**See**: [reference/cache-policies.md](reference/cache-policies.md) for complete guide

### 2. Invalidation Strategies (Explicit, Never Implicit)

**What**: Explicit cache clearing on write operations

**Strategies**:

- **Write-through**: Invalidate immediately after writes
- **Tag-based**: Batch invalidation using cache tags
- **Event-driven**: Invalidate via domain events
- **Time-based**: TTL-only (for static data)

**Critical Rule**: ALWAYS invalidate explicitly on create/update/delete

```php
// ✅ CORRECT
$this->repository->save($customer);
$this->cache->invalidateTags(["customer.{$id}"]);

// ❌ WRONG - Missing invalidation
$this->repository->save($customer);
// Cache now stale until TTL expires!
```

**See**: [reference/invalidation-strategies.md](reference/invalidation-strategies.md)

### 3. Testing (Stale Reads, Cold Start, Invalidation)

**What**: Comprehensive test coverage for all cache behaviors

**Required Tests**:

- ✅ Stale reads after writes
- ✅ Cache warmup on cold start
- ✅ TTL expiration behavior
- ✅ Tag-based invalidation
- ✅ SWR background refresh (if applicable)

**See**: [examples/cache-testing.md](examples/cache-testing.md)

---

## Stale-While-Revalidate (SWR) Pattern

**When to use**: High-traffic queries that tolerate brief staleness

**How it works**:

1. Serve cached data immediately (even if stale)
2. Refresh cache in background
3. Return fresh data on next request

**Implementation**:

```php
public function findById(string $id): ?Customer
{
    return $this->cache->get(
        "customer.{$id}",
        fn($item) => $this->loadFromDatabase($id, $item),
        beta: 1.0  // Enable probabilistic early expiration
    );
}
```

**See**: [reference/swr-pattern.md](reference/swr-pattern.md) for complete implementation with background refresh

---

## Integration with Hexagonal Architecture

### Domain Layer

- **NO caching** - Pure business logic
- Domain entities are cache-agnostic
- Domain events carry data needed for cache invalidation

### Application Layer

- **Command Handlers** publish domain events (not invalidate directly)
- **Event Subscribers** handle cache invalidation via domain events

### Infrastructure Layer

- **CachedXxxRepository** decorates MongoXxxRepository (read-through caching)
- **MongoXxxRepository** handles persistence only
- Cache invalidation triggered by domain events, NOT in save()

**Architecture Flow**:

```text
┌─────────────────────────────────────────────────────────────┐
│  Command Handler                                            │
│  └─ repository.save(customer)                               │
│  └─ eventBus.publish(CustomerUpdatedEvent)                  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  CachedCustomerRepository (Decorator)                       │
│  └─ inner.save(customer)  // delegates to Mongo             │
│  └─ (NO invalidation here!)                                 │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  CustomerUpdatedCacheInvalidationSubscriber                 │
│  └─ cache.invalidateTags([...])  // event-driven!           │
└─────────────────────────────────────────────────────────────┘
```

**Why Event-Driven Invalidation?**

1. **Decoupling**: Repository doesn't know about cache invalidation strategy
2. **Testability**: Easier to test invalidation logic separately
3. **Flexibility**: Can add more invalidation logic without touching repository
4. **Consistency**: Same event triggers multiple side effects (cache, notifications, etc.)

---

## Cache Observability

**Log cache operations**:

```php
$this->logger->info('Cache miss - loading from database', [
    'cache_key' => $cacheKey,
    'customer_id' => $id,
    'operation' => 'cache.miss',
]);
```

**Track metrics**:

- Cache hit rate: `cache.hit.total / (cache.hit.total + cache.miss.total)`
- Cache miss rate: `cache.miss.total / total_requests`
- Cache operation latency: `cache.operation.duration_ms`
- Invalidation frequency: `cache.invalidation.total`

**See**: [observability-instrumentation](../observability-instrumentation/SKILL.md) for complete instrumentation patterns

---

## Common Pitfalls

### ❌ DON'T

- Don't cache without declaring policy first
- Don't cache without TTL
- Don't cache in Domain layer
- Don't use implicit invalidation (use events!)
- Don't share cache keys between different queries
- Don't cache sensitive data (PII, passwords, tokens)
- Don't cache without testing all paths
- Don't forget to log cache operations
- Don't invalidate in repository save() method (use event subscribers!)
- Don't forget to handle email changes (invalidate both old and new email caches)

### ✅ DO

- Declare complete cache policy before coding
- Use cache tags for flexible invalidation
- Test invalidation explicitly
- Use SWR for read-heavy, stale-tolerant data
- Invalidate on all writes (create, update, delete)
- Log all cache operations
- Monitor cache hit rate in production
- Add observability (logs, metrics)
- Use `__call()` magic method for API Platform compatibility
- Wrap ALL cache operations in try/catch

---

## Unit Testing Patterns

### Test Structure for Cached Repository

```php
final class CachedCustomerRepositoryTest extends UnitTestCase
{
    private CustomerRepositoryInterface&MockObject $innerRepository;
    private TagAwareCacheInterface&MockObject $cache;
    private CacheKeyBuilder&MockObject $cacheKeyBuilder;
    private LoggerInterface&MockObject $logger;
    private CachedCustomerRepository $repository;

    protected function setUp(): void
    {
        parent::setUp();
        $this->innerRepository = $this->createMock(CustomerRepositoryInterface::class);
        $this->cache = $this->createMock(TagAwareCacheInterface::class);
        $this->cacheKeyBuilder = $this->createMock(CacheKeyBuilder::class);
        $this->logger = $this->createMock(LoggerInterface::class);

        $this->repository = new CachedCustomerRepository(
            $this->innerRepository,
            $this->cache,
            $this->cacheKeyBuilder,
            $this->logger
        );
    }
```

### Required Test Cases for Cached Repository

```php
// 1. Cache key built correctly
public function testFindUsesCacheWithCorrectKey(): void
{
    $customerId = (string) $this->faker->ulid();
    $cacheKey = 'customer.' . $customerId;
    $customer = $this->createMock(Customer::class);

    $this->cacheKeyBuilder->expects($this->once())
        ->method('buildCustomerKey')
        ->with($customerId)
        ->willReturn($cacheKey);

    $this->cache->expects($this->once())
        ->method('get')
        ->with($cacheKey, $this->isType('callable'), 1.0)
        ->willReturn($customer);

    $result = $this->repository->find($customerId);
    self::assertSame($customer, $result);
}

// 2. Graceful fallback on cache error
public function testFindFallsBackToDatabaseOnCacheError(): void
{
    $customerId = (string) $this->faker->ulid();
    $customer = $this->createMock(Customer::class);

    $this->cache->expects($this->once())
        ->method('get')
        ->willThrowException(new \RuntimeException('Cache unavailable'));

    $this->logger->expects($this->once())
        ->method('error')
        ->with('Cache error - falling back to database', $this->anything());

    $this->innerRepository->expects($this->once())
        ->method('find')
        ->willReturn($customer);

    $result = $this->repository->find($customerId);
    self::assertSame($customer, $result);
}

// 3. Cache miss loads from database with proper tags
public function testFindCacheMissLoadsFromDatabase(): void
{
    $customerId = (string) $this->faker->ulid();
    $cacheItem = $this->createMock(ItemInterface::class);

    $cacheItem->expects($this->once())->method('expiresAfter')->with(600);
    $cacheItem->expects($this->once())->method('tag')->with(['customer', 'customer.' . $customerId]);

    $this->cache->expects($this->once())
        ->method('get')
        ->willReturnCallback(fn($key, $callback) => $callback($cacheItem));

    // ... assertions
}

// 4. Delete invalidates cache before deletion
public function testDeleteInvalidatesCacheAndDelegatesToInnerRepository(): void
{
    $customer = $this->createMock(Customer::class);
    $customer->method('getUlid')->willReturn('01ABC123');
    $customer->method('getEmail')->willReturn('test@example.com');

    $this->cache->expects($this->once())
        ->method('invalidateTags')
        ->with(['customer.01ABC123', 'customer.email.hash123', 'customer.collection']);

    $this->innerRepository->expects($this->once())->method('delete')->with($customer);

    $this->repository->delete($customer);
}

// 5. Delete proceeds even on cache failure
public function testDeleteProceedsEvenWhenCacheInvalidationFails(): void
{
    $this->cache->method('invalidateTags')
        ->willThrowException(new \RuntimeException('Redis down'));

    $this->logger->expects($this->once())->method('error');
    $this->innerRepository->expects($this->once())->method('delete');

    $this->repository->delete($customer);  // Should NOT throw
}
```

### Required Test Cases for Event Subscribers

```php
// 1. Correct events subscribed
public function testSubscribedToReturnsCorrectEvents(): void
{
    $subscribedEvents = $this->subscriber->subscribedTo();
    self::assertContains(CustomerUpdatedEvent::class, $subscribedEvents);
}

// 2. Cache invalidated with correct tags
public function testInvokeInvalidatesCacheWithCorrectTags(): void
{
    $event = new CustomerUpdatedEvent(customerId: $customerId, currentEmail: 'test@example.com');

    $this->cache->expects($this->once())
        ->method('invalidateTags')
        ->with(['customer.' . $customerId, 'customer.email.hash123', 'customer.collection']);

    ($this->subscriber)($event);
}

// 3. Email change invalidates BOTH old and new email caches
public function testInvokeInvalidatesCacheWithEmailChange(): void
{
    $event = new CustomerUpdatedEvent(
        customerId: $customerId,
        currentEmail: 'new@example.com',
        previousEmail: 'old@example.com'
    );

    $this->cache->expects($this->once())
        ->method('invalidateTags')
        ->with($this->callback(function ($tags) {
            return in_array('customer.email.new_hash', $tags)
                && in_array('customer.email.old_hash', $tags);
        }));

    ($this->subscriber)($event);
}

// 4. Cache failure doesn't throw (best-effort)
public function testInvokeLogsErrorWhenCacheInvalidationFails(): void
{
    $this->cache->method('invalidateTags')
        ->willThrowException(new \RuntimeException('Redis connection failed'));

    $this->logger->expects($this->once())->method('error');
    $this->logger->expects($this->never())->method('info');

    ($this->subscriber)($event);  // Should NOT throw
}
```

---

## Integration with Other Skills

**Identify queries to cache**:

- [query-performance-analysis](../query-performance-analysis/SKILL.md) - Find slow queries

**Add observability**:

- [observability-instrumentation](../observability-instrumentation/SKILL.md) - Cache metrics and logs

**Test cache behavior**:

- [testing-workflow](../testing-workflow/SKILL.md) - Test framework guidance

**Architecture placement**:

- [implementing-ddd-architecture](../implementing-ddd-architecture/SKILL.md) - Layer separation

---

## Quick Reference

| Pattern                | Code Example                                    |
| ---------------------- | ----------------------------------------------- |
| **Read-through cache** | `$cache->get($key, fn($item) => $loadFromDb())` |
| **Set TTL**            | `$item->expiresAfter(300)` (seconds)            |
| **Set cache tag**      | `$item->tag(['entity', 'entity.id'])`           |
| **Invalidate by tag**  | `$cache->invalidateTags(['entity.id'])`         |
| **Clear all cache**    | `$cache->clear()`                               |
| **Build cache key**    | `"{prefix}.{id}"` (namespace + identifier)      |
| **Enable SWR**         | `$cache->get($key, $callback, beta: 1.0)`       |

---

## Additional Resources

### Reference Documentation

- **[Cache Policies](reference/cache-policies.md)** - TTL selection, consistency classes, policy matrix
- **[Invalidation Strategies](reference/invalidation-strategies.md)** - Write-through, tag-based, event-driven patterns
- **[SWR Pattern](reference/swr-pattern.md)** - Complete stale-while-revalidate implementation

### Complete Examples

- **[Cache Implementation](examples/cache-implementation.md)** - Full repository with caching, invalidation, observability
- **[Cache Testing](examples/cache-testing.md)** - Complete test suite for all cache behaviors

---

**For detailed implementation patterns, invalidation strategies, and test patterns → See supporting files in `reference/` and `examples/` directories.**
