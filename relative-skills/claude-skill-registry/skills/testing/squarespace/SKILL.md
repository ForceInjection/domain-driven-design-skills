---
name: squarespace
description: Squarespace API and design system integration
---

# Squarespace Best Practices

## Currency Object Complexity

All monetary values must use `SquarespaceMoney` objects:
- Consistent currency handling across all price fields
- Proper decimal precision for currency calculations
- Exchange rate handling for multi-currency scenarios

## Design System Integration

Products must consider Squarespace's design system:
- Image sizing and optimization requirements
- Template compatibility considerations
- Color and styling consistency
- Responsive design requirements

## POS Integration

Handle POS vs online order differentiation:

```java
if (SquarespaceOrderUtils.isPosOrder(order)) {
  applyPosOrderHandling(order);
} else {
  applyOnlineOrderHandling(order);
}
```

## Inventory Synchronization

Sync inventory across POS and online channels:

```java
private void syncInventoryAcrossChannels(SquarespaceProduct product) {
  for (SquarespaceVariant variant : product.getVariants()) {
    updatePosInventory(variant);
    updateOnlineInventory(variant);
  }
}
```

## Testing Patterns

### Test Structure
- Tests in `src/test/java/io/drizzl/platform/ecom/platforms/squarespace/`
- Use `@SpringBootTest` with Squarespace-specific mocks
- JSON fixtures in `src/test/resources/platform/squarespace/`

### Mock Examples
```java
@MockBean
private SquarespaceServiceClientFactory sqServiceClientFactory;

@MockBean
private SquarespaceOrderComposerUtils orderComposerUtils;

when(merchantConfiguration.shouldUseContextualPrices()).thenReturn(true);
```

## Platform-Specific Considerations

### Website Integration
- Products integrated into website design templates
- SEO considerations for product pages
- Content management integration

### Member Areas
- Customer account functionality
- Subscription and membership products
- Access control for digital products

### Tax Interpretation Flags
```java
order.setTaxInterpretation(SquarespaceTaxInterpretation.INCLUSIVE);
// or
order.setTaxInterpretation(SquarespaceTaxInterpretation.EXCLUSIVE);
```

## Debugging Tools

### Commerce API Testing
```java
// Test Squarespace Commerce API endpoints
String apiUrl = "https://api.squarespace.com/1.0/commerce/orders";
// Include proper authentication and currency objects
```

### Template Testing
- Test product display in different templates
- Verify checkout flow in various designs
- Check mobile responsiveness

### POS Integration Testing
- Test inventory sync between POS and online
- Verify order processing from both channels
- Check customer data synchronization

## Migration Guidelines

### API Version Updates
- Stay current with Squarespace Commerce API versions
- Handle breaking changes in currency object structure
- Test with different template configurations

## Integration Checklist

- [ ] Currency objects used for all monetary values
- [ ] Contextual pricing with exchange rates tested
- [ ] Fulfillment status mapping complete
- [ ] Refund tracking with currency objects
- [ ] POS vs online order differentiation
- [ ] Inventory sync across channels
- [ ] Design system integration verified
- [ ] Member area access tested
- [ ] Tax interpretation flags set correctly
- [ ] Template compatibility verified
