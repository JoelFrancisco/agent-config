---
name: claude-delegate
description: Delegate one well-specified task to Claude Fable 5 at high effort via headless claude -p and return its final message. Use when a task exceeds the local model — a design decision, tricky debugging, deep multi-file reasoning, or any judgment call worth escalating to the smartest model available.
---

# Claude delegate — escalate one task to Fable 5

`claude -p` runs a full headless Claude Code instance on Fable 5 — the
smartest model on this machine — with the user's CLAUDE.md, skills, and MCP
servers loaded. You compose the prompt and judge the answer; Fable does the
thinking. Never grind on a task below the bar when this escalation exists.

1. Write ONE self-contained prompt, like a ticket: goal, repo-relative files,
   expected behavior, constraints (style, deps, an exemplar file to follow),
   and how to verify. The run sees none of this conversation — include
   everything it needs.
2. Pick the permission surface. In `-p` mode there is no TTY to ask on: any
   tool call not covered below is DENIED mid-run, not prompted — pick so
   nothing the task needs gets denied.
   - Analysis / investigation (hard read-only — Edit/Write not even loaded):
     `--tools "Read,Glob,Grep,Bash" --allowedTools "Bash(git diff:*),Bash(git log:*),Bash(git show:*),Bash(git status:*)"`
   - Edits + build/test commands:
     `--permission-mode acceptEdits --allowedTools "Bash"`
3. Run it as ONE foreground shell command:
   `cd <workdir> && printf '%s' "<prompt>" | claude -p --model fable --effort high <permission flags>; echo "exit=$?"`
   - The prompt goes via stdin (`printf '%s' "<prompt>" |`) — `--allowedTools`
     and `--tools` are variadic and swallow a positional prompt argument.
   - `claude` has no workdir flag — `cd <workdir>` inside the same command.
   - `claude` needs network access to reach the API. Run this command outside
     any network-blocked sandbox (on Codex, that means escalated/network
     permissions for this command).
   - Stay in the foreground until the process exits — a detached run keeps
     editing after you've already read a half-written tree.
4. Stdout is the run's final message. If it edited files, run
   `git -C <workdir> diff --stat` to capture what changed. Empty output or a
   non-zero exit → report the failure with the stderr tail instead of
   retrying blind.
