#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"

command -v jq >/dev/null || { echo "error: jq is required" >&2; exit 1; }
command -v codex >/dev/null || echo "warning: codex CLI not found — install it and run 'codex login'" >&2

# link <target> <linkpath> — symlink, backing up any pre-existing real file
link() {
  local target=$1 linkpath=$2
  if [ -e "$linkpath" ] && [ ! -L "$linkpath" ]; then
    mv "$linkpath" "${linkpath}.pre-agent-config"
    echo "backed up $linkpath -> ${linkpath}.pre-agent-config"
  fi
  ln -sfn "$target" "$linkpath"
  echo "linked   $linkpath -> $target"
}

# 1. Global CLAUDE.md
mkdir -p "$CLAUDE_DIR"
link "$REPO_DIR/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"

# 2. Status line script
link "$REPO_DIR/claude/ccstatusline" "$CLAUDE_DIR/ccstatusline"

# 3. Agents
mkdir -p "$CLAUDE_DIR/agents"
for f in "$REPO_DIR"/claude/agents/*.md; do
  link "$f" "$CLAUDE_DIR/agents/$(basename "$f")"
done

# 4. Skills (per-skill symlinks; existing unrelated skills are untouched)
mkdir -p "$CLAUDE_DIR/skills"
for d in "$REPO_DIR"/claude/skills/*/; do
  link "${d%/}" "$CLAUDE_DIR/skills/$(basename "$d")"
done

# 5. Merge claude-settings.json into ~/.claude/settings.json
#    (sets effortLevel, unions permissions.allow; everything else preserved)
SETTINGS="$CLAUDE_DIR/settings.json"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
cp "$SETTINGS" "${SETTINGS}.bak"
jq -s '
  .[0] as $cur | .[1] as $frag |
  ($cur * $frag)
  | .permissions.allow =
      ((($cur.permissions.allow // []) + ($frag.permissions.allow // [])) | unique)
' "$SETTINGS" "$REPO_DIR/claude-settings.json" > "${SETTINGS}.tmp"
mv "${SETTINGS}.tmp" "$SETTINGS"
echo "merged   claude-settings.json into $SETTINGS (backup: ${SETTINGS}.bak)"

# 6. Codex config — seed only if absent; never clobber an existing one
CODEX_CFG="${HOME}/.codex/config.toml"
if [ -f "$CODEX_CFG" ]; then
  if grep -q '^model *= *"gpt-5.5"' "$CODEX_CFG"; then
    echo "ok       $CODEX_CFG already targets gpt-5.5 — left untouched"
  else
    echo "NOTE:    $CODEX_CFG exists but doesn't pin gpt-5.5 — merge codex-config.toml manually"
  fi
else
  mkdir -p "${HOME}/.codex"
  cp "$REPO_DIR/codex-config.toml" "$CODEX_CFG"
  echo "seeded   $CODEX_CFG"
fi

# 7. Cross-CLI skills (Codex + OpenCode only — Claude Code IS claude, it
#    doesn't need skills for delegating to itself)
mkdir -p "${HOME}/.codex/skills" "${HOME}/.config/opencode/skill"
for d in "$REPO_DIR"/skills/*/; do
  link "${d%/}" "${HOME}/.codex/skills/$(basename "$d")"
  link "${d%/}" "${HOME}/.config/opencode/skill/$(basename "$d")"
done

# 8. OpenCode agents
mkdir -p "${HOME}/.config/opencode/agents"
for f in "$REPO_DIR"/opencode/agents/*.md; do
  link "$f" "${HOME}/.config/opencode/agents/$(basename "$f")"
done

echo
echo "done — new Claude Code sessions pick up CLAUDE.md, skills, and agents automatically."
echo "symlinked files track this repo: 'git pull' updates them in place;"
echo "re-run apply.sh only when claude-settings.json changes."
