---
name: ecom-integrations
description: Ecommerce integration patterns and decomposer/composer
---

# Decomposer/Composer Patterns

## Decomposer Pattern

Decomposers transform **external platform data → Violet canonical models**.

### Interface
```java
public interface Decomposer<P, V> {
    V decompose(P platformEntity);
    List<V> decomposeList(List<P> platformEntities);
}
```

### Example: Shopify Product Decomposer
```java
public class ShopifyProductDecomposer implements Decomposer<ShopifyProduct, Offer> {

    public static Offer decompose(ShopifyProduct shopifyProduct) {
        Offer offer = new Offer();
        offer.setExternalId(String.valueOf(shopifyProduct.getId()));
        offer.setName(shopifyProduct.getTitle());
        offer.setDescription(shopifyProduct.getBodyHtml());
        offer.setVendor(shopifyProduct.getVendor());
        offer.setSkus(decomposeVariants(shopifyProduct.getVariants()));
        offer.setImages(decomposeImages(shopifyProduct.getImages()));
        offer.setTags(parseTags(shopifyProduct.getTags()));
        offer.setStatus(mapStatus(shopifyProduct.getStatus()));
        return offer;
    }

    private static OfferStatus mapStatus(String shopifyStatus) {
        return switch (shopifyStatus) {
            case "active" -> OfferStatus.AVAILABLE;
            case "draft" -> OfferStatus.DRAFT;
            case "archived" -> OfferStatus.UNAVAILABLE;
            default -> OfferStatus.UNKNOWN;
        };
    }
}
```

### Key Principles
1. **Pure functions** - No side effects, static methods
2. **Null safety** - Check every field before accessing
3. **Status mapping** - Translate platform statuses to Violet statuses
4. **Field normalization** - Convert to consistent formats (currency, units)

## Composer Pattern

Composers transform **Violet canonical models → external platform formats**.

### Interface
```java
public interface Composer<V, P> {
    P compose(V violetEntity);
    List<P> composeList(List<V> violetEntities);
}
```

### Example: Shopify Order Composer
```java
public class ShopifyOrderComposer implements Composer<Order, ShopifyOrderInput> {

    public static ShopifyOrderInput compose(Order violetOrder) {
        ShopifyOrderInput input = new ShopifyOrderInput();
        input.setEmail(violetOrder.getCustomer().getEmail());
        input.setLineItems(composeLineItems(violetOrder.getItems()));
        input.setShippingAddress(composeAddress(violetOrder.getShippingAddress()));
        input.setBillingAddress(composeAddress(violetOrder.getBillingAddress()));
        input.setFinancialStatus(mapFinancialStatus(violetOrder.getPaymentStatus()));
        input.setFulfillmentStatus(mapFulfillmentStatus(violetOrder.getFulfillmentStatus()));
        return input;
    }

    private static String mapFinancialStatus(PaymentStatus status) {
        return switch (status) {
            case PAID -> "paid";
            case PENDING -> "pending";
            case REFUNDED -> "refunded";
            case PARTIALLY_REFUNDED -> "partially_refunded";
            default -> "pending";
        };
    }
}
```

### Key Principles
1. **Idempotent** - Same input always produces same output
2. **Complete** - Include all required platform fields
3. **Validated** - Output should pass platform validation
4. **Documented** - Every field mapping documented

## Testing Patterns

### Decomposer Tests
```java
@Test
void decompose_shouldMapAllFields() {
    ShopifyProduct input = createTestProduct();

    Offer result = ShopifyProductDecomposer.decompose(input);

    assertThat(result.getExternalId()).isEqualTo("123");
    assertThat(result.getName()).isEqualTo("Test Product");
    assertThat(result.getStatus()).isEqualTo(OfferStatus.AVAILABLE);
}

@Test
void decompose_shouldHandleNullFields() {
    ShopifyProduct input = new ShopifyProduct();
    input.setId(123L);
    // Other fields null

    Offer result = ShopifyProductDecomposer.decompose(input);

    assertThat(result.getExternalId()).isEqualTo("123");
    assertThat(result.getName()).isNull();
}
```

### Composer Tests
```java
@Test
void compose_shouldProduceValidPlatformInput() {
    Order violetOrder = createTestOrder();

    ShopifyOrderInput result = ShopifyOrderComposer.compose(violetOrder);

    assertThat(result.getEmail()).isNotNull();
    assertThat(result.getLineItems()).isNotEmpty();
}

@Test
void compose_shouldMapStatusCorrectly() {
    Order order = new Order();
    order.setPaymentStatus(PaymentStatus.PAID);

    ShopifyOrderInput result = ShopifyOrderComposer.compose(order);

    assertThat(result.getFinancialStatus()).isEqualTo("paid");
}
```

## Status Mapping Tables

Every integration must document status mappings:

### Order Status Example
| Violet Status | Shopify | BigCommerce | WooCommerce |
|---------------|---------|-------------|-------------|
| PENDING | unfulfilled | Awaiting Fulfillment | pending |
| PROCESSING | in_progress | Awaiting Shipment | processing |
| SHIPPED | fulfilled | Shipped | completed |
| DELIVERED | fulfilled | Delivered | completed |
| CANCELLED | cancelled | Cancelled | cancelled |
