---
name: gamebuddies-game-generator
description: Generate complete multiplayer games for GameBuddies.io platform with full integration including streamer mode, lobby system, chat, WebRTC video, and real-time gameplay. Creates server logic, client UI, type definitions, and game mechanics following GameBuddies template patterns.
---

# GameBuddies Game Generator

You are an expert at creating multiplayer games for the GameBuddies.io platform using the proven template architecture. This skill guides you through generating complete, production-ready multiplayer games with all GameBuddies features built-in.

## Core Capabilities

Generate games with these integrated features:
- **Streamer Mode**: Hidden room codes, GameBuddies API integration, return-to-lobby flow
- **Lobby System**: Pre-game waiting room with player list, settings, and chat
- **Real-time Chat**: Message history, emoji picker, 500-char limit
- **WebRTC Video**: Peer-to-peer video chat with mobile support, TURN servers
- **Player Management**: Host controls, kick functionality, 30-second disconnect grace period
- **Game Logic**: Turn-based, real-time, or phase-based gameplay patterns
- **Type Safety**: Full TypeScript with matching client/server types

## Game Generation Process

### Step 1: Gather Requirements

Ask the user these questions to understand their game:

1. **Game Concept**: What's the game about? (e.g., "A reaction game where players press buttons when colors match")
2. **Game Type**:
   - Turn-based (players take sequential turns)
   - Real-time (all players act simultaneously)
   - Phase-based (game progresses through distinct phases)
3. **Player Count**: Min and max players (2-8 recommended)
4. **Win Condition**: How does a player win? (e.g., "First to 10 points", "Most points after 5 rounds")
5. **Special Features**: Any unique mechanics? (e.g., "Power-ups", "Voting system", "Time limits")

### Step 2: Define Type Structures

Create type definitions in both `server/types.ts` and `client/src/types.ts`:

**Key Types to Define:**
```typescript
// GameData - The core game state
interface GameData {
  currentRound: number;
  maxRounds: number;
  // Add game-specific state (scores, turn info, board state, etc.)
}

// Settings - Configurable game parameters
interface Settings {
  maxPlayers: number;
  // Add game-specific settings (round count, time limits, difficulty, etc.)
}

// Player - Extended player information
interface Player {
  id: string;
  name: string;
  isHost: boolean;
  isConnected: boolean;
  // Add game-specific player data (score, lives, status, etc.)
}
```

**Pattern to Follow:**
- Server types are the source of truth
- Client types mirror server but may add UI-only properties
- Use TypeScript enums for game states and phases
- Keep types synchronized between client and server

### Step 3: Implement Server Logic

Edit `server/server.ts` starting at line 343 in the `socket.on('game:start')` handler:

**3A. Initialize Game State**
```typescript
socket.on('game:start', () => {
  const lobby = /* ... find lobby ... */;

  // Initialize your game state
  lobby.gameData = {
    currentRound: 1,
    maxRounds: lobby.settings.rounds || 5,
    // Initialize game-specific state
    scores: lobby.players.reduce((acc, p) => ({ ...acc, [p.id]: 0 }), {}),
    currentTurn: lobby.players[0].id,
    // etc.
  };

  lobby.state = 'PLAYING';
  io.to(lobby.code).emit('game:started', lobby);
});
```

**3B. Add Game Event Handlers**

Add new socket event listeners for your game actions:

```typescript
socket.on('game:your-action', (data: YourActionData) => {
  const lobby = /* ... find and validate ... */;

  // Validate action (player's turn, valid move, etc.)
  // Update game state
  // Check win conditions
  // Broadcast update

  io.to(lobby.code).emit('game:update', lobby.gameData);

  // If game ended
  if (isGameOver) {
    lobby.state = 'GAME_ENDED';
    io.to(lobby.code).emit('game:ended', {
      winners: calculateWinners(lobby),
      finalScores: lobby.gameData.scores
    });
  }
});
```

**3C. Validation Patterns**

Always validate:
- Player is in the lobby
- It's the player's turn (for turn-based games)
- Move/action is legal
- Lobby is in PLAYING state

Use utilities from `server/utils/validation.ts`:
- `sanitizeInput()` - Clean user input
- `validatePlayerName()` - 1-20 characters
- `validateChatMessage()` - 1-500 characters

### Step 4: Create Client UI

Replace `client/src/components/GameComponent.tsx` with your game interface:

**4A. Component Structure**
```typescript
import { useSocket } from '../hooks/useSocket';
import { Lobby } from '../types';

interface GameComponentProps {
  lobby: Lobby;
  currentPlayerId: string;
}

export const GameComponent: React.FC<GameComponentProps> = ({ lobby, currentPlayerId }) => {
  const socket = useSocket();
  const gameData = lobby.gameData;

  // Game-specific handlers
  const handleAction = (actionData: any) => {
    socket.emit('game:your-action', actionData);
  };

  return (
    <div className="game-container">
      {/* Scoreboard */}
      {/* Game board/interface */}
      {/* Action buttons */}
      {/* Status displays */}
    </div>
  );
};
```

**4B. UI Patterns**

Use these consistent patterns:
- Tailwind CSS for styling (bg-blue-500, rounded-lg, etc.)
- Responsive design with mobile-first approach
- Disable buttons when not player's turn
- Visual feedback for actions (animations, color changes)
- Clear status messages ("Waiting for other players", "Your turn!")

**4C. Real-time Updates**

Listen for server events in useEffect:
```typescript
useEffect(() => {
  socket.on('game:update', (updatedGameData) => {
    // Update local state
  });

  return () => {
    socket.off('game:update');
  };
}, [socket]);
```

### Step 5: Implement Game Logic Patterns

Choose the pattern that matches your game type:

**TURN-BASED PATTERN** (Word Chain, Uno, Chess)
```typescript
// Server tracks currentTurn
gameData.currentTurn = playerIds[nextPlayerIndex];

// Server validates it's player's turn
if (data.playerId !== lobby.gameData.currentTurn) {
  socket.emit('error', { message: 'Not your turn' });
  return;
}

// Advance turn after valid action
const currentIndex = players.findIndex(p => p.id === gameData.currentTurn);
gameData.currentTurn = players[(currentIndex + 1) % players.length].id;
```

**REAL-TIME PATTERN** (Space Invaders, Racing, Battle Royale)
```typescript
// Server runs game loop (60Hz recommended)
const gameLoop = setInterval(() => {
  updateGamePhysics(lobby.gameData);
  checkCollisions(lobby.gameData);
  io.to(lobby.code).emit('game:update', lobby.gameData);
}, 16); // ~60fps

// Store interval reference to clear on game end
lobby.gameData.gameLoopInterval = gameLoop;
```

**PHASE-BASED PATTERN** (Color Memory, Trivia, Drawing Games)
```typescript
// Define phases as enum
enum GamePhase {
  SHOWING = 'showing',
  ANSWERING = 'answering',
  SCORING = 'scoring'
}

gameData.currentPhase = GamePhase.SHOWING;

// Transition phases with timers
setTimeout(() => {
  gameData.currentPhase = GamePhase.ANSWERING;
  io.to(lobby.code).emit('game:update', lobby.gameData);
}, 3000);
```

### Step 6: Add Settings and Configuration

Update `client/src/components/Lobby.tsx` to add game-specific settings:

```typescript
// Add settings controls in the Lobby component
<div className="settings-panel">
  <label>Rounds</label>
  <input
    type="number"
    value={settings.rounds}
    onChange={(e) => updateSettings({ rounds: parseInt(e.target.value) })}
    min={1}
    max={10}
  />
</div>
```

Settings are controlled by the host and synced via `socket.emit('settings:update')`.

### Step 7: Test and Validate

Ensure your game handles:
- [ ] Player disconnects during game (30-second grace period)
- [ ] Host leaving (host transfer to next player)
- [ ] Invalid moves/actions (proper error messages)
- [ ] Edge cases (one player left, all players disconnect)
- [ ] GameBuddies integration (streamer mode hides room code)
- [ ] Game restart functionality
- [ ] Return to GameBuddies button appears (GameBuddies rooms only)

## Reference Game Examples

The template includes 3 complete reference games in the `Games/` folder:

1. **Color Memory** (Phase-based)
   - Shows: Phase transitions, timing, scoring system
   - Pattern: WATCHING → REPLAYING → SCORING
   - 600 lines

2. **Word Chain** (Turn-based)
   - Shows: Turn rotation, validation, voting system
   - Pattern: Sequential turns with timer
   - 800 lines

3. **Space Invaders** (Real-time)
   - Shows: Game loop, physics, collision detection
   - Pattern: 60Hz server-side simulation
   - 700 lines

## Key Files to Modify

| File | Purpose | What to Add |
|------|---------|-------------|
| `server/types.ts` | Type definitions | GameData, Settings interfaces |
| `client/src/types.ts` | Client types | Mirror server types + UI types |
| `server/server.ts` | Game logic | Event handlers starting at line 343 |
| `client/src/components/GameComponent.tsx` | Game UI | Replace entire component |
| `client/src/components/Lobby.tsx` | Settings | Add game-specific settings controls |
| `server/utils/validation.ts` | Validation | Add game-specific validators |

## Built-in Features (Already Implemented)

Your game automatically includes:

✅ **Lobby System** - Pre-game waiting room with player list
✅ **Chat System** - Real-time messaging with emoji picker
✅ **WebRTC Video** - Peer-to-peer video chat with mobile support
✅ **Player Management** - Kick, disconnect handling, host transfer
✅ **GameBuddies Integration** - Streamer mode, session tokens, return flow
✅ **Return Button** - Appears only in GameBuddies rooms
✅ **Responsive Design** - Mobile and desktop support
✅ **Type Safety** - Full TypeScript coverage
✅ **Validation** - Input sanitization and error handling
✅ **WebRTC Features** - Virtual backgrounds, 3D avatars, audio effects

## GameBuddies API Integration

Games automatically integrate with GameBuddies.io:

**Streamer Mode Flow:**
1. Streamer clicks "Launch Game" on gamebuddies.io
2. Game receives session token via URL: `?session=TOKEN&players=4&role=gm`
3. Client resolves token to room code via GameBuddies API
4. Room code is hidden from UI (prevents stream sniping)
5. Players join via safe invite links
6. Return button appears automatically
7. On return, players redirect back to gamebuddies.io lobby

**Status Updates:**
Server automatically sends player status to GameBuddies API:
- `connected` - Player joined
- `in_game` - Game started
- `disconnected` - Player left

**Return Flow:**
```typescript
// Client emits return request
socket.emit('gamebuddies:return', { returnAll: true });

// Server calls GameBuddies API
const { returnUrl } = await requestReturnToGameBuddies(lobby.code, true);

// Server sends redirect URL to clients
socket.emit('gamebuddies:return-redirect', { returnUrl });
```

## Socket Event Reference

**Standard Events (Already Handled):**
- `lobby:create`, `lobby:join` - Room management
- `game:start`, `game:end`, `game:restart` - Game lifecycle
- `chat:send-message` - Chat system
- `player:kick` - Player management
- `gamebuddies:return` - Return to GameBuddies
- `webrtc:offer`, `webrtc:answer`, `webrtc:ice-candidate` - Video chat

**Your Custom Events:**
- `game:your-action` - Game-specific actions (YOU define these)
- `game:update` - Broadcast game state changes

## Code Generation Guidelines

1. **Always use TypeScript** - No plain JavaScript
2. **Follow existing patterns** - Match the template's code style
3. **Validate on server** - Never trust client input
4. **Emit updates immediately** - Use `io.to(lobby.code).emit()` after state changes
5. **Handle edge cases** - Disconnects, invalid moves, race conditions
6. **Add comments** - Explain game-specific logic
7. **Use Tailwind CSS** - For consistent styling
8. **Test streamer mode** - Verify room code is hidden
9. **Implement restart** - Clear game state properly in `game:restart` handler
10. **Mobile-friendly** - Responsive design, touch-friendly buttons

## Example: Generating a Simple Dice Game

**User Request:** "Create a dice rolling game where players take turns rolling dice, highest total after 5 rounds wins"

**Your Process:**

1. **Define Types:**
```typescript
// server/types.ts & client/src/types.ts
interface GameData {
  currentRound: number;
  maxRounds: number;
  currentTurn: string; // player ID
  lastRoll: number | null;
  scores: { [playerId: string]: number };
  rolls: { [playerId: string]: number[] };
}

interface Settings {
  maxPlayers: number;
  rounds: number;
}
```

2. **Initialize Game (server/server.ts line 343):**
```typescript
lobby.gameData = {
  currentRound: 1,
  maxRounds: lobby.settings.rounds || 5,
  currentTurn: lobby.players[0].id,
  lastRoll: null,
  scores: lobby.players.reduce((acc, p) => ({ ...acc, [p.id]: 0 }), {}),
  rolls: lobby.players.reduce((acc, p) => ({ ...acc, [p.id]: [] }), {})
};
```

3. **Add Event Handler:**
```typescript
socket.on('game:roll-dice', () => {
  const lobby = findLobbyBySocketId(socket.id);
  if (!lobby || lobby.state !== 'PLAYING') return;

  const player = lobby.players.find(p => p.id === socket.id);
  if (!player || lobby.gameData.currentTurn !== player.id) {
    socket.emit('error', { message: 'Not your turn' });
    return;
  }

  // Roll dice
  const roll = Math.floor(Math.random() * 6) + 1;
  lobby.gameData.lastRoll = roll;
  lobby.gameData.scores[player.id] += roll;
  lobby.gameData.rolls[player.id].push(roll);

  // Next turn
  const currentIndex = lobby.players.findIndex(p => p.id === player.id);
  const nextPlayer = lobby.players[(currentIndex + 1) % lobby.players.length];
  lobby.gameData.currentTurn = nextPlayer.id;

  // Check round completion
  if (nextPlayer.id === lobby.players[0].id) {
    lobby.gameData.currentRound++;
  }

  // Check game end
  if (lobby.gameData.currentRound > lobby.gameData.maxRounds) {
    const winner = Object.entries(lobby.gameData.scores)
      .sort(([,a], [,b]) => b - a)[0];
    lobby.state = 'GAME_ENDED';
    io.to(lobby.code).emit('game:ended', {
      winnerId: winner[0],
      finalScores: lobby.gameData.scores
    });
  } else {
    io.to(lobby.code).emit('game:update', lobby.gameData);
  }
});
```

4. **Create UI (client/src/components/GameComponent.tsx):**
```typescript
export const GameComponent: React.FC<GameComponentProps> = ({ lobby, currentPlayerId }) => {
  const socket = useSocket();
  const gameData = lobby.gameData;
  const isMyTurn = gameData.currentTurn === currentPlayerId;

  const rollDice = () => {
    socket.emit('game:roll-dice');
  };

  return (
    <div className="p-8">
      <div className="text-center mb-6">
        <h2 className="text-2xl font-bold">Round {gameData.currentRound}/{gameData.maxRounds}</h2>
      </div>

      <div className="grid grid-cols-2 gap-4 mb-6">
        {lobby.players.map(player => (
          <div key={player.id} className={`p-4 rounded ${player.id === gameData.currentTurn ? 'bg-blue-500' : 'bg-gray-700'}`}>
            <div className="font-bold">{player.name}</div>
            <div>Score: {gameData.scores[player.id]}</div>
          </div>
        ))}
      </div>

      {gameData.lastRoll && (
        <div className="text-center text-4xl mb-4">
          🎲 {gameData.lastRoll}
        </div>
      )}

      <button
        onClick={rollDice}
        disabled={!isMyTurn}
        className={`w-full py-4 rounded text-xl ${isMyTurn ? 'bg-green-500 hover:bg-green-600' : 'bg-gray-500 cursor-not-allowed'}`}
      >
        {isMyTurn ? 'Roll Dice!' : 'Waiting for other player...'}
      </button>
    </div>
  );
};
```

5. **Add Settings (client/src/components/Lobby.tsx):**
```typescript
<div className="mb-4">
  <label className="block mb-2">Number of Rounds</label>
  <input
    type="number"
    value={settings.rounds || 5}
    onChange={(e) => updateSettings({ rounds: parseInt(e.target.value) })}
    min={1}
    max={20}
    className="w-full p-2 rounded bg-gray-700"
  />
</div>
```

## Best Practices

1. **Server Authority** - All game logic executes on server, clients only display state
2. **Immediate Feedback** - Emit updates right after state changes
3. **Graceful Degradation** - Handle disconnects, errors, edge cases
4. **Clear Status** - Show whose turn, what's happening, how to play
5. **Mobile Support** - Large touch targets, responsive layout
6. **Performance** - Avoid sending entire lobby object, send deltas when possible
7. **Security** - Validate all inputs, sanitize chat messages
8. **Consistency** - Follow existing code patterns and naming conventions

## Deployment

The template is pre-configured for Render.com:
- Automatic reverse proxy support
- Environment variables: `PORT`, `NODE_ENV`, `CORS_ORIGIN`
- Health check endpoint: `/health`
- Build commands: `npm run build:render`
- Start command: `node server/dist/server.js`

## Common Pitfalls to Avoid

❌ Client-side game logic (creates cheating opportunities)
❌ Forgetting to validate player's turn
❌ Not handling disconnects
❌ Hardcoding room codes (breaks streamer mode)
❌ Forgetting to clear intervals/timeouts on game end
❌ Not synchronizing types between client/server
❌ Missing return button (required for GameBuddies)
❌ Emitting to socket instead of room (`socket.emit` vs `io.to(code).emit`)

## Output Format

When generating a game, provide:

1. **Type definitions** (both client and server)
2. **Server event handlers** (initialization + custom events)
3. **GameComponent.tsx** (complete replacement)
4. **Settings UI** (additions to Lobby.tsx)
5. **Testing checklist** (edge cases to verify)
6. **Game rules** (brief explanation for players)

## Summary

This skill transforms game ideas into production-ready multiplayer games with:
- Complete GameBuddies.io integration (streamer mode, return flow, API calls)
- Real-time multiplayer using Socket.IO
- WebRTC video chat with mobile support
- Chat system with emoji picker
- Lobby system with player management
- Type-safe TypeScript throughout
- Responsive, mobile-friendly UI
- Server-authoritative game logic
- Proper validation and error handling

Follow the patterns, reference the examples, and create engaging multiplayer experiences for the GameBuddies platform!
