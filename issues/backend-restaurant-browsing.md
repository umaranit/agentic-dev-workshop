# [BACKEND] Restaurant Browsing API

## User Story
As a customer I want to retrieve a list of restaurants and view the menu for a selected restaurant so that I can browse what is available before adding items to my cart.

## Context
Pre-built from copilot-instructions.md:
- JWT auth middleware: `src/backend/middleware/auth.ts` — use on every endpoint below
- Auth routes: `src/backend/routes/auth.ts` — already registered, do not modify
- Prisma models `Restaurant` and `MenuItem` exist in `schema.prisma` with seed data (Pizza Palace, Burger Barn, 6 menu items)

This issue adds only the two read-only restaurant endpoints. No schema changes are needed.

## API Endpoints

- `GET /api/restaurants` — returns all restaurants
  - Request: none (JWT in Authorization header)
  - Response: `[{ id, name, description }]`
  - Auth: required

- `GET /api/restaurants/:id/menu` — returns all menu items for a restaurant
  - Request: none (JWT in Authorization header)
  - Response: `[{ id, name, description, price }]`
  - Auth: required

## Acceptance Criteria
- [ ] `GET /api/restaurants` returns HTTP 200 with an array containing `id`, `name`, and `description` for every restaurant
- [ ] `GET /api/restaurants/:id/menu` returns HTTP 200 with an array containing `id`, `name`, `description`, and `price` for each menu item belonging to the specified restaurant
- [ ] Both endpoints return HTTP 401 when no valid JWT is provided
- [ ] Both endpoints return `{ error: string }` with an appropriate HTTP status on failure
