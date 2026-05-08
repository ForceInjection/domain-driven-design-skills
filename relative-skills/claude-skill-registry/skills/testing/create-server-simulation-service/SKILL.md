---
name: Create Server Simulation Service
description: Create a C# server-side simulation service following the Plugin/IEventAdapter pattern with configuration, pulse updates, and entity management. Use when creating new simulations, scenario generators, or test data providers for FAAD HMI server.
allowed-tools: Read, Write, Edit, Grep, Glob
---

# Create Server Simulation Service

This skill scaffolds a complete server-side simulation service following Phoenix/FAAD server patterns.

## When to Use

- Creating new simulation scenarios for testing
- Building test data generators
- Creating scenario runners with realistic behavior
- Adding configurable simulations to canary/testing projects

## Prerequisites

- Understand the entity model to simulate (FaadTrack, Platform, etc.)
- Know the desired configuration parameters
- Decide on simulation behavior (movement patterns, state changes, etc.)

## CRITICAL Server Concepts

**Reference**: [SERVER.md](../../ai-guide/_SERVER/SERVER.md)

**Server uses Data-Oriented Design**:
- ❌ NO traditional OOP with entity instances
- ✅ YES dictionary-based `IUpdate` objects
- ✅ YES builder pattern for entity creation
- ✅ YES pulse-driven updates (external timing control)

**Property Patterns**:
- `ValueProperty`: `{ "Value": x }` - Single values (enums, types)
- `CommandedProperty`: `{ "Commanded": x, "Actual": y }` - Dual state
- `RangedCommandedProperty`: Adds `"Min"` and `"Max"` fields

## Process

### Step 1: Create Configuration Class

**Location**: `server/com.faad.testing.canary/sims/configuration/{SimName}Configuration.cs`

```csharp
using System;

namespace com.faad.testing.canary.sims.configuration;

/// <summary>
/// Configuration for the {SimName} simulation.
/// Allows control over {describe what it controls}.
/// </summary>
public class {SimName}Configuration
{
    /// <summary>
    /// {Description of parameter}
    /// </summary>
    public int NumberOfEntities { get; set; } = 5;

    /// <summary>
    /// {Description of parameter}
    /// </summary>
    public bool EnableFeature { get; set; } = true;

    // Add configuration properties as needed
}
```

**Configuration Best Practices**:
- Always provide sensible defaults
- Use descriptive XML comments
- Keep properties simple (primitives, enums)
- Use bool for feature flags
- Use int for counts/limits
- Use double for physical values

### Step 2: Create Simulation Class Structure

**Location**: `server/com.faad.testing.canary/sims/{SimName}Sim.cs`

```csharp
using System.Collections.Concurrent;
using System.ComponentModel.Composition;
using System.Dynamic;
using quicktype;
using esp.extras.common.plugin;
using esp.api.infrastructure.plugin;
using esp.api.infrastructure.model;
using com.faad.testing.canary.sims.configuration;

namespace com.faad.testing.canary.sims
{
    /// <summary>
    /// {Brief description of what this simulation does}
    ///
    /// {SimName} Pattern
    /// - Rationale: {Why this simulation exists}
    /// - Behavior: {How entities behave}
    /// - Configurable: {What can be configured}
    /// </summary>
    [Export("faad.{SimName}Sim", typeof(IPluginMeta))]
    public class {SimName}Sim : Plugin, IEventAdapter
    {
        public {SimName}Configuration? configuration;

        // Constants
        private const int MAX_ENTITIES_ADDED_PER_PULSE = 500;
        private const int MAX_ENTITIES_UPDATED_PER_PULSE = 1000;

        // State tracking
        private int _lastAddedIndex = 0;
        private int _lastUpdatedIndex = 0;

        // Entity storage - Dictionary for O(1) access
        private readonly ConcurrentDictionary<string, EntityData> _entities = new ConcurrentDictionary<string, EntityData>();
        private EntityData[] _entityArray = Array.Empty<EntityData>(); // Stable O(1) access
        private DateTime _lastPulse = DateTime.MinValue;

        // Internal data structure (not IUpdate - just for sim logic)
        private class EntityData
        {
            public required string Id { get; set; }
            // Add simulation-specific fields
            public double CurrentLatitude { get; set; }
            public double CurrentLongitude { get; set; }
            public DateTime LastUpdateTime { get; set; }
        }

        public void start()
        {
            Console.WriteLine("Starting {SimName}Sim...");

            if (configuration == null)
            {
                Console.WriteLine("{SimName}Sim: Configuration is null, using defaults");
                configuration = new {SimName}Configuration();
            }

            _lastPulse = DateTime.Now;
            _entities.Clear();
            _lastAddedIndex = 0;
            _lastUpdatedIndex = 0;

            // Generate entities (in memory, not in repository yet)
            for (int i = 0; i < configuration.NumberOfEntities; i++)
            {
                var entityId = GenerateEntityId(i);
                var entityData = GenerateNewEntity(entityId, i);
                _entities[entityId] = entityData;
            }

            _entityArray = _entities.Values.ToArray(); // Stable array

            Console.WriteLine($"{SimName}Sim: Generated {_entityArray.Length} entities");

            AddEntityBatchToRepository();
        }

        public void stop()
        {
            Console.WriteLine("Stopping {SimName}Sim...");
            _entities.Clear(); // Note: entities remain in repository after stop
        }

        public void pulse(long pulseInterval) // NOTE: ~250ms intervals
        {
            var now = DateTime.Now;

            // Add entities in batches if not all added yet
            if (_lastAddedIndex < _entityArray.Length)
            {
                AddEntityBatchToRepository();
            }

            int addedCount = Math.Min(_lastAddedIndex, _entityArray.Length);
            if (addedCount == 0)
            {
                _lastPulse = now;
                return;
            }

            // Update entities in batches
            int entitiesToUpdate = Math.Min(MAX_ENTITIES_UPDATED_PER_PULSE, addedCount);
            var updates = new List<IUpdate>();

            for (int i = 0; i < entitiesToUpdate; i++)
            {
                int entityIndex = (_lastUpdatedIndex + i) % addedCount;
                var entityData = _entityArray[entityIndex];

                var entityDeltaTime = now - entityData.LastUpdateTime;
                var update = UpdateEntity(entityData, entityDeltaTime);
                if (update != null)
                {
                    updates.Add(update);
                    entityData.LastUpdateTime = now;
                    _entityArray[entityIndex] = entityData;
                }
            }

            _lastUpdatedIndex = (_lastUpdatedIndex + entitiesToUpdate) % addedCount;

            if (updates.Count > 0)
            {
                // CRITICAL: Must pass array for thread-safe serialization
                var updateArray = updates.ToArray();
                RepositoryService?.addOrUpdateObjects(updateArray);
                updates.Clear();
            }

            _lastPulse = now;
        }

        public void configure(object? config)
        {
            Console.WriteLine("Configuring {SimName}Sim");

            if (config is string jsonConfig)
            {
                configuration = System.Text.Json.JsonSerializer.Deserialize<{SimName}Configuration>(jsonConfig);
            }
            else
            {
                configuration = config as {SimName}Configuration;
            }

            Console.WriteLine($"{SimName}Sim configured with {configuration?.NumberOfEntities ?? 5} entities");
        }

        public Type getConfigurationType()
        {
            return typeof({SimName}Configuration);
        }

        private void AddEntityBatchToRepository()
        {
            if (_lastAddedIndex >= _entityArray.Length) return;

            int remainingEntities = _entityArray.Length - _lastAddedIndex;
            int entitiesToAdd = Math.Min(MAX_ENTITIES_ADDED_PER_PULSE, remainingEntities);

            if (entitiesToAdd <= 0) return;

            var updateList = new List<IUpdate>();

            for (int i = 0; i < entitiesToAdd; i++)
            {
                var entityData = _entityArray[_lastAddedIndex + i];
                var update = CreateEntityUpdate(entityData, isInitial: true);
                updateList.Add(update);
            }

            if (updateList.Count > 0)
            {
                var updateArray = updateList.ToArray();
                RepositoryService?.addOrUpdateObjects(updateArray);
                updateList.Clear();
                _lastAddedIndex += entitiesToAdd;
                Console.WriteLine($"{SimName}Sim: Added {entitiesToAdd} entities ({_lastAddedIndex} of {_entityArray.Length} total)");
            }
        }

        private EntityData GenerateNewEntity(string id, int index)
        {
            return new EntityData
            {
                Id = id,
                CurrentLatitude = 33.5, // Example
                CurrentLongitude = -113.7,
                LastUpdateTime = DateTime.Now
            };
        }

        private IUpdate CreateEntityUpdate(EntityData entityData, bool isInitial = false)
        {
            var update = new esp.extras.infrastructure.model.Update
            {
                Id = entityData.Id,
                ClassName = FaadTrack.classData, // Use appropriate entity type
                Type = typeof(FaadTrack),
            };

            // CRITICAL: Capture values locally to avoid reference sharing
            decimal currentLat = (decimal)entityData.CurrentLatitude;
            decimal currentLon = (decimal)entityData.CurrentLongitude;

            // ValueProperty pattern: { "Value": x }
            var platformTypeUpdate = new ExpandoObject() as IDictionary<string, object?>;
            platformTypeUpdate["Value"] = "Fixed Wing";
            update.UpdateProperties["platformType"] = platformTypeUpdate;

            // CommandedProperty pattern: { "Commanded": x, "Actual": y }
            var latUpdate = new ExpandoObject() as IDictionary<string, object?>;
            latUpdate["Actual"] = currentLat;
            latUpdate["Commanded"] = currentLat;
            update.UpdateProperties["latitude"] = latUpdate;

            var lonUpdate = new ExpandoObject() as IDictionary<string, object?>;
            lonUpdate["Actual"] = currentLon;
            lonUpdate["Commanded"] = currentLon;
            update.UpdateProperties["longitude"] = lonUpdate;

            // RangedCommandedProperty pattern: { "Commanded": x, "Actual": y, "Min": min, "Max": max }
            var headingUpdate = new ExpandoObject() as IDictionary<string, object?>;
            headingUpdate["Actual"] = 0m;
            headingUpdate["Commanded"] = 0m;
            headingUpdate["Min"] = 0m;
            headingUpdate["Max"] = 360m;
            update.UpdateProperties["heading"] = headingUpdate;

            return update;
        }

        private IUpdate? UpdateEntity(EntityData entityData, TimeSpan deltaTime)
        {
            // Update entity state based on simulation logic
            // Return IUpdate with changed properties only

            return CreateEntityUpdate(entityData, isInitial: false);
        }

        private string GenerateEntityId(int index)
        {
            return $"entity-{index:D4}";
        }
    }
}
```

### Step 3: Implement Simulation Logic

**Movement/Behavior Patterns**:

```csharp
// Pattern 1: Waypoint-based movement
private IUpdate? UpdateEntity(EntityData entity, TimeSpan deltaTime)
{
    double distanceToTarget = CalculateDistance(
        entity.CurrentLatitude, entity.CurrentLongitude,
        entity.TargetLatitude, entity.TargetLongitude);

    if (distanceToTarget < ARRIVAL_THRESHOLD)
    {
        // Reached target, pick new one
        var newTarget = GenerateNewTarget();
        entity.TargetLatitude = newTarget.Item1;
        entity.TargetLongitude = newTarget.Item2;
    }

    // Move toward target
    var bearing = CalculateBearing(/*...*/);
    var newPosition = CalculateNewPosition(/*...*/);
    entity.CurrentLatitude = newPosition.Latitude;
    entity.CurrentLongitude = newPosition.Longitude;

    return CreateEntityUpdate(entity);
}

// Pattern 2: Random walk
private IUpdate? UpdateEntity(EntityData entity, TimeSpan deltaTime)
{
    // Random direction change
    entity.Heading += (random.NextDouble() - 0.5) * 10; // +/- 5 degrees
    entity.Heading = (entity.Heading + 360) % 360;

    // Move forward
    double distanceMeters = entity.SpeedKts * 0.514444 * deltaTime.TotalSeconds;
    var newPos = CalculateNewPosition(/*...*/);
    entity.CurrentLatitude = newPos.Latitude;
    entity.CurrentLongitude = newPos.Longitude;

    return CreateEntityUpdate(entity);
}

// Pattern 3: State machine
private IUpdate? UpdateEntity(EntityData entity, TimeSpan deltaTime)
{
    switch (entity.State)
    {
        case EntityState.Idle:
            // Check conditions to transition
            if (ShouldActivate(entity))
            {
                entity.State = EntityState.Active;
            }
            break;

        case EntityState.Active:
            // Active behavior
            UpdateActiveEntity(entity, deltaTime);
            break;

        case EntityState.Returning:
            // Return to base logic
            break;
    }

    return CreateEntityUpdate(entity);
}
```

### Step 4: Add Geospatial Utilities (If Needed)

```csharp
#region Geospatial Math Utilities

private const double EARTH_RADIUS_MILES = 3958.8;

private double CalculateDistance(double lat1, double lon1, double lat2, double lon2)
{
    lat1 = ToRadians(lat1);
    lon1 = ToRadians(lon1);
    lat2 = ToRadians(lat2);
    lon2 = ToRadians(lon2);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;
    double a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
              Math.Cos(lat1) * Math.Cos(lat2) *
              Math.Sin(dLon / 2) * Math.Sin(dLon / 2);
    double c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
    return EARTH_RADIUS_MILES * c;
}

private double CalculateBearing(double lat1, double lon1, double lat2, double lon2)
{
    lat1 = ToRadians(lat1);
    lon1 = ToRadians(lon1);
    lat2 = ToRadians(lat2);
    lon2 = ToRadians(lon2);

    double dLon = lon2 - lon1;
    double y = Math.Sin(dLon) * Math.Cos(lat2);
    double x = Math.Cos(lat1) * Math.Sin(lat2) -
              Math.Sin(lat1) * Math.Cos(lat2) * Math.Cos(dLon);
    double bearing = Math.Atan2(y, x);
    return (bearing + 2 * Math.PI) % (2 * Math.PI);
}

private (double Latitude, double Longitude) CalculateNewPosition(
    double lat, double lon, double bearing, double distance)
{
    lat = ToRadians(lat);
    lon = ToRadians(lon);

    double angularDistance = distance / EARTH_RADIUS_MILES;
    double newLat = Math.Asin(Math.Sin(lat) * Math.Cos(angularDistance) +
                         Math.Cos(lat) * Math.Sin(angularDistance) * Math.Cos(bearing));
    double newLon = lon + Math.Atan2(Math.Sin(bearing) * Math.Sin(angularDistance) * Math.Cos(lat),
                               Math.Cos(angularDistance) - Math.Sin(lat) * Math.Sin(newLat));

    return (ToDegrees(newLat), ToDegrees(newLon));
}

private double ToRadians(double degrees) => degrees * Math.PI / 180.0;
private double ToDegrees(double radians) => radians * 180.0 / Math.PI;

#endregion
```

### Step 5: Verify Build

```bash
# Build server
dotnet build server/com.faad.testing.canary

# Check for errors
./tools/build-helpers/count-server-errors.sh
./tools/build-helpers/show-server-errors.sh 10
```

## Critical Patterns

### Property Update Pattern

**ALWAYS use ExpandoObject as IDictionary**:
```csharp
// ✅ CORRECT
var propUpdate = new ExpandoObject() as IDictionary<string, object?>;
propUpdate["Actual"] = value;
update.UpdateProperties["propertyName"] = propUpdate;

// ❌ WRONG - Direct dictionary
var dict = new Dictionary<string, object>();  // Won't serialize correctly!
```

### Batch Performance Pattern

**Add/update in batches** to avoid overwhelming repository:
```csharp
// ✅ CORRECT - Batched additions
private const int MAX_ENTITIES_ADDED_PER_PULSE = 500;
for (int i = 0; i < Math.Min(remaining, MAX_ENTITIES_ADDED_PER_PULSE); i++) { ... }

// ❌ WRONG - All at once
for (int i = 0; i < _entities.Count; i++) { ... }  // Could be 10,000+!
```

### Thread Safety Pattern

**Always pass arrays to RepositoryService**:
```csharp
// ✅ CORRECT - Array isolates from mutation
var updateArray = updates.ToArray();
RepositoryService?.addOrUpdateObjects(updateArray);
updates.Clear();

// ❌ WRONG - List could be mutated during async serialization
RepositoryService?.addOrUpdateObjects(updates);
```

### Value Capture Pattern

**Capture values before creating ExpandoObject**:
```csharp
// ✅ CORRECT - Captured as locals (thread-safe)
decimal currentLat = (decimal)entityData.CurrentLatitude;
var latUpdate = new ExpandoObject() as IDictionary<string, object?>;
latUpdate["Actual"] = currentLat;

// ❌ WRONG - Direct reference (could change during serialization)
latUpdate["Actual"] = (decimal)entityData.CurrentLatitude;
```

## Common Pitfalls

**Reference**: [SERVER.md](../../ai-guide/_SERVER/SERVER.md)

1. ❌ Don't create entity instances directly - Use IUpdate pattern
2. ❌ Don't access dictionary keys without TryGetValue
3. ❌ Don't use regular Dictionary for property updates - Use ExpandoObject as IDictionary
4. ❌ Don't send List to RepositoryService - Convert to array first
5. ❌ Don't add all entities in one pulse - Batch them
6. ❌ Don't capture entity references in closures - Capture values
7. ❌ Don't forget decimal casting for lat/lon/alt values
8. ❌ Don't mix up property patterns (Value vs Commanded vs RangedCommanded)

## Real-World Example

**Reference**: `server/com.faad.testing.canary/sims/CrowdedAirspaceSim.cs`

Study this example for:
- Batched entity addition
- Waypoint-based movement
- Realistic speed/altitude generation
- Geospatial calculations
- Configuration pattern
- Performance optimizations

## File Locations

- Simulation: `server/com.faad.testing.canary/sims/{SimName}Sim.cs`
- Configuration: `server/com.faad.testing.canary/sims/configuration/{SimName}Configuration.cs`

## Testing Your Simulation

1. Build server: `dotnet build server/com.faad.testing.canary`
2. Configure in scenario JSON (see `server/com.faad.runner/configuration/scenarios/`)
3. Run HMI server and client
4. Verify entities appear in UI
5. Check console output for batch progress

## Ask User If Unclear

- What entity type to simulate? (FaadTrack, Platform, etc.)
- What configuration parameters are needed?
- What behavior pattern? (movement, state machine, random, etc.)
- How many entities should it support?
- Should it be geospatial or abstract?
- What are the realistic value ranges?