# [PLAYWRIGHT] Restaurant Browsing and Shopping Cart

## User Story
As a QA engineer I want to verify the restaurant browsing and shopping cart journey end to end so that I can confirm the full feature works correctly for an authenticated customer.

## Primary Journey — Restaurant Browsing

1. Navigate to the login page — expect the login form to be visible
2. Enter email `test@foodorder.com` and password `password123`, then submit — expect redirect to the restaurant list page
3. Locate the `restaurant-list` container — expect it to be visible with at least one `restaurant-card` element
4. Click the first `restaurant-card` — expect navigation to the menu page and the `menu-item-list` container to be visible
5. Verify at least one `menu-item` is displayed with `menu-item-name` and `menu-item-price` elements — expect the values to be non-empty
6. Click the `back-button` — expect navigation back to the restaurant list page and `restaurant-list` to be visible

## Test Credentials
- Email: test@foodorder.com
- Password: password123

## data-testid Reference
These must match the data-testid values in the FRONTEND issues exactly:
- `restaurant-list` — assert the restaurant listing container is visible
- `restaurant-card` — click to navigate to menu page
- `restaurant-name` — assert restaurant name text is present
- `menu-item-list` — assert the menu item listing container is visible
- `menu-item` — assert individual menu items are rendered
- `menu-item-name` — assert menu item name text is present
- `menu-item-price` — assert menu item price text is present
- `add-to-cart-button` — click to add an item to the cart
- `back-button` — click to return to the restaurant list
- `cart-icon` — click to open the cart drawer
- `cart-count-badge` — assert the live total quantity badge value
- `cart-drawer` — assert the cart drawer is visible after opening
- `cart-item` — assert cart item rows in the drawer
- `cart-item-name` — assert item name in drawer
- `cart-item-quantity` — assert item quantity in drawer
- `cart-item-line-total` — assert line total in drawer
- `cart-item-increment` — click to increase quantity
- `cart-item-decrement` — click to decrease quantity
- `cart-item-remove` — click to remove item from cart
- `cart-total` — assert the overall cart total in drawer

## Acceptance Criteria
- [ ] Full primary journey passes without errors
- [ ] All selectors use data-testid only — no CSS classes or text content selectors
- [ ] The restaurant list and menu page display the correct seed data (Pizza Palace, Burger Barn, their menu items)

---

## Extension Journey — Shopping Cart (run after primary journey)
> Only run if the shopping cart issues (database-shopping-cart, backend-shopping-cart, frontend-shopping-cart) are implemented and merged.

1. From the menu page, locate the first `add-to-cart-button` — expect `cart-count-badge` to show `0` initially
2. Click the first `add-to-cart-button` — expect `cart-count-badge` to increment to `1`
3. Click `add-to-cart-button` on the same item again — expect `cart-count-badge` to show `2` (quantity incremented, not a new entry)
4. Click `cart-icon` — expect `cart-drawer` to be visible
5. Verify one `cart-item` row is visible with correct `cart-item-name`, `cart-item-quantity` showing `2`, and a non-zero `cart-item-line-total`
6. Verify `cart-total` reflects the sum of all line totals
7. Click `cart-item-increment` on the item — expect `cart-item-quantity` to show `3` and `cart-total` to update
8. Click `cart-item-decrement` on the item — expect `cart-item-quantity` to return to `2` and `cart-total` to update
9. Click `cart-item-remove` on the item — expect the `cart-item` row to disappear from the drawer and `cart-count-badge` to return to `0`
