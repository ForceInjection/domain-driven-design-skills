---
name: mycarrierpackets-api
description: "This skill should be used when the user asks to 'integrate with MyCarrierPackets', 'set up MCP API', 'onboard carriers', 'Intellivite invitation', 'monitor carriers', 'Assure Advantage', 'get carrier data', 'retrieve COI', 'get W9', 'carrier risk assessment', 'check completed packets', or when implementing TMS carrier management features. Provides comprehensive guidance for MyCarrierPackets API authentication, carrier invitations, data retrieval, monitoring, and document management."
tags: [mcp, mycarrierpackets, carrier, tms, api, oauth2, monitoring, intellivite]
---

# MyCarrierPackets API Integration Guide

## Overview

MyCarrierPackets (MCP) provides a comprehensive API for Transportation Management System (TMS) integration, enabling carrier onboarding, profile management, risk assessment, monitoring, and document retrieval.

**Base URL:** `https://api.mycarrierpackets.com`
**API Version:** v1
**Authentication:** OAuth2 Bearer Token
**Default Response Format:** JSON (XML available with `Accept: text/xml` header)

## When to Use This Skill

- Setting up OAuth2 authentication with MyCarrierPackets
- Implementing carrier invitation flows (Intellivite)
- Building carrier profile data retrieval
- Integrating Assure Advantage monitoring
- Retrieving certificates of insurance (COI), W9s, or eAgreements
- Polling for completed packets or carrier changes
- Managing carrier monitoring lists
- Implementing fraud detection with associated carriers

---

## Authentication & Configuration

### OAuth2 Password Grant Flow

Authenticate using the password grant type to obtain a bearer token.

**Token Endpoint:** `POST https://api.mycarrierpackets.com/token`

**Request:**
```
POST /token HTTP/1.1
Host: api.mycarrierpackets.com
Content-Type: application/x-www-form-urlencoded

grant_type=password&username={integration_username}&password={integration_password}
```

**Response:**
```json
{
  "access_token": "eyJ...",
  "token_type": "bearer",
  "expires_in": 3600
}
```

### Go Implementation

```go
package mcp

import (
    "context"
    "encoding/json"
    "fmt"
    "io"
    "net/http"
    "net/url"
    "strings"
    "sync"
    "time"
)

type MCPClient struct {
    baseURL      string
    httpClient   *http.Client
    username     string
    password     string
    accessToken  string
    tokenExpiry  time.Time
    tokenMu      sync.RWMutex
}

type TokenResponse struct {
    AccessToken string `json:"access_token"`
    TokenType   string `json:"token_type"`
    ExpiresIn   int    `json:"expires_in"`
}

func NewMCPClient(username, password string) *MCPClient {
    return &MCPClient{
        baseURL:    "https://api.mycarrierpackets.com",
        httpClient: &http.Client{Timeout: 30 * time.Second},
        username:   username,
        password:   password,
    }
}

func (c *MCPClient) getToken(ctx context.Context) (string, error) {
    c.tokenMu.RLock()
    if c.accessToken != "" && time.Now().Before(c.tokenExpiry) {
        token := c.accessToken
        c.tokenMu.RUnlock()
        return token, nil
    }
    c.tokenMu.RUnlock()

    c.tokenMu.Lock()
    defer c.tokenMu.Unlock()

    // Double-check after acquiring write lock
    if c.accessToken != "" && time.Now().Before(c.tokenExpiry) {
        return c.accessToken, nil
    }

    data := url.Values{}
    data.Set("grant_type", "password")
    data.Set("username", c.username)
    data.Set("password", c.password)

    req, err := http.NewRequestWithContext(ctx, "POST", c.baseURL+"/token", strings.NewReader(data.Encode()))
    if err != nil {
        return "", fmt.Errorf("creating token request: %w", err)
    }
    req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

    resp, err := c.httpClient.Do(req)
    if err != nil {
        return "", fmt.Errorf("token request failed: %w", err)
    }
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusOK {
        body, _ := io.ReadAll(resp.Body)
        return "", fmt.Errorf("token request returned %d: %s", resp.StatusCode, string(body))
    }

    var tokenResp TokenResponse
    if err := json.NewDecoder(resp.Body).Decode(&tokenResp); err != nil {
        return "", fmt.Errorf("decoding token response: %w", err)
    }

    c.accessToken = tokenResp.AccessToken
    c.tokenExpiry = time.Now().Add(time.Duration(tokenResp.ExpiresIn-60) * time.Second)

    return c.accessToken, nil
}

func (c *MCPClient) doRequest(ctx context.Context, method, endpoint string, body io.Reader) (*http.Response, error) {
    token, err := c.getToken(ctx)
    if err != nil {
        return nil, fmt.Errorf("getting token: %w", err)
    }

    req, err := http.NewRequestWithContext(ctx, method, c.baseURL+endpoint, body)
    if err != nil {
        return nil, fmt.Errorf("creating request: %w", err)
    }

    req.Header.Set("Authorization", "bearer "+token)
    req.Header.Set("Content-Type", "application/json")

    return c.httpClient.Do(req)
}
```

### Credential Management

Manage API credentials through the MyCarrierPackets Integration Tools portal:
`https://mycarrierpackets.com/IntegrationTools`

Store credentials securely using environment variables:

```bash
export MCP_USERNAME="your_integration_username"
export MCP_PASSWORD="your_integration_password"
```

---

## Carrier Invitations (Intellivite)

Three methods exist to invite carriers to complete onboarding packets.

### Method 1: API-Based Invitation (Recommended)

Send invitations programmatically with user association.

**With MCP User Association:**
```
POST /api/v1/Carrier/EmailPacketInvitation
    ?dotNumber={DOTNumber}
    &docketNumber={MC,FF,MX}
    &carrierEmail={email}
    &username={customerMCPUsername}
```

**Without User Association:**
```
POST /api/v1/Carrier/EmailPacketInvitation
    ?dotNumber={DOTNumber}
    &docketNumber={MC,FF,MX}
    &carrierEmail={email}
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `carrierEmail` | string | Yes | Carrier's email address |
| `dotNumber` | integer | No | DOT number |
| `docketNumber` | string | No | MC, FF, or MX number |
| `userName` | string | No | MCP username for tracking |
| `sendConfirmationEmail` | boolean | No | Send confirmation to inviter |
| `notificationEmails` | string | No | Comma-separated CC emails |

### Method 2: Link-Based Invitation

Generate invitation URLs for TMS-generated emails.

**Full Carrier Link (Recommended):**
```
https://mycarrierpackets.com/{CustomerIntelliviteID}/Carrier/Intellivite/{CustomerMCPUserID}/{DOTNumber}/{DocketNumber}
```

**Example:**
```
https://mycarrierpackets.com/ea72823e-1506-4b72-a3b0-a488e1ba2f1e/Carrier/Intellivite/brenda/23868/MC113843
```

**Intrastate Carrier Link (DOT only):**
```
https://mycarrierpackets.com/{CustomerIntelliviteID}/Carrier/Intellivite/{CustomerMCPUserID}/{DOTNumber}
```

**Basic Link (no pre-fill):**
```
https://mycarrierpackets.com/{CustomerIntelliviteID}/Carrier/Intellivite
```

### Method 3: Direct MCP URL

Redirect users to MyCarrierPackets portal with pre-filled data.

```
https://mycarrierpackets.com/RegisteredCustomer/SendCarrierPacket
    ?dotNumber={dotNumber}
    &docketNumber={docketNumber}
```

### Preview Carrier Before Invitation

Preload carrier data, risk assessment, and certificates before sending invitations.

```
POST /api/v1/Carrier/PreviewCarrier
    ?DOTNumber={DOTNumber}
    &docketNumber={MC,FF,MX}
```

**Response:**
```json
{
  "CarrierID": 12345,
  "DotNumber": 23868,
  "DocketNumber": "MC113843",
  "CompanyName": "Sample Trucking LLC",
  "Status": "Active",
  "RiskAssessment": {
    "Overall": "Low",
    "Authority": "Pass",
    "Insurance": "Pass",
    "Safety": "Pass",
    "Operation": "Pass"
  },
  "CertData": {
    "Status": "Current",
    "Certificates": []
  },
  "IsMonitored": false,
  "IsBlocked": false
}
```

---

## Carrier Data Management

### Get Full Carrier Data

Retrieve comprehensive carrier profile including packet data.

```
POST /api/v1/Carrier/GetCarrierData
    ?DOTNumber={DOTNumber}
    &DocketNumber={MC,FF,MX}
```

**Response includes:**
- Legal name, DBA, address, contact info
- Carrier equipment and truck types
- Cargo hauled and lanes
- Payment information
- Risk assessment details (AssureAdvantage)
- TIN matching results
- Document blob names for retrieval

### Go Implementation

```go
type CarrierData struct {
    DOTNumber       int    `json:"DOTNumber"`
    DocketNumber    string `json:"DocketNumber"`
    LegalName       string `json:"LegalName"`
    DBAName         string `json:"DBAName"`
    Street          string `json:"Street"`
    City            string `json:"City"`
    State           string `json:"State"`
    ZipCode         string `json:"ZipCode"`
    Phone           string `json:"Phone"`
    Status          string `json:"Status"`
    RiskAssessment  *RiskAssessment `json:"RiskAssessmentDetails"`
}

type RiskAssessment struct {
    Overall   string `json:"Overall"`
    Authority string `json:"Authority"`
    Insurance string `json:"Insurance"`
    Safety    string `json:"Safety"`
    Operation string `json:"Operation"`
}

func (c *MCPClient) GetCarrierData(ctx context.Context, dotNumber int, docketNumber string) (*CarrierData, error) {
    endpoint := fmt.Sprintf("/api/v1/Carrier/GetCarrierData?DOTNumber=%d&DocketNumber=%s", dotNumber, docketNumber)

    resp, err := c.doRequest(ctx, "POST", endpoint, nil)
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusOK {
        body, _ := io.ReadAll(resp.Body)
        return nil, fmt.Errorf("GetCarrierData returned %d: %s", resp.StatusCode, string(body))
    }

    var carrier CarrierData
    if err := json.NewDecoder(resp.Body).Decode(&carrier); err != nil {
        return nil, fmt.Errorf("decoding carrier data: %w", err)
    }

    return &carrier, nil
}
```

### Get Carrier Contacts

Retrieve authorized and verified users for a carrier.

```
POST /api/v1/Carrier/GetCarrierContacts
    ?DOTNumber={DOTNumber}
    &docketNumber={DocketNumber}
```

**Response:**
```json
{
  "Success": true,
  "Carrier": {
    "DOTNumber": 23868,
    "Contacts": [
      {
        "FirstName": "John",
        "LastName": "Smith",
        "Title": "Owner",
        "Phone": "555-123-4567",
        "Email": "john@sample.com",
        "AuthorizedForPackets": true,
        "VerificationStatus": "Verified"
      }
    ]
  }
}
```

### Find Associated Carriers (Fraud Detection)

Search for carriers with shared phone numbers or email addresses.

```
POST /api/v1/Carrier/FindAssociatedCarriers
    ?phone={phoneNumber}
    &email={emailAddress}
```

**Response:**
```json
{
  "Success": true,
  "AssociatedCarriersCount": 3,
  "AssociatedCarriers": [
    {
      "DOTNumber": 23868,
      "CompanyName": "Sample Trucking LLC",
      "PhoneAssociationTypes": [
        { "AssociationType": 1, "Description": "FMCSA Contact" }
      ],
      "EmailAssociationTypes": []
    }
  ]
}
```

### Completed Packets Polling

Poll for carriers that have completed packets within a date range.

```
POST /api/v1/Carrier/CompletedPackets
    ?fromDate={YYYY-MM-DDTHH:MM:SS}
    &toDate={YYYY-MM-DDTHH:MM:SS}
```

**Polling interval:** 5-15 minutes recommended

**Response:**
```json
[
  {
    "DOTNumber": 23868,
    "DocketNumber": "MC113843",
    "LegalName": "Sample Trucking LLC",
    "CompletedDate": "2024-01-15T14:30:00Z"
  }
]
```

### Go Polling Implementation

```go
func (c *MCPClient) PollCompletedPackets(ctx context.Context, fromDate, toDate time.Time) ([]CompletedPacket, error) {
    endpoint := fmt.Sprintf(
        "/api/v1/Carrier/CompletedPackets?fromDate=%s&toDate=%s",
        fromDate.Format("2006-01-02T15:04:05"),
        toDate.Format("2006-01-02T15:04:05"),
    )

    resp, err := c.doRequest(ctx, "POST", endpoint, nil)
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()

    var packets []CompletedPacket
    if err := json.NewDecoder(resp.Body).Decode(&packets); err != nil {
        return nil, fmt.Errorf("decoding completed packets: %w", err)
    }

    return packets, nil
}

type CompletedPacket struct {
    DOTNumber     int       `json:"DOTNumber"`
    DocketNumber  string    `json:"DocketNumber"`
    LegalName     string    `json:"LegalName"`
    CompletedDate time.Time `json:"CompletedDate"`
}
```

---

## Assure Advantage Carrier Monitoring

### Monitoring Overview

Assure Advantage provides continuous carrier monitoring with automatic updates when insurance, authority, safety, or operational status changes.

### Get Monitored Carriers List

```
POST /api/v1/Carrier/MonitoredCarriers
    ?pageNumber={1}
    &pageSize={2500}
```

**Max page size:** 5000
**Pagination:** Check `X-Pagination` header for total pages

**Response:**
```json
[
  {
    "DOTNumber": 23868,
    "DocketNumber": "MC113843",
    "IntrastateNumber": null,
    "CreatedDate": "2024-01-01T00:00:00Z",
    "LastModifiedDate": "2024-01-15T14:30:00Z"
  }
]
```

### Add Carrier to Monitoring

```
POST /api/v1/Carrier/RequestMonitoring

Body:
{
  "DOTNumber": 23868,
  "DocketNumber": "MC113843"
}
```

For intrastate carriers, use `IntrastateNumber` instead.

### Remove Carrier from Monitoring

```
POST /api/v1/Carrier/CancelMonitoring

Body:
{
  "DOTNumber": 23868,
  "DocketNumber": "MC113843"
}
```

### Poll for Carrier Changes

Monitor changes to carrier insurance, risk assessment, and status.

```
POST /api/v1/Carrier/CarriersChanges
    ?fromDate={YYYY-MM-DDTHH:MM:SS}
    &toDate={YYYY-MM-DDTHH:MM:SS}
    &pageNumber={1}
    &pageSize={250}
```

**Polling interval:** Minimum 4 minutes, recommended 5-15 minutes
**Max page size:** 500

**Response includes:**
- `ChangeCategories` - Array of change types
- `CarrierDetails` - Updated carrier data

### Bulk Carrier Data Sync

Retrieve full data for all monitored carriers (heavy operation).

```
POST /api/v1/Carrier/MonitoredCarrierData
    ?pageNumber={1}
    &pageSize={250}
```

**Max page size:** 500

### Risk Assessment APIs

**Single Carrier:**
```
POST /api/v1/Carrier/GetCarrierRiskAssessment
    ?dotNumber={DOTNumber}
    &docketNumber={DocketNumber}
```

**All Monitored Carriers:**
```
POST /api/v1/Carrier/GetMonitoredCarriersRiskAssessment
    ?pageNumber={1}
    &pageSize={250}
```

**Response:**
```json
{
  "RiskAssessmentDetails": {
    "Authority": {
      "TotalPoints": 0,
      "OverallRating": "Pass",
      "Infractions": []
    },
    "Insurance": {
      "TotalPoints": 0,
      "OverallRating": "Pass",
      "Infractions": []
    },
    "Safety": {
      "TotalPoints": 5,
      "OverallRating": "Warning",
      "Infractions": ["Recent inspection violation"]
    },
    "Operation": {
      "TotalPoints": 0,
      "OverallRating": "Pass",
      "Infractions": []
    }
  }
}
```

---

## Document & Image Retrieval

### Get Individual Document

Retrieve COI, W9, or eAgreement documents by blob name.

```
POST /api/v1/Carrier/GetDocument
    ?name={BlobName}
```

**Blob names** are obtained from `GetCarrierData` response.

**Example blob name:** `company-agreement/12/guid-abc123...`

### Full Packet PDF

**Browser View (requires portal login):**
```
https://mycarrierpackets.com/Download/GetCarrierPacket
    ?DOTNumber={DOTNumber}
    &inline=True
```

**API Download:**
```
GET https://mycarrierpackets.com/api/Download/CarrierPacket/{DOTNumber}
```

Note: API download uses a separate token endpoint:
```
GET https://mycarrierpackets.com/api/token
```

### View Carrier Information

Add "View Carrier" button in TMS linking to MCP portal.

**Standard:**
```
https://mycarrierpackets.com/CarrierInformation/DOTNumber/{dotNumber}/DocketNumber/{docketNumber}
```

**Intrastate:**
```
https://mycarrierpackets.com/CarrierInformation/DOTNumber/{dotNumber}
```

**With Insurance Request:**
```
https://mycarrierpackets.com/CarrierInformation/DOTNumber/{dotNumber}/DocketNumber/{docketNumber}?requestInsurance=true
```

---

## Carrier Actions

### Block/Unblock Carriers

**Block:**
```
POST /api/v1/Carrier/BlockCarrier
Body: { "DOTNumber": 23868, "DocketNumber": "MC113843" }
```

**Unblock:**
```
POST /api/v1/Carrier/UnblockCarrier
Body: { "DOTNumber": 23868, "DocketNumber": "MC113843" }
```

**Get Blocked List:**
```
POST /api/v1/Carrier/BlockedCarriers
    ?pageNumber={1}
    &pageSize={2500}
```

### Request User Verification

Request verification for a carrier contact (non-onboarding).

```
POST /api/v1/Carrier/RequestUserVerification
    ?userVerificationEmail={email}
    &dotNumber={DOTNumber}
    &docketNumber={DocketNumber}
```

### Request VIN Verification

Send VIN verification request via text message.

```
POST /api/v1/Carrier/RequestVINVerification
Body:
{
  "deliveryOption": 2,
  "vinVerificationPhoneNumber": "555-123-4567",
  "dotNumber": 23868
}
```

Note: Only phone delivery (option 2) is supported.

### Get Incident Reports

```
POST /api/v1/Carrier/GetCarrierIncidentReports
    ?DOTNumber={DOTNumber}
    &docketNumber={DocketNumber}
```

### Get VIN Verifications

```
POST /api/v1/Carrier/GetCarrierVINVerifications
    ?DOTNumber={DOTNumber}
    &docketNumber={DocketNumber}
```

### Get Updated Factoring Companies

```
POST /api/v1/Carrier/GetUpdatedFactoringCompanies
    ?fromDate={YYYY-MM-DDTHH:MM:SS}
    &toDate={YYYY-MM-DDTHH:MM:SS}
```

---

## Integration Patterns

### Data Mapping Best Practices

1. **Field Locking:** Mark monitored carrier fields as read-only in TMS
2. **Blank Fields:** If carrier is monitored but no data received, keep fields blank
3. **Sync Process:** Clear mapped fields before pulling fresh updates

### Synchronization Workflow

```
1. User runs carrier sync report in TMS
2. TMS compares local monitored list with MCP MonitoredCarriers API
3. For missing carriers: Call RequestMonitoring
4. For extra carriers: Call CancelMonitoring
5. Call CarriersChanges for incremental updates
6. For full refresh: Call GetCarrierData for each carrier
```

### Push vs Pull Integration

**Pull Model (Recommended):**
- Poll `CompletedPackets` every 5-15 minutes
- Poll `CarriersChanges` every 5-15 minutes
- Full sync with `MonitoredCarrierData` periodically

**Push Model:**
Provide MCP with a webhook endpoint:
```
POST https://api.yourtms.com/{DOTNumber}/{DocketNumber}
```

MCP will call this endpoint when packets complete.

### Polling Implementation

```go
func (c *MCPClient) StartPolling(ctx context.Context, interval time.Duration, handler func([]CompletedPacket)) {
    ticker := time.NewTicker(interval)
    defer ticker.Stop()

    lastPoll := time.Now().Add(-interval)

    for {
        select {
        case <-ctx.Done():
            return
        case <-ticker.C:
            now := time.Now()
            packets, err := c.PollCompletedPackets(ctx, lastPoll, now)
            if err != nil {
                log.Printf("polling error: %v", err)
                continue
            }
            if len(packets) > 0 {
                handler(packets)
            }
            lastPoll = now
        }
    }
}
```

### Pagination Handling

```go
func (c *MCPClient) GetAllMonitoredCarriers(ctx context.Context) ([]MonitoredCarrier, error) {
    var allCarriers []MonitoredCarrier
    pageNumber := 1
    pageSize := 2500

    for {
        endpoint := fmt.Sprintf("/api/v1/Carrier/MonitoredCarriers?pageNumber=%d&pageSize=%d", pageNumber, pageSize)
        resp, err := c.doRequest(ctx, "POST", endpoint, nil)
        if err != nil {
            return nil, err
        }

        var carriers []MonitoredCarrier
        if err := json.NewDecoder(resp.Body).Decode(&carriers); err != nil {
            resp.Body.Close()
            return nil, err
        }
        resp.Body.Close()

        allCarriers = append(allCarriers, carriers...)

        // Check X-Pagination header for more pages
        pagination := resp.Header.Get("X-Pagination")
        if pagination == "" || len(carriers) < pageSize {
            break
        }
        pageNumber++
    }

    return allCarriers, nil
}
```

---

## Error Handling

### Common Error Responses

| Status Code | Meaning | Resolution |
|-------------|---------|------------|
| 400 | Bad Request | Check parameters format |
| 401 | Unauthorized | Token expired, re-authenticate |
| 403 | Forbidden | Check API permissions |
| 404 | Not Found | Invalid DOT/Docket number |
| 429 | Rate Limited | Reduce polling frequency |
| 500 | Server Error | Retry with exponential backoff |

### Error Handling Implementation

```go
func (c *MCPClient) handleResponse(resp *http.Response) error {
    switch resp.StatusCode {
    case http.StatusOK:
        return nil
    case http.StatusUnauthorized:
        c.tokenMu.Lock()
        c.accessToken = ""
        c.tokenMu.Unlock()
        return fmt.Errorf("token expired, retry request")
    case http.StatusTooManyRequests:
        return fmt.Errorf("rate limited, reduce polling frequency")
    case http.StatusNotFound:
        return fmt.Errorf("carrier not found")
    default:
        body, _ := io.ReadAll(resp.Body)
        return fmt.Errorf("API error %d: %s", resp.StatusCode, string(body))
    }
}
```

### Retry with Exponential Backoff

```go
func (c *MCPClient) doRequestWithRetry(ctx context.Context, method, endpoint string, body io.Reader, maxRetries int) (*http.Response, error) {
    var lastErr error

    for attempt := 0; attempt < maxRetries; attempt++ {
        resp, err := c.doRequest(ctx, method, endpoint, body)
        if err == nil && resp.StatusCode == http.StatusOK {
            return resp, nil
        }

        if resp != nil {
            resp.Body.Close()
            if resp.StatusCode == http.StatusUnauthorized {
                // Clear token and retry immediately
                c.tokenMu.Lock()
                c.accessToken = ""
                c.tokenMu.Unlock()
                continue
            }
        }

        lastErr = err
        if lastErr == nil {
            lastErr = fmt.Errorf("request failed with status %d", resp.StatusCode)
        }

        // Exponential backoff
        backoff := time.Duration(1<<attempt) * time.Second
        select {
        case <-ctx.Done():
            return nil, ctx.Err()
        case <-time.After(backoff):
        }
    }

    return nil, fmt.Errorf("max retries exceeded: %w", lastErr)
}
```

---

## API Endpoint Reference

### Carrier Operations

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/Carrier/PreviewCarrier` | POST | Preview carrier before invitation |
| `/api/v1/Carrier/GetCarrierData` | POST | Full carrier profile with packet data |
| `/api/v1/Carrier/GetCarrierContacts` | POST | Carrier authorized contacts |
| `/api/v1/Carrier/FindAssociatedCarriers` | POST | Fraud detection - shared contacts |
| `/api/v1/Carrier/GetCarrierIncidentReports` | POST | Carrier incident history |
| `/api/v1/Carrier/GetCarrierVINVerifications` | POST | VIN verification status |
| `/api/v1/Carrier/CompletedPackets` | POST | Poll for completed packets |
| `/api/v1/Carrier/CarriersChanges` | POST | Poll for carrier changes |
| `/api/v1/Carrier/EmailPacketInvitation` | POST | Send Intellivite invitation |
| `/api/v1/Carrier/RequestUserVerification` | POST | Request contact verification |
| `/api/v1/Carrier/RequestVINVerification` | POST | Request VIN verification |
| `/api/v1/Carrier/GetDocument` | POST | Retrieve document by blob name |

### Monitoring Operations

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/Carrier/MonitoredCarriers` | POST | List all monitored carriers |
| `/api/v1/Carrier/MonitoredCarrierData` | POST | Bulk sync monitored carrier data |
| `/api/v1/Carrier/GetMonitoredCarrierContactsData` | POST | Contacts for all monitored carriers |
| `/api/v1/Carrier/RequestMonitoring` | POST | Add carrier to monitoring |
| `/api/v1/Carrier/CancelMonitoring` | POST | Remove carrier from monitoring |
| `/api/v1/Carrier/GetCarrierRiskAssessment` | POST | Single carrier risk assessment |
| `/api/v1/Carrier/GetMonitoredCarriersRiskAssessment` | POST | Bulk risk assessments |

### Blocking Operations

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/Carrier/BlockCarrier` | POST | Block a carrier |
| `/api/v1/Carrier/UnblockCarrier` | POST | Unblock a carrier |
| `/api/v1/Carrier/BlockedCarriers` | POST | List blocked carriers |

### Other Operations

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/Carrier/GetUpdatedFactoringCompanies` | POST | Updated factoring companies |
| `/token` | POST | OAuth2 token endpoint |

---

## Troubleshooting

### Authentication Issues

- **401 errors:** Token expired or invalid credentials
- **Solution:** Re-authenticate and verify credentials in IntegrationTools portal

### Missing Carrier Data

- **Cause:** Carrier not monitored or packet incomplete
- **Solution:** Check `IsMonitored` flag, verify packet completion status

### Pagination Not Working

- **Cause:** Missing X-Pagination header check
- **Solution:** Parse pagination info from header, not response body

### Rate Limiting

- **Cause:** Polling too frequently
- **Solution:** Increase polling interval to minimum 5 minutes

### Document Retrieval Fails

- **Cause:** Invalid blob name or expired document
- **Solution:** Re-fetch carrier data to get current blob names
