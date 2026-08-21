---
name: delegate-to-claude
description: Delegate a task from Codex to the real Claude Code harness through the configured claude-code MCP and manage it as an external sub-agent. Use when the user asks Codex to ask, use, send work to, or get a second opinion from Claude, Fable, Opus, or Sonnet; requests a Claude sub-agent; or wants a Claude session launched, monitored, continued, interrupted, or cancelled.
---

# Delegate to Claude

Use the configured `claude-code` MCP directly. Treat Claude as an external MCP-managed session, not as a native Codex collaboration child.

## Route unambiguously

- Call `claude_code` directly. Do not spawn a native Codex sub-agent merely to operate the bridge.
- Do not invoke the `claude` shell command or a Compound Engineering cross-model script unless the user explicitly requests that mechanism.
- Map model requests to the top-level MCP `model` field:
  - Fable or Fable 5 -> `fable`
  - Opus or Opus 5 -> `opus`
  - Sonnet -> `sonnet`
- Prefer these aliases over full model names. If the user omits a model, state that Claude Code will choose its configured default.
- Do not confuse a model name with a custom Claude agent name. Expose Claude's nested-agent tool only when the user separately asks Claude to run its own nested agents, and use the exact name from the runtime tool catalog rather than guessing `Task` or `Agent`.

## Start safely

Give Claude a self-contained prompt, the correct `cwd`, and this appended system instruction:

> You are an external Claude sub-agent delegated by Codex. Perform the task directly. Do not invoke Codex CLI, a Codex skill, or another Codex agent, and do not delegate the work back to Codex unless the user explicitly requests nested Codex delegation.

Set these defaults:

- `advanced.settingSources: ["project", "local"]` to preserve repository instructions while excluding the user's global Claude-to-Codex routing policy.
- Use `advanced.settingSources: []` for a fully isolated evaluator or reasoning-only test.
- `advanced.strictMcpConfig: true` and `advanced.mcpServers: {}` unless the task specifically needs a Claude-side MCP.
- `permissionRequestTimeoutMs: 300000` or greater.
- `advanced.persistSession: true` when follow-up turns are likely; otherwise use `false`.

Choose the smallest tool surface:

- Reasoning only: set `advanced.tools: []`, `allowedTools: []`, and `strictAllowedTools: true`. Omit `disallowedTools`; an empty visible catalog is already the hard boundary, and guessed deny-list names can fail validation.
- Read-only repository work: expose and strictly allow only `Read`, `Glob`, and `Grep`.
- Implementation: use an isolated git worktree unless the current Codex task already is one. Auto-allow only the required file tools. If `Bash` is necessary, expose it without blanket session approval and inspect each permission request before allowing it.
- Never approve publishing, pushing, credential access, destructive commands, or external side effects unless the user authorized them.
- When an optional tool name matters, retrieve the runtime catalog with `claude_code_setup` or a check call that includes tools before constructing the allowlist.

## Monitor and continue

1. Retain the returned `sessionId`, `resumeToken`, and event cursor.
2. Poll with `claude_code_check` until `idle`, `error`, or `cancelled`; do not treat session creation as completion.
3. Use a compact response mode and long-poll waits no longer than about 45 seconds so permission requests are seen before expiry.
4. Review pending permission actions narrowly. Do not use broad `allow_for_session` for shell access.
5. Use `claude_code_reply` with the same session for follow-ups. Use `claude_code_session` to inspect, interrupt, cancel, or clean it.

## Verify and report

- Verify the selected model from returned model-usage metadata when available. Do not rely on Claude's self-identification or the requested model string alone.
- If the actual model differs from the requested model, disclose the mismatch.
- Attribute findings to Claude and distinguish them from Codex's verification.
- Report the terminal status and any unapproved permission denials.
- Session continuity is scoped to the active Codex task because the local wrapper isolates each MCP process.
