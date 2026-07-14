---
name: dual-review
description: Dual independent high-effort review of a ticket's MRs — Fable inline and Codex (gpt-5.6-sol high via codex-delegate) in parallel, then an adjudicated consolidation. Use when the user asks to "revisar em paralelo", asks for a dual/double review of MRs, or names Fable + Codex to review the MRs of a Jira ticket or a set of MR URLs.
---

Two independent reviewers, one adjudicator. Codex (gpt-5.6-sol, high) hunts adversarially in the background while Fable (the main loop, high) reviews inline; neither sees the other's findings until both are done. The deliverable is the consolidated review — post nothing to the MR or Jira unless asked; offer it at the end.

## 1. Resolve the MRs

From a ticket ID, pull description + comments (`atendimento-jira-get-issue`, `atendimento-jira-list-comments` from the jira skill) and extract the MR links — the diagnosis comment usually carries them plus the root-cause narrative, which becomes the bug context both reviewers get. From MR URLs, skip Jira.

Completion: for each MR — GitLab project path, IID, and a one-paragraph bug/fix context.

## 2. Stage the materials

Work in `$CLAUDE_JOB_DIR/tmp` (or a scratch dir). For each MR:

- `glab api "projects/<url-encoded-path>/merge_requests/<iid>"` → metadata json (title, branches, sha, description).
- `glab api ".../merge_requests/<iid>/changes"` → build a unified diff from `changes[].diff`. (`/diffs` can 500 on this GitLab; `/changes` is the reliable endpoint.)
- Locate the local checkout under `~/Work/Repos/gitlab/<group-path>` and `git fetch origin <source-branch>` so full files are readable at the MR state (`git show origin/<branch>:<path>`). The local working tree is usually master, not the MR state — the diff is the source of truth, the checkout is for surrounding code.

Completion: per MR, a metadata json + unified diff on disk, and the source branch fetched in the local checkout.

## 3. Launch the Codex reviewer (background)

Spawn the `codex-delegate` agent in the background with a self-contained prompt that:

- overrides its low-effort default: `-m gpt-5.6-sol -c model_reasoning_effort=high -s read-only`, and tells it to pass a Bash tool `timeout` well above 2 minutes (a high-effort review outlives the default and gets killed mid-run);
- hands over the bug/fix context, absolute paths to every diff/metadata file, and the local checkout paths (flagging they may be on master);
- asks for an adversarial hunt for real defects, findings ordered by severity with exact file:line, and an explicit "verified non-issues" section.

Completion: agent spawned in background; do not wait on it.

## 4. Fable review (inline, meanwhile)

Review the diffs yourself at full depth while Codex runs, reading the surrounding code at the MR state — not just the diff. Cover at minimum:

- every dispatch/entry path the change claims to guard — verify each actually funnels through it;
- timing and races: what is set when, read when, and what can fire in between;
- deploy/rollout order in BOTH directions when the fix spans repos;
- regressions for OTHER consumers of the changed component;
- the inverted failure: inputs where the fix produces a worse outcome than the bug (e.g. both handlers suppressed → nothing happens);
- test coverage against those same paths.

Completion: a verdict plus findings each anchored to file:line, and an explicit verified-non-issues list — written down before reading Codex's output.

## 5. Collect Codex's output

The completion signal is an idle notification carrying no content. Ask for the result via SendMessage; if the reply never lands (the subagent may lack SendMessage), extract it from the subagent transcript: the recently-modified `~/.claude/projects/<project-slug>/*.jsonl` that isn't the main session — take the last `type: "assistant"` entry's text block.

Completion: Codex's full review text in hand, including its non-issues section.

## 6. Adjudicate and consolidate

Never union the two finding lists. For every finding the reviews disagree on — or that only one raised — re-check the code and rule on it; re-grade severities against evidence (a "blocker" that first requires a contract to change shape is a robustness ask, not a blocker). Structure the deliverable:

- joint verdict: mergeable? with which pre-merge asks?
- where both reviews agree (independently verified);
- divergences, each with your ruling and the code evidence;
- cheap pre-merge fixes vs follow-ups.

Completion: consolidated review delivered with every divergence explicitly ruled on, ending with the offer to post it to the MRs/ticket.
