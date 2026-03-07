# Agentic SDLC Workshop — Flow Reference

> One business requirement → tested, working code → driven by AI agents at every step.

---

## The Two Inputs That Drive Everything

```
VITE_APP_NAME  (in .env.example)   →  App name in Navbar, Login, Register pages
Issue #1       (GitHub)            →  Everything else — BRD, Issues, schema,
                                      API, UI, tests — all derived from this
```

---

## Pre-Workshop — Facilitator

| Step | Action | Detail |
|------|--------|--------|
| 1 | Set `VITE_APP_NAME` in `.env.example` | e.g. `"BookIt"`, `"FoodOrder"`, `"HelpDesk"` |
| 2 | Create GitHub Issue #1 | `[REQUIREMENT] {Feature Name}` — business requirement only, no tech spec |
| 3 | Run setup checklist | clone → npm install → prisma migrate → seed → verify auth works |

**Participants see on first run:**
```
Login page with app name  →  authenticate  →  "Features coming soon"
```

---

## Phase 1 — Requirements (PM)

```
Issue #1
    │
    ▼
┌─────────────┐
│  brd-agent  │  reads Issue #1
│             │  writes docs/requirements/BRD.md
└─────────────┘
    │
    ▼  PR raised
   👤 PM reviews BRD                         ← Gate 1
    │  merge
    ▼
┌──────────────────────┐
│  user-story-agent    │  reads copilot-instructions.md
│                      │  reads BRD.md
│                      │  identifies functional slices
│                      │  derives domain language from BRD
│                      │  writes issues/*.md files (one per role per slice)
└──────────────────────┘
    │
    ▼  PR raised
   👤 PM reviews issue files                 ← Gate 2
    │  merge
    ▼
  GitHub Actions triggers automatically
    │
    ▼
  GitHub Issues created with labels
  [DATABASE]  [BACKEND]  [FRONTEND]  [PLAYWRIGHT]
```

---

## Phase 2 — Architecture (Architect)

```
BRD + GitHub Issues
    │
    ▼
┌──────────────────┐
│  design-agent    │  reads BRD + all [user-story] Issues
│                  │  produces docs/design/design-doc.md
│                  │  produces src/prisma/schema.prisma additions
│                  │  defines all data-testid values
└──────────────────┘
    │
    ▼  PR raised
   👤 Architect reviews design doc + schema  ← Gate 3
    │  merge
    ▼
  Assign [DATABASE] Issue → Copilot
    │
    ▼
┌────────────────────────┐
│  Copilot Coding Agent  │  reads [DATABASE] Issue
│  (DATABASE)            │  adds domain models to schema.prisma
│                        │  runs prisma migrate dev
└────────────────────────┘
    │
    ▼  PR raised
   👤 Architect reviews migration            ← Gate 4
    │  merge
    ▼
  Schema unblocked — Backend Dev can proceed
```

---

## Phase 3 — Backend (Backend Dev)

```
[BACKEND] Issue + merged schema
    │
    ▼
  Assign [BACKEND] Issue → Copilot
    │
    ▼
┌────────────────────────┐
│  Copilot Coding Agent  │  reads [BACKEND] Issue
│  (BACKEND)             │  reads schema.prisma
│                        │  builds API routes + controllers
│                        │  applies auth middleware to protected routes
└────────────────────────┘
    │
    ▼  PR raised
   👤 Backend Dev reviews API               ← Gate 5
    │  checks: auth middleware, response shapes, HTTP status codes
    │  merge
    ▼
┌──────────────────────┐
│  unit-test-agent     │  reads implemented routes + controllers
│                      │  reads design-doc API contracts
│                      │  generates Jest test suite
│                      │  happy path + auth + validation per endpoint
└──────────────────────┘
    │
    ▼  PR raised
   👤 Backend Dev reviews tests             ← Gate 5b
    │  merge
```

---

## Phase 4 — Frontend (UI Dev)

```
[FRONTEND] Issue + merged API
    │
    ▼
  Assign [FRONTEND] Issue → Copilot
    │
    ▼
┌────────────────────────┐
│  Copilot Coding Agent  │  reads [FRONTEND] Issue
│  (FRONTEND)            │  reads design-doc (data-testid values)
│                        │  builds components + pages
│                        │  replaces HomePage placeholder with feature UI
│                        │  adds data-testid to all interactive elements
└────────────────────────┘
    │
    ▼  PR raised
   👤 UI Dev reviews components             ← Gate 6
    │  checks: data-testid values present, real data from API, journey works
    │  merge
```

---

## Phase 5 — Testing (QA Engineer)

```
[PLAYWRIGHT] Issue + merged frontend
    │
    ▼
┌──────────────────────────┐
│  playwright-agent        │  reads [PLAYWRIGHT] Issue (journey steps)
│                          │  reads design-doc (data-testid values)
│                          │  reads frontend components
│                          │  generates e2e/ test files
│                          │  uses getByTestId — no CSS selectors
└──────────────────────────┘
    │
    ▼  PR raised
   👤 QA reviews tests                      ← Gate 7
    │  checks: data-testid selectors, journey matches Issue
    │  merge
    ▼
  npx playwright test --ui
    │
    ▼
  ✅ ALL GREEN — demo moment
```

---

## The 7 Human-in-the-Loop Gates

Every agent output goes through a PR review before it affects the codebase.

| Gate | PR | Reviewer | Key Check |
|------|----|----------|-----------|
| 1 | BRD.md | PM | FRs numbered and specific? Out of scope explicit? |
| 2 | issues/*.md files | PM | One slice per file? 2-4 acceptance criteria? |
| 3 | design-doc + schema | Architect | All domain models present? data-testids listed? |
| 4 | DATABASE migration | Architect | Correct fields and relations? User model untouched? |
| 5 | BACKEND API | Backend Dev | Auth middleware? Response shapes match Issue? |
| 6 | FRONTEND UI | UI Dev | data-testid values present? Real data from API? |
| 7 | Playwright tests | QA | getByTestId selectors only? Journey matches Issue? |

---

## The data-testid Contract

This is the invisible thread connecting design → code → tests.

```
design-agent
  defines data-testid values in design-doc component tree
        │
        ▼
user-story-agent
  copies data-testid values into [FRONTEND] and [PLAYWRIGHT] Issues
        │
        ├──────────────────────────────────┐
        ▼                                  ▼
Copilot Coding Agent (FRONTEND)     playwright-agent
  implements data-testid on          reads data-testid values
  every interactive element          writes getByTestId selectors
```

A break anywhere in this chain causes Playwright tests to fail.
The PR review gates are where humans catch breaks before they propagate.

---

## Dependency Order — Why It Matters

```
DATABASE  →  BACKEND  →  FRONTEND  →  TESTS

Schema must exist    API must exist    UI connects     Tests run against
before API can       before UI can     to working      complete working
reference models     fetch data        API             app
```

Running out of order causes:
- Missing table errors
- Import failures
- Broken API calls
- Selector not found in tests

---

## Extension Slices

If the primary slice is complete with time to spare:

```
PM triggers user-story-agent again
  → generates extension slice Issues
  → pipeline repeats from Architect step
  → [PLAYWRIGHT] Issue already has optional extension journey section
```

---

## What Never Changes Between Workshops

```
.github/copilot-instructions.md    tech stack, standards, pre-built list
.github/agents/*.agent.md          agent personas and procedures
.github/skills/*.md                detailed agent instructions
.github/workflows/create-issues.yml  GitHub Actions pipeline
src/ scaffold                      auth, User model, seed user, shell UI
AGENTS.md                          Coding Agent instructions
```

## What Changes Between Workshops

```
VITE_APP_NAME in .env.example      set by facilitator
GitHub Issue #1                    written by facilitator
```

Everything else is generated by agents during the workshop.
