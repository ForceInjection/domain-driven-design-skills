---
name: resource-management-audit
description: Audit resource management including IDisposable pattern implementation, proper cleanup of OpenGL resources (buffers, textures, shaders, framebuffers), memory leak detection, resource lifetime management, and GPU resource tracking. Use when investigating memory leaks, GPU resource exhaustion, or implementing new resource types.
---

# Resource Management Audit

## Overview

This skill audits resource management to ensure proper cleanup of OpenGL resources, correct IDisposable implementation, and prevention of memory leaks. Focus on engine-specific concerns like OpenGL context safety, factory ownership patterns, and GPU resource tracking.

## When to Use

Invoke this skill when:
- Investigating memory leaks or growing memory usage
- GPU resources (textures, buffers) are not being cleaned up
- Adding new resource types (textures, shaders, meshes, framebuffers)
- Refactoring resource lifetime management
- Application crashes on shutdown (disposal issues)
- Out-of-memory errors or GPU resource exhaustion
- Reviewing code for proper disposal patterns

## Critical Engine-Specific Rules

### 1. Never Call OpenGL in Finalizers

**Why**: OpenGL context is NOT available on finalizer thread. Calling GL functions in finalizers causes crashes.

```csharp
// ✅ CORRECT - Log warning instead
~Texture()
{
    if (_rendererID != 0)
    {
        Logger.Error($"Texture {_path} not disposed! GPU leak.");
        // Do NOT call GL.DeleteTexture here!
    }
}

public void Dispose()
{
    if (_rendererID != 0)
    {
        GL.DeleteTexture(_rendererID);  // Safe - correct thread
        _rendererID = 0;
    }
    GC.SuppressFinalize(this);  // Prevent finalizer
}
```

### 2. Factory-Managed Resources

**Rule**: Factory owns cached resources. Consumers get references but don't dispose them.

```csharp
// TextureFactory owns and disposes cached textures
var texture = _textureFactory.Load("sprite.png");

// ❌ WRONG - Don't dispose factory-managed resources
texture.Dispose();  // Other users still need this!

// ✅ CORRECT - Factory disposes on shutdown
// Just use the texture, factory handles lifetime
```

**Check ownership documentation** in resource classes (see XML comments).

### 3. Shared vs. Owned Resources

**Owned**: Component creates resource exclusively for itself → Component disposes it
**Shared**: Resource comes from factory/cache → Factory disposes it

```csharp
public class MeshRenderer : IDisposable
{
    private Mesh _mesh;         // Shared (factory-managed)
    private uint _instanceVBO;  // Owned (created by this component)

    public void Dispose()
    {
        // Don't dispose _mesh (shared)

        // DO dispose _instanceVBO (owned)
        if (_instanceVBO != 0)
        {
            GL.DeleteBuffer(_instanceVBO);
            _instanceVBO = 0;
        }
    }
}
```

### 4. Disposal Guards

Always implement these safeguards:

```csharp
public class Texture : IDisposable
{
    private uint _rendererID;
    private bool _disposed = false;

    public void Dispose()
    {
        if (_disposed)          // 1. Guard double-disposal
            return;

        if (_rendererID != 0)   // 2. Check resource exists
        {
            GL.DeleteTexture(_rendererID);
            _rendererID = 0;    // 3. Reset to prevent re-delete
        }

        _disposed = true;
        GC.SuppressFinalize(this);  // 4. Skip finalizer
    }
}
```

## Audit Checklist

When reviewing resource-owning classes, verify:

### IDisposable Implementation
- [ ] Implements `IDisposable`
- [ ] Has `_disposed` flag to guard double-disposal
- [ ] Resets resource IDs to 0 after deletion
- [ ] Calls `GC.SuppressFinalize(this)` in Dispose()
- [ ] Finalizer logs warning (never calls OpenGL)

### Ownership Clarity
- [ ] Documented who owns the resource (XML comments)
- [ ] Shared resources NOT disposed by consumers
- [ ] Factory/pool manages disposal of cached resources
- [ ] Clear distinction between owned vs. referenced resources

### Resource Creation Sites
- [ ] Every `new Texture()` has clear disposal path
- [ ] Every `GL.GenBuffer()` has matching `GL.DeleteBuffer()`
- [ ] Resources created in loops are disposed or cached
- [ ] Exception handling doesn't skip disposal (use `using` or try-finally)

### Testing
- [ ] Unit tests verify cleanup after load/unload cycles
- [ ] ResourceTracker shows stable counters (no growth)
- [ ] Shutdown check confirms zero leaks
- [ ] Manual testing with RenderDoc (GPU resources)

## Common Anti-Patterns

See `references/anti-patterns.cs` for detailed examples. Quick reference:

1. **Missing Disposal**: Resource created but never disposed → Add disposal path
2. **Double Disposal**: No `_disposed` guard → Crashes on second Dispose()
3. **Disposing Shared Resources**: Multiple owners unclear → Document ownership
4. **OpenGL in Finalizers**: Crashes due to missing context → Log warning instead
5. **Forgetting GC.SuppressFinalize**: Unnecessary finalizer runs → Always call it
6. **Wrong Disposal Order**: FBO before attachments → Delete in reverse order of creation
7. **Null Checks Missing**: `_mesh.Dispose()` crashes if null → Use `_mesh?.Dispose()`
8. **No Disposal Path**: Resources in loops → Cache or use `using` statement

## Disposal Patterns Reference

Standard IDisposable patterns with engine-specific notes: `references/disposal-patterns.cs`

**Pattern Selection**:
- **Basic Pattern**: Sealed classes, OpenGL-only resources
- **Full Pattern**: Inheritable classes, mixed managed/unmanaged resources
- **Factory Pattern**: Cached/shared resources with centralized lifetime management

## Output Format

When reporting audit findings:

```text
**Issue**: [Resource management problem]
**Location**: [File:line]
**Resource Type**: [OpenGL buffer/texture/shader/etc.]
**Problem**: [Specific issue - leak, double disposal, missing cleanup]
**Recommendation**:
[Code example showing fix]
**Priority**: [Critical/High/Medium/Low]
```

**Example**:
```text
**Issue**: Mesh resources not disposed when entity destroyed
**Location**: Engine/Scene/Entity.cs:89
**Resource Type**: OpenGL VBO, EBO, VAO
**Problem**: Entity.Destroy() doesn't dispose MeshComponent.Mesh,
causing GPU memory leak (20MB per load/unload cycle)
**Recommendation**:
public void Destroy()
{
    if (HasComponent<MeshComponent>())
    {
        var meshComp = GetComponent<MeshComponent>();
        // Only dispose if component owns the mesh (not factory-managed)
        if (meshComp.OwnsMesh)
        {
            meshComp.Mesh?.Dispose();
        }
        meshComp.Mesh = null;
    }
    _scene.RemoveEntity(this);
}
**Priority**: High (GPU memory leak)
```

## Key Files Reference

- **`references/disposal-patterns.cs`**: Standard IDisposable patterns (basic, full, factory)
- **`references/anti-patterns.cs`**: 8 common mistakes with ❌/✅ examples

## Summary

**Core Principles**:
1. Never call OpenGL in finalizers (no GL context available)
2. Document ownership explicitly (owned vs. shared resources)
3. Factory-managed resources: factory disposes, consumers reference
4. Always guard double-disposal with `_disposed` flag
5. Always call `GC.SuppressFinalize(this)` in Dispose()
6. Use ResourceTracker for leak detection in DEBUG builds
7. Test cleanup with load/unload cycles and shutdown checks
