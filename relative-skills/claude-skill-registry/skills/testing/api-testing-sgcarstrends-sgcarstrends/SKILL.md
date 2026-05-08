---
name: api-testing
description: Test and debug Next.js API routes, validate responses, check authentication, and troubleshoot API errors. Use when testing API endpoints, debugging 500 errors, validating API responses, or checking authentication flows.
allowed-tools: Read, Bash, Grep, Glob
---

# API Testing & Debugging

Expert assistance for testing and debugging Next.js API routes in the MantisNXT project.

## Capabilities

- **API Route Testing**: Test GET, POST, PUT, DELETE endpoints
- **Response Validation**: Verify JSON responses and status codes
- **Authentication Testing**: Validate auth flows and protected routes
- **Error Debugging**: Diagnose 400, 401, 403, 404, 500 errors
- **Performance Testing**: Check API response times

## Quick Testing Commands

### Test API Endpoints

```bash
# Test inventory API
curl -s "http://localhost:3000/api/inventory?limit=5"

# Test analytics API
curl -s "http://localhost:3000/api/analytics/recommendations?limit=5"

# Test supplier API
curl -s "http://localhost:3000/api/suppliers"

# Test stock movements
curl -s "http://localhost:3000/api/stock-movements?limit=5"

# Test health check
curl -s "http://localhost:3000/api/health"
```

### Test with Authentication

```bash
# Login and get token
TOKEN=$(curl -s -X POST "http://localhost:3000/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}' \
  | jq -r '.token')

# Use token for authenticated request
curl -s "http://localhost:3000/api/protected-route" \
  -H "Authorization: Bearer $TOKEN"
```

### Test POST Endpoints

```bash
# Test creating inventory item
curl -X POST "http://localhost:3000/api/inventory" \
  -H "Content-Type: application/json" \
  -d '{
    "sku": "TEST-001",
    "name": "Test Product",
    "quantity": 100
  }'

# Test pricelist upload
curl -X POST "http://localhost:3000/api/suppliers/pricelists/upload" \
  -F "file=@path/to/pricelist.xlsx" \
  -F "supplierId=123"
```

## API Routes Location

All API routes are in `src/app/api/`:

```
src/app/api/
├── auth/
│   ├── login/route.ts
│   └── status/route.ts
├── inventory/route.ts
├── suppliers/
│   ├── route.ts
│   └── pricelists/upload/route.ts
├── analytics/
│   ├── recommendations/route.ts
│   └── predictions/route.ts
├── stock-movements/route.ts
├── health/route.ts
└── upload/route.ts
```

## Common Debugging Steps

### 500 Internal Server Error

1. Check server logs for error details
2. Verify database connection
3. Check for missing environment variables
4. Validate request payload matches expected schema
5. Look for unhandled Promise rejections

### 404 Not Found

1. Verify route file exists at correct path
2. Check route file exports Route Handler correctly
3. Ensure dynamic segments match request

### 401 Unauthorized

1. Check authentication middleware
2. Verify token is valid and not expired
3. Check Authorization header format
4. Validate user permissions

### 400 Bad Request

1. Validate request payload structure
2. Check required fields are present
3. Verify data types match expectations
4. Review validation schema

## Response Format Standards

All API responses should follow this structure:

```typescript
// Success response
{
  "success": true,
  "data": { /* response data */ },
  "message": "Operation completed successfully"
}

// Error response
{
  "success": false,
  "error": "Error message",
  "details": { /* additional error info */ }
}
```

## Testing Checklist

- [ ] Test happy path scenarios
- [ ] Test error cases (invalid input, missing fields)
- [ ] Test authentication (with/without token)
- [ ] Test authorization (correct permissions)
- [ ] Test edge cases (empty arrays, null values)
- [ ] Verify response status codes
- [ ] Check response payload structure
- [ ] Test pagination parameters
- [ ] Validate query parameter handling

## Performance Testing

```bash
# Quick response time check
time curl -s "http://localhost:3000/api/inventory" > /dev/null

# Test concurrent requests
for i in {1..10}; do
  curl -s "http://localhost:3000/api/health" &
done
wait
```

## Best Practices

1. **Always test locally first** before deploying
2. **Use meaningful test data** that represents real scenarios
3. **Check logs** for detailed error information
4. **Test auth flows** separately from business logic
5. **Validate all status codes** match expectations
6. **Use TypeScript types** to catch errors early
7. **Handle all error cases** gracefully

## Environment Variables

Required for API testing:

```env
DATABASE_URL=postgresql://...
NEXT_PUBLIC_API_URL=http://localhost:3000
NODE_ENV=development
```
