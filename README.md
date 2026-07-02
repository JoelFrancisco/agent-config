# agent-config

Portable Claude Code + Codex workflow config, after [Theo's Fable rate-limit
workflow](https://x.com/theo/status/2072481845363822914): Fable at **high**
effort orchestrates; gpt-5.5 (Codex CLI) executes well-spec'd work; token-hungry
tasks (computer use, codebase analysis) run on cheaper models and report
conclusions back.

## Layout

| path | what it is |
|---|---|
| `claude/CLAUDE.md` | global memory: model-routing table + escalation policy |
| `claude/agents/codex-delegate.md` | thin sonnet wrapper so Workflows/subagents can use gpt-5.5 |
| `claude/skills/codex-implementation/` | delegate clear-spec implementation to `codex exec` |
| `claude/skills/codex-review/` | independent gpt-5.5 review via `codex review` |
| `claude/skills/codex-computer-use/` | browser/UI verification delegated to Codex |
| `claude-settings.json` | fragment merged into `~/.claude/settings.json` (`effortLevel: high`, codex permissions) |
| `codex-config.toml` | seed for `~/.codex/config.toml` (applied only if absent) |
| `apply.sh` | idempotent installer (symlinks + jq merge) |

## Apply on a new machine

```bash
git clone git@github.com:JoelFrancisco/agent-config.git
cd agent-config && ./apply.sh
```

Prereqs: `jq`; Claude Code; Codex CLI installed and authed (`codex login`).

- `CLAUDE.md`, agents, and skills are **symlinked** — `git pull` updates them
  in place; re-run `apply.sh` only when `claude-settings.json` changes.
- `apply.sh` never destroys local state: pre-existing real files are backed up
  as `*.pre-agent-config`, `settings.json` is merged (backup at
  `settings.json.bak`), and an existing `~/.codex/config.toml` is left
  untouched.

## The workflow in one paragraph

Fable runs the main loop at `high` effort (xhigh is token-hungry, max is a
furnace). Clear-spec implementation, migrations, and data analysis go to
gpt-5.5 through `codex exec` — spec written like a ticket, output reviewed
before accepting. UI/UX verification and computer use go to Codex too (it's
better at them, and screenshots burn main-loop tokens). Codebase sweeps go to
sonnet subagents or the gemini CLI. Escalation is standing policy: judge the
output, not the price tag — if a cheaper model misses the bar, redo with a
smarter one without asking.
