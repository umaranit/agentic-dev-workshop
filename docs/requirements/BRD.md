# Business Requirements Document
**Project:** FoodOrder — Restaurant Browsing and Shopping Cart  
**Date:** 2026-03-06  
**Source:** Issue #2 — [REQUIREMENT] Food Order App

## 1. Summary

FoodOrder is a web application where authenticated customers can browse a list of available restaurants, view the menu for each restaurant, and manage a personalised shopping cart. Customers add menu items to their cart, adjust quantities using +/- controls, and remove items as needed. A cart icon in the navigation bar displays the live total quantity across all cart items, and a cart drawer provides a full view of the cart including per-item line totals and the overall cart total. Cart state persists for the duration of the user's authenticated session.

---

## 2. User Roles

| Role | Description |
|------|-------------|
| Customer | Authenticated user who browses restaurants, views menus, and manages their shopping cart |
| System | Backend service that stores and retrieves restaurant, menu, and cart data on behalf of the customer |

---

## 3. In Scope

- Restaurant listing page showing all available restaurants (name and description, no images)
- Menu page showing all menu items for a selected restaurant (name, description, price, no images)
- Navigation between restaurant list and menu pages
- "Add to Cart" button on each menu item
- Cart quantity management: +/- buttons to increment or decrement item quantities
- Automatic quantity increment when a duplicate item is added to the cart (no duplicate cart entries)
- Cart icon in the Navbar displaying the total item count (sum of all quantities)
- Cart drawer listing all cart items with name, unit price, quantity, line total, and remove button
- Cart total displayed at the bottom of the cart drawer
- Item removal from cart
- Cart persisted per authenticated user (one cart per user)
- All cart and restaurant endpoints protected by JWT authentication
- Backend REST API: 6 endpoints covering restaurants, menus, and cart operations
- Database models: Cart and CartItem
- Unit tests: happy path per endpoint + authentication test per endpoint + quantity increment test
- E2E test: full user journey (login → browse → view menu → add item → adjust quantity → verify total → remove item)

---

## 4. Out of Scope

- Restaurant or menu item images
- Payment processing or order placement
- Delivery tracking
- Restaurant admin features (create, update, delete restaurants or menu items)
- Restaurant search or filtering
- Menu item customisation (sizes, add-ons, special instructions)
- Advanced UI styling, animations, or transitions
- Empty-state illustrations
- Comprehensive error-handling UI (error boundaries, toast notifications)
- Extensive edge-case testing beyond stated acceptance criteria
- Multi-cart or saved cart functionality
- Guest (unauthenticated) cart

---

## 5. Functional Requirements

| ID | Requirement | Acceptance Criteria |
|----|-------------|---------------------|
| FR-001 | The system shall provide an API endpoint that returns a list of all restaurants | 1. `GET /api/restaurants` returns HTTP 200 with an array of restaurant objects (id, name, description). 2. `GET /api/restaurants` returns HTTP 401 when no valid JWT is provided. |
| FR-002 | The system shall provide an API endpoint that returns all menu items for a specified restaurant | 1. `GET /api/restaurants/:id/menu` returns HTTP 200 with an array of menu item objects (id, name, description, price) for the given restaurant. 2. `GET /api/restaurants/:id/menu` returns HTTP 401 when no valid JWT is provided. |
| FR-003 | The system shall display a restaurant listing page showing all available restaurants | 1. Authenticated users see a page listing every restaurant card with name and description. 2. Clicking a restaurant card navigates the user to that restaurant's menu page. |
| FR-004 | The system shall display a menu page showing all items for the selected restaurant | 1. The menu page lists every menu item for the selected restaurant with name, description, and price. 2. Each menu item has an "Add to Cart" button; a back button returns the user to the restaurant list. |
| FR-005 | The system shall provide an API endpoint to retrieve the current user's cart and its items | 1. `GET /api/cart` returns HTTP 200 with the cart object containing all CartItems (menuItemId, quantity, MenuItem details). 2. `GET /api/cart` returns HTTP 401 when no valid JWT is provided. |
| FR-006 | The system shall provide an API endpoint to add a menu item to the cart | 1. `POST /api/cart/items` with `{ menuItemId, quantity: 1 }` creates a new CartItem and returns HTTP 201 if the item is not already in the cart. 2. `POST /api/cart/items` increments the existing CartItem quantity and returns HTTP 200 if the item is already in the cart. |
| FR-007 | The system shall provide an API endpoint to update the quantity of a cart item | 1. `PUT /api/cart/items/:id` with `{ quantity }` updates the CartItem and returns HTTP 200 with the updated item. 2. `PUT /api/cart/items/:id` returns HTTP 404 when the specified CartItem does not exist. |
| FR-008 | The system shall provide an API endpoint to remove an item from the cart | 1. `DELETE /api/cart/items/:id` removes the CartItem and returns HTTP 204. 2. `DELETE /api/cart/items/:id` returns HTTP 404 when the specified CartItem does not exist. |
| FR-009 | The Navbar shall display a cart icon with a live badge showing the total quantity of all cart items | 1. After adding an item, the badge count increments to reflect the updated total quantity. 2. After removing an item or reducing quantity to zero, the badge count decrements accordingly. |
| FR-010 | The system shall provide a cart drawer that displays all cart items and the cart total | 1. Opening the cart drawer shows every CartItem with name, unit price, quantity, and line total (price × quantity). 2. The cart drawer displays the sum of all line totals as the cart total at the bottom. |
| FR-011 | The cart drawer shall allow quantity adjustment using +/- buttons | 1. Clicking + increases the item quantity by 1 and updates the line total and cart total in real time. 2. Clicking − decreases the item quantity by 1 and updates the line total and cart total in real time. |
| FR-012 | The cart drawer shall allow complete removal of an item | 1. Clicking the Remove button on a cart item deletes it from the cart and removes it from the drawer. 2. The cart total updates immediately after item removal. |
| FR-013 | The system shall persist one cart per authenticated user | 1. A cart is automatically created on the first item addition if one does not already exist for the user. 2. The cart and its items are retrievable across page refreshes within the same authenticated session. |

---

## 6. Non-Functional Requirements

| ID | Category | Requirement |
|----|----------|-------------|
| NFR-001 | Security | All cart and restaurant API endpoints require a valid JWT; unauthenticated requests receive HTTP 401 |
| NFR-002 | Security | Cart data is user-scoped; a user may only read or modify their own cart |
| NFR-003 | Performance | API responses and page transitions complete within 3 seconds under normal load |
| NFR-004 | Usability | Application is functional on desktop and mobile viewports (responsive layout) |
| NFR-005 | Code Quality | TypeScript strict mode enforced; no `any` types permitted |
| NFR-006 | Code Quality | All asynchronous operations use async/await; no raw Promise chains |
| NFR-007 | Testability | All interactive UI elements carry a `data-testid` attribute |
| NFR-008 | Maintainability | API errors return `{ error: string }` with the appropriate HTTP status code |

---

## 7. Assumptions

- **Issue #2 content:** Issue #2 is the workshop requirement issue titled "[REQUIREMENT] Food Order App", describing the Restaurant Browsing and Shopping Cart feature. This assumption is based on the workshop README and facilitator materials which indicate this is the sole feature requirement for the workshop.
- **Authentication pre-built:** User login and registration are already implemented. The BRD covers only the restaurant browsing and cart features; auth is not in scope.
- **Single cart per user:** Each user has at most one cart. This is created automatically on the first item add and reused thereafter.
- **Duplicate item handling:** If a user adds a menu item that is already in their cart, the system increments the existing CartItem quantity rather than creating a second entry.
- **No order placement:** The cart is a holding area only. Checkout, payment, and order fulfilment are explicitly out of scope.
- **Seed data assumed present:** The BRD assumes 2 restaurants (Pizza Palace, Burger Barn) and 6 menu items exist in the database via the existing seed script, and that these are sufficient for all testing scenarios.
- **No images required:** All restaurant and menu item displays are text-only, consistent with the 4-hour workshop timeline constraint.
- **Cart icon location:** The cart icon with badge is placed in the existing Navbar component shell, which currently contains no functional elements.
- **Quantity floor:** The minimum cart item quantity is 1. Reducing quantity below 1 removes the item from the cart (edge-case handling is noted but not required in this scope).
