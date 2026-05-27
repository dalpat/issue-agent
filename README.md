# issue-agent

Installable, project-specific AI agent that picks GitHub issues and implements them one at a time.

## Install

### One-liner (requires `curl`)

```bash
cd /path/to/your-project
curl -fsSL https://raw.githubusercontent.com/dalpat/issue-agent/main/install.sh | bash
```

### From a clone

```bash
cd /path/to/your-project
/path/to/issue-agent/install.sh
```

The installer runs in `bash`, copies project-local commands into `.agent/`, installs shared skills into `~/.agents/skills`, and exits non-zero if required skills fail to install.

## Upgrade

Re-run `install.sh` to update `.agent/` scripts and shared skills to the latest version:

`cd /path/to/your-project`

Run this in the root of your project

```bash
curl -fsSL https://raw.githubusercontent.com/dalpat/issue-agent/main/install.sh | bash
```

> **Note:** If your `prompt.md` or `agent-once-prompt.md` has been customized, the installer automatically backs it up to `prompt.md.bak` before overwriting.

## What it does

1. Creates a `.agent/` directory inside your project
2. Copies all project commands into `.agent/`
3. Adds `.agent/progress.md` to `.gitignore`
4. You edit `.agent/prompt.md` to match your project

## Run

### Sequential mode (default)

```bash
.agent/agent 10
```

Runs up to 10 iterations, picking and implementing one issue at a time. Stops early if the AI signals completion with `<promise>COMPLETE</promise>`.

### Parallel mode (opt-in)

```bash
.agent/parallel-agents
```

Auto-detects which issues can run in parallel by parsing file dependencies from issue bodies. Spawns multiple agents simultaneously for non-conflicting issues.

**Requirements for parallel mode:**
- Issues must have "## Existing files to modify" and "## New files" sections
- Issues must have "## Blocked by" section listing dependencies
- Use the `to-issues` skill to create properly formatted issues
- `jq` must be installed locally

**Dry-run (see what would happen):**
```bash
.agent/parallel-agents --dry-run
```

`.agent/parallel-agents` validates `gh`, `jq`, and `opencode` before it starts scheduling work.

### Single-Issue mode

```bash
.agent/agent-once 123
```

Runs exactly one issue. It validates `gh` and `opencode` before it starts.

## Project setup checklist

### Sequential mode (simple)
- [ ] Install: `curl ... | bash`
- [ ] Edit `.agent/prompt.md` (labels, branch rules, test commands, etc.)
- [ ] Ensure `gh` CLI is authenticated
- [ ] Ensure `opencode` CLI is installed
- [ ] Run `.agent/agent 10`

### Parallel mode (advanced)
- [ ] Install: `curl ... | bash`
- [ ] Edit `.agent/prompt.md` for sequential fallback
- [ ] Ensure issues have proper format (use `to-issues` skill)
- [ ] Each issue must list "## Existing files to modify" and "## New files"
- [ ] Each issue must list "## Blocked by" dependencies
- [ ] Run `.agent/parallel-agents --dry-run` to verify
- [ ] Run `.agent/parallel-agents` to execute

## How parallel mode works

The `.agent/parallel-agents` orchestrator:
1. Fetches all open issues
2. Parses "## Existing files to modify" and "## New files" sections
3. Parses "## Blocked by" section to check dependencies
4. Finds issues that can run in parallel (no file overlap, no open blockers)
5. Spawns `.agent/agent-once` for each parallel issue
6. Waits for all to complete
7. Repeats until no more issues

Each `.agent/agent-once` run renders a concrete single-issue prompt before invoking `opencode`, so parallel mode does not rely on issue numbers coming from environment variables.

## Command Contracts

### `.agent/agent <iterations>`

- Reads `.agent/prompt.md`
- Appends to `.agent/progress.md`
- Runs the sequential issue loop
- Requires `gh` and `opencode`
- Exit code `0` means the loop finished normally
- Exit code `1` means the command could not start correctly

### `.agent/agent-once <issue-number>`

- Works on exactly one GitHub issue
- Reads `.agent/agent-once-prompt.md`
- Appends to `.agent/progress.md`
- Updates GitHub labels and issue state for that issue
- Requires `gh` and `opencode`
- Exit code `0` means the issue completed
- Exit code `1` means the issue failed after retries

### `.agent/parallel-agents`

- Scans open child issues
- Reads issue bodies to detect file conflicts and blockers
- Spawns `.agent/agent-once` for schedulable issues
- Requires `gh`, `jq`, and `opencode`
- Exit code `0` means all child issues are complete or it was a dry run
- Exit code `1` means failed child issues remain open
- Exit code `2` means child issues are still in progress elsewhere
- Exit code `3` means child issues remain open but none are schedulable

### `install.sh`

- Creates or updates the local `.agent/` command directory
- Adds `.agent/progress.md` to `.gitignore`
- Installs shared skills into `~/.agents/skills`
- Runs in `bash`
- Exit code `0` means install completed successfully
- Exit code `1` means install prerequisites or required skill installation failed

**Parallelism rules:**
- Two issues can run in parallel if they have **zero file overlap**
- Issues blocked by open issues cannot run until blockers are closed
- The orchestrator automatically detects conflicts and serializes when needed

**Labels used:**
- `in-progress` - Agent is working on this issue
- `completed` - Agent finished successfully
- `failed` - Agent failed after 3 retries

## Issue Lifecycle

The bash wrapper (`agent-once`) owns all label transitions. The AI must **not** close issues or change labels directly.

```
┌──────────┐   agent-once    ┌─────────────┐
│  open    │ ──────────────► │ in-progress │
└──────────┘   adds label    └──────┬──────┘
                                    │
                      ┌─────────────┴─────────────┐
                      │                           │
               AI signals COMPLETE          3 retries exhausted
                      │                           │
                      ▼                           ▼
              ┌─────────────┐             ┌──────────┐
              │  completed  │             │  failed  │
              └─────────────┘             └──────────┘
```

**Who does what:**

| Action | Actor | Mechanism |
|--------|-------|-----------|
| Add `in-progress` label | `agent-once` (bash) | Before first opencode run |
| Implement the issue | AI (via opencode) | Reads prompt, writes code |
| Commit with `fixes #N` | AI (via opencode) | May auto-close the issue on push |
| Comment on the issue | AI (via opencode) | `gh issue comment` |
| Add `completed` label | `agent-once` (bash) | After AI signals `COMPLETE` |
| Add `failed` label | `agent-once` (bash) | After 3 retries exhausted |
| Remove `in-progress` label | `agent-once` (bash) | On completion or failure |

> **Important:** The AI is instructed to **not** close the issue or change labels. The `fixes #N` commit message may auto-close the issue on push, which is fine — the bash wrapper handles labels independently.

## Files

| File | Tracked? | Purpose |
|------|----------|---------|
| `.agent/agent` | Yes | The bash loop runner (sequential mode) |
| `.agent/agent-once` | Yes | Single-issue worker with 3 retries (parallel mode) |
| `.agent/parallel-agents` | Yes | Orchestrator that auto-detects parallelism (parallel mode) |
| `.agent/prompt.md` | Yes | AI system prompt for sequential mode (edit per project) |
| `.agent/agent-once-prompt.md` | Yes | AI system prompt for single issue (parallel mode) |
| `.agent/VERSION` | Yes | Version of issue-agent installed |
| `.agent/progress.md` | No | Local log of what the agent did |

## Requirements

- [opencode](https://github.com/opencode-ai/opencode) CLI
- [GitHub CLI](https://cli.github.com/)
- [jq](https://jqlang.org/)
- bash
- A GitHub repository with issues enabled

## Skills

The following skills are installed automatically:

Shared skills are installed into `~/.agents/skills`. Project commands stay local under `.agent/`.

### write-prd
Creates a PRD (Product Requirements Document) as a GitHub issue with:
- Problem statement
- User stories
- Developer stories
- Implementation decisions
- Testing decisions

### to-issues
Breaks a PRD into vertical slice issues with:
- File dependency tracking
- Parallelism analysis
- Blocked by relationships
- Acceptance criteria

These skills ensure issues are formatted correctly for parallel agent execution.

**Issue format required for parallel mode:**

Each issue must have these sections:
```markdown
## Existing files to modify

- `path/to/file1.js`
- `path/to/file2.js`

## New files

- `path/to/newfile.js`
- `path/to/newfile.test.js`

## Blocked by

- #<issue-number> (if any)

Or "None - can start immediately" if no blockers.
```

The orchestrator parses these sections to detect file conflicts and dependencies.

## License

MIT
