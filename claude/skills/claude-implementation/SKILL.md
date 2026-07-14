---
name: claude-implementation
description: Delegate an implementation task that needs taste — UI, copy, API design, or code that must follow this repo's Claude Code conventions (CLAUDE.md, skills, MCP) — to a headless Claude (sonnet, or opus for the highest-stakes surfaces) via claude -p. Use when the spec is clear but the work needs more taste than Codex; for mechanical clear-spec work use codex-implementation instead.
---

# Claude implementation delegate

A headless Claude Code run is the executor for well-spec'd work that still
needs taste (sonnet 7, opus 8 — vs Codex's 5) or the repo's Claude Code
harness: it auto-loads CLAUDE.md, skills, and MCP servers that Codex never
sees. Your job is the spec and the review; the headless run's job is the
typing.

1. Write the spec like a ticket: goal, files to touch, expected behavior,
   constraints (style, deps, patterns — name an exemplar file to follow), and
   exact verification steps (commands to run). The run inherits the repo's
   CLAUDE.md and skills but sees none of this conversation; the task itself
   must be self-contained.
   - When several delegated runs share one checkout, name that run's
     file-ownership boundary in the prompt — the exact paths it owns — and
     have it confine every edit to those paths and leave git state as the
     caller left it (staging, branch, and commits untouched).
2. Run — ONE Bash call (shell state does not persist between Bash calls):
   `cd <repo-root> && printf '%s' "<spec>" | claude -p --model sonnet --effort medium --permission-mode acceptEdits --allowedTools "Bash"; echo "exit=$?"`
   Stdout is the run's final message. Independent tasks may run in parallel
   from separate Bash calls.
   - **Prompt via stdin** (`printf '%s' "<spec>" |`) — `--allowedTools` is
     variadic and swallows a positional prompt argument. `claude` has no
     workdir flag, so `cd <repo-root>` inside the same call.
   - **Model + effort:** match the routing table — standard implementation →
     `--model sonnet --effort medium`, mechanical-but-convention-bound →
     `--effort low`, highest-stakes user-facing surfaces → `--model opus`.
     Never `--model fable` — Fable is the caller.
   - **Permissions:** in `-p` mode uncovered tool calls are DENIED, not
     prompted. `acceptEdits` + `--allowedTools "Bash"` covers edits, builds,
     and tests; if the run needs more, use `--dangerously-skip-permissions`
     only inside an isolated worktree.
   - **Long runs (large spec, big migration) — don't foreground-poll.** Launch
     via the Bash tool with `run_in_background: true`, redirecting stdout to a
     fixed path you chose (e.g. `/tmp/claude-<slug>.md` — NOT mktemp, or you
     won't find it later) and let its completion notification wake you. Let
     the harness do the waiting — never hand-assemble `nohup`/`sleep`/`pgrep`/
     `tail -f` polling loops.
3. Review before accepting — you own correctness:
   - `git diff` the changes and actually read them.
   - Run the verification commands from the spec (tests, build).
4. If the output doesn't meet the bar: refine the prompt and rerun once; after
   that, escalate — redo it yourself without asking.

Do NOT delegate: security-sensitive changes, or work whose spec you can't yet
state crisply.
