# Interface audit

Audit date: 2026-08-21. Source: the current `~/.codex/config.toml`, installed plugin inventory, current local skills, vendor documentation, and a fresh read-only `codex app-server` MCP status request.

The source had 21 configured MCP entries. Twelve initialized with tools in the fresh process; nine returned zero tools because they were disabled, logged out, missing static authentication, or failed to initialize. Internal plugin servers added another two healthy tool namespaces. “Configured” is therefore not treated as proof of callable access.

## Decisions

| Service | Fresh tools | Export decision | Primary interface | CLI role |
|---|---:|---|---|---|
| AgentEnrich | 0 | Keep pinned stdio MCP; requires recipient API key | MCP | None required |
| Bland | 0 | Keep vendor remote; repair recipient auth | MCP | Optional manual Bland workflows |
| Claude Code | 5 | Keep portable bridge; remove machine paths | MCP bridge | `claude` is the bridge runtime and remains useful directly for human CLI work |
| Computer Use | 0, disabled | Drop legacy MCP entry; install bundled plugin | Plugin | None |
| Context7 | 2 | Keep current remote OAuth endpoint | MCP | None |
| Context.dev | 2 | Keep pinned local MCP package with env auth | MCP | Direct API only for unsupported custom fetch flows |
| Exa | 2 | Replace local Keychain wrapper with hosted remote | MCP | None by default |
| Fathom | 9 | Replace `mcp-remote` bridge with direct vendor remote | MCP | None |
| Fibbler | 18 | Keep vendor OAuth remote | MCP | None |
| GitHits | 15 | Replace local npm server with hosted OAuth remote | MCP | `git`/`gh` remain primary for the current checkout and Actions logs |
| HeroUI Pro | 0 | Keep vendor remote with env-backed custom header | MCP | Framework CLI only for local project work |
| Instantly | 168 | Replace custom Keychain plus `mcp-remote` wrapper with direct vendor remote and env-backed header | MCP | Direct API only for deliberate batch jobs |
| LetsFG | 13 | Keep local MCP with portable launcher | MCP | Keep LetsFG CLI for login and manual workflows |
| LinkedIn automation | 0 | Exclude credential-bearing private URL from defaults; document recipient-specific registration | Optional MCP | None |
| MoltSets | 0 | Keep optional vendor OAuth remote | MCP | None |
| Node REPL | 3 | Exclude host-bundled app binary and machine environment | Bundled Codex runtime | `node` remains required for scripts |
| OpenAI developer docs | 5 | Keep official remote | MCP | `codex` CLI for local Codex operations |
| ReUI | 18 | Move from bearer-token legacy path to canonical OAuth remote | MCP | ReUI CLI/skill only for local component installation |
| ScrapeCreators | 0 | Prefer vendor OAuth remote; retain CLI for batch/shell use | MCP | Optional `scrapecreators` CLI |
| Vector | 0 | Keep optional vendor OAuth remote | MCP | None |
| Zoom local bridge | 0 | Remove non-portable custom bridge; install `zoom@openai-curated` | Plugin | None |
| Webflow | absent | Explicitly excluded; do not restore from history or caches | None | None |

Vercel Workflow is unrelated to the removed Webflow integration and remains supplied by `vercel@openai-curated`.

## Security and portability findings

1. The source config contains a credential-bearing custom LinkedIn MCP URL. It is not exported. If the original config has ever been shared, rotate that credential.
2. The source config also contains a private local router URL with a credential-like path segment. The router, model catalog, and URL are machine-specific and are not exported.
3. Four MCP launchers used absolute paths under one macOS user account. They were replaced by direct vendor remotes or portable `command -v` launchers.
4. The source used unrestricted sandboxing and no approvals. The baseline example uses `workspace-write` and `on-request`; recipients can consciously choose otherwise.
5. OAuth state, Keychain values, project trust, task history, memory data, local app paths, and plugin caches are not configuration artifacts and are excluded.
6. Four local skill names existed in both skill roots through symlinks. The repository contains one resolved copy of each, for 63 unique skills total.
7. The personal Chrome selector was parameterized; it no longer hard-codes Karim's work or personal email.
8. Eighteen explicit-only skills cannot be plugin-loaded without weakening their invocation guard. They remain local-skill installs; 45 compatible skills are plugin-loaded.

## Current-source guidance

- [Codex plugin structure and repository marketplaces](https://developers.openai.com/codex/plugins/build-plugins)
- [Bland MCP](https://docs.bland.ai/integrations/mcp/overview)
- [Fathom MCP](https://developers.fathom.ai/mcp-docs)
- [Instantly MCP](https://developer.instantly.ai/mcp/quickstart)
- [Exa MCP](https://docs.exa.ai/reference/exa-mcp)
- [GitHits MCP setup](https://docs.githits.com/installation/automatic-setup)
- [HeroUI Pro MCP](https://heroui.pro/docs/react/getting-started/mcp-server)
- [ReUI with Codex](https://reui.io/docs/codex)
- [ScrapeCreators MCP](https://docs.scrapecreators.com/integrations/mcp)
- [Fibbler MCP](https://www.fibbler.co/docs/mcp/getting-started)
- [LetsFG packages](https://letsfg.co/developers/docs/packages)
- [AgentEnrich MCP](https://agentenrich.com/mcp)
- [MoltSets MCP](https://developer.moltsets.com/integrations/moltsets-mcp)

Package pins in `.mcp.json` are the reviewed snapshot, not an instruction to remain frozen forever. Update them only after documentation review, initialization, `tools/list`, and one harmless read-only tool call.
