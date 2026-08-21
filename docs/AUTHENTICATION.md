# Authentication

Authentication is intentionally not portable. Installing this repository supplies definitions and instructions; it does not transfer access.

## OAuth on first use

The preferred path for Context7, Exa, Fathom, Fibbler, GitHits, MoltSets, ReUI, ScrapeCreators, and Vector is the provider's browser OAuth flow. Open a fresh Codex task after installation and invoke the relevant tool. If Codex reports `notLoggedIn`, complete the browser flow it offers. Where a plugin-owned MCP is visible to the CLI, `codex mcp login <server-name>` is also available.

## Static-key services

These MCPs use environment-variable names only:

| MCP | Variable | Transport |
|---|---|---|
| AgentEnrich | `AGENTENRICH_API_KEY` | Inherited by the local stdio process |
| Bland | `BLAND_API_KEY` | `Authorization: Bearer ...` |
| Context.dev | `CONTEXT_DEV_API_KEY` | Inherited by the local stdio process |
| HeroUI Pro | `HEROUI_PERSONAL_TOKEN` | `x-heroui-personal-token` header |
| Instantly | `INSTANTLY_API_KEY` | `Authorization` header as required by Instantly |
| LetsFG | `LETSFG_API_KEY` or `LETSFG_BEARER_TOKEN` | Inherited by the local stdio process |

Use the recipient's password manager, Keychain integration, or shell startup mechanism. Do not put values into `.mcp.json`, `config.toml`, a Git remote, a command-line argument, or a URL query string.

`config/env.example` is only a variable-name checklist. Do not commit a populated copy.

## Recipient-specific LinkedIn automation

The source endpoint embedded a signed account token in its URL and was not safe to export. If the recipient is authorized for that private integration, obtain a fresh endpoint directly from its provider and register it locally:

```zsh
codex mcp add linkedin-automation --url "$LINKEDIN_AUTOMATION_MCP_URL"
```

Treat the entire environment variable as a secret. Never paste the resulting URL into an issue, chat transcript, or repository.

## Verification standard

After authentication, restart Codex or open a fresh task, then verify all three layers:

1. The MCP initializes.
2. `tools/list` returns the expected tools.
3. One harmless read-only call returns account-scoped data.

An entry in `config.toml`, `bearerToken`, or a completed browser redirect alone is not proof that the integration works.
