---
name: list-messages
description: Retrieve and display message history from Sinch Conversation API. Use when the user asks to show messages, view conversation history, list recent messages, see messages with a contact, check message history, or view last N messages. Supports filtering by contact, conversation, channel, and time range.
---

# List Messages

Retrieve message history from Sinch Conversation API using the Conversation API specification. Note: MCP tools do not provide a list messages tool, so this skill always uses the Conversation API endpoint. Supports filtering by contact, conversation, channel, and time range.

## Instructions

1. **Extract query parameters from user request:**
   - Contact: contact ID, phone number, or contact name
   - Conversation: conversation ID (if specified)
   - Channel: WhatsApp, SMS, or other channel filter
   - Count: number of messages to retrieve (default: 10, max: 1000)
   - Time range: start_time and end_time if specified

2. **Use Conversation API endpoint to list messages:**
   - **Note**: MCP Sinch does not provide a list messages tool, so this skill always uses the Conversation API endpoint
   - Endpoint: `GET /v1/projects/{project_id}/messages`
   - Operation ID: `Messages_ListMessages`
   - Authentication: Use Basic Auth or OAuth2 with credentials from environment variables (CONVERSATION_PROJECT_ID, CONVERSATION_KEY_ID, CONVERSATION_KEY_SECRET)
   - Region: Use CONVERSATION_REGION environment variable (us, eu, or br)
   - Base URL: `https://{region}.conversation.api.sinch.com`
   - Apply filters based on extracted parameters as query parameters
   - Messages are returned in descending order by accept_time (most recent first)

3. **Response formatting:**
   - Display messages in chronological order (oldest to newest for readability)
   - Include: message ID, timestamp, sender/recipient, channel, message content
   - Show conversation context if available
   - Indicate if there are more messages (pagination using page_token)

## Examples

**Natural language prompts that trigger this Skill:**
- "Show me the last 5 messages with Alice"
- "What messages did I receive from John?"
- "List recent WhatsApp messages"
- "Show conversation history with contact ID abc123"
- "Display messages from the last hour"
- "What are the last 10 messages?"

**Conversation API Usage (Required - no MCP alternative):**
1. **Note**: MCP Sinch does not provide a list messages tool, so this skill always uses the Conversation API
2. Use the Conversation API endpoint: `GET /v1/projects/{project_id}/messages`
3. Authentication: Use Basic Auth with CONVERSATION_KEY_ID and CONVERSATION_KEY_SECRET, or OAuth2
4. Include required headers: `Authorization`, `Content-Type: application/json`
5. Use query parameters for filtering: `contact_id`, `conversation_id`, `channel`, `start_time`, `end_time`, `page_size`, `page_token`, `app_id`, `channel_identity`, `messages_source`, `only_recipient_originated`, `view`

## Filtering Options

- **By contact**: Filter messages for a specific contact
- **By conversation**: Filter messages in a specific conversation
- **By channel**: Filter messages by channel (WHATSAPP, SMS, etc.)
- **By time range**: Filter messages between start_time and end_time
- **By app**: Filter messages for a specific app ID
- **Pagination**: Use page_size (default 10, max 1000) and page_token for pagination

## Message View Options

- **FULL**: Complete message details (default)
- **BASIC**: Basic message information

## Notes

- **MCP Note**: MCP Sinch does not provide a list messages tool, so this skill always uses the Conversation API endpoint
- Messages are ordered by accept_time in descending order (most recent first)
- Use the Conversation API endpoint directly - reference the OpenAPI spec for exact parameter names and types
- If no messages found, inform the user clearly
- Support pagination for large message lists using `page_token` from response
- The `messages_source` parameter determines processing mode: `CONVERSATION_SOURCE` for CONVERSATION mode, `DISPATCH_SOURCE` for DISPATCH mode
- Some query parameters may not be supported depending on the `messages_source` value - check the API spec for details

