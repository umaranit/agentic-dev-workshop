---
name: create-user-stories
description: Decomposes a BRD into atomic INVEST-compliant GitHub Issue files.
  One file per functional slice per role. Written directly into issues/ folder.
  Derives all content from the BRD and copilot-instructions.md — no hardcoded values.
---

# Skill — Create User Stories

## Before You Write Anything

Read these two files first — everything you write derives from them:

1. `.github/copilot-instructions.md`
   - App context and domain
   - Tech stack
   - What is pre-built (never rebuild these)
   - Test user credentials
   - Coding standards

2. `docs/requirements/BRD.md`
   - Feature requirements
   - Functional requirement IDs
   - Out of scope items

---

## Core Principle — INVEST

Every issue must be:
- **I**ndependent — one functional slice, not all features combined
- **N**egotiable — describes what, not how
- **V**aluable — delivers a demonstrable outcome to the user
- **E**stimable — a developer can size it in minutes
- **S**mall — completable in one focused session (half a day max)
- **T**estable — 2-4 specific, verifiable acceptance criteria

---

## Step 1 — Identify Functional Slices

Group the BRD functional requirements into workflow steps.
Each workflow step that produces a demonstrable user outcome = one slice.

```
FOR EACH SLICE ASK:
  "Can a user complete a meaningful journey with just this slice?"
  If yes → valid slice

SLICE SIZING RULE:
  Primary slice   → simplest complete journey — 3-5 FRs max
  Extension slice → additional capability built on top — 3-5 FRs max
```

Label slices using the actual domain language from the BRD.
Do not use generic names like "slice-1" or "feature-a".

---

## Step 2 — Determine Files Per Slice

For each slice, only create role files where work is actually needed:

| Role | File naming | Create when |
|------|-------------|-------------|
| DATABASE | `issues/database-{slice}.md` | New Prisma models needed |
| BACKEND | `issues/backend-{slice}.md` | New API endpoints needed |
| FRONTEND | `issues/frontend-{slice}.md` | New UI components needed |
| PLAYWRIGHT | `issues/playwright-{feature}.md` | One file per feature — full journey |

Use kebab-case slice names derived from the BRD domain language.

---

## Step 3 — Write Each File

### DATABASE issue format
```
# [DATABASE] {Slice Name — from BRD}

## User Story
As a system I need {specific models from BRD} so that {specific benefit}

## Context
Pre-built models from copilot-instructions.md:
- {list each pre-built model that is relevant}
This issue adds only the models required for this slice.

## Models to Add
{ModelName}
- fieldName: Type — description

## Relationships
- {Entity A} has one/many {Entity B}

## Acceptance Criteria
- [ ] Migration runs without errors
- [ ] {specific model} created with correct fields and relations
- [ ] Pre-built models and existing data unchanged
```

**Rules:**
- Derive model names from BRD domain language
- Maximum 2 models per issue — split if more needed
- Reference pre-built models from copilot-instructions.md in Context
- Never repeat models defined in other issues

---

### BACKEND issue format
```
# [BACKEND] {Slice Name — from BRD}

## User Story
As a {user type from BRD} I want to {action} so that {benefit}

## Context
Pre-built from copilot-instructions.md:
- {list relevant pre-built backend pieces — middleware, routes, etc.}
This issue adds only the endpoints required for this slice.

## API Endpoints
- METHOD /api/{path} — description
  Request: {body shape if applicable}
  Response: {response shape}
  Auth: required / not required

## Acceptance Criteria
- [ ] {endpoint} returns {HTTP status} with {response shape}
- [ ] Protected endpoints return 401 without valid JWT
- [ ] {specific validation or error case from BRD}
```

**Rules:**
- Derive endpoint paths from BRD domain language
- Maximum 3-4 endpoints per issue — split if more needed
- Always specify HTTP method, path, request and response shape
- Always include 401 criterion for protected endpoints
- Reference pre-built middleware from copilot-instructions.md

---

### FRONTEND issue format
```
# [FRONTEND] {Slice Name — from BRD}

## User Story
As a {user type from BRD} I want to {action} so that {benefit}

## Context
Pre-built from copilot-instructions.md:
- {list relevant pre-built frontend pieces — pages, components, router}
HomePage.tsx currently shows a placeholder — this Issue replaces its
content with the primary feature component below.
API endpoints available: {list endpoints from the corresponding BACKEND issue}

## What to Build
- {ComponentName} — what it does

## HomePage Update
Replace the placeholder content in HomePage.tsx to render {PrimaryComponent}.
The user must see real feature UI immediately after login.

## data-testid Values
Every interactive and key display element must have a data-testid.
Playwright tests will use these — list them explicitly:
- `{testid-value}` — on {element description}

## Acceptance Criteria
- [ ] {specific UI behaviour derived from BRD acceptance criteria}
- [ ] All data-testid values listed above are present on correct elements
```

**Rules:**
- Derive component names from BRD domain language
- Maximum 3-4 components per issue — split if more needed
- Always list data-testid values — playwright-agent reads these
- Reference pre-built components from copilot-instructions.md
- List the API endpoints this UI calls

---

### PLAYWRIGHT issue format
```
# [PLAYWRIGHT] {Feature Name — from BRD}

## User Story
As a QA engineer I want to verify the {feature} journey end to end

## Primary Journey — {Slice Name}
One action per step with expected result:
1. {action} — expect {result}
2. {action} — expect {result}
...

## Test Credentials
{Copy from copilot-instructions.md — do not invent}

## data-testid Reference
These must match the data-testid values in the FRONTEND issues exactly:
- `{testid-value}` — used to {assertion description}

## Acceptance Criteria
- [ ] Full journey passes without errors
- [ ] All selectors use data-testid only — no CSS classes or text content
- [ ] {specific end state assertion from BRD}

---

## Extension Journey — {Extension Slice Name} (optional)
> Only run if extension slice issues are implemented and merged.

1. {action} — expect {result}
```

**Rules:**
- One PLAYWRIGHT file per feature — covers primary + optional extension
- Derive test steps from BRD user journey and acceptance criteria
- data-testid values must match FRONTEND issues exactly
- Test credentials come from copilot-instructions.md — never hardcode
- All selectors must use data-testid — never CSS classes or text

---

## Quality Checklist Before Raising PR

For every file you write, verify:

```
✅ Title is an H1 heading — will become the GitHub Issue title
✅ User story follows "As a... I want... so that..." format
✅ Context lists pre-built work from copilot-instructions.md
✅ FRONTEND issues include "HomePage Update" section with primary component
✅ Scope is limited to this slice only
✅ Acceptance criteria are specific and verifiable — not vague
✅ 2-4 acceptance criteria max — not a laundry list
✅ FRONTEND issues list all data-testid values
✅ PLAYWRIGHT data-testid values match FRONTEND issues
✅ No content duplicated from copilot-instructions.md
✅ No content invented — everything derived from BRD or copilot-instructions
```
