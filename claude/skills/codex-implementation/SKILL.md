---
name: codex-implementation
description: Delegate a well-specified implementation task (clear-spec feature, boilerplate, migration, mechanical multi-file change) to Codex (gpt-5.5) via codex exec instead of implementing it inline. Use when the spec is clear and the work doesn't need main-loop-level judgment.
---

# Codex implementation delegate

GPT-5.5 is extremely steerable and efficient at executing well-spec'd work.
Your job is the spec and the review; Codex's job is the typing.

1. Write the spec like a ticket: goal, files to touch, expected behavior,
   constraints (style, deps, patterns — name an exemplar file to follow), and
   exact verification steps (commands to run). Codex has no access to this
   conversation; the prompt must be self-contained.
2. Run:
   `codex exec -s workspace-write -C <repo-root> -o "$(mktemp)" "<spec>" </dev/null`
   Always close stdin with `</dev/null`; with a non-TTY pipe attached, codex
   blocks waiting for extra stdin input. Independent tasks may run in
   parallel with separate output files.
3. Review before accepting — you own correctness:
   - `git diff` the changes and actually read them.
   - Run the verification commands from the spec (tests, build).
4. If the output doesn't meet the bar: refine the prompt and rerun once; after
   that, escalate — redo it yourself without asking.

Do NOT delegate: anything user-facing that needs taste (UI, copy, API design),
security-sensitive changes, or work whose spec you can't yet state crisply.
