---
name: memory-playbook
description: Cross-session persistence for user preferences, implementation guide for Memory feature.
---

# Memory Skill

## When to Use
- Questions about remembering across sessions
- "What if user comes back tomorrow?"
- Cross-conversation persistence
- User profile/preference storage
- Long-term relationship building with users

## Key Feature: Memory

Memory lets Claude remember information across separate conversations.

### Core Capabilities
1. **Cross-session persistence**: Remember user context between visits
2. **Structured storage**: Organize memories by category
3. **Selective recall**: Retrieve relevant memories for each conversation
4. **Privacy controls**: User-managed memory deletion

### Memory vs Context Editing

| Feature | Context Editing | Memory |
|---------|-----------------|--------|
| Scope | Within one conversation | Across conversations |
| Lifetime | Session | Persistent |
| Use case | Long single chats | Returning users |

### Common Use Cases

1. **User preferences**: "John prefers dark mode, uses metric units"
2. **Past interactions**: "Last discussed budget concerns on Dec 1"
3. **Workflow state**: "User is in step 3 of onboarding"
4. **Relationship context**: "Enterprise customer, technical buyer"

## Response Guidelines

1. **Clarify the need**: Within-session or cross-session?
2. **If cross-session**: Recommend Memory
3. **If within-session**: Context Editing is sufficient
4. **Combine both**: For power users, use both together
