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

```bash
.agent/agent 10
```

Runs up to 10 iterations, stopping early if the AI signals completion with `<promise>COMPLETE</promise>`.

## Project setup checklist

- [ ] Install: `curl ... | bash`
- [ ] Edit `.agent/prompt.md` (labels, branch rules, test commands, etc.)
- [ ] Ensure `gh` CLI is authenticated
- [ ] Ensure `opencode` CLI is installed
- [ ] Run `.agent/agent 10`

## Files

| File | Tracked? | Purpose |
|------|----------|---------|
| `.agent/agent` | Yes | The zsh loop runner |
| `.agent/prompt.md` | Yes | AI system prompt (edit per project) |
| `.agent/progress.md` | No | Local log of what the agent did |

## Requirements

- [opencode](https://github.com/opencode-ai/opencode) CLI
- [GitHub CLI](https://cli.github.com/)
- zsh
- A GitHub repository with issues enabled

## License

MIT
