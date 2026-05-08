---
name: aspnet-core
description: Master ASP.NET Core with minimal APIs, MVC, middleware, dependency injection, and production-ready web applications.
---

# ASP.NET Core Development

Build modern web applications and APIs with ASP.NET Core using minimal APIs, MVC, and production patterns.

## Core Patterns

### Minimal API
```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<AppDbContext>();
builder.Services.AddScoped<IUserService, UserService>();

var app = builder.Build();

app.MapGet("/api/users", async (IUserService service) =>
{
    var users = await service.GetAllAsync();
    return Results.Ok(users);
});

app.MapPost("/api/users", async (User user, IUserService service) =>
{
    var created = await service.CreateAsync(user);
    return Results.Created($"/api/users/{created.Id}", created);
});

app.Run();
```

### Controller Pattern
```csharp
[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<User>>> GetAll()
    {
        var users = await _userService.GetAllAsync();
        return Ok(users);
    }

    [HttpPost]
    public async Task<ActionResult<User>> Create(CreateUserDto dto)
    {
        var user = await _userService.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = user.Id }, user);
    }
}
```

### Middleware
```csharp
public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestLoggingMiddleware> _logger;

    public RequestLoggingMiddleware(RequestDelegate next, ILogger<RequestLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        _logger.LogInformation("Request: {Method} {Path}", context.Request.Method, context.Request.Path);
        await _next(context);
    }
}
```

## Best Practices

1. Use dependency injection
2. Implement proper error handling
3. Use async/await consistently
4. Leverage middleware pipeline
5. Implement authentication/authorization
6. Use configuration providers
7. Write integration tests
8. Use proper logging

## Resources
- https://docs.microsoft.com/aspnet/core
