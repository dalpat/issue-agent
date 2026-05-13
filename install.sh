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
else
  curl -fsSL "$REPO_ROOT/agent" -o .agent/agent
  curl -fsSL "$REPO_ROOT/prompt.md" -o .agent/prompt.md
  curl -fsSL "$REPO_ROOT/.gitignore" -o .agent/.gitignore
fi

chmod +x .agent/agent
touch .agent/progress.md

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
echo "Edit .agent/prompt.md for your project, then run: .agent/agent 10"
