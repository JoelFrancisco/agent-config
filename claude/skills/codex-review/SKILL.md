---
name: codex-review
description: Get an independent gpt-5.5 code review as an extra perspective alongside (never instead of) your own. Two modes — a diff review of the current changes via `codex review`, and a full-file adversarial review of specific named files read from disk ("adversarial review of these files", "read them directly, don't rely on my summary", "find runtime-only bugs"). Use before merging agent-driven PRs or when the user asks for a second opinion.
---

# Codex review — independent second perspective

**Always append `</dev/null`** to every codex invocation below. This harness
runs commands with a non-TTY stdin pipe, and codex then blocks forever
("Reading additional input from stdin...") waiting for input that never comes —
this is the #1 way these runs fail. It is not optional or background-only.

1. Pick the diff base and run `codex review` from the repo root (it is
   diff-based, so it needs the git repo — run it inside one):
   - Working tree changes: `codex review --uncommitted </dev/null`
   - Branch against base: `codex review --base <default-branch> </dev/null`
   - Optional focus as a trailing prompt, e.g.
     `codex review --base main "Focus on concurrency and error handling" </dev/null`
2. Triage its findings yourself — verify each claimed issue against the code
   before repeating it. Codex has taste 5: trust it on correctness and logic,
   double-check its style and API-design opinions against your own judgment.
3. Report: confirmed findings (with file:line), rejected findings and why.

## Full-file adversarial review (files not in a diff)

When the ask is to review specific files by their **full contents** — new/uncommitted files, or "read them directly, don't rely on my summary" — `codex review` (which is diff-based) doesn't fit. Use `codex exec` read-only with a canonical prompt:

```
codex exec -s read-only -C <repo-root> --skip-git-repo-check -o "$(mktemp)" \
  "Adversarial code review of <file1> <file2>. Read each file directly from disk. Find bugs that only surface at runtime, edge cases, and security issues. Do NOT rewrite code — return a prioritized list of concrete findings with file:line." </dev/null
```

`--skip-git-repo-check` is a no-op inside a git repo and required if `<repo-root>`
is not one (else codex refuses with "Not inside a trusted directory"). Read the
tmpfile for the result. Triage its findings exactly as in steps 2–3.
