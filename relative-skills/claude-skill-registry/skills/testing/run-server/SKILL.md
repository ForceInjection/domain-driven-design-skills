---
name: run-server
description: Start the Gambit game server on 0.0.0.0:1234. Use when the user wants to run just the server, test server functionality, or manually test with clients.
---

# Run Gambit Server

Starts the Gambit game server, which listens for client connections on port 1234.

## Instructions

1. Run the server command:
   ```bash
   make run-server
   ```

## Server Details

- **Listen Address**: 0.0.0.0:1234
- **Protocol**: ENet (UDP-based)
- **Logging**: Server logs all connections and events via spdlog

## Expected Behavior

When running, you should see:
```
[HH:MM:SS] [info] Logger initialized
[HH:MM:SS] [info] Server initialized and listening on port 1234
```

When clients connect:
```
[HH:MM:SS] [info] Player <id> joined (color: r,g,b)
```

## Stopping the Server

- Press `Ctrl+C` to gracefully shut down the server
- The server will close all client connections and clean up

## Notes

- The server runs in the foreground - use `Ctrl+C` to stop it
- For testing multiple clients, use the `dev` skill instead
- Ensure port 1234 is not already in use
- The server will automatically build if needed
