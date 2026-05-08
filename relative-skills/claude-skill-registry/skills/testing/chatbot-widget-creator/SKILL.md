---
name: chatbot-widget-creator
description: Creates a battle-tested ChatGPT-style chatbot widget that solves real-world production issues. Features infinite re-render protection, text selection "Ask AI", RAG backend integration, streaming SSE, and comprehensive performance monitoring.
category: frontend
version: 3.2.0
date_updated: 2025-12-07
---

# Chatbot Widget Creator Skill

## Purpose

Creates a **production-ready ChatGPT-style chatbot widget** with advanced features:
- **Custom Portrait Layout**: Compact 380px x 700px styling matching ChatGPT aesthetics
- **Infinite re-render protection** using useReducer and split context pattern
- **Text selection "Ask AI"** functionality with smart tooltips
- **Streaming responses** with Server-Sent Events (SSE)
- **RAG backend integration** ready for FastAPI/Qdrant setup
- **Performance monitoring** and debugging utilities
- **Modern glassmorphic UI** with ChatGPT-style interface

## Key Improvements Based on Real Implementation

### 1. **Refined UI/UX**
- **Compact Dimensions**: 380px width x 700px height for optimal sidebar integration
- **Clean Message UI**: Removed timestamps, read receipts, and file uploads for a cleaner reading experience
- **Themed Integration**: Dynamically uses `var(--ifm-color-primary)` to match host site branding
- **Bottom Alignment**: Message bubbles and avatars are bottom-aligned for a modern chat look
- **Minimalist Indicators**: Simplified 3-dot pulsing animation for thinking state

### 2. **State Management Architecture**
- **useReducer pattern** instead of multiple useState hooks
- **Split context** (StateContext + ActionsContext) to prevent unnecessary re-renders
- **Stable callbacks** with proper dependencies to avoid circular references
- **AbortController** for proper cleanup of streaming connections

### 3. **Performance Optimizations**
- **React.memo** wrapping for expensive components like `MessageBubble`
- **useMemo** for computed values and complex operations
- **useCallback** with stable dependencies
- **Render counter utilities** for debugging
- **Virtualization** support for long conversations (50+ messages)

### 4. **Text Selection Feature**
- **useTextSelection** hook for detecting text selections
- **Smart positioning tooltip** with edge detection
- **Context-aware prompts** when asking about selected text
- **Length validation** with truncation warnings

## Prerequisites

1. **Backend Requirements**:
   - FastAPI or similar with SSE support
   - Endpoint: `POST /api/chat` returning Server-Sent Events
   - Request format: `{ "question": string, "stream": boolean }`
   - Response format: SSE with `{ "type": "chunk", "content": string }`

2. **Frontend Dependencies**:
   ```bash
   npm install react framer-motion react-markdown react-syntax-highlighter remark-gfm lucide-react clsx tailwind-merge
   # Note: No ChatKit dependency - this is a custom implementation
   ```

## Quick Start

### 1. Create the Widget Structure

```bash
# Create main directory structure
mkdir -p src/components/ChatWidget/{components,hooks,contexts,utils,styles}

# Copy all template files
cp -r .claude/skills/chatbot-widget-creator/templates/* src/components/ChatWidget/
```

### 2. Backend API Requirements

Your backend must implement:

```python
@app.post("/api/chat")
async def chat_endpoint(request: ChatRequest):
    """Chat endpoint with Server-Sent Events streaming."""

    # Request format
    {
        "question": "What is physical AI?",
        "stream": true,
        "context": {  # Optional
            "selectedText": "...",
            "source": "User selection"
        }
    }

    # Response format (SSE)
    data: {"type": "start", "session_id": "..."}
    data: {"type": "chunk", "content": "Physical AI refers to..."}
    data: {"type": "chunk", "content": "embodied AI systems..."}
    data: {"type": "done", "session_id": "..."}
```

### 3. Integration

Add to your site root (e.g., `src/theme/Root.tsx`):

```tsx
import React from 'react';
import AnimatedChatWidget from '../components/ChatWidget/components/AnimatedChatWidget';

export default function Root({ children }) {
  const getChatEndpoint = () => {
    const hostname = window.location.hostname;
    if (hostname === 'localhost') {
      return 'http://localhost:7860/api/chat';
    }
    return 'https://your-domain.com/api/chat';
  };

  return (
    <>
      {children}
      <AnimatedChatWidget
        apiUrl={getChatEndpoint()}
        maxTextSelectionLength={2000}
        fallbackTextLength={5000}
      />
    </>
  );
}
```

## Architecture Details

### State Management (Critical for Performance)

```typescript
// Consolidated state to prevent fragmentation
interface ChatState {
  messages: ChatMessage[];
  isOpen: boolean;
  isThinking: boolean;
  currentStreamingId?: string;
  error: Error | null;
  renderCount: number;
}

// Split context pattern
const ChatStateContext = createContext<{ state: ChatState }>();
const ChatActionsContext = createContext<{ actions: ChatActions }>();

// Components only subscribe to what they need
const messages = useChatSelector(s => s.messages);  // Re-renders on messages change
const actions = useChatActions();                   // Never re-renders
```

### Key Anti-Patterns Avoided

1. **❌ Multiple useState hooks**:
   ```typescript
   // Bad - causes context fragmentation
   const [messages, setMessages] = useState([]);
   const [isOpen, setIsOpen] = useState(false);
   ```

2. **✅ Consolidated useReducer**:
   ```typescript
   // Good - single state source
   const [state, dispatch] = useReducer(chatReducer, initialState);
   ```

3. **❌ Circular dependencies**:
   ```typescript
   // Bad - callback depends on state that changes
   const handleChunk = useCallback((chunk) => {
     if (session.currentStreamingId) {  // Dependency on state
       updateMessage(session.currentStreamingId, chunk);
     }
   }, [session.currentStreamingId]); // Infinite re-render!
   ```

4. **✅ Stable references**:
   ```typescript
   // Good - no circular dependencies
   const streamingIdRef = useRef<string>();
   const handleChunk = useCallback((chunk) => {
     if (streamingIdRef.current) {
       dispatch(updateStreamingAction(streamingIdRef.current, chunk));
     }
   }, [dispatch]); // Stable dependency array
   ```

### Streaming Response Handling

```typescript
// Proper SSE parsing
const lines = chunk.split('\n');
for (const line of lines) {
  if (line.startsWith('data: ')) {
    const data = line.slice(6);
    if (data !== '[DONE]') {
      const parsed = JSON.parse(data);

      if (parsed.type === 'chunk' && parsed.content) {
        handleChunk(parsed.content);
      } else if (parsed.type === 'done') {
        handleComplete();
      }
    }
  }
}
```

## Customization Guide

### Theming

Edit `src/components/ChatWidget/styles/ChatWidget.module.css`:

```css
/* Primary colors */
.widget {
  background: #171717; /* Dark mode background */
  width: 380px;
  height: 700px;
}

/* Message bubbles */
.userMessageBubble {
  background: var(--ifm-color-primary); /* Theme integration */
  color: white;
}

.aiMessageBubble {
  background: #21262d;
  border: 1px solid #30363d;
}
```

## Component Reference

### Core Components

1. **AnimatedChatWidget**: Main entry point with animations
2. **ChatInterface**: ChatGPT-style UI container
3. **MessageBubble**: Individual message display (React.memo optimized)
4. **InputArea**: Message input (No file upload)
5. **SelectionTooltip**: Text selection "Ask AI" tooltip
6. **ThinkingIndicator**: Minimalist 3-dot pulsing animation

### Hooks

1. **useChatSession**: Access chat state and actions
2. **useStreamingResponse**: Handle SSE connections
3. **useTextSelection**: Detect and handle text selection
4. **useErrorHandler**: Centralized error management

### Utilities

1. **chatReducer**: State transitions
2. **api.ts**: API request/response formatting
3. **animations.ts**: Framer Motion configs

## Troubleshooting

### Common Issues and Solutions

1. **Infinite Re-renders**
   - Check for circular dependencies in useCallback
   - Ensure split context pattern is properly implemented
   - Use React DevTools Profiler to identify causes

2. **Memory Leaks**
   - Ensure AbortController cleanup on unmount
   - Check for unclosed SSE connections
   - Monitor with `window.performance.memory`

3. **SSE Not Working**
   - Verify CORS headers include `text/event-stream`
   - Check that responses use correct `data: {}` format
   - Ensure `Cache-Control: no-cache` is set
   - **Crucial**: Ensure your API request includes `stream: true` in the body
   - Extract content correctly: `handleChunk(JSON.parse(data).content)` not the raw string

4. **Text Selection Issues**
   - Verify `useTextSelection` is enabled
   - Check for CSS `user-select: none` conflicts
   - Ensure z-index is high enough for tooltip

5. **Markdown Rendering & Layout Issues**
   - **List Numbers on Separate Lines**: 
     - Set `list-style-position: inside` on `ul`/`ol`
     - Reset `p` margins in lists: `li > p { margin: 0; display: inline; }`
   - **Invisible Text in Light Mode**:
     - Explicitly define text colors for `.messageRenderer`, headings, and lists in light mode media queries or classes
     - Ensure `.aiMessageBubble` background is transparent or correctly colored
   - **Excessive Spacing**:
     - Reduce margins on `p`, `ul`, `ol` (e.g., `0.25rem`)
     - Remove margins from first/last children: `.messageRenderer > *:first-child { margin-top: 0; }`
     - Use `!important` if global site styles (like Docusaurus) override your chat styles
   - **Avatar Alignment**:
     - Use CSS Grid for message layout to align avatar with the bottom of the text
     - Example: `.aiMessage { display: grid; align-items: end; }`

## Production Checklist

- [ ] Remove console.log statements in production
- [ ] Add proper error tracking (Sentry, etc.)
- [ ] Implement rate limiting on backend
- [ ] Add CORS configuration
- [ ] Test on slow networks
- [ ] Verify memory leak prevention
- [ ] Test with long conversations (100+ messages)

## Result

A production-ready chat widget that:
- Matches the ChatGPT visual aesthetic
- Never crashes from infinite re-renders
- Provides smooth text selection interactions
- Streams responses efficiently
- Maintains performance over time
- Handles all edge cases gracefully
