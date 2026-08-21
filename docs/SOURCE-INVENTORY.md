# Source inventory

## Bundled here

- 63 unique local skills from the active user skill roots: 45 plugin-compatible and 18 explicit-only.
- 17 secret-free MCP definitions.
- Two portable local MCP launchers.
- A repository marketplace and plugin manifest.
- A read-only preflight, opt-in installer, and repository audit.
- Current official-plugin and CLI manifests.

The plugin and explicit-only directories are the authoritative skill inventory:

```zsh
find plugins/karim-codex-toolkit/skills -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
find skills/explicit-only -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
```

## Referenced, not copied

Supported vendor-managed plugins remain vendor-managed so the recipient receives current versions: the OpenAI bundled/curated runtime plugins, Compound Engineering, and Zoom.

## Explicit-only skill handling

Eighteen skills intentionally set `disable-model-invocation: true`. The plugin ingestion contract rejects that value, so changing it would make explicitly gated workflows auto-trigger. The installer instead copies these skills into the recipient's local skill root and refuses to overwrite a differing existing skill.

## Excluded

- Webflow MCP and Webflow skills.
- Plugin caches and system skills.
- The host-bundled Node REPL and legacy Computer Use MCP entry.
- The custom local Zoom MCP bridge.
- Credential-bearing LinkedIn automation URL.
- Local model router, model catalog, and private base URL.
- OAuth state, Keychain records, API keys, cookies, browser profiles, and session files.
- Absolute paths, app-bundle paths, project trust records, task history, memory data, and notifications.
- Duplicate symlink copies of `context-dev`, `hubspot-feedback`, `impeccable`, and `prospecting-assistant`.

## Intentional personal-to-portable change

The `select-adapt-chrome` skill is retained because its safety boundary is useful, but its two hard-coded account emails were replaced with `CODEX_WORK_CHROME_EMAIL` and `CODEX_PERSONAL_CHROME_EMAIL`.
