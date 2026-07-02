# Model routing — protect the Fable budget

The main loop runs Fable at "high" effort (xhigh is token-hungry; max is a
furnace with worse outputs). Fable plans, decides, reviews, and integrates.
Cheaper models execute. Fable reads conclusions — never raw file dumps, log
trawls, or browser screenshots.

## Picking the right models for workflows and subagents

Rankings, higher = better. Cost reflects what I actually pay (Codex rides a
ChatGPT plan with plenty of headroom), not list price. Intelligence is how
hard a problem you can hand the model unsupervised. Taste covers UI/UX, code
quality, API design, and copy.

| model           | cost | intelligence | taste |
|-----------------|------|--------------|-------|
| gpt-5.5 (codex) | 8    | 8            | 5     |
| sonnet          | 5    | 5            | 7     |
| opus            | 4    | 7            | 8     |
| fable           | 2    | 9            | 9     |

How to apply:

- These are defaults, not limits. You have standing permission to override
  them: if a cheaper model's output doesn't meet the bar, rerun or redo the
  work with a smarter model without asking. Judge the output, not the price
  tag. Escalating costs less than shipping mediocre work.
- Cost is a tie-breaker only; when axes conflict for anything that ships,
  intelligence > taste > cost.
- Bulk/mechanical work (clear-spec implementation, data analysis, migrations):
  gpt-5.5 via the codex-implementation skill.
- Anything user-facing (UI, copy, API design) needs taste ≥ 7.
- Reviews of plans/implementations: fable or opus, optionally gpt-5.5
  (codex-review skill) as an extra independent perspective.
- Computer use and browser verification of UI/UX work: Codex is better and
  cheaper at this — use the codex-computer-use skill.
- Codebase exploration/analysis: Explore subagent on sonnet; for whole-repo
  huge-context questions, the gemini CLI. Never grep/read-sweep in the main
  loop.
- Haiku only for throwaway fan-out where a wrong answer is cheap; never for
  anything that ships.

Mechanics:

- gpt-5.5 is only reachable through the Codex CLI — `codex exec` /
  `codex review` (~/.codex/config.toml defaults to gpt-5.5 at xhigh). Use the
  codex-implementation, codex-review, and codex-computer-use skills; for work
  they don't cover (investigation, data analysis), run
  `codex exec -s read-only` directly with a self-contained prompt.
- Claude models (sonnet, opus, fable) run via the Agent/Workflow model
  parameter.

Using gpt-5.5 inside workflows and subagents (the model parameter only takes
Claude models, so use a wrapper):

- Spawn the codex-delegate agent — a thin sonnet wrapper at low effort whose
  job is to write a self-contained codex prompt, run `codex exec` via Bash,
  and return Codex's final message. Fable is not involved until the work is
  done.
- In Workflow scripts: `agent(taskSpec, {agentType: 'codex-delegate'})`.
