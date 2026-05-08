---
name: run-client
description: Start a single Gambit game client that connects to 127.0.0.1:1234. Use when the user wants to run a client, test client functionality, or manually connect to a server.
---

# Run Gambit Client

Starts a single Gambit game client that connects to the server at 127.0.0.1:1234.

## Instructions

1. Ensure the server is running first (use `run-server` skill or `dev` skill)

2. Run the client command:
   ```bash
   make run-client
   ```

## Client Details

- **Server Address**: 127.0.0.1:1234
- **Graphics**: SDL2 window (800×600)
- **Protocol**: ENet (UDP-based)
- **Input**: WASD or arrow keys for movement

## Expected Behavior

When running, you should see:
```
[HH:MM:SS] [info] Logger initialized
[HH:MM:SS] [info] Connected to 127.0.0.1:1234
[HH:MM:SS] [info] Local player color: r,g,b
```

An 800×600 window will open showing the game.

## Stopping the Client

- Close the window or press `Ctrl+C`
- The client will disconnect gracefully

## Notes

- The client runs in the foreground
- For testing multiplayer, use the `dev` skill to run 1 server + 4 clients automatically
- The client will automatically build if needed
- Ensure the server is running before starting the client
