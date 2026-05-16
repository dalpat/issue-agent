---
name: to-issues
description: Break a PRD into independently-grabbable GitHub issues using tracer-bullet vertical slices. Enhanced for parallel agent execution with file dependency tracking.
---

# PRD to Issues

Break a PRD into independently-grabbable GitHub issues using vertical slices (tracer bullets).

## Process

### 1. Locate the PRD

Ask the user for the PRD GitHub issue number (or URL).

If the PRD is not already in your context window, fetch it with `gh issue view <number>` (with comments).

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code.

### 3. Draft vertical slices

Break the PRD into **tracer bullet** issues. Each issue is a **thin vertical slice** that cuts through ALL integration layers end-to-end.

**CRITICAL CONCEPTS:**

**Vertical slice vs Horizontal slice:**
- ✅ **Vertical slice:** Cuts through ALL layers (schema, API, UI, tests). Independently testable. Demoable on its own.
- ❌ **Horizontal slice:** One layer only (e.g., "all database changes"). NOT independently testable. Cannot be demoed alone.

**Parallelism:**
- Two slices can run in parallel **if and only if** they have **zero file overlap**
- If slice A modifies `file.js` and slice B modifies `file.js`, they CANNOT run in parallel
- Design slices to maximize parallelism by minimizing shared files

**Tracer bullet:**
- A thin vertical slice that proves the concept end-to-end
- Prefer many thin tracer bullets over few thick slices

<vertical-slice-rules>
- Each slice is a **vertical slice** (not horizontal) - cuts through ALL layers
- Each slice is **independently testable** - can be verified without other slices
- Each slice is **demoable** - shows working functionality on its own
- Each slice lists **ALL files** it touches (existing + new + tests)
- Slices are designed for **parallelism** - minimize file overlap between slices
- Prefer **many thin slices** over few thick ones
</vertical-slice-rules>

Slices may be 'HITL' or 'AFK'. HITL slices require human interaction, such as an architectural decision or a design review. AFK slices can be implemented and merged without human interaction. Prefer AFK over HITL where possible.

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each slice, show:

- **Title**: short descriptive name
- **Type**: HITL / AFK
- **Blocked by**: which other slices (if any) must complete first
- **Developer stories covered**: which developer stories from the PRD this addresses
- **User stories covered**: which user stories from the PRD this addresses
- **Files to modify**: list of existing files this slice will modify (be exhaustive - include test files)
- **New files**: list of new files this slice will create (be exhaustive - include test files)
- **Can work parallely with**: list which other slices this can run in parallel with (zero file overlap)

**CRITICAL:** For each slice, explicitly verify:
- ✅ Is this a **vertical slice** (cuts through all layers)?
- ✅ Is this **independently testable** (can verify without other slices)?
- ✅ Are **ALL files** listed (including tests, config, schema)?
- ✅ Which slices have **zero file overlap** with this one?

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?
- Are the correct slices marked as HITL and AFK?
- **Are file dependencies correctly identified for parallelism?**
- **Can we maximize parallel execution with this breakdown?**

Iterate until the user approves the breakdown.

### 5. Create the GitHub issues

For each approved slice, create a GitHub issue using `gh issue create`. Use the issue body template below.

Create issues in dependency order (blockers first) so you can reference real issue numbers in the "Blocked by" field.

<issue-template>
## Parent PRD

#<prd-issue-number>

## What to build

A concise description of this **vertical slice**. Describe the end-to-end behavior through ALL layers (schema, API, UI, tests), not layer-by-layer implementation. Reference specific sections of the parent PRD rather than duplicating content.

This slice must be **independently testable** and **demoable** on its own.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3
- [ ] All tests pass
- [ ] This vertical slice is independently verifiable

## Blocked by

- Blocked by #<issue-number> (if any)

Or "None - can start immediately" if no blockers.

## Developer stories addressed

Reference by number from the parent PRD:

- Developer story 1
- Developer story 3

## User stories addressed

Reference by number from the parent PRD:

- User story 3
- User story 7

## Existing files to modify

List **ALL** files that will be modified (include tests, config, schema):

- `path/to/file1.js`
- `path/to/file2.js`
- `path/to/file2.test.js`

## New files

List **ALL** new files that will be created (include tests):

- `path/to/newfile1.js`
- `path/to/newfile1.test.js`

## Can work parallely

Yes - this slice has no file overlap with slices #X, #Y, #Z.

Or:

No - this slice shares files with slice #X (both modify `path/to/file.js`).

</issue-template>

Do NOT close or modify the parent PRD issue.

## Critical Rules for Vertical Slices and Parallelism

Your job is to design thin vertical slices that can be implemented independently and in parallel.

### Rule 1: Vertical Slices Only

❌ **BAD (Horizontal):**
- Issue #1: "Add all database schemas"
- Issue #2: "Add all API endpoints"
- Issue #3: "Add all UI components"

Why bad? Each issue touches multiple features. Not independently testable.

✅ **GOOD (Vertical):**
- Issue #1: "User login (schema + API + UI + tests)"
- Issue #2: "User registration (schema + API + UI + tests)"
- Issue #3: "Password reset (schema + API + UI + tests)"

Why good? Each issue is one complete feature. Independently testable. Different files.

### Rule 2: Parallelism = Zero File Overlap

Two slices can run in parallel if they touch different files.

Example:
- Issue #1 modifies: `auth.js`, `auth.test.js`
- Issue #2 modifies: `profile.js`, `profile.test.js`
- Issue #3 modifies: `auth.js`, `utils.js`

Result:
- ✅ Issue #1 and #2 can run in parallel (no shared files)
- ❌ Issue #1 and #3 CANNOT (both touch `auth.js`)

### Rule 3: List ALL Files

Be exhaustive. Include:
- Source files
- Test files
- Config files
- Schema files

### Rule 4: Minimize Shared Files

When designing slices, minimize file overlap.

❌ **BAD:**
- Issue #1: "Add Widget A" → modifies `widgets/index.js`, `widgets/WidgetA.js`
- Issue #2: "Add Widget B" → modifies `widgets/index.js`, `widgets/WidgetB.js`

Why bad? Both modify `widgets/index.js`. Cannot run in parallel.

✅ **GOOD:**
- Issue #1: "Widget registry" → modifies `widgets/index.js`
- Issue #2: "Add Widget A" → creates `widgets/WidgetA.js` only
- Issue #3: "Add Widget B" → creates `widgets/WidgetB.js` only

Why good? Issue #1 runs first. Then #2 and #3 can run in parallel.

### Summary

When breaking down a PRD:
1. Create **vertical slices** (not horizontal)
2. Make each slice **independently testable**
3. List **ALL files** (including tests)
4. Minimize file overlap between slices
