---
name: composable-svelte-chat
description: Streaming chat and collaborative features for Composable Svelte. Use when implementing LLM chat interfaces, real-time messaging, or collaborative features. Covers StreamingChat (transport-agnostic), presence tracking, typing indicators, and WebSocket integration from @composable-svelte/chat package.
---

# Composable Svelte Chat Package

Streaming chat with collaborative features for LLM interactions and real-time messaging.

---

## PACKAGE OVERVIEW

**Package**: `@composable-svelte/chat`

**Purpose**: Transport-agnostic streaming chat designed for LLM interactions with collaborative features.

**Technology Stack**:
- **Markdown**: Rendering with syntax highlighting (Prism.js)
- **WebSocket**: Real-time communication and presence
- **MediaRecorder**: Optional voice input integration
- **PDF.js**: PDF attachment preview

**Core Components**:
- `StreamingChat` - Transport-agnostic streaming chat
- `Collaborative Features` - Presence, typing, cursors
- `WebSocket Manager` - Connection management

**State Management**:
All components follow Composable Architecture patterns with dedicated reducers and type-safe actions.

---

## STREAMING CHAT

**Purpose**: Transport-agnostic streaming chat for LLM interactions (OpenAI, Anthropic, Ollama, etc.).

### Quick Start

```typescript
import { createStore } from '@composable-svelte/core';
import {
  StandardStreamingChat,
  streamingChatReducer,
  createInitialStreamingChatState
} from '@composable-svelte/chat';

// Create chat store
const chatStore = createStore({
  initialState: createInitialStreamingChatState(),
  reducer: streamingChatReducer,
  dependencies: {
    sendMessage: async function*(message, signal) {
      // Send to your LLM API (OpenAI, Anthropic, Ollama, etc.)
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message }),
        signal
      });

      const reader = response.body!.getReader();
      const decoder = new TextDecoder();

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        const chunk = decoder.decode(value);
        const lines = chunk.split('\n').filter(Boolean);

        for (const line of lines) {
          if (line.startsWith('data: ')) {
            const data = JSON.parse(line.slice(6));
            if (data.content) {
              yield data.content;
            }
          }
        }
      }
    }
  }
});

<StandardStreamingChat {chatStore} />
```

### Component Variants

**MinimalStreamingChat**:
- Message list + input
- No toolbar, no status indicators
- Best for embedded chat

**StandardStreamingChat** (recommended):
- Message list + input
- Toolbar with clear history
- Streaming status indicator
- Best for most use cases

**FullStreamingChat**:
- Standard features
- Message reactions
- Attachments (images, PDFs, audio)
- Voice input
- Copy/edit/delete messages
- Best for feature-rich chat apps

**StreamingChat** (legacy):
- Original component
- Use one of the variants above instead

### Props

All variants accept:
- `chatStore: Store<StreamingChatState, StreamingChatAction>` - Chat store (required)

**FullStreamingChat** additional props:
- `showReactions: boolean` - Enable reactions (default: true)
- `showAttachments: boolean` - Enable attachments (default: true)
- `showVoiceInput: boolean` - Enable voice input (default: true)

### State Interface

```typescript
interface StreamingChatState {
  // Messages
  messages: Message[];
  streamingMessage: string | null;    // Current streaming content
  isStreaming: boolean;

  // Input
  inputValue: string;
  inputDisabled: boolean;

  // Attachments
  attachments: MessageAttachment[];
  isUploadingAttachment: boolean;

  // UI State
  isLoading: boolean;
  error: string | null;

  // Voice (if enabled)
  isRecordingVoice: boolean;
  voiceTranscript: string | null;
}

interface Message {
  id: string;
  role: 'user' | 'assistant' | 'system';
  content: string;
  timestamp: number;
  attachments?: MessageAttachment[];
  reactions?: MessageReaction[];
  isEdited?: boolean;
  isDeleted?: boolean;
}

interface MessageAttachment {
  id: string;
  type: 'image' | 'pdf' | 'audio' | 'file';
  url: string;
  name: string;
  size: number;
  metadata?: AttachmentMetadata;
}
```

### Actions

```typescript
type StreamingChatAction =
  // Messaging
  | { type: 'sendMessage'; content: string; attachments?: MessageAttachment[] }
  | { type: 'streamingStarted' }
  | { type: 'streamingChunk'; chunk: string }
  | { type: 'streamingCompleted' }
  | { type: 'streamingError'; error: string }
  | { type: 'cancelStreaming' }

  // Input
  | { type: 'inputChanged'; value: string }
  | { type: 'clearInput' }

  // Messages
  | { type: 'editMessage'; messageId: string; newContent: string }
  | { type: 'deleteMessage'; messageId: string }
  | { type: 'clearHistory' }

  // Reactions
  | { type: 'addReaction'; messageId: string; emoji: string }
  | { type: 'removeReaction'; messageId: string; reactionId: string }

  // Attachments
  | { type: 'addAttachment'; attachment: MessageAttachment }
  | { type: 'removeAttachment'; attachmentId: string }
  | { type: 'uploadAttachment'; file: File }

  // Voice
  | { type: 'startVoiceRecording' }
  | { type: 'stopVoiceRecording' }
  | { type: 'voiceTranscriptionCompleted'; transcript: string };
```

### Dependencies

```typescript
interface StreamingChatDependencies {
  // Message handler (required)
  sendMessage: (
    content: string,
    attachments: MessageAttachment[],
    signal: AbortSignal
  ) => AsyncGenerator<string, void, unknown>;

  // File upload (optional)
  uploadFile?: (file: File) => Promise<MessageAttachment>;

  // Voice transcription (optional)
  transcribeVoice?: (audioBlob: Blob) => Promise<string>;
}
```

### Complete Example

```typescript
<script lang="ts">
import { createStore, Effect } from '@composable-svelte/core';
import {
  FullStreamingChat,
  streamingChatReducer,
  createInitialStreamingChatState,
  type MessageAttachment
} from '@composable-svelte/chat';

// Create chat store with all features
const chatStore = createStore({
  initialState: createInitialStreamingChatState(),
  reducer: streamingChatReducer,
  dependencies: {
    // Stream from OpenAI
    sendMessage: async function*(content, attachments, signal) {
      const response = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${OPENAI_API_KEY}`
        },
        body: JSON.stringify({
          model: 'gpt-4',
          messages: [
            { role: 'user', content }
          ],
          stream: true
        }),
        signal
      });

      const reader = response.body!.getReader();
      const decoder = new TextDecoder();

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        const chunk = decoder.decode(value);
        const lines = chunk.split('\n').filter(line => line.trim().startsWith('data:'));

        for (const line of lines) {
          const data = line.replace('data: ', '');
          if (data === '[DONE]') break;

          try {
            const parsed = JSON.parse(data);
            const content = parsed.choices[0]?.delta?.content;
            if (content) {
              yield content;
            }
          } catch (e) {
            // Skip invalid JSON
          }
        }
      }
    },

    // Upload files to your storage
    uploadFile: async (file: File) => {
      const formData = new FormData();
      formData.append('file', file);

      const response = await fetch('/api/upload', {
        method: 'POST',
        body: formData
      });

      const { url, id } = await response.json();

      return {
        id,
        type: file.type.startsWith('image/') ? 'image' : 'file',
        url,
        name: file.name,
        size: file.size
      };
    },

    // Transcribe voice using Whisper
    transcribeVoice: async (audioBlob: Blob) => {
      const formData = new FormData();
      formData.append('file', audioBlob, 'recording.webm');
      formData.append('model', 'whisper-1');

      const response = await fetch('https://api.openai.com/v1/audio/transcriptions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${OPENAI_API_KEY}`
        },
        body: formData
      });

      const { text } = await response.json();
      return text;
    }
  }
});
</script>

<div class="chat-container">
  <FullStreamingChat
    {chatStore}
    showReactions={true}
    showAttachments={true}
    showVoiceInput={true}
  />

  <!-- Error display -->
  {#if $chatStore.error}
    <div class="error-toast">{$chatStore.error}</div>
  {/if}
</div>
```

---

## COLLABORATIVE FEATURES

**Purpose**: Real-time presence tracking, typing indicators, and live cursors for multi-user chat.

### Quick Start

```typescript
import { createStore } from '@composable-svelte/core';
import {
  StandardStreamingChat,
  collaborativeReducer,
  createInitialCollaborativeState,
  PresenceAvatarStack,
  TypingIndicator
} from '@composable-svelte/chat';

// Create collaborative chat store
const chatStore = createStore({
  initialState: createInitialCollaborativeState(),
  reducer: collaborativeReducer,
  dependencies: {
    sendMessage: /* ... */,
    connectWebSocket: (conversationId, userId, onMessage, onConnectionChange) => {
      const ws = new WebSocket(`wss://api.example.com/chat/${conversationId}`);

      ws.onopen = () => {
        onConnectionChange({ status: 'connected', connectedAt: Date.now() });
        ws.send(JSON.stringify({ type: 'join', userId }));
      };

      ws.onmessage = (event) => {
        const message = JSON.parse(event.data);
        onMessage(message);
      };

      ws.onclose = () => {
        onConnectionChange({ status: 'disconnected' });
      };

      return () => ws.close();
    },
    sendWebSocketMessage: async (message) => {
      ws.send(JSON.stringify(message));
    }
  }
});

// Connect to conversation
chatStore.dispatch({
  type: 'connectToConversation',
  conversationId: 'chat-123',
  userId: 'user-456'
});
```

### Collaborative State

```typescript
interface CollaborativeStreamingChatState extends StreamingChatState {
  // Connection
  connection: WebSocketConnectionState;
  conversationId: string | null;
  currentUserId: string | null;

  // Users
  users: Map<string, CollaborativeUser>;

  // Sync
  pendingActions: PendingAction[];
  syncState: SyncState;
}

interface CollaborativeUser {
  id: string;
  name: string;
  avatar?: string;
  color: string;
  presence: 'active' | 'idle' | 'away' | 'offline';
  typing: TypingInfo | null;
  cursor: CursorPosition | null;
  permissions: UserPermissions;
  lastSeen: number;
  lastHeartbeat: number;
}
```

### Presence Components

**PresenceBadge**:
```typescript
<PresenceBadge presence="active" showText={true} />
```

**PresenceAvatarStack**:
```typescript
import { PresenceAvatarStack, getActiveUsers } from '@composable-svelte/chat';

const activeUsers = $derived(getActiveUsers($chatStore.users, currentUserId));

<PresenceAvatarStack users={activeUsers} maxVisible={5} />
```

**PresenceList**:
```typescript
<PresenceList users={activeUsers} groupByPresence={true} />
```

### Typing Indicators

**TypingIndicator**:
```typescript
import { TypingIndicator, getTypingUsers } from '@composable-svelte/chat';

const typingUsers = $derived(
  getTypingUsers($chatStore.users, currentUserId, 'message')
);

<TypingIndicator users={typingUsers} />
```

**TypingUsersList**:
```typescript
<TypingUsersList users={typingUsers} />
```

### Cursor Tracking

**CursorMarker**:
```typescript
<CursorMarker
  user={user}
  position={user.cursor}
/>
```

**CursorOverlay**:
```typescript
import { CursorOverlay, getCursorPositions } from '@composable-svelte/chat';

const cursorPositions = $derived(
  getCursorPositions($chatStore.users, currentUserId)
);

<CursorOverlay cursors={cursorPositions} />
```

### Collaborative Actions

```typescript
type CollaborativeAction =
  // Connection
  | { type: 'connectToConversation'; conversationId: string; userId: string }
  | { type: 'disconnectFromConversation' }
  | { type: 'connectionStateChanged'; state: WebSocketConnectionState }

  // Users
  | { type: 'userJoined'; user: CollaborativeUser }
  | { type: 'userLeft'; userId: string }
  | { type: 'userPresenceChanged'; userId: string; presence: UserPresence }

  // Typing
  | { type: 'userStartedTyping'; userId: string; info: TypingInfo }
  | { type: 'userStoppedTyping'; userId: string }

  // Cursors
  | { type: 'userCursorMoved'; userId: string; position: CursorPosition }

  // Sync
  | { type: 'syncMessage'; messageId: string; action: string }
  | { type: 'syncCompleted'; messageId: string };
```

### Complete Collaborative Example

```typescript
<script lang="ts">
import { createStore } from '@composable-svelte/core';
import {
  StandardStreamingChat,
  collaborativeReducer,
  createInitialCollaborativeState,
  PresenceAvatarStack,
  TypingIndicator,
  getActiveUsers,
  getTypingUsers,
  type CollaborativeUser
} from '@composable-svelte/chat';

const currentUserId = 'user-123';

// Create WebSocket connection
let ws: WebSocket;

const chatStore = createStore({
  initialState: createInitialCollaborativeState(),
  reducer: collaborativeReducer,
  dependencies: {
    sendMessage: /* ... */,

    connectWebSocket: (conversationId, userId, onMessage, onConnectionChange) => {
      ws = new WebSocket(`wss://api.example.com/chat/${conversationId}`);

      ws.onopen = () => {
        onConnectionChange({ status: 'connected', connectedAt: Date.now() });
        ws.send(JSON.stringify({
          type: 'join',
          userId,
          user: {
            id: userId,
            name: 'Current User',
            color: '#3b82f6'
          }
        }));
      };

      ws.onmessage = (event) => {
        const message = JSON.parse(event.data);
        onMessage(message);
      };

      ws.onerror = () => {
        onConnectionChange({ status: 'error', error: 'Connection failed' });
      };

      ws.onclose = () => {
        onConnectionChange({ status: 'disconnected' });
      };

      return () => {
        ws.close();
      };
    },

    sendWebSocketMessage: async (message) => {
      if (ws?.readyState === WebSocket.OPEN) {
        ws.send(JSON.stringify(message));
      }
    }
  }
});

// Connect on mount
$effect(() => {
  chatStore.dispatch({
    type: 'connectToConversation',
    conversationId: 'chat-room-123',
    userId: currentUserId
  });

  return () => {
    chatStore.dispatch({ type: 'disconnectFromConversation' });
  };
});

// Emit typing events
let typingTimeout: ReturnType<typeof setTimeout>;
function handleInputChange(value: string) {
  chatStore.dispatch({ type: 'inputChanged', value });

  // Emit typing started
  chatStore.dispatch({
    type: 'userStartedTyping',
    userId: currentUserId,
    info: {
      target: 'message',
      startedAt: Date.now(),
      lastUpdate: Date.now()
    }
  });

  // Clear previous timeout
  clearTimeout(typingTimeout);

  // Stop typing after 2 seconds of inactivity
  typingTimeout = setTimeout(() => {
    chatStore.dispatch({ type: 'userStoppedTyping', userId: currentUserId });
  }, 2000);
}

// Derived state
const activeUsers = $derived(getActiveUsers($chatStore.users, currentUserId));
const typingUsers = $derived(getTypingUsers($chatStore.users, currentUserId, 'message'));
</script>

<div class="collaborative-chat">
  <!-- Presence indicators -->
  <div class="chat-header">
    <h2>Team Chat</h2>
    <PresenceAvatarStack users={activeUsers} maxVisible={5} />
  </div>

  <!-- Chat interface -->
  <StandardStreamingChat {chatStore} />

  <!-- Typing indicator -->
  {#if typingUsers.length > 0}
    <TypingIndicator users={typingUsers} />
  {/if}

  <!-- Connection status -->
  <div class="connection-status">
    {$chatStore.connection.status}
    {#if $chatStore.connection.status === 'connected'}
      <span class="indicator active"></span>
    {:else}
      <span class="indicator inactive"></span>
    {/if}
  </div>
</div>
```

---

## WEBSOCKET MANAGER

**Purpose**: Low-level WebSocket management for custom implementations.

### API

```typescript
import {
  WebSocketManager,
  createWebSocketManager,
  type WebSocketConfig
} from '@composable-svelte/chat';

const config: WebSocketConfig = {
  url: 'wss://api.example.com/chat',
  reconnect: true,
  reconnectInterval: 1000,
  maxReconnectAttempts: 10,
  heartbeatInterval: 30000
};

const manager = createWebSocketManager(config);

// Connect
manager.connect();

// Send message
manager.send({ type: 'message', content: 'Hello' });

// Listen for messages
manager.onMessage((message) => {
  console.log('Received:', message);
});

// Listen for connection changes
manager.onConnectionChange((state) => {
  console.log('Connection:', state.status);
});

// Disconnect
manager.disconnect();
```

---

## MOCK UTILITIES

**Purpose**: Testing and development without backend.

```typescript
import { createMockStreamingChat } from '@composable-svelte/chat';

const chatStore = createStore({
  initialState: createInitialStreamingChatState(),
  reducer: streamingChatReducer,
  dependencies: createMockStreamingChat({
    responseDelay: 50,      // Delay between chunks (ms)
    mockResponses: [
      'This is a mock response.',
      'It simulates streaming behavior.'
    ]
  })
});
```

---

## COMPONENT SELECTION GUIDE

**When to use each variant**:

**MinimalStreamingChat**:
- Embedded chat
- Minimal UI needed
- Custom chrome/header

**StandardStreamingChat** (recommended):
- Most use cases
- Balanced features
- Good defaults

**FullStreamingChat**:
- Feature-rich chat app
- Need reactions
- Need attachments
- Need voice input

**Collaborative Features**:
- Multi-user chat
- Team collaboration
- Need presence/typing
- Real-time sync required

---

## CROSS-REFERENCES

**Related Skills**:
- **composable-svelte-core**: Store, reducer, Effect system
- **composable-svelte-media**: VoiceInput (can integrate with chat)
- **composable-svelte-code**: Syntax highlighting in messages
- **composable-svelte-components**: UI components

**When to Use Each Package**:
- **chat**: Real-time chat, streaming responses, LLM interfaces
- **media**: Audio players, video embeds, standalone voice input
- **code**: Code editors, syntax highlighting
- **core**: Base architecture (Store, reducer, effects)

---

## TESTING PATTERNS

### StreamingChat Testing

```typescript
import { TestStore } from '@composable-svelte/core';
import {
  streamingChatReducer,
  createInitialStreamingChatState,
  createMockStreamingChat
} from '@composable-svelte/chat';

const store = new TestStore({
  initialState: createInitialStreamingChatState(),
  reducer: streamingChatReducer,
  dependencies: createMockStreamingChat()
});

// Test message send
await store.send({
  type: 'sendMessage',
  content: 'Hello',
  attachments: []
});

await store.receive({ type: 'streamingStarted' }, (state) => {
  expect(state.isStreaming).toBe(true);
});

await store.receive({ type: 'streamingChunk', chunk: 'Hi' }, (state) => {
  expect(state.streamingMessage).toBe('Hi');
});

await store.receive({ type: 'streamingCompleted' }, (state) => {
  expect(state.isStreaming).toBe(false);
  expect(state.messages.length).toBe(2); // User + assistant
});
```

### Collaborative Testing

```typescript
import { TestStore } from '@composable-svelte/core';
import {
  collaborativeReducer,
  createInitialCollaborativeState
} from '@composable-svelte/chat';

const store = new TestStore({
  initialState: createInitialCollaborativeState(),
  reducer: collaborativeReducer,
  dependencies: {
    sendMessage: async function*() {
      yield 'Test response';
    },
    connectWebSocket: vi.fn(),
    sendWebSocketMessage: vi.fn()
  }
});

// Test user join
await store.send({
  type: 'userJoined',
  user: {
    id: 'user-2',
    name: 'Alice',
    color: '#3b82f6',
    presence: 'active'
  }
}, (state) => {
  expect(state.users.size).toBe(1);
  expect(state.users.get('user-2')?.name).toBe('Alice');
});

// Test typing indicator
await store.send({
  type: 'userStartedTyping',
  userId: 'user-2',
  info: {
    target: 'message',
    startedAt: Date.now(),
    lastUpdate: Date.now()
  }
}, (state) => {
  expect(state.users.get('user-2')?.typing).toBeTruthy();
});
```

---

## TROUBLESHOOTING

**Streaming not working**:
- Check sendMessage generator function returns AsyncGenerator
- Verify yield statements send string chunks
- Ensure signal.aborted is checked for cancellation
- Check network tab for response streaming

**WebSocket connection failing**:
- Verify WebSocket URL (wss:// for HTTPS, ws:// for HTTP)
- Check CORS/authentication headers
- Ensure reconnect logic is enabled
- Check browser console for errors

**Markdown not rendering**:
- Verify message content is valid markdown
- Check syntax highlighting CSS is loaded
- Ensure code blocks use supported languages

**Collaborative features not syncing**:
- Verify WebSocket connection is active
- Check message format matches expected schema
- Ensure user IDs are unique and consistent
- Check heartbeat/presence update intervals
