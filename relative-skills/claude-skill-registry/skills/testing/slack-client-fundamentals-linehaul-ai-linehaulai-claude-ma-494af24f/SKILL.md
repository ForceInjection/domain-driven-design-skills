---
name: slack-client-fundamentals
description: Foundation skill for Slack Go SDK. Use when setting up a new Slack bot, initializing the API client, choosing between Web API vs Socket Mode vs Events API, implementing error handling patterns, or establishing testing strategies for Slack applications.
---

# Slack Go SDK Client Fundamentals

## Client Initialization

Initialize the Slack API client with your bot token:

```go
import "github.com/slack-go/slack"

api := slack.New("xoxb-your-bot-token")
```

Enable debug mode for development:

```go
api := slack.New(
    "xoxb-your-bot-token",
    slack.OptionDebug(true),
)
```

## When to Use Which Approach

### Web API (synchronous operations)
Use for direct API calls where you initiate the action:
- Sending messages, creating channels
- Retrieving user information
- Uploading files
- Any request-response operation

### Socket Mode (WebSocket - behind firewall)
Use when your app runs behind a firewall and can't receive HTTP requests:
- Real-time event handling without public URL
- Apps running on local machines or private networks
- Development and testing environments

### Events API (HTTP webhooks - public URL)
Use when you have a publicly accessible endpoint:
- Production apps with HTTPS endpoints
- Event-driven architectures with webhooks
- Apps hosted on cloud platforms

## Error Handling Patterns

Always handle errors from API calls:

```go
_, _, err := api.PostMessage(channelID, slack.MsgOptionText(text, false))
if err != nil {
    // Handle specific error types
    if rateLimitedError, ok := err.(*slack.RateLimitedError); ok {
        // Wait and retry
        time.Sleep(rateLimitedError.RetryAfter)
    }
    return fmt.Errorf("failed to post message: %w", err)
}
```

Use context for cancellation and timeouts:

```go
ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
defer cancel()

// Pass context to API methods that support it
```

## Project Structure Recommendation

```
slack-bot/
├── cmd/
│   └── bot/
│       └── main.go           # Entry point
├── internal/
│   ├── handlers/
│   │   ├── messages.go       # Message handlers
│   │   ├── events.go         # Event handlers
│   │   └── commands.go       # Slash command handlers
│   ├── slack/
│   │   ├── client.go         # Slack client wrapper
│   │   └── middleware.go     # Authentication, rate limiting
│   └── config/
│       └── config.go         # Configuration management
├── pkg/
│   └── models/               # Shared data models
├── go.mod
└── go.sum
```

## Testing Strategies

See [testing-patterns.md](../../references/testing-patterns.md) for comprehensive testing guidance including:
- Mocking the Slack API client
- Integration testing patterns
- Test fixtures for events and messages
- CI/CD testing recommendations

## Configuration Best Practices

For advanced configuration including custom HTTP clients, retry strategies, and rate limiting:
- See [client-configuration.md](../../references/client-configuration.md)

## Next Steps

Based on your use case, explore these skills:

- **Web API operations** → Use the `slack-web-api` skill for messaging, channels, users, files
- **Real-time events** → Use the `slack-realtime-events` skill for Socket Mode or Events API
- **OAuth setup** → Use the `slack-auth-security` skill for multi-workspace authentication

## Common Pitfalls

- Hardcoding tokens in code (use environment variables)
- Not handling rate limits (implement exponential backoff)
- Forgetting to validate incoming webhook signatures
- Using blocking operations in event handlers (use goroutines)
- Not implementing proper context cancellation
