---
name: shopify-api-patterns
description: Common Shopify Admin GraphQL API patterns for product queries, metafield operations, webhooks, and bulk operations. Auto-invoked when working with Shopify API integration.
allowed-tools: [Read, Edit, Write, Grep, Glob]
---

# Shopify API Patterns Skill

## Purpose
Provides reusable patterns for common Shopify Admin GraphQL API operations including product queries, metafield management, webhook handling, and bulk operations.

## When This Skill Activates
- Working with Shopify Admin GraphQL API
- Querying products, variants, customers, or orders
- Managing metafields
- Implementing webhooks
- Handling bulk operations
- Implementing rate limiting

## Core Patterns

### 1. Product Query with Pagination
```graphql
query getProducts($first: Int!, $after: String) {
  products(first: $first, after: $after) {
    edges {
      node {
        id
        title
        vendor
        handle
        productType
        tags
        variants(first: 10) {
          edges {
            node {
              id
              title
              price
              sku
            }
          }
        }
      }
      cursor
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

### 2. Metafield Query Pattern
```graphql
query getProductMetafields($productId: ID!) {
  product(id: $productId) {
    id
    title
    metafields(first: 20, namespace: "custom") {
      edges {
        node {
          id
          namespace
          key
          value
          type
        }
      }
    }
  }
}
```

### 3. Metafield Update Mutation
```graphql
mutation updateMetafields($metafields: [MetafieldsSetInput!]!) {
  metafieldsSet(metafields: $metafields) {
    metafields {
      id
      namespace
      key
      value
      type
    }
    userErrors {
      field
      message
    }
  }
}
```

**Usage Example:**
```typescript
const response = await admin.graphql(UPDATE_METAFIELDS, {
  variables: {
    metafields: [
      {
        ownerId: "gid://shopify/Product/123",
        namespace: "custom",
        key: "color",
        value: "Red",
        type: "single_line_text_field",
      },
    ],
  },
});
```

### 4. Metafield Definition Creation
```graphql
mutation createMetafieldDefinition($definition: MetafieldDefinitionInput!) {
  metafieldDefinitionCreate(definition: $definition) {
    createdDefinition {
      id
      name
      namespace
      key
      type
      ownerType
    }
    userErrors {
      field
      message
    }
  }
}
```

**Usage:**
```typescript
await admin.graphql(CREATE_METAFIELD_DEFINITION, {
  variables: {
    definition: {
      name: "Product Color",
      namespace: "custom",
      key: "color",
      type: "single_line_text_field",
      ownerType: "PRODUCT",
    },
  },
});
```

### 5. Webhook Registration
```graphql
mutation registerWebhook($topic: WebhookSubscriptionTopic!, $webhookSubscription: WebhookSubscriptionInput!) {
  webhookSubscriptionCreate(topic: $topic, webhookSubscription: $webhookSubscription) {
    webhookSubscription {
      id
      topic
      endpoint {
        __typename
        ... on WebhookHttpEndpoint {
          callbackUrl
        }
      }
    }
    userErrors {
      field
      message
    }
  }
}
```

**Common Topics:**
- `PRODUCTS_CREATE`
- `PRODUCTS_UPDATE`
- `PRODUCTS_DELETE`
- `ORDERS_CREATE`
- `CUSTOMERS_CREATE`

### 6. Pagination Helper
```typescript
async function fetchAllProducts(admin) {
  let hasNextPage = true;
  let cursor = null;
  const allProducts = [];

  while (hasNextPage) {
    const response = await admin.graphql(GET_PRODUCTS, {
      variables: { first: 250, after: cursor },
    });

    const data = await response.json();

    if (data.errors) {
      throw new Error(`GraphQL error: ${data.errors[0].message}`);
    }

    const products = data.data.products.edges.map(edge => edge.node);
    allProducts.push(...products);

    hasNextPage = data.data.products.pageInfo.hasNextPage;
    cursor = data.data.products.pageInfo.endCursor;

    // Rate limiting check
    const rateLimitCost = response.headers.get("X-Shopify-Shop-Api-Call-Limit");
    if (rateLimitCost) {
      const [used, total] = rateLimitCost.split("/").map(Number);
      if (used > total * 0.8) {
        await new Promise(resolve => setTimeout(resolve, 1000));
      }
    }
  }

  return allProducts;
}
```

### 7. Bulk Operation Pattern
```graphql
mutation bulkOperationRunQuery {
  bulkOperationRunQuery(
    query: """
    {
      products {
        edges {
          node {
            id
            title
            metafields {
              edges {
                node {
                  namespace
                  key
                  value
                }
              }
            }
          }
        }
      }
    }
    """
  ) {
    bulkOperation {
      id
      status
    }
    userErrors {
      field
      message
    }
  }
}
```

**Check Status:**
```graphql
query {
  currentBulkOperation {
    id
    status
    errorCode
    createdAt
    completedAt
    objectCount
    fileSize
    url
  }
}
```

**Download and Process Results:**
```typescript
async function processBulkOperationResults(url: string) {
  const response = await fetch(url);
  const jsonl = await response.text();

  const lines = jsonl.trim().split("\n");
  const results = lines.map(line => JSON.parse(line));

  return results;
}
```

### 8. Rate Limiting Handler
```typescript
async function graphqlWithRetry(admin, query, variables, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await admin.graphql(query, { variables });

      // Check rate limit
      const rateLimitCost = response.headers.get("X-Shopify-Shop-Api-Call-Limit");
      if (rateLimitCost) {
        const [used, total] = rateLimitCost.split("/").map(Number);
        console.log(`API calls: ${used}/${total}`);

        if (used > total * 0.9) {
          console.warn("Approaching rate limit, slowing down...");
          await new Promise(resolve => setTimeout(resolve, 2000));
        }
      }

      const data = await response.json();

      if (data.errors) {
        throw new Error(`GraphQL error: ${data.errors[0].message}`);
      }

      return data;
    } catch (error) {
      if (error.message.includes("Throttled") && i < maxRetries - 1) {
        const delay = Math.pow(2, i) * 1000; // Exponential backoff
        console.log(`Rate limited, retrying in ${delay}ms...`);
        await new Promise(resolve => setTimeout(resolve, delay));
        continue;
      }
      throw error;
    }
  }
}
```

## Best Practices

1. **Pagination** - Always use cursor-based pagination for large result sets
2. **Field Selection** - Only request fields you need to reduce response size
3. **Rate Limiting** - Monitor API call limits and implement backoff
4. **Error Handling** - Check both `errors` and `userErrors` in responses
5. **Bulk Operations** - Use for processing 1000+ products
6. **Metafield Types** - Use appropriate types (single_line_text_field, number_integer, json, etc.)
7. **Webhook Verification** - Always verify HMAC signatures
8. **Caching** - Cache frequently accessed data like metafield definitions
9. **Retry Logic** - Implement exponential backoff for transient failures
10. **Logging** - Log API calls and errors for debugging

## Common Metafield Types

- `single_line_text_field` - Short text
- `multi_line_text_field` - Long text
- `number_integer` - Whole numbers
- `number_decimal` - Decimal numbers
- `json` - Structured data
- `color` - Color values
- `url` - URLs
- `boolean` - True/false
- `date` - Date values
- `list.single_line_text_field` - Array of strings

## Quick Reference

### Get Product by Handle
```graphql
query getProductByHandle($handle: String!) {
  productByHandle(handle: $handle) {
    id
    title
    vendor
  }
}
```

### Get Product Variants
```graphql
query getProductVariants($productId: ID!) {
  product(id: $productId) {
    variants(first: 100) {
      edges {
        node {
          id
          title
          price
          sku
          inventoryQuantity
        }
      }
    }
  }
}
```

### Update Product
```graphql
mutation productUpdate($input: ProductInput!) {
  productUpdate(input: $input) {
    product {
      id
      title
    }
    userErrors {
      field
      message
    }
  }
}
```

---

**Remember**: Always check the Shopify Admin API documentation for the latest schema and deprecations.
