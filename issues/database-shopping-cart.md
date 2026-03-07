# [DATABASE] Shopping Cart Models

## User Story
As a system I need Cart and CartItem models so that each authenticated user's cart and its contents can be stored and retrieved persistently.

## Context
Pre-built models from copilot-instructions.md:
- `User` — already in `schema.prisma`; Cart will have a one-to-one relation with User
- `MenuItem` — already in `schema.prisma`; CartItem will reference MenuItem

This issue adds only the Cart and CartItem models. No existing models are modified.

## Models to Add

**Cart**
- `id`: Int — auto-increment primary key
- `userId`: Int — unique foreign key referencing User
- `createdAt`: DateTime — defaults to now

**CartItem**
- `id`: Int — auto-increment primary key
- `cartId`: Int — foreign key referencing Cart
- `menuItemId`: Int — foreign key referencing MenuItem
- `quantity`: Int — number of this item in the cart
- `createdAt`: DateTime — defaults to now

## Relationships
- `User` has one `Cart` (one-to-one)
- `Cart` has many `CartItem`s
- `CartItem` belongs to one `MenuItem`

## Acceptance Criteria
- [ ] Migration `add-cart` runs without errors (`npx prisma migrate dev --name add-cart`)
- [ ] `Cart` model created with correct fields and a unique constraint on `userId`
- [ ] `CartItem` model created with correct fields referencing `Cart` and `MenuItem`
- [ ] Pre-built `User`, `Restaurant`, and `MenuItem` models and existing seed data remain unchanged
