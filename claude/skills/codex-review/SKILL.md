---
name: codex-review
description: Get an independent gpt-5.5 code review of the current changes via codex review, as an extra perspective alongside (never instead of) your own review. Use before merging agent-driven PRs or when the user asks for a second opinion.
---

# Codex review — independent second perspective

1. Pick the diff base and run from the repo root:
   - Working tree changes: `codex review --uncommitted`
   - Branch against base: `codex review --base <default-branch>`
   - Optional focus as a trailing prompt, e.g.
     `codex review --base main "Focus on concurrency and error handling"`
2. Triage its findings yourself — verify each claimed issue against the code
   before repeating it. Codex has taste 5: trust it on correctness and logic,
   double-check its style and API-design opinions against your own judgment.
3. Report: confirmed findings (with file:line), rejected findings and why.
