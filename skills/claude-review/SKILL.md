---
name: claude-review
description: Independent review by Claude Fable 5 at high effort — a fresh-context headless claude -p run, hard read-only, findings ordered by severity with exact file:line. Diff review of current changes against a base, or full-file adversarial review of specific named files. Use before merging nontrivial work, or when asked for a second opinion from the smartest model.
---

# Claude review — Fable 5 second perspective

A fresh headless Fable 5 run reviews with intelligence 9 and taste 9, and
none of this session's context — it judges the code, not your narrative of
it.

1. Compose a self-contained review prompt. The run sees none of this
   conversation: name the diff base (or the files), the change's intent in one
   or two sentences, and any focus ("concurrency and error handling"). Ask for
   a prioritized list of concrete findings with file:line — explicitly not a
   rewrite.
   - Diff review: "Review the changes shown by `git diff <base>...HEAD` (or
     `git diff` for uncommitted work) against the intent: <intent>."
   - Full-file adversarial review (new/uncommitted files, or "read them
     directly, don't rely on my summary"): "Adversarial code review of <files>.
     Read each file directly from disk. Find bugs that only surface at
     runtime, edge cases, and security issues."
2. Run — ONE foreground shell command, hard read-only (Edit/Write not even
   loaded; in `-p` mode any shell call outside the allowlist is denied, not
   prompted):
   `cd <repo-root> && printf '%s' "<prompt>" | claude -p --model fable --effort high --tools "Read,Glob,Grep,Bash" --allowedTools "Bash(git diff:*),Bash(git log:*),Bash(git show:*),Bash(git status:*)"; echo "exit=$?"`
   The prompt goes via stdin — `--tools`/`--allowedTools` are variadic and
   swallow a positional prompt argument. `claude` has no workdir flag, so
   `cd <repo-root>` inside the same command. Findings print to stdout.
   `claude` needs network access to reach the API — run this command outside
   any network-blocked sandbox (on Codex, escalated/network permissions).
3. Triage its findings — confirm each claimed issue at the cited file:line
   before acting on it. Fable's findings carry the most weight of any
   reviewer available here; a finding you can't confirm goes back to the user
   as an open question, not silently dropped.
4. Report: confirmed findings (with file:line), rejected findings and why.
