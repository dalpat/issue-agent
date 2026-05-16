#!/usr/bin/env bash
set -e

REPO_ROOT="https://raw.githubusercontent.com/dalpat/issue-agent/main/template"

if [ ! -d ".git" ]; then
  echo "Warning: No .git directory found. Installing anyway."
fi

mkdir -p .agent

# If running from a clone of issue-agent, use local templates
if [ -f "$(dirname "$0")/template/agent" ]; then
  TEMPLATE_DIR="$(dirname "$0")/template"
  cp "$TEMPLATE_DIR/agent" .agent/agent
  cp "$TEMPLATE_DIR/prompt.md" .agent/prompt.md
  cp "$TEMPLATE_DIR/.gitignore" .agent/.gitignore
  
  # Parallel agent files (optional)
  if [ -f "$TEMPLATE_DIR/agent-once" ]; then
    cp "$TEMPLATE_DIR/agent-once" agent-once
    cp "$TEMPLATE_DIR/parallel-agents" parallel-agents
    cp "$TEMPLATE_DIR/agent-once-prompt.md" .agent/agent-once-prompt.md
    chmod +x agent-once parallel-agents
  fi
else
  curl -fsSL "$REPO_ROOT/agent" -o .agent/agent
  curl -fsSL "$REPO_ROOT/prompt.md" -o .agent/prompt.md
  curl -fsSL "$REPO_ROOT/.gitignore" -o .agent/.gitignore
  
  # Parallel agent files (optional)
  if curl -fsSL "$REPO_ROOT/agent-once" -o agent-once 2>/dev/null; then
    curl -fsSL "$REPO_ROOT/parallel-agents" -o parallel-agents
    curl -fsSL "$REPO_ROOT/agent-once-prompt.md" -o .agent/agent-once-prompt.md
    chmod +x agent-once parallel-agents
  fi
fi

chmod +x .agent/agent
touch .agent/progress.md

# Install skills (required for parallel mode)
SKILLS_DIR="$HOME/.agents/skills"
if [ -d "$(dirname "$0")/template" ] && [ -d "$(dirname "$0")/skills" ]; then
  SKILLS_SOURCE="$(dirname "$0")/skills"
  mkdir -p "$SKILLS_DIR"
  for skill_dir in "$SKILLS_SOURCE"/*/; do
    skill_name=$(basename "$skill_dir")
    if [ -f "$skill_dir/SKILL.md" ]; then
      mkdir -p "$SKILLS_DIR/$skill_name"
      cp "$skill_dir/SKILL.md" "$SKILLS_DIR/$skill_name/"
      echo "Installed skill: $skill_name"
    fi
  done
else
  # Download skills from repo
  for skill in write-prd to-issues; do
    mkdir -p "$SKILLS_DIR/$skill"
    if curl -fsSL "$REPO_ROOT/skills/$skill/SKILL.md" -o "$SKILLS_DIR/$skill/SKILL.md" 2>/dev/null; then
      echo "Installed skill: $skill"
    fi
  done
fi

if [ -f ".gitignore" ]; then
  if ! grep -q "^\\.agent/progress\\.md$" .gitignore; then
    echo ".agent/progress.md" >> .gitignore
    echo "Updated .gitignore"
  fi
else
  echo ".agent/progress.md" > .gitignore
  echo "Created .gitignore"
fi

echo ""
echo "issue-agent installed."
echo ""
echo "Sequential mode: Edit .agent/prompt.md, then run: .agent/agent 10"
echo "Parallel mode:   Use write-prd + to-issues skills, then run: ./parallel-agents --dry-run"
echo ""
echo "Installed skills: write-prd, to-issues"
