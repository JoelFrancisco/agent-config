---
name: claude-review
description: Independent Claude review — a fresh-context headless opus run via claude -p, hard read-only, findings ordered by severity with exact file:line. Diff review of current changes against a base, or full-file adversarial review of specific named files. Use for a second opinion with taste (API design, naming, copy) or as the Claude leg alongside codex-review when two independent perspectives are wanted.
---

# Claude review — independent second perspective

A fresh headless opus run reviews with taste 8 and none of this session's
context — it judges the code, not your narrative of it.

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
2. Run — ONE Bash call, hard read-only (Edit/Write not even loaded; in `-p`
   mode any Bash call outside the allowlist is denied, not prompted):
   `cd <repo-root> && printf '%s' "<prompt>" | claude -p --model opus --effort high --tools "Read,Glob,Grep,Bash" --allowedTools "Bash(git diff:*),Bash(git log:*),Bash(git show:*),Bash(git status:*)"; echo "exit=$?"`
   The prompt goes via stdin — `--tools`/`--allowedTools` are variadic and
   swallow a positional prompt argument. `claude` has no workdir flag, so
   `cd <repo-root>` inside the same call. Findings print to stdout.
3. Triage its findings yourself — verify each claimed issue against the code
   before repeating it. Opus has taste 8: its style and API-design findings
   carry weight; still confirm every correctness claim at the cited file:line.
4. Report: confirmed findings (with file:line), rejected findings and why.
