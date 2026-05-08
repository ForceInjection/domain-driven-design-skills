---
name: bigcommerce
description: BigCommerce API patterns and enterprise features
---

# BigCommerce Best Practices & Common Issues

## Product Option Complexity

BigCommerce has a complex product option system that requires careful handling:

- Multiple option types: dropdown, radio, checkbox, etc.
- Option value dependencies and pricing modifiers
- Complex mapping from options to variants
- Variant-specific pricing and inventory
- Image associations with variants
- SKU management for variants

## Common Issues & Solutions

### Option Mapping Complexity
When mapping BigCommerce product options to Violet variants:
1. **Extract Option Names**: From `optionValue.getOptionDisplayName()`
2. **Create Variant Structure**: Group option values by option name
3. **Handle Pricing Modifiers**: Apply option-specific price adjustments
4. **Test Edge Cases**: Multiple options, option value dependencies

### Webhook Signature Validation

Always validate webhook signatures:

```java
// Validate BigCommerce webhook signatures
String expectedSignature = BigCommerceWebhookUtils.calculateSignature(payload, webhookSecret);
if (!BigCommerceWebhookUtils.isValidSignature(receivedSignature, expectedSignature)) {
  throw new InvalidWebhookSignatureException();
}
```

### Rate Limiting

BigCommerce enforces strict rate limits:
- **Rate Limit**: 450 requests per 30 seconds
- **Backoff Strategy**: Exponential backoff with jitter
- **Header Monitoring**: Watch `X-Rate-Limit-Remaining` headers
- **Bulk Operations**: Consider message queues for better rate limit management

### Authentication Issues

Common authentication problems:
- **Store Hash**: Required and unique to each store
- **Access Token**: Must be properly scoped for required resources
- **API Path**: Use correct API version (v3 recommended)
- **HTTPS**: All calls must use HTTPS

## Testing Patterns

### Test Structure
- Tests located in `src/test/java/io/drizzl/platform/ecom/platforms/bigcommerce/`
- Use `@SpringBootTest` with BigCommerce-specific mocks
- JSON fixtures in `src/test/resources/platform/bigcommerce/`

### Mock Examples
```java
@MockBean
private BigCommerceServiceClientFactory bcServiceClientFactory;

@MockBean
private BigCommerceCalculateCartUtils cartCalculationUtils;

@MockBean
private AsyncBcOrderEvents asyncBcOrderEvents;

// Mock BigCommerce API responses
when(bcServiceClientFactory.getApiClient(merchantId))
    .thenReturn(mockBigCommerceClient);
```

### Test Data
- Complex product structures with variants and options
- Order responses with extensive metadata
- Webhook payloads with proper signatures
- Edge cases: null option values, missing images, complex discounts

## Enterprise Features Testing

### Advanced Catalog Management
- Test with multiple categories and brands
- Verify category relationships and hierarchies
- Test with product relationships (bundles, related products)

### Customer Groups and Pricing Tiers
- Test with different pricing for different customer groups
- Verify tier-based pricing calculations
- Handle group-specific product restrictions

### Multi-Channel Inventory
- Test inventory sync across channels
- Verify channel-specific availability
- Handle channel-specific visibility rules

## Platform-Specific Considerations

### Customer Management
- Comprehensive customer data structures
- Customer groups for pricing and permissions
- Custom customer fields
- Subscription/recurring customer data

### Order Management
- Comprehensive order lifecycle management
- Advanced fulfillment options
- Return and exchange processing
- Order notes and communications
- Audit trail tracking

### Shipping and Tax
- Advanced shipping rule system with zones
- Tax calculation with multiple rates
- Tax-inclusive vs tax-exclusive pricing
- Shipping method cost overrides

### Payment Processing
- Multiple payment gateway support
- Stored payment methods
- Recurring billing capabilities
- Fraud detection integration
- Payment status tracking

## Migration Guidelines

### Legacy to Modern Migration

The BigCommerce integration needs significant modernization:

1. **Identify Legacy Components**:
   - `BigcommerceOrderComposer` (instance-based)
   - `BigCommerceProductDecomposer` (instance-based)

2. **Create Static Equivalents**:
   ```java
   // Target modern pattern
   public class BigcommerceOrderComposer {
     public static BigCommerceOrder composeOrder(TransactableBag bag, MerchantConfiguration config) {
       // Static method implementation
     }
   }
   ```

3. **Extract Utility Methods**:
   - Move complex logic to utility classes
   - Create focused helper methods for option mapping
   - Remove instance variable dependencies

4. **Update Tests**:
   - Migrate to static method testing patterns
   - Update mock setup for new method signatures
   - Add edge case tests

### API Version Management

- Stay current with BigCommerce API versions
- Test compatibility with API changes
- Handle deprecation warnings and sunset dates
- Update client library versions

## Debugging Tools

### API Testing

```java
// Test BigCommerce API endpoints directly
String apiUrl = "https://api.bigcommerce.com/stores/{store_hash}/v3/products";
// Include proper authentication headers
```

### Webhook Development
- Use ngrok for local webhook testing
- Verify webhook signatures in development
- Test webhook retry behavior and failure handling

### Store Configuration
- Verify API credentials and permissions
- Check store-specific settings that affect API behavior
- Test with different store configurations
- Monitor store-level rate limits

## Performance Optimization

### Rate Limit Optimization
- Batch requests when possible
- Use filtering and pagination to reduce response size
- Cache frequently accessed data
- Monitor actual rate limit usage

### Webhook Processing
- Process webhooks asynchronously (`AsyncBcOrderEvents`)
- Implement proper error handling and retries
- Use message queues for high-volume events

## Integration Checklist

- [ ] Webhook signature validation implemented
- [ ] Rate limiting with exponential backoff
- [ ] Product option mapping tested
- [ ] Status ID mapping complete
- [ ] Metadata fields consistent with conventions
- [ ] Coupon/discount support verified
- [ ] Webhook payload processing async
- [ ] Error handling for API failures
- [ ] Payment method support verified
- [ ] Shipping and tax calculations accurate
- [ ] Authentication scopes validated
- [ ] Comprehensive test coverage
