---
name: send-message
description: Send messages via Sinch Conversation API over WhatsApp, SMS, RCS, Messenger, Viber, Instagram, Telegram, and other channels. Use when the user wants to send a message, text someone, send a WhatsApp message, send an SMS, or communicate via any messaging channel. Automatically handles contact creation and conversation management.
---

# Send Message

Send messages through Sinch Conversation API. Prefer MCP tools if available, otherwise use the Conversation API specification. Supports all channels including WhatsApp, SMS, RCS, Messenger, Viber, Instagram, Telegram, LINE, WeChat, KakaoTalk, and Apple Messages for Business.

## Instructions

1. **Extract message details from user request:**
   - Recipient: phone number, contact name, or contact ID
   - Message content: text to send
   - Channel preference: WhatsApp, SMS, or other (if specified)
   - Message type: text, media, location, choice, or template
   - If channel not specified, use WhatsApp as default for phone numbers

2. **Check MCP availability and use appropriate method:**

   **Option A: Use MCP tools (if MCP Sinch is configured):**
   - First check if MCP Sinch server is available (check MCP server configuration)
   - If MCP is available, use the appropriate MCP tool:
     - `send-text-message` for text messages
     - `send-media-message` for media messages (images, videos, etc.)
     - `send-location-message` for location messages
     - `send-choice-message` for interactive choice messages
     - `send-template-message` for template messages
   - MCP tools handle authentication automatically via environment variables
   - If MCP tool execution fails or MCP is not configured, fallback to Option B

   **Option B: Use Conversation API endpoint (fallback if MCP not available):**
   - Endpoint: `POST /v1/projects/{project_id}/messages:send`
   - Operation ID: `Messages_SendMessage`
   - Authentication: Use Basic Auth or OAuth2 with credentials from environment variables (CONVERSATION_PROJECT_ID, CONVERSATION_KEY_ID, CONVERSATION_KEY_SECRET)
   - Region: Use CONVERSATION_REGION environment variable (us, eu, or br)
   - Base URL: `https://{region}.conversation.api.sinch.com`
   - The API will automatically:
     - Create a contact if the recipient doesn't exist
     - Start a conversation if one doesn't exist
     - Send the message via the specified channel

3. **Message format:**
   - For text messages: Use `text_message` with the message content
   - For template messages: Use `template_message` with template_id and parameters
   - Channel is determined from user request or defaults to WhatsApp

4. **Response handling:**
   - Confirm successful message send with message ID
   - Report any errors clearly
   - If channel is not available, suggest alternatives

## Examples

**Natural language prompts that trigger this Skill:**
- "Send a WhatsApp message to John saying 'Meeting at 3 PM'"
- "Text Alice that I'll be late"
- "Send SMS to +1234567890 with message 'Your order is ready'"
- "Message Bob on WhatsApp: 'Thanks for the update'"
- "Send a message to contact ID abc123 saying 'Hello'"

**MCP Tool Usage (Preferred if available):**
1. Check if MCP Sinch server is configured (MCP server settings)
2. Use appropriate MCP tool based on message type:
   - `send-text-message` for text messages
   - `send-media-message` for media (requires `url` parameter)
   - `send-location-message` for location (requires `address` parameter)
   - `send-choice-message` for interactive choices (requires `choiceContent` array)
   - `send-template-message` for templates (requires `templateId` or `whatsAppTemplateName`)
3. MCP tools automatically use credentials from environment variables
4. If MCP is not available or tool execution fails, fallback to Conversation API

**Conversation API Usage (Fallback):**
1. Use the Conversation API endpoint: `POST /v1/projects/{project_id}/messages:send`
2. Authentication: Use Basic Auth with CONVERSATION_KEY_ID and CONVERSATION_KEY_SECRET, or OAuth2
3. Include required headers: `Authorization`, `Content-Type: application/json`
4. Request body should include: `app_id` (from CONVERSATION_APP_ID), `recipient`, `message` (with appropriate message type), and optional `channel_priority_order`

## Channel Support

Supported channels:
- **WHATSAPP**: WhatsApp Business messages
- **SMS**: SMS text messages
- **RCS**: Rich Communication Services
- **MESSENGER**: Facebook Messenger
- **VIBERBM**: Viber Business Messages
- **INSTAGRAM**: Instagram Direct Messages
- **TELEGRAM**: Telegram messages
- **LINE**: LINE messages
- **WECHAT**: WeChat messages
- **KAKAOTALK**: KakaoTalk messages
- **APPLEBC**: Apple Messages for Business

## Notes

- **Prefer MCP tools** if MCP Sinch is configured - they provide a simpler interface and handle authentication automatically
- **Fallback to Conversation API** if MCP is not configured or MCP tool execution fails
- Recipients can be identified by phone number (with country code), contact ID, or contact name
- If a contact doesn't exist, one will be created automatically
- Messages are added to existing conversations or new conversations are created automatically
- For MCP: Use the appropriate tool based on message type (text, media, location, choice, template)
- For Conversation API: Use `text_message` for text, `template_message` with `template_id` for templates
- Channel can be specified in `channel_priority_order` or determined automatically

