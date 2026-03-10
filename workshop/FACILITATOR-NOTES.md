# Agentic SDLC Workshop — Facilitator Notes

**Duration:** 2-3 hours
**Participants:** 5 (one per role)
**Goal:** One complete vertical slice end to end — from requirement to passing tests
**Prerequisites:** GitHub accounts, repo access, VS Code installed

---

## Pre-Workshop Checklist (Day Before)

### Repository Setup
- [ ] Create a new GitHub repository — private
- [ ] Push all scaffold files from this repo
- [ ] Confirm `.github/copilot-instructions.md` is on main branch
- [ ] Confirm `.github/agents/` has all 5 `.agent.md` files
- [ ] Confirm `.github/skills/` has all 5 `SKILL.md` files
- [ ] Confirm `AGENTS.md` is on main branch
- [ ] Confirm `issues/` folder exists with only `.gitkeep` inside
- [ ] Confirm `.github/workflows/create-issues.yml` is on main branch
- [ ] Confirm `src/backend/prisma/migrations/` contains ONLY the init migration for User model
- [ ] Confirm `src/prisma/schema.prisma` has ONLY the User model — no domain models
- [ ] Confirm `src/prisma/seed.ts` creates ONLY the test user — no domain data

### GitHub Actions Setup ⚠️ REQUIRED — Do This First
- [ ] Go to repo → Settings → Actions → General
- [ ] Under **Workflow permissions** → select **Read and write permissions**
- [ ] Click **Save**

> Without this the `create-issues` workflow will fail with:
> `GraphQL: Resource not accessible by integration`

### GitHub Configuration
- [ ] Enable GitHub Copilot for the repository
- [ ] Enable Copilot Coding Agent — repo settings → Copilot → Coding Agent
- [ ] Enable custom agents — repo settings → Copilot → Agents
- [ ] Add all participant GitHub accounts as collaborators with Write access

### Local Setup (Each Participant Machine)
- [ ] `git clone <repo-url>`
- [ ] `cd src/backend && npm install`
- [ ] `cd src/frontend && npm install`

- [ ] Set up backend environment:
      ```
      cp src/backend/.env.example src/backend/.env
      ```
      No changes needed — defaults work for local workshop use

- [ ] Set up frontend environment:
      ```
      cp src/frontend/.env.example src/frontend/.env
      ```
      Then open `src/frontend/.env` and set the app name:
      ```
      ex VITE_APP_NAME="BookIt"
      ```
      This controls the browser tab title, Navbar logo, and Login/Register page heading.
      Change it to match the feature being built for this cohort.
- [ ] `cd src/backend && npx prisma migrate dev --name init`
- [ ] `cd src/backend && npx prisma db seed`
- [ ] `cd src/backend && npm run dev` → confirm running on port 3001
- [ ] `cd src/frontend && npm run dev` → confirm running on port 5173
- [ ] Login with `test@example.com / password123` → confirm auth works
- [ ] Confirm browser tab title matches `VITE_APP_NAME`
- [ ] Confirm HomePage shows "Features coming soon"

### Verify Agents Work
- [ ] Go to github.com → repo → Copilot → Agents
- [ ] Confirm all 5 custom agents appear in the dropdown
- [ ] Confirm Copilot Coding Agent is available for Issue assignment

---

## Workshop Starting State

When participants clone and run the app they will see:

```
Login page → authenticate → HomePage shows "Features coming soon"
Navbar: app title (from VITE_APP_NAME) + Logout button — no feature nav yet
Schema: User model only
Seed:   test user only — no domain data
```

Everything else is built during the workshop by agents.
This is intentional — it demonstrates the full pipeline from scratch.

---

## Workshop Reset Procedure

> Use between cohorts or before starting fresh.
> Participants never do this.

### Automated Reset (Recommended)

Two reset scripts are provided in the repo root — use the one for your OS:

**Mac/Linux:**
```bash
bash reset-workshop.sh
```

**Windows PowerShell:**
```powershell
# First — allow script execution for this session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Then run the script
.\reset-workshop.ps1
```

> ⚠️ Windows only: The `Bypass` scope is session-only — closes automatically
> when you close PowerShell. Nothing permanent changes on your machine.
> Without this you will see: "File cannot be loaded. The file is not digitally signed."

The script performs all 8 reset steps automatically and verifies the result:

```
Step 1  Remove BRD.md and design-doc.md
Step 2  Remove all issues/*.md files
Step 3  Reset schema.prisma to User model only
Step 4  Reset seed.ts to test user only
Step 5  Delete migrations folder and dev.db
Step 6  Run prisma migrate dev --name init (clean)
Step 7  Run prisma db seed (test user)
Step 8  Verify migration contains exactly 1 table (User)
        → prints OK if clean
        → prints WARNING with table names if not clean
```

After the script completes:
- [ ] Commit and push to main
- [ ] Close all open Issues on GitHub manually
- [ ] Confirm app runs — login works, "Features coming soon" appears

### Manual Reset (If Scripts Unavailable)

```
Step 1  repo → Issues → select all → Close issues
Step 2  Delete all .md files inside issues/ folder — leave .gitkeep
Step 3  Reset schema.prisma to User model only
Step 4  Reset seed.ts to test user only (test@example.com / password123)
Step 5  Delete src/backend/prisma/migrations/ folder entirely  ⚠️ CRITICAL
Step 6  Run: cd src/backend && npx prisma migrate dev --name init
Step 7  Delete docs/requirements/BRD.md if it exists
Step 8  Delete docs/design/design-doc.md if it exists
Step 9  Commit and push to main
```

> ⚠️ WHY Step 5 is critical:
> If old migration files from a previous cohort remain, the Coding Agent
> sees a mismatch between schema.prisma and migration history. It gets
> confused trying to reconcile old tables (e.g. Restaurant, MenuItem)
> with new domain models (e.g. Room, Booking) and either fails or
> produces incorrect migrations. Always reset migrations between cohorts.

---

## How the Issues Pipeline Works

```
user-story-agent
  → reads copilot-instructions.md (app context, tech stack, pre-built)
  → reads BRD.md (feature requirements)
  → identifies functional slices
  → derives domain language from BRD
  → calculates Assignment Order for every Issue
  → writes issue .md files to issues/ folder
  → raises PR

PM reviews PR → merges to main

GitHub Actions (create-issues.yml) triggers automatically
  → reads each .md file in issues/
  → exact-match duplicate check
  → creates GitHub Issue with correct label
```

---

## Issue Assignment Order

Every Issue contains an `## Assignment Order` section written by user-story-agent.
When participants open an Issue they see exactly when to assign it:

```
## Assignment Order
Step 3 of 7 — assign after: [DATABASE] {primary slice} is merged
Tier: BACKEND — primary slice
```

**The golden rule — always follow this tier sequence:**

```
DATABASE  (all slices) → BACKEND  (all slices) → FRONTEND  (all slices) → PLAYWRIGHT
          ↑
          Primary slice before extension slice within each tier
```

**Typical order for 2-slice feature:**
```
Step 1  [DATABASE]   primary slice     ← assign first, nothing to wait for
Step 2  [DATABASE]   extension slice   ← wait for Step 1 PR to merge
Step 3  [BACKEND]    primary slice     ← wait for Step 2 PR to merge
Step 4  [BACKEND]    extension slice   ← wait for Step 3 PR to merge
Step 5  [FRONTEND]   primary slice     ← wait for Step 4 PR to merge
Step 6  [FRONTEND]   extension slice   ← wait for Step 5 PR to merge
Step 7  [PLAYWRIGHT]                   ← wait for Step 6 PR to merge
```

Participants never need to figure this out — it is written in each Issue.

---

## Issue #1 — Create This Before Workshop Starts

Write this based on the feature you have chosen for this cohort.
The requirement should be a concise business need — not a technical spec.

**Suggested format:**
```
Title: [REQUIREMENT] {Feature Name}

## Feature Name
{Feature name}

## Business Context
{Why this feature is needed — 2-3 sentences max}

## What Users Can Do
- {User action 1}
- {User action 2}
- {User action 3}

## Out of Scope
- {Excluded item 1}
- {Excluded item 2}

## Acceptance Criteria
- [ ] {High-level criterion 1}
- [ ] {High-level criterion 2}
- [ ] {High-level criterion 3}
```

Submit with label: `requirement`

> Keep it focused. One feature with 3-5 user actions is ideal.
> The agents derive all domain models, API paths, and components
> from this requirement — the clearer it is, the better they perform.

---

## Workshop Schedule

| Time | Phase | Who | What |
|------|-------|-----|------|
| 0:00 | Intro | Facilitator | Agentic SDLC concept — 15 min |
| 0:15 | Setup | All | Clone repo, verify app runs — 15 min |
| 0:30 | Phase 1 | PM | brd-agent + user-story-agent — 20 min |
| 0:50 | Phase 2 | Architect | design-agent + assign DATABASE — 20 min |
| 1:10 | Phase 3 | Backend Dev | Assign BACKEND Issue to Copilot — 20 min |
| 1:30 | Phase 4 | UI Dev | Assign FRONTEND Issue to Copilot — 20 min |
| 1:50 | Phase 5 | QA | playwright-agent + run tests — 20 min |
| 2:10 | Demo | All | npx playwright test --ui on screen — 10 min |
| 2:20 | Debrief | All | Discussion — 20 min |
| 2:40 | Extension | Fast groups | Additional slices if time allows |
| 3:00 | End | | |

---

## Intro Talking Points (15 min)

**The concept:**
> "Today you will take a single business requirement all the way to
> tested, working code — using AI agents at every step of the SDLC.
> You are not pair programming with AI. You are directing autonomous
> agents that do the work and raise PRs for your review."

**The starting point:**
> "When you clone this repo you get auth, a User model, and a page
> that says 'Features coming soon'. Nothing else. Every model, every
> API route, every UI component — the agents build it from the
> requirement you saw in Issue #1."

**Key distinction:**
> "These agents are not chat assistants. You assign a task, they go
> away, do the work, and come back with a Pull Request. Your job is
> to review and merge — or push back with a comment."

---

## Phase-by-Phase Facilitation Notes

### Phase 1 — PM (0:30–0:50)

**Watch for:** PM chatting with the agent instead of assigning once and waiting.

**brd-agent:** Should produce a BRD with numbered FRs and explicit out of scope.
If too vague — PM comments on PR requesting more specific acceptance criteria.

**user-story-agent:** Reads copilot-instructions.md and BRD.
Derives domain language entirely from BRD — file names, model names,
endpoint paths all come from the requirement, not hardcoded templates.
Primary slice = simplest complete journey. Extension slices = additional.
Every Issue includes an Assignment Order section — participants use this
to know which Issue to assign next.

**After merge:** GitHub Actions creates Issues automatically.
PM confirms Issues visible in Issues tab with correct labels.

**Signal to move on:** Issues visible with correct labels and Assignment Order sections.

---

### Phase 2 — Architect (0:50–1:10)

**Critical difference from before:** design-agent now produces ALL domain
models from scratch — not just adding to existing ones.
Check the schema carefully — every model the BRD needs should be here.

**Watch for:** Missing relations or models that the BRD implies.
Architect adds a PR comment if anything is missing.

**Critical gate:** DATABASE PR must be merged before Phase 3.
Backend Dev cannot reference models that do not yet exist.

**data-testid contract starts here:** design-agent lists data-testid
values in the component tree. These flow through to FRONTEND Issue
and Playwright tests. If missing — Architect flags it on the PR.

**Signal to move on:** DATABASE migration PR merged successfully.

---

### Phase 3 — Backend Dev (1:10–1:30)

Focus review on three things only:
```
1. Auth middleware on all protected routes
2. Response shapes match the [BACKEND] Issue spec
3. Correct HTTP status codes
```

**Signal to move on:** BACKEND PR merged. Server starts without errors.

---

### Phase 4 — UI Dev (1:30–1:50)

**Critical check:** data-testid values from [FRONTEND] Issue present in components.
If missing → UI Dev adds PR comment requesting them.
This is the key teaching moment — the data-testid contract flows
from design-agent → [FRONTEND] Issue → component → Playwright test.
A break here causes test failures downstream.

**Signal to move on:** FRONTEND PR merged. Journey works in browser.

---

### Phase 5 — QA (1:50–2:10)

**Watch for:** playwright-agent using CSS selectors instead of data-testid.
Have QA request correction in PR comment — agents make this mistake.

**Signal to move on:** `npx playwright test --ui` primary journey passes.

---

## Demo Moment (2:10–2:20)

Project `npx playwright test --ui` on screen.
At each step narrate which agent produced the code making it work.
End on all green — let it sit before moving to debrief.

---

## Debrief Questions (20 min)

- Where did an agent produce output that needed correction?
- How did the data-testid contract flow through the pipeline?
- What decisions required human judgment the agent could not make?
- How did the quality of Issue #1 affect everything downstream?
- What would you change about the agent instructions to improve quality?

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Agent not in dropdown | Check `.agent.md` in `.github/agents/` on main |
| Issues not created after merge | Settings → Actions → Read and write permissions |
| `GraphQL: Resource not accessible` | Same — Actions permissions not set |
| Duplicate Issues | Workflow has exact-match duplicate detection — safe to re-run |
| `issues/` not triggering workflow | `.md` files must exist — `.gitkeep` alone does not trigger |
| Coding Agent confused by migration history | Old migrations from previous cohort present — run reset script |
| Coding Agent fails on DATABASE Issue | Schema and migrations out of sync — run reset script |
| Prisma errors on migrate | Delete `dev.db` → re-run `prisma migrate dev --name init` |
| CORS error frontend→backend | Check vite proxy config, confirm backend on port 3001 |
| Playwright fails on selectors | data-testid values must match exactly between component and test |
| Coding Agent assigned but no PR | Check Copilot Coding Agent enabled in repo settings |
| `npm run test` fails | Run `npx prisma db seed` — test user must exist |
| Schema missing domain models | design-agent must run and DATABASE PR must merge before BACKEND |
| Browser tab shows wrong name | Check `VITE_APP_NAME` in `src/frontend/.env`, restart dev server |
| Frontend shows blank page after DATABASE merge | Seed data missing — check seed.ts, run `npx prisma db seed` manually |
| PowerShell script blocked — not digitally signed | Run: `Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process` first |
| Reset script runs but migration still has domain tables | schema.prisma was not reset — run reset script again, do not run prisma commands manually |
