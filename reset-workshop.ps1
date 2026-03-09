# =============================================================================
# reset-workshop.ps1
# Resets the workshop repo to a clean starting state.
# Run this between cohorts or before starting fresh.
# Usage: .\reset-workshop.ps1
# =============================================================================

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$BackendDir = Join-Path $RepoRoot "src\backend"
$PrismaDir = Join-Path $BackendDir "prisma"
$IssuesDir = Join-Path $RepoRoot "issues"
$DocsDir = Join-Path $RepoRoot "docs"

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  Workshop Reset Script" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# --- Step 1: Confirm ---
$confirm = Read-Host "This will reset the repo to workshop starting state. Continue? (y/n)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "Aborted." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Step 1/8 — Removing generated docs..." -ForegroundColor White
$brdPath = Join-Path $DocsDir "requirements\BRD.md"
$designPath = Join-Path $DocsDir "design\design-doc.md"
if (Test-Path $brdPath) { Remove-Item $brdPath -Force }
if (Test-Path $designPath) { Remove-Item $designPath -Force }
Write-Host "         OK BRD.md and design-doc.md removed" -ForegroundColor Green

Write-Host ""
Write-Host "Step 2/8 — Removing issue files..." -ForegroundColor White
Get-ChildItem -Path $IssuesDir -Filter "*.md" | Where-Object { $_.Name -ne ".gitkeep" } | Remove-Item -Force
Write-Host "         OK Issue files removed" -ForegroundColor Green

Write-Host ""
Write-Host "Step 3/8 — Resetting schema.prisma to User model only..." -ForegroundColor White
$schemaContent = @'
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
'@
Set-Content -Path (Join-Path $PrismaDir "schema.prisma") -Value $schemaContent -Encoding UTF8
Write-Host "         OK schema.prisma reset to User model only" -ForegroundColor Green

Write-Host ""
Write-Host "Step 4/8 — Resetting seed.ts to test user only..." -ForegroundColor White
$seedContent = @'
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
'@
Set-Content -Path (Join-Path $PrismaDir "seed.ts") -Value $seedContent -Encoding UTF8
Write-Host "         OK seed.ts reset to test user only" -ForegroundColor Green

Write-Host ""
Write-Host "Step 5/8 — Deleting old migrations and database..." -ForegroundColor White
$migrationsPath = Join-Path $PrismaDir "migrations"
$devDbPath = Join-Path $PrismaDir "dev.db"
if (Test-Path $migrationsPath) { Remove-Item $migrationsPath -Recurse -Force }
if (Test-Path $devDbPath) { Remove-Item $devDbPath -Force }
Write-Host "         OK Migrations and dev.db deleted" -ForegroundColor Green

Write-Host ""
Write-Host "Step 6/8 — Running fresh migration..." -ForegroundColor White
Set-Location $BackendDir
npx prisma migrate dev --name init --skip-seed
Write-Host "         OK Clean migration created (User table only)" -ForegroundColor Green

Write-Host ""
Write-Host "Step 7/8 — Seeding test user..." -ForegroundColor White
npx prisma db seed
Write-Host "         OK Test user seeded (test@example.com / password123)" -ForegroundColor Green

Write-Host ""
Write-Host "Step 8/8 — Verifying migration is clean..." -ForegroundColor White
$migrationFile = Get-ChildItem -Path $migrationsPath -Filter "migration.sql" -Recurse | Select-Object -First 1
if ($migrationFile) {
    $migrationContent = Get-Content $migrationFile.FullName -Raw
    $tableCount = ([regex]::Matches($migrationContent, "CREATE TABLE")).Count
    if ($tableCount -eq 1) {
        Write-Host "         OK Migration contains exactly 1 table (User)" -ForegroundColor Green
    } else {
        Write-Host "         WARNING Migration contains $tableCount tables — check schema.prisma" -ForegroundColor Yellow
        Write-Host "                 Expected: User only" -ForegroundColor Yellow
        [regex]::Matches($migrationContent, 'CREATE TABLE "\w+"') | ForEach-Object { Write-Host "                 Found: $($_.Value)" -ForegroundColor Yellow }
    }
}

Set-Location $RepoRoot

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  Reset Complete" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Starting state:" -ForegroundColor White
Write-Host "  * schema.prisma — User model only" -ForegroundColor Gray
Write-Host "  * seed.ts       — test user only" -ForegroundColor Gray
Write-Host "  * migrations    — clean init migration" -ForegroundColor Gray
Write-Host "  * issues/       — empty (only .gitkeep)" -ForegroundColor Gray
Write-Host "  * docs/         — no BRD or design doc" -ForegroundColor Gray
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor White
Write-Host "  1. Commit and push to main" -ForegroundColor Gray
Write-Host "  2. Close all open Issues on GitHub" -ForegroundColor Gray
Write-Host "  3. Set VITE_APP_NAME in src/frontend/.env" -ForegroundColor Gray
Write-Host "  4. Create Issue #1 with the workshop requirement" -ForegroundColor Gray
Write-Host "  5. Start the workshop!" -ForegroundColor Gray
Write-Host ""
