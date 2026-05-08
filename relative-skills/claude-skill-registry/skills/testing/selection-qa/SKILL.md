---
name: Selection Q&A
description: Add selection-based Q&A functionality to ChatKit UI allowing users to ask about highlighted text with proper integration.
---

# Selection Q&A

## Instructions

1. Implement text selection detection:
   - Add event listeners for text selection
   - Capture selected text content
   - Determine selection boundaries
   - Handle multiple selection scenarios

2. Create "Ask About Selection" interface:
   - Add contextual button/menu for selections
   - Position UI element appropriately
   - Style button consistently with theme
   - Handle mobile vs desktop differences

3. Integrate with backend Q&A:
   - Send selection context to POST /chat endpoint
   - Include selection as additional context
   - Format request properly with main query
   - Handle response integration

4. Display results appropriately:
   - Show backend answer with selection context
   - Include proper citation of sources
   - Maintain conversation flow
   - Handle error cases gracefully

5. Follow Context7 MCP documentation:
   - Follow ChatKit component architecture
   - Use deterministic patch protocols
   - Include proper error handling
   - Maintain existing functionality

## Examples

Input: "Add selection-based Q&A to ChatKit"
Output: Patches UI files to add text selection detection and contextual Q&A functionality.