# [FRONTEND] Restaurant Browsing UI

## User Story
As a customer I want to see a list of restaurants and navigate to a restaurant's menu page so that I can browse available food items.

## Context
Pre-built from copilot-instructions.md:
- React app entry point and Router: `src/frontend/src/App.tsx` — add new routes here
- Protected route wrapper already exists — use it for both new pages
- Login and Register pages already exist — do not rebuild
- Navbar shell: `src/frontend/src/components/Navbar.tsx` — no changes required in this slice

API endpoints available (from backend-restaurant-browsing issue):
- `GET /api/restaurants` — list all restaurants
- `GET /api/restaurants/:id/menu` — list menu items for a restaurant

## What to Build
- `RestaurantsPage` — full-page list of restaurant cards; each card shows restaurant name and description and is clickable
- `MenuPage` — full-page list of menu items for the selected restaurant; each item shows name, description, and price; includes a back button to return to the restaurant list
- API service functions in `src/frontend/src/services/` to call both endpoints

## data-testid Values
Every interactive and key display element must have a data-testid. Playwright tests will use these — list them explicitly:
- `restaurant-list` — on the container wrapping all restaurant cards
- `restaurant-card` — on each individual restaurant card (multiple)
- `restaurant-name` — on the restaurant name element within each card
- `menu-item-list` — on the container wrapping all menu items
- `menu-item` — on each individual menu item row (multiple)
- `menu-item-name` — on the name element within each menu item row
- `menu-item-price` — on the price element within each menu item row
- `add-to-cart-button` — on the "Add to Cart" button within each menu item row (rendered in this slice; wire up in the shopping cart slice)
- `back-button` — on the back button on the menu page

## Acceptance Criteria
- [ ] Authenticated users see the restaurant list page with every restaurant's name and description displayed
- [ ] Clicking a restaurant card navigates the user to that restaurant's menu page, which lists every menu item with name, description, and price
- [ ] The menu page includes a back button that returns the user to the restaurant list
- [ ] All data-testid values listed above are present on their correct elements
