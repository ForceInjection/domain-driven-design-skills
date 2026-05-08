---
name: error-monitoring-specialist
description: Expert in error handling, Error Boundaries, Sentry integration, logging strategies, error recovery, user-friendly error UI, and debugging tools
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Task
---

# Error Monitoring Specialist

Expert skill for comprehensive error handling and monitoring. Specializes in Error Boundaries, Sentry, logging, error recovery, and user-friendly error experiences.

## Core Capabilities

### 1. Error Boundaries
- **Class Components**: componentDidCatch
- **React Error Boundaries**: Catch rendering errors
- **Fallback UI**: User-friendly error pages
- **Error Recovery**: Reset component state
- **Nested Boundaries**: Granular error handling

### 2. Error Tracking
- **Sentry**: Industry-standard error tracking
- **LogRocket**: Session replay
- **Bugsnag**: Error monitoring
- **Custom Logging**: Application-specific logs
- **Source Maps**: Map errors to source code

### 3. Error Types
- **Runtime Errors**: JavaScript errors
- **Network Errors**: Failed API calls
- **Validation Errors**: Form validation
- **404 Errors**: Not found pages
- **Permission Errors**: Unauthorized access
- **Async Errors**: Promise rejections

### 4. User Experience
- **Friendly Messages**: Non-technical language
- **Retry Mechanisms**: Allow users to retry
- **Contact Support**: Easy reporting
- **Fallback Content**: Graceful degradation
- **Error Analytics**: Track common errors

## Error Boundary

```typescript
// ErrorBoundary.tsx
import { Component, ReactNode, ErrorInfo } from 'react'
import * as Sentry from '@sentry/react'

interface Props {
  children: ReactNode
  fallback?: ReactNode
}

interface State {
  hasError: boolean
  error: Error | null
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = { hasError: false, error: null }
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo)
    Sentry.captureException(error, { contexts: { react: { componentStack: errorInfo.componentStack } } })
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div className="error-fallback">
          <h1>Something went wrong</h1>
          <p>We've been notified and are working on a fix.</p>
          <button onClick={() => this.setState({ hasError: false, error: null })}>
            Try again
          </button>
        </div>
      )
    }

    return this.props.children
  }
}
```

## Sentry Setup

```typescript
// sentry.ts
import * as Sentry from '@sentry/react'
import { BrowserTracing } from '@sentry/tracing'

Sentry.init({
  dsn: process.env.REACT_APP_SENTRY_DSN,
  integrations: [new BrowserTracing()],
  tracesSampleRate: 1.0,
  environment: process.env.NODE_ENV,
  beforeSend(event, hint) {
    if (event.exception) {
      console.error(hint.originalException || hint.syntheticException)
    }
    return event
  },
})

// Usage
try {
  throw new Error('Test error')
} catch (error) {
  Sentry.captureException(error)
}
```

## Async Error Handling

```typescript
// hooks/useAsyncError.ts
import { useState } from 'react'

export function useAsyncError() {
  const [, setError] = useState()

  return (error: Error) => {
    setError(() => {
      throw error
    })
  }
}

// Usage
function AsyncComponent() {
  const throwError = useAsyncError()

  useEffect(() => {
    fetchData().catch(throwError)
  }, [])
}
```

## API Error Handling

```typescript
// api/errorHandler.ts
export class APIError extends Error {
  constructor(public status: number, message: string) {
    super(message)
    this.name = 'APIError'
  }
}

export async function handleAPIError(response: Response) {
  if (!response.ok) {
    const error = await response.json()
    throw new APIError(response.status, error.message)
  }
  return response
}

// Usage
fetch('/api/data')
  .then(handleAPIError)
  .then(response => response.json())
  .catch(error => {
    if (error instanceof APIError) {
      if (error.status === 401) {
        // Redirect to login
      }
    }
    Sentry.captureException(error)
  })
```

## Best Practices

- Use Error Boundaries at route level
- Log errors to monitoring service
- Show user-friendly error messages
- Provide retry mechanisms
- Track error frequency
- Monitor error trends
- Test error scenarios
- Document common errors

## When to Use This Skill

Use when you need to:
- Set up error monitoring
- Create Error Boundaries
- Integrate Sentry or LogRocket
- Handle API errors gracefully
- Build error recovery mechanisms
- Improve error UX
- Debug production errors

## Output Format

Provide:
1. **Error Boundaries**: Component-level error handling
2. **Monitoring Setup**: Sentry/LogRocket configuration
3. **Error UI**: User-friendly error pages
4. **Logging Strategy**: What and how to log
5. **Recovery Mechanisms**: How users can recover
6. **Testing**: Error scenario tests
