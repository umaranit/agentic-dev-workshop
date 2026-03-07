# [FRONTEND] Shopping Cart UI

## User Story
As a customer I want to add items to my cart, see the live cart count in the Navbar, and manage quantities and removals in a cart drawer so that I can review and adjust my order before checking out.

## Context
Pre-built from copilot-instructions.md:
- Navbar shell: `src/frontend/src/components/Navbar.tsx` — add cart icon with badge here
- React app entry point and Router: `src/frontend/src/App.tsx`
- `add-to-cart-button` data-testid already rendered on the menu page (see frontend-restaurant-browsing issue)

API endpoints available (from backend-shopping-cart issue):
- `GET /api/cart` — fetch current cart with items
- `POST /api/cart/items` — add item (creates cart if needed, increments if duplicate)
- `PUT /api/cart/items/:id` — update item quantity
- `DELETE /api/cart/items/:id` — remove item

## What to Build
- `CartContext` — React context in `src/frontend/src/context/` providing cart state, total item count, and actions (add, update quantity, remove); consumed by Navbar and CartDrawer
- `CartIcon` — added to the existing Navbar shell; displays a badge with the live total quantity of all cart items
- `CartDrawer` — slide-in panel showing all cart items (name, unit price, quantity, line total), cart total at the bottom, +/- quantity buttons per item, and a Remove button per item

## data-testid Values
Every interactive and key display element must have a data-testid. Playwright tests will use these — list them explicitly:
- `cart-icon` — on the cart icon button in the Navbar
- `cart-count-badge` — on the quantity badge inside the cart icon
- `cart-drawer` — on the cart drawer container element
- `cart-item` — on each cart item row in the drawer (multiple)
- `cart-item-name` — on the item name element within each cart item row
- `cart-item-quantity` — on the quantity display within each cart item row
- `cart-item-line-total` — on the line total element within each cart item row
- `cart-item-increment` — on the + button within each cart item row
- `cart-item-decrement` — on the − button within each cart item row
- `cart-item-remove` — on the Remove button within each cart item row
- `cart-total` — on the cart total element at the bottom of the drawer

## Acceptance Criteria
- [ ] After clicking "Add to Cart" on a menu item, the `cart-count-badge` increments to reflect the updated total quantity across all items
- [ ] Opening the cart drawer via the cart icon shows all cart items with name, unit price, quantity, line total, and a remove button; the cart total is shown at the bottom
- [ ] Clicking + or − on a cart item updates the quantity, line total, and cart total in real time; clicking − on a quantity of 1 removes the item
- [ ] Clicking the Remove button deletes the item from the cart and the cart total updates immediately
- [ ] All data-testid values listed above are present on their correct elements
