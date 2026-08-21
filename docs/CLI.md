# CLI policy and inventory

CLIs are included as first-class dependencies, but not as duplicate defaults for every SaaS provider.

## Required

`codex`, `git`, `node`, `npm`, `npx`, `python3`, `jq`, `rg`, and `curl` support the installer, local scripts, and MCP launchers.

## Recommended

- `gh`: current-checkout GitHub work, PR discovery, Actions logs, and authenticated repository operations.
- `claude`: runtime under the Claude Code MCP bridge and optional direct human CLI use.
- `uv`: isolated Python tools and Python-heavy skills.
- `ffmpeg` and `ffprobe`: media skills.
- `docker`: repositories that require containers.
- `pnpm` and `bun`: only when the target repository uses them.
- `agent-browser`: explicit portable/recorded browser sessions; Browser and Chrome plugins remain primary for normal Codex browser work.
- `scrapecreators`: batch and shell pipelines; MCP remains primary for agent calls.
- `letsfg`: authentication and manual workflows; MCP remains primary for agent calls.
- `mlxfast`: the MLXFast challenge workflow.

The exact machine snapshot is recorded in `config/cli-manifest.json`. Versions are evidence of what was audited, not global minimums.

## Installation boundary

`install.zsh` reports missing CLIs but does not run Homebrew, npm global installs, curl-to-shell installers, or privilege escalation. The recipient or their package-management policy owns those choices.

## Routing examples

| Task | Interface |
|---|---|
| Read or update a structured SaaS record | MCP/plugin |
| Inspect the checked-out branch or local diff | `git` |
| Inspect Actions for the current repository | `gh` |
| Build, test, debug, or deploy local code | Repository CLI |
| Run repeatable high-volume batch enrichment | Provider API or approved CLI script |
| Normal authenticated Chrome work | Chrome plugin |
| Recorded or remote-CDP browser session | `agent-browser` |
