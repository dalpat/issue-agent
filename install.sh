#!/usr/bin/env bash
set -e

TEMPLATE_ROOT="https://raw.githubusercontent.com/dalpat/issue-agent/main/template"
SKILLS_ROOT="https://raw.githubusercontent.com/dalpat/issue-agent/main/skills"

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
    cp "$TEMPLATE_DIR/agent-once" .agent/agent-once
    cp "$TEMPLATE_DIR/parallel-agents" .agent/parallel-agents
    cp "$TEMPLATE_DIR/agent-once-prompt.md" .agent/agent-once-prompt.md
    chmod +x .agent/agent-once .agent/parallel-agents
  fi
else
  curl -fsSL "$TEMPLATE_ROOT/agent" -o .agent/agent
  curl -fsSL "$TEMPLATE_ROOT/prompt.md" -o .agent/prompt.md
  curl -fsSL "$TEMPLATE_ROOT/.gitignore" -o .agent/.gitignore
  
  # Parallel agent files (optional)
  if curl -fsSL "$TEMPLATE_ROOT/agent-once" -o .agent/agent-once 2>/dev/null; then
    curl -fsSL "$TEMPLATE_ROOT/parallel-agents" -o .agent/parallel-agents
    curl -fsSL "$TEMPLATE_ROOT/agent-once-prompt.md" -o .agent/agent-once-prompt.md
    chmod +x .agent/agent-once .agent/parallel-agents
  fi
fi

chmod +x .agent/agent
touch .agent/progress.md

# Install skills (required for parallel mode)
SKILLS_DIR="$HOME/.agents/skills"
installed_skills=()
failed_skills=()
if [ -d "$(dirname "$0")/template" ] && [ -d "$(dirname "$0")/skills" ]; then
  SKILLS_SOURCE="$(dirname "$0")/skills"
  mkdir -p "$SKILLS_DIR"
  for skill_dir in "$SKILLS_SOURCE"/*/; do
    skill_name=$(basename "$skill_dir")
    if [ -f "$skill_dir/SKILL.md" ]; then
      mkdir -p "$SKILLS_DIR/$skill_name"
      cp "$skill_dir/SKILL.md" "$SKILLS_DIR/$skill_name/"
      installed_skills+=("$skill_name")
      echo "Installed skill: $skill_name"
    fi
  done
else
  # Download skills from repo
  for skill in write-prd to-issues; do
    mkdir -p "$SKILLS_DIR/$skill"
    if curl -fsSL "$SKILLS_ROOT/$skill/SKILL.md" -o "$SKILLS_DIR/$skill/SKILL.md" 2>/dev/null; then
      installed_skills+=("$skill")
      echo "Installed skill: $skill"
    else
      failed_skills+=("$skill")
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

if [ ${#failed_skills[@]} -gt 0 ]; then
  echo "Error: Failed to install required skills: ${failed_skills[*]}" >&2
  exit 1
fi

echo ""
echo "issue-agent installed."
echo ""
echo "Project commands live under: .agent/"
echo "Sequential mode: Edit .agent/prompt.md, then run: .agent/agent 10"
echo "Single issue:    Run .agent/agent-once <issue-number>"
echo "Parallel mode:   Use write-prd + to-issues skills, then run: .agent/parallel-agents --dry-run"
echo ""
echo "Shared skills install to: $SKILLS_DIR"
if [ ${#installed_skills[@]} -gt 0 ]; then
  echo "Installed skills: ${installed_skills[*]}"
else
  echo "Installed skills: none"
fi
