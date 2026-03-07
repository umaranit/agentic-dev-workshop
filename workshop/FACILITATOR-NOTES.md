# Agentic SDLC Workshop — Facilitator Notes

**Duration:** 2-3 hours
**Participants:** 5 (one per role)
**Goal:** One complete vertical slice — primary feature end to end
**Extension:** Additional slices for fast groups with time to spare
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

### GitHub Actions Setup ⚠️ REQUIRED — Do This First
- [ ] Go to repo → Settings → Actions → General
- [ ] Under **Workflow permissions** → select **Read and write permissions**
- [ ] Click **Save**

> Without this the `create-issues` workflow will fail with:
> `GraphQL: Resource not accessible by integration`
> This is a repo-level setting — the workflow YAML alone is not enough.

### GitHub Configuration
- [ ] Enable GitHub Copilot for the repository
- [ ] Enable Copilot Coding Agent — repo settings → Copilot → Coding Agent
- [ ] Enable custom agents — repo settings → Copilot → Agents
- [ ] Add all participant GitHub accounts as collaborators with Write access

### Local Setup (Each Participant Machine)
- [ ] `git clone <repo-url>`
- [ ] `cd src/backend && npm install`
- [ ] `cd src/frontend && npm install`
- [ ] `cp .env.example .env`
- [ ] `cd src/backend && npx prisma migrate dev --name init`
- [ ] `cd src/backend && npx prisma db seed`
- [ ] `cd src/backend && npm run dev` → confirm running on port 3001
- [ ] `cd src/frontend && npm run dev` → confirm running on port 5173
- [ ] Login with credentials from `.github/copilot-instructions.md`
- [ ] Confirm app loads and auth works

### Verify Agents Work
- [ ] Go to github.com → repo → Copilot → Agents
- [ ] Confirm all 5 custom agents appear in the dropdown
- [ ] Confirm Copilot Coding Agent is available for Issue assignment

---

## Workshop Reset Procedure

> Use this between cohorts or when running the workshop again from scratch.
> Participants never need to do this.

```
Step 1  repo → Issues → select all → Close issues
Step 2  Delete all .md files inside issues/ folder
        Leave .gitkeep in place
Step 3  Commit and push deletion to main
Step 4  Ready for next run
```

---

## How the Issues Pipeline Works

```
user-story-agent
  → reads copilot-instructions.md (app context)
  → reads BRD.md (feature requirements)
  → identifies functional slices
  → writes issue .md files to issues/ folder
  → raises PR

PM reviews PR → merges to main

GitHub Actions (create-issues.yml) triggers automatically
  → reads each .md file in issues/
  → exact-match duplicate check — skips already-created issues
  → creates GitHub Issue with correct label
  → done
```

---

## Issue #1 — Create This Before Workshop Starts

The requirement Issue triggers the entire pipeline.
Write this based on the feature you have chosen for the workshop.
It should be a concise business requirement — not a technical spec.

**Suggested format:**

```
Title: [REQUIREMENT] {Feature Name}

Body:
## Feature Name
{Feature name}

## Business Context
{Why this feature is needed — 2-3 sentences}

## What Users Can Do
- {User action 1}
- {User action 2}
- {User action 3}

## Out of Scope
- {Explicitly excluded item 1}
- {Explicitly excluded item 2}

## Acceptance Criteria
- [ ] {High-level criterion 1}
- [ ] {High-level criterion 2}
- [ ] {High-level criterion 3}
```

Submit with label: `requirement`

> Keep this requirement focused. The smaller and clearer the requirement,
> the better the agents perform. One feature with 3-5 user actions
> is ideal for a 2-3 hour workshop.

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

**Key distinction:**
> "These agents are not chat assistants. You assign a task, they go away,
> do the work, and come back with a Pull Request. Your job is to review
> and merge — or reject and give feedback."

**The goal:**
> "By the end of this workshop we will have one complete vertical slice
> running end to end with passing Playwright tests — built entirely by
> agents, reviewed and guided by you."

**On agent quality:**
> "Agents make mistakes. That is intentional. The PR review gate is
> where your expertise matters. Watch for missing data-testid attributes,
> wrong response shapes, or scope creep — these are real review skills."

---

## Phase-by-Phase Facilitation Notes

### Phase 1 — PM (0:30–0:50)

**Watch for:** PM trying to chat with the agent. Remind them — one
instruction, then wait. Do not keep adding messages.

**brd-agent:** Should produce a BRD with numbered functional requirements
(FR-001, FR-002...) and an explicit out of scope section.
If BRD is too vague — PM adds a PR comment asking for more detail.
Agent will update the PR.

**user-story-agent:** Reads copilot-instructions.md and BRD.
Derives functional slices from the BRD — not from hardcoded templates.
Creates one issue file per role per slice.
Primary slice files come first — extension files are additional.

**After merge:** GitHub Actions creates Issues automatically.
PM confirms Issues visible in Issues tab with correct labels
before handing off to Architect.

**Signal to move on:** Issues visible with correct labels.

---

### Phase 2 — Architect (0:50–1:10)

**Watch for:** design-agent producing schema that does not match
the [DATABASE] Issue. Check models, fields, and relations match exactly.

**Critical gate:** DATABASE PR must be merged before Phase 3.
Backend Dev cannot reference models that do not exist in schema.

**data-testid contract:** design-agent should list data-testid values
in the design doc component tree. These flow to FRONTEND Issue
and then to Playwright tests. If missing — Architect adds a PR comment.

**Signal to move on:** DATABASE migration PR merged successfully.

---

### Phase 3 — Backend Dev (1:10–1:30)

**Large PR guidance:** Coding Agent may implement multiple endpoints
in one PR. Focus review on:
```
1. Auth middleware on all protected routes
2. Response shapes match the [BACKEND] Issue spec exactly
3. Correct HTTP status codes (200, 201, 401, 404)
```
Participants do not need to review every line — that is not the point.

**Common issue:** CORS error when frontend calls backend.
Confirm `vite.config.ts` proxy is set to `http://localhost:3001`.

**Signal to move on:** BACKEND PR merged. Server starts without errors.

---

### Phase 4 — UI Dev (1:30–1:50)

**Critical check:** Are all data-testid values from the [FRONTEND] Issue
present in the components? If missing — UI Dev adds a PR comment.
This is a key teaching moment — the data-testid contract flows from
Issue → component → Playwright test. A break here fails tests later.

**Test locally:** Walk the user journey manually before merging.
Does it work end to end using real API data?

**Signal to move on:** FRONTEND PR merged. Journey works in browser.

---

### Phase 5 — QA (1:50–2:10)

**Watch for:** playwright-agent using CSS selectors instead of data-testid.
Have QA add a PR comment requesting correction.
This is the governance teaching moment — agents can get this wrong,
PR review is the safety net.

**Common failure:** data-testid values in tests do not match components.
Walk through as a process failure — where did the chain break?
data-testid defined in [FRONTEND] Issue → implemented in component
→ referenced in [PLAYWRIGHT] Issue → used in Playwright test.
Find the break point.

**Signal to move on:** `npx playwright test --ui` — primary journey passes.

---

## Demo Moment (2:10–2:20)

Project `npx playwright test --ui` on screen for the group.

Walk through each step of the test journey.
After each step narrate which agent contributed to making it work:
- "The schema that makes this data exist — design-agent + Coding Agent"
- "The API returning this data — Coding Agent from the [BACKEND] Issue"
- "The component displaying it — Coding Agent from the [FRONTEND] Issue"
- "This test step itself — playwright-agent from the [PLAYWRIGHT] Issue"

End with all green. Let it sit for a moment before moving to debrief.

---

## Debrief Questions (20 min)

**On agent quality:**
- Where did an agent produce output that needed correction?
- What would have happened if you merged without reviewing?

**On the data-testid contract:**
- How did the data-testid convention flow through the pipeline?
- Where could the chain have broken — and what would that look like?

**On roles:**
- What decisions required human judgment the agent could not make?
- Did your role feel different from normal development work?

**On real-world applicability:**
> "Would you use this exact setup in production?"

Suggested answer:
> "The pattern — agents raising PRs, humans reviewing — absolutely yes.
> The specific tooling may differ. GitHub Issues works for team-scale
> projects. Enterprise connects this same pattern to Jira or Azure DevOps
> via their REST APIs. The agent does not change. Only the integration
> destination changes."

**On the requirement quality:**
> "How did the quality of Issue #1 affect what the agents produced?"

This surfaces the most important lesson — garbage in, garbage out.
A well-written requirement produces well-structured BRD, well-scoped
user stories, and well-implemented code. The agents amplify whatever
quality they receive.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Agent not in dropdown | Check `.agent.md` is in `.github/agents/` on main |
| Issues not created after merge | Settings → Actions → Read and write permissions |
| `GraphQL: Resource not accessible` | Same — Actions permissions not set |
| Duplicate Issues created | Workflow has exact-match duplicate detection — safe to re-run |
| `issues/` not triggering workflow | Confirm `.md` files exist — `.gitkeep` alone does not trigger |
| Prisma errors on migrate | Delete `dev.db` → re-run `prisma migrate dev --name init` |
| CORS error frontend→backend | Check vite proxy config, confirm backend on port 3001 |
| Playwright fails on selectors | data-testid values must match exactly between component and test |
| Coding Agent assigned but no PR | Check Copilot Coding Agent enabled in repo settings |
| `npm run test` fails | Run `npx prisma db seed` — test user must exist |
| Agent ignores BRD structure | Check BRD has numbered FRs — agent relies on this structure |
