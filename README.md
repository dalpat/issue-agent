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

## What it does

1. Creates a `.agent/` directory inside your project
2. Copies the runner script and a starter prompt
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
./parallel-agents
```

Auto-detects which issues can run in parallel by parsing file dependencies from issue bodies. Spawns multiple agents simultaneously for non-conflicting issues.

**Requirements for parallel mode:**
- Issues must have "## Existing files to modify" and "## New files" sections
- Issues must have "## Blocked by" section listing dependencies
- Use the `to-issues` skill to create properly formatted issues

**Dry-run (see what would happen):**
```bash
./parallel-agents --dry-run
```

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
- [ ] Run `./parallel-agents --dry-run` to verify
- [ ] Run `./parallel-agents` to execute

## How parallel mode works

The `parallel-agents` orchestrator:
1. Fetches all open issues
2. Parses "## Existing files to modify" and "## New files" sections
3. Parses "## Blocked by" section to check dependencies
4. Finds issues that can run in parallel (no file overlap, no open blockers)
5. Spawns `agent-once` for each parallel issue
6. Waits for all to complete
7. Repeats until no more issues

**Parallelism rules:**
- Two issues can run in parallel if they have **zero file overlap**
- Issues blocked by open issues cannot run until blockers are closed
- The orchestrator automatically detects conflicts and serializes when needed

**Labels used:**
- `in-progress` - Agent is working on this issue
- `completed` - Agent finished successfully
- `failed` - Agent failed after 3 retries

## Files

| File | Tracked? | Purpose |
|------|----------|---------|
| `.agent/agent` | Yes | The zsh loop runner (sequential mode) |
| `.agent/prompt.md` | Yes | AI system prompt for sequential mode (edit per project) |
| `.agent/agent-once-prompt.md` | Yes | AI system prompt for single issue (parallel mode) |
| `.agent/progress.md` | No | Local log of what the agent did |
| `agent-once` | Yes | Single-issue worker with 3 retries (parallel mode) |
| `parallel-agents` | Yes | Orchestrator that auto-detects parallelism (parallel mode) |

## Requirements

- [opencode](https://github.com/opencode-ai/opencode) CLI
- [GitHub CLI](https://cli.github.com/)
- zsh
- A GitHub repository with issues enabled

## Skills

The following skills are installed automatically:

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
