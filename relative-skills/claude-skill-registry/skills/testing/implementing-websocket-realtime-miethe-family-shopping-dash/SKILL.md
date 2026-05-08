---
name: implementing-websocket-realtime
description: Use this skill when implementing real-time features with WebSockets, including connection lifecycle management, pub/sub event patterns, state synchronization between client and server, event broadcasting, and integration with frontend state management (React Query, SWR, etc.). Covers FastAPI/Node.js/Express backends and React/Next.js/Vue frontends with fallback strategies and error recovery.
---

# WebSocket Real-Time Implementation

## Decision Tree: Real-Time Protocol Selection

| Requirement | Protocol | Why |
|-------------|----------|-----|
| Bidirectional, instant updates | **WebSocket** | Full duplex, low latency |
| Server → client only | **SSE** | Simpler, auto-reconnect |
| Infrequent updates (<1/min) | **Polling** | Simpler, no persistent connection |
| Mobile/unstable network | **WS + Fallback** | Graceful degradation |

**Decision**: Use WebSocket for real-time collaboration, SSE for notifications, polling as last resort.

## Generic Event Structure

```typescript
interface WebSocketEvent {
  topic: string;              // "resource-type:identifier" (e.g., "gift-list:family-123")
  event: EventType;           // ADDED | UPDATED | DELETED | STATUS_CHANGED | CUSTOM
  data: {
    entity_id: string;        // Resource ID
    payload: unknown;         // Event-specific data (DTO)
    user_id?: string;         // Who triggered (optional)
    tenant_id?: string;       // Multi-tenant context (optional)
    timestamp: string;        // ISO 8601
  };
  trace_id?: string;          // For observability
}

type EventType = "ADDED" | "UPDATED" | "DELETED" | "STATUS_CHANGED" | string;
```

**Validation**: See `./scripts/validate-ws-event.js`

## Connection Lifecycle

### 1. Initial Connection

```typescript
// Client
const ws = new WebSocket(`${WS_URL}?token=${authToken}`);

ws.onopen = () => {
  console.log('Connected');
  subscribeToTopics(['gift-list:123', 'user:456']);
};
```

```python
# Server (FastAPI)
@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket, token: str):
    await websocket.accept()
    user = authenticate(token)  # Validate on connect
    connection_manager.connect(websocket, user.id)
```

### 2. Authentication

**Options**:
- **Query param**: `?token=jwt` (simplest)
- **First message**: Send auth message after connect
- **Cookie**: Use existing HTTP session

**Recommendation**: Query param for stateless, first message for flexible auth.

### 3. Subscription Management

```typescript
// Subscribe to topics
function subscribe(topics: string[]) {
  ws.send(JSON.stringify({
    type: 'subscribe',
    topics: ['gift-list:123', 'user:456']
  }));
}

// Unsubscribe on unmount
function unsubscribe(topics: string[]) {
  ws.send(JSON.stringify({
    type: 'unsubscribe',
    topics: ['gift-list:123']
  }));
}
```

### 4. Heartbeat/Keepalive

```typescript
// Client: Ping every 30s
const heartbeat = setInterval(() => {
  if (ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify({ type: 'ping' }));
  }
}, 30000);

// Server responds with pong
ws.onmessage = (event) => {
  const msg = JSON.parse(event.data);
  if (msg.type === 'pong') {
    lastPong = Date.now();
  }
};
```

### 5. Reconnection Logic

```typescript
let reconnectAttempts = 0;
const MAX_RECONNECT_ATTEMPTS = 5;
const INITIAL_DELAY = 1000;

function reconnect() {
  if (reconnectAttempts >= MAX_RECONNECT_ATTEMPTS) {
    console.error('Max reconnection attempts reached');
    return;
  }

  const delay = INITIAL_DELAY * Math.pow(2, reconnectAttempts); // Exponential backoff
  setTimeout(() => {
    reconnectAttempts++;
    connect();
  }, delay);
}

ws.onclose = () => {
  console.log('Connection closed, reconnecting...');
  reconnect();
};
```

### 6. Cleanup

```typescript
// On component unmount
useEffect(() => {
  return () => {
    if (ws) {
      ws.close();
      clearInterval(heartbeat);
    }
  };
}, []);
```

**Details**: See `./connection-lifecycle.md`

## State Synchronization Pattern

### Flow

```
1. Load initial data    → REST API (React Query)
2. Subscribe to updates → WebSocket (on mount)
3. Receive event        → Invalidate cache → React Query refetches
4. Optimistic update    → Update UI immediately, rollback on error
5. Unsubscribe          → WebSocket (on unmount)
6. Fallback             → Poll every 10s if WS fails
```

### Implementation

```typescript
// 1. Load initial data
const { data, isLoading } = useQuery({
  queryKey: ['gift-list', listId],
  queryFn: () => fetchGiftList(listId),
});

// 2. Subscribe to WebSocket updates
useEffect(() => {
  const ws = connectWebSocket();

  ws.onmessage = (event) => {
    const wsEvent: WebSocketEvent = JSON.parse(event.data);

    // 3. Invalidate cache on event
    if (wsEvent.topic === `gift-list:${listId}`) {
      queryClient.invalidateQueries(['gift-list', listId]);
    }
  };

  ws.send(JSON.stringify({
    type: 'subscribe',
    topics: [`gift-list:${listId}`]
  }));

  return () => {
    ws.send(JSON.stringify({
      type: 'unsubscribe',
      topics: [`gift-list:${listId}`]
    }));
    ws.close();
  };
}, [listId]);

// 4. Optimistic update
const mutation = useMutation({
  mutationFn: updateGift,
  onMutate: async (newGift) => {
    await queryClient.cancelQueries(['gift-list', listId]);
    const previous = queryClient.getQueryData(['gift-list', listId]);
    queryClient.setQueryData(['gift-list', listId], (old) => ({
      ...old,
      gifts: old.gifts.map(g => g.id === newGift.id ? newGift : g)
    }));
    return { previous };
  },
  onError: (err, newGift, context) => {
    queryClient.setQueryData(['gift-list', listId], context.previous);
  },
});
```

**Details**: See `./state-sync-strategies.md`

## Implementation Checklist

### Backend Setup

- [ ] WebSocket server endpoint
  - [ ] FastAPI: `@app.websocket("/ws")`
  - [ ] Node.js: `ws` or `socket.io` library
- [ ] Authentication on connect
- [ ] Connection manager (track active connections)
- [ ] Topic subscription logic
- [ ] Event broadcasting
  - [ ] Per-topic subscribers
  - [ ] Per-user filtering (if multi-tenant)
- [ ] Heartbeat/pong handler
- [ ] Error handling & logging
- [ ] Trace IDs for observability

### Frontend Setup

- [ ] WebSocket connection hook
- [ ] Auto-reconnection logic
- [ ] Subscription management
- [ ] Event handlers
- [ ] State management integration
  - [ ] React Query invalidation
  - [ ] SWR revalidation
  - [ ] Custom state updates
- [ ] Optimistic updates
- [ ] Connection status UI
- [ ] Fallback polling (if WS fails)
- [ ] Cleanup on unmount

### Testing

- [ ] Connection establishment
- [ ] Authentication flow
- [ ] Subscription/unsubscription
- [ ] Event delivery
- [ ] Reconnection logic
- [ ] Fallback behavior
- [ ] Load testing (concurrent connections)
- [ ] Network failure scenarios

**Details**: See `./backend-patterns.md` and `./frontend-patterns.md`

## Backend Patterns

### FastAPI Connection Manager

```python
from fastapi import WebSocket
from typing import Dict, Set

class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, WebSocket] = {}
        self.subscriptions: Dict[str, Set[str]] = {}  # topic -> set of user_ids

    async def connect(self, websocket: WebSocket, user_id: str):
        self.active_connections[user_id] = websocket

    def disconnect(self, user_id: str):
        if user_id in self.active_connections:
            del self.active_connections[user_id]

    def subscribe(self, user_id: str, topic: str):
        if topic not in self.subscriptions:
            self.subscriptions[topic] = set()
        self.subscriptions[topic].add(user_id)

    async def broadcast(self, topic: str, event: dict):
        if topic not in self.subscriptions:
            return

        for user_id in self.subscriptions[topic]:
            if user_id in self.active_connections:
                ws = self.active_connections[user_id]
                await ws.send_json(event)

manager = ConnectionManager()
```

**Full examples**: See `./backend-patterns.md`

## Frontend Patterns

### React Hook: useWebSocket

```typescript
function useWebSocket(topics: string[]) {
  const [isConnected, setIsConnected] = useState(false);
  const wsRef = useRef<WebSocket | null>(null);
  const queryClient = useQueryClient();

  useEffect(() => {
    const ws = new WebSocket(`${WS_URL}?token=${getToken()}`);

    ws.onopen = () => {
      setIsConnected(true);
      ws.send(JSON.stringify({ type: 'subscribe', topics }));
    };

    ws.onmessage = (event) => {
      const wsEvent: WebSocketEvent = JSON.parse(event.data);

      // Invalidate relevant queries
      queryClient.invalidateQueries([wsEvent.topic.split(':')[0]]);
    };

    ws.onclose = () => {
      setIsConnected(false);
      // Reconnect logic here
    };

    wsRef.current = ws;

    return () => {
      ws.send(JSON.stringify({ type: 'unsubscribe', topics }));
      ws.close();
    };
  }, [topics.join(',')]);

  return { isConnected };
}
```

**Full examples**: See `./frontend-patterns.md`

## Progressive Disclosure References

For detailed patterns and examples:

- **Connection Lifecycle**: `./connection-lifecycle.md`
- **Event Structure & Validation**: `./event-structure-patterns.md`
- **State Sync Strategies**: `./state-sync-strategies.md`
- **Backend Implementations**: `./backend-patterns.md`
- **Frontend Implementations**: `./frontend-patterns.md`
- **Fallback & Recovery**: `./fallback-strategies.md`
- **Event Validator Script**: `./scripts/validate-ws-event.js`
