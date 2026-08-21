# Setup-agent instructions

This repository installs a shared Codex tool profile. Treat authentication and the recipient's existing configuration as out of scope unless the user separately authorizes them.

1. Read `README.md`, `docs/INTERFACE-AUDIT.md`, `docs/AUTHENTICATION.md`, and `docs/ADDONS.md`.
2. Run `./install.zsh --check` before any write.
3. Report missing required commands and any existing plugin conflicts.
4. When authorized, run `./install.zsh --apply --full`.
5. Do not replace `~/.codex/config.toml`; merge only settings the user selects from `config/codex-baseline.toml.example`.
6. Never copy, print, commit, or request tokens. Leave OAuth to the recipient's browser and static keys to environment variables or their secret manager.
7. Restart Codex and use a fresh task before judging tool availability.
8. Run `./scripts/audit-repo.zsh` after installation.

Optional add-ons require a separately named user request. Never run `ocx init`, `ocx start`, `ocx service install`, `ocx codex-shim install`, or otherwise change Codex provider routing merely because OpenCodex was installed. Never star the OpenCodex repository or answer its star prompt affirmatively without explicit user consent.

Webflow MCP and Webflow skills are intentionally absent. Do not infer or reinstall them from cache, history, or old project files. This does not apply to Vercel Workflow.

Use MCP/plugins for structured SaaS operations, CLIs for local development and automation, and direct APIs only when the first two do not cover the requirement.
