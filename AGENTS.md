<!-- BEGIN:multi-model-routing-policy -->

# Multi-Model Task Routing Policy

This project routes work across multiple models using Kilo's current agent/subagent
system (primary agents + Task-tool subagents). The deprecated Orchestrator mode is not
used anywhere in this configuration.

## Model roles and exact IDs

These IDs are reused as-is from the existing provider configuration
(`~/.config/kilo/kilo.jsonc`, `provider.foundry-claude` and `provider.bh-vllm-a100`).
Nothing about providers, APIM/Azure AI Foundry endpoints, auth headers, or model
definitions was changed to build this routing policy.

| Role | Model ID | Notes |
|---|---|---|
| Sonnet 5 | `foundry-claude/claude-sonnet-5` | Primary/default coding model |
| Opus 5 | `foundry-claude/claude-opus-5` | Deep engineering specialist |
| Fable 5 | `foundry-claude/claude-fable-5` | Highest escalation tier |
| Local Qwen | `bh-vllm-a100/qwen3.8-27b` | Optional local model, not guaranteed online |

GPT-6 is intentionally not configured anywhere in this project.

## Agent architecture

```
Kilo Code
|
+-- Code / Sonnet 5                        (foundry-claude/claude-sonnet-5)
|   |
|   +-- local-explore / Qwen (optional)     (bh-vllm-a100/qwen3.8-27b, subagent, read-only)
|   +-- local-worker / Qwen (optional)      (bh-vllm-a100/qwen3.8-27b, subagent)
|   +-- built-in Explore / Sonnet fallback  (no model override -- inherits normal default)
|   +-- deep-engineer / Opus 5              (foundry-claude/claude-opus-5, subagent)
|   +-- frontier-coder / Fable 5            (foundry-claude/claude-fable-5, subagent)
|
+-- Plan / Opus 5                           (foundry-claude/claude-opus-5)
|
+-- Debug / Sonnet 5                        (foundry-claude/claude-sonnet-5)
```

Primary agents (selectable directly): `code`, `plan`, `debug` (mapped in
`.kilo/kilo.json` for this project). Custom subagents (invoked only via the Task tool
by a primary agent): `local-explore`, `local-worker`, `deep-engineer`, `frontier-coder`
(defined in `.kilo/agent/*.md`). The built-in `explore` subagent is deliberately left
unconfigured so it keeps using the normal cloud/default model path.

## Routing priority

When local Qwen is available:

```
Qwen -> Sonnet 5 -> Opus 5 -> Fable 5
```

When local Qwen is unavailable:

```
Sonnet 5 -> Opus 5 -> Fable 5
```

Do not mechanically escalate every task through every tier. Always use the cheapest
capable model for the task at hand.

| Task type | First choice | If unavailable |
|---|---|---|
| Repository exploration, locating files/symbols, tracing dependencies, summarization | `local-explore` (Qwen) | built-in `explore` / Sonnet |
| Simple repetitive edits, docs, simple tests, formatting, lint fixes, basic CRUD | `local-worker` (Qwen) | Sonnet (primary `code` agent) |
| Normal coding: implementation, APIs, normal debugging, multi-file changes, normal refactoring | Sonnet (primary `code`/`debug` agent) | -- |
| Difficult architecture, difficult debugging, concurrency, distributed systems, complex migrations, performance, security-sensitive design, large/complex refactors | `deep-engineer` (Opus 5) | -- |
| Exceptionally difficult / long-horizon / very large cross-system work, or Sonnet/Opus failed | `frontier-coder` (Fable 5) | -- |

## Approved sibling repositories for `local-explore`

`local-explore` in this repo (`netlify-kontent-custom-element-ckeditor`) is additionally approved, via a scoped
`permission.external_directory` allow-list in `.kilo/agent/local-explore.md`, to
read/glob/grep the following sibling repositories under `/Users/nattawat/Repos` (and their
descendants) for cross-repo investigation and dependency tracing. Every other external
path is denied. Access to these sibling repos remains strictly read-only (no
edit/write/delete/bash), same as within this project.

| Repo | Path |
|---|---|
| `LifestyleTech` | `/Users/nattawat/Repos/LifestyleTech` |
| `bh-algolia-ai-search` | `/Users/nattawat/Repos/bh-algolia-ai-search` |
| `bh-cowork-app` | `/Users/nattawat/Repos/bh-cowork-app` |
| `bh-smart-appointment` | `/Users/nattawat/Repos/bh-smart-appointment` |
| `bot-visibility-extension` | `/Users/nattawat/Repos/bot-visibility-extension` |
| `claude-usage-analyzer-aca` | `/Users/nattawat/Repos/claude-usage-analyzer-aca` |
| `edgeoptimize` | `/Users/nattawat/Repos/edgeoptimize` |
| `jiramvc-http-proxy-middleware` | `/Users/nattawat/Repos/jiramvc-http-proxy-middleware` |
| `line-liff-project` | `/Users/nattawat/Repos/line-liff-project` |
| `vllm-to-apim-migration` | `/Users/nattawat/Repos/vllm-to-apim-migration` |
| `vtl-website-frontend` | `/Users/nattawat/Repos/vtl-website-frontend` |
| `GemmaApp` | `/Users/nattawat/Repos/GemmaApp` |
| `GemmaApp_build` | `/Users/nattawat/Repos/GemmaApp_build` |
| `ai-realtime-translate-project` | `/Users/nattawat/Repos/ai-realtime-translate-project` |
| `bumrungrad-clone` | `/Users/nattawat/Repos/bumrungrad-clone` |
| `llmtrain` | `/Users/nattawat/Repos/llmtrain` |
| `vtl-website-enhance` | `/Users/nattawat/Repos/vtl-website-enhance` |

## Behavior expected of the primary Sonnet (`code`) agent

- Delegate repository discovery to `local-explore` when it would save expensive cloud
  context (repo search, locating files/symbols, tracing dependencies, summarizing
  multiple files) instead of reading the entire repository itself.
- `local-explore` may inspect any of the approved sibling repositories listed above
  (and their descendants). Use `local-explore` for cross-repo investigation and
  dependency tracing between this repo and those sibling repos instead of reading them
  yourself.
- Never depend on Qwen's availability. If a call to `local-explore` or `local-worker`
  fails for a connectivity- or model-availability-shaped reason -- connection refused,
  timeout, provider unavailable, model unavailable, malformed response, tool-call
  incompatibility, or any similar failure -- do not stop the task and do not retry Qwen
  repeatedly. Silently continue with the built-in `explore` agent or do the work
  directly as Sonnet instead. Do not stop to ask the user what to do in this case.
- An `external_directory` permission failure is NOT a Qwen connectivity failure and
  must not be treated as one. It means a tool call tried to access a path outside both
  this workspace and the approved sibling-repo allow-list above. Do not fall back to
  Sonnet, and do not treat this as "the sibling repo is unreachable," merely because a
  sibling repo is outside the workspace -- every repo listed above is explicitly
  permitted. If this denial happens for a path genuinely outside scope (neither this
  workspace nor an approved sibling repo), report the out-of-scope path back rather
  than silently retrying it elsewhere or escalating.
- Reserve the Sonnet/built-in-`explore` fallback strictly for actual Qwen/provider
  failures: connection refused, timeout, provider/model unavailable, malformed
  response, tool-call incompatibility, or inference failure. Do not use it as a
  catch-all for permission or scope errors.
- Integrate subagent results yourself; subagents report findings back to you, they do
  not act independently on the user's behalf.
- Escalate to `deep-engineer` (Opus 5) only when a problem genuinely requires deeper
  reasoning than routine implementation -- difficult architecture, difficult
  debugging, concurrency, distributed systems, complex migrations, performance, or
  security-sensitive design.
- Escalate to `frontier-coder` (Fable 5) only for exceptionally difficult tasks,
  long-horizon autonomous work, very large cross-system changes, or when Sonnet/Opus
  already failed to reach a reliable result. Treat Fable as the highest-cost tier and
  do not use it for routine escalation.

## Qwen fallback: how it works, and its limitations

Kilo's config format has no built-in automatic model-failover or retry-on-connectivity-
failure mechanism (there is no "fallback model" field in the agent/provider schema).
Fallback here is therefore enforced entirely through instructions, not through a native
runtime feature:

- `local-explore` and `local-worker` are ordinary Task-tool subagents pinned to
  `bh-vllm-a100/qwen3.8-27b`.
- If the Qwen backend is offline or errors, the Task-tool call itself fails and that
  failure is returned to the calling primary agent (Sonnet) as a normal tool error.
- The calling agent's own instructions (in this file and in each subagent's
  `description`) tell it to treat that failure as non-fatal: do not retry Qwen
  repeatedly, and immediately continue using the built-in `explore` agent or its own
  (Sonnet) capabilities instead.
- Because this is instruction-driven rather than a config-level failover, it depends on
  the primary agent actually following these instructions on each call. There is no
  guarantee at the framework level that a future primary-agent change (e.g. a different
  system prompt) will preserve this behavior; it must be kept in `AGENTS.md` and in the
  subagent descriptions for it to keep working.
- A Qwen outage never blocks task completion: worst case, work that could have been
  cheap (via Qwen) is simply done by Sonnet instead, at higher cost but with no loss of
  functionality.

## Routing visibility

Whenever you delegate work to a subagent, briefly state which subagent
you are using and why before invoking it.

Examples:
- "Using local-explore (Qwen) for repository discovery."
- "Using deep-engineer (Opus 5) for architecture analysis."
- "Using frontier-coder (Fable 5) because the problem requires highest-tier reasoning."

Do not expose hidden reasoning. Only state the selected agent/model and a short reason.

<!-- END:multi-model-routing-policy -->
