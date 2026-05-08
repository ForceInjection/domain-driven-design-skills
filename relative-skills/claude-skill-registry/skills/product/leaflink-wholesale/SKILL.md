---
name: LeafLink Wholesale
description: Manage wholesale inventory, products, and orders via LeafLink API.
---

# LeafLink Skill

## Capabilities
- **Orders**: View incoming wholesale orders (`leaflink.list_orders`).
- **Products**: List wholesale catalog (`leaflink.list_products`).
- **Inventory**: Update stock levels for specific products (`leaflink.update_inventory`).

## Usage
- Use for "B2B", "Wholesale", or "Distributor" related queries.
- Use `leaflink.update_inventory` when the user explicitly asks to "set stock" or "update quantity".

## Constraints
- Requires user authentication via `requireUser`.
- Requires LeafLink API key in user settings.
