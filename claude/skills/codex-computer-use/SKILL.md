---
name: codex-computer-use
description: Delegate browser/UI verification and computer-use tasks to Codex (gpt-5.5) — launching the app, clicking through flows, verifying UI/UX changes visually. Use when a change needs to be seen working in a real browser and screenshots would burn main-loop tokens.
---

# Codex computer use — UI/UX verification delegate

Codex is markedly better and cheaper at computer use and UI/UX verification
than the main loop (screenshots are token furnaces).

1. Write a self-contained verification brief for Codex: how to launch the app
   (dev server command, port), the flow to exercise step by step, and what
   "correct" looks like (layout, copy, behavior, no console errors).
2. Run:
   `codex exec -s workspace-write -C <repo-root> -o "$(mktemp)" "<brief>" </dev/null`
   Always close stdin with `</dev/null` (codex blocks on a non-TTY stdin pipe).
   Tell it to use its browser tooling, take its own screenshots, and end with
   PASS/FAIL per checkpoint plus anything unexpected it saw.
3. Read the output file; report only the verdict and findings — never pull raw
   screenshots into the main context.
4. FAIL or ambiguous → inspect yourself (chrome-devtools skill) before fixing.
