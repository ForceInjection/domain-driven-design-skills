---
name: beam
description: Beam dropshipping and product sync context
---

# Beam Domain Context

## What Is Beam?

Beam enables **dropshipping** by syncing products FROM Violet TO destination e-commerce platforms (Shopify) and processing orders back.

### Beam vs Prism

| | Prism | Beam |
|---|-------|------|
| **Direction** | Read Products, Write Orders | Write Products, Read Orders |
| **Flow** | Ingest products from stores → Create orders there | Publish Violet products to destinations → Read orders back |
| **Customer** | Channels (marketplaces, platforms) | Destination merchants (dropshippers) |
| **End User** | Merchants (suppliers) | Shoppers on destination stores |

**Key Value Proposition**: Enables destination merchants to dropship products from multiple Violet suppliers through their own Shopify stores without holding inventory.

## Core Data Model

| Collection | Purpose | Key Fields |
|------------|---------|------------|
| `Shops` | Destination Shopify stores | shopId, accessToken, scopes |
| `Products` | Published products | shopId, violetOfferId, shopifyProductId |
| `Variants` | Product variants | sku, violetSkuId, shopifyVariantId |
| `Orders` | Shopify orders | orderId, lineItems, fulfillmentStatus |
| `Fulfillments` | Fulfillment tracking | orderId, trackingNumber, status |
| `Mappings` | Variant SKU mappings | sourceSkuId, shopifyVariantId, confidence |
| `SyncLogs` | Audit trail | timestamp, action, status, errors |

## Core Temporal Workflows

| Workflow | Purpose | Trigger |
|----------|---------|---------|
| `CatalogSyncWorkflow` | Sync products to Shopify | Scheduled / manual |
| `ProductPublishWorkflow` | Publish single product | API / event |
| `OrderProcessingWorkflow` | Process Shopify order | Webhook |
| `FulfillmentWorkflow` | Handle fulfillment updates | Violet event |
| `ReconciliationWorkflow` | Fix data inconsistencies | Scheduled |
| `VariantMappingWorkflow` | Resolve SKU mappings | On demand |

## Key Principles

### 1. Reliability Over Speed
Beam's value is making dropshipping **reliable**:
- Order accuracy (right products, right quantities)
- Fulfillment tracking (customers know where orders are)
- Data consistency (Shopify ↔ Violet sync)

### 2. Self-Healing Systems
Design for automatic recovery:
- Reconciliation workflows detect and fix issues
- Confidence scoring for variant mappings
- Retry logic with exponential backoff
- Dead letter queues for failed webhooks

### 3. Shopify-First
Focus on Shopify until perfected:
- Deep integration (OAuth, webhooks, GraphQL)
- Handle all edge cases (partial fulfillment, cancellations, refunds)
- Stay current with Shopify API changes

### 4. Multi-Vendor Complexity
Single Shopify orders can have products from multiple Violet merchants:
- Split orders into multiple Violet bags
- Track fulfillment per line item
- Handle partial fulfillments gracefully

## Key Metrics

| Metric | Target | Alert Threshold |
|--------|--------|-----------------|
| Order Success Rate | >98% | <95% |
| Product Sync Latency | <5 min | >10 min |
| Webhook Processing | <30s | >60s |
| Fulfillment Accuracy | >99% | <97% |
| Broken Mappings | <0.1% | >1% |

## Key Repositories

| Repo | Purpose |
|------|---------|
| `BeamService` | Main backend service (Java 21, Spring Boot) |
| `BeamContextLibrary` | Documentation & context |
| `beam-migrations` | Database migrations |
| `beam-brain` | Product brain (specs, strategy) |
