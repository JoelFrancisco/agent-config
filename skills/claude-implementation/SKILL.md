---
name: claude-implementation
description: Delegate an implementation task to Claude Fable 5 at high effort via headless claude -p — user-facing work needing top taste (UI, copy, API design), subtle multi-file changes, or code that must follow the repo's Claude Code conventions (CLAUDE.md, skills, MCP). Use when the work needs more intelligence or taste than the local model.
---

# Claude implementation — Fable 5 as the implementer

A headless `claude -p` run on Fable 5 (intelligence 9, taste 9) implements
with the repo's Claude Code harness auto-loaded: CLAUDE.md, skills, and MCP
servers the local model never sees. Your job is the spec and the review;
Fable's job is the code.

1. Write the spec like a ticket: goal, files to touch, expected behavior,
   constraints (style, deps, patterns — name an exemplar file to follow), and
   exact verification steps (commands to run). The run inherits the repo's
   CLAUDE.md and skills but sees none of this conversation; the task itself
   must be self-contained.
   - When several delegated runs share one checkout, name each run's
     file-ownership boundary in the prompt — the exact paths it owns — and
     have it confine every edit to those paths and leave git state as the
     caller left it (staging, branch, and commits untouched).
2. Run — ONE foreground shell command:
   `cd <repo-root> && printf '%s' "<spec>" | claude -p --model fable --effort high --permission-mode acceptEdits --allowedTools "Bash"; echo "exit=$?"`
   Stdout is the run's final message.
   - **Prompt via stdin** (`printf '%s' "<spec>" |`) — `--allowedTools` is
     variadic and swallows a positional prompt argument. `claude` has no
     workdir flag, so `cd <repo-root>` inside the same command.
   - **Permissions:** in `-p` mode uncovered tool calls are DENIED, not
     prompted. `acceptEdits` + `--allowedTools "Bash"` covers edits, builds,
     and tests.
   - **Network:** `claude` needs API access. Run this command outside any
     network-blocked sandbox (on Codex, escalated/network permissions for
     this command).
   - Stay in the foreground until the process exits — a detached run keeps
     editing after you've already read a half-written tree.
3. Review before accepting — you own the integration:
   - `git diff` the changes and actually read them.
   - Run the verification commands from the spec (tests, build).
4. If the output misses the spec: refine the prompt (state what was wrong and
   what correct looks like) and rerun once; still failing → surface the gap to
   the user rather than patching Fable's work with a weaker model.
