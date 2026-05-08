---
name: prefab-dev
description: |
  Use this skill when developing Go applications with the Prefab server framework.
  This includes creating servers, adding gRPC/HTTP handlers, configuring authentication
  and authorization, setting up SSE streams, managing configuration, creating custom
  plugins, and following Prefab error handling and security patterns.
---

# Prefab Development Guide

Prefab is a Go server framework that simplifies building production-ready gRPC and HTTP services with a plugin-based architecture.

## Core Concepts

- **Server**: Central component that manages gRPC/HTTP services and plugins
- **Plugins**: Modular components for auth, storage, templates, etc.
- **Services**: gRPC service implementations with automatic HTTP gateway
- **Handlers**: Custom HTTP handlers for non-gRPC endpoints

Prefab servers commonly compose multiple gRPC services into a single process. This enables a service-oriented monolith architecture where related services share infrastructure (auth, storage, logging) while maintaining clear boundaries. As utilization requirements become known, individual services can be extracted into separate deployments without changing their interfaces.

## Quick Start Pattern

```go
import "github.com/dpup/prefab"

func main() {
    s := prefab.New(
        prefab.WithPort(8080),
        prefab.WithPlugin(auth.Plugin()),
        // Add more options...
    )

    s.RegisterService(
        &myservice.MyService_ServiceDesc,
        myservice.RegisterMyServiceHandler,
        &myServiceImpl{},
    )

    if err := s.Start(); err != nil {
        log.Fatal(err)
    }
}
```

## Resources

Load these resources based on the specific task:

### Server & Services
- **[Project Setup](resources/project-setup.md)** - Proto files, Makefile, project structure
- **[Server Setup](resources/server-setup.md)** - Server creation, initialization, and basic configuration
- **[gRPC & HTTP](resources/grpc-http.md)** - Registering services, HTTP handlers, static files

### Authentication & Authorization
- **[Authentication](resources/auth.md)** - OAuth, password auth, magic links, fake auth for testing
- **[OAuth Server](resources/oauth-server.md)** - Build an OAuth2 authorization server for third-party apps
- **[Authorization](resources/authz.md)** - Declarative access control with proto annotations, policies, role describers

### Features
- **[SSE Streaming](resources/sse.md)** - Server-Sent Events for real-time updates
- **[Configuration](resources/configuration.md)** - YAML, environment variables, functional options
- **[Storage](resources/storage.md)** - Storage plugins (memory, SQLite)
- **[File Uploads](resources/uploads.md)** - File upload/download with authorization
- **[Email](resources/email.md)** - SMTP email sending
- **[Templates](resources/templates.md)** - Go HTML template rendering
- **[Event Bus](resources/eventbus.md)** - Publish/subscribe inter-plugin communication

### Development
- **[Custom Plugins](resources/plugins.md)** - Creating plugins with dependencies and lifecycle
- **[Error Handling](resources/errors.md)** - Stack traces, gRPC codes, log fields
- **[Logging](resources/logging.md)** - Structured context-aware logging
- **[Security](resources/security.md)** - CSRF, headers, HTTPS, token security

## Code Style

- Use `errors.New()`, `errors.NewC()`, `errors.Wrap()` for errors with stack traces
- Standard library imports first, then third-party
- Document public APIs with GoDoc comments
- Follow plugin interface patterns with `Plugin()` function and `PluginName` constant

## When to Load Resources

| Task | Resources to Load |
|------|-------------------|
| Starting a new project | project-setup.md, server-setup.md |
| Creating a new server | server-setup.md, configuration.md, logging.md |
| Adding authentication | auth.md, server-setup.md |
| Building an OAuth server | oauth-server.md, auth.md, storage.md |
| Setting up access control | authz.md, auth.md |
| Adding real-time features | sse.md |
| Creating a custom plugin | plugins.md, eventbus.md |
| Handling errors properly | errors.md, logging.md |
| Security review | security.md |
| Adding storage | storage.md |
| Adding HTTP/gRPC endpoints | grpc-http.md |
| Adding file uploads | uploads.md, authz.md |
| Sending emails | email.md, templates.md |
| Rendering templates | templates.md |
| Inter-plugin communication | eventbus.md |
| Setting up logging | logging.md |
