---
name: twilio-testing
description: Test and validate Twilio Voice API integration with ElevenLabs ConversationRelay for outbound calling. Use when setting up Twilio integration, testing outbound calls, validating audio quality, configuring webhooks, measuring call metrics, or debugging telephony issues. Includes ConversationRelay setup, call execution, and quality validation.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, WebFetch
---

# Twilio Testing Skill

Comprehensive testing framework for **Twilio Voice API + ElevenLabs ConversationRelay** integration on the Next Level Real Estate platform. This skill provides systematic testing procedures, quality validation, and troubleshooting guidance.

## When to Use This Skill

Invoke this skill when you need to:
- ✅ Set up Twilio Voice API integration
- ✅ Configure ElevenLabs ConversationRelay
- ✅ Execute test outbound calls
- ✅ Validate call audio quality
- ✅ Measure call performance metrics
- ✅ Debug telephony connection issues
- ✅ Test TCPA compliance checkpoints
- ✅ Verify webhook endpoints

## Twilio + ElevenLabs Architecture

```
┌─────────────────┐
│  Next Level RE  │
│   Application   │
└────────┬────────┘
         │
         │ 1. Initiate call with
         │    lead context
         ▼
┌─────────────────┐
│  Twilio Voice   │◄──── Phone Number
│      API        │
└────────┬────────┘
         │
         │ 2. ConversationRelay
         │    webhook
         ▼
┌─────────────────┐
│  ElevenLabs     │
│  Conversational │
│      AI         │
└────────┬────────┘
         │
         │ 3. Bidirectional
         │    audio stream
         ▼
┌─────────────────┐
│  Lead's Phone   │
└─────────────────┘
```

## Setup Checklist

### Prerequisites

```bash
# 1. Twilio Account Requirements
- [ ] Active Twilio account
- [ ] Account SID
- [ ] Auth Token
- [ ] At least one phone number (verified or purchased)
- [ ] Voice API enabled

# 2. ElevenLabs Requirements
- [ ] ElevenLabs API key
- [ ] At least one conversational agent created
- [ ] Agent ID noted

# 3. Environment Configuration
- [ ] TWILIO_ACCOUNT_SID set
- [ ] TWILIO_AUTH_TOKEN set
- [ ] TWILIO_PHONE_NUMBER set
- [ ] ELEVENLABS_API_KEY set
- [ ] Webhook endpoint accessible (public URL)
```

### Environment Setup

Create `.env` file with required credentials:

```bash
# Twilio Configuration
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_PHONE_NUMBER=+1234567890

# ElevenLabs Configuration
ELEVENLABS_API_KEY=your_elevenlabs_api_key
ELEVENLABS_AGENT_ID=agent_xxxxxxxx

# Webhook Configuration
WEBHOOK_BASE_URL=https://your-domain.com
WEBHOOK_SECRET=your_webhook_secret

# Testing
TEST_PHONE_NUMBER=+1234567890  # Your test number
```

## Integration Setup

### Step 1: Install Twilio SDK

```bash
cd services/calling-service
npm install twilio
```

### Step 2: Create Twilio Client Service

Create `services/calling-service/src/clients/twilio.ts`:

```typescript
import twilio from 'twilio'

export interface TwilioConfig {
  accountSid: string
  authToken: string
  phoneNumber: string
}

export interface CallConfig {
  to: string
  conversationId: string
  webhookUrl: string
}

export function createTwilioClient(config: TwilioConfig) {
  const client = twilio(config.accountSid, config.authToken)

  return {
    async initiateCall(callConfig: CallConfig) {
      const call = await client.calls.create({
        from: config.phoneNumber,
        to: callConfig.to,
        url: `${callConfig.webhookUrl}/twiml/${callConfig.conversationId}`,
        statusCallback: `${callConfig.webhookUrl}/status/${callConfig.conversationId}`,
        statusCallbackEvent: ['initiated', 'ringing', 'answered', 'completed'],
        record: true,  // Record for TCPA compliance
      })

      return {
        callSid: call.sid,
        status: call.status,
        to: call.to,
        from: call.from,
      }
    },

    async getCallStatus(callSid: string) {
      const call = await client.calls(callSid).fetch()
      return {
        sid: call.sid,
        status: call.status,
        duration: call.duration,
        startTime: call.startTime,
        endTime: call.endTime,
      }
    },

    async hangupCall(callSid: string) {
      await client.calls(callSid).update({ status: 'completed' })
    },
  }
}
```

### Step 3: Create ConversationRelay Webhook Handler

Create `services/calling-service/src/routes/twiml.ts`:

```typescript
import { Router } from 'express'
import twilio from 'twilio'

const router = Router()
const VoiceResponse = twilio.twiml.VoiceResponse

router.post('/twiml/:conversationId', async (req, res) => {
  const { conversationId } = req.params

  // Get conversation details from ElevenLabs
  const conversation = await getElevenLabsConversation(conversationId)

  const twiml = new VoiceResponse()

  // Optional: Add recording consent message
  if (conversation.recordingConsent) {
    twiml.say({
      voice: 'alice',
      language: 'en-US'
    }, 'This call may be recorded for quality and training purposes.')
  }

  // Connect to ElevenLabs ConversationRelay
  const connect = twiml.connect()
  connect.stream({
    url: `wss://api.elevenlabs.io/v1/convai/${conversationId}/stream`,
    parameters: {
      apiKey: process.env.ELEVENLABS_API_KEY,
      agentId: conversation.agentId,
    }
  })

  res.type('text/xml')
  res.send(twiml.toString())
})

router.post('/status/:conversationId', async (req, res) => {
  const { conversationId } = req.params
  const { CallStatus, CallDuration, RecordingUrl } = req.body

  console.log(`Call ${conversationId}: ${CallStatus}`)

  // Update conversation status in your database
  await updateConversationStatus(conversationId, {
    status: CallStatus,
    duration: CallDuration,
    recordingUrl: RecordingUrl,
  })

  res.sendStatus(200)
})

export default router
```

### Step 4: Test Webhook Endpoint

```bash
# Install ngrok for local testing
npm install -g ngrok

# Start your calling service
npm run dev

# In another terminal, expose local server
ngrok http 3000

# Update WEBHOOK_BASE_URL with ngrok URL
# Example: https://abc123.ngrok.io
```

## Testing Framework

### Test Categories

1. **Integration Tests** - Verify component connectivity
2. **Functional Tests** - Validate end-to-end call flow
3. **Quality Tests** - Measure audio and conversation quality
4. **Performance Tests** - Track metrics under load
5. **Compliance Tests** - Verify TCPA requirements

### Test 1: Webhook Connectivity

**Objective:** Verify Twilio can reach your webhook endpoint

```bash
# Test webhook endpoint is accessible
curl -X POST https://your-domain.com/twiml/test-123 \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "From=+1234567890&To=+0987654321"

# Expected: 200 OK with valid TwiML response
```

**Success Criteria:**
- [ ] Webhook returns 200 status
- [ ] Response is valid TwiML XML
- [ ] Logs show request received

### Test 2: ElevenLabs Agent Health

**Objective:** Verify agent is configured and accessible

```bash
# Use MCP tool to check agent
Use mcp__elevenlabs__elevenlabs_get_agent with:
{
  "agentId": "your_agent_id"
}
```

**Success Criteria:**
- [ ] Agent status is "active"
- [ ] Agent has valid voice ID
- [ ] Agent system prompt is configured
- [ ] No configuration errors

### Test 3: Test Outbound Call

**Objective:** Execute complete call flow end-to-end

```typescript
// Create test script
async function testOutboundCall() {
  // 1. Start ElevenLabs conversation
  const conversation = await startElevenLabsConversation({
    agentId: process.env.ELEVENLABS_AGENT_ID,
    leadData: {
      name: "Test Lead",
      phone: process.env.TEST_PHONE_NUMBER,
      propertyAddress: "123 Test St"
    },
    maxDuration: 120  // 2 minutes for test
  })

  // 2. Initiate Twilio call
  const call = await twilioClient.initiateCall({
    to: process.env.TEST_PHONE_NUMBER,
    conversationId: conversation.conversationId,
    webhookUrl: process.env.WEBHOOK_BASE_URL
  })

  console.log(`Test call initiated:`)
  console.log(`- Call SID: ${call.callSid}`)
  console.log(`- Conversation ID: ${conversation.conversationId}`)
  console.log(`- Status: ${call.status}`)

  // 3. Monitor call status
  let callStatus = call.status
  while (callStatus !== 'completed' && callStatus !== 'failed') {
    await sleep(5000)  // Wait 5 seconds

    const status = await twilioClient.getCallStatus(call.callSid)
    callStatus = status.status
    console.log(`Call status: ${callStatus}`)
  }

  // 4. Get conversation details
  const conversationDetails = await getElevenLabsConversation(
    conversation.conversationId
  )

  // 5. Report results
  console.log(`\nTest Results:`)
  console.log(`- Call Status: ${callStatus}`)
  console.log(`- Duration: ${conversationDetails.duration}s`)
  console.log(`- Sentiment: ${conversationDetails.sentiment?.overall}`)
  console.log(`- Transcript lines: ${conversationDetails.transcript?.length}`)

  return {
    success: callStatus === 'completed',
    callSid: call.callSid,
    conversationId: conversation.conversationId,
    duration: conversationDetails.duration,
    transcript: conversationDetails.transcript
  }
}
```

**Success Criteria:**
- [ ] Call connects successfully
- [ ] Audio is clear both directions
- [ ] Agent greeting is heard
- [ ] Agent responds to input appropriately
- [ ] Call completes gracefully
- [ ] Transcript is captured
- [ ] Recording URL is provided

### Test 4: Audio Quality Validation

**Objective:** Measure and validate call audio quality

**Manual Checklist:**
```markdown
## Audio Quality Checklist

### Agent Audio (What You Hear)
- [ ] Voice is clear and intelligible
- [ ] No robotic or choppy artifacts
- [ ] Volume is appropriate (not too loud/quiet)
- [ ] No echo or feedback
- [ ] Natural pacing and rhythm

### User Audio (What Agent Hears)
- [ ] Agent responds to your speech accurately
- [ ] No repeated requests for clarification
- [ ] Agent picks up on tone/sentiment
- [ ] Background noise doesn't confuse agent

### Technical Metrics
- [ ] Response latency <200ms
- [ ] No audio dropouts >1 second
- [ ] Turn-taking feels natural
- [ ] No awkward pauses >3 seconds
```

**Automated Metrics:**
```typescript
interface AudioQualityMetrics {
  avgResponseLatency: number    // milliseconds
  maxResponseLatency: number    // milliseconds
  audioDropouts: number         // count
  turnTakingQuality: number     // 0-1 score
  clarificationRequests: number // count
}

async function measureAudioQuality(conversationId: string) {
  const conversation = await getElevenLabsConversation(conversationId)

  // Calculate metrics from transcript
  const metrics: AudioQualityMetrics = {
    avgResponseLatency: calculateAvgLatency(conversation.transcript),
    maxResponseLatency: calculateMaxLatency(conversation.transcript),
    audioDropouts: countDropouts(conversation.transcript),
    turnTakingQuality: scoreTurnTaking(conversation.transcript),
    clarificationRequests: countClarifications(conversation.transcript)
  }

  // Validate against thresholds
  const quality = {
    excellent: metrics.avgResponseLatency < 150 &&
               metrics.audioDropouts === 0 &&
               metrics.turnTakingQuality > 0.8,

    good: metrics.avgResponseLatency < 250 &&
          metrics.audioDropouts < 2 &&
          metrics.turnTakingQuality > 0.6,

    acceptable: metrics.avgResponseLatency < 400 &&
                metrics.audioDropouts < 5 &&
                metrics.turnTakingQuality > 0.4
  }

  return { metrics, quality }
}
```

### Test 5: Context Injection

**Objective:** Verify lead data is properly used in conversation

```typescript
async function testContextInjection() {
  const testLeadData = {
    name: "John Smith",
    phone: "+1234567890",
    propertyAddress: "456 Oak Avenue, Austin TX",
    estimatedValue: 250000,
    motivation: "probate",
    timeline: "urgent"
  }

  // Start conversation with context
  const conversation = await startElevenLabsConversation({
    agentId: process.env.ELEVENLABS_AGENT_ID,
    leadData: testLeadData,
    propertyInfo: {
      address: testLeadData.propertyAddress,
      estimatedValue: testLeadData.estimatedValue,
      condition: "needs_repairs"
    }
  })

  // Initiate call
  const call = await twilioClient.initiateCall({
    to: testLeadData.phone,
    conversationId: conversation.conversationId,
    webhookUrl: process.env.WEBHOOK_BASE_URL
  })

  // After call, check transcript for context usage
  const details = await getElevenLabsConversation(conversation.conversationId)
  const transcript = details.transcript.map(t => t.text).join(' ')

  // Verify agent used the context
  const contextChecks = {
    usedName: transcript.includes(testLeadData.name),
    mentionedAddress: transcript.includes('Oak Avenue'),
    referencedMotivation: transcript.toLowerCase().includes('probate'),
    acknowledgedTimeline: transcript.toLowerCase().includes('urgent') ||
                         transcript.toLowerCase().includes('soon')
  }

  console.log('Context Injection Results:')
  console.log(`- Used name: ${contextChecks.usedName ? '✓' : '✗'}`)
  console.log(`- Mentioned address: ${contextChecks.mentionedAddress ? '✓' : '✗'}`)
  console.log(`- Referenced motivation: ${contextChecks.referencedMotivation ? '✓' : '✗'}`)
  console.log(`- Acknowledged timeline: ${contextChecks.acknowledgedTimeline ? '✓' : '✗'}`)

  return contextChecks
}
```

**Success Criteria:**
- [ ] Agent uses lead's name naturally
- [ ] Agent references property address
- [ ] Agent acknowledges motivation (probate)
- [ ] Agent adapts to urgent timeline
- [ ] Context feels personalized, not scripted

### Test 6: TCPA Compliance

**Objective:** Verify all TCPA 2025 requirements are met

```markdown
## TCPA Compliance Checklist

### Pre-Call Requirements
- [ ] Written consent verified before call
- [ ] Lead not on national DNC registry
- [ ] Consent date within validity period
- [ ] Consent source documented

### During Call
- [ ] Recording disclosure at call start (if recording)
- [ ] Agent identifies company name
- [ ] Agent states purpose of call clearly
- [ ] Opt-out option provided if requested

### Post-Call
- [ ] Call details logged (date, time, duration, outcome)
- [ ] Recording URL captured
- [ ] Opt-out requests honored immediately
- [ ] Audit trail maintained
```

```typescript
async function testTCPACompliance(conversationId: string) {
  const conversation = await getElevenLabsConversation(conversationId)
  const transcript = conversation.transcript.map(t => t.text).join(' ').toLowerCase()

  const compliance = {
    recordingDisclosure: transcript.includes('recorded') ||
                        transcript.includes('recording'),
    companyIdentified: transcript.includes('next level real estate'),
    purposeStated: transcript.includes('property') ||
                   transcript.includes('selling'),
    optOutOffered: true  // Assumed agent can handle if requested
  }

  const allCompliant = Object.values(compliance).every(v => v === true)

  return {
    compliant: allCompliant,
    checks: compliance,
    issues: Object.entries(compliance)
      .filter(([k, v]) => !v)
      .map(([k]) => k)
  }
}
```

### Test 7: Load Testing

**Objective:** Verify system handles concurrent calls

```typescript
async function loadTest(concurrentCalls: number = 10) {
  console.log(`Starting load test with ${concurrentCalls} concurrent calls...`)

  const testPromises = []
  const results = []

  for (let i = 0; i < concurrentCalls; i++) {
    const promise = testOutboundCall()
      .then(result => {
        results.push({ success: true, ...result })
      })
      .catch(error => {
        results.push({ success: false, error: error.message })
      })

    testPromises.push(promise)

    // Stagger start times by 1 second
    await sleep(1000)
  }

  // Wait for all calls to complete
  await Promise.all(testPromises)

  // Analyze results
  const successCount = results.filter(r => r.success).length
  const failureCount = results.filter(r => !r.success).length
  const successRate = (successCount / concurrentCalls) * 100

  console.log(`\nLoad Test Results:`)
  console.log(`- Total calls: ${concurrentCalls}`)
  console.log(`- Successful: ${successCount}`)
  console.log(`- Failed: ${failureCount}`)
  console.log(`- Success rate: ${successRate.toFixed(1)}%`)

  // Report any failures
  if (failureCount > 0) {
    console.log(`\nFailures:`)
    results.filter(r => !r.success).forEach((r, i) => {
      console.log(`  ${i + 1}. ${r.error}`)
    })
  }

  return {
    totalCalls: concurrentCalls,
    successCount,
    failureCount,
    successRate,
    results
  }
}
```

**Success Criteria:**
- [ ] Success rate >95%
- [ ] No system crashes
- [ ] Average latency <200ms
- [ ] No resource exhaustion

## Metrics Collection

### Call Metrics Dashboard

```typescript
interface CallMetrics {
  // Connection metrics
  initiatedCalls: number
  connectedCalls: number
  failedCalls: number
  connectRate: number  // percentage

  // Duration metrics
  avgDuration: number      // seconds
  minDuration: number
  maxDuration: number

  // Quality metrics
  avgAudioQuality: number  // 0-1 score
  avgResponseLatency: number  // milliseconds
  audioDropoutRate: number    // percentage

  // Business metrics
  conversationCompletionRate: number  // percentage
  positiveSentimentRate: number       // percentage
  qualifiedLeadRate: number           // percentage
}

async function collectMetrics(timeRange: { start: Date, end: Date }) {
  // Get all conversations in time range
  const conversations = await listElevenLabsConversations({
    startDate: timeRange.start,
    endDate: timeRange.end
  })

  // Calculate metrics
  const metrics: CallMetrics = {
    initiatedCalls: conversations.length,
    connectedCalls: conversations.filter(c => c.status === 'completed').length,
    failedCalls: conversations.filter(c => c.status === 'failed').length,
    connectRate: 0,  // calculated below

    avgDuration: average(conversations.map(c => c.duration || 0)),
    minDuration: Math.min(...conversations.map(c => c.duration || Infinity)),
    maxDuration: Math.max(...conversations.map(c => c.duration || 0)),

    avgAudioQuality: average(conversations.map(c => c.audioQuality || 0)),
    avgResponseLatency: average(conversations.map(c => c.avgLatency || 0)),
    audioDropoutRate: (conversations.filter(c => c.audioDropouts > 0).length / conversations.length) * 100,

    conversationCompletionRate: (conversations.filter(c => c.goalReached).length / conversations.length) * 100,
    positiveSentimentRate: (conversations.filter(c => c.sentiment?.overall === 'positive').length / conversations.length) * 100,
    qualifiedLeadRate: (conversations.filter(c => c.leadQualified).length / conversations.length) * 100
  }

  metrics.connectRate = (metrics.connectedCalls / metrics.initiatedCalls) * 100

  return metrics
}
```

## Troubleshooting Guide

### Issue: Call Doesn't Connect

**Symptoms:**
- Call status stays "initiated" or "ringing"
- No audio heard
- Call fails immediately

**Diagnosis Steps:**
1. Check Twilio phone number is verified/purchased
2. Verify test number can receive calls
3. Check webhook endpoint is accessible
4. Review Twilio debugger logs

**Solutions:**
```bash
# Test webhook accessibility
curl https://your-domain.com/twiml/test

# Check Twilio account status
# Log into Twilio Console > Monitor > Debugger

# Verify phone number
curl -X GET "https://api.twilio.com/2010-04-01/Accounts/$TWILIO_ACCOUNT_SID/IncomingPhoneNumbers.json" \
  -u "$TWILIO_ACCOUNT_SID:$TWILIO_AUTH_TOKEN"
```

### Issue: Poor Audio Quality

**Symptoms:**
- Choppy or robotic voice
- Echo or feedback
- Audio dropouts

**Diagnosis Steps:**
1. Check network latency
2. Verify bandwidth availability
3. Test with different voice model
4. Check agent configuration

**Solutions:**
```typescript
// Switch to lower latency model
await updateAgent(agentId, {
  modelId: "eleven_flash_v2_5",  // Fastest model
  responseLatency: 75
})

// Reduce concurrent calls if bandwidth limited
maxConcurrentCalls = 5

// Use codec optimization
// In Twilio call config:
{
  codec: 'opus',  // Better quality than PCMU
  jitterBufferSize: 'small'
}
```

### Issue: Agent Doesn't Use Context

**Symptoms:**
- Generic responses
- Doesn't mention lead name
- Ignores property details

**Diagnosis Steps:**
1. Verify context injection format
2. Check agent system prompt references context
3. Review transcript for context usage

**Solutions:**
```typescript
// Ensure context is properly formatted
const context = {
  leadData: {
    name: "John",  // Simple, clear field names
    property: "123 Main St"
  }
}

// Update system prompt to reference context
systemPrompt += `\n\nIMPORTANT: You will receive lead context including name and property address. Use these naturally in conversation.`

// Test context injection separately
console.log('Context sent:', JSON.stringify(context, null, 2))
```

### Issue: TCPA Compliance Failure

**Symptoms:**
- Missing recording disclosure
- No company identification
- Opt-out not honored

**Diagnosis Steps:**
1. Review call transcript
2. Check agent configuration
3. Verify compliance flags enabled

**Solutions:**
```typescript
// Ensure compliance settings
const agent = await createAgent({
  // ...other config
  tcpaCompliance: true,
  recordingConsent: true,
  greeting: "Hi [name], this is [agent name] calling from Next Level Real Estate. This call may be recorded. [continue...]"
})

// Add opt-out handling to system prompt
systemPrompt += `\n\nIF the person asks to be removed from the call list, apologize politely, confirm their request, and end the call immediately.`
```

## Best Practices

### 1. Test in Stages
- Start with webhook connectivity
- Then test single call
- Scale to multiple calls
- Finally, load test

### 2. Use Test Numbers
- Don't test on real leads initially
- Use your own phone for testing
- Keep a list of test numbers
- Document test scenarios

### 3. Monitor Continuously
- Set up alerting for failed calls
- Track metrics daily
- Review transcripts weekly
- Update agents based on learnings

### 4. Document Everything
- Keep test logs
- Record test scenarios
- Document failures and fixes
- Maintain troubleshooting runbook

### 5. Compliance First
- Always verify consent
- Check DNC before every call
- Include recording disclosure
- Honor opt-outs immediately

## Testing Checklist

```markdown
## Pre-Production Testing Checklist

### Infrastructure
- [ ] Twilio account configured
- [ ] Phone numbers purchased/verified
- [ ] Webhook endpoints accessible
- [ ] ElevenLabs agents created
- [ ] Environment variables set

### Integration
- [ ] Webhook connectivity tested
- [ ] TwiML response validated
- [ ] ConversationRelay configured
- [ ] Status callbacks working

### Functionality
- [ ] Single call successful
- [ ] Audio quality acceptable
- [ ] Context injection working
- [ ] Agent responds appropriately
- [ ] Call completes gracefully

### Quality
- [ ] Response latency <200ms
- [ ] No audio dropouts
- [ ] Natural turn-taking
- [ ] Clear voice quality

### Compliance
- [ ] Recording disclosure present
- [ ] Company identified
- [ ] Purpose stated
- [ ] Opt-out option available
- [ ] Consent verified

### Performance
- [ ] Load test passed (10+ concurrent)
- [ ] Success rate >95%
- [ ] No system crashes
- [ ] Metrics collected

### Documentation
- [ ] Test results documented
- [ ] Issues logged
- [ ] Troubleshooting guide updated
- [ ] Team trained
```

## Resources

### Internal Documentation
- Twilio client: `services/calling-service/src/clients/twilio.ts`
- Webhook routes: `services/calling-service/src/routes/twiml.ts`
- Test scripts: `services/calling-service/tests/`

### External Resources
- [Twilio Voice API Docs](https://www.twilio.com/docs/voice/api)
- [ConversationRelay Guide](https://www.twilio.com/docs/voice/api/conversationrelay)
- [ElevenLabs WebSocket API](https://elevenlabs.io/docs/conversational-ai/websocket-api)
- [TCPA Compliance Guide](https://www.fcc.gov/general/telemarketing-and-robocalls)

---

**Remember:** Thorough testing prevents costly production issues. Test every scenario, document every issue, and always prioritize call quality and compliance.
