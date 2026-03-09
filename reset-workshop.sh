#!/bin/bash

# =============================================================================
# reset-workshop.sh
# Resets the workshop repo to a clean starting state.
# Run this between cohorts or before starting fresh.
# Usage: bash reset-workshop.sh
# =============================================================================

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$REPO_ROOT/src/backend"
PRISMA_DIR="$BACKEND_DIR/prisma"
ISSUES_DIR="$REPO_ROOT/issues"
DOCS_DIR="$REPO_ROOT/docs"

echo ""
echo "======================================"
echo "  Workshop Reset Script"
echo "======================================"
echo ""

# --- Step 1: Confirm ---
read -p "This will reset the repo to workshop starting state. Continue? (y/n): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Aborted."
  exit 0
fi

echo ""
echo "Step 1/8 — Removing generated docs..."
rm -f "$DOCS_DIR/requirements/BRD.md"
rm -f "$DOCS_DIR/design/design-doc.md"
echo "         ✅ BRD.md and design-doc.md removed"

echo ""
echo "Step 2/8 — Removing issue files..."
find "$ISSUES_DIR" -name "*.md" -not -name ".gitkeep" -delete
echo "         ✅ Issue files removed"

echo ""
echo "Step 3/8 — Resetting schema.prisma to User model only..."
cat > "$PRISMA_DIR/schema.prisma" << 'SCHEMA'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "sqlite"
  url      = env("DATABASE_URL")
}

// PRE-BUILT — do not modify
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  password  String
  name      String
  createdAt DateTime @default(now())
}

// All domain models are added during the workshop by agents
SCHEMA
echo "         ✅ schema.prisma reset to User model only"

echo ""
echo "Step 4/8 — Resetting seed.ts to test user only..."
cat > "$PRISMA_DIR/seed.ts" << 'SEED'
import { PrismaClient } from '@prisma/client'
import bcrypt from 'bcryptjs'

const prisma = new PrismaClient()

async function main() {
  const hashedPassword = await bcrypt.hash('password123', 10)

  await prisma.user.upsert({
    where: { email: 'test@example.com' },
    update: {},
    create: {
      email: 'test@example.com',
      password: hashedPassword,
      name: 'Test User',
    },
  })

  console.log('Seed complete — test user ready')
  // Domain seed data is added by agents during the workshop
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
SEED
echo "         ✅ seed.ts reset to test user only"

echo ""
echo "Step 5/8 — Deleting old migrations and database..."
rm -rf "$PRISMA_DIR/migrations"
rm -f "$PRISMA_DIR/dev.db"
echo "         ✅ Migrations and dev.db deleted"

echo ""
echo "Step 6/8 — Running fresh migration..."
cd "$BACKEND_DIR"
npx prisma migrate dev --name init --skip-seed
echo "         ✅ Clean migration created (User table only)"

echo ""
echo "Step 7/8 — Seeding test user..."
npx prisma db seed
echo "         ✅ Test user seeded (test@example.com / password123)"

echo ""
echo "Step 8/8 — Verifying migration is clean..."
MIGRATION_FILE=$(find "$PRISMA_DIR/migrations" -name "migration.sql" | head -1)
if grep -q "CREATE TABLE" "$MIGRATION_FILE"; then
  TABLE_COUNT=$(grep -c "CREATE TABLE" "$MIGRATION_FILE")
  if [ "$TABLE_COUNT" -eq 1 ]; then
    echo "         ✅ Migration contains exactly 1 table (User)"
  else
    echo "         ⚠️  Migration contains $TABLE_COUNT tables — check schema.prisma"
    echo "            Expected: User only"
    grep "CREATE TABLE" "$MIGRATION_FILE"
  fi
fi

echo ""
echo "======================================"
echo "  Reset Complete ✅"
echo "======================================"
echo ""
echo "  Starting state:"
echo "  • schema.prisma — User model only"
echo "  • seed.ts       — test user only"
echo "  • migrations    — clean init migration"
echo "  • issues/       — empty (only .gitkeep)"
echo "  • docs/         — no BRD or design doc"
echo ""
echo "  Next steps:"
echo "  1. Commit and push to main"
echo "  2. Close all open Issues on GitHub"
echo "  3. Set VITE_APP_NAME in src/frontend/.env"
echo "  4. Create Issue #1 with the workshop requirement"
echo "  5. Start the workshop!"
echo ""
