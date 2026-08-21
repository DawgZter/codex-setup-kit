# Karim's Codex Setup Kit

This repository is a portable, secret-free export of Karim's reviewed Codex setup. It packages 63 deduplicated local skills, canonical MCP endpoints, supported Codex plugins, and the command-line dependencies those skills expect. It also catalogs optional Codex companions without silently installing or activating them.

It deliberately does **not** copy `~/.codex/config.toml`, OAuth state, Keychain entries, local app binaries, project trust records, task history, or tokens. Webflow MCP and Webflow skills are explicitly excluded. Vercel Workflow remains available through the Vercel plugin.

## Fast install

Clone the repository, then run:

```zsh
./install.zsh --check
./install.zsh --apply --full
```

`--check` is read-only. `--apply` adds this repository as a local Codex marketplace, installs `karim-codex-toolkit`, and copies 18 explicit-only skills without overwriting conflicts. `--full` also adds the Compound Engineering marketplace when needed and installs the supported plugins listed in `config/plugin-manifest.json`. The installer never overwrites `~/.codex/config.toml`, logs in to a service, or writes a secret.

Restart Codex after installation so a new task receives the refreshed skill and tool catalog. Authenticate MCPs when Codex prompts. Static-key services require the environment variables in `config/env.example`.

To hand the repo to another agent, use this prompt:

> Read `AGENTS.md` and `README.md` in this repository. Run `./install.zsh --check`, report missing dependencies and planned changes, then run `./install.zsh --apply --full`. Do not copy config files wholesale or handle credentials. Finish with `./scripts/audit-repo.zsh` and tell me which OAuth or environment-variable setup remains.

## What gets installed

- `karim-codex-toolkit`: 45 plugin-compatible skills plus 17 MCP definitions.
- `skills/explicit-only`: 18 skills installed locally so their model-invocation guard stays intact.
- Official plugins: browser, Chrome, computer use, GitHub, Gmail, Notion, Vercel, Codex Security, document/PDF/spreadsheet/presentation tools, visualization, computer history, Compound Engineering, and Zoom.
- Portable MCP launchers for the Claude Code bridge and LetsFG.

The installer checks CLIs but does not install package managers or system software on the recipient's behalf. See `docs/CLI.md` for required and optional commands.

## Optional Codex add-ons

OpenCodex is available as a pinned, explicit package install; CodexBar is available as an explicit macOS cask install; and the official OpenAI Codex repository is linked as the canonical upstream reference:

```zsh
./addons.zsh list
./addons.zsh info opencodex
./addons.zsh install opencodex
```

The OpenCodex command installs the package only. It does not run `ocx init`, start its proxy, install a background service or shim, or alter Codex routing. See `docs/ADDONS.md` for the safety boundary and the other tools considered.

## Authentication

OAuth MCPs should use their browser login. API-key MCPs receive only environment-variable names; values stay in the recipient's shell, password manager, or Keychain. See `docs/AUTHENTICATION.md`.

## Configuration policy

`config/codex-baseline.toml.example` is a merge reference, not a replacement config. The original setup contains machine-specific paths and credential-bearing URLs, so bulk copying it would be unsafe and brittle.

The routing rule is one primary interface per job:

- Use MCP or a supported plugin for routine structured SaaS work.
- Use a CLI for local repositories, builds, deployment, debugging, scripts, and pipelines.
- Use a direct API only for unsupported or deliberately high-volume custom work.

The reviewed decisions and fresh runtime evidence are in `docs/INTERFACE-AUDIT.md`.

## Updating

Vendor endpoints and package versions can change. Before publishing an update:

```zsh
./scripts/audit-repo.zsh
python3 /path/to/plugin-creator/scripts/validate_plugin.py plugins/karim-codex-toolkit
```

Update package pins only after a read-only startup test. Do not replace OAuth with tokens embedded in URLs.
