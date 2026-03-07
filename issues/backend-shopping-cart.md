# [BACKEND] Shopping Cart API

## User Story
As a customer I want to retrieve, add to, update, and remove items from my cart via the API so that my cart persists and stays accurate.

## Context
Pre-built from copilot-instructions.md:
- JWT auth middleware: `src/backend/middleware/auth.ts` — required on every endpoint below
- `Cart` and `CartItem` Prisma models added in the database-shopping-cart issue

This issue adds the four cart endpoints only. Restaurant endpoints are covered in the backend-restaurant-browsing issue.

## API Endpoints

- `GET /api/cart` — retrieve the current user's cart and all its items
  - Request: none (JWT in Authorization header)
  - Response: `{ id, userId, items: [{ id, menuItemId, quantity, menuItem: { id, name, description, price } }] }`
  - Auth: required

- `POST /api/cart/items` — add a menu item to the cart
  - Request: `{ menuItemId: number, quantity: number }`
  - Response on create: HTTP 201 with the new CartItem
  - Response when item already in cart: HTTP 200 with the updated CartItem (quantity incremented)
  - Auth: required

- `PUT /api/cart/items/:id` — update the quantity of a cart item
  - Request: `{ quantity: number }`
  - Response: HTTP 200 with the updated CartItem
  - Response when not found: HTTP 404 with `{ error: string }`
  - Auth: required

- `DELETE /api/cart/items/:id` — remove an item from the cart
  - Request: none
  - Response: HTTP 204 (no body)
  - Response when not found: HTTP 404 with `{ error: string }`
  - Auth: required

## Acceptance Criteria
- [ ] `GET /api/cart` returns HTTP 200 with the user's cart including all CartItems and their related MenuItem details
- [ ] `POST /api/cart/items` returns HTTP 201 when the item is new to the cart and HTTP 200 with incremented quantity when it already exists; a Cart is created automatically if one does not yet exist for the user
- [ ] `PUT /api/cart/items/:id` returns HTTP 200 with the updated item, or HTTP 404 when the CartItem does not exist
- [ ] `DELETE /api/cart/items/:id` returns HTTP 204 on success, or HTTP 404 when the CartItem does not exist
- [ ] All four endpoints return HTTP 401 when no valid JWT is provided
