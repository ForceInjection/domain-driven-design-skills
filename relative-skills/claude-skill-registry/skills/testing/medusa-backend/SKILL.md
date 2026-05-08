---
name: medusa-backend
description: Complete Medusa backend API reference and integration guide
---

# Medusa Backend Skill

Complete documentation for Medusa e-commerce backend.

## API Endpoints

### Products
- GET /store/products - List products
- GET /store/products/:id - Get single product

### Cart
- POST /store/carts - Create cart
- POST /store/carts/:id/line-items - Add item
- POST /store/carts/:id/complete - Checkout

### Orders
- GET /store/orders - List orders
- GET /store/orders/:id - Get order

### Customers
- POST /store/customers - Register
- POST /store/auth/login - Login
- GET /store/customers/me - Get me

See references/ for more documentation.
