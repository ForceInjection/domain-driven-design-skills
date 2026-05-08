---
name: background-job
description: Use when creating recurring jobs, scheduled tasks, or batch processing operations with proper paging strategies.
---

# Background Job Development Workflow

## When to Use This Skill
- Scheduled/recurring tasks (cron-based)
- Batch data processing
- Bulk operations across tenants
- Data synchronization jobs
- Cleanup/maintenance tasks

## Pre-Flight Checklist
- [ ] Identify job frequency (hourly, daily, weekly)
- [ ] Determine if single-tenant or multi-tenant
- [ ] Choose pagination strategy (Paged, Scrolling, BatchScrolling)
- [ ] Search existing jobs: `grep "BackgroundJob.*{Feature}" --include="*.cs"`

## File Location
```
{Service}.Application/
└── BackgroundJobs/
    └── {Feature}/
        └── {JobName}BackgroundJob.cs
```

## Job Type Decision Tree

```
Does processing affect the query result?
├── NO → Simple Paged (skip/take stays consistent)
│   └── Use: PlatformApplicationPagedBackgroundJobExecutor
│
└── YES → Scrolling needed (processed items excluded from next query)
    │
    └── Is this multi-tenant (company-based)?
        ├── YES → Batch Scrolling (batch by company, scroll within)
        │   └── Use: PlatformApplicationBatchScrollingBackgroundJobExecutor
        │
        └── NO → Simple Scrolling
            └── Use: ExecuteInjectScopedScrollingPagingAsync
```

## Pattern 1: Simple Paged Job

Use when: Items don't change during processing (or changes don't affect query).

```csharp
[PlatformRecurringJob("0 3 * * *")]  // Daily at 3 AM
public sealed class ProcessPendingItemsJob : PlatformApplicationPagedBackgroundJobExecutor
{
    private readonly IServiceRepository<Item> repository;

    protected override int PageSize => 50;

    // Filter for items to process
    private IQueryable<Item> QueryBuilder(IQueryable<Item> query)
        => query.Where(x => x.Status == Status.Pending);

    // Return total items matching filter
    protected override async Task<int> MaxItemsCount(
        PlatformApplicationPagedBackgroundJobParam<object?> param)
    {
        return await repository.CountAsync((uow, q) => QueryBuilder(q));
    }

    // Process each page
    protected override async Task ProcessPagedAsync(
        int? skip,
        int? take,
        object? param,
        IServiceProvider serviceProvider,
        IPlatformUnitOfWorkManager unitOfWorkManager)
    {
        var items = await repository.GetAllAsync((uow, q) =>
            QueryBuilder(q)
                .OrderBy(x => x.CreatedDate)
                .PageBy(skip, take));

        await items.ParallelAsync(async item =>
        {
            item.Process();
            await repository.UpdateAsync(item);
        }, maxConcurrent: 5);
    }
}
```

## Pattern 2: Batch Scrolling Job (Multi-Tenant)

Use when: Processing per-company, data changes during processing.

```csharp
[PlatformRecurringJob("0 0 * * *")]  // Daily at midnight
public sealed class SyncCompanyDataJob
    : PlatformApplicationBatchScrollingBackgroundJobExecutor<Entity, string>
{
    // Batch key = CompanyId, Entity = what we're processing
    protected override int BatchKeyPageSize => 50;   // Companies per page
    protected override int BatchPageSize => 25;       // Entities per company batch

    // Build entity query (with optional company filter)
    protected override IQueryable<Entity> EntitiesQueryBuilder(
        IQueryable<Entity> query,
        object? param,
        string? batchKey = null)
    {
        return query
            .Where(e => e.NeedsSync)
            .WhereIf(batchKey != null, e => e.CompanyId == batchKey)
            .OrderBy(e => e.Id);
    }

    // Extract batch keys (company IDs)
    protected override IQueryable<string> EntitiesBatchKeyQueryBuilder(
        IQueryable<Entity> query,
        object? param,
        string? batchKey = null)
    {
        return EntitiesQueryBuilder(query, param, batchKey)
            .Select(e => e.CompanyId)
            .Distinct();
    }

    // Process entities for one company
    protected override async Task ProcessEntitiesAsync(
        List<Entity> entities,
        string batchKey,  // CompanyId
        object? param,
        IServiceProvider serviceProvider)
    {
        Logger.LogInformation("Processing {Count} entities for company {CompanyId}",
            entities.Count, batchKey);

        await entities.ParallelAsync(async entity =>
        {
            entity.MarkSynced();
            await repository.UpdateAsync(entity);
        }, maxConcurrent: 1);  // Often 1 to avoid race conditions within company
    }
}
```

## Pattern 3: Scrolling Job (Data Changes During Processing)

Use when: Processing creates a log/record that excludes item from next query.

```csharp
public sealed class ProcessAndLogJob : PlatformApplicationBackgroundJobExecutor
{
    public override async Task ProcessAsync(object? param)
    {
        var queryBuilder = repository.GetQueryBuilder((uow, q) =>
            q.Where(x => x.Status == Status.Pending)
             .Where(x => !processedLogRepo.Query().Any(log => log.EntityId == x.Id)));

        var totalCount = await repository.CountAsync((uow, q) => queryBuilder(uow, q));

        await UnitOfWorkManager.ExecuteInjectScopedScrollingPagingAsync<Entity>(
            processingDelegate: ExecutePaged,
            maxPageCount: totalCount / PageSize,
            param: param,
            pageSize: PageSize);
    }

    private static async Task<List<Entity>> ExecutePaged(
        object? param,
        int? limitPageSize,
        IServiceRepository<Entity> repo,
        IServiceRepository<ProcessedLog> logRepo)
    {
        var items = await repo.GetAllAsync((uow, q) =>
            q.Where(x => x.Status == Status.Pending)
             .Where(x => !logRepo.Query().Any(log => log.EntityId == x.Id))
             .OrderBy(x => x.Id)
             .PipeIf(limitPageSize != null, q => q.Take(limitPageSize!.Value)));

        if (items.IsEmpty()) return items;

        // Create log entries (excludes from next query)
        await logRepo.CreateManyAsync(items.SelectList(e => new ProcessedLog(e)));

        // Process items
        foreach (var item in items)
        {
            item.Process();
            await repo.UpdateAsync(item, dismissSendEvent: true);
        }

        return items;
    }
}
```

## Pattern 4: Master Job (Schedules Child Jobs)

Use when: Complex coordination across companies and date ranges.

```csharp
[PlatformRecurringJob("0 6 * * *")]
public sealed class MasterSchedulerJob : PlatformApplicationBackgroundJobExecutor
{
    public override async Task ProcessAsync(object? param)
    {
        var companies = await companyRepo.GetAllAsync(c => c.IsActive);
        var dateRange = DateRangeBuilder.BuildDateRange(
            Clock.UtcNow.AddDays(-7),
            Clock.UtcNow);

        // Schedule child jobs for each company x date combination
        await companies.ParallelAsync(async company =>
        {
            await dateRange.ParallelAsync(async date =>
            {
                await BackgroundJobScheduler.Schedule<ChildProcessingJob, ChildJobParam>(
                    Clock.UtcNow,
                    new ChildJobParam
                    {
                        CompanyId = company.Id,
                        ProcessDate = date
                    });
            });
        }, maxConcurrent: 10);
    }
}
```

## Cron Schedule Reference

| Schedule | Cron Expression | Description |
|----------|-----------------|-------------|
| Every 5 min | `*/5 * * * *` | Every 5 minutes |
| Hourly | `0 * * * *` | Top of every hour |
| Daily midnight | `0 0 * * *` | 00:00 daily |
| Daily 3 AM | `0 3 * * *` | 03:00 daily |
| Weekly Sunday | `0 0 * * 0` | Midnight Sunday |
| Monthly 1st | `0 0 1 * *` | Midnight, 1st day |

## Job Attributes

```csharp
// Basic recurring job
[PlatformRecurringJob("0 3 * * *")]

// With startup execution
[PlatformRecurringJob("5 0 * * *", executeOnStartUp: true)]

// Disabled (for manual or event-triggered)
[PlatformRecurringJob(isDisabled: true)]
```

## Anti-Patterns to AVOID

:x: **Processing without paging**
```csharp
// WRONG - memory issues with large datasets
var allItems = await repository.GetAllAsync();
foreach (var item in allItems) { }
```

:x: **Wrong pagination for changing data**
```csharp
// WRONG - skip/take shifts when data changes
.Skip(skip).Take(take)  // Items get skipped when processed items removed
```

:x: **No parallel control**
```csharp
// WRONG - unbounded parallelism
await items.ParallelAsync(ProcessAsync);  // Could overwhelm system

// CORRECT - bounded parallelism
await items.ParallelAsync(ProcessAsync, maxConcurrent: 5);
```

:x: **Long-running without unit of work**
```csharp
// WRONG - transaction held too long
foreach (var item in items) {
    await repository.UpdateAsync(item);  // All in one transaction
}

// CORRECT - commit per batch
using (var uow = UnitOfWorkManager.Begin()) {
    await ProcessBatch(items);
    await uow.CompleteAsync();
}
```

## Verification Checklist
- [ ] Correct job pattern selected for use case
- [ ] Pagination strategy handles data changes correctly
- [ ] `ParallelAsync` has `maxConcurrent` limit
- [ ] Unit of work scoped appropriately
- [ ] Cron expression validated
- [ ] `dismissSendEvent: true` used if events not needed
- [ ] Logging added for monitoring
