---
name: collect-selector
description: Use this skill to determine the correct data-testid selector for Playwright or end-to-end tests. 
---

# Collect Selector

## Purpose
Determine the correct `data-testid` for a UI component following a strict priority order.

## Logic to collect data-testid
1. Priority 1: playwrightId
   - If component has playwrightId="some-value"
   - Use in test: [data-testid="some-value"]
   - Example: <Button playwrightId="submit-btn"> → test uses [data-testid="submit-btn"]
2. Priority 2: data-testid
   - If component has data-testid="some-value" (and no playwrightId)
   - Use in test: [data-testid="some-value"]
   - Example: <Button data-testid="submit-btn"> → test uses [data-testid="submit-btn"]
3. Priority 3: Text Content
   - If no playwrightId or data-testid exists
   - Use in test: element's visible text
   - Example: <Button>Submit Form</Button> → test uses text="Submit Form"
4. Priority 4: Auto create playwrightId
   - If nothing above exists please add playwrightId using relevant value for the component
Simple Summary:
// Component has playwrightId:
<Component playwrightId="my-element" />
// Test uses:
[data-testid="my-element"]
// Component has only data-testid:
<Component data-testid="my-element" />
// Test uses:
[data-testid="my-element"]

Key Rule: Always use [data-testid="..."] in tests, whether the component has playwrightId or data-testid!

## Output Format
Return a simple string containing the resolved `data-testid` value.

If no match is found, return: `"undefined-testid"`
